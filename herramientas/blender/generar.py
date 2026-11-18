"""Genera, comprueba, previsualiza y (con el rig oficial) exporta las animaciones de OREBOUND.

Uso (con el Python que tiene bpy, o «blender -b -P generar.py -- ...»):
  python generar.py --rig provisional --previas DIR [--solo a,b] [--lote A]
  python generar.py --rig ruta/R15.fbx --previas DIR --exportar assets/animaciones [--solo a,b]
Sin --exportar no se escribe ningún FBX. El rig provisional no se exporta nunca.
"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import bpy  # noqa: E402

import animaciones  # noqa: E402
import oreb_anim  # noqa: E402
import rig_provisional  # noqa: E402

RAIZ_REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def cargar_rig(rig):
    if rig == "provisional":
        return rig_provisional.construir()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.fbx(filepath=rig)
    arms = [o for o in bpy.data.objects if o.type == "ARMATURE"]
    if len(arms) != 1:
        raise SystemExit(f"Se esperaba un armature en {rig} y hay {len(arms)}")
    arm = arms[0]
    faltan = [h for h in oreb_anim.HUESOS + [oreb_anim.RAIZ] if h not in arm.data.bones]
    if faltan:
        raise SystemExit("Faltan huesos del R15: " + ", ".join(faltan))
    rig_provisional.escena()
    return arm


def previas(arm, nombre, spec, carpeta):
    try:
        from PIL import Image, ImageDraw
    except ImportError:
        # Blender normal no trae Pillow: se dejan las imágenes sueltas en vez de la hoja.
        m = spec.get("marcadores", {})
        n = spec["frames"]
        for vista in ("frente", "lado"):
            rig_provisional.vista(vista)
            for f in sorted({0, m.get("hit", n // 2), n - 1}):
                oreb_anim.render(os.path.join(carpeta, f"{nombre}_{vista}_{f}.png"), f)
        return os.path.join(carpeta, nombre + "_*.png")
    m = spec.get("marcadores", {})
    n = spec["frames"]
    frames = sorted({0, m.get("hit", n // 2), m.get("cancel_ok", (n * 3) // 4), n - 1, max(1, m.get("hit", n // 2) - 3)})
    imagenes = []
    for vista in ("frente", "lado"):
        rig_provisional.vista(vista)
        fila = []
        for f in frames:
            ruta = os.path.join(carpeta, f"_{nombre}_{vista}_{f}.png")
            oreb_anim.render(ruta, f)
            fila.append((f, Image.open(ruta).convert("RGB")))
        imagenes.append(fila)
    w, h = imagenes[0][0][1].size
    hoja = Image.new("RGB", (w * len(frames), h * 2 + 40), (30, 32, 40))
    d = ImageDraw.Draw(hoja)
    marc = ", ".join(f"{k} {v}" for k, v in sorted(m.items(), key=lambda kv: kv[1]))
    d.text((8, 6), f"{nombre}  ·  {n} frames ({n / 30:.2f} s)  ·  {'LOOP' if spec['loop'] else 'no loop'}  ·  "
                   f"{'parte superior' if spec['superior'] else 'cuerpo entero'}  ·  {marc}", fill=(255, 230, 150))
    for r, fila in enumerate(imagenes):
        for c, (f, img) in enumerate(fila):
            hoja.paste(img, (c * w, 40 + r * h))
            etiquetas = [k for k, v in m.items() if v == f]
            d.text((c * w + 6, 40 + r * h + 4), f"frame {f} " + " ".join(etiquetas), fill=(20, 20, 20))
    for archivo in os.listdir(carpeta):
        if archivo.startswith(f"_{nombre}_"):
            os.remove(os.path.join(carpeta, archivo))
    salida = os.path.join(carpeta, f"{nombre}.png")
    hoja.save(salida)
    return salida


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:]
    p = argparse.ArgumentParser()
    p.add_argument("--rig", default="provisional")
    p.add_argument("--solo", default="")
    p.add_argument("--lote", default="")
    p.add_argument("--previas", default="")
    p.add_argument("--exportar", default="")
    p.add_argument("--escala", default="FBX_SCALE_NONE")
    a = p.parse_args(argv)

    nombres = list(animaciones.ANIMS)
    if a.lote == "A":
        nombres = animaciones.LOTE_A
    if a.solo:
        nombres = a.solo.split(",")

    arm = cargar_rig(a.rig)
    bpy.context.scene.render.fps, bpy.context.scene.render.fps_base = 30, 1.0
    print(f"Rig: {'PROVISIONAL' if arm.get('provisional') else a.rig} · fps {bpy.context.scene.render.fps}")
    resumen, total_errores = [], 0
    for nombre in nombres:
        spec = animaciones.ANIMS[nombre]
        if a.previas:
            rig_provisional.arma(arm, "Pico" if spec["categoria"] == "mining" else "Espada")
        oreb_anim.construir(arm, nombre, spec)
        errores = oreb_anim.comprobar(arm, nombre, spec)
        total_errores += len(errores)
        estado = "OK" if not errores else f"{len(errores)} ERRORES"
        print(f"{nombre:30s} {estado}")
        for e in errores[:12]:
            print("    " + e)
        if a.previas:
            os.makedirs(a.previas, exist_ok=True)
            print("    previa: " + previas(arm, nombre, spec, a.previas))
        if a.exportar and not errores:
            os.makedirs(a.exportar, exist_ok=True)
            ruta = os.path.join(a.exportar, f"OREBOUND_{nombre}.fbx")
            oreb_anim.exportar_fbx(arm, ruta, spec, a.escala)
            print("    exportada: " + ruta)
        resumen.append((nombre, spec))
    oreb_anim.guardar_marcadores(os.path.join(RAIZ_REPO, "assets", "animaciones", "marcadores.json"), animaciones.ANIMS)
    print()
    print(f"{'Nombre':30s} {'Frames':>6s} {'Seg':>5s} {'Loop':>5s} {'Parte':>9s}  Marcadores")
    for nombre, s in resumen:
        m = ", ".join(f"{k} {v}" for k, v in sorted(s.get("marcadores", {}).items(), key=lambda kv: kv[1]))
        print(f"{nombre:30s} {s['frames']:6d} {s['frames'] / 30:5.2f} {'sí' if s['loop'] else 'no':>5s} "
              f"{'superior' if s['superior'] else 'entero':>9s}  {m}")
    print(f"\nErrores en total: {total_errores}")
    return 1 if total_errores else 0


if __name__ == "__main__":
    sys.exit(main())
