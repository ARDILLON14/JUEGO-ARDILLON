"""OREBOUND - Etapa 10 (D_Roadmap): umbrales del plan de pruebas a partir de los archivos B.
Ejecutar desde OREBOUND/:  python3 calculos/b10_roadmap.py      Valores [PROVISIONAL]."""
import math
G = 2.0
def xp_sig(L): return math.ceil(100 + 20 * L + 0.8 * L * L)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
H = [0.0]
for L in range(1, 1000): H.append(H[-1] + xp_sig(L) / (240 * xp_acc(L)))
import json
MIN = json.load(open("calculos/_b3.json"))["minero_eq"][:3]; COM = json.load(open("calculos/_b4.json"))["combate_eq"][:3]
TOL = 0.25
def rango(x, d=1): return f"{x*(1-TOL):.{d}f} - {x*(1+TOL):.{d}f}"
print("== 1. Tiempo hasta cada nivel (objetivo y margen del 25 %) ==")
for L in (10, 25, 50, 100, 200, 300):
    print(f"Nivel {L:3d}: objetivo {H[L-1]:5.1f} h | aceptable {rango(H[L-1])} h | minutos por nivel {60*xp_sig(L)/(240*xp_acc(L)):.1f}")
print("\n== 2. Ingresos por hora en las zonas del MVP (equilibrado, sin mascotas) ==")
for z in (1, 2, 3):
    i = (MIN[z-1] + COM[z-1]) / 2
    print(f"Zona {z}: referencia {i:,.0f} | aceptable {i*(1-TOL):,.0f} - {i*(1+TOL):,.0f} | combate/mineria {COM[z-1]/MIN[z-1]:.2f}")
print("\n== 3. Ritmos de accion ==")
for nombre, v in [("Segundos por deposito Comun (pico Comun de la zona)", 6.0), ("Segundos por enemigo Comun (jugador tipico)", 6.3),
                  ("Minutos por jefe en solitario", 7.9), ("Minutos por carga de mochila (60 unidades)", 3.5), ("Segundos de duelo entre equilibrados", 17.9)]:
    print(f"{nombre:52s} objetivo {v:5.1f} | aceptable {rango(v)}")
print("\n== 4. Contenido del MVP ==")
print(f"Minerales: {6+6+7} | picos: {3*7} | armas: {3*3*7} | mascotas: 6 | jefes: 3 | horas hasta nivel 300: {H[299]:.1f}")
print(f"Objetos de equipo distintos que hay que modelar: picos 3 zonas x 1 modelo + armas 3 tipos x 3 zonas = {3 + 9} modelos base (la rareza cambia color y efecto)")
print("\n== 5. Expansion: horas de contenido por bloque de 100 niveles por encima de 1.000 ==")
for L in (1000, 1100, 1500, 1900):
    h = sum((820100 + 900 * (x - 1000)) / (240 * xp_acc(x)) for x in range(L, L + 100))
    print(f"Niveles {L}-{L+100}: {h:.1f} h")
print("\n== 6. Tamano de muestra para auditar las tasas de caja ==")
p = 0.04449
for err in (0.005, 0.002):
    n = 1.96 ** 2 * p * (1 - p) / err ** 2
    print(f"Para medir el 4,449 % de Legendario+ con un error de +-{100*err:.1f} puntos (95 %): {n:,.0f} aperturas")
