# OREBOUND

RPG de minería y acción para Roblox. Proyecto de [Rojo](https://rojo.space/docs) 7.7.1 (gestionado con Rokit).

- **Diseño:** carpeta `OREBOUND/` (`A_GDD.md`, `B_Matematico/`, `C_Tecnico.md`, `D_Roadmap.md`, `DECISIONES.md`).
- **Código:** `src/` (fases 1 y 2 del roadmap: Cimientos y Progresión).
- **Pruebas:** `tests/`.

## Estructura del código

```
src/shared/Config/     13 módulos de datos (cifras de los archivos B). Para ajustar el juego se tocan estos.
src/shared/Formulas/   Fórmulas F1 a F36 como funciones puras.
src/shared/Net/        Definición de los 46 Remotes y validador de esquemas.
src/shared/Reglas/     Reglas puras sobre el perfil: puntos, reinicio, valores derivados, XP y niveles.
src/server/Net/        Límite de frecuencia y validación común de cada Remote.
src/server/Datos/      Plantilla del perfil, migraciones y guardado con sesión bloqueada.
src/server/Reglas/     Reglas puras del servidor: energía y regeneración, monedero.
src/server/Services/   DataService, AnalyticsService, EconomyService, StatsService y ProgressionService.
src/client/            HUD (nivel, XP, vida, energía, monedas, avisos) y panel de estadísticas (tecla P).
src/character/         Sustituye la regeneración de vida por defecto de Roblox.
tests/                 Pruebas y valores de referencia (tests/Vectores, generados de OREBOUND/calculos).
```

## Abrir el juego en Studio

```bash
rojo build -o "OREBOUND.rbxlx"
```

```bash
rojo serve
```

En Studio hay que activar *Game Settings → Security → Enable Studio Access to API Services* para que el guardado use
DataStore. Sin eso, `DataService` avisa y guarda solo en memoria.

En Studio aparecen arriba a la derecha dos botones de prueba («+1 nivel» y «+10.000 $») que no existen en el juego publicado.

## Pruebas

Fuera de Roblox (necesita Python 3 y `pip install lupa`):

```bash
python3 herramientas/pruebas.py
```

Dentro de Studio: abrir el lugar de pruebas y pulsar *Run*; el resultado sale en la ventana Output.

```bash
rojo serve pruebas.project.json
```

El código que se prueba fuera de Roblox está escrito en el subconjunto común de Lua 5.1 y Luau (sin anotaciones de
tipo, sin `+=` y sin `continue`). Los servicios que usan el motor (`DataService`, `AnalyticsService`, arranque) solo
se pueden probar en Studio.

## Regenerar datos a partir de los cálculos

Si cambian los CSV de `OREBOUND/calculos/`:

```bash
cd OREBOUND && python3 calculos/c1_exportar_luau.py
```
