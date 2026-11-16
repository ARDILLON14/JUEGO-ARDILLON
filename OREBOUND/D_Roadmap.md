# OREBOUND — Documento D: Roadmap de producción

Etapa 10, rehecha con el GDD de combate, minería PvPvE y mascotas · 2026-11-16 · Cálculos de apoyo: `calculos/b10_roadmap.py`.

> **Fuentes.** Esta versión incorpora el GDD, incluidos sus «siguientes pasos». No se ha
> dispuesto de la sección 21 del prompt maestro: las 9 fases son propuestas **[PROVISIONAL]**.
> Los umbrales del plan de pruebas salen de los archivos B.
>
> **Sin fechas.** Este documento no da plazos: dependen del tamaño del equipo, que no se
> conoce. Cada fase lleva un tamaño relativo (S, M, L o XL) y un criterio de salida.

---

## 1. Orden de desarrollo

### 1.1 Las 9 fases hasta el lanzamiento del MVP

| Fase | Nombre | Qué se construye | Tamaño | Depende de |
|---|---|---|---|---|
| 1 | Cimientos | Proyecto de Rojo renombrado; `Shared/Config` (incluido `Fracture`, el «FractureConfig» que pide el GDD) y `Shared/Formulas` con sus pruebas; DataService con sesión bloqueada y migraciones; validador de Remotes y límite de frecuencia; AnalyticsService | L | — |
| 2 | Progresión | ProgressionService y StatsService: XP, niveles, puntos, estadísticas derivadas, energía; interfaz básica; reinicio de puntos | M | 1 |
| 3 | Minería y economía base | DepositService, MiningService, InventoryService, EconomyService, BankService; mochila; venta; picos con pasivas; zona 1 jugable de principio a fin | L | 2 |
| 4 | Combate y Núcleos | CombatService, EnemyService, armas (Espada, Daga y Bastón) con sus técnicas, ranuras mixtas, dash de 2 cargas, parpadeo, Ruptura y Tenacidad; **PowerCoreService con el Núcleo Prismático** y maestría | XL | 2 |
| 5 | Fabricación, rarezas y cajas | CraftingService, niveles de objeto; RarityService con Suerte; BoxService con protección contra mala suerte y registro; animación de la Geoda | L | 3 y 4 |
| 6 | Mascotas | PetService (huevo y cría, incubación por golpes, Nido, posturas Recolectar y Proteger, recogida automática); PetCombatService con el tope de DPS; **PetEvolutionService preparado**; Guiverno de Cuarzo | L | 3 y 4 |
| 7 | Jefes y mundo 1 | BossService y los 3 jefes; zonas 2 y 3; WorldService y teletransporte; tutorial; misiones diarias | XL | 4, 5 y 6 |
| 8 | PvP y Zonas Fracturadas | PvPService; ArenaService con 1 arena; **FractureService** con la grieta de la zona 3: debuff de carga, saqueo, cofres, extracción, racha, protección de novato, Seguro de carga y contratos | XL | 4 y 7 |
| 9 | Optimización, beta y lanzamiento | Rendimiento, calidad automática, ComplianceService, cosméticos y Cristales, beta cerrada y abierta | L | Todas |

### 1.2 Prototipos tempranos que pide el GDD

El GDD lista cinco «siguientes pasos». Tres son prototipos que conviene adelantar, porque son los mayores riesgos del diseño:

| Paso del GDD | Dónde encaja | Cuándo |
|---|---|---|
| Simular ingresos por hora (minero PvE, minero de grieta y saqueador) en las zonas 2, 5 y 8 | Hecho: B6, sección 4.2, y B7, sección 3.4 | — |
| Prototipar el debuff de carga y la extracción en la zona 1 con jugadores de prueba | Prototipo desechable al cerrar la fase 3, antes de construir FractureService | Entre las fases 3 y 4 |
| Construir un solo Núcleo (el Prismático) y una mascota (el Guiverno) para validar la sinergia y el tope de DPS | Fases 4 y 6; prueba conjunta al cerrar la fase 6 | Fin de la fase 6 |
| Medir el presupuesto de partículas en un móvil de gama media antes de producir más VFX | En cuanto existan los efectos del Prismático | Dentro de la fase 4 |
| Pasar todas las cifras a módulos de configuración | Fase 1 | Fase 1 |

### 1.3 Dónde entran los tres sistemas nuevos

| Sistema | Entra en | Qué entra | Qué queda para después |
|---|---|---|---|
| Núcleos de Poder | Fase 4 | PowerCoreService, Núcleo Prismático del GDD, ranuras mixtas con las técnicas del arma, maestría 1–100 | Los otros 5 Núcleos y las cajas de Núcleos (expansiones 1 a 3); Despertar y Transformación (expansión 1) |
| Zonas Fracturadas | Fase 8 | FractureService completo y 1 grieta de prueba (zona 3) | Las demás grietas; fragmentos Celestiales y Grieta Celestial (zona 6 o más); jefes de grieta; temporadas de grieta |
| Evolución de mascotas | Fase 6 | Servicio y datos preparados; huevo y cría con su pasiva de recolección | Forma desatada con habilidad activa (expansión 1); forma máxima con ataque coordinado (expansión 2) |

### 1.4 Dependencias entre sistemas

```
1 Cimientos
└─ 2 Progresión
   ├─ 3 Minería y economía ──┐
   └─ 4 Combate y Núcleos ───┼─ 5 Fabricación y cajas ─┐
                             └─ 6 Mascotas ────────────┼─ 7 Jefes y mundo 1 ─ 8 PvP y Zonas Fracturadas ─ 9 Beta
                                                       ┘
```

- Las fases 3 y 4 se pueden hacer en paralelo, igual que la 5 y la 6.
- La fase 8 no empieza hasta cerrar la 7: las Zonas Fracturadas usan a la vez minería, combate, mascotas y economía.
- Nada que dé o quite monedas se construye fuera de EconomyService.
- La sesión bloqueada y las migraciones van en la fase 1.

### 1.5 Después del lanzamiento

| Expansión | Contenido | Sistemas que se activan |
|---|---|---|
| 1 | Mundo 2 (zonas 4–6) con 3 jefes; Hacha y Lanza; Núcleos de Brasa y de Escarcha; Búho Boreal y Carnero de Magma | Despertar y Transformación; forma desatada; caja de Núcleos; grietas de las zonas 1, 2, 4, 5 y 6; escuadrones; arenas 2 contra 2 |
| 2 | Mundo 3 (zonas 7–8); Arco; Núcleos de Tormenta y Sísmico; Mantis Vitral | Temporadas de grieta; Grieta Celestial y fragmentos; jefes de evento y de grieta; forma desatada máxima; recompensa por cabeza y rastro de venganza |
| 3 | Mundo 4 (zonas 9–10); Núcleo Umbrío; Ciervo Astral y Sierpe de Nova | Renacimiento; arenas 3 contra 3; códice completo |
| 4 en adelante | Zonas por encima de la 10 (sección 5) | Ninguno nuevo |

---

## 2. MVP

### 2.1 Contenido exacto

| Elemento | Contenido | Fase |
|---|---|---|
| Mundo | Puerto Veta y el mundo 1, Superficie Quebrada | 7 |
| Zonas | 1 Cantera del Alba, 2 Galerías de Musgo y 3 Vetas Salinas (niveles 1–300) | 3 y 7 |
| Minerales | 19: los 6 de la zona 1, los 6 de la zona 2 y los 7 de la zona 3 (B3) | 3 y 7 |
| Picos | 21: 3 zonas × 7 rarezas, con pasivas menores y mayores y estadística de combate desde Épico | 3 y 5 |
| Armas | 63: Espada, Daga y Bastón × 3 zonas × 7 rarezas; 2 técnicas por tipo | 4 y 5 |
| Modelos de equipo | 12 modelos base (3 picos y 9 armas); la rareza cambia color y efecto | 3 y 4 |
| Núcleo | Prismático: Lanza Prismática, Campo de Refracción, Paso de Relámpago, Prisma Total y la pasiva Fragmentos de luz | 4 |
| Mascotas | 7: Topillo de Pizarra, Luciérnaga de Veta, Zorro de Ascua, Tortuga Geoda, Murciélago de Eco, Nutria Salina y el Guiverno de Cuarzo (recompensa del jefe de la zona 3); fases huevo y cría; 3 espacios; posturas Recolectar y Proteger | 6 y 7 |
| Jefes | Capataz de Pizarra, Madre Liquen y Leviatán de Salmuera, de 1 a 8 jugadores | 7 |
| Cajas | De armas, de zona y de mascotas, con protección contra mala suerte y la animación de la Geoda | 5 y 6 |
| Tienda | Mercader, forja (fabricar y niveles de objeto 1–10), banco, consumibles, ampliaciones de mochila de las zonas 2 y 3 | 3 y 5 |
| Guardado | Perfil versión 1 con sesión bloqueada, autoguardado y migraciones | 1 |
| Arena | 1 arena de 1 contra 1, igualada por tramos | 8 |
| Zona Fracturada | 1 de prueba: la de la zona 3, con debuff de carga, 3 posiciones de extracción, saqueo 80/20, racha, protección de novato, Seguro de carga y 3 contratos diarios | 8 |
| Retención | Tutorial hasta el nivel 10 y 3 misiones diarias | 7 |
| Monetización | Cosméticos y almacén de mascotas con Cristales | 9 |

**Fuera del MVP:** ranuras de mejora y Despertar de habilidad de objetos, Despertar y Transformación de Núcleos, cajas de Núcleos, equipo Celestial, forma desatada, Grieta Celestial, jefes de grieta, escuadrones, eventos, temporadas, misiones semanales, renacimiento, códice y los mundos 2 a 4.

**Duración:** 40,7 horas hasta el nivel 300.

### 2.2 Criterio para darlo por terminado

| # | Criterio | Cómo se comprueba |
|---|---|---|
| 1 | Un jugador nuevo puede ir del nivel 1 al 300 sin ayuda externa ni bloqueos | 5 jugadores de prueba completan el recorrido |
| 2 | Todas las pruebas automáticas de C_Tecnico, sección 9.1, pasan | Ejecución en el lugar de pruebas |
| 3 | Ninguna pérdida ni duplicación de datos en 1.000 sesiones de prueba, incluidos teletransportes y cierres de servidor | Prueba de carga con DataStore real |
| 4 | 30 fotogramas por segundo en un móvil de gama media en el peor caso (jefe con 8 jugadores) | Medición con el MicroProfiler |
| 5 | Los ritmos de la sección 3 están dentro del margen del 25% | Telemetría de la beta cerrada |
| 6 | La tasa real de Legendario o superior en cajas está entre 3,9% y 4,9% | Al menos 6.532 aperturas registradas |
| 7 | El tope de DPS de mascotas no se supera en ninguna ventana de 5 s | Prueba automática contra el servicio real |
| 8 | En la Zona Fracturada, ninguna derrota hace perder algo que no sea mineral | Prueba dirigida y revisión de registros |
| 9 | Más del 70% de los jugadores de la beta llegan al nivel 10 | Telemetría |
| 10 | La política de Roblox sobre recompensas aleatorias y los límites de DataStore se han releído en la documentación oficial | Revisión manual |

---

## 3. Plan de pruebas por fase

### 3.1 Qué se mide en cada fase

| Fase | Qué se mide | Valor objetivo | Qué hacer si falla |
|---|---|---|---|
| 1 | Pruebas de fórmulas contra los vectores de `calculos/` | 100% en verde | No avanzar |
| 1 | Sesión bloqueada con dos servidores simulados | 0 cargas simultáneas en 1.000 intentos | Corregir antes de la fase 2 |
| 2 | Tiempo hasta los niveles 10, 50 y 100 con XP simulada | 0,2 / 1,9 / 5,8 h | Ajustar la XP por acción (B2) |
| 3 | Segundos por depósito Común con el pico Común de la zona | 6,0 (aceptable 4,5–7,5) | Ajustar `FactorVida` o la dureza (B3) |
| 3 | Minutos por carga de mochila | 3,5 (aceptable 2,6–4,4) | Ajustar la capacidad base |
| 3 | Tiempo sin depósito libre con 8 mineros | Menos del 5% | Subir depósitos activos o bajar la regeneración |
| 3 | Monedas por hora en la zona 1 | 5.152 (aceptable 3.864–6.441) | Ajustar `FactorValor` |
| 3 | Prototipo de carga: un jugador con Carga 10 escapa con dash y parpadeo de otro sin carga | Escapa en más de la mitad de los intentos | Ajustar el factor 0,12 o el recargo de energía |
| 4 | Segundos por enemigo Común | 6,3 (aceptable 4,7–7,9) | Ajustar la vida de enemigo (B4) |
| 4 | Diferencia de tiempo entre Espada, Daga y Bastón contra el mismo enemigo | Menos del 10% | Ajustar coeficientes |
| 4 | Factor real de habilidades con el Prismático | ×1,39 (aceptable 1,2–1,6) | Ajustar los daños propuestos de sus habilidades |
| 4 | Tiempo máximo bajo control en prueba dirigida | No más de 2,5 s seguidos; no más del 31% del tiempo | Ajustar la Tenacidad |
| 4 | Combate frente a minería en monedas por hora, con equipo de la zona | Entre 0,77 y 1,30 | Ajustar monedas de enemigo o regeneración en combate |
| 4 | Partículas en un móvil de gama media con los efectos del Prismático | 30 fotogramas por segundo | Reducir efectos antes de producir más |
| 5 | Tasa de Legendario o superior en 100.000 aperturas simuladas en el servidor | 4,449% ± 0,2 | Revisar el orden de las garantías |
| 5 | Racha más larga sin Legendario o superior | Nunca más de 50 | Error de contadores |
| 5 | Horas hasta fabricar el arma Rara de la zona | 1,2 horas de ingreso (± 25%) | Ajustar precios (B6) |
| 6 | Daño de mascotas sobre el del jugador | Nunca más del 40% en PvE | Error en PetCombatService |
| 6 | Horas hasta mascota de nivel 50 | Unas 11 | Ajustar XP de mascota (B5) |
| 6 | Sinergia Prismático + Guiverno: los Haces de Cuarzo cuentan para el tope | Ninguna ventana de 5 s por encima del tope | Error en la ventana deslizante |
| 6 | Monedas por hora por composición de equipo de mascotas | Diferencia menor de 10 puntos entre equipos | Ajustar el escudo o la velocidad de extracción |
| 7 | Minutos por jefe en solitario | 7,9 (aceptable 5,9–9,9) | Ajustar vida del jefe |
| 7 | Minutos por jefe con 4 y con 8 jugadores | 5,5 y 5,1 | Ajustar el escalado (0,6 por jugador) |
| 7 | Derrotas por ataque letal en el primer intento del primer jefe | Menos del 50% de los jugadores | Alargar el aviso o aclarar la marca |
| 7 | Tiempo hasta los niveles 200 y 300 | 19,7 y 40,7 h (± 25%) | Ajustar XP por acción |
| 7 | Monedas por hora en las zonas 2 y 3 | 10.301 y 20.040 (± 25%) | Ajustar valores de zona |
| 7 | Tiempo que tarda un jugador en fabricar el arma de la zona al llegar | Menos de 2 horas de juego | Reforzar el tutorial de zona (B7, P5) |
| 8 | Segundos de duelo entre builds equilibradas | 17,9 (aceptable 13,4–22,4) | Ajustar `MultModo` |
| 8 | Tasa de victoria por build en la arena | Ninguna por encima del 60% | Revisar Vitalidad y Defensa en PvP |
| 8 | Probabilidad de caer por viaje en la Zona Fracturada | Entre el 15% y el 35% | Ajustar protecciones, cambio de punto o debuff de carga |
| 8 | Ingresos en Zona Fracturada frente a PvE | Entre 1,3 y 2,1; nunca más de 2,5 | Ajustar el multiplicador base o la racha |
| 8 | Extracciones interrumpidas | Entre el 20% y el 40% | Cambiar los puntos cada 5 minutos en lugar de 10 |
| 8 | Jugadores que vuelven a entrar tras su primera derrota con pérdida | Más del 50% | Bajar el 50% de carga soltada |
| 8 | Ingresos del saqueador puro frente al minero PvE | Entre 0,3 y 0,75 | Si supera 1,0, bajar lo recogible |
| 9 | Fotogramas por segundo en móvil de gama media, peor caso | 30 o más | Bajar topes de partículas o radio de streaming |
| 9 | Pasos de simulación del servidor con 20 jugadores | 30 por segundo o más | Reducir frecuencia de IA y de mascotas |
| 9 | Ahorro mediano de los jugadores | Entre 3 y 6 horas de ingreso | Añadir o suavizar sumideros (B6) |
| 9 | Abandono en la primera sesión | Menos del 50% antes del nivel 10 | Revisar tutorial y primeros 10 minutos |

### 3.2 Margen aceptado

- **Ritmos e ingresos:** ±25% sobre el valor de los archivos B.
- **Límites duros** (sin margen): tope de mascotas, tope de 2,5 veces en Zonas Fracturadas, tope de aturdimiento, sumas de probabilidad al 100% y garantías de caja.
- **Cuando una medida sale del margen:** se cambia primero el parámetro de configuración indicado y se vuelven a ejecutar los scripts `b1` a `b7` en orden, que regeneran los documentos B.

### 3.3 Telemetría mínima desde la fase 3

| Evento | Para qué |
|---|---|
| Depósito agotado y enemigo derrotado, con duración | Ritmos de acción |
| Monedas ganadas y gastadas, con motivo | Ingresos, sumideros e inflación |
| Subida de nivel, con tiempo de juego acumulado | Curva de XP |
| Apertura de caja, con rareza y contadores | Auditoría de tasas |
| Fabricación y mejora | Tiempos hasta cada objetivo |
| Derrota, con causa | Dificultad; derrotas PvP |
| Entrada, extracción, derrota y salida de Zona Fracturada, con Carga y racha | Riesgo real y rentabilidad |
| Duelo terminado, con builds, ranuras y duración | Balance PvP y uso de técnicas de arma |
| Fotogramas por segundo medios por sesión y dispositivo | Rendimiento |

---

## 4. Optimización y beta

### 4.1 Qué revisar antes de abrir el juego

**Rendimiento**

- [ ] Peor caso (jefe con 8 jugadores y 24 mascotas) a 30 fotogramas por segundo en móvil de gama media.
- [ ] Presupuesto de partículas respetado: 760 de 800 en Bajo, 865 de 1.400 en Medio y 865 de 2.000 en Alto.
- [ ] Distorsión, vibración y aberración se pueden desactivar.
- [ ] Calidad automática probada.
- [ ] Streaming: la sala de jefe y la Zona Fracturada no se cargan desde la zona PvE.
- [ ] Servidor de 20 jugadores estable con bots al ritmo máximo de Remotes (199 por segundo).

**Datos**

- [ ] Sesión bloqueada probada con teletransportes reales entre Puerto Veta y el mundo 1.
- [ ] `BindToClose` guarda todos los perfiles al cerrar un servidor.
- [ ] Una migración de prueba ejecutada sobre copias de perfiles reales de la beta.
- [ ] Límites de DataStore y MemoryStore comprobados en la documentación oficial.

**Seguridad**

- [ ] Los 46 Remotes del cliente probados con tipos erróneos, valores fuera de rango, exceso de frecuencia y objetos ajenos.
- [ ] Ningún Remote acepta daño, cantidades, precios ni probabilidades del cliente.
- [ ] Desconexión en combate PvP tratada como derrota.
- [ ] Alerta de ingresos anómalos activa.

**Economía y cajas**

- [ ] `b6_economia.py` ejecutado otra vez con los precios finales: ahorro mediano entre 3 y 6 horas.
- [ ] Probabilidades exactas y garantías visibles en cada caja antes de abrirla.
- [ ] Ninguna forma de convertir Cristales o Robux en monedas o cajas.
- [ ] `PolicyService` consultado al entrar; política de Roblox releída en su página oficial.

**Experiencia**

- [ ] Tutorial completo en menos de 10 minutos.
- [ ] Controles del GDD probados en móvil, PC y mando, y reasignables.
- [ ] Avisos de jefe legibles en calidad Baja y con filtros de daltonismo.
- [ ] Primera entrada a la Zona Fracturada: confirmación, borde rojo y explicación de qué se arriesga; aviso claro al terminar la protección de novato.
- [ ] La interfaz de grieta muestra carga, debuff y pérdida posible en todo momento.

### 4.2 Beta

| Etapa | Jugadores | Objetivo | Se cierra cuando |
|---|---|---|---|
| Interna | El equipo | Errores bloqueantes y flujo completo | Recorrido del nivel 1 al 300 sin bloqueos |
| Cerrada | 50–200 invitados | Ritmos, precios, tutorial y pérdida de datos | Criterios 1 a 9 de la sección 2.2 |
| Abierta | Sin límite, con aviso de beta | Carga real, PvP y Zona Fracturada con población | Dos semanas sin incidentes de datos y con las medidas de la fase 8 en rango |

- Los datos de la beta cerrada pueden borrarse; los de la abierta se conservan.
- Durante la beta, los valores de configuración pueden cambiar cada semana; se anuncia cada cambio.

---

## 5. Expansión sin rehacer los sistemas base

### 5.1 Zonas de nivel 1.100 a 2.000

Para añadir una zona hacen falta solo **datos y arte**:

| Qué añadir | Dónde | Cuánto |
|---|---|---|
| Nombre, paleta y jefe de la zona | `Config/Worlds` | 1 entrada |
| Minerales | `Config/Mining.Minerals` | 6 o 7 nombres |
| Prefijo de picos y armas | `Config/Pickaxes.ZonePrefix` | 1 nombre |
| Mapa, modelos de depósito y de equipo | Studio | 1 zona, 1 sala de jefe y 1 Zona Fracturada |
| Jefe | Script de patrones del jefe | 3 fases |

Lo que **no** hay que tocar: vida y valor de depósitos, vida y daño de enemigos, potencia y precio del equipo, requisitos, XP, cajas, tope de mascotas, reglas PvP y debuff de carga. Todo eso ya escala.

Parámetros que dejan preparada la expansión (B7): XP por nivel lineal por encima de 1.000; 1 punto de estadística por nivel desde el 1.001; Minería requerida y dureza congeladas desde la zona 10.

**Límite numérico:** con crecimiento ×2,00 por zona, las cifras caben sin perder precisión hasta la zona 21 (nivel 2.000) con un margen de casi 7.000 veces, y se agota hacia la zona 34. Antes hay que abreviar las cifras en pantalla; para ir más allá, reducir el crecimiento de las zonas nuevas.

Contenido que aporta cada zona nueva: entre 47 y 59 horas por cada 100 niveles.

### 5.2 Mundos nuevos

- Un mundo es un lugar de Roblox más y una entrada en `Config/Worlds`.
- Antes de publicarlo: prueba de teletransporte y de sesión bloqueada con el lugar nuevo.

### 5.3 Núcleos nuevos

- Un Núcleo es una entrada en `Config/PowerCores`: rareza, elemento, 4 habilidades (área, control, movilidad y definitiva) y 1 pasiva.
- **Regla de presupuesto:** el daño por segundo con todo en uso debe quedar entre el 63% y el 73% de la potencia del arma, como los seis actuales. El Prismático del GDD (72,5%) es el techo.
- Toda habilidad nueva pasa por la fórmula F19 y por los topes existentes.
- Antes de publicar: simulación de ráfaga contra el tope del 60% en 2 s.

### 5.4 Mascotas nuevas

- Una mascota es una entrada en `Config/Pets.Species`: rareza, elemento, rol, pasiva de recolección, habilidad activa y ataque coordinado.
- Debe usar uno de los cinco roles. Su daño entra en el tope conjunto y su utilidad en los topes de F30.
- Las mascotas Celestiales solo se entregan en eventos.

### 5.5 Temporadas

- Cada temporada de grieta es configuración en vivo: fechas, clasificación por valor extraído y premios cosméticos.
- Recompensas permitidas: cosméticos, Cristales, Fragmentos de temporada y fichas de evento. Nunca poder.

### 5.6 Regla general

Si un contenido nuevo obliga a cambiar una fórmula y no solo a añadir datos, se trata como un cambio de diseño: se cambia el parámetro en el script del archivo B afectado, se ejecutan `b1` a `b7` y se anota en `DECISIONES.md`.

---

## 6. Valores PROVISIONALES pendientes de probar

### 6.1 Pendientes de una decisión del autor

| Valor | Estado actual | Cómo decidirlo |
|---|---|---|
| Se suelta el 50% de la carga al ser derrotado por un jugador | Provisional desde el inicio y en el GDD | Beta, fase 8: porcentaje que vuelve a entrar tras su primera derrota con pérdida |
| Nombre «Núcleos de Poder» | Provisional | Prueba de comprensión con jugadores |
| Crecimiento por zona ×2,00 y bonos hasta +50% | Corrección propuesta a los multiplicadores del GDD | Alternativa: mantener 1,65 y aceptar que un objeto raro aguante 5 zonas |
| Multiplicador base de grieta ×1,5 | Propuesto para que quepa la racha del GDD | Alternativa: base ×2,0 y racha hasta ×1,2 |
| Fragmentos Celestiales al 0,25% por depósito | Sustituye al 0,02% del GDD | Semanas reales hasta el primer Celestial |
| Tenacidad de 5 s | Sustituye a los 2 s del GDD | Arenas de prueba |
| Sincronización de nivel en las grietas | Añadido al GDD | Sin ella, un nivel 1.000 puede entrar en la grieta de la zona 1 |
| Daños de Campo de Refracción, Paso de Relámpago y Prisma Total | El GDD no los da | Medir el factor de habilidades real |
| Todo lo propuesto sin fuente: octava estadística, sexto tipo de arma, minerales, 11 mascotas, jefes, mundos | Propuesto por el equipo | Contrastar con el prompt maestro cuando esté disponible |
| Perder todas las monedas al renacer | Propuesto | Alternativa: perder la mitad |
| Vender el sexto espacio de mascota | Propuesto | Da +2,4% de monedas en PvE |

### 6.2 Pendientes de prueba con jugadores

| Valor | Archivo | Cómo probarlo | Señal de alarma |
|---|---|---|---|
| 240 acciones por hora | B2 | Depósitos y enemigos por hora | Fuera de 180–300 |
| XP por acción | B2 | Horas reales hasta los niveles 100 y 300 | Fuera de 4,4–7,3 h y de 30,5–50,9 h |
| Curva de estadísticas (`M = 3`, `K = 1.000`) | B2 | Reparto real de puntos | Más del 60% de los jugadores con la misma build |
| Topes de Defensa (75% y 50%) | B2 | Derrotas por hora y duración de duelos | Jugadores que no caen nunca o duelos de más de 40 s |
| Energía: costes, pausa, cargas de dash y Ruptura | B2 | Tiempo sin poder actuar por falta de energía | Más de 5 s seguidos en un combate normal |
| Multiplicadores de rareza del GDD | B1 | Ingresos por rareza de equipo en la misma zona | Equipo Ultra raro por encima de 3 veces el Común |
| `FactorVida` de depósitos y dureza | B3 | Segundos por depósito | Fuera de 4,5–7,5 s |
| 40 depósitos y 45 s de regeneración | B3 | Tiempo sin depósito libre | Más del 5% |
| Pasivas y estadística de combate de los picos | B3 | Pasivas elegidas y uso del pico en PvP | Una pasiva elegida por más del 70% |
| Debuff de carga del GDD | B3 | Escapes con Carga 5, 10 y 30 | Menos del 20% de escapes con Carga 10 |
| Protección de novato (5 entradas) | B3 | Abandono tras la sexta entrada | Más del 50% no vuelve |
| Cambio de punto de extracción cada 10 minutos | B3 | Extracciones interrumpidas | Más del 40% |
| Coeficientes de arma y técnicas | B4 | Tiempo por enemigo con cada tipo y combinación de ranuras | Diferencia mayor del 10%; una combinación usada por más del 70% |
| Vida y daño de enemigos | B4 | Segundos por enemigo y derrotas por hora | Fuera de 4,7–7,9 s; más de 2 derrotas por hora |
| Daño de los Núcleos propuestos | B4 | Uso de cada Núcleo | Menos del 10% de uso |
| `MultModo = 0,062` y topes PvP | B4 | Duración de duelos | Fuera de 8–25 s |
| Vitalidad y Defensa en PvP | B4, B7 | Tasa de victoria por build; 3 contra 3 | Una build por encima del 60% |
| Golpes en área al 25% | B4, B7 | Enemigos por hora con Hacha frente a Daga | Diferencia mayor del 15% |
| Regeneración del 0,5% en combate | B4, B7 | Combate frente a minería para niveles 50–150 | Minería por encima de 1,3 veces con equipo de la zona |
| Coeficientes de rol y posturas de mascota | B5 | Daño real de mascotas por postura | Tope alcanzado antes del nivel 300 |
| Escudo, velocidad de ataque, ralentización y extracción de mascotas | B5 | Monedas por hora por composición | Un equipo más de 10 puntos por encima del resto |
| Incubación por golpes de pico | B5 | Horas reales hasta eclosionar | Más del doble de lo previsto |
| Precios en horas de ingreso | B6 | Horas reales hasta cada objetivo | Desviación mayor del 25% |
| Racha hasta ×1,5 | B6 | Ingresos en Zona Fracturada frente a PvE | Por debajo de 1,2 o por encima de 2,5 |
| Seguro de carga fabricable | B6 | Proporción de entradas aseguradas | Menos del 5%: abaratar la receta |
| Contratos de derrotar portadores | B6 | Proporción de contratos cambiados | Más del 60% los cambia: retirarlos |
| Ingresos del saqueador | B6, B7 | Monedas por hora de los jugadores con más derrotas PvP | Por encima de 1,0 veces el minero PvE |
| Cajas de Núcleos | B6 | Aperturas hasta completar los seis | Menos de 15 de media |
| Suerte (`Fmax = 3`) | B1 | Ingresos de builds de Suerte | Por encima de 1,3 veces |
| Topes de partículas del GDD | A, C | Fotogramas por segundo por dispositivo | Menos de 30 en gama media |
| Renacimiento | A | Porcentaje de jugadores de nivel 1.000 que renacen | Menos del 20% |

### 6.3 Pendientes de verificación documental

| Valor | Qué falta |
|---|---|
| Política de Roblox sobre recompensas aleatorias de pago y `PolicyService` | Releer las páginas oficiales; solo se consultaron resúmenes (B6, sección 9.3). El GDD también lo pide |
| Límites de DataStore y MemoryStore | Comprobar en la documentación |
| Prompt maestro (secciones 1, 3–15, 17, 19–21 y 23) | No se ha visto: contrastar el diseño cuando esté disponible |

---

## 7. Revisión de coherencia entre A, B, C y D

Regla de precedencia: **el GDD manda sobre las propuestas, salvo en las seis correcciones documentadas**; **B7 manda sobre B1–B6**; **los archivos B mandan sobre A**; **C y D siguen a los B**.

### 7.1 Estado tras rehacer con el GDD

- Los siete archivos B se generan ahora con sus scripts (`b1` a `b7`), que se pasan los resultados entre sí. Un cambio de parámetro se propaga solo al volver a ejecutarlos.
- A, C y D se han reescrito o actualizado a mano con los valores finales de los archivos B.
- El contraste completo con el GDD está en `00_Fuentes/Contraste_GDD.md`.

### 7.2 Comprobaciones hechas sin encontrar diferencias

- Multiplicadores de rareza, crecimiento ×2,00 y tope de bonos +50%: iguales en B1, B3, B4, B7, A y C.
- Reglas de grieta (×1,5, racha hasta ×1,5, 50% soltado, 80% recogible, 10 s de protección, 5 entradas de novato, 8 s de extracción, cambio cada 10 minutos, debuff logarítmico): iguales en B3, B6, B7, A y C.
- Reglas PvP (×0,062, Vitalidad `M = 1,0`, Defensa 4.500 y 50%, topes del 35% y del 60% en 2 s): iguales en B4, B7, A y C.
- Anti-combo (ventana de 6 s, Tenacidad de 5 s, tope de 2,5 s, Ruptura de 50 de energía): igual en B2, B4, A y C.
- Núcleo Prismático, Despertar a maestría 100 y Transformación de 20 s y 120 s: iguales en B4, A y C.
- Mascotas (dos posturas, radio de 20 studs, fases y roles del GDD, topes del 40% y 25%, factor de referencia ×1,39): iguales en B5, B7, A y C.
- Tablas de cajas y protección contra mala suerte: iguales en B1, B6, A y C; todas suman 100.
- Contenido del MVP: igual en A y D.

### 7.3 Contradicciones y pendientes que quedan

| # | Entre | Qué queda | Resolución |
|---|---|---|---|
| 1 | Diseño y prompt maestro | Nada se ha contrastado con el prompt maestro | Es la mayor incertidumbre. Al recibirlo: repetir el contraste y cambiar los parámetros en los scripts |
| 2 | Diseño y GDD | Seis valores del GDD se han corregido (sección 6.1) | Decisión del autor: aceptar las correcciones o volver al valor del GDD, que se cambia en una línea de script |
| 3 | B2 | Las secciones 9.1 y P1 de B2 conservan el cálculo PvP original (señalado en el texto) y hablan de «esquiva» como acción aparte | Históricas. Vigente: sección 8 de B2 y B4 |
| 4 | B4 y B7 | La tabla de ritmo del combatiente de B4 no incluye el tiempo parado ni el equipo atrasado; B7 sí | Manda B7 |
| 5 | B6 y B7 | B6 da combatiente frente a minero en 0,99–1,06; B7 da hasta 1,39 a favor de la minería al llegar a una zona con el arma anterior | No miden lo mismo. Manda B7; es transitorio (B7, P5) |
| 6 | B1 y B3 | La Suerte de depósitos es la media de la zona (B3); B7 simula con la Suerte propia | Equivale a jugar solo. Manda B3 |
| 7 | A y B6 | El total de gemas antiguas por semana no está calculado | Fijarlo antes de la expansión 2 |
| 8 | B4 | Las técnicas de arma y los cinco Núcleos propuestos no se han simulado en combate real | Beta de la fase 4 |
| 9 | DECISIONES | Las series E1 a E10 son de la primera versión | Mandan la serie G (GDD) y la serie R (rehecho); ver `DECISIONES.md` |
