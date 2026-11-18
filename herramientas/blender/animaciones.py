"""Especificación de las animaciones de COMBATE y MINERÍA de OREBOUND (fase de animación).

Cada animación: frames (0..N-1, 30 fps), loop, superior (solo parte de arriba: sin keys de cadera ni piernas),
claves [(frame, pose)], marcadores y, si no acaba en reposo, «termina» (pose final, p. ej. la guardia).
Una pose es {hueso: (X, Y, Z)} en grados con la convención de oreb_anim.py; lo que no aparece vale 0 (reposo).
Ritmo: espada 1,6 golpes/s (cancel_ok del combo en el frame 19 = 0,633 s); pico 1 golpe/s (el código acelera).
"""


def P(**h):
    return dict(h)


def mas(base, **h):
    d = dict(base)
    d.update(h)
    return d


REPOSO = {}

# Guardia: brazos delante de la cara, antebrazos verticales, espada cruzada.
GUARDIA = P(UpperTorso=(-5, 0, 0), Head=(-5, 0, 0),
            RightUpperArm=(-50, 0, 0), RightLowerArm=(-90, 0, 0), RightHand=(45, 45, 0),
            LeftUpperArm=(-55, 0, -20), LeftLowerArm=(-95, 0, 0))

# Pico al hombro (espera antes de picar).
HOMBRO = P(RightUpperArm=(-35, 0, 15), RightLowerArm=(-115, 0, 0), RightHand=(-20, 0, 0),
           LeftUpperArm=(-5, 0, 6), LeftLowerArm=(-10, 0, 0))

# Pico arriba, listo para golpear.
PICO_ARRIBA = P(UpperTorso=(8, 8, 0), Head=(4, 0, 0),
                RightUpperArm=(-135, 0, 10), RightLowerArm=(-75, 0, 0), RightHand=(-20, 0, 0),
                LeftUpperArm=(-30, 0, 15), LeftLowerArm=(-40, 0, 0))

ANIMS = {}

# ============================================================== MINERÍA

ANIMS["mining_stance_loop"] = dict(
    categoria="mining", frames=30, loop=True, superior=True,
    claves=[(0, mas(HOMBRO, UpperTorso=(2, 0, 0))),
            (15, mas(HOMBRO, UpperTorso=(-3, 0, 0), Head=(1, 0, 0), RightUpperArm=(-37, 0, 15))),
            (29, mas(HOMBRO, UpperTorso=(2, 0, 0)))],
    marcadores={})

ANIMS["mining_swing_loop"] = dict(
    categoria="mining", frames=30, loop=True, superior=True,
    claves=[(0, PICO_ARRIBA),
            (9, mas(PICO_ARRIBA, UpperTorso=(10, 10, 0), RightUpperArm=(-145, 0, 10), RightLowerArm=(-85, 0, 0))),
            (12, P(UpperTorso=(-15, -5, 0), Head=(-8, 0, 0), RightUpperArm=(-55, 0, 5), RightLowerArm=(-15, 0, 0),
                   RightHand=(45, 0, 0), LeftUpperArm=(15, 0, 20), LeftLowerArm=(-30, 0, 0))),
            (15, P(UpperTorso=(-12, -4, 0), Head=(-6, 0, 0), RightUpperArm=(-65, 0, 5), RightLowerArm=(-25, 0, 0),
                   RightHand=(40, 0, 0), LeftUpperArm=(10, 0, 18), LeftLowerArm=(-30, 0, 0))),
            (22, mas(PICO_ARRIBA, UpperTorso=(0, 4, 0), RightUpperArm=(-105, 0, 8), RightLowerArm=(-60, 0, 0))),
            (29, PICO_ARRIBA)],
    marcadores={"hit": 12})

ANIMS["mining_swing_down_loop"] = dict(
    categoria="mining", frames=30, loop=True, superior=True,
    claves=[(0, PICO_ARRIBA),
            (9, mas(PICO_ARRIBA, UpperTorso=(10, 10, 0), RightUpperArm=(-145, 0, 10), RightLowerArm=(-85, 0, 0))),
            (12, P(UpperTorso=(-25, -5, 0), Head=(-15, 0, 0), RightUpperArm=(-30, 0, 5), RightLowerArm=(-10, 0, 0),
                   RightHand=(45, 0, 0), LeftUpperArm=(10, 0, 20), LeftLowerArm=(-30, 0, 0))),
            (15, P(UpperTorso=(-22, -4, 0), Head=(-13, 0, 0), RightUpperArm=(-40, 0, 5), RightLowerArm=(-20, 0, 0),
                   RightHand=(40, 0, 0), LeftUpperArm=(8, 0, 18), LeftLowerArm=(-30, 0, 0))),
            (22, mas(PICO_ARRIBA, UpperTorso=(-4, 4, 0), RightUpperArm=(-100, 0, 8), RightLowerArm=(-60, 0, 0))),
            (29, PICO_ARRIBA)],
    marcadores={"hit": 12})

# ============================================================== COMBATE (espada en la mano derecha)

ANIMS["combat_combo1"] = dict(  # tajo horizontal de derecha a izquierda
    categoria="combat", frames=24, loop=False, superior=True,
    claves=[(0, REPOSO),
            (3, P(UpperTorso=(0, -25, 0), Head=(0, 10, 0), RightUpperArm=(-70, -55, 85), RightLowerArm=(-30, 0, 0),
                  RightHand=(45, -45, 0), LeftUpperArm=(-40, 0, 10), LeftLowerArm=(-30, 0, 0))),
            (5, P(UpperTorso=(-5, 30, 0), Head=(0, -15, 0), RightUpperArm=(-85, 55, 0), RightLowerArm=(0, 0, 0),
                  RightHand=(45, 15, 0), LeftUpperArm=(20, 0, 30), LeftLowerArm=(-20, 0, 0))),
            (7, P(UpperTorso=(-6, 36, 0), Head=(0, -18, 0), RightUpperArm=(-80, 55, -25), RightLowerArm=(-15, 0, 0),
                  RightHand=(40, 20, 0), LeftUpperArm=(25, 0, 32), LeftLowerArm=(-20, 0, 0))),
            (12, P(UpperTorso=(-4, 30, 0), Head=(0, -14, 0), RightUpperArm=(-60, 55, 0), RightLowerArm=(-10, 0, 0),
                   RightHand=(45, 30, 0), LeftUpperArm=(18, 0, 25), LeftLowerArm=(-20, 0, 0))),
            (23, REPOSO)],
    marcadores={"hit_start": 4, "hit": 5, "hit_end": 7, "cancel_ok": 19})

ANIMS["combat_combo2"] = dict(  # revés de izquierda a derecha con la misma mano
    categoria="combat", frames=24, loop=False, superior=True,
    claves=[(0, REPOSO),
            (3, P(UpperTorso=(0, 30, 0), Head=(0, -12, 0), RightUpperArm=(-75, 55, -25), RightLowerArm=(-65, 0, 0),
                  RightHand=(40, 45, 0), LeftUpperArm=(15, 0, 25), LeftLowerArm=(-20, 0, 0))),
            (5, P(UpperTorso=(-5, -30, 0), Head=(0, 15, 0), RightUpperArm=(-85, -55, 75), RightLowerArm=(-10, 0, 0),
                  RightHand=(45, 45, 0), LeftUpperArm=(-40, 0, 15), LeftLowerArm=(-35, 0, 0))),
            (7, P(UpperTorso=(-6, -36, 0), Head=(0, 18, 0), RightUpperArm=(-70, -55, 85), RightLowerArm=(-12, 0, 0),
                  RightHand=(40, 10, 0), LeftUpperArm=(-45, 0, 15), LeftLowerArm=(-35, 0, 0))),
            (12, P(UpperTorso=(-4, -30, 0), Head=(0, 14, 0), RightUpperArm=(-80, -55, 50), RightLowerArm=(-10, 0, 0),
                   RightHand=(45, 0, 0), LeftUpperArm=(-35, 0, 12), LeftLowerArm=(-30, 0, 0))),
            (23, REPOSO)],
    marcadores={"hit_start": 4, "hit": 5, "hit_end": 7, "cancel_ok": 19})

_ESTOCADA = P(LowerTorso=(-10, 8, 0), UpperTorso=(-20, 12, 0), Head=(10, -8, 0),
              RightUpperArm=(-60, 0, 0), RightLowerArm=(0, 0, 0), RightHand=(45, 0, 0),
              LeftUpperArm=(25, 0, 25), LeftLowerArm=(-20, 0, 0),
              LeftUpperLeg=(-45, 0, 5), LeftLowerLeg=(35, 0, 0), LeftFoot=(10, 0, 0),
              RightUpperLeg=(18, 0, 5), RightLowerLeg=(25, 0, 0), RightFoot=(-8, 0, 0))
ANIMS["combat_combo3"] = dict(  # estocada con paso
    categoria="combat", frames=24, loop=False, superior=False,
    claves=[(0, REPOSO),
            (3, P(LowerTorso=(-5, -10, 0), UpperTorso=(5, -10, 0), RightUpperArm=(-30, 0, 10), RightLowerArm=(-120, 0, 0),
                  LeftUpperArm=(-45, 0, 10), LeftLowerArm=(-60, 0, 0),
                  RightUpperLeg=(-25, 0, 5), RightLowerLeg=(40, 0, 0), LeftUpperLeg=(-25, 0, 5), LeftLowerLeg=(40, 0, 0))),
            (6, _ESTOCADA),
            (8, mas(_ESTOCADA, UpperTorso=(-22, 14, 0))),
            (14, mas(_ESTOCADA, UpperTorso=(-12, 8, 0), RightUpperArm=(-45, 0, 5), RightLowerArm=(-30, 0, 0), RightHand=(30, 0, 0))),
            (23, REPOSO)],
    marcadores={"hit_start": 5, "hit": 6, "hit_end": 8, "cancel_ok": 19})

_ARRIBA_2M = P(UpperTorso=(12, 0, 0), Head=(10, 0, 0),
               RightUpperArm=(-150, 0, -5), RightLowerArm=(-35, 0, 0), RightHand=(-20, 0, 0), LeftUpperArm=(-150, 0, -5), LeftLowerArm=(-35, 0, 0),
               RightUpperLeg=(-15, 0, 8), RightLowerLeg=(30, 0, 0), LeftUpperLeg=(-15, 0, 8), LeftLowerLeg=(30, 0, 0))
_REMATE = P(LowerTorso=(-10, 0, 0), UpperTorso=(-25, 0, 0), Head=(-5, 0, 0),
            RightUpperArm=(-40, 0, -10), RightLowerArm=(-10, 0, 0), RightHand=(45, 0, 0), LeftUpperArm=(-40, 0, -15), LeftLowerArm=(-15, 0, 0),
            RightUpperLeg=(-35, 0, 10), RightLowerLeg=(45, 0, 0), LeftUpperLeg=(-35, 0, 10), LeftLowerLeg=(45, 0, 0))
ANIMS["combat_combo4"] = dict(  # remate por arriba con las dos manos
    categoria="combat", frames=30, loop=False, superior=False,
    claves=[(0, REPOSO), (6, _ARRIBA_2M),
            (9, _REMATE), (11, mas(_REMATE, UpperTorso=(-25, 0, 3))),
            (18, mas(_REMATE, UpperTorso=(-15, 0, 0), RightUpperLeg=(-20, 0, 8), RightLowerLeg=(25, 0, 0),
                     LeftUpperLeg=(-20, 0, 8), LeftLowerLeg=(25, 0, 0))),
            (29, REPOSO)],
    marcadores={"hit_start": 8, "hit": 9, "hit_end": 11, "cancel_ok": 24})

_DASH_F = P(LowerTorso=(-5, 0, 0), UpperTorso=(-15, 0, 0), Head=(10, 0, 0),
            RightUpperArm=(35, 0, 15), RightLowerArm=(-20, 0, 0), LeftUpperArm=(35, 0, 15), LeftLowerArm=(-20, 0, 0),
            RightUpperLeg=(-30, 0, 0), RightLowerLeg=(40, 0, 0), LeftUpperLeg=(15, 0, 0), LeftLowerLeg=(60, 0, 0))
ANIMS["combat_dash_fwd"] = dict(
    categoria="combat", frames=12, loop=False, superior=False,
    claves=[(0, REPOSO), (2, P(LowerTorso=(10, 0, 0), UpperTorso=(5, 0, 0))), (5, _DASH_F), (8, _DASH_F), (11, REPOSO)],
    marcadores={"cancel_ok": 8})

_DASH_B = P(LowerTorso=(5, 0, 0), UpperTorso=(15, 0, 0), Head=(-8, 0, 0),
            RightUpperArm=(-40, 0, 15), RightLowerArm=(-30, 0, 0), LeftUpperArm=(-40, 0, 15), LeftLowerArm=(-30, 0, 0),
            RightUpperLeg=(-20, 0, 5), RightLowerLeg=(30, 0, 0), LeftUpperLeg=(-20, 0, 5), LeftLowerLeg=(30, 0, 0))
ANIMS["combat_dash_bwd"] = dict(
    categoria="combat", frames=12, loop=False, superior=False,
    claves=[(0, REPOSO), (2, P(LowerTorso=(-8, 0, 0), UpperTorso=(-5, 0, 0))), (5, _DASH_B), (8, _DASH_B), (11, REPOSO)],
    marcadores={"cancel_ok": 8})

ANIMS["combat_blink"] = dict(
    categoria="combat", frames=10, loop=False, superior=False,
    claves=[(0, REPOSO),
            (2, P(UpperTorso=(-15, 0, 0), Head=(-5, 0, 0), RightUpperArm=(20, 0, 25), LeftUpperArm=(20, 0, 25),
                  RightUpperLeg=(-35, 0, 5), RightLowerLeg=(45, 0, 0), LeftUpperLeg=(-35, 0, 5), LeftLowerLeg=(45, 0, 0))),
            (5, P(UpperTorso=(-4, 0, 0), RightUpperArm=(5, 0, 10), LeftUpperArm=(5, 0, 10),
                  RightUpperLeg=(-10, 0, 0), RightLowerLeg=(12, 0, 0), LeftUpperLeg=(-10, 0, 0), LeftLowerLeg=(12, 0, 0))),
            (9, REPOSO)],
    marcadores={"blink": 2})

ANIMS["combat_block_start"] = dict(
    categoria="combat", frames=5, loop=False, superior=True,
    claves=[(0, REPOSO), (4, GUARDIA)], termina=GUARDIA, marcadores={})

ANIMS["combat_block_loop"] = dict(
    categoria="combat", frames=30, loop=True, superior=True,
    claves=[(0, GUARDIA), (15, mas(GUARDIA, UpperTorso=(-3, 0, 0))), (29, GUARDIA)], marcadores={})

ANIMS["combat_block_hit"] = dict(
    categoria="combat", frames=8, loop=False, superior=True,
    claves=[(0, GUARDIA),
            (2, mas(GUARDIA, UpperTorso=(12, 0, 0), Head=(10, 0, 0), RightUpperArm=(-38, 0, 0), LeftUpperArm=(-43, 0, -20))),
            (7, GUARDIA)],
    termina=GUARDIA, marcadores={})

ANIMS["combat_hurt_light"] = dict(
    categoria="combat", frames=12, loop=False, superior=True,
    claves=[(0, REPOSO),
            (2, P(UpperTorso=(10, 0, 4), Head=(8, 10, 0), RightUpperArm=(10, 0, 15), LeftUpperArm=(10, 0, 15))),
            (5, P(UpperTorso=(6, 0, -2), Head=(4, -6, 0), RightUpperArm=(5, 0, 10), LeftUpperArm=(5, 0, 10))),
            (11, REPOSO)],
    marcadores={"cancel_ok": 6})

_ATURDIDO = P(UpperTorso=(-15, 0, 6), Head=(-15, 0, 4), RightUpperArm=(5, 0, 8), RightLowerArm=(-15, 0, 0),
              LeftUpperArm=(5, 0, 8), LeftLowerArm=(-15, 0, 0),
              RightUpperLeg=(-8, 0, 3), RightLowerLeg=(15, 0, 0), LeftUpperLeg=(-8, 0, 3), LeftLowerLeg=(15, 0, 0))
ANIMS["combat_stunned_loop"] = dict(
    categoria="combat", frames=30, loop=True, superior=False,
    claves=[(0, _ATURDIDO), (15, mas(_ATURDIDO, UpperTorso=(-13, 0, -6), Head=(-15, 0, -5))), (29, _ATURDIDO)],
    marcadores={})

_ENCOGIDO = P(UpperTorso=(-20, 0, 0), Head=(-12, 0, 0), RightUpperArm=(-30, 0, -20), RightLowerArm=(-110, 0, 0),
              LeftUpperArm=(-30, 0, -20), LeftLowerArm=(-110, 0, 0),
              RightUpperLeg=(-20, 0, 5), RightLowerLeg=(30, 0, 0), LeftUpperLeg=(-20, 0, 5), LeftLowerLeg=(30, 0, 0))
_ESTALLIDO = P(UpperTorso=(15, 0, 0), Head=(10, 0, 0), RightUpperArm=(-60, 0, 80), RightLowerArm=(-10, 0, 0),
               LeftUpperArm=(-60, 0, 80), LeftLowerArm=(-10, 0, 0),
               RightUpperLeg=(-5, 0, 10), RightLowerLeg=(5, 0, 0), LeftUpperLeg=(-5, 0, 10), LeftLowerLeg=(5, 0, 0))
ANIMS["combat_break"] = dict(  # Ruptura: liberarse del aturdimiento
    categoria="combat", frames=15, loop=False, superior=False,
    claves=[(0, mas(_ATURDIDO)), (3, _ENCOGIDO), (4, _ESTALLIDO), (6, _ESTALLIDO), (14, REPOSO)],
    marcadores={"break": 4, "cancel_ok": 10})

# ============================================================== HABILIDADES (una por tipo de hueco)

ANIMS["combat_cast_area"] = dict(  # Z: lanzamiento hacia delante
    categoria="combat", frames=30, loop=False, superior=True,
    claves=[(0, REPOSO),
            (9, P(UpperTorso=(5, -20, 0), Head=(0, 15, 0), RightUpperArm=(-130, 40, 20), RightLowerArm=(-60, 0, 0),
                  LeftUpperArm=(-70, 0, 0), LeftLowerArm=(-10, 0, 0))),
            (12, P(UpperTorso=(-15, 25, 0), Head=(0, -12, 0), RightUpperArm=(-70, 0, 0), RightLowerArm=(-5, 0, 0),
                   RightHand=(10, 0, 0), LeftUpperArm=(15, 0, 25), LeftLowerArm=(-20, 0, 0))),
            (14, P(UpperTorso=(-17, 28, 0), Head=(0, -14, 0), RightUpperArm=(-60, -10, -5), RightLowerArm=(-5, 0, 0),
                   LeftUpperArm=(18, 0, 25), LeftLowerArm=(-20, 0, 0))),
            (29, REPOSO)],
    marcadores={"hit_start": 11, "hit": 12, "hit_end": 14, "cancel_ok": 20})

_CONTROL_ARRIBA = P(UpperTorso=(10, 0, 0), Head=(8, 0, 0), RightUpperArm=(-150, 0, 10), RightLowerArm=(-20, 0, 0),
                    LeftUpperArm=(-150, 0, 10), LeftLowerArm=(-20, 0, 0),
                    RightUpperLeg=(-10, 0, 8), RightLowerLeg=(20, 0, 0), LeftUpperLeg=(-10, 0, 8), LeftLowerLeg=(20, 0, 0))
_CONTROL_SUELO = P(LowerTorso=(-10, 0, 0), UpperTorso=(-25, 0, 0), Head=(-8, 0, 0),
                   RightUpperArm=(-50, 0, 5), RightLowerArm=(-20, 0, 0), LeftUpperArm=(-50, 0, 5), LeftLowerArm=(-20, 0, 0),
                   RightUpperLeg=(-40, 0, 12), RightLowerLeg=(50, 0, 0), LeftUpperLeg=(-40, 0, 12), LeftLowerLeg=(50, 0, 0))
ANIMS["combat_cast_control"] = dict(  # X: golpe al suelo que crea un campo
    categoria="combat", frames=36, loop=False, superior=False,
    claves=[(0, REPOSO), (14, _CONTROL_ARRIBA), (18, _CONTROL_SUELO), (22, _CONTROL_SUELO), (35, REPOSO)],
    marcadores={"hit_start": 17, "hit": 18, "hit_end": 22, "cancel_ok": 28})

_IMPULSO = P(UpperTorso=(-25, 0, 0), Head=(12, 0, 0), RightUpperArm=(-70, 0, 0), RightLowerArm=(0, 0, 0), RightHand=(45, 0, 0),
             LeftUpperArm=(30, 0, 20), LeftLowerArm=(-20, 0, 0),
             RightUpperLeg=(-40, 0, 5), RightLowerLeg=(30, 0, 0), LeftUpperLeg=(20, 0, 5), LeftLowerLeg=(50, 0, 0))
ANIMS["combat_cast_mobility"] = dict(  # C: arranque explosivo (el servidor desplaza)
    categoria="combat", frames=18, loop=False, superior=False,
    claves=[(0, REPOSO),
            (3, P(UpperTorso=(-10, 0, 0), RightUpperArm=(15, 0, 15), LeftUpperArm=(15, 0, 15),
                  RightUpperLeg=(-30, 0, 5), RightLowerLeg=(45, 0, 0), LeftUpperLeg=(-30, 0, 5), LeftLowerLeg=(45, 0, 0))),
            (9, _IMPULSO), (11, _IMPULSO), (17, REPOSO)],
    marcadores={"hit_start": 8, "hit": 9, "hit_end": 11, "cancel_ok": 12})

_CARGA = P(UpperTorso=(15, 0, 0), Head=(15, 0, 0), RightUpperArm=(-150, 0, 25), RightLowerArm=(-20, 0, 0),
           LeftUpperArm=(-150, 0, 25), LeftLowerArm=(-20, 0, 0),
           RightUpperLeg=(-30, 0, 12), RightLowerLeg=(50, 0, 0), LeftUpperLeg=(-30, 0, 12), LeftLowerLeg=(50, 0, 0))
_DESCARGA = P(UpperTorso=(-20, 0, 0), Head=(0, 0, 0), RightUpperArm=(-90, 0, 10), RightLowerArm=(0, 0, 0), RightHand=(45, 0, 0),
              LeftUpperArm=(-90, 0, 10), LeftLowerArm=(0, 0, 0),
              RightUpperLeg=(-25, 0, 10), RightLowerLeg=(35, 0, 0), LeftUpperLeg=(-25, 0, 10), LeftLowerLeg=(35, 0, 0))
ANIMS["combat_ultimate"] = dict(  # V
    categoria="combat", frames=75, loop=False, superior=False,
    claves=[(0, REPOSO), (20, _CARGA), (29, mas(_CARGA, RightUpperArm=(-150, 0, 30), LeftUpperArm=(-150, 0, 30))),
            (33, _DESCARGA), (40, _DESCARGA), (55, mas(_DESCARGA, UpperTorso=(-8, 0, 0), RightUpperArm=(-40, 0, 10),
                                                          LeftUpperArm=(-40, 0, 10), RightLowerArm=(-20, 0, 0),
                                                          LeftLowerArm=(-20, 0, 0))),
            (74, REPOSO)],
    marcadores={"hit_start": 30, "hit": 33, "hit_end": 40})

ANIMS["combat_transform"] = dict(  # transformación del Núcleo
    categoria="combat", frames=45, loop=False, superior=False,
    claves=[(0, REPOSO),
            (18, P(UpperTorso=(-20, 0, 0), Head=(-15, 0, 0), RightUpperArm=(-60, 0, -25), RightLowerArm=(-120, 0, 0),
                   LeftUpperArm=(-60, 0, -25), LeftLowerArm=(-120, 0, 0),
                   RightUpperLeg=(-25, 0, 8), RightLowerLeg=(40, 0, 0), LeftUpperLeg=(-25, 0, 8), LeftLowerLeg=(40, 0, 0))),
            (24, P(UpperTorso=(15, 0, 0), Head=(12, 0, 0), RightUpperArm=(-110, 0, 70), RightLowerArm=(-10, 0, 0),
                   LeftUpperArm=(-110, 0, 70), LeftLowerArm=(-10, 0, 0),
                   RightUpperLeg=(-5, 0, 10), RightLowerLeg=(10, 0, 0), LeftUpperLeg=(-5, 0, 10), LeftLowerLeg=(10, 0, 0))),
            (30, P(UpperTorso=(14, 0, 0), Head=(10, 0, 0), RightUpperArm=(-108, 0, 70), RightLowerArm=(-12, 0, 0),
                   LeftUpperArm=(-108, 0, 70), LeftLowerArm=(-12, 0, 0),
                   RightUpperLeg=(-5, 0, 10), RightLowerLeg=(10, 0, 0), LeftUpperLeg=(-5, 0, 10), LeftLowerLeg=(10, 0, 0))),
            (44, REPOSO)],
    marcadores={"transform": 24})

# ============================================================== TÉCNICAS DE ESPADA

_GIRO = dict(UpperTorso=(-5, 0, 0), RightUpperArm=(-120, 0, 90), RightLowerArm=(0, 0, 0), RightHand=(30, -45, 0), LeftUpperArm=(-20, 0, 45),
             RightUpperLeg=(-15, 0, 10), RightLowerLeg=(25, 0, 0), LeftUpperLeg=(-15, 0, 10), LeftLowerLeg=(25, 0, 0))
ANIMS["combat_tech_spinning_slash"] = dict(  # giro completo de 360° (excepción de rango en LowerTorso Y)
    categoria="combat", frames=30, loop=False, superior=False,
    claves=[(0, REPOSO),
            (4, mas(_GIRO, LowerTorso=(0, -20, 0), UpperTorso=(-5, -20, 0))),
            (8, mas(_GIRO, LowerTorso=(0, 70, 0))),
            (12, mas(_GIRO, LowerTorso=(0, 160, 0))),
            (15, mas(_GIRO, LowerTorso=(0, -110, 0))),   # = 250°
            (18, mas(_GIRO, LowerTorso=(0, -20, 0))),    # = 340°
            (22, mas(_GIRO, LowerTorso=(0, 0, 0), RightUpperArm=(-50, 0, 40), RightLowerArm=(-20, 0, 0), RightHand=(20, 0, 0))),
            (29, REPOSO)],
    excepciones={"LowerTorso": ((-180, 180), (-180, 180), (-180, 180))},   # giro: no se puede medir en ángulos de Euler
    marcadores={"hit_start": 8, "hit": 12, "hit_end": 18, "cancel_ok": 22})

_RIPOSTE = P(LowerTorso=(-8, 10, 0), UpperTorso=(-20, 15, 0), Head=(8, -10, 0),
             RightUpperArm=(-60, 0, 0), RightLowerArm=(0, 0, 0), RightHand=(45, 0, 0),
             LeftUpperArm=(25, 0, 25), LeftLowerArm=(-20, 0, 0),
             LeftUpperLeg=(-35, 0, 5), LeftLowerLeg=(30, 0, 0), RightUpperLeg=(15, 0, 5), RightLowerLeg=(20, 0, 0))
ANIMS["combat_tech_riposte"] = dict(  # contraataque desde la guardia
    categoria="combat", frames=20, loop=False, superior=False,
    claves=[(0, GUARDIA), (3, mas(GUARDIA, RightLowerArm=(-120, 0, 0), UpperTorso=(-5, -10, 0))),
            (5, _RIPOSTE), (7, _RIPOSTE), (19, REPOSO)],
    marcadores={"hit_start": 4, "hit": 5, "hit_end": 7, "cancel_ok": 14})

LOTE_A = ["mining_stance_loop", "mining_swing_loop", "mining_swing_down_loop", "combat_combo1", "combat_combo2",
          "combat_combo3", "combat_combo4", "combat_dash_fwd", "combat_block_start", "combat_block_loop",
          "combat_block_hit", "combat_hurt_light"]
