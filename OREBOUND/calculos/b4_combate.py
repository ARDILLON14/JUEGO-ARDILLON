"""OREBOUND - Etapa 4 (B4), rehecha con el GDD: combate.
Ejecutar desde OREBOUND/:  python3 calculos/b4_combate.py   (despues de b2 y b3)
Genera B_Matematico/B4_Combate.md, calculos/b4_armas.csv y calculos/_b4.json"""
import csv, math, sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from montar import montar, tabla, n
B2 = json.load(open("calculos/_b2.json")); B3 = json.load(open("calculos/_b3.json"))
G = 2.00
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = [1.00, 1.25, 1.50, 1.90, 2.50, 3.30, 4.50]; MULT_CEL = 5.20; TOPE_BONO = 0.50
PREF = ["Pizarra", "Verdín", "Sal", "Brasa", "Escarcha", "Eco", "Obsidiana", "Magma", "Vitral", "Astral"]
F_HAB = B2["F_HAB"]; HAB_E = {int(k): v - 0.92 for k, v in B2["F_HAB_E"].items()}
def pot_zona(z): return 100 * G ** (z - 1)
def nivel_zona(z): return max(1, 100 * (z - 1))
def nivel_medio(z): return 100 * (z - 1) + 50 if z > 1 else 50
def dureza(z): return min(2.0, 1 + 0.1 * (z - 1))
def valor_zona(z): return 10 * G ** (z - 1)
def vida_base(L): return 500 * G ** ((L - 1) / 100)
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def puntos(L): return 3 + 3 * (L - 1)
frag, kv = {}, {}

# ---------- 1. Armas ----------
CRIT_P, CRIT_M, CRIT_P_MAX, CRIT_M_MAX = 0.05, 1.5, 0.30, 2.0
ARMAS = {"Espada": (1.60, 0.625, 8, 0.00, 2, "Equilibrada; combo de 4 golpes; bloquear cuesta 20% menos"),
         "Hacha": (0.90, 1.150, 9, 0.00, 3, "Arco de 180°; daño a la guardia ×1,5"),
         "Daga": (2.60, 0.365, 6, 0.10, 1, "+10% de crítico; +25% de daño por la espalda"),
         "Lanza": (1.20, 0.810, 14, 0.00, 3, "Largo alcance; atraviesa en línea"),
         "Bastón": (1.00, 0.960, 35, 0.00, 1, "Proyectil a media distancia; habilidades cuestan 10% menos de energía"),
         "Arco": (1.10, 0.727, 70, 0.00, 1, "Sexto tipo (propuesto): largo alcance; DPS menor a propósito")}
def dps_rel(t): v, c, _, cx, _, _ = ARMAS[t]; return v * c * (1 + (CRIT_P + cx) * (CRIT_M - 1))
cinco = [dps_rel(t) for t in list(ARMAS)[:5]]; media = sum(cinco) / 5
frag["armas_tipos"] = tabla(["Tipo", "Golpes/s", "Coef. por golpe", "Alcance (studs)", "Objetivos por golpe", "DPS relativo (con críticos)", "Frente a la media de los 5", "Qué lo diferencia"],
    [[t, n(a[0], 2), n(a[1], 3), a[2], a[4], n(dps_rel(t), 3), f"{100*(dps_rel(t)/media-1):+.1f}%".replace(".", ","), a[5]] for t, a in ARMAS.items()])
kv.update(disp_min=f"{100*(min(cinco)/media-1):+.1f}".replace(".", ","), disp_max=f"{100*(max(cinco)/media-1):+.1f}".replace(".", ","), arco=n(100 * (1 - dps_rel("Arco") / media), 1))
frag["armas_dano"] = tabla(["Zona", "Nivel", "Potencia (Común)"] + list(ARMAS), [[z, nivel_zona(z), n(pot_zona(z))] + [n(pot_zona(z) * a[1], 1) for a in ARMAS.values()] for z in range(1, 11)])
HAB_ARMA = ["Ninguna", "Filo templado: el 4.º golpe del combo hace +30%", "Sed de combate: +5% de velocidad de ataque 3 s tras derrotar a un enemigo",
            "Golpe resonante: cada 8 s el siguiente golpe aplica Vulnerable 3 s", "Furia medida: +10% de daño con la vida por encima del 80%",
            "Eco del acero: 15% de repetir el golpe al 40%", "Remate: +20% de daño a objetivos por debajo del 25% de vida"]
HAB_CEL = "Juicio astral: cada 20 s el siguiente golpe es crítico seguro y aplica Vulnerable"
filas = []
for z in range(1, 11):
    for t, a in ARMAS.items():
        for r in range(7):
            p = pot_zona(z) * MULT[r]
            filas.append(dict(arma=f"{t} de {PREF[z-1]} ({RAR[r]})", tipo=t, zona=z, rareza=RAR[r], potencia=round(p), dano_golpe=round(p * a[1], 1), golpes_s=a[0],
                              dps_base=round(p * a[0] * a[1], 1), alcance=a[2], nivel=nivel_zona(z), pasiva=HAB_ARMA[r]))
        if z >= 6:
            p = pot_zona(z) * MULT_CEL
            filas.append(dict(arma=f"{t} Celestial de {PREF[z-1]}", tipo=t, zona=z, rareza="Celestial", potencia=round(p), dano_golpe=round(p * a[1], 1), golpes_s=a[0],
                              dps_base=round(p * a[0] * a[1], 1), alcance=a[2], nivel=nivel_zona(z), pasiva=HAB_CEL))
with open("calculos/b4_armas.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=list(filas[0])); w.writeheader(); w.writerows(filas)
kv["n_armas"] = len(filas)
frag["armas_rareza"] = tabla(["Rareza", "Mult. de potencia", "Pasiva de arma"], [[RAR[r], "×" + n(MULT[r], 2), HAB_ARMA[r]] for r in range(7)] + [["Celestial", "×" + n(MULT_CEL, 2), HAB_CEL]])
# Tecnicas de arma: (nombre, coef, energia, enfriamiento, efecto)
TEC = {"Espada": [("Tajo Giratorio", 1.5, 15, 5, "Área de 8 studs a tu alrededor"), ("Contragolpe", 3.0, 30, 12, "Solo tras bloquear un golpe en el último segundo")],
       "Hacha": [("Hendidura", 1.7, 15, 6, "Cono frontal; daño a la guardia ×2"), ("Terremoto Menor", 3.2, 30, 14, "Salto e impacto; derribo de 0,6 s en PvE")],
       "Daga": [("Puñalada Doble", 1.6, 15, 5, "Dos golpes del 80%"), ("Sombra Fugaz", 2.8, 30, 12, "Te coloca 8 studs detrás del objetivo")],
       "Lanza": [("Estocada Larga", 1.6, 15, 5, "Línea de 16 studs"), ("Barrido de Asta", 3.0, 30, 12, "Giro completo que empuja")],
       "Bastón": [("Orbe Cargado", 1.7, 15, 5, "Proyectil que atraviesa"), ("Pulso Arcano", 3.0, 30, 12, "Área de 10 studs; Lento 20% 2 s")],
       "Arco": [("Disparo Cargado", 1.9, 15, 6, "Mantener para cargar"), ("Lluvia de Flechas", 3.2, 30, 14, "Zona de 3 s")]}
frag["tecnicas"] = tabla(["Arma", "Técnica", "Maestría de arma", "Daño (% de potencia)", "Energía", "Enfriamiento (s)", "% por segundo", "Efecto"],
    [[t, x[0], (10, 50)[i], f"{int(100*x[1])}%", x[2], x[3], n(100 * x[1] / x[3], 1), x[4]] for t, v in TEC.items() for i, x in enumerate(v)])

# ---------- 2. Nucleos ----------
N = {
 "Núcleo Prismático": ("Épico", "Luz", "Fragmentos de luz: los críticos devuelven 5 de energía (1 vez por segundo)", [
   ("Z · Lanza Prismática", "Área", 2.2, 20, 6, "Proyectil; ralentiza 25% 1,5 s", "GDD"),
   ("X · Campo de Refracción", "Control", 1.5, 25, 12, "Área de 14 studs; aplica Refractado 6 s (+10% de daño recibido)", "GDD; el daño es propuesta"),
   ("C · Paso de Relámpago", "Movilidad", 1.2, 25, 9, "Parpadeo de 18 studs hacia un objetivo Refractado; 10 si no hay", "GDD; el daño es propuesta"),
   ("V · Prisma Total", "Definitiva", 6.0, 40, 60, "Cúpula de 6 s; enemigos 20% más lentos y un rayo del 100% por segundo", "GDD; el daño es propuesta")],
   "La Lanza rebota una vez al 50%", "Forma Prisma: la Lanza dispara 3 proyectiles en abanico; en PvP solo +10% de velocidad de movimiento"),
 "Núcleo de Brasa": ("Raro", "Fuego", "Rescoldo: los críticos aplican Quemadura", [
   ("Z · Chispa Voraz", "Área", 2.0, 20, 6, "140% + Quemadura del 60% en 4 s", "Propuesta"),
   ("X · Cerco de Ascuas", "Control", 1.4, 25, 12, "Anillo de 10 studs durante 4 s; quien lo cruza recibe Quemadura", "Propuesta"),
   ("C · Estela Ígnea", "Movilidad", 1.3, 25, 9, "Carrera de 14 studs que deja un rastro de fuego 3 s", "Propuesta"),
   ("V · Sol Menor", "Definitiva", 6.6, 40, 60, "Orbe de 6 s: 6 pulsos del 110%", "Propuesta")],
   "La Quemadura se propaga a un enemigo cercano", "Forma Ascua Viva"),
 "Núcleo de Escarcha": ("Raro", "Hielo", "Piel de Escarcha: quien te golpea queda con Lento 20% 2 s (una vez cada 10 s)", [
   ("Z · Esquirla Gélida", "Área", 1.9, 20, 6, "Proyectil que estalla; Lento 20% 2 s", "Propuesta"),
   ("X · Ventisca Corta", "Control", 1.3, 25, 12, "Cono; Congelación 1,2 s en PvE, Lento 40% 1,5 s en PvP", "Propuesta"),
   ("C · Patín de Hielo", "Movilidad", 1.0, 25, 9, "Deslizamiento de 14 studs que deja hielo (Lento 20%)", "Propuesta"),
   ("V · Cero Absoluto", "Definitiva", 5.4, 40, 60, "Área de 14 studs; Congelación 2 s en PvE, 1 s en PvP", "Propuesta")],
   "Los enemigos con Lento reciben +10% de tus habilidades", "Forma Glaciar"),
 "Núcleo de Tormenta": ("Épico", "Rayo", "Carga Estática: cada 10 studs recorridos da 1 carga (máx. 5); el siguiente básico hace +6% por carga", [
   ("Z · Arco Voltaico", "Área", 2.1, 20, 6, "130% + salta a 2 objetivos más al 40%", "Propuesta"),
   ("X · Jaula Estática", "Control", 1.4, 25, 12, "Zona de 5 s; aplica Descarga", "Propuesta"),
   ("C · Salto de Chispa", "Movilidad", 1.3, 25, 9, "Parpadeo de 16 studs que daña en la trayectoria", "Propuesta"),
   ("V · Juicio del Trueno", "Definitiva", 6.0, 40, 60, "3 rayos del 200%", "Propuesta")],
   "Salto de Chispa guarda 2 cargas", "Forma Tempestad"),
 "Núcleo Sísmico": ("Legendario", "Tierra", "Corteza: +8% de reducción de daño tras 1 s sin moverte (sin superar el tope de Defensa)", [
   ("Z · Puño de Roca", "Área", 2.1, 20, 6, "Onda corta; daño a la guardia ×1,5", "Propuesta"),
   ("X · Falla Abierta", "Control", 1.4, 25, 12, "Grieta de 20 studs; derribo de 0,8 s en PvE; cuenta como 3 golpes de pico en depósitos", "Propuesta"),
   ("C · Embestida Pétrea", "Movilidad", 1.0, 25, 9, "Carga de 12 studs con un escudo del 10% de la vida máxima 3 s", "Propuesta"),
   ("V · Cataclismo", "Definitiva", 5.6, 40, 60, "Salto e impacto en 16 studs; rompe la guardia al instante", "Propuesta")],
   "La Embestida también protege a aliados a 10 studs al 50%", "Forma Coloso"),
 "Núcleo Umbrío": ("Legendario", "Sombra", "Hambre de Vacío: cada derrota reduce los enfriamientos 1 s (0,5 s en PvP)", [
   ("Z · Tajo Velado", "Área", 2.0, 20, 6, "Arco frontal; +30% de daño por la espalda", "Propuesta"),
   ("X · Manto Nocturno", "Control", 1.2, 25, 12, "Invisible 3 s; el siguiente golpe es crítico seguro y aplica Lento 30% 2 s", "Propuesta"),
   ("C · Paso de Sombra", "Movilidad", 1.3, 25, 9, "Parpadeo de 12 studs detrás del objetivo", "Propuesta"),
   ("V · Eclipse", "Definitiva", 6.0, 40, 60, "6 cortes del 100% a un objetivo", "Propuesta")],
   "Manto Nocturno dura 1 s más", "Forma Penumbra")}
filas, res, dn = [], [], {}
for nom, (rar, elem, pas, habs, desp, trans) in N.items():
    for h, tipo, coef, en, cd, ef, orig in habs:
        filas.append([nom, h, tipo, f"{int(round(100*coef))}%", en, cd, n(100 * coef / cd, 1), ef, orig])
    d = sum(c / cd for _, _, c, _, cd, _, _ in habs); e = sum(en / cd for _, _, _, en, cd, _, _ in habs); dn[nom] = d
    res.append([nom, rar, elem, n(100 * d, 1) + "%", n(e, 2), pas, desp, trans])
frag["nucleos_hab"] = tabla(["Núcleo", "Habilidad", "Tipo", "Daño (% de potencia de arma)", "Energía", "Enfriamiento (s)", "% por segundo", "Efecto", "Origen"], filas)
frag["nucleos_res"] = tabla(["Núcleo", "Rareza", "Elemento", "Daño por segundo con todo en uso", "Energía por segundo", "Pasiva", "Despertar", "Transformación"], res)
ref = dn["Núcleo Prismático"]
kv.update(nuc_ref=n(100 * ref, 1), nuc_min=n(100 * (min(dn.values()) / ref - 1), 1), nuc_max=n(100 * (max(dn.values()) / ref - 1), 1), f_hab=n(F_HAB, 2),
          hab0=n(100 * HAB_E[0], 1), hab1000=n(100 * HAB_E[1000], 1))
def carga(sel): return sum(c / cd for c, _, cd in sel), sum(e / cd for _, e, cd in sel)
P = [(h[2], h[3], h[4]) for h in N["Núcleo Prismático"][3]]; E = [(x[1], x[2], x[3]) for x in TEC["Espada"]]
frag["ranuras"] = tabla(["Qué se pone en Z, X, C y V (Espada + Prismático)", "Daño por segundo sin límite de energía", "Energía por segundo"],
    [[a, n(100 * carga(s)[0], 1) + "%", n(carga(s)[1], 2)] for a, s in [("Las 4 del Núcleo (referencia)", P), ("Lanza, Campo y Prisma Total + Tajo Giratorio", [P[0], P[1], P[3], E[0]]),
                                                                      ("Lanza y Prisma Total + las 2 técnicas de Espada", [P[0], P[3], E[0], E[1]]), ("Lanza, Paso de Relámpago y las 2 técnicas", [P[0], P[2], E[0], E[1]])]])
kv.update(mix_max=n(100 * carga([P[0], P[3], E[0], E[1]])[0], 1), mix_e=n(carga([P[0], P[3], E[0], E[1]])[1], 2))

# ---------- 3. Formula de dano ----------
MAESTRIA_MAX, ESTADO_MAX = 0.10, 0.40
ej = pot_zona(5) * MULT[3] * 1.25 * ARMAS["Espada"][1]
frag["dano_ejemplo"] = tabla(["Paso", "Daño"], [[a, n(b)] for a, b in [("Golpe de Espada Épica de zona 5 con +25% de bonos", ej), ("× Fuerza 500 (×2,000)", ej * 2), ("× Maestría 50 (×1,05)", ej * 2 * 1.05),
    ("× crítico (×1,5)", ej * 2 * 1.05 * 1.5), ("× objetivo Vulnerable (+15%)", ej * 2 * 1.05 * 1.5 * 1.15), ("× (1 − 25%) por Defensa 500 en PvE", ej * 2 * 1.05 * 1.5 * 1.15 * 0.75)]])
tip = MULT[4] * 1.25 * sat(1000) * (1 + 0.15 * 0.5) * 1.10 * 1.10
mx = MULT_CEL * (1 + TOPE_BONO) * sat(5000) * (1 + CRIT_P_MAX * (CRIT_M_MAX - 1)) * (1 + MAESTRIA_MAX) * (1 + ESTADO_MAX)
kv.update(dano_tip=n(tip, 1), dano_max=n(mx, 1), nueve=n(G ** 9))

# ---------- 4. Enemigos y combatiente ----------
F_VIDA = {"Común": 16, "Élite": 64, "Guardián": 240, "Jefe": 1200}
F_DANO = {"Común": 0.03, "Élite": 0.06, "Guardián": 0.10, "Jefe": 0.15}; INTERVALO = {"Común": 1.5, "Élite": 1.8, "Guardián": 2.2, "Jefe": 2.5}
F_XP = {"Común": 1, "Élite": 3.5, "Guardián": 10, "Jefe": 60}; REL_MON = {"Común": 1, "Élite": 4, "Guardián": 12}
PTS = {"Común": 1, "Élite": 4, "Guardián": 12, "Jefe": 80}; MIX = {"Común": 0.88, "Élite": 0.10, "Guardián": 0.02}
ARMA_TIP = MULT[2] * 1.125; VIAJE = 5.0
def vida_enemigo(z, t): return pot_zona(z) * F_VIDA[t] * dureza(z)
def dano_enemigo(z, t): return vida_base(nivel_zona(z)) * F_DANO[t]
def dps_tipico(z, ff=0.125): return pot_zona(z) * ARMA_TIP * sat(min(1000, puntos(nivel_medio(z)) * ff)) * (1 + CRIT_P * (CRIT_M - 1)) * F_HAB
def ciclo(z, ff): return sum(MIX[t] * (vida_enemigo(z, t) / dps_tipico(z, ff) + VIAJE) for t in MIX)
kh5 = 3600 / ciclo(5, 0.125)
K_XP = round(240 * xp_acc(450) / (kh5 * sum(MIX[t] * F_XP[t] for t in MIX) * xp_acc(450)), 2)
K_MON = round(1.03 * B3["minero_eq"][4] / (kh5 * sum(MIX[t] * REL_MON[t] for t in MIX) * valor_zona(5)), 2)
F_MON = {t: round(K_MON * REL_MON[t], 2) for t in REL_MON}; F_MON["Jefe"] = 60
frag["enemigos_mult"] = tabla(["Tipo", "Vida (× PotZona × dureza)", "Daño por golpe (% de la vida base del jugador de la zona)", "Segundos entre golpes", "XP (× Común)", "Monedas (× valor de zona)", "Puntos de maestría", "Parte de los enemigos"],
    [[t, F_VIDA[t], f"{int(100*F_DANO[t])}%", n(INTERVALO[t], 1), n(F_XP[t], 1), n(F_MON[t], 2), PTS[t], f"{int(100*MIX[t])}%" if t in MIX else "1 por zona"] for t in F_VIDA])
frag["enemigos"] = tabla(["Zona", "Tipo", "Vida", "Daño por golpe", "XP", "Monedas", "Segundos para derrotarlo (jugador típico)"],
    [[z, t, n(vida_enemigo(z, t)), n(dano_enemigo(z, t)), n(K_XP * xp_acc(nivel_medio(z)) * F_XP[t]), n(valor_zona(z) * F_MON[t]), n(vida_enemigo(z, t) / dps_tipico(z), 1)] for z in range(1, 11) for t in F_VIDA])
filas = []; comb = {"eq": [], "esp": []}; rel = []; xr = []; pts_h = None
for z in range(1, 11):
    for nom, ff, k, refm in (("Equilibrada (12,5%)", 0.125, "eq", B3["minero_eq"]), ("Combate (35% en Fuerza)", 0.35, "esp", B3["minero_esp"])):
        kh = 3600 / ciclo(z, ff); xp = kh * sum(MIX[t] * F_XP[t] for t in MIX) * K_XP * xp_acc(nivel_medio(z)); mon = kh * sum(MIX[t] * F_MON[t] for t in MIX) * valor_zona(z)
        comb[k].append(round(mon)); rel.append(mon / refm[z-1])
        if k == "eq": xr.append(100 * (xp / (240 * xp_acc(nivel_medio(z))) - 1))
        if z == 5 and k == "eq": pts_h = kh * sum(MIX[t] * PTS[t] for t in MIX)
        filas.append([z, nom, n(vida_enemigo(z, "Común") / dps_tipico(z, ff), 1), n(kh), n(xp), n(240 * xp_acc(nivel_medio(z))), n(mon), n(refm[z-1]), n(mon / refm[z-1], 2)])
frag["combatiente"] = tabla(["Zona", "Build", "s por enemigo Común", "Enemigos/hora", "XP/hora", "XP/hora objetivo (B2)", "Monedas/hora", "Monedas/hora del minero equivalente (B3)", "Combatiente / minero"], filas)
kv.update(k_xp=n(K_XP, 2), rel_min=n(min(rel), 2), rel_max=n(max(rel), 2), xp_min=n(min(xr)), xp_max=n(max(xr)), ttk1=n(vida_enemigo(1, "Común") / dps_tipico(1), 1), ttk10=n(vida_enemigo(10, "Común") / dps_tipico(10), 1),
          ej_vida=n(vida_enemigo(1, "Élite")), arma_tip=n(ARMA_TIP, 2))
# Maestria
def xpm(nv): return math.ceil(10 + 2 * nv + 0.04 * nv * nv)
tot = {}; a = 0
for nv in range(1, 101): tot[nv] = a; a += xpm(nv)
HIT = {1: "Habilidad Z / combo básico", 10: "Habilidad X / técnica 1 del arma", 25: "Habilidad C / pasiva de arma mejorada", 50: "Habilidad V / técnica 2 del arma",
       75: "Pasiva del Núcleo mejorada / ataque cargado", 100: "Despertar y Transformación / título y aspecto de maestro"}
frag["maestria"] = tabla(["Nivel de maestría", "XP para el siguiente", "XP acumulada", "Horas acumuladas", "Desbloqueo (Núcleo / arma)"],
    [[nv, xpm(nv), n(tot[nv]), n(tot[nv] / pts_h, 1), HIT[nv]] for nv in (1, 10, 25, 50, 75, 100)])
kv.update(pts_h=n(pts_h), h100=n(tot[100] / pts_h, 1), h50=n(tot[50] / pts_h, 1), xpm100=xpm(100), min100=n(60 * xpm(100) / pts_h))

# ---------- 5. Anti-combo ----------
ESC = [1, 1, 1, 1, .9, .8, .7, .6, .5, .5]
frag["combo"] = tabla(["Golpe del combo", "Daño", "Acumulado", "Acumulado sin la regla"], [[i + 1, f"{int(100*ESC[i])}%", f"{int(round(100*sum(ESC[:i+1])))}%", f"{100*(i+1)}%"] for i in range(10)])
d = 1.5; cad = min(2.5, d * 1.5)
frag["tenacidad"] = tabla(["Inmunidad (Tenacidad) tras el segundo control", "Tiempo máximo bajo control", "Con Ruptura disponible"],
    [[f"{t} s" + txt, n(100 * cad / (cad + t)) + "%", n(100 * (0.8 + 0.5 * d) / (0.8 + 0.5 * d + t)) + "%"] for t, txt in ((2, " (GDD)"), (3, ""), (5, " (adoptada)"), (6, ""))])
kv.update(cad=n(d * 1.5, 2), ctl_gdd=n(100 * cad / (cad + 2)), ctl=n(100 * cad / (cad + 5)))

# ---------- 6. Jefes ----------
def ev(nj): return 1 + 0.6 * (nj - 1)
JEFES = [("Capataz de Pizarra", 1), ("Madre Liquen", 2), ("Leviatán de Salmuera", 3)]
frag["jefes_escala"] = tabla(["Jugadores", "Vida del jefe", "Daño del jefe", "Vida por jugador"] + [f"{j}: minutos" for j, _ in JEFES],
    [[nj, "×" + n(ev(nj), 1), "×" + n(1 + 0.05 * (nj - 1), 2), n(100 * ev(nj) / nj) + "%"] + [n(vida_enemigo(z, "Jefe") * ev(nj) / (nj * dps_tipico(z)) / 60, 1) for _, z in JEFES] for nj in range(1, 9)])
frag["jefes_stats"] = tabla(["Jefe", "Zona", "Vida (1 jugador)", "Vida (8 jugadores)", "Vida base del jugador de la zona", "Golpe normal (15%)", "Ataque fuerte (35%)", "Ataque letal avisado (70%)", "Monedas por jugador", "XP por jugador"],
    [[nm, z, n(vida_enemigo(z, "Jefe")), n(vida_enemigo(z, "Jefe") * ev(8)), n(vida_base(nivel_zona(z))), n(dano_enemigo(z, "Jefe")), n(vida_base(nivel_zona(z)) * .35), n(vida_base(nivel_zona(z)) * .70),
      n(valor_zona(z) * 60), n(K_XP * xp_acc(nivel_medio(z)) * 60)] for nm, z in JEFES])
kv.update(jefe1=n(vida_enemigo(1, "Jefe") / dps_tipico(1) / 60, 1), jefe8=n(vida_enemigo(1, "Jefe") * ev(8) / (8 * dps_tipico(1)) / 60, 1))

# ---------- 7. PvP ----------
TOPE_GOLPE, K_PVP, TOPE_DEF, M_VIT, RAFAGA = 0.35, 4500, 0.50, 1.0, 0.60
L = 1000; arma = pot_zona(10) * MULT[4] * 1.5
BU = {"Cristal (Fue/Vel/Ene)": dict(F=1000, Vel=1000, E=1000), "Tanque (Vit/Def/Fue)": dict(F=1000, V=1000, D=1000),
      "Equilibrada (375 × 8)": dict(F=375, V=375, D=375, Vel=375, E=375), "Minero (Min/Sue/Vit)": dict(V=1000)}
def bruto(b): g = lambda k: b.get(k, 0); return arma * sat(g("F")) * (1 + CRIT_P * (CRIT_M - 1)) * (0.92 * sat(g("Vel"), 0.8) + HAB_E[g("E")])
def vpvp(b): g = lambda k: b.get(k, 0); return vida_base(L) * sat(g("V"), M_VIT) / (1 - min(g("D") / (g("D") + K_PVP), TOPE_DEF))
eq = BU["Equilibrada (375 × 8)"]
MULT_PVP = round(vpvp(eq) / bruto(eq) / 18.0, 3)                      # duelo de equilibradas de 18 s
frag["pvp_ttk"] = tabla(["Atacante ↓ / Defensor →"] + list(BU), [[a] + [n(vpvp(BU[d_]) / (bruto(BU[a]) * MULT_PVP), 1) + " s" for d_ in BU] for a in BU])
ts = [vpvp(BU[d_]) / (bruto(BU[a]) * MULT_PVP) for a in list(BU)[:3] for d_ in list(BU)[:3]]
t_, c_ = BU["Tanque (Vit/Def/Fue)"], BU["Cristal (Fue/Vel/Ene)"]
combo = arma * sat(1000) * (2.0 * 1.5 * 1.3 + 6.0 + 1.3 + 1.2) * MULT_PVP        # Umbrio: Manto + Tajo critico por la espalda + Eclipse + Paso
v_def = arma * sat(1000) * 6.0 * MULT_PVP
kv.update(mult_pvp=n(MULT_PVP, 3), sin_mult=n(vpvp(eq) / bruto(eq), 1), duelo_min=n(min(ts)), duelo_max=n(max(ts)), ventaja=n((vpvp(t_) / bruto(c_)) / (vpvp(c_) / bruto(t_)), 2),
          combo=n(100 * combo / vida_base(L)), v_def=n(100 * v_def / vida_base(L)), golpe_v=n(100 * arma * sat(1000) * 1.0 * MULT_PVP / vida_base(L), 1))
json.dump({"combate_eq": comb["eq"], "combate_esp": comb["esp"], "F_MON": F_MON, "F_VIDA": F_VIDA, "K_XP": K_XP, "MULT_PVP": MULT_PVP, "ARMA_TIP": ARMA_TIP, "pts_h": pts_h}, open("calculos/_b4.json", "w"))
montar("plantillas/B4.md", "B_Matematico/B4_Combate.md", frag, kv)
for k in sorted(kv): print(f"  {k} = {kv[k]}")
