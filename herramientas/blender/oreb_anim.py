"""Utilidades comunes para generar las animaciones de OREBOUND con Blender (bpy).

Convención de rotaciones (grados, igual para todas las animaciones; ver LEEME.md):
  Torso, cadera y cabeza (LowerTorso, UpperTorso, Head):
    X negativo = inclinarse hacia delante | Y positivo = girar hacia la izquierda del personaje | Z = ladearse
  Brazos y piernas (UpperArm, LowerArm, Hand, UpperLeg, LowerLeg, Foot):
    X negativo = hacia delante / arriba (hombro -150 = brazo por encima de la cabeza; codo negativo = flexionar)
    Rodilla: X positivo = flexionar (la pierna se dobla hacia atrás)
    Z positivo = separar del cuerpo (en los dos lados) | Y = giro del miembro (espejado en el lado izquierdo)
Los ángulos se aplican en el marco del personaje de Roblox (X derecha, Y arriba, Z atrás) y se convierten a los
ejes locales de cada hueso del rig, sean cuales sean sus «roll». Por eso sirve igual el rig provisional y el oficial.
"""

import json
import math
import os

import bpy
from mathutils import Euler, Matrix, Quaternion, Vector

HUESOS = [
    "LowerTorso", "UpperTorso", "Head",
    "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
]
RAIZ = "HumanoidRootPart"
SUPERIORES = {"UpperTorso", "Head", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperArm", "LeftLowerArm", "LeftHand"}
EJE = {"LowerTorso", "UpperTorso", "Head"}

# Rangos permitidos (mín, máx) por eje en la convención de arriba.
RANGOS = {
    "LowerTorso": ((-25, 25), (-20, 20), (-15, 15)),
    "UpperTorso": ((-25, 25), (-40, 40), (-15, 15)),
    "Head": ((-20, 20), (-30, 30), (-15, 15)),
    "UpperArm": ((-150, 90), (-60, 60), (-30, 90)),
    "LowerArm": ((-140, 0), (-10, 10), (-10, 10)),
    "Hand": ((-45, 45), (-45, 45), (-45, 45)),
    "UpperLeg": ((-110, 30), (-30, 30), (-20, 45)),
    "LowerLeg": ((0, 120), (-10, 10), (-10, 10)),
    "Foot": ((-30, 30), (-15, 15), (-15, 15)),
}
TOLERANCIA = 1.0  # grados


def rango(hueso):
    if hueso in RANGOS:
        return RANGOS[hueso]
    return RANGOS[hueso.replace("Right", "").replace("Left", "")]


# ---------------------------------------------------------------- marco del personaje

def marco(arm):
    """Matriz 3x3 cuyas columnas son los ejes de Roblox (X derecha, Y arriba, Z atrás) en el espacio del armature."""
    b = arm.data.bones
    derecha = (b["RightUpperArm"].head_local - b["LeftUpperArm"].head_local).normalized()
    arriba = (b["Head"].head_local - b["LowerTorso"].head_local)
    arriba = (arriba - derecha * arriba.dot(derecha)).normalized()
    atras = derecha.cross(arriba).normalized()
    return Matrix((derecha, arriba, atras)).transposed()


def sem_a_cuerpo(hueso, x, y, z):
    rx, ry, rz = math.radians(x), math.radians(y), math.radians(z)
    if hueso in EJE:
        e = (rx, ry, rz)
    else:
        lado = -1 if hueso.startswith("Left") else 1
        e = (-rx, lado * ry, lado * rz)
    return Euler(e, "ZYX").to_matrix()


def cuerpo_a_sem(hueso, r):
    e = r.to_euler("ZYX")
    if hueso in EJE:
        v = (e.x, e.y, e.z)
    else:
        lado = -1 if hueso.startswith("Left") else 1
        v = (-e.x, lado * e.y, lado * e.z)
    return tuple(math.degrees(a) for a in v)


def a_local(arm, M, hueso, angulos):
    reposo = arm.data.bones[hueso].matrix_local.to_3x3()
    ra = M @ sem_a_cuerpo(hueso, *angulos) @ M.transposed()
    return (reposo.inverted() @ ra @ reposo).to_quaternion()


def de_local(arm, M, hueso, q):
    reposo = arm.data.bones[hueso].matrix_local.to_3x3()
    ra = reposo @ q.to_matrix() @ reposo.inverted()
    return cuerpo_a_sem(hueso, M.transposed() @ ra @ M)


# ---------------------------------------------------------------- construcción de una animación

def _altura_pies(arm, M):
    arriba = M.col[1]
    alturas = []
    for pie in ("RightFoot", "LeftFoot", "RightLowerLeg", "LeftLowerLeg"):
        pb = arm.pose.bones[pie]
        alturas += [pb.head.dot(arriba), pb.tail.dot(arriba)]
    return min(alturas)


def construir(arm, nombre, spec):
    """Crea el action con las poses clave de spec. Devuelve el action."""
    M = marco(arm)
    escena = bpy.context.scene
    for pb in arm.pose.bones:
        pb.rotation_mode = "QUATERNION"
        pb.rotation_quaternion = Quaternion()
        pb.location = Vector()
    bpy.context.view_layer.update()
    suelo = _altura_pies(arm, M)

    accion = bpy.data.actions.new(nombre)
    accion.use_fake_user = True
    arm.animation_data_create()
    arm.animation_data.action = accion

    superior = spec["superior"]
    huesos = [h for h in HUESOS if (h in SUPERIORES or not superior)]
    previo = {}
    for frame, pose in spec["claves"]:
        for h in huesos:
            angulos = pose.get(h, (0, 0, 0))
            q = a_local(arm, M, h, angulos)
            if h in previo:
                q.make_compatible(previo[h])
            previo[h] = q
            pb = arm.pose.bones[h]
            pb.rotation_quaternion = q
        if not superior:
            # Pies en el suelo: LowerTorso baja (solo en vertical) lo que suben los pies al doblar las piernas.
            lt = arm.pose.bones["LowerTorso"]
            lt.location = Vector()
            bpy.context.view_layer.update()
            baja = _altura_pies(arm, M) - suelo
            reposo = arm.data.bones["LowerTorso"].matrix_local.to_3x3()
            lt.location = reposo.inverted() @ (-M.col[1] * baja)
            lt.keyframe_insert("location", frame=frame)
        for h in huesos:
            arm.pose.bones[h].keyframe_insert("rotation_quaternion", frame=frame)
        bpy.context.view_layer.update()

    for fc in _curvas(accion):
        for k in fc.keyframe_points:
            k.interpolation = "BEZIER"
            k.handle_left_type = k.handle_right_type = "AUTO_CLAMPED"
        if spec["loop"]:
            fc.modifiers.new("CYCLES")
        fc.update()

    escena.frame_start = 0
    escena.frame_end = spec["frames"] - 1
    escena.render.fps = 30
    escena.render.fps_base = 1.0
    poner_marcadores(accion, spec)
    return accion


def _curvas(accion):
    if hasattr(accion, "fcurves") and len(accion.fcurves) > 0:
        return list(accion.fcurves)
    curvas = []  # Blender 4.4+: actions por capas
    for capa in getattr(accion, "layers", []):
        for tira in capa.strips:
            for bolsa in tira.channelbags:
                curvas += list(bolsa.fcurves)
    return curvas


def poner_marcadores(accion, spec):
    escena = bpy.context.scene
    escena.timeline_markers.clear()
    for m in list(accion.pose_markers):
        accion.pose_markers.remove(m)
    for nombre, frame in spec.get("marcadores", {}).items():
        escena.timeline_markers.new(nombre, frame=frame)
        pm = accion.pose_markers.new(nombre)
        pm.frame = frame


# ---------------------------------------------------------------- comprobaciones

def _angulo(a, b):
    """Ángulo entre dos rotaciones (q y -q son la misma)."""
    ang = a.rotation_difference(b).angle
    return min(ang, 2 * math.pi - ang)


def comprobar(arm, nombre, spec):
    """Devuelve la lista de errores (vacía si todo está bien)."""
    M = marco(arm)
    errores = []
    escena = bpy.context.scene
    n = spec["frames"]
    excepciones = spec.get("excepciones", {})
    for frame in range(n):
        escena.frame_set(frame)
        for h in HUESOS:
            pb = arm.pose.bones[h]
            ang = de_local(arm, M, h, pb.rotation_quaternion)
            limites = excepciones.get(h, rango(h))
            for eje, valor, (lo, hi) in zip("XYZ", ang, limites):
                if valor < lo - TOLERANCIA or valor > hi + TOLERANCIA:
                    errores.append(f"frame {frame}: {h} {eje} = {valor:.1f} fuera de [{lo}, {hi}]")
    # Sin keys en la raíz; las [SUPERIOR] sin keys de cadera ni piernas; solo LowerTorso se traslada.
    for fc in _curvas(arm.animation_data.action):
        hueso = fc.data_path.split('"')[1] if '"' in fc.data_path else ""
        if hueso == RAIZ:
            errores.append("hay keys en HumanoidRootPart")
        if spec["superior"] and hueso not in SUPERIORES:
            errores.append(f"animación de parte superior con keys en {hueso}")
        if fc.data_path.endswith("location") and hueso != "LowerTorso":
            errores.append(f"traslación en {hueso}")
    # Marcadores
    reales = {m.name: m.frame for m in escena.timeline_markers}
    if reales != spec.get("marcadores", {}):
        errores.append(f"marcadores {reales} != {spec.get('marcadores', {})}")
    # Loop limpio / pose final
    def pose(frame):
        escena.frame_set(frame)
        return {h: arm.pose.bones[h].rotation_quaternion.copy() for h in HUESOS}
    primera, ultima = pose(0), pose(n - 1)
    if spec["loop"]:
        for h in HUESOS:
            if _angulo(primera[h], ultima[h]) > math.radians(0.5):
                errores.append(f"loop: {h} distinto en el primer y el último frame")
    else:
        final = spec.get("termina", {})
        for h in HUESOS:
            esperado = a_local(arm, M, h, final.get(h, (0, 0, 0)))
            if (h in SUPERIORES or not spec["superior"]) and _angulo(ultima[h], esperado) > math.radians(0.5):
                errores.append(f"pose final: {h} no está en {'guardia' if final else 'reposo'}")
    return errores


# ---------------------------------------------------------------- render y exportación

def render(ruta, frame):
    escena = bpy.context.scene
    escena.frame_set(frame)
    escena.render.filepath = ruta
    bpy.ops.render.render(write_still=True)


def exportar_fbx(arm, ruta, spec, escala="FBX_SCALE_NONE"):
    if arm.get("provisional"):
        raise RuntimeError("El rig provisional no se exporta nunca: carga el rig R15 oficial (--rig ruta.fbx)")
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    bpy.context.view_layer.objects.active = arm
    bpy.context.scene.frame_start, bpy.context.scene.frame_end = 0, spec["frames"] - 1
    bpy.ops.export_scene.fbx(
        filepath=ruta, use_selection=True, object_types={"ARMATURE"},
        apply_scale_options=escala, bake_space_transform=False,
        use_armature_deform_only=True, add_leaf_bones=False,
        bake_anim=True, bake_anim_use_all_bones=True, bake_anim_use_nla_strips=False,
        bake_anim_use_all_actions=False, bake_anim_force_startend_keying=True, bake_anim_step=1.0,
        bake_anim_simplify_factor=0.0,
    )


def guardar_marcadores(ruta, specs):
    datos = {}
    for nombre, s in specs.items():
        datos[nombre] = {"frames": s["frames"], "segundos": round(s["frames"] / 30, 3), "loop": s["loop"],
                         "superior": s["superior"], "marcadores": s.get("marcadores", {})}
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(datos, f, ensure_ascii=False, indent=2)
