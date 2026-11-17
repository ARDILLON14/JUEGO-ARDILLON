# OREBOUND

RPG de minería y acción para Roblox. Proyecto de [Rojo](https://rojo.space/docs) 7.7.1 (gestionado con Rokit).

- **Diseño:** carpeta `OREBOUND/` (`A_GDD.md`, `B_Matematico/`, `C_Tecnico.md`, `D_Roadmap.md`, `DECISIONES.md`).
- **Código:** `src/` (fases 1 a 9 del roadmap: Cimientos, Progresión, Minería y economía base, Combate y Núcleos, Fabricación y cajas, Mascotas, Jefes y mundo 1, PvP y Zonas Fracturadas, Optimización y lanzamiento).
- **Pruebas:** `tests/`.

## Estructura del código

```
src/shared/Config/     13 módulos de datos (cifras de los archivos B). Para ajustar el juego se tocan estos.
src/shared/Formulas/   Fórmulas F1 a F36 como funciones puras.
src/shared/Net/        Definición de los 46 Remotes y validador de esquemas.
src/shared/Reglas/     Reglas puras sobre el perfil: puntos, reinicio, valores derivados, XP y niveles.
src/server/Net/        Límite de frecuencia y validación común de cada Remote.
src/server/Datos/      Plantilla del perfil, migraciones y guardado con sesión bloqueada.
src/shared/Visual/     Nombres y colores de rarezas.
src/server/Reglas/     Reglas puras del servidor: energía, monedero, depósitos, generación y pasivas de pico.
src/server/Mundo/      Mapa de prueba con la cantera de bloques de la zona 1 (solo si el lugar no trae mapa propio).
src/server/Services/   Datos, analítica, economía, estadísticas, progresión, inventario, minería, banco, enemigos, combate, Núcleos, forja, cajas, mascotas, mundo, jefes, misiones, PvP, Zona Fracturada y arena.
src/client/            HUD, picar, combate (Z/X/C/V, Q, F, E), estadísticas (P), inventario (B), habilidades (K), mascotas (M, postura T), misiones (J), jefes, tienda, forja y geodas.
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

Si el lugar no tiene mapa, se crea uno de prueba: ciudad con banco y mercader, y la Cantera del Alba (zona 1), un volumen
de bloques que se excava hacia abajo. Para usar un mapa propio, etiqueta con CollectionService una parte `Mina` en el centro
de la cara de arriba de la cantera (atributos `Zona`, `Ancho`, `Largo`, `Profundidad` y `Salida`) y las partes `Banco` y `Mercader`.

En Studio aparecen arriba a la derecha dos botones de prueba («+1 nivel» y «+10.000 $») que no existen en el juego publicado.

## Antes de publicar (fase 9)

1. Crear en el Creator Dashboard los 3 productos de Cristales y los pases (sexto espacio de mascota, pase de temporada) y
   copiar sus números en `src/shared/Config/Monetization.luau` (mientras estén a 0, la tienda muestra «Próximamente»).
2. Para la beta cerrada: en `src/shared/Config/Security.luau` poner `Beta.Enabled = true` y rellenar `AllowedUserIds`
   o `AllowGroupId`. En Studio la beta nunca bloquea.
3. Activar *Enable Studio Access to API Services* y publicar el lugar.

Teclas: P estadísticas, B inventario, K habilidades, M mascotas, J misiones, O ajustes, L cosméticos; R interactuar.

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
