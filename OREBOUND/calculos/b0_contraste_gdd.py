"""OREBOUND - Contraste del diseno (etapas 1-10) con el GDD de combate, mineria PvPvE y mascotas.
Ejecutar desde OREBOUND/:  python3 calculos/b0_contraste_gdd.py
Mide el impacto de adoptar los valores del GDD donde difieren de los propuestos."""
import math
G = 1.65
RAR = ["Comun", "Poco comun", "Raro", "Epico", "Legendario", "Mitico", "Ultra raro", "Celestial"]
M_MIO = [1.00, 1.15, 1.32, 1.52, 1.75, 1.98, 2.20, 2.60]
M_GDD = [1.00, 1.25, 1.50, 1.90, 2.50, 3.30, 4.50, 5.20]      # Poco comun 1,25 es supuesto: el GDD da rangos por pares

print("== 1. Multiplicadores de rareza del GDD y regla 'la zona pesa mas' ==")
def zonas(mult, g): return math.ceil(math.log(mult) / math.log(g) + 1e-9)
for nombre, M in (("Propuestos (B1)", M_MIO), ("GDD", M_GDD)):
    print(f"{nombre:16s} UR sin bonos: {zonas(M[6], G)} zonas | UR +100 %: {zonas(M[6]*2, G)} | Celestial sin bonos: {zonas(M[7], G)} | Celestial +100 %: {zonas(M[7]*2, G)}"
          f" | rango dentro de una zona: x{M[7]*2:.1f}")
print("Con los multiplicadores del GDD, alternativas para recuperar la regla:")
for nombre, g, tope in [("Mantener g = 1,65 y bonos hasta +100 %", 1.65, 1.0), ("g = 1,65 y bonos hasta +50 %", 1.65, 0.5), ("g = 2,00 y bonos hasta +100 %", 2.0, 1.0),
                        ("g = 2,00 y bonos hasta +50 %", 2.0, 0.5), ("g = 2,30 y bonos hasta +50 %", 2.3, 0.5)]:
    print(f"  {nombre:40s} Comun supera a UR maximo a {zonas(M_GDD[6]*(1+tope), g)} zonas y a Celestial maximo a {zonas(M_GDD[7]*(1+tope), g)}; "
          f"zona 10 / zona 1 = x{g**9:,.0f}")

print("\n== 2. Debuff de carga del GDD ==")
def lento_gdd(c): return min(0.40, 0.12 * math.log(1 + c))
def lento_mio(f): return 0.30 * f ** 1.5
VAL_DEP = sum(p / 100 * f for p, f in zip([55, 25, 12, 5.5, 2, 0.45, 0.05], [1, 1.8, 3.2, 6, 12, 25, 60]))   # valor medio de un deposito, en V
for nombre, uds in [("Mochila de grieta base (120 unidades)", 120), ("Mochila de grieta maxima (400 unidades)", 400)]:
    v = uds / 3.77 * VAL_DEP; c = v / 20
    print(f"{nombre:40s} valor {v:6.1f} V -> Carga {c:5.2f} -> ralentizacion GDD {100*lento_gdd(c):4.1f} % (formula propuesta: 30 %)")
for c in (1, 5, 10, 12, 16, 30):
    print(f"  Carga {c:2d}: {100*lento_gdd(c):4.1f} %   (equivale a {c*20/VAL_DEP:5.0f} depositos medios o a {c*20/60:4.1f} depositos Ultra raros)")
print("  Un solo deposito Ultra raro (60 V) son Carga 3,0; uno Mitico (25 V), Carga 1,25")

print("\n== 3. Cofre de Saqueo: 80 % recogible y 20 % destruido (GDD) frente a 70/30 ==")
for rec in (0.70, 0.80):
    print(f"  Con carga 100: conserva 50, cofre {50*rec:.0f}, destruido {50*(1-rec):.0f} | saqueador puro (B7, servidor normal): {0.38*rec/0.70 + 0.10:.2f} x PvE")

print("\n== 4. Racha de extraccion del GDD: x1,1 ... x1,5 ==")
T_PVE = (60 / 3.77) * 13 + 40; T_ZF = (120 / 3.77) * 13 + 53; RITMO = (T_PVE / (60 / 3.77)) * (120 / 3.77) / T_ZF
def racha_media(p, paso, tope):
    return sum(p * (1 - p) ** k * min(1 + paso * k, tope) for k in range(400))
def ingreso(p, base, paso, tope):
    t = (1 - p) * T_ZF + p * (0.6 * T_ZF + 30)
    v = (1 - p) * base * racha_media(p, paso, tope) + p * 0.6 * 0.5
    return v / t * T_PVE / (60 / 3.77) * (120 / 3.77)
print(f"Ritmo relativo de la grieta: {RITMO:.3f}")
print("base | racha            | max teorico | 15 % muertes | 30 % | 50 %   (x PvE, sin contratos)")
for base, paso, tope, txt in [(2.0, 0.02, 1.10, "propuesta B6"), (2.0, 0.10, 1.50, "GDD"), (1.8, 0.10, 1.50, "GDD"), (1.6, 0.10, 1.50, "GDD"), (1.5, 0.10, 1.50, "GDD")]:
    print(f"x{base} | +{int(100*paso)} % hasta x{tope} ({txt:12s}) | {RITMO*base*tope:5.2f} | {ingreso(.15, base, paso, tope):5.2f} | {ingreso(.30, base, paso, tope):5.2f} | {ingreso(.50, base, paso, tope):5.2f}")

print("\n== 5. Fragmentos Celestiales: 0,02 % por deposito y 50 por objeto (GDD) ==")
DEP_H = 3600 / 13 * 0.94
for prob in (0.0002, 0.002, 0.005):
    fh = DEP_H * prob
    print(f"  {100*prob:.2f} % por deposito: {fh:.3f} fragmentos/hora -> {50/fh:7.0f} horas de grieta por objeto Celestial")
print(f"  Solo jefes de evento (2 fragmentos, 5 por semana, B1): {50/10:.0f} semanas por objeto")
print(f"  Para 1 objeto cada 8 semanas con 10 h semanales de grieta haria falta {100*50/(80*DEP_H):.3f} % por deposito")

print("\n== 6. Anti-combo del GDD ==")
d = 1.5
cadena = min(2.5, d + 0.5 * d)
print(f"Dos controles de {d} s en la ventana de 6 s: {d + 0.5*d:.2f} s (tope 2,5 s) y despues 2 s de Tenacidad")
print(f"Tiempo maximo bajo control: {cadena:.2f} s de cada {cadena+2:.2f} s = {100*cadena/(cadena+2):.0f} % (propuesta B4: 12,5 %)")
print(f"Con Ruptura (50 de energia, cada 15 s): el primer control de cada 15 s se corta a los 0,8 s")
print(f"Energia: Ruptura cuesta 50 de 100 de base; con la regeneracion en combate de B2 (8/s) se recupera en {50/8:.1f} s")

print("\n== 7. Dash con 2 cargas y recarga de 3 s (GDD) ==")
print(f"Sostenido: 1 dash cada 3 s = {20/3:.2f} de energia/s (propuesta: 1 cada 2,5 s = {20/2.5:.2f}/s); rafaga de 2 dashes = 24 studs y 40 de energia")
print(f"Parpadeo de 12 studs (propuesta 16). Desplazamiento maximo en 1 s: 24 andando + 24 de dos dashes + 18 de Paso de Relampago = {24+24+18} studs")

print("\n== 8. Presupuesto de particulas del GDD: 2.000 en Alto, 800 en Bajo, ajenos al 50 % ==")
HAB, MASC, JEFE, AMB = 60, 10, 150, 40
for nombre, tope, ajeno in [("Bajo segun el GDD (ajenos al 50 %)", 800, 0.5), ("Alto segun el GDD (ajenos al 50 %)", 2000, 0.5), ("Bajo con ajenos al 40 %", 800, 0.4)]:
    uso = 2 * HAB + 7 * 2 * HAB * ajeno + 3 * MASC + 21 * MASC * ajeno + JEFE + AMB
    print(f"  {nombre:36s} peor caso (jefe con 8 jugadores): {uso:5.0f} de {tope} -> {'cabe' if uso <= tope else 'NO CABE'}")

print("\n== 9. Transformacion: +25 % en PvE y +10 % en PvP (GDD) frente a +20 % de dano y -20 % de enfriamientos ==")
print(f"  Tiempo activa: 20 s de cada 120 s de enfriamiento + carga de la barra (~90 s) -> como mucho {100*20/140:.0f} % del tiempo; "
      f"dano medio extra con +25 %: {100*0.25*20/140:.1f} %")
