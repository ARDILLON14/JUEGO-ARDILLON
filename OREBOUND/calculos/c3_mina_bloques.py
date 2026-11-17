"""OREBOUND - Código, fase 3 (revisión): minería por bloques al estilo de Minecraft (P3b y P3c).
Ejecutar desde OREBOUND/:  python3 calculos/c3_mina_bloques.py

La cantera deja de tener rocas sueltas: es un volumen de bloques de piedra que se excava. Cada bloque que queda
a la vista se sortea en ese momento: mineral con probabilidad d (rareza con la tabla de B3) o piedra.
Los bloques de mineral son los depósitos de B3 (misma vida, unidades, valor y XP). La piedra no da nada.

Este script calibra d para que el minero de referencia de B3 (zona 1, nivel 50, Minería 18, pico Raro)
siga ganando lo que fija B6 (5.152 monedas/h, aceptable 3.864-6.441) con una forma realista de excavar:
  1. Si hay un mineral a la vista y a su alcance (2,5 bloques), lo pica.
  2. Si no, baja por un pozo de 1x1 hasta una profundidad al azar (6-30 bloques).
  3. Después abre un túnel de 1x2 en línea recta (8-20 bloques) y gira; repite.
  4. Con la mochila llena (60) sube a la superficie, deposita y vuelve a donde estaba.
Los huecos vuelven a ser piedra a los 240 s si el minero no está a menos de 3 bloques (igual que en el juego).
"""
import math, random, statistics

RAR = ["Común", "Poco común", "Raro", "Épico", "Legendario", "Mítico", "Ultra raro"]
P_SIN = [55, 25, 12, 5.5, 2, 0.50, 0]                       # zona 1 (sin Ultra raro), B3
F_VIDA = [6, 9, 14, 22, 35, 55, 90]; F_VALOR = [1, 1.8, 3.2, 6, 12, 25, 60]; F_XP = [1, 1.4, 2, 3, 4.5, 7, 11]
UNIDADES = [4, 4, 3, 3, 2, 2, 1]
ZONA, POT_ZONA, DUREZA, V = 1, 100, 1.0, 10
PICO, HPS, MINERIA = 150, 1.04, 18                          # pico Raro de zona 1, Minería del minero equilibrado a nivel 50
MULT_MIN = 1 + 3 * MINERIA / (MINERIA + 1000)
XP_ACC = 25 + 3.75 * 50 + 0.002 * 50 * 50; K_XP = 0.69     # XP por acción a nivel medio de la zona 1 y escala de B3
W, L, D = 24, 24, 40                                        # tamaño de la cantera en bloques
FACTOR_PIEDRA = 1.0                                         # vida de la piedra = PotZona x dureza x 1 (un golpe con el pico de la zona)
MOCHILA = 60
T_MOVER, T_CAER = 0.3, 0.1                                  # s por bloque andando y cayendo
T_BANCO = 3 + 6 + 3 + 6                                     # subir (3 s), ir al banco, depositar (3 s), volver al pozo
REGEN = 240                                                 # s hasta que un hueco vuelve a ser piedra
OBJETIVO, MIN_OK, MAX_OK = 5152, 3864, 6441

def t_mineral(r):
    golpes = max(3, math.ceil(POT_ZONA * F_VIDA[r] * DUREZA / (PICO * MULT_MIN)))
    return golpes / HPS
T_PIEDRA = max(1, math.ceil(POT_ZONA * DUREZA * FACTOR_PIEDRA / (PICO * MULT_MIN))) / HPS

def simular(d, horas=3.0, semilla=1, mochila=None, escala_valor=1.0, escala_xp=1.0):
    mochila = mochila or MOCHILA
    rng = random.Random(semilla)
    aire, contenido = {}, {}                                 # aire[(x,y,z)] = momento en que se picó                              # contenido[(x,y,z)] = rareza o -1 (piedra) al quedar a la vista
    def dentro(c): return 1 <= c[0] <= W and 1 <= c[1] <= D and 1 <= c[2] <= L
    def vecinos(c):
        x, y, z = c
        return [(x+1,y,z),(x-1,y,z),(x,y+1,z),(x,y-1,z),(x,y,z+1),(x,y,z-1)]
    def destapar(c):
        if dentro(c) and c not in aire and c not in contenido:
            contenido[c] = rng.choices(range(7), weights=P_SIN)[0] if rng.random() < d else -1
    for x in range(1, W + 1):
        for z in range(1, L + 1):
            destapar((x, 1, z))
    t, monedas, xp, menas, bloques, unidades, cargas = 0.0, 0.0, 0.0, 0, 0, 0, 0
    fin = horas * 3600
    def picar(c):
        nonlocal t, monedas, xp, menas, bloques, unidades, cargas
        destapar(c)
        r = contenido.pop(c)
        aire[c] = t; bloques += 1
        if r < 0:
            t += T_PIEDRA
        else:
            t += t_mineral(r); menas += 1
            monedas += V * F_VALOR[r] * escala_valor; xp += K_XP * XP_ACC * F_XP[r] * escala_xp; unidades += UNIDADES[r]
            if unidades >= mochila:
                t += T_BANCO; unidades = 0; cargas += 1
        for v in vecinos(c):
            destapar(v)
    T_NUEVO_POZO = 3 + 8                                   # subir a la superficie (3 s) y andar a otro sitio
    def pozo_nuevo():
        for _ in range(50):
            c = (rng.randint(1, W), 1, rng.randint(1, L))
            if c not in aire:
                return (c[0], 0, c[2])
        return (rng.randint(1, W), 0, rng.randint(1, L))
    pos = pozo_nuevo()
    objetivo, direccion, largo, tramos, en_aire = rng.randint(6, 30), None, 0, 0, 0
    proxima_regen = 10.0
    while t < fin:
        x, y, z = pos
        if t >= proxima_regen:
            proxima_regen = t + 10
            for c in [c for c, cuando in aire.items() if t - cuando >= REGEN and max(abs(c[0]-x), abs(c[1]-y), abs(c[2]-z)) > 3]:
                del aire[c]
                for v in vecinos(c) + [c]:
                    if v in contenido and not any(w in aire or w[1] == 0 for w in vecinos(v)):
                        del contenido[v]
                if any(w in aire or w[1] == 0 for w in vecinos(c)):
                    destapar(c)
        # 1. minerales a la vista y al alcance
        cerca = [c for c, r in contenido.items() if r >= 0 and abs(c[0]-x) <= 2 and abs(c[2]-z) <= 2 and abs(c[1]-y) <= 2
                 and any(v in aire or v[1] == 0 for v in vecinos(c))]
        if cerca:
            picar(min(cerca, key=lambda c: abs(c[0]-x) + abs(c[1]-y) + abs(c[2]-z)))
            continue
        # 2. pozo hacia abajo hasta la profundidad objetivo
        if y < objetivo and y < D:
            abajo = (x, y + 1, z)
            if abajo not in aire:
                picar(abajo)
            pos = abajo; t += T_CAER
            continue
        # 3. túneles de 1x2; tras 2 tramos, o si se pisa zona ya excavada, sube y abre otro pozo
        if direccion is None or largo <= 0:
            if tramos >= 2 or en_aire >= 6:
                t += T_NUEVO_POZO; pos = pozo_nuevo()
                objetivo, direccion, largo, tramos, en_aire = rng.randint(6, 30), None, 0, 0, 0
                continue
            direccion, largo, tramos = rng.choice([(1,0),(-1,0),(0,1),(0,-1)]), rng.randint(8, 20), tramos + 1
        dx, dz = direccion
        sig, cabeza = (x + dx, y, z + dz), (x + dx, y - 1, z + dz)
        if not dentro(sig) or y - 1 < 1:
            direccion = None
            continue
        nuevos = 0
        for c in (sig, cabeza):
            if c not in aire:
                picar(c); nuevos += 1
        en_aire = en_aire + 1 if nuevos == 0 else 0
        pos = sig; t += T_MOVER; largo -= 1
    h = t / 3600
    return dict(monedas=monedas / h, xp=xp / h, menas=menas / h, bloques=bloques / h,
                min_carga=60 * h / max(cargas, 1), piedra_por_mena=(bloques - menas) / max(menas, 1))

if __name__ == "__main__":
    print(f"Tiempo por bloque de piedra: {T_PIEDRA:.2f} s; mineral Común: {t_mineral(0):.2f} s")
    print(f"{'d':>6} {'monedas/h':>10} {'menas/h':>8} {'XP/h':>8} {'bloques/h':>9} {'min/carga':>9} {'piedra/mena':>11}")
    filas = []
    for d in [0.03, 0.04, 0.045, 0.05, 0.055, 0.06, 0.07, 0.08]:
        rs = [simular(d, semilla=s) for s in range(8)]
        m = {k: statistics.mean(r[k] for r in rs) for k in rs[0]}
        filas.append((d, m))
        print(f"{d:>6.3f} {m['monedas']:>10.0f} {m['menas']:>8.0f} {m['xp']:>8.0f} {m['bloques']:>9.0f} {m['min_carga']:>9.2f} {m['piedra_por_mena']:>11.1f}")
    mejor = min(filas, key=lambda f: abs(f[1]["monedas"] - OBJETIVO))
    print(f"Calibración P3b: d = {mejor[0]:.3f}: {mejor[1]['monedas']:.0f} monedas/h (objetivo {OBJETIVO}, aceptable {MIN_OK}-{MAX_OK})")

    # P3c: el usuario pide más minerales. Se sube d a 0,10 y se compensa el valor y la XP de cada mineral
    # para que monedas/h y XP/h sigan en el objetivo; la mochila crece para mantener ~3,5-4 min por carga.
    D_NUEVA = 0.10
    ref = {k: statistics.mean(r[k] for r in [simular(mejor[0], semilla=s) for s in range(6)]) for k in ("monedas", "xp", "menas")}
    sin = [simular(D_NUEVA, semilla=s) for s in range(6)]
    m_sin = {k: statistics.mean(r[k] for r in sin) for k in ("monedas", "xp", "menas", "min_carga")}
    esc_valor = round(OBJETIVO / m_sin["monedas"], 2); esc_xp = round(ref["xp"] / m_sin["xp"], 2)
    unidades_min = MOCHILA / m_sin["min_carga"]
    mochila = int(round(unidades_min * 3.75 / 10) * 10)
    fin = [simular(D_NUEVA, semilla=s, mochila=mochila, escala_valor=esc_valor, escala_xp=esc_xp) for s in range(6)]
    m_fin = {k: statistics.mean(r[k] for r in fin) for k in ("monedas", "xp", "menas", "min_carga")}
    print(f"P3c: d = {D_NUEVA}: {m_sin['menas']:.0f} minerales/h ({m_sin['menas']/ref['menas']:.2f} veces más que con d = {mejor[0]})")
    print(f"     escala de valor {esc_valor}, escala de XP {esc_xp}, mochila {mochila}")
    print(f"     resultado: {m_fin['monedas']:.0f} monedas/h, {m_fin['xp']:.0f} XP/h, {m_fin['min_carga']:.2f} min por carga")
