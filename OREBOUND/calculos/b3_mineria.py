"""OREBOUND - Etapa 3 (B3), rehecha con el GDD: mineria y Zonas Fracturadas.
Ejecutar desde OREBOUND/:  python3 calculos/b3_mineria.py
Genera B_Matematico/B3_Mineria.md, calculos/b3_minerales.csv, calculos/b3_picos.csv y calculos/_b3.json"""
import csv, math, random, sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from montar import montar, tabla, n

RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = [1.00, 1.25, 1.50, 1.90, 2.50, 3.30, 4.50]; MULT_CEL = 5.20            # GDD
VEL = [1.00, 1.02, 1.04, 1.06, 1.08, 1.10, 1.12]; VEL_CEL = 1.15
P_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; P_SIN = [55, 25, 12, 5.5, 2, 0.50, 0]
F_VIDA = [6, 9, 14, 22, 35, 55, 90]; F_VALOR = [1, 1.8, 3.2, 6, 12, 25, 60]; F_XP = [1, 1.4, 2, 3, 4.5, 7, 11]
UNIDADES = [4, 4, 3, 3, 2, 2, 1]; F_REQ_MIN = [1, 1, 1.5, 2.5, 3.5, 5, 7]; F_REQ_PICO = [1, 1, 1.2, 1.5, 2, 2.5, 3]
G, REQ_PICO, TOPE_BONO = 2.00, 0.5, 0.50
ZONAS = ["Cantera del Alba", "Galerías de Musgo", "Vetas Salinas", "Grutas de Brasa", "Sima Helada",
         "Bóveda de Ecos", "Minas Oscuras", "Mar de Magma", "Catedral de Cristal", "Núcleo Astral"]
CON_UR = {3, 5, 7, 8, 9, 10}
MIN = {1: ["Pizarra Clara", "Cobre Rosado", "Estaño Lunar", "Cuarzo Meloso", "Ámbar de Aurora", "Ópalo Naciente"],
       2: ["Piedra Verdín", "Hierro Musgoso", "Malaquita Viva", "Jade de Raíz", "Esmeralda Húmeda", "Corazón de Liquen"],
       3: ["Sal Gema", "Yeso Nacarado", "Plata Salobre", "Aguamarina Seca", "Perla de Veta", "Zafiro de Marea", "Lágrima de Salmuera"],
       4: ["Carbón Tibio", "Azufre Dorado", "Bronce Ardiente", "Granate de Ascua", "Rubí de Fragua", "Topacio Incandescente"],
       5: ["Hielo Gris", "Cobalto Escarchado", "Platino Glacial", "Celestina Invernal", "Diamante de Escarcha", "Zafiro Boreal", "Copo Eterno"],
       6: ["Basalto Sonoro", "Níquel Vibrante", "Electro Resonante", "Amatista de Eco", "Oro Armónico", "Cristal Diapasón"],
       7: ["Obsidiana Mate", "Titanio Sombrío", "Ónice Veteado", "Espinela Nocturna", "Iridio Umbrío", "Diamante de Raíz Negra", "Semilla de Vacío"],
       8: ["Escoria Roja", "Wolframio Fundido", "Cinabrio Líquido", "Ópalo de Fuego", "Paladio Solar", "Corindón Volcánico", "Corazón de Caldera"],
       9: ["Vidrio de Roca", "Berilo Translúcido", "Turmalina Vitral", "Kunzita Coral", "Alejandrita Prisma", "Diamante Catedral", "Rosetón Luminoso"],
       10: ["Polvo Estelar", "Meteorito Férreo", "Moldavita Astral", "Tanzanita Cósmica", "Oricalco Sideral", "Estelita Pura", "Fragmento de Nova"]}
MATERIAL = ["Lingote", "Lingote", "Placa", "Gema tallada", "Núcleo de mena", "Catalizador", "Esencia"]
USO = ["Fabricar picos y armas Común y Poco común", "Subir el nivel de objeto (1-5)", "Fabricar picos y armas Raro y Épico; nivel de objeto (6-10)",
       "Ranuras de mejora", "Fabricar picos y armas Legendario", "Fabricar picos y armas Mítico; Despertar de habilidad", "Fabricar picos y armas Ultra raro"]
PREF = ["Pizarra", "Verdín", "Sal", "Brasa", "Escarcha", "Eco", "Obsidiana", "Magma", "Vitral", "Astral"]
PASIVAS = ["1 menor", "1 menor", "1 menor", "1 mayor", "1 mayor", "1 mayor + 1 menor", "1 mayor + 1 menor"]
COMBATE = ["Ninguna", "Ninguna", "Ninguna", "+3% (tope PvP +2%)", "+3% (tope PvP +2%)", "+5% (tope PvP +3%)", "+5% (tope PvP +3%)"]
frag, kv = {}, {}
def pot_zona(z): return 100 * G ** (z - 1)
def nivel_zona(z): return max(1, 100 * (z - 1))
def nivel_medio(z): return 100 * (z - 1) + 50
def dureza(z): return min(2.0, 1 + 0.1 * (z - 1))
def req_min_zona(z): return 10 * (min(z, 10) - 1)
def valor_zona(z): return 10 * G ** (z - 1)
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def probs(z): return P_UR if z in CON_UR else P_SIN
def vida(z, r): return pot_zona(z) * F_VIDA[r] * dureza(z)
def valor(z, r): return valor_zona(z) * F_VALOR[r]
def t_extraer(z, r, pot, vel, mm): return max(3, math.ceil(vida(z, r) / (pot * mm))) / vel
def puntos(L): return 3 + 3 * (L - 1)
BUILDS = {"Minería (50%)": 0.50, "Equilibrada (12,5%)": 0.125, "Combate (5%)": 0.05}
def mineria(b, L): return min(1000, int(puntos(L) * BUILDS[b]))
CAP, T_BANCO, VIAJE = 60, 40.0, 6.0
def ritmo(z, b, L=None, k_xp=1.0, mult_pico=MULT[2], vel=VEL[2]):
    L = L or (nivel_medio(z) if z > 1 else 50); m = mineria(b, L); p = [x / 100 for x in probs(z)]
    ok = [r for r in range(7) if p[r] > 0 and m >= req_min_zona(z) * F_REQ_MIN[r]]; pt = sum(p[r] for r in ok)
    tm = sum(p[r] * t_extraer(z, r, pot_zona(z) * mult_pico, vel, sat(m)) for r in ok) / pt
    uds = sum(p[r] * UNIDADES[r] for r in ok) / pt; dh = 3600 / (tm + VIAJE + T_BANCO * uds / CAP)
    return dict(L=L, m=m, tm=tm, dh=dh, mon=dh * sum(p[r] * valor(z, r) for r in ok) / pt,
                xp=dh * sum(p[r] * k_xp * xp_acc(L) * F_XP[r] for r in ok) / pt, tope=RAR[max(ok)])
K_XP = round(240 * xp_acc(450) / ritmo(5, "Equilibrada (12,5%)")["xp"], 2)     # calibrado para la XP/hora de B2

# 1. Zonas y builds
frag["zonas"] = tabla(["Zona", "Nombre", "Nivel", "Minería requerida", "Potencia de pico requerida", "PotZona", "Dureza", "Ultra raro"],
    [[z, ZONAS[z-1], nivel_zona(z), req_min_zona(z), n(REQ_PICO * pot_zona(z)), n(pot_zona(z)), n(dureza(z), 1), "Sí" if z in CON_UR else "No"] for z in range(1, 11)])
filas = []
for z in range(1, 11):
    L = nivel_zona(z); pico = pot_zona(max(z - 1, 1)) * (MULT[2] if z > 1 else 1.0)
    for b in BUILDS:
        m = mineria(b, L); tope = max(r for r in range(7) if probs(z)[r] > 0 and m >= req_min_zona(z) * F_REQ_MIN[r])
        filas.append([z, b, m, "Sí" if m >= req_min_zona(z) and pico >= REQ_PICO * pot_zona(z) else "No", RAR[tope], n(sat(m), 2),
                      n(t_extraer(z, 0, pico, VEL[2] if z > 1 else 1.0, sat(m)), 1)])
frag["builds"] = tabla(["Zona", "Build", "Minería al entrar", "¿Entra?", "Rareza máxima que puede picar", "Mult. Minería", "s por depósito Común con el pico anterior"], filas)
assert all(f[3] == "Sí" for f in filas)
kv.update(t_comb10=filas[-1][6], t_min10=filas[-3][6])

# 2. Catalogo
cat = []
for z in range(1, 11):
    assert abs(sum(probs(z)) - 100) < 1e-9
    for r, nombre in enumerate(MIN[z]):
        cat.append(dict(mineral=nombre, zona=z, rareza=RAR[r], vida=round(vida(z, r)), valor_deposito=round(valor(z, r)), unidades=UNIDADES[r],
                        valor_unidad=round(valor(z, r) / UNIDADES[r], 1), xp=round(K_XP * xp_acc(nivel_medio(z) if z > 1 else 50) * F_XP[r]),
                        pico_requerido=round(REQ_PICO * pot_zona(z)), mineria_requerida=round(req_min_zona(z) * F_REQ_MIN[r]),
                        material=f"{MATERIAL[r]} de {nombre}", uso=USO[r], probabilidad=probs(z)[r]))
with open("calculos/b3_minerales.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=list(cat[0])); w.writeheader(); w.writerows(cat)
frag["catalogo"] = tabla(["Zona", "Mineral", "Rareza", "Vida", "Valor del depósito", "Unidades", "XP", "Minería req.", "Material", "Prob."],
    [[c["zona"], c["mineral"], c["rareza"], n(c["vida"]), n(c["valor_deposito"]), c["unidades"], n(c["xp"]), c["mineria_requerida"], c["material"], n(c["probabilidad"], 2) + "%"] for c in cat])
frag["factores"] = tabla(["Rareza", "FactorVida (s de referencia)", "FactorValor", "FactorXP", "Unidades por depósito", "Minería requerida (× 10 × (zona − 1))", "Valor por segundo de referencia"],
    [[RAR[r], F_VIDA[r], n(F_VALOR[r], 1), n(F_XP[r], 1), UNIDADES[r], n(F_REQ_MIN[r], 1), n(F_VALOR[r] / F_VIDA[r], 2)] for r in range(7)])
kv.update(k_xp=n(K_XP, 2), ej_vida=n(vida(4, 4)), ej_pz=n(pot_zona(4)), ej_valor=n(valor(4, 4)), ej_vz=n(valor_zona(4)), req5=n(REQ_PICO * pot_zona(5)), n_min=len(cat))

# 3. Picos
picos = []
for z in range(1, 11):
    for r in range(7):
        picos.append(dict(pico=f"Pico de {PREF[z-1]} ({RAR[r]})", zona=z, rareza=RAR[r], potencia=round(pot_zona(z) * MULT[r]),
                          potencia_maxima=round(pot_zona(z) * MULT[r] * (1 + TOPE_BONO)), golpes_s=VEL[r], nivel=nivel_zona(z),
                          mineria=round(req_min_zona(z) * F_REQ_PICO[r]), pasivas=PASIVAS[r], estadistica_combate=COMBATE[r]))
    if z >= 6:
        picos.append(dict(pico=f"Pico Celestial de {PREF[z-1]}", zona=z, rareza="Celestial", potencia=round(pot_zona(z) * MULT_CEL),
                          potencia_maxima=round(pot_zona(z) * MULT_CEL * (1 + TOPE_BONO)), golpes_s=VEL_CEL, nivel=nivel_zona(z),
                          mineria=round(req_min_zona(z) * 3), pasivas="1 única", estadistica_combate="+6% (tope PvP +3%)"))
with open("calculos/b3_picos.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=list(picos[0])); w.writeheader(); w.writerows(picos)
frag["picos_potencia"] = tabla(["Zona", "Nivel"] + RAR + ["Celestial"],
    [[z, nivel_zona(z)] + [n(pot_zona(z) * m) for m in MULT] + [n(pot_zona(z) * MULT_CEL) if z >= 6 else "—"] for z in range(1, 11)])
frag["picos_rareza"] = tabla(["Rareza", "Mult. de potencia", "Golpes/s", "Minería para equipar", "Pasivas de recolección", "Estadística de combate"],
    [[RAR[r], "×" + n(MULT[r], 2), n(VEL[r], 2), f"{n(10*F_REQ_PICO[r])} × (zona − 1)", PASIVAS[r], COMBATE[r]] for r in range(7)] +
    [["Celestial", "×" + n(MULT_CEL, 2), n(VEL_CEL, 2), "30 × (zona − 1)", "1 única", "+6% (tope PvP +3%)"]])
kv.update(n_picos=len(picos))

# 4. Tiempos
filas = []
for z in range(1, 11):
    m = sat(mineria("Equilibrada (12,5%)", nivel_zona(z)))
    for nom, mu, ve in (("Común", MULT[0], VEL[0]), ("Ultra raro", MULT[6], VEL[6])):
        filas.append([z, n(m, 2), nom] + [n(t_extraer(z, r, pot_zona(z) * mu, ve, m), 1) if probs(z)[r] > 0 else "—" for r in range(7)])
frag["tiempos"] = tabla(["Zona", "Mult. Minería", "Pico"] + RAR, filas)

# 5. Depositos activos
T_REF = [t_extraer(5, r, pot_zona(5) * MULT[2], VEL[2], sat(mineria("Equilibrada (12,5%)", 450))) for r in range(7)]
def sim_zona(N, R, M, horas=2, semilla=7):
    rng = random.Random(semilla); p = [x / 100 for x in P_UR]
    nodos = [rng.choices(range(7), p)[0] for _ in range(N)]; reap = [0.0] * N; libre = [True] * N
    estado = [("busca", 0.0, None)] * M; ocio = [0.0] * M; hechos = [0] * M; ur = 0; disp = 0; pasos = 0; dt = 0.5; t = 0.0; fin = horas * 3600
    while t < fin:
        for i in range(N):
            if nodos[i] is None and t >= reap[i]: nodos[i] = rng.choices(range(7), p)[0]; libre[i] = True; ur += nodos[i] == 6
        for j in range(M):
            e, hasta, nodo = estado[j]
            if e == "busca":
                cand = [i for i in range(N) if nodos[i] is not None and libre[i]]
                if cand: i = rng.choice(cand); libre[i] = False; estado[j] = ("mina", t + VIAJE + T_REF[nodos[i]], i)
                else: ocio[j] += dt
            elif t >= hasta: nodos[nodo] = None; reap[nodo] = t + R; hechos[j] += 1; estado[j] = ("busca", 0.0, None)
        disp += sum(1 for i in range(N) if nodos[i] is not None and libre[i]); pasos += 1; t += dt
    return 100 * sum(ocio) / (M * fin), sum(hechos) / (M * horas), disp / pasos, ur / horas
filas = []; res = {}
for N, R, MS in [(30, 45, (4, 8, 12)), (40, 45, (1, 4, 8, 12, 20)), (40, 60, (8, 12)), (60, 45, (12,)), (80, 45, (16, 20))]:
    for M in MS:
        o, h, d, u = sim_zona(N, R, M); res[(N, R, M)] = o
        filas.append([N, R, M, n(o, 1) + "%", n(h), n(d, 1), n(u, 2)])
frag["depositos"] = tabla(["Depósitos activos", "Regeneración (s)", "Mineros en la zona", "Tiempo sin depósito libre", "Depósitos/hora por minero", "Depósitos libres de media", "Ultra raros nuevos por hora"], filas)
kv.update(o8=n(res[(40, 45, 8)], 1), o12=n(res[(40, 45, 12)], 1), o12e=n(res[(60, 45, 12)], 1), o20=n(res[(80, 45, 20)], 1))

# 6. Ritmo e ingresos
filas = []; ing = {"eq": [], "esp": [], "xp": []}
for z in range(1, 11):
    for b, k in (("Equilibrada (12,5%)", "eq"), ("Minería (50%)", "esp")):
        x = ritmo(z, b, k_xp=K_XP); ing[k].append(round(x["mon"]))
        if k == "eq": ing["xp"].append(round(x["xp"]))
        filas.append([z, b, x["L"], x["m"], n(x["tm"], 1), n(x["dh"]), n(x["mon"]), n(x["xp"]), n(240 * xp_acc(x["L"]))])
frag["ingresos"] = tabla(["Zona", "Build", "Nivel", "Minería", "s medios por depósito", "Depósitos/hora", "Monedas/hora", "XP/hora", "XP/hora objetivo (B2)"], filas)
dh = [ritmo(z, "Equilibrada (12,5%)")["dh"] for z in range(1, 11)]; rel = [e / q for e, q in zip(ing["esp"], ing["eq"])]
xr = [100 * (x / (240 * xp_acc(nivel_medio(z) if z > 1 else 50)) - 1) for z, x in zip(range(1, 11), ing["xp"])]
uds = sum(p / 100 * u for p, u in zip(P_UR, UNIDADES))
kv.update(dh_min=n(min(dh)), dh_max=n(max(dh)), rel_min=n(min(rel), 2), rel_max=n(max(rel), 2), xp_min=n(min(xr)), xp_max=n(max(xr)),
          mon1=n(ing["eq"][0]), mon10=n(ing["eq"][9]), uds=n(uds, 2), dep_mochila=n(CAP / uds), min_mochila=n(CAP / uds * (dh and 3600 / dh[4]) / 60, 1))
json.dump({"minero_eq": ing["eq"], "minero_esp": ing["esp"], "K_XP": K_XP, "dep_h": dh}, open("calculos/_b3.json", "w"))

# 7. Zonas Fracturadas (GDD)
MULT_F, SUELTA, RECOGE, RACHA_PASO, RACHA_TOPE, P_FRAG = 1.5, 0.50, 0.80, 0.10, 1.50, 0.0025
VAL_DEP = sum(p / 100 * f for p, f in zip(P_UR, F_VALOR))
def lento(c): return min(0.40, 0.12 * math.log(1 + c))
frag["carga"] = tabla(["Carga", "Ralentización", "Equivale a", "Efecto extra"],
    [[c, n(100 * lento(c), 1) + "%", f"{n(c*20/VAL_DEP)} depósitos medios o {n(c*20/60, 1)} Ultra raros", e] for c, e in
     [(1, "Ninguno"), (5, "Partículas de mineral visibles a 60 studs"), (10, "Resplandor en el minimapa de todos; dash y parpadeo cuestan 25% más"), (20, "Lo anterior"), (30, "Tope del 40%; anuncio en la zona")]])
c120 = 120 / uds * VAL_DEP / 20; c400 = 400 / uds * VAL_DEP / 20
kv.update(c120=n(c120, 1), l120=n(100 * lento(c120), 1), c400=n(c400, 1), l400=n(100 * lento(c400), 1), ws_lleno=n(20 * (1 - lento(c400)), 1), ws_base=n(20 * (1 - lento(c120)), 1))
frag["saqueo"] = tabla(["Destino", "Unidades", "Regla"],
    [["Las conserva la víctima", n(100 * (1 - SUELTA)), "Reaparece fuera de la Zona Fracturada; valen ×1,0"], ["Cofre de Saqueo", n(100 * SUELTA * RECOGE), "El 80% de lo que se suelta (GDD)"],
     ["Destruidas", n(100 * SUELTA * (1 - RECOGE)), "El 20% de lo que se suelta; sumidero contra la inflación (GDD)"]])
frag["racha"] = tabla(["Extracciones seguidas", "Multiplicador de racha", "Valor del mineral extraído"],
    [[k, "×" + n(min(1 + RACHA_PASO * k, RACHA_TOPE), 1), "×" + n(MULT_F * min(1 + RACHA_PASO * k, RACHA_TOPE), 2)] for k in range(0, 7)])
T_PVE = (CAP / uds) * 13 + 40; T_ZF = (2 * CAP / uds) * 13 + 53; RITMO = (T_PVE / (CAP / uds)) * (2 * CAP / uds) / T_ZF
def racha_media(p): return RACHA_TOPE if p == 0 else sum(p * (1 - p) ** k * min(1 + RACHA_PASO * k, RACHA_TOPE) for k in range(400))
def grieta(p, base=MULT_F):
    t = (1 - p) * T_ZF + p * (0.6 * T_ZF + 30)
    return ((1 - p) * base * racha_media(p) + p * 0.6 * (1 - SUELTA)) / t * T_PVE / (CAP / uds) * (2 * CAP / uds)
frag["fractura_ev"] = tabla(["Prob. de morir por viaje", "Racha media", "Ingresos frente al PvE", "Parte de la carga que acaba en cofres", "Parte destruida"],
    [[f"{int(100*p)}%", "×" + n(racha_media(p), 2), n(grieta(p), 2), n(100 * p * 0.6 * SUELTA * RECOGE, 1) + "%", n(100 * p * 0.6 * SUELTA * (1 - RECOGE), 1) + "%"] for p in (0, 0.05, 0.15, 0.30, 0.50, 0.70)])
lo, hi = 0.0, 1.0
for _ in range(60):
    mid = (lo + hi) / 2
    if grieta(mid) > 1: lo = mid
    else: hi = mid
frag["base_alt"] = tabla(["Multiplicador base", "Máximo teórico", "15% de muertes", "30%", "50%"],
    [["×" + n(b, 1), n(RITMO * b * RACHA_TOPE, 2), n(grieta(.15, b), 2), n(grieta(.30, b), 2), n(grieta(.50, b), 2)] for b in (2.0, 1.8, 1.6, 1.5)])
kv.update(mult_f=n(MULT_F, 1), max_teo=n(RITMO * MULT_F * RACHA_TOPE, 2), p_eq=n(100 * lo), g15=n(grieta(.15), 2), g30=n(grieta(.30), 2), g50=n(grieta(.50), 2),
          max20=n(RITMO * 2.0 * RACHA_TOPE, 2), p_frag=n(100 * P_FRAG, 2), cofre=n(100 * SUELTA * RECOGE), destr=n(100 * SUELTA * (1 - RECOGE)),
          valor_muerte=n(100 * (1 - SUELTA) / MULT_F, 1))
json.dump(dict(json.load(open("calculos/_b3.json")), MULT_F=MULT_F, RECOGE=RECOGE, T_PVE=T_PVE, T_ZF=T_ZF, uds=uds, VAL_DEP=VAL_DEP), open("calculos/_b3.json", "w"))
montar("plantillas/B3.md", "B_Matematico/B3_Mineria.md", frag, kv)
for k in sorted(kv): print(f"  {k} = {kv[k]}")
