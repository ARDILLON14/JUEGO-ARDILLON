# OREBOUND — DECISIONES.md

Versión: Etapa 3 · 2026-11-16

> **Estado de las fuentes.** Este archivo se ha construido solo con el documento
> «OREBOUND — Prompts por partes» (prompt único con continuidad + partes 0 a 10).
> **No se han recibido** `prompt_maestro.txt` ni `GDD_combate_mineria_mascotas.pdf`.
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
- E2-03. Ajuste recomendado: XP por acción `25 + 3,75·L + 0,002·L²` → 344,6 horas a nivel 1.000.
- E2-04. Por encima de 1.000: `XP(L) = 820.100 + 900 × (L − 1.000)` (cola lineal); unas 95 horas por cada 100 niveles.

Puntos de estadística
- E2-05. 3 puntos por nivel: `Puntos(L) = 3 + 3 × (L − 1)`; 3.000 a nivel 1.000.
- E2-06. Tope de 1.000 puntos asignados por estadística; tope de 5.000 de valor total con equipo.
- E2-07. Reinicio completo en la ciudad: gratis bajo nivel 50; después `1.000 × nivel` monedas. Objeto «Tomo de Reajuste» para un reinicio gratis.

Estadísticas
- E2-08. Las 8: Fuerza, Vitalidad, Defensa, Velocidad, Energía, Minería, Suerte y Dominio de mascotas (Energía es la octava propuesta; resuelve P-F-05 de forma provisional).
- E2-09. Curva común: `Mult(S) = 1 + M × S/(S + 1.000)`. Sustituye a la raíz cuadrada (P-06).
- E2-10. `M` por efecto: Fuerza 3; Vitalidad 3; Minería 3; Suerte 3; Dominio (daño y vida de mascota) 3; Dominio (recolección) 1,5; Velocidad de ataque 0,8; Velocidad de movimiento 0,5 (WalkSpeed máximo 24); regeneración de Energía 1.
- E2-11. `VidaBase(L) = 500 × 1,65^((L − 1)/100)`.
- E2-12. En PvP y Zonas Fracturadas la Vitalidad usa `M = 1,5` (recomendación; la Etapa 4 la confirma).

Defensa
- E2-13. `Reducción = mín(D/(D + K), Tope)`. PvE: `K = 1.500`, tope 75%. PvP y Zonas Fracturadas: `K = 3.000`, tope 60%.

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

## 8. Registro de cambios
- 2026-11-16 · Etapa 0 (1/2): creación del archivo a partir del documento de prompts. Faltan las dos fuentes.
- 2026-11-16 · Etapa 0 cerrada: incongruencias del prompt resueltas (C-25 a C-34) y prompt corregido.
- 2026-11-16 · Etapa 1: valores E1-01 a E1-19.
- 2026-11-16 · Etapa 2: valores E2-01 a E2-18. B1 no cambia.
- 2026-11-16 · Etapa 3: valores E3-01 a E3-36. Precisa B1 (Suerte de depósitos de grupo); B2 no cambia todavía.
