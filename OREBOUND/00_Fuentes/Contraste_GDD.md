# OREBOUND — Contraste del diseño con el GDD de combate, minería PvPvE y mascotas

2026-11-16 · Fuente: `00_Fuentes/GDD_combate_mineria_mascotas.pdf` (14 páginas, recibido tras la Etapa 10) · Cálculos: `calculos/b0_contraste_gdd.py`.

> **Qué es este documento.** Es la parte de la Etapa 0 que no se pudo hacer al principio: comparar
> el diseño con una de sus dos fuentes. Las etapas 1 a 10 se hicieron sin el GDD, así que muchos
> valores eran propuestas. Aquí se lista dónde coinciden, dónde manda el GDD y qué hay que rehacer.
>
> **Sigue faltando el prompt maestro.** El GDD lo llama «OREBOUND» a secas y remite a él para
> las 7 rarezas, las reglas PvE y la maestría de armas. Lo que dependa solo del prompt maestro
> (30 minerales, 8 mascotas de referencia, nombres de zonas, fórmulas iniciales de estadísticas,
> secciones 20, 21 y 23) sigue sin contrastar.
>
> **Estado de las cifras del GDD.** El propio GDD dice que todas sus cifras son provisionales y
> están «pendientes de simulación». Por eso este documento no se limita a copiarlas: las simula y,
> donde dan problemas, propone una alternativa con números.

---

## 1. Resumen

| Resultado | Cantidad | Qué significa |
|---|---|---|
| Coincide | 24 puntos | El diseño ya decía lo mismo |
| Manda el GDD | 68 puntos | El diseño propuso otra cosa; hay que cambiarlo |
| El GDD da un problema al simularlo | 6 puntos | Se propone una alternativa con números |
| El diseño añade algo que el GDD no trata | 9 puntos | Se mantiene, marcado como añadido |

**Consecuencia:** hay que rehacer las etapas 1, 3, 4, 5, 6 y 7 con los valores del GDD y después actualizar el GDD final (A), la especificación técnica (C) y el roadmap (D). La Etapa 2 solo necesita retoques. El plan está en la sección 7.

---

## 2. Coincidencias

| Tema | GDD | Diseño |
|---|---|---|
| Mina principal PvE; Zonas Fracturadas voluntarias con PvP siempre activo, una por zona | Sí | Igual |
| Solo se arriesga el mineral transportado | Sí | Igual |
| Nombres de las 7 rarezas | Común, Poco común, Raro, Épico, Legendario, Mítico, Ultra raro | **Iguales** (se habían propuesto sin verlos) |
| Celestial como octava, fuera de las cajas estándar, con tabla propia | Sí | Igual |
| Colores de Común a Mítico | Gris, verde, azul, morado, dorado, rojo | Iguales |
| Combate: básico + Z, X, C, V + movilidad; combo básico de 4 golpes | Sí | Igual |
| Doble salto sin coste; dash de 20 de energía; parpadeo de 30 de energía y 8 s; no atraviesa paredes | Sí | Igual |
| Núcleos: 4 habilidades + 1 pasiva; uno equipado a la vez; maestría por uso | Sí | Igual |
| Transformación: 20 s de duración y 120 s de enfriamiento; bono reducido en PvP | Sí | Igual |
| Maestría de Núcleos más allá de 100 solo cosmética | Sí | Igual |
| Servidor autoritativo: el cliente pide, el servidor valida | Sí | Igual |
| Tope de DPS de mascotas: 40% en PvE y 25% en PvP y Zonas Fracturadas; solo cuenta el daño | Sí | Igual |
| La forma desatada máxima es un refinamiento, no una cuarta fase | Sí | Igual |
| Forma desatada a nivel 50 y máxima a nivel 100 | Sí | Igual |
| Guiverno de Cuarzo es Legendario | Sí | Igual |
| Las mascotas recogen mineral y Cofres de Saqueo | Sí | Igual |
| Se suelta el 50% de la carga al morir contra un jugador | Sí (provisional) | Igual |
| Morir contra enemigos o entorno: 20% de la carga | Sí | Igual |
| Extracción con 8 s de canalización, interrumpida por el daño | Sí | Igual |
| Se puede salir sin extraer por la entrada, perdiendo el bono | Sí | Igual |
| El bono de grieta no debe superar 2,5 veces el PvE contando muertes | Sí | Igual |
| Celestial se fabrica al nivel de zona | Sí | Igual (anclaje de zona) |
| Escuadrones de hasta 3; temporadas de 8 semanas; códice | Sí | Igual |
| Nunca se venden Celestial, Núcleos Despertados ni el Seguro de carga; `PolicyService` | Sí | Igual |

---

## 3. Donde manda el GDD

### 3.1 Rarezas y arte (rehacer Etapa 1; actualizar A)

| Tema | GDD | Diseño actual |
|---|---|---|
| Multiplicador de rareza | 1,00 a 1,50 (Común a Raro); 1,90 a 2,50 (Épico y Legendario); 3,30 a 4,50 (Mítico y Ultra raro); 5,20 (Celestial) | 1,00 / 1,15 / 1,32 / 1,52 / 1,75 / 1,98 / 2,20 / 2,60 |
| Color de Ultra raro | Arcoíris, con ciclo de color | Turquesa prismático |
| Color de Celestial | Blanco perla con núcleo cian | Blanco estelar con halo dorado |
| Tratamiento visual por rareza | Del polvo (Común) al halo orbital con anuncio global (Celestial); anuncio en el servidor desde Ultra raro | Solo estela desde Legendario |
| Estilo de arte | Anime de alta gama, colores saturados; minas oscuras y desaturadas | Estilizado de pocos polígonos |
| Cómo lograr cada efecto en Roblox | Tabla de 5 efectos con su herramienta nativa | No definido |
| Opciones de accesibilidad | Distorsión, vibración y aberración desactivables | No definido |
| Partículas | 2.000 en Alto y 800 en Bajo; efectos ajenos al 50% y apagados a más de 120 studs | 2.000 / 800 / 300; ajenos al 10–100% |
| Fragmentos por objeto Celestial | 50 | 60 |
| Fuentes de fragmentos | Depósitos de Zonas Fracturadas de zona 6 o más y jefes de evento | Extracciones (no depósitos) y jefes de evento |

El GDD da los multiplicadores por pares; se toma 1,00 / 1,25 / 1,50 / 1,90 / 2,50 / 3,30 / 4,50 / 5,20. El 1,25 de Poco común es un supuesto.

### 3.2 Minería y Zonas Fracturadas (rehacer Etapa 3)

| Tema | GDD | Diseño actual |
|---|---|---|
| Debuff de carga | `Carga = valor transportado / (20 × valor base de la zona)`; `Ralentización = mín(0,40; 0,12 × ln(1 + Carga))` | `0,30 × (carga/capacidad)^1,5` |
| Dash y parpadeo con carga | No se ralentizan; cuestan 25% más de energía con Carga 10 o más | Dash +50% de coste; parpadeo más corto |
| Avisos por carga | Carga 5: partículas a 60 studs; 10: minimapa de todos; 30: anuncio en la zona | Minimapa desde el 75% de la mochila |
| Reparto del cofre | 80% recogible y 20% destruido | 70% y 30% |
| Protección al entrar | 10 s mientras no ataques; también al reaparecer | 5 s |
| Protección de novato | Las 5 primeras entradas no sueltan carga al morir | Escudo de 120 s en las 3 primeras |
| Carga mínima protegida | Por debajo de Carga 1 no se suelta nada | Por debajo del 10% de la mochila |
| Puntos de Extracción | Cambian de sitio cada 10 minutos | Rotan cada 2 minutos |
| Picos: pasivas | 1 menor (Común a Raro); 1 mayor (Épico y Legendario); 1 mayor + 1 menor (Mítico y Ultra raro); 1 única (Celestial) | Una habilidad fija por rareza |
| Picos: estadística de combate | Ninguna / +3% / +5% / +6% de defensa o velocidad de ataque, con tope PvP de +2% / +3% / +3% | No existe |
| Pasivas de ejemplo | Eco del filo, Lastre ligero, Sonar rúnico | Otras siete, con otros nombres |
| Nombre de la zona 7 | «Minas oscuras» | Raíces de Obsidiana |
| Interfaz | Siempre muestra carga, debuff y cuánto perderías al morir | No definido |

### 3.3 Combate (rehacer Etapa 4)

| Tema | GDD | Diseño actual |
|---|---|---|
| Qué va en las 4 ranuras | Mezcla de habilidades del arma y del Núcleo | Solo habilidades del Núcleo |
| Tipo de cada habilidad de Núcleo | Área, control, movilidad y definitiva | Sin tipo fijo |
| Núcleos con rareza | Sí (el Prismático es Épico) | Sin rareza |
| Cómo se consiguen | Jefes, cajas de Núcleos, eventos y reliquias en depósitos profundos | Jefes y misiones |
| Cambiar de Núcleo fuera de la ciudad | Cuesta un consumible | Libre fuera de combate |
| Despertar | Con maestría 100 y materiales de jefe; desbloquea la Transformación | Despertar a maestría 75; Transformación a 100 |
| Barra de la Transformación | Resonancia | Sincronía |
| Bono de la Transformación | Hasta +25% de estadísticas en PvE y +10% en PvP | +20% de daño y −20% de enfriamientos; 12 s en PvP |
| Dash | 2 cargas; 3 s de recarga por carga | 1 uso cada 2,5 s |
| Parpadeo | 12 studs; se desbloquea con Agilidad | 16 studs; siempre disponible |
| Control repetido | Ventana de 6 s: el segundo dura 50% y el tercero da 2 s de inmunidad (Tenacidad) | Ventana de 10 s: 100 / 50 / 25% e inmunidad de 6 s |
| Tope de aturdimiento | 2,5 s | 2,0 s |
| Ruptura | Tras 0,8 s bajo control, gastar 50 de energía para liberarse y empujar; enfriamiento de 15 s | «Ruptura» era romper la guardia; la liberación era automática («Rompecadenas») |
| Bloqueo en PC | F | Clic derecho |
| Habilidades en consola | X, Y, B y RB directos | LB + botón |
| Dash en consola | LB | RB |

**Núcleo Prismático.** El GDD define su conjunto y hay que sustituir el propuesto:

| Ranura | GDD | Diseño actual |
|---|---|---|
| Z | Lanza Prismática: proyectil de 2,2× de daño; ralentiza 25% 1,5 s; 20 de energía; 6 s | Haz Facetado |
| X | Campo de Refracción: área de 14 studs; aplica Refractado 6 s (+10% de daño recibido en PvP); 25; 12 s | Abanico Espectral |
| C | Paso de Relámpago: parpadeo de 18 studs hacia un objetivo Refractado (10 si no hay); 25; 9 s | Prisma Centinela |
| V | Prisma Total: cúpula de 6 s; enemigos 20% más lentos y un rayo por segundo; 40; 60 s | Espectro Total |
| Pasiva | Fragmentos de luz: los críticos devuelven 5 de energía | Refracción |
| Transformación | Forma Prisma: la Lanza dispara 3 proyectiles; en PvP solo +10% de velocidad de movimiento | Forma Caleidoscopio |

«Paso de Relámpago» se había usado para el Núcleo de Tormenta; hay que renombrar esa habilidad.

### 3.4 Mascotas (rehacer Etapa 5)

| Tema | GDD | Diseño actual |
|---|---|---|
| Posturas | Dos: Recolectar (+50% de radio, −50% de daño) y Proteger (lo contrario) | Tres: Atacar, Recolectar (0% de daño) y Proteger (60%) |
| Cambio de postura | 5 s | 3 s |
| Radio de recogida | 20 studs | 12 studs |
| Incubación | Minando (por ejemplo, 500 golpes de pico) | Minutos de juego según rareza |
| Forma desatada | Nivel 50 + materiales de su elemento; tamaño ×1,8 | Nivel 50 + Vínculos + material de jefe |
| Forma máxima | Nivel 100 + material de jefe; desbloquea un ataque coordinado con el dueño | Mejora de la habilidad desatada |
| Qué desbloquea cada fase | Cría: pasiva de recolección; desatada: habilidad activa; máxima: ataque coordinado | Cría: ataque y habilidad; desatada: segunda habilidad |
| Roles | Defensa, Ofensiva, Control, Apoyo y Minería | Tanque, Atacante, Control, Apoyo y Recolector |
| Apoyo | Da velocidad de ataque (+15% 6 s) y cura tras una esquiva perfecta | Cura continua |
| Defensa | Escudo del 20% de la vida máxima durante 5 s | Desvío del 5% y escudo del 2% |
| Minería | +20% de velocidad de extracción 10 s | +4% de daño de pico |
| Guiverno de Cuarzo | Pasiva: +15% de velocidad de extracción. Activa: Escudo Facetado (absorbe el 20% de la vida máxima 5 s si el dueño baja del 50%; 30 s). Coordinado: Haz de Cuarzo | Atacante con Aliento de esquirlas y Vuelo rasante |

### 3.5 Economía y retención (rehacer Etapa 6; actualizar A)

| Tema | GDD | Diseño actual |
|---|---|---|
| Racha de extracción | ×1,1, ×1,2… hasta ×1,5 | +2% por paso hasta +10% |
| Seguro de carga | Consumible fabricable con minerales; protege el 50% de una carga | Se compra con monedas; paga en monedas el 50% de lo soltado |
| Contratos de grieta | Extraer 3 cristales de una rareza, o derrotar a 2 portadores con carga alta | Nunca piden matar jugadores |
| Recompensa por cabeza | Racha de 5 o más: queda marcado y quien lo derrote gana un bono | No existe (había «marca de saqueador») |
| Grieta Celestial | Evento cada 2 horas, anunciado 5 minutos antes | No existe |
| Rastro de venganza | Quien te derrotó queda marcado para ti 3 minutos | No existe |
| Escuadrones | Carga compartida y extracción más rápida en grupo | Solo exclusividad compartida del cofre |
| Temporadas | De grieta, con clasificación por valor extraído | Pase de temporada general |
| Jefes de grieta | Aparecen cuando muchos jugadores luchan en la misma zona | No existen |
| Cajas de Núcleos | Existen | No existen |
| Simulación pedida | Zonas 2, 5 y 8 | Zonas 1, 3, 5, 8 y 10 (las del prompt de trabajo) |

---

## 4. Valores del GDD que dan problemas al simularlos

### P1 — Los multiplicadores de rareza rompen la regla «la zona pesa más»

| | Zonas de diferencia para que un Común sin mejoras supere a… | | |
|---|---|---|---|
| | Ultra raro al máximo | Celestial al máximo | Rango dentro de una zona |
| Multiplicadores propuestos | 3 | 4 | ×5,2 |
| Multiplicadores del GDD | 5 | 5 | ×10,4 |

- Con los valores del GDD, un Celestial anclado a la zona 6 y mejorado al máximo (×10,4) supera a un Común de la zona 10 (×7,4). El propio GDD pide que eso no ocurra.
- Alternativas con los multiplicadores del GDD:

| Opción | Común supera a Ultra raro al máximo a | Común supera a Celestial al máximo a | Zona 10 frente a zona 1 |
|---|---|---|---|
| Crecimiento 1,65 y bonos hasta +100% (actual) | 5 zonas | 5 zonas | ×91 |
| Crecimiento 1,65 y bonos hasta +50% | 4 | 5 | ×91 |
| Crecimiento 2,00 y bonos hasta +100% | 4 | 4 | ×512 |
| **Crecimiento 2,00 y bonos hasta +50%** | **3** | **3** | **×512** |
| Crecimiento 2,30 y bonos hasta +50% | 3 | 3 | ×1.801 |

- **Recomendación:** adoptar los multiplicadores del GDD, subir el crecimiento por zona de 1,65 a 2,00 y bajar el tope de bonos de +100% a +50%. Recupera la regla de 3 zonas. Los precios, al medirse en horas de ingreso, se reescalan solos.

### P2 — La racha de ×1,5 supera el techo de 2,5

Ingresos de grieta frente al PvE, sin contratos:

| Multiplicador base | Racha | Máximo teórico | 15% de muertes | 30% | 50% |
|---|---|---|---|---|---|
| ×2,0 | +2% hasta ×1,1 (actual) | 2,33 | 2,06 | 1,82 | 1,49 |
| ×2,0 | +10% hasta ×1,5 (GDD) | 3,17 | 2,54 | 2,07 | 1,59 |
| ×1,8 | GDD | 2,86 | 2,29 | 1,88 | 1,45 |
| ×1,6 | GDD | 2,54 | 2,04 | 1,68 | 1,31 |
| **×1,5** | **GDD** | **2,38** | **1,92** | **1,58** | **1,24** |

- El GDD no fija el multiplicador base de la grieta; el ×2,0 era propuesta del diseño.
- **Recomendación:** adoptar la racha del GDD (hasta ×1,5) y bajar el multiplicador base a ×1,5. El máximo teórico queda en 2,38 y hay sitio para los contratos. La racha pasa a ser lo que más pesa, que es la intención del GDD.

### P3 — Los fragmentos Celestiales al 0,02% por depósito

| Probabilidad por depósito | Horas de grieta por objeto Celestial (50 fragmentos) |
|---|---|
| 0,02% (GDD) | 960 |
| 0,20% | 96 |
| 0,50% | 38 |

- Con 0,02%, un objeto Celestial pide 960 horas de minería en grieta. La ruta de jefes de evento (5 semanas) sería 20 veces más rápida y la grieta dejaría de contar.
- **Recomendación:** 0,25% por depósito (unas 77 horas; 8 semanas a 10 horas semanales), más los jefes de evento y la Grieta Celestial.

### P4 — El anti-combo del GDD deja controlar más de la mitad del tiempo

- Con dos controles de 1,5 s en la ventana de 6 s y 2 s de Tenacidad, un jugador puede pasar 2,25 de cada 4,25 s bajo control: el 53%. Con las reglas propuestas era el 12,5%.
- La Ruptura lo alivia, pero cuesta 50 de energía (la mitad de la barra base) y tiene 15 s de enfriamiento.
- **Recomendación:** adoptar la estructura del GDD (ventana de 6 s, Tenacidad, tope de 2,5 s y Ruptura activa) y subir la Tenacidad de 2 a 5 s. El máximo baja al 31%. Se decide con simulación al rehacer la Etapa 4.

### P5 — «Los requisitos de acceso evitan que un nivel 1.000 entre en la grieta de nivel 50»

- Los requisitos (nivel, Minería y potencia de pico) son mínimos: un jugador de nivel 1.000 los cumple todos y puede entrar en la grieta de la zona 1.
- **Recomendación:** mantener la sincronización de nivel propuesta (nivel efectivo máximo `100 × zona` dentro de cada Zona Fracturada). Es un añadido necesario para que el GDD cumpla lo que dice.

### P6 — El tope de 800 partículas en calidad Baja con efectos ajenos al 50%

- Peor caso (jefe con 8 jugadores): 865 partículas, por encima de 800.
- **Recomendación:** en calidad Baja, efectos ajenos al 40% (760). En Alta cabe de sobra (865 de 2.000).

---

## 5. Añadidos del diseño que el GDD no trata

Se mantienen, marcados como añadidos, porque el GDD no los contradice:

| Añadido | Motivo |
|---|---|
| Sincronización de nivel en Zonas Fracturadas | Necesaria (P5) |
| Multiplicador de daño entre jugadores (×0,06) y topes del 35% por golpe y del 60% en 2 s | Sin ellos los duelos duran 1 s (B4, B7) |
| Vitalidad y Defensa reducidas en PvP | Dominio del Tanque (B7) |
| Esquiva con invulnerabilidad breve | El GDD la da por hecha («esquiva perfecta») sin definirla |
| Mochila doble dentro de la grieta | Para que saquear tenga sentido (B6); hay que revisarla con el debuff del GDD |
| Regla de «misma víctima» sin botín durante 10 minutos | Contra el abuso; compatible con el Rastro de venganza |
| Desconectarse en combate cuenta como muerte | Seguridad (C) |
| Golpes en área limitados y grupos de enemigos | Hacha y Lanza (B7) |
| Regeneración de vida en combate PvE | Combate frente a minería (B7) |

**Términos que chocan y se cambian:**

| Término | En el GDD | En el diseño | Cambio |
|---|---|---|---|
| Ruptura | Liberarse de un control gastando energía | Romper la guardia del rival | La guardia rota pasa a llamarse «Guardia rota» |
| Rompecadenas | No existe | Liberación automática | Se elimina; lo sustituye la Ruptura |
| Resonancia | Barra de la Transformación | Habilidad del pico Ultra raro | Se renombra la habilidad del pico |
| Sincronía | No existe | Barra de la Transformación | Pasa a llamarse Resonancia |
| Paso de Relámpago | Habilidad C del Prismático | Habilidad X de Tormenta | Se renombra la de Tormenta |

---

## 6. Lo que sigue sin poder contrastarse

Depende del prompt maestro, que no se ha recibido:

- Los 30 minerales de referencia y los nombres de las 10 zonas (del GDD solo sale «Minas oscuras», zona 7).
- Las 8 mascotas de referencia.
- Las fórmulas iniciales de las 8 estadísticas y el nombre de la octava. El GDD menciona «Agilidad» como requisito del parpadeo; puede ser el nombre que el prompt maestro da a Velocidad.
- El sexto tipo de arma y la maestría de armas original.
- Las probabilidades de caja originales y la tabla propia de Celestial que el GDD menciona pero no incluye.
- La arquitectura técnica (sección 20), las 9 fases (sección 21) y los perfiles A a G (sección 23).

---

## 7. Plan para rehacer

Una etapa por respuesta, con el comando REPETIR del protocolo.

| Orden | Etapa | Qué cambia |
|---|---|---|
| 1 | REPETIR 1 — Rarezas | Multiplicadores del GDD; crecimiento por zona y tope de bonos (P1); colores; 50 fragmentos y su probabilidad (P3) |
| 2 | Retoque de B2 | Dash de 2 cargas, parpadeo de 12 studs, coste de la Ruptura en la tabla de energía |
| 3 | REPETIR 3 — Minería | Picos con pasivas y estadística de combate; debuff de carga; cofre 80/20; protecciones; rotación de extracción; fuentes de Celestial |
| 4 | REPETIR 4 — Combate | Ranuras mixtas de arma y Núcleo; Prismático del GDD; Despertar y Transformación; anti-combo y Ruptura (P4); controles |
| 5 | REPETIR 5 — Mascotas | Dos posturas; fases y lo que desbloquea cada una; roles; Guiverno de Cuarzo; incubación por golpes |
| 6 | REPETIR 6 — Economía | Racha y multiplicador base (P2); seguro fabricable; contratos; cajas de Núcleos; eventos de grieta |
| 7 | REPETIR 7 — Simulaciones | Todo de nuevo con los valores anteriores; añadir las zonas 2, 5 y 8 que pide el GDD |
| 8 | Actualizar A, C y D | Arte y VFX del GDD; configuración; controles; lista de provisionales |
