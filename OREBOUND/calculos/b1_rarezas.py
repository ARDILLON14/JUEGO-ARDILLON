"""OREBOUND - Etapa 1 (B1): rarezas, potencia, suerte y proteccion contra mala suerte.
Ejecutar:  python3 calculos/b1_rarezas.py
Todos los valores son [PROVISIONAL] salvo que DECISIONES.md diga lo contrario."""
import random
from fractions import Fraction as Fr

RAREZAS = ["Comun", "Poco comun", "Raro", "Epico", "Legendario", "Mitico", "Ultra raro"]
MULT = {"Comun": 1.00, "Poco comun": 1.15, "Raro": 1.32, "Epico": 1.52,
        "Legendario": 1.75, "Mitico": 1.98, "Ultra raro": 2.20, "Celestial": 2.60}
CAJA = [50, 26, 14, 7, 2.4, 0.5, 0.1]            # % caja estandar
DEP_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]        # % depositos, zona con Ultra raro
DEP_SIN = [55, 25, 12, 5.5, 2, 0.50, 0.0]        # % depositos, zona sin Ultra raro
EVENTO = {"Raro": 45, "Epico": 33, "Legendario": 15, "Mitico": 5, "Ultra raro": 1.5, "Celestial": 0.5}
EXP_SUERTE = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.0]
F_MAX, K_SUERTE = 3.0, 1000.0
G_ZONA, POT_BASE = 1.65, 100.0
TOPE_BONO = 1.00                                  # +100 % maximo (nivel+mejoras+habilidades)

def exacto(v):  # suma exacta con fracciones
    return sum(Fr(str(x)) for x in v)

def redondeo_100(pcts, dec=3):
    """Redondea a `dec` decimales y garantiza suma exacta 100 (mayor resto)."""
    u = 10 ** dec
    bruto = [p * u for p in pcts]
    ent = [int(b) for b in bruto]
    falta = 100 * u - sum(ent)
    orden = sorted(range(len(pcts)), key=lambda i: bruto[i] - ent[i], reverse=True)
    for i in orden[:falta]:
        ent[i] += 1
    return [e / u for e in ent]

print("== 1. SUMAS EXACTAS ==")
for n, t in [("Caja estandar", CAJA), ("Depositos con UR", DEP_UR),
             ("Depositos sin UR", DEP_SIN), ("Caja de evento", EVENTO.values())]:
    s = exacto(t); assert s == 100, n
    print(f"{n:18s} suma = {s} %")
print("Legendario o superior en caja estandar:", float(exacto(CAJA[4:])), "%")

print("\n== 2. POTENCIA DE OBJETO ==")
def pot_zona(z): return POT_BASE * G_ZONA ** (z - 1)
def potencia(z, rareza, bono=0.0): return pot_zona(z) * MULT[rareza] * (1 + min(bono, TOPE_BONO))
print("zona | PotZona | Comun sin mejoras | Ultra raro max | Celestial max")
for z in range(1, 11):
    print(f"{z:4d} | {pot_zona(z):8.0f} | {potencia(z,'Comun'):10.0f} | "
          f"{potencia(z,'Ultra raro',1):10.0f} | {potencia(z,'Celestial',1):10.0f}")
print("Comparaciones (Comun sin mejoras de zona alta vs objeto de zona baja):")
for alta, baja, r, b in [(3, 1, "Ultra raro", 0), (4, 1, "Ultra raro", 1), (5, 1, "Celestial", 1),
                         (10, 6, "Ultra raro", 1), (10, 6, "Celestial", 1), (9, 6, "Celestial", 0)]:
    a, c = potencia(alta, "Comun"), potencia(baja, r, b)
    print(f"  Comun z{alta} = {a:.0f}  vs  {r} z{baja} (bono {b:.0%}) = {c:.0f}  -> ratio {a/c:.2f}")
import math
for r, b in [("Ultra raro", 0), ("Ultra raro", 1), ("Celestial", 0), ("Celestial", 1)]:
    k = math.ceil(math.log(MULT[r] * (1 + b)) / math.log(G_ZONA) + 1e-9)
    print(f"  Zonas de diferencia para que un Comun sin mejoras supere a {r} (bono {b:.0%}): {k}")
print(f"  Rango maximo dentro de una zona: {MULT['Celestial']*2:.2f}x (Celestial max / Comun base)")

print("\n== 3. SUERTE ==")
def factor(s): return 1 + F_MAX * s / (s + K_SUERTE)
def con_suerte(tabla, s):
    w = [p * factor(s) ** e for p, e in zip(tabla, EXP_SUERTE)]
    t = sum(w)
    return [100 * x / t for x in w]
for nombre, tabla in [("CAJA ESTANDAR (gratuita)", CAJA), ("DEPOSITOS (zona con UR)", DEP_UR)]:
    print(nombre)
    print("Suerte | F     | " + " | ".join(f"{r:>10s}" for r in RAREZAS) + " | Leg+   | suma")
    for s in [0, 10, 100, 500, 1000, 2500, 10**9]:
        p = redondeo_100(con_suerte(tabla, s))
        et = "inf" if s == 10**9 else str(s)
        print(f"{et:>6s} | {factor(s):.3f} | " + " | ".join(f"{x:10.3f}" for x in p) +
              f" | {sum(p[4:]):6.3f} | {sum(Fr(str(x)) for x in p)}")

print("\n== 4. PROTECCION CONTRA MALA SUERTE ==")
P0 = float(exacto(CAJA[4:])) / 100            # Legendario+
PM = float(exacto(CAJA[5:])) / 100            # Mitico+
def p_leg(n):                                   # n = numero de apertura desde el ultimo Legendario+
    if n <= 40: return P0
    if n >= 50: return 1.0
    return P0 + (1 - P0) * ((n - 40) / 10) ** 2
print("apertura n | P(Legendario+) | P(llegar a n sin premio)")
sup, e_ciclo = 1.0, 0.0
for n in range(1, 51):
    if n in (1, 40) or n >= 41: print(f"{n:10d} | {100*p_leg(n):13.2f}% | {100*sup:6.2f}%")
    e_ciclo += sup; sup *= 1 - p_leg(n)
print(f"Analitico (solo contador A): ciclo medio {e_ciclo:.2f} aperturas -> tasa {100/e_ciclo:.3f}%")
sup = 1.0; e0 = 0.0
for n in range(1, 2000): e0 += sup; sup *= 1 - P0
print(f"Sin proteccion: tasa {100*P0:.3f}%  |  P(50 aperturas sin Legendario+) = {100*(1-P0)**50:.2f}%")

def simular(n_ap, semilla=20261116, suerte=0):
    rng = random.Random(semilla)
    tabla = [x / 100 for x in con_suerte(CAJA, suerte)]
    p0 = sum(tabla[4:])
    cnt = [0] * 7; a = b = 0; gar50 = gar100 = 0; peor = 0
    for _ in range(n_ap):
        a += 1; b += 1
        if b >= 100:                              # garantia B: Mitico+
            idx = rng.choices([5, 6], weights=tabla[5:])[0]; gar100 += 1
        else:
            if a <= 40: p = p0
            elif a >= 50: p = 1.0
            else: p = p0 + (1 - p0) * ((a - 40) / 10) ** 2
            if rng.random() < p:
                idx = rng.choices([4, 5, 6], weights=tabla[4:])[0]
                if a >= 50: gar50 += 1
            else:
                idx = rng.choices([0, 1, 2, 3], weights=tabla[:4])[0]
        cnt[idx] += 1
        if idx >= 4: peor = max(peor, a); a = 0
        if idx >= 5: b = 0
    return cnt, gar50, gar100, peor
for s in (0, 1000):
    N = 100_000
    cnt, g50, g100, peor = simular(N, suerte=s)
    print(f"Simulacion {N} aperturas, Suerte {s}:")
    for r, c in zip(RAREZAS, cnt): print(f"   {r:11s} {c:6d}  {100*c/N:7.3f}%")
    print(f"   Legendario o superior: {100*sum(cnt[4:])/N:.3f}%   Mitico o superior: {100*sum(cnt[5:])/N:.3f}%"
          f"   Ultra raro: {100*cnt[6]/N:.3f}%")
    print(f"   Garantias en 50: {g50}   Garantias en 100: {g100}   Racha mas larga sin Legendario+: {peor}")

print("\n== 5. CELESTIAL ==")
FRAG_OBJ, FRAG_JEFE, P_DIRECTO = 60, 2, 0.005
P_FRAC = {6: 0.10, 7: 0.125, 8: 0.15, 9: 0.175, 10: 0.20}; TOPE_JEFE, TOPE_FRAC = 5, 10
for nombre, jefes, extr, z in [("Casual", 2, 0, 6), ("Regular", 4, 10, 7), ("Dedicado", 5, 20, 8),
                               ("Maximo", 5, 60, 10)]:
    fj = min(jefes, TOPE_JEFE) * FRAG_JEFE
    ff = min(extr * P_FRAC[z], TOPE_FRAC)
    tot = fj + ff
    pd = 1 - (1 - P_DIRECTO) ** jefes
    print(f"{nombre:9s} jefes/sem {jefes}, extracciones/sem {extr} (z{z}): {tot:5.2f} fragmentos/sem -> "
          f"{FRAG_OBJ/tot:5.1f} semanas por Celestial | drop directo {100*pd:.2f}%/sem")

print("\n== 6. ALTERNATIVA: garantia B (Mitico+) en otra apertura ==")
def tasa_garantia(p, n): return 100 * p / (1 - (1 - p) ** n)
for n in (100, 150, 200, 300):
    print(f"Garantia Mitico+ en {n}: tasa analitica aprox. {tasa_garantia(PM, n):.3f}% (base {100*PM:.3f}%)")
