"""Etapa de código, fase 1. Ejecutar desde OREBOUND/:  python3 calculos/c1_exportar_luau.py
Exporta a Luau lo que el juego y sus pruebas necesitan de los CSV de calculos/:
  ../src/shared/Config/Catalogo/Minerales.luau   catálogo de 66 minerales (lo usa Config/Mining)
  ../tests/Vectores/*.luau                       valores de referencia para las pruebas de fórmulas
Los CSV salen de b2..b6; si cambian, se vuelve a ejecutar este script."""
import csv, os, unicodedata

RAR = {"Común": "Common", "Poco común": "Uncommon", "Raro": "Rare", "Épico": "Epic", "Legendario": "Legendary",
       "Mítico": "Mythic", "Ultra raro": "UltraRare", "Celestial": "Celestial"}
TIPO = {"Espada": "Sword", "Hacha": "Axe", "Daga": "Dagger", "Lanza": "Spear", "Bastón": "Staff", "Arco": "Bow"}
MATERIAL = {"Lingote": "Ingot", "Placa": "Plate", "Gema": "CutGem", "Núcleo": "OreCore", "Catalizador": "Catalyst", "Esencia": "Essence"}
AVISO = "-- GENERADO por OREBOUND/calculos/c1_exportar_luau.py. No editar a mano: cambiar el CSV y volver a generar.\n"

def leer(nombre):
    with open("calculos/" + nombre, encoding="utf-8") as fh: return list(csv.DictReader(fh))
def ident(texto):
    limpio = "".join(c for c in unicodedata.normalize("NFD", texto) if unicodedata.category(c) != "Mn")
    return "".join(p[:1].upper() + p[1:] for p in limpio.replace("-", " ").split())
def num(x):
    f = float(x); return str(int(f)) if f == int(f) else repr(f)
def escribir(ruta, cabecera, filas):
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    with open(ruta, "w", encoding="utf-8") as fh:
        fh.write(AVISO + cabecera + "\nreturn {\n" + "".join("\t" + f + ",\n" for f in filas) + "}\n")
    print(ruta, len(filas))

minerales = leer("b3_minerales.csv")
ids = [ident(m["mineral"]) for m in minerales]
assert len(set(ids)) == len(ids) == 66
escribir("../src/shared/Config/Catalogo/Minerales.luau", "-- Catálogo de minerales (B3, sección 2). La vida, el valor y la XP no van aquí: se calculan con Formulas/Mineria.\n",
    ['%s = { Name = "%s", Zone = %s, Rarity = "%s", Material = "%s", MaterialName = "%s" }' % (
        i, m["mineral"], m["zona"], RAR[m["rareza"]], MATERIAL[m["material"].split()[0]], m["material"]) for i, m in zip(ids, minerales)])

V = "../tests/Vectores/"
xp = leer("b2_xp_niveles.csv")
escribir(V + "XP.luau", "-- { nivel, XP para el siguiente nivel, XP acumulada }  (b2_xp_niveles.csv)\n",
    ["{ %s, %s, %s }" % (f["nivel"], f["xp_siguiente_nivel"], f["xp_acumulada"]) for f in xp])
escribir(V + "Minerales.luau", "-- Depósitos: valores de b3_minerales.csv\n",
    ['{ Id = "%s", Zone = %s, Rarity = "%s", Health = %s, Value = %s, Units = %s, XP = %s, PickReq = %s, MiningReq = %s, Chance = %s }' % (
        i, m["zona"], RAR[m["rareza"]], num(m["vida"]), num(m["valor_deposito"]), m["unidades"], num(m["xp"]), num(m["pico_requerido"]),
        num(m["mineria_requerida"]), num(m["probabilidad"])) for i, m in zip(ids, minerales)])
escribir(V + "Picos.luau", "-- Picos: valores de b3_picos.csv\n",
    ['{ Zone = %s, Rarity = "%s", Power = %s, PowerMax = %s, HitsPerSecond = %s, Level = %s, Mining = %s }' % (
        p["zona"], RAR[p["rareza"]], num(p["potencia"]), num(p["potencia_maxima"]), num(p["golpes_s"]), p["nivel"], num(p["mineria"])) for p in leer("b3_picos.csv")])
escribir(V + "Armas.luau", "-- Armas: valores de b4_armas.csv\n",
    ['{ Type = "%s", Zone = %s, Rarity = "%s", Power = %s, HitDamage = %s, HitsPerSecond = %s, BaseDPS = %s }' % (
        TIPO[a["tipo"]], a["zona"], RAR[a["rareza"]], num(a["potencia"]), num(a["dano_golpe"]), num(a["golpes_s"]), num(a["dps_base"])) for a in leer("b4_armas.csv")])
escribir(V + "PreciosEquipo.luau", "-- Precios de equipo: valores de b6_precios_equipo.csv\n",
    ['{ Zone = %s, Rarity = "%s", Craft = %s, Levels = %s, Slots = %s, Awaken = %s, Sell = %s }' % (
        e["zona"], RAR[e["rareza"]], e["monedas_fabricar"], e["monedas_niveles_1_10"], e["monedas_3_ranuras"], e["monedas_despertar"], e["venta_al_mercader"]) for e in leer("b6_precios_equipo.csv")])
escribir(V + "PreciosMinerales.luau", "-- Precio de venta por unidad: valores de b6_precios_minerales.csv\n",
    ['{ Id = "%s", Sell = %s, Fractured = %s, FracturedMaxStreak = %s }' % (
        ident(m["mineral"]), num(m["precio_venta_unidad"]), num(m["precio_fracturado_extraido_sin_racha"]), num(m["precio_fracturado_racha_maxima"])) for m in leer("b6_precios_minerales.csv")])
