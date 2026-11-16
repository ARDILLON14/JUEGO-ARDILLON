"""OREBOUND - Etapa 8 (A_GDD): calculos de apoyo para los sistemas nuevos del GDD.
Ejecutar desde OREBOUND/:  python3 calculos/b8_gdd.py      Valores [PROVISIONAL]."""
import math
def xp_sig(L): return math.ceil(100 + 20 * L + 0.8 * L * L)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
H = [0.0]
for L in range(1, 1000): H.append(H[-1] + xp_sig(L) / (240 * xp_acc(L)))
def horas(a, b): return H[b - 1] - H[max(a, 1) - 1]

print("== 1. Mundos: horas de juego por mundo (curva ajustada de B2) ==")
MUNDOS = [("Superficie Quebrada", 1, 3), ("Hondonada de los Extremos", 4, 6), ("Abismo Negro", 7, 8), ("Corazón Celeste", 9, 10)]
for nombre, a, b in MUNDOS:
    print(f"{nombre:28s} zonas {a}-{b}  niveles {max(1,100*(a-1))}-{100*b}  {horas(100*(a-1), 100*b):6.1f} h")
print(f"MVP (zonas 1-3, hasta nivel 300): {horas(1, 300):.1f} h de contenido de subida de nivel")

print("\n== 2. Renacimiento ==")
BONO_XP, MAX_REN, PTS_REN = 0.05, 10, 10
total = 0.0
for r in range(0, MAX_REN + 1):
    h = H[-1] / (1 + BONO_XP * r); total += h
    print(f"Vuelta {r+1:2d} (renacimientos previos {r:2d}): XP +{int(100*BONO_XP*r):2d} %, puntos extra {PTS_REN*r:3d} ({100*PTS_REN*r/3000:.1f} % de 3.000), "
          f"{h:6.1f} h hasta nivel 1.000, acumulado {total:7.1f} h")
sat = lambda S: 1 + 3 * S / (S + 1000)
print(f"Efecto maximo de los puntos extra: 100 puntos en una estadistica ya a 1.000 no cuentan (tope); repartidos en una a 0: x{sat(100):.3f}")
import json
I10 = json.load(open("calculos/_b6.json"))["I"][9]
print(f"Monedas que se pierden al renacer con 10 h de ahorro en zona 10: {10*I10:,.0f} (sumidero)")

print("\n== 3. Eventos aleatorios: efecto medio en los ingresos ==")
for nombre, cada, dura, mult, part in [("Lluvia de meteoritos", 25, 4, 1.5, 0.8), ("Veta colosal", 40, 5, 1.6, 0.6), ("Oleada de la profundidad", 30, 5, 1.5, 0.7)]:
    print(f"{nombre:26s} cada {cada} min, dura {dura} min, x{mult} mientras dura, participa el {int(100*part)} %: +{100*dura/cada*(mult-1)*part:.1f} % de ingreso medio")
tot = sum(d / c * (m - 1) * p for c, d, m, p in [(25, 4, 1.5, 0.8), (40, 5, 1.6, 0.6), (30, 5, 1.5, 0.7)]) / 3 * 1.0
print(f"Solo hay un evento activo a la vez (rotacion): efecto medio conjunto aprox. +{100*tot:.1f} %")

print("\n== 4. Presupuesto de particulas en el peor caso (jefe con 8 jugadores), con los topes del GDD ==")
HAB, MASC, JEFE, AMB = 60, 10, 150, 40
for calidad, tope, ajeno in [("Bajo (GDD: 800)", 800, 0.5), ("Bajo con ajenos al 40 %", 800, 0.4), ("Medio (propuesta: 1.400)", 1400, 0.5), ("Alto (GDD: 2.000)", 2000, 0.5)]:
    uso = 2 * HAB + 7 * 2 * HAB * ajeno + 3 * MASC + 21 * MASC * ajeno + JEFE + AMB
    print(f"{calidad:28s} tope {tope:5d} | efectos ajenos al {int(100*ajeno)} % | uso en el peor caso {uso:6.0f} | {'cabe' if uso <= tope else 'NO CABE'} ({100*uso/tope:.0f} %)")

print("\n== 5. Temporada: fragmentos para el sexto espacio por la via gratuita ==")
SEM, NIV, XP_NIV = 8, 50, 1000
xp_sem = 7 * 3 * 120 + 5 * 400            # 3 diarias de 120 y 5 semanales de 400
print(f"XP de pase por semana jugando a diario: {xp_sem}; niveles en {SEM} semanas: {SEM*xp_sem/XP_NIV:.1f} de {NIV}")
n4 = SEM * (4 * 3 * 120 + 5 * 400) / XP_NIV
print(f"Con 4 dias por semana: {n4:.1f} niveles")
print(f"Fragmentos de temporada: 2 por nivel de la via gratuita en los niveles 1-30 (60 en total). "
      f"A diario se completan en {30*XP_NIV/xp_sem:.1f} semanas; con 4 dias por semana se obtienen {2*min(30, int(n4))} en la primera temporada")
