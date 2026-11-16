"""OREBOUND - Etapa 6 (B6), rehecha con el GDD: economia.
Ejecutar desde OREBOUND/:  python3 calculos/b6_economia.py   (despues de b2 a b5)
Genera B_Matematico/B6_Economia.md, calculos/b6_precios_*.csv y calculos/_b6.json"""
import csv, math, random, sys, os, json
from fractions import Fraction as Fr
sys.path.insert(0, os.path.dirname(__file__))
from montar import montar, tabla, n
B3 = json.load(open("calculos/_b3.json")); B4 = json.load(open("calculos/_b4.json")); B5 = json.load(open("calculos/_b5.json"))
G = 2.0
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
CAJA = [50, 26, 14, 7, 2.4, 0.5, 0.1]; REAL = [49.128, 25.573, 13.888, 6.962, 3.050, 1.171, 0.228]
P_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; UNIDADES = [4, 4, 3, 3, 2, 2, 1]; F_VALOR = [1, 1.8, 3.2, 6, 12, 25, 60]
MINERO, COMBAT = B3["minero_eq"], B4["combate_eq"]; ZONAS = (1, 3, 5, 8, 10)
def V(z): return 10 * G ** (z - 1)
def I(z): return (MINERO[z-1] + COMBAT[z-1]) / 2
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def xp_sig(L): return math.ceil(100 + 20 * L + 0.8 * L * L)
frag, kv = {}, {}
IV = sum(I(z) / V(z) for z in range(1, 11)) / 10
frag["ingreso_ref"] = tabla(["Zona", "Valor de zona V", "Minero (B3)", "Combatiente (B4)", "Ingreso de referencia I", "I / V"],
    [[z, n(V(z)), n(MINERO[z-1]), n(COMBAT[z-1]), n(I(z)), n(I(z) / V(z))] for z in range(1, 11)])
kv.update(iv=n(IV), i1=n(I(1)), i10=n(I(10)))
PETS = 1 + round(min(B5["bono_combate"], B5["bono_mineria"]), 2); kv["pets"] = n(100 * (PETS - 1)); kv["sexto"] = n(B5["sexto"], 1)

# 1. Venta de minerales
frag["venta"] = tabla(["Zona"] + RAR, [[z] + [n(V(z) * F_VALOR[r] / UNIDADES[r], 1) for r in range(7)] for z in range(1, 11)])
with open("calculos/b3_minerales.csv", encoding="utf-8") as fh, open("calculos/b6_precios_minerales.csv", "w", newline="", encoding="utf-8") as out:
    w = csv.writer(out); w.writerow(["mineral", "zona", "rareza", "precio_venta_unidad", "precio_fracturado_extraido_sin_racha", "precio_fracturado_racha_maxima"])
    for f in csv.DictReader(fh): w.writerow([f["mineral"], f["zona"], f["rareza"], f["valor_unidad"], round(float(f["valor_unidad"]) * 1.5, 1), round(float(f["valor_unidad"]) * 2.25, 1)])

# 2. Equipo
H = [0.3, 0.6, 1.2, 2.5, 5, 10, 20]
RECETA = ["30 Lingotes Común", "40 Lingotes Común + 20 Lingotes Poco común", "30 Lingotes Poco común + 15 Placas Raro", "30 Placas Raro + 10 Gemas talladas",
          "20 Gemas talladas + 8 Núcleos de mena + 2 de jefe", "15 Núcleos de mena + 6 Catalizadores + 4 de jefe", "10 Catalizadores + 4 Esencias + 6 de jefe + 1 gema antigua"]
REC = [{0: 30}, {0: 40, 1: 20}, {1: 30, 2: 15}, {2: 30, 3: 10}, {3: 20, 4: 8}, {4: 15, 5: 6}, {5: 10, 6: 4}]; DEP_H = B3["dep_h"][4]
def horas_mat(rec): return max(q / (DEP_H * P_UR[r] / 100 * UNIDADES[r]) for r, q in rec.items()), sum(q * F_VALOR[r] / UNIDADES[r] for r, q in rec.items()) / IV
frag["equipo"] = tabla(["Rareza", "Monedas (horas de ingreso)", "Receta (minerales de la zona)", "Horas de minería para el material más escaso", "Valor de venta de los materiales (horas)",
                        "Niveles 1–10 (horas)", "3 ranuras (horas)", "Despertar de habilidad (horas)", "Total al máximo (horas)"],
    [[RAR[r], n(H[r], 1), RECETA[r], n(horas_mat(REC[r])[0], 1), n(horas_mat(REC[r])[1], 2), n(2.75 * H[r], 2), n(1.5 * H[r], 2), n(1.5 * H[r], 2), n(6.75 * H[r], 1)] for r in range(7)])
frag["equipo_monedas"] = tabla(["Zona"] + RAR, [[z] + [n(H[r] * I(z)) for r in range(7)] for z in range(1, 11)])
with open("calculos/b6_precios_equipo.csv", "w", newline="", encoding="utf-8") as out:
    w = csv.writer(out); w.writerow(["zona", "rareza", "monedas_fabricar", "monedas_niveles_1_10", "monedas_3_ranuras", "monedas_despertar", "venta_al_mercader"])
    for z in range(1, 11):
        for r in range(7): b = H[r] * I(z); w.writerow([z, RAR[r], round(b), round(2.75 * b), round(1.5 * b), round(1.5 * b), round(0.1 * b)])
kv.update(ur_max=n(6.75 * H[6]), ur_mat=n(horas_mat(REC[6])[0], 1))

# 3. Enemigos y jefes
FM = B4["F_MON"]; FX = {"Común": 1, "Élite": 3.5, "Guardián": 10, "Jefe": 60}
frag["enemigos"] = tabla(["Zona", "Común: monedas", "Élite", "Guardián", "Jefe (por jugador)", "Común: XP", "Élite", "Guardián", "Jefe", "Material de jefe"],
    [[z] + [n(V(z) * FM[t]) for t in FX] + [n(B4["K_XP"] * xp_acc(100 * (z - 1) + 50) * FX[t]) for t in FX] + ["3"] for z in range(1, 11)])
kv.update(fm_c=n(FM["Común"], 2), fm_e=n(FM["Élite"], 2), fm_g=n(FM["Guardián"], 2), jefe_min=n(60 / IV * 60, 1))

# 4. Cajas
ev_armas = sum(REAL[r] / 100 * H[r] for r in range(7)); LOTE = [0.15, 0.25, 0.4, 0.8, 2, 5, 12]; ev_lote = sum(REAL[r] / 100 * LOTE[r] for r in range(7))
ev_zona = 0.35 * ev_armas + 0.55 * ev_lote + 0.10 * 0.2
frag["cajas_precio"] = tabla(["Caja", "Precio (horas de I)"] + [f"Zona {z}" for z in ZONAS] + ["Valor medio del contenido (horas)", "Valor de reventa (horas)"],
    [["De armas", "1,00"] + [n(I(z)) for z in ZONAS] + [n(ev_armas, 2), n(0.1 * ev_armas, 2)],
     ["De zona", "0,60"] + [n(0.6 * I(z)) for z in ZONAS] + [n(ev_zona, 2), n(0.035 * ev_armas + 0.55 * ev_lote, 2)],
     ["De mascotas", "0,75"] + [n(0.75 * I(z)) for z in ZONAS] + ["—", "0 (no se venden)"],
     ["De Núcleos", "3,00"] + [n(3 * I(z)) for z in ZONAS] + ["—", "0 (no se venden)"]])
MASC = [("Topillo de Pizarra", "Común", 25), ("Luciérnaga de Veta", "Común", 25), ("Zorro de Ascua", "Poco común", 13), ("Tortuga Geoda", "Poco común", 13), ("Murciélago de Eco", "Raro", 7),
        ("Nutria Salina", "Raro", 7), ("Búho Boreal", "Épico", 3.5), ("Carnero de Magma", "Épico", 3.5), ("Mantis Vitral", "Legendario", 1.2), ("Guiverno de Cuarzo", "Legendario", 1.2),
        ("Ciervo Astral", "Mítico", 0.5), ("Sierpe de Nova", "Ultra raro", 0.1)]
NUC = [("Núcleo de Brasa", "Raro", 30), ("Núcleo de Escarcha", "Raro", 30), ("Núcleo Prismático", "Épico", 15), ("Núcleo de Tormenta", "Épico", 15), ("Núcleo Sísmico", "Legendario", 5), ("Núcleo Umbrío", "Legendario", 5)]
assert sum(Fr(str(p)) for _, _, p in MASC) == 100 and sum(p for _, _, p in NUC) == 100 and sum(Fr(str(x)) for x in CAJA) == 100
frag["caja_mascotas"] = tabla(["Huevo", "Rareza", "Probabilidad"], [[a, b, n(c, 1) + "%"] for a, b, c in MASC] + [["**Suma**", "", "**100,0%**"]])
frag["caja_nucleos"] = tabla(["Núcleo", "Rareza", "Probabilidad"], [[a, b, f"{c}%"] for a, b, c in NUC] + [["**Suma**", "", "**100%**"]])
rng = random.Random(3); tot = 0
for _ in range(20000):
    vistos = set(); k = 0
    while len(vistos) < 6: vistos.add(rng.choices(range(6), [c for _, _, c in NUC])[0]); k += 1
    tot += k
CAT = [("Pico de la zona", 35), ("Lote de minerales de la zona", 40), ("Materiales de fabricación", 15), ("Lote de consumibles", 10)]
assert sum(Fr(pc) * Fr(str(CAJA[r])) / 100 for _, pc in CAT for r in range(7)) == 100
frag["caja_zona"] = tabla(["Categoría", "Probabilidad"] + RAR, [[c, f"{pc}%"] + [n(pc * CAJA[r] / 100, 3) + "%" for r in range(7)] for c, pc in CAT] + [["**Suma**", "**100%**"] + [n(CAJA[r], 1) + "%" for r in range(7)]])
p_leg = (REAL[4] + REAL[5] + REAL[6]) / 100 / 6
kv.update(cajas_leg=n(1 / p_leg), ev_armas=n(ev_armas, 2), nuc_todos=n(tot / 20000, 1), nuc_h=n(3 * tot / 20000))

# 5. Zonas Fracturadas
MULT_F, SUELTA, RECOGE, RACHA_PASO, RACHA_TOPE = B3["MULT_F"], 0.50, B3["RECOGE"], 0.10, 1.50
T_PVE, T_ZF, UDS, VAL_DEP = B3["T_PVE"], B3["T_ZF"], B3["uds"], B3["VAL_DEP"]
C_ZF = 120 / UDS * VAL_DEP; ING_PVE_S = (60 / UDS) * VAL_DEP / T_PVE; CONTR = 0.20 / 2.0
SEG_REC = {1: 8, 2: 1}; PRIMA = sum(q * F_VALOR[r] / UNIDADES[r] for r, q in SEG_REC.items())
def racha_media(p): return RACHA_TOPE if p == 0 else sum(p * (1 - p) ** k * min(1 + RACHA_PASO * k, RACHA_TOPE) for k in range(400))
def grieta(p, seguro=False):
    suelta = SUELTA * (0.5 if seguro else 1.0)
    t = (1 - p) * T_ZF + p * (0.6 * T_ZF + 30)
    v = (1 - p) * C_ZF * MULT_F * racha_media(p) + p * 0.6 * C_ZF * (1 - suelta) - (PRIMA if seguro else 0)
    return v / t / ING_PVE_S
def botin(kills_h, p_propia, recoge=RECOGE): return kills_h * 0.6 * C_ZF * SUELTA * recoge * MULT_F * (1 - p_propia) / 3600 / ING_PVE_S
RITMO = (T_PVE / (60 / UDS)) * (120 / UDS) / T_ZF
PERF = [("Minero de grieta prudente (15% de muertes)", grieta(.15), 0), ("Minero de grieta (30%)", grieta(.30), 0), ("Minero de grieta en servidor hostil (50%)", grieta(.50), 0),
        ("Híbrido: mina (25%) y derrota a 1,5 portadores por hora", grieta(.25) * 0.9, botin(1.5, .25)), ("Saqueador puro: 8 derrotas por hora", 0, botin(8, .20)),
        ("Máximo teórico: sin muertes y racha completa", RITMO * MULT_F * RACHA_TOPE, 0)]
frag["fractura"] = tabla(["Perfil", "Minería (× PvE)", "Saqueo (× PvE)", "Contratos (× PvE)", "Total (× PvE)", "¿Bajo el techo de 2,5?"],
    [[a, n(m, 2), n(b, 2), n(CONTR, 2), n(m + b + CONTR, 2), "Sí" if m + b + CONTR <= 2.5 else "NO"] for a, m, b in PERF])
assert all(m + b + CONTR <= 2.5 for _, m, b in PERF)
filas = []
for p in (0.15, 0.30, 0.50, 0.70): filas.append([f"{int(100*p)}%", n(grieta(p), 2), n(grieta(p, True), 2), n(100 * (grieta(p, True) / grieta(p) - 1), 1) + "%"])
frag["seguro"] = tabla(["Prob. de morir por viaje", "Ingresos sin seguro (× PvE)", "Con seguro (× PvE)", "Diferencia"], filas)
lo, hi = 0.0, 1.0
for _ in range(60):
    mid = (lo + hi) / 2
    if grieta(mid, True) > grieta(mid): hi = mid
    else: lo = mid
kv.update(c_zf=n(C_ZF, 1), c_min=n(60 * C_ZF / IV, 1), prima=n(PRIMA, 1), prima_pct=n(100 * PRIMA / C_ZF, 1), seg_p=n(100 * lo), max_teo=n(RITMO * MULT_F * RACHA_TOPE + CONTR, 2), mult_f=n(MULT_F, 1),
          g15=n(grieta(.15) + CONTR, 2), g30=n(grieta(.30) + CONTR, 2), g50=n(grieta(.50) + CONTR, 2), saq=n(botin(8, .20) + CONTR, 2), hib=n(grieta(.25) * 0.9 + botin(1.5, .25) + CONTR, 2),
          cabeza=n(botin(8, .20, 1.0) / botin(8, .20), 2))
frag["gdd_zonas"] = tabla(["Zona", "Minero PvE (monedas/hora)", "Minero de grieta, 30% de muertes", "× PvE", "Saqueador puro", "× PvE"],
    [[z, n(MINERO[z-1]), n(MINERO[z-1] * (grieta(.30) + CONTR)), n(grieta(.30) + CONTR, 2), n(MINERO[z-1] * (botin(8, .20) + CONTR)), n(botin(8, .20) + CONTR, 2)] for z in (2, 5, 8)])

# 6. Flujo por hora
def horas_tramo(a, b): return sum(xp_sig(L) / (240 * xp_acc(L)) for L in range(max(a, 1), b))
H_ZONA = [horas_tramo(100 * (z - 1), 100 * z) for z in range(1, 11)]
OBJ = [("Pico y arma Raros", 2.4), ("Niveles 1–5 de ambos", 1.8), ("Pico y arma Épicos", 5.0), ("Niveles 1–10 de ambos", 13.75), ("Ranuras de ambos", 7.5), ("Pico y arma Legendarios", 10.0),
       ("Niveles 1–10", 27.5), ("Ranuras", 15.0), ("Despertar de habilidad", 15.0), ("Pico y arma Míticos", 20.0), ("Niveles 1–10", 55.0), ("Ranuras y Despertar", 60.0),
       ("Pico y arma Ultra raros", 40.0), ("Niveles, ranuras y Despertar", 230.0)]
filas = []; gasto = []; rel = []
for z in ZONAS:
    hz = H_ZONA[z-1]; g = 0.0
    for _, c in OBJ:
        if g + c <= 0.9 * (PETS - 0.2) * hz: g += c
        else: break
    for est, base, xg in [("Minero PvE", MINERO[z-1], 0), ("Combatiente PvE", COMBAT[z-1], 0), ("Zona Fracturada (minero, 30% de muertes, con seguro)", MINERO[z-1] * (grieta(.30, True) + CONTR), 0.02)]:
        ing = base * PETS; cons, caj, eq = (0.05 + xg) * base, 0.15 * base, g / hz * I(z)
        if "PvE" in est: gasto.append(100 * (cons + caj + eq) / ing)
        rel.append(ing / (MINERO[z-1] * PETS))
        filas.append([z, est, n(ing), n(cons), n(caj), n(eq), n(ing - cons - caj - eq), n(ing / (MINERO[z-1] * PETS), 2)])
frag["flujo"] = tabla(["Zona", "Estilo", "Ingresos/hora", "Consumibles/hora", "Cajas/hora", "Equipo y mejoras/hora", "Ahorro/hora", "Ingresos frente al minero PvE"], filas)
cm = [COMBAT[z-1] / MINERO[z-1] for z in range(1, 11)]
kv.update(gasto_min=n(min(gasto)), gasto_max=n(max(gasto)), cm_min=n(min(cm), 2), cm_max=n(max(cm), 2), zf_flujo=n(grieta(.30, True) + CONTR, 2))
def alcanza(z):
    tot_, ult = 0.0, "Ninguno"
    for nom, c in OBJ:
        if tot_ + c > H_ZONA[z-1] * (PETS - 0.2): break
        tot_ += c; ult = nom
    return ult
frag["horas_zona"] = tabla(["Zona", "Horas de juego en la zona", "Ingreso disponible (horas de I)", "Último objetivo de equipo que se puede pagar"],
    [[z, n(H_ZONA[z-1], 1), n(H_ZONA[z-1] * (PETS - 0.2), 1), alcanza(z)] for z in range(1, 11)])

# 7. Otros precios
frag["otros"] = tabla(["Concepto", "Precio", "Zona 1", "Zona 5", "Zona 10"], [[a, b] + [n(h * I(z)) for z in (1, 5, 10)] for a, b, h in [
    ("Poción de vida (cura 30%)", "0,01 h", 0.01), ("Tónico de energía (+100 de energía)", "0,01 h", 0.01), ("Elixir de Suerte (+100 de Suerte, 15 min)", "0,10 h", 0.10),
    ("Pergamino de XP (+25%, 30 min)", "0,15 h", 0.15), ("Sello de Reajuste (cambiar de Núcleo fuera de la ciudad)", "0,05 h", 0.05), ("Reinicio de estadísticas", "1,5 h", 1.5),
    ("Evolución a forma desatada (por mascota)", "2 h", 2.0), ("Evolución a forma máxima (por mascota)", "8 h", 8.0), ("Forjar un objeto Celestial (más 50 fragmentos)", "10 h", 10.0),
    ("Aspecto de prestigio (cosmético)", "20 h", 20.0)]])
MOCH = [(80, 2, 0.5), (100, 3, 1), (120, 4, 2), (140, 5, 3), (160, 6, 5), (180, 8, 8), (200, 10, 12)]
frag["mochila"] = tabla(["Capacidad", "Disponible desde la zona", "Precio (horas de I de esa zona)", "Monedas"], [[c, z, n(h, 1), n(h * I(z))] for c, z, h in MOCH])

# 8. Masa monetaria
HN = [0.0]
for L in range(1, 1000): HN.append(HN[-1] + xp_sig(L) / (240 * xp_acc(L)))
def nivel_h(h):
    lo_, hi_ = 0, len(HN) - 1
    while lo_ < hi_:
        m = (lo_ + hi_ + 1) // 2
        if HN[m] <= h: lo_ = m
        else: hi_ = m - 1
    return lo_ + 1
ARQ = [("Casual", 0.50, 0.5, 6, 0.10), ("Regular", 0.35, 1.5, 9, 0.15), ("Dedicado", 0.15, 4.0, 14, 0.20)]
def simular(sumideros=True, dias=90, NJ=1000, semilla=6):
    rng = random.Random(semilla); js = []
    for nom, fr, h, prof, pc in ARQ:
        for _ in range(int(NJ * fr)): js.append(dict(a=nom, h=h, prof=prof, pc=pc, horas=0.0, saldo=0.0, zona=1, obj=0, pets=0))
    hist = {}
    for d in range(1, dias + 1):
        fa = su = 0.0
        for j in js:
            if rng.random() > 0.8: continue
            h = j["h"] * rng.uniform(0.7, 1.3); j["horas"] += h; z = min(10, nivel_h(j["horas"]) // 100 + 1)
            if z != j["zona"]: j["zona"] = z; j["obj"] = 0
            iz = I(z); ing = h * iz * PETS + 0.10 * h * iz + (3 * 60 * V(z) if h >= 0.5 else 0); j["saldo"] += ing; fa += ing
            if not sumideros: continue
            g = min((0.05 + j["pc"]) * h * iz, j["saldo"]); j["saldo"] -= g; su += g
            while j["obj"] < j["prof"] and j["saldo"] >= OBJ[j["obj"]][1] * iz: c = OBJ[j["obj"]][1] * iz; j["saldo"] -= c; su += c; j["obj"] += 1
            for umb, coste in ((3, 6.0), (8, 24.0)):
                if z >= umb and j["pets"] < umb and j["saldo"] >= coste * iz and j["a"] != "Casual": j["saldo"] -= coste * iz; su += coste * iz; j["pets"] = umb
            if j["obj"] >= j["prof"] and j["saldo"] > 10 * iz: c = 0.5 * (j["saldo"] - 10 * iz); j["saldo"] -= c; su += c
        if d in (1, 7, 14, 30, 60, 90):
            ah = sorted(j["saldo"] / I(j["zona"]) for j in js)
            hist[d] = (sum(j["saldo"] for j in js), ah[len(ah) // 2], ah[int(len(ah) * 0.9)], fa, su, sum(j["zona"] for j in js) / len(js), max(nivel_h(j["horas"]) for j in js))
    return hist
con, sin = simular(True), simular(False)
frag["masa"] = tabla(["Día", "Masa monetaria total", "Entra ese día", "Sale ese día", "Sale / entra", "Ahorro mediano (horas de ingreso)", "Ahorro del 10% más rico (horas)", "Zona media", "Nivel máximo", "Ahorro mediano sin sumideros (horas)"],
    [[d, n(con[d][0]), n(con[d][3]), n(con[d][4]), n(100 * con[d][4] / con[d][3]) + "%", n(con[d][1], 1), n(con[d][2], 1), n(con[d][5], 1), con[d][6], n(sin[d][1], 1)] for d in sorted(con)])
med = [con[d][1] for d in (14, 30, 60, 90)]; ric = [con[d][2] for d in (14, 30, 60, 90)]
kv.update(med_min=n(min(med), 1), med_max=n(max(med), 1), ric_min=n(min(ric)), ric_max=n(max(ric)), sin90=n(sin[90][1], 1), masa1=n(con[1][0] / 1e6, 1), masa90=n(con[90][0] / 1e6))
json.dump({"I": [I(z) for z in range(1, 11)], "IV": IV, "PETS": PETS, "PRIMA": PRIMA, "CONTR": CONTR, "H": H}, open("calculos/_b6.json", "w"))
montar("plantillas/B6.md", "B_Matematico/B6_Economia.md", frag, kv)
for k in sorted(kv): print(f"  {k} = {kv[k]}")
