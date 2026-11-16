# OREBOUND — B1: Rarezas y probabilidades

Etapa 1 · 2026-11-16 · Script: `calculos/b1_rarezas.py` (todas las cifras de este documento salen de su ejecución).

> **Aviso de fuentes.** No se dispone de las secciones 4, 6 y 12 del prompt maestro ni del GDD.
> Todas las cifras de este documento son **[PROVISIONAL]** salvo las marcadas **[CONFIRMADO]**,
> que son decisiones fijas del prompt. Si llegan las fuentes, mandan ellas y se rehace lo afectado.

---

## 1. Tabla oficial de las 8 rarezas

| Índice | Rareza | Color | Hex | Multiplicador | Dónde aparece |
|---|---|---|---|---|---|
| 1 | Común | Gris piedra | `#9AA0A6` | ×1,00 | Depósitos, cajas estándar, enemigos, tienda |
| 2 | Poco común | Verde | `#4CAF50` | ×1,15 | Depósitos, cajas estándar, enemigos, tienda |
| 3 | Raro | Azul | `#2F80ED` | ×1,32 | Depósitos, cajas estándar, enemigos, fabricación |
| 4 | Épico | Morado | `#9B51E0` | ×1,52 | Depósitos, cajas estándar, élites, fabricación |
| 5 | Legendario | Dorado | `#F2B01E` | ×1,75 | Depósitos, cajas estándar, guardianes y jefes |
| 6 | Mítico | Carmesí | `#E5383B` | ×1,98 | Depósitos, cajas estándar, jefes |
| 7 | Ultra raro | Turquesa prismático | `#19D3C5` | ×2,20 | Depósitos de algunas zonas, cajas estándar, jefes |
| 8 | Celestial | Blanco estelar con halo dorado | `#FFF4D6` | ×2,60 | Solo eventos, jefes de evento y fragmentos (Zonas Fracturadas de zona 6+) |

- Que sean 7 rarezas + Celestial y que Celestial no entre en cajas estándar es **[CONFIRMADO]**.
- Nombres intermedios, colores y multiplicadores son **[PROVISIONAL]**. El prompt solo cita Común, Legendario, Ultra raro y Celestial.
- Los saltos de multiplicador son de un 11–15% entre rarezas vecinas y un 18% hasta Celestial. Toda la escala cabe en ×2,60: la rareza importa, pero menos que la zona (sección 4).
- Accesibilidad: cada rareza lleva además un icono con su número de puntas (1 a 8), para no depender solo del color.

---

## 2. Probabilidades de referencia

### 2.1 Caja estándar (mascotas, armas y zona)

| Rareza | Probabilidad | 1 de cada |
|---|---|---|
| Común | 50,0% | 2 |
| Poco común | 26,0% | 3,8 |
| Raro | 14,0% | 7,1 |
| Épico | 7,0% | 14,3 |
| Legendario | 2,4% | 41,7 |
| Mítico | 0,5% | 200 |
| Ultra raro | 0,1% | 1.000 |
| **Suma** | **100,0%** | |

Legendario o superior: 3,0% antes de la protección contra mala suerte. Con la protección la tasa real es mayor (sección 6).

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

- En las zonas sin Ultra raro, su 0,05% pasa a Mítico.
- Qué zonas tienen Ultra raro se decide en la Etapa 3.
- Las cuatro tablas (2.1, 2.2 y 3.1) se comprueban en el script con fracciones exactas: todas suman 100.

---

## 3. Distribución de Celestial

Celestial no usa las tablas de la sección 2. Tiene tres fuentes propias y ninguna se compra.

### 3.1 Fuentes

| Fuente | Qué da | Valor | Límite |
|---|---|---|---|
| Jefe de evento | Fragmentos garantizados | 2 por derrota | 5 derrotas por semana |
| Jefe de evento | Objeto Celestial completo | 0,5% por derrota | Sin límite |
| Zona Fracturada, zonas 6 a 10 | 1 fragmento al extraer con éxito | 10 / 12,5 / 15 / 17,5 / 20% | 10 fragmentos por semana |
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

- 60 fragmentos Celestiales = 1 objeto Celestial a elegir en la forja de la ciudad.
- Los fragmentos van directos a la cuenta al extraer: no se sueltan al morir y no se comercian. Así se respeta que en las Zonas Fracturadas solo se arriesga el mineral **[CONFIRMADO]**.
- La extracción solo cuenta si la carga es de al menos el 50% de la capacidad, para que no se pueda entrar y salir sin riesgo.
- La Suerte no afecta a ninguna fuente de Celestial.
- Anclaje de potencia: un Celestial usa la `PotZona` de la zona que lo entrega, con mínimo zona 6. Los de jefe de evento y caja de evento se anclan a la zona más alta que el jugador tenga desbloqueada (mínimo 6).

### 3.3 Ritmo previsto

| Perfil | Jefes/semana | Extracciones/semana | Fragmentos/semana | Semanas por Celestial | Celestial directo/semana |
|---|---|---|---|---|---|
| Casual | 2 | 0 | 4,00 | 15,0 | 1,00% |
| Regular | 4 | 10 (zona 7) | 9,25 | 6,5 | 1,99% |
| Dedicado | 5 | 20 (zona 8) | 13,00 | 4,6 | 2,48% |
| Máximo | 5 | 60 (zona 10) | 20,00 | 3,0 | 2,48% |

El tope semanal es 20 fragmentos, así que nadie baja de 3 semanas por objeto salvo por el 0,5% directo.

---

## 4. Fórmula de potencia de objeto

### F1 — Potencia de objeto

- **Expresión:** `Potencia = PotZona(z) × MultRareza(r) × (1 + min(BonoNivel + BonoMejoras + BonoHabilidades, TopeBono))`
- **Con:** `PotZona(z) = PotBase × g^(z−1)`
- **Variables:**
  - `z`: zona del objeto (1 a 10; para Celestial, zona de anclaje).
  - `r`: rareza (multiplicador de la sección 1).
  - `BonoNivel`: 0 a 0,50 según el nivel del objeto.
  - `BonoMejoras`: 0 a 0,30 según las mejoras aplicadas.
  - `BonoHabilidades`: 0 a 0,20 según las habilidades pasivas del objeto.
- **Unidad:** puntos de potencia. La Etapa 3 los convierte en potencia de pico y la Etapa 4 en daño de arma.
- **Valores configurables recomendados:** `PotBase = 100`, `g = 1,65`, `TopeBono = 1,00`.
- **Ejemplo:** pico Épico de zona 4 con nivel +0,25, mejoras +0,15 y habilidades +0,10 → `449 × 1,52 × 1,50 = 1.024`.
- **Límites:** dentro de una zona, el objeto más fuerte posible (Celestial al máximo) vale 5,20 veces el más débil (Común sin mejoras). Ningún bono multiplica a otro: los tres se suman y tienen tope.
- **Posibles problemas:** si en etapas posteriores se añade un bono que multiplique fuera del paréntesis, se rompe el límite de 5,20. Todo bono nuevo debe entrar en la suma.

### 4.1 Potencia por zona

| Zona | PotZona | Común sin mejoras | Ultra raro al máximo | Celestial al máximo |
|---|---|---|---|---|
| 1 | 100 | 100 | 440 | — |
| 2 | 165 | 165 | 726 | — |
| 3 | 272 | 272 | 1.198 | — |
| 4 | 449 | 449 | 1.977 | — |
| 5 | 741 | 741 | 3.261 | — |
| 6 | 1.223 | 1.223 | 5.381 | 6.360 |
| 7 | 2.018 | 2.018 | 8.879 | 10.493 |
| 8 | 3.330 | 3.330 | 14.650 | 17.314 |
| 9 | 5.494 | 5.494 | 24.173 | 28.568 |
| 10 | 9.065 | 9.065 | 39.885 | 47.137 |

Celestial no existe por debajo de la zona 6 (anclaje mínimo).

### 4.2 Demostración: un Común de zona alta supera a un objeto raro de zona baja

| Común sin mejoras | Rival | Potencias | Resultado |
|---|---|---|---|
| Zona 3 | Ultra raro de zona 1 sin mejoras | 272 frente a 220 | El Común es 1,24 veces mejor |
| Zona 4 | Ultra raro de zona 1 al máximo | 449 frente a 440 | El Común es 1,02 veces mejor |
| Zona 10 | Ultra raro de zona 6 al máximo | 9.065 frente a 5.381 | El Común es 1,68 veces mejor |
| Zona 9 | Celestial de anclaje 6 sin mejoras | 5.494 frente a 3.180 | El Común es 1,73 veces mejor |
| Zona 10 | Celestial de anclaje 6 al máximo | 9.065 frente a 6.360 | El Común es 1,43 veces mejor |

Regla general que da el script:

| Rival | Zonas de diferencia para que un Común sin mejoras lo supere |
|---|---|
| Ultra raro sin mejoras | 2 |
| Ultra raro al máximo | 3 |
| Celestial sin mejoras | 2 |
| Celestial al máximo | 4 |

Consecuencia de diseño: un objeto muy mejorado aguanta 2 o 3 zonas, no más. Avanzar de zona siempre acaba ganando a quedarse mejorando.

---

## 5. Sistema de Suerte

### F2 — Factor de suerte

- **Expresión:** `F(S) = 1 + Fmax × S / (S + K)`
- **Variables:** `S` = Suerte total del jugador (estadística + equipo + consumibles).
- **Unidad:** multiplicador sin dimensión.
- **Valores configurables recomendados:** `Fmax = 3`, `K = 1.000`.
- **Ejemplo:** Suerte 500 → `1 + 3 × 500/1.500 = 2,000`.
- **Límites:** `F` va de 1 a 4 y nunca llega a 4.
- **Posibles problemas:** con `K = 1.000` la mitad del efecto llega en Suerte 1.000; si la Etapa 2 hace que la Suerte se consiga muy rápido, hay que subir `K`.

### F3 — Peso ajustado y normalización

- **Expresión:** `Peso'(r) = Peso(r) × F(S)^e(r)` y `P(r) = Peso'(r) / Σ Peso'`
- **Variables:** `Peso(r)` = probabilidad base de la tabla; `e(r)` = exponente de la rareza.
- **Exponentes recomendados:** Común 0 · Poco común 0,2 · Raro 0,4 · Épico 0,6 · Legendario 0,8 · Mítico 1,0 · Ultra raro 1,0.
- **Unidad:** probabilidad en %.
- **Ejemplo:** Ultra raro en caja con Suerte 1.000 → `0,1 × 2,5^1 = 0,25`; tras normalizar, 0,208%.
- **Límites:** con Suerte infinita, Ultra raro pasa de 0,100% a 0,297% y Legendario o superior de 3,0% a 7,197%.
- **Posibles problemas:** la normalización hace que el aumento real sea menor que `F`. Hay que enseñar al jugador la probabilidad final, no el factor.

### 5.1 Simulación en caja estándar gratuita

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
| Rareza del depósito que aparece | Sí | Es el uso principal de la estadística |
| Botín de enemigos comunes, élites y guardianes | Sí | Recompensa repetible de PvE |
| Tiradas extra de jefes | Sí | Solo las tiradas extra |
| Cajas compradas con monedas del juego | Sí | Recompensa gratuita |
| Material garantizado de jefe | No | Es fijo; no puede depender del azar |
| Cajas compradas con Robux | No | Sus probabilidades deben ser fijas y publicadas |
| Garantías de la protección contra mala suerte | No | Son deterministas |
| Fragmentos y objetos Celestiales | No | Celestial se gana por constancia |
| Botín y Cofres de Saqueo en Zonas Fracturadas | No | La Suerte no debe decidir el PvP |
| Recompensas de misiones, logros y temporada | No | Son fijas |

---

## 6. Protección contra mala suerte

Cada tipo de caja lleva dos contadores propios por jugador. Los de una caja no afectan a otra.

### F4 — Contador A: Legendario o superior

- **Expresión**, con `n` = número de apertura desde el último Legendario o superior:
  - `p(n) = p0` si `n ≤ 40`
  - `p(n) = p0 + (1 − p0) × ((n − 40) / 10)²` si `41 ≤ n ≤ 49`
  - `p(n) = 1` si `n = 50`
- **Variables:** `p0` = probabilidad base de Legendario o superior de esa caja (3,0% en la estándar; con Suerte, la de la tabla 5.1).
- **Unidad:** probabilidad por apertura.
- **Valores configurables recomendados:** inicio de rampa 40, garantía 50, exponente 2.
- **Ejemplo:** apertura 45 → `0,03 + 0,97 × 0,25 = 27,25%`.
- **Límites:** nunca hay más de 50 aperturas seguidas sin Legendario o superior.
- **Posibles problemas:** sube la tasa real por encima de la base (ver 6.2).

Cuando el contador A da premio, la rareza se sortea entre Legendario, Mítico y Ultra raro con sus pesos relativos (2,4 : 0,5 : 0,1). El contador vuelve a 0 con cualquier Legendario o superior.

### F5 — Contador B: Mítico o superior

- **Expresión:** si `m = 100`, premio garantizado de Mítico o superior; `m` = aperturas desde el último Mítico o superior.
- **Premio:** se sortea entre Mítico y Ultra raro con sus pesos relativos (0,5 : 0,1).
- **Valor configurable recomendado:** garantía en 100.
- **Ejemplo:** 99 aperturas sin Mítico → la 100 es Mítico (83,3%) o Ultra raro (16,7%).
- **Límites:** nunca hay más de 100 aperturas sin Mítico o superior.

### Reglas para que no haya contradicciones

1. En cada apertura se comprueba primero B y después A.
2. Si B se activa, su premio también pone A a 0 (un Mítico es «Legendario o superior»).
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

Solo el 0,27% de las rachas llega a la garantía de la apertura 50; la rampa resuelve casi todas antes. Sin protección, el 21,81% de los jugadores pasaría 50 aperturas sin un Legendario.

### 6.2 Simulación de 100.000 aperturas (caja estándar)

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

- **Tasa real de Legendario o superior: 4,449%** (base 3,0%). El cálculo analítico del contador A solo da 3,995%; el resto lo aporta el contador B.
- Semilla fija `20261116`, para que el resultado se pueda reproducir.

---

## 7. Problemas de balance detectados y alternativas

### P1 — La garantía de la apertura 100 dobla con creces la tasa de Mítico y Ultra raro

- **Problema:** Mítico o superior pasa de 0,600% a 1,399% y Ultra raro de 0,100% a 0,228%. La base de Mítico+ es tan baja que casi todos los ciclos acaban en la garantía (643 de cada 100.000 aperturas).
- **Alternativas:**

| Garantía de Mítico+ en la apertura | Tasa aproximada de Mítico+ |
|---|---|
| 100 (actual) | 1,327% |
| 150 | 1,009% |
| 200 | 0,857% |
| 300 | 0,718% |

- **Recomendación:** mantener 100, porque es la cifra pedida, y tratar 1,399% y 0,228% como las tasas oficiales. La Etapa 6 debe poner precio a las cajas con las tasas reales, no con las base. Si entonces Ultra raro resulta demasiado frecuente, bajar su peso base de 0,1 a 0,05 antes que mover la garantía.

### P2 — La tasa publicada debe ser la real

- **Problema:** si el juego muestra «Legendario 2,4%» pero entrega 3,05%, la información al jugador es inexacta.
- **Alternativa:** mostrar las dos cosas: probabilidad base por apertura y texto de garantía («Legendario o superior garantizado en 50 aperturas; Mítico o superior en 100»). La Etapa 6 lo contrasta con la política de Roblox.

### P3 — La Suerte puede acumularse desde varias fuentes

- **Problema:** estadística, equipo, mascotas y consumibles pueden sumar mucha Suerte.
- **Alternativa ya aplicada:** todas las fuentes suman en `S` y pasan por `F(S)`, que no supera ×4. Ninguna fuente puede multiplicar `F` directamente. Con Suerte infinita, Legendario+ se queda en 7,197%.

### P4 — La Suerte casi no se nota al principio

- **Problema:** con Suerte 10, Legendario+ pasa de 3,000% a 3,059%. Un jugador nuevo no percibe el cambio.
- **Alternativa:** si las pruebas lo confirman, bajar `K` de 1.000 a 500 (Suerte 100 daría `F = 1,5` en vez de 1,273). Se decide en la Etapa 2, cuando se sepa cuánta Suerte hay por nivel.

### P5 — Celestial es solo un 18% mejor que Ultra raro

- **Problema:** ×2,60 frente a ×2,20 puede parecer poco para 3–15 semanas de esfuerzo.
- **Por qué se mantiene:** un salto mayor rompería el PvP de las Zonas Fracturadas. El atractivo extra de Celestial debe venir de una habilidad única y del aspecto, no de la potencia. Se concreta en las Etapas 3, 4 y 5.

### P6 — Un objeto muy mejorado deja de servir en 3 zonas

- **Problema:** el jugador puede sentir que la inversión en mejoras se pierde.
- **Alternativa:** en la Etapa 6, devolver parte de los materiales al reciclar el objeto, o permitir traspasar un porcentaje de las mejoras al objeto de la zona siguiente.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| Multiplicadores de rareza | Etapa 7: builds con equipo común, ultra raro y Celestial en la misma zona |
| `g = 1,65` | Etapa 3 y 4: tiempos de extracción y de combate al cambiar de zona |
| `Fmax` y `K` | Etapa 7: build con todo en Suerte frente a build equilibrada, en monedas por hora |
| Rampa 40–50 y garantía 100 | Telemetría de beta: distribución real de rachas sin premio por tipo de caja |
| Fragmentos Celestiales | Beta: semanas reales hasta el primer Celestial por perfil de jugador |
