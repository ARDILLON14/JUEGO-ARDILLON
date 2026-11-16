# OREBOUND — B3: Minería

Etapa 3, rehecha con el GDD · 2026-11-16 · Script: `calculos/b3_mineria.py` (genera este documento) · Catálogos: `calculos/b3_minerales.csv` (66 minerales) y `calculos/b3_picos.csv` (75 picos).

> **Fuentes.** Esta versión usa el GDD de combate, minería PvPvE y mascotas. De él vienen las
> reglas de las Zonas Fracturadas (debuff de carga, saqueo, extracción, protecciones), la
> estructura de los picos y el nombre de la zona 7. El GDD marca sus cifras como pendientes de
> simulación: son **[PROVISIONAL]**. No se dispone del prompt maestro: los 30 minerales de
> referencia y los nombres de las demás zonas siguen siendo propuestas **[PROVISIONAL]**.
> Son **[CONFIRMADO]**: mina PvE, una Zona Fracturada por zona, solo se arriesga el mineral y
> el 20% de pérdida en PvE. El 50% soltado en Zona Fracturada sigue **[PROVISIONAL]**.

---

## 1. Las 10 zonas

| Zona | Nombre | Nivel | Minería requerida | Potencia de pico requerida | PotZona | Dureza | Ultra raro |
|---|---|---|---|---|---|---|---|
| 1 | Cantera del Alba | 1 | 0 | 50 | 100 | 1,0 | No |
| 2 | Galerías de Musgo | 100 | 10 | 100 | 200 | 1,1 | No |
| 3 | Vetas Salinas | 200 | 20 | 200 | 400 | 1,2 | Sí |
| 4 | Grutas de Brasa | 300 | 30 | 400 | 800 | 1,3 | No |
| 5 | Sima Helada | 400 | 40 | 800 | 1.600 | 1,4 | Sí |
| 6 | Bóveda de Ecos | 500 | 50 | 1.600 | 3.200 | 1,5 | No |
| 7 | Minas Oscuras | 600 | 60 | 3.200 | 6.400 | 1,6 | Sí |
| 8 | Mar de Magma | 700 | 70 | 6.400 | 12.800 | 1,7 | Sí |
| 9 | Catedral de Cristal | 800 | 80 | 12.800 | 25.600 | 1,8 | Sí |
| 10 | Núcleo Astral | 900 | 90 | 25.600 | 51.200 | 1,9 | Sí |

### F13 — Requisitos de zona

- **Nivel:** `Nivel(z) = 100 × (z − 1)`, con la zona 1 abierta desde el nivel 1.
- **Minería requerida:** `10 × (z − 1)`.
- **Potencia de pico requerida:** `0,5 × PotZona(z)`, con `PotZona(z) = 100 × 2,00^(z−1)` (B1).
- **Dureza:** `mín(2,0; 1 + 0,1 × (z − 1))`. Multiplica la vida de los depósitos para compensar que el jugador medio tiene más Minería en zonas altas.
- **Ejemplo:** zona 5 → nivel 400, Minería 40, pico de potencia 800 o más.
- **Límites:** el requisito de pico (0,5) lo cumple justo un pico Común de la zona anterior (`1/2,00 = 0,5`). Nadie queda bloqueado por no tener suerte con el pico.
- **Posibles problemas:** si cambia el crecimiento por zona, hay que recalcular el 0,5.
- La zona 7 se llama «Minas Oscuras» por el GDD. Los demás nombres son propuestos.

### F14 — Minería requerida por depósito

- **Expresión:** `MineríaReq(z, r) = 10 × (mín(z, 10) − 1) × FactorReq(r)`
- **Ejemplo:** depósito Mítico de zona 8 → `10 × 7 × 5 = 350` de Minería.
- **Límites:** el máximo es 630 (Ultra raro de zona 10), por debajo del tope de 1.000 puntos. En zonas por encima de la 10 se queda en el valor de la zona 10 (B7).

### 1.1 Comprobación con tres builds

Cada build se mide al nivel de entrada de la zona, con el pico Raro de la zona anterior. El porcentaje es la parte de los puntos puesta en Minería.

| Zona | Build | Minería al entrar | ¿Entra? | Rareza máxima que puede picar | Mult. Minería | s por depósito Común con el pico anterior |
|---|---|---|---|---|---|---|
| 1 | Minería (50%) | 1 | Sí | Mítico | 1,00 | 6,0 |
| 1 | Equilibrada (12,5%) | 0 | Sí | Mítico | 1,00 | 6,0 |
| 1 | Combate (5%) | 0 | Sí | Mítico | 1,00 | 6,0 |
| 2 | Minería (50%) | 150 | Sí | Mítico | 1,39 | 6,7 |
| 2 | Equilibrada (12,5%) | 37 | Sí | Legendario | 1,11 | 7,7 |
| 2 | Combate (5%) | 15 | Sí | Raro | 1,04 | 8,7 |
| 3 | Minería (50%) | 300 | Sí | Ultra raro | 1,69 | 5,8 |
| 3 | Equilibrada (12,5%) | 75 | Sí | Legendario | 1,21 | 7,7 |
| 3 | Combate (5%) | 30 | Sí | Raro | 1,09 | 8,7 |
| 4 | Minería (50%) | 450 | Sí | Mítico | 1,93 | 5,8 |
| 4 | Equilibrada (12,5%) | 112 | Sí | Legendario | 1,30 | 7,7 |
| 4 | Combate (5%) | 45 | Sí | Raro | 1,13 | 9,6 |
| 5 | Minería (50%) | 600 | Sí | Ultra raro | 2,12 | 5,8 |
| 5 | Equilibrada (12,5%) | 150 | Sí | Legendario | 1,39 | 8,7 |
| 5 | Combate (5%) | 60 | Sí | Raro | 1,17 | 9,6 |
| 6 | Minería (50%) | 750 | Sí | Mítico | 2,29 | 5,8 |
| 6 | Equilibrada (12,5%) | 187 | Sí | Legendario | 1,47 | 8,7 |
| 6 | Combate (5%) | 75 | Sí | Raro | 1,21 | 9,6 |
| 7 | Minería (50%) | 900 | Sí | Ultra raro | 2,42 | 5,8 |
| 7 | Equilibrada (12,5%) | 225 | Sí | Legendario | 1,55 | 8,7 |
| 7 | Combate (5%) | 90 | Sí | Raro | 1,25 | 10,6 |
| 8 | Minería (50%) | 1000 | Sí | Ultra raro | 2,50 | 5,8 |
| 8 | Equilibrada (12,5%) | 262 | Sí | Legendario | 1,62 | 8,7 |
| 8 | Combate (5%) | 105 | Sí | Raro | 1,29 | 10,6 |
| 9 | Minería (50%) | 1000 | Sí | Ultra raro | 2,50 | 5,8 |
| 9 | Equilibrada (12,5%) | 300 | Sí | Legendario | 1,69 | 8,7 |
| 9 | Combate (5%) | 120 | Sí | Raro | 1,32 | 10,6 |
| 10 | Minería (50%) | 1000 | Sí | Ultra raro | 2,50 | 6,7 |
| 10 | Equilibrada (12,5%) | 337 | Sí | Legendario | 1,76 | 8,7 |
| 10 | Combate (5%) | 135 | Sí | Raro | 1,36 | 11,5 |

- **Las tres builds entran en las 10 zonas.**
- **Minería:** puede picar todas las rarezas en todas las zonas.
- **Equilibrada:** llega hasta Legendario en su zona.
- **Combate:** con un 5% de sus puntos en Minería entra en todas las zonas y pica hasta Raro. En la zona 10 tarda 11,5 s por depósito Común, frente a 6,7 s del minero.

---

## 2. Catálogo de minerales

### F15 — Vida, valor y XP de un depósito

- **Vida:** `Vida(z, r) = PotZona(z) × FactorVida(r) × Dureza(z)`
- **Valor:** `Valor(z, r) = 10 × 2,00^(z−1) × FactorValor(r)` monedas por depósito.
- **XP:** `XP(z, r) = 0,69 × (25 + 3,75·L + 0,002·L²) × FactorXP(r)`, con `L` = nivel medio de la zona.
- **Ejemplo:** Rubí de Fragua (zona 4, Legendario) → vida `800 × 35 × 1,3 = 36.400`; valor `80 × 12 = 960` monedas.
- **Límites:** el valor crece ×2,00 por zona, igual que la potencia. Dentro de una zona, el depósito más valioso vale 60 veces el Común.
- **Posibles problemas:** el factor 0,69 de la XP está calibrado para que el minero equilibrado gane la XP por hora de B2; si cambia el ritmo de minado hay que recalibrarlo (el script lo hace solo).

| Rareza | FactorVida (s de referencia) | FactorValor | FactorXP | Unidades por depósito | Minería requerida (× 10 × (zona − 1)) | Valor por segundo de referencia |
|---|---|---|---|---|---|---|
| Común | 6 | 1,0 | 1,0 | 4 | 1,0 | 0,17 |
| Poco común | 9 | 1,8 | 1,4 | 4 | 1,0 | 0,20 |
| Raro | 14 | 3,2 | 2,0 | 3 | 1,5 | 0,23 |
| Épico | 22 | 6,0 | 3,0 | 3 | 2,5 | 0,27 |
| Legendario | 35 | 12,0 | 4,5 | 2 | 3,5 | 0,34 |
| Mítico | 55 | 25,0 | 7,0 | 2 | 5,0 | 0,45 |
| Ultra raro | 90 | 60,0 | 11,0 | 1 | 7,0 | 0,67 |

- «s de referencia» = segundos que tarda un pico Común de la zona con Minería ×1 y dureza 1.
- Cuanto más raro el depósito, más valor por segundo y menos peso: un Ultra raro ocupa 1 unidad de mochila.

### 2.1 Los 66 minerales

Probabilidades de aparición por zona: las de B1. Cada zona suma exactamente 100%, comprobado en el script.

| Zona | Mineral | Rareza | Vida | Valor del depósito | Unidades | XP | Minería req. | Material | Prob. |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Pizarra Clara | Común | 600 | 10 | 4 | 150 | 0 | Lingote de Pizarra Clara | 55,00% |
| 1 | Cobre Rosado | Poco común | 900 | 18 | 4 | 210 | 0 | Lingote de Cobre Rosado | 25,00% |
| 1 | Estaño Lunar | Raro | 1.400 | 32 | 3 | 300 | 0 | Placa de Estaño Lunar | 12,00% |
| 1 | Cuarzo Meloso | Épico | 2.200 | 60 | 3 | 450 | 0 | Gema tallada de Cuarzo Meloso | 5,50% |
| 1 | Ámbar de Aurora | Legendario | 3.500 | 120 | 2 | 675 | 0 | Núcleo de mena de Ámbar de Aurora | 2,00% |
| 1 | Ópalo Naciente | Mítico | 5.500 | 250 | 2 | 1.051 | 0 | Catalizador de Ópalo Naciente | 0,50% |
| 2 | Piedra Verdín | Común | 1.320 | 20 | 4 | 436 | 10 | Lingote de Piedra Verdín | 55,00% |
| 2 | Hierro Musgoso | Poco común | 1.980 | 36 | 4 | 611 | 10 | Lingote de Hierro Musgoso | 25,00% |
| 2 | Malaquita Viva | Raro | 3.080 | 64 | 3 | 873 | 15 | Placa de Malaquita Viva | 12,00% |
| 2 | Jade de Raíz | Épico | 4.840 | 120 | 3 | 1.309 | 25 | Gema tallada de Jade de Raíz | 5,50% |
| 2 | Esmeralda Húmeda | Legendario | 7.700 | 240 | 2 | 1.964 | 35 | Núcleo de mena de Esmeralda Húmeda | 2,00% |
| 2 | Corazón de Liquen | Mítico | 12.100 | 500 | 2 | 3.055 | 50 | Catalizador de Corazón de Liquen | 0,50% |
| 3 | Sal Gema | Común | 2.880 | 40 | 4 | 750 | 20 | Lingote de Sal Gema | 55,00% |
| 3 | Yeso Nacarado | Poco común | 4.320 | 72 | 4 | 1.051 | 20 | Lingote de Yeso Nacarado | 25,00% |
| 3 | Plata Salobre | Raro | 6.720 | 128 | 3 | 1.501 | 30 | Placa de Plata Salobre | 12,00% |
| 3 | Aguamarina Seca | Épico | 10.560 | 240 | 3 | 2.251 | 50 | Gema tallada de Aguamarina Seca | 5,50% |
| 3 | Perla de Veta | Legendario | 16.800 | 480 | 2 | 3.377 | 70 | Núcleo de mena de Perla de Veta | 2,00% |
| 3 | Zafiro de Marea | Mítico | 26.400 | 1.000 | 2 | 5.253 | 100 | Catalizador de Zafiro de Marea | 0,45% |
| 3 | Lágrima de Salmuera | Ultra raro | 43.200 | 2.400 | 1 | 8.254 | 140 | Esencia de Lágrima de Salmuera | 0,05% |
| 4 | Carbón Tibio | Común | 6.240 | 80 | 4 | 1.092 | 30 | Lingote de Carbón Tibio | 55,00% |
| 4 | Azufre Dorado | Poco común | 9.360 | 144 | 4 | 1.529 | 30 | Lingote de Azufre Dorado | 25,00% |
| 4 | Bronce Ardiente | Raro | 14.560 | 256 | 3 | 2.184 | 45 | Placa de Bronce Ardiente | 12,00% |
| 4 | Granate de Ascua | Épico | 22.880 | 480 | 3 | 3.276 | 75 | Gema tallada de Granate de Ascua | 5,50% |
| 4 | Rubí de Fragua | Legendario | 36.400 | 960 | 2 | 4.914 | 105 | Núcleo de mena de Rubí de Fragua | 2,00% |
| 4 | Topacio Incandescente | Mítico | 57.200 | 2.000 | 2 | 7.643 | 150 | Catalizador de Topacio Incandescente | 0,50% |
| 5 | Hielo Gris | Común | 13.440 | 160 | 4 | 1.461 | 40 | Lingote de Hielo Gris | 55,00% |
| 5 | Cobalto Escarchado | Poco común | 20.160 | 288 | 4 | 2.046 | 40 | Lingote de Cobalto Escarchado | 25,00% |
| 5 | Platino Glacial | Raro | 31.360 | 512 | 3 | 2.922 | 60 | Placa de Platino Glacial | 12,00% |
| 5 | Celestina Invernal | Épico | 49.280 | 960 | 3 | 4.383 | 100 | Gema tallada de Celestina Invernal | 5,50% |
| 5 | Diamante de Escarcha | Legendario | 78.400 | 1.920 | 2 | 6.575 | 140 | Núcleo de mena de Diamante de Escarcha | 2,00% |
| 5 | Zafiro Boreal | Mítico | 123.200 | 4.000 | 2 | 10.228 | 200 | Catalizador de Zafiro Boreal | 0,45% |
| 5 | Copo Eterno | Ultra raro | 201.600 | 9.600 | 1 | 16.072 | 280 | Esencia de Copo Eterno | 0,05% |
| 6 | Basalto Sonoro | Común | 28.800 | 320 | 4 | 1.858 | 50 | Lingote de Basalto Sonoro | 55,00% |
| 6 | Níquel Vibrante | Poco común | 43.200 | 576 | 4 | 2.601 | 50 | Lingote de Níquel Vibrante | 25,00% |
| 6 | Electro Resonante | Raro | 67.200 | 1.024 | 3 | 3.716 | 75 | Placa de Electro Resonante | 12,00% |
| 6 | Amatista de Eco | Épico | 105.600 | 1.920 | 3 | 5.573 | 125 | Gema tallada de Amatista de Eco | 5,50% |
| 6 | Oro Armónico | Legendario | 168.000 | 3.840 | 2 | 8.360 | 175 | Núcleo de mena de Oro Armónico | 2,00% |
| 6 | Cristal Diapasón | Mítico | 264.000 | 8.000 | 2 | 13.005 | 250 | Catalizador de Cristal Diapasón | 0,50% |
| 7 | Obsidiana Mate | Común | 61.440 | 640 | 4 | 2.282 | 60 | Lingote de Obsidiana Mate | 55,00% |
| 7 | Titanio Sombrío | Poco común | 92.160 | 1.152 | 4 | 3.195 | 60 | Lingote de Titanio Sombrío | 25,00% |
| 7 | Ónice Veteado | Raro | 143.360 | 2.048 | 3 | 4.564 | 90 | Placa de Ónice Veteado | 12,00% |
| 7 | Espinela Nocturna | Épico | 225.280 | 3.840 | 3 | 6.847 | 150 | Gema tallada de Espinela Nocturna | 5,50% |
| 7 | Iridio Umbrío | Legendario | 358.400 | 7.680 | 2 | 10.270 | 210 | Núcleo de mena de Iridio Umbrío | 2,00% |
| 7 | Diamante de Raíz Negra | Mítico | 563.200 | 16.000 | 2 | 15.975 | 300 | Catalizador de Diamante de Raíz Negra | 0,45% |
| 7 | Semilla de Vacío | Ultra raro | 921.600 | 38.400 | 1 | 25.104 | 420 | Esencia de Semilla de Vacío | 0,05% |
| 8 | Escoria Roja | Común | 130.560 | 1.280 | 4 | 2.734 | 70 | Lingote de Escoria Roja | 55,00% |
| 8 | Wolframio Fundido | Poco común | 195.840 | 2.304 | 4 | 3.828 | 70 | Lingote de Wolframio Fundido | 25,00% |
| 8 | Cinabrio Líquido | Raro | 304.640 | 4.096 | 3 | 5.468 | 105 | Placa de Cinabrio Líquido | 12,00% |
| 8 | Ópalo de Fuego | Épico | 478.720 | 7.680 | 3 | 8.202 | 175 | Gema tallada de Ópalo de Fuego | 5,50% |
| 8 | Paladio Solar | Legendario | 761.600 | 15.360 | 2 | 12.304 | 245 | Núcleo de mena de Paladio Solar | 2,00% |
| 8 | Corindón Volcánico | Mítico | 1.196.800 | 32.000 | 2 | 19.139 | 350 | Catalizador de Corindón Volcánico | 0,45% |
| 8 | Corazón de Caldera | Ultra raro | 1.958.400 | 76.800 | 1 | 30.075 | 490 | Esencia de Corazón de Caldera | 0,05% |
| 9 | Vidrio de Roca | Común | 276.480 | 2.560 | 4 | 3.214 | 80 | Lingote de Vidrio de Roca | 55,00% |
| 9 | Berilo Translúcido | Poco común | 414.720 | 4.608 | 4 | 4.499 | 80 | Lingote de Berilo Translúcido | 25,00% |
| 9 | Turmalina Vitral | Raro | 645.120 | 8.192 | 3 | 6.427 | 120 | Placa de Turmalina Vitral | 12,00% |
| 9 | Kunzita Coral | Épico | 1.013.760 | 15.360 | 3 | 9.641 | 200 | Gema tallada de Kunzita Coral | 5,50% |
| 9 | Alejandrita Prisma | Legendario | 1.612.800 | 30.720 | 2 | 14.462 | 280 | Núcleo de mena de Alejandrita Prisma | 2,00% |
| 9 | Diamante Catedral | Mítico | 2.534.400 | 64.000 | 2 | 22.496 | 400 | Catalizador de Diamante Catedral | 0,45% |
| 9 | Rosetón Luminoso | Ultra raro | 4.147.200 | 153.600 | 1 | 35.350 | 560 | Esencia de Rosetón Luminoso | 0,05% |
| 10 | Polvo Estelar | Común | 583.680 | 5.120 | 4 | 3.721 | 90 | Lingote de Polvo Estelar | 55,00% |
| 10 | Meteorito Férreo | Poco común | 875.520 | 9.216 | 4 | 5.209 | 90 | Lingote de Meteorito Férreo | 25,00% |
| 10 | Moldavita Astral | Raro | 1.361.920 | 16.384 | 3 | 7.442 | 135 | Placa de Moldavita Astral | 12,00% |
| 10 | Tanzanita Cósmica | Épico | 2.140.160 | 30.720 | 3 | 11.162 | 225 | Gema tallada de Tanzanita Cósmica | 5,50% |
| 10 | Oricalco Sideral | Legendario | 3.404.800 | 61.440 | 2 | 16.744 | 315 | Núcleo de mena de Oricalco Sideral | 2,00% |
| 10 | Estelita Pura | Mítico | 5.350.400 | 128.000 | 2 | 26.046 | 450 | Catalizador de Estelita Pura | 0,45% |
| 10 | Fragmento de Nova | Ultra raro | 8.755.200 | 307.200 | 1 | 40.929 | 630 | Esencia de Fragmento de Nova | 0,05% |

| Rareza | Material | Uso |
|---|---|---|
| Común | Lingote | Fabricar picos y armas Común y Poco común |
| Poco común | Lingote | Subir el nivel de objeto del 1 al 5 |
| Raro | Placa | Fabricar picos y armas Raro y Épico; nivel de objeto del 6 al 10 |
| Épico | Gema tallada | Ranuras de mejora |
| Legendario | Núcleo de mena | Fabricar picos y armas Legendario |
| Mítico | Catalizador | Fabricar picos y armas Mítico; Despertar de habilidad |
| Ultra raro | Esencia | Fabricar picos y armas Ultra raro |

- Zonas con Ultra raro: 3, 5, 7, 8, 9 y 10.
- El material Legendario pasa a llamarse «Núcleo de mena» para no confundirlo con los Núcleos de Poder.
- Las cantidades de cada receta se fijan en B6.

---

## 3. Tabla de picos

Hay 75 picos: 10 zonas × 7 rarezas, más 5 Celestiales anclados a las zonas 6 a 10. El listado fila a fila está en el CSV.

### 3.1 Potencia base por zona y rareza

| Zona | Nivel | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro | Celestial |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 100 | 125 | 150 | 190 | 250 | 330 | 450 | — |
| 2 | 100 | 200 | 250 | 300 | 380 | 500 | 660 | 900 | — |
| 3 | 200 | 400 | 500 | 600 | 760 | 1.000 | 1.320 | 1.800 | — |
| 4 | 300 | 800 | 1.000 | 1.200 | 1.520 | 2.000 | 2.640 | 3.600 | — |
| 5 | 400 | 1.600 | 2.000 | 2.400 | 3.040 | 4.000 | 5.280 | 7.200 | — |
| 6 | 500 | 3.200 | 4.000 | 4.800 | 6.080 | 8.000 | 10.560 | 14.400 | 16.640 |
| 7 | 600 | 6.400 | 8.000 | 9.600 | 12.160 | 16.000 | 21.120 | 28.800 | 33.280 |
| 8 | 700 | 12.800 | 16.000 | 19.200 | 24.320 | 32.000 | 42.240 | 57.600 | 66.560 |
| 9 | 800 | 25.600 | 32.000 | 38.400 | 48.640 | 64.000 | 84.480 | 115.200 | 133.120 |
| 10 | 900 | 51.200 | 64.000 | 76.800 | 97.280 | 128.000 | 168.960 | 230.400 | 266.240 |

Nombres: «Pico de» + Pizarra, Verdín, Sal, Brasa, Escarcha, Eco, Obsidiana, Magma, Vitral o Astral (zonas 1 a 10), con la rareza como grado.

### 3.2 Propiedades por rareza (estructura del GDD)

| Rareza | Mult. de potencia | Golpes/s | Minería para equipar | Pasivas de recolección | Estadística de combate |
|---|---|---|---|---|---|
| Común | ×1,00 | 1,00 | 10 × (zona − 1) | 1 menor | Ninguna |
| Poco común | ×1,25 | 1,02 | 10 × (zona − 1) | 1 menor | Ninguna |
| Raro | ×1,50 | 1,04 | 12 × (zona − 1) | 1 menor | Ninguna |
| Épico | ×1,90 | 1,06 | 15 × (zona − 1) | 1 mayor | +3% (tope PvP +2%) |
| Legendario | ×2,50 | 1,08 | 20 × (zona − 1) | 1 mayor | +3% (tope PvP +2%) |
| Mítico | ×3,30 | 1,10 | 25 × (zona − 1) | 1 mayor + 1 menor | +5% (tope PvP +3%) |
| Ultra raro | ×4,50 | 1,12 | 30 × (zona − 1) | 1 mayor + 1 menor | +5% (tope PvP +3%) |
| Celestial | ×5,20 | 1,15 | 30 × (zona − 1) | 1 única | +6% (tope PvP +3%) |

- **Requisitos para equipar:** el nivel de la zona del pico y la Minería de la tabla.
- **Daño por golpe:** `Potencia × MultMinería`, con `MultMinería = 1 + 3·M/(M + 1.000)` (B2).
- **Mínimo de 3 golpes por depósito**, para que un jugador de zona alta no vacíe las zonas bajas de un toque.
- **Velocidad máxima:** 2,0 golpes por segundo contando todos los bonos.
- **Estadística de combate:** defensa o velocidad de ataque, a elegir al fabricar. El tope PvP evita que el pico sustituya al arma.

### 3.3 Pasivas de recolección

Cada pico recibe sus pasivas al fabricarse, elegidas por el jugador entre las de su categoría.

| Categoría | Pasiva | Efecto | Origen |
|---|---|---|---|
| Menor | Eco del filo | 10% de golpear también un segundo depósito cercano | GDD |
| Menor | Lastre ligero | La carga cuenta un 15% menos para el debuff de las Zonas Fracturadas | GDD |
| Menor | Golpe certero | Cada 10.º golpe hace daño doble | Propuesta |
| Mayor | Sonar rúnico | Revela depósitos ocultos a 30 studs | GDD |
| Mayor | Veta abierta | 10% de sacar una unidad más | Propuesta |
| Mayor | Onda sísmica | Cada 12 s el golpe daña al 50% a los depósitos a 8 studs | Propuesta |
| Mayor | Fractura en cadena | Al agotar un depósito, el siguiente empieza con un 25% menos de vida | Propuesta |
| Única (Celestial) | Eco estelar | 5% de que el depósito agotado reaparezca al instante (1 vez cada 60 s) | Propuesta |

### 3.4 Mejoras

Siguen la fórmula de potencia de B1; los tres bonos se suman y el total no pasa de +50%.

| Mejora | Efecto | Máximo | Material |
|---|---|---|---|
| Nivel de objeto (1 a 10) | +2,5% de potencia por nivel | +25% | Lingotes Poco común (1–5) y Placas Raro (6–10) de la zona |
| Ranuras de mejora (3) | +5% de potencia por ranura | +15% | Gemas talladas Épico de la zona |
| Despertar de habilidad | +10% de potencia y mejora una pasiva | +10% | Catalizador Mítico de la zona |

---

## 4. Tiempo de extracción

Segundos por depósito para una build equilibrada al nivel de entrada de la zona, con un pico de esa zona sin mejoras.

| Zona | Mult. Minería | Pico | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1,00 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | — |
| 1 | 1,00 | Ultra raro | 2,7 | 2,7 | 3,6 | 4,5 | 7,1 | 11,6 | — |
| 2 | 1,11 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | — |
| 2 | 1,11 | Ultra raro | 2,7 | 2,7 | 3,6 | 4,5 | 7,1 | 11,6 | — |
| 3 | 1,21 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | 90,0 |
| 3 | 1,21 | Ultra raro | 2,7 | 2,7 | 3,6 | 4,5 | 7,1 | 11,6 | 17,9 |
| 4 | 1,30 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | — |
| 4 | 1,30 | Ultra raro | 2,7 | 2,7 | 3,6 | 4,5 | 7,1 | 11,6 | — |
| 5 | 1,39 | Común | 7,0 | 10,0 | 15,0 | 23,0 | 36,0 | 56,0 | 91,0 |
| 5 | 1,39 | Ultra raro | 2,7 | 2,7 | 3,6 | 4,5 | 7,1 | 11,6 | 18,7 |
| 6 | 1,47 | Común | 7,0 | 10,0 | 15,0 | 23,0 | 36,0 | 57,0 | — |
| 6 | 1,47 | Ultra raro | 2,7 | 2,7 | 3,6 | 4,5 | 7,1 | 11,6 | — |
| 7 | 1,55 | Común | 7,0 | 10,0 | 15,0 | 23,0 | 37,0 | 57,0 | 93,0 |
| 7 | 1,55 | Ultra raro | 2,7 | 2,7 | 3,6 | 5,4 | 8,0 | 11,6 | 18,7 |
| 8 | 1,62 | Común | 7,0 | 10,0 | 15,0 | 24,0 | 37,0 | 58,0 | 95,0 |
| 8 | 1,62 | Ultra raro | 2,7 | 2,7 | 3,6 | 5,4 | 8,0 | 11,6 | 18,7 |
| 9 | 1,69 | Común | 7,0 | 10,0 | 15,0 | 24,0 | 38,0 | 59,0 | 96,0 |
| 9 | 1,69 | Ultra raro | 2,7 | 2,7 | 3,6 | 5,4 | 8,0 | 11,6 | 19,6 |
| 10 | 1,76 | Común | 7,0 | 10,0 | 16,0 | 24,0 | 38,0 | 60,0 | 98,0 |
| 10 | 1,76 | Ultra raro | 2,7 | 2,7 | 3,6 | 5,4 | 8,0 | 12,5 | 19,6 |

- **F16:** `Tiempo = máx(3, techo(Vida / (Potencia × MultMinería))) / GolpesPorSegundo`.
- Con el pico Común de la zona, el depósito Común cuesta 6–7 s en todas las zonas.
- El pico Ultra raro (×4,50 de potencia) deja casi todos los depósitos en el mínimo de 3 golpes. Con los multiplicadores del GDD, el mínimo de golpes es lo que impide que la rareza del pico dispare los ingresos de minería.

---

## 5. Generación de depósitos

Los depósitos son compartidos: todos los jugadores de la zona ven los mismos. Cuando uno se agota, reaparece en el mismo punto con una rareza nueva.

### 5.1 Simulación

Dos horas simuladas por caso. Cada minero tarda 6 s en llegar a un depósito libre y lo pica con los tiempos de la zona 5 (build equilibrada, pico Raro).

| Depósitos activos | Regeneración (s) | Mineros en la zona | Tiempo sin depósito libre | Depósitos/hora por minero | Depósitos libres de media | Ultra raros nuevos por hora |
|---|---|---|---|---|---|---|
| 30 | 45 | 4 | 0,0% | 283 | 12,1 | 0,00 |
| 30 | 45 | 8 | 16,5% | 233 | 0,3 | 0,00 |
| 30 | 45 | 12 | 43,8% | 157 | 0,1 | 0,50 |
| 40 | 45 | 1 | 0,0% | 280 | 35,5 | 0,00 |
| 40 | 45 | 4 | 0,0% | 281 | 22,1 | 0,50 |
| 40 | 45 | 8 | 0,0% | 280 | 4,4 | 1,50 |
| 40 | 45 | 12 | 25,4% | 209 | 0,2 | 1,50 |
| 40 | 45 | 20 | 55,3% | 126 | 0,0 | 0,50 |
| 40 | 60 | 8 | 12,5% | 247 | 0,5 | 0,50 |
| 40 | 60 | 12 | 41,0% | 166 | 0,1 | 0,00 |
| 60 | 45 | 12 | 0,0% | 282 | 6,3 | 1,00 |
| 80 | 45 | 16 | 0,0% | 281 | 8,6 | 2,00 |
| 80 | 45 | 20 | 10,8% | 250 | 0,6 | 2,50 |

### 5.2 Valores elegidos

| Parámetro | Valor |
|---|---|
| Depósitos activos base por zona | 40 |
| Tiempo de regeneración | 45 s |
| Escalado | +5 depósitos por cada minero por encima de 8 |
| Máximo de depósitos activos | 80 |
| Jugadores por servidor (supuesto) | 20 |

- Con 40 depósitos y 45 s, 8 mineros esperan el 0,0% del tiempo.
- Con 12 mineros y 40 depósitos se pierde el 25,4%; con el escalado (60 depósitos), el 0,0%.
- Con los 20 jugadores del servidor en la misma zona y el máximo de 80, la espera es del 10,8%.

### 5.3 Reglas

- **Rareza al reaparecer:** tabla de B1, con la Suerte media de los jugadores presentes en la zona.
- **Reparto:** si varios jugadores pican el mismo depósito, las unidades y la XP se reparten en proporción al daño. Quien haga al menos el 10% del daño recibe como mínimo 1 unidad.

---

## 6. Ritmo e ingresos del minero PvE

Minero con pico Raro de su zona, al nivel medio de la zona, con mochila de 60 unidades y 40 s por viaje al banco.

| Zona | Build | Nivel | Minería | s medios por depósito | Depósitos/hora | Monedas/hora | XP/hora | XP/hora objetivo (B2) |
|---|---|---|---|---|---|---|---|---|
| 1 | Equilibrada (12,5%) | 50 | 18 | 5,9 | 249 | 5.175 | 53.415 | 52.200 |
| 1 | Minería (50%) | 50 | 75 | 5,5 | 258 | 5.354 | 55.271 | 52.200 |
| 2 | Equilibrada (12,5%) | 150 | 56 | 5,9 | 249 | 10.349 | 155.334 | 151.800 |
| 2 | Minería (50%) | 150 | 225 | 4,6 | 274 | 11.382 | 170.836 | 151.800 |
| 3 | Equilibrada (12,5%) | 250 | 93 | 5,9 | 250 | 19.661 | 263.307 | 261.000 |
| 3 | Minería (50%) | 250 | 375 | 4,3 | 280 | 23.519 | 301.365 | 261.000 |
| 4 | Equilibrada (12,5%) | 350 | 131 | 6,0 | 248 | 39.007 | 380.093 | 379.800 |
| 4 | Minería (50%) | 350 | 525 | 4,2 | 284 | 47.184 | 442.974 | 379.800 |
| 5 | Equilibrada (12,5%) | 450 | 168 | 6,0 | 248 | 78.013 | 508.592 | 508.200 |
| 5 | Minería (50%) | 450 | 675 | 4,2 | 284 | 95.111 | 593.239 | 508.200 |
| 6 | Equilibrada (12,5%) | 550 | 206 | 6,0 | 248 | 155.819 | 645.838 | 646.200 |
| 6 | Minería (50%) | 550 | 825 | 4,2 | 284 | 188.736 | 753.686 | 646.200 |
| 7 | Equilibrada (12,5%) | 650 | 243 | 6,8 | 235 | 295.882 | 753.247 | 793.800 |
| 7 | Minería (50%) | 650 | 975 | 4,3 | 281 | 376.451 | 916.908 | 793.800 |
| 8 | Equilibrada (12,5%) | 750 | 281 | 6,8 | 235 | 589.714 | 899.290 | 951.000 |
| 8 | Minería (50%) | 750 | 1000 | 4,6 | 275 | 738.758 | 1.077.851 | 951.000 |
| 9 | Equilibrada (12,5%) | 850 | 318 | 6,8 | 234 | 1.177.945 | 1.055.691 | 1.117.800 |
| 9 | Minería (50%) | 850 | 1000 | 4,6 | 274 | 1.468.285 | 1.258.985 | 1.117.800 |
| 10 | Equilibrada (12,5%) | 950 | 356 | 6,8 | 234 | 2.355.890 | 1.222.289 | 1.294.200 |
| 10 | Minería (50%) | 950 | 1000 | 5,4 | 259 | 2.783.904 | 1.381.884 | 1.294.200 |

- El minero equilibrado hace entre 234 y 250 depósitos por hora, cerca de las 240 acciones por hora que supone B2.
- Su XP por hora queda entre -6% y 2% del objetivo de B2.
- La build de Minería gana entre 1,03 y 1,27 veces lo que la equilibrada: dentro del límite de 1,3.
- Ingresos de referencia: 5.175 monedas por hora en la zona 1 y 2.355.890 en la zona 10. Son la base de los precios de B6.

---

## 7. Zonas Fracturadas

Cada zona de la mina tiene su Zona Fracturada: una grieta inestable, opcional, con PvP siempre activo **[CONFIRMADO]**. Las reglas de esta sección son las del GDD, salvo donde se indica.

### 7.1 Acceso

- **Requisitos:** los mismos que la zona PvE (nivel, Minería y potencia de pico).
- **Al entrar:** pantalla de confirmación, borde rojo en la interfaz y **10 s de protección** mientras no ataques. La misma protección se aplica al reaparecer.
- **Sincronización de nivel (añadido):** dentro de la Zona Fracturada de la zona `z`, el nivel efectivo máximo es `100 × z`. Los requisitos son mínimos y por sí solos no impiden que entre un jugador de nivel alto.
- **Salir sin extraer:** por el portal de entrada, con 3 s de canalización que el daño interrumpe (añadido). Se pierde el bono de la carrera: el mineral sale a ×1,0.
- **Interfaz:** muestra siempre la carga, el debuff y cuánto se perdería al morir en ese momento.

### 7.2 Valor del mineral y racha de extracción

- El mineral picado en una Zona Fracturada es «mineral fracturado». **Si se extrae**, vale **×1,5** por el multiplicador de racha y da ×1,25 de XP. **Si no se extrae**, vale ×1,0.
- Depósitos: misma tabla de rarezas que la zona PvE, sin Suerte (B1).
- **Contenedor de grieta (añadido):** dentro de la Zona Fracturada la mochila admite el doble (120 unidades base).

| Extracciones seguidas | Multiplicador de racha | Valor del mineral extraído |
|---|---|---|
| 0 | ×1,0 | ×1,50 |
| 1 | ×1,1 | ×1,65 |
| 2 | ×1,2 | ×1,80 |
| 3 | ×1,3 | ×1,95 |
| 4 | ×1,4 | ×2,10 |
| 5 | ×1,5 | ×2,25 |
| 6 | ×1,5 | ×2,25 |

- La racha es la del GDD: ×1,1, ×1,2… hasta ×1,5. Morir en una Zona Fracturada la reinicia; salir sin extraer no la rompe.
- **Por qué el multiplicador base es ×1,5:** el GDD no lo fija. Con ×2,0 y la racha de ×1,5, el máximo teórico sería 3,17 veces el PvE, por encima del techo de 2,5.

| Multiplicador base | Máximo teórico | 15% de muertes | 30% | 50% |
|---|---|---|---|---|
| ×2,0 | 3,17 | 2,54 | 2,07 | 1,59 |
| ×1,8 | 2,86 | 2,29 | 1,88 | 1,45 |
| ×1,6 | 2,54 | 2,04 | 1,68 | 1,31 |
| ×1,5 | 2,38 | 1,92 | 1,58 | 1,24 |

### 7.3 Debuff de carga (fórmula del GDD)

- **F17:** `Carga = valor base de los minerales transportados / (20 × valor base de la zona)` y `Ralentización = mín(0,40; 0,12 × ln(1 + Carga))`.
- `Velocidad final = velocidad del jugador × (1 − Ralentización)`.
- **Dash y parpadeo no se ralentizan.** Con Carga 10 o más cuestan un 25% más de energía. Escapar siempre es posible.

| Carga | Ralentización | Equivale a | Efecto extra |
|---|---|---|---|
| 1 | 8,3% | 10 depósitos medios o 0,3 Ultra raros | Ninguno |
| 5 | 21,5% | 48 depósitos medios o 1,7 Ultra raros | Partículas de mineral visibles a 60 studs |
| 10 | 28,8% | 95 depósitos medios o 3,3 Ultra raros | Resplandor en el minimapa de todos; dash y parpadeo cuestan 25% más |
| 20 | 36,5% | 191 depósitos medios o 6,7 Ultra raros | Lo anterior |
| 30 | 40,0% | 286 depósitos medios o 10,0 Ultra raros | Tope del 40%; anuncio en la zona |

- Una mochila de grieta base llena (120 unidades de mineral medio) son Carga 3,3: 17,6% de ralentización.
- Con la mochila máxima (400 unidades), Carga 11,1: 29,9%.
- La carga depende del valor, no del número de piedras: quien encuentra depósitos raros se vuelve lento y visible mucho antes.

### 7.4 Saqueo

Al ser derrotado por un jugador con 100 unidades de carga:

| Destino | Unidades | Regla |
|---|---|---|
| Las conserva la víctima | 50 | Reaparece fuera de la Zona Fracturada; valen ×1,0 |
| Cofre de Saqueo | 40 | El 80% de lo que se suelta (GDD) |
| Destruidas | 10 | El 20% de lo que se suelta; sumidero contra la inflación (GDD) |

- **Se suelta el 50%** de la carga **[PROVISIONAL]**; se eligen primero las unidades más valiosas.
- **Cofre de Saqueo:** dura 90 s; los primeros 10 s solo lo abre quien derrotó a la víctima (y su escuadrón); abrirlo lleva 3 s y se interrumpe con daño (duraciones propuestas).
- Lo saqueado sigue siendo mineral fracturado: el saqueador también tiene que extraerlo, y su carga y su ralentización suben.
- **Morir contra un enemigo o el entorno:** regla PvE, se pierde el 20% de la carga.
- **Carga mínima protegida:** por debajo de Carga 1 no se suelta nada.
- **Misma víctima (añadido):** derrotar al mismo jugador otra vez en menos de 10 minutos no suelta carga.
- Nunca se pierden armas, picos, mascotas, monedas ni nivel **[CONFIRMADO]**.
- Quien muere conserva la mitad de las unidades, pero a ×1,0: en valor, el 33,3% de lo que habría cobrado extrayendo sin racha.

### 7.5 Ingresos del minero de grieta

| Prob. de morir por viaje | Racha media | Ingresos frente al PvE | Parte de la carga que acaba en cofres | Parte destruida |
|---|---|---|---|---|
| 0% | ×1,50 | 2,38 | 0,0% | 0,0% |
| 5% | ×1,43 | 2,21 | 1,2% | 0,3% |
| 15% | ×1,32 | 1,92 | 3,6% | 0,9% |
| 30% | ×1,19 | 1,58 | 7,2% | 1,8% |
| 50% | ×1,10 | 1,24 | 12,0% | 3,0% |
| 70% | ×1,04 | 0,94 | 16,8% | 4,2% |

- Valores relativos a picar en PvE (= 1,00), contando el tiempo de extracción y la racha.
- **Máximo teórico: 2,38** (sin morir nunca y con la racha completa), bajo el techo de 2,5.
- El minero sale ganando frente al PvE mientras muera en menos del 66% de los viajes.

### 7.6 Puntos de Extracción

| Parámetro | Valor | Origen |
|---|---|---|
| Canalización | 8 s; recibir daño la reinicia | GDD |
| Cambio de sitio | Cada 10 minutos | GDD |
| Puntos por Zona Fracturada | 3 posiciones posibles, 1 activa | Propuesta |
| Aviso del siguiente punto | 30 s antes | Propuesta |
| Al extraer | La carga va al banco y queda protegida; el jugador sale a la entrada PvE | GDD |

### 7.7 Protecciones (GDD)

- **Protección de novato:** las 5 primeras entradas a una Zona Fracturada no sueltan carga al morir. Se avisa con claridad cuando termina.
- **Carga mínima protegida:** por debajo de Carga 1 no se suelta nada.
- **Anti-acampada:** 10 s de protección al entrar y al reaparecer; los Puntos de Extracción cambian de sitio cada 10 minutos.
- **Rangos de nivel:** requisitos de acceso más la sincronización de nivel de 7.1.
- **Transparencia:** la interfaz muestra carga, debuff y pérdida posible.
- **Añadido contra el abuso:** quien permanezca más de 60 s a menos de 25 studs del Punto de Extracción activo sin canalizar queda marcado en el minimapa de todos.

### 7.8 Fragmentos Celestiales

- En las Zonas Fracturadas de las zonas 6 a 10, cada depósito agotado tiene un 0,25% de dar 1 fragmento Celestial (B1; el GDD proponía 0,02%).
- El fragmento va directo a la cuenta: no ocupa mochila ni se puede saquear.

---

## 8. Muerte en minas PvE, banco y jugadores nuevos

| Regla | Valor |
|---|---|
| Pérdida al morir en PvE | 20% de la carga **[CONFIRMADO]** |
| Destino de lo perdido | Queda en un saco en el lugar de la muerte; solo su dueño puede recogerlo durante 120 s. Después se destruye |
| Protección de jugador nuevo | Por debajo del nivel 25 no se pierde nada |
| Reaparición | En la entrada de la zona |
| Mochila base | 60 unidades (ampliaciones en B6) |
| Banco | En la ciudad y en la entrada de cada zona PvE. Depositar lleva 3 s. Lo guardado no se pierde nunca |
| Banco en Zonas Fracturadas | No hay: la carga solo está a salvo cuando se extrae |

Con 60 unidades de mochila y 3,77 unidades de media por depósito, el minero vuelve al banco cada 16 depósitos.

---

## 9. Problemas de balance detectados y alternativas

### P1 — La racha del GDD con mineral al doble supera el techo de 2,5

- Resuelto con multiplicador base ×1,5 (sección 7.2). Máximo teórico 2,38.
- **Efecto:** sin racha, el mineral de grieta vale solo un 50% más que en PvE. Con un 30% de muertes el minero gana 1,58 veces el PvE; con un 50%, 1,24. La grieta compensa sobre todo a quien encadena extracciones, que es la intención del GDD.

### P2 — Morir cuesta más de lo que parece

- La víctima conserva el 50% de las unidades a ×1,0 y pierde la racha. B6 mide el efecto del Seguro de carga.

### P3 — Los multiplicadores de pico del GDD aplanan la minería en la parte alta

- **Dato:** con un pico Ultra raro casi todos los depósitos se quedan en el mínimo de 3 golpes.
- **Por qué se acepta:** impide que el equipo dispare los ingresos; el valor de un pico raro está en sus pasivas y en su estadística de combate. B7 lo comprueba.

### P4 — Los requisitos de acceso no bastan como rango de nivel

- El GDD confía en ellos, pero son mínimos. Se añade la sincronización de nivel (7.1).

### P5 — Puntos de Extracción fijos durante 10 minutos

- **Riesgo:** con el punto quieto 10 minutos (en la primera versión rotaba cada 2), es más fácil que un grupo lo vigile.
- **Mitigación:** la marca en el minimapa de 7.7 y los 10 s de protección al reaparecer. Se mide en la beta: si más del 40% de las extracciones se interrumpen, bajar a 5 minutos.

### P6 — Con más de 8 mineros faltan depósitos

- Resuelto con el escalado de la sección 5.2.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| FactorVida y dureza | Prueba de juego: 6–7 s por depósito Común con el pico de la zona |
| 40 depósitos, 45 s, escalado | Telemetría: tiempo sin depósito libre; objetivo, menos del 5% |
| Multiplicador ×1,5 y racha hasta ×1,5 | B6 y B7; en beta, ingresos reales de grieta frente a PvE |
| Debuff de carga del GDD | Prueba de juego: que un minero cargado pueda escapar con dash y parpadeo |
| Cambio de punto cada 10 minutos | Beta: porcentaje de extracciones interrumpidas; objetivo, entre 20% y 40% |
| Protección de novato (5 entradas) | Beta: abandono tras la sexta entrada |
