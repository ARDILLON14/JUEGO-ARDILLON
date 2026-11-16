"""OREBOUND - Etapa 9 (C_Tecnico): limites de frecuencia, validacion de movimiento y tamano de datos.
Ejecutar desde OREBOUND/:  python3 calculos/b9_tecnico.py      Valores [PROVISIONAL]."""
import json, math
def sat(S, M, K=1000): return 1 + M * S / (S + K)
MARGEN = 1.25                                   # tolerancia por latencia y rafagas

print("== 1. Limites de frecuencia a partir de los maximos del diseno ==")
vel_max = sat(5000, 0.8)                         # velocidad de ataque con 5.000 de Velocidad
acc = {
 "Atacar (Daga, la mas rapida)": 2.60 * vel_max * 1.05,     # +5 % de Sed de combate
 "Picar (tope de 2,0 golpes/s)": 2.0,
 "Habilidad (4 ranuras; la mas rapida, tecnica de arma de 5 s)": 1 / 5 + 1 / 5 + 1 / 6 + 1 / 9,
 "Dash (2 cargas; 3 s de recarga por carga)": 1 / 3,
 "Parpadeo (8 s)": 1 / 8, "Ruptura (15 s)": 1 / 15,
 "Bloqueo (pulsar y soltar)": 2.0, "Cambiar postura (5 s)": 1 / 5,
}
for k, v in acc.items():
    print(f"{k:58s} maximo legitimo {v:5.2f}/s -> limite {math.ceil(v * MARGEN * 10) / 10:4.1f}/s, rafaga {max(2, math.ceil(v * MARGEN * 2))}")
tot = sum(acc.values())
print(f"Suma de acciones de combate de un jugador: {tot:.1f}/s; con 20 jugadores: {20*tot:.0f} eventos/s que el servidor debe validar")

print("\n== 2. Validacion de movimiento ==")
ws = 16 * sat(5000, 0.5)
print(f"WalkSpeed maximo: {ws:.2f} (tope de diseno 24)")
for dt in (0.5, 1.0, 2.0):
    andar = 24 * dt; dash = 12 * 2; paso = 18; parp = 12 if dt >= 1.0 else 0
    print(f"Ventana de {dt:.1f} s: andar {andar:.0f} + 2 dash {dash} + Paso de Relampago {paso} + parpadeo {parp} = {andar+dash+paso+parp:.0f} studs; "
          f"con tolerancia del 20 %: {1.2*(andar+dash+paso+parp):.0f}")

print("\n== 3. Tamano estimado del perfil guardado ==")
def b(o): return len(json.dumps(o, separators=(",", ":")))
objeto = {"id": "a1b2c3d4", "t": "Espada", "z": 10, "r": 7, "n": 10, "ran": [1, 1, 1], "desp": True}
mascota = {"id": "a1b2c3d4", "esp": "GuivernoDeCuarzo", "n": 100, "xp": 45936, "fase": 3, "eq": True}
registro = {"t": 1794900000, "c": "armas", "z": 10, "r": 5, "obj": "a1b2c3d4", "a": 37, "b": 82}
partes = {
 "Progreso, estadisticas, monedas y contadores": 600,
 "Equipo (hasta 120 objetos)": 120 * b(objeto),
 "Mascotas (almacen ampliado a 200)": 200 * b(mascota),
 "Minerales y materiales (66 + 40 claves)": 106 * 22,
 "Maestrias (6 armas + 6 Nucleos), Nucleos y Despertar": 12 * 30 + 200,
 "Misiones, contratos, temporada y racha": 1500,
 "Codice y logros (300 entradas como bits)": 400,
 "Registro de cajas (ultimas 200 aperturas)": 200 * b(registro),
 "Recibos de compra (ultimos 100)": 100 * 50,
 "Cosmeticos (hasta 300 identificadores)": 300 * 8,
}
total = 0
for k, v in partes.items():
    total += v; print(f"{k:55s} {v:7,d} bytes")
print(f"{'TOTAL':55s} {total:7,d} bytes = {total/1024:.1f} KB; limite por clave de DataStore 4.194.304 bytes -> uso del {100*total/4194304:.2f} %")

print("\n== 4. Presupuesto de escrituras del DataStore ==")
J = 20; presupuesto = 60 + 10 * J
auto = J * 60 / 300                                # autoguardado cada 5 min
criticas = J * 0.5                                 # compras con Robux, renacer, evolucionar: 0,5 por jugador y minuto como mucho
print(f"Servidor de {J} jugadores: presupuesto {presupuesto} escrituras/min (60 + 10 por jugador; cifra a verificar en la documentacion de Roblox)")
print(f"Autoguardado cada 300 s: {auto:.0f}/min; guardados criticos: {criticas:.0f}/min; entradas y salidas: {J*2/10:.0f}/min -> total {auto+criticas+J*2/10:.0f}/min "
      f"({100*(auto+criticas+J*2/10)/presupuesto:.0f} % del presupuesto)")

print("\n== 5. Replicacion de depositos y enemigos por zona ==")
for nombre, cant, hz, bytes_ in [("Depositos (40-80; solo cambios de estado)", 80, 0.2, 12), ("Enemigos activos (hasta 40; posicion y vida)", 40, 10, 16),
                                 ("Mascotas (hasta 60; posicion)", 60, 5, 10), ("Barras de vida de depositos en uso (20)", 20, 4, 6)]:
    print(f"{nombre:48s} {cant*hz*bytes_/1024:6.1f} KB/s")
