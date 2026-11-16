"""OREBOUND - Etapa 2 (B2): progresion, estadisticas, defensa y energia.
Ejecutar desde OREBOUND/:  python3 calculos/b2_progresion.py
Genera calculos/b2_xp_niveles.csv. Valores [PROVISIONAL] salvo la formula de XP."""
import math, csv

# ---------- 1. XP ----------
def xp_sig(L):                       # XP para pasar de L a L+1 (formula del prompt)
    return math.ceil(100 + 20 * L + 0.8 * L * L)
ACC_H, XP_ACC_BASE, XP_ACC_NIVEL = 240, 25, 3.75
def xp_hora(L):                      # 240 acciones/h x (25 + 3,75 L) XP por accion
    return ACC_H * (XP_ACC_BASE + XP_ACC_NIVEL * L)
XP1000 = xp_sig(1000)
PEND_COLA = 900
def xp_sig_cola(L):                  # alternativa lineal para L > 1000
    return xp_sig(L) if L <= 1000 else XP1000 + PEND_COLA * (L - 1000)

def tabla(hasta, f):
    acum, horas, filas = 0, 0.0, {}
    for L in range(1, hasta + 1):
        filas[L] = (f(L), acum, horas)
        acum += f(L); horas += f(L) / xp_hora(L)
    return filas
T = tabla(3000, xp_sig); TC = tabla(3000, xp_sig_cola)
with open("calculos/b2_xp_niveles.csv", "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["nivel", "xp_siguiente_nivel", "xp_acumulada", "horas_acumuladas", "xp_por_hora"])
    for L in range(1, 1001):
        w.writerow([L, T[L][0], T[L][1], round(T[L][2], 2), int(xp_hora(L))])
print("== 1. XP: hitos ==")
print("nivel | XP sig. nivel | XP acumulada | XP/hora | min por nivel | horas acum. | dias a 2 h/dia")
for L in [1, 10, 25, 50, 100, 200, 250, 300, 400, 500, 650, 800, 1000]:
    x, a, h = T[L]
    print(f"{L:5d} | {x:13,d} | {a:12,d} | {int(xp_hora(L)):9,d} | {60*x/xp_hora(L):6.1f} | {h:8.1f} | {h/2:7.1f}")
print("Horas por tramo de 100 niveles:")
for a in range(0, 1000, 100):
    ini = max(a, 1)
    print(f"  {ini:4d}-{a+100:4d}: {T[a+100][2]-T[ini][2]:6.1f} h")
print("Sensibilidad de horas a nivel 1000 segun XP/hora:")
for k in (0.7, 1.0, 1.3, 1.5):
    print(f"  XP/hora x{k}: {T[1000][2]/k:6.1f} h")

print("\n== 2. Mas alla de 1000 ==")
print("nivel | formula original: XP sig | acumulada | min/nivel | horas acum || cola lineal: XP sig | acumulada | min/nivel | horas acum")
for L in [1000, 1100, 1200, 1500, 2000, 3000]:
    x, a, h = T[L]; xc, ac, hc = TC[L]
    print(f"{L:5d} | {x:11,d} | {a:14,d} | {60*x/xp_hora(L):6.1f} | {h:8.1f} || {xc:10,d} | {ac:14,d} | {60*xc/xp_hora(L):6.1f} | {hc:8.1f}")
print(f"Horas 1000->2000: original {T[2000][2]-T[1000][2]:.0f} h, cola lineal {TC[2000][2]-TC[1000][2]:.0f} h")
print(f"Horas por 100 niveles en 1900-2000: original {T[2000][2]-T[1900][2]:.0f} h, cola {TC[2000][2]-TC[1900][2]:.0f} h")
print(f"XP acumulada a nivel 3000 (original) = {T[3000][1]:.3e}; limite entero exacto de un double = {2**53:.3e}")

# ---------- 2. Puntos ----------
PTS_NIVEL, PTS_INI, TOPE_PTS, TOPE_TOTAL = 3, 3, 1000, 5000
def puntos(L): return PTS_INI + PTS_NIVEL * (L - 1)
print("\n== 3. Puntos de estadistica ==")
for L in [1, 10, 25, 50, 100, 200, 250, 300, 400, 500, 650, 800, 1000]:
    p = puntos(L)
    print(f"nivel {L:4d}: {p:5d} puntos | estadisticas que se pueden llevar al tope de 1000: {p/TOPE_PTS:.2f} | reinicio: "
          f"{'gratis' if L < 50 else format(1000*L, ',d') + ' monedas'}")

# ---------- 3. Estadisticas ----------
def sat(S, M, K=1000): return 1 + M * S / (S + K)
def marg(S, M, K=1000): return sat(S, M, K) - sat(S - 1, M, K)     # efecto del punto S
STATS = [("Fuerza: dano", 3.0), ("Vitalidad: vida", 3.0), ("Mineria: dano de pico", 3.0), ("Suerte: factor F", 3.0),
         ("Dominio: dano y vida de mascota", 3.0), ("Dominio: recoleccion", 1.5),
         ("Velocidad: ataque", 0.8), ("Velocidad: movimiento", 0.5),
         ("Energia: regeneracion", 1.0)]
print("\n== 4. Estadisticas (curva de saturacion 1 + M*S/(S+1000)) ==")
print("efecto | M | punto 1 | punto 100 | punto 1000 | total 100 | total 1000 | total 5000 | asintota")
for n, M in STATS:
    print(f"{n:32s} | {M:3.1f} | +{100*marg(1,M):.3f}% | +{100*marg(100,M):.3f}% | +{100*marg(1000,M):.3f}% | "
          f"x{sat(100,M):.3f} | x{sat(1000,M):.3f} | x{sat(5000,M):.3f} | x{1+M:.1f}")
def emax(E): return 100 + 300 * E / (E + 1000)
print("Energia maxima: " + " | ".join(f"E={e}: {emax(e):.1f}" for e in (0, 1, 100, 1000, 5000)) + " | asintota 400")
print("Comparacion con raiz cuadrada calibrada al mismo valor en 1000 puntos (1 + 0,04743*raiz(S)):")
c = 1.5 / math.sqrt(1000)
rq = lambda S: 1 + c * math.sqrt(S)
for S in (1, 100, 1000, 5000):
    print(f"  S={S:5d}: raiz x{rq(S):.3f} (punto +{100*(rq(S)-rq(S-1)):.3f}%) | saturacion x{sat(S,3):.3f} (punto +{100*marg(S,3):.3f}%)")
print(f"  Punto 1 / punto 1000: raiz {(rq(1)-rq(0))/(rq(1000)-rq(999)):.0f} veces | saturacion {marg(1,3)/marg(1000,3):.1f} veces")
print("Vitalidad lineal ilustrativa (1 + 0,01*V) frente a saturacion:")
for V in (100, 1000, 5000): print(f"  V={V}: lineal x{1+0.01*V:.1f} | saturacion x{sat(V,3):.3f}")
def hp_base(L): return 500 * 1.65 ** ((L - 1) / 100)
print("Vida base por nivel: " + " | ".join(f"L{L}: {hp_base(L):,.0f}" for L in (1, 100, 300, 500, 800, 1000)))
print("Velocidad de movimiento (WalkSpeed base 16): " + " | ".join(f"S={s}: {16*sat(s,0.5):.2f}" for s in (0, 100, 1000, 5000)))

# ---------- 4. Defensa ----------
K_PVE, TOPE_PVE, K_PVP, TOPE_PVP = 1500, 0.75, 3000, 0.60
def red(D, K, tope): return min(D / (D + K), tope)
print("\n== 5. Defensa ==")
print("Defensa | PvE reduccion | PvE dano recibido | PvE vida efectiva | PvP reduccion | PvP dano recibido | PvP vida efectiva")
for D in [0, 10, 100, 500, 1000, 2500, 5000]:
    a, b = red(D, K_PVE, TOPE_PVE), red(D, K_PVP, TOPE_PVP)
    print(f"{D:7d} | {100*a:6.2f}% | {100*(1-a):6.2f}% | x{1/(1-a):.2f} | {100*b:6.2f}% | {100*(1-b):6.2f}% | x{1/(1-b):.2f}")
print(f"Defensa a la que se alcanza el tope: PvE {K_PVE*TOPE_PVE/(1-TOPE_PVE):.0f} | PvP {K_PVP*TOPE_PVP/(1-TOPE_PVP):.0f}")

print("\n== 6. Builds de comprobacion (nivel 1000, 3000 puntos, sin equipo) ==")
ORD = ["Fue", "Vit", "Def", "Vel", "Ene", "Min", "Sue", "Dom"]
BUILDS = {"Cristal (Fue/Vel/Ene)": dict(Fue=1000, Vel=1000, Ene=1000),
          "Tanque (Vit/Def/Fue)": dict(Vit=1000, Def=1000, Fue=1000),
          "Muro (Vit/Def/Ene)": dict(Vit=1000, Def=1000, Ene=1000),
          "Minero (Min/Sue/Vit)": dict(Min=1000, Sue=1000, Vit=1000),
          "Equilibrada (375 x 8)": {k: 375 for k in ORD}}
res = {}
print("build | DPS | vida ef. PvE | vida ef. PvP | DPS x vida PvP | mineria | suerte F")
for n, b in BUILDS.items():
    g = lambda k: b.get(k, 0)
    dps = sat(g("Fue"), 3) * sat(g("Vel"), 0.8)
    v = sat(g("Vit"), 3)
    e_pve, e_pvp = v / (1 - red(g("Def"), K_PVE, TOPE_PVE)), v / (1 - red(g("Def"), K_PVP, TOPE_PVP))
    res[n] = (dps, e_pvp)
    print(f"{n:24s} | x{dps:.2f} | x{e_pve:.2f} | x{e_pvp:.2f} | {dps*e_pvp:5.2f} | x{sat(g('Min'),3):.2f} | x{sat(g('Sue'),3):.2f}")
a, t = res["Cristal (Fue/Vel/Ene)"], res["Tanque (Vit/Def/Fue)"]
print(f"Duelo Cristal vs Tanque (tiempo relativo para matar): Cristal mata en {t[1]/a[0]:.2f}, Tanque mata en {a[1]/t[0]:.2f}")

# ---------- 5. Energia ----------
REG_COMB, REG_FUERA, PAUSA = 8.0, 20.0, 1.5
ACC = {"V": (30, 50), "C": (14, 35), "X": (8, 25), "Z": (4, 15), "Parpadeo": (8, 30), "Dash": (2.5, 20)}
def simular(E, usar, dur=120.0, dt=0.1):
    cap = emax(E); en = cap; reg = REG_COMB * sat(E, 1.0)
    listo = {k: 0.0 for k in usar}; usos = {k: 0 for k in usar}; t = 0.0; ult = -99; vacio = None
    while t < dur:
        for k in usar:
            cd, coste = ACC[k]
            if t >= listo[k] and en >= coste:
                en -= coste; listo[k] = t + cd; usos[k] += 1; ult = t
        if vacio is None and en < min(ACC[k][1] for k in usar): vacio = t
        if t - ult >= PAUSA: en = min(cap, en + reg * dt)
        t += dt
    posibles = sum(int(dur / ACC[k][0]) + 1 for k in usar)
    return cap, reg, sum(usos.values()), posibles, vacio
print("\n== 7. Energia: 120 s de combate usando todo en cuanto se puede ==")
for nombre, usar in [("Solo Dash", ["Dash"]), ("Habilidades ZXCV", ["V", "C", "X", "Z"]),
                     ("Todo (ZXCV + Dash + Parpadeo)", list(ACC))]:
    for E in (0, 1000, 5000):
        cap, reg, u, p, vac = simular(E, usar)
        print(f"{nombre:30s} Energia {E:4d}: max {cap:5.1f}, regen {reg:5.2f}/s | usos {u:3d} de {p:3d} posibles "
              f"({100*u/p:5.1f}%) | se queda sin energia a los {vac if vac is None else round(vac,1)} s")
print("Demanda si todo se usara sin limite: " + f"{sum(c/cd for cd, c in ACC.values()):.2f} energia/s")
for E in (0, 1000, 5000):
    print(f"  Energia {E}: recarga completa fuera de combate en {emax(E)/(REG_FUERA*sat(E,1.0)):.1f} s; "
          f"regeneracion entre dos Dash ({ACC['Dash'][0]-PAUSA:.1f} s utiles): {REG_COMB*sat(E,1.0)*(ACC['Dash'][0]-PAUSA):.1f} frente a coste {ACC['Dash'][1]}")
print(f"  Bloqueo sostenido (8/s, sin regenerar): Energia 0 aguanta {emax(0)/8:.1f} s; Energia 1000 {emax(1000)/8:.1f} s; Energia 5000 {emax(5000)/8:.1f} s")

# ---------- 6. Alternativas de balance ----------
print("\n== 8. Alternativa XP: accion con termino cuadratico (25 + 3,75 L + 0,002 L^2) ==")
def xp_hora_b(L): return ACC_H * (XP_ACC_BASE + XP_ACC_NIVEL * L + 0.002 * L * L)
h = 0.0; marcas = {}
for L in range(1, 1001):
    marcas[L] = h; h += xp_sig(L) / xp_hora_b(L)
for L in (100, 300, 500, 800, 1000):
    print(f"  nivel {L:4d}: {marcas[L]:6.1f} h (base {T[L][2]:6.1f} h) | min por nivel {60*xp_sig(L)/xp_hora_b(L):.1f}")
print(f"  Ultimo tramo 900-1000: {marcas[1000]-marcas[900]:.1f} h (base {T[1000][2]-T[900][2]:.1f} h)")

print("\n== 9. Alternativa PvP: Vitalidad al 50 % en PvP (M = 1,5) ==")
for nombre, mv in [("Actual (M=3)", 3.0), ("Vitalidad PvP M=1,5", 1.5)]:
    ehp_t = sat(1000, mv) / (1 - red(1000, K_PVP, TOPE_PVP))
    dps_c, dps_t = sat(1000, 3) * sat(1000, 0.8), sat(1000, 3)
    print(f"  {nombre:20s}: vida ef. Tanque x{ehp_t:.2f} | Cristal mata en {ehp_t/dps_c:.2f} | Tanque mata en {1/dps_t:.2f} | "
          f"ventaja del Tanque {(ehp_t/dps_c)/(1/dps_t):.2f} veces")
