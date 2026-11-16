# OREBOUND — B1: Rarezas y probabilidades

Etapa 1, rehecha con el GDD · 2026-11-16 · Script: `calculos/b1_rarezas.py` (genera este documento; todas las cifras salen de su ejecución).

> **Fuentes.** Esta versión usa el GDD de combate, minería PvPvE y mascotas (`00_Fuentes/`).
> De él vienen los nombres, colores y multiplicadores de las rarezas y los 50 fragmentos por
> objeto Celestial. El GDD marca sus cifras como pendientes de simulación, así que son
> **[PROVISIONAL]**. No se dispone del prompt maestro: las probabilidades de caja y de
> depósitos y el sistema de Suerte siguen siendo propuestas **[PROVISIONAL]**.
> Son **[CONFIRMADO]**: 7 rarezas más Celestial, y Celestial fuera de las cajas estándar.

---

## 1. Tabla oficial de las 8 rarezas

| Índice | Rareza | Color | Tratamiento visual | Multiplicador | Dónde aparece |
|---|---|---|---|---|---|
| 1 | Común | Gris | Sin aura; partículas de polvo | ×1,00 | Depósitos, cajas estándar, enemigos, tienda |
| 2 | Poco común | Verde | Brillo suave en bordes | ×1,25 | Depósitos, cajas estándar, enemigos, tienda |
| 3 | Raro | Azul | Destello al soltar el objeto | ×1,50 | Depósitos, cajas estándar, enemigos, fabricación |
| 4 | Épico | Morado | Aura pulsante y estela corta | ×1,90 | Depósitos, cajas estándar, élites, fabricación |
| 5 | Legendario | Dorado | Aura, estela y rayos de luz al aparecer | ×2,50 | Depósitos, cajas estándar, guardianes y jefes |
| 6 | Mítico | Rojo | Todo lo anterior y vibración de cámara al obtenerlo | ×3,30 | Depósitos, cajas estándar, jefes |
| 7 | Ultra raro | Arcoíris | Ciclo de color y anuncio en el servidor | ×4,50 | Depósitos de algunas zonas, cajas estándar, jefes |
| 8 | Celestial | Blanco perla con núcleo cian | Halo orbital, partículas que suben y anuncio global | ×5,20 | Solo eventos, jefes de evento y fragmentos de Zonas Fracturadas de zona 6 o más |

- Nombres, colores y tratamiento visual: los del GDD.
- Multiplicadores: el GDD los da por pares (1,00 a 1,50; 1,90 a 2,50; 3,30 a 4,50; 5,20). El 1,25 de Poco común es un supuesto.
- Accesibilidad: cada rareza lleva además un icono con su número de puntas (1 a 8), para no depender solo del color.

---

## 2. Probabilidades de referencia

### 2.1 Caja estándar

| Rareza | Probabilidad | 1 de cada |
|---|---|---|
| Común | 50,0% | 2,0 |
| Poco común | 26,0% | 3,8 |
| Raro | 14,0% | 7,1 |
| Épico | 7,0% | 14,3 |
| Legendario | 2,4% | 41,7 |
| Mítico | 0,5% | 200,0 |
| Ultra raro | 0,1% | 1.000,0 |
| **Suma** | **100,0%** |  |

Legendario o superior: 3,0% antes de la protección contra mala suerte; 4,449% con ella (sección 6).

### 2.2 Aparición de depósitos

| Rareza | Zona con Ultra raro | Zona sin Ultra raro |
|---|---|---|
| Común | 55,00% | 55,00% |
| Poco común | 25,00% | 25,00% |
| Raro | 12,00% | 12,00% |
| Épico | 5,50% | 5,50% |
| Legendario | 2,00% | 2,00% |
| Mítico | 0,45% | 0,50% |
| Ultra raro | 0,05% | 0,00% |
| **Suma** | **100,00%** | **100,00%** |

- En las zonas sin Ultra raro, su 0,05% pasa a Mítico. Qué zonas tienen Ultra raro se decide en B3.
- Las cuatro tablas de este documento se comprueban en el script con fracciones exactas: todas suman 100.

---

## 3. Distribución de Celestial

Celestial no usa las tablas de la sección 2 y ninguna de sus fuentes se compra.

### 3.1 Fuentes

| Fuente | Qué da | Valor | Límite |
|---|---|---|---|
| Depósitos de Zonas Fracturadas, zonas 6 a 10 | 1 fragmento | 0,25% por depósito agotado | Sin límite; va directo a la cuenta |
| Grieta Celestial (evento cada 2 horas) | 1 fragmento | ×4 durante el evento (1,0% por depósito) | Lo que dure el evento |
| Jefe de evento | Fragmentos garantizados | 2 por derrota | 5 derrotas por semana |
| Jefe de evento | Objeto Celestial completo | 0,5% por derrota | Sin límite |
| Caja de evento | Objeto Celestial completo | 0,5% por caja | Las que dé el evento |

Caja de evento (no es estándar; solo se gana jugando el evento):

| Rareza | Probabilidad |
|---|---|
| Raro | 45,0% |
| Épico | 33,0% |
| Legendario | 15,0% |
| Mítico | 5,0% |
| Ultra raro | 1,5% |
| Celestial | 0,5% |
| **Suma** | **100,0%** |

### 3.2 Sistema de fragmentos

- **50 fragmentos Celestiales = 1 objeto Celestial** a elegir en la forja (valor del GDD).
- Los fragmentos van directos a la cuenta: no ocupan mochila, no se sueltan al morir y no se comercian. Así se respeta que en las Zonas Fracturadas solo se arriesga el mineral **[CONFIRMADO]**.
- La Suerte no afecta a ninguna fuente de Celestial.
- **Ruta PvE:** los jefes de evento dan fragmentos sin entrar en ninguna Zona Fracturada, como pide el GDD.
- **Anclaje de potencia:** un Celestial usa la `PotZona` de la zona que lo entrega, con mínimo zona 6. Los de jefe de evento y caja de evento se anclan a la zona más alta que el jugador tenga desbloqueada (mínimo 6).

### 3.3 Problema del valor del GDD y valor adoptado

El GDD propone 0,02% de fragmento por depósito de grieta. A 260 depósitos por hora:

| Probabilidad por depósito | Fragmentos por hora de grieta | Horas de grieta por objeto |
|---|---|---|
| 0,02% (GDD) | 0,052 | 960 |
| 0,10% | 0,260 | 192 |
| 0,25% (adoptada) | 0,651 | 77 |
| 0,50% | 1,302 | 38 |

- Con 0,02% harían falta 960 horas de grieta por objeto. La ruta de jefes de evento sería unas 20 veces más rápida y la grieta dejaría de contar.
- **Valor adoptado: 0,25% por depósito** (77 horas de grieta por objeto).

### 3.4 Ritmo previsto

| Perfil | Jefes de evento/semana | Horas de grieta (zona 6+)/semana | Fragmentos/semana | Semanas por Celestial | Celestial directo/semana |
|---|---|---|---|---|---|
| Solo PvE, casual | 2 | 0 | 4,00 | 12,5 | 1,00% |
| Solo PvE, constante | 5 | 0 | 10,00 | 5,0 | 2,48% |
| Regular | 4 | 4 | 10,60 | 4,7 | 1,99% |
| Dedicado | 5 | 10 | 16,51 | 3,0 | 2,48% |
| Solo grieta | 0 | 10 | 6,51 | 7,7 | 0,00% |

---

## 4. Fórmula de potencia de objeto

### F1 — Potencia de objeto

- **Expresión:** `Potencia = PotZona(z) × MultRareza(r) × (1 + mín(BonoNivel + BonoMejoras + BonoHabilidades, TopeBono))`
- **Con:** `PotZona(z) = PotBase × g^(z−1)`
- **Variables:**
  - `z`: zona del objeto (para Celestial, zona de anclaje).
  - `r`: rareza (multiplicador de la sección 1).
  - `BonoNivel`: 0 a 0,25 según el nivel del objeto.
  - `BonoMejoras`: 0 a 0,15 según las mejoras aplicadas.
  - `BonoHabilidades`: 0 a 0,10 según el Despertar de su habilidad.
- **Unidad:** puntos de potencia. B3 los convierte en potencia de pico y B4 en daño de arma.
- **Valores configurables recomendados:** `PotBase = 100`, `g = 2,00`, `TopeBono = 0,50`.
- **Ejemplo:** pico Épico de zona 4 con +0,25 de bonos → `800 × 1,90 × 1,25 = 1.900`.
- **Límites:** dentro de una zona, el objeto más fuerte posible (Celestial al máximo) vale 7,80 veces el más débil (Común sin mejoras). Los tres bonos se suman y tienen tope; ninguno multiplica a otro.
- **Posibles problemas:** un bono nuevo que multiplique fuera del paréntesis rompería el límite. Todo bono futuro debe entrar en la suma.

### 4.1 Por qué cambian el crecimiento por zona y el tope de bonos

En la primera versión (sin el GDD) los multiplicadores iban de ×1,00 a ×2,60, el crecimiento por zona era 1,65 y los bonos llegaban a +100%. Con los multiplicadores del GDD (hasta ×5,20) esos valores ya no sirven:

- Con crecimiento 1,65 y bonos de +100%, un Común sin mejoras necesitaría 5 zonas de diferencia para superar a un Ultra raro al máximo.
- Un Celestial anclado a la zona 6 y mejorado al máximo valdría ×10,4 la potencia de su zona, y un Común de la zona 10 solo ×7,4: el Celestial de zona baja ganaría, que es justo lo que el GDD pide evitar.
- **Corrección:** crecimiento por zona `g = 2,00` y tope de bonos +50%. La zona 10 tiene 512 veces la potencia de la zona 1.

### 4.2 Potencia por zona

| Zona | PotZona | Común sin mejoras | Ultra raro al máximo | Celestial al máximo |
|---|---|---|---|---|
| 1 | 100 | 100 | 675 | — |
| 2 | 200 | 200 | 1.350 | — |
| 3 | 400 | 400 | 2.700 | — |
| 4 | 800 | 800 | 5.400 | — |
| 5 | 1.600 | 1.600 | 10.800 | — |
| 6 | 3.200 | 3.200 | 21.600 | 24.960 |
| 7 | 6.400 | 6.400 | 43.200 | 49.920 |
| 8 | 12.800 | 12.800 | 86.400 | 99.840 |
| 9 | 25.600 | 25.600 | 172.800 | 199.680 |
| 10 | 51.200 | 51.200 | 345.600 | 399.360 |

Celestial no existe por debajo de la zona 6.

### 4.3 Demostración: un Común de zona alta supera a un objeto raro de zona baja

| Común sin mejoras | Rival | Potencias | Resultado |
|---|---|---|---|
| Zona 4 | Ultra raro de zona 1 sin mejoras | 800 frente a 450 | El Común es 1,78 veces mejor |
| Zona 5 | Ultra raro de zona 2 al máximo | 1.600 frente a 1.350 | El Común es 1,19 veces mejor |
| Zona 10 | Ultra raro de zona 7 al máximo | 51.200 frente a 43.200 | El Común es 1,19 veces mejor |
| Zona 9 | Celestial de zona 6 sin mejoras | 25.600 frente a 16.640 | El Común es 1,54 veces mejor |
| Zona 10 | Celestial de zona 6 al máximo | 51.200 frente a 24.960 | El Común es 2,05 veces mejor |
| Zona 9 | Celestial de zona 6 al máximo | 25.600 frente a 24.960 | El Común es 1,03 veces mejor |

| Rival | Zonas de diferencia para que un Común sin mejoras lo supere |
|---|---|
| Ultra raro sin mejoras | 3 |
| Ultra raro al máximo | 3 |
| Celestial sin mejoras | 3 |
| Celestial al máximo | 3 |

Consecuencia de diseño: un objeto muy mejorado aguanta 2 o 3 zonas. Avanzar de zona siempre acaba ganando a quedarse mejorando.

---

## 5. Sistema de Suerte

### F2 — Factor de suerte

- **Expresión:** `F(S) = 1 + Fmax × S / (S + K)`
- **Variables:** `S` = Suerte total del jugador.
- **Unidad:** multiplicador sin dimensión.
- **Valores configurables recomendados:** `Fmax = 3`, `K = 1.000`.
- **Ejemplo:** Suerte 500 → `1 + 3 × 500/1.500 = 2,000`.
- **Límites:** `F` va de 1 a 4 y nunca llega a 4.
- **Posibles problemas:** si la Suerte se consigue muy rápido, hay que subir `K`.

### F3 — Peso ajustado y normalización

- **Expresión:** `Peso'(r) = Peso(r) × F(S)^e(r)` y `P(r) = Peso'(r) / Σ Peso'`
- **Exponentes recomendados:** Común 0 · Poco común 0,2 · Raro 0,4 · Épico 0,6 · Legendario 0,8 · Mítico 1,0 · Ultra raro 1,0.
- **Unidad:** probabilidad en %.
- **Ejemplo:** Ultra raro en caja con Suerte 1.000 → `0,1 × 2,5 = 0,25`; tras normalizar, 0,208%.
- **Límites:** con Suerte infinita, Ultra raro pasa de 0,100% a 0,298% y Legendario o superior de 3,0% a 7,197%.
- **Posibles problemas:** la normalización hace que el aumento real sea menor que `F`. Hay que enseñar al jugador la probabilidad final, no el factor.

### 5.1 Simulación en caja estándar

| Suerte | F | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro | Legendario+ |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 1,000 | 50,000 | 26,000 | 14,000 | 7,000 | 2,400 | 0,500 | 0,100 | 3,000 |
| 10 | 1,030 | 49,743 | 26,018 | 14,092 | 7,088 | 2,444 | 0,512 | 0,103 | 3,059 |
| 100 | 1,273 | 47,862 | 26,118 | 14,759 | 7,744 | 2,786 | 0,609 | 0,122 | 3,517 |
| 500 | 2,000 | 43,734 | 26,123 | 16,158 | 9,280 | 3,655 | 0,875 | 0,175 | 4,705 |
| 1.000 | 2,500 | 41,649 | 26,013 | 16,824 | 10,104 | 4,161 | 1,041 | 0,208 | 5,410 |
| 2.500 | 3,143 | 39,486 | 25,818 | 17,480 | 10,989 | 4,738 | 1,241 | 0,248 | 6,227 |
| ∞ | 4,000 | 37,191 | 25,519 | 18,131 | 11,962 | 5,412 | 1,488 | 0,297 | 7,197 |

### 5.2 Simulación en depósitos (zona con Ultra raro)

| Suerte | F | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro | Legendario+ |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 1,000 | 55,000 | 25,000 | 12,000 | 5,500 | 2,000 | 0,450 | 0,050 | 2,500 |
| 10 | 1,030 | 54,755 | 25,035 | 12,087 | 5,573 | 2,038 | 0,461 | 0,051 | 2,550 |
| 100 | 1,273 | 52,951 | 25,258 | 12,723 | 6,120 | 2,335 | 0,552 | 0,061 | 2,948 |
| 500 | 2,000 | 48,945 | 25,556 | 14,091 | 7,419 | 3,099 | 0,801 | 0,089 | 3,989 |
| 1.000 | 2,500 | 46,895 | 25,603 | 14,761 | 8,126 | 3,549 | 0,959 | 0,107 | 4,615 |
| 2.500 | 3,143 | 44,748 | 25,575 | 15,436 | 8,895 | 4,067 | 1,151 | 0,128 | 5,346 |
| ∞ | 4,000 | 42,445 | 25,458 | 16,124 | 9,751 | 4,679 | 1,389 | 0,154 | 6,222 |

Todas las filas, en %, suman exactamente 100 (redondeo por mayor resto, comprobado en el script).

### 5.3 Qué recompensas admiten Suerte

| Recompensa | ¿Admite Suerte? | Motivo |
|---|---|---|
| Rareza del depósito que aparece en la mina PvE | Sí, con la Suerte media de los jugadores de la zona (B3) | El depósito es compartido |
| Botín de enemigos comunes, élites y guardianes | Sí | Recompensa repetible de PvE |
| Tiradas extra de jefes | Sí | Solo las tiradas extra |
| Cajas compradas con monedas del juego | Sí | Recompensa gratuita |
| Material garantizado de jefe | No | Es fijo |
| Cajas de pago, si llegaran a existir | No | Sus probabilidades deben ser fijas y publicadas |
| Garantías de la protección contra mala suerte | No | Son deterministas |
| Fragmentos y objetos Celestiales | No | Celestial se gana por constancia |
| Depósitos y Cofres de Saqueo en Zonas Fracturadas | No | La Suerte no debe decidir el PvP |
| Recompensas de misiones, logros y temporada | No | Son fijas |

---

## 6. Protección contra mala suerte

Cada tipo de caja lleva dos contadores propios por jugador. Los de una caja no afectan a otra.

### F4 — Contador A: Legendario o superior

- **Expresión**, con `n` = número de apertura desde el último Legendario o superior:
  - `p(n) = p0` si `n ≤ 40`
  - `p(n) = p0 + (1 − p0) × ((n − 40) / 10)²` si `41 ≤ n ≤ 49`
  - `p(n) = 1` si `n = 50`
- **Variables:** `p0` = probabilidad base de Legendario o superior de esa caja (3,0% en la estándar).
- **Unidad:** probabilidad por apertura.
- **Valores configurables recomendados:** inicio de rampa 40, garantía 50, exponente 2.
- **Ejemplo:** apertura 45 → `0,03 + 0,97 × 0,25 = 27,25%`.
- **Límites:** nunca hay más de 50 aperturas seguidas sin Legendario o superior.
- **Posibles problemas:** sube la tasa real por encima de la base (6.2).

Cuando el contador A da premio, la rareza se sortea entre Legendario, Mítico y Ultra raro con sus pesos relativos (2,4 : 0,5 : 0,1).

### F5 — Contador B: Mítico o superior

- **Expresión:** si `m = 100`, premio garantizado de Mítico o superior; `m` = aperturas desde el último Mítico o superior.
- **Premio:** se sortea entre Mítico y Ultra raro con sus pesos relativos (0,5 : 0,1).
- **Valor configurable recomendado:** garantía en 100.
- **Ejemplo:** 99 aperturas sin Mítico → la 100 es Mítico (83,3%) o Ultra raro (16,7%).
- **Límites:** nunca hay más de 100 aperturas sin Mítico o superior.

### Reglas para que no haya contradicciones

1. En cada apertura se comprueba primero B y después A.
2. Si B se activa, su premio también pone A a 0.
3. Un Legendario pone A a 0 pero no toca B.
4. Las garantías no admiten Suerte; la Suerte solo cambia `p0`.
5. El servidor decide el premio y actualiza los contadores antes de enviar nada al cliente.

### 6.1 Progresión exacta entre las aperturas 40 y 50

| Apertura n | Probabilidad de Legendario+ | Jugadores que llegan a n sin premio |
|---|---|---|
| 1 a 40 | 3,00% | 100,00% → 30,49% |
| 41 | 3,97% | 29,57% |
| 42 | 6,88% | 28,40% |
| 43 | 11,73% | 26,44% |
| 44 | 18,52% | 23,34% |
| 45 | 27,25% | 19,02% |
| 46 | 37,92% | 13,84% |
| 47 | 50,53% | 8,59% |
| 48 | 65,08% | 4,25% |
| 49 | 81,57% | 1,48% |
| 50 | 100,00% | 0,27% |

Sin protección, el 21,81% de los jugadores pasaría 50 aperturas sin un Legendario.

### 6.2 Simulación de 100.000 aperturas

| Rareza | Base | Simulado, Suerte 0 | Simulado, Suerte 1.000 |
|---|---|---|---|
| Común | 50,000% | 49,128% | 41,110% |
| Poco común | 26,000% | 25,573% | 25,937% |
| Raro | 14,000% | 13,888% | 16,648% |
| Épico | 7,000% | 6,962% | 10,093% |
| Legendario | 2,400% | 3,050% | 4,449% |
| Mítico | 0,500% | 1,171% | 1,474% |
| Ultra raro | 0,100% | 0,228% | 0,289% |
| **Legendario o superior** | **3,000%** | **4,449%** | **6,212%** |
| **Mítico o superior** | **0,600%** | **1,399%** | **1,763%** |

| Dato | Suerte 0 | Suerte 1.000 |
|---|---|---|
| Garantías activadas en la apertura 50 | 8 | 5 |
| Garantías activadas en la apertura 100 | 643 | 460 |
| Racha más larga sin Legendario+ | 50 | 50 |

- **Tasa real de Legendario o superior: 4,449%** (base 3,0%). Mítico o superior: 1,399%. Ultra raro: 0,228%.
- Semilla fija `20261116`, para que el resultado se pueda reproducir.

---

## 7. Problemas de balance detectados y alternativas

### P1 — Los multiplicadores del GDD rompían la regla de la zona

- Resuelto en la sección 4.1 con `g = 2,00` y tope de bonos +50%.
- **Efecto secundario:** dentro de una zona, el equipo Celestial al máximo vale 7,80 veces el Común (antes 5,2). La rareza pesa más que en la primera versión; B7 comprueba que no rompa los límites de ingresos.

### P2 — Fragmentos Celestiales al 0,02% (valor del GDD)

- 960 horas de grieta por objeto. **Valor adoptado:** 0,25% (77 horas).

### P3 — La garantía de la apertura 100 dobla con creces la tasa de Mítico y Ultra raro

- Mítico o superior pasa de 0,600% a 1,399% y Ultra raro de 0,100% a 0,228%: la garantía se activa 643 veces en 100.000 aperturas.

| Garantía de Mítico+ en la apertura | Tasa aproximada de Mítico+ |
|---|---|
| 100 | 1,327% |
| 150 | 1,009% |
| 200 | 0,857% |
| 300 | 0,718% |

- **Recomendación:** mantener 100 y tratar las tasas reales como las oficiales. B6 pone precio a las cajas con las tasas reales.

### P4 — La tasa publicada debe ser la real

- El juego debe mostrar la probabilidad base y el texto de las garantías («Legendario o superior garantizado en 50 aperturas; Mítico o superior en 100»).

### P5 — La Suerte puede acumularse desde varias fuentes

- Todas las fuentes suman en `S` y pasan por `F(S)`, que no supera ×4. Con Suerte infinita, Legendario o superior se queda en 7,197%.

### P6 — Un objeto muy mejorado deja de servir en 3 zonas

- B6: reciclar un objeto devuelve parte de los materiales de sus mejoras.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| Multiplicadores de rareza del GDD | B7: equipo Común, Ultra raro y Celestial en la misma zona |
| `g = 2,00` y tope de bonos +50% | B3 y B4: tiempos al cambiar de zona; B7: reglas de ingresos |
| `Fmax` y `K` | B7: build de todo en Suerte frente a equilibrada |
| Rampa 40–50 y garantía 100 | Telemetría de beta: rachas reales sin premio por tipo de caja |
| 0,25% de fragmento por depósito | Beta: semanas reales hasta el primer Celestial |
