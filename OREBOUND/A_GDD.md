# OREBOUND — Documento A: Game Design Document

Etapa 8, rehecha con el GDD de combate, minería PvPvE y mascotas · 2026-11-16 · Cálculos de apoyo: `calculos/b8_gdd.py`.

> **Cómo leer este documento**
>
> - **[C]** = CONFIRMADO: decisión fija del autor.
> - **[G]** = viene del GDD de combate, minería PvPvE y mascotas (`00_Fuentes/`). El propio GDD marca sus cifras como pendientes de simulación, así que cuentan como provisionales.
> - **[P]** = PROVISIONAL: propuesta del equipo de diseño, pendiente de prueba.
> - Los números de detalle no se repiten aquí: cada sección remite a su archivo B. **Si un número de este documento difiere de un archivo B, manda el archivo B.**
>
> **Fuentes.** No se ha dispuesto del prompt maestro. Los 4 mundos, los eventos PvE, el
> renacimiento, las misiones y los nombres de zonas, minerales, mascotas y jefes (salvo los
> que cita el GDD) son propuestas **[P]**.

---

## 1. Concepto, público y pilares

### 1.1 Concepto

OREBOUND es un juego de rol de acción y minería para Roblox. El jugador baja por una mina de 10 zonas, pica minerales, pelea contra criaturas y jefes, fabrica picos y armas cada vez mejores, equipa Núcleos de Poder y cría mascotas que recolectan y combaten a su lado. Junto a cada zona hay una **Zona Fracturada** opcional: una grieta inestable donde el mineral vale más, pero otros jugadores pueden atacarte y llevarse parte de lo que cargas.

Tres capas, según el GDD **[G]**: combate de alta movilidad con Núcleos de Poder, minería de alto riesgo en Zonas Fracturadas opcionales y mascotas con evolución en tres fases. La mina principal sigue siendo PvE y segura; el PvP con saqueo solo existe donde el jugador decide entrar.

Frase de venta: *«Baja más hondo. Carga más. Decide cuándo salir.»*

### 1.2 Público objetivo [P]

| Aspecto | Definición |
|---|---|
| Edad principal | 10 a 16 años; el GDD recuerda que Roblox tiene muchos jugadores menores de edad |
| Plataformas | Móvil (prioritaria), PC y consola |
| Sesión típica | 20–40 minutos **[G]** |
| Tono | Aventura fantástica de estética anime, sin sangre ni contenido adulto |

### 1.3 Pilares de diseño

| # | Pilar | Qué significa en la práctica | Estado |
|---|---|---|---|
| 1 | La zona pesa más que la suerte | Un objeto Común supera a cualquier objeto de tres zonas atrás, por raro o mejorado que sea. Celestial nunca pone un objeto de zona baja por encima de uno Común de zona alta | [G] el principio; [P] los valores (B1) |
| 2 | El riesgo es opcional, entendible y acotado | La mina es PvE. En las Zonas Fracturadas solo se arriesga el mineral que llevas. Perder debe sentirse consecuencia de una decisión, no del azar | [C] y [G] |
| 3 | El combate premia moverse bien | La movilidad tiene sus propios botones y ningún control puede encadenarse sin fin | [G] |
| 4 | Varias formas de jugar valen parecido | Minero y combatiente ganan casi lo mismo (0,99–1,06 con equipo al día); ninguna build extrema supera 1,13 veces a la equilibrada | [P] (B6, B7) |
| 5 | Todo tiene techo | Cada estadística, bono y efecto tiene un tope | [P] (B1–B5) |
| 6 | Lo que da poder no se compra | Celestial, Núcleos Despertados y Seguro de carga nunca se venden. Sin presión de compra para recuperar pérdidas o no perder una racha | [C] y [G] |
| 7 | Nombres y mundo propios | No se usa «frutas» ni se copia contenido de otros juegos | [C] |

---

## 2. Dirección de arte y VFX [G]

### 2.1 Objetivo

Un anime de alta gama con colores saturados, construido con las herramientas que Roblox permite y escalado para móvil. Las referencias que cita el GDD son solo de tono: no se copian personajes, siluetas ni efectos concretos.

### 2.2 Pilares visuales

- **Color con significado.** Cada rareza y cada elemento tiene un color propio; el brillo más intenso se reserva para lo más raro.
- **Contraste de escala.** Minas oscuras y desaturadas para que minerales, habilidades y auras destaquen.
- **Impacto legible.** Todo golpe fuerte comunica quién lo dio y a quién, aunque haya diez jugadores en pantalla.

### 2.3 Paleta por rareza

| Rareza | Color | Tratamiento visual |
|---|---|---|
| Común | Gris | Sin aura; partículas de polvo |
| Poco común | Verde | Brillo suave en bordes |
| Raro | Azul | Destello al soltar el objeto |
| Épico | Morado | Aura pulsante y estela corta |
| Legendario | Dorado | Aura, estela y rayos de luz al aparecer |
| Mítico | Rojo | Todo lo anterior y vibración de cámara al obtenerlo |
| Ultra raro | Arcoíris | Ciclo de color y anuncio en el servidor |
| Celestial | Blanco perla con núcleo cian | Halo orbital, partículas que suben y anuncio global |

Accesibilidad **[P]**: cada rareza lleva además un icono con puntas (1 a 8).

### 2.4 Cómo lograr el aspecto en Roblox

Roblox no permite shaders propios; cada efecto se traduce a una herramienta nativa.

| Efecto pedido | Implementación propuesta |
|---|---|
| Explosiones volumétricas | Varias capas de `ParticleEmitter` (núcleo brillante, humo, chispas) con `LightEmission` alto |
| Estelas de luz con bloom | `Trail` y `Beam` + `BloomEffect` local de intensidad moderada |
| Aberración cromática en críticos | Simulada: tres imágenes de interfaz desplazadas en rojo, verde y azul durante 0,12 s + destello de `ColorCorrection` |
| Distorsión en definitivas | Pulso de campo de visión, desenfoque radial con `DepthOfField`, viñeta de interfaz y vibración de cámara |
| Auras de mascotas | `ParticleEmitter` adjunto + `Trail` al moverse; `Highlight` solo en formas desatadas |

### 2.5 Presupuesto de rendimiento

| Regla | Valor | Estado |
|---|---|---|
| Niveles de calidad | Tres (Bajo, Medio, Alto), elegidos según el dispositivo y cambiables en Ajustes | [G] |
| Efectos propios | Completos | [G] |
| Efectos de otros jugadores | Al 50% de partículas; apagados a más de 120 studs | [G] |
| Tope de partículas por cliente | 2.000 en Alto y 800 en Bajo; 1.400 en Medio | [G]; el de Medio es [P] |
| Accesibilidad | Distorsión, vibración y aberración desactivables | [G] |
| Medición | Con el MicroProfiler en un móvil de gama media | [G] |
| Por habilidad | 60 partículas, 3 emisores y 2 luces dinámicas; 10 por mascota | [P] |

Peor caso calculado (jefe con 8 jugadores y 24 mascotas): 865 partículas con los efectos ajenos al 50%. Cabe en Alto y en Medio, pero **no en Bajo** (tope 800). Propuesta **[P]**: en Bajo, efectos ajenos al 40% (760). Los avisos de ataque nunca se reducen.

---

## 3. Core loops [G]

El juego funciona en tres escalas de tiempo, y el loop de las Zonas Fracturadas se conecta con las tres.

### 3.1 Micro (segundos): golpear, esquivar, recoger

1. Picar un depósito o atacar a un enemigo.
2. Leer el aviso del rival y esquivar, bloquear o romper el combo.
3. Lanzar una habilidad en la ventana correcta.
4. Ver el impacto y a la mascota reaccionar.

Ritmo **[P]**: 6–7 s por depósito o enemigo; unas 230–250 acciones por hora (B3, B4).

### 3.2 Meso (sesión de 20 a 40 minutos): la expedición

1. Preparar el equipo en la ciudad: pico, Núcleo de Poder, mascotas y consumibles.
2. Bajar a la zona de la mina que toca por nivel.
3. Minar y combatir hasta llenar el inventario.
4. Decidir: volver seguro o entrar en una Zona Fracturada para multiplicar el valor.
5. Vender, fabricar o mejorar, y repetir.

### 3.3 Macro (semanas y meses): crecer

1. Subir de nivel y repartir puntos.
2. Desbloquear zonas más profundas.
3. Despertar Núcleos de Poder y evolucionar mascotas a su forma desatada.
4. Escalar en la temporada de Zonas Fracturadas y en las arenas.
5. Completar colecciones: minerales, mascotas, Núcleos y objetos Celestiales.

### 3.4 Loop de la Zona Fracturada (5 a 15 minutos)

La carga solo está a salvo cuando llega al banco.

1. **Entrar al portal**, con aviso de PvP activo.
2. **Minar depósitos:** la carga y la lentitud suben.
3. **¿Extraer?** Si no, seguir minando con más carga.
4. **Punto de Extracción:** canalizar 8 s sin recibir daño → la carga va al banco, protegida para siempre.
5. **O perder una pelea:** el derrotado suelta el 50% **[P]** en un cofre; el ganador lo recoge y ahora es él quien carga el riesgo.

Cada carrera termina en el banco o en un cofre para otro jugador.

---

## 4. Mecánicas

### 4.1 Progresión (B2)

- Niveles 1 a 1.000 con `XP = techo(100 + 20·L + 0,8·L²)`. Unas 345 horas hasta el máximo **[P]**.
- 3 puntos de estadística por nivel; máximo 1.000 por estadística, así que a nivel 1.000 solo se llevan 3 de 8 al máximo **[P]**.
- Reinicio de puntos gratis hasta el nivel 50; después cuesta 1,5 horas de ingreso **[P]**.

### 4.2 Estadísticas (B2) [P]

Ocho: Fuerza, Vitalidad, Defensa, Velocidad, Energía, Minería, Suerte y Dominio de mascotas. El prompt de trabajo nombra siete; Energía es la octava propuesta. El GDD menciona «Agilidad» como requisito del parpadeo: puede ser el nombre original de Velocidad.

- Todas menos Defensa usan la misma curva con techo.
- Defensa reduce el daño hasta un 75% en PvE y un 50% en PvP. Nunca hay inmunidad.
- La Energía paga habilidades, dash, parpadeo, bloqueo y Ruptura.

### 4.3 Rarezas y suerte (B1)

- 8 rarezas: 7 estándar + Celestial **[C]**. Celestial solo en eventos y final de juego, y nunca en cajas estándar **[C]**.
- Multiplicadores **[G]**: de ×1,00 (Común) a ×4,50 (Ultra raro) y ×5,20 (Celestial).
- La potencia crece ×2,00 por zona y los bonos de mejora no pasan de +50% **[P]**: con eso, ningún objeto aguanta más de 3 zonas.
- La Suerte mejora las probabilidades con un techo de ×4 y no afecta a Celestial, a las garantías ni a las Zonas Fracturadas **[P]**.

### 4.4 Minería (B3)

- 10 zonas, una cada 100 niveles; 66 minerales; 75 picos **[P]**. La zona 7 se llama Minas Oscuras **[G]**.
- Cada depósito pide una Minería mínima según su rareza **[P]**.
- **Picos encantados [G]:** cada pico tiene pasivas de recolección (1 menor, 1 mayor, ambas o 1 única según su rareza) y, desde Épico, una estadística de combate pequeña con tope propio en PvP para que el pico no sustituya al arma. Ejemplos del GDD: Eco del filo, Lastre ligero y Sonar rúnico.
- Al morir en la mina PvE se pierde el 20% de la carga **[C]**.

### 4.5 Combate (B4)

- Tiempo real: ataque básico (combo de 4 golpes) + 4 ranuras (Z, X, C, V) + movilidad **[C]**.
- **Las cuatro ranuras se configuran mezclando habilidades del arma y del Núcleo equipado [G].** Cada arma aporta 2 técnicas **[P]**.
- 6 tipos de arma **[P]**: Espada, Hacha, Daga, Lanza, Bastón y Arco.
- **Movilidad [G]:** doble salto sin coste; dash aéreo o terrestre con 2 cargas (20 de energía, 3 s de recarga cada una); parpadeo de 12 studs (30 de energía, 8 s, no atraviesa paredes).
- **Anti-combo infinito [G]:** el segundo control en 6 s dura la mitad y el tercero da inmunidad (Tenacidad); nadie está aturdido más de 2,5 s seguidos; la Ruptura permite liberarse y empujar gastando 50 de energía tras 0,8 s bajo control (15 s de enfriamiento); el dash cancela la recuperación de los ataques básicos, pero no la de las habilidades.
- La Tenacidad dura 5 s en lugar de los 2 s del GDD **[P]**: con 2 s un jugador podía pasar el 53% del tiempo bajo control.

### 4.6 Núcleos de Poder (B4)

Nombre provisional **[P]**. Son artefactos cristalizados que se extraen como reliquias de las profundidades de la mina, lo que conecta el combate con la minería **[G]**.

- Cada Núcleo trae 4 habilidades (área, control, movilidad y definitiva) y 1 pasiva **[G]**.
- Se consiguen en jefes, cajas de Núcleos, eventos y como reliquias raras en depósitos profundos **[G]**.
- Solo se equipa uno a la vez; cambiarlo fuera de la ciudad cuesta un consumible **[G]**.
- La maestría sube al usarlo **[G]**. Más allá de 100, niveles cosméticos que cambian el color de sus efectos **[G]**.
- **Despertar [G]:** con maestría 100 y materiales de jefe. Sus habilidades mejoran y se desbloquea la Transformación.
- **Transformación [G]:** dura 20 s, tiene 120 s de enfriamiento y se carga con una barra de Resonancia al hacer y recibir daño. Cambia el modelo, el marco de la interfaz y los iconos. Su bono llega al 25% en PvE y se limita al 10% en PvP.
- Seis de lanzamiento: **Prismático [G]** y los de Brasa, Escarcha, Tormenta, Sísmico y Umbrío **[P]**.
- Los Núcleos Despertados nunca se venden **[C]**.

### 4.7 Mascotas (B5)

- **Función dual [G]:** recolectan (recogen el mineral suelto en 20 studs, incluidos los Cofres de Saqueo) y apoyan en combate.
- **Dos posturas [G]:** Recolectar (+50% de radio, −50% de daño) y Proteger (lo contrario); 5 s para cambiar.
- **Fases [C]:** huevo → cría → forma desatada, con la forma desatada máxima como refinamiento **[G]**.

| Fase | Cómo se alcanza | Desbloquea |
|---|---|---|
| Huevo | Cajas, jefes o exploración; se incuba minando | Nada |
| Cría | Al eclosionar; niveles 1 a 49 | Pasiva de recolección |
| Forma desatada | Nivel 50 + materiales de su elemento | Habilidad activa de combate |
| Forma desatada máxima | Nivel 100 + material de jefe | Ataque coordinado con el dueño |

- Cinco roles **[G]**: Defensa, Ofensiva, Control, Apoyo y Minería.
- 12 de lanzamiento: el Guiverno de Cuarzo **[G]** y 11 propuestas **[P]**.
- Su daño conjunto no pasa del 40% del del jugador en PvE ni del 25% en PvP y Zonas Fracturadas **[C]**. El tope solo cuenta el daño: escudo, control y minería siguen siendo útiles.
- 3 espacios iniciales **[C]**; hasta 6 **[P]**. Nunca se pierden.

### 4.8 Fabricación (B6) [P]

- Cada pico y arma se fabrica con monedas y minerales de su zona; de 0,3 horas de ingreso (Común) a 20 (Ultra raro).
- Tres mejoras: nivel de objeto (+25%), ranuras (+15%) y Despertar de habilidad (+10%).
- Celestial: 50 fragmentos **[G]** + 10 horas de ingreso.
- El Seguro de carga se fabrica con minerales **[G]**.

---

## 5. Mundos y zonas [P]

### 5.1 Ciudad principal: Puerto Veta

Zona segura sin combate: mercader, forja, banco, criadero, tablón de misiones y contratos, entrada a las arenas, tienda de cosméticos, altar de renacimiento y portales a los 4 mundos. Es donde se prepara la expedición y donde cambiar de Núcleo es gratis.

### 5.2 Los 4 mundos

| Mundo | Zonas | Niveles | Horas de juego | Jefe final del mundo |
|---|---|---|---|---|
| 1 · Superficie Quebrada | 1 Cantera del Alba, 2 Galerías de Musgo, 3 Vetas Salinas | 1–300 | 40,7 | Leviatán de Salmuera |
| 2 · Hondonada de los Extremos | 4 Grutas de Brasa, 5 Sima Helada, 6 Bóveda de Ecos | 300–600 | 100,4 | Por diseñar |
| 3 · Abismo Negro | 7 Minas Oscuras, 8 Mar de Magma | 600–800 | 93,1 | Por diseñar |
| 4 · Corazón Celeste | 9 Catedral de Cristal, 10 Núcleo Astral | 800–1.000 | 110,4 | Por diseñar |

- Cada mundo es un lugar de Roblox distinto. Cada zona tiene área PvE, entrada con banco y mercader, sala de jefe y portal a su Zona Fracturada.
- El mundo 1 es el MVP.

---

## 6. Enemigos, jefes y eventos

### 6.1 Enemigos (B4) [P]

- Cuatro tipos: Común (88%), Élite (10%), Guardián (2%) y Jefe (uno por zona). Aparecen solos, en parejas o en tríos.
- Un jugador típico tarda 6–7 s por enemigo Común en cualquier zona.

### 6.2 Jefes (B4) [P]

- Tres fases, ataques siempre avisados en el suelo y una ventana de vulnerabilidad de 6 s tras superar la mecánica.
- De 1 a 8 jugadores: unos 8 minutos en solitario y 5 con 8.
- Botín individual: monedas, 3 materiales de jefe garantizados y una probabilidad pequeña de su Núcleo. Hasta 3 veces al día con botín completo.
- Jefes del MVP: Capataz de Pizarra, Madre Liquen y Leviatán de Salmuera.

### 6.3 Eventos

| Evento | Qué ocurre | Estado |
|---|---|---|
| Grieta Celestial | Cada 2 horas aparece una zona temporal con fragmentos Celestiales y PvP más intenso, anunciada 5 minutos antes | [G] |
| Jefes de grieta | Aparecen cuando muchos jugadores luchan en la misma Zona Fracturada, y obligan a elegir entre seguir peleando o aliarse un momento | [G] |
| Jefe de evento | Jefe PvE especial; da fragmentos Celestiales sin entrar en la grieta | [G] la ruta PvE; [P] los valores |
| Lluvia de meteoritos | Depósitos temporales de una rareza superior durante 4 minutos | [P] |
| Veta colosal | Un depósito gigante que hay que picar entre varios | [P] |
| Oleada de la profundidad | Oleadas de enemigos con un Guardián final | [P] |

Los tres eventos PvE propuestos rotan cada 25–40 minutos y suman de media un 5,6% de ingresos.

---

## 7. Cajas y animación de apertura

### 7.1 Cajas (B1 y B6)

| Caja | Cómo se consigue | Contenido | ¿Puede dar Celestial? |
|---|---|---|---|
| De armas | Monedas | Un arma de la zona, tipo y rareza al azar | No **[C]** |
| De zona | Monedas | Pico, minerales, materiales o consumibles de la zona | No **[C]** |
| De mascotas | Monedas | Un huevo de las 12 mascotas | No **[C]** |
| De Núcleos **[G]** | Monedas | Uno de los 6 Núcleos | No **[C]** |
| De evento | Fichas de evento | Objetos de Raro a Celestial | Sí, 0,5% |

- Protección contra mala suerte **[P]**: Legendario o superior garantizado en 50 aperturas y Mítico o superior en 100, con contadores por tipo de caja.
- Las probabilidades exactas se muestran antes de abrir **[G]**.

### 7.2 Animación de apertura: la Geoda [P]

1. El jugador coloca la geoda en el yunque y da 3 golpes de pico.
2. Con cada golpe se abren grietas por las que sale luz del color de la rareza.
3. Al tercer golpe la geoda se parte y muestra el objeto con el tratamiento visual de su rareza (sección 2.3).

Reglas:

- **El servidor decide el premio antes de que empiece la animación** **[C]**.
- El color de la luz es el de la rareza real desde la primera grieta: **no hay falsos «casi»**.
- Se puede saltar. Hay apertura de 10 seguidas. Duración: 2,5 s.
- Los objetos Ultra raro y Celestial se anuncian en el servidor y de forma global **[G]**.

---

## 8. Economía resumida (detalle en B6) [P]

- **Unidad de precio:** la hora de ingreso de la zona. Los precios suben solos con la zona.
- **Siete recursos:** monedas, minerales, Cristales, materiales de jefe, fragmentos elementales, gemas antiguas y fragmentos Celestiales.
- **Salidas principales:** fabricación y mejoras, cajas (15% del ingreso) y consumibles (5%). En cada muerte PvP se destruye el 20% de lo soltado **[G]**.
- **Equilibrio:** el jugador gasta entre el 52% y el 92% de lo que gana mientras sube. En la simulación de 1.000 jugadores y 90 días, el ahorro mediano se mantiene en 3,5–4,7 horas de ingreso.
- Sin reparaciones, sin durabilidad y sin comercio entre jugadores en el lanzamiento.

Límites pedidos por el autor: ningún estilo PvE gana más de 1,3 veces que otro **[C]** (obtenido 0,99–1,06) y las Zonas Fracturadas no rinden más de 2,5 veces el PvE **[C]** (obtenido 1,34–2,02; máximo teórico 2,48).

---

## 9. PvE, arenas y Zonas Fracturadas

### 9.1 PvE

- Toda la mina principal es PvE **[C]**. Depósitos y jefes reparten por daño aportado y el botín de jefe es individual **[P]**.

### 9.2 Arenas (B4) [P]

- 1 contra 1, 2 contra 2 y 3 contra 3, al mejor de 3 rondas de 90 s, igualadas por tramos de 100 niveles.
- Solo se arriesga puntuación. Recompensas cosméticas.

### 9.3 Zonas Fracturadas (B3, B4 y B6)

| Regla | Valor | Estado |
|---|---|---|
| Una grieta por cada zona, voluntaria, con PvP siempre activo | 10 en total | [C] |
| Qué se arriesga | Solo el mineral transportado | [C] |
| Acceso | Mismos requisitos que la zona PvE; confirmación y borde rojo en la interfaz | [G] |
| Protección | 10 s al entrar y al reaparecer mientras no ataques | [G] |
| Debuff de carga | `Carga = valor / (20 × valor de zona)`; ralentización de `0,12 × ln(1 + Carga)` con tope del 40%; dash y parpadeo no se ralentizan | [G] |
| Avisos de carga | Carga 5: partículas visibles; 10: minimapa de todos; 30: anuncio en la zona | [G] |
| Carga que se suelta al ser derrotado por un jugador | 50% | [P] |
| Reparto del cofre | 80% recogible y 20% destruido | [G] |
| Extracción | 8 s de canalización; el daño la reinicia; los puntos cambian de sitio cada 10 minutos | [G] |
| Valor del mineral extraído | ×1,5, por la racha | [P] |
| Racha de extracción | ×1,1, ×1,2… hasta ×1,5; morir la reinicia | [G] |
| Sincronización de nivel | Nivel máximo efectivo `100 × zona` | [P] |
| Daño entre jugadores | ×0,062, con tope del 35% por golpe y del 60% en 2 s | [P] |

- El multiplicador base es ×1,5 y no ×2,0 porque, con la racha del GDD, el máximo teórico se iría a 3,17 veces el PvE.
- **El saqueador puro gana menos que un minero normal** (0,47 veces): el riesgo que señalaba el GDD («cazar portadores puede rendir más que minar») no se cumple con estos valores.

---

## 10. Retención

### 10.1 Para que el riesgo sea emocionante [G]

El riesgo engancha cuando el jugador lo elige, entiende lo que se juega y siente que perder fue culpa de una decisión.

| Propuesta | Cómo funciona | Valores (B6) |
|---|---|---|
| Racha de extracción | Cada extracción seguida sin morir sube un multiplicador de valor | Hasta ×1,5 |
| Contratos de grieta | Encargos diarios: extraer 3 minerales de una rareza, o derrotar a 2 portadores con carga alta | 3 al día; el de derrotar se puede cambiar **[P]** |
| Recompensa por cabeza | Un jugador con racha de 5 o más queda marcado; quien lo derrote gana un bono | Recoge el 100% de lo soltado **[P]** |
| Grieta Celestial | Evento cada 2 horas, anunciado 5 minutos antes | 10 minutos; fragmentos ×4 **[P]** |
| Seguro de carga | Consumible fabricable con minerales que protege el 50% de una carga; nunca con Robux | Receta de minerales de la zona **[P]** |
| Escuadrones | Grupos de hasta 3 con carga compartida y extracción más rápida | 6 s con 2 y 5 s con 3 **[P]** |
| Rastro de venganza | Quien te derrotó queda marcado para ti 3 minutos | — |

### 10.2 Para retener a largo plazo [G]

- **Temporadas de grieta** de 8 semanas, con clasificación por valor extraído, premios cosméticos (auras, estelas, marcos) y reinicio de clasificación, no de progreso.
- **Códice de colección** de minerales, Núcleos y mascotas, con recompensas por completar cada página.
- **Maestría de Núcleos más allá de 100**, con niveles cosméticos.
- **Jefes de grieta.**

### 10.3 Añadidos propuestos [P]

| Sistema | Resumen |
|---|---|
| Misiones diarias y semanales | 3 diarias (un 10% extra de monedas en total) y 5 semanales; de minería, combate y mascotas; sin castigo por faltar |
| Pase de temporada | 50 niveles; la vía de pago solo da cosméticos y Cristales; la gratuita da los 60 Fragmentos de temporada del sexto espacio de mascota en 6,6 semanas |
| Logros | Títulos, cosméticos y Cristales |
| Renacimiento | A nivel 1.000, hasta 10 veces: +5% de XP y +10 puntos de estadística por vuelta; se pierden nivel, puntos asignados y todas las monedas; se conserva lo demás |

Renacimiento: la primera subida son 344,6 horas y la undécima 229,7. Los 100 puntos finales son un 3,3% de los normales. Un jugador de zona 10 con 10 horas de ahorro deja unos 24 millones de monedas al renacer: es el sumidero de final de juego.

### 10.4 Salvaguardas para que el riesgo sea justo [G]

- **Protección de novato:** las 5 primeras entradas a una Zona Fracturada no sueltan carga al morir; se avisa cuando termina.
- **Carga mínima protegida:** por debajo de Carga 1 no se suelta nada.
- **Anti-acampada:** 10 s de protección al entrar y al reaparecer; los Puntos de Extracción cambian de sitio cada 10 minutos.
- **Rangos de nivel:** requisitos de acceso, reforzados con la sincronización de nivel **[P]** (los requisitos por sí solos son mínimos).
- **Transparencia:** la interfaz muestra siempre la carga, el debuff y cuánto perderías si murieses ahora.
- **Sin presión de pago:** ninguna mecánica empuja a pagar para recuperar pérdidas o para no perder una racha.

---

## 11. Monetización justa (detalle en B6, sección 9)

| Se vende | No se vende nunca |
|---|---|
| Cosméticos (aspectos, estelas, auras) | Celestial y sus fragmentos **[C]** |
| Pase de temporada | Núcleos Despertados y sus materiales **[C]** |
| Almacén de mascotas, pestañas de banco, tercera incubadora | Seguro de carga **[C]** |
| Pergamino de XP | Monedas, minerales, materiales de jefe, gemas antiguas |
| Sexto espacio de mascota (también se gana gratis) | Suerte, cajas o cualquier ventaja en PvP |

- En el lanzamiento no hay recompensas aleatorias de pago: las cajas se compran solo con monedas.
- Si llegara a haber cajas de pago **[G]**: mostrar las probabilidades exactas antes de abrir y consultar `PolicyService` (`ArePaidRandomItemsRestricted`) para ocultarlas a quien no pueda usarlas.
- Antes de lanzar hay que revisar la política vigente de Roblox **[G]**; en este trabajo solo se pudo consultar a través de resúmenes del buscador (B6, sección 9.3).
- El sexto espacio de mascota añade un 2,4% de monedas por hora en PvE y nada en PvP (B5).

---

## 12. Contenido del MVP [P]

| Elemento | Contenido |
|---|---|
| Mundo | Puerto Veta y el mundo 1 (Superficie Quebrada) |
| Zonas | 1, 2 y 3 (niveles 1 a 300) |
| Minerales | 19 (6 + 6 + 7) |
| Picos | 21 (3 zonas × 7 rarezas), con pasivas menores y mayores |
| Armas | 63: Espada, Daga y Bastón × 3 zonas × 7 rarezas, con sus 2 técnicas |
| Núcleo | Prismático, con sus 4 habilidades y pasiva (sin Despertar) |
| Mascotas | 6 de las propuestas, más el Guiverno de Cuarzo como recompensa de jefe; fases huevo y cría |
| Jefes | Capataz de Pizarra, Madre Liquen y Leviatán de Salmuera |
| Cajas | De armas, de zona y de mascotas |
| Tienda | Mercader, forja con niveles de objeto, banco y consumibles básicos |
| Guardado | Datos persistentes con sesión bloqueada |
| Arena | 1 arena de 1 contra 1 |
| Zona Fracturada | 1 de prueba, la de la zona 3, con debuff de carga, extracción, saqueo, racha y protección de novato |

- **Duración:** 40,7 horas de subida de nivel.
- El GDD pide como siguientes pasos prototipar el debuff de carga y la extracción, y construir un solo Núcleo (el Prismático) y una mascota (el Guiverno) para validar la sinergia y el tope de DPS: por eso ambos entran en el MVP.
- **Fuera del MVP:** mundos 2 a 4, los otros 5 Núcleos, Hacha, Lanza y Arco, Despertar y Transformación, forma desatada, Celestial, Grieta Celestial, temporadas, renacimiento y eventos.

---

## 13. Pendientes de diseño

| Pendiente | Dónde se resuelve |
|---|---|
| Contrastar todo con el prompt maestro cuando esté disponible | Revisión general |
| Confirmar el 50% de carga soltada y el nombre «Núcleos de Poder» | Decisión del autor |
| Confirmar las seis correcciones a valores del GDD (crecimiento ×2,00, base ×1,5, fragmentos al 0,25%, Tenacidad de 5 s, sincronización de nivel, efectos ajenos al 40% en Bajo) | Decisión del autor |
| Jefes de las zonas 4 a 10, jefes de evento y jefes de grieta | Expansiones (D_Roadmap) |
| Escuadrones de Tanques dominantes en 3 contra 3 | Beta (B7) |
| Minería frente a combate al llegar a una zona con el arma anterior (1,39) | Beta (B7, P5) |
| Combinaciones de técnicas de arma en las ranuras | Beta (B4, P3) |
