# OREBOUND — B7: Simulaciones y cierre del Documento B

Etapa 7 · 2026-11-16 · Script: `calculos/b7_simulaciones.py` (reúne las fórmulas finales de B1 a B6 y las ejecuta juntas).

> **Aviso de fuentes.** No se dispone de la sección 23 del prompt maestro: los perfiles de los
> jugadores A a G son propuestos; solo sus niveles (1, 50, 100, 300, 500, 800 y 1.000) vienen
> del prompt de trabajo. Todo sigue siendo **[PROVISIONAL]** salvo las decisiones fijas.
>
> **Esta etapa corrige B2, B3 y B4.** Las correcciones ya están aplicadas en esos archivos; la
> tabla de la sección 6 dice qué cambia, de qué valor a cuál y por qué.

---

## 1. Jugadores A a G

| Jugador | Zona | Perfil |
|---|---|---|
| A · nivel 1 · recién llegado | 1 | Arma y pico Comunes sin mejoras; 1 cría |
| B · nivel 50 · equilibrado | 1 | Equipo Raro +25 %; 2 crías de nivel 10 |
| C · nivel 100 · recién llegado a la zona 2 | 2 | Equipo Raro de zona 1 (+25 %); 3 crías de nivel 15 |
| D · nivel 300 · minero | 4 | 50 % Minería, 25 % Suerte, 25 % Vitalidad; pico Épico +50 %; 2 Recolectores |
| E · nivel 500 · combatiente | 6 | 40 % Fuerza; arma Épica +50 %; 3 mascotas desatadas |
| F · nivel 800 · híbrido de grieta | 9 | Fuerza, Vitalidad, Minería y Velocidad; equipo Legendario +50 % |
| G · nivel 1.000 · final de juego | 10 | Fuerza, Vitalidad y Dominio a 1.000; arma Ultra rara +100 %; mascotas al máximo |

### 1.1 Tiempos de combate y de extracción en su zona

| Jugador | Enemigo Común (s) | Élite (s) | Guardián (s) | Jefe en solitario (min) | Depósito Común (s) | Depósito Raro (s) | Depósito Legendario (s) |
|---|---|---|---|---|---|---|---|
| A | 6,9 | 27,6 | 103,6 | 8,6 | 6,0 | 14,0 | 34,0 |
| B | 6,0 | 24,1 | 90,5 | 7,5 | 3,8 | 7,7 | 19,2 |
| C | 10,0 | 40,1 | 150,5 | 12,5 | 5,8 | 13,5 | 31,7 |
| D | 8,1 | 32,6 | 122,2 | 10,2 | 2,8 | 3,8 | 9,4 |
| E | 2,8 | 11,1 | 41,7 | 3,5 | No puede | No puede | No puede |
| F | 2,6 | 10,5 | 39,4 | 3,3 | 2,8 | 4,6 | 10,2 |
| G | 1,3 | 5,2 | 19,3 | 1,6 | No puede | No puede | No puede |

- **A** tarda 6,9 s por enemigo gracias a la vida de tutorial a la mitad; sin ella serían 13,8 s.
- **C** acaba de llegar a la zona 2 con equipo de la zona 1: 10 s por enemigo y 12,5 minutos el jefe. Es la señal de que toca renovar equipo.
- **E** y **G** no tienen puntos en Minería y no pueden picar en su zona; tendrían que bajar a la zona 1.
- **G** derrota al jefe de la zona 10 en solitario en 1,6 minutos. Para un jugador con todo al máximo es aceptable; el jefe sigue limitado a 3 botines diarios.

### 1.2 Economía y progreso

| Jugador | Monedas/hora combatiendo | Monedas/hora minando | Combate / minería | Horas para el arma siguiente | Horas para el pico siguiente | Minutos para subir de nivel |
|---|---|---|---|---|---|---|
| A | 4.113 | 4.428 | 0,93 | 0,8 h (Poco común) | 0,8 h (Poco común) | 1,1 |
| B | 4.838 | 5.817 | 0,83 | 2,6 h (Épico) | 2,6 h (Épico) | 2,9 |
| C | 5.422 | 7.261 | 0,75 | 3,4 h (Épico) | 3,4 h (Épico) | 6,3 |
| D | 18.527 | 34.070 | 0,54 | 2,0 h (Épico) | 3,9 h (Legendario) | 9,7 |
| E | 95.955 | No puede | — | 3,8 h (Legendario) | 1,9 h (Épico) | 13,3 |
| F | 442.507 | 379.093 | 1,17 | 7,4 h (Mítico) | 7,4 h (Mítico) | 18,2 |
| G | 949.866 | No puede | — | 11,4 h (Ultra raro) | 11,4 h (Ultra raro) | 16,2 |

- «Horas para el siguiente» = horas de juego para pagar la rareza siguiente de su zona, guardando el 80% de lo que gana con su mejor actividad.
- El arma o el pico siguiente cuestan entre 0,8 y 11,4 horas: ningún salto de equipo queda fuera de alcance.
- Subir de nivel cuesta de 1 a 18 minutos. A nivel 1.000 ya no se sube; la cifra de G es el ritmo del nivel 999.
- **Combate frente a minería:** con los perfiles equilibrados (A, B, C) minar rinde entre 1,08 y 1,34 veces lo que combatir. El peor caso es C (1,34), recién llegado a una zona con el arma vieja. Ver el problema P5.

### 1.3 Mascotas y minerales raros

| Jugador | DPS de mascotas sin tope | DPS de mascotas contado | Ayuda al picar | Daño desviado | Curación por segundo | Tiempo parado | Rareza máxima que pica | Depósitos Legendario o superior | Legendario+ por hora |
|---|---|---|---|---|---|---|---|---|---|
| A | 0,5 % | 0,5 % | 4,0 % | 0,0 % | 0,00 % | 11,3 % | Mítico | 2,50 % | 5,3 |
| B | 3,1 % | 3,1 % | 5,4 % | 0,0 % | 0,00 % | 4,6 % | Mítico | 2,59 % | 7,2 |
| C | 4,6 % | 4,6 % | 6,8 % | 5,6 % | 0,00 % | 7,0 % | Legendario | 2,68 % | 4,7 |
| D | 3,8 % | 3,8 % | 10,8 % | 6,0 % | 0,00 % | 0,0 % | Mítico | 3,37 % | 11,1 |
| E | 7,3 % | 7,3 % | 4,7 % | 7,8 % | 0,00 % | 0,0 % | Ninguna | 2,50 % | 0,0 |
| F | 6,3 % | 6,3 % | 10,1 % | 0,0 % | 0,25 % | 0,0 % | Ultra raro | 2,50 % | 8,2 |
| G | 36,0 % | 36,0 % | 11,8 % | 0,0 % | 0,59 % | 0,0 % | Ninguna | 2,50 % | 0,0 |

- Ningún jugador supera el tope del 40%: G se queda en el 36,0% con mascotas Ultra raras al máximo y Dominio 1.000.
- La ayuda al picar va del 4% al 11,8%, lejos del tope del 20%.
- Con la regeneración en combate de esta etapa, el tiempo parado recuperando vida baja al 4,6–11,3% al principio y a 0% desde el nivel 300.
- D, el minero con un 25% de sus puntos en Suerte, ve un 3,37% de depósitos Legendario o superior (base 2,50%) y pica 11,1 por hora.

---

## 2. Builds extremas

### 2.1 Todo en una estadística

Nivel 1.000, equipo Legendario +50% y las mismas tres mascotas. «Todo en X» = 1.000 puntos en X y 285 en cada una de las otras siete.

| Build (nivel 1.000, equipo Legendario +50 %) | DPS (× equilibrada) | Vida efectiva PvE (× base) | Vida efectiva PvP (× base) | Monedas/h combate | × equilibrada | Monedas/h minería | × equilibrada | Mejor estilo × equilibrada | Legendario+ en depósitos | DPS de mascotas contado |
|---|---|---|---|---|---|---|---|---|---|---|
| Equilibrada (375 en todo) | 1,00 | 2,27 | 1,38 | 693.570 | 1,00 | 630.359 | 1,00 | 1,00 | 3,75 % | 17,1 % |
| Todo en Fuerza | 1,28 | 1,98 | 1,30 | 775.035 | 1,12 | 540.180 | 0,86 | 1,12 | 3,53 % | 11,4 % |
| Todo en Minería | 0,89 | 1,98 | 1,30 | 654.788 | 0,94 | 712.116 | 1,13 | 1,03 | 3,53 % | 17,1 % |
| Todo en Suerte | 0,89 | 1,98 | 1,30 | 654.788 | 0,94 | 565.322 | 0,90 | 0,94 | 4,62 % | 17,1 % |
| Todo en Defensa | 0,89 | 2,78 | 1,49 | 654.788 | 0,94 | 540.180 | 0,86 | 0,94 | 3,53 % | 17,1 % |
| Todo en Dominio | 0,95 | 1,98 | 1,30 | 675.546 | 0,97 | 540.180 | 0,86 | 0,97 | 3,53 % | 25,7 % |
| Minería + Suerte + Vitalidad | 0,47 | 2,50 | 1,50 | 448.235 | 0,65 | 780.673 | 1,24 | 1,13 | 4,62 % | 17,1 % |
| Fuerza + Velocidad + Energía | 1,44 | 1,00 | 1,00 | 813.912 | 1,17 | 0 | 0,00 | 1,17 | 2,50 % | 6,8 % |

- **Ninguna build rinde más de 1,17 veces la equilibrada** en su mejor actividad. El límite de 1,3 se cumple con margen.
- **Todo en Fuerza:** +28% de DPS, pero solo +12% de monedas, porque el tiempo de desplazamiento no cambia.
- **Todo en Minería:** +13% minando. **Minería + Suerte + Vitalidad:** +24%, la mejor build de minero.
- **Todo en Suerte:** sube los depósitos Legendario o superior de 3,75% a 4,62%, pero pierde monedas (0,90) porque pica más despacio. La Suerte sola no compensa; combinada con Minería, sí.
- **Todo en Defensa:** la más resistente (×2,78 de vida efectiva en PvE) y de las que menos gana.
- **Todo en Dominio:** sus mascotas pasan del 17,1% al 25,7% del DPS del jugador, pero la build rinde 0,97. El Dominio no sirve como estadística de daño; su valor está en la utilidad (B5).
- **Fuerza + Velocidad + Energía:** el mayor DPS (×1,44), la que más gana combatiendo (1,17) y cero minería.

### 2.2 Solo equipo Común, Ultra raro y Celestial

Build equilibrada de nivel 1.000 en la zona 10.

| Equipo (build equilibrada, nivel 1.000) | Potencia | DPS (× Común) | Enemigo Común (s) | Jefe (min) | Depósito Común (s) | Monedas/h combate | × Común | Monedas/h minería | × Común |
|---|---|---|---|---|---|---|---|---|---|
| Solo Común sin mejoras | 9.065 | 1,00 | 7,7 | 9,6 | 6,0 | 389.250 | 1,00 | 419.550 | 1,00 |
| Raro +25 % | 14.957 | 1,65 | 4,7 | 5,8 | 3,8 | 540.039 | 1,39 | 543.154 | 1,29 |
| Legendario +50 % | 23.795 | 2,63 | 2,9 | 3,7 | 2,8 | 693.570 | 1,78 | 630.359 | 1,50 |
| Ultra raro +100 % | 39.885 | 4,40 | 1,8 | 2,2 | 2,7 | 860.600 | 2,21 | 687.249 | 1,64 |
| Celestial +100 % | 47.137 | 5,20 | 1,5 | 1,9 | 2,6 | 910.488 | 2,34 | 698.286 | 1,66 |

- El equipo Ultra raro al máximo da 2,21 veces las monedas del Común en combate; el Celestial, 2,34.
- **Celestial frente a Ultra raro: +5,8% de monedas.** Es mejor, pero no obligatorio.
- En minería la diferencia se aplana (1,64 frente a 1,66) por el mínimo de 3 golpes por depósito.
- Bajar a la zona 9 con equipo Ultra raro rinde 0,62 veces lo que la zona 10: no compensa farmear zonas inferiores.

---

## 3. Escenarios de Zona Fracturada

Nivel 1.000 en la Zona Fracturada de la zona 10, arma Legendaria +50%, mascotas al tope del 25%.

### 3.1 Minero solo contra 2 saqueadores

Saqueadores: un Cristal (WalkSpeed 20) y un Tanque (WalkSpeed 16). El minero huye hacia una salida; salir requiere 3 s de canalización sin recibir daño.

| Situación | Carga | Velocidad del minero | WalkSpeed del minero | Tiempo hasta el primer golpe | Distancia máxima a una salida para escapar (studs) | Tiempo hasta morir si no escapa | Con mascotas en Proteger |
|---|---|---|---|---|---|---|---|
| Los ve a 60 studs | 25 % | 0 | 15,4 | 11,3 s | 128 | 21,5 s | 24,0 s |
| Los ve a 60 studs | 25 % | 1.000 | 19,2 | 69,3 s | 1.276 | 79,4 s | 82,0 s |
| Los ve a 60 studs | 50 % | 0 | 14,3 | 9,1 s | 87 | 19,3 s | 21,8 s |
| Los ve a 60 studs | 50 % | 1.000 | 17,9 | 24,5 s | 384 | 34,7 s | 37,2 s |
| Los ve a 60 studs | 100 % | 0 | 11,2 | 5,9 s | 32 | 13,9 s | 15,4 s |
| Los ve a 60 studs | 100 % | 1.000 | 14,0 | 8,6 s | 79 | 18,8 s | 21,4 s |
| Emboscada a 20 studs | 25 % | 0 | 15,4 | 2,6 s | 0 | 12,8 s | 15,3 s |
| Emboscada a 20 studs | 25 % | 1.000 | 19,2 | 16,0 s | 249 | 26,1 s | 28,7 s |
| Emboscada a 20 studs | 50 % | 0 | 14,3 | 2,1 s | 0 | 10,1 s | 11,6 s |
| Emboscada a 20 studs | 50 % | 1.000 | 17,9 | 5,6 s | 47 | 15,8 s | 18,4 s |
| Emboscada a 20 studs | 100 % | 0 | 11,2 | 1,4 s | 0 | 7,7 s | 9,2 s |
| Emboscada a 20 studs | 100 % | 1.000 | 14,0 | 2,0 s | 0 | 9,6 s | 11,0 s |

- **Si planta cara, muere en 5,9 s** y solo le quita al Cristal el 25% de la vida. Pelear no es opción.
- **Visto de lejos y con poca carga, escapa:** con el 25% de carga y Velocidad 1.000 tiene 69 s de ventaja.
- **Cargado al 100% casi no escapa:** necesita una salida a menos de 32–79 studs.
- **En una emboscada a 20 studs, solo escapa el minero con Velocidad y poca carga.**
- Las mascotas en Proteger alargan la vida entre 1,5 y 2,6 s: ayudan, pero no salvan.
- **Consecuencia de diseño:** el mapa de cada Zona Fracturada debe tener una salida o un Punto de Extracción a menos de 150 studs de cualquier depósito, y la decisión real del minero es cuánta carga acumular antes de extraer.

### 3.2 Escuadrón de 3 contra 3

Cada escuadrón concentra el daño en el rival con menos vida.

| Escuadrón A | Escuadrón B | Gana | Duración | Supervivientes | Vida restante del ganador |
|---|---|---|---|---|---|
| Cristal + Cristal + Cristal | Tanque + Tanque + Tanque | Escuadrón B | 11,9 s | 2 | 40 % |
| Equilibrada + Equilibrada + Equilibrada | Tanque + Tanque + Tanque | Escuadrón B | 15,6 s | 2 | 50 % |
| Cristal + Cristal + Tanque | Tanque + Tanque + Cristal | Escuadrón B | 20,7 s | 1 | 19 % |
| Cristal + Tanque + Equilibrada | Equilibrada + Equilibrada + Equilibrada | Escuadrón A | 24,3 s | 1 | 12 % |
| Minero + Minero + Minero | Cristal + Cristal + Cristal | Escuadrón B | 10,2 s | 3 | 71 % |
| Minero + Minero + Tanque | Cristal + Cristal + Tanque | Escuadrón B | 18,9 s | 1 | 33 % |

- Los combates duran entre 10 y 24 s.
- **Los escuadrones de Tanques ganan a los de Cristales y a los de Equilibradas.** Con fuego concentrado, la vida vale más que el daño. Ver el problema P3.
- Los equipos mixtos se deciden por poco (12–19% de vida restante).
- **Tres mineros pierden contra tres Cristales sin matar a ninguno.** Un Tanque de escolta cambia el resultado: los saqueadores ganan con un solo superviviente al 33%.

### 3.3 Saqueador profesional frente a minero PvE

Simulación de 4.000 horas. El saqueador busca objetivo, pelea 20 s y extrae al llegar al 50% de carga. Objetivos: 70% mineros solos, 20% mineros con escuadrón y 10% otros saqueadores.

| Escenario | Muertes causadas por hora | Muertes propias por hora | Extracciones por hora | Ingresos (× minero PvE) | Con contratos (× minero PvE) |
|---|---|---|---|---|---|
| Servidor con pocos mineros (búsqueda de 5 min) | 6,3 | 1,76 | 1,35 | 0,25 | 0,35 |
| Servidor normal (3 min) | 9,5 | 2,67 | 2,03 | 0,38 | 0,48 |
| Servidor lleno de mineros (1,5 min) | 15,5 | 4,35 | 3,35 | 0,63 | 0,73 |
| Servidor normal con 85 % recogible | 9,4 | 2,64 | 2,51 | 0,48 | 0,58 |

- **El saqueador profesional gana entre 0,35 y 0,73 veces lo que un minero PvE.** En un servidor normal, 0,48.
- Confirma el 0,47 estimado en B6. Saquear no es una forma rentable de ganar monedas, y así se mantiene (decisión E6-23).
- Subir lo recogible al 85% lo deja en 0,58: no cambia la conclusión.

Efecto sobre los mineros según cuántos saqueadores haya:

| Saqueadores por mineros | Prob. de morir por viaje | Minero de grieta (× PvE) | Con contratos |
|---|---|---|---|
| 1 por cada 10 | 8,2 % | 2,18 | 2,28 |
| 2 por cada 10 | 15,8 % | 2,05 | 2,15 |
| 3 por cada 10 | 22,7 % | 1,94 | 2,04 |
| 5 por cada 10 | 34,9 % | 1,74 | 1,84 |
| 10 por cada 10 | 57,6 % | 1,35 | 1,45 |

- Incluso con un saqueador por cada minero, el minero de grieta gana 1,45 veces el PvE. El modo sigue mereciendo la pena.
- Con 2–3 saqueadores por cada 10 mineros, la probabilidad de morir por viaje es del 16–23%, cerca del 30% usado en B6.
- **Traspaso entre cuentas:** dejarse matar por un cómplice entrega 1,20 veces el valor base (1,45 con seguro), frente a 2,00 extrayendo. No hay incentivo para hacerlo.

---

## 4. Escalado más allá del nivel 1.000

Las fórmulas no cambian. Solo se añaden tres topes de parámetro (sección 6): requisito de Minería y dureza congelados a partir de la zona 10, y 1 punto de estadística por nivel desde el 1.001.

Regla de zonas: la zona `z` se abre en el nivel `100 × (z − 1)`. Los niveles 1.100, 1.200, 1.500 y 2.000 corresponden a las zonas 12, 13, 16 y 21.

| Nivel | Zona | Potencia de zona | Vida del jefe | Vida base del jugador | XP para el siguiente nivel | Minutos por nivel | Monedas/hora | Depósito Común sin tope de dureza (s) | Con tope (s) | Enemigo Común sin tope (s) | Con tope (s) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1.000 | 10 | 9,06 × 10^3 | 2,58 × 10^07 | 74.411 | 820.100 | 28,4 | 540.039 | 3,8 | 3,8 | 4,7 | 4,7 |
| 1.100 | 12 | 2,47 × 10^4 | 7,4 × 10^07 | 122.777 | 910.100 | 28,4 | 1.437.500 | 3,8 | 3,8 | 5,1 | 4,8 |
| 1.200 | 13 | 4,07 × 10^4 | 1,22 × 10^08 | 202.583 | 1.000.100 | 27,4 | 2.392.746 | 3,8 | 3,8 | 5,3 | 4,8 |
| 1.500 | 16 | 1,83 × 10^5 | 5,49 × 10^08 | 910.027 | 1.270.100 | 24,8 | 11.003.152 | 4,8 | 3,8 | 5,7 | 4,6 |
| 2.000 | 21 | 2,24 × 10^6 | 6,71 × 10^09 | 11.129.459 | 1.720.100 | 21,2 | 139.408.376 | 4,8 | 3,8 | 6,5 | 4,3 |

| Nivel | Zona | Puntos (1 por nivel desde 1.001) | Estadísticas al máximo | Puntos si siguieran a 3 por nivel | Estadísticas al máximo | Minería para Ultra raro sin tope | Con tope | Rareza máxima (equilibrada) sin tope | Con tope |
|---|---|---|---|---|---|---|---|---|---|
| 1.000 | 10 | 3.000 | 3 | 3.000 | 3 | 630 | 630 | Legendario | Legendario |
| 1.100 | 12 | 3.100 | 3 | 3.300 | 3 | 770 | 630 | Legendario | Legendario |
| 1.200 | 13 | 3.200 | 3 | 3.600 | 3 | 840 | 630 | Épico | Legendario |
| 1.500 | 16 | 3.500 | 3 | 4.500 | 4 | 1.050 | 630 | Épico | Legendario |
| 2.000 | 21 | 4.000 | 4 | 6.000 | 6 | 1.400 | 630 | Épico | Mítico |

- **Sin los topes, el juego se rompe:** el Ultra raro de la zona 21 pediría Minería 1.400 (el máximo es 1.000) y una build equilibrada solo podría picar hasta Épico.
- **Con los topes**, los tiempos se mantienen: 3,8 s por depósito Común y 4,3–4,8 s por enemigo.
- **Con 3 puntos por nivel**, a nivel 2.000 se podrían llevar al máximo 6 de las 8 estadísticas y las builds dejarían de diferenciarse. Con 1 punto por nivel son 4.
- Cada nivel cuesta entre 21 y 28 minutos, estable gracias a la cola lineal de XP de B2.
- **Los números caben:** la vida del jefe de la zona 21 con 8 jugadores es 3,5 × 10¹⁰ y las monedas ganadas en total hasta el nivel 2.000 son 8,0 × 10⁹, muy por debajo del límite exacto de Roblox (9,0 × 10¹⁵).
- **Para añadir una zona nueva basta con:** nombre, 6 o 7 minerales, un jefe y su Zona Fracturada. Vida, daño, valor, precios y requisitos salen de las fórmulas.

---

## 5. Builds y combinaciones que rompen el juego

| # | Combinación | Qué rompe | Corrección | Estado |
|---|---|---|---|---|
| P1 | Hacha o Lanza contra grupos de enemigos | Golpear a 5 objetivos al 100% daba 3,7 veces los enemigos por hora | Máximo 3 objetivos por golpe; los secundarios reciben el 25%; grupos de hasta 3 enemigos | Aplicada en B4 |
| P2 | Núcleo Umbrío: Manto + Eclipse + Paso + Tajo | 97% de la vida de un Cristal en 3 s; con un crítico más, lo mata de un combo | Tope de ráfaga: no más del 60% de la vida máxima en 2 s en PvP | Aplicada en B4 |
| P3 | Tanque (Fuerza + Vitalidad + Defensa) en PvP | Ganaba al Cristal con una ventaja de 1,69 veces | Vitalidad `M = 1,0`, Defensa `K = 4.500` y tope 50% en PvP; daño PvP ×0,06 | Aplicada en B2 y B4; ventaja 1,33 |
| P4 | Subir por encima del nivel 1.000 | Requisitos imposibles y 6 estadísticas al máximo | Topes de requisito y dureza; 1 punto por nivel | Aplicada en B2 y B3 |
| P5 | Minar al llegar a una zona nueva | Minar rendía hasta 2,1 veces más que combatir al principio | Regeneración del 0,5% de vida por segundo en combate PvE | Aplicada en B4; queda 1,34 en el peor caso |
| P6 | Jefes 3 veces al día | 1,6 horas de ingreso gratis al día | Monedas de jefe de `250 × V` a `60 × V` | Aplicada en la Etapa 6 |
| P7 | Farmear zonas bajas con equipo alto | Vaciar zonas de un golpe | Mínimo de 3 golpes por depósito; rinde 0,62 | Ya en B3; comprobado |
| P8 | Traspasar mineral a una segunda cuenta | Duplicar el ×2,0 | Lo saqueado vale 1,20; misma víctima sin botín 10 minutos | Ya en B3; comprobado |
| P9 | Mascotas con Dominio 1.000 | 141,7% del DPS del jugador | Tope del 40% y 25% aplicado por el servidor | Ya en B5; comprobado (máximo 36,0%) |
| P10 | Encadenar aturdimientos | Bloqueo permanente | Rendimientos decrecientes y Rompecadenas a los 2,0 s | Ya en B4 |
| P11 | Acumular Suerte | Legendario garantizado | Factor de suerte con techo ×4 | Ya en B1; todo en Suerte rinde 0,90–0,94 |

### P1 — Golpes en área

| Caso | Enemigos/hora | × un solo objetivo | × minero equivalente |
|---|---|---|---|
| Referencia de B4: un objetivo, enemigos sueltos | 310 | 1,00 | 1,03 |
| Hacha antes: 5 objetivos al 100 %, grupos de hasta 5 | 1.142 | 3,68 | 3,79 |
| Lanza antes: 3 objetivos al 100 %, grupos de hasta 5 | 927 | 2,99 | 3,08 |
| Hacha después: secundarios al 25 %, máx. 3; grupos de hasta 3 | 385 | 1,24 | 1,28 |
| Lanza después: secundarios al 25 %, máx. 3 | 372 | 1,20 | 1,23 |
| Espada después: 2 objetivos, secundario al 25 % | 372 | 1,20 | 1,24 |
| Daga después: un objetivo; grupos de hasta 3 | 349 | 1,13 | 1,16 |

Con la regla nueva, el arma más favorecida (Hacha) queda en 1,28 veces el minero equivalente, bajo el límite de 1,3.

### P2 — Ráfaga de un combo

| Defensor | Vida máxima en PvP | Daño del combo Umbrío (C + V + X + Z, unos 3 s) | % de la vida | Sin tope de ráfaga | Con tope (60 % en 2 s) | Resultado |
|---|---|---|---|---|---|---|
| Cristal | 74.411 | 72.099 | 97 % | Sobrevive | 60 % | Sobrevive |
| Minero | 111.616 | 72.099 | 65 % | Sobrevive | 60 % | Sobrevive |
| Equilibrada | 94.704 | 66.553 | 70 % | Sobrevive | 60 % | Sobrevive |
| Tanque | 111.616 | 58.990 | 53 % | Sobrevive | 60 % | Sobrevive |

### P3 — Tanque frente a Cristal

| Regla PvP | Cristal mata al Tanque en | Tanque mata al Cristal en | Ventaja del Tanque | Duelo de Equilibradas | Duelo de Tanques |
|---|---|---|---|---|---|
| B4: Vitalidad M = 1,5; Defensa K = 3.000, tope 60 % | 15,8 s | 9,3 s | 1,69 | 16,8 s | 21,7 s |
| Solo Vitalidad M = 1,0 | 13,5 s | 9,3 s | 1,45 | 15,2 s | 18,6 s |
| Solo Defensa K = 4.500, tope 50 % | 14,5 s | 9,3 s | 1,55 | 16,2 s | 19,9 s |
| Etapa 7: Vitalidad M = 1,0; Defensa K = 4.500, tope 50 % | 12,4 s | 9,3 s | 1,33 | 14,6 s | 17,1 s |

- La ventaja restante (1,33) se deja: el Cristal tiene un 25% más de velocidad de movimiento y más usos de habilidad, que esta simulación no puede medir.
- **Sigue siendo el punto más débil del PvP.** En escuadrones, los Tanques siguen ganando (sección 3.2). Hay que medirlo en la beta; el siguiente ajuste sería reducir la Defensa efectiva contra habilidades.

Nueva tabla de Defensa en PvP (sustituye a la de B2):

| Defensa | Reducción en PvP | Daño recibido | Vida efectiva |
|---|---|---|---|
| 10 | 0,22 % | 99,78 % | ×1,00 |
| 100 | 2,17 % | 97,83 % | ×1,02 |
| 500 | 10,00 % | 90,00 % | ×1,11 |
| 1.000 | 18,18 % | 81,82 % | ×1,22 |
| 2.500 | 35,71 % | 64,29 % | ×1,56 |
| 5.000 | 50,00 % | 50,00 % | ×2,00 |

### P5 — Combate frente a minería al principio

- **Problema:** con el modelo de B5 (el jugador para a recuperar vida), los perfiles iniciales perdían entre el 16% y el 24% del tiempo. Minar rendía 1,36 veces lo que combatir para B y 1,51 para C.
- **Corrección:** regeneración del 0,5% de la vida máxima por segundo durante el combate en PvE. El tiempo parado baja al 4,6–11,3%.
- **Resultado:** minar rinde 1,08 (A), 1,20 (B) y 1,34 (C) veces lo que combatir.
- **Lo que queda:** C sigue un poco por encima de 1,3. Es un estado transitorio (arma de la zona anterior) y se corrige al fabricar el arma de la zona, que cuesta 3,4 horas. No se toca más para no desajustar el final del juego, donde el combatiente ya gana 1,17 veces (F).

### Sin corrección en esta etapa

- **Núcleos de Escarcha y Sísmico** hacen hasta un 19% menos de daño. No rompe nada; se mide su uso en la beta (B4, P5).
- **Máximo teórico de daño de 36 veces.** La build más fuerte simulada (G) hace 6,0 veces el daño de un jugador equilibrado con equipo Común. No hay builds por encima de 15 veces, así que no se bajan los topes (B4, P4).
- **El tope total de 5.000 por estadística** es inalcanzable: el equipo no da estadísticas y los consumibles suman 100. Se mantiene como seguro para contenido futuro.

---

## 6. Tabla de cambios en los archivos B

| # | Valor | Archivo | Antes | Ahora | Por qué |
|---|---|---|---|---|---|
| 1 | Vitalidad en PvP (`M`) | B2 (P1), B4 (8.1) | 1,5 | 1,0 | Ventaja del Tanque de 1,69 a 1,33 |
| 2 | Defensa en PvP (`K` y tope) | B2 (sección 7), B4 (F19, 8.1) | 3.000 y 60% | 4.500 y 50% | Igual que el anterior |
| 3 | Multiplicador de daño PvP (`MultModo`) | B4 (F19, 8.1, 8.2) | 0,07 | 0,06 | Mantener los duelos en 8–25 s tras bajar la vida efectiva |
| 4 | Tope de ráfaga en PvP | B4 (8.1) | No existía | 60% de la vida máxima en 2 s | Combo del Núcleo Umbrío |
| 5 | Golpes en área del ataque básico | B4 (1.1) | Hasta 5 objetivos al 100% | Hasta 3; secundarios al 25% | Hacha y Lanza contra grupos |
| 6 | Grupos de enemigos | B4 (sección 6) | Sin definir | 70% solos, 25% parejas, 5% tríos; 20 studs de separación | Igual que el anterior |
| 7 | Regeneración de vida en combate PvE | B4 (sección 6) | 0 | 0,5% de la vida máxima por segundo | Combate peor que minería al principio |
| 8 | Puntos de estadística desde el nivel 1.001 | B2 (sección 5) | 3 por nivel | 1 por nivel | Evitar 6 estadísticas al máximo |
| 9 | Minería requerida en zonas mayores que 10 | B3 (F14) | `10 × (z − 1) × factor` | Congelada en el valor de la zona 10 | Requisito imposible (1.400) |
| 10 | Dureza en zonas mayores que 10 | B3 (F13) | `1 + 0,1 × (z − 1)` | Máximo 2,0 | Tiempos de extracción y combate estables |
| 11 | Salir de una Zona Fracturada sin extraer | B3 (7.5) | Sin definir | 3 s de canalización que el daño interrumpe | Escenario del minero perseguido |
| 12 | Monedas de jefe | B4 | `250 × V` | `60 × V` | Hecho en la Etapa 6 |
| 13 | Coste del reinicio de estadísticas | B2 | `1.000 × nivel` | 1,5 horas de ingreso | Hecho en la Etapa 6 |
| 14 | Mochila en Zona Fracturada y racha | B3 | 60 unidades; sin racha | 120 unidades; racha de +2% hasta +10% | Hecho en la Etapa 6 |
| 15 | XP por depósito | B3 | Sin factor | × 0,73 | Hecho en la Etapa 3 |
| 16 | Monedas y XP de enemigos | B4 | 1,5 / 6 / 18 y 0,82 | 1,35 / 5,4 / 16 y 0,72 | Hecho en la Etapa 4 |

B1, B5 y B6 no cambian en esta etapa. La tabla de duelos de B4 (8.2) y la tabla de Defensa de B2 (sección 7) se han regenerado con los valores nuevos.

---

## 7. Índice del Documento B: fórmulas finales

| # | Fórmula | Expresión final | Archivo |
|---|---|---|---|
| F1 | Potencia de objeto | `PotZona(z) × MultRareza × (1 + mín(BonoNivel + BonoMejoras + BonoHabilidades, 1,00))`; `PotZona(z) = 100 × 1,65^(z−1)` | B1 |
| F2 | Factor de suerte | `F(S) = 1 + 3·S/(S + 1.000)` | B1 |
| F3 | Peso con suerte | `Peso × F^e`, normalizado a 100%; `e` = 0 / 0,2 / 0,4 / 0,6 / 0,8 / 1 / 1 | B1 |
| F4 | Protección A (Legendario+) | `p0` hasta la apertura 40; `p0 + (1 − p0)·((n − 40)/10)²` de 41 a 49; 100% en 50 | B1 |
| F5 | Protección B (Mítico+) | Garantía en la apertura 100; si coincide con A, manda B | B1 |
| F6 | XP por nivel | `techo(100 + 20·L + 0,8·L²)` hasta 1.000 | B2 |
| F7 | XP por acción | `25 + 3,75·L + 0,002·L²`, a unas 240 acciones por hora | B2 |
| F8 | XP por encima de 1.000 | `820.100 + 900 × (L − 1.000)` | B2 |
| F9 | Puntos de estadística | `3 + 3 × (L − 1)` hasta 1.000; +1 por nivel después; máximo 1.000 por estadística | B2, B7 |
| F10 | Curva de estadística | `1 + M·S/(S + 1.000)`; `M` = 3 (Fuerza, Vitalidad, Minería, Suerte, Dominio), 1,5 (recolección y utilidad), 0,8 (velocidad de ataque), 0,5 (movimiento), 1 (regeneración de energía) | B2 |
| F11 | Vida base | `500 × 1,65^((L − 1)/100)` | B2 |
| F12 | Defensa | `mín(D/(D + K), Tope)`; PvE 1.500 y 75%; PvP 4.500 y 50% | B2, B7 |
| — | Energía | Máxima `100 + 300·E/(E + 1.000)`; regeneración 8/s en combate y 20/s fuera, por `(1 + E/(E + 1.000))`; pausa de 1,5 s | B2 |
| F13 | Requisitos de zona | Nivel `100 × (z − 1)`; Minería `10 × (z − 1)`; pico `0,6 × PotZona`; dureza `mín(2, 1 + 0,1 × (z − 1))` | B3, B7 |
| F14 | Minería por depósito | `10 × (mín(z, 10) − 1) ×` 1 / 1 / 1,5 / 2,5 / 3,5 / 5 / 7 | B3, B7 |
| F15 | Depósito | Vida `PotZona × FactorVida × Dureza`; valor `10 × 1,65^(z−1) × FactorValor`; XP `0,73 × XPacción × FactorXP` | B3 |
| F16 | Tiempo de extracción | `máx(3, techo(Vida/(PotenciaPico × MultMinería))) / GolpesPorSegundo` | B3 |
| F17 | Debuff de carga | Velocidad `× (1 − 0,30 × c^1,5)`; dash `20 × (1 + 0,5 × c)` | B3 |
| F18 | Daño por golpe | `PotenciaArma × Coef(tipo)` | B4 |
| F19 | Daño final | `PotenciaArma × Coef × MultFuerza × MultMaestría × MultCrítico × (1 + Estados) × (1 − Defensa) × MultModo`; `MultModo` = 1 en PvE y 0,06 en PvP | B4, B7 |
| F20 | Maestría | `techo(10 + 2·n + 0,04·n²)`; +0,1% de daño por nivel hasta +10% | B4 |
| F21 | Vida de enemigo | `PotZona × Dureza ×` 20 / 80 / 300 / 1.500 | B4 |
| F22 | Daño de enemigo | `VidaBase(zona) ×` 3 / 6 / 10 / 15% | B4 |
| F23 | XP de enemigo | `0,72 × XPacción ×` 1 / 3,5 / 10 / 60 | B4 |
| F24 | Monedas de enemigo | `V(z) ×` 1,35 / 5,4 / 16 / 60 | B4, B6 |
| F25 | Escalado de jefe | Vida `× (1 + 0,6 × (n − 1))`; daño `× (1 + 0,05 × (n − 1))` | B4 |
| F26 | Nivel de mascota | `techo(15 + 3·n + 0,09·n²)`; daño `1 + 0,015 × (n − 1)` | B5 |
| F27 | DPS de mascota | `PotenciaArma × b × MultRareza × MultNivel × FactorFase × MultDominio × MultVelocidadNivel` | B5 |
| F28 | Vida de mascota | `VidaBase × h × MultRareza × (1 + 0,01 × (n − 1)) × FactorFase × MultDominio` | B5 |
| F29 | Velocidad de ataque de mascota | `VelBase × (1 + 0,002 × (n − 1))`, máximo 2,0 | B5 |
| F30 | Utilidad de mascota | `ValorBase × FactorFase × (1 + 0,005 × (n − 1)) × (1 + 1,5·D/(D + 1.000))` | B5 |
| F31 | Tope de DPS de mascotas | `mín(1, Tope × DPSref / Σ DPS)` y ventana de 5 s; `DPSref = PotenciaArma × MultFuerza × 1,025 × MultMaestría × 1,75`; tope 40% y 25% | B5 |
| F32 | Ingreso de referencia | `I(z)` ≈ `480 × V(z)`; `V(z) = 10 × 1,65^(z−1)` | B6 |
| F33 | Precio de equipo | `I(z) ×` 0,3 / 0,6 / 1,2 / 2,5 / 5 / 10 / 20; mejoras 5,75 veces el base | B6 |
| F34 | Mineral fracturado | `× 2,0 × (1 + 0,02 × mín(racha, 5))` al extraer; ×1,0 si no | B3, B6 |
| F35 | Saqueo | Se suelta el 50%; el 70% de eso va al cofre y el 30% se destruye | B3 |
| F36 | Seguro de carga | Prima `6 × V`; paga el 50% del valor base de lo soltado | B6 |

Los nombres completos, variables, ejemplos y límites de cada una están en su archivo. Los catálogos (minerales, picos, armas y precios) están en los CSV de `calculos/`.
