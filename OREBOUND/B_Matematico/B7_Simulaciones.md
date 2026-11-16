# OREBOUND — B7: Simulaciones y cierre del Documento B

Etapa 7, rehecha con el GDD · 2026-11-16 · Script: `calculos/b7_simulaciones.py` (genera este documento a partir de los resultados de B2 a B6).

> **Fuentes.** Esta versión simula el diseño rehecho con el GDD de combate, minería PvPvE y
> mascotas. No se dispone de la sección 23 del prompt maestro: los perfiles de los jugadores A
> a G son propuestos; solo sus niveles vienen del prompt de trabajo. Todo es **[PROVISIONAL]**
> salvo las decisiones fijas.
>
> **Orden de ejecución.** `b1` a `b7` en orden: cada script deja sus resultados en
> `calculos/_bN.json` y el siguiente los lee. Así ningún número se copia a mano.

---

## 1. Jugadores A a G

| Jugador | Zona | Perfil |
|---|---|---|
| A · nivel 1 · recién llegado | 1 | Arma y pico Comunes sin mejoras; 1 cría |
| B · nivel 50 · equilibrado | 1 | Equipo Raro con la mitad de los bonos; 2 crías de nivel 10 |
| C · nivel 100 · recién llegado a la zona 2 | 2 | Equipo Raro de zona 1; 3 crías de nivel 15 |
| D · nivel 300 · minero | 4 | 50% Minería, 25% Suerte, 25% Vitalidad; pico Épico con la mitad de los bonos; 2 mascotas de Minería |
| E · nivel 500 · combatiente | 6 | 40% Fuerza; arma Épica con la mitad de los bonos; 3 mascotas desatadas |
| F · nivel 800 · híbrido de grieta | 9 | Fuerza, Vitalidad, Minería y Velocidad; equipo Legendario con la mitad de los bonos |
| G · nivel 1.000 · final de juego | 10 | Fuerza, Vitalidad y Dominio a 1.000; arma Ultra rara al máximo; mascotas al máximo (incluido el Guiverno de Cuarzo) |

### 1.1 Tiempos de combate y de extracción en su zona

| Jugador | Enemigo Común (s) | Élite (s) | Guardián (s) | Jefe en solitario (min) | Depósito Común (s) | Depósito Raro (s) | Depósito Legendario (s) |
|---|---|---|---|---|---|---|---|
| A | 5,9 | 23,5 | 88,3 | 7,4 | 5,7 | 13,3 | 33,3 |
| B | 5,9 | 23,7 | 88,7 | 7,4 | 3,7 | 7,3 | 18,3 |
| C | 11,9 | 47,6 | 178,6 | 14,9 | 7,3 | 15,6 | 38,5 |
| D | 8,2 | 32,8 | 123,0 | 10,2 | 2,5 | 3,3 | 8,3 |
| E | 2,6 | 10,4 | 39,1 | 3,3 | No puede | No puede | No puede |
| F | 2,1 | 8,4 | 31,4 | 2,6 | 2,4 | 3,2 | 8,0 |
| G | 0,8 | 3,3 | 12,3 | 1,0 | No puede | No puede | No puede |

- **A** derrota a un enemigo en 5,9 s gracias a la vida de tutorial a la mitad.
- **C** acaba de llegar a la zona 2 con equipo de la zona 1: 11,9 s por enemigo y 14,9 minutos el jefe. Con crecimiento ×2,00 por zona, el equipo atrasado se nota más que antes: es la señal de que toca renovarlo.
- **E** y **G** no tienen puntos en Minería y no pueden picar en su zona.
- **G** derrota al jefe de la zona 10 en solitario en 1,0 minutos. El jefe sigue limitado a 3 botines diarios.

### 1.2 Economía y progreso

| Jugador | Monedas/hora combatiendo | Monedas/hora minando | Combate / minería | Horas para el arma siguiente | Horas para el pico siguiente | Minutos para subir de nivel |
|---|---|---|---|---|---|---|
| A | 4.813 | 4.541 | 1,06 | 0,8 h (Poco común) | 0,8 h (Poco común) | 1,1 |
| B | 5.180 | 5.832 | 0,89 | 2,6 h (Épico) | 2,6 h (Épico) | 3,1 |
| C | 5.689 | 7.920 | 0,72 | 3,9 h (Épico) | 3,9 h (Épico) | 7,5 |
| D | 32.746 | 62.568 | 0,52 | 2,0 h (Épico) | 3,9 h (Legendario) | 10,0 |
| E | 268.994 | No puede | — | 3,6 h (Legendario) | 1,8 h (Épico) | 13,1 |
| F | 2.361.707 | 1.871.972 | 1,26 | 6,6 h (Mítico) | 6,6 h (Mítico) | 16,7 |
| G | 6.232.465 | No puede | — | 10,1 h (Ultra raro) | 10,1 h (Ultra raro) | 14,7 |

- «Horas para el siguiente» = horas de juego para pagar la rareza siguiente de su zona, guardando el 80% de lo que gana con su mejor actividad.
- El arma o el pico siguiente cuestan entre 0,8 y 10,1 horas: ningún salto de equipo queda fuera de alcance.
- **Minería frente a combate en los perfiles iniciales:** 0,94 veces (A), 1,13 (B) y 1,39 (C). El caso de C supera 1,3: ver el problema P5.
- Con equipo al día y defensa, el combatiente pasa por delante: F gana 1,26 veces más combatiendo que minando.

### 1.3 Mascotas y minerales raros

| Jugador | DPS de mascotas sin tope | DPS de mascotas contado | Velocidad de extracción añadida | Escudo de mascota | Tiempo parado | Rareza máxima que pica | Depósitos Legendario o superior | Legendario+ por hora |
|---|---|---|---|---|---|---|---|---|
| A | 0,4% | 0,4% | 5,0% | No | 10,2% | Mítico | 2,50% | 5,5 |
| B | 2,9% | 2,9% | 5,0% | No | 3,0% | Mítico | 2,59% | 7,2 |
| C | 4,3% | 4,3% | 5,0% | No | 11,6% | Legendario | 2,68% | 4,3 |
| D | 1,1% | 1,1% | 13,0% | No | 4,1% | Mítico | 3,37% | 11,5 |
| E | 8,9% | 8,9% | 0,0% | Sí | 0,0% | Ninguna | 2,50% | 0,0 |
| F | 9,5% | 9,5% | 15,2% | Sí | 0,0% | Ultra raro | 2,50% | 8,7 |
| G | 64,7% | 40,0% | 0,0% | Sí | 0,0% | Ninguna | 2,50% | 0,0 |

- **Tope de mascotas:** G alcanza el 40% (sin tope harían el 65%). Nadie lo supera.
- El tiempo parado recuperando vida no pasa del 11,6% y es 0% desde el nivel 500.
- D, el minero con un 25% de sus puntos en Suerte, ve un 3,37% de depósitos Legendario o superior (base 2,50%) y pica 11,5 por hora.

---

## 2. Builds extremas

### 2.1 Todo en una estadística

Nivel 1.000, equipo Legendario al máximo y las mismas tres mascotas. «Todo en X» = 1.000 puntos en X y 285 en cada una de las otras siete.

| Build (nivel 1.000, equipo Legendario al máximo) | DPS (× equilibrada) | Vida efectiva PvE (× base) | Vida efectiva PvP (× base) | Monedas/h combate | × equilibrada | Monedas/h minería | × equilibrada | Mejor estilo × equilibrada | Legendario+ en depósitos | DPS de mascotas contado |
|---|---|---|---|---|---|---|---|---|---|---|
| Equilibrada (375 en todo) | 1,00 | 2,27 | 1,38 | 4.895.283 | 1,00 | 3.980.517 | 1,00 | 1,00 | 3,75% | 24,3% |
| Todo en Fuerza | 1,26 | 1,98 | 1,30 | 5.303.991 | 1,08 | 3.400.843 | 0,85 | 1,08 | 3,53% | 16,2% |
| Todo en Minería | 0,89 | 1,98 | 1,30 | 4.673.258 | 0,95 | 4.365.155 | 1,10 | 0,95 | 3,53% | 24,3% |
| Todo en Suerte | 0,89 | 1,98 | 1,30 | 4.673.258 | 0,95 | 3.576.008 | 0,90 | 0,95 | 4,62% | 24,3% |
| Todo en Defensa | 0,89 | 2,78 | 1,49 | 4.673.258 | 0,95 | 3.400.843 | 0,85 | 0,95 | 3,53% | 24,3% |
| Todo en Dominio | 0,96 | 1,98 | 1,30 | 4.825.150 | 0,99 | 3.422.490 | 0,86 | 0,99 | 3,53% | 36,5% |
| Minería + Suerte + Vitalidad | 0,46 | 2,50 | 1,50 | 3.394.309 | 0,69 | 4.801.570 | 1,21 | 0,98 | 4,62% | 24,3% |
| Fuerza + Velocidad + Energía | 1,43 | 1,00 | 1,00 | 5.517.837 | 1,13 | 0 | — | 1,13 | 2,50% | 9,7% |

- **Ninguna build rinde más de 1,13 veces la equilibrada** en su mejor actividad (Fuerza + Velocidad + Energía). El límite de 1,3 se cumple.
- Todo en Fuerza: 1,08. Todo en Minería: 0,95. Todo en Suerte: 0,95. Todo en Defensa: 0,95. Todo en Dominio: 0,99.
- Con los picos del GDD, casi todos los depósitos se pican en el mínimo de 3 golpes con equipo Legendario: la Minería extra apenas acelera, y por eso «todo en Minería» no destaca. Su valor está en acceder a las rarezas altas.
- El Dominio sube el daño de mascotas contado, pero no convierte la build en la mejor: su valor está en la utilidad (B5).

### 2.2 Solo equipo Común, Ultra raro y Celestial

Build equilibrada de nivel 1.000 en la zona 10.

| Equipo (build equilibrada, nivel 1.000) | Potencia | DPS (× Común) | Enemigo Común (s) | Jefe (min) | Depósito Común (s) | Monedas/h combate | × Común | Monedas/h minería | × Común |
|---|---|---|---|---|---|---|---|---|---|
| Solo Común sin mejoras | 51.200 | 1,00 | 7,1 | 8,9 | 5,6 | 2.406.816 | 1,00 | 2.500.254 | 1,00 |
| Raro con la mitad de los bonos | 96.000 | 1,88 | 3,8 | 4,8 | 3,1 | 3.557.689 | 1,48 | 3.309.449 | 1,32 |
| Legendario al máximo | 192.000 | 3,75 | 1,9 | 2,4 | 2,2 | 4.895.283 | 2,03 | 3.980.517 | 1,59 |
| Ultra raro al máximo | 345.600 | 6,75 | 1,1 | 1,3 | 2,1 | 5.877.388 | 2,44 | 4.157.135 | 1,66 |
| Celestial al máximo | 399.360 | 7,80 | 0,9 | 1,1 | 2,1 | 6.082.732 | 2,53 | 4.212.899 | 1,68 |

- El equipo Ultra raro al máximo da 2,44 veces las monedas del Común en combate; el Celestial, 2,53.
- **Celestial frente a Ultra raro: +3,5% de monedas.** Es mejor, pero no obligatorio.
- En minería la diferencia se aplana (1,66 frente a 1,68) por el mínimo de 3 golpes por depósito.
- Bajar a la zona 9 con equipo Ultra raro rinde 0,51 veces lo que la zona 10: no compensa farmear zonas inferiores.
- El daño real máximo simulado (G) es 8,7 veces el de un jugador equilibrado con equipo Común, lejos del máximo teórico de B4.

---

## 3. Escenarios de Zona Fracturada

Nivel 1.000 en la Zona Fracturada de la zona 10, arma Legendaria al máximo, mascotas al tope del 25%.

### 3.1 Minero solo contra 2 saqueadores

Saqueadores: un Cristal (WalkSpeed 20) y un Tanque (WalkSpeed 16). El minero huye; la distancia de escape cuenta sus dos cargas de dash (24 studs, que la carga no ralentiza) y los 3 s de canalización de la salida.

| Situación | Carga | Ralentización | Velocidad del minero | WalkSpeed | Tiempo hasta el primer golpe | Distancia máxima a una salida para escapar (studs) | Tiempo hasta caer si no escapa | Con Escudo Facetado |
|---|---|---|---|---|---|---|---|---|
| Los ve a 60 studs | 1 | 8% | 0 | 14,7 | 9,8 s | 123 | 19,7 s | 21,7 s |
| Los ve a 60 studs | 1 | 8% | 1.000 | 18,3 | 31,3 s | 542 | 41,2 s | 43,1 s |
| Los ve a 60 studs | 5 | 22% | 0 | 12,6 | 6,9 s | 74 | 16,2 s | 17,4 s |
| Los ve a 60 studs | 5 | 22% | 1.000 | 15,7 | 12,1 s | 166 | 22,0 s | 24,0 s |
| Los ve a 60 studs | 12 | 31% | 0 | 11,1 | 5,8 s | 55 | 13,6 s | 14,8 s |
| Los ve a 60 studs | 12 | 31% | 1.000 | 13,8 | 8,4 s | 99 | 18,4 s | 20,3 s |
| Los ve a 60 studs | 30 | 40% | 0 | 9,6 | 4,9 s | 43 | 12,1 s | 13,3 s |
| Los ve a 60 studs | 30 | 40% | 1.000 | 12,0 | 6,4 s | 65 | 15,0 s | 16,2 s |
| Emboscada a 20 studs | 1 | 8% | 0 | 14,7 | 2,2 s | 24 | 10,9 s | 12,1 s |
| Emboscada a 20 studs | 1 | 8% | 1.000 | 18,3 | 7,2 s | 101 | 17,2 s | 19,1 s |
| Emboscada a 20 studs | 5 | 22% | 0 | 12,6 | 1,6 s | 24 | 8,2 s | 9,4 s |
| Emboscada a 20 studs | 5 | 22% | 1.000 | 15,7 | 2,7 s | 24 | 12,7 s | 14,7 s |
| Emboscada a 20 studs | 12 | 31% | 0 | 11,1 | 1,3 s | 24 | 7,6 s | 8,8 s |
| Emboscada a 20 studs | 12 | 31% | 1.000 | 13,8 | 1,9 s | 24 | 9,2 s | 10,5 s |
| Emboscada a 20 studs | 30 | 40% | 0 | 9,6 | 1,2 s | 24 | 7,3 s | 8,5 s |
| Emboscada a 20 studs | 30 | 40% | 1.000 | 12,0 | 1,5 s | 24 | 7,9 s | 9,1 s |

- **Si planta cara, cae en 5,9 s.** Pelear solo contra dos no es opción.
- La Carga 12 del ejemplo del GDD da un 31% de ralentización, y la Carga 16, un 34%: coinciden con el GDD (31% y 34%).
- **Visto de lejos y con poca carga, escapa.** Con Carga 30 necesita una salida muy cerca.
- **En una emboscada a 20 studs** solo le quedan los dos dash, el parpadeo y la Ruptura: es el caso que el GDD resuelve con decisiones (cambiar a Proteger, guardar la Ruptura) y no con velocidad.
- El Escudo Facetado del Guiverno de Cuarzo alarga la vida entre 1 y 2 s.
- **Consecuencia de diseño:** una salida o un Punto de Extracción a menos de 150 studs de cualquier depósito, y la decisión real es cuánto valor acumular antes de extraer.

### 3.2 Escuadrón de 3 contra 3

Cada escuadrón concentra el daño en el rival con menos vida.

| Escuadrón A | Escuadrón B | Gana | Duración | Supervivientes | Vida restante del ganador |
|---|---|---|---|---|---|
| Cristal + Cristal + Cristal | Tanque + Tanque + Tanque | Escuadrón B | 12,2 s | 2 | 37% |
| Equilibrada + Equilibrada + Equilibrada | Tanque + Tanque + Tanque | Escuadrón B | 16,1 s | 2 | 48% |
| Cristal + Cristal + Tanque | Tanque + Tanque + Cristal | Escuadrón B | 21,5 s | 1 | 17% |
| Cristal + Tanque + Equilibrada | Equilibrada + Equilibrada + Equilibrada | Escuadrón A | 24,8 s | 1 | 9% |
| Minero + Minero + Minero | Cristal + Cristal + Cristal | Escuadrón B | 10,2 s | 3 | 72% |
| Minero + Minero + Tanque | Cristal + Cristal + Tanque | Escuadrón B | 17,3 s | 1 | 40% |

- Los combates duran entre 10 y 25 s.
- **Los escuadrones de Tanques ganan a los de Cristales y a los de Equilibradas.** Con fuego concentrado, la vida vale más que el daño. En duelo la ventaja del Tanque es de 1,27 veces.
- Tres mineros pierden contra tres Cristales; un Tanque de escolta deja a los saqueadores con un solo superviviente.

### 3.3 Saqueador profesional frente a minero PvE

Simulación de 4.000 horas. El saqueador busca objetivo, pelea 20 s y extrae al llegar al 50% de carga. Objetivos: 70% mineros solos, 20% mineros con escuadrón y 10% otros saqueadores.

| Escenario | Derrotas causadas por hora | Derrotas propias por hora | Extracciones por hora | Ingresos (× minero PvE) | Con contratos (× minero PvE) |
|---|---|---|---|---|---|
| Servidor con pocos mineros (búsqueda de 5 min) | 6,2 | 1,76 | 1,57 | 0,24 | 0,34 |
| Servidor normal (3 min) | 9,4 | 2,64 | 2,37 | 0,37 | 0,47 |
| Servidor lleno de mineros (1,5 min) | 15,3 | 4,33 | 3,84 | 0,60 | 0,70 |
| Servidor normal con todo recogible (recompensa por cabeza) | 9,3 | 2,63 | 2,84 | 0,47 | 0,57 |

- **El saqueador profesional gana entre 0,34 y 0,70 veces lo que un minero PvE**; en un servidor normal, 0,47.
- El GDD advierte de que «cazar portadores puede rendir más que minar». Con el 50% soltado, el 80% recogible y el multiplicador base ×1,5, no ocurre.
- Cazando solo jugadores con recompensa por cabeza (todo recogible) llegaría a 0,57.

Efecto sobre los mineros según cuántos saqueadores haya:

| Saqueadores por mineros | Prob. de caer por viaje | Minero de grieta (× PvE) | Con contratos |
|---|---|---|---|
| 1 por cada 10 | 8,2% | 2,11 | 2,21 |
| 2 por cada 10 | 15,7% | 1,90 | 2,00 |
| 3 por cada 10 | 22,6% | 1,73 | 1,83 |
| 5 por cada 10 | 34,8% | 1,49 | 1,59 |
| 10 por cada 10 | 57,5% | 1,12 | 1,22 |

- Incluso con un saqueador por cada minero, el minero de grieta gana 1,22 veces el PvE.
- Con 2–3 saqueadores por cada 10 mineros, la probabilidad de caer por viaje es del 16–23%.
- **Traspaso entre cuentas:** dejarse derrotar por un cómplice entrega 1,10 veces el valor base, frente a 1,50 extrayendo sin racha. No hay incentivo.

### 3.4 Simulación pedida por el GDD: zonas 2, 5 y 8

| Zona | Minero PvE (monedas/hora) | Minero de grieta con 3 saqueadores por cada 10 mineros | × PvE | Saqueador profesional | × PvE |
|---|---|---|---|---|---|
| 2 | 10.349 | 18.986 | 1,83 | 4.830 | 0,47 |
| 5 | 78.013 | 143.117 | 1,83 | 36.409 | 0,47 |
| 8 | 589.714 | 1.081.850 | 1,83 | 275.225 | 0,47 |

La relación es la misma en las tres zonas porque valores, precios y vida escalan juntos.

---

## 4. Escalado más allá del nivel 1.000

Las fórmulas no cambian. Solo se añaden tres topes de parámetro: requisito de Minería y dureza congelados a partir de la zona 10, y 1 punto de estadística por nivel desde el 1.001.

Regla de zonas: la zona `z` se abre en el nivel `100 × (z − 1)`. Los niveles 1.100, 1.200, 1.500 y 2.000 corresponden a las zonas 12, 13, 16 y 21.

| Nivel | Zona | Potencia de zona | Vida del jefe | XP para el siguiente nivel | Minutos por nivel | Monedas/hora | Depósito Común sin tope de dureza (s) | Con tope (s) | Enemigo Común sin tope (s) | Con tope (s) |
|---|---|---|---|---|---|---|---|---|---|---|
| 1.000 | 10 | 5,12 × 10^4 | 1,17 × 10^8 | 820.100 | 27,3 | 3.354.031 | 3,1 | 3,1 | 4,2 | 4,2 |
| 1.100 | 12 | 2,05 × 10^5 | 4,92 × 10^8 | 910.100 | 27,2 | 13.131.409 | 3,8 | 3,1 | 4,6 | 4,4 |
| 1.200 | 13 | 4,10 × 10^5 | 9,83 × 10^8 | 1.000.100 | 26,3 | 26.490.468 | 3,8 | 3,1 | 4,8 | 4,3 |
| 1.500 | 16 | 3,28 × 10^6 | 7,86 × 10^9 | 1.270.100 | 23,8 | 216.864.647 | 3,8 | 3,1 | 5,2 | 4,2 |
| 2.000 | 21 | 1,05 × 10^8 | 2,52 × 10^11 | 1.720.100 | 20,3 | 7.184.973.906 | 4,6 | 3,0 | 5,9 | 3,9 |

| Nivel | Zona | Puntos (1 por nivel desde 1.001) | Estadísticas al máximo | Puntos si siguieran a 3 por nivel | Estadísticas al máximo | Minería para Ultra raro sin tope | Con tope | Rareza máxima (equilibrada) sin tope | Con tope |
|---|---|---|---|---|---|---|---|---|---|
| 1.000 | 10 | 3.000 | 3 | 3.000 | 3 | 630 | 630 | Legendario | Legendario |
| 1.100 | 12 | 3.100 | 3 | 3.300 | 3 | 770 | 630 | Legendario | Legendario |
| 1.200 | 13 | 3.200 | 3 | 3.600 | 3 | 840 | 630 | Épico | Legendario |
| 1.500 | 16 | 3.500 | 3 | 4.500 | 4 | 1.050 | 630 | Épico | Legendario |
| 2.000 | 21 | 4.000 | 4 | 6.000 | 6 | 1.400 | 630 | Épico | Mítico |

- **Sin los topes, el juego se rompe:** el Ultra raro de la zona 21 pediría Minería 1.400 (el máximo es 1.000).
- **Con los topes**, los tiempos se mantienen estables.
- **Con 3 puntos por nivel**, a nivel 2.000 se podrían llevar al máximo 6 de las 8 estadísticas; con 1 punto por nivel son 4.
- **¿Caben los números con crecimiento ×2,00? Sí.** La vida del jefe de la zona 21 con 8 jugadores es 1,3 × 10^12 y las monedas ganadas en total hasta el nivel 2.000 son 2,5 × 10^11; el límite exacto de Roblox es 9,0 × 10^15, 6.883 veces mayor.
- **Aviso:** con ×2,00 por zona el margen se agota hacia la zona 34 (nivel 3.300). Antes de llegar ahí habrá que mostrar las cifras abreviadas y, si se sigue ampliando, reducir el crecimiento de las zonas nuevas.

---

## 5. Builds y combinaciones que rompen el juego

| # | Combinación | Qué rompe | Corrección | Estado |
|---|---|---|---|---|
| P1 | Hacha o Lanza contra grupos | Golpear a 5 objetivos al 100% daba 3,7 veces los enemigos por hora | Máximo 3 objetivos; los secundarios reciben el 25%; grupos de hasta 3 | En B4; queda en 1,24 |
| P2 | Núcleo Umbrío: Manto + Tajo + Eclipse + Paso | 73% de la vida de un Cristal en un combo | Tope de ráfaga del 60% de la vida en 2 s en PvP | En B4 |
| P3 | Tanque (Fuerza + Vitalidad + Defensa) en PvP | Domina duelos y escuadrones | Vitalidad `M = 1,0` y Defensa `K = 4.500` con tope 50% en PvP | En B2 y B4; ventaja 1,27 en duelo |
| P4 | Subir por encima del nivel 1.000 | Requisitos imposibles y 6 estadísticas al máximo | Topes de requisito y dureza; 1 punto por nivel | En B2 y B3 |
| P5 | Llegar a una zona con el arma anterior | Minar rinde 1,39 veces lo que combatir | Regeneración del 0,5% de vida por segundo en combate; el resto es transitorio | En B4; queda abierto |
| P6 | Racha de ×1,5 con mineral al doble (GDD) | 3,17 veces el PvE | Multiplicador base ×1,5 | En B3 y B6 |
| P7 | Multiplicadores de rareza del GDD con crecimiento 1,65 | Un Celestial de zona 6 superaba a un Común de zona 10 | Crecimiento ×2,00 y bonos hasta +50% | En B1 |
| P8 | Tenacidad de 2 s (GDD) | 53% del tiempo bajo control | Tenacidad de 5 s | En B4 |
| P9 | Fragmentos Celestiales al 0,02% (GDD) | 960 horas de grieta por objeto | 0,25% por depósito | En B1 y B3 |
| P10 | Farmear zonas bajas con equipo alto | Vaciar zonas de un golpe | Mínimo de 3 golpes por depósito; rinde 0,51 | En B3; comprobado |
| P11 | Traspasar mineral a una segunda cuenta | Duplicar el bono de grieta | Lo saqueado vale 1,10; misma víctima sin botín 10 minutos | En B3; comprobado |
| P12 | Mascotas con Dominio alto | Hasta el 65% del DPS del jugador | Tope del 40% y 25% aplicado por el servidor | En B5; comprobado |
| P13 | Saqueadores profesionales (riesgo señalado por el GDD) | Que cazar rinda más que minar | — | No ocurre: 0,47 veces el PvE |

### P1 — Golpes en área

| Caso | Enemigos/hora | × un solo objetivo |
|---|---|---|
| Un objetivo, enemigos sueltos (referencia de B4) | 310 | 1,00 |
| Hacha sin regla: 5 objetivos al 100%, grupos de hasta 5 | 1.142 | 3,68 |
| Hacha con la regla: secundarios al 25%, máx. 3; grupos de hasta 3 | 385 | 1,24 |
| Lanza con la regla | 372 | 1,20 |
| Espada con la regla (2 objetivos) | 372 | 1,20 |
| Daga (un objetivo) | 349 | 1,13 |

### P2 — Ráfaga de un combo

| Defensor | Vida máxima en PvP | Daño del combo Umbrío (Manto + Tajo + Eclipse + Paso) | % de la vida sin tope | Con el tope de ráfaga (en 2 s) |
|---|---|---|---|---|
| Cristal | 508.463 | 369.024 | 73% | 60% |
| Minero | 762.695 | 369.024 | 48% | 48% |
| Equilibrada | 647.135 | 340.638 | 53% | 53% |
| Tanque | 762.695 | 301.929 | 40% | 40% |

### P5 — Minería frente a combate al llegar a una zona

- **Dato:** C mina 1,39 veces lo que gana combatiendo, por encima del límite de 1,3. B, con el equipo de su zona, está en 1,13.
- **Por qué pasa:** con crecimiento ×2,00, un arma de la zona anterior hace la mitad del daño necesario, mientras que los depósitos tienen un mínimo de golpes que amortigua el retraso del pico.
- **Por qué no se corrige con números:** subir las monedas de enemigo rompería el final del juego, donde el combatiente ya gana 1,26 veces más (F). La solución es de diseño: el arma Rara de la zona nueva cuesta 1,2 horas de ingreso, y el tutorial de cada zona debe empujar a fabricarla al llegar.
- **Se mide en la beta:** tiempo que tardan los jugadores en renovar el arma al cambiar de zona.

### Sin corrección en esta etapa

- **Escuadrones de Tanques.** Siguen ganando en 3 contra 3. Hay que medirlo en la beta.
- **Combinar técnicas de arma en las ranuras** puede dar más daño que el Núcleo completo (B4, P3). No se ha simulado en combate real.
- **El tope total de 5.000 por estadística** sigue siendo inalcanzable: solo los picos Épico o superior dan una estadística de combate pequeña. Se mantiene como seguro.

---

## 6. Tabla de cambios

### 6.1 Cambios por adoptar el GDD

| # | Valor | Archivo | Primera versión | Ahora | Por qué |
|---|---|---|---|---|---|
| 1 | Multiplicadores de rareza | B1 | 1,00 a 2,60 | 1,00 / 1,25 / 1,50 / 1,90 / 2,50 / 3,30 / 4,50 / 5,20 | GDD |
| 2 | Crecimiento por zona (potencia, valor y vida base) | B1, B2, B3, B4 | 1,65 | 2,00 | Mantener la regla de la zona con los multiplicadores del GDD |
| 3 | Tope de bonos de objeto | B1, B3, B6 | +100% (50 + 30 + 20) | +50% (25 + 15 + 10) | Igual que el anterior |
| 4 | Potencia de pico requerida por zona | B3 | 0,6 × PotZona | 0,5 × PotZona | Que la cumpla un pico Común de la zona anterior |
| 5 | Colores de Ultra raro y Celestial | B1 | Turquesa; blanco y dorado | Arcoíris; blanco perla con núcleo cian | GDD |
| 6 | Fragmentos por objeto Celestial y fuente | B1, B3 | 60; por extracción | 50; 0,25% por depósito de grieta de zona 6 o más | GDD (el 0,02% del GDD daba 960 horas) |
| 7 | Debuff de carga | B3 | `0,30 × c^1,5` según mochila | `mín(0,40; 0,12 × ln(1 + Carga))` según valor | GDD |
| 8 | Reparto del cofre | B3, B6 | 70% y 30% | 80% y 20% | GDD |
| 9 | Protecciones de grieta | B3 | 5 s; escudo de 120 s en 3 entradas; rotación cada 2 min | 10 s; 5 entradas sin pérdida; cambio cada 10 min | GDD |
| 10 | Picos | B3 | Una habilidad por rareza | Pasivas menor, mayor o única y estadística de combate con tope PvP | GDD |
| 11 | Multiplicador base del mineral fracturado | B3, B6 | ×2,0 | ×1,5 | Para que quepa la racha del GDD bajo 2,5 |
| 12 | Racha de extracción | B3, B6 | +2% hasta +10% | ×1,1 hasta ×1,5 | GDD |
| 13 | Ranuras Z, X, C, V | B4 | Solo habilidades del Núcleo | Mezcla de 4 del Núcleo y 2 técnicas del arma | GDD |
| 14 | Núcleo Prismático | B4 | Conjunto propuesto | Lanza Prismática, Campo de Refracción, Paso de Relámpago y Prisma Total | GDD |
| 15 | Factor de habilidades | B2, B4, B5 | ×1,75 | ×1,39 | Enfriamientos del GDD (6 a 60 s) |
| 16 | Vida de enemigos (Común) | B4 | 20 × PotZona | 16 × PotZona | Mantener 6–7 s por enemigo con el factor nuevo |
| 17 | Despertar y Transformación | B4 | Maestría 75 y 100; barra de Sincronía | Ambos a maestría 100; barra de Resonancia; +25% en PvE y 10% en PvP | GDD |
| 18 | Dash y parpadeo | B2, B4 | 1 dash cada 2,5 s; parpadeo de 16 studs | 2 cargas con 3 s de recarga; 12 studs | GDD |
| 19 | Esquiva | B2, B4 | Acción aparte | Dash justo antes del golpe («esquiva perfecta») | El GDD no le da botón propio |
| 20 | Control repetido | B4 | Ventana de 10 s; inmunidad de 6 s; tope de 2,0 s | Ventana de 6 s; Tenacidad de 5 s; tope de 2,5 s | GDD (Tenacidad ampliada de 2 a 5 s) |
| 21 | Ruptura | B4 | Guardia rota; liberación automática | Liberarse por 50 de energía tras 0,8 s; 15 s | GDD |
| 22 | Controles | B4 | Propuestos | Los del GDD | GDD |
| 23 | Posturas de mascota | B5 | Atacar, Recolectar y Proteger | Recolectar (+50% radio, −50% daño) y Proteger (lo contrario) | GDD |
| 24 | Roles y utilidad de mascota | B5 | Tanque, Atacante, Recolector… con valores propuestos | Defensa, Ofensiva, Minería… con los ejemplos del GDD | GDD |
| 25 | Qué desbloquea cada fase | B5 | Habilidades por fase | Pasiva de recolección, habilidad activa y ataque coordinado | GDD |
| 26 | Incubación y evolución | B5 | Minutos de juego; Vínculos | Golpes de pico; fragmentos de su elemento y material de jefe | GDD |
| 27 | Guiverno de Cuarzo | B5 | Atacante propuesto | Defensa con Escudo Facetado y Haz de Cuarzo | GDD |
| 28 | Seguro de carga | B6 | Se compra con monedas | Se fabrica con minerales; protege el 50% de una carga | GDD |
| 29 | Contratos de grieta | B6 | Nunca piden derrotar jugadores | Extraer rarezas o derrotar portadores, con opción de cambio | GDD |
| 30 | Cajas de Núcleos y eventos de grieta | B6 | No existían | Caja de Núcleos, Grieta Celestial, recompensa por cabeza, rastro de venganza, jefes de grieta | GDD |

### 6.2 Correcciones que se mantienen de la primera versión

| # | Valor | Archivo | Motivo |
|---|---|---|---|
| 31 | Vitalidad `M = 1,0` y Defensa `K = 4.500` con tope 50% en PvP | B2, B4 | Dominio del Tanque |
| 32 | Multiplicador de daño entre jugadores (ahora 0,062) y topes del 35% por golpe y del 60% en 2 s | B4 | Duelos de 1 s y combos letales |
| 33 | Golpes en área al 25%, máximo 3 objetivos; grupos de hasta 3 enemigos | B4 | Hacha y Lanza |
| 34 | Regeneración de vida en combate PvE: 0,5% por segundo | B4 | Combate frente a minería |
| 35 | Monedas de jefe: `60 × V` | B4, B6 | Fuente excesiva |
| 36 | Reinicio de estadísticas: 1,5 horas de ingreso | B2, B6 | Coste desajustado |
| 37 | Mochila doble dentro de la grieta | B3 | Dar sentido al saqueo |
| 38 | 1 punto de estadística por nivel desde el 1.001; requisitos y dureza congelados desde la zona 10 | B2, B3 | Expansión |
| 39 | Sincronización de nivel en las Zonas Fracturadas | B3, B4 | Los requisitos de acceso del GDD son mínimos |

---

## 7. Índice del Documento B: fórmulas finales

| # | Fórmula | Expresión final | Archivo |
|---|---|---|---|
| F1 | Potencia de objeto | `PotZona(z) × MultRareza × (1 + mín(bonos, 0,50))`; `PotZona(z) = 100 × 2,00^(z−1)` | B1 |
| F2 | Factor de suerte | `F(S) = 1 + 3·S/(S + 1.000)` | B1 |
| F3 | Peso con suerte | `Peso × F^e`, normalizado a 100%; `e` = 0 / 0,2 / 0,4 / 0,6 / 0,8 / 1 / 1 | B1 |
| F4 | Protección A (Legendario+) | `p0` hasta la apertura 40; `p0 + (1 − p0)·((n − 40)/10)²` de 41 a 49; 100% en 50 | B1 |
| F5 | Protección B (Mítico+) | Garantía en la apertura 100; si coincide con A, manda B | B1 |
| F6 | XP por nivel | `techo(100 + 20·L + 0,8·L²)` hasta 1.000 | B2 |
| F7 | XP por acción | `25 + 3,75·L + 0,002·L²`, a unas 240 acciones por hora | B2 |
| F8 | XP por encima de 1.000 | `820.100 + 900 × (L − 1.000)` | B2 |
| F9 | Puntos de estadística | `3 + 3 × (L − 1)` hasta 1.000; +1 por nivel después; máximo 1.000 por estadística | B2 |
| F10 | Curva de estadística | `1 + M·S/(S + 1.000)`; `M` = 3 (Fuerza, Vitalidad, Minería, Suerte, Dominio), 1,5 (utilidad de mascotas), 0,8 (velocidad de ataque), 0,5 (movimiento), 1 (regeneración de energía) | B2 |
| F11 | Vida base | `500 × 2,00^((L − 1)/100)` | B2 |
| F12 | Defensa | `mín(D/(D + K), Tope)`; PvE 1.500 y 75%; PvP 4.500 y 50% | B2 |
| — | Energía | Máxima `100 + 300·E/(E + 1.000)`; regeneración 8/s en combate y 20/s fuera, por `(1 + E/(E + 1.000))`; pausa de 1,5 s | B2 |
| F13 | Requisitos de zona | Nivel `100 × (z − 1)`; Minería `10 × (z − 1)`; pico `0,5 × PotZona`; dureza `mín(2, 1 + 0,1 × (z − 1))` | B3 |
| F14 | Minería por depósito | `10 × (mín(z, 10) − 1) ×` 1 / 1 / 1,5 / 2,5 / 3,5 / 5 / 7 | B3 |
| F15 | Depósito | Vida `PotZona × FactorVida × Dureza`; valor `10 × 2,00^(z−1) × FactorValor`; XP calibrada a la XP por hora de B2 | B3 |
| F16 | Tiempo de extracción | `máx(3, techo(Vida/(PotenciaPico × MultMinería))) / GolpesPorSegundo` | B3 |
| F17 | Debuff de carga (GDD) | `Carga = valor / (20 × V(z))`; `Ralentización = mín(0,40; 0,12 × ln(1 + Carga))` | B3 |
| F18 | Daño por golpe | `PotenciaArma × Coef(tipo)` | B4 |
| F19 | Daño final | `PotenciaArma × Coef × MultFuerza × MultMaestría × MultCrítico × (1 + Estados) × (1 − Defensa) × MultModo`; `MultModo` = 1 en PvE y 0,062 en PvP | B4 |
| F20 | Maestría | `techo(10 + 2·n + 0,04·n²)`; +0,1% de daño por nivel hasta +10% | B4 |
| F21 | Vida de enemigo | `PotZona × Dureza ×` 16 / 64 / 240 / 1.200 | B4 |
| F22 | Daño de enemigo | `VidaBase(zona) ×` 3 / 6 / 10 / 15% | B4 |
| F23 | XP de enemigo | `XPacción ×` 1 / 3,5 / 10 / 60, calibrada a la XP por hora de B2 | B4 |
| F24 | Monedas de enemigo | `V(z) ×` factor calibrado para igualar al minero; jefe `60 × V` | B4, B6 |
| F25 | Escalado de jefe | Vida `× (1 + 0,6 × (n − 1))`; daño `× (1 + 0,05 × (n − 1))` | B4 |
| F26 | Nivel de mascota | `techo(15 + 3·n + 0,09·n²)`; daño `1 + 0,015 × (n − 1)` | B5 |
| F27 | DPS de mascota | `PotenciaArma × b × MultRareza × MultNivel × FactorFase × MultDominio × MultVelocidadNivel × Postura` | B5 |
| F28 | Vida de mascota | `VidaBase × h × MultRareza × (1 + 0,01 × (n − 1)) × FactorFase × MultDominio` | B5 |
| F29 | Velocidad de ataque de mascota | `VelBase × (1 + 0,002 × (n − 1))`, máximo 2,0 | B5 |
| F30 | Utilidad de mascota | Valor del GDD escalado por fase, nivel y Dominio (`M = 1,5`) | B5 |
| F31 | Tope de DPS de mascotas | `mín(1, Tope × DPSref / Σ DPS)` y ventana de 5 s; `DPSref = PotenciaArma × MultFuerza × 1,025 × MultMaestría × 1,39`; tope 40% y 25% | B5 |
| F32 | Ingreso de referencia | `I(z)`: media del minero y el combatiente equilibrados; `V(z) = 10 × 2,00^(z−1)` | B6 |
| F33 | Precio de equipo | `I(z) ×` 0,3 / 0,6 / 1,2 / 2,5 / 5 / 10 / 20; mejoras 5,75 veces el base | B6 |
| F34 | Mineral fracturado | `× 1,5 × mín(1 + 0,1 × racha; 1,5)` al extraer; ×1,0 si no | B3, B6 |
| F35 | Saqueo (GDD) | Se suelta el 50%; el 80% de eso va al cofre y el 20% se destruye | B3 |
| F36 | Seguro de carga (GDD) | Consumible fabricado; con él se suelta el 25% en lugar del 50% | B6 |

Los nombres completos, variables, ejemplos y límites de cada una están en su archivo. Los catálogos están en los CSV de `calculos/`.
