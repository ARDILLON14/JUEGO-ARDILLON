# OREBOUND — Documento A: Game Design Document

Etapa 8 · 2026-11-16 · Cálculos de apoyo: `calculos/b8_gdd.py`.

> **Cómo leer este documento**
>
> - **[C]** = CONFIRMADO: decisión fija del autor (ver `DECISIONES.md`, sección 1).
> - **[P]** = PROVISIONAL: propuesta del equipo de diseño, pendiente de prueba.
> - Los números de detalle no se repiten aquí: cada sección remite a su archivo B. **Si un número de este documento difiere de un archivo B, manda el archivo B.**
>
> **Aviso de fuentes.** No se ha dispuesto del prompt maestro ni del GDD de combate, minería y
> mascotas. La dirección de arte, los 4 mundos, los eventos, el renacimiento y los sistemas de
> retención de este documento son propuestas **[P]**; del material original solo se conoce que
> existen (ciudad principal, 4 mundos, arenas, diarias, semanales, temporadas, logros, códice y
> renacimiento).

---

## 1. Concepto, público y pilares

### 1.1 Concepto

OREBOUND es un juego de rol de acción y minería para Roblox. El jugador baja por una mina de 10 zonas, pica minerales, pelea contra criaturas y jefes, fabrica picos y armas cada vez mejores y cría mascotas que le ayudan. Junto a cada zona hay una **Zona Fracturada** opcional: el mismo mineral vale el doble, pero otros jugadores pueden atacarte y llevarse parte de lo que cargas.

Frase de venta: *«Baja más hondo. Carga más. Decide cuándo salir.»*

### 1.2 Público objetivo [P]

| Aspecto | Definición |
|---|---|
| Edad principal | 10 a 16 años |
| Plataformas | Móvil (prioritaria), PC y consola |
| Sesión típica | 20–40 minutos; debe poder aprovecharse una de 10 |
| Perfil | Jugadores de simuladores de minería y de RPG de acción de Roblox |
| Tono | Aventura fantástica, sin sangre ni contenido adulto |

### 1.3 Pilares de diseño

| # | Pilar | Qué significa en la práctica | Estado |
|---|---|---|---|
| 1 | La zona pesa más que la suerte | Un objeto Común de zona alta supera a uno Ultra raro de 3 zonas atrás. Avanzar siempre compensa | [P] (B1) |
| 2 | El riesgo es opcional y acotado | La mina es PvE. En las Zonas Fracturadas solo se arriesga el mineral que llevas; nunca armas, picos, mascotas, monedas ni nivel | [C] |
| 3 | Varias formas de jugar valen parecido | Minero y combatiente ganan casi lo mismo (1,02–1,06); ninguna build extrema supera 1,17 veces a la equilibrada | [P] (B6, B7) |
| 4 | Todo tiene techo | Cada estadística, bono y efecto tiene un tope; no hay multiplicadores descontrolados | [P] (B1–B5) |
| 5 | Lo que da poder no se compra | Celestial, Núcleos Despertados y Seguro de carga nunca se venden. Ninguna recompensa aleatoria se paga con dinero real | [C] los tres primeros; [P] el resto (B6) |
| 6 | Nombres y mundo propios | No se usa «frutas» ni se copia nada de otros juegos | [C] |

---

## 2. Dirección de arte y VFX [P]

La dirección de arte del GDD original no se ha visto. Esta es la propuesta.

### 2.1 Estilo

- **Formas:** modelado estilizado de pocos polígonos, siluetas grandes y legibles en pantalla de móvil.
- **Luz:** la mina es oscura y los minerales brillan. La rareza se lee de lejos por el color y la intensidad del brillo (colores de B1).
- **Paleta por zona:** cada zona tiene dos colores dominantes y uno de acento.

| Zona | Nombre | Paleta | Ambiente |
|---|---|---|---|
| 1 | Cantera del Alba | Ocres y azul cielo | Cantera abierta, luz de amanecer |
| 2 | Galerías de Musgo | Verdes y turquesa | Túneles húmedos, hongos luminosos |
| 3 | Vetas Salinas | Blancos y rosa pálido | Cristales de sal, lagunas |
| 4 | Grutas de Brasa | Naranjas y gris carbón | Brasas, humo ligero |
| 5 | Sima Helada | Azules y blanco | Hielo, ventisca |
| 6 | Bóveda de Ecos | Violetas y cobre | Salas enormes, ondas visibles |
| 7 | Raíces de Obsidiana | Negro y magenta | Raíces de piedra negra |
| 8 | Mar de Magma | Rojo y amarillo | Lagos de lava |
| 9 | Catedral de Cristal | Arcoíris sobre blanco | Vidrieras naturales |
| 10 | Núcleo Astral | Azul noche y oro | Vacío estrellado |

- **Zonas Fracturadas:** la misma zona con la paleta virada a tonos fríos, grietas de luz violeta y niebla. Deben reconocerse al instante como peligrosas.
- **Accesibilidad:** la rareza lleva además un icono con puntas (1 a 8), y los avisos de ataque de los jefes combinan color, forma y sonido.

### 2.2 VFX

- **Regla de lectura:** primero se ve el aviso (dónde va a caer el golpe), después el impacto. Ningún efecto propio tapa un aviso enemigo.
- **Identidad por Núcleo:** Prismático, haces y destellos de colores; Brasa, chispas y estelas; Escarcha, esquirlas y vaho; Tormenta, arcos eléctricos; Sísmico, polvo y grietas; Umbrío, humo oscuro.
- **Rareza del objeto:** los objetos Legendario o superior tienen estela propia; el Celestial, un halo dorado.

### 2.3 Límites de rendimiento

| Límite | Valor |
|---|---|
| Objetivo de fotogramas | 30 por segundo en móvil de gama baja; 60 en PC y consola |
| Partículas por habilidad | Máximo 60, con 3 emisores y 2 luces dinámicas como mucho |
| Duración de un efecto | Máximo 2 s, salvo zonas persistentes (6 s) |
| Partículas por mascota | Máximo 10 |
| Tope en pantalla | 300 (calidad baja), 800 (media), 2.000 (alta) |

Peor caso calculado: jefe con 8 jugadores usando habilidades a la vez y 24 mascotas.

| Calidad | Qué se reduce | Uso en el peor caso | Tope |
|---|---|---|---|
| Baja | Efectos propios al 60%, ajenos al 10%, sin efectos de mascotas ajenas, jefe al 50% | 273 | 300 |
| Media | Ajenos al 40%, mascotas ajenas al 30% | 739 | 800 |
| Alta | Nada | 1.390 | 2.000 |

- Los avisos de ataque nunca se reducen: son información de juego, no decoración.
- El detalle técnico (niveles de calidad, streaming de la mina) va en `C_Tecnico.md`.

---

## 3. Core loops

### 3.1 Micro (15 segundos) [P]

1. Ver un depósito o un enemigo.
2. Picar o combatir: 6–7 s (B3, B4).
3. Recibir mineral, monedas y XP.
4. Moverse al siguiente.

Ritmo objetivo: unas 230–240 acciones por hora (B2, validado en B3 y B4).

### 3.2 Sesión (20–40 minutos) [P]

1. Entrar en la zona y revisar misiones diarias y contratos.
2. Llenar la mochila (unos 3,5 minutos por carga) y volver al banco.
3. Vender, fabricar o mejorar una pieza de equipo.
4. Derrotar al jefe de la zona (hasta 3 veces al día con botín completo).
5. Participar en el evento aleatorio si aparece.
6. Opcional: una o dos incursiones en la Zona Fracturada.

### 3.3 Largo plazo [P]

| Horizonte | Objetivo |
|---|---|
| Cada 6–57 horas | Zona nueva: minerales, enemigos, jefe y equipo nuevos |
| 13 a 68 horas | Maestría de un arma o Núcleo: 4 habilidades, Despertar y Transformación |
| 12 a 65 horas | Mascotas a nivel 50 (forma desatada) y 100 (forma máxima) |
| Unas 345 horas | Nivel 1.000 |
| Final de juego | Equipo Mítico y Ultra raro, Celestial, arenas, renacimiento |

### 3.4 Zonas Fracturadas [C] en lo esencial, [P] en los valores

1. **Entrar** (opcional). Escudo de 5 s; escudo de novato las 3 primeras veces.
2. **Cargar.** El mineral vale el doble si se extrae. Cuanta más carga, más lento vas y más visible eres.
3. **Decidir.** Extraer ya o seguir cargando.
4. **Extraer.** Llegar al Punto de Extracción activo y canalizar 8 s.
5. **O caer.** Si te mata otro jugador, sueltas el 50% de la carga **[P]**; nada más.

La tensión está en el paso 3: es la decisión que da nombre al juego.

---

## 4. Mecánicas

### 4.1 Progresión (B2)

- Niveles 1 a 1.000 con `XP = techo(100 + 20·L + 0,8·L²)`. Unas 345 horas hasta el máximo **[P]**.
- 3 puntos de estadística por nivel; máximo 1.000 por estadística, así que a nivel 1.000 solo se llevan 3 de 8 al máximo **[P]**.
- Reinicio de puntos gratis hasta el nivel 50; después cuesta 1,5 horas de ingreso **[P]**.

### 4.2 Estadísticas (B2)

Ocho estadísticas **[P]** (el prompt nombra siete; Energía es la octava propuesta): Fuerza, Vitalidad, Defensa, Velocidad, Energía, Minería, Suerte y Dominio de mascotas.

- Todas menos Defensa usan la misma curva con techo: mucho efecto al principio, menos después, nunca infinito.
- Defensa reduce el daño hasta un 75% en PvE y un 50% en PvP. Nunca hay inmunidad.
- La Energía limita habilidades, dash, parpadeo, esquiva y bloqueo: no se puede usar todo siempre.

### 4.3 Rarezas y suerte (B1)

- 8 rarezas: 7 estándar + Celestial **[C]**. Celestial solo en eventos y final de juego, y nunca en cajas estándar **[C]**.
- Nombres propuestos **[P]**: Común, Poco común, Raro, Épico, Legendario, Mítico, Ultra raro y Celestial.
- La Suerte mejora las probabilidades con un techo de ×4 y no afecta a Celestial, a las garantías ni al PvP.

### 4.4 Minería (B3)

- 10 zonas, una cada 100 niveles; 66 minerales; 75 picos.
- Cada depósito pide una Minería mínima según su rareza: el especialista pica todo, el equilibrado hasta Legendario y el combatiente hasta Raro.
- Depósitos compartidos (40 por zona, que suben hasta 80 si hay muchos mineros).
- Al morir en la mina PvE se pierde el 20% de la carga **[C]**, recuperable durante 120 s **[P]**. Por debajo del nivel 25 no se pierde nada **[P]**.

### 4.5 Combate (B4)

- Ataque básico + 4 habilidades (Z, X, C, V) + movilidad (dash, doble salto y parpadeo) **[C]**. Además, esquiva y bloqueo **[P]**.
- 6 tipos de arma **[P]**: Espada, Hacha, Daga, Lanza, Bastón y Arco. Los cinco primeros hacen un DPS casi igual; el Arco, menos a cambio de alcance.
- Reglas contra el combo infinito: el daño baja a partir del 5.º golpe seguido, el control repetido dura cada vez menos y nadie queda aturdido más de 2,0 s.

### 4.6 Núcleos de Poder (B4)

- Los poderes equipables se llaman **Núcleos de Poder** **[P]** (nombre provisional).
- Cada Núcleo tiene 4 habilidades y 1 pasiva. Se equipa uno a la vez.
- Seis de lanzamiento **[P]**: Prismático, de Brasa, de Escarcha, de Tormenta, Sísmico y Umbrío. El Prismático es el inicial.
- **Despertar** (maestría 75): +15% de daño y un efecto nuevo. **Transformación** (maestría 100): forma temporal de 20 s.
- Los Núcleos Despertados nunca se venden **[C]**.

### 4.7 Mascotas (B5)

- Fases: huevo → cría → forma desatada **[C]**, con un grado final (forma desatada máxima) **[P]**.
- 12 de lanzamiento, incluido el Guiverno de Cuarzo **[P]**. Cinco roles: Atacante, Tanque, Apoyo, Control y Recolector.
- Tres posturas: Atacar, Recolectar y Proteger **[P]**.
- Su daño conjunto no pasa del 40% del del jugador en PvE ni del 25% en PvP y Zonas Fracturadas **[C]**.
- 3 espacios iniciales **[C]**; hasta 6 **[P]**. Nunca se pierden.

### 4.8 Fabricación (B6)

- Cada pico y arma se fabrica con monedas y minerales de su zona. El precio se mide en horas de ingreso: de 0,3 (Común) a 20 (Ultra raro).
- Tres mejoras: nivel de objeto (+50%), ranuras (+30%) y Despertar de habilidad (+20%). Sumadas, nunca más de +100%.
- Deshacer un objeto devuelve el 30% de los materiales de sus mejoras.
- Celestial no se fabrica con minerales: 60 fragmentos Celestiales + 10 horas de ingreso.

---

## 5. Mundos y zonas [P]

### 5.1 Ciudad principal: Puerto Veta

Zona segura sin combate. Contiene: mercader, forja, banco, criadero (incubadoras y Nido), tablón de misiones y contratos, entrada a las arenas, tienda de cosméticos, altar de renacimiento y los portales a los 4 mundos.

### 5.2 Los 4 mundos

| Mundo | Zonas | Niveles | Horas de juego | Jefe final del mundo |
|---|---|---|---|---|
| 1 · Superficie Quebrada | 1 Cantera del Alba, 2 Galerías de Musgo, 3 Vetas Salinas | 1–300 | 40,7 | Leviatán de Salmuera |
| 2 · Hondonada de los Extremos | 4 Grutas de Brasa, 5 Sima Helada, 6 Bóveda de Ecos | 300–600 | 100,4 | Por diseñar |
| 3 · Abismo Negro | 7 Raíces de Obsidiana, 8 Mar de Magma | 600–800 | 93,1 | Por diseñar |
| 4 · Corazón Celeste | 9 Catedral de Cristal, 10 Núcleo Astral | 800–1.000 | 110,4 | Por diseñar |

- Cada mundo es un lugar de Roblox distinto; se cambia de mundo desde Puerto Veta.
- Cada zona tiene: área PvE, entrada con banco y mercader, sala de jefe y portal a su Zona Fracturada.
- El mundo 1 es el MVP. Los mundos 3 y 4 tienen solo 2 zonas porque cada zona dura más.

---

## 6. Enemigos, jefes y eventos

### 6.1 Enemigos (B4)

- Cuatro tipos **[P]**: Común (88% de los enemigos), Élite (10%), Guardián (2%) y Jefe (uno por zona).
- Aparecen solos, en parejas o en tríos. Su vida, daño, XP y monedas salen de fórmulas según la zona.
- Un jugador típico tarda 6–7 s por enemigo Común en cualquier zona.

### 6.2 Jefes (B4)

- Tres fases, ataques siempre avisados en el suelo y una ventana de vulnerabilidad de 6 s tras superar la mecánica.
- De 1 a 8 jugadores: unos 8 minutos en solitario y 5 con 8.
- Botín individual: monedas, 3 materiales de jefe garantizados y una tirada extra. Hasta 3 veces al día con botín completo.
- Jefes del MVP **[P]**: Capataz de Pizarra (zona 1), Madre Liquen (zona 2) y Leviatán de Salmuera (zona 3). Los otros 7 están por diseñar.

### 6.3 Eventos aleatorios [P]

Un evento cada 25–40 minutos por servidor; solo uno activo a la vez.

| Evento | Qué ocurre | Duración | Efecto medio en ingresos |
|---|---|---|---|
| Lluvia de meteoritos | Caen depósitos temporales de una rareza superior | 4 min | +6,4% |
| Veta colosal | Un depósito gigante que hay que picar entre varios; reparte por daño | 5 min | +4,5% |
| Oleada de la profundidad | Oleadas de enemigos con un Guardián final | 5 min | +5,8% |
| Grieta inestable | En la Zona Fracturada, dos Puntos de Extracción activos a la vez durante 3 minutos | 3 min | Sin monedas extra |
| Jefe de evento (semanal) | Jefe especial anunciado con antelación; da fragmentos Celestiales (B1) | 15 min | Sin monedas extra |

- Con rotación, el efecto medio conjunto es de un +5,6% de ingresos: suficiente para animar, sin desequilibrar la economía.
- Los eventos de fin de semana y de temporada usan la Caja de evento (B1, B6), la única que puede dar Celestial.

---

## 7. Cajas y animación de apertura

### 7.1 Cajas (B1 y B6)

| Caja | Cómo se consigue | Contenido | ¿Puede dar Celestial? |
|---|---|---|---|
| De armas | Monedas | Un arma de la zona, tipo y rareza al azar | No **[C]** |
| De zona | Monedas | Pico, minerales, materiales o consumibles de la zona | No **[C]** |
| De mascotas | Monedas | Un huevo de las 12 mascotas | No **[C]** |
| De evento | Fichas de evento (jugando) | Objetos de Raro a Celestial | Sí, 0,5% |

- Protección contra mala suerte **[P]**: Legendario o superior garantizado en 50 aperturas y Mítico o superior en 100, con contadores por tipo de caja.
- Las probabilidades y el contador de garantía se muestran siempre antes de abrir.

### 7.2 Animación de apertura: la Geoda [P]

Diseño visual propio; las cajas son geodas de roca.

1. El jugador coloca la geoda en el yunque y da 3 golpes de pico (o mantiene pulsado).
2. Con cada golpe se abren grietas por las que sale luz.
3. Al tercer golpe la geoda se parte y muestra el objeto, con el color y el icono de su rareza.

Reglas:

- **El servidor decide el premio antes de que empiece la animación** **[C]** y actualiza los contadores en ese momento. La animación solo lo enseña.
- El color de la luz es el de la rareza real desde la primera grieta. **No hay falsos «casi»:** nunca se insinúa una rareza mayor que la obtenida.
- Se puede saltar con un toque. Hay apertura de 10 seguidas con resumen final.
- Si el jugador se desconecta a media animación, el objeto ya está en su inventario.
- Duración: 2,5 s (1 s desde la tercera apertura seguida).

---

## 8. Economía resumida (detalle en B6)

- **Unidad de precio:** la hora de ingreso de la zona. Los precios suben solos con la zona.
- **Seis recursos:** monedas, minerales, Cristales, materiales de jefe, gemas antiguas y fragmentos Celestiales.
- **Entradas principales:** venta de mineral y enemigos. **Salidas principales:** fabricación y mejoras (el mayor sumidero), cajas (15% del ingreso) y consumibles (5%).
- **Equilibrio:** el jugador gasta entre el 58% y el 93% de lo que gana mientras sube. En la simulación de 1.000 jugadores y 90 días, el ahorro mediano se mantiene en 3,4–4,5 horas de ingreso: no hay inflación.
- **Sin reparaciones, sin durabilidad y sin comercio entre jugadores** en el lanzamiento.

Todo este apartado es **[P]** salvo los límites pedidos por el autor: ningún estilo PvE gana más de 1,3 veces que otro **[C]** (obtenido 1,02–1,06) y las Zonas Fracturadas no rinden más de 2,5 veces el PvE **[C]** (obtenido 1,59–2,16; máximo teórico 2,43).

---

## 9. PvE, arenas y Zonas Fracturadas

### 9.1 PvE

- Toda la mina principal es PvE **[C]**. No hay daño entre jugadores fuera de arenas y Zonas Fracturadas.
- Cooperación sin fricción: depósitos y jefes reparten por daño aportado y el botín de jefe es individual **[P]**.

### 9.2 Arenas [P] (B4)

- Modos 1 contra 1, 2 contra 2 y 3 contra 3, al mejor de 3 rondas de 90 s.
- Igualadas por tramos de 100 niveles: gana quien juega mejor, no quien lleva más equipo.
- Emparejamiento por puntuación. Solo se arriesga puntuación.
- Recompensas: títulos y cosméticos de temporada. Ninguna da poder.

### 9.3 Zonas Fracturadas (B3, B4 y B6)

| Regla | Valor | Estado |
|---|---|---|
| Una por cada zona de la mina, opcional, con PvP siempre activo | 10 en total | [C] |
| Qué se arriesga | Solo el mineral transportado | [C] |
| Carga que se suelta al morir contra un jugador | 50% (el 70% de eso va a un Cofre de Saqueo y el 30% se destruye) | [P] |
| Valor del mineral extraído | ×2,0, hasta ×2,2 con racha | [P] |
| Mochila | El doble que en PvE | [P] |
| Sincronización de nivel | Nivel máximo efectivo `100 × zona` | [P] |
| Escuadrones | Hasta 3 jugadores | [P] |
| Daño entre jugadores | ×0,06, con tope del 35% por golpe y del 60% en 2 s | [P] |

- **Protección de novato:** escudo de 120 s en las 3 primeras entradas y aviso claro de qué se arriesga.
- **Anti-acampada:** el Punto de Extracción rota cada 120 s; quien lo acampa queda marcado; matar a la misma víctima otra vez en 10 minutos no da botín.
- **El saqueador puro gana menos que un minero normal** (0,48 veces). Es intencionado: se recompensa con reputación y cosméticos, y así los mineros no desaparecen.

---

## 10. Retención

Todo este apartado es **[P]**.

### 10.1 Misiones diarias y semanales

| Tipo | Cantidad | Ejemplos | Recompensa |
|---|---|---|---|
| Diarias | 3 | Picar 50 depósitos, derrotar 1 jefe, fabricar o mejorar 1 objeto | Monedas (en total, un 10% extra sobre lo ganado ese día), Cristales y XP de pase |
| Semanales | 5 | Derrotar a los 3 jefes de tu mundo, subir 10 niveles, completar 5 extracciones | Tomo de Reajuste, gemas antiguas, Cristales y XP de pase |

- Hay misiones de minería, de combate y de mascotas: ningún estilo queda obligado al PvP.
- **Sin castigo por faltar:** no hay racha de conexión que se pierda. Las diarias no hechas no se acumulan, pero tampoco penalizan.

### 10.2 Temporadas

- Duración: 8 semanas. Pase de 50 niveles con vía gratuita y vía de pago.
- La vía de pago solo añade cosméticos y Cristales.
- La vía gratuita da 2 Fragmentos de temporada por nivel en los niveles 1 a 30 (60 en total), que desbloquean el sexto espacio de mascota.
- Jugando a diario se llega al nivel 36 de 50 y los 60 fragmentos salen en 6,6 semanas. Jugando 4 días por semana se consiguen 54 en la primera temporada y el resto en la siguiente. Los fragmentos no caducan.

### 10.3 Logros y códice

- **Logros:** hitos de progreso (zonas, jefes, maestrías, extracciones). Dan títulos, cosméticos y Cristales.
- **Códice:** registro de los 66 minerales, las 12 mascotas, los enemigos y los jefes descubiertos. Completar una página da un cosmético y una recompensa pequeña y única de Cristales. No da poder.

### 10.4 Renacimiento

Disponible en el altar de Puerto Veta al llegar al nivel 1.000. Máximo 10 renacimientos.

| Se conserva | Se pierde | Se gana por renacimiento |
|---|---|---|
| Mascotas, niveles y evoluciones | Nivel (vuelve a 1) | +5% de XP (hasta +50%) |
| Núcleos y todas las maestrías | Puntos de estadística asignados | +10 puntos de estadística permanentes (hasta +100) |
| Picos y armas (no equipables hasta tener su nivel) | Todas las monedas | Un título y un aura de renacido |
| Minerales del banco, materiales y fragmentos | Acceso a zonas (se reabren al subir) | Un marco de perfil por cada renacimiento |
| Cristales, cosméticos, códice y logros | | |
| Espacios de mascota, mochila e incubadoras | | |

- **Tiempo:** la primera subida son 344,6 horas; la segunda, 328,2; la undécima, 229,7.
- **Poder:** los +100 puntos son un 3,3% de los 3.000 normales y respetan el tope de 1.000 por estadística. Es una ventaja pequeña a propósito.
- **Sumidero:** perder las monedas al renacer es el sumidero de final de juego que pedía B6. Un jugador de zona 10 con 10 horas de ahorro deja unos 4 millones de monedas.
- Renacer es opcional y pide confirmación doble, con la lista de lo que se pierde.

### 10.5 Mejoras de riesgo y sus salvaguardas

Las «mejoras de retención del GDD» conocidas son el seguro de carga, la racha de extracción y los contratos de grieta (valores en B6). Cada una lleva su freno:

| Mejora | Qué aporta | Salvaguarda |
|---|---|---|
| Racha de extracción | Hasta +10% de valor por extraer seguido | Tope bajo; salir sin extraer no la rompe, así que no obliga a arriesgar |
| Seguro de carga | Devuelve parte de lo perdido | Solo con monedas, nunca con dinero real **[C]**; máximo 5 al día |
| Contratos de grieta | Objetivos diarios en Zonas Fracturadas | Nunca piden matar jugadores; recompensa pequeña (0,20 horas al día) |
| Zonas Fracturadas | Mineral al doble | Solo se arriesga la carga **[C]**; escudo de novato; aviso previo |
| Cajas | Sorpresa | Solo con monedas; probabilidades visibles; garantías; sin falsos «casi» |

Salvaguardas generales:

- Ningún sistema castiga por no conectarse.
- Ninguna oferta con cuenta atrás de menos de 24 horas.
- Aviso de descanso opcional a los 60 minutos de sesión.

---

## 11. Monetización justa (detalle en B6, sección 9)

| Se vende | No se vende nunca |
|---|---|
| Cosméticos (aspectos, estelas, efectos) | Celestial y sus fragmentos **[C]** |
| Pase de temporada (la vía de pago solo da cosméticos y Cristales) | Núcleos Despertados y sus materiales **[C]** |
| Almacén de mascotas, pestañas de banco, tercera incubadora | Seguro de carga **[C]** |
| Pergamino de XP (+25%) | Monedas, minerales, materiales de jefe, gemas antiguas |
| Sexto espacio de mascota (también se gana gratis) | Suerte, cajas o cualquier ventaja en PvP |

- **Regla general [P]:** se vende comodidad y aspecto; no se vende poder ni azar.
- **Recompensas aleatorias de pago:** en el lanzamiento no hay ninguna. Las cajas se compran solo con monedas, y las monedas no se pueden comprar.
- **Política de Roblox:** el servidor consulta `PolicyService` para cada jugador. La política se revisó solo a través de resúmenes del buscador (B6, sección 9.3); hay que releer las páginas oficiales antes de publicar.
- El sexto espacio de mascota es la única compra con efecto en el juego: +4,8% de monedas por hora en PvE y nada en PvP (B5).

---

## 12. Contenido del MVP [P]

| Elemento | Contenido |
|---|---|
| Mundo | Puerto Veta y el mundo 1 (Superficie Quebrada) |
| Zonas | 1, 2 y 3 (niveles 1 a 300) |
| Minerales | 19 (6 + 6 + 7) |
| Picos | 21 (3 zonas × 7 rarezas) |
| Armas | 63: Espada, Daga y Bastón × 3 zonas × 7 rarezas |
| Núcleo | Prismático, con sus 4 habilidades y pasiva (sin Despertar) |
| Mascotas | 6: Topillo de Pizarra, Luciérnaga de Veta, Zorro de Ascua, Tortuga Geoda, Murciélago de Eco y Nutria Salina; fases huevo y cría |
| Jefes | Capataz de Pizarra, Madre Liquen y Leviatán de Salmuera |
| Cajas | De armas, de zona y de mascotas, con protección contra mala suerte |
| Tienda | Mercader, forja con niveles de objeto, banco y consumibles básicos |
| Guardado | Datos persistentes con sesión bloqueada (detalle en `C_Tecnico.md`) |
| Arena | 1 arena de 1 contra 1 |
| Zona Fracturada | 1 de prueba, la de la zona 3 |

- **Duración:** 40,7 horas de subida de nivel.
- **Fuera del MVP:** mundos 2 a 4, los otros 5 Núcleos y 6 mascotas, Hacha, Lanza y Arco, Despertar y Transformación, forma desatada, Celestial, temporadas, renacimiento y eventos.
- El criterio para darlo por terminado y el plan de pruebas van en `D_Roadmap.md`.

---

## 13. Pendientes de diseño

| Pendiente | Dónde se resuelve |
|---|---|
| Contrastar todo con el prompt maestro y el GDD original cuando estén disponibles | Revisión general |
| Jefes de las zonas 4 a 10 y jefes de evento | Expansiones (D_Roadmap) |
| Mascota y objetos Celestiales concretos | Primer evento |
| Tanques dominantes en 3 contra 3 | Beta (B7, sección 5) |
| Combate frente a minería al llegar a una zona (1,34) | Beta (B7, P5) |
| Uso real de los Núcleos de Escarcha y Sísmico | Beta (B4, P5) |
| Confirmar el 50% de carga soltada y el nombre «Núcleos de Poder» | Decisión del autor |
