# OREBOUND — B3: Minería

Etapa 3 · 2026-11-16 (ampliado en la Etapa 6: contenedor de grieta y racha) · Script: `calculos/b3_mineria.py` · Catálogos completos: `calculos/b3_minerales.csv` (66 minerales) y `calculos/b3_picos.csv` (75 picos).

> **Aviso de fuentes.** No se dispone de las secciones 7, 8, 9 y 14 del prompt maestro ni de la
> sección de Minería PvPvE del GDD. Los 30 minerales de referencia y los valores de las Zonas
> Fracturadas del GDD no se han visto: los nombres y cifras de este documento son propuestas
> **[PROVISIONAL]**. Son **[CONFIRMADO]** solo las decisiones fijas: mina PvE, una Zona Fracturada
> por zona, solo se arriesga el mineral y el 20% de pérdida en PvE. El 50% en Zona Fracturada sigue
> **[PROVISIONAL]**.

---

## 1. Las 10 zonas

| Zona | Nombre | Nivel | Minería requerida | Potencia de pico requerida | PotZona | Dureza | Ultra raro |
|---|---|---|---|---|---|---|---|
| 1 | Cantera del Alba | 1 | 0 | 60 | 100 | 1,0 | No |
| 2 | Galerías de Musgo | 100 | 10 | 99 | 165 | 1,1 | No |
| 3 | Vetas Salinas | 200 | 20 | 163 | 272 | 1,2 | Sí |
| 4 | Grutas de Brasa | 300 | 30 | 270 | 449 | 1,3 | No |
| 5 | Sima Helada | 400 | 40 | 445 | 741 | 1,4 | Sí |
| 6 | Bóveda de Ecos | 500 | 50 | 734 | 1.223 | 1,5 | No |
| 7 | Raíces de Obsidiana | 600 | 60 | 1.211 | 2.018 | 1,6 | Sí |
| 8 | Mar de Magma | 700 | 70 | 1.998 | 3.330 | 1,7 | Sí |
| 9 | Catedral de Cristal | 800 | 80 | 3.296 | 5.494 | 1,8 | Sí |
| 10 | Núcleo Astral | 900 | 90 | 5.439 | 9.065 | 1,9 | Sí |

### F13 — Requisitos de zona

- **Nivel:** `Nivel(z) = 100 × (z − 1)`, con la zona 1 abierta desde el nivel 1.
- **Minería requerida:** `10 × (z − 1)`.
- **Potencia de pico requerida:** `0,6 × PotZona(z)`, con `PotZona(z) = 100 × 1,65^(z−1)` (B1).
- **Dureza:** `1 + 0,1 × (z − 1)`. Multiplica la vida de los depósitos para compensar que el jugador medio tiene más Minería en zonas altas.
- **Ejemplo:** zona 5 → nivel 400, Minería 40, pico de potencia 445 o más.
- **Límites:** el requisito de pico (0,6) lo cumple un pico Común de la zona anterior (`1/1,65 = 0,606`). Nadie queda bloqueado por no tener suerte con el pico.
- **Posibles problemas:** si en el futuro cambia el crecimiento 1,65, hay que recalcular el 0,6.

### F14 — Minería requerida por depósito

- **Expresión:** `MineríaReq(z, r) = 10 × (z − 1) × FactorReq(r)`
- **FactorReq:** Común 1 · Poco común 1 · Raro 1,5 · Épico 2,5 · Legendario 3,5 · Mítico 5 · Ultra raro 7.
- **Ejemplo:** depósito Mítico de zona 8 → `10 × 7 × 5 = 350` de Minería.
- **Límites:** el máximo es 630 (Ultra raro de zona 10), por debajo del tope de 1.000 puntos.

### 1.1 Comprobación con tres builds

Cada build se mide al nivel de entrada de la zona, con el pico Raro de la zona anterior. El porcentaje es la parte de los puntos puesta en Minería.

| Zona | Build | Minería al entrar | ¿Entra? | Rareza máxima que puede picar | Mult. Minería | s por depósito Común con el pico anterior |
|---|---|---|---|---|---|---|
| 1 | Minería (50 %) | 1 | Sí | Mítico | 1,00 | 6,0 |
| 1 | Equilibrada (12,5 %) | 0 | Sí | Mítico | 1,00 | 6,0 |
| 1 | Combate (5 %) | 0 | Sí | Mítico | 1,00 | 6,0 |
| 2 | Minería (50 %) | 150 | Sí | Mítico | 1,39 | 5,8 |
| 2 | Equilibrada (12,5 %) | 37 | Sí | Legendario | 1,11 | 7,7 |
| 2 | Combate (5 %) | 15 | Sí | Raro | 1,04 | 7,7 |
| 3 | Minería (50 %) | 300 | Sí | Ultra raro | 1,69 | 5,8 |
| 3 | Equilibrada (12,5 %) | 75 | Sí | Legendario | 1,21 | 7,7 |
| 3 | Combate (5 %) | 30 | Sí | Raro | 1,09 | 8,7 |
| 4 | Minería (50 %) | 450 | Sí | Mítico | 1,93 | 5,8 |
| 4 | Equilibrada (12,5 %) | 112 | Sí | Legendario | 1,30 | 7,7 |
| 4 | Combate (5 %) | 45 | Sí | Raro | 1,13 | 8,7 |
| 5 | Minería (50 %) | 600 | Sí | Ultra raro | 2,12 | 4,8 |
| 5 | Equilibrada (12,5 %) | 150 | Sí | Legendario | 1,39 | 7,7 |
| 5 | Combate (5 %) | 60 | Sí | Raro | 1,17 | 8,7 |
| 6 | Minería (50 %) | 750 | Sí | Mítico | 2,29 | 4,8 |
| 6 | Equilibrada (12,5 %) | 187 | Sí | Legendario | 1,47 | 7,7 |
| 6 | Combate (5 %) | 75 | Sí | Raro | 1,21 | 9,6 |
| 7 | Minería (50 %) | 900 | Sí | Ultra raro | 2,42 | 4,8 |
| 7 | Equilibrada (12,5 %) | 225 | Sí | Legendario | 1,55 | 7,7 |
| 7 | Combate (5 %) | 90 | Sí | Raro | 1,25 | 9,6 |
| 8 | Minería (50 %) | 1000 | Sí | Ultra raro | 2,50 | 5,8 |
| 8 | Equilibrada (12,5 %) | 262 | Sí | Legendario | 1,62 | 7,7 |
| 8 | Combate (5 %) | 105 | Sí | Raro | 1,29 | 9,6 |
| 9 | Minería (50 %) | 1000 | Sí | Ultra raro | 2,50 | 5,8 |
| 9 | Equilibrada (12,5 %) | 300 | Sí | Legendario | 1,69 | 7,7 |
| 9 | Combate (5 %) | 120 | Sí | Raro | 1,32 | 10,6 |
| 10 | Minería (50 %) | 1000 | Sí | Ultra raro | 2,50 | 5,8 |
| 10 | Equilibrada (12,5 %) | 337 | Sí | Legendario | 1,76 | 8,7 |
| 10 | Combate (5 %) | 135 | Sí | Raro | 1,36 | 10,6 |

- **Las tres builds entran en las 10 zonas.** No ha hecho falta ajustar nada.
- **Minería:** puede picar todas las rarezas en todas las zonas, incluido Ultra raro.
- **Equilibrada:** llega hasta Legendario en su zona. Para Mítico y Ultra raro tiene que bajar a zonas anteriores.
- **Combate:** con solo un 5% de sus puntos en Minería entra en todas las zonas y pica hasta Raro. Tarda casi el doble que el minero (10,6 s frente a 5,8 s por depósito Común en zona 10).

---

## 2. Catálogo de minerales

### F15 — Vida, valor y XP de un depósito

- **Vida:** `Vida(z, r) = PotZona(z) × FactorVida(r) × Dureza(z)`
- **Valor:** `Valor(z, r) = 10 × 1,65^(z−1) × FactorValor(r)` monedas por depósito.
- **XP:** `XP(z, r) = 0,73 × (25 + 3,75·L + 0,002·L²) × FactorXP(r)`, con `L` = nivel medio de la zona.
- **Ejemplo:** Rubí de Fragua (zona 4, Legendario) → vida `449 × 35 × 1,3 = 20.439`; valor `44,9 × 12 = 539` monedas.
- **Límites:** el valor crece ×1,65 por zona, igual que la potencia. Dentro de una zona, el depósito más valioso vale 60 veces el Común.
- **Posibles problemas:** el factor 0,73 de la XP se ha calibrado para que el minero equilibrado gane la XP por hora de B2; si cambia el ritmo de minado hay que recalibrarlo.

| Rareza | FactorVida (s de referencia) | FactorValor | FactorXP | Unidades por depósito | Monedas por segundo de referencia |
|---|---|---|---|---|---|
| Común | 6 | 1 | 1 | 4 | 0,17 |
| Poco común | 9 | 1,8 | 1,4 | 4 | 0,20 |
| Raro | 14 | 3,2 | 2 | 3 | 0,23 |
| Épico | 22 | 6 | 3 | 3 | 0,27 |
| Legendario | 35 | 12 | 4,5 | 2 | 0,34 |
| Mítico | 55 | 25 | 7 | 2 | 0,45 |
| Ultra raro | 90 | 60 | 11 | 1 | 0,67 |

- «s de referencia» = segundos que tarda un pico Común de la zona con Minería ×1 y dureza 1.
- Cuanto más raro el depósito, más monedas por segundo y menos peso: un Ultra raro ocupa 1 unidad de mochila.
- El pico requerido para todos los depósitos de una zona es el de la zona (sección 1). La Minería requerida depende de la rareza (F14).

### 2.1 Los 66 minerales

Probabilidades de aparición por zona: son las de B1 (tabla con Ultra raro o sin Ultra raro). Cada zona suma exactamente 100%, comprobado en el script.

| Zona | Mineral | Rareza | Vida | Valor del depósito | Unidades | XP | Minería req. | Material | Prob. |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Pizarra Clara | Común | 600 | 10 | 4 | 159 | 0 | Lingote de Pizarra Clara | 55,00 % |
| 1 | Cobre Rosado | Poco común | 900 | 18 | 4 | 222 | 0 | Lingote de Cobre Rosado | 25,00 % |
| 1 | Estaño Lunar | Raro | 1.400 | 32 | 3 | 318 | 0 | Placa de Estaño Lunar | 12,00 % |
| 1 | Cuarzo Meloso | Épico | 2.200 | 60 | 3 | 476 | 0 | Gema tallada de Cuarzo Meloso | 5,50 % |
| 1 | Ámbar de Aurora | Legendario | 3.500 | 120 | 2 | 714 | 0 | Núcleo de Ámbar de Aurora | 2,00 % |
| 1 | Ópalo Naciente | Mítico | 5.500 | 250 | 2 | 1.111 | 0 | Catalizador de Ópalo Naciente | 0,50 % |
| 2 | Piedra Verdín | Común | 1.089 | 16 | 4 | 462 | 10 | Lingote de Piedra Verdín | 55,00 % |
| 2 | Hierro Musgoso | Poco común | 1.634 | 30 | 4 | 646 | 10 | Lingote de Hierro Musgoso | 25,00 % |
| 2 | Malaquita Viva | Raro | 2.541 | 53 | 3 | 923 | 15 | Placa de Malaquita Viva | 12,00 % |
| 2 | Jade de Raíz | Épico | 3.993 | 99 | 3 | 1.385 | 25 | Gema tallada de Jade de Raíz | 5,50 % |
| 2 | Esmeralda Húmeda | Legendario | 6.353 | 198 | 2 | 2.078 | 35 | Núcleo de Esmeralda Húmeda | 2,00 % |
| 2 | Corazón de Liquen | Mítico | 9.982 | 412 | 2 | 3.232 | 50 | Catalizador de Corazón de Liquen | 0,50 % |
| 3 | Sal Gema | Común | 1.960 | 27 | 4 | 794 | 20 | Lingote de Sal Gema | 55,00 % |
| 3 | Yeso Nacarado | Poco común | 2.940 | 49 | 4 | 1.111 | 20 | Lingote de Yeso Nacarado | 25,00 % |
| 3 | Plata Salobre | Raro | 4.574 | 87 | 3 | 1.588 | 30 | Placa de Plata Salobre | 12,00 % |
| 3 | Aguamarina Seca | Épico | 7.187 | 163 | 3 | 2.382 | 50 | Gema tallada de Aguamarina Seca | 5,50 % |
| 3 | Perla de Veta | Legendario | 11.434 | 327 | 2 | 3.572 | 70 | Núcleo de Perla de Veta | 2,00 % |
| 3 | Zafiro de Marea | Mítico | 17.968 | 681 | 2 | 5.557 | 100 | Catalizador de Zafiro de Marea | 0,45 % |
| 3 | Lágrima de Salmuera | Ultra raro | 29.403 | 1.633 | 1 | 8.733 | 140 | Esencia de Lágrima de Salmuera | 0,05 % |
| 4 | Carbón Tibio | Común | 3.504 | 45 | 4 | 1.155 | 30 | Lingote de Carbón Tibio | 55,00 % |
| 4 | Azufre Dorado | Poco común | 5.256 | 81 | 4 | 1.617 | 30 | Lingote de Azufre Dorado | 25,00 % |
| 4 | Bronce Ardiente | Raro | 8.176 | 144 | 3 | 2.310 | 45 | Placa de Bronce Ardiente | 12,00 % |
| 4 | Granate de Ascua | Épico | 12.847 | 270 | 3 | 3.466 | 75 | Gema tallada de Granate de Ascua | 5,50 % |
| 4 | Rubí de Fragua | Legendario | 20.439 | 539 | 2 | 5.199 | 105 | Núcleo de Rubí de Fragua | 2,00 % |
| 4 | Topacio Incandescente | Mítico | 32.119 | 1.123 | 2 | 8.087 | 150 | Catalizador de Topacio Incandescente | 0,50 % |
| 5 | Hielo Gris | Común | 6.226 | 74 | 4 | 1.546 | 40 | Lingote de Hielo Gris | 55,00 % |
| 5 | Cobalto Escarchado | Poco común | 9.339 | 133 | 4 | 2.164 | 40 | Lingote de Cobalto Escarchado | 25,00 % |
| 5 | Platino Glacial | Raro | 14.528 | 237 | 3 | 3.092 | 60 | Placa de Platino Glacial | 12,00 % |
| 5 | Celestina Invernal | Épico | 22.829 | 445 | 3 | 4.637 | 100 | Gema tallada de Celestina Invernal | 5,50 % |
| 5 | Diamante de Escarcha | Legendario | 36.319 | 889 | 2 | 6.956 | 140 | Núcleo de Diamante de Escarcha | 2,00 % |
| 5 | Zafiro Boreal | Mítico | 57.072 | 1.853 | 2 | 10.820 | 200 | Catalizador de Zafiro Boreal | 0,45 % |
| 5 | Copo Eterno | Ultra raro | 93.391 | 4.447 | 1 | 17.004 | 280 | Esencia de Copo Eterno | 0,05 % |
| 6 | Basalto Sonoro | Común | 11.007 | 122 | 4 | 1.966 | 50 | Lingote de Basalto Sonoro | 55,00 % |
| 6 | Níquel Vibrante | Poco común | 16.510 | 220 | 4 | 2.752 | 50 | Lingote de Níquel Vibrante | 25,00 % |
| 6 | Electro Resonante | Raro | 25.683 | 391 | 3 | 3.931 | 75 | Placa de Electro Resonante | 12,00 % |
| 6 | Amatista de Eco | Épico | 40.358 | 734 | 3 | 5.897 | 125 | Gema tallada de Amatista de Eco | 5,50 % |
| 6 | Oro Armónico | Legendario | 64.207 | 1.468 | 2 | 8.845 | 175 | Núcleo de Oro Armónico | 2,00 % |
| 6 | Cristal Diapasón | Mítico | 100.896 | 3.057 | 2 | 13.759 | 250 | Catalizador de Cristal Diapasón | 0,50 % |
| 7 | Obsidiana Mate | Común | 19.372 | 202 | 4 | 2.414 | 60 | Lingote de Obsidiana Mate | 55,00 % |
| 7 | Titanio Sombrío | Poco común | 29.058 | 363 | 4 | 3.380 | 60 | Lingote de Titanio Sombrío | 25,00 % |
| 7 | Ónice Veteado | Raro | 45.201 | 646 | 3 | 4.829 | 90 | Placa de Ónice Veteado | 12,00 % |
| 7 | Espinela Nocturna | Épico | 71.031 | 1.211 | 3 | 7.243 | 150 | Gema tallada de Espinela Nocturna | 5,50 % |
| 7 | Iridio Umbrío | Legendario | 113.003 | 2.422 | 2 | 10.865 | 210 | Núcleo de Iridio Umbrío | 2,00 % |
| 7 | Diamante de Raíz Negra | Mítico | 177.577 | 5.045 | 2 | 16.901 | 300 | Catalizador de Diamante de Raíz Negra | 0,45 % |
| 7 | Semilla de Vacío | Ultra raro | 290.580 | 12.108 | 1 | 26.559 | 420 | Esencia de Semilla de Vacío | 0,05 % |
| 8 | Escoria Roja | Común | 33.962 | 333 | 4 | 2.893 | 70 | Lingote de Escoria Roja | 55,00 % |
| 8 | Wolframio Fundido | Poco común | 50.942 | 599 | 4 | 4.050 | 70 | Lingote de Wolframio Fundido | 25,00 % |
| 8 | Cinabrio Líquido | Raro | 79.244 | 1.065 | 3 | 5.785 | 105 | Placa de Cinabrio Líquido | 12,00 % |
| 8 | Ópalo de Fuego | Épico | 124.526 | 1.998 | 3 | 8.678 | 175 | Gema tallada de Ópalo de Fuego | 5,50 % |
| 8 | Paladio Solar | Legendario | 198.109 | 3.995 | 2 | 13.017 | 245 | Núcleo de Paladio Solar | 2,00 % |
| 8 | Corindón Volcánico | Mítico | 311.314 | 8.324 | 2 | 20.248 | 350 | Catalizador de Corindón Volcánico | 0,45 % |
| 8 | Corazón de Caldera | Ultra raro | 509.424 | 19.977 | 1 | 31.819 | 490 | Esencia de Corazón de Caldera | 0,05 % |
| 9 | Vidrio de Roca | Común | 59.333 | 549 | 4 | 3.400 | 80 | Lingote de Vidrio de Roca | 55,00 % |
| 9 | Berilo Translúcido | Poco común | 88.999 | 989 | 4 | 4.760 | 80 | Lingote de Berilo Translúcido | 25,00 % |
| 9 | Turmalina Vitral | Raro | 138.443 | 1.758 | 3 | 6.800 | 120 | Placa de Turmalina Vitral | 12,00 % |
| 9 | Kunzita Coral | Épico | 217.554 | 3.296 | 3 | 10.200 | 200 | Gema tallada de Kunzita Coral | 5,50 % |
| 9 | Alejandrita Prisma | Legendario | 346.108 | 6.593 | 2 | 15.300 | 280 | Núcleo de Alejandrita Prisma | 2,00 % |
| 9 | Diamante Catedral | Mítico | 543.885 | 13.734 | 2 | 23.800 | 400 | Catalizador de Diamante Catedral | 0,45 % |
| 9 | Rosetón Luminoso | Ultra raro | 889.993 | 32.963 | 1 | 37.400 | 560 | Esencia de Rosetón Luminoso | 0,05 % |
| 10 | Polvo Estelar | Común | 103.338 | 906 | 4 | 3.937 | 90 | Lingote de Polvo Estelar | 55,00 % |
| 10 | Meteorito Férreo | Poco común | 155.007 | 1.632 | 4 | 5.511 | 90 | Lingote de Meteorito Férreo | 25,00 % |
| 10 | Moldavita Astral | Raro | 241.122 | 2.901 | 3 | 7.873 | 135 | Placa de Moldavita Astral | 12,00 % |
| 10 | Tanzanita Cósmica | Épico | 378.906 | 5.439 | 3 | 11.810 | 225 | Gema tallada de Tanzanita Cósmica | 5,50 % |
| 10 | Oricalco Sideral | Legendario | 602.805 | 10.878 | 2 | 17.714 | 315 | Núcleo de Oricalco Sideral | 2,00 % |
| 10 | Estelita Pura | Mítico | 947.266 | 22.662 | 2 | 27.556 | 450 | Catalizador de Estelita Pura | 0,45 % |
| 10 | Fragmento de Nova | Ultra raro | 1.550.071 | 54.388 | 1 | 43.302 | 630 | Esencia de Fragmento de Nova | 0,05 % |

Uso en fabricación según la rareza del material:

| Rareza | Material | Uso |
|---|---|---|
| Común | Lingote | Fabricar picos y armas Común y Poco común |
| Poco común | Lingote | Subir el nivel de objeto del 1 al 5 |
| Raro | Placa | Fabricar picos y armas Raro y Épico; nivel de objeto del 6 al 10 |
| Épico | Gema tallada | Ranuras de mejora (+10% cada una) |
| Legendario | Núcleo | Fabricar picos y armas Legendario |
| Mítico | Catalizador | Fabricar picos y armas Mítico; Despertar de habilidad |
| Ultra raro | Esencia | Fabricar picos y armas Ultra raro |

- Zonas con Ultra raro: 3, 5, 7, 8, 9 y 10. Zonas sin Ultra raro: 1, 2, 4 y 6.
- Las cantidades de cada receta se fijan en la Etapa 6.

---

## 3. Tabla de picos

Hay 75 picos: 10 zonas × 7 rarezas, más 5 Celestiales anclados a las zonas 6 a 10. El listado fila a fila está en `calculos/b3_picos.csv`.

### 3.1 Potencia base por zona y rareza

| Zona | Nivel | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro | Celestial |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 100 | 115 | 132 | 152 | 175 | 198 | 220 | — |
| 2 | 100 | 165 | 190 | 218 | 251 | 289 | 327 | 363 | — |
| 3 | 200 | 272 | 313 | 359 | 414 | 476 | 539 | 599 | — |
| 4 | 300 | 449 | 517 | 593 | 683 | 786 | 889 | 988 | — |
| 5 | 400 | 741 | 852 | 978 | 1.127 | 1.297 | 1.468 | 1.631 | — |
| 6 | 500 | 1.223 | 1.406 | 1.614 | 1.859 | 2.140 | 2.422 | 2.691 | 3.180 |
| 7 | 600 | 2.018 | 2.321 | 2.664 | 3.067 | 3.531 | 3.995 | 4.439 | 5.247 |
| 8 | 700 | 3.330 | 3.829 | 4.395 | 5.061 | 5.827 | 6.593 | 7.325 | 8.657 |
| 9 | 800 | 5.494 | 6.318 | 7.252 | 8.351 | 9.614 | 10.878 | 12.086 | 14.284 |
| 10 | 900 | 9.065 | 10.424 | 11.965 | 13.778 | 15.863 | 17.948 | 19.942 | 23.568 |

Nombres: «Pico de» + Pizarra, Verdín, Sal, Brasa, Escarcha, Eco, Obsidiana, Magma, Vitral o Astral (zonas 1 a 10), con la rareza como grado.

### 3.2 Propiedades por rareza

| Rareza | Mult. potencia | Golpes/s | Minería para equipar | Habilidad especial |
|---|---|---|---|---|
| Común | 1,00 | 1,00 | 10 × (zona − 1) | Ninguna |
| Poco común | 1,15 | 1,02 | 10 × (zona − 1) | Golpe certero: cada 10.º golpe hace daño doble |
| Raro | 1,32 | 1,04 | 12 × (zona − 1) | Veta abierta: 10 % de sacar +1 unidad |
| Épico | 1,52 | 1,06 | 15 × (zona − 1) | Onda sísmica: cada 12 s el golpe daña al 50 % a depósitos a 8 studs |
| Legendario | 1,75 | 1,08 | 20 × (zona − 1) | Prospector: marca depósitos Legendario o superior a 60 studs |
| Mítico | 1,98 | 1,10 | 25 × (zona − 1) | Fractura en cadena: al agotar un depósito, el siguiente empieza con 25 % menos de vida |
| Ultra raro | 2,20 | 1,12 | 30 × (zona − 1) | Resonancia: tras 5 s en el mismo depósito, +15 % de velocidad de golpe |
| Celestial | 2,60 | 1,15 | 30 × (zona − 1) | Eco estelar: 5 % de que el depósito agotado reaparezca al instante (1 vez cada 60 s) |

- **Requisitos para equipar:** el nivel de la zona del pico y la Minería de la tabla. Ejemplo: Pico de Magma Mítico (zona 8) → nivel 700 y Minería 175.
- **Daño por golpe:** `Potencia × MultMinería`, con `MultMinería = 1 + 3·M/(M + 1.000)` (B2).
- **Mínimo de 3 golpes por depósito**, para que un jugador de zona alta no vacíe las zonas bajas de un toque.
- **Velocidad máxima:** 2,0 golpes por segundo contando todos los bonos.

### 3.3 Mejoras

Siguen la fórmula de potencia de B1; los tres bonos se suman y el total no pasa de +100%.

| Mejora | Efecto | Máximo | Material |
|---|---|---|---|
| Nivel de objeto (1 a 10) | +5% de potencia por nivel | +50% | Lingotes Poco común (1–5) y Placas Raro (6–10) de la zona |
| Ranuras de mejora (3) | +10% de potencia por ranura | +30% | Gemas talladas Épico de la zona |
| Despertar de habilidad | +20% de potencia y mejora la habilidad especial | +20% | Catalizador Mítico de la zona |

---

## 4. Tiempo de extracción

Segundos por depósito para una build equilibrada al nivel de entrada de la zona, con un pico de esa zona sin mejoras.

| Zona | Mult. Minería | Pico | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 1,00 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | — |
| 1 | 1,00 | Ultra raro | 2,7 | 4,5 | 6,2 | 8,9 | 14,3 | 22,3 | — |
| 2 | 1,11 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | — |
| 2 | 1,11 | Ultra raro | 2,7 | 4,5 | 6,2 | 8,9 | 14,3 | 22,3 | — |
| 3 | 1,21 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | 90,0 |
| 3 | 1,21 | Ultra raro | 2,7 | 4,5 | 6,2 | 8,9 | 14,3 | 22,3 | 36,6 |
| 4 | 1,30 | Común | 6,0 | 9,0 | 14,0 | 22,0 | 35,0 | 55,0 | — |
| 4 | 1,30 | Ultra raro | 2,7 | 4,5 | 6,2 | 8,9 | 14,3 | 22,3 | — |
| 5 | 1,39 | Común | 7,0 | 10,0 | 15,0 | 23,0 | 36,0 | 56,0 | 91,0 |
| 5 | 1,39 | Ultra raro | 2,7 | 4,5 | 6,2 | 9,8 | 15,2 | 23,2 | 37,5 |
| 6 | 1,47 | Común | 7,0 | 10,0 | 15,0 | 23,0 | 36,0 | 57,0 | — |
| 6 | 1,47 | Ultra raro | 2,7 | 4,5 | 6,2 | 9,8 | 15,2 | 23,2 | — |
| 7 | 1,55 | Común | 7,0 | 10,0 | 15,0 | 23,0 | 37,0 | 57,0 | 93,0 |
| 7 | 1,55 | Ultra raro | 2,7 | 4,5 | 6,2 | 9,8 | 15,2 | 23,2 | 38,4 |
| 8 | 1,62 | Común | 7,0 | 10,0 | 15,0 | 24,0 | 37,0 | 58,0 | 95,0 |
| 8 | 1,62 | Ultra raro | 2,7 | 4,5 | 6,2 | 9,8 | 15,2 | 24,1 | 38,4 |
| 9 | 1,69 | Común | 7,0 | 10,0 | 15,0 | 24,0 | 38,0 | 59,0 | 96,0 |
| 9 | 1,69 | Ultra raro | 2,7 | 4,5 | 6,2 | 9,8 | 15,2 | 24,1 | 39,3 |
| 10 | 1,76 | Común | 7,0 | 10,0 | 16,0 | 24,0 | 38,0 | 60,0 | 98,0 |
| 10 | 1,76 | Ultra raro | 2,7 | 4,5 | 6,2 | 9,8 | 16,1 | 25,0 | 40,2 |

- **F16:** `Tiempo = máx(3, techo(Vida / (Potencia × MultMinería))) / GolpesPorSegundo`.
- Con el pico Común de la zona, el depósito Común cuesta 6–7 s en todas las zonas: la dureza compensa la Minería que gana el jugador.
- El pico Ultra raro reduce el tiempo a menos de la mitad (×2,2 de potencia y ×1,12 de velocidad). El Común con Ultra raro se queda en 2,7 s por el mínimo de 3 golpes.

---

## 5. Generación de depósitos

Los depósitos son compartidos: todos los jugadores de la zona ven los mismos. Cuando uno se agota, reaparece en el mismo punto con una rareza nueva.

### 5.1 Simulación

Dos horas simuladas por caso. Cada minero tarda 6 s en llegar a un depósito libre y lo pica con los tiempos de la zona 5 (build equilibrada, pico Raro).

| Depósitos activos | Regeneración (s) | Mineros en la zona | Tiempo sin depósito libre | Depósitos/hora por minero | Depósitos libres de media | Ultra raros nuevos por hora |
|---|---|---|---|---|---|---|
| 20 | 30 | 1 | 0,0 % | 255 | 16,9 | 0,50 |
| 20 | 30 | 4 | 0,0 % | 260 | 7,5 | 0,00 |
| 20 | 30 | 8 | 20,3 % | 206 | 0,2 | 1,50 |
| 20 | 30 | 12 | 46,5 % | 138 | 0,0 | 1,00 |
| 20 | 30 | 20 | 68,0 % | 83 | 0,0 | 0,50 |
| 30 | 45 | 1 | 0,0 % | 263 | 25,8 | 0,00 |
| 30 | 45 | 4 | 0,0 % | 260 | 13,2 | 1,00 |
| 30 | 45 | 8 | 11,7 % | 228 | 0,5 | 1,00 |
| 30 | 45 | 12 | 40,2 % | 154 | 0,1 | 0,00 |
| 30 | 45 | 20 | 64,1 % | 92 | 0,0 | 1,00 |
| 40 | 45 | 1 | 0,0 % | 249 | 35,9 | 0,00 |
| 40 | 45 | 4 | 0,0 % | 259 | 23,2 | 1,00 |
| 40 | 45 | 8 | 0,0 % | 260 | 6,4 | 0,00 |
| 40 | 45 | 12 | 20,8 % | 205 | 0,2 | 1,50 |
| 40 | 45 | 20 | 52,2 % | 123 | 0,0 | 1,00 |
| 40 | 60 | 1 | 0,0 % | 260 | 34,7 | 0,00 |
| 40 | 60 | 4 | 0,0 % | 260 | 18,9 | 0,50 |
| 40 | 60 | 8 | 6,8 % | 240 | 1,0 | 1,00 |
| 40 | 60 | 12 | 36,5 % | 163 | 0,1 | 1,00 |
| 40 | 60 | 20 | 61,9 % | 98 | 0,0 | 1,00 |
| 60 | 45 | 12 | 0,0 % | 259 | 9,6 | 1,50 |
| 80 | 45 | 16 | 0,0 % | 259 | 13,0 | 1,50 |
| 80 | 45 | 20 | 5,5 % | 243 | 1,2 | 2,00 |

### 5.2 Valores elegidos

| Parámetro | Valor |
|---|---|
| Depósitos activos base por zona | 40 |
| Tiempo de regeneración | 45 s |
| Escalado | +5 depósitos por cada minero por encima de 8 |
| Máximo de depósitos activos | 80 |
| Jugadores por servidor (supuesto) | 20 |

- Con 40 depósitos y 45 s, hasta 8 mineros no esperan nunca (0,0% del tiempo sin depósito libre).
- Con 12 mineros y 40 depósitos se pierde el 20,8% del tiempo. Con el escalado (60 depósitos) vuelve a 0,0%.
- Con los 20 jugadores del servidor en la misma zona y el máximo de 80, la espera es del 5,5%. Es el peor caso posible y se considera aceptable.
- Aparecen entre 1 y 2 depósitos Ultra raro por hora en una zona con actividad.

### 5.3 Reglas

- **Rareza al reaparecer:** tabla de B1, con la Suerte media de los jugadores presentes en la zona (precisión de B1: la Suerte de depósitos es de grupo, no individual, porque el depósito es compartido).
- **Reparto:** si varios jugadores pican el mismo depósito, las unidades se reparten en proporción al daño. Quien haga al menos el 10% del daño recibe como mínimo 1 unidad.
- **XP:** cada jugador recibe la XP en proporción a su daño.

---

## 6. Ritmo e ingresos del minero PvE

Minero con pico Raro de su zona, al nivel medio de la zona, con mochila de 60 unidades y 40 s por viaje al banco.

| Zona | Build | Nivel | Minería | s medios por depósito | Depósitos/hora | Monedas/hora | XP/hora | XP/hora objetivo (B2) |
|---|---|---|---|---|---|---|---|---|
| 1 | Equilibrada (12,5 %) | 50 | 18 | 7,1 | 230 | 4.782 | 52.224 | 52.200 |
| 1 | Minería (50 %) | 50 | 75 | 5,9 | 249 | 5.181 | 56.587 | 52.200 |
| 2 | Equilibrada (12,5 %) | 150 | 56 | 7,1 | 230 | 7.890 | 151.870 | 151.800 |
| 2 | Minería (50 %) | 150 | 225 | 5,4 | 259 | 8.884 | 170.989 | 151.800 |
| 3 | Equilibrada (12,5 %) | 250 | 93 | 7,0 | 232 | 12.418 | 258.511 | 261.000 |
| 3 | Minería (50 %) | 250 | 375 | 4,7 | 273 | 15.586 | 310.440 | 261.000 |
| 4 | Equilibrada (12,5 %) | 350 | 131 | 7,0 | 231 | 20.419 | 374.893 | 379.800 |
| 4 | Minería (50 %) | 350 | 525 | 4,6 | 274 | 25.565 | 452.207 | 379.800 |
| 5 | Equilibrada (12,5 %) | 450 | 168 | 7,0 | 231 | 33.692 | 501.634 | 508.200 |
| 5 | Minería (50 %) | 450 | 675 | 4,6 | 274 | 42.511 | 605.571 | 508.200 |
| 6 | Equilibrada (12,5 %) | 550 | 206 | 7,0 | 231 | 55.523 | 637.059 | 646.200 |
| 6 | Minería (50 %) | 550 | 825 | 4,6 | 274 | 69.600 | 769.394 | 646.200 |
| 7 | Equilibrada (12,5 %) | 650 | 243 | 7,0 | 231 | 91.613 | 782.571 | 793.800 |
| 7 | Minería (50 %) | 650 | 975 | 4,7 | 273 | 115.569 | 944.511 | 793.800 |
| 8 | Equilibrada (12,5 %) | 750 | 281 | 7,1 | 230 | 150.461 | 933.204 | 951.000 |
| 8 | Minería (50 %) | 750 | 1000 | 5,4 | 259 | 180.726 | 1.072.440 | 951.000 |
| 9 | Equilibrada (12,5 %) | 850 | 318 | 7,5 | 225 | 242.713 | 1.072.374 | 1.117.800 |
| 9 | Minería (50 %) | 850 | 1000 | 5,4 | 258 | 297.570 | 1.257.887 | 1.117.800 |
| 10 | Equilibrada (12,5 %) | 950 | 356 | 7,5 | 225 | 399.993 | 1.240.108 | 1.294.200 |
| 10 | Minería (50 %) | 950 | 1000 | 5,9 | 251 | 476.187 | 1.412.484 | 1.294.200 |

- El minero equilibrado hace 225–232 depósitos por hora. El supuesto de B2 (240 acciones por hora) queda validado con un 4–6% de margen.
- La XP por hora del minero equilibrado coincide con el objetivo de B2 (entre −4% y 0%).
- La build de Minería gana entre un 8% y un 26% más de monedas que la equilibrada: dentro del límite de 1,3 veces.
- Estas monedas por hora son la base para los precios de la Etapa 6.

---

## 7. Zonas Fracturadas

Cada zona de la mina tiene su Zona Fracturada: un área aparte, opcional, con PvP siempre activo **[CONFIRMADO]**. Los valores del GDD no se han visto; estos son los de partida propuestos.

### 7.1 Multiplicador de valor

- El mineral picado en una Zona Fracturada es «mineral fracturado».
- **Si se extrae** por un Punto de Extracción, vale **×2,0** y da ×1,25 de XP.
- **Si no se extrae** (el jugador muere y conserva una parte), esa parte vale ×1,0, como mineral normal.
- Depósitos: misma tabla de rarezas que la zona PvE, sin Suerte (B1).
- **Contenedor de grieta (añadido en la Etapa 6):** dentro de la Zona Fracturada la mochila admite el doble (120 unidades base). Con 60, una carga completa valía 4 minutos de ingreso y el saqueo no tenía sentido.
- **Racha de extracción (Etapa 6):** +2% al multiplicador por cada extracción seguida, hasta +10% (×2,20). Con ella el máximo teórico pasa de 2,00 a 2,43 veces el PvE (B6, sección 7), todavía bajo el techo de 2,5.

### 7.2 Debuff de carga

- **F17:** `Velocidad = VelocidadBase × (1 − 0,30 × c^1,5)` y `CosteDash = 20 × (1 + 0,5 × c)`, con `c = carga / capacidad`.

| Carga / capacidad | Velocidad de movimiento | Coste del dash | Visible en el minimapa |
|---|---|---|---|
| 0 % | 100,0 % | 20,0 | No |
| 25 % | 96,2 % | 22,5 | No |
| 50 % | 89,4 % | 25,0 | No |
| 75 % | 80,5 % | 27,5 | Sí |
| 100 % | 70,0 % | 30,0 | Sí |

- Con la mochila llena, un jugador con Velocidad 1.000 se mueve a WalkSpeed 14,0. Un saqueador sin carga y sin puntos en Velocidad va a 16,0: lo alcanza.
- A partir del 75% de carga, el jugador aparece en el minimapa de todos.
- Solo se aplica dentro de las Zonas Fracturadas.

### 7.3 Saqueo

Al morir contra un jugador con 100 unidades de carga:

| Destino | Unidades | Regla |
|---|---|---|
| Las conserva la víctima | 50 | Reaparece fuera de la Zona Fracturada; valen ×1,0 |
| Cofre de Saqueo | 35 | El 70% de lo que se suelta |
| Destruidas | 15 | El 30% de lo que se suelta; sumidero de la economía |

- **Se suelta el 50%** de la carga **[PROVISIONAL]**; se eligen primero las unidades más valiosas.
- **Cofre de Saqueo:** dura 90 s. Los primeros 10 s solo lo abre quien mató (y su escuadrón). Abrirlo lleva 3 s y se interrumpe con daño.
- Lo saqueado sigue siendo mineral fracturado: el saqueador también tiene que extraerlo para cobrar ×2,0.
- El saqueador necesita hueco en la mochila; lo que no cabe se queda en el cofre.
- **Muerte contra un enemigo o el entorno** dentro de la Zona Fracturada: se suelta el 20% en un cofre que puede abrir cualquiera.
- Nunca se pierden armas, picos, mascotas, monedas ni nivel **[CONFIRMADO]**.

### 7.4 Valor esperado para el minero

| Prob. de morir antes de extraer | Valor esperado del viaje (PvE = 1,00) | Parte que va al saqueador | Parte destruida |
|---|---|---|---|
| 0 % | 2,00 | 0,00 | 0,00 |
| 10 % | 1,85 | 0,07 | 0,01 |
| 20 % | 1,70 | 0,14 | 0,03 |
| 30 % | 1,55 | 0,21 | 0,04 |
| 40 % | 1,40 | 0,28 | 0,06 |
| 50 % | 1,25 | 0,35 | 0,07 |
| 66 % | 1,00 | 0,47 | 0,10 |
| 80 % | 0,80 | 0,56 | 0,12 |

- Valores relativos a picar la misma carga en PvE (= 1,00).
- El minero sale ganando frente al PvE mientras muera en menos del 66,7% de los viajes.
- El máximo teórico de esta tabla es 2,00. Con la racha y los contratos de la Etapa 6 sube a 2,43, por debajo del techo de 2,5 que fija el prompt.

### 7.5 Puntos de Extracción

| Parámetro | Valor |
|---|---|
| Puntos por Zona Fracturada | 3 |
| Activos a la vez | 1 |
| Rotación | Cada 120 s |
| Aviso del siguiente punto | 20 s antes |
| Canalización para extraer | 8 s; el daño recibido la interrumpe |
| Carga mínima para contar en racha y fragmentos | 50% de la capacidad |
| Al extraer | Toda la carga se asegura y va al banco; el jugador sale a la entrada PvE |

### 7.6 Protección de novato

- **Escudo de novato:** en las 3 primeras entradas a cualquier Zona Fracturada, el jugador no puede atacar ni ser atacado durante 120 s. Se rompe si ataca a otro jugador o si pasa del 50% de carga.
- **Escudo de entrada:** 5 s de invulnerabilidad al entrar, siempre.
- **Sincronización de nivel:** en la Zona Fracturada de la zona `z`, el nivel efectivo máximo es `100 × z`. Un jugador de nivel 1.000 en la zona 2 pelea como uno de nivel 200. Las reglas de detalle van en la Etapa 4.
- **Carga mínima:** con menos del 10% de carga no se suelta nada al morir.
- **Aviso previo:** la primera vez se explica en pantalla qué se arriesga y qué no.

### 7.7 Anti-acampada

| Regla | Valor |
|---|---|
| Acampar un Punto de Extracción | Más de 45 s a menos de 25 studs sin canalizar: el jugador queda marcado en el mapa y pierde 5% de vida máxima por segundo |
| Marca de saqueador | 3 muertes de jugadores en 5 minutos: visible en el mapa para todos durante 60 s |
| Misma víctima | Matar al mismo jugador otra vez en menos de 10 minutos no suelta carga |
| Reentrada | 30 s de espera tras morir antes de volver a entrar |
| Rotación de extracción | El punto cambia cada 120 s, así que no hay una posición fija que defender |

---

## 8. Muerte en minas PvE, banco y jugadores nuevos

| Regla | Valor |
|---|---|
| Pérdida al morir en PvE | 20% de la carga **[CONFIRMADO]** |
| Destino de lo perdido | Queda en un saco en el lugar de la muerte; solo su dueño puede recogerlo durante 120 s. Después se destruye |
| Protección de jugador nuevo | Por debajo del nivel 25 no se pierde nada |
| Reaparición | En la entrada de la zona |
| Mochila base | 60 unidades (las ampliaciones se definen en la Etapa 6) |
| Banco | En la ciudad y en la entrada de cada zona PvE. Depositar lleva 3 s. Lo guardado no se pierde nunca |
| Banco en Zonas Fracturadas | No hay: solo se asegura la carga extrayendo |
| Venta | En la ciudad o al mercader de la entrada de zona (precios en la Etapa 6) |

Con 60 unidades de mochila y 3,77 unidades de media por depósito, el minero vuelve al banco cada 16 depósitos, unos 3,5 minutos.

---

## 9. Problemas de balance detectados y alternativas

### P1 — La XP de minería salía un 37% por encima del objetivo

- **Problema:** con `FactorXP` sin corregir, el minero equilibrado ganaba 71.540 XP/h en zona 1 frente a las 52.200 de B2.
- **Corrección aplicada:** factor 0,73 en la XP de depósito. Ahora coincide (52.224 XP/h). B2 no cambia.

### P2 — Con más de 8 mineros faltan depósitos

- **Problema:** 40 depósitos y 12 mineros dejan un 20,8% de tiempo muerto.
- **Corrección aplicada:** escalado de +5 depósitos por minero por encima de 8, hasta 80. Queda en 0,0% con 12 y 5,5% con 20.

### P3 — Morir en una Zona Fracturada cuesta más del 50% del valor

- **Problema:** la víctima pierde la mitad de las unidades y además el ×2,0 de las que conserva. En valor, se queda con el 25% de lo que habría cobrado al extraer.
- **Alternativas:**

| Opción | Valor que conserva la víctima | Valor esperado con 30% de muertes |
|---|---|---|
| Actual: conserva 50% a ×1,0 | 25% | 1,55 |
| Conserva 50% a ×1,5 | 37,5% | 1,63 |
| Suelta solo el 35% y conserva a ×1,0 | 32,5% | 1,60 |

- **Recomendación:** mantener la regla actual hasta la Etapa 6, que es donde se mide contra el techo de 2,5 y los ingresos del saqueador. Si hay que suavizar, bajar el 50% (decisión C-33).

### P4 — El saqueador puro no produce nada

- **Dato:** con un 30% de muertes de mineros, el saqueador recibe 0,21 por cada 1,00 de carga que entra, y además tiene que extraerlo.
- **Riesgo:** si saquear rinde poco no habrá PvP; si rinde mucho, no habrá mineros.
- **Se resuelve en:** Etapa 6 (ingresos por hora) y Etapa 7 (saqueador frente a minero PvE).

### P5 — La build de combate casi no puede minar minerales raros

- **Dato:** solo llega a Raro en su zona.
- **Por qué se acepta:** es lo que da valor a la estadística Minería. El combatiente tiene sus propias fuentes de ingresos (enemigos y jefes, Etapa 4) y puede bajar de zona para picar rarezas altas.

### P6 — El coste del reinicio de estadísticas de B2 no encaja al principio

- **Problema:** a nivel 150 el reinicio cuesta 150.000 monedas y el minero gana 7.890 por hora: 19 horas, cuando el objetivo era 1–2 horas. A nivel 950 sí encaja (950.000 frente a 399.993 por hora: 2,4 horas).
- **Alternativa:** que el coste siga a los ingresos: `1,5 × monedas por hora de la zona del jugador`. Se fija en la Etapa 6; **cambiará E2-07 en B2**.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| FactorVida y dureza | Prueba de juego: 6–7 s por depósito Común con el pico de la zona |
| 40 depósitos, 45 s, escalado | Telemetría: tiempo sin depósito libre por zona; objetivo, menos del 5% |
| Multiplicador ×2,0 y 50% soltado | Etapas 6 y 7; en beta, proporción de jugadores que vuelve a entrar tras morir |
| Debuff de carga | Prueba de juego: que un saqueador alcance a un minero cargado, pero no a uno al 50% con Velocidad alta |
| Rotación de 120 s y canalización de 8 s | Beta: porcentaje de extracciones interrumpidas; objetivo, entre 20% y 40% |
| Escudo de novato | Beta: abandono tras la primera entrada a una Zona Fracturada |
