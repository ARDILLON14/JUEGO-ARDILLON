# OREBOUND — B5: Mascotas

Etapa 5, rehecha con el GDD · 2026-11-16 · Script: `calculos/b5_mascotas.py` (genera este documento).

> **Fuentes.** Esta versión usa el GDD de combate, minería PvPvE y mascotas. De él vienen la
> función dual, las dos posturas, lo que desbloquea cada fase, los cinco roles con sus
> ejemplos y el Guiverno de Cuarzo. Sus cifras están pendientes de simulación: son
> **[PROVISIONAL]**. No se dispone del prompt maestro: las 8 mascotas de referencia no se han
> visto y las otras 11 mascotas de este documento son propuestas **[PROVISIONAL]**.
> Son **[CONFIRMADO]**: fases huevo → cría → forma desatada, tope de DPS conjunto del 40% del
> jugador en PvE y del 25% en PvP y Zonas Fracturadas, 3 espacios iniciales y que las
> mascotas nunca se pierden.

---

## 1. Función dual y posturas (GDD)

Cada mascota hace dos cosas a la vez: **recolectar** y **apoyar en combate**.

- **Recolección:** recogen solas el mineral suelto en 20 studs, incluidos los Cofres de Saqueo, y algunas aumentan la velocidad de extracción del dueño.
- **Combate:** atacan al objetivo del dueño y usan su habilidad cuando se cumple su condición.

| Postura | Radio de recogida | Daño de mascotas | Uso |
|---|---|---|---|
| Recolectar | +50% (30 studs) | −50% | Minar |
| Proteger | −50% (10 studs) | +50% | Combatir |

- Cambiar de postura tiene 5 s de enfriamiento.
- **Cofres de Saqueo:** una mascota abre el cofre por el jugador si este está dentro del radio de recogida. Tarda 4,5 s (el jugador, 3 s), respeta los 10 s de exclusividad de B3 y se interrumpe si la mascota recibe daño (valores propuestos).
- Lo que no cabe en la mochila se queda en el suelo o en el cofre.

---

## 2. Nivel de mascota

### F26 — XP y multiplicadores de nivel

- **XP para el siguiente nivel:** `XPp(n) = techo(15 + 3·n + 0,09·n²)`, de nivel 1 a 100.
- **Multiplicador de daño:** `1 + 0,015 × (n − 1)` → ×2,485 a nivel 100.
- **Multiplicador de velocidad de ataque:** `1 + 0,002 × (n − 1)` → ×1,198 a nivel 100.
- **Multiplicador de utilidad:** `1 + 0,005 × (n − 1)` → ×1,495 a nivel 100.
- **Ejemplo:** `XPp(50) = techo(15 + 150 + 225) = 390`.
- **Límites:** nivel máximo 100. La XP de mascota no depende de la zona.
- **Posibles problemas:** fuentes de XP de mascota de pago romperían el ritmo previsto.

| Nivel | XP para el siguiente | XP acumulada | Mult. de daño | Mult. de velocidad de ataque | Mult. de utilidad | Horas en combate | Horas minando | Horas en el Nido |
|---|---|---|---|---|---|---|---|---|
| 1 | 19 | 0 | 1,000 | 1,000 | 1,000 | 0,0 | 0,0 | 0,0 |
| 10 | 54 | 301 | 1,135 | 1,018 | 1,045 | 0,4 | 0,4 | 2,8 |
| 25 | 147 | 1.713 | 1,360 | 1,048 | 1,120 | 2,4 | 2,4 | 15,9 |
| 50 | 390 | 8.073 | 1,735 | 1,098 | 1,245 | 11,3 | 11,2 | 75,0 |
| 75 | 747 | 21.876 | 2,110 | 1,148 | 1,370 | 30,5 | 30,2 | 203,3 |
| 100 | — | 45.936 | 2,485 | 1,198 | 1,495 | 64,0 | 63,5 | 426,9 |

| Fuente | XP de mascota | Ritmo |
|---|---|---|
| Combate | Común 2 · Élite 8 · Guardián 24 · Jefe 160 | 717 por hora |
| Minería | Por rareza del depósito: 2 / 3 / 4 / 6 / 9 / 14 / 22 | 723 por hora |
| Nido | 15% del ritmo de combate mientras el dueño juega; 2 huecos | 108 por hora |

- Todas las mascotas equipadas reciben la XP completa.
- Nivel 50 en unas 11,3 horas y nivel 100 en unas 64,0 horas de juego.

---

## 3. Evolución (GDD)

| Fase | Cómo se alcanza | Factor de fase | Desbloquea | Aspecto |
|---|---|---|---|---|
| Huevo | Cajas, jefes o exploración | — | Nada: se incuba minando | Huevo con el brillo de su rareza |
| Cría | Al eclosionar; niveles 1 a 49 | ×1,00 | Pasiva de recolección | Tamaño pequeño, aura suave |
| Forma desatada | Nivel 50 + materiales de su elemento | ×1,25 | Habilidad activa de combate | Tamaño ×1,8, aura y estela persistente |
| Forma desatada máxima | Nivel 100 + material de jefe | ×1,50 | Ataque coordinado con el dueño | Resalte, partículas de rareza y sonido propio |

- La forma desatada máxima es un refinamiento de la forma desatada, no una cuarta fase (GDD).
- El factor de fase es propuesta; multiplica daño, vida y utilidad.

| Rareza | Incubación (golpes de pico) | Horas minando | Desatada: fragmentos de su elemento | Máxima: material de jefe | Fragmentos al liberar un duplicado |
|---|---|---|---|---|---|
| Común | 500 | 0,3 | 10 | 5 | 1 |
| Poco común | 1.000 | 0,7 | 15 | 5 | 2 |
| Raro | 2.000 | 1,3 | 25 | 8 | 4 |
| Épico | 4.000 | 2,7 | 40 | 8 | 8 |
| Legendario | 8.000 | 5,4 | 60 | 12 | 16 |
| Mítico | 15.000 | 10,1 | 90 | 12 | 32 |
| Ultra raro | 30.000 | 20,1 | 130 | 16 | 64 |

- **Incubación:** el GDD da como ejemplo 500 golpes de pico; se toma como valor del huevo Común y se escala con la rareza. A unos 1.490 golpes por hora. Cada enemigo derrotado cuenta como 5 golpes, para que quien combate también pueda incubar (propuesta).
- **Fragmentos elementales:** los sueltan los Élites (1) y Guardianes (3) de las zonas del elemento de la mascota, y se obtienen al liberar duplicados (propuesta).
- Evolucionar cuesta además monedas (B6) y no reinicia el nivel.

---

## 4. Daño, vida y velocidad de ataque

### F27 — DPS de una mascota

- **Expresión:** `DPS = PotenciaArma × b(rol) × MultRareza × MultNivel × FactorFase × MultDominio × MultVelocidadNivel × Postura`
- **Variables:**
  - `PotenciaArma`: la del arma del jugador (B4). La mascota escala con su dueño.
  - `b(rol)`: coeficiente del rol (tabla de abajo).
  - `MultRareza`: el de B1 (×1,00 a ×4,50).
  - `MultDominio = 1 + 3·D/(D + 1.000)` (B2).
  - `Postura`: ×1,5 en Proteger y ×0,5 en Recolectar.
- **Unidad:** puntos de daño por segundo, antes del tope.
- **Ejemplo:** Ofensiva Legendaria de nivel 60, desatada, con Dominio 400 y en Proteger → 0,2935 × PotenciaArma por segundo: el 12,1% del DPS de un jugador con Fuerza 300.
- **Límites:** el tope conjunto de la sección 6. El daño de mascota pasa por la fórmula F19 de B4.
- **Posibles problemas:** con los multiplicadores de rareza del GDD, una mascota Ultra rara pega 4,5 veces lo que una Común; el tope lo contiene.

### F28 — Vida de una mascota

- **Expresión:** `Vida = VidaBase(nivel del jugador) × h(rol) × MultRareza × (1 + 0,01 × (n − 1)) × FactorFase × MultDominio`
- **Ejemplo:** Defensa Épica de nivel 50, desatada, Dominio 0, jugador de nivel 450 → `11.236 × 1,00 × 1,90 × 1,49 × 1,25 = 39.760`.
- Una mascota derrotada vuelve a los 20 s (30 s en una Zona Fracturada). Nunca se pierde.

### F29 — Velocidad de ataque

- **Expresión:** `GolpesPorSegundo = VelBase(especie) × (1 + 0,002 × (n − 1))`, con máximo 2,0.

### Roles (GDD)

| Rol | Coef. de daño (b) | Coef. de vida (h) | Habilidad activa (forma desatada) | Ataque coordinado (forma máxima) | Tope del efecto |
|---|---|---|---|---|---|
| Ofensiva | 0,016 | 0,40 | Mordisco que aplica Quemadura | Remata objetivos por debajo del 15% de vida | Tope de DPS conjunto |
| Control | 0,010 | 0,50 | Ralentización del 30% durante 2 s (cada 10 s) | Encadena un aturdimiento corto tras una habilidad del dueño, sujeto a rendimientos decrecientes | 25% menos de daño enemigo |
| Defensa | 0,008 | 1,00 | Escudo que absorbe el 20% de la vida máxima del dueño durante 5 s (cada 30 s, si baja del 50%) | Bloquea un proyectil que apunta al dueño | Un escudo activo a la vez |
| Apoyo | 0,005 | 0,50 | +15% de velocidad de ataque durante 6 s (cada 20 s) | Cura el 8% al dueño tras una esquiva perfecta | 4% de la vida por segundo en PvE; la mitad en PvP |
| Minería | 0,004 | 0,40 | +20% de velocidad de extracción durante 10 s (cada 30 s) | Pica el mismo depósito que el dueño | +40% de velocidad de extracción entre todas |

- **F30 — Efecto de utilidad:** `Efecto = ValorDelGDD × (FactorFase × (1 + 0,005 × (n − 1)) × (1 + 1,5·D/(D + 1.000))) / 1,556`. Los valores del GDD se toman como los de una mascota en forma desatada de nivel 50 sin Dominio.
- El tope de DPS solo cuenta el daño. Por eso las mascotas de Defensa, Control, Apoyo y Minería siguen siendo útiles aunque peguen poco, y por eso el Dominio de mascotas tiene valor más allá del daño.

Pasiva de recolección de las mascotas de Minería (propuesta; el Guiverno de Cuarzo del GDD da +15% siendo Legendario):

| Rareza de la mascota de Minería | Común | Poco común | Raro | Épico | Legendario | Mítico | Ultra raro |
|---|---|---|---|---|---|---|---|
| Velocidad de extracción (pasiva de cría) | +5% | +6% | +8% | +10% | +15% | +18% | +22% |

---

## 5. Las 12 mascotas de lanzamiento

| # | Mascota | Rareza | Elemento | Rol | Golpes/s | Origen |
|---|---|---|---|---|---|---|
| 1 | Topillo de Pizarra | Común | Tierra | Minería | 1,2 | Propuesta |
| 2 | Luciérnaga de Veta | Común | Luz | Apoyo | 1,0 | Propuesta |
| 3 | Zorro de Ascua | Poco común | Fuego | Ofensiva | 1,6 | Propuesta |
| 4 | Tortuga Geoda | Poco común | Tierra | Defensa | 0,6 | Propuesta |
| 5 | Murciélago de Eco | Raro | Sonido | Control | 1,4 | Propuesta |
| 6 | Nutria Salina | Raro | Agua | Minería | 1,2 | Propuesta |
| 7 | Búho Boreal | Épico | Hielo | Control | 0,8 | Propuesta |
| 8 | Carnero de Magma | Épico | Fuego | Defensa | 0,7 | Propuesta |
| 9 | Mantis Vitral | Legendario | Luz | Ofensiva | 1,6 | Propuesta |
| 10 | Guiverno de Cuarzo | Legendario | Cristal | Defensa | 1,0 | GDD |
| 11 | Ciervo Astral | Mítico | Astral | Apoyo | 0,8 | Propuesta |
| 12 | Sierpe de Nova | Ultra raro | Astral | Ofensiva | 1,0 | Propuesta |

No hay mascota Celestial de lanzamiento: se reserva para eventos.

| Mascota | Pasiva de recolección (cría) | Habilidad activa (forma desatada) | Ataque coordinado (forma máxima) |
|---|---|---|---|
| Topillo de Pizarra | +5% de velocidad de extracción | Excavar: +20% de velocidad de extracción 10 s (cada 30 s) | Pica el mismo depósito que el dueño |
| Luciérnaga de Veta | Revela depósitos Épico o superior a 40 studs | Destello: +15% de velocidad de ataque 6 s (cada 20 s) | Cura el 8% al dueño tras una esquiva perfecta |
| Zorro de Ascua | +10% de radio de recogida | Mordisco ardiente: aplica Quemadura (cada 10 s) | Remata objetivos por debajo del 15% de vida |
| Tortuga Geoda | +6 unidades de mochila | Caparazón: escudo del 20% de la vida máxima 5 s si el dueño baja del 50% (cada 30 s) | Bloquea un proyectil que apunta al dueño (cada 15 s) |
| Murciélago de Eco | Detecta Cofres de Saqueo a 50 studs | Chillido: ralentiza 30% durante 2 s (cada 10 s) | Aturde 0,5 s tras una habilidad de control del dueño |
| Nutria Salina | +8% de velocidad de extracción | Corriente: +20% de velocidad de extracción 10 s (cada 30 s) | Pica el mismo depósito que el dueño |
| Búho Boreal | +15% de radio de recogida | Pluma helada: ralentiza 30% durante 2 s (cada 10 s) | Congela 1 s en PvE tras la definitiva del dueño |
| Carnero de Magma | +8 unidades de mochila | Corteza de lava: escudo del 20% que quema a quien lo golpea (cada 30 s) | Embiste a quien ataca al dueño |
| Mantis Vitral | +3% de probabilidad de unidad extra | Danza de cuchillas: 5 cortes a un objetivo (cada 12 s) | Remata objetivos por debajo del 15% de vida |
| Guiverno de Cuarzo | +15% de velocidad de extracción (GDD) | Escudo Facetado: absorbe el 20% de la vida máxima 5 s si el dueño baja del 50%; 30 s (GDD) | Haz de Cuarzo: dispara a cada objetivo que el dueño marque con Refractado (GDD) |
| Ciervo Astral | +10 unidades de mochila | Claro estelar: +15% de velocidad de ataque 6 s al dueño y a aliados cercanos (cada 20 s) | Cura el 8% al dueño tras una esquiva perfecta |
| Sierpe de Nova | +20% de radio de recogida | Supernova menor: explosión en 12 studs (cada 12 s) | Remata con una explosión a objetivos por debajo del 15% |

- El daño de las habilidades activas y de los ataques coordinados cuenta para el tope de DPS (el Haz de Cuarzo incluido, como indica el GDD).
- Límites de recolección sumando todas las mascotas: +40% de velocidad de extracción, +20% de probabilidad de unidad extra, +30% de mochila y +50% de radio de recogida.

---

## 6. Topes de DPS

Los topes son **[CONFIRMADO]**: 40% del DPS del jugador en PvE; 25% en PvP y Zonas Fracturadas.

### 6.1 Cómo los aplica el servidor

1. **DPS de referencia del jugador.** El servidor lo calcula con sus estadísticas, no con el daño que haya hecho: `DPSref = PotenciaArma × MultFuerza × 1,025 × MultMaestría × 1,39`. (1,025 es el crítico medio y 1,39 el factor de habilidades de B2.) Un jugador quieto no cambia el tope y no se puede inflar con ráfagas.
2. **Factor de escala.** Cada vez que cambian estadísticas, equipo, mascotas o postura: `Factor = mín(1, Tope × DPSref / Σ DPS teórico de las mascotas)`. Todo golpe de mascota se multiplica por el factor.
3. **Ventana deslizante de 5 s.** El servidor suma el daño de mascotas de los últimos 5 s y recorta cualquier golpe que haga superar `Tope × DPSref × 5`. Cubre las ráfagas de habilidades y ataques coordinados.
4. **Solo en combate.** Las mascotas atacan únicamente si el jugador ha dado o recibido un golpe en los últimos 5 s.
5. **Máximo de mascotas activas:** en PvP y Zonas Fracturadas combaten como mucho 3.
6. El cliente nunca envía daño de mascota: lo calcula todo el servidor.

### 6.2 Simulación con 3 mascotas de Ofensiva a niveles 10, 50 y 100

120 s de combate por caso, en postura Proteger (+50% de daño). Las tres mascotas tienen velocidades distintas (1,6, 1,0 y 0,6 golpes por segundo).

| Modo | Jugador | Nivel de las 3 mascotas | Rareza y fase | DPS teórico sin tope (% del jugador) | Factor del servidor | DPS real medio | Mayor media en 5 s | Tope |
|---|---|---|---|---|---|---|---|---|
| PvE | Típico (Fuerza 170, Dominio 170) | 10 | Común, cría | 5,8% | 1,000 | 5,7% | 6,7% | 40% |
| PvE | Típico (Fuerza 170, Dominio 170) | 50 | Épico, forma desatada | 26,2% | 1,000 | 25,5% | 30,8% | 40% |
| PvE | Típico (Fuerza 170, Dominio 170) | 100 | Ultra raro, forma desatada máxima | 116,4% | 0,344 | 36,2% | 40,0% | 40% |
| PvE | Fuerza 1.000, Dominio 0 | 10 | Común, cría | 2,3% | 1,000 | 2,3% | 2,7% | 40% |
| PvE | Fuerza 1.000, Dominio 0 | 50 | Épico, forma desatada | 10,5% | 1,000 | 10,2% | 12,3% | 40% |
| PvE | Fuerza 1.000, Dominio 0 | 100 | Ultra raro, forma desatada máxima | 46,6% | 0,859 | 36,2% | 40,0% | 40% |
| PvE | Fuerza 1.000, Dominio 1.000 | 10 | Común, cría | 5,8% | 1,000 | 5,7% | 6,7% | 40% |
| PvE | Fuerza 1.000, Dominio 1.000 | 50 | Épico, forma desatada | 26,2% | 1,000 | 25,5% | 30,8% | 40% |
| PvE | Fuerza 1.000, Dominio 1.000 | 100 | Ultra raro, forma desatada máxima | 116,4% | 0,344 | 36,2% | 40,0% | 40% |
| PvE | Fuerza 0, Dominio 1.000 | 10 | Común, cría | 14,6% | 1,000 | 14,2% | 16,8% | 40% |
| PvE | Fuerza 0, Dominio 1.000 | 50 | Épico, forma desatada | 65,5% | 0,610 | 35,4% | 40,0% | 40% |
| PvE | Fuerza 0, Dominio 1.000 | 100 | Ultra raro, forma desatada máxima | 291,1% | 0,137 | 36,2% | 40,0% | 40% |
| PvP y Zonas Fracturadas | Típico (Fuerza 170, Dominio 170) | 10 | Común, cría | 5,8% | 1,000 | 5,7% | 6,7% | 25% |
| PvP y Zonas Fracturadas | Típico (Fuerza 170, Dominio 170) | 50 | Épico, forma desatada | 26,2% | 0,954 | 22,1% | 25,0% | 25% |
| PvP y Zonas Fracturadas | Típico (Fuerza 170, Dominio 170) | 100 | Ultra raro, forma desatada máxima | 116,4% | 0,215 | 22,6% | 25,0% | 25% |
| PvP y Zonas Fracturadas | Fuerza 1.000, Dominio 0 | 10 | Común, cría | 2,3% | 1,000 | 2,3% | 2,7% | 25% |
| PvP y Zonas Fracturadas | Fuerza 1.000, Dominio 0 | 50 | Épico, forma desatada | 10,5% | 1,000 | 10,2% | 12,3% | 25% |
| PvP y Zonas Fracturadas | Fuerza 1.000, Dominio 0 | 100 | Ultra raro, forma desatada máxima | 46,6% | 0,537 | 22,6% | 25,0% | 25% |
| PvP y Zonas Fracturadas | Fuerza 1.000, Dominio 1.000 | 10 | Común, cría | 5,8% | 1,000 | 5,7% | 6,7% | 25% |
| PvP y Zonas Fracturadas | Fuerza 1.000, Dominio 1.000 | 50 | Épico, forma desatada | 26,2% | 0,954 | 22,1% | 25,0% | 25% |
| PvP y Zonas Fracturadas | Fuerza 1.000, Dominio 1.000 | 100 | Ultra raro, forma desatada máxima | 116,4% | 0,215 | 22,6% | 25,0% | 25% |
| PvP y Zonas Fracturadas | Fuerza 0, Dominio 1.000 | 10 | Común, cría | 14,6% | 1,000 | 14,2% | 16,8% | 25% |
| PvP y Zonas Fracturadas | Fuerza 0, Dominio 1.000 | 50 | Épico, forma desatada | 65,5% | 0,381 | 22,1% | 25,0% | 25% |
| PvP y Zonas Fracturadas | Fuerza 0, Dominio 1.000 | 100 | Ultra raro, forma desatada máxima | 291,1% | 0,086 | 22,6% | 25,0% | 25% |

- En los 24 casos, ni el DPS medio ni ninguna ventana de 5 s superan el tope (el script lo comprueba con `assert`).
- Tres crías Comunes de nivel 10 dan el 5,8% del DPS de un jugador típico.
- Con Fuerza 1.000 y sin Dominio, tres Ultra raras al máximo dan el 46,6%.
- Con Dominio 1.000 y sin Fuerza harían el 291,1%, y el servidor lo deja en el tope.

---

## 7. Valor de las mascotas que no hacen daño

### 7.1 En combate (jugador típico de zona 5)

Supuestos: el jugador esquiva la mitad del daño, regenera un 0,5% de vida por segundo en combate (B7), se retira al 30% de vida y recupera un 5% por segundo fuera de combate. Sin mascotas pasa el 10,8% del tiempo parado.

| Equipo (Épico, nivel 50, desatada, postura Proteger) | DPS que añaden | Tiempo parado recuperando vida | Enemigos/hora | Monedas/hora frente a sin mascotas | Aguante frente a un Guardián sin esquivar | Aguante extra |
|---|---|---|---|---|---|---|
| Sin mascotas | 0,0% | 10,8% | 210 | 0,0% | 24,7 s | 0% |
| 3 de Ofensiva | 26,3% | 9,2% | 249 | 18,4% | 24,7 s | 0% |
| 2 de Ofensiva + Defensa | 21,9% | 0,0% | 268 | 27,6% | 30,7 s | 24% |
| 2 de Ofensiva + Apoyo | 20,3% | 9,3% | 247 | 17,3% | 24,7 s | 0% |
| 2 de Ofensiva + Control | 23,0% | 7,9% | 249 | 18,1% | 26,9 s | 9% |
| Defensa + Apoyo + Control | 12,6% | 0,0% | 261 | 24,1% | 33,5 s | 35% |

- Tres mascotas de Ofensiva dan +18,4% de monedas por hora.
- Cambiar una por una de Defensa da +27,6%; por una de Apoyo, +17,3%; por una de Control, +18,1%.
- Un equipo sin Ofensiva (Defensa + Apoyo + Control) da +24,1%.

### 7.2 En minería (minero equilibrado de zona 5)

| Equipo en postura Recolectar | Velocidad de extracción añadida | Recogida automática | Depósitos/hora | Monedas/hora frente a sin mascotas |
|---|---|---|---|---|
| Sin mascotas | 0,0% | No | 248 | 0,0% |
| 1 de Minería (Épica) | 18,1% | Sí | 286 | 15,2% |
| 2 de Minería | 28,1% | Sí | 295 | 19,0% |
| 3 de Minería | 38,1% | Sí | 304 | 22,4% |
| Guiverno de Cuarzo + 2 de Minería Épicas | 40,0% | Sí | 305 | 23,0% |

- Una mascota de Minería da +15,2% de monedas por hora y tres dan +22,4%.
- El tope de +40% de velocidad de extracción impide que el equipo de Minería rompa la paridad con el combatiente.

---

## 8. Espacios de mascotas

| Espacio | Cómo se desbloquea |
|---|---|
| 1, 2 y 3 | Iniciales **[CONFIRMADO]** |
| 4 | Misión al llegar al nivel 300 |
| 5 | Misión al llegar al nivel 700 |
| 6 | De pago (pase único) o 60 Fragmentos de temporada |

| Espacios y equipo | Monedas/hora frente a sin mascotas | Frente al equipo de 3 |
|---|---|---|
| 3 (inicial): 3 de Ofensiva | 18,4% | 0,0% |
| 4: + Defensa | 33,2% | 12,5% |
| 5: + Defensa + Apoyo | 37,8% | 16,3% |
| 6: + Defensa + Apoyo + Control | 41,1% | 19,1% |

- **Qué se puede comprar:** un único espacio, el sexto. Añade un 2,4% de monedas por hora sobre un jugador con 5 espacios.
- **Por qué no da ventaja excesiva:** el tope de DPS es conjunto; los efectos de utilidad tienen topes propios; y en PvP y Zonas Fracturadas solo combaten 3 mascotas.
- **Almacén de mascotas:** 30 huecos iniciales, ampliables. No da poder.
- **Incubadoras:** 1 inicial; la segunda a nivel 200 y una tercera de pago. Solo permiten incubar varios huevos a la vez.

---

## 9. Problemas de balance detectados y alternativas

### P1 — Los multiplicadores de rareza del GDD amplían la distancia entre mascotas

- **Dato:** una Ultra rara hace 4,5 veces el daño de una Común (antes 2,2). Tres Ultra raras al máximo llegan al 116,4% del DPS de un jugador típico antes del tope.
- **Por qué se acepta:** el tope lo corta en el 40%. Lo que sí crece con la rareza sin tope de DPS es la vida de la mascota.

### P2 — La postura Proteger sube el daño un 50%

- **Corrección aplicada:** los coeficientes `b` de rol se han reducido (Ofensiva de 0,030 a 0,016) para que el daño en Proteger sea el que antes tenía la postura de ataque. En Recolectar las mascotas hacen un tercio de eso.

### P3 — El escudo del 20% de la vida es muy fuerte en PvE

- **Dato:** el equipo con una mascota de Defensa rinde +27,6% frente a +18,4% de tres de Ofensiva.
- **Límite aplicado:** solo un escudo activo a la vez, aunque haya varias mascotas de Defensa, y en la simulación no puede absorber más del 60% del daño recibido.
- **Se mide en la beta:** si las mascotas de Ofensiva no se usan, bajar el escudo al 15%.

### P4 — El tope de DPS deja sin uso gran parte del Dominio

- **Dato:** con Dominio 1.000 y sin Fuerza, las mascotas harían el 291,1% y se cuentan al 40%.
- **Por qué se mantiene:** es una decisión fija. El valor del Dominio está en la utilidad (F30) y en la vida de las mascotas. B7 lo comprueba.

### P5 — El sexto espacio es de pago

- **Dato:** +2,4% de monedas por hora en PvE; 0% en PvP. B6 decide.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| XP de mascota e incubación por golpes | Telemetría: horas hasta eclosionar y hasta los niveles 50 y 100 |
| Coeficientes `b` de rol | Daño real de mascotas sobre el del jugador, por postura |
| Tope de DPS | Prueba automática en servidor: ninguna ventana de 5 s por encima del tope |
| Escudo, velocidad de ataque, ralentización y extracción | Comparar monedas y muertes por hora de cada composición de equipo |
| Costes de evolución | B6: horas para reunir fragmentos elementales y material de jefe |
| Sexto espacio | Comparar ingresos de jugadores con 5 y 6 espacios; límite, +5% |
