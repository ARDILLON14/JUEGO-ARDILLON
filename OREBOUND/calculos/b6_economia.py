"""OREBOUND - Etapa 6 (B6): economia.
Ejecutar desde OREBOUND/:  python3 calculos/b6_economia.py [carpeta_fragmentos_md]
Genera calculos/b6_precios_minerales.csv y calculos/b6_precios_equipo.csv. Valores [PROVISIONAL]."""
import csv, math, random, sys, os
from fractions import Fraction as Fr

G = 1.65
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
CAJA = [50, 26, 14, 7, 2.4, 0.5, 0.1]
REAL = [49.128, 25.573, 13.888, 6.962, 3.050, 1.171, 0.228]        # B1, simulacion con proteccion
P_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; UNIDADES = [4, 4, 3, 3, 2, 2, 1]; F_VALOR = [1, 1.8, 3.2, 6, 12, 25, 60]
MINERO = [4782, 7890, 12418, 20419, 33692, 55523, 91613, 150461, 242713, 399993]     # B3 equilibrado
COMBAT = [4877, 8042, 13213, 21652, 35417, 57854, 94414, 153968, 250954, 408875]     # B4 equilibrado
ZONAS = (1, 3, 5, 8, 10)
def V(z): return 10 * G ** (z - 1)
def I(z): return (MINERO[z-1] + COMBAT[z-1]) / 2                    # ingreso de referencia por hora
def n(x, d=0): return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")
frag = {}
def md(nombre, cab, filas):
    out = ["| " + " | ".join(cab) + " |", "|" + "---|" * len(cab)]
    out += ["| " + " | ".join(str(c) for c in f) + " |" for f in filas]
    frag[nombre] = "\n".join(out); print(f"\n## {nombre}"); print(frag[nombre])

md("ingreso_ref", ["Zona", "Valor de zona V", "Minero (B3)", "Combatiente (B4)", "Ingreso de referencia I", "I / V"],
   [[z, n(V(z), 1), n(MINERO[z-1]), n(COMBAT[z-1]), n(I(z)), n(I(z) / V(z))] for z in range(1, 11)])

# ---------- 1. Venta de minerales ----------
md("venta", ["Zona"] + RAR, [[z] + [n(V(z) * F_VALOR[r] / UNIDADES[r], 1) for r in range(7)] for z in range(1, 11)])
with open("calculos/b3_minerales.csv", encoding="utf-8") as fh, open("calculos/b6_precios_minerales.csv", "w", newline="", encoding="utf-8") as out:
    w = csv.writer(out); w.writerow(["mineral", "zona", "rareza", "precio_venta_unidad", "precio_venta_fracturado_extraido"])
    for f in csv.DictReader(fh):
        w.writerow([f["mineral"], f["zona"], f["rareza"], f["valor_unidad"], round(float(f["valor_unidad"]) * 2, 1)])

# ---------- 2. Equipo y mejoras ----------
H = [0.3, 0.6, 1.2, 2.5, 5, 10, 20]                               # horas de ingreso por rareza
RECETA = ["30 Lingotes Común", "40 Lingotes Común + 20 Lingotes Poco común", "30 Lingotes Poco común + 15 Placas Raro",
          "30 Placas Raro + 10 Gemas talladas", "20 Gemas talladas + 8 Núcleos + 2 de jefe",
          "15 Núcleos + 6 Catalizadores + 4 de jefe", "10 Catalizadores + 4 Esencias + 6 de jefe + 1 gema antigua"]
REC = [{0: 30}, {0: 40, 1: 20}, {1: 30, 2: 15}, {2: 30, 3: 10}, {3: 20, 4: 8}, {4: 15, 5: 6}, {5: 10, 6: 4}]
DEP_H = 231
def horas_mat(rec):       # horas de mineria para reunir el material mas lento, y valor de venta al que se renuncia (en horas de I)
    lento = max(q / (DEP_H * P_UR[r] / 100 * UNIDADES[r]) for r, q in rec.items())
    valor = sum(q * F_VALOR[r] / UNIDADES[r] for r, q in rec.items()) / 479.0
    return lento, valor
md("equipo", ["Rareza", "Monedas (horas de ingreso)", "Receta (minerales de la zona)", "Horas de minería para el material más escaso", "Valor de venta de los materiales (horas)",
              "Niveles 1–10 (monedas, horas)", "3 ranuras (horas)", "Despertar (horas)", "Total al máximo (horas)"],
   [[RAR[r], n(H[r], 1), RECETA[r], n(horas_mat(REC[r])[0], 1), n(horas_mat(REC[r])[1], 2), n(2.75 * H[r], 2), n(1.5 * H[r], 2), n(1.5 * H[r], 2),
     n(6.75 * H[r], 1)] for r in range(7)])
md("equipo_monedas", ["Zona"] + RAR, [[z] + [n(H[r] * I(z)) for r in range(7)] for z in range(1, 11)])
with open("calculos/b6_precios_equipo.csv", "w", newline="", encoding="utf-8") as out:
    w = csv.writer(out); w.writerow(["zona", "rareza", "monedas_fabricar", "monedas_niveles_1_10", "monedas_3_ranuras", "monedas_despertar", "venta_al_mercader"])
    for z in range(1, 11):
        for r in range(7):
            b = H[r] * I(z); w.writerow([z, RAR[r], round(b), round(2.75 * b), round(1.5 * b), round(1.5 * b), round(0.1 * b)])

# ---------- 3. Recompensas de enemigos y jefes ----------
F_MON = {"Común": 1.35, "Élite": 5.4, "Guardián": 16, "Jefe": 60}
F_XP = {"Común": 1, "Élite": 3.5, "Guardián": 10, "Jefe": 60}
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
md("enemigos", ["Zona", "Común: monedas", "Élite", "Guardián", "Jefe (por jugador)", "Común: XP", "Élite", "Guardián", "Jefe", "Material de jefe"],
   [[z] + [n(V(z) * F_MON[t]) for t in F_MON] + [n(0.72 * xp_acc(100 * (z - 1) + 50) * F_XP[t]) for t in F_XP] + ["3"] for z in range(1, 11)])
print(f"Jefe: {F_MON['Jefe']} V = {60/479*60:.1f} min de ingreso por un combate de 8 min; antes 250 V = {250/479:.2f} h")

# ---------- 4. Cajas ----------
P_CAJA = {"Caja de armas": 1.0, "Caja de zona": 0.6, "Caja de mascotas": 0.75}
ev_armas = sum(REAL[r] / 100 * H[r] for r in range(7))
LOTE = [0.15, 0.25, 0.4, 0.8, 2, 5, 12]
ev_zona = 0.35 * ev_armas + 0.40 * sum(REAL[r] / 100 * LOTE[r] for r in range(7)) + 0.15 * sum(REAL[r] / 100 * LOTE[r] for r in range(7)) + 0.10 * 0.2
md("cajas_precio", ["Caja", "Precio (horas de I)", "Zona 1", "Zona 3", "Zona 5", "Zona 8", "Zona 10", "Valor medio del contenido (horas)", "Valor de reventa (horas)"],
   [["Caja de armas", "1,00"] + [n(1.0 * I(z)) for z in ZONAS] + [n(ev_armas, 2), n(0.1 * ev_armas, 2)],
    ["Caja de zona", "0,60"] + [n(0.6 * I(z)) for z in ZONAS] + [n(ev_zona, 2), n(0.35 * 0.1 * ev_armas + 0.55 * sum(REAL[r] / 100 * LOTE[r] for r in range(7)), 2)],
    ["Caja de mascotas", "0,75"] + [n(0.75 * I(z)) for z in ZONAS] + ["—", "0 (no se venden)"]])
TIPOS = {"Espada": 17, "Hacha": 17, "Daga": 17, "Lanza": 17, "Bastón": 16, "Arco": 16}
assert sum(TIPOS.values()) == 100 and sum(Fr(str(x)) for x in CAJA) == 100
MASC = [("Topillo de Pizarra", "Común", 25), ("Luciérnaga de Veta", "Común", 25), ("Zorro de Ascua", "Poco común", 13), ("Tortuga Geoda", "Poco común", 13),
        ("Murciélago de Eco", "Raro", 7), ("Nutria Salina", "Raro", 7), ("Búho Boreal", "Épico", 3.5), ("Carnero de Magma", "Épico", 3.5),
        ("Mantis Vitral", "Legendario", 1.2), ("Guiverno de Cuarzo", "Legendario", 1.2), ("Ciervo Astral", "Mítico", 0.5), ("Sierpe de Nova", "Ultra raro", 0.1)]
assert sum(Fr(str(p)) for _, _, p in MASC) == 100
md("caja_mascotas", ["Huevo", "Rareza", "Probabilidad"], [[a, b, n(c, 1) + " %"] for a, b, c in MASC] + [["**Suma**", "", "**100,0 %**"]])
CAT = [("Pico de la zona", 35), ("Lote de minerales de la zona", 40), ("Materiales de fabricación", 15), ("Lote de consumibles", 10)]
filas = []
for cat, pc in CAT:
    filas.append([cat, f"{pc} %"] + [n(pc * CAJA[r] / 100, 3) + " %" for r in range(7)])
tot = sum(Fr(pc) * Fr(str(CAJA[r])) / 100 for _, pc in CAT for r in range(7)); assert tot == 100
filas.append(["**Suma**", "**100 %**"] + [n(CAJA[r], 1) + " %" for r in range(7)])
md("caja_zona", ["Categoría", "Probabilidad"] + RAR, filas)
p_leg_tipo = (REAL[4] + REAL[5] + REAL[6]) / 100 / 6
print(f"Cajas de armas para un Legendario o superior de un tipo concreto: {1/p_leg_tipo:.0f} cajas = {1.0/p_leg_tipo:.0f} h; fabricarlo: {H[4]} h + materiales")
print(f"Valor medio caja de armas {ev_armas:.3f} h (precio 1,0); caja de zona {ev_zona:.3f} h (precio 0,6)")

# ---------- 5. Zonas Fracturadas, racha, seguro, contratos ----------
MULT_F, SUELTA, RECOGE, CAP_PVE, CAP_ZF, UDS = 2.0, 0.50, 0.70, 60, 120, 3.77
T_DEP, T_BANCO, T_EXTR, T_REENTRA = 13.0, 40.0, 53.0, 30.0
RACHA_PASO, RACHA_MAX = 0.02, 5
CONTRATOS_DIA, HORAS_DIA = 0.20, 2.0
val_dep = sum(p / 100 * f for p, f in zip(P_UR, F_VALOR))           # en V
dep_pve = CAP_PVE / UDS; t_pve = dep_pve * T_DEP + T_BANCO
ing_pve_s = dep_pve * val_dep / t_pve                                # V por segundo
dep_zf = CAP_ZF / UDS; t_zf = dep_zf * T_DEP + T_EXTR; C_zf = dep_zf * val_dep
def bono_racha(p): return sum(p * (1 - p) ** k * RACHA_PASO * min(k, RACHA_MAX) for k in range(200))
def minero_grieta(p, seguro=False):
    t = (1 - p) * t_zf + p * (0.6 * t_zf + T_REENTRA)
    v = (1 - p) * C_zf * MULT_F * (1 + bono_racha(p)) + p * 0.6 * C_zf * (1 - SUELTA)
    if seguro: v += p * 0.6 * C_zf * SUELTA * 0.5 - PRIMA
    return v / t / ing_pve_s
PRIMA = 6.0                                                          # V por entrada
def botin(kills_h, p_propia): return kills_h * 0.6 * C_zf * SUELTA * RECOGE * MULT_F * (1 - p_propia) / 3600 / ing_pve_s
contr = CONTRATOS_DIA / HORAS_DIA
PERFILES = [("Minero de grieta prudente (15 % de muertes)", minero_grieta(0.15), 0), ("Minero de grieta (30 %)", minero_grieta(0.30), 0),
            ("Minero de grieta en servidor hostil (50 %)", minero_grieta(0.50), 0),
            ("Híbrido: mina (25 %) y saquea 1,5 por hora", minero_grieta(0.25) * 0.9, botin(1.5, 0.25)),
            ("Saqueador puro: 8 muertes por hora", 0, botin(8, 0.20)),
            ("Máximo teórico: sin muertes y racha completa", t_pve / dep_pve * dep_zf / t_zf * MULT_F * (1 + RACHA_PASO * RACHA_MAX), 0)]
md("fractura", ["Perfil", "Minería (× PvE)", "Saqueo (× PvE)", "Contratos (× PvE)", "Total (× PvE)", "¿Bajo el techo de 2,5?"],
   [[a, n(m, 2), n(b, 2), n(contr, 2), n(m + b + contr, 2), "Sí" if m + b + contr <= 2.5 else "NO"] for a, m, b in PERFILES])
print(f"Carga completa en Zona Fracturada: {C_zf:.1f} V = {60*C_zf/479:.1f} min de ingreso PvE; viaje {t_zf:.0f} s; ritmo relativo {t_pve/dep_pve*dep_zf/t_zf:.3f}")
md("racha", ["Extracciones seguidas", "Bono", "Multiplicador del mineral"], [[k, f"+{int(100*RACHA_PASO*min(k,RACHA_MAX))} %", "×" + n(MULT_F * (1 + RACHA_PASO * min(k, RACHA_MAX)), 2)] for k in range(0, 7)])
md("racha_media", ["Prob. de morir por viaje", "Bono medio de racha"], [[f"{int(100*p)} %", "+" + n(100 * bono_racha(p), 1) + " %"] for p in (0.05, 0.15, 0.30, 0.50)])
filas = []
for p in (0.15, 0.30, 0.50, 0.60, 0.70):
    pago = p * 0.6 * C_zf * SUELTA * 0.5
    filas.append([f"{int(100*p)} %", n(PRIMA, 1), n(pago, 2), n(100 * pago / PRIMA) + " %", n(minero_grieta(p), 3), n(minero_grieta(p, True), 3)])
md("seguro", ["Prob. de morir por viaje", "Prima (V)", "Pago medio (V)", "Pago / prima", "Ingreso sin seguro (× PvE)", "Ingreso con seguro (× PvE)"], filas)
print(f"Seguro: con muerte al 60 % de carga, conserva 50 % a x1 + cobra 25 % = {100*(0.5+0.25)/2:.1f} % del valor que habria extraido; sin seguro {100*0.5/2:.0f} %")
for rec in (0.70, 0.85):
    print(f"Saqueador puro con {int(100*rec)} % recogible: {8*0.6*C_zf*SUELTA*rec*MULT_F*0.8/3600/ing_pve_s + contr:.2f} x PvE")

# ---------- 6. Ingresos y gastos por hora ----------
def xp_sig(L): return math.ceil(100 + 20 * L + 0.8 * L * L)
def horas_tramo(a, b): return sum(xp_sig(L) / (240 * xp_acc(L)) for L in range(max(a, 1), b))
H_ZONA = [horas_tramo(100 * (z - 1), 100 * z) for z in range(1, 11)]
OBJ = [("Pico y arma Raros", 2.4), ("Niveles 1–5 de ambos", 1.8), ("Pico y arma Épicos", 5.0), ("Niveles 1–10 de ambos", 13.75), ("Ranuras de ambos", 7.5),
       ("Pico y arma Legendarios", 10.0), ("Niveles 1–10", 27.5), ("Ranuras", 15.0), ("Despertar de habilidad", 15.0),
       ("Pico y arma Míticos", 20.0), ("Niveles 1–10", 55.0), ("Ranuras y Despertar", 60.0), ("Pico y arma Ultra raros", 40.0), ("Niveles, ranuras y Despertar", 230.0)]
PETS = 1.12
filas = []
for z in ZONAS:
    hz = H_ZONA[z-1]; neto_h = PETS * 1.0 - 0.05 - 0.15
    comp, gast = 0.0, 0.0
    for _, c in OBJ:
        if gast + c <= 0.9 * neto_h * hz: gast += c
        else: break
    for estilo, base, extra_g, extra_txt in [("Minero PvE", MINERO[z-1], 0.0, ""), ("Combatiente PvE", COMBAT[z-1], 0.0, ""),
                                             ("Zona Fracturada (minero, 30 % de muertes, con seguro)", MINERO[z-1] * (minero_grieta(0.30, True) + contr), 0.02, "")]:
        ing = base * PETS
        cons, caj, eq = 0.05 * base + extra_g * base, 0.15 * base, gast / hz * I(z)
        filas.append([z, estilo, n(ing), n(cons), n(caj), n(eq), n(ing - cons - caj - eq), n(ing / (MINERO[z-1] * PETS), 2)])
md("flujo", ["Zona", "Estilo", "Ingresos/hora", "Consumibles/hora", "Cajas/hora", "Equipo y mejoras/hora", "Ahorro/hora", "Ingresos frente al minero PvE"], filas)
md("horas_zona", ["Zona", "Horas de juego en la zona", "Ingreso total (horas de I)", "Objetivos de equipo que se pueden pagar"],
   [[z, n(H_ZONA[z-1], 1), n(H_ZONA[z-1] * (PETS - 0.2), 1),
     next((OBJ[i-1][0] if i else "Ninguno") for i in range(len(OBJ) + 1) if sum(c for _, c in OBJ[:i+1]) > H_ZONA[z-1] * (PETS - 0.2) or i == len(OBJ))] for z in range(1, 11)])
for z in ZONAS: pass

# ---------- 7. Otros precios ----------
md("otros", ["Concepto", "Precio", "Zona 1", "Zona 5", "Zona 10"],
   [[a, b] + [n(h * I(z)) for z in (1, 5, 10)] for a, b, h in [
     ("Poción de vida (cura 30 %)", "0,01 h", 0.01), ("Tónico de energía (+100 de energía)", "0,01 h", 0.01),
     ("Elixir de Suerte (+100 de Suerte, 15 min)", "0,10 h", 0.10), ("Pergamino de XP (+25 %, 30 min)", "0,15 h", 0.15),
     ("Baliza de extracción (aviso 30 s antes)", "0,05 h", 0.05), ("Seguro de carga (por entrada)", "6 V", 6 / 479),
     ("Reinicio de estadísticas", "1,5 h", 1.5), ("Evolución a forma desatada (por mascota)", "2 h", 2.0),
     ("Evolución a forma máxima (por mascota)", "8 h", 8.0), ("Forjar un objeto Celestial (más 60 fragmentos)", "10 h", 10.0),
     ("Aspecto de prestigio (cosmético)", "20 h", 20.0)]])
MOCH = [(80, 2, 0.5), (100, 3, 1), (120, 4, 2), (140, 5, 3), (160, 6, 5), (180, 8, 8), (200, 10, 12)]
md("mochila", ["Capacidad", "Disponible desde la zona", "Precio (horas de I de esa zona)", "Monedas"], [[c, z, n(h, 1), n(h * I(z))] for c, z, h in MOCH])

# ---------- 8. Masa monetaria: 1.000 jugadores, 90 dias ----------
HORAS_NIVEL = [0.0]
for L in range(1, 1000): HORAS_NIVEL.append(HORAS_NIVEL[-1] + xp_sig(L) / (240 * xp_acc(L)))
def nivel_por_horas(h):
    lo, hi = 0, len(HORAS_NIVEL) - 1
    while lo < hi:
        m = (lo + hi + 1) // 2
        if HORAS_NIVEL[m] <= h: lo = m
        else: hi = m - 1
    return lo + 1
ARQ = [("Casual", 0.50, 0.5, 6, 0.10), ("Regular", 0.35, 1.5, 9, 0.15), ("Dedicado", 0.15, 4.0, 14, 0.20)]
def simular(con_sumideros=True, dias=90, N=1000, semilla=6):
    rng = random.Random(semilla); js = []
    for nombre, frac, h, prof, pc in ARQ:
        for _ in range(int(N * frac)): js.append(dict(a=nombre, h=h, prof=prof, pc=pc, horas=0.0, saldo=0.0, zona=1, obj=0, pets=0))
    hist = {}
    for d in range(1, dias + 1):
        fa = su = 0.0
        for j in js:
            if rng.random() > 0.8: continue                          # 20 % de los dias no juega
            h = j["h"] * rng.uniform(0.7, 1.3); j["horas"] += h
            z = min(10, (nivel_por_horas(j["horas"]) // 100) + 1)
            if z != j["zona"]: j["zona"] = z; j["obj"] = 0
            iz = I(z)
            ing = h * iz * PETS + 0.10 * h * iz + (3 * 60 * V(z) if h >= 0.5 else 0)
            j["saldo"] += ing; fa += ing
            if not con_sumideros: continue
            g = (0.05 + j["pc"]) * h * iz; g = min(g, j["saldo"]); j["saldo"] -= g; su += g
            while j["obj"] < j["prof"] and j["saldo"] >= OBJ[j["obj"]][1] * iz:
                c = OBJ[j["obj"]][1] * iz; j["saldo"] -= c; su += c; j["obj"] += 1
            for umbral, coste in ((3, 6.0), (8, 24.0)):                # evolucion de 3 mascotas
                if z >= umbral and j["pets"] < umbral and j["saldo"] >= coste * iz and j["a"] != "Casual":
                    j["saldo"] -= coste * iz; su += coste * iz; j["pets"] = umbral
            if j["obj"] >= j["prof"] and j["saldo"] > 10 * iz:           # sumidero de prestigio: aspectos y cajas extra
                c = 0.5 * (j["saldo"] - 10 * iz); j["saldo"] -= c; su += c
        if d in (1, 7, 14, 30, 60, 90):
            ah = sorted(j["saldo"] / I(j["zona"]) for j in js)
            hist[d] = (sum(j["saldo"] for j in js), ah[len(ah) // 2], ah[int(len(ah) * 0.9)], fa, su,
                       sum(j["zona"] for j in js) / len(js), max(nivel_por_horas(j["horas"]) for j in js))
    return hist
con, sin = simular(True), simular(False)
md("masa", ["Día", "Masa monetaria total", "Entra ese día", "Sale ese día", "Sale / entra", "Ahorro mediano (horas de ingreso)", "Ahorro del 10 % más rico (horas)", "Zona media", "Nivel máximo",
            "Masa sin sumideros", "Ahorro mediano sin sumideros (horas)"],
   [[d, n(con[d][0]), n(con[d][3]), n(con[d][4]), n(100 * con[d][4] / con[d][3]) + " %", n(con[d][1], 1), n(con[d][2], 1), n(con[d][5], 1), con[d][6],
     n(sin[d][0]), n(sin[d][1], 1)] for d in sorted(con)])
print(f"Dia 90: la masa con sumideros es el {100*con[90][0]/sin[90][0]:.1f} % de la que habria sin ellos")

if len(sys.argv) > 1:
    os.makedirs(sys.argv[1], exist_ok=True)
    for k, v in frag.items(): open(os.path.join(sys.argv[1], k + ".md"), "w", encoding="utf-8").write(v)
