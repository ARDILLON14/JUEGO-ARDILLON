# Animaciones de OREBOUND con Blender (combate y minería)

Generación por código (bpy): las poses clave están en `animaciones.py`; `generar.py` construye cada animación sobre el
rig, comprueba todas las reglas, hace hojas de previsualización y, con el rig oficial, exporta los FBX.

## Requisitos
- Blender 4.x (o el módulo `bpy` de Python: `pip install "bpy>=4.2,<5"` con Python 3.11) y `pillow` para las hojas.

## Uso
```bash
python herramientas/blender/generar.py --rig provisional --previas assets/animaciones/previas
python herramientas/blender/generar.py --rig ruta/R15.fbx --previas assets/animaciones/previas --solo mining_stance_loop --exportar assets/animaciones
```
- `--rig provisional`: rig aproximado construido por código (mismos nombres que el R15). Solo sirve para ver poses;
  **no se exporta nunca**.
- `--rig R15.fbx`: el rig oficial exportado desde Roblox Studio (Avatar → Rig Builder → R15 → clic derecho en el
  rig → «Export Selection…»).
- `--lote A`, `--solo a,b`: limitar qué animaciones se generan.
- Sin `--exportar` no se escribe ningún FBX. Solo se exportan animaciones sin errores.
- Siempre se reescribe `assets/animaciones/marcadores.json` (frames, segundos, loop y marcadores de cada animación):
  los marcadores de Blender no viajan a Roblox dentro del FBX, así que el código y los Animation Events de Studio
  salen de este archivo.

## Convención de ángulos (grados)
- Torso, cadera y cabeza: X negativo = inclinarse hacia delante; Y positivo = girar a la izquierda del personaje.
- Brazos y piernas: X negativo = hacia delante/arriba (hombro -150 = brazo sobre la cabeza; codo negativo = flexionar);
  rodilla X positivo = flexionar; Z positivo = separar del cuerpo; Y = giro del miembro (espejado en el lado izquierdo).
- Se aplican en el marco del personaje (X derecha, Y arriba, Z atrás) y se convierten a los ejes de cada hueso, sea cual
  sea su «roll»: sirve igual para el rig provisional y el oficial.

## Reglas que comprueba (todas las frames)
- Rangos por hueso (`oreb_anim.RANGOS`), incluida la interpolación entre poses.
- HumanoidRootPart sin keys. Solo LowerTorso puede trasladarse, y solo en vertical: baja lo que haga falta para que los
  pies sigan en el suelo al flexionar las piernas (sin esto no hay agacharse posible).
- Animaciones de parte superior: sin keys en LowerTorso ni piernas (se puede andar mientras se ataca o se pica).
- Marcadores exactos, loops limpios (primer frame = último) y pose final en reposo (o en guardia cuando se indica).

## Cambios respecto al prompt original de animación (decididos al programarlo)
- El arma del R15 sale perpendicular a la mano: para que la hoja o el pico apunten bien se usan la muñeca (±45°) y el giro
  del hombro. Los ángulos se calcularon para que la hoja vaya donde debe en cada pose clave.
- Bezier con «auto clamped» en todo y modificador Cycles en los loops (la exportación hornea cada frame).
- `combat_tech_spinning_slash` gira 360° en LowerTorso: es la única excepción de rango.
