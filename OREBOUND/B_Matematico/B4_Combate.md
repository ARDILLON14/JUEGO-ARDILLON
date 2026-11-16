# OREBOUND — B4: Combate

Etapa 4, rehecha con el GDD · 2026-11-16 · Script: `calculos/b4_combate.py` (genera este documento) · Catálogo de armas: `calculos/b4_armas.csv` (450 armas).

> **Fuentes.** Esta versión usa el GDD de combate, minería PvPvE y mascotas. De él vienen los
> controles, las ranuras mixtas de arma y Núcleo, el Núcleo Prismático, el Despertar y la
> Transformación, la movilidad y las reglas contra el combo infinito. Sus cifras están
> pendientes de simulación: son **[PROVISIONAL]**. No se dispone del prompt maestro: los tipos
> de arma, los enemigos, los jefes y las reglas PvP numéricas siguen siendo propuestas
> **[PROVISIONAL]**. Son **[CONFIRMADO]**: ataque básico + 4 ranuras (Z, X, C, V) + movilidad
> (dash, doble salto y parpadeo) y el tope de mascotas del 25% en PvP.

---

## 1. Armas

### 1.1 Los 6 tipos

| Tipo | Golpes/s | Coef. por golpe | Alcance (studs) | Objetivos por golpe | DPS relativo (con críticos) | Frente a la media de los 5 | Qué lo diferencia |
|---|---|---|---|---|---|---|---|
| Espada | 1,60 | 0,625 | 8 | 2 | 1,025 | +0,8% | Equilibrada; combo de 4 golpes; bloquear cuesta 20% menos |
| Hacha | 0,90 | 1,150 | 9 | 3 | 1,061 | +4,3% | Arco de 180°; daño a la guardia ×1,5 |
| Daga | 2,60 | 0,365 | 6 | 1 | 1,020 | +0,3% | +10% de crítico; +25% de daño por la espalda |
| Lanza | 1,20 | 0,810 | 14 | 3 | 0,996 | -2,1% | Largo alcance; atraviesa en línea |
| Bastón | 1,00 | 0,960 | 35 | 1 | 0,984 | -3,3% | Proyectil a media distancia; habilidades cuestan 10% menos de energía |
| Arco | 1,10 | 0,727 | 70 | 1 | 0,820 | -19,4% | Sexto tipo (propuesto): largo alcance; DPS menor a propósito |

- **F18 — Daño por golpe:** `DañoGolpe = PotenciaArma × Coef(tipo)`, con `PotenciaArma = PotZona(z) × MultRareza × (1 + bonos)` (B1).
- **DPS relativo:** `Golpes/s × Coef × (1 + ProbCrítico × 0,5)`.
- **Resultado:** Espada, Hacha, Daga, Lanza y Bastón quedan entre -3,3% y +4,3% de su media. El requisito era ±10%.
- **Arco:** queda un 19,4% por debajo a propósito y lo compensa con 70 studs de alcance. El sexto tipo no se conoce; el Arco es propuesta.
- **Golpes en área:** el primer objetivo recibe el 100% y los demás el 25% (B7).
- El ataque básico es un combo de 4 golpes (GDD).

### 1.2 Daño por golpe de un arma Común, por zona

| Zona | Nivel | Potencia (Común) | Espada | Hacha | Daga | Lanza | Bastón | Arco |
|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 100 | 62,5 | 115,0 | 36,5 | 81,0 | 96,0 | 72,7 |
| 2 | 100 | 200 | 125,0 | 230,0 | 73,0 | 162,0 | 192,0 | 145,4 |
| 3 | 200 | 400 | 250,0 | 460,0 | 146,0 | 324,0 | 384,0 | 290,8 |
| 4 | 300 | 800 | 500,0 | 920,0 | 292,0 | 648,0 | 768,0 | 581,6 |
| 5 | 400 | 1.600 | 1.000,0 | 1.840,0 | 584,0 | 1.296,0 | 1.536,0 | 1.163,2 |
| 6 | 500 | 3.200 | 2.000,0 | 3.680,0 | 1.168,0 | 2.592,0 | 3.072,0 | 2.326,4 |
| 7 | 600 | 6.400 | 4.000,0 | 7.360,0 | 2.336,0 | 5.184,0 | 6.144,0 | 4.652,8 |
| 8 | 700 | 12.800 | 8.000,0 | 14.720,0 | 4.672,0 | 10.368,0 | 12.288,0 | 9.305,6 |
| 9 | 800 | 25.600 | 16.000,0 | 29.440,0 | 9.344,0 | 20.736,0 | 24.576,0 | 18.611,2 |
| 10 | 900 | 51.200 | 32.000,0 | 58.880,0 | 18.688,0 | 41.472,0 | 49.152,0 | 37.222,4 |

Para otra rareza se multiplica por su factor; con mejoras, por `(1 + bonos)` hasta ×1,5.

### 1.3 Rareza y pasiva de arma

| Rareza | Mult. de potencia | Pasiva de arma |
|---|---|---|
| Común | ×1,00 | Ninguna |
| Poco común | ×1,25 | Filo templado: el 4.º golpe del combo hace +30% |
| Raro | ×1,50 | Sed de combate: +5% de velocidad de ataque 3 s tras derrotar a un enemigo |
| Épico | ×1,90 | Golpe resonante: cada 8 s el siguiente golpe aplica Vulnerable 3 s |
| Legendario | ×2,50 | Furia medida: +10% de daño con la vida por encima del 80% |
| Mítico | ×3,30 | Eco del acero: 15% de repetir el golpe al 40% |
| Ultra raro | ×4,50 | Remate: +20% de daño a objetivos por debajo del 25% de vida |
| Celestial | ×5,20 | Juicio astral: cada 20 s el siguiente golpe es crítico seguro y aplica Vulnerable |

- **Nivel requerido:** el de la zona del arma.
- **Catálogo:** 420 armas (6 tipos × 10 zonas × 7 rarezas) más 30 Celestiales (zonas 6 a 10): 450 en total.
- **Mejoras:** las de los picos (B3): nivel de objeto +25%, ranuras +15% y Despertar de habilidad +10%.

### 1.4 Técnicas de arma

El GDD establece que las cuatro ranuras se configuran mezclando habilidades del arma y del Núcleo. Cada tipo de arma aporta 2 técnicas (propuestas):

| Arma | Técnica | Maestría de arma | Daño (% de potencia) | Energía | Enfriamiento (s) | % por segundo | Efecto |
|---|---|---|---|---|---|---|---|
| Espada | Tajo Giratorio | 10 | 150% | 15 | 5 | 30,0 | Área de 8 studs a tu alrededor |
| Espada | Contragolpe | 50 | 300% | 30 | 12 | 25,0 | Solo tras bloquear un golpe en el último segundo |
| Hacha | Hendidura | 10 | 170% | 15 | 6 | 28,3 | Cono frontal; daño a la guardia ×2 |
| Hacha | Terremoto Menor | 50 | 320% | 30 | 14 | 22,9 | Salto e impacto; derribo de 0,6 s en PvE |
| Daga | Puñalada Doble | 10 | 160% | 15 | 5 | 32,0 | Dos golpes del 80% |
| Daga | Sombra Fugaz | 50 | 280% | 30 | 12 | 23,3 | Te coloca 8 studs detrás del objetivo |
| Lanza | Estocada Larga | 10 | 160% | 15 | 5 | 32,0 | Línea de 16 studs |
| Lanza | Barrido de Asta | 50 | 300% | 30 | 12 | 25,0 | Giro completo que empuja |
| Bastón | Orbe Cargado | 10 | 170% | 15 | 5 | 34,0 | Proyectil que atraviesa |
| Bastón | Pulso Arcano | 50 | 300% | 30 | 12 | 25,0 | Área de 10 studs; Lento 20% 2 s |
| Arco | Disparo Cargado | 10 | 190% | 15 | 6 | 31,7 | Mantener para cargar |
| Arco | Lluvia de Flechas | 50 | 320% | 30 | 14 | 22,9 | Zona de 3 s |

---

## 2. Ranuras, controles y movilidad

### 2.1 Las cuatro ranuras

- El jugador tiene 6 habilidades disponibles: 4 del Núcleo equipado y 2 técnicas del arma. Elige cuáles 4 lleva en Z, X, C y V. Se cambian fuera de combate.
- La ranura V es la definitiva: solo admite la definitiva del Núcleo o la segunda técnica del arma.

| Qué se pone en Z, X, C y V (Espada + Prismático) | Daño por segundo sin límite de energía | Energía por segundo |
|---|---|---|
| Las 4 del Núcleo (referencia) | 72,5% | 8,86 |
| Lanza, Campo y Prisma Total + Tajo Giratorio | 89,2% | 9,08 |
| Lanza y Prisma Total + las 2 técnicas de Espada | 101,7% | 9,50 |
| Lanza, Paso de Relámpago y las 2 técnicas | 105,0% | 11,61 |

- La combinación con más daño (101,7% por segundo) pide 9,50 de energía por segundo, más de lo que se regenera en combate (8). Renunciar al control y a la movilidad del Núcleo da daño, pero no gratis.

### 2.2 Controles (GDD)

| Acción | PC | Móvil | Consola |
|---|---|---|---|
| Ataque básico (combo de 4 golpes) y picar | Clic izquierdo | Botón grande | RT |
| Habilidad 1 (Z) | Z | Botón 1 | X / Cuadrado |
| Habilidad 2 (X) | X | Botón 2 | Y / Triángulo |
| Habilidad 3 (C) | C | Botón 3 | B / Círculo |
| Habilidad 4 o definitiva (V) | V | Botón 4 | RB |
| Dash | Q | Botón de dash | LB |
| Salto y doble salto | Espacio | Botón de salto | A / Cruz |
| Bloquear | F | Botón de escudo | LT |
| Parpadeo (propuesta) | E | Mantener el botón de dash | LB + A |
| Ruptura (propuesta) | Espacio mientras estás bajo control | Botón que aparece al estar bajo control | A mientras estás bajo control |
| Transformación (propuesta) | G | Botón que aparece al llenarse la barra | Pulsar los dos sticks |
| Interactuar (propuesta) | R | Botón contextual | Cruceta abajo |
| Postura de mascotas (propuesta) | T | Botón de mascotas | Cruceta arriba |

- Móvil: apuntado asistido hacia el enemigo más cercano en un cono de 30°. En las tres plataformas se pueden reasignar los controles.

### 2.3 Movilidad

| Acción | Efecto | Energía | Enfriamiento | Origen |
|---|---|---|---|---|
| Doble salto | Segundo salto | 0 | 1 por salto | GDD |
| Dash | 12 studs, aéreo o terrestre | 20 | 2 cargas; 3 s de recarga por carga | GDD (la distancia es propuesta) |
| Esquiva perfecta | Un dash hecho en los 0,25 s anteriores a un golpe da 0,3 s de invulnerabilidad | La del dash | La del dash | Propuesta (el GDD la menciona sin definirla) |
| Parpadeo | Teletransporte de 12 studs; no atraviesa paredes | 30 | 8 s | GDD |
| Bloqueo | Reduce el daño frontal un 70% | 8/s + 10 por golpe | — | Propuesta |

- El parpadeo «se desbloquea con Agilidad» (GDD). No se sabe si Agilidad es una estadística del prompt maestro; se propone desbloquearlo con 50 puntos de Velocidad.
- En una Zona Fracturada, dash y parpadeo no se ralentizan con la carga; con Carga 10 o más cuestan un 25% más (B3).

---

## 3. Fórmula completa de daño

### F19 — Daño final

```
Daño = PotenciaArma × Coef × MultFuerza × MultMaestría × MultCrítico
       × (1 + EstadosDelObjetivo) × (1 − ReducciónDefensa) × MultModo
```

| Término | Fórmula o valor | Límite |
|---|---|---|
| `PotenciaArma` | `PotZona × MultRareza × (1 + bonos)` | Bonos hasta +50% (B1) |
| `Coef` | Coeficiente del golpe básico (1.1), de la técnica (1.4) o de la habilidad (sección 5) | — |
| `MultFuerza` | `1 + 3·F/(F + 1.000)` | Máximo ×4 (B2) |
| `MultMaestría` | `1 + 0,001 × nivel de maestría` | Máximo ×1,10 |
| `MultCrítico` | ×1,5 con probabilidad 5% | Probabilidad máxima 30%; multiplicador máximo ×2,0 |
| `EstadosDelObjetivo` | Suma de Refractado, Vulnerable, Descarga y Guardia rota | Máximo +40% |
| `ReducciónDefensa` | `mín(D/(D + K), Tope)` | 75% en PvE, 50% en PvP (B2, B7) |
| `MultModo` | 1 en PvE; 0,062 en PvP y Zonas Fracturadas | — |

- **Unidad:** puntos de vida. El daño mínimo es 1.
- **Ejemplo:**

| Paso | Daño |
|---|---|
| Golpe de Espada Épica de zona 5 con +25% de bonos | 2.375 |
| × Fuerza 500 (×2,000) | 4.750 |
| × Maestría 50 (×1,05) | 4.988 |
| × crítico (×1,5) | 7.481 |
| × objetivo Vulnerable (+15%) | 8.603 |
| × (1 − 25%) por Defensa 500 en PvE | 6.453 |

- **Límites del conjunto:** en la misma zona, una build final típica hace 10,2 veces el daño de un arma Común sin nada. El máximo teórico, con todos los topes a la vez, es 54,7 veces. Nueve zonas de diferencia son 512 veces: la zona sigue pesando más.
- **Posibles problemas:** ningún término nuevo debe multiplicar fuera de esta lista.

### 3.1 Estados alterados

| Estado | Efecto | Duración | En PvP |
|---|---|---|---|
| Refractado | +10% de daño recibido; objetivo del Paso de Relámpago y del Guiverno de Cuarzo | 6 s | Igual (GDD) |
| Quemadura | Daño en el tiempo indicado por la habilidad; se renueva, no se acumula | 4 s | Igual |
| Lento | −20% a −40% de velocidad de movimiento | 1,5–2 s | Igual |
| Congelación | Inmoviliza | 1,2–2 s | Se convierte en Lento 40% o dura la mitad |
| Descarga | El siguiente golpe recibido hace +15% | Hasta consumirse o 5 s | Igual |
| Vulnerable | +15% de daño recibido | 3 s | Igual |
| Guardia rota | Aturdido y +25% de daño recibido | 2,0 s aturdido en PvE, 1,5 s en PvP; +25% durante 3 s | Inmune a otra durante 8 s |

Los aumentos de daño recibido se suman y no pasan de +40%. «Guardia rota» es lo que la primera versión llamaba Ruptura; en el GDD, Ruptura es otra cosa (sección 6).

---

## 4. Maestría de armas y de Núcleos

### F20 — XP de maestría

- **Expresión:** `XPm(n) = techo(10 + 2·n + 0,04·n²)`.
- **Cómo se gana:** usándolo. Cada enemigo derrotado con esa arma o ese Núcleo equipado da puntos: Común 1, Élite 4, Guardián 12, Jefe 80.
- **Ejemplo:** `XPm(50) = techo(10 + 100 + 100) = 210`.
- **Bono:** +0,1% de daño por nivel, hasta +10% en el nivel 100.
- Hay una maestría por tipo de arma (6) y una por Núcleo (6).

| Nivel de maestría | XP para el siguiente | XP acumulada | Horas acumuladas | Desbloqueo (Núcleo / arma) |
|---|---|---|---|---|
| 1 | 13 | 0 | 0,0 | Habilidad Z / combo básico |
| 10 | 34 | 196 | 0,5 | Habilidad X / técnica 1 del arma |
| 25 | 85 | 1.046 | 2,9 | Habilidad C / pasiva de arma mejorada |
| 50 | 210 | 4.577 | 12,7 | Habilidad V / técnica 2 del arma |
| 75 | 385 | 11.833 | 33,0 | Pasiva del Núcleo mejorada / ataque cargado |
| 100 | 610 | 24.064 | 67,0 | Despertar y Transformación / título y aspecto de maestro |

- Ritmo: 359 puntos por hora. Las cuatro habilidades del Núcleo están disponibles a las 12,7 horas; el nivel 100, a las 67,0.
- **Más allá de 100 (GDD):** niveles solo cosméticos que cambian el color de los efectos. Cada uno cuesta 610 puntos (unos 102 minutos) y no da daño.

---

## 5. Núcleos de Poder

### 5.1 Estructura (GDD)

- Artefactos cristalizados que se extraen como reliquias de las profundidades de la mina.
- Cada Núcleo trae **4 habilidades (área, control, movilidad y definitiva) y 1 pasiva**.
- Solo se equipa uno a la vez. Cambiarlo es libre en la ciudad; fuera de ella cuesta un consumible (Sello de Reajuste, B6).
- Se consiguen en jefes, cajas de Núcleos, eventos y como reliquias raras en depósitos profundos.
- Su daño es un porcentaje de la potencia del arma equipada: un Núcleo no queda obsoleto al cambiar de zona.
- Los Núcleos tienen rareza (el Prismático es Épico en el GDD). La rareza marca lo difícil que es conseguirlo, no su potencia (propuesta).
- **Desbloqueo por maestría:** Z al nivel 1, X al 10, C al 25 y V al 50.

### 5.2 Despertar y Transformación (GDD)

| Aspecto | Valor | Origen |
|---|---|---|
| Requisito del Despertar | Maestría 100 del Núcleo y materiales de jefe | GDD |
| Efecto del Despertar | Sus habilidades mejoran (+15% de daño; +8% en PvP; un efecto propio) y se desbloquea la Transformación | GDD; los porcentajes son propuesta |
| Carga | Barra de Resonancia: se llena al hacer y recibir daño | GDD |
| Duración y enfriamiento | 20 s y 120 s | GDD |
| Cambios visibles | Modelo del personaje, marco de la interfaz e iconos de habilidad | GDD |
| Bono en PvE | Hasta +25% de daño | GDD |
| Bono en PvP | Limitado al 10%, con aviso visual claro al activarla | GDD |
| Venta | Los Núcleos Despertados nunca se venden por dinero real | GDD |

### 5.3 Los 6 Núcleos de lanzamiento

| Núcleo | Rareza | Elemento | Daño por segundo con todo en uso | Energía por segundo | Pasiva | Despertar | Transformación |
|---|---|---|---|---|---|---|---|
| Núcleo Prismático | Épico | Luz | 72,5% | 8,86 | Fragmentos de luz: los críticos devuelven 5 de energía (1 vez por segundo) | La Lanza rebota una vez al 50% | Forma Prisma: la Lanza dispara 3 proyectiles en abanico; en PvP solo +10% de velocidad de movimiento |
| Núcleo de Brasa | Raro | Fuego | 70,4% | 8,86 | Rescoldo: los críticos aplican Quemadura | La Quemadura se propaga a un enemigo cercano | Forma Ascua Viva |
| Núcleo de Escarcha | Raro | Hielo | 62,6% | 8,86 | Piel de Escarcha: quien te golpea queda con Lento 20% 2 s (una vez cada 10 s) | Los enemigos con Lento reciben +10% de tus habilidades | Forma Glaciar |
| Núcleo de Tormenta | Épico | Rayo | 71,1% | 8,86 | Carga Estática: cada 10 studs recorridos da 1 carga (máx. 5); el siguiente básico hace +6% por carga | Salto de Chispa guarda 2 cargas | Forma Tempestad |
| Núcleo Sísmico | Legendario | Tierra | 67,1% | 8,86 | Corteza: +8% de reducción de daño tras 1 s sin moverte (sin superar el tope de Defensa) | La Embestida también protege a aliados a 10 studs al 50% | Forma Coloso |
| Núcleo Umbrío | Legendario | Sombra | 67,8% | 8,86 | Hambre de Vacío: cada derrota reduce los enfriamientos 1 s (0,5 s en PvP) | Manto Nocturno dura 1 s más | Forma Penumbra |

- El Prismático es el del GDD y marca la referencia: 72,5% de la potencia del arma por segundo con todo en uso.
- Los otros cinco son propuestos, con la misma estructura y entre -13,6% y 0,0% de ese daño.
- El Núcleo inicial de todos los jugadores es el Prismático (propuesta).

### 5.4 Habilidades

| Núcleo | Habilidad | Tipo | Daño (% de potencia de arma) | Energía | Enfriamiento (s) | % por segundo | Efecto | Origen |
|---|---|---|---|---|---|---|---|---|
| Núcleo Prismático | Z · Lanza Prismática | Área | 220% | 20 | 6 | 36,7 | Proyectil; ralentiza 25% 1,5 s | GDD |
| Núcleo Prismático | X · Campo de Refracción | Control | 150% | 25 | 12 | 12,5 | Área de 14 studs; aplica Refractado 6 s (+10% de daño recibido) | GDD; el daño es propuesta |
| Núcleo Prismático | C · Paso de Relámpago | Movilidad | 120% | 25 | 9 | 13,3 | Parpadeo de 18 studs hacia un objetivo Refractado; 10 si no hay | GDD; el daño es propuesta |
| Núcleo Prismático | V · Prisma Total | Definitiva | 600% | 40 | 60 | 10,0 | Cúpula de 6 s; enemigos 20% más lentos y un rayo del 100% por segundo | GDD; el daño es propuesta |
| Núcleo de Brasa | Z · Chispa Voraz | Área | 200% | 20 | 6 | 33,3 | 140% + Quemadura del 60% en 4 s | Propuesta |
| Núcleo de Brasa | X · Cerco de Ascuas | Control | 140% | 25 | 12 | 11,7 | Anillo de 10 studs durante 4 s; quien lo cruza recibe Quemadura | Propuesta |
| Núcleo de Brasa | C · Estela Ígnea | Movilidad | 130% | 25 | 9 | 14,4 | Carrera de 14 studs que deja un rastro de fuego 3 s | Propuesta |
| Núcleo de Brasa | V · Sol Menor | Definitiva | 660% | 40 | 60 | 11,0 | Orbe de 6 s: 6 pulsos del 110% | Propuesta |
| Núcleo de Escarcha | Z · Esquirla Gélida | Área | 190% | 20 | 6 | 31,7 | Proyectil que estalla; Lento 20% 2 s | Propuesta |
| Núcleo de Escarcha | X · Ventisca Corta | Control | 130% | 25 | 12 | 10,8 | Cono; Congelación 1,2 s en PvE, Lento 40% 1,5 s en PvP | Propuesta |
| Núcleo de Escarcha | C · Patín de Hielo | Movilidad | 100% | 25 | 9 | 11,1 | Deslizamiento de 14 studs que deja hielo (Lento 20%) | Propuesta |
| Núcleo de Escarcha | V · Cero Absoluto | Definitiva | 540% | 40 | 60 | 9,0 | Área de 14 studs; Congelación 2 s en PvE, 1 s en PvP | Propuesta |
| Núcleo de Tormenta | Z · Arco Voltaico | Área | 210% | 20 | 6 | 35,0 | 130% + salta a 2 objetivos más al 40% | Propuesta |
| Núcleo de Tormenta | X · Jaula Estática | Control | 140% | 25 | 12 | 11,7 | Zona de 5 s; aplica Descarga | Propuesta |
| Núcleo de Tormenta | C · Salto de Chispa | Movilidad | 130% | 25 | 9 | 14,4 | Parpadeo de 16 studs que daña en la trayectoria | Propuesta |
| Núcleo de Tormenta | V · Juicio del Trueno | Definitiva | 600% | 40 | 60 | 10,0 | 3 rayos del 200% | Propuesta |
| Núcleo Sísmico | Z · Puño de Roca | Área | 210% | 20 | 6 | 35,0 | Onda corta; daño a la guardia ×1,5 | Propuesta |
| Núcleo Sísmico | X · Falla Abierta | Control | 140% | 25 | 12 | 11,7 | Grieta de 20 studs; derribo de 0,8 s en PvE; cuenta como 3 golpes de pico en depósitos | Propuesta |
| Núcleo Sísmico | C · Embestida Pétrea | Movilidad | 100% | 25 | 9 | 11,1 | Carga de 12 studs con un escudo del 10% de la vida máxima 3 s | Propuesta |
| Núcleo Sísmico | V · Cataclismo | Definitiva | 560% | 40 | 60 | 9,3 | Salto e impacto en 16 studs; rompe la guardia al instante | Propuesta |
| Núcleo Umbrío | Z · Tajo Velado | Área | 200% | 20 | 6 | 33,3 | Arco frontal; +30% de daño por la espalda | Propuesta |
| Núcleo Umbrío | X · Manto Nocturno | Control | 120% | 25 | 12 | 10,0 | Invisible 3 s; el siguiente golpe es crítico seguro y aplica Lento 30% 2 s | Propuesta |
| Núcleo Umbrío | C · Paso de Sombra | Movilidad | 130% | 25 | 9 | 14,4 | Parpadeo de 12 studs detrás del objetivo | Propuesta |
| Núcleo Umbrío | V · Eclipse | Definitiva | 600% | 40 | 60 | 10,0 | 6 cortes del 100% a un objetivo | Propuesta |

### 5.5 Factor de habilidades

- Con la energía base, un jugador usa las cuatro habilidades del Prismático lo bastante para sumar un 47,4% de la potencia del arma por segundo (B2, sección 8.4). Con 1.000 puntos de Energía, 73,2%.
- **Factor de referencia: ×1,39** sobre el ataque básico. Lo usan el «jugador típico» de este documento y el tope de DPS de mascotas de B5.

---

## 6. Anti-combo infinito

### 6.1 Reglas del GDD

| Regla | Valor | Origen |
|---|---|---|
| Rendimientos decrecientes | En una ventana de 6 s, el segundo control dura el 50% y el tercero no se aplica: da inmunidad (Tenacidad) | GDD |
| Duración de la Tenacidad | 5 s | El GDD propone 2 s; ver 6.2 |
| Tope de aturdimiento | Nadie puede estar aturdido más de 2,5 s seguidos | GDD |
| Ruptura | Tras 0,8 s bajo control, el jugador puede gastar 50 de energía para liberarse y empujar al atacante; enfriamiento de 15 s | GDD |
| Cancelación de animaciones | El dash cancela la recuperación de los ataques básicos, pero no la de las habilidades | GDD |
| Servidor autoritativo | El cliente pide la acción; el servidor valida alcance, enfriamientos, energía y daño | GDD |

### 6.2 Por qué la Tenacidad dura 5 s

Con dos controles de 1,5 s encadenados (2,25 s en total):

| Inmunidad (Tenacidad) tras el segundo control | Tiempo máximo bajo control | Con Ruptura disponible |
|---|---|---|
| 2 s (GDD) | 53% | 44% |
| 3 s | 43% | 34% |
| 5 s (adoptada) | 31% | 24% |
| 6 s | 27% | 21% |

- Con los 2 s del GDD, un jugador sin Ruptura disponible podría pasar el 53% del tiempo bajo control.
- Con 5 s baja al 31%. La Ruptura lo reduce más, pero cuesta la mitad de la barra de energía base y tiene 15 s de enfriamiento.

### 6.3 Reglas añadidas

| Regla | Valor |
|---|---|
| Escalado de daño en combo | Golpes 1 a 4 al 100%; después 90, 80, 70, 60 y 50% (mínimo 50%) |
| Guardia rota | Al quedarse sin energía bloqueando: 1,5 s aturdido en PvP (2,0 s en PvE); después, 8 s de inmunidad |
| Jefes | Inmunes a aturdimiento, Congelación y derribo; Lento les afecta a la mitad |

| Golpe del combo | Daño | Acumulado | Acumulado sin la regla |
|---|---|---|---|
| 1 | 100% | 100% | 100% |
| 2 | 100% | 200% | 200% |
| 3 | 100% | 300% | 300% |
| 4 | 100% | 400% | 400% |
| 5 | 90% | 490% | 500% |
| 6 | 80% | 570% | 600% |
| 7 | 70% | 640% | 700% |
| 8 | 60% | 700% | 800% |
| 9 | 50% | 750% | 900% |
| 10 | 50% | 800% | 1000% |

---

## 7. Enemigos

### 7.1 Multiplicadores por tipo

| Tipo | Vida (× PotZona × dureza) | Daño por golpe (% de la vida base del jugador de la zona) | Segundos entre golpes | XP (× Común) | Monedas (× valor de zona) | Puntos de maestría | Parte de los enemigos |
|---|---|---|---|---|---|---|---|
| Común | 16 | 3% | 1,5 | 1,0 | 1,40 | 1 | 88% |
| Élite | 64 | 6% | 1,8 | 3,5 | 5,60 | 4 | 10% |
| Guardián | 240 | 10% | 2,2 | 10,0 | 16,80 | 12 | 2% |
| Jefe | 1200 | 15% | 2,5 | 60,0 | 60,00 | 80 | 1 por zona |

- **F21 — Vida:** `Vida = PotZona(z) × FactorVida × Dureza(z)`.
- **F22 — Daño por golpe:** `Daño = VidaBase(nivel de la zona) × FactorDaño`.
- **F23 — XP:** `XP = 0,71 × (25 + 3,75·L + 0,002·L²) × FactorXP`.
- **F24 — Monedas:** `Monedas = 10 × 2,00^(z−1) × FactorMonedas`.
- **Ejemplo:** Élite de zona 1 → vida `100 × 64 × 1,0 = 6.400`; golpe `500 × 6% = 30`.
- Los factores de XP y de monedas los calibra el script para cumplir la XP por hora de B2 y quedar a la par del minero de B3.
- **Tutorial:** hasta el nivel 10 los enemigos de la zona 1 tienen la mitad de vida.
- **Regeneración en combate:** en PvE el jugador recupera el 0,5% de su vida máxima por segundo (5% fuera de combate). No se aplica en PvP.
- **Grupos:** los enemigos aparecen solos (70%), en parejas (25%) o en tríos (5%), separados al menos 20 studs.

### 7.2 Tabla de las 10 zonas

«Jugador típico» = arma Rara de la zona con la mitad de los bonos (×1,69 en total), build equilibrada y uso normal de habilidades.

| Zona | Tipo | Vida | Daño por golpe | XP | Monedas | Segundos para derrotarlo (jugador típico) |
|---|---|---|---|---|---|---|
| 1 | Común | 1.600 | 15 | 154 | 14 | 6,3 |
| 1 | Élite | 6.400 | 30 | 540 | 56 | 25,2 |
| 1 | Guardián | 24.000 | 50 | 1.544 | 168 | 94,3 |
| 1 | Jefe | 120.000 | 75 | 9.265 | 600 | 471,6 |
| 2 | Común | 3.520 | 30 | 449 | 28 | 6,3 |
| 2 | Élite | 14.080 | 60 | 1.572 | 112 | 25,2 |
| 2 | Guardián | 52.800 | 99 | 4.491 | 336 | 94,4 |
| 2 | Jefe | 264.000 | 149 | 26.944 | 1.200 | 472,0 |
| 3 | Común | 7.680 | 60 | 772 | 56 | 6,3 |
| 3 | Élite | 30.720 | 119 | 2.702 | 224 | 25,3 |
| 3 | Guardián | 115.200 | 199 | 7.721 | 672 | 95,0 |
| 3 | Jefe | 576.000 | 298 | 46.328 | 2.400 | 475,0 |
| 4 | Común | 16.640 | 119 | 1.124 | 112 | 6,4 |
| 4 | Élite | 66.560 | 238 | 3.933 | 448 | 25,6 |
| 4 | Guardián | 249.600 | 397 | 11.236 | 1.344 | 96,0 |
| 4 | Jefe | 1.248.000 | 596 | 67.414 | 4.800 | 479,9 |
| 5 | Común | 35.840 | 238 | 1.503 | 224 | 6,5 |
| 5 | Élite | 143.360 | 477 | 5.262 | 896 | 25,9 |
| 5 | Guardián | 537.600 | 794 | 15.034 | 2.688 | 97,2 |
| 5 | Jefe | 2.688.000 | 1.192 | 90.206 | 9.600 | 486,1 |
| 6 | Común | 76.800 | 477 | 1.912 | 448 | 6,6 |
| 6 | Élite | 307.200 | 953 | 6.691 | 1.792 | 26,3 |
| 6 | Guardián | 1.152.000 | 1.589 | 19.117 | 5.376 | 98,7 |
| 6 | Jefe | 5.760.000 | 2.383 | 114.700 | 19.200 | 493,4 |
| 7 | Común | 163.840 | 953 | 2.348 | 896 | 6,7 |
| 7 | Élite | 655.360 | 1.907 | 8.219 | 3.584 | 26,7 |
| 7 | Guardián | 2.457.600 | 3.178 | 23.483 | 10.752 | 100,3 |
| 7 | Jefe | 12.288.000 | 4.767 | 140.900 | 38.400 | 501,4 |
| 8 | Común | 348.160 | 1.907 | 2.813 | 1.792 | 6,8 |
| 8 | Élite | 1.392.640 | 3.813 | 9.847 | 7.168 | 27,2 |
| 8 | Guardián | 5.222.400 | 6.356 | 28.134 | 21.504 | 102,0 |
| 8 | Jefe | 26.112.000 | 9.534 | 168.802 | 76.800 | 510,1 |
| 9 | Común | 737.280 | 3.813 | 3.307 | 3.584 | 6,9 |
| 9 | Élite | 2.949.120 | 7.627 | 11.574 | 14.336 | 27,7 |
| 9 | Guardián | 11.059.200 | 12.712 | 33.068 | 43.008 | 103,8 |
| 9 | Jefe | 55.296.000 | 19.067 | 198.410 | 153.600 | 519,2 |
| 10 | Común | 1.556.480 | 7.627 | 3.829 | 7.168 | 7,1 |
| 10 | Élite | 6.225.920 | 15.254 | 13.400 | 28.672 | 28,2 |
| 10 | Guardián | 23.347.200 | 25.423 | 38.287 | 86.016 | 105,8 |
| 10 | Jefe | 116.736.000 | 38.135 | 229.720 | 307.200 | 528,8 |

### 7.3 Ritmo e ingresos del combatiente

| Zona | Build | s por enemigo Común | Enemigos/hora | XP/hora | XP/hora objetivo (B2) | Monedas/hora | Monedas/hora del minero equivalente (B3) | Combatiente / minero |
|---|---|---|---|---|---|---|---|---|
| 1 | Equilibrada (12,5%) | 6,3 | 241 | 53.230 | 52.200 | 5.130 | 5.175 | 0,99 |
| 1 | Combate (35% en Fuerza) | 5,8 | 255 | 56.307 | 52.200 | 5.426 | 5.354 | 1,01 |
| 2 | Equilibrada (12,5%) | 6,3 | 241 | 154.710 | 151.800 | 10.253 | 10.349 | 0,99 |
| 2 | Combate (35% en Fuerza) | 5,2 | 273 | 175.288 | 151.800 | 11.617 | 11.382 | 1,02 |
| 3 | Equilibrada (12,5%) | 6,3 | 240 | 264.875 | 261.000 | 20.420 | 19.661 | 1,04 |
| 3 | Combate (35% en Fuerza) | 4,9 | 282 | 311.821 | 261.000 | 24.039 | 23.519 | 1,02 |
| 4 | Equilibrada (12,5%) | 6,4 | 238 | 382.818 | 379.800 | 40.562 | 39.007 | 1,04 |
| 4 | Combate (35% en Fuerza) | 4,8 | 287 | 461.067 | 379.800 | 48.853 | 47.184 | 1,04 |
| 5 | Equilibrada (12,5%) | 6,5 | 236 | 507.827 | 508.200 | 80.425 | 78.013 | 1,03 |
| 5 | Combate (35% en Fuerza) | 4,7 | 289 | 620.267 | 508.200 | 98.232 | 95.111 | 1,03 |
| 6 | Equilibrada (12,5%) | 6,6 | 234 | 639.317 | 646.200 | 159.253 | 155.819 | 1,02 |
| 6 | Combate (35% en Fuerza) | 4,7 | 288 | 787.667 | 646.200 | 196.207 | 188.736 | 1,04 |
| 7 | Equilibrada (12,5%) | 6,7 | 231 | 776.798 | 793.800 | 315.040 | 295.882 | 1,06 |
| 7 | Combate (35% en Fuerza) | 4,8 | 286 | 962.062 | 793.800 | 390.176 | 376.451 | 1,04 |
| 8 | Equilibrada (12,5%) | 6,8 | 229 | 919.846 | 951.000 | 622.778 | 589.714 | 1,06 |
| 8 | Combate (35% en Fuerza) | 4,9 | 284 | 1.142.562 | 951.000 | 773.567 | 738.758 | 1,05 |
| 9 | Equilibrada (12,5%) | 6,9 | 226 | 1.068.092 | 1.117.800 | 1.230.476 | 1.177.945 | 1,04 |
| 9 | Combate (35% en Fuerza) | 4,9 | 281 | 1.328.485 | 1.117.800 | 1.530.457 | 1.468.285 | 1,04 |
| 10 | Equilibrada (12,5%) | 7,1 | 223 | 1.221.208 | 1.294.200 | 2.430.226 | 2.355.890 | 1,03 |
| 10 | Combate (35% en Fuerza) | 5,0 | 277 | 1.519.283 | 1.294.200 | 3.023.401 | 2.783.904 | 1,09 |

- Un enemigo Común cae en 6,3–7,1 s en cualquier zona.
- **XP:** el combatiente equilibrado queda entre -6% y 2% del objetivo de B2.
- **Monedas:** el combatiente gana entre 0,99 y 1,09 veces lo que el minero equivalente. El límite era 1,3.

---

## 8. Jefes

### 8.1 Reglas comunes

- **Tres fases** por vida: 100–60%, 60–30% y 30–0%. Al cambiar de fase el jefe es invulnerable 2 s y cambia de patrón.
- **Ataques telegrafiados:** todo ataque marca su zona en el suelo antes de golpear.

| Ataque | Aviso | Daño (% de la vida base del jugador de la zona) | Cómo se evita |
|---|---|---|---|
| Golpe normal | 0,6 s | 15% | Bloqueo o esquiva perfecta |
| Ataque fuerte | 1,2 s | 35% | Salir de la zona marcada |
| Ataque letal | 2,5 s | 70% | Mecánica propia del jefe |

- **Ventana de vulnerabilidad:** tras superar la mecánica, el jefe queda expuesto 6 s y recibe +50% de daño.
- **Furia:** a los 12 minutos el jefe hace +10% de daño cada 30 s.

### 8.2 Escalado cooperativo de 1 a 8 jugadores

- **F25:** `VidaJefe(n) = VidaBase × (1 + 0,6 × (n − 1))` y `DañoJefe(n) = DañoBase × (1 + 0,05 × (n − 1))`.

| Jugadores | Vida del jefe | Daño del jefe | Vida por jugador | Capataz de Pizarra: minutos | Madre Liquen: minutos | Leviatán de Salmuera: minutos |
|---|---|---|---|---|---|---|
| 1 | ×1,0 | ×1,00 | 100% | 7,9 | 7,9 | 7,9 |
| 2 | ×1,6 | ×1,05 | 80% | 6,3 | 6,3 | 6,3 |
| 3 | ×2,2 | ×1,10 | 73% | 5,8 | 5,8 | 5,8 |
| 4 | ×2,8 | ×1,15 | 70% | 5,5 | 5,5 | 5,5 |
| 5 | ×3,4 | ×1,20 | 68% | 5,3 | 5,3 | 5,4 |
| 6 | ×4,0 | ×1,25 | 67% | 5,2 | 5,2 | 5,3 |
| 7 | ×4,6 | ×1,30 | 66% | 5,2 | 5,2 | 5,2 |
| 8 | ×5,2 | ×1,35 | 65% | 5,1 | 5,1 | 5,1 |

- En solitario el combate dura unos 7,9 minutos; con 8 jugadores, 5,1.
- El número de jugadores se fija al empezar el combate.

### 8.3 Los 3 jefes del MVP

| Jefe | Zona | Vida (1 jugador) | Vida (8 jugadores) | Vida base del jugador de la zona | Golpe normal (15%) | Ataque fuerte (35%) | Ataque letal avisado (70%) | Monedas por jugador | XP por jugador |
|---|---|---|---|---|---|---|---|---|---|
| Capataz de Pizarra | 1 | 120.000 | 624.000 | 500 | 75 | 175 | 350 | 600 | 9.265 |
| Madre Liquen | 2 | 264.000 | 1.372.800 | 993 | 149 | 348 | 695 | 1.200 | 26.944 |
| Leviatán de Salmuera | 3 | 576.000 | 2.995.200 | 1.986 | 298 | 695 | 1.390 | 2.400 | 46.328 |

**Capataz de Pizarra (zona 1, Cantera del Alba).** Gólem minero con un pico enorme.

| Fase | Patrón | Ataque letal | Ventana de vulnerabilidad |
|---|---|---|---|
| 1 (100–60%) | Barridos de pico en arco (golpe normal) y pisotón en área (ataque fuerte) | — | Tras 3 barridos se le atasca el pico 4 s |
| 2 (60–30%) | Añade desprendimientos: 5 rocas marcadas en el suelo | «Derrumbe»: toda la sala salvo 3 zonas seguras | 6 s si nadie recibe el Derrumbe |
| 3 (30–0%) | Barridos dobles; invoca 2 enemigos comunes cada 20 s | «Derrumbe» con 2 zonas seguras | 6 s tras cada Derrumbe |

**Madre Liquen (zona 2, Galerías de Musgo).** Planta fúngica anclada al centro de la sala.

| Fase | Patrón | Ataque letal | Ventana de vulnerabilidad |
|---|---|---|---|
| 1 (100–60%) | Látigos de raíz en línea (golpe normal) y nube de esporas que aplica Lento (ataque fuerte) | — | Destruir sus 3 bulbos la deja expuesta 6 s |
| 2 (60–30%) | Los bulbos se regeneran cada 25 s; charcos que dañan con el tiempo | «Floración»: onda en toda la sala; hay que cubrirse tras un bulbo roto | 6 s tras la Floración |
| 3 (30–0%) | Látigos en cruz; 4 bulbos | «Floración» doble con 3 s entre ondas | 6 s tras la segunda onda |

**Leviatán de Salmuera (zona 3, Vetas Salinas).** Serpiente de sal cristalina que entra y sale del suelo.

| Fase | Patrón | Ataque letal | Ventana de vulnerabilidad |
|---|---|---|---|
| 1 (100–60%) | Mordisco frontal (golpe normal) y coletazo en arco trasero (ataque fuerte) | — | Tras emerger queda quieto 4 s |
| 2 (60–30%) | Se sumerge y emerge bajo un jugador marcado; deja pilares de sal | «Marea Seca»: embestida en línea; se evita poniéndose tras un pilar | Si choca contra un pilar queda aturdido 6 s |
| 3 (30–0%) | Dos zonas de emersión a la vez; los pilares duran la mitad | «Marea Seca» dos veces seguidas | 6 s tras cada choque |

### 8.4 Recompensas

| Recompensa | Valor |
|---|---|
| Monedas | `60 × valor de zona` por jugador |
| XP | 60 veces la de un enemigo Común, por jugador |
| Material de jefe | 3 garantizados por derrota; no depende de la Suerte |
| Núcleo | Cada jefe tiene un Núcleo asociado con una probabilidad pequeña de soltarlo (B6) |
| Requisito | Haber hecho al menos el 5% del daño o de la curación del grupo |
| Límite diario | 3 derrotas con botín completo por jefe y día; después, 25% de monedas y XP y sin material |

---

## 9. Reglas PvP

### 9.1 Reglas comunes (arenas y Zonas Fracturadas)

| Regla | Valor |
|---|---|
| Multiplicador de daño entre jugadores | ×0,062 |
| Defensa | `K = 4.500`, tope 50% |
| Vitalidad | `M = 1,0` en lugar de 3 |
| Tope por golpe | Ningún golpe quita más del 35% de la vida máxima del objetivo |
| Tope de ráfaga | Un jugador no pierde más del 60% de su vida máxima en 2 s por daño de otros jugadores |
| Tope de mascotas | 25% del DPS del jugador **[CONFIRMADO]** |
| Curación | Reducida un 50% |
| Control | Reglas de la sección 6; Congelación convertida en Lento |
| Transformación | Bono limitado al 10% (GDD) |
| Estadística de combate de los picos | Con su tope PvP (B3) |

### 9.2 Duración de un duelo (nivel 1.000, arma Legendaria al máximo)

Segundos que tarda el atacante en derrotar al defensor.

| Atacante ↓ / Defensor → | Cristal (Fue/Vel/Ene) | Tanque (Vit/Def/Fue) | Equilibrada (375 × 8) | Minero (Min/Sue/Vit) |
|---|---|---|---|---|
| Cristal (Fue/Vel/Ene) | 8,3 s | 15,1 s | 11,4 s | 12,4 s |
| Tanque (Vit/Def/Fue) | 12,0 s | 21,9 s | 16,5 s | 17,9 s |
| Equilibrada (375 × 8) | 13,0 s | 23,8 s | 17,9 s | 19,5 s |
| Minero (Min/Sue/Vit) | 29,9 s | 54,8 s | 41,2 s | 44,8 s |

- Sin el multiplicador, un duelo entre dos builds equilibradas duraría 1,1 s. El multiplicador se calibra para que dure 18 s.
- Los duelos entre builds de combate duran entre 8 y 24 s.
- El Tanque gana al Cristal con una ventaja de 1,27 veces; el Cristal lo compensa con movilidad.
- Una definitiva completa de un Cristal quita el 35% de la vida base, repartida en 6 s. El combo más explosivo (Núcleo Umbrío) sumaría el 73%: el tope de ráfaga lo deja en el 60%.

### 9.3 Arenas

| Regla | Valor |
|---|---|
| Modos | 1 contra 1, 2 contra 2 y 3 contra 3 |
| Igualación | Por tramos de 100 niveles; todos pelean con el nivel máximo del tramo y la potencia de arma de esa zona |
| Emparejamiento | Puntuación Elo: inicio 1.000, factor 32; rival a ±100 puntos, con margen que crece 50 cada 15 s |
| Qué se arriesga | Solo puntuación |
| Formato | Al mejor de 3 rondas de 90 s |

### 9.4 Reglas específicas de las Zonas Fracturadas

| Regla | Valor |
|---|---|
| PvP | Siempre activo **[CONFIRMADO]** |
| Protección | 10 s al entrar y al reaparecer mientras no ataques (GDD) |
| Sincronización de nivel | Nivel efectivo máximo `100 × z`; potencia de arma y pico limitada a la de un Ultra raro de esa zona al máximo |
| Escuadrón | Hasta 3 jugadores; sin fuego amigo; carga compartida y extracción más rápida (GDD; valores en B6) |
| Debuff de carga | Fórmula F17 de B3; dash y parpadeo no se ralentizan |
| Invisibilidad | Manto Nocturno no oculta el resplandor de carga ni la marca del minimapa |
| Extracción | 8 s de canalización; el daño la reinicia |
| Qué se arriesga | Solo el mineral transportado **[CONFIRMADO]** |

---

## 10. Problemas de balance detectados y alternativas

### P1 — La Tenacidad de 2 s del GDD permite controlar más de la mitad del tiempo

- Resuelto con Tenacidad de 5 s (sección 6.2). Se valida en arenas de prueba.

### P2 — Las habilidades del GDD pesan menos que las de la primera versión

- **Dato:** el Prismático del GDD suma 72,5% de la potencia del arma por segundo (enfriamientos de 6 a 60 s). El conjunto propuesto antes sumaba 154%.
- **Efecto:** el factor de habilidades baja de ×1,75 a ×1,39. Se ha recalibrado la vida de los enemigos (20 → 16 veces la potencia de zona para el Común) para mantener 6–7 s por enemigo.
- **Consecuencia:** el ataque básico y la movilidad pesan más; las habilidades son momentos puntuales. Encaja con «el combate premia moverse bien» del GDD.

### P3 — Mezclar técnicas de arma puede dar más daño que el Núcleo completo

- **Dato:** hasta 101,7% por segundo frente a 72,5%, a cambio de 9,50 de energía por segundo y de perder el control y la movilidad del Núcleo.
- **A vigilar en B7:** que no se convierta en la única configuración usada en PvE.

### P4 — Sin multiplicador PvP los duelos duran 1,1 s

- Las armas están calibradas contra enemigos con mucha más vida que un jugador. Resuelto con `MultModo = 0,062` y los topes de golpe y de ráfaga.

### P5 — El Tanque sigue por delante del Cristal

- Ventaja de 1,27 veces con Vitalidad `M = 1,0` y Defensa con tope 50% en PvP. Se mide en la beta.

### P6 — El máximo teórico de daño es 54,7 veces el de un arma Común

- Exige alcanzar todos los topes a la vez. B7 comprueba el máximo real.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| Coeficientes de arma y técnicas | Prueba de juego con cada tipo contra el mismo enemigo; diferencia menor del 10% |
| Daño de las habilidades del Prismático | Construir el Núcleo y medir el factor real de habilidades (objetivo ×1,39) |
| Vida y daño de enemigos | 6–7 s por enemigo Común y menos de 2 muertes por hora |
| `MultModo = 0,062` | Arenas de prueba: duelos de 10–25 s |
| Tenacidad y Ruptura | Prueba dirigida: tiempo máximo bajo control |
| Escalado de jefes | Tiempo real de derrota con 1, 4 y 8 jugadores |
