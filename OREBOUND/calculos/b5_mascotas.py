"""OREBOUND - Etapa 5 (B5): mascotas.
Ejecutar desde OREBOUND/:  python3 calculos/b5_mascotas.py [carpeta_fragmentos_md]
Valores [PROVISIONAL] salvo los topes de DPS (40 % PvE, 25 % PvP) y las fases."""
import math, sys, os

RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = dict(zip(RAR, [1.00, 1.15, 1.32, 1.52, 1.75, 1.98, 2.20]))
G = 1.65
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
def n(x, d=0): return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")
frag = {}
def md(nombre, cab, filas):
    out = ["| " + " | ".join(cab) + " |", "|" + "---|" * len(cab)]
    out += ["| " + " | ".join(str(c) for c in f) + " |" for f in filas]
    frag[nombre] = "\n".join(out); print(f"\n## {nombre}"); print(frag[nombre])

# ---------- 1. Nivel de mascota ----------
def xpp(nv): return math.ceil(15 + 3 * nv + 0.09 * nv * nv)
def mult_nivel(nv): return 1 + 0.015 * (nv - 1)
def vel_nivel(nv): return 1 + 0.002 * (nv - 1)
def util_nivel(nv): return 1 + 0.005 * (nv - 1)
FASE = {"Cría": 1.00, "Forma desatada": 1.25, "Forma desatada máxima": 1.50}
PTS_ENEMIGO = {"Común": 2, "Élite": 8, "Guardián": 24, "Jefe": 160}
PTS_DEPOSITO = [2, 3, 4, 6, 9, 14, 22]
MIX = {"Común": 0.88, "Élite": 0.10, "Guardián": 0.02}
P_DEP = [55, 25, 12, 5.5, 2, 0.45, 0.05]
pts_combate = 233 * sum(MIX[t] * PTS_ENEMIGO[t] for t in MIX)          # 233 enemigos/h (B4, zona 5)
pts_mineria = 231 * sum(p / 100 * x for p, x in zip(P_DEP, PTS_DEPOSITO))  # 231 depositos/h (B3, zona 5)
NIDO = 0.15
acum = {}; a = 0
for nv in range(1, 101): acum[nv] = a; a += xpp(nv)
md("nivel", ["Nivel", "XP para el siguiente", "XP acumulada", "Mult. de daño", "Mult. de velocidad de ataque", "Mult. de utilidad", "Horas en combate", "Horas minando", "Horas en el Nido"],
   [[nv, xpp(nv) if nv < 100 else "—", n(acum[nv]), n(mult_nivel(nv), 3), n(vel_nivel(nv), 3), n(util_nivel(nv), 3), n(acum[nv] / pts_combate, 1),
     n(acum[nv] / pts_mineria, 1), n(acum[nv] / (NIDO * pts_combate), 1)] for nv in (1, 10, 25, 50, 75, 100)])
print(f"XP de mascota por hora: combate {pts_combate:.0f}, mineria {pts_mineria:.0f}, Nido {NIDO*pts_combate:.0f}")

# ---------- 2. Evolucion ----------
INCUB = [10, 20, 40, 90, 180, 360, 720]
VINC_SUELTA = [1, 2, 4, 8, 16, 32, 64]
VINC_DES = [5, 8, 12, 20, 32, 50, 80]; JEFE_DES = [3, 3, 5, 5, 8, 8, 10]
VINC_MAX = [15, 24, 36, 60, 96, 150, 240]; CAT_MAX = [1, 1, 2, 2, 4, 4, 6]; GEMA_MAX = [0, 0, 1, 1, 2, 3, 5]
md("evolucion", ["Rareza", "Incubación (min de juego)", "Vínculos al liberar un duplicado", "Desatada: Vínculos", "Desatada: material de jefe",
                 "Máxima: Vínculos", "Máxima: Catalizadores Míticos", "Máxima: gemas antiguas", "Duplicados equivalentes (Desatada + Máxima)"],
   [[r, INCUB[i], VINC_SUELTA[i], VINC_DES[i], JEFE_DES[i], VINC_MAX[i], CAT_MAX[i], GEMA_MAX[i],
     n((VINC_DES[i] + VINC_MAX[i]) / VINC_SUELTA[i], 1)] for i, r in enumerate(RAR)])

# ---------- 3. Formulas de combate de mascota ----------
ROL = {"Atacante": (0.030, 0.40), "Control": (0.018, 0.50), "Tanque": (0.015, 1.00), "Apoyo": (0.010, 0.50), "Recolector": (0.008, 0.40)}
md("roles", ["Rol", "Coef. de daño (b)", "Coef. de vida (h)", "Efecto propio (valor base)", "Tope del efecto"],
   [["Atacante", "0,030", "0,40", "Solo daño", "Tope de DPS conjunto"],
    ["Control", "0,018", "0,50", "Reduce un 8 % el daño que hacen los enemigos afectados", "25 %"],
    ["Tanque", "0,015", "1,00", "Desvía a sí misma el 5 % del daño que recibe el jugador y da un escudo del 2 % de la vida máxima cada 20 s", "Desvío 30 %"],
    ["Apoyo", "0,010", "0,50", "Cura el 0,15 % de la vida máxima por segundo", "1 % por segundo (0,5 % en PvP)"],
    ["Recolector", "0,008", "0,40", "+4 % de daño de pico en postura Recolectar", "+20 % entre todas"]])
FACTOR_HAB, CRIT = 1.75, 1.025
def dps_ref_jugador(fuerza, maestria=0): return sat(fuerza) * CRIT * (1 + 0.001 * maestria) * FACTOR_HAB       # en unidades de PotenciaArma
def dps_mascota(rol, rareza, nivel, fase, dominio):
    return ROL[rol][0] * MULT[rareza] * mult_nivel(nivel) * FASE[fase] * sat(dominio) * vel_nivel(nivel)
def util(nivel, fase, dominio): return FASE[fase] * util_nivel(nivel) * sat(dominio, 1.5)
ej = dps_mascota("Atacante", "Legendario", 60, "Forma desatada", 400)
print(f"Ejemplo F27: Atacante Legendaria nivel 60 desatada, Dominio 400 -> {ej:.4f} x PotenciaArma por segundo "
      f"({100*ej/dps_ref_jugador(300):.1f} % del DPS de referencia de un jugador con Fuerza 300)")

# ---------- 4. Topes de DPS: simulacion ----------
TOPE = {"PvE": 0.40, "PvP y Zonas Fracturadas": 0.25}
EQUIPOS = {10: ("Común", "Cría"), 50: ("Épico", "Forma desatada"), 100: ("Ultra raro", "Forma desatada máxima")}
VELS = [1.6, 1.0, 0.6]               # golpes/s base de las tres mascotas
def simular(nivel, dominio, fuerza, modo, dur=120.0, dt=0.05):
    rareza, fase = EQUIPOS[nivel]
    ref = dps_ref_jugador(fuerza); tope = TOPE[modo] * ref
    teor = [dps_mascota("Atacante", rareza, nivel, fase, dominio) for _ in VELS]
    hab = [0.15 * d for d in teor]                       # la habilidad activa aporta un 15 % mas, en rafagas cada 12 s
    total_teor = sum(teor) + sum(hab)
    factor = min(1.0, tope / total_teor)
    VENT = 5.0
    prox = [0.0] * 3; prox_hab = [3.0, 7.0, 11.0]; hecho = 0.0; pico_1s = 0.0; vent = []; t = 0.0
    while t < dur:
        vent = [(a, b) for a, b in vent if a > t - VENT]; cubo = tope * VENT - sum(b for _, b in vent); golpe_t = 0.0
        for i, v in enumerate(VELS):
            vel = v * vel_nivel(nivel)
            if t >= prox[i]:
                d = min(teor[i] / vel * factor, cubo); cubo -= d; golpe_t += d; prox[i] = t + 1 / vel
            if t >= prox_hab[i]:
                d = min(hab[i] * 12 * factor, cubo); cubo -= d; golpe_t += d; prox_hab[i] = t + 12
        hecho += golpe_t; vent.append((t, golpe_t))
        pico_1s = max(pico_1s, sum(b for _, b in vent) / VENT)
        t += dt
    return total_teor / ref, factor, hecho / dur / ref, pico_1s / ref
filas = []
for modo in TOPE:
    for nombre, fuerza, dominio in [("Típico (Fuerza 170, Dominio 170)", 170, 170), ("Fuerza 1.000, Dominio 0", 1000, 0),
                                    ("Fuerza 1.000, Dominio 1.000", 1000, 1000), ("Fuerza 0, Dominio 1.000", 0, 1000)]:
        for nivel in (10, 50, 100):
            bruto, factor, real, pico = simular(nivel, dominio, fuerza, modo)
            assert real <= TOPE[modo] + 1e-9 and pico <= TOPE[modo] + 1e-9
            filas.append([modo, nombre, nivel, f"{EQUIPOS[nivel][0]}, {EQUIPOS[nivel][1].lower()}", n(100 * bruto, 1) + " %", n(factor, 3),
                          n(100 * real, 1) + " %", n(100 * pico, 1) + " %", f"{int(100*TOPE[modo])} %"])
md("topes", ["Modo", "Jugador", "Nivel de las 3 mascotas", "Rareza y fase", "DPS teórico sin tope (% del jugador)", "Factor del servidor", "DPS real medio", "Mayor media en 5 s", "Tope"], filas)
print("Comprobado: ni el DPS medio ni ninguna ventana de 5 s superan el tope en los 24 casos.")

# ---------- 5. Valor de las mascotas que no hacen dano ----------
# Jugador tipico de zona 5 (B4): 6,6 s por Comun; ciclo con mezcla y viaje.
F_VIDA = {"Común": 20, "Élite": 80, "Guardián": 300}; F_DANO = {"Común": 0.03, "Élite": 0.06, "Guardián": 0.10}
INTERVALO = {"Común": 1.5, "Élite": 1.8, "Guardián": 2.2}; F_MON = {"Común": 1.35, "Élite": 5.4, "Guardián": 16}
VIAJE, ESQUIVA, DESCANSO, UMBRAL, REGEN = 5.0, 0.5, 5.0, 0.30, 0.05
dureza5 = 1.4; fuerza_tip = 168
dps_tip = 1.32 * 1.25 * dps_ref_jugador(fuerza_tip)                 # en unidades de PotZona
def ciclo_combate(dps_extra=0.0, menos_dano=0.0, desvio=0.0, escudo_s=0.0, cura_s=0.0):
    d = dps_tip * (1 + dps_extra)
    t_pelea = sum(MIX[t] * F_VIDA[t] * dureza5 / d for t in MIX)
    t_ciclo = t_pelea + VIAJE
    dano_s = sum(MIX[t] * (F_VIDA[t] * dureza5 / d) * F_DANO[t] / INTERVALO[t] for t in MIX) / t_ciclo   # fraccion de vida por s
    dano_s *= (1 - ESQUIVA) * (1 - menos_dano) * (1 - desvio)
    neto = dano_s - escudo_s - cura_s
    if neto <= 0: parado = 0.0
    else:
        t_lucha = (1 - UMBRAL) / neto; t_desc = DESCANSO + (1 - UMBRAL) / REGEN
        parado = t_desc / (t_lucha + t_desc)
    kills_h = 3600 / t_ciclo * (1 - parado)
    mon = kills_h * sum(MIX[t] * F_MON[t] for t in MIX)
    return kills_h, parado, mon, dano_s
def aguante_guardian(menos_dano=0.0, desvio=0.0, escudo_s=0.0, cura_s=0.0):
    dps_in = F_DANO["Guardián"] / INTERVALO["Guardián"] * (1 - menos_dano) * (1 - desvio) - escudo_s - cura_s
    return 1 / dps_in
U = util(50, "Forma desatada", 170)
at = dps_mascota("Atacante", "Épico", 50, "Forma desatada", 170) / (1.32 * 1.25 * dps_ref_jugador(fuerza_tip)) * 1.15
def aporte(rol): return dps_mascota(rol, "Épico", 50, "Forma desatada", 170) / (1.32 * 1.25 * dps_ref_jugador(fuerza_tip)) * 1.15
base = ciclo_combate(); ag0 = aguante_guardian()
EQ = {"Sin mascotas": dict(),
      "3 Atacantes": dict(dps_extra=3 * aporte("Atacante")),
      "2 Atacantes + Tanque": dict(dps_extra=2 * aporte("Atacante") + aporte("Tanque"), desvio=min(0.30, 0.05 * U), escudo_s=0.02 * U / 20),
      "2 Atacantes + Apoyo": dict(dps_extra=2 * aporte("Atacante") + aporte("Apoyo"), cura_s=min(0.01, 0.0015 * U)),
      "2 Atacantes + Control": dict(dps_extra=2 * aporte("Atacante") + aporte("Control"), menos_dano=min(0.25, 0.08 * U)),
      "Tanque + Apoyo + Control": dict(dps_extra=aporte("Tanque") + aporte("Apoyo") + aporte("Control"), desvio=min(0.30, 0.05 * U),
                                       escudo_s=0.02 * U / 20, cura_s=min(0.01, 0.0015 * U), menos_dano=min(0.25, 0.08 * U))}
filas = []
for nombre, kw in EQ.items():
    k, parado, mon, _ = ciclo_combate(**kw)
    surv = {x: kw[x] for x in ("menos_dano", "desvio", "escudo_s", "cura_s") if x in kw}
    filas.append([nombre, n(100 * kw.get("dps_extra", 0), 1) + " %", n(100 * parado, 1) + " %", n(k), n(100 * (mon / base[2] - 1), 1) + " %",
                  n(aguante_guardian(**surv), 1) + " s", n(100 * (aguante_guardian(**surv) / ag0 - 1)) + " %"])
md("valor", ["Equipo (Épico, nivel 50, desatada)", "DPS que añaden", "Tiempo parado recuperando vida", "Enemigos/hora", "Monedas/hora frente a sin mascotas",
             "Aguante frente a un Guardián sin esquivar", "Aguante extra"], filas)
print(f"Multiplicador de utilidad U (nivel 50, desatada, Dominio 170): {U:.3f}")
# Mineria: recolectores
T_MED, VIAJE_M, T_BANCO, UDS, CAP = 7.0, 6.0, 40.0, 3.77, 60
def minero(asist=0.0, recogida_auto=False, extra_cap=0.0):
    viaje = VIAJE_M - (1.0 if recogida_auto else 0.0)
    ciclo = T_MED / (1 + asist) + viaje + T_BANCO * UDS / (CAP * (1 + extra_cap))
    return 3600 / ciclo
m0 = minero(); filas = []
for nombre, nrec, auto in [("Sin mascotas", 0, False), ("1 Recolector", 1, True), ("2 Recolectores", 2, True), ("3 Recolectores", 3, True)]:
    asist = min(0.20, nrec * 0.04 * U)
    filas.append([nombre, n(100 * asist, 1) + " %", "Sí" if auto else "No", n(minero(asist, auto)), n(100 * (minero(asist, auto) / m0 - 1), 1) + " %"])
asist_max = 0.20
filas.append(["3 Recolectores al máximo (nivel 100, Dominio 1.000)", "20,0 % (tope)", "Sí", n(minero(asist_max, True)), n(100 * (minero(asist_max, True) / m0 - 1), 1) + " %"])
md("valor_mineria", ["Equipo en postura Recolectar", "Daño de pico añadido", "Recogida automática", "Depósitos/hora", "Monedas/hora frente a sin mascotas"], filas)

# ---------- 6. Espacios ----------
k3 = ciclo_combate(**EQ["3 Atacantes"])[2]
def equipo_n(nat, tanque=0, apoyo=0, control=0):
    kw = dict(dps_extra=nat * aporte("Atacante") + tanque * aporte("Tanque") + apoyo * aporte("Apoyo") + control * aporte("Control"),
              desvio=min(0.30, tanque * 0.05 * U), escudo_s=tanque * 0.02 * U / 20, cura_s=min(0.01, apoyo * 0.0015 * U),
              menos_dano=min(0.25, control * 0.08 * U))
    kw["dps_extra"] = min(kw["dps_extra"], 0.40)
    return ciclo_combate(**kw)[2]
filas = []
for nombre, args in [("3 (inicial): 3 Atacantes", (3,)), ("4: + Tanque", (3, 1)), ("5: + Tanque + Apoyo", (3, 1, 1)),
                     ("6: + Tanque + Apoyo + Control", (3, 1, 1, 1))]:
    m = equipo_n(*args); filas.append([nombre, n(100 * (m / base[2] - 1), 1) + " %", n(100 * (m / k3 - 1), 1) + " %"])
md("espacios", ["Espacios y equipo", "Monedas/hora frente a sin mascotas", "Frente al equipo de 3"], filas)
m5, m6 = equipo_n(3, 1, 1), equipo_n(3, 1, 1, 1)
print(f"Ventaja del 6.o espacio (de pago) sobre 5: {100*(m6/m5-1):.2f} %")

if len(sys.argv) > 1:
    os.makedirs(sys.argv[1], exist_ok=True)
    for k, v in frag.items(): open(os.path.join(sys.argv[1], k + ".md"), "w", encoding="utf-8").write(v)

# ---------- 7. Comprobaciones de ejemplos del documento ----------
vb = 500 * G ** ((450 - 1) / 100)
print(f"Ejemplo F28: vida base nivel 450 = {vb:.0f}; Tanque Epica nivel 50 desatada = {vb * 1.0 * MULT['Épico'] * 1.49 * 1.25:.0f}")
for b in (0.030, 0.040):
    x = 3 * b * mult_nivel(10) * sat(170) * vel_nivel(10) * 1.15 / dps_ref_jugador(170)
    print(f"P4: tres crias Comunes de nivel 10 con b = {b}: {100*x:.1f} % del DPS del jugador tipico")
