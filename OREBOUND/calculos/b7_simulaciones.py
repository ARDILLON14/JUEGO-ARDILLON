"""OREBOUND - Etapa 7 (B7), rehecha con el GDD: simulaciones de cierre del Documento B.
Ejecutar desde OREBOUND/:  python3 calculos/b7_simulaciones.py   (despues de b1 a b6)
Genera B_Matematico/B7_Simulaciones.md"""
import math, random, sys, os, json
sys.path.insert(0, os.path.dirname(__file__))
from montar import montar, tabla, n
B2, B3, B4, B5, B6 = (json.load(open(f"calculos/_b{i}.json")) for i in (2, 3, 4, 5, 6))
G, TOPE_BONO = 2.0, 0.5
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro", "Celestial"]
MULT = [1.00, 1.25, 1.50, 1.90, 2.50, 3.30, 4.50, 5.20]; VEL_PICO = [1.00, 1.02, 1.04, 1.06, 1.08, 1.10, 1.12, 1.15]
P_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; P_SIN = [55, 25, 12, 5.5, 2, 0.50, 0.0]; CON_UR = {3, 5, 7, 8, 9, 10}
EXP_S = [0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.0]; F_VD = [6, 9, 14, 22, 35, 55, 90]; F_VAL = [1, 1.8, 3.2, 6, 12, 25, 60]; F_XD = [1, 1.4, 2, 3, 4.5, 7, 11]
UNI = [4, 4, 3, 3, 2, 2, 1]; F_REQ = [1, 1, 1.5, 2.5, 3.5, 5, 7]
FV, FM = B4["F_VIDA"], B4["F_MON"]; FD = {"Común": 0.03, "Élite": 0.06, "Guardián": 0.10, "Jefe": 0.15}; IT = {"Común": 1.5, "Élite": 1.8, "Guardián": 2.2, "Jefe": 2.5}
FX = {"Común": 1, "Élite": 3.5, "Guardián": 10}; MIX = {"Común": 0.88, "Élite": 0.10, "Guardián": 0.02}
H_EQ = B6["H"]; F_HAB = B2["F_HAB"]; HAB_E = {int(k): v - 0.92 for k, v in B2["F_HAB_E"].items()}
K_PVP, TOPE_PVP, M_VIT_PVP, MULT_PVP, REGEN_C = 4500, 0.50, 1.0, B4["MULT_PVP"], 0.005
def zona_de(L): return max(1, L // 100 + 1)
def pot_zona(z): return 100 * G ** (z - 1)
def V(z): return 10 * G ** (z - 1)
def dureza(z, tope=True): return min(2.0, 1 + 0.1 * (z - 1)) if tope else 1 + 0.1 * (z - 1)
def vida_base(L): return 500 * G ** ((L - 1) / 100)
def sat(S, M=3.0): return 1 + M * S / (S + 1000)
def xp_sig(L): return math.ceil(100 + 20 * L + 0.8 * L * L) if L <= 1000 else 820100 + 900 * (L - 1000)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def puntos(L): return 3 + 3 * (min(L, 1000) - 1) + max(0, L - 1000)
def req_min(z, r, tope=True): return 10 * ((min(z, 10) if tope else z) - 1) * F_REQ[r]
def probs(z): return P_UR if (z in CON_UR or z > 10) else P_SIN
def con_suerte(t, S): F = sat(S); w = [p * F ** e for p, e in zip(t, EXP_S)]; s = sum(w); return [100 * x / s for x in w]
def red_def(D, pvp=False): return min(D / (D + (K_PVP if pvp else 1500)), TOPE_PVP if pvp else 0.75)
def hab_dmg(E): return HAB_E[0] + (HAB_E[1000] - HAB_E[0]) * min(1.0, (E / (E + 1000)) / 0.5)
def I_ref(z): return B6["IV"] * V(z)
frag, kv = {}, {}
ROL = B5["ROL"]; FASE = {"cría": 1.00, "desatada": 1.25, "máxima": 1.50}; U_REF = 1.25 * 1.245; PAS_MIN = [5, 6, 8, 10, 15, 18, 22]
class Jugador:
    def __init__(s, nombre, L, pts, arma, pico, masc=(), kit=1.0, zona=None, maestria=0, tope=True, postura="Proteger"):
        s.nombre, s.L, s.z = nombre, L, zona or min(zona_de(L), 10)
        tot = puntos(L); s.st = {k: min(1000, int(tot * f)) for k, f in pts.items()} if all(v <= 1 for v in pts.values()) else dict(pts)
        s.arma, s.pico, s.masc, s.kit, s.maestria, s.dt, s.postura = arma, pico, list(masc), kit, maestria, tope, postura
    def g(s, k): return s.st.get(k, 0)
    def pot_arma(s): z, r, b = s.arma; return pot_zona(z) * MULT[r] * (1 + min(b, TOPE_BONO))
    def pot_pico(s): z, r, b = s.pico; return pot_zona(z) * MULT[r] * (1 + min(b, TOPE_BONO))
    def U(s, nv, f): return FASE[f] * (1 + 0.005 * (nv - 1)) * sat(s.g("Dom"), 1.5) / U_REF
    def util(s):
        d = dict(escudo=0.0, vel_atq=0.0, control=0.0, ext=0.0)
        for rol, r, nv, f in s.masc:
            u = s.U(nv, f); act = f != "cría"
            if rol == "Defensa" and act: d["escudo"] = max(d["escudo"], 0.20 / 30 * u)
            if rol == "Apoyo" and act: d["vel_atq"] = max(d["vel_atq"], 0.15 * 6 / 20 * u)
            if rol == "Control" and act: d["control"] += 0.30 * 2 / 10 * u
            if rol == "Minería": d["ext"] += PAS_MIN[r] / 100 + (0.20 * 10 / 30 * u if act else 0)
        d["control"] = min(0.25, d["control"]); d["ext"] = min(0.40, d["ext"]); return d
    def base_dps(s): return s.pot_arma() * sat(s.g("Fue")) * 1.025 * (1 + 0.001 * s.maestria)
    def dps_ref(s): return s.base_dps() * F_HAB
    def dps_propio(s):
        fh = (0.95 + 2.2 / 6) if s.kit < 1 else 0.92 * sat(s.g("Vel"), 0.8) * (1 + s.util()["vel_atq"]) + hab_dmg(s.g("Ene"))
        return s.base_dps() * fh
    def dps_masc(s, pvp=False):
        post = 1.5 if s.postura == "Proteger" else 0.5
        t = sum(ROL[rol] * MULT[r] * (1 + 0.015 * (nv - 1)) * FASE[f] * sat(s.g("Dom")) * (1 + 0.002 * (nv - 1)) * (1.15 if f != "cría" else 1.0) * post for rol, r, nv, f in s.masc) * s.pot_arma()
        return min(t, (0.25 if pvp else 0.40) * s.dps_ref()), t
    def dps(s): return s.dps_propio() + s.dps_masc()[0]
    def vida(s, pvp=False): return vida_base(s.L) * sat(s.g("Vit"), M_VIT_PVP if pvp else 3.0)
    def vida_ef(s, pvp=False): return s.vida(pvp) / (1 - red_def(s.g("Def"), pvp))
    def t_enemigo(s, t): return pot_zona(s.z) * FV[t] * dureza(s.z, s.dt) * (0.5 if s.L < 10 else 1.0) / s.dps()
    def combate(s):
        u = s.util(); tp = sum(MIX[t] * s.t_enemigo(t) for t in MIX); cic = tp + 5.0
        dano = sum(MIX[t] * s.t_enemigo(t) * FD[t] / IT[t] for t in MIX) / cic * vida_base(max(1, 100 * (s.z - 1)))
        dano = dano * 0.5 * (1 - u["control"]) * (1 - red_def(s.g("Def"))) / s.vida(); neto = dano - min(u["escudo"], 0.6 * dano) - REGEN_C
        parado = 0.0 if neto <= 0 else 19.0 / (0.7 / neto + 19.0); kh = 3600 / cic * (1 - parado)
        return dict(kh=kh, parado=parado, mon=kh * sum(MIX[t] * FM[t] for t in MIX) * V(s.z), xp=kh * sum(MIX[t] * FX[t] for t in MIX) * B4["K_XP"] * xp_acc(min(s.L, 100 * s.z)))
    def t_dep(s, r, z=None):
        z = z or s.z; golpes = max(3, math.ceil(pot_zona(z) * F_VD[r] * dureza(z, s.dt) / (s.pot_pico() * sat(s.g("Min")))))
        return golpes / (VEL_PICO[s.pico[1]] * (1 + s.util()["ext"]))
    def mineria(s, z=None, suerte=None):
        z = z or s.z; p = [x / 100 for x in con_suerte(probs(z), s.g("Sue") if suerte is None else suerte)]
        ok = [r for r in range(7) if p[r] > 0 and s.g("Min") >= req_min(z, r, s.dt)]; pt = sum(p[r] for r in ok)
        if not ok: return dict(dh=0, mon=0, tope="Ninguna", xp=0, leg_h=0, p_leg=100 * sum(p[4:]))
        tm = sum(p[r] * s.t_dep(r, z) for r in ok) / pt; uds = sum(p[r] * UNI[r] for r in ok) / pt
        dh = 3600 / (tm + 6.0 - (1.0 if s.masc else 0) + 40.0 * uds / 60)
        return dict(dh=dh, mon=dh * sum(p[r] * F_VAL[r] for r in ok) / pt * V(z), tope=RAR[max(ok)], xp=dh * sum(p[r] * F_XD[r] for r in ok) / pt * B3["K_XP"] * xp_acc(min(s.L, 100 * z)),
                    leg_h=dh * sum(p[r] for r in ok if r >= 4) / pt, p_leg=100 * sum(p[4:]))

# ===================== 1. Jugadores A a G =====================
EQ = {k: 0.125 for k in ("Fue", "Vit", "Def", "Vel", "Ene", "Min", "Sue", "Dom")}
JUG = [
 Jugador("A · nivel 1 · recién llegado", 1, {"Fue": 0.34, "Vit": 0.33, "Min": 0.33}, (1, 0, 0), (1, 0, 0), [("Minería", 0, 1, "cría")], kit=0.5),
 Jugador("B · nivel 50 · equilibrado", 50, EQ, (1, 2, 0.125), (1, 2, 0.125), [("Ofensiva", 1, 10, "cría"), ("Minería", 0, 10, "cría")], maestria=20),
 Jugador("C · nivel 100 · recién llegado a la zona 2", 100, EQ, (1, 2, 0.125), (1, 2, 0.125), [("Ofensiva", 1, 15, "cría"), ("Defensa", 1, 15, "cría"), ("Minería", 0, 15, "cría")], maestria=30),
 Jugador("D · nivel 300 · minero", 300, {"Min": 0.50, "Sue": 0.25, "Vit": 0.25}, (4, 2, 0.125), (4, 3, 0.25), [("Minería", 2, 40, "cría"), ("Minería", 0, 40, "cría"), ("Defensa", 1, 40, "cría")], maestria=40, postura="Recolectar"),
 Jugador("E · nivel 500 · combatiente", 500, {"Fue": 0.40, "Vit": 0.20, "Def": 0.20, "Vel": 0.10, "Ene": 0.10}, (6, 3, 0.25), (6, 2, 0.125), [("Ofensiva", 3, 50, "desatada"), ("Ofensiva", 2, 50, "desatada"), ("Defensa", 3, 50, "desatada")], maestria=60),
 Jugador("F · nivel 800 · híbrido de grieta", 800, {"Fue": 0.30, "Vit": 0.25, "Min": 0.25, "Vel": 0.20}, (9, 4, 0.25), (9, 4, 0.25), [("Ofensiva", 4, 70, "desatada"), ("Minería", 2, 70, "desatada"), ("Defensa", 4, 70, "desatada")], maestria=80),
 Jugador("G · nivel 1.000 · final de juego", 1000, {"Fue": 1000, "Vit": 1000, "Dom": 1000}, (10, 6, 0.5), (10, 5, 0.4), [("Ofensiva", 6, 100, "máxima"), ("Ofensiva", 4, 100, "máxima"), ("Defensa", 4, 100, "máxima")], maestria=100)]
PERFIL = ["Arma y pico Comunes sin mejoras; 1 cría", "Equipo Raro con la mitad de los bonos; 2 crías de nivel 10", "Equipo Raro de zona 1; 3 crías de nivel 15",
          "50% Minería, 25% Suerte, 25% Vitalidad; pico Épico con la mitad de los bonos; 2 mascotas de Minería", "40% Fuerza; arma Épica con la mitad de los bonos; 3 mascotas desatadas",
          "Fuerza, Vitalidad, Minería y Velocidad; equipo Legendario con la mitad de los bonos", "Fuerza, Vitalidad y Dominio a 1.000; arma Ultra rara al máximo; mascotas al máximo (incluido el Guiverno de Cuarzo)"]
frag["jug_perfil"] = tabla(["Jugador", "Zona", "Perfil"], [[j.nombre, j.z, PERFIL[i]] for i, j in enumerate(JUG)])
f1, f2, f3 = [], [], []; cm = {}; sig = []; par = []
for j in JUG:
    c, m = j.combate(), j.mineria(); mejor = max(c["mon"], m["mon"]); xp = max(c["xp"], m["xp"]); capd, bruto = j.dps_masc(); u = j.util(); L0 = j.nombre[0]
    puede = lambda r: j.g("Min") >= req_min(j.z, r)
    f1.append([L0, n(j.t_enemigo("Común"), 1), n(j.t_enemigo("Élite"), 1), n(j.t_enemigo("Guardián"), 1), n(j.t_enemigo("Jefe") / 60, 1)] + [n(j.t_dep(r), 1) if puede(r) else "No puede" for r in (0, 2, 4)])
    sa, sp = min(j.arma[1] + 1, 6), min(j.pico[1] + 1, 6); ha = H_EQ[sa] * I_ref(j.z) / (0.8 * mejor); hp = H_EQ[sp] * I_ref(j.z) / (0.8 * mejor); sig += [ha, hp]
    if m["mon"]: cm[L0] = m["mon"] / c["mon"]
    f2.append([L0, n(c["mon"]), n(m["mon"]) if m["mon"] else "No puede", n(c["mon"] / m["mon"], 2) if m["mon"] else "—", f"{n(ha, 1)} h ({RAR[sa]})", f"{n(hp, 1)} h ({RAR[sp]})", n(60 * xp_sig(j.L) / xp, 1)])
    par.append(100 * c["parado"])
    f3.append([L0, n(100 * bruto / j.dps_ref(), 1) + "%", n(100 * capd / j.dps_ref(), 1) + "%", n(100 * u["ext"], 1) + "%", "Sí" if u["escudo"] else "No", n(100 * c["parado"], 1) + "%", m["tope"], n(m["p_leg"], 2) + "%", n(m["leg_h"], 1)])
frag["jug_tiempos"] = tabla(["Jugador", "Enemigo Común (s)", "Élite (s)", "Guardián (s)", "Jefe en solitario (min)", "Depósito Común (s)", "Depósito Raro (s)", "Depósito Legendario (s)"], f1)
frag["jug_economia"] = tabla(["Jugador", "Monedas/hora combatiendo", "Monedas/hora minando", "Combate / minería", "Horas para el arma siguiente", "Horas para el pico siguiente", "Minutos para subir de nivel"], f2)
frag["jug_mascotas"] = tabla(["Jugador", "DPS de mascotas sin tope", "DPS de mascotas contado", "Velocidad de extracción añadida", "Escudo de mascota", "Tiempo parado", "Rareza máxima que pica", "Depósitos Legendario o superior", "Legendario+ por hora"], f3)
gj = JUG[-1]
kv.update(a_ttk=f1[0][1], c_ttk=f1[2][1], c_jefe=f1[2][4], g_jefe=f1[6][4], sig_min=n(min(sig), 1), sig_max=n(max(sig), 1), cm_a=n(cm["A"], 2), cm_b=n(cm["B"], 2), cm_c=n(cm["C"], 2),
          cm_f=n(1 / cm["F"], 2), g_masc=n(100 * gj.dps_masc()[0] / gj.dps_ref(), 1), g_bruto=n(100 * gj.dps_masc()[1] / gj.dps_ref()), par_max=n(max(par), 1), d_leg=f3[3][7], d_legh=f3[3][8])

# ===================== 2. Builds extremas y equipo =====================
def todo(k): return {x: (1000 if x == k else 285) for x in EQ}
LEG = (10, 4, 0.5); PETS = [("Ofensiva", 4, 80, "desatada"), ("Defensa", 4, 80, "desatada"), ("Minería", 4, 80, "desatada")]
BE = {"Equilibrada (375 en todo)": {x: 375 for x in EQ}, "Todo en Fuerza": todo("Fue"), "Todo en Minería": todo("Min"), "Todo en Suerte": todo("Sue"), "Todo en Defensa": todo("Def"),
      "Todo en Dominio": todo("Dom"), "Minería + Suerte + Vitalidad": {"Min": 1000, "Sue": 1000, "Vit": 1000}, "Fuerza + Velocidad + Energía": {"Fue": 1000, "Vel": 1000, "Ene": 1000}}
ref = None; filas = []; mejores = {}
for nom, st in BE.items():
    j = Jugador(nom, 1000, st, LEG, LEG, PETS, maestria=100); c = j.combate(); j2 = Jugador(nom, 1000, st, LEG, LEG, PETS, maestria=100, postura="Recolectar"); m = j2.mineria()
    if ref is None: ref = (c["mon"], m["mon"], j.dps())
    mejores[nom] = max(c["mon"], m["mon"]) / max(ref[0], ref[1])
    filas.append([nom, n(j.dps() / ref[2], 2), n(j.vida_ef() / vida_base(1000), 2), n(j.vida_ef(True) / vida_base(1000), 2), n(c["mon"]), n(c["mon"] / ref[0], 2), n(m["mon"]), n(m["mon"] / ref[1], 2) if m["mon"] else "—",
                  n(mejores[nom], 2), n(m["p_leg"], 2) + "%", n(100 * j.dps_masc()[0] / j.dps_ref(), 1) + "%"])
frag["extremas"] = tabla(["Build (nivel 1.000, equipo Legendario al máximo)", "DPS (× equilibrada)", "Vida efectiva PvE (× base)", "Vida efectiva PvP (× base)", "Monedas/h combate", "× equilibrada", "Monedas/h minería", "× equilibrada",
                          "Mejor estilo × equilibrada", "Legendario+ en depósitos", "DPS de mascotas contado"], filas)
kv.update(ext_max=n(max(mejores.values()), 2), ext_quien=max(mejores, key=mejores.get), ext_fue=n(mejores["Todo en Fuerza"], 2), ext_min=n(mejores["Todo en Minería"], 2), ext_sue=n(mejores["Todo en Suerte"], 2),
          ext_def=n(mejores["Todo en Defensa"], 2), ext_dom=n(mejores["Todo en Dominio"], 2), ext_msv=n(mejores["Minería + Suerte + Vitalidad"], 2))
filas = []; rg = None; eqv = {}
for nom, r, b in [("Solo Común sin mejoras", 0, 0.0), ("Raro con la mitad de los bonos", 2, 0.25), ("Legendario al máximo", 4, 0.5), ("Ultra raro al máximo", 6, 0.5), ("Celestial al máximo", 7, 0.5)]:
    j = Jugador(nom, 1000, {x: 375 for x in EQ}, (10, r, b), (10, r, b), PETS, maestria=100); c = j.combate(); m = Jugador(nom, 1000, {x: 375 for x in EQ}, (10, r, b), (10, r, b), PETS, maestria=100, postura="Recolectar").mineria()
    if rg is None: rg = (j.dps(), c["mon"], m["mon"])
    eqv[nom] = (c["mon"], m["mon"], j.dps() / rg[0])
    filas.append([nom, n(j.pot_arma()), n(j.dps() / rg[0], 2), n(j.t_enemigo("Común"), 1), n(j.t_enemigo("Jefe") / 60, 1), n(j.t_dep(0), 1), n(c["mon"]), n(c["mon"] / rg[1], 2), n(m["mon"]), n(m["mon"] / rg[2], 2)])
frag["equipo"] = tabla(["Equipo (build equilibrada, nivel 1.000)", "Potencia", "DPS (× Común)", "Enemigo Común (s)", "Jefe (min)", "Depósito Común (s)", "Monedas/h combate", "× Común", "Monedas/h minería", "× Común"], filas)
u_, c_ = eqv["Ultra raro al máximo"], eqv["Celestial al máximo"]; cc = eqv["Solo Común sin mejoras"]
gz = Jugador("x", 1000, {x: 375 for x in EQ}, (10, 6, 0.5), (10, 6, 0.5), PETS, maestria=100, postura="Recolectar")
kv.update(eq_ur=n(u_[0] / cc[0], 2), eq_cel=n(c_[0] / cc[0], 2), cel_ur=n(100 * (c_[0] / u_[0] - 1), 1), eq_min_ur=n(u_[1] / cc[1], 2), eq_min_cel=n(c_[1] / cc[1], 2), bajar=n(gz.mineria(z=9)["mon"] / gz.mineria()["mon"], 2),
          g_real=n(JUG[-1].dps() / Jugador("c", 1000, {x: 375 for x in EQ}, (10, 0, 0), (10, 0, 0), PETS, maestria=100).dps(), 1))

# ===================== 3. Golpes en area =====================
def kills(obj, sec, packs, rel=1.0):
    ts = 6.6 / rel; tt = 0.0; kk = 0.0
    for tam, pr in packs.items(): k = min(tam, obj); tt += pr * (tam * ts / (1 + (k - 1) * sec) + 5.0); kk += pr * tam
    return 3600 * kk / tt
LIBRE = {1: 0.2, 3: 0.3, 5: 0.5}; NUEVO = {1: 0.70, 2: 0.25, 3: 0.05}; b0 = kills(1, 0, {1: 1.0})
casos = [("Un objetivo, enemigos sueltos (referencia de B4)", b0), ("Hacha sin regla: 5 objetivos al 100%, grupos de hasta 5", kills(5, 1.0, LIBRE, 1.04)),
         ("Hacha con la regla: secundarios al 25%, máx. 3; grupos de hasta 3", kills(3, 0.25, NUEVO, 1.04)), ("Lanza con la regla", kills(3, 0.25, NUEVO, 0.98)),
         ("Espada con la regla (2 objetivos)", kills(2, 0.25, NUEVO, 1.0)), ("Daga (un objetivo)", kills(1, 0, NUEVO, 1.0))]
frag["area"] = tabla(["Caso", "Enemigos/hora", "× un solo objetivo"], [[a, n(k), n(k / b0, 2)] for a, k in casos])
kv.update(area_sin=n(casos[1][1] / b0, 1), area_con=n(casos[2][1] / b0, 2))

# ===================== 4. PvP y Zonas Fracturadas =====================
ARMA = pot_zona(10) * MULT[4] * 1.5; VB = vida_base(1000)
BP = {"Cristal": dict(Fue=1000, Vel=1000, Ene=1000), "Tanque": dict(Fue=1000, Vit=1000, Def=1000), "Equilibrada": {x: 375 for x in EQ}, "Minero": dict(Min=1000, Sue=1000, Vit=1000)}
def dps_pvp(b): g_ = lambda k: b.get(k, 0); return ARMA * sat(g_("Fue")) * 1.025 * (0.92 * sat(g_("Vel"), 0.8) + hab_dmg(g_("Ene"))) * MULT_PVP * 1.25
def vida_pvp(b): g_ = lambda k: b.get(k, 0); return VB * sat(g_("Vit"), M_VIT_PVP) / (1 - red_def(g_("Def"), True))
combo = ARMA * sat(1000) * (2.0 * 1.5 * 1.3 + 6.0 + 1.3 + 1.2) * MULT_PVP
filas = []
for d in ("Cristal", "Minero", "Equilibrada", "Tanque"):
    v = VB * sat(BP[d].get("Vit", 0), M_VIT_PVP); r = combo * (1 - red_def(BP[d].get("Def", 0), True))
    filas.append([d, n(v), n(r), n(100 * r / v) + "%", n(min(100 * r / v, 60)) + "%"])
frag["rafaga"] = tabla(["Defensor", "Vida máxima en PvP", "Daño del combo Umbrío (Manto + Tajo + Eclipse + Paso)", "% de la vida sin tope", "Con el tope de ráfaga (en 2 s)"], filas)
kv.update(raf_cristal=filas[0][3])
def lento(c): return min(0.40, 0.12 * math.log(1 + c))
def huida(carga, vel, escudo, d0, raiders=("Cristal", "Tanque"), dt=0.05):
    b = dict(BP["Minero"]); b["Vel"] = vel; vm = 16 * sat(vel, 0.5) * (1 - lento(carga)); vida = vida_pvp(b) * (1.2 if escudo else 1.0)
    x = 0.0; pos = [-d0, -d0]; t = 0.0; vr = [16 * sat(BP[r].get("Vel", 0), 0.5) for r in raiders]; alc = None
    if all(v <= vm for v in vr): return None, None, None, vm
    while vida > 0 and t < 900:
        x += vm * dt
        for i, r in enumerate(raiders):
            if x - pos[i] > 8: pos[i] += vr[i] * dt
            if x - pos[i] <= 8:
                vida -= dps_pvp(BP[r]) * dt
                if alc is None: alc = t
        t += dt
    return alc, t, vm * max(0.0, alc - 3.0) + 24, vm
filas = []
for d0, txt in ((60, "Los ve a 60 studs"), (20, "Emboscada a 20 studs")):
    for carga in (1, 5, 12, 30):
        for vel in (0, 1000):
            a, t, dist, vm = huida(carga, vel, False, d0)
            if a is None: filas.append([txt, carga, n(100 * lento(carga)) + "%", n(vel), n(vm, 1), "No lo alcanzan", "Cualquiera", "—", "—"]); continue
            _, tp, _, _ = huida(carga, vel, True, d0)
            filas.append([txt, carga, n(100 * lento(carga)) + "%", n(vel), n(vm, 1), n(a, 1) + " s", n(dist), n(t, 1) + " s", n(tp, 1) + " s"])
frag["huida"] = tabla(["Situación", "Carga", "Ralentización", "Velocidad del minero", "WalkSpeed", "Tiempo hasta el primer golpe", "Distancia máxima a una salida para escapar (studs)", "Tiempo hasta caer si no escapa", "Con Escudo Facetado"], filas)
cara = vida_pvp(BP["Minero"]) / (dps_pvp(BP["Cristal"]) + dps_pvp(BP["Tanque"]))
kv.update(cara=n(cara, 1), kael=n(100 * lento(12)), kael16=n(100 * lento(16)))
def tres(A, Bq, dt=0.1):
    a = [[vida_pvp(BP[x]), dps_pvp(BP[x]), vida_pvp(BP[x])] for x in A]; b = [[vida_pvp(BP[x]), dps_pvp(BP[x]), vida_pvp(BP[x])] for x in Bq]; t = 0.0
    while any(u[0] > 0 for u in a) and any(u[0] > 0 for u in b) and t < 600:
        da = sum(u[1] for u in a if u[0] > 0); db = sum(u[1] for u in b if u[0] > 0)
        ta = min((u for u in b if u[0] > 0), key=lambda u: u[2]); tb = min((u for u in a if u[0] > 0), key=lambda u: u[2]); ta[0] -= da * dt; tb[0] -= db * dt; t += dt
    va = sum(1 for u in a if u[0] > 0); vb_ = sum(1 for u in b if u[0] > 0); gan = a if va else b
    return ("A" if va else "B"), t, max(va, vb_), sum(max(u[0], 0) for u in gan) / sum(u[2] for u in gan)
filas = []; dur = []
for A, Bq in [(("Cristal",) * 3, ("Tanque",) * 3), (("Equilibrada",) * 3, ("Tanque",) * 3), (("Cristal", "Cristal", "Tanque"), ("Tanque", "Tanque", "Cristal")), (("Cristal", "Tanque", "Equilibrada"), ("Equilibrada",) * 3),
              (("Minero",) * 3, ("Cristal",) * 3), (("Minero", "Minero", "Tanque"), ("Cristal", "Cristal", "Tanque"))]:
    g_, t, viv, resto = tres(A, Bq); dur.append(t); filas.append([" + ".join(A), " + ".join(Bq), "Escuadrón " + g_, n(t, 1) + " s", viv, n(100 * resto) + "%"])
frag["tres"] = tabla(["Escuadrón A", "Escuadrón B", "Gana", "Duración", "Supervivientes", "Vida restante del ganador"], filas)
tc = vida_pvp(BP["Tanque"]) / dps_pvp(BP["Cristal"]); tt = vida_pvp(BP["Cristal"]) / dps_pvp(BP["Tanque"])
kv.update(tres_min=n(min(dur)), tres_max=n(max(dur)), ventaja=n(tc / tt, 2), mult_pvp=n(MULT_PVP, 3))
# Saqueador (Monte Carlo)
MULT_F, RECOGE = B3["MULT_F"], B3["RECOGE"]; UDS, VAL_DEP = B3["uds"], B3["VAL_DEP"]; VAL_UD = VAL_DEP / UDS
ING_PVE_H = 3600 * (60 / UDS) * VAL_DEP / B3["T_PVE"]; T_ZF = B3["T_ZF"]
def saqueador(horas=4000, busca=180.0, rec=RECOGE, semilla=7):
    rng = random.Random(semilla); t = 0.0; fin = horas * 3600; carga = 0.0; cob = 0.0; racha = 0; ki = mu = ex = 0
    while t < fin:
        t += rng.expovariate(1 / busca); x = rng.random()
        if x < 0.70: pm_, pd_, vic = 0.70, 0.03, rng.uniform(0.1, 1.0) * 120
        elif x < 0.90: pm_, pd_, vic = 0.35, 0.45, rng.uniform(0.1, 1.0) * 120
        else: pm_, pd_, vic = 0.50, 0.50, rng.uniform(0.0, 0.6) * 120
        t += 20; y = rng.random()
        if y < pm_: ki += 1; carga = min(120, carga + vic * 0.5 * rec); t += 13
        elif y < pm_ + pd_: mu += 1; cob += carga * 0.5 * VAL_UD; carga = 0; racha = 0; t += 90
        if carga >= 60:
            t += 61
            if rng.random() < 0.075: mu += 1; cob += carga * 0.5 * VAL_UD; carga = 0; racha = 0; t += 90
            else: cob += carga * VAL_UD * MULT_F * min(1 + 0.1 * racha, 1.5); carga = 0; racha += 1; ex += 1
    return cob / horas / ING_PVE_H, ki / horas, mu / horas, ex / horas
filas = []; sq = {}
for nom, bus, rec in [("Servidor con pocos mineros (búsqueda de 5 min)", 300, RECOGE), ("Servidor normal (3 min)", 180, RECOGE), ("Servidor lleno de mineros (1,5 min)", 90, RECOGE), ("Servidor normal con todo recogible (recompensa por cabeza)", 180, 1.0)]:
    r, k, m_, e = saqueador(busca=bus, rec=rec); sq[nom] = r + 0.10; filas.append([nom, n(k, 1), n(m_, 2), n(e, 2), n(r, 2), n(r + 0.10, 2)])
frag["saqueador"] = tabla(["Escenario", "Derrotas causadas por hora", "Derrotas propias por hora", "Extracciones por hora", "Ingresos (× minero PvE)", "Con contratos (× minero PvE)"], filas)
sv = list(sq.values()); kn = saqueador()[1]
def racha_media(p): return 1.5 if p == 0 else sum(p * (1 - p) ** k * min(1 + 0.1 * k, 1.5) for k in range(400))
def grieta(p): return ((1 - p) * MULT_F * racha_media(p) + p * 0.6 * 0.5) / ((1 - p) * T_ZF + p * (0.6 * T_ZF + 30)) * B3["T_PVE"] / (60 / UDS) * (120 / UDS)
filas = []; pr = {}
for rs in (1, 2, 3, 5, 10):
    p = 1 - math.exp(-kn * 0.7 * rs / 10 / 3600 * T_ZF); pr[rs] = (p, grieta(p) + 0.10); filas.append([f"{rs} por cada 10", n(100 * p, 1) + "%", n(grieta(p), 2), n(grieta(p) + 0.10, 2)])
frag["presion"] = tabla(["Saqueadores por mineros", "Prob. de caer por viaje", "Minero de grieta (× PvE)", "Con contratos"], filas)
SQN = sq["Servidor normal (3 min)"]
frag["gdd_zonas"] = tabla(["Zona", "Minero PvE (monedas/hora)", "Minero de grieta con 3 saqueadores por cada 10 mineros", "× PvE", "Saqueador profesional", "× PvE"],
    [[z, n(B3["minero_eq"][z-1]), n(B3["minero_eq"][z-1] * pr[3][1]), n(pr[3][1], 2), n(B3["minero_eq"][z-1] * SQN), n(SQN, 2)] for z in (2, 5, 8)])
kv.update(sq_min=n(min(sv[:3]), 2), sq_max=n(max(sv[:3]), 2), sq_norm=n(SQN, 2), sq_cab=n(sv[3], 2), pres10=n(pr[10][1], 2), pres_p2=n(100 * pr[2][0]), pres_p3=n(100 * pr[3][0]),
          comp=n(0.5 + 0.5 * RECOGE * MULT_F, 2), extr=n(MULT_F, 2))

# ===================== 5. Mas alla de 1.000 =====================
filas = []; fr = []
for L in (1000, 1100, 1200, 1500, 2000):
    z = zona_de(L) if L > 1000 else 10; pt = puntos(L); st = {x: min(1000, pt // 8) for x in EQ}; res = {}
    for tp in (False, True):
        j = Jugador("x", L, st, (z, 2, 0.125), (z, 2, 0.125), PETS, zona=z, maestria=100, tope=tp); c = j.combate()
        res[tp] = (j.t_dep(0), j.t_enemigo("Común"), Jugador("x", L, st, (z, 2, 0.125), (z, 2, 0.125), PETS, zona=z, tope=tp, postura="Recolectar").mineria()["tope"], c["mon"], c["xp"])
    filas.append([n(L), z, f"{pot_zona(z):.2e}".replace(".", ",").replace("e+0", " × 10^").replace("e+", " × 10^"), f"{pot_zona(z)*FV['Jefe']*dureza(z):.2e}".replace(".", ",").replace("e+0", " × 10^").replace("e+", " × 10^"),
                  n(xp_sig(L)), n(60 * xp_sig(L) / res[True][4], 1), n(res[True][3]), n(res[False][0], 1), n(res[True][0], 1), n(res[False][1], 1), n(res[True][1], 1)])
    fr.append([n(L), z, n(pt), min(8, pt // 1000), n(3 + 3 * (L - 1)), min(8, (3 + 3 * (L - 1)) // 1000), n(req_min(z, 6, False)), n(req_min(z, 6, True)), res[False][2], res[True][2]])
frag["mas_alla"] = tabla(["Nivel", "Zona", "Potencia de zona", "Vida del jefe", "XP para el siguiente nivel", "Minutos por nivel", "Monedas/hora", "Depósito Común sin tope de dureza (s)", "Con tope (s)", "Enemigo Común sin tope (s)", "Con tope (s)"], filas)
frag["mas_alla_req"] = tabla(["Nivel", "Zona", "Puntos (1 por nivel desde 1.001)", "Estadísticas al máximo", "Puntos si siguieran a 3 por nivel", "Estadísticas al máximo", "Minería para Ultra raro sin tope", "Con tope", "Rareza máxima (equilibrada) sin tope", "Con tope"], fr)
acum = sum(I_ref(zona_de(L)) * xp_sig(L) / (240 * xp_acc(L)) for L in range(1, 2000)); jefe21 = pot_zona(21) * FV["Jefe"] * 2.0 * 5.2
kv.update(acum=f"{acum:.1e}".replace(".", ",").replace("e+", " × 10^"), jefe21=f"{jefe21:.1e}".replace(".", ",").replace("e+", " × 10^"), cabe="Sí" if max(acum, jefe21) < 2 ** 53 else "NO", margen=n(2 ** 53 / max(acum, jefe21)))
montar("plantillas/B7.md", "B_Matematico/B7_Simulaciones.md", frag, kv)
for k in sorted(kv): print(f"  {k} = {kv[k]}")
