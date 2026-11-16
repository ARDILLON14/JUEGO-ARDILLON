"""OREBOUND - Etapa 5 (B5), rehecha con el GDD: mascotas.
Ejecutar desde OREBOUND/:  python3 calculos/b5_mascotas.py   (despues de b2, b3 y b4)
Genera B_Matematico/B5_Mascotas.md y calculos/_b5.json"""
import math, sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from montar import montar, tabla, n
B2 = json.load(open("calculos/_b2.json")); B3 = json.load(open("calculos/_b3.json")); B4 = json.load(open("calculos/_b4.json"))
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
MULT = dict(zip(RAR, [1.00, 1.25, 1.50, 1.90, 2.50, 3.30, 4.50]))
G, F_HAB, CRIT = 2.0, B2["F_HAB"], 1.025
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
frag, kv = {}, {}

# ---------- 1. Nivel ----------
def xpp(nv): return math.ceil(15 + 3 * nv + 0.09 * nv * nv)
def mult_nivel(nv): return 1 + 0.015 * (nv - 1)
def vel_nivel(nv): return 1 + 0.002 * (nv - 1)
def util_nivel(nv): return 1 + 0.005 * (nv - 1)
FASE = {"Cría": 1.00, "Forma desatada": 1.25, "Forma desatada máxima": 1.50}
PTS_E = {"Común": 2, "Élite": 8, "Guardián": 24}; PTS_D = [2, 3, 4, 6, 9, 14, 22]; MIX = {"Común": 0.88, "Élite": 0.10, "Guardián": 0.02}; P_DEP = [55, 25, 12, 5.5, 2, 0.45, 0.05]
pc = 236 * sum(MIX[t] * PTS_E[t] for t in MIX); pm = B3["dep_h"][4] * sum(p / 100 * x for p, x in zip(P_DEP, PTS_D)); NIDO = 0.15
acum = {}; a = 0
for nv in range(1, 101): acum[nv] = a; a += xpp(nv)
frag["nivel"] = tabla(["Nivel", "XP para el siguiente", "XP acumulada", "Mult. de daño", "Mult. de velocidad de ataque", "Mult. de utilidad", "Horas en combate", "Horas minando", "Horas en el Nido"],
    [[nv, xpp(nv) if nv < 100 else "—", n(acum[nv]), n(mult_nivel(nv), 3), n(vel_nivel(nv), 3), n(util_nivel(nv), 3), n(acum[nv] / pc, 1), n(acum[nv] / pm, 1), n(acum[nv] / (NIDO * pc), 1)] for nv in (1, 10, 25, 50, 75, 100)])
kv.update(pc=n(pc), pm=n(pm), pn=n(NIDO * pc), h50=n(acum[50] / pc, 1), h100=n(acum[100] / pc, 1))

# ---------- 2. Evolucion ----------
GOLPES = [500, 1000, 2000, 4000, 8000, 15000, 30000]; golpes_h = B3["dep_h"][4] * 6.0
F_ELEM = [10, 15, 25, 40, 60, 90, 130]; JEFE_MAX = [5, 5, 8, 8, 12, 12, 16]; DUP = [1, 2, 4, 8, 16, 32, 64]
frag["evolucion"] = tabla(["Rareza", "Incubación (golpes de pico)", "Horas minando", "Desatada: fragmentos de su elemento", "Máxima: material de jefe", "Fragmentos al liberar un duplicado"],
    [[r, n(GOLPES[i]), n(GOLPES[i] / golpes_h, 1), F_ELEM[i], JEFE_MAX[i], DUP[i]] for i, r in enumerate(RAR)])
kv.update(golpes_h=n(golpes_h))

# ---------- 3. Roles y formulas ----------
ROL = {"Ofensiva": (0.016, 0.40), "Control": (0.010, 0.50), "Defensa": (0.008, 1.00), "Apoyo": (0.005, 0.50), "Minería": (0.004, 0.40)}
POSTURA = {"Proteger": (1.5, 0.5), "Recolectar": (0.5, 1.5)}; RADIO = 20
U_REF = FASE["Forma desatada"] * util_nivel(50)
def dps_ref(f, maestria=0): return sat(f) * CRIT * (1 + 0.001 * maestria) * F_HAB
def dps_masc(rol, rar, nv, fase, dom, postura="Proteger"): return ROL[rol][0] * MULT[rar] * mult_nivel(nv) * FASE[fase] * sat(dom) * vel_nivel(nv) * POSTURA[postura][0]
def U(nv, fase, dom): return FASE[fase] * util_nivel(nv) * sat(dom, 1.5) / U_REF
frag["roles"] = tabla(["Rol", "Coef. de daño (b)", "Coef. de vida (h)", "Habilidad activa (forma desatada)", "Ataque coordinado (forma máxima)", "Tope del efecto"],
    [["Ofensiva", "0,016", "0,40", "Mordisco que aplica Quemadura", "Remata objetivos por debajo del 15% de vida", "Tope de DPS conjunto"],
     ["Control", "0,010", "0,50", "Ralentización del 30% durante 2 s (cada 10 s)", "Encadena un aturdimiento corto tras una habilidad del dueño, sujeto a rendimientos decrecientes", "25% menos de daño enemigo"],
     ["Defensa", "0,008", "1,00", "Escudo que absorbe el 20% de la vida máxima del dueño durante 5 s (cada 30 s, si baja del 50%)", "Bloquea un proyectil que apunta al dueño", "Un escudo activo a la vez"],
     ["Apoyo", "0,005", "0,50", "+15% de velocidad de ataque durante 6 s (cada 20 s)", "Cura el 8% al dueño tras una esquiva perfecta", "4% de la vida por segundo en PvE; la mitad en PvP"],
     ["Minería", "0,004", "0,40", "+20% de velocidad de extracción durante 10 s (cada 30 s)", "Pica el mismo depósito que el dueño", "+40% de velocidad de extracción entre todas"]])
ej = dps_masc("Ofensiva", "Legendario", 60, "Forma desatada", 400)
kv.update(ej_dps=n(ej, 4), ej_pct=n(100 * ej / dps_ref(300), 1), u_ref=n(U_REF, 3), radio=RADIO, r_rec=n(RADIO * 1.5), r_pro=n(RADIO * 0.5), f_hab=n(F_HAB, 2))
vb = 500 * G ** ((450 - 1) / 100); kv.update(ej_vb=n(vb), ej_vida=n(vb * 1.0 * MULT["Épico"] * 1.49 * 1.25))
PAS_MIN = [5, 6, 8, 10, 15, 18, 22]
frag["pasiva_mineria"] = tabla(["Rareza de la mascota de Minería"] + RAR, [["Velocidad de extracción (pasiva de cría)"] + [f"+{x}%" for x in PAS_MIN]])

# ---------- 4. Topes de DPS ----------
TOPE = {"PvE": 0.40, "PvP y Zonas Fracturadas": 0.25}
EQ = {10: ("Común", "Cría"), 50: ("Épico", "Forma desatada"), 100: ("Ultra raro", "Forma desatada máxima")}; VELS = [1.6, 1.0, 0.6]
def simular(nv, dom, fue, modo, postura, dur=120.0, dt=0.05, VENT=5.0):
    rar, fase = EQ[nv]; ref = dps_ref(fue); tope = TOPE[modo] * ref
    teor = [dps_masc("Ofensiva", rar, nv, fase, dom, postura) for _ in VELS]; hab = [0.15 * d for d in teor] if fase != "Cría" else [0.0] * 3
    total = sum(teor) + sum(hab); factor = min(1.0, tope / total)
    prox = [0.0] * 3; ph = [3.0, 7.0, 11.0]; hecho = 0.0; pico = 0.0; vent = []; t = 0.0
    while t < dur:
        vent = [(a_, b_) for a_, b_ in vent if a_ > t - VENT]; cubo = tope * VENT - sum(b_ for _, b_ in vent); g = 0.0
        for i, v in enumerate(VELS):
            vel = v * vel_nivel(nv)
            if t >= prox[i]: d = min(teor[i] / vel * factor, cubo); cubo -= d; g += d; prox[i] = t + 1 / vel
            if hab[i] and t >= ph[i]: d = min(hab[i] * 12 * factor, cubo); cubo -= d; g += d; ph[i] = t + 12
        hecho += g; vent.append((t, g)); pico = max(pico, sum(b_ for _, b_ in vent) / VENT); t += dt
    return total / ref, factor, hecho / dur / ref, pico / ref
filas = []; casos = 0; peor = 0
for modo in TOPE:
    for nom, fue, dom in [("Típico (Fuerza 170, Dominio 170)", 170, 170), ("Fuerza 1.000, Dominio 0", 1000, 0), ("Fuerza 1.000, Dominio 1.000", 1000, 1000), ("Fuerza 0, Dominio 1.000", 0, 1000)]:
        for nv in (10, 50, 100):
            br, fa, real, pico = simular(nv, dom, fue, modo, "Proteger"); casos += 1; peor = max(peor, pico / TOPE[modo])
            assert real <= TOPE[modo] + 1e-9 and pico <= TOPE[modo] + 1e-9
            filas.append([modo, nom, nv, f"{EQ[nv][0]}, {EQ[nv][1].lower()}", n(100 * br, 1) + "%", n(fa, 3), n(100 * real, 1) + "%", n(100 * pico, 1) + "%", f"{int(100*TOPE[modo])}%"])
frag["topes"] = tabla(["Modo", "Jugador", "Nivel de las 3 mascotas", "Rareza y fase", "DPS teórico sin tope (% del jugador)", "Factor del servidor", "DPS real medio", "Mayor media en 5 s", "Tope"], filas)
kv.update(casos=casos, t_f1000=filas[5][4], t_d1000=filas[11][4], t_tip100=filas[2][4], t_crias=filas[0][4])

# ---------- 5. Valor de las mascotas que no hacen dano ----------
FV = B4["F_VIDA"]; FD = {"Común": 0.03, "Élite": 0.06, "Guardián": 0.10}; IT = {"Común": 1.5, "Élite": 1.8, "Guardián": 2.2}; FM = B4["F_MON"]
VIAJE, ESQ, DESC, UMB, REGEN_F, REGEN_C = 5.0, 0.5, 5.0, 0.30, 0.05, 0.005
DUR5 = 1.4; FUE = 168; DOM = 170; dps_tip = B4["ARMA_TIP"] * dps_ref(FUE)
u = U(50, "Forma desatada", DOM)
def aporte(rol): return dps_masc(rol, "Épico", 50, "Forma desatada", DOM, "Proteger") * 1.15 / dps_ref(FUE)
def combate(dps_x=0.0, control=0.0, escudo=0.0, cura=0.0, vel_atq=0.0):
    d = dps_tip * (1 + min(dps_x, 0.40)) * (1 + 0.66 * vel_atq)
    tp = sum(MIX[t] * FV[t] * DUR5 / d for t in MIX); cic = tp + VIAJE
    dano = sum(MIX[t] * (FV[t] * DUR5 / d) * FD[t] / IT[t] for t in MIX) / cic * (1 - ESQ) * (1 - min(control, 0.25))
    neto = dano - min(escudo, dano * 0.6) - cura - REGEN_C
    parado = 0.0 if neto <= 0 else (DESC + (1 - UMB) / REGEN_F) / ((1 - UMB) / neto + DESC + (1 - UMB) / REGEN_F)
    kh = 3600 / cic * (1 - parado); return kh, parado, kh * sum(MIX[t] * FM[t] for t in MIX), dano
def aguante(control=0.0, escudo=0.0, cura=0.0):
    bruto_ = FD["Guardián"] / IT["Guardián"] * (1 - min(control, 0.25)); return 1 / (bruto_ - cura - REGEN_C) * (1 + (0.20 * u if escudo else 0))
ESC, CUR, CTL, VAT = 0.20 / 30 * u, 0.08 / 30 * u, 0.30 * 2 / 10 * u, 0.15 * 6 / 20 * u
EQS = {"Sin mascotas": {}, "3 de Ofensiva": dict(dps_x=3 * aporte("Ofensiva")),
       "2 de Ofensiva + Defensa": dict(dps_x=2 * aporte("Ofensiva") + aporte("Defensa"), escudo=ESC),
       "2 de Ofensiva + Apoyo": dict(dps_x=2 * aporte("Ofensiva") + aporte("Apoyo"), vel_atq=VAT),
       "2 de Ofensiva + Control": dict(dps_x=2 * aporte("Ofensiva") + aporte("Control"), control=CTL),
       "Defensa + Apoyo + Control": dict(dps_x=aporte("Defensa") + aporte("Apoyo") + aporte("Control"), escudo=ESC, vel_atq=VAT, control=CTL)}
base = combate(); ag0 = aguante(); filas = []; val = {}
for nom, kw in EQS.items():
    k, par, mon, _ = combate(**kw); s = {x: kw[x] for x in ("control", "escudo") if x in kw}; ag = aguante(**s); val[nom] = 100 * (mon / base[2] - 1)
    filas.append([nom, n(100 * kw.get("dps_x", 0), 1) + "%", n(100 * par, 1) + "%", n(k), n(val[nom], 1) + "%", n(ag, 1) + " s", n(100 * (ag / ag0 - 1)) + "%"])
frag["valor"] = tabla(["Equipo (Épico, nivel 50, desatada, postura Proteger)", "DPS que añaden", "Tiempo parado recuperando vida", "Enemigos/hora", "Monedas/hora frente a sin mascotas", "Aguante frente a un Guardián sin esquivar", "Aguante extra"], filas)
kv.update(v3=n(val["3 de Ofensiva"], 1), vdef=n(val["2 de Ofensiva + Defensa"], 1), vapo=n(val["2 de Ofensiva + Apoyo"], 1), vctl=n(val["2 de Ofensiva + Control"], 1), vutil=n(val["Defensa + Apoyo + Control"], 1),
          parado0=n(100 * base[1], 1))
# Mineria
T_MED, VIAJE_M, T_BANCO, UDS, CAP, TOPE_EXT = 6.0, 6.0, 40.0, B3["uds"], 60, 0.40
def minero(vel_ext=0.0, auto=False): return 3600 / (T_MED / (1 + min(vel_ext, TOPE_EXT)) + VIAJE_M - (1.0 if auto else 0) + T_BANCO * UDS / CAP)
m0 = minero(); filas = []; vm = {}
for nom, k_, pas in [("Sin mascotas", 0, 0), ("1 de Minería (Épica)", 1, 0.10), ("2 de Minería", 2, 0.10), ("3 de Minería", 3, 0.10), ("Guiverno de Cuarzo + 2 de Minería Épicas", 2, 0.10)]:
    ve = k_ * pas + (0.20 * 10 / 30 * u if k_ else 0) + (0.15 if "Guiverno" in nom else 0); vm[nom] = 100 * (minero(ve, k_ > 0) / m0 - 1)
    filas.append([nom, n(100 * min(ve, TOPE_EXT), 1) + "%", "Sí" if k_ else "No", n(minero(ve, k_ > 0)), n(vm[nom], 1) + "%"])
frag["valor_mineria"] = tabla(["Equipo en postura Recolectar", "Velocidad de extracción añadida", "Recogida automática", "Depósitos/hora", "Monedas/hora frente a sin mascotas"], filas)
kv.update(vm1=n(vm["1 de Minería (Épica)"], 1), vm3=n(vm["3 de Minería"], 1))

# ---------- 6. Espacios ----------
def equipo(of=3, de=0, ap=0, ct=0):
    return combate(dps_x=of * aporte("Ofensiva") + de * aporte("Defensa") + ap * aporte("Apoyo") + ct * aporte("Control"), escudo=ESC if de else 0, vel_atq=VAT if ap else 0, control=CTL * ct)[2]
k3 = equipo(); filas = []
for nom, a_ in [("3 (inicial): 3 de Ofensiva", (3,)), ("4: + Defensa", (3, 1)), ("5: + Defensa + Apoyo", (3, 1, 1)), ("6: + Defensa + Apoyo + Control", (3, 1, 1, 1))]:
    m = equipo(*a_); filas.append([nom, n(100 * (m / base[2] - 1), 1) + "%", n(100 * (m / k3 - 1), 1) + "%"])
frag["espacios"] = tabla(["Espacios y equipo", "Monedas/hora frente a sin mascotas", "Frente al equipo de 3"], filas)
sexto = 100 * (equipo(3, 1, 1, 1) / equipo(3, 1, 1) - 1); kv.update(sexto=n(sexto, 1))
json.dump({"bono_combate": val["2 de Ofensiva + Defensa"] / 100, "bono_mineria": vm["3 de Minería"] / 100, "sexto": sexto, "ROL": {k: v[0] for k, v in ROL.items()}}, open("calculos/_b5.json", "w"))
montar("plantillas/B5.md", "B_Matematico/B5_Mascotas.md", frag, kv)
for k in sorted(kv): print(f"  {k} = {kv[k]}")
