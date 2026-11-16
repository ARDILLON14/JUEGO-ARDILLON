# OREBOUND — B6: Economía

Etapa 6 · 2026-11-16 · Script: `calculos/b6_economia.py` · Precios completos: `calculos/b6_precios_minerales.csv` (66 minerales) y `calculos/b6_precios_equipo.csv` (70 combinaciones de zona y rareza).

> **Aviso de fuentes.** No se dispone de las secciones 12, 13 y 19 del prompt maestro ni de las
> mejoras de retención del GDD. Todos los precios son **[PROVISIONAL]**. Son **[CONFIRMADO]**
> las decisiones fijas: nunca se venden Celestial, Núcleos Despertados ni el Seguro de carga;
> ningún estilo PvE gana más de 1,3 veces que otro; las Zonas Fracturadas no rinden más de 2,5
> veces el PvE.
>
> **Correcciones a etapas anteriores hechas aquí:** B4 (monedas de jefe), B3 (mochila en Zona
> Fracturada) y B2 (coste del reinicio de estadísticas). Detalle en la sección 10.

---

## 0. Unidad de precio: la hora de ingreso

Casi todos los precios se expresan en **horas de ingreso de la zona** (`I`): lo que gana en una hora un jugador equilibrado en esa zona. Así los precios suben solos con la zona y no hay que retocarlos.

| Zona | Valor de zona V | Minero (B3) | Combatiente (B4) | Ingreso de referencia I | I / V |
|---|---|---|---|---|---|
| 1 | 10,0 | 4.782 | 4.877 | 4.830 | 483 |
| 2 | 16,5 | 7.890 | 8.042 | 7.966 | 483 |
| 3 | 27,2 | 12.418 | 13.213 | 12.816 | 471 |
| 4 | 44,9 | 20.419 | 21.652 | 21.036 | 468 |
| 5 | 74,1 | 33.692 | 35.417 | 34.554 | 466 |
| 6 | 122,3 | 55.523 | 57.854 | 56.688 | 464 |
| 7 | 201,8 | 91.613 | 94.414 | 93.014 | 461 |
| 8 | 333,0 | 150.461 | 153.968 | 152.214 | 457 |
| 9 | 549,4 | 242.713 | 250.954 | 246.834 | 449 |
| 10 | 906,5 | 399.993 | 408.875 | 404.434 | 446 |

- `V(z) = 10 × 1,65^(z−1)` es el valor de zona de B3.
- `I(z)` es la media del minero y el combatiente equilibrados; equivale a unas 480 veces `V`.
- Con mascotas típicas el ingreso real es un 12% mayor (B5).

---

## 1. Recursos: cómo entran y cómo salen

| Recurso | Cómo entra | Cómo sale |
|---|---|---|
| Monedas | Venta de minerales; enemigos y jefes; misiones (10% extra); contratos de grieta | Fabricación y mejoras; cajas; consumibles; mochila; evolución de mascotas; reinicio de estadísticas; Seguro de carga; aspectos de prestigio |
| Minerales | Depósitos; Cofres de Saqueo; lotes de la Caja de zona | Venta al mercader; recetas de fabricación; 15% de la carga destruido al morir en Zona Fracturada |
| Cristales | Misiones diarias y semanales, logros, temporada; compra con Robux | Cosméticos, almacén de mascotas, tercera incubadora, pase de temporada, Pergaminos de XP |
| Materiales de jefe | 3 por derrota de jefe, máximo 3 derrotas con botín por jefe y día | Fabricar equipo Legendario o superior; evolución de mascotas; Despertar de Núcleos |
| Gemas antiguas | Contratos de grieta; primera derrota semanal de cada jefe; temporada | Equipo Ultra raro; forma desatada máxima; Despertar de Núcleos |
| Fragmentos Celestiales | Jefes de evento y extracciones en Zonas Fracturadas de zona 6 o más (B1) | 60 fragmentos + 10 horas de ingreso en monedas = 1 objeto Celestial |

- Los Cristales **no se pueden cambiar por monedas** ni compran cajas. Así ninguna recompensa aleatoria se paga con dinero real (sección 9).
- Materiales de jefe, gemas antiguas y fragmentos Celestiales no se venden ni se comercian.
- No hay comercio entre jugadores en el lanzamiento: evita duplicaciones y mercado de dinero real.

---

## 2. Tablas de precios

### 2.1 Venta de minerales (monedas por unidad)

| Zona | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|
| 1 | 2,5 | 4,5 | 10,7 | 20,0 | 60,0 | 125,0 | 600,0 |
| 2 | 4,1 | 7,4 | 17,6 | 33,0 | 99,0 | 206,2 | 990,0 |
| 3 | 6,8 | 12,3 | 29,0 | 54,4 | 163,3 | 340,3 | 1.633,5 |
| 4 | 11,2 | 20,2 | 47,9 | 89,8 | 269,5 | 561,5 | 2.695,3 |
| 5 | 18,5 | 33,4 | 79,1 | 148,2 | 444,7 | 926,5 | 4.447,2 |
| 6 | 30,6 | 55,0 | 130,5 | 244,6 | 733,8 | 1.528,7 | 7.337,9 |
| 7 | 50,4 | 90,8 | 215,2 | 403,6 | 1.210,8 | 2.522,4 | 12.107,5 |
| 8 | 83,2 | 149,8 | 355,2 | 665,9 | 1.997,7 | 4.162,0 | 19.977,4 |
| 9 | 137,3 | 247,2 | 586,0 | 1.098,8 | 3.296,3 | 6.867,2 | 32.962,7 |
| 10 | 226,6 | 407,9 | 966,9 | 1.812,9 | 5.438,8 | 11.330,9 | 54.388,5 |

- `Precio = V(z) × FactorValor / Unidades` (B3). El listado por mineral está en el CSV.
- El mineral fracturado extraído vale el doble (sección 7).

### 2.2 Picos y armas: fabricación y mejoras

Un pico y un arma de la misma zona y rareza cuestan lo mismo.

| Rareza | Monedas (horas de ingreso) | Receta (minerales de la zona) | Horas de minería para el material más escaso | Valor de venta de los materiales (horas) | Niveles 1–10 (monedas, horas) | 3 ranuras (horas) | Despertar (horas) | Total al máximo (horas) |
|---|---|---|---|---|---|---|---|---|
| Común | 0,3 | 30 Lingotes Común | 0,1 | 0,02 | 0,82 | 0,45 | 0,45 | 2,0 |
| Poco común | 0,6 | 40 Lingotes Común + 20 Lingotes Poco común | 0,1 | 0,04 | 1,65 | 0,90 | 0,90 | 4,0 |
| Raro | 1,2 | 30 Lingotes Poco común + 15 Placas Raro | 0,2 | 0,06 | 3,30 | 1,80 | 1,80 | 8,1 |
| Épico | 2,5 | 30 Placas Raro + 10 Gemas talladas | 0,4 | 0,11 | 6,88 | 3,75 | 3,75 | 16,9 |
| Legendario | 5,0 | 20 Gemas talladas + 8 Núcleos + 2 de jefe | 0,9 | 0,18 | 13,75 | 7,50 | 7,50 | 33,8 |
| Mítico | 10,0 | 15 Núcleos + 6 Catalizadores + 4 de jefe | 2,9 | 0,34 | 27,50 | 15,00 | 15,00 | 67,5 |
| Ultra raro | 20,0 | 10 Catalizadores + 4 Esencias + 6 de jefe + 1 gema antigua | 34,6 | 0,76 | 55,00 | 30,00 | 30,00 | 135,0 |

Coste de fabricación en monedas, por zona:

| Zona | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|
| 1 | 1.449 | 2.898 | 5.795 | 12.074 | 24.148 | 48.295 | 96.590 |
| 2 | 2.390 | 4.780 | 9.559 | 19.915 | 39.830 | 79.660 | 159.320 |
| 3 | 3.845 | 7.689 | 15.379 | 32.039 | 64.078 | 128.155 | 256.310 |
| 4 | 6.311 | 12.621 | 25.243 | 52.589 | 105.178 | 210.355 | 420.710 |
| 5 | 10.366 | 20.733 | 41.465 | 86.386 | 172.772 | 345.545 | 691.090 |
| 6 | 17.007 | 34.013 | 68.026 | 141.721 | 283.442 | 566.885 | 1.133.770 |
| 7 | 27.904 | 55.808 | 111.616 | 232.534 | 465.068 | 930.135 | 1.860.270 |
| 8 | 45.664 | 91.329 | 182.657 | 380.536 | 761.072 | 1.522.145 | 3.044.290 |
| 9 | 74.050 | 148.100 | 296.200 | 617.084 | 1.234.168 | 2.468.335 | 4.936.670 |
| 10 | 121.330 | 242.660 | 485.321 | 1.011.085 | 2.022.170 | 4.044.340 | 8.088.680 |

- **Mejoras:** nivel `n` cuesta `0,05 × n ×` el coste base (2,75 veces el base en total); cada ranura, 0,5 veces el base y 6 Gemas talladas; el Despertar de habilidad, 1,5 veces el base y 4 Catalizadores.
- **En zonas sin depósitos Ultra raro** (1, 2, 4 y 6), el equipo Ultra raro pide 16 Catalizadores en lugar de las 4 Esencias.
- **Venta al mercader:** 10% del coste de fabricación. No se recuperan las mejoras.
- **Reciclaje:** deshacer un objeto devuelve el 30% de los materiales de sus mejoras (respuesta al problema P6 de B1).
- **Celestial:** no se fabrica con minerales; solo con fragmentos.

### 2.3 Mochila

| Capacidad | Disponible desde la zona | Precio (horas de I de esa zona) | Monedas |
|---|---|---|---|
| 80 | 2 | 0,5 | 3.983 |
| 100 | 3 | 1,0 | 12.816 |
| 120 | 4 | 2,0 | 42.071 |
| 140 | 5 | 3,0 | 103.664 |
| 160 | 6 | 5,0 | 283.442 |
| 180 | 8 | 8,0 | 1.217.716 |
| 200 | 10 | 12,0 | 4.853.208 |

### 2.4 Consumibles y servicios

| Concepto | Precio | Zona 1 | Zona 5 | Zona 10 |
|---|---|---|---|---|
| Poción de vida (cura 30 %) | 0,01 h | 48 | 346 | 4.044 |
| Tónico de energía (+100 de energía) | 0,01 h | 48 | 346 | 4.044 |
| Elixir de Suerte (+100 de Suerte, 15 min) | 0,10 h | 483 | 3.455 | 40.443 |
| Pergamino de XP (+25 %, 30 min) | 0,15 h | 724 | 5.183 | 60.665 |
| Baliza de extracción (aviso 30 s antes) | 0,05 h | 241 | 1.728 | 20.222 |
| Seguro de carga (por entrada) | 6 V | 60 | 433 | 5.066 |
| Reinicio de estadísticas | 1,5 h | 7.244 | 51.832 | 606.651 |
| Evolución a forma desatada (por mascota) | 2 h | 9.659 | 69.109 | 808.868 |
| Evolución a forma máxima (por mascota) | 8 h | 38.636 | 276.436 | 3.235.472 |
| Forjar un objeto Celestial (más 60 fragmentos) | 10 h | 48.295 | 345.545 | 4.044.340 |
| Aspecto de prestigio (cosmético) | 20 h | 96.590 | 691.090 | 8.088.680 |

- No hay reparaciones ni durabilidad: perder tiempo reparando no aporta nada en sesiones cortas de móvil, y los sumideros de mejora ya cumplen esa función.
- El reinicio de estadísticas sigue siendo gratis por debajo del nivel 50.

---

## 3. Recompensas de enemigos y jefes por zona

| Zona | Común: monedas | Élite | Guardián | Jefe (por jugador) | Común: XP | Élite | Guardián | Jefe | Material de jefe |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 14 | 54 | 160 | 600 | 157 | 548 | 1.566 | 9.396 | 3 |
| 2 | 22 | 89 | 264 | 990 | 455 | 1.594 | 4.554 | 27.324 | 3 |
| 3 | 37 | 147 | 436 | 1.633 | 783 | 2.740 | 7.830 | 46.980 | 3 |
| 4 | 61 | 243 | 719 | 2.695 | 1.139 | 3.988 | 11.394 | 68.364 | 3 |
| 5 | 100 | 400 | 1.186 | 4.447 | 1.525 | 5.336 | 15.246 | 91.476 | 3 |
| 6 | 165 | 660 | 1.957 | 7.338 | 1.939 | 6.785 | 19.386 | 116.316 | 3 |
| 7 | 272 | 1.090 | 3.229 | 12.108 | 2.381 | 8.335 | 23.814 | 142.884 | 3 |
| 8 | 449 | 1.798 | 5.327 | 19.977 | 2.853 | 9.986 | 28.530 | 171.180 | 3 |
| 9 | 742 | 2.967 | 8.790 | 32.963 | 3.353 | 11.737 | 33.534 | 201.204 | 3 |
| 10 | 1.224 | 4.895 | 14.504 | 54.388 | 3.883 | 13.589 | 38.826 | 232.956 | 3 |

- Monedas: `V(z) ×` 1,35 (Común), 5,4 (Élite), 16 (Guardián) y 60 (Jefe).
- **Corrección de B4:** el jefe daba `250 × V`, es decir, 0,52 horas de ingreso por un combate de 8 minutos. Con 3 derrotas diarias equivalía a 1,6 horas de ingreso gratis al día. Ahora da `60 × V` (7,5 minutos de ingreso por 8 de combate) y su valor está en los materiales de jefe.

---

## 4. Ingresos y gastos por hora

Jugador equilibrado con mascotas típicas (+12%). Consumibles: 5% del ingreso base. Cajas: 15%. El equipo es el gasto medio por hora de los objetivos que se pueden pagar durante la estancia en la zona.

| Zona | Estilo | Ingresos/hora | Consumibles/hora | Cajas/hora | Equipo y mejoras/hora | Ahorro/hora | Ingresos frente al minero PvE |
|---|---|---|---|---|---|---|---|
| 1 | Minero PvE | 5.356 | 239 | 717 | 3.469 | 931 | 1,00 |
| 1 | Combatiente PvE | 5.462 | 244 | 732 | 3.469 | 1.018 | 1,02 |
| 1 | Zona Fracturada (minero, 30 % de muertes, con seguro) | 9.982 | 624 | 1.337 | 3.469 | 4.553 | 1,86 |
| 3 | Minero PvE | 13.908 | 621 | 1.863 | 5.601 | 5.823 | 1,00 |
| 3 | Combatiente PvE | 14.799 | 661 | 1.982 | 5.601 | 6.555 | 1,06 |
| 3 | Zona Fracturada (minero, 30 % de muertes, con seguro) | 25.922 | 1.620 | 3.472 | 5.601 | 15.229 | 1,86 |
| 5 | Minero PvE | 37.735 | 1.685 | 5.054 | 23.589 | 7.408 | 1,00 |
| 5 | Combatiente PvE | 39.667 | 1.771 | 5.313 | 23.589 | 8.995 | 1,05 |
| 5 | Zona Fracturada (minero, 30 % de muertes, con seguro) | 70.331 | 4.396 | 9.419 | 23.589 | 32.927 | 1,86 |
| 8 | Minero PvE | 168.516 | 7.523 | 22.569 | 125.990 | 12.434 | 1,00 |
| 8 | Combatiente PvE | 172.444 | 7.698 | 23.095 | 125.990 | 15.661 | 1,02 |
| 8 | Zona Fracturada (minero, 30 % de muertes, con seguro) | 314.084 | 19.630 | 42.065 | 125.990 | 126.399 | 1,86 |
| 10 | Minero PvE | 447.992 | 20.000 | 59.999 | 285.841 | 82.152 | 1,00 |
| 10 | Combatiente PvE | 457.940 | 20.444 | 61.331 | 285.841 | 90.324 | 1,02 |
| 10 | Zona Fracturada (minero, 30 % de muertes, con seguro) | 834.978 | 52.186 | 111.827 | 285.841 | 385.123 | 1,86 |

- **Minero frente a combatiente:** entre 1,02 y 1,06. El límite era 1,3.
- **Zona Fracturada:** 1,86 veces el minero PvE con un 30% de muertes y pagando seguro. El límite era 2,5.
- El jugador PvE gasta entre el 58% y el 93% de lo que gana mientras sube de zona; el resto es ahorro para el siguiente objetivo de equipo.

### 4.1 Qué equipo se puede pagar en cada zona

| Zona | Horas de juego en la zona | Ingreso total (horas de I) | Objetivos de equipo que se pueden pagar |
|---|---|---|---|
| 1 | 5,8 | 5,4 | Niveles 1–5 de ambos |
| 2 | 13,8 | 12,7 | Pico y arma Épicos |
| 3 | 21,0 | 19,4 | Pico y arma Épicos |
| 4 | 27,6 | 25,4 | Niveles 1–10 de ambos |
| 5 | 33,6 | 30,9 | Ranuras de ambos |
| 6 | 39,1 | 36,0 | Ranuras de ambos |
| 7 | 44,2 | 40,7 | Pico y arma Legendarios |
| 8 | 48,9 | 45,0 | Pico y arma Legendarios |
| 9 | 53,2 | 48,9 | Pico y arma Legendarios |
| 10 | 57,2 | 52,7 | Pico y arma Legendarios |

- Las horas en cada zona usan la curva de XP ajustada de B2.
- Subiendo de nivel a ritmo normal, el jugador llega a equipo Épico mejorado o Legendario base. Mítico y Ultra raro son objetivos de final de juego (135 horas de ingreso por objeto Ultra raro al máximo).

---

## 5. Cajas

Las tres cajas estándar se compran solo con monedas. Usan la tabla de rarezas de B1 y su protección contra mala suerte, con contadores separados por tipo de caja.

| Caja | Precio (horas de I) | Zona 1 | Zona 3 | Zona 5 | Zona 8 | Zona 10 | Valor medio del contenido (horas) | Valor de reventa (horas) |
|---|---|---|---|---|---|---|---|---|
| Caja de armas | 1,00 | 4.830 | 12.816 | 34.554 | 152.214 | 404.434 | 0,96 | 0,10 |
| Caja de zona | 0,60 | 2.898 | 7.689 | 20.733 | 91.329 | 242.660 | 0,57 | 0,25 |
| Caja de mascotas | 0,75 | 3.622 | 9.612 | 25.916 | 114.161 | 303.326 | — | 0 (no se venden) |

- La Caja de mascotas se paga según la zona más alta que el jugador tenga desbloqueada, no la zona donde la compre. Así no se pueden comprar miles de cajas baratas desde el final del juego.
- El contenido vale, de media, algo menos que el precio; y revender lo obtenido devuelve entre el 10% y el 42%. Ninguna caja genera monedas.
- **Caja frente a fabricar:** conseguir un arma Legendaria o superior de un tipo concreto requiere de media 135 Cajas de armas (135 horas de ingreso); fabricarla cuesta 5 horas y sus materiales. La caja es la vía de la sorpresa; la forja, la vía segura.

### 5.1 Caja de armas

- Contenido: un arma de la zona de la caja.
- Tipo: Espada 17%, Hacha 17%, Daga 17%, Lanza 17%, Bastón 16%, Arco 16% (suma 100%).
- Rareza: Común 50%, Poco común 26%, Raro 14%, Épico 7%, Legendario 2,4%, Mítico 0,5%, Ultra raro 0,1% (suma 100%).

### 5.2 Caja de mascotas

| Huevo | Rareza | Probabilidad |
|---|---|---|
| Topillo de Pizarra | Común | 25,0 % |
| Luciérnaga de Veta | Común | 25,0 % |
| Zorro de Ascua | Poco común | 13,0 % |
| Tortuga Geoda | Poco común | 13,0 % |
| Murciélago de Eco | Raro | 7,0 % |
| Nutria Salina | Raro | 7,0 % |
| Búho Boreal | Épico | 3,5 % |
| Carnero de Magma | Épico | 3,5 % |
| Mantis Vitral | Legendario | 1,2 % |
| Guiverno de Cuarzo | Legendario | 1,2 % |
| Ciervo Astral | Mítico | 0,5 % |
| Sierpe de Nova | Ultra raro | 0,1 % |
| **Suma** |  | **100,0 %** |

### 5.3 Caja de zona

| Categoría | Probabilidad | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|---|
| Pico de la zona | 35 % | 17,500 % | 9,100 % | 4,900 % | 2,450 % | 0,840 % | 0,175 % | 0,035 % |
| Lote de minerales de la zona | 40 % | 20,000 % | 10,400 % | 5,600 % | 2,800 % | 0,960 % | 0,200 % | 0,040 % |
| Materiales de fabricación | 15 % | 7,500 % | 3,900 % | 2,100 % | 1,050 % | 0,360 % | 0,075 % | 0,015 % |
| Lote de consumibles | 10 % | 5,000 % | 2,600 % | 1,400 % | 0,700 % | 0,240 % | 0,050 % | 0,010 % |
| **Suma** | **100 %** | 50,0 % | 26,0 % | 14,0 % | 7,0 % | 2,4 % | 0,5 % | 0,1 % |

- Primero se sortea la categoría y después la rareza con la tabla estándar; las 28 casillas suman exactamente 100%.
- Los lotes valen, según rareza, 0,15 / 0,25 / 0,4 / 0,8 / 2 / 5 / 12 horas de ingreso en minerales o materiales de la zona.

### 5.4 Caja de evento

- No se compra: se gana con fichas del evento.
- Tabla de B1: Raro 45%, Épico 33%, Legendario 15%, Mítico 5%, Ultra raro 1,5%, Celestial 0,5% (suma 100%).
- Es la única caja que puede dar Celestial y no admite Suerte.

### 5.5 Protección contra mala suerte

- La de B1, sin cambios: base hasta la apertura 40, rampa de la 41 a la 49, Legendario o superior garantizado en la 50 y Mítico o superior en la 100.
- Tasas reales con la protección: Legendario 3,050%, Mítico 1,171%, Ultra raro 0,228%. Son las que se usan en los valores medios de arriba.
- En la Caja de evento la garantía de la apertura 100 da Ultra raro o superior.

---

## 6. Sumideros contra la inflación

| Sumidero | Tamaño | Notas |
|---|---|---|
| Fabricación | 0,3 a 20 horas de ingreso por objeto | Hay que repetirla en cada zona |
| Mejoras | 5,75 veces el coste base por objeto al máximo | El mayor sumidero del juego |
| Cajas | Alrededor del 15% del ingreso | Reventa del 10–42% |
| Consumibles | Alrededor del 5% del ingreso | |
| Mochila | 31,5 horas de ingreso en total | Una sola vez |
| Evolución de mascotas | 2 y 8 horas por mascota | |
| Reinicio de estadísticas | 1,5 horas | |
| Seguro de carga | 6 V por entrada | Devuelve de media el 50% de lo cobrado |
| Destrucción en el saqueo | 15% de la carga de cada muerte PvP | Sale mineral, no monedas |
| Aspectos de prestigio | 20 horas cada uno | Cosméticos sin límite para el final de juego |
| Reparaciones | No hay | Ver 2.4 |

### 6.1 Simulación: 1.000 jugadores durante 90 días

- 500 casuales (0,5 h al día), 350 regulares (1,5 h) y 150 dedicados (4 h); cada uno juega 4 de cada 5 días.
- Cada jugador gana según su zona, gasta en consumibles y cajas, y compra el siguiente objetivo de equipo cuando le alcanza. Los que ya lo tienen todo gastan la mitad de lo que supere 10 horas de ahorro en aspectos de prestigio.

| Día | Masa monetaria total | Entra ese día | Sale ese día | Sale / entra | Ahorro mediano (horas de ingreso) | Ahorro del 10 % más rico (horas) | Zona media | Nivel máximo | Masa sin sumideros | Ahorro mediano sin sumideros (horas) |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 4.584.276 | 7.676.953 | 3.092.677 | 40 % | 1,0 | 2,1 | 1,0 | 93 | 7.676.953 | 1,1 |
| 7 | 13.321.493 | 14.001.063 | 11.973.326 | 86 % | 1,3 | 3,8 | 1,6 | 259 | 75.624.194 | 6,4 |
| 14 | 40.874.663 | 18.372.969 | 13.499.993 | 73 % | 3,4 | 9,2 | 2,0 | 374 | 186.205.788 | 10,5 |
| 30 | 76.296.911 | 39.221.470 | 35.152.743 | 90 % | 3,6 | 11,0 | 2,9 | 535 | 650.967.906 | 22,8 |
| 60 | 196.344.164 | 107.462.395 | 92.024.323 | 86 % | 4,5 | 8,9 | 4,3 | 786 | 2.709.885.566 | 43,8 |
| 90 | 488.244.301 | 239.649.597 | 238.632.058 | 100 % | 4,5 | 10,8 | 5,0 | 984 | 7.656.396.920 | 57,5 |

- **La masa monetaria total crece** (de 4,6 millones a 488 millones), pero es porque los jugadores suben de zona y cada zona paga 1,65 veces más. No es inflación.
- **La medida correcta es el ahorro en horas de ingreso:** el jugador mediano se mantiene entre 3,4 y 4,5 horas desde el día 14, y el 10% más rico entre 9 y 11 horas. No se acumula.
- A partir del día 7 sale entre el 73% y el 100% de lo que entra cada día.
- **Sin sumideros**, el jugador mediano tendría 57,5 horas de ingreso ahorradas el día 90 y la masa sería 15,7 veces mayor.

---

## 7. Seguro de carga, racha de extracción y contratos de grieta

Los valores del GDD no se han visto; estos son los propuestos.

### 7.1 Contenedor de grieta (corrección de B3)

- Dentro de una Zona Fracturada la mochila admite el doble: 120 unidades base en lugar de 60.
- Motivo: con 60 unidades, una carga completa valía 4 minutos de ingreso y saquear no compensaba ni un poco. Con 120, una carga completa son 66,7 V (8,4 minutos de ingreso) y un viaje dura unos 7,8 minutos.

### 7.2 Racha de extracción

| Extracciones seguidas | Bono | Multiplicador del mineral |
|---|---|---|
| 0 | +0 % | ×2,00 |
| 1 | +2 % | ×2,04 |
| 2 | +4 % | ×2,08 |
| 3 | +6 % | ×2,12 |
| 4 | +8 % | ×2,16 |
| 5 | +10 % | ×2,20 |
| 6 | +10 % | ×2,20 |

- Cuenta cada extracción con al menos el 50% de carga. Morir en una Zona Fracturada la pone a 0; salir sin extraer no la rompe.

| Prob. de morir por viaje | Bono medio de racha |
|---|---|
| 5 % | +8,6 % |
| 15 % | +6,3 % |
| 30 % | +3,9 % |
| 50 % | +1,9 % |

### 7.3 Seguro de carga

- **Precio:** 6 V por entrada (monedas). **Nunca se vende por dinero real** **[CONFIRMADO]**.
- **Qué cubre:** si el jugador muere contra otro jugador, cobra en monedas el 50% del valor base de las unidades que soltó.
- **Límites:** 5 seguros al día; no disponible con la marca de saqueador activa.

| Prob. de morir por viaje | Prima (V) | Pago medio (V) | Pago / prima | Ingreso sin seguro (× PvE) | Ingreso con seguro (× PvE) |
|---|---|---|---|---|---|
| 15 % | 6,0 | 1,50 | 25 % | 2,063 | 1,988 |
| 30 % | 6,0 | 3,00 | 50 % | 1,817 | 1,764 |
| 50 % | 6,0 | 5,00 | 83 % | 1,487 | 1,468 |
| 60 % | 6,0 | 6,01 | 100 % | 1,312 | 1,312 |
| 70 % | 6,0 | 7,01 | 117 % | 1,127 | 1,148 |

- Con seguro, quien muere conserva el 37,5% del valor que habría extraído, frente al 25% sin él.
- El seguro es un sumidero: solo sale a cuenta a quien muere en más del 60% de los viajes. Su función es reducir el disgusto, no dar ganancias.
- El pago sale de las primas: de media el sistema paga el 50% de lo que cobra (con un 30% de muertes).

### 7.4 Contratos de grieta

| Parámetro | Valor |
|---|---|
| Contratos diarios | 3, propios de la Zona Fracturada de la zona del jugador |
| Ejemplos | «Extrae 100 unidades», «Extrae un mineral Épico o superior», «Completa 3 extracciones seguidas» |
| Recompensa por contrato | 0,067 horas de ingreso en monedas (0,20 horas al día en total) |
| Contrato semanal | 5 extracciones con el 50% de carga: 2 gemas antiguas |
| Qué no piden | Nunca piden matar jugadores: no se premia el acoso |

### 7.5 Efecto en la economía

Ingresos por hora en Zona Fracturada, relativos al minero PvE de la misma zona.

| Perfil | Minería (× PvE) | Saqueo (× PvE) | Contratos (× PvE) | Total (× PvE) | ¿Bajo el techo de 2,5? |
|---|---|---|---|---|---|
| Minero de grieta prudente (15 % de muertes) | 2,06 | 0,00 | 0,10 | 2,16 | Sí |
| Minero de grieta (30 %) | 1,82 | 0,00 | 0,10 | 1,92 | Sí |
| Minero de grieta en servidor hostil (50 %) | 1,49 | 0,00 | 0,10 | 1,59 | Sí |
| Híbrido: mina (25 %) y saquea 1,5 por hora | 1,71 | 0,06 | 0,10 | 1,87 | Sí |
| Saqueador puro: 8 muertes por hora | 0,00 | 0,37 | 0,10 | 0,47 | Sí |
| Máximo teórico: sin muertes y racha completa | 2,33 | 0,00 | 0,10 | 2,43 | Sí |

- **Todos los perfiles quedan por debajo de 2,5.** El máximo teórico, sin morir nunca y con la racha completa, es 2,43.
- **El minero de grieta** gana entre 1,59 y 2,16 veces el PvE según cuánto muera.
- **El saqueador puro gana 0,47 veces el PvE:** menos de la mitad que un minero normal. Ver el problema P2.

---

## 8. Resumen de límites

| Límite | Exigido | Obtenido |
|---|---|---|
| Estilo PvE frente a otro (equilibrados) | ≤ 1,30 | 1,02 – 1,06 |
| Especialista de Minería frente a equilibrado (B3) | ≤ 1,30 | 1,08 – 1,26 |
| Zona Fracturada frente a PvE, perfil típico | ≤ 2,50 | 1,86 – 1,92 |
| Zona Fracturada frente a PvE, máximo teórico | ≤ 2,50 | 2,43 |
| Sexto espacio de mascota (B5) | ≤ +5% | +4,8% |

---

## 9. Monetización

### 9.1 Qué se vende

| Producto | Moneda | Da poder |
|---|---|---|
| Cosméticos: aspectos de arma, pico, mascota y efectos | Cristales | No |
| Pase de temporada (vía gratuita y vía de pago) | Robux | No: la vía de pago solo añade cosméticos y Cristales |
| Almacén de mascotas ampliado | Cristales | No |
| Tercera incubadora | Cristales | No: solo ahorra espera |
| Pergamino de XP (+25%) | Monedas o Cristales | Ahorra tiempo; no da monedas ni fuerza |
| Sexto espacio de mascota | Robux, o 60 Fragmentos de temporada gratis | +4,8% de monedas por hora en PvE; nada en PvP |
| Pestañas de banco y segunda cola de fabricación | Cristales | No |

### 9.2 Qué no se vende nunca

- Objetos, armas, picos o mascotas **Celestiales**, ni sus fragmentos **[CONFIRMADO]**.
- **Núcleos Despertados**, ni los materiales del Despertar **[CONFIRMADO]**.
- El **Seguro de carga** **[CONFIRMADO]**.
- Monedas, minerales, materiales de jefe o gemas antiguas.
- Suerte, Elixires de Suerte o cualquier aumento de probabilidad en cajas.
- Cajas de cualquier tipo: en el lanzamiento solo se compran con monedas ganadas jugando.
- Cualquier ventaja en PvP, arenas o Zonas Fracturadas.

### 9.3 Política de Roblox sobre recompensas aleatorias de pago

**Qué he podido consultar.** No he podido abrir las páginas oficiales (el dominio `create.roblox.com` no es accesible desde esta sesión). Lo que sigue procede de los resúmenes del buscador sobre esas páginas, consultados el 16 de noviembre de 2026. Hay que releer las páginas originales antes de publicar.

Según esos resúmenes:

- Se considera «objeto aleatorio de pago» todo resultado aleatorio comprado **directa o indirectamente** con Robux, incluido el que se compra con una moneda del juego que a su vez se compra con Robux.
- `PolicyService:GetPolicyInfoForPlayerAsync` devuelve `ArePaidRandomItemsRestricted`. Si es verdadero, ese jugador no puede interactuar con generadores de objetos aleatorios de pago: hay que ocultarlos, bloquear la compra con un aviso o sacar al jugador de esa parte.
- Hay que mostrar las **probabilidades numéricas reales** antes de la compra.
- Si un objeto de pago mejora las probabilidades de otro resultado aleatorio, hay que explicarlo antes de la compra y actualizar las probabilidades mostradas mientras esté activo.
- Los jugadores restringidos tampoco pueden intercambiar los objetos resultantes.
- El uso de objetos aleatorios de pago se declara en el cuestionario de madurez y cumplimiento de la experiencia.
- Para usuarios del Reino Unido menores de 18 años, una experiencia que no use esta API queda no disponible para ellos de forma automática.

Fuentes:
- [Paid random items — Roblox Creator Hub](https://create.roblox.com/docs/production/monetization/paid-random-items)
- [Randomized virtual items policy — Roblox Creator Hub](https://create.roblox.com/docs/production/monetization/randomized-virtual-items-policy)
- [Guidelines around users paying for random virtual items — DevForum](https://devforum.roblox.com/t/guidelines-around-users-paying-for-random-virtual-items/307189)
- [Update on paid random items restriction for UK users under 18 — DevForum](https://devforum.roblox.com/t/update-on-paid-random-items-restriction-for-uk-users-under-18/3072183)

**Cómo cumple OREBOUND.**

1. **En el lanzamiento no hay recompensas aleatorias de pago.** Las cajas se compran solo con monedas, y las monedas no se pueden comprar ni obtener a partir de Cristales o Robux.
2. Aun así, cada caja muestra sus probabilidades numéricas y el texto de las garantías antes de abrirla.
3. Con un Elixir de Suerte activo, la pantalla de la caja muestra las probabilidades ya modificadas.
4. El servidor consulta `PolicyService` al entrar cada jugador y guarda el resultado. Si en el futuro alguna caja pasa a venderse por Robux o Cristales, se oculta a quien tenga `ArePaidRandomItemsRestricted` y se le ofrece la compra directa del objeto.
5. Si se añade comercio entre jugadores, se consulta también `IsPaidItemTradingAllowed`.

---

## 10. Problemas de balance detectados y alternativas

### P1 — Las monedas de jefe eran una fuente excesiva (corrige B4)

- **Problema:** 3 derrotas al día daban 1,6 horas de ingreso. Para un jugador de 1 hora diaria, más que todo lo demás junto.
- **Corrección aplicada:** `60 × V` por derrota. **Cambia B4:** tabla de multiplicadores, tabla de jefes y recompensas (E4-28 y E4-34).

### P2 — El saqueador puro gana menos de la mitad que un minero PvE

- **Dato:** 0,47 veces el PvE con 8 muertes por hora.
- **Por qué pasa:** una carga completa son 8,4 minutos de ingreso y el saqueador solo recoge el 35% de lo que lleva la víctima.
- **Alternativas:**

| Opción | Saqueador puro (× PvE) |
|---|---|
| Actual: 70% de lo soltado es recogible | 0,47 |
| 85% recogible (solo se destruye el 7,5% de la carga) | 0,55 |

- **Recomendación:** mantener el valor actual. Un saqueo poco rentable protege a los mineros, que son quienes sostienen el modo. El saqueador se recompensa con reputación y cosméticos de grieta, no con monedas. El perfil híbrido (mina y saquea) gana 1,87 veces el PvE y es el camino previsto.
- **Se valida en la Etapa 7** (saqueador profesional frente a minero PvE).

### P3 — La mochila de 60 unidades hacía irrelevante el saqueo (corrige B3)

- **Corrección aplicada:** contenedor de grieta de 120 unidades dentro de las Zonas Fracturadas. **Cambia B3** (sección 7).
- La racha se ha fijado en +2% por extracción (máximo +10%) para que el máximo teórico quede en 2,43 y no supere 2,5.

### P4 — Las cajas salían más baratas que fabricar

- **Problema:** a 0,5 horas, la Caja de armas contenía de media 0,96 horas de valor de fabricación.
- **Corrección aplicada:** Caja de armas a 1,0 hora y Caja de zona a 0,6.

### P5 — El coste del reinicio de estadísticas no encajaba (corrige B2)

- **Corrección aplicada:** 1,5 horas de ingreso de la zona del jugador, en lugar de `1.000 × nivel`. **Cambia B2** (E2-07).

### P6 — Morir en Zona Fracturada (pendiente de B3)

- **Decisión:** se mantiene el 50% soltado. Con el seguro, la víctima conserva el 37,5% del valor en vez del 25%, y el minero con un 30% de muertes sigue ganando 1,76–1,82 veces el PvE. No hace falta bajar el 50%.

### P7 — Los jugadores que lo tienen todo acumulan monedas

- **Dato:** en la simulación solo se contiene porque gastan en aspectos de prestigio.
- **Riesgo:** si esos cosméticos no interesan, el ahorro del 10% más rico crecerá.
- **Alternativa:** añadir en la Etapa 8 un sumidero ligado al renacimiento.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| Precios en horas de ingreso | Telemetría: horas reales hasta comprar cada objetivo; desviación menor del 25% |
| 15% del ingreso en cajas | Porcentaje real de gasto en cajas por perfil de jugador |
| Ahorro mediano | Debe mantenerse entre 3 y 6 horas de ingreso; por encima de 10, añadir sumideros |
| Probabilidad de morir en Zona Fracturada | Medirla por zona; las tablas de 7.5 dicen qué ingreso resulta |
| Seguro | Proporción de entradas aseguradas y relación pago/prima; objetivo, entre 40% y 70% |
| Saqueador | Monedas por hora reales de los jugadores con más muertes PvP |
