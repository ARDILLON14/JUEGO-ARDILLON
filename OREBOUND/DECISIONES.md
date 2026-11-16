# OREBOUND — DECISIONES.md

Versión: rehecho con el GDD · 2026-11-16 · Diseño completo

> **Estado de las fuentes.** Este archivo se ha construido solo con el documento
> «OREBOUND — Prompts por partes» (prompt único con continuidad + partes 0 a 10).
> **Actualización:** el GDD se recibió tras la Etapa 10 y está en `00_Fuentes/`. Sus valores están en la sección 15 y **mandan sobre las series E1 a E10** donde difieran. El prompt maestro sigue sin recibirse.
> **Al crear este archivo no se habían recibido** `prompt_maestro.txt` ni `GDD_combate_mineria_mascotas.pdf`.
> Por decisión del autor (2026-11-16) se trabaja sin ellas: lo que falte se propone
> como [PROVISIONAL] y se contrasta si las fuentes llegan (ver C-25).
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

### 1.4 Correcciones del prompt (Etapa 0, cerradas el 2026-11-16)
- C-25. Si falta una fuente no se detiene el trabajo: se proponen valores [PROVISIONAL] (T-10).
- C-26. Rige el prompt único corregido: `00_Fuentes/prompt_corregido.md` (T-09).
- C-27. Protección contra mala suerte: base hasta la apertura 40, rampa de la 41 a la 49, garantía en la 50 y garantía de rango superior en la 100 (T-01).
- C-28. Celestial no tiene versión por zona de la mina; su potencia se ancla a una zona según la fuente, con anclaje mínimo en la zona 6 (T-02).
- C-29. Las cajas de mascotas, armas y zona son estándar y nunca dan Celestial. En las Zonas Fracturadas solo caen fragmentos Celestiales (T-03).
- C-30. De los 6 tipos de arma, 5 quedan dentro de ±10% de DPS; el sexto queda fuera a propósito y se compensa con alcance o utilidad (T-04).
- C-31. La «forma desatada máxima» es el grado final de la tercera fase, no una cuarta fase (T-05).
- C-32. Dominio de mascotas da también valor fuera del daño (T-06).
- C-33. Si el riesgo de las Zonas Fracturadas no compensa, se ajusta el 50% de carga soltada, no el techo de 2,5× (T-07).
- C-34. Diseño completo: 10 Zonas Fracturadas. MVP: 1 de prueba (T-08).

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

## 4. Incongruencias del prompt y su resolución

Todas quedan resueltas y aplicadas en `00_Fuentes/prompt_corregido.md`.

| # | Incongruencia | Resolución | Decisión |
|---|---------------|------------|----------|
| T-01 | La protección contra mala suerte aparecía como «entre las aperturas 40 y 100» y como «progresión entre 40 y 50, garantía en 50 y 100». | Una sola regla: base hasta 40, rampa 41–49, garantía en 50, garantía superior en 100. | C-27 |
| T-02 | Celestial era «solo eventos y fin de juego», pero se pedía comparar con un «Celestial de zona baja». | Celestial no tiene versión por zona; se ancla a una zona según la fuente, mínimo zona 6. | C-28 |
| T-03 | Celestial sale en Zonas Fracturadas de zona 6 o más, pero «no entra en cajas estándar» y existen cajas de zona. | Las cajas de zona son estándar. En Zonas Fracturadas solo caen fragmentos. | C-29 |
| T-04 | Había 6 tipos de arma pero el margen de ±10% de DPS se pedía solo para 5. | El sexto tipo queda fuera del margen a propósito. | C-30 |
| T-05 | Mascotas con 3 fases fijas, pero se citaba una «forma desatada máxima». | Es el grado final de la tercera fase. | C-31 |
| T-06 | El tope de DPS de mascotas podía dejar sin valor la estadística Dominio de mascotas. | Dominio da también vida, recolección y utilidad. | C-32 |
| T-07 | 20% de pérdida en PvE y 50% en Zona Fracturada con un techo de 2,5× de ingresos. | Se valida en la Etapa 6; si no compensa se ajusta el 50%. | C-33 |
| T-08 | «Una Zona Fracturada por cada zona» frente a «1 Zona Fracturada de prueba» en el MVP. | 10 en el diseño completo, 1 en el MVP. | C-34 |
| T-09 | Dos frases de cierre distintas (CONTINUAR frente a «envíame la Parte N+1»). | Rige el prompt único con CONTINUAR. | C-26 |
| T-10 | El prompt exigía las dos fuentes y a la vez prohibía preguntas innecesarias; sin fuentes el trabajo se bloqueaba. | Sin fuentes se proponen valores [PROVISIONAL]. | C-25 |

Sigue pendiente la lista de contradicciones entre el prompt maestro y el GDD: solo puede hacerse si llegan los dos archivos.

---

## 5. Valores de la Etapa 1 — B1_Rarezas.md (todos [PROVISIONAL])

Rarezas
- E1-01. Orden y nombres: 1 Común, 2 Poco común, 3 Raro, 4 Épico, 5 Legendario, 6 Mítico, 7 Ultra raro, 8 Celestial. Resuelve P-F-03 de forma provisional.
- E1-02. Multiplicadores de rareza: 1,00 / 1,15 / 1,32 / 1,52 / 1,75 / 1,98 / 2,20 / 2,60.

Probabilidades
- E1-03. Caja estándar: 50 / 26 / 14 / 7 / 2,4 / 0,5 / 0,1 % (Legendario o superior 3,0%).
- E1-04. Depósitos en zona con Ultra raro: 55 / 25 / 12 / 5,5 / 2 / 0,45 / 0,05 %.
- E1-05. Depósitos en zona sin Ultra raro: 55 / 25 / 12 / 5,5 / 2 / 0,50 / 0 %.
- E1-06. Caja de evento (no estándar, no se vende): Raro 45, Épico 33, Legendario 15, Mítico 5, Ultra raro 1,5, Celestial 0,5 %.

Potencia de objeto
- E1-07. `Potencia = PotZona(z) × MultRareza(r) × (1 + min(BonoNivel + BonoMejoras + BonoHabilidades, 1,00))`.
- E1-08. `PotZona(z) = 100 × 1,65^(z−1)`; crecimiento por zona 1,65.
- E1-09. Topes de bono: nivel de objeto +50%, mejoras +30%, habilidades +20%; total +100%.

Suerte
- E1-10. `F(S) = 1 + 3 × S / (S + 1.000)`; máximo ×4.
- E1-11. Exponentes por rareza: 0 / 0,2 / 0,4 / 0,6 / 0,8 / 1,0 / 1,0. Peso ajustado = peso × F^exponente, y se normaliza a 100%.
- E1-12. La Suerte no afecta a Celestial, a las garantías, a las cajas de pago ni al botín de las Zonas Fracturadas.

Protección contra mala suerte
- E1-13. Contador A por tipo de caja: `p(n) = 3%` si n ≤ 40; `p(n) = 3% + 97% × ((n−40)/10)²` si 41 ≤ n ≤ 49; 100% en n = 50. Premio: Legendario o superior.
- E1-14. Contador B por tipo de caja: garantía de Mítico o superior en la apertura 100. Si coincide con A, manda B.
- E1-15. Tasas reales simuladas (100.000 aperturas): Legendario o superior 4,449%; Mítico o superior 1,399%; Ultra raro 0,228%. Son las que hay que publicar y usar en la Etapa 6.

Celestial
- E1-16. 60 fragmentos Celestiales = 1 objeto Celestial a elegir. Los fragmentos no se pueden soltar ni comerciar.
- E1-17. Jefe de evento: 2 fragmentos por derrota (máximo 5 derrotas por semana) y 0,5% de objeto Celestial directo.
- E1-18. Extracción con éxito en Zona Fracturada: 10 / 12,5 / 15 / 17,5 / 20 % de 1 fragmento en zonas 6 a 10; máximo 10 fragmentos por semana.
- E1-19. Ritmo previsto: de 3,0 semanas (máximo) a 15,0 semanas (casual) por objeto Celestial.

---

## 6. Valores de la Etapa 2 — B2_Progresion.md (todos [PROVISIONAL] salvo E2-01)

Experiencia
- E2-01. `XP(L) = techo(100 + 20·L + 0,8·L²)` de nivel 1 a 1.000 (fórmula del prompt). XP acumulada a nivel 1.000: 276.357.100.
- E2-02. XP por hora base: `240 × (25 + 3,75·L)`. Con ella, nivel 1.000 cuesta 460,3 horas.
- E2-03. [ADOPTADO desde la Etapa 3] Ajuste de XP por acción `25 + 3,75·L + 0,002·L²` → 344,6 horas a nivel 1.000.
- E2-04. Por encima de 1.000: `XP(L) = 820.100 + 900 × (L − 1.000)` (cola lineal); unas 95 horas por cada 100 niveles.

Puntos de estadística
- E2-05. 3 puntos por nivel: `Puntos(L) = 3 + 3 × (L − 1)`; 3.000 a nivel 1.000.
- E2-06. Tope de 1.000 puntos asignados por estadística; tope de 5.000 de valor total con equipo.
- E2-07. [SUSTITUIDO por E6-13] Reinicio completo en la ciudad: gratis bajo nivel 50; después `1.000 × nivel` monedas. Objeto «Tomo de Reajuste» para un reinicio gratis.

Estadísticas
- E2-08. Las 8: Fuerza, Vitalidad, Defensa, Velocidad, Energía, Minería, Suerte y Dominio de mascotas (Energía es la octava propuesta; resuelve P-F-05 de forma provisional).
- E2-09. Curva común: `Mult(S) = 1 + M × S/(S + 1.000)`. Sustituye a la raíz cuadrada (P-06).
- E2-10. `M` por efecto: Fuerza 3; Vitalidad 3; Minería 3; Suerte 3; Dominio (daño y vida de mascota) 3; Dominio (recolección) 1,5; Velocidad de ataque 0,8; Velocidad de movimiento 0,5 (WalkSpeed máximo 24); regeneración de Energía 1.
- E2-11. `VidaBase(L) = 500 × 1,65^((L − 1)/100)`.
- E2-12. [SUSTITUIDO por E7-08: `M = 1,0`] En PvP y Zonas Fracturadas la Vitalidad usa `M = 1,5` (recomendación; la Etapa 4 la confirma).

Defensa
- E2-13. `Reducción = mín(D/(D + K), Tope)`. PvE: `K = 1.500`, tope 75%. PvP y Zonas Fracturadas: `K = 4.500`, tope 50% (corregido por E7-09; antes 3.000 y 60%).

Energía
- E2-14. Energía máxima `100 + 300·E/(E + 1.000)`; regeneración 8/s en combate y 20/s fuera, por `(1 + E/(E + 1.000))`.
- E2-15. Pausa de regeneración de 1,5 s tras gastar; «en combate» = 5 s desde el último golpe.
- E2-16. Costes: esquiva 20, bloqueo 8/s más 10 por golpe, dash 20, doble salto 0, parpadeo 30, habilidades Z/X/C/V 15/25/35/50.
- E2-17. Enfriamientos: esquiva 1,2 s, dash 2,5 s, parpadeo 8 s, Z/X/C/V 4/8/14/30 s (referencia).
- E2-18. Reducción de costes máxima del 30%; consumibles de energía cada 30 s en PvP.

---

## 7. Valores de la Etapa 3 — B3_Mineria.md (todos [PROVISIONAL] salvo los marcados)

Zonas
- E3-01. Nombres de las 10 zonas: Cantera del Alba, Galerías de Musgo, Vetas Salinas, Grutas de Brasa, Sima Helada, Bóveda de Ecos, Raíces de Obsidiana, Mar de Magma, Catedral de Cristal, Núcleo Astral.
- E3-02. Requisitos de zona: nivel `100 × (z − 1)` (zona 1 desde nivel 1); Minería `10 × (z − 1)`; potencia de pico `0,6 × PotZona(z)`.
- E3-03. Dureza de zona `1 + 0,1 × (z − 1)`.
- E3-04. Minería requerida por depósito: `10 × (z − 1) ×` 1 / 1 / 1,5 / 2,5 / 3,5 / 5 / 7 según rareza.
- E3-05. Zonas con Ultra raro: 3, 5, 7, 8, 9 y 10.

Depósitos y minerales
- E3-06. `Vida = PotZona × FactorVida × Dureza`; FactorVida 6 / 9 / 14 / 22 / 35 / 55 / 90.
- E3-07. `Valor = 10 × 1,65^(z−1) × FactorValor`; FactorValor 1 / 1,8 / 3,2 / 6 / 12 / 25 / 60.
- E3-08. `XP = 0,73 × (25 + 3,75·L + 0,002·L²) × FactorXP`; FactorXP 1 / 1,4 / 2 / 3 / 4,5 / 7 / 11.
- E3-09. Unidades por depósito 4 / 4 / 3 / 3 / 2 / 2 / 1. Mochila base 60 unidades.
- E3-10. Catálogo de 66 minerales con nombres originales (`calculos/b3_minerales.csv`).
- E3-11. Materiales por rareza: Lingote, Lingote, Placa, Gema tallada, Núcleo, Catalizador, Esencia.

Picos
- E3-12. 75 picos: 10 zonas × 7 rarezas + 5 Celestiales en zonas 6 a 10 (`calculos/b3_picos.csv`).
- E3-13. Golpes por segundo por rareza: 1,00 / 1,02 / 1,04 / 1,06 / 1,08 / 1,10 / 1,12; Celestial 1,15. Máximo 2,0.
- E3-14. Minería para equipar: `(zona − 1) ×` 10 / 10 / 12 / 15 / 20 / 25 / 30; Celestial 30.
- E3-15. Mínimo de 3 golpes por depósito.
- E3-16. Una habilidad especial por rareza (Golpe certero, Veta abierta, Onda sísmica, Prospector, Fractura en cadena, Resonancia, Eco estelar).
- E3-17. Mejoras: nivel de objeto 1–10 (+5% cada uno), 3 ranuras (+10% cada una), Despertar de habilidad (+20%).

Generación
- E3-18. 40 depósitos activos por zona, regeneración de 45 s, +5 depósitos por minero por encima de 8, máximo 80. Supuesto de 20 jugadores por servidor.
- E3-19. Depósitos compartidos; reparto de unidades y XP en proporción al daño.
- E3-20. La Suerte de depósitos es la media de los jugadores de la zona (precisa E1-11 y la tabla 5.3 de B1).

Ritmo e ingresos (base para la Etapa 6)
- E3-21. Minero equilibrado: 225–232 depósitos por hora; valida las 240 acciones por hora de B2.
- E3-22. Monedas por hora del minero equilibrado: 4.782 (zona 1), 12.418 (zona 3), 33.692 (zona 5), 150.461 (zona 8), 399.993 (zona 10).
- E3-23. La build de Minería gana entre 1,08 y 1,26 veces lo que la equilibrada.

Zonas Fracturadas
- E3-24. Mineral fracturado: ×2,0 de valor y ×1,25 de XP si se extrae; ×1,0 si no.
- E3-25. Debuff de carga: `Velocidad × (1 − 0,30 × c^1,5)`; coste de dash `20 × (1 + 0,5 × c)`; visible en el minimapa desde el 75% de carga.
- E3-26. Muerte contra jugador: se suelta el 50% [PROVISIONAL, P-01]; de lo soltado, el 70% va al Cofre de Saqueo y el 30% se destruye.
- E3-27. Cofre de Saqueo: 90 s; 10 s de exclusividad; 3 s para abrir.
- E3-28. Muerte contra enemigo o entorno en Zona Fracturada: 20% a un cofre abierto a cualquiera.
- E3-29. Puntos de Extracción: 3 por zona, 1 activo, rotación cada 120 s, aviso 20 s antes, canalización de 8 s.
- E3-30. Protección de novato: escudo de 120 s en las 3 primeras entradas; escudo de entrada de 5 s; sincronización de nivel a `100 × z`; sin pérdida por debajo del 10% de carga.
- E3-31. Anti-acampada: 45 s a menos de 25 studs del punto → marcado y −5% de vida por segundo; marca de saqueador tras 3 muertes en 5 minutos; misma víctima sin botín durante 10 minutos; reentrada a los 30 s.
- E3-32. El minero gana más que en PvE mientras muera en menos del 66,7% de los viajes.

Muerte en PvE y banco
- E3-33. Pérdida del 20% de la carga [CONFIRMADO]; queda en un saco recuperable por su dueño durante 120 s.
- E3-34. Sin pérdida por debajo del nivel 25.
- E3-35. Banco en la ciudad y en la entrada de cada zona PvE; no hay banco en Zonas Fracturadas.

Pendiente para la Etapa 6
- E3-36. El coste del reinicio de estadísticas (E2-07) no encaja en niveles bajos; propuesta: `1,5 × monedas por hora de la zona`.

---

## 8. Valores de la Etapa 4 — B4_Combate.md (todos [PROVISIONAL] salvo los marcados)

Armas
- E4-01. Los 6 tipos: Espada, Hacha, Daga, Lanza, Bastón y Arco (el Arco es el sexto, propuesto; resuelve P-F-07 de forma provisional).
- E4-02. Golpes por segundo y coeficiente por golpe: Espada 1,60 / 0,625; Hacha 0,90 / 1,150; Daga 2,60 / 0,365; Lanza 1,20 / 0,810; Bastón 1,00 / 0,960; Arco 1,10 / 0,727.
- E4-03. Alcance en studs: 8 / 9 / 6 / 14 / 35 / 70.
- E4-04. DPS de los 5 tipos entre −3,3% y +4,3% de su media; Arco −19,4% a propósito.
- E4-05. 450 armas (420 + 30 Celestiales en zonas 6 a 10), en `calculos/b4_armas.csv`. Nivel requerido: el de su zona.
- E4-06. Una habilidad de arma por rareza (Filo templado, Sed de combate, Golpe resonante, Furia medida, Eco del acero, Remate, Juicio astral).

Fórmula de daño
- E4-07. `Daño = PotenciaArma × Coef × MultFuerza × MultMaestría × MultCrítico × (1 + Estados) × (1 − Defensa) × MultModo`.
- E4-08. Crítico: 5% de probabilidad y ×1,5; topes 30% y ×2,0. Daga +10% de probabilidad.
- E4-09. Maestría: +0,1% de daño por nivel, máximo +10%.
- E4-10. Estados: Quemadura, Lento, Congelación, Descarga (+15%), Vulnerable (+10–15%) y Ruptura (+25%); aumento de daño recibido máximo +40%.
- E4-11. `MultModo = 0,06` en PvP y Zonas Fracturadas (corregido por E7-10; antes 0,07).

Maestría
- E4-12. `XPm(n) = techo(10 + 2·n + 0,04·n²)`; puntos por enemigo 1 / 4 / 12 / 80; nivel 100 en 67,9 horas.
- E4-13. Hitos: 1, 10, 25 y 50 desbloquean Z, X, C y V; 75 permite el Despertar; 100, la Transformación.
- E4-14. Por encima de 100 la maestría sigue sin dar poder (610 puntos por nivel; solo prestigio y aspectos).

Núcleos de Poder
- E4-15. Estructura: 4 habilidades + 1 pasiva; un Núcleo equipado; daño como porcentaje de la potencia del arma.
- E4-16. Presupuesto de referencia: Z 180% / 15 / 4 s; X 320% / 25 / 8 s; C 500% / 35 / 14 s; V 1.000% / 50 / 30 s.
- E4-17. Los 6 de lanzamiento: Prismático (luz), de Brasa (fuego), de Escarcha (hielo), de Tormenta (rayo), Sísmico (tierra) y Umbrío (sombra). El Prismático es el inicial.
- E4-18. Despertar: maestría 75 + misión + materiales de jefe; +15% de daño de habilidades (+8% en PvP) y un efecto por Núcleo. Nunca se vende.
- E4-19. Transformación: 20 s, +20% de daño y −20% de enfriamientos en PvE; 12 s, +10% y −10% en PvP; enfriamiento de 120 s.

Movilidad y anti-combo
- E4-20. Dash 12 studs; parpadeo 16 studs (12 con carga del 75% o más); esquiva 8 studs con 0,3 s de invulnerabilidad; bloqueo reduce un 70% el daño frontal.
- E4-21. Escalado de combo: golpes 1–4 al 100%, después 90 / 80 / 70 / 60 / 50%, mínimo 50%.
- E4-22. Control repetido en 10 s: 100% / 50% / 25% / inmune 6 s.
- E4-23. Tope de aturdimiento de 2,0 s en 4 s; Rompecadenas con 0,6 s de invulnerabilidad.
- E4-24. Ruptura: 1,5 s en PvP y 2,0 s en PvE; 8 s de inmunidad.
- E4-25. Cancelación de animaciones desde el 60%, con +50% de energía y máximo 1 cada 1,5 s.

Enemigos
- E4-26. Vida `PotZona × Dureza ×` 20 / 80 / 300 / 1.500 (Común / Élite / Guardián / Jefe).
- E4-27. Daño por golpe: 3 / 6 / 10 / 15% de la vida base del jugador de la zona; cada 1,5 / 1,8 / 2,2 / 2,5 s.
- E4-28. XP `0,72 × XP por acción ×` 1 / 3,5 / 10 / 60. Monedas `valor de zona ×` 1,35 / 5,4 / 16 / 60 (el jefe era 250; corregido por E6-10).
- E4-29. Mezcla de enemigos: 88% Común, 10% Élite, 2% Guardián. Enemigos de tutorial con la mitad de vida hasta el nivel 10.
- E4-30. El combatiente gana entre 1,00 y 1,07 veces lo que el minero equivalente.

Jefes
- E4-31. Tres fases (100–60–30%); avisos de 0,6 / 1,2 / 2,5 s; daños del 15 / 35 / 70%; ventana de vulnerabilidad de 6 s con +50% de daño; furia a los 12 minutos.
- E4-32. Escalado: vida `× (1 + 0,6 × (n − 1))`, daño `× (1 + 0,05 × (n − 1))`, de 1 a 8 jugadores.
- E4-33. Jefes del MVP: Capataz de Pizarra (zona 1), Madre Liquen (zona 2) y Leviatán de Salmuera (zona 3).
- E4-34. Recompensas: `60 × valor de zona` en monedas (corregido por E6-10), 3 materiales de jefe garantizados, 1 tirada extra; 3 derrotas con botín completo por jefe y día.

PvP
- E4-35. [SUSTITUIDO por E7-08] Vitalidad con `M = 1,5` en PvP.
- E4-36. Tope del 35% de la vida máxima por golpe; curación −50%.
- E4-37. Arenas 1v1, 2v2 y 3v3, igualadas por tramos de 100 niveles, con Elo (inicio 1.000, factor 32).
- E4-38. Zonas Fracturadas: escuadrones de hasta 3, sin fuego amigo; potencia limitada a la de un Ultra raro de la zona al máximo.

Controles
- E4-39. Esquemas de PC, móvil y consola definidos en B4, sección 9, todos reasignables.

---

## 9. Valores de la Etapa 5 — B5_Mascotas.md (todos [PROVISIONAL] salvo los marcados)

Nivel
- E5-01. `XPp(n) = techo(15 + 3·n + 0,09·n²)`; nivel máximo 100; 45.936 de XP en total.
- E5-02. Multiplicadores por nivel: daño `1 + 0,015 × (n − 1)`; velocidad de ataque `1 + 0,002 × (n − 1)`; utilidad `1 + 0,005 × (n − 1)`.
- E5-03. XP de mascota: enemigos 2 / 8 / 24 / 160; depósitos 2 / 3 / 4 / 6 / 9 / 14 / 22; Nido al 15% con 2 huecos.
- E5-04. Ritmo: nivel 50 en 11–12 horas; nivel 100 en 65–68 horas.

Evolución
- E5-05. Factor de fase: Cría ×1,00; Forma desatada ×1,25 (nivel 50); Forma desatada máxima ×1,50 (nivel 100).
- E5-06. Incubación por rareza: 10 / 20 / 40 / 90 / 180 / 360 / 720 minutos de juego.
- E5-07. Vínculos al liberar un duplicado: 1 / 2 / 4 / 8 / 16 / 32 / 64.
- E5-08. Coste de Desatada: Vínculos 5 / 8 / 12 / 20 / 32 / 50 / 80 y material de jefe 3 / 3 / 5 / 5 / 8 / 8 / 10.
- E5-09. Coste de Máxima: Vínculos 15 / 24 / 36 / 60 / 96 / 150 / 240; Catalizadores Míticos 1 / 1 / 2 / 2 / 4 / 4 / 6; gemas antiguas 0 / 0 / 1 / 1 / 2 / 3 / 5.

Fórmulas
- E5-10. `DPS = PotenciaArma × b × MultRareza × MultNivel × FactorFase × MultDominio × MultVelocidadNivel`.
- E5-11. `Vida = VidaBase(jugador) × h × MultRareza × (1 + 0,01 × (n − 1)) × FactorFase × MultDominio`; reaparece a los 20 s (30 s en Zona Fracturada).
- E5-12. Velocidad de ataque: 0,6–1,6 golpes por segundo según especie, máximo 2,0.
- E5-13. Roles (`b` / `h`): Atacante 0,030 / 0,40; Control 0,018 / 0,50; Tanque 0,015 / 1,00; Apoyo 0,010 / 0,50; Recolector 0,008 / 0,40.
- E5-14. Utilidad: `ValorBase × FactorFase × (1 + 0,005 × (n − 1)) × (1 + 1,5·D/(D + 1.000))`; no cuenta para el tope de DPS.
- E5-15. Valores base de utilidad: Tanque desvía 5% y da escudo del 2% cada 20 s (tope de desvío 30%); Apoyo cura 0,15% por segundo (tope 1%; 0,5% en PvP); Control reduce un 8% el daño enemigo (tope 25%); Recolector +4% de daño de pico (tope +20%).

Mascotas
- E5-16. Las 12 de lanzamiento: Topillo de Pizarra, Luciérnaga de Veta, Zorro de Ascua, Tortuga Geoda, Murciélago de Eco, Nutria Salina, Búho Boreal, Carnero de Magma, Mantis Vitral, Guiverno de Cuarzo, Ciervo Astral y Sierpe de Nova (resuelve P-F-08 de forma provisional).
- E5-17. Sin mascota Celestial de lanzamiento; se reserva para eventos.
- E5-18. Límites de recolección conjuntos: +20% de unidad extra, +30% de mochila, +12 studs de recogida.

Posturas
- E5-19. Tres posturas: Atacar (100% de daño), Recolectar (0%) y Proteger (60%).
- E5-20. Recogida automática a 12 studs; una mascota abre un Cofre de Saqueo en 4,5 s con el jugador a menos de 15 studs.
- E5-21. Cambio de postura cada 3 s; 6 s si hubo daño de otro jugador en los últimos 5 s.

Topes de DPS
- E5-22. Topes del 40% (PvE) y 25% (PvP y Zonas Fracturadas) [CONFIRMADO].
- E5-23. `DPSref = PotenciaArma × MultFuerza × 1,025 × MultMaestría × 1,75`, calculado por el servidor a partir de las estadísticas.
- E5-24. Aplicación: factor de escala + ventana deslizante de 5 s; las mascotas solo atacan con el jugador en combate; máximo 3 mascotas activas en PvP y Zonas Fracturadas.

Valor y espacios
- E5-25. Aporte de las mascotas a las monedas por hora: +9,1% (3 Atacantes) a +22,8% (Tanque + Apoyo + Control) en combate; +16,2% (3 Recolectores) en minería.
- E5-26. Espacios: 3 iniciales [CONFIRMADO]; el 4.º por misión a nivel 300; el 5.º a nivel 700; el 6.º de pago o por 60 Fragmentos de temporada.
- E5-27. El sexto espacio añade un 4,8% de monedas por hora en PvE y nada en PvP.
- E5-28. Almacén de 30 mascotas; incubadoras: 1 inicial, la 2.ª a nivel 200 y la 3.ª de pago.

---

## 10. Valores de la Etapa 6 — B6_Economia.md (todos [PROVISIONAL] salvo los marcados)

Unidad y recursos
- E6-01. Los precios se expresan en horas de ingreso de la zona, `I(z)`: media del minero y el combatiente equilibrados (4.830 en zona 1; 34.554 en zona 5; 404.434 en zona 10; unas 480 veces el valor de zona).
- E6-02. Seis recursos: monedas, minerales, Cristales, materiales de jefe, gemas antiguas y fragmentos Celestiales.
- E6-03. Los Cristales no se cambian por monedas ni compran cajas. Sin comercio entre jugadores en el lanzamiento.

Precios
- E6-04. Venta de mineral: `V(z) × FactorValor / Unidades` por unidad (`calculos/b6_precios_minerales.csv`).
- E6-05. Fabricar pico o arma: 0,3 / 0,6 / 1,2 / 2,5 / 5 / 10 / 20 horas de ingreso según rareza, más la receta de minerales (`calculos/b6_precios_equipo.csv`).
- E6-06. Mejoras: nivel `n` = `0,05 × n ×` coste base; ranura = 0,5 × base + 6 Gemas talladas; Despertar de habilidad = 1,5 × base + 4 Catalizadores. Total al máximo: 6,75 veces el base.
- E6-07. Venta de equipo al mercader: 10% del coste. Reciclar devuelve el 30% de los materiales de mejora.
- E6-08. Mochila: 80 / 100 / 120 / 140 / 160 / 180 / 200 unidades desde las zonas 2 / 3 / 4 / 5 / 6 / 8 / 10, por 0,5 / 1 / 2 / 3 / 5 / 8 / 12 horas.
- E6-09. Consumibles: poción de vida 0,01 h; tónico de energía 0,01 h; Elixir de Suerte 0,10 h; Pergamino de XP 0,15 h; Baliza de extracción 0,05 h. Sin reparaciones ni durabilidad.
- E6-10. Monedas de jefe: `60 × V` por derrota (corrige B4; antes 250).
- E6-11. Evolución de mascotas: 2 horas (desatada) y 8 horas (máxima) por mascota. Forjar un Celestial: 60 fragmentos + 10 horas.
- E6-12. Aspectos de prestigio: 20 horas cada uno (sumidero de final de juego).
- E6-13. Reinicio de estadísticas: 1,5 horas de ingreso de la zona; gratis bajo nivel 50 (sustituye E2-07; cierra E3-36).

Cajas
- E6-14. Precios: Caja de armas 1,0 h; Caja de zona 0,6 h; Caja de mascotas 0,75 h de la zona más alta desbloqueada. Solo se compran con monedas.
- E6-15. Caja de armas: tipo 17 / 17 / 17 / 17 / 16 / 16% (Espada, Hacha, Daga, Lanza, Bastón, Arco); rareza estándar de B1.
- E6-16. Caja de mascotas: Topillo 25, Luciérnaga 25, Zorro 13, Tortuga 13, Murciélago 7, Nutria 7, Búho 3,5, Carnero 3,5, Mantis 1,2, Guiverno 1,2, Ciervo 0,5, Sierpe 0,1%.
- E6-17. Caja de zona: pico 35%, lote de minerales 40%, materiales 15%, consumibles 10%; después rareza estándar.
- E6-18. Caja de evento: solo con fichas de evento; tabla de B1; no admite Suerte.
- E6-19. Ninguna caja genera monedas: el contenido vale de media menos que el precio y la reventa devuelve el 10–42%.

Ingresos y límites
- E6-20. Gasto típico: consumibles 5% del ingreso, cajas 15%, equipo y mejoras el resto hasta el 58–93%.
- E6-21. Combatiente frente a minero (equilibrados): 1,02–1,06 (límite 1,3).
- E6-22. Zona Fracturada frente a PvE: 1,59–2,16 según muertes; máximo teórico 2,43 (límite 2,5).
- E6-23. Saqueador puro: 0,47 veces el PvE; se recompensa con reputación y cosméticos, no con monedas.

Zonas Fracturadas
- E6-24. Contenedor de grieta: mochila ×2 dentro de la Zona Fracturada (120 unidades base). Amplía B3.
- E6-25. Racha de extracción: +2% por extracción seguida, máximo +10% (×2,20); se pierde al morir.
- E6-26. Seguro de carga: 6 V por entrada; paga el 50% del valor base de lo soltado; 5 al día; nunca se vende por dinero real [CONFIRMADO].
- E6-27. Contratos de grieta: 3 diarios (0,20 horas de ingreso en total) y 1 semanal (2 gemas antiguas); nunca piden matar jugadores.
- E6-28. Se mantiene el 50% de carga soltada (P-01 sigue PROVISIONAL, validado frente al techo de 2,5).

Inflación
- E6-29. Simulación de 1.000 jugadores y 90 días: ahorro mediano estable en 3,4–4,5 horas de ingreso; 10% más rico en 9–11 horas; sin sumideros serían 57,5 horas.

Monetización
- E6-30. Se vende: cosméticos, pase de temporada, almacén de mascotas, tercera incubadora, Pergamino de XP, pestañas de banco y el sexto espacio de mascota (también ganable gratis).
- E6-31. Nunca se vende: Celestial, Núcleos Despertados, Seguro de carga [CONFIRMADO]; ni monedas, minerales, materiales de jefe, gemas antiguas, Suerte, cajas o ventajas PvP.
- E6-32. Sin recompensas aleatorias de pago en el lanzamiento. El servidor consulta `PolicyService` (`ArePaidRandomItemsRestricted`) y las cajas muestran sus probabilidades.
- E6-33. Política de Roblox consultada solo a través de resúmenes del buscador (16-11-2026); pendiente de releer las páginas oficiales antes de publicar.

---

## 11. Valores de la Etapa 7 — B7_Simulaciones.md (todos [PROVISIONAL])

Resultados
- E7-01. Perfiles propuestos de los jugadores A a G (niveles 1, 50, 100, 300, 500, 800 y 1.000); resuelve P-F-12 de forma provisional.
- E7-02. Ninguna build extrema rinde más de 1,17 veces la equilibrada en su mejor actividad.
- E7-03. Equipo Celestial al máximo: +5,8% de monedas frente a Ultra raro al máximo; 2,34 veces el equipo Común.
- E7-04. Saqueador profesional: 0,35–0,73 veces el minero PvE (0,48 en un servidor normal); confirma E6-23.
- E7-05. Minero de grieta con un saqueador por minero: 1,45 veces el PvE.
- E7-06. Traspaso de mineral entre cuentas: 1,20 (1,45 con seguro) frente a 2,00 extrayendo; no hay incentivo.
- E7-07. Diseño de mapa: salida o Punto de Extracción a menos de 150 studs de cualquier depósito de una Zona Fracturada.

Correcciones aplicadas a B2, B3 y B4
- E7-08. Vitalidad en PvP: `M = 1,0` (antes 1,5).
- E7-09. Defensa en PvP: `K = 4.500` y tope 50% (antes 3.000 y 60%).
- E7-10. Daño entre jugadores: `MultModo = 0,06` (antes 0,07). Duelos de 8–25 s; ventaja del Tanque sobre el Cristal de 1,33 (antes 1,69).
- E7-11. Tope de ráfaga en PvP: no más del 60% de la vida máxima en 2 s.
- E7-12. Golpes en área del ataque básico: máximo 3 objetivos; los secundarios reciben el 25%.
- E7-13. Grupos de enemigos: 70% solos, 25% parejas, 5% tríos; separación mínima de 20 studs.
- E7-14. Regeneración de vida en combate PvE: 0,5% de la vida máxima por segundo; no se aplica en PvP.
- E7-15. Desde el nivel 1.001: 1 punto de estadística por nivel (antes 3).
- E7-16. Zonas mayores que la 10: Minería requerida congelada en la de la zona 10 y dureza máxima 2,0.
- E7-17. Salir de una Zona Fracturada sin extraer: 3 s de canalización que el daño interrumpe; el mineral sale a ×1,0.

Expansión
- E7-18. La zona `z` se abre en el nivel `100 × (z − 1)`: los niveles 1.100, 1.200, 1.500 y 2.000 son las zonas 12, 13, 16 y 21.
- E7-19. Con los topes de E7-15 y E7-16, los tiempos se mantienen (3,8 s por depósito Común; 4,3–4,8 s por enemigo) y los números caben en un entero exacto.

Pendientes para la beta
- E7-20. Combate frente a minería al llegar a una zona con el arma anterior: minar rinde 1,34 veces (transitorio).
- E7-21. Los escuadrones de Tanques siguen ganando en 3 contra 3.
- E7-22. El tope total de 5.000 por estadística es inalcanzable hoy; se conserva para contenido futuro.

Índice
- E7-23. Fórmulas finales F1 a F36 en B7, sección 7.

---

## 12. Valores de la Etapa 8 — A_GDD.md (todos [PROVISIONAL])

Concepto y arte
- E8-01. Público: 10 a 16 años; móvil prioritario; sesiones de 20–40 minutos.
- E8-02. Seis pilares de diseño (A_GDD, sección 1.3).
- E8-03. Arte estilizado de pocos polígonos; mina oscura con minerales luminosos; paleta propia por zona; Zonas Fracturadas en tonos fríos con grietas violetas.
- E8-04. Límites de VFX: 60 partículas, 3 emisores y 2 luces por habilidad; 10 por mascota; tope en pantalla de 300 / 800 / 2.000 según calidad; 30 fotogramas por segundo en móvil de gama baja.
- E8-05. Los avisos de ataque nunca se reducen por calidad gráfica.

Mundo
- E8-06. Ciudad principal: Puerto Veta (zona segura).
- E8-07. Cuatro mundos: Superficie Quebrada (zonas 1–3), Hondonada de los Extremos (4–6), Abismo Negro (7–8) y Corazón Celeste (9–10); 40,7 / 100,4 / 93,1 / 110,4 horas.
- E8-08. Cada mundo es un lugar de Roblox distinto.

Eventos
- E8-09. Un evento aleatorio cada 25–40 minutos por servidor, uno activo a la vez: Lluvia de meteoritos, Veta colosal, Oleada de la profundidad y Grieta inestable; jefe de evento semanal.
- E8-10. Efecto medio de los eventos en los ingresos: +5,6%.

Cajas
- E8-11. Animación de apertura «la Geoda»: 3 golpes de pico, 2,5 s, se puede saltar, apertura de 10; el color es el de la rareza real desde el principio (sin falsos «casi»).

Retención
- E8-12. 3 misiones diarias (10% extra de monedas en total) y 5 semanales; sin castigo por no conectarse.
- E8-13. Temporadas de 8 semanas con pase de 50 niveles; 2 Fragmentos de temporada por nivel gratuito en los niveles 1–30 (60 en total); no caducan.
- E8-14. Logros y códice dan títulos, cosméticos y Cristales; nunca poder.
- E8-15. Renacimiento a nivel 1.000, máximo 10: +5% de XP y +10 puntos de estadística por renacimiento; se pierden nivel, puntos asignados y todas las monedas; se conserva todo lo demás.
- E8-16. Salvaguardas: sin ofertas con cuenta atrás de menos de 24 horas; aviso de descanso opcional a los 60 minutos.

MVP
- E8-17. MVP: Puerto Veta, mundo 1 (zonas 1–3), 19 minerales, 21 picos, 63 armas (Espada, Daga y Bastón), Núcleo Prismático, 6 mascotas, 3 jefes, 3 cajas, 1 arena de 1 contra 1 y la Zona Fracturada de la zona 3; 40,7 horas de contenido.

---

## 13. Valores de la Etapa 9 — C_Tecnico.md (todos [PROVISIONAL] salvo los marcados)

Proyecto
- E9-01. Proyecto de Rojo sobre la estructura existente (`src/shared`, `src/server`, `src/client`); renombrar el proyecto de `ECLIPSE` a `OREBOUND`.
- E9-02. Un lugar de Roblox por mundo más Puerto Veta, todos con el mismo código; mapas hechos en Studio.
- E9-03. Doce módulos de configuración en `Shared/Config`: Stats, Rarity, Mining, Pickaxes, Weapons, PowerCores, Pets, Economy, Boxes, Fracture, Worlds y PvP. Solo datos; claves en inglés.
- E9-04. Fórmulas F1 a F36 como funciones puras en `Shared/Formulas`.
- E9-05. 29 servicios de servidor, entre ellos FractureService, PowerCoreService, PetEvolutionService y PetCombatService; 13 controladores de cliente.
- E9-06. Una sola puerta por recurso: EconomyService para monedas e InventoryService para objetos y minerales.

Remotes
- E9-07. 43 Remotes del cliente al servidor y 13 del servidor al cliente; el cliente envía intenciones, nunca resultados.
- E9-08. Validación común: tipos y rangos, frecuencia, estado, propiedad.
- E9-09. Límites de frecuencia con un 25% de margen: atacar 5,7/s; picar 2,5/s; habilidad 1,8/s; bloqueo 2,5/s; esquiva 1,1/s; dash 0,5/s; postura 0,5/s; parpadeo 0,2/s.
- E9-10. Validación de movimiento: máximo 50 studs en 0,5 s, 65 en 1 s y 94 en 2 s.

Datos
- E9-11. Perfil versión 1 en una clave por jugador; tamaño estimado de 51 KB en el peor caso.
- E9-12. Migraciones encadenadas por número de versión; un perfil de versión futura no se carga.
- E9-13. Sesión bloqueada con `UpdateAsync`: caduca a los 30 minutos; reintento cada 5 s hasta 30 s; liberar antes de teletransportar.
- E9-14. Autoguardado cada 300 s; guardado inmediato tras compras con Robux, renacimiento, evolución, fabricación Legendaria o superior y extracción.
- E9-15. Registro de las últimas 200 aperturas de caja en el perfil, con los contadores A y B resultantes.
- E9-16. El servidor decide el premio y actualiza contadores antes de enviar el resultado al cliente [CONFIRMADO].
- E9-17. `ProcessReceipt` idempotente con los últimos 100 recibos.

Seguridad
- E9-18. Muerte PvP: cuenta quien hizo más daño en los últimos 10 s; desconectarse en combate se trata como muerte.
- E9-19. Las mascotas no tienen autoridad en el cliente; el tope de DPS se aplica en PetCombatService [CONFIRMADO el tope].
- E9-20. Alerta de analítica si un jugador gana más de 3 veces el ingreso de referencia de su zona en una hora.

Rendimiento
- E9-21. Prioridad de efectos: avisos de ataque, propios, jefe, otros jugadores, mascotas ajenas, ambiente.
- E9-22. Calidad automática: baja un nivel si la media cae por debajo de 25 fotogramas por segundo durante 10 s.
- E9-23. `StreamingEnabled` en todos los lugares; radio objetivo de 256 studs en móvil y 512 en PC.
- E9-24. IA de enemigos activa solo con un jugador a 120 studs o menos; un único bucle de mascotas a 10 Hz.

Pruebas
- E9-25. TestEZ con vectores de referencia exportados de los scripts de `calculos/`; ninguna fase se cierra con pruebas en rojo.

Sin verificar
- E9-26. Los límites de DataStore y MemoryStore citados no se han contrastado con la documentación de Roblox.

---

## 14. Valores de la Etapa 10 — D_Roadmap.md (todos [PROVISIONAL])

Fases
- E10-01. Nueve fases hasta el MVP: 1 Cimientos; 2 Progresión; 3 Minería y economía base; 4 Combate y Núcleos; 5 Fabricación, rarezas y cajas; 6 Mascotas; 7 Jefes y mundo 1; 8 PvP y Zonas Fracturadas; 9 Optimización, beta y lanzamiento. Resuelve P-F-11 de forma provisional.
- E10-02. Las fases 3 y 4, y la 5 y la 6, pueden ir en paralelo; la 8 no empieza hasta cerrar la 7.
- E10-03. Núcleos de Poder en la fase 4 (solo Prismático); Zonas Fracturadas en la fase 8 (zona 3 de prueba); evolución de mascotas preparada en la fase 6 y con contenido desde la expansión 1.
- E10-04. Expansiones: 1 = mundo 2, Despertar y forma desatada; 2 = mundo 3, temporadas, eventos y Celestial; 3 = mundo 4, Transformación y renacimiento; 4 en adelante = zonas por encima de la 10.
- E10-05. El roadmap no da fechas; cada fase lleva tamaño relativo y criterio de salida.

MVP
- E10-06. Fuera del MVP: ranuras de mejora, Despertar de habilidad, Celestial, forma desatada, eventos, temporadas, semanales, renacimiento, códice y escuadrones de 3.
- E10-07. Diez criterios de terminado (D_Roadmap, sección 2.2), entre ellos: 0 pérdidas de datos en 1.000 sesiones, 30 fotogramas por segundo en móvil de gama baja y tasa de Legendario o superior entre 3,9% y 4,9% con al menos 6.532 aperturas.

Pruebas
- E10-08. Margen del 25% para ritmos e ingresos; sin margen para los límites duros (tope de mascotas, 2,5 veces en Zonas Fracturadas, aturdimiento, sumas al 100% y garantías).
- E10-09. Objetivos del MVP: niveles 10 / 50 / 100 / 200 / 300 en 0,2 / 1,9 / 5,8 / 19,7 / 40,7 horas; ingresos de 4.830 / 7.966 / 12.816 monedas por hora en las zonas 1 / 2 / 3.
- E10-10. Beta en tres etapas: interna, cerrada (50–200 jugadores, datos borrables) y abierta (datos conservados).

Expansión
- E10-11. Una zona nueva solo necesita datos y arte: nombre, 6 o 7 minerales, prefijo de equipo, mapa y jefe; aporta entre 47 y 59 horas por cada 100 niveles.
- E10-12. Regla de presupuesto para Núcleos nuevos: entre el 125% y el 154% de la potencia del arma por segundo.

Coherencia
- E10-13. Precedencia: B7 sobre B1–B6; los archivos B sobre A; C y D siguen a los B; las series E sobre la sección 2.2 de este archivo.
- E10-14. Diez contradicciones abiertas listadas en D_Roadmap, sección 7.2. La principal: ningún documento se ha contrastado con el prompt maestro ni con el GDD original.
- E10-15. Pendiente de recalcular: B5, sección 7 (valor de las mascotas de utilidad), con la regeneración en combate de la Etapa 7.
- E10-16. Pendiente de fijar: total de gemas antiguas por semana, antes de la expansión 2.

---

## 15. Valores del GDD de combate, minería PvPvE y mascotas

Fuente: `00_Fuentes/GDD_combate_mineria_mascotas.pdf`. Contraste completo: `00_Fuentes/Contraste_GDD.md`. El GDD marca todas sus cifras como provisionales y pendientes de simulación. Estos valores mandan sobre las series E1 a E10. Los archivos A, B, C y D ya los reflejan (serie R, sección 16).

Rarezas y arte
- G-01. Nombres de las 7 rarezas confirmados: Común, Poco común, Raro, Épico, Legendario, Mítico y Ultra raro. Cierra P-F-03 en cuanto a nombres.
- G-02. Multiplicadores: 1,00 a 1,50 (Común a Raro); 1,90 a 2,50 (Épico y Legendario); 3,30 a 4,50 (Mítico y Ultra raro); 5,20 (Celestial). Se toma 1,00 / 1,25 / 1,50 / 1,90 / 2,50 / 3,30 / 4,50 / 5,20 (el 1,25 es supuesto). Sustituye E1-02.
- G-03. Colores: gris, verde, azul, morado, dorado, rojo, arcoíris (Ultra raro) y blanco perla con núcleo cian (Celestial).
- G-04. Tratamiento visual por rareza, con anuncio en el servidor desde Ultra raro y anuncio global en Celestial.
- G-05. Estilo: anime de alta gama con colores saturados; minas oscuras y desaturadas. Sustituye E8-03.
- G-06. Partículas: 2.000 en Alto y 800 en Bajo; efectos ajenos al 50% y apagados a más de 120 studs; distorsión, vibración y aberración desactivables. Sustituye E8-04.
- G-07. 50 fragmentos por objeto Celestial; caen en depósitos de Zonas Fracturadas de zona 6 o más (0,02% por depósito) y en jefes de evento. Sustituye E1-16 a E1-18.

Zonas Fracturadas
- G-08. Acceso con los mismos requisitos que la zona PvE; confirmación al entrar y borde rojo en la interfaz.
- G-09. 10 s de protección al entrar y al reaparecer, mientras no se ataque. Sustituye parte de E3-30.
- G-10. `Carga = valor transportado / (20 × valor base de la zona)`; `Ralentización = mín(0,40; 0,12 × ln(1 + Carga))`. Sustituye E3-25.
- G-11. Dash y parpadeo no se ralentizan; cuestan 25% más de energía con Carga 10 o más.
- G-12. Avisos: Carga 5, partículas visibles a 60 studs; Carga 10, minimapa de todos; Carga 30, anuncio en la zona.
- G-13. Se suelta el 50% [PROVISIONAL]; del cofre, el 80% es recogible y el 20% se destruye. Sustituye E3-26.
- G-14. Protección de novato: las 5 primeras entradas no sueltan carga al morir. Sustituye E3-30.
- G-15. Carga mínima protegida: por debajo de Carga 1 no se suelta nada.
- G-16. Puntos de Extracción: 8 s de canalización; el daño la reinicia; cambian de sitio cada 10 minutos. Sustituye E3-29.
- G-17. La interfaz muestra siempre carga, debuff y cuánto se perdería al morir.

Picos
- G-18. Pasivas de recolección: 1 menor (Común a Raro), 1 mayor (Épico y Legendario), 1 mayor + 1 menor (Mítico y Ultra raro), 1 única (Celestial). Sustituye E3-16.
- G-19. Estadística de combate: ninguna / +3% / +5% / +6% de defensa o velocidad de ataque, con tope PvP de +2% / +3% / +3%.
- G-20. Pasivas de ejemplo: Eco del filo (10% de golpear un segundo depósito), Lastre ligero (la carga cuenta 15% menos) y Sonar rúnico (revela depósitos ocultos a 30 studs).
- G-21. La zona 7 se llama «Minas oscuras».

Combate
- G-22. Las 4 ranuras mezclan habilidades del arma y del Núcleo. Sustituye E4-15 en ese punto.
- G-23. Cada Núcleo: área, control, movilidad y definitiva, más 1 pasiva. Los Núcleos tienen rareza.
- G-24. Núcleos: se obtienen en jefes, cajas de Núcleos, eventos y reliquias en depósitos profundos; cambiarlo fuera de la ciudad cuesta un consumible.
- G-25. Despertar con maestría 100 y materiales de jefe; desbloquea la Transformación. Sustituye E4-13 y E4-18.
- G-26. Transformación: 20 s, enfriamiento de 120 s, barra de Resonancia; bono de estadísticas de hasta 25% en PvE y 10% en PvP. Sustituye E4-19.
- G-27. Dash: 2 cargas, 20 de energía cada una, 3 s de recarga por carga. Sustituye E2-17 para el dash.
- G-28. Parpadeo: 12 studs, 30 de energía, 8 s; se desbloquea con Agilidad. Sustituye E4-20 para el parpadeo.
- G-29. Control repetido: ventana de 6 s; el segundo dura 50% y el tercero da 2 s de inmunidad (Tenacidad). Sustituye E4-22.
- G-30. Tope de aturdimiento de 2,5 s. Sustituye E4-23.
- G-31. Ruptura: tras 0,8 s bajo control, 50 de energía para liberarse y empujar; enfriamiento de 15 s. Sustituye E4-24.
- G-32. El dash cancela la recuperación de los ataques básicos, no la de las habilidades.
- G-33. Controles: bloqueo en F (PC) y LT; habilidades en X, Y, B y RB en consola; dash en Q (PC) y LB. Sustituye E4-39.
- G-34. Núcleo Prismático (Épico): Lanza Prismática (2,2× de daño, 20 de energía, 6 s), Campo de Refracción (14 studs, Refractado 6 s, 25, 12 s), Paso de Relámpago (18 o 10 studs, 25, 9 s), Prisma Total (cúpula de 6 s, 40, 60 s) y la pasiva Fragmentos de luz (los críticos devuelven 5 de energía). Transformación: Forma Prisma. Sustituye el conjunto de E4-17.

Mascotas
- G-35. Dos posturas: Recolectar (+50% de radio, −50% de daño) y Proteger (lo contrario); 5 s para cambiar. Sustituye E5-19 y E5-21.
- G-36. Radio de recogida de 20 studs. Sustituye E5-20.
- G-37. El huevo se incuba minando (por ejemplo, 500 golpes de pico). Sustituye E5-06.
- G-38. Cría (niveles 1–49): pasiva de recolección. Forma desatada (nivel 50 + materiales de su elemento): habilidad activa; tamaño ×1,8. Forma máxima (nivel 100 + material de jefe): ataque coordinado con el dueño. Sustituye E5-08 y E5-09.
- G-39. Roles: Defensa, Ofensiva, Control, Apoyo y Minería, con los ejemplos del GDD (escudo del 20% de la vida 5 s; ralentización del 30% 2 s; +15% de velocidad de ataque 6 s; +20% de velocidad de extracción 10 s). Sustituye E5-13 y E5-15.
- G-40. Guiverno de Cuarzo (Legendario): +15% de velocidad de extracción; Escudo Facetado (20% de la vida máxima 5 s por debajo del 50%; 30 s); Haz de Cuarzo coordinado.

Retención y riesgo
- G-41. Racha de extracción: ×1,1, ×1,2… hasta ×1,5; morir la reinicia. Sustituye E6-25.
- G-42. Contratos de grieta: extraer 3 cristales de una rareza o derrotar a 2 portadores con carga alta. Sustituye E6-27.
- G-43. Recompensa por cabeza: con racha de 5 o más el jugador queda marcado.
- G-44. Grieta Celestial: evento cada 2 horas, anunciado 5 minutos antes.
- G-45. Seguro de carga: consumible fabricable con minerales que protege el 50% de una carga; nunca con Robux. Sustituye E6-26.
- G-46. Escuadrones de hasta 3 con carga compartida y extracción más rápida.
- G-47. Rastro de venganza: quien te derrotó queda marcado 3 minutos.
- G-48. Temporadas de grieta de 8 semanas, con clasificación por valor extraído y premios cosméticos.
- G-49. Jefes de grieta cuando muchos jugadores luchan en la misma zona.
- G-50. Simulaciones pedidas en las zonas 2, 5 y 8.

Problemas detectados al simular el GDD (recomendaciones, pendientes de aplicar al rehacer)
- G-51. Multiplicadores de rareza: con crecimiento 1,65 y bonos de +100%, un Celestial de zona 6 al máximo supera a un Común de zona 10. Recomendación: crecimiento por zona 2,00 y tope de bonos +50%.
- G-52. Racha de ×1,5: con multiplicador base ×2,0 el máximo teórico es 3,17. Recomendación: base ×1,5 (máximo 2,38).
- G-53. Fragmentos al 0,02%: 960 horas por objeto. Recomendación: 0,25% (unas 77 horas).
- G-54. Anti-combo: hasta el 53% del tiempo bajo control. Recomendación: Tenacidad de 5 s (31%).
- G-55. Los requisitos de acceso no impiden que entre un nivel alto. Se mantiene la sincronización de nivel (E3-30).
- G-56. Calidad Baja con efectos ajenos al 50%: 865 partículas de 800. Recomendación: 40% (760).

Términos
- G-57. «Ruptura» es la liberación de un control (GDD). La guardia rota del diseño pasa a llamarse «Guardia rota»; «Rompecadenas» se elimina.
- G-58. La barra de la Transformación se llama Resonancia; se renombra la habilidad del pico Ultra raro que usaba ese nombre.
- G-59. «Paso de Relámpago» es del Núcleo Prismático; se renombra la habilidad del Núcleo de Tormenta.

Plan
- G-60. [HECHO] Rehechas las Etapas 1, 3, 4, 5, 6 y 7, retocada B2 y actualizados A, C y D.

---

## 16. Valores vigentes tras rehacer con el GDD (serie R)

Orden de precedencia: serie R y serie G sobre las series E1 a E10. Donde una entrada E no aparece sustituida aquí ni en la serie G, sigue vigente.

Estructura de trabajo
- R-01. Los archivos B1 a B7 los generan los scripts `calculos/b1` a `b7` a partir de `plantillas/`; cada script deja sus resultados en `calculos/_bN.json` para el siguiente. Hay que ejecutarlos en orden.

Rarezas y potencia (B1)
- R-02. Multiplicadores 1,00 / 1,25 / 1,50 / 1,90 / 2,50 / 3,30 / 4,50 / 5,20 (GDD; el 1,25 es supuesto).
- R-03. Crecimiento por zona 2,00 (potencia, valor de zona y vida base); tope de bonos +50% (nivel 25, ranuras 15, Despertar de habilidad 10). Sustituye E1-08, E1-09 y E2-11. Corrección al GDD.
- R-04. Un Común sin mejoras supera a cualquier objeto de 3 zonas atrás; rango dentro de una zona ×7,80.
- R-05. Celestial: 50 fragmentos (GDD); 0,25% por depósito de grieta de zona 6 o más (el GDD proponía 0,02%); ×4 en la Grieta Celestial; jefe de evento 2 fragmentos, 5 por semana.
- R-06. Sin cambios: tablas de caja y depósitos, Suerte y protección contra mala suerte (E1-03 a E1-06, E1-10 a E1-15).

Progresión (B2)
- R-07. `VidaBase(L) = 500 × 2,00^((L − 1)/100)`.
- R-08. Dash: 2 cargas, 20 de energía, 3 s de recarga (GDD). Parpadeo: 12 studs, 30 de energía, 8 s; se desbloquea con Velocidad 50 (propuesta para «Agilidad»). Ruptura: 50 de energía, 15 s.
- R-09. La esquiva no es una acción aparte: un dash en los 0,25 s previos a un golpe da 0,3 s de invulnerabilidad.
- R-10. Factor de habilidades de referencia ×1,39 (antes 1,75); con Energía 1.000, ×1,65.

Minería (B3)
- R-11. Potencia de pico requerida `0,5 × PotZona`. Zona 7: Minas Oscuras (GDD).
- R-12. Picos: pasivas menor, mayor o única y estadística de combate con tope PvP (GDD). Material Legendario renombrado a «Núcleo de mena».
- R-13. XP de depósito con factor 0,69 (calibrado por el script).
- R-14. Ingresos del minero equilibrado: 5.175 (zona 1) a 2.355.890 (zona 10) monedas por hora.
- R-15. Grieta: mineral ×1,5 por racha (×1,1 a ×1,5); debuff de carga del GDD; cofre 80/20; 10 s de protección; 5 entradas de novato; sin pérdida bajo Carga 1; puntos de extracción cada 10 minutos. Máximo teórico 2,38 veces el PvE.
- R-16. Se mantienen como añadidos: sincronización de nivel, mochila doble en grieta, misma víctima sin botín 10 minutos, salida con 3 s de canalización.

Combate (B4)
- R-17. Ranuras mixtas: 4 habilidades del Núcleo y 2 técnicas del arma (maestría 10 y 50); V solo admite la definitiva o la segunda técnica.
- R-18. Núcleo Prismático del GDD; daños propuestos para Campo (150%), Paso (120%) y Prisma Total (6 rayos del 100%). Total 72,5% de la potencia del arma por segundo.
- R-19. Los otros cinco Núcleos rehechos con la estructura del GDD (área, control, movilidad y definitiva); entre −13,6% y 0% del Prismático. Rarezas: Brasa y Escarcha Raro; Prismático y Tormenta Épico; Sísmico y Umbrío Legendario.
- R-20. Despertar y Transformación a maestría 100 (GDD); barra de Resonancia; +25% en PvE y tope del 10% en PvP.
- R-21. Anti-combo del GDD con Tenacidad de 5 s (el GDD proponía 2 s); tope de aturdimiento 2,5 s. «Guardia rota» sustituye al antiguo uso de «Ruptura».
- R-22. Enemigos: vida 16 / 64 / 240 / 1.200 × PotZona × dureza; monedas 1,40 / 5,60 / 16,80 / 60 × valor de zona; XP con factor 0,71.
- R-23. `MultModo = 0,062` en PvP; duelos de 8 a 24 s; ventaja del Tanque sobre el Cristal 1,27.
- R-24. Controles del GDD (bloqueo en F y LT; habilidades en X, Y, B y RB; dash en Q y LB).

Mascotas (B5)
- R-25. Dos posturas (GDD): Recolectar (radio ×1,5, daño ×0,5) y Proteger (radio ×0,5, daño ×1,5); radio base 20 studs; 5 s para cambiar.
- R-26. Roles y coeficientes: Ofensiva 0,016; Control 0,010; Defensa 0,008; Apoyo 0,005; Minería 0,004.
- R-27. Fases del GDD: cría (pasiva de recolección), desatada (habilidad activa), máxima (ataque coordinado). Incubación por golpes de pico: 500 a 30.000 según rareza.
- R-28. Evolución: fragmentos de su elemento 10 a 130 (desatada) y material de jefe 5 a 16 (máxima). Sustituye a los Vínculos.
- R-29. Utilidad con los valores del GDD (escudo del 20% 5 s cada 30 s; +15% de velocidad de ataque 6 s; ralentización del 30% 2 s; +20% de extracción 10 s); tope de +40% de velocidad de extracción.
- R-30. Guiverno de Cuarzo: rol Defensa con el conjunto del GDD.
- R-31. Aporte de las mascotas: +18% a +28% de monedas en combate y +15% a +22% en minería; sexto espacio +2,4%.

Economía (B6)
- R-32. Ingreso de referencia: 5.152 (zona 1) a 2.393.058 (zona 10); unas 490 veces el valor de zona.
- R-33. Cajas: de armas 1,0 h; de zona 0,6 h; de mascotas 0,75 h; de Núcleos 3,0 h (30 / 30 / 15 / 15 / 5 / 5%).
- R-34. Seguro de carga fabricable: 8 Lingotes Poco común y 1 Placa Raro; con él se suelta el 25%; 5 al día.
- R-35. Contratos: extraer rarezas o derrotar portadores con Carga 5 o más; el segundo se puede cambiar una vez al día.
- R-36. Eventos de grieta: recompensa por cabeza (racha 5; todo recogible), Grieta Celestial (cada 2 h, 10 min), rastro de venganza (3 min), jefes de grieta, escuadrones (extracción en 6 y 5 s).
- R-37. Límites: combatiente frente a minero 0,99–1,06; grieta 1,34–2,02 (máximo teórico 2,48); saqueador puro 0,42.
- R-38. Ahorro mediano en la simulación de 90 días: 3,5–4,7 horas de ingreso.

Simulaciones (B7)
- R-39. Ninguna build extrema supera 1,13 veces a la equilibrada.
- R-40. Equipo Celestial al máximo: +3,5% de monedas sobre Ultra raro al máximo.
- R-41. Saqueador profesional: 0,34–0,70 veces el minero PvE (0,47 en un servidor normal).
- R-42. Abierto: minería frente a combate al llegar a una zona con el arma anterior, 1,39.
- R-43. Los números caben hasta la zona 21; el margen se agota hacia la zona 34.

A, C y D
- R-44. Arte y VFX del GDD: anime de colores saturados; 2.000 partículas en Alto y 800 en Bajo; efectos ajenos al 50% (40% en Bajo, corrección); accesibilidad.
- R-45. MVP: se añade el Guiverno de Cuarzo (7 mascotas) para validar la sinergia con el Prismático, como pide el GDD.
- R-46. Especificación técnica: 13 módulos de configuración (se añade `VFX`), 46 Remotes del cliente, validación de movimiento de 65 / 94 / 122 studs en 0,5 / 1 / 2 s.
- R-47. Roadmap: prototipo de debuff de carga y extracción entre las fases 3 y 4.

Pendiente de decisión del autor
- R-48. Aceptar o revertir las seis correcciones a valores del GDD: crecimiento ×2,00 con bonos +50%; base de grieta ×1,5; fragmentos al 0,25%; Tenacidad de 5 s; sincronización de nivel; efectos ajenos al 40% en calidad Baja.

---

## 17. Registro de cambios
- 2026-11-16 · Etapa 0 (1/2): creación del archivo a partir del documento de prompts. Faltan las dos fuentes.
- 2026-11-16 · Etapa 0 cerrada: incongruencias del prompt resueltas (C-25 a C-34) y prompt corregido.
- 2026-11-16 · Etapa 1: valores E1-01 a E1-19.
- 2026-11-16 · Etapa 2: valores E2-01 a E2-18. B1 no cambia.
- 2026-11-16 · Etapa 3: valores E3-01 a E3-36. Precisa B1 (Suerte de depósitos de grupo); B2 no cambia todavía.
- 2026-11-16 · Etapa 4: valores E4-01 a E4-39. Confirma E2-12; B1, B2 y B3 no cambian.
- 2026-11-16 · Etapa 5: valores E5-01 a E5-28. B1 a B4 no cambian.
- 2026-11-16 · Etapa 6: valores E6-01 a E6-33. Corrige B4 (monedas de jefe), B2 (coste del reinicio) y amplía B3 (contenedor de grieta y racha).
- 2026-11-16 · Etapa 7: valores E7-01 a E7-23. Corrige B2 (Defensa y Vitalidad en PvP, puntos desde 1.001), B3 (topes de zonas mayores que 10, salida sin extraer) y B4 (daño PvP, ráfaga, golpes en área, grupos, regeneración). Documento B cerrado.
- 2026-11-16 · Etapa 8: valores E8-01 a E8-17. Los archivos B no cambian.
- 2026-11-16 · Etapa 9: valores E9-01 a E9-26. Los archivos A y B no cambian.
- 2026-11-16 · Etapa 10: valores E10-01 a E10-16. Correcciones de coherencia en B2 (nota en 9.1), B5 (×0,06 en F27), A_GDD (pilar 3) y E2-03. Diseño completo.
- 2026-11-16 · Recibido el GDD. Contraste en `00_Fuentes/Contraste_GDD.md`; valores G-01 a G-60. Los archivos A, B, C y D están pendientes de rehacer.
- 2026-11-16 · Rehecho con el GDD: B1, B3, B4, B5, B6 y B7 regenerados; B2 retocado; A, C y D actualizados. Valores R-01 a R-48.
