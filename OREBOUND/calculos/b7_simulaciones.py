"""OREBOUND - Etapa 7 (B7): simulaciones de cierre del Documento B.
Ejecutar desde OREBOUND/:  python3 calculos/b7_simulaciones.py [carpeta_fragmentos_md]
Reune las formulas finales de B1-B6. Valores [PROVISIONAL]."""
import math, random, sys, os

# ===================== Formulas finales (B1-B6) =====================
G = 1.65
RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro", "Celestial"]
MULT = [1.00, 1.15, 1.32, 1.52, 1.75, 1.98, 2.20, 2.60]
VEL_PICO = [1.00, 1.02, 1.04, 1.06, 1.08, 1.10, 1.12, 1.15]
P_UR = [55, 25, 12, 5.5, 2, 0.45, 0.05]; P_SIN = [55, 25, 12, 5.5, 2, 0.50, 0.0]; CON_UR = {3, 5, 7, 8, 9, 10}
EXP_SUERTE = [0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.0]
F_VIDA_DEP = [6, 9, 14, 22, 35, 55, 90]; F_VALOR = [1, 1.8, 3.2, 6, 12, 25, 60]; F_XP_DEP = [1, 1.4, 2, 3, 4.5, 7, 11]
UNIDADES = [4, 4, 3, 3, 2, 2, 1]; F_REQ = [1, 1, 1.5, 2.5, 3.5, 5, 7]
ENE = {"Común": (20, 0.03, 1.5, 1, 1.35), "Élite": (80, 0.06, 1.8, 3.5, 5.4), "Guardián": (300, 0.10, 2.2, 10, 16), "Jefe": (1500, 0.15, 2.5, 60, 60)}
MIX = {"Común": 0.88, "Élite": 0.10, "Guardián": 0.02}
H_EQUIPO = [0.3, 0.6, 1.2, 2.5, 5, 10, 20]
ZMAX_REQ, DUREZA_MAX = 10, 2.0                       # topes nuevos de la Etapa 7 para zonas > 10
def zona_de(L): return max(1, L // 100 + 1)
def pot_zona(z): return 100 * G ** (z - 1)
def V(z): return 10 * G ** (z - 1)
def dureza(z, tope=True): return min(DUREZA_MAX, 1 + 0.1 * (z - 1)) if tope else 1 + 0.1 * (z - 1)
def vida_base(L): return 500 * G ** ((L - 1) / 100)
def sat(S, M=3.0, K=1000): return 1 + M * S / (S + K)
def xp_sig(L): return math.ceil(100 + 20 * L + 0.8 * L * L) if L <= 1000 else 820100 + 900 * (L - 1000)
def xp_acc(L): return 25 + 3.75 * L + 0.002 * L * L
def puntos(L): return 3 + 3 * (min(L, 1000) - 1) + max(0, L - 1000)        # 1 punto por nivel por encima de 1.000 (Etapa 7)
def req_mineria(z, r, tope=True): return 10 * (min(z, ZMAX_REQ) - 1 if tope else z - 1) * F_REQ[r]
def probs(z): return P_UR if (z in CON_UR or z > 10) else P_SIN
def con_suerte(tabla, S):
    F = sat(S); w = [p * F ** e for p, e in zip(tabla, EXP_SUERTE)]; t = sum(w); return [100 * x / t for x in w]
K_PVP, TOPE_PVP, M_VIT_PVP = 4500, 0.50, 1.0          # Etapa 7 (antes 3000, 0,60 y 1,5)
REGEN_COMBATE = 0.005                                # Etapa 7: 0,5 % de vida maxima por segundo en combate PvE
def red_def(D, pvp=False, k=None, tope=None): return min(D / (D + (k or (K_PVP if pvp else 1500))), tope or (TOPE_PVP if pvp else 0.75))
def I_ref(z): return 479.0 * V(z)
def uso_hab(E): return 0.557 + (0.754 - 0.557) * (E / (E + 1000)) / 0.5
def n(x, d=0): return f"{x:,.{d}f}".replace(",", "X").replace(".", ",").replace("X", ".")
frag = {}
def md(nombre, cab, filas):
    out = ["| " + " | ".join(cab) + " |", "|" + "---|" * len(cab)]
    out += ["| " + " | ".join(str(c) for c in f) + " |" for f in filas]
    frag[nombre] = "\n".join(out); print(f"\n## {nombre}"); print(frag[nombre])

ROL = {"Atacante": 0.030, "Control": 0.018, "Tanque": 0.015, "Apoyo": 0.010, "Recolector": 0.008}
FASE = {"cría": 1.00, "desatada": 1.25, "máxima": 1.50}
class Jugador:
    def __init__(s, nombre, L, pts, arma, pico, mascotas=(), kit=1.0, zona=None, maestria=0, dureza_tope=True):
        s.nombre, s.L, s.z = nombre, L, zona or min(zona_de(L), 10 if L <= 1000 else 99)
        tot = puntos(L); s.st = {k: min(1000, int(tot * f)) for k, f in pts.items()} if all(v <= 1 for v in pts.values()) else dict(pts)
        s.arma, s.pico, s.masc, s.kit, s.maestria, s.dt = arma, pico, list(mascotas), kit, maestria, dureza_tope
        s.regen = REGEN_COMBATE
    def g(s, k): return s.st.get(k, 0)
    def pot_arma(s): z, r, b = s.arma; return pot_zona(z) * MULT[r] * (1 + b)
    def pot_pico(s): z, r, b = s.pico; return pot_zona(z) * MULT[r] * (1 + b)
    def factor_hab(s): return (0.95 + 0.45) if s.kit < 1 else 0.89 * sat(s.g("Vel"), 0.8) + 1.54 * uso_hab(s.g("Ene"))
    def dps_ref(s): return s.pot_arma() * sat(s.g("Fue")) * 1.025 * (1 + 0.001 * s.maestria) * 1.75
    def dps_propio(s): return s.pot_arma() * sat(s.g("Fue")) * 1.025 * (1 + 0.001 * s.maestria) * s.factor_hab()
    def U(s, nivel, fase): return FASE[fase] * (1 + 0.005 * (nivel - 1)) * sat(s.g("Dom"), 1.5)
    def dps_masc(s):
        t = sum(ROL[rol] * MULT[r] * (1 + 0.015 * (nv - 1)) * FASE[f] * sat(s.g("Dom")) * (1 + 0.002 * (nv - 1)) * 1.15 for rol, r, nv, f in s.masc)
        return min(t * s.pot_arma(), 0.40 * s.dps_ref()), t * s.pot_arma()
    def dps(s): return s.dps_propio() + s.dps_masc()[0]
    def util(s):
        d = dict(desvio=0.0, escudo=0.0, cura=0.0, control=0.0, pico=0.0)
        for rol, r, nv, f in s.masc:
            u = s.U(nv, f)
            if rol == "Tanque": d["desvio"] += 0.05 * u; d["escudo"] += 0.02 * u / 20
            if rol == "Apoyo": d["cura"] += 0.0015 * u
            if rol == "Control": d["control"] += 0.08 * u
            d["pico"] += (0.04 if rol == "Recolector" else 0.01) * u
        return dict(desvio=min(.30, d["desvio"]), escudo=d["escudo"], cura=min(.01, d["cura"]), control=min(.25, d["control"]), pico=min(.20, d["pico"]))
    def vida(s, pvp=False): return vida_base(s.L) * sat(s.g("Vit"), M_VIT_PVP if pvp else 3.0)
    def vida_ef(s, pvp=False): return s.vida(pvp) / (1 - red_def(s.g("Def"), pvp))
    def t_enemigo(s, tipo): return pot_zona(s.z) * ENE[tipo][0] * dureza(s.z, s.dt) * (0.5 if s.L < 10 else 1.0) / s.dps()
    def combate(s):
        u = s.util(); tp = sum(MIX[t] * s.t_enemigo(t) for t in MIX); ciclo = tp + 5.0
        dano = sum(MIX[t] * s.t_enemigo(t) * ENE[t][1] / ENE[t][2] for t in MIX) / ciclo * vida_base(100 * (s.z - 1) if s.z > 1 else 1)
        dano = dano * 0.5 * (1 - u["control"]) * (1 - u["desvio"]) * (1 - red_def(s.g("Def"))) / s.vida() - u["escudo"] - u["cura"] - s.regen
        parado = 0.0 if dano <= 0 else 19.0 / (0.7 / dano + 19.0)
        kh = 3600 / ciclo * (1 - parado)
        return dict(kh=kh, parado=parado, mon=kh * sum(MIX[t] * ENE[t][4] for t in MIX) * V(s.z),
                    xp=kh * sum(MIX[t] * ENE[t][3] for t in MIX) * 0.72 * xp_acc(min(s.L, 100 * s.z)))
    def t_deposito(s, r, z=None):
        z = z or s.z; vida = pot_zona(z) * F_VIDA_DEP[r] * dureza(z, s.dt)
        golpes = max(3, math.ceil(vida / (s.pot_pico() * sat(s.g("Min")) * (1 + s.util()["pico"]))))
        return golpes / VEL_PICO[s.pico[1]]
    def mineria(s, z=None, cap=60, suerte=None):
        z = z or s.z; p = [x / 100 for x in con_suerte(probs(z), s.g("Sue") if suerte is None else suerte)]
        ok = [r for r in range(7) if p[r] > 0 and s.g("Min") >= req_mineria(z, r, s.dt)]; pt = sum(p[r] for r in ok)
        if not ok: return dict(dh=0, tm=0, mon=0, tope="Ninguna", xp=0, leg_h=0, p_leg=100 * sum(p[4:]))
        tm = sum(p[r] * s.t_deposito(r, z) for r in ok) / pt; uds = sum(p[r] * UNIDADES[r] for r in ok) / pt
        auto = 1.0 if any(m[0] == "Recolector" for m in s.masc) else 0.0
        dh = 3600 / (tm + 6.0 - auto + 40.0 * uds / cap)
        return dict(dh=dh, tm=tm, mon=dh * sum(p[r] * F_VALOR[r] for r in ok) / pt * V(z), tope=RAR[max(ok)],
                    xp=dh * sum(p[r] * F_XP_DEP[r] for r in ok) / pt * 0.73 * xp_acc(min(s.L, 100 * z)),
                    leg_h=dh * sum(p[r] for r in ok if r >= 4) / pt, p_leg=100 * sum(p[4:]))

# ===================== 1. Jugadores A a G =====================
EQ = {k: 0.125 for k in ("Fue", "Vit", "Def", "Vel", "Ene", "Min", "Sue", "Dom")}
JUG = [
 Jugador("A · nivel 1 · recién llegado", 1, {"Fue": 0.34, "Vit": 0.33, "Min": 0.33}, (1, 0, 0), (1, 0, 0), [("Recolector", 0, 1, "cría")], kit=0.5),
 Jugador("B · nivel 50 · equilibrado", 50, EQ, (1, 2, 0.25), (1, 2, 0.25), [("Atacante", 1, 10, "cría"), ("Recolector", 0, 10, "cría")], maestria=20),
 Jugador("C · nivel 100 · recién llegado a la zona 2", 100, EQ, (1, 2, 0.25), (1, 2, 0.25), [("Atacante", 1, 15, "cría"), ("Tanque", 1, 15, "cría"), ("Recolector", 0, 15, "cría")], maestria=30),
 Jugador("D · nivel 300 · minero", 300, {"Min": 0.50, "Sue": 0.25, "Vit": 0.25}, (4, 2, 0.25), (4, 3, 0.50), [("Recolector", 2, 40, "cría"), ("Recolector", 0, 40, "cría"), ("Tanque", 1, 40, "cría")], maestria=40),
 Jugador("E · nivel 500 · combatiente", 500, {"Fue": 0.40, "Vit": 0.20, "Def": 0.20, "Vel": 0.10, "Ene": 0.10}, (6, 3, 0.50), (6, 2, 0.25), [("Atacante", 3, 50, "desatada"), ("Atacante", 2, 50, "desatada"), ("Tanque", 3, 50, "desatada")], maestria=60),
 Jugador("F · nivel 800 · híbrido de grieta", 800, {"Fue": 0.30, "Vit": 0.25, "Min": 0.25, "Vel": 0.20}, (9, 4, 0.50), (9, 4, 0.50), [("Atacante", 4, 70, "desatada"), ("Recolector", 2, 70, "desatada"), ("Apoyo", 5, 70, "desatada")], maestria=80),
 Jugador("G · nivel 1.000 · final de juego", 1000, {"Fue": 1000, "Vit": 1000, "Dom": 1000}, (10, 6, 1.0), (10, 5, 0.8), [("Atacante", 6, 100, "máxima"), ("Atacante", 4, 100, "máxima"), ("Apoyo", 5, 100, "máxima")], maestria=100)]
PERFIL = ["Arma y pico Comunes sin mejoras; 1 cría", "Equipo Raro +25 %; 2 crías de nivel 10", "Equipo Raro de zona 1 (+25 %); 3 crías de nivel 15",
          "50 % Minería, 25 % Suerte, 25 % Vitalidad; pico Épico +50 %; 2 Recolectores", "40 % Fuerza; arma Épica +50 %; 3 mascotas desatadas",
          "Fuerza, Vitalidad, Minería y Velocidad; equipo Legendario +50 %", "Fuerza, Vitalidad y Dominio a 1.000; arma Ultra rara +100 %; mascotas al máximo"]
md("jug_perfil", ["Jugador", "Zona", "Perfil"], [[j.nombre, j.z, PERFIL[i]] for i, j in enumerate(JUG)])
f1, f2, f3 = [], [], []
for j in JUG:
    c, m = j.combate(), j.mineria(); mejor = max(c["mon"], m["mon"]); xp = max(c["xp"], m["xp"])
    capd, bruto = j.dps_masc()
    f1.append([j.nombre[0], n(j.t_enemigo("Común"), 1), n(j.t_enemigo("Élite"), 1), n(j.t_enemigo("Guardián"), 1), n(j.t_enemigo("Jefe") / 60, 1),
               n(j.t_deposito(0), 1) if j.g("Min") >= req_mineria(j.z, 0) else "No puede", n(j.t_deposito(2), 1) if j.g("Min") >= req_mineria(j.z, 2) else "No puede", n(j.t_deposito(4), 1) if j.g("Min") >= req_mineria(j.z, 4) else "No puede"])
    sig_a, sig_p = min(j.arma[1] + 1, 6), min(j.pico[1] + 1, 6)
    f2.append([j.nombre[0], n(c["mon"]), n(m["mon"]) if m["mon"] else "No puede", n(c["mon"] / m["mon"], 2) if m["mon"] else "—", n(H_EQUIPO[sig_a] * I_ref(j.z) / (0.8 * mejor), 1) + f" h ({RAR[sig_a]})",
               n(H_EQUIPO[sig_p] * I_ref(j.z) / (0.8 * mejor), 1) + f" h ({RAR[sig_p]})", n(60 * xp_sig(j.L) / xp, 1)])
    u = j.util()
    f3.append([j.nombre[0], n(100 * bruto / j.dps_ref(), 1) + " %", n(100 * capd / j.dps_ref(), 1) + " %", n(100 * u["pico"], 1) + " %",
               n(100 * u["desvio"], 1) + " %", n(100 * u["cura"], 2) + " %", n(100 * c["parado"], 1) + " %", m["tope"], n(m["p_leg"], 2) + " %", n(m["leg_h"], 1)])
md("jug_tiempos", ["Jugador", "Enemigo Común (s)", "Élite (s)", "Guardián (s)", "Jefe en solitario (min)", "Depósito Común (s)", "Depósito Raro (s)", "Depósito Legendario (s)"], f1)
md("jug_economia", ["Jugador", "Monedas/hora combatiendo", "Monedas/hora minando", "Combate / minería", "Horas para el arma siguiente", "Horas para el pico siguiente", "Minutos para subir de nivel"], f2)
md("jug_mascotas", ["Jugador", "DPS de mascotas sin tope", "DPS de mascotas contado", "Ayuda al picar", "Daño desviado", "Curación por segundo", "Tiempo parado", "Rareza máxima que pica", "Depósitos Legendario o superior", "Legendario+ por hora"], f3)

# ===================== 2. Builds extremas =====================
def build_todo(k): return {x: (1000 if x == k else 285) for x in EQ}
LEG = (10, 4, 0.5); PETS_STD = [("Atacante", 4, 80, "desatada"), ("Tanque", 4, 80, "desatada"), ("Recolector", 4, 80, "desatada")]
BE = {"Equilibrada (375 en todo)": {x: 375 for x in EQ}, "Todo en Fuerza": build_todo("Fue"), "Todo en Minería": build_todo("Min"), "Todo en Suerte": build_todo("Sue"),
      "Todo en Defensa": build_todo("Def"), "Todo en Dominio": build_todo("Dom"), "Minería + Suerte + Vitalidad": {"Min": 1000, "Sue": 1000, "Vit": 1000},
      "Fuerza + Velocidad + Energía": {"Fue": 1000, "Vel": 1000, "Ene": 1000}}
ref = None; filas = []
for nombre, st in BE.items():
    j = Jugador(nombre, 1000, st, LEG, LEG, PETS_STD, maestria=100); c, m = j.combate(), j.mineria()
    if ref is None: ref = (c["mon"], m["mon"], j.dps())
    filas.append([nombre, n(j.dps() / ref[2], 2), n(j.vida_ef() / vida_base(1000), 2), n(j.vida_ef(True) / vida_base(1000), 2), n(c["mon"]), n(c["mon"] / ref[0], 2),
                  n(m["mon"]), n(m["mon"] / ref[1], 2), n(max(c["mon"], m["mon"]) / max(ref[0], ref[1]), 2), n(m["p_leg"], 2) + " %", n(100 * j.dps_masc()[0] / j.dps_ref(), 1) + " %"])
md("extremas", ["Build (nivel 1.000, equipo Legendario +50 %)", "DPS (× equilibrada)", "Vida efectiva PvE (× base)", "Vida efectiva PvP (× base)", "Monedas/h combate", "× equilibrada",
                "Monedas/h minería", "× equilibrada", "Mejor estilo × equilibrada", "Legendario+ en depósitos", "DPS de mascotas contado"], filas)
filas = []; refg = None
for nombre, r, b in [("Solo Común sin mejoras", 0, 0.0), ("Raro +25 %", 2, 0.25), ("Legendario +50 %", 4, 0.5), ("Ultra raro +100 %", 6, 1.0), ("Celestial +100 %", 7, 1.0)]:
    j = Jugador(nombre, 1000, {x: 375 for x in EQ}, (10, r, b), (10, r, b), PETS_STD, maestria=100); c, m = j.combate(), j.mineria()
    if refg is None: refg = (j.dps(), c["mon"], m["mon"])
    filas.append([nombre, n(j.pot_arma()), n(j.dps() / refg[0], 2), n(j.t_enemigo("Común"), 1), n(j.t_enemigo("Jefe") / 60, 1), n(j.t_deposito(0), 1), n(c["mon"]), n(c["mon"] / refg[1], 2), n(m["mon"]), n(m["mon"] / refg[2], 2)])
md("equipo", ["Equipo (build equilibrada, nivel 1.000)", "Potencia", "DPS (× Común)", "Enemigo Común (s)", "Jefe (min)", "Depósito Común (s)", "Monedas/h combate", "× Común", "Monedas/h minería", "× Común"], filas)
g = Jugador("x", 1000, {x: 375 for x in EQ}, (10, 6, 1.0), (10, 6, 1.0), PETS_STD, maestria=100)
m10, m9 = g.mineria(), g.mineria(z=9)
print(f"Farmear una zona por debajo con equipo Ultra raro: zona 10 = {m10['mon']:,.0f}/h; zona 9 = {m9['mon']:,.0f}/h ({m9['mon']/m10['mon']:.2f})")

# ===================== 3. Golpes en area (Hacha) =====================
def kills_h_area(objetivos, secundario, packs, dps_rel=1.0):
    t_solo = 6.6 / dps_rel; total = 0.0; kills = 0.0
    for tam, prob in packs.items():
        k = min(tam, objetivos); mult = 1 + (k - 1) * secundario
        total += prob * (tam * t_solo / mult + 5.0); kills += prob * tam
    return 3600 * kills / total
PACK_LIBRE = {1: 0.2, 3: 0.3, 5: 0.5}; PACK_NUEVO = {1: 0.70, 2: 0.25, 3: 0.05}; SEC = 0.25
base_k = kills_h_area(1, 0, {1: 1.0})
md("area", ["Caso", "Enemigos/hora", "× un solo objetivo", "× minero equivalente"],
   [[a, n(k), n(k / base_k, 2), n(k / base_k * 1.03, 2)] for a, k in [
     ("Referencia de B4: un objetivo, enemigos sueltos", base_k),
     ("Hacha antes: 5 objetivos al 100 %, grupos de hasta 5", kills_h_area(5, 1.0, PACK_LIBRE, 1.04)),
     ("Lanza antes: 3 objetivos al 100 %, grupos de hasta 5", kills_h_area(3, 1.0, PACK_LIBRE, 0.98)),
     ("Hacha después: secundarios al 25 %, máx. 3; grupos de hasta 3", kills_h_area(3, SEC, PACK_NUEVO, 1.04)),
     ("Lanza después: secundarios al 25 %, máx. 3", kills_h_area(3, SEC, PACK_NUEVO, 0.98)),
     ("Espada después: 2 objetivos, secundario al 25 %", kills_h_area(2, SEC, PACK_NUEVO, 1.0)),
     ("Daga después: un objetivo; grupos de hasta 3", kills_h_area(1, 0, PACK_NUEVO, 1.0))]])

# ===================== 4. PvP: rafaga y Zonas Fracturadas =====================
MULT_PVP = 0.06; ARMA_PVP = pot_zona(10) * MULT[4] * 1.5; VB = vida_base(1000)
BP = {"Cristal": dict(Fue=1000, Vel=1000, Ene=1000), "Tanque": dict(Fue=1000, Vit=1000, Def=1000), "Equilibrada": {x: 375 for x in EQ},
      "Minero": dict(Min=1000, Sue=1000, Vit=1000), "Minero veloz": dict(Min=1000, Vel=1000, Vit=1000)}
def dps_pvp(b, mascotas=True):
    gg = lambda k: b.get(k, 0)
    d = ARMA_PVP * sat(gg("Fue")) * 1.025 * (0.89 * sat(gg("Vel"), 0.8) + 1.54 * uso_hab(gg("Ene"))) * MULT_PVP
    return d * (1.25 if mascotas else 1.0)
def vida_pvp(b, m=None, k=None, tope=None): gg = lambda x: b.get(x, 0); return VB * sat(gg("Vit"), m or M_VIT_PVP) / (1 - red_def(gg("Def"), True, k, tope))
coef_combo = 460 * 1.5 + 900 + 260 + 170
rafaga = ARMA_PVP * sat(1000) * coef_combo / 100 * MULT_PVP
filas = []
for d in ("Cristal", "Minero", "Equilibrada", "Tanque"):
    vida = VB * sat(BP[d].get("Vit", 0), M_VIT_PVP); r = rafaga * (1 - red_def(BP[d].get("Def", 0), True))
    filas.append([d, n(vida), n(r), n(100 * r / vida) + " %", "Muere en un combo" if r >= vida else "Sobrevive", "60 %", "Sobrevive"])
md("rafaga", ["Defensor", "Vida máxima en PvP", "Daño del combo Umbrío (C + V + X + Z, unos 3 s)", "% de la vida", "Sin tope de ráfaga", "Con tope (60 % en 2 s)", "Resultado"], filas)

def huida(carga, vel_min, proteger, d0, raiders=("Cristal", "Tanque"), dt=0.05):
    b = dict(BP["Minero"]); b["Vel"] = vel_min
    vm = 16 * sat(vel_min, 0.5) * (1 - 0.30 * carga ** 1.5)
    vida = vida_pvp(b) / (1 - (0.20 if proteger else 0.0)); x_m = 0.0; pos = [-d0, -d0]; t = 0.0
    vr = [16 * sat(BP[r].get("Vel", 0), 0.5) for r in raiders]; alc = None
    if all(v <= vm for v in vr): return None, None, None, vm
    while vida > 0 and t < 900:
        x_m += vm * dt
        for i, r in enumerate(raiders):
            if x_m - pos[i] > 8: pos[i] += vr[i] * dt
            if x_m - pos[i] <= 8:
                vida -= dps_pvp(BP[r]) * dt
                if alc is None: alc = t
        t += dt
    return alc, t, vm * max(0.0, alc - 3.0), vm
filas = []
for d0, txt in ((60, "Los ve a 60 studs"), (20, "Emboscada a 20 studs")):
    for carga in (0.25, 0.5, 1.0):
        for vel in (0, 1000):
            a, t, dist, vm = huida(carga, vel, False, d0); _, tp, _, _ = huida(carga, vel, True, d0)
            filas.append([txt, f"{int(100*carga)} %", n(vel), n(vm, 1), n(a, 1) + " s", n(dist), n(t, 1) + " s", n(tp, 1) + " s"])
md("huida", ["Situación", "Carga", "Velocidad del minero", "WalkSpeed del minero", "Tiempo hasta el primer golpe", "Distancia máxima a una salida para escapar (studs)",
             "Tiempo hasta morir si no escapa", "Con mascotas en Proteger"], filas)
print(f"Minero que planta cara a 2 saqueadores: muere en {vida_pvp(BP['Minero'])/(dps_pvp(BP['Cristal'])+dps_pvp(BP['Tanque'])):.1f} s; "
      f"le quita al Cristal el {100*dps_pvp(BP['Minero'])*vida_pvp(BP['Minero'])/(dps_pvp(BP['Cristal'])+dps_pvp(BP['Tanque']))/vida_pvp(BP['Cristal']):.0f} % de la vida")

def tres_v_tres(A, Bq, dt=0.1):
    a = [[vida_pvp(BP[x]), dps_pvp(BP[x]), vida_pvp(BP[x])] for x in A]; b = [[vida_pvp(BP[x]), dps_pvp(BP[x]), vida_pvp(BP[x])] for x in Bq]; t = 0.0
    while any(u[0] > 0 for u in a) and any(u[0] > 0 for u in b) and t < 600:
        da = sum(u[1] for u in a if u[0] > 0); db = sum(u[1] for u in b if u[0] > 0)
        ta = min((u for u in b if u[0] > 0), key=lambda u: u[2]); tb = min((u for u in a if u[0] > 0), key=lambda u: u[2])
        ta[0] -= da * dt; tb[0] -= db * dt; t += dt
    va = sum(1 for u in a if u[0] > 0); vb_ = sum(1 for u in b if u[0] > 0)
    resto = sum(max(u[0], 0) for u in (a if va else b)) / sum(u[2] for u in (a if va else b))
    return ("A" if va else "B"), t, max(va, vb_), resto
filas = []
for A, Bq in [(("Cristal",) * 3, ("Tanque",) * 3), (("Equilibrada",) * 3, ("Tanque",) * 3), (("Cristal", "Cristal", "Tanque"), ("Tanque", "Tanque", "Cristal")),
              (("Cristal", "Tanque", "Equilibrada"), ("Equilibrada",) * 3), (("Minero",) * 3, ("Cristal",) * 3), (("Minero", "Minero", "Tanque"), ("Cristal", "Cristal", "Tanque"))]:
    g_, t, viv, resto = tres_v_tres(A, Bq)
    filas.append([" + ".join(A), " + ".join(Bq), "Escuadrón " + g_, n(t, 1) + " s", viv, n(100 * resto) + " %"])
md("tres", ["Escuadrón A", "Escuadrón B", "Gana", "Duración", "Supervivientes", "Vida restante del ganador"], filas)

filas = []
for nombre, mv, k, tp in [("B4: Vitalidad M = 1,5; Defensa K = 3.000, tope 60 %", 1.5, 3000, 0.60), ("Solo Vitalidad M = 1,0", 1.0, 3000, 0.60),
                          ("Solo Defensa K = 4.500, tope 50 %", 1.5, 4500, 0.50), ("Etapa 7: Vitalidad M = 1,0; Defensa K = 4.500, tope 50 %", 1.0, 4500, 0.50)]:
    tc = vida_pvp(BP["Tanque"], mv, k, tp) / dps_pvp(BP["Cristal"]); tt = vida_pvp(BP["Cristal"], mv, k, tp) / dps_pvp(BP["Tanque"])
    te = vida_pvp(BP["Equilibrada"], mv, k, tp) / dps_pvp(BP["Equilibrada"])
    filas.append([nombre, n(tc, 1) + " s", n(tt, 1) + " s", n(tc / tt, 2), n(te, 1) + " s", n(vida_pvp(BP["Tanque"], mv, k, tp) / dps_pvp(BP["Tanque"]), 1) + " s"])
md("tanque", ["Regla PvP", "Cristal mata al Tanque en", "Tanque mata al Cristal en", "Ventaja del Tanque", "Duelo de Equilibradas", "Duelo de Tanques"], filas)
md("defensa_pvp", ["Defensa", "Reducción en PvP", "Daño recibido", "Vida efectiva"],
   [[n(D), n(100 * red_def(D, True), 2) + " %", n(100 * (1 - red_def(D, True)), 2) + " %", "×" + n(1 / (1 - red_def(D, True)), 2)] for D in (10, 100, 500, 1000, 2500, 5000)])

# ----- Saqueador profesional (Monte Carlo) -----
VAL_UD = sum(p / 100 * f for p, f in zip(P_UR, F_VALOR)) / 3.77        # V por unidad
ING_PVE_H = 3600 * (60 / 3.77) * VAL_UD * 3.77 / ((60 / 3.77) * 13 + 40)   # V por hora del minero PvE
def saqueador(horas=4000, busqueda=180.0, recogible=0.70, semilla=7):
    rng = random.Random(semilla); t = 0.0; fin = horas * 3600; carga = 0.0; cobrado = 0.0; racha = 0; kills = muertes = extr = 0; ult = {}
    while t < fin:
        t += rng.expovariate(1 / busqueda); x = rng.random()
        # objetivo: 70 % minero solo, 20 % minero con escuadron, 10 % otro saqueador -> (prob. de matar, prob. de morir, carga de la victima)
        if x < 0.70:   p_mata, p_muere, vic = 0.70, 0.03, rng.uniform(0.1, 1.0) * 120
        elif x < 0.90: p_mata, p_muere, vic = 0.35, 0.45, rng.uniform(0.1, 1.0) * 120
        else:          p_mata, p_muere, vic = 0.50, 0.50, rng.uniform(0.0, 0.6) * 120
        t += 20; y = rng.random()
        if y < p_mata:
            kills += 1; carga = min(120, carga + vic * 0.5 * recogible); t += 13
        elif y < p_mata + p_muere:
            muertes += 1; cobrado += carga * 0.5 * VAL_UD; carga = 0; racha = 0; t += 90
        if carga >= 60:
            t += 61
            if rng.random() < 0.15 and rng.random() < 0.5:
                muertes += 1; cobrado += carga * 0.5 * VAL_UD; carga = 0; racha = 0; t += 90
            else:
                cobrado += carga * VAL_UD * 2.0 * (1 + 0.02 * min(racha, 5)); carga = 0; racha += 1; extr += 1
    return cobrado / horas / ING_PVE_H, kills / horas, muertes / horas, extr / horas
filas = []
for nombre, bus, rec in [("Servidor con pocos mineros (búsqueda de 5 min)", 300, 0.70), ("Servidor normal (3 min)", 180, 0.70), ("Servidor lleno de mineros (1,5 min)", 90, 0.70),
                         ("Servidor normal con 85 % recogible", 180, 0.85)]:
    r, k, m_, e = saqueador(busqueda=bus, recogible=rec)
    filas.append([nombre, n(k, 1), n(m_, 2), n(e, 2), n(r, 2), n(r + 0.10, 2)])
md("saqueador", ["Escenario", "Muertes causadas por hora", "Muertes propias por hora", "Extracciones por hora", "Ingresos (× minero PvE)", "Con contratos (× minero PvE)"], filas)
kn = saqueador()[1]; T_ZF = (120 / 3.77) * 13 + 53
def minero_grieta(p):
    br = sum(p * (1 - p) ** k * 0.02 * min(k, 5) for k in range(200)); C = 120 * VAL_UD
    return ((1 - p) * C * 2 * (1 + br) + p * 0.6 * C * 0.5) / ((1 - p) * T_ZF + p * (0.6 * T_ZF + 30)) * 3600 / ING_PVE_H
filas = []
for rs, ms in [(1, 10), (2, 10), (3, 10), (5, 10), (10, 10)]:
    tasa = kn * 0.7 * rs / ms / 3600; p = 1 - math.exp(-tasa * T_ZF)
    filas.append([f"{rs} por cada {ms}", n(100 * p, 1) + " %", n(minero_grieta(p), 2), n(minero_grieta(p) + 0.10, 2)])
md("presion", ["Saqueadores por mineros", "Prob. de morir por viaje", "Minero de grieta (× PvE)", "Con contratos"], filas)
C = 1.0
print(f"Traspaso entre cuentas: extraer = 2,00; dejarse matar por un complice = {0.5 + 0.5*0.7*2:.2f}; con seguro = {0.5 + 0.5*0.7*2 + 0.25:.2f}")

# ===================== 5. Mas alla de 1.000 =====================
filas = []; f_req = []
for L in (1000, 1100, 1200, 1500, 2000):
    z = zona_de(L) if L > 1000 else 10
    pt = puntos(L); st = {x: min(1000, pt // 8) for x in EQ}
    res = {}
    for tope in (False, True):
        j = Jugador("x", L, st, (z, 2, 0.25), (z, 2, 0.25), PETS_STD, zona=z, maestria=100, dureza_tope=tope)
        res[tope] = (j.t_deposito(0), j.t_enemigo("Común"), j.mineria()["tope"], j.combate()["mon"], j.combate()["xp"])
    jt = res[True]
    filas.append([n(L), z, f"{pot_zona(z):.3g}".replace(".", ",").replace("e+0", " × 10^"), f"{pot_zona(z)*1500*dureza(z):.3g}".replace(".", ",").replace("e+", " × 10^"),
                  n(vida_base(L)), n(xp_sig(L)), n(60 * xp_sig(L) / jt[4], 1), n(jt[3]), n(res[False][0], 1), n(jt[0], 1), n(res[False][1], 1), n(jt[1], 1)])
    f_req.append([n(L), z, n(pt), pt // 1000 if pt < 8000 else 8, n(3 + 3 * (L - 1)), min(8, (3 + 3 * (L - 1)) // 1000), n(req_mineria(z, 6, False)), n(req_mineria(z, 6, True)), res[False][2], res[True][2]])
md("mas_alla", ["Nivel", "Zona", "Potencia de zona", "Vida del jefe", "Vida base del jugador", "XP para el siguiente nivel", "Minutos por nivel", "Monedas/hora", "Depósito Común sin tope de dureza (s)",
                "Con tope (s)", "Enemigo Común sin tope (s)", "Con tope (s)"], filas)
md("mas_alla_req", ["Nivel", "Zona", "Puntos (1 por nivel desde 1.001)", "Estadísticas al máximo", "Puntos si siguieran a 3 por nivel", "Estadísticas al máximo", "Minería para Ultra raro sin tope", "Con tope", "Rareza máxima (equilibrada) sin tope", "Con tope"], f_req)
acum = sum(I_ref(zona_de(L)) * xp_sig(L) / (240 * xp_acc(L)) for L in range(1, 2000))
print(f"Monedas ganadas en total hasta nivel 2.000: {acum:.3e}; vida del jefe de zona 21 con 8 jugadores: {pot_zona(21)*1500*2.0*5.2:.3e}; limite exacto {2**53:.3e}")

if len(sys.argv) > 1:
    os.makedirs(sys.argv[1], exist_ok=True)
    for k, v in frag.items(): open(os.path.join(sys.argv[1], k + ".md"), "w", encoding="utf-8").write(v)

# ===================== 6. Comprobacion: dano maximo real frente al teorico =====================
comun = Jugador("c", 1000, {x: 375 for x in EQ}, (10, 0, 0.0), (10, 0, 0.0), PETS_STD, maestria=100)
print(f"DPS de G frente a un equilibrado con equipo Comun: x{JUG[-1].dps()/comun.dps():.2f} (maximo teorico de B4: x36,4)")
