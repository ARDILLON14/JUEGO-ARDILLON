"""Rig R15 PROVISIONAL para previsualizar poses mientras no está el rig oficial exportado desde Roblox Studio.

Mismos nombres de huesos y jerarquía que el R15, proporciones aproximadas (en studs), cajas como cuerpo,
y un arma de prueba (espada o pico) en la mano derecha. Lleva la marca «provisional»: oreb_anim.exportar_fbx se
niega a exportarlo.
"""

import bpy
from mathutils import Matrix, Vector

# Posiciones en el marco de Roblox (X derecha, Y arriba, Z atrás) -> Blender (personaje mirando a -Y).
def _bl(x, y, z):
    return Vector((-x, z, y))

# hueso: (padre, cabeza, cola, tamaño de la caja (ancho X, alto Y, fondo Z))
HUESOS = {
    "HumanoidRootPart": (None, (0, 2.1, 0), (0, 3.1, 0), None),
    "LowerTorso": ("HumanoidRootPart", (0, 2.1, 0), (0, 2.5, 0), (2.0, 0.4, 1.0)),
    "UpperTorso": ("LowerTorso", (0, 2.5, 0), (0, 4.1, 0), (2.0, 1.6, 1.0)),
    "Head": ("UpperTorso", (0, 4.1, 0), (0, 5.3, 0), (1.2, 1.2, 1.2)),
    "RightUpperArm": ("UpperTorso", (1.5, 3.9, 0), (1.5, 2.9, 0), (0.9, 1.2, 0.9)),
    "RightLowerArm": ("RightUpperArm", (1.5, 2.9, 0), (1.5, 1.95, 0), (0.85, 1.0, 0.85)),
    "RightHand": ("RightLowerArm", (1.5, 1.95, 0), (1.5, 1.6, 0), (0.8, 0.4, 0.8)),
    "LeftUpperArm": ("UpperTorso", (-1.5, 3.9, 0), (-1.5, 2.9, 0), (0.9, 1.2, 0.9)),
    "LeftLowerArm": ("LeftUpperArm", (-1.5, 2.9, 0), (-1.5, 1.95, 0), (0.85, 1.0, 0.85)),
    "LeftHand": ("LeftLowerArm", (-1.5, 1.95, 0), (-1.5, 1.6, 0), (0.8, 0.4, 0.8)),
    "RightUpperLeg": ("LowerTorso", (0.5, 2.1, 0), (0.5, 1.1, 0), (0.95, 1.1, 0.95)),
    "RightLowerLeg": ("RightUpperLeg", (0.5, 1.1, 0), (0.5, 0.25, 0), (0.9, 0.9, 0.9)),
    "RightFoot": ("RightLowerLeg", (0.5, 0.25, 0), (0.5, 0.05, -0.6), (0.9, 0.25, 1.3)),
    "LeftUpperLeg": ("LowerTorso", (-0.5, 2.1, 0), (-0.5, 1.1, 0), (0.95, 1.1, 0.95)),
    "LeftLowerLeg": ("LeftUpperLeg", (-0.5, 1.1, 0), (-0.5, 0.25, 0), (0.9, 0.9, 0.9)),
    "LeftFoot": ("LeftLowerLeg", (-0.5, 0.25, 0), (-0.5, 0.05, -0.6), (0.9, 0.25, 1.3)),
}

COLORES = {"Torso": (0.15, 0.35, 0.75, 1), "Head": (0.95, 0.8, 0.55, 1), "Arm": (0.95, 0.8, 0.55, 1),
           "Hand": (0.95, 0.8, 0.55, 1), "Leg": (0.2, 0.2, 0.25, 1), "Foot": (0.1, 0.1, 0.1, 1),
           "Espada": (0.8, 0.85, 0.95, 1), "Pico": (0.55, 0.4, 0.25, 1), "PicoCabeza": (0.6, 0.6, 0.65, 1)}


def _material(nombre):
    m = bpy.data.materials.get(nombre) or bpy.data.materials.new(nombre)
    m.diffuse_color = COLORES[nombre]
    return m


def _caja(nombre, arm, hueso, centro_bl, tam_bl, color, ejes=None):
    """Caja pegada a un hueso. centro_bl y tam_bl en el espacio del armature EN REPOSO; ejes: matriz 3x3 opcional."""
    malla = bpy.data.meshes.new(nombre)
    o = bpy.data.objects.new(nombre, malla)
    bpy.context.scene.collection.objects.link(o)
    import bmesh
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    bm.to_mesh(malla)
    bm.free()
    malla.materials.append(_material(color))
    o.color = COLORES[color]
    rot = (ejes or Matrix.Identity(3)).to_4x4()
    deseado = Matrix.Translation(centro_bl) @ rot @ Matrix.Diagonal((tam_bl[0], tam_bl[1], tam_bl[2], 1))
    b = arm.data.bones[hueso]
    espacio_hueso = b.matrix_local @ Matrix.Translation((0, b.length, 0))
    o.parent = arm
    o.parent_type = "BONE"
    o.parent_bone = hueso
    o.matrix_parent_inverse = Matrix.Identity(4)
    o.matrix_basis = espacio_hueso.inverted() @ deseado
    return o


def construir():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    datos = bpy.data.armatures.new("R15")
    arm = bpy.data.objects.new("R15", datos)
    bpy.context.scene.collection.objects.link(arm)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    for nombre, (padre, cabeza, cola, _) in HUESOS.items():
        b = datos.edit_bones.new(nombre)
        b.head, b.tail = _bl(*cabeza), _bl(*cola)
        if padre:
            b.parent = datos.edit_bones[padre]
    bpy.ops.object.mode_set(mode="OBJECT")
    arm["provisional"] = True

    for nombre, (_, cabeza, cola, tam) in HUESOS.items():
        if not tam:
            continue
        c = (Vector(cabeza) + Vector(cola)) / 2
        if nombre.endswith("Foot"):
            c = Vector((cabeza[0], 0.12, -0.35))
        color = ("Torso" if "Torso" in nombre else "Head" if nombre == "Head" else "Hand" if "Hand" in nombre
                 else "Arm" if "Arm" in nombre else "Foot" if "Foot" in nombre else "Leg")
        _caja("Caja_" + nombre, arm, nombre, _bl(*c), Vector((tam[0], tam[2], tam[1])), color)

    # Cara (visera oscura) para saber hacia dónde mira el personaje.
    _caja("Cara", arm, "Head", _bl(0, 4.85, -0.62), Vector((0.8, 0.08, 0.25)), "Foot")
    escena()
    return arm


def escena():
    """Suelo, cámara ortográfica y render Workbench para las previsualizaciones."""
    bpy.ops.mesh.primitive_plane_add(size=14, location=(0, 0, 0))
    bpy.context.active_object.name = "Suelo"
    e = bpy.context.scene
    e.render.engine = "BLENDER_WORKBENCH"
    e.display.shading.color_type = "OBJECT"
    e.display.shading.light = "STUDIO"
    e.display.shading.show_shadows = True
    e.render.resolution_x = 360
    e.render.resolution_y = 420
    cam = bpy.data.objects.new("Camara", bpy.data.cameras.new("Camara"))
    e.collection.objects.link(cam)
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 8.5
    e.camera = cam


def arma(arm, tipo):
    """Pone un arma de prueba (solo para ver) en la mano derecha: 'Espada' o 'Pico'. Devuelve los objetos."""
    import oreb_anim
    for o in [o for o in bpy.data.objects if o.get("arma_prueba")]:
        bpy.data.objects.remove(o)
    M = oreb_anim.marco(arm)
    mano = arm.data.bones["RightHand"]
    centro = (mano.head_local + mano.tail_local) / 2
    delante = -M.col[2]
    unidad = arm.data.bones["RightLowerArm"].length
    objs = []
    def caja(nombre, desplaz, tam, color):
        tam = Vector((tam[0] * unidad, tam[1] * unidad, tam[2] * unidad))
        o = _caja(nombre, arm, "RightHand", centro + delante * desplaz * unidad, tam, color, ejes=M)
        o["arma_prueba"] = True
        objs.append(o)
    if tipo == "Espada":
        caja("Espada", 2.1, (0.15, 0.35, 3.8), "Espada")
    elif tipo == "Pico":
        caja("PicoMango", 1.4, (0.2, 0.2, 2.9), "Pico")
        caja("PicoCabeza", 2.75, (0.25, 2.1, 0.3), "PicoCabeza")
    return objs


def vista(cual):
    """Coloca la cámara: 'frente' (3/4 delante-derecha del personaje) o 'lado' (perfil derecho)."""
    import math
    cam = bpy.context.scene.camera
    if cual == "frente":
        cam.location = (-7.0, -9.0, 4.2)
    else:
        cam.location = (-11.0, 0.0, 3.2)
    destino = Vector((0, 0, 2.7))
    d = destino - cam.location
    cam.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()
