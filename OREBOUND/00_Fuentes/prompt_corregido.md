# OREBOUND — Prompt único con continuidad (versión corregida)

Versión 2 · 2026-11-16 · Sustituye al prompt único original. Los cambios respecto al original están marcados con **[CORREGIDO Tn]** y explicados en `DECISIONES.md`, sección 4.

```
Vamos a diseñar OREBOUND, un juego de Roblox, en 11 etapas con continuidad.

FUENTES
1. prompt_maestro.txt: el encargo completo, con sistemas, fórmulas iniciales y
   formato de entrega.
2. GDD_combate_mineria_mascotas.pdf: decisiones nuevas que amplían y, donde
   choquen, sustituyen al prompt maestro.
[CORREGIDO T10] Si alguna de las dos fuentes no está adjunta, no te detengas:
propón los valores que falten, márcalos [PROVISIONAL] y anótalos en
DECISIONES.md como "pendiente de contrastar". Cuando la fuente llegue, manda
la fuente y se corrige el archivo afectado.

Actúa como el equipo descrito en la sección 1 del prompt maestro. Si no está
disponible: diseñador de sistemas, diseñador de economía, diseñador de
combate, programador técnico de Roblox y analista de balance.

========================================
REGLAS GENERALES
========================================
- Haz UNA etapa por respuesta, en orden. No adelantes trabajo de etapas
  siguientes.
- Cada etapa produce un archivo con nombre fijo. Entrégalo completo, nunca
  resumido ni "igual que antes".
- No programes el juego. Solo diseño, matemáticas y especificación.
- Haz todos los cálculos con código (Python) y muestra el script. No calcules
  de cabeza. Si no puedes ejecutar código, dilo y entrega el script.
- Marca cada cifra como [CONFIRMADO] o [PROVISIONAL].
- Para cada fórmula incluye: nombre, expresión, variables, unidad, ejemplo
  numérico, límites, posibles problemas y valor configurable recomendado.
- Toda tabla de probabilidades debe sumar exactamente 100%.
- Si detectas un problema de balance, explícalo y propón una alternativa con
  números.
- No hagas preguntas innecesarias: si falta un valor, propón uno, márcalo
  [PROVISIONAL] y di cómo probarlo.
- Si una etapa anterior tiene un error, corrígelo en la etapa actual y di qué
  archivo cambia.

========================================
DECISIONES FIJAS (no las cambies sin explicar por qué)
========================================
- Todo lo de la sección 3 del prompt maestro.
- La mina principal es PvE. Hay una Zona Fracturada opcional con PvP siempre
  activo por cada zona de la mina.
  [CORREGIDO T08] Diseño completo: 10 Zonas Fracturadas. MVP: 1 de prueba.
- En las Zonas Fracturadas solo se arriesga el mineral transportado; nunca
  armas, picos, mascotas, monedas ni nivel.
- Al morir contra un jugador en una Zona Fracturada se suelta el 50% de la
  carga [PROVISIONAL].
  [CORREGIDO T07] En minas PvE se pierde el 20%. Si en la Etapa 6 el riesgo
  no compensa dentro del techo de 2.5 veces, se ajusta el 50%, no el techo.
- Rarezas: las 7 del prompt maestro + Celestial como octava, solo en eventos
  y fin de juego. Celestial no entra en cajas estándar.
  [CORREGIDO T02] Celestial no tiene versión por zona de la mina. Su potencia
  se ancla a una zona según la fuente que lo entrega; el anclaje mínimo es la
  zona 6.
  [CORREGIDO T03] Son cajas estándar las de mascotas, armas y zona: nunca dan
  Celestial. En las Zonas Fracturadas (zona 6 o más) solo caen fragmentos
  Celestiales, nunca el objeto completo.
- Los poderes equipables se llaman Núcleos de Poder [PROVISIONAL el nombre].
  No uses "frutas" ni copies nada de otros juegos.
- Combate: ataque básico + 4 ranuras (Z, X, C, V) + movilidad (dash, doble
  salto, parpadeo).
  [CORREGIDO T04] Hay 6 tipos de arma. Espada, hacha, daga, lanza y bastón
  quedan dentro de ±10% de DPS entre sí. El sexto tipo queda fuera de ese
  margen a propósito y se compensa con alcance o utilidad.
- Mascotas: fases huevo → cría → forma desatada. Tope de DPS conjunto: 40%
  del jugador en PvE y 25% en PvP y Zonas Fracturadas.
  [CORREGIDO T05] La "forma desatada máxima" es el grado final de la tercera
  fase, no una cuarta fase.
  [CORREGIDO T06] La estadística Dominio de mascotas debe dar también valor
  fuera del daño (vida de mascota, recolección, utilidad), para que el tope
  de DPS no la deje sin uso.

========================================
PROTOCOLO DE CONTINUIDAD
========================================
[CORREGIDO T09] Este protocolo es el único válido. Las "partes" sueltas
quedan solo como respaldo y, si se usan, cierran igual que aquí.

Al final de CADA respuesta escribe siempre estos tres bloques:

1. "Cambios para DECISIONES.md": lista de valores y decisiones nuevos o
   modificados en esta etapa.
2. "ESTADO":
   - Etapas terminadas: (lista)
   - Etapa siguiente: (número y nombre)
   - Valores clave para las siguientes etapas: (lista corta)
3. La frase exacta: "Etapa N terminada. Guarda [archivo] y escribe CONTINUAR
   para la Etapa N+1: [nombre]."

Cómo respondo yo:
- CONTINUAR: haz la etapa siguiente.
- SIGUE: tu respuesta anterior se cortó; continúa donde se quedó, sin repetir.
- REPETIR N: rehaz la etapa N teniendo en cuenta lo que te diga.
- Si abro un chat nuevo, te enviaré este mismo prompt con DECISIONES.md y el
  último bloque ESTADO: retoma en la etapa siguiente que indique.

Si una etapa es demasiado larga para una respuesta, divídela en "Etapa N
(1/2)" y "Etapa N (2/2)" y pídeme CONTINUAR entre ambas.

========================================
PLAN DE TRABAJO
========================================
ETAPA 0 — Arranque. Archivo: DECISIONES.md
- DECISIONES.md inicial con todas las decisiones fijas y valores, separados
  en CONFIRMADO y PROVISIONAL.
- Lista de contradicciones y cómo resolverlas.
- No diseñes nada más todavía.

ETAPA 1 — Rarezas y probabilidades. Archivo: B1_Rarezas.md (secciones 4, 6 y
12 del prompt maestro)
- Tabla de las 8 rarezas: color, índice, multiplicador y dónde aparece cada
  una.
- Probabilidades de caja estándar y de depósitos (suman 100%); distribución y
  fragmentos de Celestial.
- Fórmula de potencia de objeto (zona, rareza, nivel, mejoras, habilidades)
  sin multiplicadores descontrolados; demuestra que un común de zona alta
  supera a un ultra raro de zona baja y a un Celestial de anclaje bajo.
- Suerte: fórmula de pesos, tabla de qué recompensas la admiten y simulación
  con Suerte 10, 100, 500, 1,000 y 2,500.
- [CORREGIDO T01] Protección contra mala suerte: probabilidad base hasta la
  apertura 40, rampa de la 41 a la 49, garantía de Legendario o superior en
  la 50 y garantía de rango superior en la 100. Contadores independientes
  por caja. Simula 100,000 aperturas e informa la tasa real.

ETAPA 2 — Progresión y estadísticas. Archivo: B2_Progresion.md (secciones 5 y
6)
- XP por nivel con techo(100 + 20L + 0.8L²) de 1 a 1,000 (hitos en el
  documento, CSV completo aparte) y XP acumulada.
- Horas de juego por hito, con XP por hora justificada; si la curva es lenta
  o rápida, propón ajustes.
- Comportamiento en niveles 1,500, 2,000 y 3,000.
- Puntos por nivel y sistema de redistribución.
- Las 8 estadísticas: fórmula, efecto del punto 1, 100 y 1,000, y tope.
  Revisa si Fuerza, Velocidad y Dominio de mascotas escalan demasiado poco y
  Vitalidad demasiado.
- Defensa PvE y PvP con Defensa 10 a 5,000, sin inmunidad.
- Energía: capacidad, consumos (incluidos dash y parpadeo), regeneración y
  límites.

ETAPA 3 — Minería. Archivo: B3_Mineria.md (secciones 7, 8, 9 y 14 + GDD)
- Las 10 zonas y sus requisitos, comprobados con build de minería,
  equilibrada y de combate.
- Catálogo completo de minerales en todas las rarezas (nombre, zona, rareza,
  vida, valor, requisitos, materiales, uso, probabilidad; cada zona suma
  100%). Entrégalo también en CSV.
- Tabla de picos: 10 zonas × 7 rarezas (+ Celestial con anclaje de zona 6 o
  más), con potencia, velocidad, requisitos, habilidad y mejoras.
- Tiempo de extracción por rareza y zona con pico común y ultra raro.
- Depósitos activos por zona y regeneración, justificados con simulación.
- Zonas Fracturadas: multiplicador de valor, debuff de carga, saqueo,
  extracción, protección de novato y anti-acampada.
- Muerte en minas PvE (20%), banco y protección para jugadores nuevos.

ETAPA 4 — Combate. Archivo: B4_Combate.md (secciones 10, 15 y 17 + GDD)
- Armas: 6 tipos × 10 zonas × rarezas; DPS de los 5 tipos cuerpo a cuerpo y
  bastón dentro de ±10%.
- Fórmula de daño completa: arma, fuerza, críticos, habilidades, defensa y
  estados.
- Maestría de armas y Núcleos: fórmula de XP, hitos y más allá de 100.
- Núcleos de Poder: estructura, Despertar, Transformación y 6 Núcleos de
  lanzamiento con nombres originales (incluido el Prismático).
- Movilidad y anti-combo infinito con valores.
- Enemigos por zona y tipo (común, élite, guardián, jefe); 3 jefes del MVP
  con fases y escalado de 1 a 8 jugadores.
- Reglas PvP y de Zonas Fracturadas; controles en PC, móvil y consola.

ETAPA 5 — Mascotas. Archivo: B5_Mascotas.md (sección 11 + GDD)
- Nivel de mascota hasta 100, evolución y requisitos de cada fase.
- Daño, vida y velocidad con Dominio de mascotas.
- 12 mascotas de lanzamiento con nombres originales (incluido el Guiverno de
  Cuarzo).
- Posturas Recolectar y Proteger, y recogida automática.
- Topes de DPS: cómo los aplica el servidor y simulación con 3 mascotas a
  niveles 10, 50 y 100.
- Valor de las mascotas que no hacen daño; espacios de mascotas.

ETAPA 6 — Economía. Archivo: B6_Economia.md (secciones 12, 13 y 19 + GDD)
- Entradas y salidas de cada recurso.
- Precios de minerales, cajas, picos, armas y mejoras; materiales de
  fabricación; recompensas de enemigos y jefes.
- Ingresos y gastos por hora en zonas 1, 3, 5, 8 y 10 para minero PvE,
  combatiente PvE y jugador de Zonas Fracturadas. Ningún estilo PvE gana más
  de 1.3 veces que otro; las Zonas Fracturadas no más de 2.5 veces el valor
  PvE.
- Contenido y probabilidades de todas las cajas.
- Sumideros e inflación: simula 1,000 jugadores durante 90 días.
- Seguro de carga, racha de extracción y contratos de grieta.
- Monetización: qué se vende y qué nunca. Revisa la política vigente de
  Roblox sobre recompensas aleatorias pagadas y PolicyService; cita la fuente
  si puedes consultarla o di que no pudiste.

ETAPA 7 — Simulaciones. Archivo: B7_Simulaciones.md (sección 23)
- Jugadores A a G (niveles 1, 50, 100, 300, 500, 800 y 1,000).
- Builds extremas (Fuerza, Minería, Suerte, Defensa, Dominio) y equipo común,
  ultra raro y Celestial.
- Zonas Fracturadas: 1 contra 2, 3 contra 3, saqueador frente a minero PvE.
- Escalado a zonas de nivel 1,100 a 2,000 sin cambiar el núcleo de las
  fórmulas.
- Builds que rompen el juego y su corrección; tabla de cambios en los
  archivos B.
- Índice del Documento B con todas las fórmulas finales.

ETAPA 8 — Game Design Document. Archivo: A_GDD.md
- Concepto y pilares; arte y VFX con límites de rendimiento; core loops;
  mecánicas; mundos y reparto de las 10 zonas; enemigos, jefes y eventos;
  cajas y animación (el servidor decide antes de animar); economía resumida;
  PvE, arenas y Zonas Fracturadas; retención y renacimiento; monetización
  justa; MVP.
- Si algún número difiere de los archivos B, mandan los archivos B.

ETAPA 9 — Especificación técnica. Archivo: C_Tecnico.md (sección 20)
- Proyecto con Rojo y árbol de carpetas, con FractureService,
  PowerCoreService y evolución de mascotas.
- Módulos de configuración con las claves exactas de los archivos B.
- Servicios, controladores, Remotes (parámetros, validación y límite de
  frecuencia).
- Datos persistentes con versiones, migraciones, bloqueo de sesión y registro
  de cajas.
- Seguridad de cada operación; rendimiento de VFX; plan de pruebas.

ETAPA 10 — Roadmap. Archivo: D_Roadmap.md (sección 21)
- Fases de desarrollo con dependencias; contenido exacto del MVP y criterio
  de terminado.
- Pruebas por fase con métricas y umbrales; optimización y beta; expansión
  más allá de 1,000.
- Lista de valores PROVISIONALES y cómo probar cada uno.
- Contradicciones restantes entre A, B, C y D.
- Cierra con: "Etapa 10 terminada. El diseño de OREBOUND está completo."
```
