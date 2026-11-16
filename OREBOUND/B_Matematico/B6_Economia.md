# OREBOUND — B6: Economía

Etapa 6, rehecha con el GDD · 2026-11-16 · Script: `calculos/b6_economia.py` (genera este documento) · Precios: `calculos/b6_precios_minerales.csv` y `calculos/b6_precios_equipo.csv`.

> **Fuentes.** Esta versión usa el GDD de combate, minería PvPvE y mascotas. De él vienen la
> racha de extracción, el Seguro de carga fabricable, los contratos de grieta, los eventos de
> grieta, las cajas de Núcleos y las reglas de monetización. Sus cifras están pendientes de
> simulación: son **[PROVISIONAL]**. No se dispone del prompt maestro: todos los precios son
> propuestas **[PROVISIONAL]**. Son **[CONFIRMADO]**: nunca se venden Celestial, Núcleos
> Despertados ni el Seguro de carga; ningún estilo PvE gana más de 1,3 veces que otro; las
> Zonas Fracturadas no rinden más de 2,5 veces el PvE.

---

## 0. Unidad de precio: la hora de ingreso

Casi todos los precios se expresan en **horas de ingreso de la zona** (`I`): lo que gana en una hora un jugador equilibrado en esa zona. Así los precios suben solos con la zona.

| Zona | Valor de zona V | Minero (B3) | Combatiente (B4) | Ingreso de referencia I | I / V |
|---|---|---|---|---|---|
| 1 | 10 | 5.175 | 5.130 | 5.152 | 515 |
| 2 | 20 | 10.349 | 10.253 | 10.301 | 515 |
| 3 | 40 | 19.661 | 20.420 | 20.040 | 501 |
| 4 | 80 | 39.007 | 40.562 | 39.784 | 497 |
| 5 | 160 | 78.013 | 80.425 | 79.219 | 495 |
| 6 | 320 | 155.819 | 159.253 | 157.536 | 492 |
| 7 | 640 | 295.882 | 315.040 | 305.461 | 477 |
| 8 | 1.280 | 589.714 | 622.778 | 606.246 | 474 |
| 9 | 2.560 | 1.177.945 | 1.230.476 | 1.204.210 | 470 |
| 10 | 5.120 | 2.355.890 | 2.430.226 | 2.393.058 | 467 |

- `V(z) = 10 × 2,00^(z−1)` es el valor de zona de B3.
- `I(z)` es la media del minero y el combatiente equilibrados; equivale a unas 490 veces `V`.
- Con mascotas típicas el ingreso real es un 22% mayor (B5).

---

## 1. Recursos: cómo entran y cómo salen

| Recurso | Cómo entra | Cómo sale |
|---|---|---|
| Monedas | Venta de minerales; enemigos y jefes; misiones (10% extra); contratos de grieta | Fabricación y mejoras; cajas; consumibles; mochila; evolución de mascotas; reinicio de estadísticas; aspectos de prestigio |
| Minerales | Depósitos; Cofres de Saqueo; lotes de la Caja de zona | Venta; recetas de fabricación, incluido el Seguro de carga; 10% de la carga destruido en cada muerte PvP |
| Cristales | Misiones, logros, temporada; compra con Robux | Cosméticos, almacén de mascotas, tercera incubadora, pase de temporada |
| Materiales de jefe | 3 por derrota de jefe, máximo 3 derrotas con botín por jefe y día | Equipo Legendario o superior; forma desatada máxima; Despertar de Núcleos |
| Fragmentos elementales | Élites y Guardianes de las zonas de cada elemento; liberar mascotas duplicadas | Forma desatada de las mascotas |
| Gemas antiguas | Contrato semanal de grieta; primera derrota semanal de cada jefe; temporada | Equipo Ultra raro; Despertar de Núcleos |
| Fragmentos Celestiales | Depósitos de Zonas Fracturadas de zona 6 o más, Grieta Celestial y jefes de evento (B1) | 50 fragmentos + 10 horas de ingreso en monedas = 1 objeto Celestial |

- Los Cristales **no se pueden cambiar por monedas** ni compran cajas. Ninguna recompensa aleatoria se paga con dinero real (sección 9).
- Materiales de jefe, fragmentos y gemas antiguas no se venden ni se comercian.
- No hay comercio entre jugadores en el lanzamiento.

---

## 2. Tablas de precios

### 2.1 Venta de minerales (monedas por unidad)

| Zona | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|
| 1 | 2,5 | 4,5 | 10,7 | 20,0 | 60,0 | 125,0 | 600,0 |
| 2 | 5,0 | 9,0 | 21,3 | 40,0 | 120,0 | 250,0 | 1.200,0 |
| 3 | 10,0 | 18,0 | 42,7 | 80,0 | 240,0 | 500,0 | 2.400,0 |
| 4 | 20,0 | 36,0 | 85,3 | 160,0 | 480,0 | 1.000,0 | 4.800,0 |
| 5 | 40,0 | 72,0 | 170,7 | 320,0 | 960,0 | 2.000,0 | 9.600,0 |
| 6 | 80,0 | 144,0 | 341,3 | 640,0 | 1.920,0 | 4.000,0 | 19.200,0 |
| 7 | 160,0 | 288,0 | 682,7 | 1.280,0 | 3.840,0 | 8.000,0 | 38.400,0 |
| 8 | 320,0 | 576,0 | 1.365,3 | 2.560,0 | 7.680,0 | 16.000,0 | 76.800,0 |
| 9 | 640,0 | 1.152,0 | 2.730,7 | 5.120,0 | 15.360,0 | 32.000,0 | 153.600,0 |
| 10 | 1.280,0 | 2.304,0 | 5.461,3 | 10.240,0 | 30.720,0 | 64.000,0 | 307.200,0 |

- `Precio = V(z) × FactorValor / Unidades` (B3). El listado por mineral está en el CSV.
- El mineral fracturado extraído vale ×1,5 por el multiplicador de racha (sección 7).

### 2.2 Picos y armas: fabricación y mejoras

Un pico y un arma de la misma zona y rareza cuestan lo mismo.

| Rareza | Monedas (horas de ingreso) | Receta (minerales de la zona) | Horas de minería para el material más escaso | Valor de venta de los materiales (horas) | Niveles 1–10 (horas) | 3 ranuras (horas) | Despertar de habilidad (horas) | Total al máximo (horas) |
|---|---|---|---|---|---|---|---|---|
| Común | 0,3 | 30 Lingotes Común | 0,1 | 0,02 | 0,82 | 0,45 | 0,45 | 2,0 |
| Poco común | 0,6 | 40 Lingotes Común + 20 Lingotes Poco común | 0,1 | 0,04 | 1,65 | 0,90 | 0,90 | 4,0 |
| Raro | 1,2 | 30 Lingotes Poco común + 15 Placas Raro | 0,2 | 0,06 | 3,30 | 1,80 | 1,80 | 8,1 |
| Épico | 2,5 | 30 Placas Raro + 10 Gemas talladas | 0,3 | 0,11 | 6,88 | 3,75 | 3,75 | 16,9 |
| Legendario | 5,0 | 20 Gemas talladas + 8 Núcleos de mena + 2 de jefe | 0,8 | 0,18 | 13,75 | 7,50 | 7,50 | 33,8 |
| Mítico | 10,0 | 15 Núcleos de mena + 6 Catalizadores + 4 de jefe | 2,7 | 0,34 | 27,50 | 15,00 | 15,00 | 67,5 |
| Ultra raro | 20,0 | 10 Catalizadores + 4 Esencias + 6 de jefe + 1 gema antigua | 32,2 | 0,74 | 55,00 | 30,00 | 30,00 | 135,0 |

Coste de fabricación en monedas, por zona:

| Zona | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|
| 1 | 1.546 | 3.092 | 6.183 | 12.881 | 25.762 | 51.525 | 103.050 |
| 2 | 3.090 | 6.181 | 12.361 | 25.752 | 51.505 | 103.010 | 206.020 |
| 3 | 6.012 | 12.024 | 24.049 | 50.101 | 100.202 | 200.405 | 400.810 |
| 4 | 11.935 | 23.871 | 47.741 | 99.461 | 198.922 | 397.845 | 795.690 |
| 5 | 23.766 | 47.531 | 95.063 | 198.048 | 396.095 | 792.190 | 1.584.380 |
| 6 | 47.261 | 94.522 | 189.043 | 393.840 | 787.680 | 1.575.360 | 3.150.720 |
| 7 | 91.638 | 183.277 | 366.553 | 763.652 | 1.527.305 | 3.054.610 | 6.109.220 |
| 8 | 181.874 | 363.748 | 727.495 | 1.515.615 | 3.031.230 | 6.062.460 | 12.124.920 |
| 9 | 361.263 | 722.526 | 1.445.053 | 3.010.526 | 6.021.052 | 12.042.105 | 24.084.210 |
| 10 | 717.917 | 1.435.835 | 2.871.670 | 5.982.645 | 11.965.290 | 23.930.580 | 47.861.160 |

- **Mejoras:** nivel `n` cuesta `0,05 × n ×` el coste base; cada ranura, 0,5 veces el base y 6 Gemas talladas; el Despertar de habilidad, 1,5 veces el base y 4 Catalizadores. Dan +25%, +15% y +10% de potencia (B1).
- **En zonas sin depósitos Ultra raro** (1, 2, 4 y 6), el equipo Ultra raro pide 16 Catalizadores en lugar de las 4 Esencias.
- **Venta al mercader:** 10% del coste de fabricación. **Reciclaje:** devuelve el 30% de los materiales de las mejoras.
- **Celestial:** no se fabrica con minerales; solo con fragmentos.
- Un objeto Ultra raro al máximo cuesta 135 horas de ingreso y su material más escaso pide 32,2 horas de minería.

### 2.3 Mochila

| Capacidad | Disponible desde la zona | Precio (horas de I de esa zona) | Monedas |
|---|---|---|---|
| 80 | 2 | 0,5 | 5.150 |
| 100 | 3 | 1,0 | 20.040 |
| 120 | 4 | 2,0 | 79.569 |
| 140 | 5 | 3,0 | 237.657 |
| 160 | 6 | 5,0 | 787.680 |
| 180 | 8 | 8,0 | 4.849.968 |
| 200 | 10 | 12,0 | 28.716.696 |

### 2.4 Consumibles y servicios

| Concepto | Precio | Zona 1 | Zona 5 | Zona 10 |
|---|---|---|---|---|
| Poción de vida (cura 30%) | 0,01 h | 52 | 792 | 23.931 |
| Tónico de energía (+100 de energía) | 0,01 h | 52 | 792 | 23.931 |
| Elixir de Suerte (+100 de Suerte, 15 min) | 0,10 h | 515 | 7.922 | 239.306 |
| Pergamino de XP (+25%, 30 min) | 0,15 h | 773 | 11.883 | 358.959 |
| Sello de Reajuste (cambiar de Núcleo fuera de la ciudad) | 0,05 h | 258 | 3.961 | 119.653 |
| Reinicio de estadísticas | 1,5 h | 7.729 | 118.828 | 3.589.587 |
| Evolución a forma desatada (por mascota) | 2 h | 10.305 | 158.438 | 4.786.116 |
| Evolución a forma máxima (por mascota) | 8 h | 41.220 | 633.752 | 19.144.464 |
| Forjar un objeto Celestial (más 50 fragmentos) | 10 h | 51.525 | 792.190 | 23.930.580 |
| Aspecto de prestigio (cosmético) | 20 h | 103.050 | 1.584.380 | 47.861.160 |

- No hay reparaciones ni durabilidad.
- El reinicio de estadísticas es gratis por debajo del nivel 50.

---

## 3. Recompensas de enemigos y jefes por zona

| Zona | Común: monedas | Élite | Guardián | Jefe (por jugador) | Común: XP | Élite | Guardián | Jefe | Material de jefe |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 14 | 56 | 168 | 600 | 154 | 540 | 1.544 | 9.265 | 3 |
| 2 | 28 | 112 | 336 | 1.200 | 449 | 1.572 | 4.491 | 26.944 | 3 |
| 3 | 56 | 224 | 672 | 2.400 | 772 | 2.702 | 7.721 | 46.328 | 3 |
| 4 | 112 | 448 | 1.344 | 4.800 | 1.124 | 3.933 | 11.236 | 67.414 | 3 |
| 5 | 224 | 896 | 2.688 | 9.600 | 1.503 | 5.262 | 15.034 | 90.206 | 3 |
| 6 | 448 | 1.792 | 5.376 | 19.200 | 1.912 | 6.691 | 19.117 | 114.700 | 3 |
| 7 | 896 | 3.584 | 10.752 | 38.400 | 2.348 | 8.219 | 23.483 | 140.900 | 3 |
| 8 | 1.792 | 7.168 | 21.504 | 76.800 | 2.813 | 9.847 | 28.134 | 168.802 | 3 |
| 9 | 3.584 | 14.336 | 43.008 | 153.600 | 3.307 | 11.574 | 33.068 | 198.410 | 3 |
| 10 | 7.168 | 28.672 | 86.016 | 307.200 | 3.829 | 13.400 | 38.287 | 229.720 | 3 |

- Monedas: `V(z) ×` 1,40 (Común), 5,60 (Élite), 16,80 (Guardián) y 60 (Jefe). Los tres primeros los calibra B4 para igualar al minero.
- El jefe da el equivalente a 7,3 minutos de ingreso por unos 8 de combate; su valor está en los materiales de jefe y en la posibilidad de un Núcleo.

---

## 4. Ingresos y gastos por hora

Jugador equilibrado con mascotas típicas (+22%). Consumibles: 5% del ingreso base. Cajas: 15%. El equipo es el gasto medio por hora de los objetivos que se pueden pagar durante la estancia en la zona.

| Zona | Estilo | Ingresos/hora | Consumibles/hora | Cajas/hora | Equipo y mejoras/hora | Ahorro/hora | Ingresos frente al minero PvE |
|---|---|---|---|---|---|---|---|
| 1 | Minero PvE | 6.314 | 259 | 776 | 3.701 | 1.578 | 1,00 |
| 1 | Combatiente PvE | 6.259 | 256 | 770 | 3.701 | 1.532 | 0,99 |
| 1 | Zona Fracturada (minero, 30% de muertes, con seguro) | 10.426 | 598 | 1.282 | 3.701 | 4.845 | 1,65 |
| 3 | Minero PvE | 23.986 | 983 | 2.949 | 8.759 | 11.295 | 1,00 |
| 3 | Combatiente PvE | 24.912 | 1.021 | 3.063 | 8.759 | 12.070 | 1,04 |
| 3 | Zona Fracturada (minero, 30% de muertes, con seguro) | 39.611 | 2.273 | 4.870 | 8.759 | 23.709 | 1,65 |
| 5 | Minero PvE | 95.176 | 3.901 | 11.702 | 71.752 | 7.821 | 1,00 |
| 5 | Combatiente PvE | 98.118 | 4.021 | 12.064 | 71.752 | 10.281 | 1,03 |
| 5 | Zona Fracturada (minero, 30% de muertes, con seguro) | 157.173 | 9.018 | 19.325 | 71.752 | 57.078 | 1,65 |
| 8 | Minero PvE | 719.451 | 29.486 | 88.457 | 501.797 | 99.711 | 1,00 |
| 8 | Combatiente PvE | 759.789 | 31.139 | 93.417 | 501.797 | 133.436 | 1,06 |
| 8 | Zona Fracturada (minero, 30% de muertes, con seguro) | 1.188.098 | 68.170 | 146.078 | 501.797 | 472.053 | 1,65 |
| 10 | Minero PvE | 2.874.186 | 117.794 | 353.384 | 1.691.338 | 711.669 | 1,00 |
| 10 | Combatiente PvE | 2.964.876 | 121.511 | 364.534 | 1.691.338 | 787.492 | 1,03 |
| 10 | Zona Fracturada (minero, 30% de muertes, con seguro) | 4.746.415 | 272.335 | 583.576 | 1.691.338 | 2.199.166 | 1,65 |

- **Combatiente frente a minero:** entre 0,99 y 1,06. El límite era 1,3.
- **Zona Fracturada:** 1,65 veces el minero PvE con un 30% de muertes y usando seguro. El límite era 2,5.
- El jugador PvE gasta entre el 52% y el 92% de lo que gana mientras sube de zona.

### 4.1 Qué equipo se puede pagar en cada zona

| Zona | Horas de juego en la zona | Ingreso disponible (horas de I) | Último objetivo de equipo que se puede pagar |
|---|---|---|---|
| 1 | 5,8 | 6,0 | Niveles 1–5 de ambos |
| 2 | 13,8 | 14,1 | Pico y arma Épicos |
| 3 | 21,0 | 21,5 | Pico y arma Épicos |
| 4 | 27,6 | 28,2 | Niveles 1–10 de ambos |
| 5 | 33,6 | 34,3 | Ranuras de ambos |
| 6 | 39,1 | 39,9 | Ranuras de ambos |
| 7 | 44,2 | 45,1 | Pico y arma Legendarios |
| 8 | 48,9 | 49,8 | Pico y arma Legendarios |
| 9 | 53,2 | 54,3 | Pico y arma Legendarios |
| 10 | 57,2 | 58,4 | Pico y arma Legendarios |

Las horas en cada zona usan la curva de XP de B2. Mítico y Ultra raro son objetivos de final de juego.

### 4.2 Simulación pedida por el GDD: zonas 2, 5 y 8

| Zona | Minero PvE (monedas/hora) | Minero de grieta, 30% de muertes | × PvE | Saqueador puro | × PvE |
|---|---|---|---|---|---|
| 2 | 10.349 | 17.395 | 1,68 | 4.302 | 0,42 |
| 5 | 78.013 | 131.126 | 1,68 | 32.431 | 0,42 |
| 8 | 589.714 | 991.204 | 1,68 | 245.151 | 0,42 |

---

## 5. Cajas

Todas las cajas estándar se compran solo con monedas. Usan la tabla de rarezas de B1 y su protección contra mala suerte, con contadores separados por tipo de caja.

| Caja | Precio (horas de I) | Zona 1 | Zona 3 | Zona 5 | Zona 8 | Zona 10 | Valor medio del contenido (horas) | Valor de reventa (horas) |
|---|---|---|---|---|---|---|---|---|
| De armas | 1,00 | 5.152 | 20.040 | 79.219 | 606.246 | 2.393.058 | 0,96 | 0,10 |
| De zona | 0,60 | 3.092 | 12.024 | 47.531 | 363.748 | 1.435.835 | 0,57 | 0,25 |
| De mascotas | 0,75 | 3.864 | 15.030 | 59.414 | 454.684 | 1.794.794 | — | 0 (no se venden) |
| De Núcleos | 3,00 | 15.458 | 60.122 | 237.657 | 1.818.738 | 7.179.174 | — | 0 (no se venden) |

- Las cajas de mascotas y de Núcleos se pagan según la zona más alta que el jugador tenga desbloqueada.
- Ninguna caja genera monedas: el contenido vale de media menos que el precio y la reventa devuelve una fracción.
- **Caja frente a fabricar:** un arma Legendaria o superior de un tipo concreto requiere de media 135 Cajas de armas; fabricarla cuesta 5 horas y sus materiales.

### 5.1 Caja de armas

- Tipo: Espada 17%, Hacha 17%, Daga 17%, Lanza 17%, Bastón 16%, Arco 16% (suma 100%).
- Rareza: Común 50%, Poco común 26%, Raro 14%, Épico 7%, Legendario 2,4%, Mítico 0,5%, Ultra raro 0,1% (suma 100%).

### 5.2 Caja de mascotas

| Huevo | Rareza | Probabilidad |
|---|---|---|
| Topillo de Pizarra | Común | 25,0% |
| Luciérnaga de Veta | Común | 25,0% |
| Zorro de Ascua | Poco común | 13,0% |
| Tortuga Geoda | Poco común | 13,0% |
| Murciélago de Eco | Raro | 7,0% |
| Nutria Salina | Raro | 7,0% |
| Búho Boreal | Épico | 3,5% |
| Carnero de Magma | Épico | 3,5% |
| Mantis Vitral | Legendario | 1,2% |
| Guiverno de Cuarzo | Legendario | 1,2% |
| Ciervo Astral | Mítico | 0,5% |
| Sierpe de Nova | Ultra raro | 0,1% |
| **Suma** |  | **100,0%** |

### 5.3 Caja de zona

| Categoría | Probabilidad | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|---|
| Pico de la zona | 35% | 17,500% | 9,100% | 4,900% | 2,450% | 0,840% | 0,175% | 0,035% |
| Lote de minerales de la zona | 40% | 20,000% | 10,400% | 5,600% | 2,800% | 0,960% | 0,200% | 0,040% |
| Materiales de fabricación | 15% | 7,500% | 3,900% | 2,100% | 1,050% | 0,360% | 0,075% | 0,015% |
| Lote de consumibles | 10% | 5,000% | 2,600% | 1,400% | 0,700% | 0,240% | 0,050% | 0,010% |
| **Suma** | **100%** | 50,0% | 26,0% | 14,0% | 7,0% | 2,4% | 0,5% | 0,1% |

Los lotes valen, según rareza, 0,15 / 0,25 / 0,4 / 0,8 / 2 / 5 / 12 horas de ingreso en minerales o materiales de la zona.

### 5.4 Caja de Núcleos (GDD)

| Núcleo | Rareza | Probabilidad |
|---|---|---|
| Núcleo de Brasa | Raro | 30% |
| Núcleo de Escarcha | Raro | 30% |
| Núcleo Prismático | Épico | 15% |
| Núcleo de Tormenta | Épico | 15% |
| Núcleo Sísmico | Legendario | 5% |
| Núcleo Umbrío | Legendario | 5% |
| **Suma** |  | **100%** |

- Un Núcleo repetido se convierte en 200 puntos de maestría de ese Núcleo.
- Conseguir los seis solo con cajas requiere de media 31,5 cajas (94 horas de ingreso). Por eso existen las otras vías del GDD: cada jefe suelta su Núcleo asociado con un 1% por derrota, hay Núcleos como recompensa de evento y como reliquia rara en depósitos Mítico o superior de las zonas 7 a 10.
- La protección contra mala suerte se aplica igual: Legendario garantizado en 50 aperturas.

### 5.5 Caja de evento

- No se compra: se gana con fichas del evento. Tabla de B1: Raro 45%, Épico 33%, Legendario 15%, Mítico 5%, Ultra raro 1,5%, Celestial 0,5% (suma 100%).
- Es la única caja que puede dar Celestial y no admite Suerte.

---

## 6. Sumideros contra la inflación

| Sumidero | Tamaño |
|---|---|
| Fabricación | 0,3 a 20 horas de ingreso por objeto; se repite en cada zona |
| Mejoras | 5,75 veces el coste base por objeto al máximo; el mayor sumidero del juego |
| Cajas | Alrededor del 15% del ingreso |
| Consumibles | Alrededor del 5% del ingreso |
| Mochila | 31,5 horas de ingreso en total, una sola vez |
| Evolución de mascotas | 2 y 8 horas por mascota |
| Destrucción en el saqueo (GDD) | 20% de lo que se suelta en cada muerte PvP: sale mineral, no monedas |
| Seguro de carga | Minerales por valor de 4,7 V por entrada |
| Aspectos de prestigio | 20 horas cada uno, sin límite |
| Reparaciones | No hay |

### 6.1 Simulación: 1.000 jugadores durante 90 días

- 500 casuales (0,5 h al día), 350 regulares (1,5 h) y 150 dedicados (4 h); cada uno juega 4 de cada 5 días.
- Cada jugador gana según su zona, gasta en consumibles y cajas, y compra el siguiente objetivo de equipo cuando le alcanza. Los que ya lo tienen todo gastan la mitad de lo que supere 10 horas de ahorro en aspectos de prestigio.

| Día | Masa monetaria total | Entra ese día | Sale ese día | Sale / entra | Ahorro mediano (horas de ingreso) | Ahorro del 10% más rico (horas) | Zona media | Nivel máximo | Ahorro mediano sin sumideros (horas) |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 4.670.779 | 8.690.616 | 4.019.837 | 46% | 1,0 | 2,0 | 1,0 | 93 | 1,1 |
| 7 | 19.061.848 | 20.850.136 | 18.661.143 | 90% | 1,3 | 3,9 | 1,6 | 259 | 6,3 |
| 14 | 58.954.591 | 31.979.077 | 25.528.543 | 80% | 3,5 | 9,8 | 2,0 | 374 | 10,8 |
| 30 | 131.406.945 | 93.560.971 | 90.519.769 | 97% | 3,6 | 10,8 | 2,9 | 535 | 22,6 |
| 60 | 667.802.654 | 396.870.156 | 330.894.613 | 83% | 3,7 | 9,1 | 4,3 | 786 | 35,2 |
| 90 | 2.400.810.929 | 1.297.587.001 | 1.299.725.527 | 100% | 4,7 | 11,4 | 5,0 | 984 | 47,6 |

- **La masa monetaria total crece** (de 4,7 a 2.401 millones) porque los jugadores suben de zona y cada zona paga el doble. No es inflación.
- **La medida correcta es el ahorro en horas de ingreso:** el jugador mediano se mantiene entre 3,5 y 4,7 horas desde el día 14, y el 10% más rico entre 9 y 11.
- **Sin sumideros**, el jugador mediano tendría 47,6 horas de ingreso ahorradas el día 90.

---

## 7. Sistema de riesgo de las Zonas Fracturadas (GDD)

### 7.1 Racha de extracción

- Cada extracción seguida sin morir sube un multiplicador de valor: ×1,1, ×1,2… hasta ×1,5. Morir lo reinicia.
- Multiplica al valor base del mineral fracturado (×1,5); la tabla completa está en B3, sección 7.2.
- Una carga completa de grieta (120 unidades) vale 66,7 V en base: 8,2 minutos de ingreso PvE.

### 7.2 Seguro de carga

- **Qué es (GDD):** un consumible fabricable con minerales que protege el 50% de una carga. Se fabrica; **nunca se compra con Robux** **[CONFIRMADO]**.
- **Receta propuesta:** 8 Lingotes Poco común y 1 Placa Raro de la zona (valor de venta 4,7 V, el 7,0% de una carga completa).
- **Efecto:** se activa al entrar y dura esa carrera. Si el jugador muere contra otro jugador, suelta el 25% de la carga en lugar del 50%.
- **Límite propuesto:** 5 al día.

| Prob. de morir por viaje | Ingresos sin seguro (× PvE) | Con seguro (× PvE) | Diferencia |
|---|---|---|---|
| 15% | 1,92 | 1,87 | -2,8% |
| 30% | 1,58 | 1,55 | -1,9% |
| 50% | 1,24 | 1,24 | 0,5% |
| 70% | 0,94 | 0,99 | 5,2% |

- El seguro solo compensa en monedas a quien muere en más del 47% de los viajes. Para los demás es un gasto: da control al jugador prudente sin romper el riesgo, como pide el GDD.

### 7.3 Contratos de grieta

| Parámetro | Valor | Origen |
|---|---|---|
| Contratos diarios | 3 | Propuesta |
| Tipos | «Extrae 3 minerales de una rareza concreta» y «Derrota a 2 portadores con carga alta» (Carga 5 o más) | GDD |
| Recompensa | 0,20 horas de ingreso al día entre los tres | Propuesta |
| Contrato semanal | 5 extracciones seguidas: 2 gemas antiguas | Propuesta |
| Salvaguarda | Un contrato de derrotar portadores se puede cambiar una vez al día por uno de extracción | Propuesta |

### 7.4 Otros sistemas de riesgo

| Sistema | Cómo funciona (GDD) | Valores propuestos |
|---|---|---|
| Recompensa por cabeza | Un jugador con racha de 5 o más queda marcado; quien lo derrote gana un bono | El vencedor recoge el 100% de lo soltado (no se destruye el 20%): ×1,25 de botín |
| Grieta Celestial | Evento cada 2 horas: zona temporal con fragmentos Celestiales y PvP más intenso, anunciada 5 minutos antes | Dura 10 minutos; fragmentos ×4 (B1); sin protección al reaparecer |
| Escuadrones | Grupos de hasta 3 con carga compartida y extracción más rápida | Canalización de 6 s con 2 y de 5 s con 3 a menos de 10 studs; el cofre de un compañero derrotado lo recoge el escuadrón sin esperar |
| Rastro de venganza | Quien te derrotó aparece marcado para ti durante 3 minutos si sigue en la zona | Derrotarlo devuelve la exclusividad sobre tu propio cofre si aún existe |
| Jefes de grieta | Aparecen cuando muchos jugadores luchan en la misma zona | Con 6 o más jugadores en combate en 5 minutos; da 2 materiales de jefe a cada participante y ninguna moneda |
| Temporadas de grieta | 8 semanas, con clasificación por valor extraído y premios cosméticos (auras, estelas, marcos); se reinicia la clasificación, no el progreso | — |

Ninguno de estos sistemas crea monedas: reparten mineral que ya existe o dan materiales y cosméticos.

### 7.5 Efecto en la economía

Ingresos por hora en Zona Fracturada, relativos al minero PvE de la misma zona.

| Perfil | Minería (× PvE) | Saqueo (× PvE) | Contratos (× PvE) | Total (× PvE) | ¿Bajo el techo de 2,5? |
|---|---|---|---|---|---|
| Minero de grieta prudente (15% de muertes) | 1,92 | 0,00 | 0,10 | 2,02 | Sí |
| Minero de grieta (30%) | 1,58 | 0,00 | 0,10 | 1,68 | Sí |
| Minero de grieta en servidor hostil (50%) | 1,24 | 0,00 | 0,10 | 1,34 | Sí |
| Híbrido: mina (25%) y derrota a 1,5 portadores por hora | 1,51 | 0,06 | 0,10 | 1,67 | Sí |
| Saqueador puro: 8 derrotas por hora | 0,00 | 0,32 | 0,10 | 0,42 | Sí |
| Máximo teórico: sin muertes y racha completa | 2,38 | 0,00 | 0,10 | 2,48 | Sí |

- **Todos los perfiles quedan por debajo de 2,5.** El máximo teórico con contratos es 2,48.
- El minero de grieta gana 2,02, 1,68 o 1,34 veces el PvE con un 15%, 30% o 50% de muertes.
- El perfil que mina y saquea gana 1,67; el saqueador puro, 0,42.

---

## 8. Resumen de límites

| Límite | Exigido | Obtenido |
|---|---|---|
| Combatiente frente a minero (equilibrados) | ≤ 1,30 | 0,99 – 1,06 |
| Zona Fracturada frente a PvE, con 15% a 50% de muertes | ≤ 2,50 | 1,34 – 2,02 |
| Zona Fracturada frente a PvE, máximo teórico | ≤ 2,50 | 2,48 |
| Sexto espacio de mascota (B5) | ≤ +5% | +2,4% |

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
| Sexto espacio de mascota | Robux, o 60 Fragmentos de temporada gratis | +2,4% de monedas por hora en PvE; nada en PvP |
| Pestañas de banco y segunda cola de fabricación | Cristales | No |

### 9.2 Qué no se vende nunca

- Objetos, armas, picos o mascotas **Celestiales**, ni sus fragmentos **[CONFIRMADO]**.
- **Núcleos Despertados**, ni los materiales del Despertar **[CONFIRMADO]**.
- El **Seguro de carga** **[CONFIRMADO]**.
- Monedas, minerales, materiales de jefe o gemas antiguas.
- Suerte, Elixires de Suerte o cualquier aumento de probabilidad en cajas.
- Cajas de cualquier tipo, incluidas las de Núcleos: en el lanzamiento solo se compran con monedas ganadas jugando.
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

El GDD pide lo mismo: mostrar las probabilidades exactas antes de abrir, consultar `ArePaidRandomItemsRestricted` y revisar la política vigente antes de lanzar.

**Cómo cumple OREBOUND.**

1. **En el lanzamiento no hay recompensas aleatorias de pago.** Las cajas se compran solo con monedas, y las monedas no se pueden comprar ni obtener a partir de Cristales o Robux.
2. Aun así, cada caja muestra sus probabilidades numéricas y el texto de las garantías antes de abrirla.
3. Con un Elixir de Suerte activo, la pantalla de la caja muestra las probabilidades ya modificadas.
4. El servidor consulta `PolicyService` al entrar cada jugador y guarda el resultado. Si en el futuro alguna caja pasa a venderse por Robux o Cristales, se oculta a quien tenga `ArePaidRandomItemsRestricted` y se le ofrece la compra directa del objeto.
5. Si se añade comercio entre jugadores, se consulta también `IsPaidItemTradingAllowed`.

---

## 10. Problemas de balance detectados y alternativas

### P1 — La racha del GDD obligó a bajar el multiplicador base

- Con mineral al doble y racha de ×1,5, el máximo teórico era 3,17 veces el PvE. Con base ×1,5 queda en 2,48 con contratos.
- **Efecto:** el minero que muere a menudo gana menos que en la primera versión (1,34 veces el PvE con un 50% de muertes). La grieta premia encadenar extracciones.

### P2 — El saqueador puro gana menos que un minero PvE

- **Dato:** 0,42 veces el PvE con 8 derrotas por hora, incluso con el 80% recogible del GDD.
- **Por qué pasa:** una carga completa son 8,2 minutos de ingreso y el saqueador recoge el 40% de lo que lleva la víctima.
- **Recomendación:** mantenerlo. El GDD señala a los saqueadores profesionales como riesgo («cazar portadores puede rendir más que minar»); con estos valores no ocurre. Sus incentivos son la recompensa por cabeza, los contratos y la clasificación de temporada. Se valida en B7.

### P3 — Los contratos de derrotar portadores premian el PvP

- **Riesgo:** empujar a cazar a jugadores que solo quieren minar.
- **Salvaguardas:** piden portadores con Carga 5 o más (no novatos), la recompensa es pequeña y el contrato se puede cambiar por uno de extracción.

### P4 — El Seguro de carga casi nunca compensa en monedas

- **Dato:** solo sale a cuenta a partir del 47% de muertes.
- **Valoración:** es lo que busca el GDD (control para el jugador prudente). Si en la beta nadie lo fabrica, abaratar la receta a la mitad.

### P5 — Reunir los seis Núcleos solo con cajas es caro

- **Dato:** 94 horas de ingreso de media. Es intencionado: los Núcleos Legendarios deben venir sobre todo de jefes y eventos.

### P6 — Los jugadores que lo tienen todo acumulan monedas

- En la simulación solo se contiene con los aspectos de prestigio. El renacimiento (A_GDD) añade el sumidero de final de juego.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| Precios en horas de ingreso | Telemetría: horas reales hasta comprar cada objetivo; desviación menor del 25% |
| Ahorro mediano | Debe mantenerse entre 3 y 6 horas de ingreso |
| Multiplicador base ×1,5 y racha | Ingresos reales de grieta frente a PvE por zona |
| Probabilidad de morir en Zona Fracturada | Medirla por zona; las tablas de 7.5 dicen qué ingreso resulta |
| Seguro | Proporción de entradas aseguradas |
| Saqueador | Monedas por hora reales de los jugadores con más derrotas PvP; alarma por encima de 1,0 veces el minero PvE |
| Cajas de Núcleos | Aperturas reales hasta completar los seis |
