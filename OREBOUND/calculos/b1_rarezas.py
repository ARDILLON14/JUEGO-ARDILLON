"""OREBOUND - Etapa 1 (B1), rehecha con el GDD: rarezas, potencia, suerte y proteccion contra mala suerte.
Ejecutar desde OREBOUND/:  python3 calculos/b1_rarezas.py     Genera B_Matematico/B1_Rarezas.md"""
import random, math, sys, os
from fractions import Fraction as Fr
sys.path.insert(0, os.path.dirname(__file__))
from montar import montar, tabla, n

RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = {"Común": 1.00, "Poco común": 1.25, "Raro": 1.50, "Épico": 1.90, "Legendario": 2.50, "Mítico": 3.30, "Ultra raro": 4.50, "Celestial": 5.20}  # GDD
CAJA = [50, 26, 14, 7, 2.4, 0.5, 0.1]
DEP_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; DEP_SIN = [55, 25, 12, 5.5, 2, 0.50, 0.0]
EVENTO = {"Raro": 45, "Épico": 33, "Legendario": 15, "Mítico": 5, "Ultra raro": 1.5, "Celestial": 0.5}
EXP_SUERTE = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.0]
F_MAX, K_SUERTE = 3.0, 1000.0
G_ZONA, POT_BASE, TOPE_BONO = 2.00, 100.0, 0.50          # Etapa 1 rehecha: 2,00 y +50 % (antes 1,65 y +100 %)
frag, kv = {}, {}
def exacto(v): return sum(Fr(str(x)) for x in v)
def redondeo_100(pcts, dec=3):
    u = 10 ** dec; bruto = [p * u for p in pcts]; ent = [int(b) for b in bruto]
    for i in sorted(range(len(pcts)), key=lambda i: bruto[i] - ent[i], reverse=True)[:100 * u - sum(ent)]: ent[i] += 1
    return [e / u for e in ent]
for t in (CAJA, DEP_UR, DEP_SIN, EVENTO.values()): assert exacto(t) == 100

# 1. Rarezas
INFO = [("Gris", "Sin aura; partículas de polvo", "Depósitos, cajas estándar, enemigos, tienda"), ("Verde", "Brillo suave en bordes", "Depósitos, cajas estándar, enemigos, tienda"),
        ("Azul", "Destello al soltar el objeto", "Depósitos, cajas estándar, enemigos, fabricación"), ("Morado", "Aura pulsante y estela corta", "Depósitos, cajas estándar, élites, fabricación"),
        ("Dorado", "Aura, estela y rayos de luz al aparecer", "Depósitos, cajas estándar, guardianes y jefes"), ("Rojo", "Todo lo anterior y vibración de cámara al obtenerlo", "Depósitos, cajas estándar, jefes"),
        ("Arcoíris", "Ciclo de color y anuncio en el servidor", "Depósitos de algunas zonas, cajas estándar, jefes"),
        ("Blanco perla con núcleo cian", "Halo orbital, partículas que suben y anuncio global", "Solo eventos, jefes de evento y fragmentos de Zonas Fracturadas de zona 6 o más")]
frag["rarezas"] = tabla(["Índice", "Rareza", "Color", "Tratamiento visual", "Multiplicador", "Dónde aparece"],
                        [[i + 1, r, INFO[i][0], INFO[i][1], "×" + n(MULT[r], 2), INFO[i][2]] for i, r in enumerate(list(MULT))])
frag["caja"] = tabla(["Rareza", "Probabilidad", "1 de cada"], [[r, n(p, 1) + "%", n(100 / p, 1)] for r, p in zip(RAR, CAJA)] + [["**Suma**", "**100,0%**", ""]])
frag["depositos"] = tabla(["Rareza", "Zona con Ultra raro", "Zona sin Ultra raro"], [[r, n(a, 2) + "%", n(b, 2) + "%"] for r, a, b in zip(RAR, DEP_UR, DEP_SIN)] + [["**Suma**", "**100,00%**", "**100,00%**"]])
frag["evento"] = tabla(["Rareza", "Probabilidad"], [[r, n(p, 1) + "%"] for r, p in EVENTO.items()] + [["**Suma**", "**100,0%**"]])

# 2. Potencia
def pot_zona(z): return POT_BASE * G_ZONA ** (z - 1)
def potencia(z, r, bono=0.0): return pot_zona(z) * MULT[r] * (1 + min(bono, TOPE_BONO))
frag["potencia"] = tabla(["Zona", "PotZona", "Común sin mejoras", "Ultra raro al máximo", "Celestial al máximo"],
    [[z, n(pot_zona(z)), n(potencia(z, "Común")), n(potencia(z, "Ultra raro", 1)), n(potencia(z, "Celestial", 1)) if z >= 6 else "—"] for z in range(1, 11)])
comp = [(4, 1, "Ultra raro", 0), (5, 2, "Ultra raro", 1), (10, 7, "Ultra raro", 1), (9, 6, "Celestial", 0), (10, 6, "Celestial", 1), (9, 6, "Celestial", 1)]
frag["demostracion"] = tabla(["Común sin mejoras", "Rival", "Potencias", "Resultado"],
    [[f"Zona {a}", f"{r} de zona {b} {'al máximo' if bo else 'sin mejoras'}", f"{n(potencia(a,'Común'))} frente a {n(potencia(b, r, bo))}",
      f"El Común es {n(potencia(a,'Común')/potencia(b, r, bo), 2)} veces mejor"] for a, b, r, bo in comp])
def zonas(mult): return math.ceil(math.log(mult) / math.log(G_ZONA) + 1e-9)
frag["regla"] = tabla(["Rival", "Zonas de diferencia para que un Común sin mejoras lo supere"],
    [[f"{r} {'al máximo' if b else 'sin mejoras'}", zonas(MULT[r] * (1 + b * TOPE_BONO))] for r, b in [("Ultra raro", 0), ("Ultra raro", 1), ("Celestial", 0), ("Celestial", 1)]])
kv.update(rango=n(MULT["Celestial"] * (1 + TOPE_BONO), 2), ej_pot=n(potencia(4, "Épico", 0.25)), ej_pz=n(pot_zona(4)), g=n(G_ZONA, 2), z10=n(G_ZONA ** 9),
          antes_ur=math.ceil(math.log(4.5 * 2) / math.log(1.65)), cel6=n(1.65 ** 5 * 5.2 * 2 / 1.65 ** 5, 1), com10_165=n(1.65 ** 4, 1))

# 3. Suerte
def factor(s): return 1 + F_MAX * s / (s + K_SUERTE)
def con_suerte(t, s):
    w = [p * factor(s) ** e for p, e in zip(t, EXP_SUERTE)]; tot = sum(w); return [100 * x / tot for x in w]
for clave, t in (("suerte_caja", CAJA), ("suerte_dep", DEP_UR)):
    filas = []
    for s in [0, 10, 100, 500, 1000, 2500, 10 ** 9]:
        p = redondeo_100(con_suerte(t, s)); assert sum(Fr(str(x)) for x in p) == 100
        filas.append(["∞" if s == 10 ** 9 else n(s), n(factor(s), 3)] + [n(x, 3) for x in p] + [n(sum(p[4:]), 3)])
    frag[clave] = tabla(["Suerte", "F"] + RAR + ["Legendario+"], filas)
kv.update(leg_inf=n(sum(con_suerte(CAJA, 10 ** 9)[4:]), 3), ur_inf=n(con_suerte(CAJA, 10 ** 9)[6], 3), ur_1000=n(con_suerte(CAJA, 1000)[6], 3), leg_2500=n(sum(con_suerte(CAJA, 2500)[4:]), 1))

# 4. Proteccion contra mala suerte
P0 = float(exacto(CAJA[4:])) / 100; PM = float(exacto(CAJA[5:])) / 100
def p_leg(k): return P0 if k <= 40 else 1.0 if k >= 50 else P0 + (1 - P0) * ((k - 40) / 10) ** 2
sup, filas = 1.0, []
for k in range(1, 51):
    if k == 40: filas.append(["1 a 40", n(100 * P0, 2) + "%", f"100,00% → {n(100*sup, 2)}%"])
    if k >= 41: filas.append([k, n(100 * p_leg(k), 2) + "%", n(100 * sup, 2) + "%"])
    sup *= 1 - p_leg(k)
frag["rampa"] = tabla(["Apertura n", "Probabilidad de Legendario+", "Jugadores que llegan a n sin premio"], filas)
def simular(N, semilla=20261116, suerte=0):
    rng = random.Random(semilla); t = [x / 100 for x in con_suerte(CAJA, suerte)]; p0 = sum(t[4:])
    cnt = [0] * 7; a = b = g50 = g100 = peor = 0
    for _ in range(N):
        a += 1; b += 1
        if b >= 100: idx = rng.choices([5, 6], weights=t[5:])[0]; g100 += 1
        else:
            p = p0 if a <= 40 else 1.0 if a >= 50 else p0 + (1 - p0) * ((a - 40) / 10) ** 2
            if rng.random() < p:
                idx = rng.choices([4, 5, 6], weights=t[4:])[0]; g50 += a >= 50
            else: idx = rng.choices([0, 1, 2, 3], weights=t[:4])[0]
        cnt[idx] += 1
        if idx >= 4: peor = max(peor, a); a = 0
        if idx >= 5: b = 0
    return cnt, g50, g100, peor
N = 100_000; s0, s1 = simular(N), simular(N, suerte=1000)
frag["simulacion"] = tabla(["Rareza", "Base", "Simulado, Suerte 0", "Simulado, Suerte 1.000"],
    [[r, n(CAJA[i], 3) + "%", n(100 * s0[0][i] / N, 3) + "%", n(100 * s1[0][i] / N, 3) + "%"] for i, r in enumerate(RAR)] +
    [["**Legendario o superior**", "**3,000%**", f"**{n(100*sum(s0[0][4:])/N, 3)}%**", f"**{n(100*sum(s1[0][4:])/N, 3)}%**"],
     ["**Mítico o superior**", "**0,600%**", f"**{n(100*sum(s0[0][5:])/N, 3)}%**", f"**{n(100*sum(s1[0][5:])/N, 3)}%**"]])
frag["garantias"] = tabla(["Dato", "Suerte 0", "Suerte 1.000"], [["Garantías activadas en la apertura 50", s0[1], s1[1]], ["Garantías activadas en la apertura 100", s0[2], s1[2]], ["Racha más larga sin Legendario+", s0[3], s1[3]]])
kv.update(leg_real=n(100 * sum(s0[0][4:]) / N, 3), mit_real=n(100 * sum(s0[0][5:]) / N, 3), ur_real=n(100 * s0[0][6] / N, 3), g100=s0[2], sin50=n(100 * (1 - P0) ** 50, 2))
frag["garantia_alt"] = tabla(["Garantía de Mítico+ en la apertura", "Tasa aproximada de Mítico+"], [[k, n(100 * PM / (1 - (1 - PM) ** k), 3) + "%"] for k in (100, 150, 200, 300)])

# 5. Celestial
FRAG_OBJ, FRAG_JEFE, TOPE_JEFE, P_DIRECTO, P_DEP_GDD, P_DEP, MULT_GRIETA_CEL = 50, 2, 5, 0.005, 0.0002, 0.0025, 4
DEP_H = 3600 / 13 * 0.94
frag["cel_fuentes"] = tabla(["Fuente", "Qué da", "Valor", "Límite"],
    [["Depósitos de Zonas Fracturadas, zonas 6 a 10", "1 fragmento", n(100 * P_DEP, 2) + "% por depósito agotado", "Sin límite; va directo a la cuenta"],
     ["Grieta Celestial (evento cada 2 horas)", "1 fragmento", f"×{MULT_GRIETA_CEL} durante el evento ({n(100*P_DEP*MULT_GRIETA_CEL, 1)}% por depósito)", "Lo que dure el evento"],
     ["Jefe de evento", "Fragmentos garantizados", f"{FRAG_JEFE} por derrota", f"{TOPE_JEFE} derrotas por semana"],
     ["Jefe de evento", "Objeto Celestial completo", n(100 * P_DIRECTO, 1) + "% por derrota", "Sin límite"],
     ["Caja de evento", "Objeto Celestial completo", "0,5% por caja", "Las que dé el evento"]])
frag["cel_prob"] = tabla(["Probabilidad por depósito", "Fragmentos por hora de grieta", "Horas de grieta por objeto"],
    [[n(100 * p, 2) + "%" + txt, n(DEP_H * p, 3), n(FRAG_OBJ / (DEP_H * p))] for p, txt in ((P_DEP_GDD, " (GDD)"), (0.001, ""), (P_DEP, " (adoptada)"), (0.005, ""))])
filas = []
for nombre, jefes, horas in [("Solo PvE, casual", 2, 0), ("Solo PvE, constante", 5, 0), ("Regular", 4, 4), ("Dedicado", 5, 10), ("Solo grieta", 0, 10)]:
    f = min(jefes, TOPE_JEFE) * FRAG_JEFE + horas * DEP_H * P_DEP
    filas.append([nombre, jefes, horas, n(f, 2), n(FRAG_OBJ / f, 1), n(100 * (1 - (1 - P_DIRECTO) ** jefes), 2) + "%"])
frag["cel_ritmo"] = tabla(["Perfil", "Jefes de evento/semana", "Horas de grieta (zona 6+)/semana", "Fragmentos/semana", "Semanas por Celestial", "Celestial directo/semana"], filas)
kv.update(h_gdd=n(FRAG_OBJ / (DEP_H * P_DEP_GDD)), h_adop=n(FRAG_OBJ / (DEP_H * P_DEP)), frag_obj=FRAG_OBJ, p_dep=n(100 * P_DEP, 2), dep_h=n(DEP_H))
montar("plantillas/B1.md", "B_Matematico/B1_Rarezas.md", frag, kv)
for k in sorted(kv): print(f"  {k} = {kv[k]}")
