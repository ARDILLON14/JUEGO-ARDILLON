"""OREBOUND - Etapa 3 (B3): mineria.
Ejecutar desde OREBOUND/:  python3 calculos/b3_mineria.py [carpeta_fragmentos_md]
Genera calculos/b3_minerales.csv y calculos/b3_picos.csv. Valores [PROVISIONAL]."""
import csv, math, random, sys, os

RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = [1.00, 1.15, 1.32, 1.52, 1.75, 1.98, 2.20]; MULT_CEL = 2.60
VEL = [1.00, 1.02, 1.04, 1.06, 1.08, 1.10, 1.12]; VEL_CEL = 1.15
P_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; P_SIN = [55, 25, 12, 5.5, 2, 0.50, 0]
F_VIDA = [6, 9, 14, 22, 35, 55, 90]            # s con pico Comun de la zona, Mineria x1, dureza 1
F_VALOR = [1, 1.8, 3.2, 6, 12, 25, 60]
F_XP = [1, 1.4, 2, 3, 4.5, 7, 11]
K_XP = 0.73                                    # ajuste para cumplir la XP/hora de B2
UNIDADES = [4, 4, 3, 3, 2, 2, 1]
F_REQ_MIN = [1, 1, 1.5, 2.5, 3.5, 5, 7]        # x 10*(z-1)
F_REQ_PICO = [1, 1, 1.2, 1.5, 2, 2.5, 3]       # Mineria para equipar pico, x 10*(z-1)
G = 1.65
ZONAS = ["Cantera del Alba", "Galerías de Musgo", "Vetas Salinas", "Grutas de Brasa", "Sima Helada",
         "Bóveda de Ecos", "Raíces de Obsidiana", "Mar de Magma", "Catedral de Cristal", "Núcleo Astral"]
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
MATERIAL = ["Lingote", "Lingote", "Placa", "Gema tallada", "Núcleo", "Catalizador", "Esencia"]
USO = ["Fabricar picos y armas Común y Poco común", "Subir el nivel de objeto (1-5)", "Fabricar picos y armas Raro y Épico; nivel de objeto (6-10)",
       "Ranuras de mejora (+10 % cada una)", "Fabricar picos y armas Legendario", "Fabricar picos y armas Mítico; Despertar de habilidad",
       "Fabricar picos y armas Ultra raro"]
HAB = ["Ninguna", "Golpe certero: cada 10.º golpe hace daño doble", "Veta abierta: 10 % de sacar +1 unidad",
       "Onda sísmica: cada 12 s el golpe daña al 50 % a depósitos a 8 studs", "Prospector: marca depósitos Legendario o superior a 60 studs",
       "Fractura en cadena: al agotar un depósito, el siguiente empieza con 25 % menos de vida",
       "Resonancia: tras 5 s en el mismo depósito, +15 % de velocidad de golpe"]
HAB_CEL = "Eco estelar: 5 % de que el depósito agotado reaparezca al instante (1 vez cada 60 s)"

def pot_zona(z): return 100 * G ** (z - 1)
def nivel_zona(z): return max(1, 100 * (z - 1))
def dureza(z): return 1 + 0.1 * (z - 1)
def req_min_zona(z): return 10 * (z - 1)
def req_pico_zona(z): return 0.6 * pot_zona(z)
def valor_zona(z): return 10 * G ** (z - 1)
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def probs(z): return P_UR if z in CON_UR else P_SIN
def vida(z, r): return pot_zona(z) * F_VIDA[r] * dureza(z)
def valor(z, r): return valor_zona(z) * F_VALOR[r]
GOLPES_MIN = 3
def t_extraer(z, r, pot, vel, mult_min):
    golpes = max(GOLPES_MIN, math.ceil(vida(z, r) / (pot * mult_min)))
    return golpes / vel
def puntos(L): return 3 + 3 * (L - 1)
BUILDS = {"Minería (50 %)": 0.50, "Equilibrada (12,5 %)": 0.125, "Combate (5 %)": 0.05}
def mineria(build, L): return min(1000, int(puntos(L) * BUILDS[build]))

frag = {}
def md(nombre, cab, filas):
    out = ["| " + " | ".join(cab) + " |", "|" + "---|" * len(cab)]
    out += ["| " + " | ".join(str(c) for c in f) + " |" for f in filas]
    frag[nombre] = "\n".join(out); print(f"\n## {nombre}"); print(frag[nombre])
def n(x, d=0): return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")

# 1. Zonas
md("zonas", ["Zona", "Nombre", "Nivel", "Minería requerida", "Potencia de pico requerida", "PotZona", "Dureza", "Ultra raro"],
   [[z, ZONAS[z-1], nivel_zona(z), req_min_zona(z), n(req_pico_zona(z)), n(pot_zona(z)), n(dureza(z), 1),
     "Sí" if z in CON_UR else "No"] for z in range(1, 11)])
# 2. Builds
filas = []
for z in range(1, 11):
    L = nivel_zona(z); pico_prev = pot_zona(max(z-1, 1)) * (MULT[2] if z > 1 else 1.0)
    for b in BUILDS:
        m = mineria(b, L)
        tope = max(r for r in range(len(probs(z))) if probs(z)[r] > 0 and m >= req_min_zona(z) * F_REQ_MIN[r])
        entra = m >= req_min_zona(z) and pico_prev >= req_pico_zona(z)
        filas.append([z, b, m, "Sí" if entra else "No", RAR[tope], n(sat(m), 2),
                      n(t_extraer(z, 0, pico_prev, VEL[2] if z > 1 else 1.0, sat(m)), 1)])
md("builds", ["Zona", "Build", "Minería al entrar", "¿Entra?", "Rareza máxima que puede picar", "Mult. Minería", "s por depósito Común con el pico anterior"], filas)
# 3. Catalogo
cat = []
for z in range(1, 11):
    for r, nombre in enumerate(MIN[z]):
        cat.append(dict(mineral=nombre, zona=z, rareza=RAR[r], vida=round(vida(z, r)), valor_deposito=round(valor(z, r)),
                        unidades=UNIDADES[r], valor_unidad=round(valor(z, r) / UNIDADES[r], 1),
                        xp=round(K_XP * xp_acc(nivel_zona(z) + 50 if z > 1 else 50) * F_XP[r]),
                        pico_requerido=round(req_pico_zona(z)), mineria_requerida=round(req_min_zona(z) * F_REQ_MIN[r]),
                        material=f"{MATERIAL[r]} de {nombre}", uso=USO[r], probabilidad=probs(z)[r]))
    assert abs(sum(probs(z)) - 100) < 1e-9
with open("calculos/b3_minerales.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=list(cat[0])); w.writeheader(); w.writerows(cat)
md("catalogo", ["Zona", "Mineral", "Rareza", "Vida", "Valor del depósito", "Unidades", "XP", "Minería req.", "Material", "Prob."],
   [[c["zona"], c["mineral"], c["rareza"], n(c["vida"]), n(c["valor_deposito"]), c["unidades"], n(c["xp"]), c["mineria_requerida"],
     c["material"], n(c["probabilidad"], 2) + " %"] for c in cat])
print(f"Minerales: {len(cat)} | suma por zona comprobada = 100 %")
# 4. Picos
picos = []
PREF = ["Pizarra", "Verdín", "Sal", "Brasa", "Escarcha", "Eco", "Obsidiana", "Magma", "Vitral", "Astral"]
for z in range(1, 11):
    for r in range(7):
        picos.append(dict(pico=f"Pico de {PREF[z-1]} ({RAR[r]})", zona=z, rareza=RAR[r], potencia=round(pot_zona(z) * MULT[r]),
                          potencia_maxima=round(pot_zona(z) * MULT[r] * 2), velocidad=VEL[r], nivel=nivel_zona(z),
                          mineria=round(req_min_zona(z) * F_REQ_PICO[r]), habilidad=HAB[r]))
    if z >= 6:
        picos.append(dict(pico=f"Pico Celestial de {PREF[z-1]}", zona=z, rareza="Celestial", potencia=round(pot_zona(z) * MULT_CEL),
                          potencia_maxima=round(pot_zona(z) * MULT_CEL * 2), velocidad=VEL_CEL, nivel=nivel_zona(z),
                          mineria=round(req_min_zona(z) * 3), habilidad=HAB_CEL))
with open("calculos/b3_picos.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=list(picos[0])); w.writeheader(); w.writerows(picos)
md("picos_potencia", ["Zona", "Nivel"] + RAR + ["Celestial"],
   [[z, nivel_zona(z)] + [n(pot_zona(z) * m) for m in MULT] + [n(pot_zona(z) * MULT_CEL) if z >= 6 else "—"] for z in range(1, 11)])
md("picos_rareza", ["Rareza", "Mult. potencia", "Golpes/s", "Minería para equipar", "Habilidad especial"],
   [[RAR[r], n(MULT[r], 2), n(VEL[r], 2), f"{n(10*F_REQ_PICO[r])} × (zona − 1)", HAB[r]] for r in range(7)] +
   [["Celestial", n(MULT_CEL, 2), n(VEL_CEL, 2), "30 × (zona − 1)", HAB_CEL]])
print(f"Picos: {len(picos)}")
# 5. Tiempos de extraccion (build equilibrada al nivel de entrada)
filas = []
for z in range(1, 11):
    m = sat(mineria("Equilibrada (12,5 %)", nivel_zona(z)))
    c = [n(t_extraer(z, r, pot_zona(z), VEL[0], m), 1) if probs(z)[r] > 0 else "—" for r in range(7)]
    u = [n(t_extraer(z, r, pot_zona(z) * MULT[6], VEL[6], m), 1) if probs(z)[r] > 0 else "—" for r in range(7)]
    filas.append([z, n(m, 2), "Común"] + c); filas.append([z, n(m, 2), "Ultra raro"] + u)
md("tiempos", ["Zona", "Mult. Minería", "Pico"] + RAR, filas)

# 6. Depositos activos y regeneracion
def t_medio_ref(z=5):
    m = sat(mineria("Equilibrada (12,5 %)", nivel_zona(z) + 50))
    return [t_extraer(z, r, pot_zona(z) * MULT[2], VEL[2], m) for r in range(7)]
T_REF = t_medio_ref(); VIAJE = 6.0
def sim_zona(N, R, M, horas=2, semilla=7):
    rng = random.Random(semilla); p = [x / 100 for x in P_UR]
    nodos = [rng.choices(range(7), p)[0] for _ in range(N)]       # rareza o None si agotado
    reap = [0.0] * N; libre = [True] * N
    estado = [("busca", 0.0, None)] * M; ocio = [0.0] * M; hechos = [0] * M; ur = 0; disp_acum = 0; pasos = 0
    dt = 0.5; t = 0.0; fin = horas * 3600
    while t < fin:
        for i in range(N):
            if nodos[i] is None and t >= reap[i]:
                nodos[i] = rng.choices(range(7), p)[0]; libre[i] = True; ur += nodos[i] == 6
        for j in range(M):
            e, hasta, nodo = estado[j]
            if e == "busca":
                cand = [i for i in range(N) if nodos[i] is not None and libre[i]]
                if cand:
                    i = rng.choice(cand); libre[i] = False
                    estado[j] = ("mina", t + VIAJE + T_REF[nodos[i]], i)
                else: ocio[j] += dt
            elif t >= hasta:
                nodos[nodo] = None; reap[nodo] = t + R; hechos[j] += 1; estado[j] = ("busca", 0.0, None)
        disp_acum += sum(1 for i in range(N) if nodos[i] is not None and libre[i]); pasos += 1; t += dt
    return 100 * sum(ocio) / (M * fin), sum(hechos) / (M * horas), disp_acum / pasos, ur / horas
filas = []
for N, R, MS in [(20, 30, (1, 4, 8, 12, 20)), (30, 45, (1, 4, 8, 12, 20)), (40, 45, (1, 4, 8, 12, 20)),
                 (40, 60, (1, 4, 8, 12, 20)), (60, 45, (12,)), (80, 45, (16, 20))]:
    for M in MS:
        o, h, d, u = sim_zona(N, R, M)
        filas.append([N, R, M, n(o, 1) + " %", n(h), n(d, 1), n(u, 2)])
md("depositos", ["Depósitos activos", "Regeneración (s)", "Mineros en la zona", "Tiempo sin depósito libre", "Depósitos/hora por minero",
                 "Depósitos libres de media", "Ultra raros nuevos por hora"], filas)
print("Tiempos de referencia zona 5 (s):", [round(x, 1) for x in T_REF])

# 7. Ritmo e ingresos del minero PvE (equilibrada, pico Raro de la zona, nivel medio de zona)
CAP = 60; T_BANCO = 40
filas = []
for z in range(1, 11):
    L = nivel_zona(z) + 50 if z > 1 else 50
    for b in ("Equilibrada (12,5 %)", "Minería (50 %)"):
        m = mineria(b, L); p = [x / 100 for x in probs(z)]
        ok = [r for r in range(7) if p[r] > 0 and m >= req_min_zona(z) * F_REQ_MIN[r]]
        pt = sum(p[r] for r in ok)
        tm = sum(p[r] * t_extraer(z, r, pot_zona(z) * MULT[2], VEL[2], sat(m)) for r in ok) / pt
        uds = sum(p[r] * UNIDADES[r] for r in ok) / pt
        ciclo = tm + VIAJE + T_BANCO * uds / CAP
        dep_h = 3600 / ciclo
        mon = dep_h * sum(p[r] * valor(z, r) for r in ok) / pt
        xp = dep_h * sum(p[r] * K_XP * xp_acc(L) * F_XP[r] for r in ok) / pt
        filas.append([z, b, L, m, n(tm, 1), n(dep_h), n(mon), n(xp), n(240 * xp_acc(L))])
md("ingresos", ["Zona", "Build", "Nivel", "Minería", "s medios por depósito", "Depósitos/hora", "Monedas/hora", "XP/hora", "XP/hora objetivo (B2)"], filas)

# 8. Zonas Fracturadas
MULT_FRAC, SUELTA, RECOGIBLE, DESTRUYE = 2.0, 0.50, 0.70, 0.30
md("fractura_ev", ["Prob. de morir antes de extraer", "Valor esperado del viaje (PvE = 1,00)", "Parte que va al saqueador", "Parte destruida"],
   [[f"{int(100*p)} %", n((1 - p) * MULT_FRAC + p * (1 - SUELTA) * 1.0, 2), n(p * SUELTA * RECOGIBLE * MULT_FRAC, 2),
     n(p * SUELTA * DESTRUYE, 2)] for p in (0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6667, 0.8)])
print(f"Muerte PvP con carga 100: conserva {100*(1-SUELTA):.0f}, cofre {100*SUELTA*RECOGIBLE:.0f}, destruido {100*SUELTA*DESTRUYE:.0f}")
print(f"Prob. de muerte de equilibrio (viaje = PvE): {(MULT_FRAC-1)/(MULT_FRAC-(1-SUELTA)):.4f}")
md("fractura_carga", ["Carga / capacidad", "Velocidad de movimiento", "Coste del dash", "Visible en el minimapa"],
   [[f"{int(100*c)} %", n(100 * (1 - 0.30 * c ** 1.5), 1) + " %", n(20 * (1 + 0.5 * c), 1), "Sí" if c >= 0.75 else "No"]
    for c in (0, 0.25, 0.5, 0.75, 1.0)])
ws = 16 * 1.25
print(f"WalkSpeed con Velocidad 1000: {ws:.1f}; con carga completa {ws*0.7:.1f}; saqueador sin carga y Velocidad 0: 16.0")

if len(sys.argv) > 1:
    os.makedirs(sys.argv[1], exist_ok=True)
    for k, v in frag.items(): open(os.path.join(sys.argv[1], k + ".md"), "w", encoding="utf-8").write(v)

# 9. Alternativas a la perdida por muerte en Zona Fracturada (P3)
print("\n## alternativas_muerte (valor que conserva la victima, valor esperado con 30 % de muertes)")
for nombre, suelta, mult_cons in [("Actual: conserva 50 % a x1,0", 0.5, 1.0), ("Conserva 50 % a x1,5", 0.5, 1.5),
                                  ("Suelta 35 %, conserva a x1,0", 0.35, 1.0)]:
    print(f"{nombre:32s} {100*(1-suelta)*mult_cons/MULT_FRAC:5.1f} %   {0.7*MULT_FRAC + 0.3*(1-suelta)*mult_cons:.3f}")
uds = sum(p / 100 * u for p, u in zip(P_UR, UNIDADES))
print(f"Unidades medias por deposito: {uds:.2f}; depositos por mochila de {CAP}: {CAP/uds:.1f}")
