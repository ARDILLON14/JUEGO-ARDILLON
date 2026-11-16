"""OREBOUND - Etapa 4 (B4): combate.
Ejecutar desde OREBOUND/:  python3 calculos/b4_combate.py [carpeta_fragmentos_md]
Genera calculos/b4_armas.csv. Valores [PROVISIONAL]."""
import csv, math, sys, os

G = 1.65
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = [1.00, 1.15, 1.32, 1.52, 1.75, 1.98, 2.20]; MULT_CEL = 2.60
PREF = ["Pizarra", "Verdín", "Sal", "Brasa", "Escarcha", "Eco", "Obsidiana", "Magma", "Vitral", "Astral"]
def pot_zona(z): return 100 * G ** (z - 1)
def nivel_zona(z): return max(1, 100 * (z - 1))
def nivel_medio(z): return 100 * (z - 1) + 50
def dureza(z): return 1 + 0.1 * (z - 1)
def valor_zona(z): return 10 * G ** (z - 1)
def vida_base(L): return 500 * G ** ((L - 1) / 100)
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def puntos(L): return 3 + 3 * (L - 1)
frag = {}
def md(nombre, cab, filas):
    out = ["| " + " | ".join(cab) + " |", "|" + "---|" * len(cab)]
    out += ["| " + " | ".join(str(c) for c in f) + " |" for f in filas]
    frag[nombre] = "\n".join(out); print(f"\n## {nombre}"); print(frag[nombre])
def n(x, d=0): return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")

# ---------- 1. Armas ----------
CRIT_P, CRIT_M, CRIT_P_MAX, CRIT_M_MAX = 0.05, 1.5, 0.30, 2.0
# tipo: (golpes/s, coef. por golpe, alcance studs, crit extra, objetivos, diferencia)
ARMAS = {"Espada": (1.60, 0.625, 8, 0.00, 2, "Equilibrada; combo de 4 golpes; bloquear cuesta 20 % menos"),
         "Hacha": (0.90, 1.150, 9, 0.00, 3, "Arco de 180°; golpea hasta 3; daño a la guardia ×1,5"),
         "Daga": (2.60, 0.365, 6, 0.10, 1, "+10 % de crítico; +25 % de daño por la espalda"),
         "Lanza": (1.20, 0.810, 14, 0.00, 3, "Largo alcance; atraviesa hasta 3 en línea"),
         "Bastón": (1.00, 0.960, 35, 0.00, 1, "Proyectil a media distancia; habilidades cuestan 10 % menos de energía"),
         "Arco": (1.10, 0.727, 70, 0.00, 1, "Sexto tipo: largo alcance; DPS menor a propósito")}
def dps_rel(t):
    v, c, _, cx, _, _ = ARMAS[t]; return v * c * (1 + (CRIT_P + cx) * (CRIT_M - 1))
cinco = [dps_rel(t) for t in list(ARMAS)[:5]]; media = sum(cinco) / 5
md("armas_tipos", ["Tipo", "Golpes/s", "Coef. por golpe", "Alcance (studs)", "Objetivos", "DPS relativo (con críticos)", "Frente a la media de los 5", "Qué lo diferencia"],
   [[t, n(a[0], 2), n(a[1], 3), a[2], a[4], n(dps_rel(t), 3), f"{100*(dps_rel(t)/media-1):+.1f} %".replace(".", ","), a[5]] for t, a in ARMAS.items()])
print(f"Dispersion de los 5 tipos: min {100*(min(cinco)/media-1):+.2f} %, max {100*(max(cinco)/media-1):+.2f} %; max/min = {max(cinco)/min(cinco):.3f}")
md("armas_dano", ["Zona", "Nivel", "Potencia (Común)"] + list(ARMAS),
   [[z, nivel_zona(z), n(pot_zona(z))] + [n(pot_zona(z) * a[1], 1) for a in ARMAS.values()] for z in range(1, 11)])
HAB_ARMA = ["Ninguna", "Filo templado: el 4.º golpe del combo hace +30 %", "Sed de combate: +5 % de velocidad de ataque 3 s tras matar",
            "Golpe resonante: cada 8 s el siguiente golpe aplica Vulnerable 3 s", "Furia medida: +10 % de daño con la vida por encima del 80 %",
            "Eco del acero: 15 % de repetir el golpe al 40 %", "Remate: +20 % de daño a objetivos por debajo del 25 % de vida"]
HAB_CEL = "Juicio astral: cada 20 s el siguiente golpe es crítico seguro y aplica Vulnerable"
filas = []
for z in range(1, 11):
    for t, a in ARMAS.items():
        for r in range(7):
            p = pot_zona(z) * MULT[r]
            filas.append(dict(arma=f"{t} de {PREF[z-1]} ({RAR[r]})", tipo=t, zona=z, rareza=RAR[r], potencia=round(p), dano_golpe=round(p * a[1], 1),
                              golpes_s=a[0], dps_base=round(p * a[0] * a[1], 1), alcance=a[2], nivel=nivel_zona(z), habilidad=HAB_ARMA[r]))
        if z >= 6:
            p = pot_zona(z) * MULT_CEL
            filas.append(dict(arma=f"{t} Celestial de {PREF[z-1]}", tipo=t, zona=z, rareza="Celestial", potencia=round(p), dano_golpe=round(p * a[1], 1),
                              golpes_s=a[0], dps_base=round(p * a[0] * a[1], 1), alcance=a[2], nivel=nivel_zona(z), habilidad=HAB_CEL))
with open("calculos/b4_armas.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=list(filas[0])); w.writeheader(); w.writerows(filas)
print("Armas en el CSV:", len(filas))
md("armas_rareza", ["Rareza", "Mult. potencia", "Habilidad de arma"], [[RAR[r], n(MULT[r], 2), HAB_ARMA[r]] for r in range(7)] + [["Celestial", n(MULT_CEL, 2), HAB_CEL]])

# ---------- 2. Formula de dano: ejemplo y maximos ----------
MAESTRIA_MAX, ESTADO_MAX = 0.10, 0.40
ej = pot_zona(5) * MULT[3] * 1.5 * ARMAS["Espada"][1]
pasos = [("Golpe de Espada Épica de zona 5 con +50 % de bonos", ej), ("× Fuerza 500 (×2,000)", ej * sat(500)),
         ("× Maestría 50 (×1,05)", ej * sat(500) * 1.05), ("× crítico (×1,5)", ej * sat(500) * 1.05 * 1.5),
         ("× objetivo Vulnerable (+15 %)", ej * sat(500) * 1.05 * 1.5 * 1.15),
         ("× (1 − 25 %) por Defensa 500 en PvE", ej * sat(500) * 1.05 * 1.5 * 1.15 * 0.75)]
md("dano_ejemplo", ["Paso", "Daño"], [[a, n(b)] for a, b in pasos])
tip = MULT[4] * 1.5 * sat(1000) * (1 + 0.15 * 0.5) * 1.10 * 1.10
mx = MULT_CEL * 2.0 * sat(5000) * (1 + CRIT_P_MAX * (CRIT_M_MAX - 1)) * (1 + MAESTRIA_MAX) * (1 + ESTADO_MAX)
print(f"Multiplicador total sobre un Comun sin nada, misma zona: build final tipica x{tip:.2f}; maximo teorico x{mx:.2f}; "
      f"una zona = x{G}; nueve zonas = x{G**9:.1f}")

# ---------- 3. Maestria ----------
def xpm(nv): return math.ceil(10 + 2 * nv + 0.04 * nv * nv)
PTS = {"Común": 1, "Élite": 4, "Guardián": 12, "Jefe": 80}
MIX = {"Común": 0.88, "Élite": 0.10, "Guardián": 0.02}
acum, filas, hitos = 0, [], {1: "Habilidad Z del Núcleo / combo básico del arma", 10: "Habilidad X / remate de combo del arma",
        25: "Habilidad C / pasiva de arma 1", 50: "Habilidad V / pasiva de arma 2", 75: "Despertar disponible / variante de ataque cargado",
        100: "Transformación / título y aspecto de maestro"}
tot = {}
for nv in range(1, 101):
    tot[nv] = acum; acum += xpm(nv)
total100 = tot[100]
# ---------- 4. Enemigos y ritmo del combatiente ----------
F_VIDA = {"Común": 20, "Élite": 80, "Guardián": 300, "Jefe": 1500}
F_DANO = {"Común": 0.03, "Élite": 0.06, "Guardián": 0.10, "Jefe": 0.15}
INTERVALO = {"Común": 1.5, "Élite": 1.8, "Guardián": 2.2, "Jefe": 2.5}
F_XP = {"Común": 1, "Élite": 3.5, "Guardián": 10, "Jefe": 60}
F_MON = {"Común": 1.35, "Élite": 5.4, "Guardián": 16, "Jefe": 60}   # Jefe corregido en la Etapa 6 (antes 250)
K_XP_ENEMIGO = 0.72
FACTOR_HAB = 1.75          # basicos 89 % + habilidades 154 % x 56 % de uso (energia de B2)
VIAJE = 5.0
def vida_enemigo(z, t): return pot_zona(z) * F_VIDA[t] * dureza(z)
def dano_enemigo(z, t): return vida_base(nivel_zona(z)) * F_DANO[t]
def dps_tipico(z, frac_fuerza=0.125, mult_arma=MULT[2] * 1.25, L=None):
    L = L or nivel_medio(z); F = min(1000, puntos(L) * frac_fuerza)
    return pot_zona(z) * mult_arma * sat(F) * (1 + CRIT_P * (CRIT_M - 1)) * FACTOR_HAB
md("enemigos", ["Zona", "Tipo", "Vida", "Daño por golpe", "Segundos entre golpes", "XP", "Monedas", "Segundos para matarlo (jugador típico)"],
   [[z, t, n(vida_enemigo(z, t)), n(dano_enemigo(z, t)), n(INTERVALO[t], 1), n(K_XP_ENEMIGO * xp_acc(nivel_medio(z)) * F_XP[t]),
     n(valor_zona(z) * F_MON[t]), n(vida_enemigo(z, t) / dps_tipico(z), 1)] for z in range(1, 11) for t in F_VIDA])
md("enemigos_mult", ["Tipo", "Vida (× PotZona × dureza)", "Daño por golpe (% de la vida base del jugador de la zona)", "Segundos entre golpes", "XP (× Común)", "Monedas (× valor de zona)", "Puntos de maestría", "Parte de los enemigos"],
   [[t, F_VIDA[t], f"{int(100*F_DANO[t])} %", n(INTERVALO[t], 1), n(F_XP[t], 1), n(F_MON[t], 1), PTS[t], f"{int(100*MIX[t])} %" if t in MIX else "1 por zona"] for t in F_VIDA])
MINERO = [4782, 7890, 12418, 20419, 33692, 55523, 91613, 150461, 242713, 399993]   # B3, minero equilibrado
MINERO_ESP = [5181, 8884, 15586, 25565, 42511, 69600, 115569, 180726, 297570, 476187]   # B3, build de Mineria
filas = []; pts_h_ref = None
for z in range(1, 11):
    for nombre, ff in [("Equilibrada (12,5 %)", 0.125), ("Combate (35 % en Fuerza)", 0.35)]:
        d = dps_tipico(z, ff)
        t_kill = sum(MIX[t] * (vida_enemigo(z, t) / d + VIAJE) for t in MIX)
        kh = 3600 / t_kill
        xp = kh * sum(MIX[t] * F_XP[t] for t in MIX) * K_XP_ENEMIGO * xp_acc(nivel_medio(z))
        mon = kh * sum(MIX[t] * F_MON[t] for t in MIX) * valor_zona(z)
        pm = kh * sum(MIX[t] * PTS[t] for t in MIX)
        if z == 5 and ff == 0.125: pts_h_ref = pm
        ref = MINERO[z-1] if ff == 0.125 else MINERO_ESP[z-1]
        filas.append([z, nombre, n(vida_enemigo(z, "Común") / d, 1), n(kh), n(xp), n(240 * xp_acc(nivel_medio(z))), n(mon), n(ref),
                      n(mon / ref, 2)])
md("combatiente", ["Zona", "Build", "s por enemigo Común", "Enemigos/hora", "XP/hora", "XP/hora objetivo (B2)", "Monedas/hora", "Monedas/hora del minero equivalente (B3)", "Combatiente / minero"], filas)
md("maestria", ["Nivel de maestría", "XP para el siguiente", "XP acumulada", "Horas acumuladas", "Desbloqueo (Núcleo / arma)"],
   [[nv, xpm(nv), n(tot[nv]), n(tot[nv] / pts_h_ref, 1), hitos.get(nv, "+0,1 % de daño por nivel")] for nv in (1, 10, 25, 50, 75, 100)])
print(f"Puntos de maestria por hora (zona 5, equilibrada): {pts_h_ref:.0f}; total a 100: {total100}; horas: {total100/pts_h_ref:.1f}; "
      f"cada nivel tras 100: {xpm(100)} puntos = {60*xpm(100)/pts_h_ref:.0f} min")

# ---------- 5. Nucleos ----------
# (habilidad, coef %, energia, enfriamiento s, efecto)
NUCLEOS = {
 "Núcleo Prismático": ("Luz", "Versátil a media distancia", "Refracción: cada 4.º golpe básico lanza un destello del 40 % a un segundo objetivo", [
   ("Z · Haz Facetado", 180, 15, 4, "Rayo en línea de 25 studs"),
   ("X · Abanico Espectral", 320, 25, 8, "5 esquirlas en cono (64 % cada una)"),
   ("C · Prisma Centinela", 500, 35, 14, "Prisma 6 s: 10 pulsos del 50 % en 12 studs"),
   ("V · Espectro Total", 1000, 50, 30, "Rayo canalizado 2,5 s; aplica Vulnerable +10 % 4 s")], "El Haz rebota una vez al 50 %", "Forma Caleidoscopio"),
 "Núcleo de Brasa": ("Fuego", "Daño en el tiempo", "Rescoldo: los golpes críticos aplican Quemadura", [
   ("Z · Chispa Voraz", 180, 15, 4, "120 % + Quemadura del 60 % en 4 s"),
   ("X · Estela Ígnea", 320, 25, 8, "Carrera de fuego: 200 % + rastro de 120 % en 3 s"),
   ("C · Géiser de Ceniza", 500, 35, 14, "Área de 10 studs tras 0,8 s: 420 % + Quemadura del 80 %"),
   ("V · Sol Menor", 1000, 50, 30, "Orbe 5 s: 10 pulsos del 100 %")], "La Quemadura se propaga a un enemigo cercano", "Forma Ascua Viva"),
 "Núcleo de Escarcha": ("Hielo", "Control", "Piel de Escarcha: quien te golpea queda con Lento 20 % 2 s (una vez cada 10 s)", [
   ("Z · Esquirla Gélida", 160, 15, 4, "Proyectil; Lento 20 % 2 s"),
   ("X · Muro de Hielo", 240, 25, 9, "Barrera 4 s que bloquea proyectiles; daña al aparecer"),
   ("C · Ventisca Corta", 420, 35, 14, "Cono; Congelación 1,2 s en PvE, Lento 40 % 1,5 s en PvP"),
   ("V · Cero Absoluto", 900, 50, 32, "Área de 14 studs; Congelación 2 s en PvE, 1 s en PvP")], "Los enemigos con Lento reciben +10 % de tus habilidades", "Forma Glaciar"),
 "Núcleo de Tormenta": ("Rayo", "Movilidad y cadenas", "Carga Estática: cada 10 studs recorridos da 1 carga (máx. 5); el siguiente básico hace +6 % por carga", [
   ("Z · Arco Voltaico", 180, 15, 4, "110 % + salta a 2 objetivos más al 35 %"),
   ("X · Paso Relámpago", 280, 25, 8, "Parpadeo de 18 studs que daña en la trayectoria"),
   ("C · Jaula Estática", 440, 35, 14, "Zona 5 s: 8 pulsos del 55 %; aplica Descarga"),
   ("V · Juicio del Trueno", 1000, 50, 30, "3 rayos del 300 % + cadena del 100 %")], "Paso Relámpago guarda 2 cargas", "Forma Tempestad"),
 "Núcleo Sísmico": ("Tierra", "Aguante y Ruptura", "Corteza: +8 % de reducción de daño tras 1 s sin moverte (sin superar el tope de Defensa)", [
   ("Z · Puño de Roca", 190, 15, 4.5, "Golpe corto; daño a la guardia ×1,5"),
   ("X · Bastión", 200, 25, 10, "Escudo del 15 % de la vida máxima 4 s; estalla al acabar"),
   ("C · Falla Abierta", 480, 35, 14, "Grieta de 20 studs; derribo 0,8 s en PvE; cuenta como 3 golpes de pico en depósitos"),
   ("V · Cataclismo", 950, 50, 30, "Salto e impacto en 16 studs; rompe la guardia al instante")], "Bastión también protege a aliados a 10 studs al 50 %", "Forma Coloso"),
 "Núcleo Umbrío": ("Sombra", "Asesino", "Hambre de Vacío: cada muerte reduce los enfriamientos 1 s (0,5 s en PvP)", [
   ("Z · Tajo Velado", 170, 15, 4, "+30 % de daño por la espalda"),
   ("X · Paso de Sombra", 260, 25, 8, "Parpadeo de 12 studs detrás del objetivo"),
   ("C · Manto Nocturno", 460, 35, 15, "Invisible 3 s; el siguiente golpe es crítico seguro"),
   ("V · Eclipse", 900, 50, 30, "6 cortes del 150 % a un objetivo")], "Manto Nocturno dura 1 s más y no se rompe al usar Paso de Sombra", "Forma Penumbra")}
filas, res = [], []
for nombre, (elem, rol, pasiva, habs, desp, trans) in NUCLEOS.items():
    for h, coef, en, cd, ef in habs:
        filas.append([nombre, h, f"{coef} %", en, n(cd, 1), n(coef / cd, 1), n(coef / en, 1), ef])
    dps = sum(c / cd for _, c, _, cd, _ in habs); eps = sum(e / cd for _, _, e, cd, _ in habs)
    res.append([nombre, elem, rol, n(dps, 1) + " %", n(eps, 2), n(dps / eps, 1), pasiva, desp, trans])
md("nucleos_hab", ["Núcleo", "Habilidad", "Daño (% de potencia de arma)", "Energía", "Enfriamiento (s)", "% por segundo", "% por punto de energía", "Efecto"], filas)
md("nucleos_res", ["Núcleo", "Elemento", "Rol", "Daño por segundo con todo en uso", "Energía por segundo", "Daño por energía", "Pasiva", "Despertar", "Transformación"], res)
v = [sum(c / cd for _, c, _, cd, _ in x[3]) for x in NUCLEOS.values()]
print(f"Nucleos: dano/s min {min(v):.1f} %, max {max(v):.1f} %, max/min {max(v)/min(v):.3f}")

# ---------- 6. Anti-combo ----------
ESC = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5]
def escala(i): return 1.0 if i < 3 else ESC[min(i - 3, 5)] if i - 3 < 6 else 0.5
md("combo", ["Golpe del combo", "Daño", "Acumulado", "Acumulado sin la regla"],
   [[i + 1, f"{int(100*escala(i))} %", f"{int(round(100*sum(escala(j) for j in range(i+1))))} %", f"{100*(i+1)} %"] for i in range(10)])
RD = [1.0, 0.5, 0.25, 0.0]
md("control", ["Control sobre el mismo objetivo en 10 s", "Duración", "Ejemplo con un aturdimiento de 1,5 s"],
   [[f"{i+1}.º", f"{int(100*r)} %" if r else "Inmune 6 s", n(1.5 * r, 2) + " s" if r else "0 s"] for i, r in enumerate(RD)])
cad = sum(1.5 * r for r in RD); TOPE_ATURD = 2.0
print(f"Cadena maxima de control con aturdimientos de 1,5 s: {cad:.3f} s -> recortada al tope de {TOPE_ATURD} s; "
      f"ciclo minimo 10 s + 6 s de inmunidad: controlado como maximo {100*TOPE_ATURD/16:.1f} % del tiempo")

# ---------- 7. Jefes ----------
def esc_vida(nj): return 1 + 0.6 * (nj - 1)
def esc_dano(nj): return 1 + 0.05 * (nj - 1)
JEFES = [("Capataz de Pizarra", 1), ("Madre Liquen", 2), ("Leviatán de Salmuera", 3)]
filas = []
for nj in range(1, 9):
    fila = [nj, "×" + n(esc_vida(nj), 1), "×" + n(esc_dano(nj), 2), n(100 * esc_vida(nj) / nj) + " %"]
    for _, z in JEFES:
        fila.append(n(vida_enemigo(z, "Jefe") * esc_vida(nj) / (nj * dps_tipico(z)) / 60, 1))
    filas.append(fila)
md("jefes_escala", ["Jugadores", "Vida del jefe", "Daño del jefe", "Vida por jugador", "Capataz: minutos", "Madre Liquen: minutos", "Leviatán: minutos"], filas)
md("jefes_stats", ["Jefe", "Zona", "Vida (1 jugador)", "Vida (8 jugadores)", "Vida base del jugador de la zona", "Golpe normal (15 %)", "Ataque fuerte (35 %)", "Ataque letal avisado (70 %)", "Monedas por jugador", "XP por jugador"],
   [[nm, z, n(vida_enemigo(z, "Jefe")), n(vida_enemigo(z, "Jefe") * esc_vida(8)), n(vida_base(nivel_zona(z))), n(dano_enemigo(z, "Jefe")),
     n(vida_base(nivel_zona(z)) * 0.35), n(vida_base(nivel_zona(z)) * 0.70), n(valor_zona(z) * F_MON["Jefe"]),
     n(K_XP_ENEMIGO * xp_acc(nivel_medio(z)) * F_XP["Jefe"])] for nm, z in JEFES])

# ---------- 8. PvP ----------
MULT_PVP, TOPE_GOLPE, K_PVP, TOPE_DEF_PVP, M_VIT_PVP = 0.06, 0.35, 4500, 0.50, 1.0   # Etapa 7 (antes 0,07; 3000; 0,60; 1,5)
L = 1000; arma = pot_zona(10) * MULT[4] * 1.5
B = {"Cristal (Fue/Vel/Ene)": dict(F=1000, Vel=1000, E=1000), "Tanque (Vit/Def/Fue)": dict(F=1000, V=1000, D=1000),
     "Equilibrada (375 × 8)": dict(F=375, V=375, D=375, Vel=375, E=375), "Minero (Min/Sue/Vit)": dict(V=1000)}
USO = {0: 0.557, 375: 0.63, 1000: 0.754}
def dps_pvp(b):
    g = lambda k: b.get(k, 0)
    fh = 0.89 * sat(g("Vel"), 0.8) + 1.54 * USO[g("E")]
    return arma * sat(g("F")) * (1 + CRIT_P * (CRIT_M - 1)) * fh * MULT_PVP
def vida_pvp(b):
    g = lambda k: b.get(k, 0)
    return vida_base(L) * sat(g("V"), M_VIT_PVP) / (1 - min(g("D") / (g("D") + K_PVP), TOPE_DEF_PVP))
md("pvp_ttk", ["Atacante ↓ / Defensor →"] + list(B), [[a] + [n(vida_pvp(B[d]) / dps_pvp(B[a]), 1) + " s" for d in B] for a in B])
v_golpe = arma * sat(1000) * 10.0 * MULT_PVP
print(f"PvP nivel 1000: habilidad V (1000 %) de Cristal = {v_golpe:,.0f} sin tope; vida base {vida_base(L):,.0f} -> {100*v_golpe/vida_base(L):.0f} % de la vida base; "
      f"con tope del {int(100*TOPE_GOLPE)} %: {TOPE_GOLPE*vida_base(L):,.0f}")
print(f"Sin MULT_PVP el duelo Equilibrada vs Equilibrada duraria {vida_pvp(B['Equilibrada (375 × 8)'])/dps_pvp(B['Equilibrada (375 × 8)'])*MULT_PVP:.1f} s")
t, c = B["Tanque (Vit/Def/Fue)"], B["Cristal (Fue/Vel/Ene)"]
print(f"Ventaja del Tanque sobre el Cristal: {(vida_pvp(t)/dps_pvp(c))/(vida_pvp(c)/dps_pvp(t)):.2f} veces")

if len(sys.argv) > 1:
    os.makedirs(sys.argv[1], exist_ok=True)
    for k, v in frag.items(): open(os.path.join(sys.argv[1], k + ".md"), "w", encoding="utf-8").write(v)

# ---------- 9. Alternativa P4: topes de estado +25 % y critico x1,75 ----------
alt = MULT_CEL * 2.0 * sat(5000) * (1 + CRIT_P_MAX * 0.75) * (1 + MAESTRIA_MAX) * 1.25
print(f"Maximo teorico con topes alternativos: x{alt:.1f} (actual x{mx:.1f})")
