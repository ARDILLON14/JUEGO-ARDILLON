# OREBOUND — B2: Progresión y estadísticas

Etapa 2 · 2026-11-16 (corregido en las Etapas 6 y 7; ver B7, sección 6) · Script: `calculos/b2_progresion.py` · Tabla completa de XP: `calculos/b2_xp_niveles.csv` (niveles 1 a 1.000).

> **Aviso de fuentes.** No se dispone de las secciones 5 y 6 del prompt maestro. La fórmula de XP
> viene del prompt de trabajo. Todo lo demás es **[PROVISIONAL]**: las fórmulas originales de las
> estadísticas no se han visto, así que se proponen aquí y se comparan con una raíz cuadrada
> y una lineal de referencia.

---

## 1. XP para el siguiente nivel

### F6 — XP por nivel

- **Expresión:** `XP(L) = techo(100 + 20·L + 0,8·L²)` **[fórmula del prompt]**
- **Variables:** `L` = nivel actual (1 a 1.000). `XP(L)` es lo que cuesta pasar de `L` a `L+1`.
- **Unidad:** puntos de experiencia.
- **Ejemplo:** `XP(100) = techo(100 + 2.000 + 8.000) = 10.100`.
- **Límites:** nivel máximo de lanzamiento 1.000. La XP acumulada cabe sin pérdida de precisión en un número de Roblox (ver sección 4).
- **Posibles problemas:** el término `0,8·L²` domina a partir del nivel 50; la mitad final del juego concentra el 74% del tiempo (sección 3).
- **Valores configurables:** `a = 100`, `b = 20`, `c = 0,8`.

### 1.1 Hitos

| Nivel | XP para el siguiente | XP acumulada hasta el nivel |
|---|---|---|
| 1 | 121 | 0 |
| 10 | 380 | 2.032 |
| 25 | 1.100 | 12.330 |
| 50 | 3.100 | 61.760 |
| 100 | 10.100 | 371.620 |
| 200 | 36.100 | 2.535.340 |
| 250 | 55.100 | 4.789.200 |
| 300 | 78.100 | 8.091.060 |
| 400 | 136.100 | 18.638.780 |
| 500 | 210.100 | 35.778.500 |
| 650 | 351.100 | 77.348.080 |
| 800 | 528.100 | 142.749.660 |
| 1.000 | 820.100 | 276.357.100 |

---

## 2. XP por hora

### F7 — XP por hora de juego activo

- **Expresión:** `XPh(L) = Acciones × (XPbase + k·L)` = `240 × (25 + 3,75·L)` = `6.000 + 900·L`
- **Variables:**
  - `Acciones` = 240 por hora: una acción con XP (derrotar un enemigo o agotar un depósito) cada 15 s, contando desplazamientos y venta.
  - `XPbase + k·L` = XP de una acción en la zona adecuada al nivel.
- **Unidad:** XP por hora.
- **Ejemplo:** nivel 100 → `240 × 400 = 96.000` XP/h.
- **Límites:** supone que el jugador está en la zona de su nivel. En una zona inferior gana menos.
- **Posibles problemas:** es una estimación. La Etapa 3 (tiempos de extracción) y la 4 (tiempos de combate) deben dar la XP por acción real y confirmar las 240 acciones.
- **Por qué estos valores:** 15 s por acción es un ritmo cómodo en móvil; la XP por acción crece de forma lineal porque el contenido nuevo de cada zona da más XP, pero no debe compensar del todo el coste cuadrático del nivel.

---

## 3. Horas de juego por hito

| Nivel | XP/hora | Minutos por nivel | Horas acumuladas | Días a 2 h/día |
|---|---|---|---|---|
| 1 | 6.900 | 1,1 | 0,0 | 0,0 |
| 10 | 15.000 | 1,5 | 0,2 | 0,1 |
| 25 | 28.500 | 2,3 | 0,7 | 0,3 |
| 50 | 51.000 | 3,6 | 1,9 | 0,9 |
| 100 | 96.000 | 6,3 | 6,0 | 3,0 |
| 200 | 186.000 | 11,6 | 20,9 | 10,5 |
| 250 | 231.000 | 14,3 | 31,7 | 15,9 |
| 300 | 276.000 | 17,0 | 44,8 | 22,4 |
| 400 | 366.000 | 22,3 | 77,4 | 38,7 |
| 500 | 456.000 | 27,6 | 119,0 | 59,5 |
| 650 | 591.000 | 35,6 | 198,1 | 99,0 |
| 800 | 726.000 | 43,6 | 297,1 | 148,6 |
| 1.000 | 906.000 | 54,3 | 460,3 | 230,1 |

Horas por tramo de 100 niveles:

| Tramo | Horas | Tramo | Horas |
|---|---|---|---|
| 1–100 | 6,0 | 500–600 | 50,5 |
| 100–200 | 14,9 | 600–700 | 59,4 |
| 200–300 | 23,8 | 700–800 | 68,3 |
| 300–400 | 32,7 | 800–900 | 77,1 |
| 400–500 | 41,6 | 900–1.000 | 86,0 |

### 3.1 Valoración de la curva

- **Niveles 1–100: bien.** Un nivel cada 1–6 minutos; el primer día se llega a nivel 50 en menos de 2 horas.
- **Niveles 100–500: bien.** 113 horas; un nivel cada 6–28 minutos, con una zona nueva cada 15–40 horas.
- **Niveles 500–1.000: lenta.** 341 horas, el 74% del total. El último tramo (900–1.000) cuesta 86 horas y cada nivel casi una hora.

### 3.2 Ajuste propuesto

No se toca la fórmula de XP. Se añade un término cuadrático pequeño a la XP por acción:

`XP por acción = 25 + 3,75·L + 0,002·L²`

| Nivel | Horas (base) | Horas (ajuste) | Minutos por nivel (ajuste) |
|---|---|---|---|
| 100 | 6,0 | 5,8 | 6,0 |
| 300 | 44,8 | 40,7 | 14,7 |
| 500 | 119,0 | 102,0 | 21,9 |
| 800 | 297,1 | 234,1 | 30,7 |
| 1.000 | 460,3 | 344,6 | 35,5 |

El último tramo baja de 86,0 a 57,2 horas y el principio casi no cambia. **Recomendación:** adoptar el ajuste. Objetivo: unas 345 horas hasta nivel 1.000 (172 días a 2 h/día).

Sensibilidad de la curva base si la XP por hora real se desvía:

| XP/hora real | Horas a nivel 1.000 |
|---|---|
| ×0,7 | 657,6 |
| ×1,0 | 460,3 |
| ×1,3 | 354,1 |
| ×1,5 | 306,9 |

---

## 4. Más allá del nivel 1.000

| Nivel | Fórmula original: XP siguiente | XP acumulada | Min/nivel | Cola lineal: XP siguiente | XP acumulada | Min/nivel |
|---|---|---|---|---|---|---|
| 1.000 | 820.100 | 276.357.100 | 54,3 | 820.100 | 276.357.100 | 54,3 |
| 1.100 | 990.100 | 366.648.820 | 59,6 | 910.100 | 362.822.100 | 54,8 |
| 1.200 | 1.176.100 | 474.732.540 | 65,0 | 1.000.100 | 458.287.100 | 55,3 |
| 1.500 | 1.830.100 | 921.735.700 | 81,0 | 1.270.100 | 798.682.100 | 56,2 |
| 2.000 | 3.240.100 | 2.171.914.300 | 107,6 | 1.720.100 | 1.546.007.100 | 57,1 |
| 3.000 | 7.260.100 | 7.286.671.500 | 161,0 | 2.620.100 | 3.715.657.100 | 58,1 |

(Minutos por nivel calculados con la XP por hora base de la sección 2.)

- **La fórmula original no se rompe:** a nivel 3.000 la XP acumulada es 7,3 × 10⁹, muy por debajo del límite de precisión de Roblox (9,0 × 10¹⁵).
- **Pero se vuelve demasiado lenta:** de 1.000 a 2.000 son 1.349 horas, y cada tramo de 100 niveles llega a costar 175 horas.

### F8 — Cola lineal para niveles superiores a 1.000

- **Expresión:** `XP(L) = XP(1.000) + 900 × (L − 1.000)` para `L > 1.000`
- **Variables:** `XP(1.000) = 820.100`; pendiente 900 XP por nivel.
- **Ejemplo:** `XP(1.500) = 820.100 + 450.000 = 1.270.100`.
- **Límites:** cada nivel cuesta 54–58 minutos de forma estable; cada zona nueva de 100 niveles, unas 95 horas.
- **Posibles problemas:** de 1.000 a 2.000 siguen siendo 934 horas. Es aceptable porque ese tramo llegará repartido en varias expansiones.
- **Recomendación:** usar la cola lineal a partir de 1.001. La fórmula del prompt se mantiene intacta de 1 a 1.000.

---

## 5. Puntos de estadística y redistribución

### F9 — Puntos disponibles

- **Expresión:** `Puntos(L) = 3 + 3 × (L − 1)`
- **Unidad:** puntos para repartir.
- **Ejemplo:** nivel 500 → 1.500 puntos.
- **Por encima del nivel 1.000 (Etapa 7):** 1 punto por nivel en lugar de 3, para que a nivel 2.000 solo se puedan llevar al máximo 4 de las 8 estadísticas (con 3 por nivel serían 6).
- **Límites:** máximo 1.000 puntos asignados por estadística. Máximo 5.000 de valor total por estadística sumando equipo, mascotas y consumibles.
- **Valores configurables:** 3 puntos por nivel, tope por puntos 1.000, tope total 5.000.

| Nivel | Puntos | Estadísticas que se pueden llevar a 1.000 | Coste del reinicio |
|---|---|---|---|
| 1 | 3 | 0,00 | Gratis |
| 10 | 30 | 0,03 | Gratis |
| 25 | 75 | 0,07 | Gratis |
| 50 | 150 | 0,15 | 7.244 monedas |
| 100 | 300 | 0,30 | 11.949 monedas |
| 200 | 600 | 0,60 | 19.223 monedas |
| 250 | 750 | 0,75 | 19.223 monedas |
| 300 | 900 | 0,90 | 31.553 monedas |
| 400 | 1.200 | 1,20 | 51.832 monedas |
| 500 | 1.500 | 1,50 | 85.033 monedas |
| 650 | 1.950 | 1,95 | 139.520 monedas |
| 800 | 2.400 | 2,40 | 370.250 monedas |
| 1.000 | 3.000 | 3,00 | 606.651 monedas |

A nivel máximo se pueden llevar al tope 3 de las 8 estadísticas. Eso obliga a elegir build.

### Redistribución

| Vía | Cómo funciona |
|---|---|
| Servicio en la ciudad | Reinicio completo. Gratis por debajo del nivel 50; después 1,5 horas de ingreso de la zona del jugador (B6). Corregido en la Etapa 6: antes `1.000 × nivel`. |
| Objeto «Tomo de Reajuste» | Un reinicio gratis. Se gana en misiones semanales y temporadas. |
| Reinicio parcial | No existe: siempre se devuelven todos los puntos. |

- No se puede redistribuir en combate ni dentro de una Zona Fracturada.
- El coste se fijó en la Etapa 6: 1,5 horas de ingreso de la zona (tabla de arriba, con el ingreso de referencia de B6).

---

## 6. Las 8 estadísticas

Las ocho son: **Fuerza, Vitalidad, Defensa, Velocidad, Energía, Minería, Suerte y Dominio de mascotas**. El prompt nombra siete; la octava (Energía) es propuesta.

### F10 — Curva de saturación (común a todas menos Defensa)

- **Expresión:** `Mult(S) = 1 + M × S / (S + K)`
- **Variables:** `S` = valor total de la estadística; `M` = ganancia máxima; `K` = valor al que se obtiene la mitad de `M`.
- **Unidad:** multiplicador sin dimensión.
- **Valor configurable:** `K = 1.000` para todas; `M` según la tabla.
- **Ejemplo:** Fuerza 1.000 → `1 + 3 × 1.000/2.000 = 2,5`.
- **Límites:** nunca supera `1 + M`, por mucho equipo que se sume.
- **Posibles problemas:** si `K` se queda corto frente a la Suerte o Fuerza que da el equipo, todos los jugadores acaban cerca del máximo y la estadística deja de diferenciar.

Es la misma forma que el factor de Suerte de B1, así que la Suerte de B1 no cambia.

| Estadística | Qué multiplica | M | Punto 1 | Punto 100 | Punto 1.000 | Total con 100 | Total con 1.000 | Total con 5.000 | Tope |
|---|---|---|---|---|---|---|---|---|---|
| Fuerza | Daño de arma y habilidades | 3,0 | +0,300% | +0,248% | +0,075% | ×1,273 | ×2,500 | ×3,500 | ×4,0 |
| Vitalidad | Vida máxima | 3,0 | +0,300% | +0,248% | +0,075% | ×1,273 | ×2,500 | ×3,500 | ×4,0 |
| Minería | Daño de pico a depósitos | 3,0 | +0,300% | +0,248% | +0,075% | ×1,273 | ×2,500 | ×3,500 | ×4,0 |
| Suerte | Factor `F` de B1 | 3,0 | +0,300% | +0,248% | +0,075% | ×1,273 | ×2,500 | ×3,500 | ×4,0 |
| Dominio de mascotas | Daño y vida de mascotas | 3,0 | +0,300% | +0,248% | +0,075% | ×1,273 | ×2,500 | ×3,500 | ×4,0 |
| Dominio de mascotas | Velocidad y radio de recolección | 1,5 | +0,150% | +0,124% | +0,038% | ×1,136 | ×1,750 | ×2,250 | ×2,5 |
| Velocidad | Velocidad de ataque | 0,8 | +0,080% | +0,066% | +0,020% | ×1,073 | ×1,400 | ×1,667 | ×1,8 |
| Velocidad | Velocidad de movimiento | 0,5 | +0,050% | +0,041% | +0,013% | ×1,045 | ×1,250 | ×1,417 | ×1,5 |
| Energía | Regeneración de energía | 1,0 | +0,100% | +0,083% | +0,025% | ×1,091 | ×1,500 | ×1,833 | ×2,0 |

El «punto N» es lo que añade ese punto concreto, en puntos porcentuales sobre el valor base.

Efectos que no son multiplicadores:

| Estadística | Fórmula | Con 0 | Con 100 | Con 1.000 | Con 5.000 | Tope |
|---|---|---|---|---|---|---|
| Energía: energía máxima | `100 + 300·E/(E + 1.000)` | 100 | 127,3 | 250 | 350 | 400 |
| Velocidad: WalkSpeed | `16 × Mult` | 16,00 | 16,73 | 20,00 | 22,67 | 24 |
| Defensa | Ver sección 7 | — | — | — | — | — |

Vida base por nivel (para que la Vitalidad tenga algo que multiplicar):

- **F11:** `VidaBase(L) = 500 × 1,65^((L − 1)/100)`. Crece al mismo ritmo que la potencia de zona de B1 (×1,65 cada 100 niveles).
- Valores: nivel 1 → 500; 100 → 821; 300 → 2.235; 500 → 6.084; 800 → 27.332; 1.000 → 74.411.
- La Etapa 4 debe confirmarla contra el daño de los enemigos.

### 6.1 Revisión: ¿escalan poco Fuerza, Velocidad y Dominio con raíz cuadrada?

Comparación con una raíz cuadrada calibrada para dar lo mismo con 1.000 puntos (`1 + 0,04743·√S`):

| Puntos | Raíz: total | Raíz: lo que añade ese punto | Saturación: total | Saturación: lo que añade ese punto |
|---|---|---|---|---|
| 1 | ×1,047 | +4,743% | ×1,003 | +0,300% |
| 100 | ×1,474 | +0,238% | ×1,273 | +0,248% |
| 1.000 | ×2,500 | +0,075% | ×2,500 | +0,075% |
| 5.000 | ×4,354 | +0,034% | ×3,500 | +0,008% |

- **Sí, la raíz cuadrada es un problema, pero no por escalar poco en total.** El problema es el reparto: el primer punto vale 63 veces más que el punto 1.000. Lo óptimo sería poner unos pocos puntos en todo, y todas las builds se parecerían.
- Con la curva de saturación el primer punto vale solo 4 veces más que el punto 1.000. Especializarse sigue compensando.
- La raíz cuadrada además no tiene techo (×4,35 con 5.000 y sigue subiendo); la saturación se detiene en ×4.
- **Fuerza y Dominio:** con `M = 3` llegan a ×2,5 con 1.000 puntos. Suficiente para que la build se note sin superar el peso de la zona (×1,65 por zona).
- **Velocidad:** se queda deliberadamente por debajo (×1,4 de ataque) porque también da movimiento, que en PvP y en la huida de las Zonas Fracturadas vale mucho. El movimiento tiene tope de WalkSpeed 24 para no romper la detección de trampas.

### 6.2 Revisión: ¿escala demasiado la Vitalidad?

| Vitalidad | Lineal de referencia (`1 + 0,01·V`) | Saturación |
|---|---|---|
| 100 | ×2,0 | ×1,273 |
| 1.000 | ×11,0 | ×2,500 |
| 5.000 | ×51,0 | ×3,500 |

- **Sí.** Una Vitalidad lineal multiplica la vida por 11 con 1.000 puntos, cuando la Fuerza del rival solo multiplica el daño por 2,5. Los combates PvP se harían interminables.
- Con saturación, Vitalidad y Fuerza usan la misma curva: 1.000 puntos de Fuerza contra 1.000 de Vitalidad dejan el tiempo de combate igual que sin puntos.

---

## 7. Defensa en PvE y PvP

### F12 — Reducción de daño por Defensa

- **Expresión:** `Reducción = mín(D / (D + K), Tope)` y `DañoRecibido = Daño × (1 − Reducción)`
- **Variables:** `D` = Defensa total; `K` y `Tope` dependen del modo.
- **Valores configurables:** PvE `K = 1.500`, `Tope = 75%`. PvP y Zonas Fracturadas `K = 4.500`, `Tope = 50%` (corregido en la Etapa 7; antes 3.000 y 60%).
- **Unidad:** porcentaje de daño evitado.
- **Ejemplo:** Defensa 1.000 en PvE → `1.000/2.500 = 40%`.
- **Límites:** el tope se alcanza con Defensa 4.500 en ambos modos. Siempre se recibe al menos el 25% del daño en PvE y el 50% en PvP.
- **Posibles problemas:** el daño verdadero o la penetración de defensa, si se añaden en la Etapa 4, deben restarse de `D` antes de la fórmula, no de la reducción.

| Defensa | PvE: reducción | PvE: daño recibido | PvE: vida efectiva | PvP: reducción | PvP: daño recibido | PvP: vida efectiva |
|---|---|---|---|---|---|---|
| 10 | 0,66% | 99,34% | ×1,01 | 0,22% | 99,78% | ×1,00 |
| 100 | 6,25% | 93,75% | ×1,07 | 2,17% | 97,83% | ×1,02 |
| 500 | 25,00% | 75,00% | ×1,33 | 10,00% | 90,00% | ×1,11 |
| 1.000 | 40,00% | 60,00% | ×1,67 | 18,18% | 81,82% | ×1,22 |
| 2.500 | 62,50% | 37,50% | ×2,67 | 35,71% | 64,29% | ×1,56 |
| 5.000 | 75,00% | 25,00% | ×4,00 | 50,00% | 50,00% | ×2,00 |

**Nunca hay inmunidad:** aunque la Defensa fuese infinita, la reducción se queda en el tope. Cada punto de Defensa añade la misma vida efectiva (1/K), así que no hay un punto a partir del cual la Defensa se dispare.

---

## 8. Energía

### 8.1 Capacidad y regeneración

| Concepto | Fórmula o valor | Con Energía 0 | Con 1.000 | Con 5.000 |
|---|---|---|---|---|
| Energía máxima | `100 + 300·E/(E + 1.000)` | 100 | 250 | 350 |
| Regeneración en combate | `8/s × (1 + E/(E + 1.000))` | 8,0/s | 12,0/s | 14,7/s |
| Regeneración fuera de combate | `20/s × (1 + E/(E + 1.000))` | 20,0/s | 30,0/s | 36,7/s |
| Recarga completa fuera de combate | — | 5,0 s | 8,3 s | 9,5 s |

- «En combate» = menos de 5 s desde el último golpe dado o recibido.
- **Pausa de regeneración:** tras gastar energía, no se regenera durante 1,5 s.

### 8.2 Consumos

| Acción | Coste | Enfriamiento | Notas |
|---|---|---|---|
| Esquiva | 20 | 1,2 s | Su enfriamiento es menor que la pausa: encadenarlas no deja regenerar |
| Bloqueo sostenido | 8 por segundo | — | No se regenera mientras se bloquea |
| Golpe bloqueado | 10 por golpe | — | Con energía 0 se rompe la guardia (Ruptura, Etapa 4) |
| Dash | 20 | 2,5 s | |
| Doble salto | 0 | 1 por salto | Sin coste: es movimiento básico |
| Parpadeo | 30 | 8 s | |
| Habilidad Z | 15 | 4 s | Valores de referencia; la Etapa 4 fija los de cada Núcleo |
| Habilidad X | 25 | 8 s | |
| Habilidad C | 35 | 14 s | |
| Habilidad V | 50 | 30 s | |

### 8.3 Simulación: 120 s de combate usando todo en cuanto se puede

| Qué se usa | Energía | Usos conseguidos | Usos posibles por enfriamiento | Porcentaje | Se vacía a los |
|---|---|---|---|---|---|
| Solo Dash | 0 | 33 | 49 | 67,3% | 15,5 s |
| Solo Dash | 1.000 | 44 | 49 | 89,8% | 68,2 s |
| Solo Dash | 5.000 | 47 | 49 | 95,9% | No en 120 s |
| Habilidades Z, X, C, V | 0 | 34 | 61 | 55,7% | Primera ráfaga |
| Habilidades Z, X, C, V | 1.000 | 46 | 61 | 75,4% | 30,0 s |
| Habilidades Z, X, C, V | 5.000 | 54 | 61 | 88,5% | 72,5 s |
| Todo a la vez | 0 | 35 | 126 | 27,8% | Primera ráfaga |
| Todo a la vez | 1.000 | 48 | 126 | 38,1% | 8,1 s |
| Todo a la vez | 5.000 | 55 | 126 | 43,7% | 15,5 s |

- Usarlo todo pide 22,79 de energía por segundo; la regeneración máxima posible es 16/s. Nadie puede usarlo todo siempre.
- La estadística Energía sube el uso de habilidades de 55,7% a 75,4% con 1.000 puntos: tiene valor real para una build ofensiva.

### 8.4 Límites contra la energía infinita

1. **Pausa de 1,5 s** tras cada gasto. Entre dos Dash seguidos solo se regenera 1 s: 8,0 con Energía 0, 12,0 con 1.000 y 14,7 con 5.000, siempre menos que los 20 que cuesta. Encadenar Dash siempre acaba vaciando la barra.
2. **Topes de la estadística:** energía máxima 400 y regeneración ×2.
3. **Reducción de costes:** el equipo y las pasivas pueden abaratar las acciones un 30% como máximo en total.
4. **Los enfriamientos no dependen de la energía:** tener energía de sobra no permite usar antes una habilidad.
5. **Bloqueo:** con 8/s y sin regenerar, aguanta 12,5 s (Energía 0), 31,2 s (1.000) o 43,8 s (5.000) sin recibir golpes; cada golpe bloqueado lo acorta.
6. **Consumibles de energía:** un uso cada 30 s en PvP y Zonas Fracturadas.

---

## 9. Problemas de balance detectados y alternativas

### 9.1 Comprobación con builds (nivel 1.000, 3.000 puntos, sin equipo)

> Cálculo original de la Etapa 2, con las reglas PvP de entonces (`K = 3.000`, tope 60%, Vitalidad sin reducir). Se conserva porque explica el problema P1. Los valores vigentes en PvP están en B7, sección 5 (P3).

| Build | DPS | Vida efectiva PvE | Vida efectiva PvP | Minería | Suerte |
|---|---|---|---|---|---|
| Cristal (Fuerza, Velocidad, Energía) | ×3,50 | ×1,00 | ×1,00 | ×1,00 | ×1,00 |
| Tanque (Vitalidad, Defensa, Fuerza) | ×2,50 | ×4,17 | ×3,33 | ×1,00 | ×1,00 |
| Muro (Vitalidad, Defensa, Energía) | ×1,00 | ×4,17 | ×3,33 | ×1,00 | ×1,00 |
| Minero (Minería, Suerte, Vitalidad) | ×1,00 | ×2,50 | ×2,50 | ×2,50 | ×2,50 |
| Equilibrada (375 en cada una) | ×2,21 | ×2,27 | ×2,05 | ×1,82 | ×1,82 |

### P1 — El Tanque con Fuerza domina el duelo PvP

- **Problema:** en un duelo, el Tanque mata al Cristal en 0,40 unidades de tiempo y el Cristal al Tanque en 0,95. El Tanque gana con una ventaja de 2,38 veces. Fuerza + Vitalidad + Defensa sería la única build viable en PvP.
- **Alternativa con números:** que la Vitalidad cuente la mitad en PvP y Zonas Fracturadas (`M = 1,5`).

| Regla | Vida efectiva PvP del Tanque | Cristal mata en | Tanque mata en | Ventaja del Tanque |
|---|---|---|---|---|
| Actual (`M = 3`) | ×3,33 | 0,95 | 0,40 | 2,38 veces |
| Vitalidad PvP con `M = 1,5` | ×2,33 | 0,67 | 0,40 | 1,67 veces |

- **Decisión final (Etapa 7):** `M = 1,0` en PvP, junto con Defensa `K = 4.500` y tope 50%; la ventaja del Tanque queda en 1,33 veces (B7, sección 3). La tabla de arriba es el cálculo original.
- **Recomendación original:** adoptar `M = 1,5` en PvP. La ventaja restante la compensa el Cristal con un 35% más de usos de habilidad (75,4% frente a 55,7%) y más movimiento. La Etapa 4 lo cierra con las habilidades reales y la Etapa 7 lo simula.

### P2 — La mitad final de la curva de XP es lenta

- **Problema:** 341 de las 460 horas están entre el nivel 500 y el 1.000.
- **Alternativa:** XP por acción `25 + 3,75·L + 0,002·L²` → 344,6 horas en total (sección 3.2). Recomendada.

### P3 — La fórmula original es demasiado lenta por encima de 1.000

- **Problema:** 1.349 horas de 1.000 a 2.000.
- **Alternativa:** cola lineal (F8) → 934 horas y ritmo estable. Recomendada.

### P4 — El minero es débil en combate

- **Problema:** la build Minero tiene DPS ×1,00. En una Zona Fracturada pierde contra cualquier build de combate.
- **Por qué se acepta:** es el riesgo que define a las Zonas Fracturadas, y solo arriesga la carga. Sus defensas son la huida (Velocidad), las mascotas en postura Proteger (Etapa 5) y la protección de novato (Etapa 3).
- **A vigilar:** la Etapa 6 debe comprobar que el minero sigue ganando lo suficiente contando muertes.

### P5 — La Suerte se nota poco al principio (heredado de B1)

- **Estado:** con 3 puntos por nivel, un jugador que la priorice tiene Suerte 300 a nivel 100 (`F = 1,69`). Es suficiente; se mantiene `K = 1.000` y B1 no cambia.

### P6 — La build Equilibrada no destaca en nada

- **Dato:** ×2,21 de DPS y ×2,05–2,27 de vida efectiva, más ×1,82 en Minería y Suerte.
- **Valoración:** es correcta para un jugador que alterna minería y combate. No necesita cambios.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| 240 acciones por hora y XP por acción | Etapas 3 y 4; después, telemetría de XP por hora real por tramo de nivel |
| `M = 3`, `K = 1.000` | Etapa 7: builds extremas de Fuerza, Minería, Suerte, Defensa y Dominio |
| Topes de Defensa (75% y 60%) | Etapa 4: tiempo para morir contra jefes y en duelos |
| Vida base por nivel | Etapa 4: golpes que aguanta un jugador contra enemigos de su zona |
| Energía (costes, pausa, regeneración) | Prueba de juego: que un combate de 60 s no deje al jugador sin opciones más de 5 s seguidos |
| Coste del reinicio | Fijado en la Etapa 6 en 1,5 horas de ingreso |
