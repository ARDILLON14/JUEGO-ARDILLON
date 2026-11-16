# OREBOUND — DECISIONES.md

Versión: Etapa 0 (1/2) · 2026-11-16

> **Estado de las fuentes.** Este archivo se ha construido solo con el documento
> «OREBOUND — Prompts por partes» (prompt único con continuidad + partes 0 a 10).
> **No se han recibido** `prompt_maestro.txt` ni `GDD_combate_mineria_mascotas.pdf`.
> Por eso hay tres bloques en lugar de dos:
>
> - **CONFIRMADO**: decisiones fijas escritas literalmente en el prompt.
> - **PROVISIONAL**: valores marcados como provisionales en el prompt, o cifras que
>   el plan de etapas cita de pasada y que aún no se han contrastado con su fuente.
> - **PENDIENTE DE FUENTE**: lo que el prompt da por definido en el prompt maestro o
>   en el GDD y que no se puede rellenar sin esos archivos. No se ha inventado nada.

---

## 1. CONFIRMADO

### 1.1 Reglas de trabajo
- C-01. El diseño se hace en 11 etapas (0 a 10), una por respuesta, en orden y sin adelantar trabajo.
- C-02. Cada etapa produce un archivo de nombre fijo, entregado completo.
- C-03. No se programa el juego: solo diseño, matemáticas y especificación.
- C-04. Todos los cálculos se hacen con Python y se entrega el script.
- C-05. Cada cifra se marca [CONFIRMADO] o [PROVISIONAL].
- C-06. Cada fórmula incluye: nombre, expresión, variables, unidad, ejemplo numérico, límites, posibles problemas y valor configurable recomendado.
- C-07. Toda tabla de probabilidades suma exactamente 100%.
- C-08. Si falta un valor se propone uno, se marca [PROVISIONAL] y se indica cómo probarlo.
- C-09. Si una etapa anterior tiene un error, se corrige en la etapa actual indicando qué archivo cambia.
- C-10. Si un número del GDD final (A_GDD.md) difiere de los archivos B, mandan los archivos B.
- C-11. El GDD adjunto amplía el prompt maestro y, donde choquen, lo sustituye.

### 1.2 Archivos
- C-12. DECISIONES.md, B1_Rarezas.md, B2_Progresion.md, B3_Mineria.md, B4_Combate.md, B5_Mascotas.md, B6_Economia.md, B7_Simulaciones.md, A_GDD.md, C_Tecnico.md, D_Roadmap.md.
- C-13. Los scripts de cálculo van en la carpeta `calculos/`.

### 1.3 Decisiones fijas de diseño
- C-14. Rige todo lo de la sección 3 del prompt maestro (contenido: ver P-F-02).
- C-15. La mina principal es PvE.
- C-16. Hay una Zona Fracturada opcional con PvP siempre activo por cada zona de la mina.
- C-17. En las Zonas Fracturadas solo se arriesga el mineral transportado; nunca armas, picos, mascotas, monedas ni nivel.
- C-18. Rarezas: las 7 del prompt maestro + Celestial como octava.
- C-19. Celestial solo aparece en eventos y fin de juego. No entra en cajas estándar.
- C-20. No se usa la palabra «frutas» ni se copia nada de otros juegos. Todos los nombres son originales.
- C-21. Combate: ataque básico + 4 ranuras (Z, X, C, V) + movilidad (dash, doble salto, parpadeo).
- C-22. Mascotas: fases huevo → cría → forma desatada.
- C-23. Tope de DPS conjunto de mascotas: 40% del DPS del jugador en PvE.
- C-24. Tope de DPS conjunto de mascotas: 25% del DPS del jugador en PvP y Zonas Fracturadas.

---

## 2. PROVISIONAL

### 2.1 Marcados como provisionales en el prompt
- P-01. Al morir contra un jugador en una Zona Fracturada se suelta el 50% de la carga.
  Cómo probarlo: simulación de ingresos saqueador frente a minero (Etapa 6 y 7) y, en beta, tasa de abandono tras la primera muerte.
- P-02. Nombre «Núcleos de Poder» para los poderes equipables.
  Cómo probarlo: prueba de comprensión del nombre con jugadores y comprobación de que no coincide con otro juego.

### 2.2 Cifras que cita el plan de etapas (origen: prompt maestro o GDD, sin contrastar)
Pasan a CONFIRMADO cuando se comprueben contra el archivo de origen.

Progresión
- P-03. XP para el siguiente nivel: `XP(L) = techo(100 + 20·L + 0,8·L²)`.
- P-04. Nivel máximo de lanzamiento: 1.000. Expansión prevista con zonas de nivel 1.100 a 2.000; comportamiento a revisar en 1.500, 2.000 y 3.000.
- P-05. Hay 8 estadísticas. Nombradas en el prompt: Fuerza, Velocidad, Vitalidad, Defensa, Minería, Suerte y Dominio de mascotas (7 de 8).
- P-06. Fuerza, Velocidad y Dominio de mascotas escalan con raíz cuadrada (a revisar si escalan demasiado poco).
- P-07. La Defensa tiene reglas distintas en PvE y PvP y nunca llega a inmunidad.
- P-08. La Energía se consume en esquiva, bloqueo, habilidades, dash y parpadeo, y regenera distinto dentro y fuera de combate.
- P-09. Existe redistribución de puntos de estadística (objeto, coste o servicio, por decidir).

Rarezas, suerte y cajas
- P-10. Nombres de rareza citados: Común, Legendario, Ultra raro, Celestial.
- P-11. No todas las zonas tienen depósitos Ultra raro.
- P-12. Celestial se obtiene en eventos, jefes de evento y Zonas Fracturadas de zona 6 o superior, con un sistema de fragmentos Celestiales.
- P-13. Protección contra mala suerte: la probabilidad sube entre las aperturas 40 y 50, con garantía en la 50 y en la 100, y contadores independientes por caja. El umbral se mide en «Legendario o superior».
- P-14. Valores de Suerte de referencia para simular: 10, 100, 500, 1.000 y 2.500.
- P-15. Tipos de caja: mascotas, armas, evento y zona. El servidor decide el premio antes de la animación.

Minería
- P-16. La mina tiene 10 zonas, cada una con nivel, Minería y potencia de pico requeridos.
- P-17. Catálogo de referencia: 30 minerales, a ampliar a todas las rarezas.
- P-18. Picos: 10 zonas × 7 rarezas, más Celestial donde aplique.
- P-19. Muerte en minas PvE: se pierde el 20% de la carga. Hay banco y protección para jugadores nuevos.
- P-20. Zonas Fracturadas: multiplicador de valor, debuff de carga, saqueo (parte que se suelta, se recoge y se destruye), Puntos de Extracción, Cofres de Saqueo, protección de novato y anti-acampada.

Combate
- P-21. 6 tipos de arma. Nombrados: espada, hacha, daga, lanza y bastón (5 de 6).
- P-22. El DPS de espada, hacha, daga, lanza y bastón debe quedar dentro de ±10% entre sí.
- P-23. Maestría de armas y de Núcleos con hitos; nivel de referencia 100.
- P-24. Núcleos de Poder: 4 habilidades + 1 pasiva, con Despertar y Transformación.
- P-25. 6 Núcleos de lanzamiento, incluido el Núcleo Prismático del GDD.
- P-26. Anti-combo infinito: rendimientos decrecientes, tope de aturdimiento, Ruptura y cancelación de animaciones.
- P-27. Tipos de enemigo: común, élite, guardián y jefe.
- P-28. 3 jefes en el MVP. Los jefes escalan en cooperativo de 1 a 8 jugadores.
- P-29. Plataformas: PC, móvil y consola.

Mascotas
- P-30. Nivel máximo de mascota: 100.
- P-31. Existe una «forma desatada máxima» además de las tres fases.
- P-32. 12 mascotas de lanzamiento: 8 de referencia + 4 nuevas, incluido el Guiverno de Cuarzo del GDD.
- P-33. Posturas Recolectar y Proteger; recogida automática de mineral y Cofres de Saqueo.
- P-34. 3 espacios de mascota iniciales; se pueden desbloquear más.

Economía y monetización
- P-35. Recursos: monedas, minerales, cristales, materiales de jefe, gemas antiguas y fragmentos Celestiales.
- P-36. Ningún estilo PvE (minero o combatiente) gana más de 1,3 veces lo que el otro.
- P-37. Las Zonas Fracturadas no rinden más de 2,5 veces el valor PvE, contando muertes y saqueos.
- P-38. Mejoras de retención del GDD: seguro de carga, racha de extracción y contratos de grieta.
- P-39. Nunca se venden por dinero real: Celestial, Núcleos Despertados ni el Seguro de carga.
- P-40. La economía se valida simulando la masa monetaria de 1.000 jugadores durante 90 días.

Mundo, retención y producción
- P-41. Ciudad principal + 4 mundos, entre los que se reparten las 10 zonas.
- P-42. PvP en arenas, separado de las Zonas Fracturadas.
- P-43. Retención: diarias, semanales, temporadas, logros, códice y renacimiento.
- P-44. Proyecto con Rojo. Servicios nuevos: FractureService, PowerCoreService y evolución de mascotas.
- P-45. Módulos de configuración: Stats, Rarity, Mining, Pickaxes, Weapons, PowerCores, Pets, Economy, Boxes, Fracture, Worlds, PvP.
- P-46. Roadmap de 9 fases. El MVP incluye 1 Núcleo, 3 jefes, 1 arena y 1 Zona Fracturada de prueba.
- P-47. Perfiles de simulación A a G: niveles 1, 50, 100, 300, 500, 800 y 1.000.

---

## 3. PENDIENTE DE FUENTE

### 3.1 Del prompt maestro (`prompt_maestro.txt`)
- P-F-01. Sección 1: composición del equipo que debe actuar.
- P-F-02. Sección 3: decisiones fijas (C-14 depende de ella).
- P-F-03. Sección 4: nombre, orden, color y multiplicador de las 7 rarezas.
- P-F-04. Sección 5: puntos de estadística por nivel.
- P-F-05. Sección 6: nombre de la octava estadística, fórmulas y topes de las 8, fórmula de Suerte.
- P-F-06. Secciones 7, 8, 9 y 14: requisitos de las 10 zonas, los 30 minerales, picos y generación de depósitos.
- P-F-07. Secciones 10, 15 y 17: sexto tipo de arma, fórmula de daño inicial, enemigos y reglas PvP.
- P-F-08. Sección 11: las 8 mascotas de referencia y sus fórmulas.
- P-F-09. Secciones 12, 13 y 19: probabilidades de cajas, precios y monetización.
- P-F-10. Sección 20: arquitectura técnica y lista de operaciones a validar.
- P-F-11. Sección 21: las 9 fases de desarrollo.
- P-F-12. Sección 23: perfiles completos de los jugadores A a G.

### 3.2 Del GDD (`GDD_combate_mineria_mascotas.pdf`)
- P-F-13. Combate: Núcleo Prismático y valores de Despertar y Transformación.
- P-F-14. Minería PvPvE: multiplicador de valor, debuff de carga, porcentajes de saqueo, Puntos de Extracción, protección de novato y anti-acampada.
- P-F-15. Mascotas: Guiverno de Cuarzo, requisitos de evolución y posturas.
- P-F-16. Mejoras de retención: valores de seguro de carga, racha de extracción y contratos de grieta.
- P-F-17. Dirección de arte y VFX.
- P-F-18. Definición y distribución de Celestial.

---

## 4. Tensiones detectadas dentro del propio prompt

No son las contradicciones entre el prompt maestro y el GDD (esa lista necesita los dos archivos). Son puntos del prompt que conviene cerrar.

| # | Tensión | Propuesta |
|---|---------|-----------|
| T-01 | La protección contra mala suerte aparece como «entre las aperturas 40 y 100» y como «progresión entre 40 y 50, garantía en 50 y 100». | Usar la versión detallada: rampa de 40 a 50, garantía en 50, segunda garantía de rango superior en 100. Concretar en Etapa 1. |
| T-02 | Celestial es «solo eventos y fin de juego», pero se pide comparar con un «Celestial de zona baja» y hay picos Celestial «donde aplique». | Celestial no tiene versión por zona de mina; su potencia se ancla a la zona del evento que lo entrega. La comparación de la Etapa 1 se hace con el Celestial de anclaje más bajo. |
| T-03 | Celestial sale en Zonas Fracturadas de zona 6 o más, pero «no entra en cajas estándar» y hay cajas de zona. | Las cajas de zona cuentan como estándar: nunca dan Celestial. En Zonas Fracturadas solo caen fragmentos. |
| T-04 | Hay 6 tipos de arma pero el margen de ±10% de DPS se pide solo para 5. | El sexto tipo queda fuera del margen a propósito (previsiblemente a distancia o de apoyo). Confirmar con la sección 10 del prompt maestro. |
| T-05 | Mascotas con 3 fases fijas, pero la Etapa 5 cita una «forma desatada máxima». | Tratarla como grado final de la tercera fase, no como cuarta fase. |
| T-06 | El tope de DPS de mascotas (40% / 25%) puede dejar sin valor la estadística Dominio de mascotas. | En Etapa 2 y 5, Dominio debe dar también valor fuera del DPS (vida, recolección, utilidad). |
| T-07 | Perder el 20% en PvE y soltar el 50% en Zona Fracturada, con un techo de 2,5× de ingresos. | Validar en Etapa 6 que el riesgo compensa; si no, ajustar el 50% (P-01), no el techo. |
| T-08 | «Una Zona Fracturada por cada zona» frente a «1 Zona Fracturada de prueba» en el MVP. | No es contradicción: 10 en el diseño completo, 1 en el MVP. |
| T-09 | El prompt único cierra con «Etapa N terminada… escribe CONTINUAR»; las partes sueltas con «Parte N terminada… envíame la Parte N+1». | Rige el prompt único con continuidad. |

---

## 5. Registro de cambios
- 2026-11-16 · Etapa 0 (1/2): creación del archivo a partir del documento de prompts. Faltan las dos fuentes.
