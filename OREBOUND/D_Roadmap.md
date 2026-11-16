# OREBOUND — Documento D: Roadmap de producción

Etapa 10 · 2026-11-16 · Cálculos de apoyo: `calculos/b10_roadmap.py`.

> **Aviso de fuentes.** No se ha dispuesto de la sección 21 del prompt maestro: las 9 fases
> son propuestas **[PROVISIONAL]**. Del prompt de trabajo solo se sabe que son 9 y qué debe
> contener el MVP. Los umbrales del plan de pruebas salen de los archivos B.
>
> **Sin fechas.** Este documento no da plazos: dependen del tamaño del equipo, que no se
> conoce. Cada fase lleva un tamaño relativo (S, M, L o XL) y un criterio de salida.

---

## 1. Orden de desarrollo

### 1.1 Las 9 fases hasta el lanzamiento del MVP

| Fase | Nombre | Qué se construye | Tamaño | Depende de |
|---|---|---|---|---|
| 1 | Cimientos | Proyecto de Rojo renombrado; `Shared/Config` y `Shared/Formulas` con sus pruebas; DataService con sesión bloqueada y migraciones; validador de Remotes y límite de frecuencia; AnalyticsService | L | — |
| 2 | Progresión | ProgressionService y StatsService: XP, niveles, puntos, estadísticas derivadas, energía; HUD básico; reinicio de puntos | M | 1 |
| 3 | Minería y economía base | DepositService, MiningService, InventoryService, EconomyService, BankService; mochila; venta; zona 1 jugable de principio a fin | L | 2 |
| 4 | Combate y Núcleos | CombatService, EnemyService, armas (Espada, Daga y Bastón), movilidad, anti-combo; **PowerCoreService con el Núcleo Prismático** y maestría | XL | 2 |
| 5 | Fabricación, rarezas y cajas | CraftingService, niveles de objeto; RarityService con Suerte; BoxService con protección contra mala suerte y registro; animación de la Geoda | L | 3 y 4 |
| 6 | Mascotas | PetService (huevo y cría, incubación, Nido, posturas); PetCombatService con el tope de DPS; **PetEvolutionService preparado pero sin contenido** | L | 3 y 4 |
| 7 | Jefes y mundo 1 | BossService y los 3 jefes; zonas 2 y 3; WorldService y teletransporte entre Puerto Veta y el mundo 1; tutorial; misiones diarias | XL | 4, 5 y 6 |
| 8 | PvP y Zonas Fracturadas | PvPService; ArenaService con 1 arena de 1 contra 1; **FractureService** con la Zona Fracturada de la zona 3: carga, saqueo, cofres, extracción, racha, seguro y contratos | XL | 4 y 7 |
| 9 | Optimización, beta y lanzamiento | Rendimiento, calidad automática, ComplianceService, cosméticos y Cristales, beta cerrada y abierta | L | Todas |

### 1.2 Dónde entran los tres sistemas nuevos

| Sistema | Entra en | Qué entra | Qué queda para después |
|---|---|---|---|
| Núcleos de Poder | Fase 4 | PowerCoreService, Núcleo Prismático con 4 habilidades y pasiva, maestría 1–100 | Los otros 5 Núcleos (expansión 1 y 2), Despertar (expansión 1), Transformación (expansión 3) |
| Zonas Fracturadas | Fase 8 | FractureService completo y 1 zona de prueba (zona 3) | Las Zonas Fracturadas de las zonas 1, 2 y 4–10; fragmentos Celestiales (zona 6 o más) |
| Evolución de mascotas | Fase 6 | Servicio y datos preparados; fases huevo y cría | Forma desatada (expansión 1) y forma máxima (expansión 2) |

### 1.3 Dependencias entre sistemas

```
1 Cimientos
└─ 2 Progresión
   ├─ 3 Minería y economía ──┐
   └─ 4 Combate y Núcleos ───┼─ 5 Fabricación y cajas ─┐
                             └─ 6 Mascotas ────────────┼─ 7 Jefes y mundo 1 ─ 8 PvP y Zonas Fracturadas ─ 9 Beta
                                                       ┘
```

- **Las fases 3 y 4 se pueden hacer en paralelo**, igual que la 5 y la 6.
- **La fase 8 no empieza hasta cerrar la 7:** las Zonas Fracturadas dependen de que minería, combate, mascotas y economía estén estables, porque las usan todas a la vez.
- **Nada que dé o quite monedas se construye fuera de EconomyService** (C_Tecnico, sección 3), ni siquiera de forma provisional.
- La sesión bloqueada y las migraciones van en la fase 1 y no después: añadirlas con jugadores reales es la forma más común de perder datos.

### 1.4 Después del lanzamiento

| Expansión | Contenido | Sistemas que se activan |
|---|---|---|
| 1 | Mundo 2 (zonas 4–6) con 3 jefes; Hacha y Lanza; Núcleos de Brasa y de Escarcha; mascotas Búho Boreal y Carnero de Magma | Despertar de Núcleos; forma desatada; Zonas Fracturadas de las zonas 1, 2, 4, 5 y 6; arenas 2 contra 2 |
| 2 | Mundo 3 (zonas 7–8); Arco; Núcleos de Tormenta y Sísmico; Mantis Vitral y Guiverno de Cuarzo | Temporadas; eventos aleatorios y jefe de evento; Celestial y fragmentos; forma desatada máxima |
| 3 | Mundo 4 (zonas 9–10); Núcleo Umbrío; Ciervo Astral y Sierpe de Nova | Transformación; renacimiento; arenas 3 contra 3; códice completo |
| 4 en adelante | Zonas por encima de la 10 (sección 5) | Ninguno nuevo |

---

## 2. MVP

### 2.1 Contenido exacto

| Elemento | Contenido | Fase |
|---|---|---|
| Mundo | Puerto Veta y el mundo 1, Superficie Quebrada | 7 |
| Zonas | 1 Cantera del Alba, 2 Galerías de Musgo y 3 Vetas Salinas (niveles 1–300) | 3 y 7 |
| Minerales | 19: los 6 de la zona 1, los 6 de la zona 2 y los 7 de la zona 3 (B3) | 3 y 7 |
| Picos | 21: 3 zonas × 7 rarezas | 3 y 5 |
| Armas | 63: Espada, Daga y Bastón × 3 zonas × 7 rarezas | 4 y 5 |
| Modelos de equipo | 12 modelos base (3 picos y 9 armas); la rareza cambia color y efecto | 3 y 4 |
| Núcleo | Prismático: Haz Facetado, Abanico Espectral, Prisma Centinela, Espectro Total y la pasiva Refracción | 4 |
| Mascotas | 6: Topillo de Pizarra, Luciérnaga de Veta, Zorro de Ascua, Tortuga Geoda, Murciélago de Eco y Nutria Salina; fases huevo y cría; 3 espacios | 6 |
| Jefes | Capataz de Pizarra, Madre Liquen y Leviatán de Salmuera, de 1 a 8 jugadores | 7 |
| Cajas | De armas, de zona y de mascotas, con protección contra mala suerte y la animación de la Geoda | 5 y 6 |
| Tienda | Mercader, forja (fabricar y niveles de objeto 1–10), banco, 4 consumibles, ampliaciones de mochila de las zonas 2 y 3 | 3 y 5 |
| Guardado | Perfil versión 1 con sesión bloqueada, autoguardado y migraciones | 1 |
| Arena | 1 arena de 1 contra 1, igualada por tramos | 8 |
| Zona Fracturada | 1 de prueba: la de la zona 3, con 3 Puntos de Extracción, seguro, racha y 3 contratos diarios | 8 |
| Retención | Tutorial hasta el nivel 10 y 3 misiones diarias | 7 |
| Monetización | Cosméticos y almacén de mascotas con Cristales | 9 |

**Fuera del MVP:** ranuras de mejora y Despertar de habilidad, equipo Celestial, forma desatada, eventos, temporadas, misiones semanales, renacimiento, códice, escuadrones de 3 y los mundos 2 a 4.

**Duración:** 40,7 horas hasta el nivel 300.

### 2.2 Criterio para darlo por terminado

El MVP está terminado cuando se cumplen **todos** estos puntos:

| # | Criterio | Cómo se comprueba |
|---|---|---|
| 1 | Un jugador nuevo puede ir del nivel 1 al 300 sin ayuda externa ni bloqueos | 5 jugadores de prueba completan el recorrido |
| 2 | Todas las pruebas automáticas de C_Tecnico, sección 9.1, pasan | Ejecución en el lugar de pruebas |
| 3 | Ninguna pérdida ni duplicación de datos en 1.000 sesiones de prueba, incluidos teletransportes y cierres de servidor | Prueba de carga con DataStore real en un lugar de pruebas |
| 4 | 30 fotogramas por segundo en un móvil de gama baja en el peor caso (jefe con 8 jugadores) | Medición en dispositivo |
| 5 | Los ritmos de la sección 3.2 están dentro del margen del 25% | Telemetría de la beta cerrada |
| 6 | La tasa real de Legendario o superior en cajas está entre 3,9% y 4,9% | Al menos 6.532 aperturas registradas |
| 7 | El tope de DPS de mascotas no se supera en ninguna ventana de 5 s | Prueba automática contra el servicio real |
| 8 | En la Zona Fracturada, ninguna muerte hace perder algo que no sea mineral | Prueba dirigida y revisión de registros |
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
| 3 | Monedas por hora en la zona 1 | 4.830 (aceptable 3.622–6.037) | Ajustar `FactorValor` |
| 4 | Segundos por enemigo Común | 6,4 (aceptable 4,8–8,0) | Ajustar la vida de enemigo (B4) |
| 4 | Diferencia de tiempo entre Espada, Daga y Bastón contra el mismo enemigo | Menos del 10% | Ajustar coeficientes |
| 4 | Aturdimiento máximo conseguido en prueba dirigida | No más de 2,0 s | Revisar rendimientos y Rompecadenas |
| 4 | Usos de habilidad en 120 s sin puntos en Energía | Alrededor del 56% de los posibles | Ajustar regeneración o costes (B2) |
| 4 | Combate frente a minería en monedas por hora | Entre 0,77 y 1,30 | Ajustar monedas de enemigo o regeneración en combate |
| 5 | Tasa de Legendario o superior en 100.000 aperturas simuladas en el servidor | 4,449% ± 0,2 | Revisar el orden de las garantías |
| 5 | Racha más larga sin Legendario o superior | Nunca más de 50 | Error de contadores |
| 5 | Horas hasta fabricar el arma Rara de la zona | 1,2 horas de ingreso (± 25%) | Ajustar precios (B6) |
| 6 | Daño de mascotas sobre el del jugador | Nunca más del 40% en PvE | Error en PetCombatService |
| 6 | Horas hasta mascota de nivel 50 | 11–12 | Ajustar XP de mascota (B5) |
| 6 | Monedas por hora con 3 Atacantes frente a 2 Atacantes y 1 Tanque | Diferencia menor de 10 puntos | Ajustar valores de utilidad |
| 7 | Minutos por jefe en solitario | 8,0 (aceptable 6,0–10,0) | Ajustar vida del jefe |
| 7 | Minutos por jefe con 4 y con 8 jugadores | 5,6 y 5,2 | Ajustar el escalado (0,6 por jugador) |
| 7 | Muertes por ataque letal en el primer intento del primer jefe | Menos del 50% de los jugadores | Alargar el aviso o aclarar la marca |
| 7 | Tiempo hasta los niveles 200 y 300 | 19,7 y 40,7 h (± 25%) | Ajustar XP por acción |
| 7 | Monedas por hora en las zonas 2 y 3 | 7.966 y 12.816 (± 25%) | Ajustar valores de zona |
| 8 | Segundos de duelo entre builds equilibradas | 18,8 (aceptable 14,1–23,5) | Ajustar `MultModo` |
| 8 | Tasa de victoria por build en la arena | Ninguna por encima del 60% | Revisar Vitalidad y Defensa en PvP (B7, P3) |
| 8 | Probabilidad de morir por viaje en la Zona Fracturada | Entre el 15% y el 35% | Ajustar rotación de extracción, escudos o debuff de carga |
| 8 | Ingresos en Zona Fracturada frente a PvE | Entre 1,5 y 2,2; nunca más de 2,5 | Ajustar el multiplicador o la racha |
| 8 | Extracciones interrumpidas | Entre el 20% y el 40% | Ajustar los 8 s de canalización |
| 8 | Jugadores que vuelven a entrar tras su primera muerte | Más del 50% | Bajar el 50% de carga soltada (C-33) |
| 8 | Ingresos del saqueador puro frente al minero PvE | Entre 0,35 y 0,75 | Si supera 1,0, bajar lo recogible |
| 9 | Fotogramas por segundo en móvil de gama baja, peor caso | 30 o más | Bajar topes de partículas o radio de streaming |
| 9 | Pasos de simulación del servidor con 20 jugadores | 30 por segundo o más | Reducir frecuencia de IA y de mascotas |
| 9 | Ahorro mediano de los jugadores | Entre 3 y 6 horas de ingreso | Añadir o suavizar sumideros (B6) |
| 9 | Abandono en la primera sesión | Menos del 50% antes del nivel 10 | Revisar tutorial y primeros 10 minutos |
| 9 | Retención al día siguiente y a los 7 días | Se fija tras la beta cerrada como línea base | Comparar con cada cambio |

### 3.2 Margen aceptado

- **Ritmos e ingresos:** ±25% sobre el valor de los archivos B. Dentro del margen no se toca nada.
- **Límites duros** (no admiten margen): tope de mascotas, tope de 2,5 veces en Zonas Fracturadas, tope de aturdimiento, sumas de probabilidad al 100% y garantías de caja.
- **Cuando una medida sale del margen:** se cambia primero el parámetro de configuración indicado; si eso no basta, se vuelve a ejecutar el script de Python correspondiente con el valor nuevo antes de tocar código.

### 3.3 Telemetría mínima desde la fase 3

Cada evento lleva nivel, zona y build resumida del jugador.

| Evento | Para qué |
|---|---|
| Depósito agotado y enemigo derrotado, con duración | Ritmos de acción |
| Monedas ganadas y gastadas, con motivo | Ingresos, sumideros e inflación |
| Subida de nivel, con tiempo de juego acumulado | Curva de XP |
| Apertura de caja, con rareza y contadores | Auditoría de tasas |
| Fabricación y mejora | Tiempos hasta cada objetivo |
| Muerte, con causa | Dificultad; muertes PvP |
| Entrada, extracción, muerte y salida de Zona Fracturada, con carga | Riesgo real y rentabilidad |
| Duelo terminado, con builds y duración | Balance PvP |
| Fotogramas por segundo medios por sesión y dispositivo | Rendimiento |

---

## 4. Optimización y beta

### 4.1 Qué revisar antes de abrir el juego

**Rendimiento**

- [ ] Peor caso (jefe con 8 jugadores y 24 mascotas) a 30 fotogramas por segundo en móvil de gama baja.
- [ ] Presupuesto de partículas respetado en los tres niveles de calidad: 273 de 300, 739 de 800 y 1.390 de 2.000.
- [ ] Calidad automática probada: baja de nivel tras 10 s por debajo de 25 fotogramas por segundo.
- [ ] Streaming: la sala de jefe y la Zona Fracturada no se cargan desde la zona PvE.
- [ ] Servidor de 20 jugadores estable con bots al ritmo máximo de Remotes.
- [ ] Memoria del cliente estable tras 60 minutos en móvil.

**Datos**

- [ ] Sesión bloqueada probada con teletransportes reales entre Puerto Veta y el mundo 1.
- [ ] `BindToClose` guarda todos los perfiles al cerrar un servidor.
- [ ] Una migración de prueba (versión 1 a 2) ejecutada sobre copias de perfiles reales de la beta.
- [ ] Límites de DataStore y MemoryStore comprobados en la documentación oficial.

**Seguridad**

- [ ] Los 43 Remotes del cliente probados con tipos erróneos, valores fuera de rango, exceso de frecuencia y objetos ajenos.
- [ ] Ningún Remote acepta daño, cantidades, precios ni probabilidades del cliente.
- [ ] Desconexión en combate PvP tratada como muerte.
- [ ] Alerta de ingresos anómalos activa.

**Economía y cajas**

- [ ] `b6_economia.py` ejecutado otra vez con los precios finales: ahorro mediano entre 3 y 6 horas.
- [ ] Probabilidades y garantías visibles en cada caja antes de abrirla.
- [ ] Ninguna forma de convertir Cristales o Robux en monedas o cajas.
- [ ] `PolicyService` consultado al entrar; política de Roblox releída en su página oficial.

**Experiencia**

- [ ] Tutorial completo en menos de 10 minutos.
- [ ] Controles de móvil, PC y mando probados y reasignables.
- [ ] Avisos de jefe legibles en calidad baja y con filtros de daltonismo.
- [ ] Primera entrada a la Zona Fracturada con aviso claro de qué se arriesga.

### 4.2 Beta

| Etapa | Jugadores | Objetivo | Se cierra cuando |
|---|---|---|---|
| Interna | El equipo | Errores bloqueantes y flujo completo | Recorrido del nivel 1 al 300 sin bloqueos |
| Cerrada | 50–200 invitados | Ritmos, precios, tutorial y pérdida de datos | Criterios 1 a 9 de la sección 2.2 |
| Abierta | Sin límite, con aviso de beta | Carga real, PvP y Zona Fracturada con población | Dos semanas sin incidentes de datos y con las medidas de la fase 8 en rango |

- Los datos de la beta cerrada pueden borrarse; se avisa antes de empezar.
- Los datos de la beta abierta se conservan: desde ese momento toda modificación del perfil pasa por una migración.
- Durante la beta, los valores de configuración pueden cambiar cada semana; se anuncia cada cambio.

---

## 5. Expansión sin rehacer los sistemas base

### 5.1 Zonas de nivel 1.100 a 2.000

Todo lo de una zona sale de su número `z` (B7, sección 4). Para añadir una zona hacen falta solo **datos y arte**:

| Qué añadir | Dónde | Cuánto |
|---|---|---|
| Nombre, paleta y jefe de la zona | `Config/Worlds` | 1 entrada |
| Minerales | `Config/Mining.Minerals` | 6 o 7 nombres |
| Prefijo de picos y armas | `Config/Pickaxes.ZonePrefix` | 1 nombre |
| Mapa, modelos de depósito y de equipo | Studio | 1 zona, 1 sala de jefe y 1 Zona Fracturada |
| Jefe | Script de patrones del jefe | 3 fases |

Lo que **no** hay que tocar: vida y valor de depósitos, vida y daño de enemigos, potencia y precio del equipo, requisitos, XP, cajas, tope de mascotas y reglas PvP. Todo eso ya escala.

Parámetros que ya dejan preparada la expansión (B7):

- XP por nivel lineal por encima de 1.000.
- 1 punto de estadística por nivel desde el 1.001.
- Minería requerida congelada en la de la zona 10 y dureza máxima 2,0.
- La zona `z` se abre en el nivel `100 × (z − 1)`.

Contenido que aporta cada zona nueva: entre 47 y 59 horas por cada 100 niveles.

### 5.2 Mundos nuevos

- Un mundo es un lugar de Roblox más y una entrada en `Config/Worlds`. El código es el mismo.
- Recomendación: 2 zonas por mundo a partir del mundo 5 (unas 100–115 horas por mundo).
- Antes de publicar un mundo: prueba de teletransporte y de sesión bloqueada con el lugar nuevo.

### 5.3 Núcleos nuevos

- Un Núcleo es una entrada en `Config/PowerCores` (4 habilidades con coeficiente, energía y enfriamiento, y 1 pasiva) más sus efectos.
- **Regla de presupuesto:** el daño por segundo con todo en uso debe quedar entre el 125% y el 154% de la potencia del arma, como los seis actuales. Un Núcleo con más control o defensa va en la parte baja.
- Toda habilidad nueva pasa por la fórmula F19 y por los topes existentes; no se añaden multiplicadores fuera de la fórmula.
- Antes de publicar: simulación de ráfaga contra el tope del 60% en 2 s y prueba de uso con energía.

### 5.4 Mascotas nuevas

- Una mascota es una entrada en `Config/Pets.Species`: rareza, elemento, rol y golpes por segundo.
- Debe usar uno de los cinco roles existentes. Su daño entra en el tope conjunto y su utilidad en los topes de F30, así que ninguna mascota nueva puede romper el balance por sí sola.
- Las mascotas Celestiales solo se entregan en eventos, nunca en cajas estándar.

### 5.5 Temporadas

- Cada temporada es configuración en vivo: identificador, fechas, 50 niveles de recompensas y un tema visual.
- Recompensas permitidas: cosméticos, Cristales, Fragmentos de temporada y fichas de evento. Nunca poder.
- La Caja de evento de la temporada puede cambiar de contenido, pero no de tabla de rarezas sin volver a ejecutar `b1_rarezas.py`.

### 5.6 Regla general

Si un contenido nuevo obliga a cambiar una fórmula y no solo a añadir datos, se trata como un cambio de diseño: se actualiza el archivo B afectado, se vuelve a ejecutar su script y B7, y se añade a `DECISIONES.md`.

---

## 6. Valores PROVISIONALES pendientes de probar

`DECISIONES.md` contiene 239 valores numerados de las etapas 1 a 9; casi todos son provisionales. Esta tabla agrupa los que más pueden cambiar el juego, por orden de prioridad.

### 6.1 Pendientes de una decisión del autor

| Valor | Estado actual | Cómo decidirlo |
|---|---|---|
| Se suelta el 50% de la carga al morir contra un jugador | Provisional desde el inicio (P-01) | Beta, fase 8: porcentaje que vuelve a entrar tras su primera muerte. Si es menor del 50%, bajar a 35% |
| Nombre «Núcleos de Poder» | Provisional desde el inicio (P-02) | Prueba de comprensión con jugadores y comprobación de que no coincide con otro juego |
| Todo lo propuesto sin fuente: nombres de rarezas, octava estadística, sexto tipo de arma, minerales, mascotas, jefes, mundos | Propuesto por el equipo | Contrastar con el prompt maestro y el GDD original cuando estén disponibles |
| Perder todas las monedas al renacer | Propuesto en la Etapa 8 | Decisión de diseño; alternativa, perder la mitad |
| Vender el sexto espacio de mascota | Propuesto en las Etapas 5 y 6 | Decisión de negocio; da +4,8% de monedas en PvE |

### 6.2 Pendientes de prueba con jugadores

| Valor | Archivo | Cómo probarlo | Señal de alarma |
|---|---|---|---|
| 240 acciones por hora | B2 | Telemetría de depósitos y enemigos por hora | Fuera de 180–300 |
| XP por acción `25 + 3,75·L + 0,002·L²` | B2 | Horas reales hasta los niveles 100 y 300 | Fuera de 4,4–7,3 h y de 30,5–50,9 h |
| Curva de estadísticas (`M = 3`, `K = 1.000`) | B2 | Reparto real de puntos entre estadísticas | Más del 60% de los jugadores con la misma build |
| Topes de Defensa (75% y 50%) | B2, B7 | Muertes por hora y duración de duelos | Jugadores que no mueren nunca o duelos de más de 40 s |
| Energía: costes, pausa y regeneración | B2 | Tiempo sin poder actuar por falta de energía | Más de 5 s seguidos en un combate normal |
| `FactorVida` de depósitos y dureza | B3 | Segundos por depósito | Fuera de 4,5–7,5 s |
| 40 depósitos y 45 s de regeneración | B3 | Tiempo sin depósito libre | Más del 5% |
| Minería requerida por rareza | B3 | Rareza máxima que pica cada build | Builds equilibradas que no llegan a Legendario |
| Coeficientes de arma | B4 | Tiempo por enemigo con cada tipo | Diferencia mayor del 10% |
| Vida y daño de enemigos | B4 | Segundos por enemigo y muertes por hora | Fuera de 4,8–8,0 s; más de 2 muertes por hora |
| Daño de los Núcleos de Escarcha y Sísmico | B4 | Uso de cada Núcleo en PvE | Menos del 10% de uso |
| `MultModo = 0,06` y topes PvP | B4, B7 | Duración de duelos | Fuera de 8–25 s |
| Vitalidad `M = 1,0` y Defensa `K = 4.500` en PvP | B7 | Tasa de victoria por build; resultado de 3 contra 3 | Una build por encima del 60% |
| Golpes en área al 25% | B7 | Enemigos por hora con Hacha frente a Daga | Diferencia mayor del 15% |
| Regeneración del 0,5% en combate | B7 | Combate frente a minería para jugadores de nivel 50–150 | Minería por encima de 1,3 veces |
| Coeficientes de rol de mascota | B5 | Daño real de mascotas sobre el del jugador | Menos del 3% o tope alcanzado antes del nivel 300 |
| Valores de utilidad de mascota | B5 | Monedas por hora por composición de equipo | Un equipo más de 10 puntos por encima del resto |
| Precios en horas de ingreso | B6 | Horas reales hasta cada objetivo de equipo | Desviación mayor del 25% |
| 15% del ingreso en cajas | B6 | Gasto real en cajas | Fuera del 5–25% |
| Mineral fracturado ×2,0 y racha | B3, B6 | Ingresos en Zona Fracturada frente a PvE | Por debajo de 1,3 o por encima de 2,5 |
| Rotación de 120 s y canalización de 8 s | B3 | Extracciones interrumpidas | Fuera del 20–40% |
| Escudo de novato | B3 | Abandono tras la primera entrada | Más del 50% no vuelve |
| Seguro de carga (6 V) | B6 | Entradas aseguradas y relación pago/prima | Fuera del 40–70% |
| Ingresos del saqueador | B6, B7 | Monedas por hora de los jugadores con más muertes PvP | Por encima de 1,0 veces el minero PvE |
| Suerte (`Fmax = 3`) | B1 | Ingresos de builds de Suerte frente a equilibradas | Por encima de 1,3 veces |
| Garantía de la apertura 100 | B1 | Tasa real de Ultra raro | Por encima de 0,30% |
| Fragmentos Celestiales (60 por objeto) | B1 | Semanas hasta el primer Celestial | Menos de 3 o más de 20 |
| Topes de partículas | A, C | Fotogramas por segundo por dispositivo | Menos de 30 en gama baja |
| Eventos (+5,6% de ingresos) | A | Participación e ingresos durante eventos | Más del 15% de ingresos extra |
| Renacimiento (+5% de XP, +10 puntos) | A | Porcentaje de jugadores de nivel 1.000 que renacen | Menos del 20% |

### 6.3 Pendientes de verificación documental

| Valor | Qué falta |
|---|---|
| Política de Roblox sobre recompensas aleatorias de pago y `PolicyService` | Releer las páginas oficiales; solo se consultaron resúmenes (B6, sección 9.3) |
| Límites de DataStore y MemoryStore | Comprobar en la documentación; se usó conocimiento general (C_Tecnico) |
| Secciones 1, 3–15, 17, 19–21 y 23 del prompt maestro | No se han visto: contrastar todo el diseño cuando estén disponibles |
| GDD de combate, minería PvPvE y mascotas | No se ha visto: valores del Núcleo Prismático, Guiverno de Cuarzo, Zonas Fracturadas, mejoras de retención y dirección de arte |

---

## 7. Revisión de coherencia entre A, B, C y D

Regla de precedencia: **B7 manda sobre B1–B6** donde difieran; **los archivos B mandan sobre A**; **C y D siguen a los B**.

### 7.1 Corregidas en esta etapa

| Dónde | Qué decía | Corrección |
|---|---|---|
| B5, F27 | Daño de mascota en PvP ×0,07 | ×0,06, como B4 y B7 |
| B2, sección 9.1 | Tabla de builds con vida efectiva PvP calculada con las reglas antiguas, sin aviso | Nota: es el cálculo original; los valores vigentes están en B7 |
| A, pilar 3 | «Minero y combatiente ganan casi lo mismo (1,02–1,06)» sin matiz | Añadido: hasta 1,34 a favor de la minería al llegar a una zona con el arma anterior |
| DECISIONES, E2-03 | Ajuste de XP por acción «recomendado» | Marcado como adoptado desde la Etapa 3 |

### 7.2 Contradicciones que quedan y cómo resolverlas

| # | Entre | Contradicción | Resolución |
|---|---|---|---|
| 1 | B6 y B7 | B6 da combatiente frente a minero en 1,02–1,06; B7 da, para perfiles iniciales, minería 1,08–1,34 veces por encima | No miden lo mismo: B6 no cuenta el tiempo parado recuperando vida ni el equipo atrasado. **Manda B7.** El límite de 1,3 se cumple salvo en el caso transitorio de 1,34 |
| 2 | B5 y B7 | B5 (sección 7) calcula el valor de las mascotas con un 20,6% de tiempo parado; B7 añade regeneración en combate y lo deja en 0–11% | Las cifras de B5 sobrestiman el valor de Tanque y Apoyo. El orden de las conclusiones se mantiene. **Recalcular B5, sección 7, con datos de la beta**; hasta entonces manda B7 |
| 3 | B3 y B7 | B3 da 399.993 monedas por hora al minero de zona 10; B7 da 630.359 | Supuestos distintos: B3 usa pico Raro sin mejoras y nivel 950; B7, equipo Legendario +50%, nivel 1.000 y mascotas. El ingreso de referencia `I(z)` de B6 es el de B3 y B4 (equipo Raro). No hay error; los precios están calibrados con el más bajo |
| 4 | B1 y B3 | B1 (tabla 5.3) dice que la Suerte afecta a «la rareza del depósito que aparece» como si fuera individual; B3 establece que es la media de la zona | **Manda B3** (E3-20). B7 simula con la Suerte propia por simplicidad, lo que equivale a jugar solo |
| 5 | B4 y B7 | La tabla de ritmo del combatiente de B4 no incluye grupos de enemigos ni regeneración | **Manda B7.** B4 sigue valiendo como referencia de un objetivo cada vez |
| 6 | B2 y B7 | En B2, el problema P1 conserva la tabla con `M = 1,5` | Es histórico y está señalado. Vigente: `M = 1,0` |
| 7 | A y C | A describe el MVP con 3 tipos de arma; `Config/Weapons` de C define los 6 | No es contradicción: la configuración contiene todo el diseño y el MVP activa 3. Añadir en la fase 4 una lista `EnabledTypes` |
| 8 | A y B6 | A propone misiones semanales con gemas antiguas; B6 las da por contratos de grieta, primera derrota semanal de jefe y temporada | Fuentes compatibles, pero la cantidad total semanal no está calculada. **Fijar el total de gemas antiguas por semana antes de la expansión 2**, que es cuando empiezan a usarse |
| 9 | DECISIONES | La sección 2.2 (P-03 a P-47) lista valores «sin contrastar» que después se fijaron o sustituyeron (por ejemplo, la raíz cuadrada de P-06) | La sección 2.2 es el punto de partida de la Etapa 0. Los valores vigentes son los de las series E1 a E9; donde difieran, manda la serie E |
| 10 | Todos | Ningún documento se ha contrastado con el prompt maestro ni con el GDD original | Es la mayor incertidumbre del diseño. Al recibirlos: repetir la Etapa 0 (2/2), listar diferencias y corregir empezando por los archivos B |

### 7.3 Comprobaciones hechas sin encontrar diferencias

- Reglas PvP (×0,06, Vitalidad `M = 1,0`, Defensa 4.500 y 50%, topes del 35% y del 60% en 2 s): iguales en B2, B4, B7, A y C.
- Topes de mascotas (40% y 25%) y ventana de 5 s: iguales en B5, B7, A y C.
- Protección contra mala suerte (40, 50 y 100) y tablas de cajas: iguales en B1, B6, A y C; todas las tablas de pesos de C suman 100.
- Zonas Fracturadas (×2,0, mochila doble, racha de +2% hasta +10%, 50% soltado, 70% recogible): iguales en B3, B6, B7, A y C.
- Monedas de jefe (`60 × V`) y reinicio de estadísticas (1,5 horas): iguales en B2, B4, B6 y C.
- Contenido del MVP: igual en A y D.
- Nunca se venden Celestial, Núcleos Despertados ni el Seguro de carga: igual en B6, A y C.
