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
def hp_base(L): return 500 * 2.0 ** ((L - 1) / 100)        # crecimiento 2,00 por zona (B1 rehecho)
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
# GDD: Nucleo Prismatico (Z 6 s/20, X 12 s/25, C 9 s/25, V 60 s/40); dash 2 cargas con 3 s de recarga; parpadeo 8 s/30
ACC = {"V": (60, 40), "X": (12, 25), "C": (9, 25), "Z": (6, 20), "Parpadeo": (8, 30), "Dash": (3.0, 20)}
COEF = {"V": 6.0, "X": 1.5, "C": 1.2, "Z": 2.2}
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
    simular.usos = dict(usos)
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


# ---------- 7. Factor de habilidades de referencia y seccion 8 de B2 (rehecha con el GDD) ----------
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from montar import tabla, n
def dano_hab(E, dur=120.0):
    simular(E, ["V", "X", "C", "Z"], dur); u = simular.usos
    return sum(u[k] * COEF[k] for k in u) / dur, sum(u.values())
teor = sum(COEF[k] / ACC[k][0] for k in COEF)
F_HAB = {E: 0.92 + dano_hab(E)[0] for E in (0, 375, 1000, 5000)}
print("\n== 10. Factor de habilidades (basicos 92 % + habilidades del Nucleo Prismatico) ==")
print(f"Dano teorico de las 4 habilidades sin limite de energia: {100*teor:.1f} % de la potencia del arma por segundo")
for E, f in F_HAB.items(): print(f"  Energia {E:4d}: habilidades {100*(f-0.92):5.1f} %/s -> factor {f:.3f}")
filas = []
for nombre, usar in [("Solo Dash", ["Dash"]), ("Habilidades Z, X, C, V", ["V", "X", "C", "Z"]), ("Todo a la vez", list(ACC))]:
    for E in (0, 1000, 5000):
        cap, reg, u, p, vac = simular(E, usar)
        filas.append([nombre, n(E), u, p, n(100 * u / p, 1) + "%", "No en 120 s" if vac is None else ("Primera ráfaga" if vac < 1 else n(vac, 1) + " s")])
t_sim = tabla(["Qué se usa", "Energía", "Usos conseguidos", "Usos posibles por enfriamiento", "Porcentaje", "Se vacía a los"], filas)
demanda = sum(c / cd for cd, c in ACC.values())
seccion = f"""## 8. Energía

> Sección rehecha con el GDD: dash de 2 cargas con 3 s de recarga, parpadeo de 12 studs, Ruptura de 50 de energía y las habilidades del Núcleo Prismático como referencia. La esquiva deja de ser una acción aparte: es un dash hecho en los 0,25 s anteriores a un golpe («esquiva perfecta»).

### 8.1 Capacidad y regeneración

| Concepto | Fórmula o valor | Con Energía 0 | Con 1.000 | Con 5.000 |
|---|---|---|---|---|
| Energía máxima | `100 + 300·E/(E + 1.000)` | {n(emax(0))} | {n(emax(1000))} | {n(emax(5000))} |
| Regeneración en combate | `8/s × (1 + E/(E + 1.000))` | {n(REG_COMB*sat(0,1),1)}/s | {n(REG_COMB*sat(1000,1),1)}/s | {n(REG_COMB*sat(5000,1),1)}/s |
| Regeneración fuera de combate | `20/s × (1 + E/(E + 1.000))` | {n(REG_FUERA*sat(0,1),1)}/s | {n(REG_FUERA*sat(1000,1),1)}/s | {n(REG_FUERA*sat(5000,1),1)}/s |
| Recarga completa fuera de combate | — | {n(emax(0)/(REG_FUERA*sat(0,1)),1)} s | {n(emax(1000)/(REG_FUERA*sat(1000,1)),1)} s | {n(emax(5000)/(REG_FUERA*sat(5000,1)),1)} s |

- «En combate» = menos de 5 s desde el último golpe dado o recibido.
- **Pausa de regeneración:** tras gastar energía, no se regenera durante 1,5 s.

### 8.2 Consumos

| Acción | Coste | Enfriamiento | Notas | Origen |
|---|---|---|---|---|
| Dash | 20 | 2 cargas; 3 s de recarga por carga | Aéreo o terrestre; hecho justo antes de un golpe es una esquiva perfecta | GDD |
| Doble salto | 0 | 1 por salto | — | GDD |
| Parpadeo | 30 | 8 s | 12 studs; no atraviesa paredes; se desbloquea con Agilidad (propuesta: Velocidad 50) | GDD |
| Ruptura | 50 | 15 s | Tras 0,8 s bajo control, libera y empuja al atacante | GDD |
| Bloqueo sostenido | 8 por segundo | — | No se regenera mientras se bloquea | Propuesta |
| Golpe bloqueado | 10 por golpe | — | Con energía 0 se rompe la guardia (B4) | Propuesta |
| Habilidad Z (área) | 20 | 6 s | Valores del Núcleo Prismático | GDD |
| Habilidad X (control) | 25 | 12 s | | GDD |
| Habilidad C (movilidad) | 25 | 9 s | | GDD |
| Habilidad V (definitiva) | 40 | 60 s | | GDD |

- Con Carga 10 o más en una Zona Fracturada, dash y parpadeo cuestan un 25% más (B3).

### 8.3 Simulación: 120 s de combate usando todo en cuanto se puede

{t_sim}

- Usarlo todo pide {n(demanda, 2)} de energía por segundo; la regeneración máxima posible es 16/s.
- Las habilidades del GDD tienen enfriamientos largos, así que la energía limita menos que la combinación con dash y parpadeo: lo que el jugador decide es cuánta energía reservar para moverse y para la Ruptura.

### 8.4 Factor de habilidades de referencia

Con los ataques básicos al 92% (el resto del tiempo se gasta en lanzar habilidades) y las cuatro habilidades del Núcleo Prismático:

| Energía | Daño de habilidades (% de la potencia del arma por segundo) | Factor total sobre el ataque básico |
|---|---|---|
| 0 | {n(100*(F_HAB[0]-0.92),1)}% | ×{n(F_HAB[0],3)} |
| 375 | {n(100*(F_HAB[375]-0.92),1)}% | ×{n(F_HAB[375],3)} |
| 1.000 | {n(100*(F_HAB[1000]-0.92),1)}% | ×{n(F_HAB[1000],3)} |
| 5.000 | {n(100*(F_HAB[5000]-0.92),1)}% | ×{n(F_HAB[5000],3)} |

- **Factor de referencia: ×{n(F_HAB[0],2)}.** Es el que usan B4, B5 y B7 para el «jugador típico» y para el tope de DPS de mascotas. En la primera versión era ×1,75, con habilidades propuestas más frecuentes.
- La estadística Energía sube el factor de ×{n(F_HAB[0],2)} a ×{n(F_HAB[1000],2)} con 1.000 puntos, y además deja margen para dash, parpadeo, bloqueo y Ruptura.

### 8.5 Límites contra la energía infinita

1. **Pausa de 1,5 s** tras cada gasto. Entre dos dash seguidos solo se regenera 1,5 s: {n(REG_COMB*sat(0,1)*1.5,1)} con Energía 0, {n(REG_COMB*sat(1000,1)*1.5,1)} con 1.000 y {n(REG_COMB*sat(5000,1)*1.5,1)} con 5.000, frente a los 20 que cuesta. Con Energía muy alta el dash deja de estar limitado por la energía y lo limitan sus 2 cargas.
2. **Topes de la estadística:** energía máxima 400 y regeneración ×2.
3. **Reducción de costes:** el equipo y las pasivas pueden abaratar las acciones un 30% como máximo en total.
4. **Los enfriamientos no dependen de la energía.**
5. **Bloqueo:** con 8/s y sin regenerar, aguanta {n(emax(0)/8,1)} s (Energía 0), {n(emax(1000)/8,1)} s (1.000) o {n(emax(5000)/8,1)} s (5.000) sin recibir golpes.
6. **Consumibles de energía:** un uso cada 30 s en PvP y Zonas Fracturadas.

---

"""
p = "B_Matematico/B2_Progresion.md"; d = open(p, encoding="utf-8").read()
i, j = d.index("## 8. Energía"), d.index("## 9. Problemas de balance")
d = d[:i] + seccion + d[j:]
import re
d = re.sub(r"- \*\*F11:\*\* .*\n- Valores: .*\n", f"- **F11:** `VidaBase(L) = 500 × 2,00^((L − 1)/100)`. Crece al mismo ritmo que la potencia de zona de B1 (×2,00 cada 100 niveles; era 1,65 antes de rehacer B1 con el GDD).\n- Valores: nivel 1 → {n(hp_base(1))}; 100 → {n(hp_base(100))}; 300 → {n(hp_base(300))}; 500 → {n(hp_base(500))}; 800 → {n(hp_base(800))}; 1.000 → {n(hp_base(1000))}.\n", d)
d = re.sub(r"Etapa 2 · 2026-11-16[^·]*·", "Etapa 2 · 2026-11-16 (corregido en las Etapas 6 y 7; energía y vida base rehechas con el GDD) ·", d, count=1)
open(p, "w", encoding="utf-8").write(d)
import json
json.dump({"F_HAB": F_HAB[0], "F_HAB_E": {str(k): v for k, v in F_HAB.items()}}, open("calculos/_b2.json", "w"))
print("B2 actualizado; factor de referencia", round(F_HAB[0], 3))
