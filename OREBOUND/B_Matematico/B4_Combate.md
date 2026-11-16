# OREBOUND — B4: Combate

Etapa 4 · 2026-11-16 (corregido en las Etapas 6 y 7; ver B7, sección 6) · Script: `calculos/b4_combate.py` · Catálogo completo de armas: `calculos/b4_armas.csv` (450 armas).

> **Aviso de fuentes.** No se dispone de las secciones 10, 15 y 17 del prompt maestro ni de la
> sección de combate del GDD. El sexto tipo de arma, los valores del Núcleo Prismático y los
> jefes son propuestas **[PROVISIONAL]**. Son **[CONFIRMADO]** las decisiones fijas: ataque
> básico + 4 ranuras (Z, X, C, V) + movilidad (dash, doble salto, parpadeo), tope de mascotas
> del 25% en PvP y el nombre provisional «Núcleos de Poder».

---

## 1. Armas

### 1.1 Los 6 tipos

| Tipo | Golpes/s | Coef. por golpe | Alcance (studs) | Objetivos | DPS relativo (con críticos) | Frente a la media de los 5 | Qué lo diferencia |
|---|---|---|---|---|---|---|---|
| Espada | 1,60 | 0,625 | 8 | 2 | 1,025 | +0,8 % | Equilibrada; combo de 4 golpes; bloquear cuesta 20 % menos |
| Hacha | 0,90 | 1,150 | 9 | 3 | 1,061 | +4,3 % | Arco de 180°; golpea hasta 3; daño a la guardia ×1,5 |
| Daga | 2,60 | 0,365 | 6 | 1 | 1,020 | +0,3 % | +10 % de crítico; +25 % de daño por la espalda |
| Lanza | 1,20 | 0,810 | 14 | 3 | 0,996 | -2,1 % | Largo alcance; atraviesa hasta 3 en línea |
| Bastón | 1,00 | 0,960 | 35 | 1 | 0,984 | -3,3 % | Proyectil a media distancia; habilidades cuestan 10 % menos de energía |
| Arco | 1,10 | 0,727 | 70 | 1 | 0,820 | -19,4 % | Sexto tipo: largo alcance; DPS menor a propósito |

- **F18 — Daño por golpe:** `DañoGolpe = PotenciaArma × Coef(tipo)`, con `PotenciaArma = PotZona(z) × MultRareza × (1 + bonos)` (B1).
- **DPS relativo:** `Golpes/s × Coef × (1 + ProbCrítico × 0,5)`. La Daga suma +10% de crítico.
- **Resultado:** Espada, Hacha, Daga, Lanza y Bastón quedan entre −3,3% y +4,3% de su media. El requisito era ±10%.
- **Arco (sexto tipo):** queda un 19,4% por debajo a propósito (decisión C-30). Lo compensa con 70 studs de alcance. El prompt no nombra el sexto tipo; el Arco es propuesta.
- El Hacha tiene el DPS más alto de los cinco porque sus golpes lentos se fallan con más facilidad.
- **Golpes en área (regla de la Etapa 7):** un golpe básico alcanza como máximo 3 objetivos; el primero recibe el 100% y los demás el 25%. Sin esta regla, el Hacha contra grupos multiplicaba por 3,7 los enemigos por hora.

### 1.2 Daño por golpe de un arma Común, por zona

| Zona | Nivel | Potencia (Común) | Espada | Hacha | Daga | Lanza | Bastón | Arco |
|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 100 | 62,5 | 115,0 | 36,5 | 81,0 | 96,0 | 72,7 |
| 2 | 100 | 165 | 103,1 | 189,7 | 60,2 | 133,7 | 158,4 | 120,0 |
| 3 | 200 | 272 | 170,2 | 313,1 | 99,4 | 220,5 | 261,4 | 197,9 |
| 4 | 300 | 449 | 280,8 | 516,6 | 164,0 | 363,9 | 431,2 | 326,6 |
| 5 | 400 | 741 | 463,3 | 852,4 | 270,5 | 600,4 | 711,6 | 538,9 |
| 6 | 500 | 1.223 | 764,4 | 1.406,4 | 446,4 | 990,6 | 1.174,1 | 889,1 |
| 7 | 600 | 2.018 | 1.261,2 | 2.320,6 | 736,5 | 1.634,5 | 1.937,2 | 1.467,0 |
| 8 | 700 | 3.330 | 2.081,0 | 3.829,0 | 1.215,3 | 2.696,9 | 3.196,4 | 2.420,6 |
| 9 | 800 | 5.494 | 3.433,6 | 6.317,9 | 2.005,2 | 4.450,0 | 5.274,0 | 3.994,0 |
| 10 | 900 | 9.065 | 5.665,5 | 10.424,5 | 3.308,6 | 7.342,4 | 8.702,2 | 6.590,1 |

Para otra rareza se multiplica por su factor; con mejoras, por `(1 + bonos)` hasta ×2.

### 1.3 Rareza y habilidad de arma

| Rareza | Mult. potencia | Habilidad de arma |
|---|---|---|
| Común | 1,00 | Ninguna |
| Poco común | 1,15 | Filo templado: el 4.º golpe del combo hace +30 % |
| Raro | 1,32 | Sed de combate: +5 % de velocidad de ataque 3 s tras matar |
| Épico | 1,52 | Golpe resonante: cada 8 s el siguiente golpe aplica Vulnerable 3 s |
| Legendario | 1,75 | Furia medida: +10 % de daño con la vida por encima del 80 % |
| Mítico | 1,98 | Eco del acero: 15 % de repetir el golpe al 40 % |
| Ultra raro | 2,20 | Remate: +20 % de daño a objetivos por debajo del 25 % de vida |
| Celestial | 2,60 | Juicio astral: cada 20 s el siguiente golpe es crítico seguro y aplica Vulnerable |

- **Nivel requerido:** el de la zona del arma (`100 × (zona − 1)`).
- **Catálogo:** 6 tipos × 10 zonas × 7 rarezas = 420 armas, más 30 Celestiales (6 tipos × zonas 6 a 10). Total 450, fila a fila en el CSV.
- **Nombres:** tipo + «de» + Pizarra, Verdín, Sal, Brasa, Escarcha, Eco, Obsidiana, Magma, Vitral o Astral.
- **Mejoras:** las mismas que los picos (B3): nivel de objeto +50%, ranuras +30% y Despertar de habilidad +20%.

---

## 2. Fórmula completa de daño

### F19 — Daño final

```
Daño = PotenciaArma × Coef × MultFuerza × MultMaestría × MultCrítico
       × (1 + EstadosDelObjetivo) × (1 − ReducciónDefensa) × MultModo
```

| Término | Fórmula o valor | Límite |
|---|---|---|
| `PotenciaArma` | `PotZona × MultRareza × (1 + bonos)` | Bonos hasta +100% (B1) |
| `Coef` | Coeficiente del golpe básico (tabla 1.1) o de la habilidad (sección 4) | — |
| `MultFuerza` | `1 + 3·F/(F + 1.000)` | Máximo ×4 (B2) |
| `MultMaestría` | `1 + 0,001 × nivel de maestría` | Máximo ×1,10 |
| `MultCrítico` | ×1,5 con probabilidad 5% | Probabilidad máxima 30%; multiplicador máximo ×2,0 |
| `EstadosDelObjetivo` | Suma de Vulnerable, Descarga y Ruptura | Máximo +40% |
| `ReducciónDefensa` | `mín(D/(D + K), Tope)` | 75% en PvE, 50% en PvP (B2, corregido en la Etapa 7) |
| `MultModo` | 1 en PvE; 0,06 en PvP y Zonas Fracturadas | — |

- **Unidad:** puntos de vida.
- **Orden:** los términos se multiplican en ese orden; la Defensa va después de todos los bonos del atacante. El daño mínimo es 1.
- **Ejemplo:**

| Paso | Daño |
|---|---|
| Golpe de Espada Épica de zona 5 con +50 % de bonos | 1.056 |
| × Fuerza 500 (×2,000) | 2.112 |
| × Maestría 50 (×1,05) | 2.218 |
| × crítico (×1,5) | 3.327 |
| × objetivo Vulnerable (+15 %) | 3.826 |
| × (1 − 25 %) por Defensa 500 en PvE | 2.870 |

- **Límites del conjunto:** en la misma zona, una build final típica hace 8,5 veces el daño de un arma Común sin nada. El máximo teórico, con todos los topes a la vez, es 36,4 veces. Nueve zonas de diferencia son 90,6 veces: la zona sigue pesando más que la build.
- **Posibles problemas:** el máximo teórico es alto. Ningún término nuevo debe multiplicar fuera de esta lista; cualquier bono futuro entra en `bonos` o en `EstadosDelObjetivo`, que tienen tope.

### 2.1 Estados alterados

| Estado | Efecto | Duración | En PvP |
|---|---|---|---|
| Quemadura | Daño en el tiempo indicado por la habilidad; no se acumula, se renueva | 4 s | Igual (ya reducido por `MultModo`) |
| Lento | −20% o −40% de velocidad de movimiento | 1,5–2 s | Igual |
| Congelación | Inmoviliza | 1,2–2 s | Se convierte en Lento 40% o dura la mitad |
| Descarga | El siguiente golpe recibido hace +15% | Hasta consumirse o 5 s | Igual |
| Vulnerable | +10% o +15% de daño recibido | 3–4 s | Igual |
| Ruptura | Aturdido y +25% de daño recibido | 2,0 s aturdido en PvE, 1,5 s en PvP; +25% durante 3 s | Inmune a otra Ruptura 8 s |

Los aumentos de daño recibido se suman entre sí y no pasan de +40%.

---

## 3. Maestría de armas y de Núcleos

### F20 — XP de maestría

- **Expresión:** `XPm(n) = techo(10 + 2·n + 0,04·n²)` para pasar del nivel `n` al `n+1`.
- **Cómo se gana:** al derrotar enemigos con esa arma o ese Núcleo equipado. Común 1 punto, Élite 4, Guardián 12, Jefe 80. Solo cuentan enemigos de la zona del jugador o de la anterior.
- **Ejemplo:** `XPm(50) = techo(10 + 100 + 100) = 210`.
- **Bono:** +0,1% de daño por nivel, hasta +10% en el nivel 100.
- **Una maestría por tipo de arma** (6) y **una por Núcleo** (6). Avanzan a la vez la del arma y la del Núcleo equipados.

| Nivel de maestría | XP para el siguiente | XP acumulada | Horas acumuladas | Desbloqueo (Núcleo / arma) |
|---|---|---|---|---|
| 1 | 13 | 0 | 0,0 | Habilidad Z del Núcleo / combo básico del arma |
| 10 | 34 | 196 | 0,6 | Habilidad X / remate de combo del arma |
| 25 | 85 | 1.046 | 2,9 | Habilidad C / pasiva de arma 1 |
| 50 | 210 | 4.577 | 12,9 | Habilidad V / pasiva de arma 2 |
| 75 | 385 | 11.833 | 33,4 | Despertar disponible / variante de ataque cargado |
| 100 | 610 | 24.064 | 67,9 | Transformación / título y aspecto de maestro |

- Ritmo: 355 puntos por hora (combatiente equilibrado en zona 5). Nivel 100 en 67,9 horas por arma o Núcleo.
- Las cuatro habilidades de un Núcleo están disponibles a las 12,9 horas (maestría 50).

### 3.1 ¿Debe seguir después de 100?

**Sí, pero sin dar poder.** Por encima de 100:

- Cada nivel cuesta lo mismo que el 100 (610 puntos, unos 103 minutos).
- No da más daño: el bono se queda en +10%.
- Da una estrella de prestigio visible en el perfil y, cada 10 niveles, un cofre de monedas y un aspecto de arma.

Así los jugadores veteranos tienen algo que seguir subiendo sin que crezca la diferencia de poder.

---

## 4. Núcleos de Poder

### 4.1 Estructura común

- Cada Núcleo tiene **4 habilidades** (ranuras Z, X, C y V) **y 1 pasiva**. Se equipa uno a la vez; cambiarlo solo es posible fuera de combate.
- El daño de las habilidades es un porcentaje de la potencia del arma equipada y usa la fórmula F19. Un Núcleo no queda obsoleto al cambiar de zona.
- **Presupuesto de referencia** (Núcleo Prismático): Z 180% / 15 de energía / 4 s; X 320% / 25 / 8 s; C 500% / 35 / 14 s; V 1.000% / 50 / 30 s.
- **Desbloqueo por maestría del Núcleo:** Z al nivel 1, X al 10, C al 25, V al 50.

### 4.2 Despertar

| Aspecto | Valor |
|---|---|
| Requisito | Maestría 75 del Núcleo, una misión propia y materiales de jefe |
| Efecto | +15% al daño de las cuatro habilidades y un efecto nuevo por Núcleo (tabla 4.4) |
| En PvP | El +15% se reduce a +8% |
| Venta | Nunca se vende por dinero real **[decisión del prompt]** |

### 4.3 Transformación

| Aspecto | PvE | PvP y Zonas Fracturadas |
|---|---|---|
| Requisito | Núcleo Despertado y maestría 100 | Igual |
| Carga | Barra de Sincronía: se llena haciendo y recibiendo daño (unos 90 s de combate) | Igual |
| Duración | 20 s | 12 s |
| Daño de habilidades | +20% | +10% |
| Enfriamientos | −20% | −10% |
| Enfriamiento de la Transformación | 120 s | 120 s |
| Otros | Cambia el aspecto y la animación del ataque básico; no cura ni da invulnerabilidad | Visible para todos con un aviso de 1 s |

### 4.4 Los 6 Núcleos de lanzamiento

| Núcleo | Elemento | Rol | Daño por segundo con todo en uso | Energía por segundo | Daño por energía | Pasiva | Despertar | Transformación |
|---|---|---|---|---|---|---|---|---|
| Núcleo Prismático | Luz | Versátil a media distancia | 154,0 % | 11,04 | 14,0 | Refracción: cada 4.º golpe básico lanza un destello del 40 % a un segundo objetivo | El Haz rebota una vez al 50 % | Forma Caleidoscopio |
| Núcleo de Brasa | Fuego | Daño en el tiempo | 154,0 % | 11,04 | 14,0 | Rescoldo: los golpes críticos aplican Quemadura | La Quemadura se propaga a un enemigo cercano | Forma Ascua Viva |
| Núcleo de Escarcha | Hielo | Control | 124,8 % | 10,59 | 11,8 | Piel de Escarcha: quien te golpea queda con Lento 20 % 2 s (una vez cada 10 s) | Los enemigos con Lento reciben +10 % de tus habilidades | Forma Glaciar |
| Núcleo de Tormenta | Rayo | Movilidad y cadenas | 144,8 % | 11,04 | 13,1 | Carga Estática: cada 10 studs recorridos da 1 carga (máx. 5); el siguiente básico hace +6 % por carga | Paso Relámpago guarda 2 cargas | Forma Tempestad |
| Núcleo Sísmico | Tierra | Aguante y Ruptura | 128,2 % | 10,00 | 12,8 | Corteza: +8 % de reducción de daño tras 1 s sin moverte (sin superar el tope de Defensa) | Bastión también protege a aliados a 10 studs al 50 % | Forma Coloso |
| Núcleo Umbrío | Sombra | Asesino | 135,7 % | 10,88 | 12,5 | Hambre de Vacío: cada muerte reduce los enfriamientos 1 s (0,5 s en PvP) | Manto Nocturno dura 1 s más y no se rompe al usar Paso de Sombra | Forma Penumbra |

- Prismático y Brasa marcan el daño de referencia (154% de la potencia del arma por segundo con todo en uso).
- Tormenta (−6%), Umbrío (−12%), Sísmico (−17%) y Escarcha (−19%) hacen menos daño a cambio de movilidad, invisibilidad, escudo o control. Es intencionado.
- El Núcleo inicial de todos los jugadores es el Prismático. Los demás se consiguen jugando (jefes y misiones; se concreta en la Etapa 6).

### 4.5 Habilidades

| Núcleo | Habilidad | Daño (% de potencia de arma) | Energía | Enfriamiento (s) | % por segundo | % por punto de energía | Efecto |
|---|---|---|---|---|---|---|---|
| Núcleo Prismático | Z · Haz Facetado | 180 % | 15 | 4,0 | 45,0 | 12,0 | Rayo en línea de 25 studs |
| Núcleo Prismático | X · Abanico Espectral | 320 % | 25 | 8,0 | 40,0 | 12,8 | 5 esquirlas en cono (64 % cada una) |
| Núcleo Prismático | C · Prisma Centinela | 500 % | 35 | 14,0 | 35,7 | 14,3 | Prisma 6 s: 10 pulsos del 50 % en 12 studs |
| Núcleo Prismático | V · Espectro Total | 1000 % | 50 | 30,0 | 33,3 | 20,0 | Rayo canalizado 2,5 s; aplica Vulnerable +10 % 4 s |
| Núcleo de Brasa | Z · Chispa Voraz | 180 % | 15 | 4,0 | 45,0 | 12,0 | 120 % + Quemadura del 60 % en 4 s |
| Núcleo de Brasa | X · Estela Ígnea | 320 % | 25 | 8,0 | 40,0 | 12,8 | Carrera de fuego: 200 % + rastro de 120 % en 3 s |
| Núcleo de Brasa | C · Géiser de Ceniza | 500 % | 35 | 14,0 | 35,7 | 14,3 | Área de 10 studs tras 0,8 s: 420 % + Quemadura del 80 % |
| Núcleo de Brasa | V · Sol Menor | 1000 % | 50 | 30,0 | 33,3 | 20,0 | Orbe 5 s: 10 pulsos del 100 % |
| Núcleo de Escarcha | Z · Esquirla Gélida | 160 % | 15 | 4,0 | 40,0 | 10,7 | Proyectil; Lento 20 % 2 s |
| Núcleo de Escarcha | X · Muro de Hielo | 240 % | 25 | 9,0 | 26,7 | 9,6 | Barrera 4 s que bloquea proyectiles; daña al aparecer |
| Núcleo de Escarcha | C · Ventisca Corta | 420 % | 35 | 14,0 | 30,0 | 12,0 | Cono; Congelación 1,2 s en PvE, Lento 40 % 1,5 s en PvP |
| Núcleo de Escarcha | V · Cero Absoluto | 900 % | 50 | 32,0 | 28,1 | 18,0 | Área de 14 studs; Congelación 2 s en PvE, 1 s en PvP |
| Núcleo de Tormenta | Z · Arco Voltaico | 180 % | 15 | 4,0 | 45,0 | 12,0 | 110 % + salta a 2 objetivos más al 35 % |
| Núcleo de Tormenta | X · Paso Relámpago | 280 % | 25 | 8,0 | 35,0 | 11,2 | Parpadeo de 18 studs que daña en la trayectoria |
| Núcleo de Tormenta | C · Jaula Estática | 440 % | 35 | 14,0 | 31,4 | 12,6 | Zona 5 s: 8 pulsos del 55 %; aplica Descarga |
| Núcleo de Tormenta | V · Juicio del Trueno | 1000 % | 50 | 30,0 | 33,3 | 20,0 | 3 rayos del 300 % + cadena del 100 % |
| Núcleo Sísmico | Z · Puño de Roca | 190 % | 15 | 4,5 | 42,2 | 12,7 | Golpe corto; daño a la guardia ×1,5 |
| Núcleo Sísmico | X · Bastión | 200 % | 25 | 10,0 | 20,0 | 8,0 | Escudo del 15 % de la vida máxima 4 s; estalla al acabar |
| Núcleo Sísmico | C · Falla Abierta | 480 % | 35 | 14,0 | 34,3 | 13,7 | Grieta de 20 studs; derribo 0,8 s en PvE; cuenta como 3 golpes de pico en depósitos |
| Núcleo Sísmico | V · Cataclismo | 950 % | 50 | 30,0 | 31,7 | 19,0 | Salto e impacto en 16 studs; rompe la guardia al instante |
| Núcleo Umbrío | Z · Tajo Velado | 170 % | 15 | 4,0 | 42,5 | 11,3 | +30 % de daño por la espalda |
| Núcleo Umbrío | X · Paso de Sombra | 260 % | 25 | 8,0 | 32,5 | 10,4 | Parpadeo de 12 studs detrás del objetivo |
| Núcleo Umbrío | C · Manto Nocturno | 460 % | 35 | 15,0 | 30,7 | 13,1 | Invisible 3 s; el siguiente golpe es crítico seguro |
| Núcleo Umbrío | V · Eclipse | 900 % | 50 | 30,0 | 30,0 | 18,0 | 6 cortes del 150 % a un objetivo |

---

## 5. Movilidad y anti-combo infinito

### 5.1 Movilidad

| Acción | Efecto | Energía | Enfriamiento | Notas |
|---|---|---|---|---|
| Dash | 12 studs en 0,2 s | 20 | 2,5 s | Sin invulnerabilidad |
| Doble salto | Segundo salto al 70% de altura | 0 | 1 por salto | — |
| Parpadeo | Teletransporte de 16 studs | 30 | 8 s | No atraviesa paredes; con carga del 75% o más en Zona Fracturada, 12 studs |
| Esquiva | Rodar 8 studs | 20 | 1,2 s | 0,3 s de invulnerabilidad |
| Bloqueo | Reduce el daño frontal un 70% | 8/s + 10 por golpe | — | Con energía 0: Ruptura |

### 5.2 Escalado de daño en combo

A partir del 5.º golpe seguido sobre un objetivo aturdido, cada golpe hace menos daño.

| Golpe del combo | Daño | Acumulado | Acumulado sin la regla |
|---|---|---|---|
| 1 | 100 % | 100 % | 100 % |
| 2 | 100 % | 200 % | 200 % |
| 3 | 100 % | 300 % | 300 % |
| 4 | 100 % | 400 % | 400 % |
| 5 | 90 % | 490 % | 500 % |
| 6 | 80 % | 570 % | 600 % |
| 7 | 70 % | 640 % | 700 % |
| 8 | 60 % | 700 % | 800 % |
| 9 | 50 % | 750 % | 900 % |
| 10 | 50 % | 800 % | 1000 % |

### 5.3 Rendimientos decrecientes del control

| Control sobre el mismo objetivo en 10 s | Duración | Ejemplo con un aturdimiento de 1,5 s |
|---|---|---|
| 1.º | 100 % | 1,50 s |
| 2.º | 50 % | 0,75 s |
| 3.º | 25 % | 0,38 s |
| 4.º | Inmune 6 s | 0 s |

### 5.4 Resto de reglas

| Regla | Valor |
|---|---|
| Tope de aturdimiento | 2,0 s de aturdimiento acumulado en una ventana de 4 s |
| Rompecadenas | Al llegar al tope, el objetivo queda libre con 0,6 s de invulnerabilidad y empuja a quien esté a 6 studs |
| Aturdimiento por golpe básico | 0,25 s en PvP; los enemigos comunes no tienen límite, los jefes son inmunes |
| Ruptura | Al quedarse sin energía bloqueando: 1,5 s aturdido en PvP (2,0 s en PvE) y +25% de daño recibido 3 s; después, 8 s de inmunidad a Ruptura |
| Cancelación de animaciones | Un básico solo se puede cancelar con dash, esquiva o habilidad a partir del 60% de la animación |
| Coste de cancelar | El dash o la esquiva usados para cancelar cuestan +50% de energía |
| Límite de cancelaciones | 1 cada 1,5 s |
| Habilidad en habilidad | No se puede cancelar una habilidad con otra |

**Resultado:** encadenando tres aturdimientos de 1,5 s, el control total sería 2,63 s, pero el tope lo corta en 2,0 s. Con la inmunidad de 6 s, un jugador no puede estar controlado más del 12,5% del tiempo.

---

## 6. Enemigos

### 6.1 Multiplicadores por tipo

| Tipo | Vida (× PotZona × dureza) | Daño por golpe (% de la vida base del jugador de la zona) | Segundos entre golpes | XP (× Común) | Monedas (× valor de zona) | Puntos de maestría | Parte de los enemigos |
|---|---|---|---|---|---|---|---|
| Común | 20 | 3 % | 1,5 | 1,0 | 1,4 | 1 | 88 % |
| Élite | 80 | 6 % | 1,8 | 3,5 | 5,4 | 4 | 10 % |
| Guardián | 300 | 10 % | 2,2 | 10,0 | 16,0 | 12 | 2 % |
| Jefe | 1500 | 15 % | 2,5 | 60,0 | 60,0 | 80 | 1 por zona |

- **F21 — Vida:** `Vida = PotZona(z) × FactorVida × Dureza(z)`.
- **F22 — Daño por golpe:** `Daño = VidaBase(nivel de la zona) × FactorDaño`.
- **F23 — XP:** `XP = 0,72 × (25 + 3,75·L + 0,002·L²) × FactorXP`, con `L` = nivel medio de la zona.
- **F24 — Monedas:** `Monedas = 10 × 1,65^(z−1) × FactorMonedas`.
- **Ejemplo:** Élite de zona 1 → vida `100 × 80 × 1,0 = 8.000`; golpe `500 × 6% = 30`.
- **Tutorial:** hasta el nivel 10 los enemigos de la zona 1 tienen la mitad de vida.
- **Regeneración en combate (Etapa 7):** en PvE el jugador recupera el 0,5% de su vida máxima por segundo durante el combate (5% fuera de combate). No se aplica en PvP.
- **Grupos de enemigos (Etapa 7):** aparecen solos (70%), en parejas (25%) o en tríos (5%), separados al menos 20 studs.

### 6.2 Tabla de las 10 zonas

«Jugador típico» = arma Rara de la zona con +25% de bonos, build equilibrada y uso normal de habilidades.

| Zona | Tipo | Vida | Daño por golpe | Segundos entre golpes | XP | Monedas | Segundos para matarlo (jugador típico) |
|---|---|---|---|---|---|---|---|
| 1 | Común | 2.000 | 15 | 1,5 | 157 | 14 | 6,4 |
| 1 | Élite | 8.000 | 30 | 1,8 | 548 | 54 | 25,6 |
| 1 | Guardián | 30.000 | 50 | 2,2 | 1.566 | 160 | 96,1 |
| 1 | Jefe | 150.000 | 75 | 2,5 | 9.396 | 600 | 480,3 |
| 2 | Común | 3.630 | 25 | 1,5 | 455 | 22 | 6,4 |
| 2 | Élite | 14.520 | 49 | 1,8 | 1.594 | 89 | 25,6 |
| 2 | Guardián | 54.450 | 82 | 2,2 | 4.554 | 264 | 96,1 |
| 2 | Jefe | 272.250 | 123 | 2,5 | 27.324 | 990 | 480,7 |
| 3 | Común | 6.534 | 41 | 1,5 | 783 | 37 | 6,5 |
| 3 | Élite | 26.136 | 81 | 1,8 | 2.740 | 147 | 25,8 |
| 3 | Guardián | 98.010 | 135 | 2,2 | 7.830 | 436 | 96,8 |
| 3 | Jefe | 490.050 | 203 | 2,5 | 46.980 | 1.633 | 483,8 |
| 4 | Común | 11.680 | 67 | 1,5 | 1.139 | 61 | 6,5 |
| 4 | Élite | 46.718 | 134 | 1,8 | 3.988 | 243 | 26,1 |
| 4 | Guardián | 175.193 | 223 | 2,2 | 11.394 | 719 | 97,7 |
| 4 | Jefe | 875.964 | 335 | 2,5 | 68.364 | 2.695 | 488,7 |
| 5 | Común | 20.754 | 111 | 1,5 | 1.525 | 100 | 6,6 |
| 5 | Élite | 83.014 | 221 | 1,8 | 5.336 | 400 | 26,4 |
| 5 | Guardián | 311.304 | 369 | 2,2 | 15.246 | 1.186 | 99,0 |
| 5 | Jefe | 1.556.521 | 553 | 2,5 | 91.476 | 4.447 | 495,1 |
| 6 | Común | 36.689 | 183 | 1,5 | 1.939 | 165 | 6,7 |
| 6 | Élite | 146.758 | 365 | 1,8 | 6.785 | 660 | 26,8 |
| 6 | Guardián | 550.341 | 608 | 2,2 | 19.386 | 1.957 | 100,5 |
| 6 | Jefe | 2.751.707 | 913 | 2,5 | 116.316 | 7.338 | 502,5 |
| 7 | Común | 64.573 | 301 | 1,5 | 2.381 | 272 | 6,8 |
| 7 | Élite | 258.294 | 602 | 1,8 | 8.335 | 1.090 | 27,2 |
| 7 | Guardián | 968.601 | 1.004 | 2,2 | 23.814 | 3.229 | 102,1 |
| 7 | Jefe | 4.843.005 | 1.506 | 2,5 | 142.884 | 12.108 | 510,7 |
| 8 | Común | 113.205 | 497 | 1,5 | 2.853 | 449 | 6,9 |
| 8 | Élite | 452.821 | 994 | 1,8 | 9.986 | 1.798 | 27,7 |
| 8 | Guardián | 1.698.079 | 1.656 | 2,2 | 28.530 | 5.327 | 103,9 |
| 8 | Jefe | 8.490.393 | 2.485 | 2,5 | 171.180 | 19.977 | 519,5 |
| 9 | Común | 197.776 | 820 | 1,5 | 3.353 | 742 | 7,1 |
| 9 | Élite | 791.105 | 1.640 | 1,8 | 11.737 | 2.967 | 28,2 |
| 9 | Guardián | 2.966.643 | 2.733 | 2,2 | 33.534 | 8.790 | 105,8 |
| 9 | Jefe | 14.833.216 | 4.100 | 2,5 | 201.204 | 32.963 | 528,8 |
| 10 | Común | 344.460 | 1.353 | 1,5 | 3.883 | 1.224 | 7,2 |
| 10 | Élite | 1.377.841 | 2.706 | 1,8 | 13.589 | 4.895 | 28,7 |
| 10 | Guardián | 5.166.904 | 4.510 | 2,2 | 38.826 | 14.504 | 107,7 |
| 10 | Jefe | 25.834.518 | 6.765 | 2,5 | 232.956 | 54.388 | 538,6 |

### 6.3 Ritmo e ingresos del combatiente

| Zona | Build | s por enemigo Común | Enemigos/hora | XP/hora | XP/hora objetivo (B2) | Monedas/hora | Monedas/hora del minero equivalente (B3) | Combatiente / minero |
|---|---|---|---|---|---|---|---|---|
| 1 | Equilibrada (12,5 %) | 6,4 | 238 | 53.325 | 52.200 | 4.877 | 4.782 | 1,02 |
| 1 | Combate (35 % en Fuerza) | 5,9 | 252 | 56.427 | 52.200 | 5.160 | 5.181 | 1,00 |
| 2 | Equilibrada (12,5 %) | 6,4 | 238 | 154.985 | 151.800 | 8.042 | 7.890 | 1,02 |
| 2 | Combate (35 % en Fuerza) | 5,3 | 270 | 175.742 | 151.800 | 9.119 | 8.884 | 1,03 |
| 3 | Equilibrada (12,5 %) | 6,5 | 237 | 265.338 | 261.000 | 13.213 | 12.418 | 1,06 |
| 3 | Combate (35 % en Fuerza) | 5,0 | 279 | 312.704 | 261.000 | 15.572 | 15.586 | 1,00 |
| 4 | Equilibrada (12,5 %) | 6,5 | 235 | 383.472 | 379.800 | 21.652 | 20.419 | 1,06 |
| 4 | Combate (35 % en Fuerza) | 4,9 | 284 | 462.426 | 379.800 | 26.110 | 25.565 | 1,02 |
| 5 | Equilibrada (12,5 %) | 6,6 | 233 | 508.668 | 508.200 | 35.417 | 33.692 | 1,05 |
| 5 | Combate (35 % en Fuerza) | 4,8 | 285 | 622.118 | 508.200 | 43.316 | 42.511 | 1,02 |
| 6 | Equilibrada (12,5 %) | 6,7 | 231 | 640.338 | 646.200 | 57.854 | 55.523 | 1,04 |
| 6 | Combate (35 % en Fuerza) | 4,8 | 285 | 790.011 | 646.200 | 71.377 | 69.600 | 1,03 |
| 7 | Equilibrada (12,5 %) | 6,8 | 228 | 777.988 | 793.800 | 94.414 | 91.613 | 1,03 |
| 7 | Combate (35 % en Fuerza) | 4,9 | 283 | 964.884 | 793.800 | 117.096 | 115.569 | 1,01 |
| 8 | Equilibrada (12,5 %) | 6,9 | 226 | 921.193 | 951.000 | 153.968 | 150.461 | 1,02 |
| 8 | Combate (35 % en Fuerza) | 4,9 | 281 | 1.145.842 | 951.000 | 191.516 | 180.726 | 1,06 |
| 9 | Equilibrada (12,5 %) | 7,1 | 223 | 1.069.581 | 1.117.800 | 250.954 | 242.713 | 1,03 |
| 9 | Combate (35 % en Fuerza) | 5,0 | 278 | 1.332.195 | 1.117.800 | 312.570 | 297.570 | 1,05 |
| 10 | Equilibrada (12,5 %) | 7,2 | 220 | 1.222.823 | 1.294.200 | 408.875 | 399.993 | 1,02 |
| 10 | Combate (35 % en Fuerza) | 5,1 | 274 | 1.523.393 | 1.294.200 | 509.376 | 476.187 | 1,07 |

- **XP:** el combatiente equilibrado queda entre −6% y +2% del objetivo de B2.
- **Monedas:** el combatiente gana entre 1,00 y 1,07 veces lo que el minero equivalente (equilibrado contra equilibrado, especialista contra especialista). El límite era 1,3.
- La Etapa 6 añade a ambos estilos los materiales, las cajas y los gastos.

---

## 7. Jefes

### 7.1 Reglas comunes

- **Tres fases** por vida: 100–60%, 60–30% y 30–0%. Al cambiar de fase el jefe es invulnerable 2 s y cambia de patrón.
- **Ataques telegrafiados:** todo ataque marca su zona en el suelo antes de golpear.

| Ataque | Aviso | Daño (% de la vida base del jugador de la zona) | Cómo se evita |
|---|---|---|---|
| Golpe normal | 0,6 s | 15% | Bloqueo o esquiva |
| Ataque fuerte | 1,2 s | 35% | Salir de la zona marcada o esquivar |
| Ataque letal | 2,5 s | 70% | Mecánica propia del jefe |

- **Ventana de vulnerabilidad:** tras cada ataque letal fallado o mecánica superada, el jefe queda expuesto 6 s y recibe +50% de daño.
- **Furia:** a los 12 minutos el jefe hace +10% de daño cada 30 s.
- **Los jefes son inmunes** a aturdimiento, Congelación y derribo; Lento les afecta a la mitad.

### 7.2 Escalado cooperativo de 1 a 8 jugadores

- **F25:** `VidaJefe(n) = VidaBase × (1 + 0,6 × (n − 1))` y `DañoJefe(n) = DañoBase × (1 + 0,05 × (n − 1))`.

| Jugadores | Vida del jefe | Daño del jefe | Vida por jugador | Capataz: minutos | Madre Liquen: minutos | Leviatán: minutos |
|---|---|---|---|---|---|---|
| 1 | ×1,0 | ×1,00 | 100 % | 8,0 | 8,0 | 8,1 |
| 2 | ×1,6 | ×1,05 | 80 % | 6,4 | 6,4 | 6,5 |
| 3 | ×2,2 | ×1,10 | 73 % | 5,9 | 5,9 | 5,9 |
| 4 | ×2,8 | ×1,15 | 70 % | 5,6 | 5,6 | 5,6 |
| 5 | ×3,4 | ×1,20 | 68 % | 5,4 | 5,4 | 5,5 |
| 6 | ×4,0 | ×1,25 | 67 % | 5,3 | 5,3 | 5,4 |
| 7 | ×4,6 | ×1,30 | 66 % | 5,3 | 5,3 | 5,3 |
| 8 | ×5,2 | ×1,35 | 65 % | 5,2 | 5,2 | 5,2 |

- En solitario el combate dura unos 8 minutos; con 8 jugadores, 5,2 minutos.
- Cada jugador adicional aporta más de lo que añade al jefe: ir en grupo siempre compensa, pero el jefe se puede hacer solo.
- El número de jugadores se fija al empezar el combate; quien entra después no cambia la vida del jefe ni recibe botín.

### 7.3 Los 3 jefes del MVP

| Jefe | Zona | Vida (1 jugador) | Vida (8 jugadores) | Vida base del jugador de la zona | Golpe normal (15 %) | Ataque fuerte (35 %) | Ataque letal avisado (70 %) | Monedas por jugador | XP por jugador |
|---|---|---|---|---|---|---|---|---|---|
| Capataz de Pizarra | 1 | 150.000 | 780.000 | 500 | 75 | 175 | 350 | 600 | 9.396 |
| Madre Liquen | 2 | 272.250 | 1.415.700 | 821 | 123 | 287 | 575 | 990 | 27.324 |
| Leviatán de Salmuera | 3 | 490.050 | 2.548.260 | 1.354 | 203 | 474 | 948 | 1.633 | 46.980 |

**Capataz de Pizarra (zona 1, Cantera del Alba).** Gólem minero con un pico enorme.

| Fase | Patrón | Ataque letal | Ventana de vulnerabilidad |
|---|---|---|---|
| 1 (100–60%) | Barridos de pico en arco de 180° (golpe normal) y pisotón en área (ataque fuerte) | — | Tras 3 barridos se le atasca el pico 4 s |
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
| 2 (60–30%) | Se sumerge y emerge bajo un jugador marcado; deja pilares de sal | «Marea Seca»: embestida en línea que atraviesa la sala; se evita poniéndose tras un pilar | Si choca contra un pilar queda aturdido 6 s |
| 3 (30–0%) | Dos zonas de emersión a la vez; los pilares duran la mitad | «Marea Seca» dos veces seguidas | 6 s tras cada choque |

### 7.4 Recompensas

| Recompensa | Valor |
|---|---|
| Monedas | `60 × valor de zona` por jugador (tabla 7.3). Corregido en la Etapa 6: antes `250 ×` |
| XP | 60 veces la de un enemigo Común, por jugador |
| Material de jefe | 3 garantizados por derrota; no depende de la Suerte |
| Tirada extra | 1 tirada en la tabla de depósitos de la zona (admite Suerte, B1) |
| Requisito | Haber hecho al menos el 5% del daño o de la curación del grupo |
| Límite diario | 3 derrotas con botín completo por jefe y día; después, 25% de monedas y XP y sin material |
| Botín | Individual: cada jugador recibe el suyo y no se reparte |

---

## 8. Reglas PvP

### 8.1 Reglas comunes (arenas y Zonas Fracturadas)

| Regla | Valor |
|---|---|
| Multiplicador de daño entre jugadores | ×0,06 (Etapa 7; antes ×0,07) |
| Defensa | `K = 4.500`, tope 50% (Etapa 7; antes 3.000 y 60%) |
| Vitalidad | `M = 1,0` en lugar de 3 (Etapa 7; antes 1,5) |
| Tope por golpe | Ningún golpe quita más del 35% de la vida máxima del objetivo |
| Tope de ráfaga (Etapa 7) | Un jugador no pierde más del 60% de su vida máxima en 2 s por daño de otros jugadores |
| Tope de mascotas | 25% del DPS del jugador **[CONFIRMADO]** |
| Curación | Reducida un 50% |
| Control | Duraciones según la tabla 2.1; rendimientos decrecientes y Rompecadenas (sección 5) |
| Despertar y Transformación | Bonos reducidos (secciones 4.2 y 4.3) |
| Consumibles de energía | 1 cada 30 s (B2) |

### 8.2 Duración de un duelo (nivel 1.000, arma Legendaria con +50%)

Segundos que tarda el atacante en derrotar al defensor.

| Atacante ↓ / Defensor → | Cristal (Fue/Vel/Ene) | Tanque (Vit/Def/Fue) | Equilibrada (375 × 8) | Minero (Min/Sue/Vit) |
|---|---|---|---|---|
| Cristal (Fue/Vel/Ene) | 8,4 s | 15,5 s | 11,7 s | 12,7 s |
| Tanque (Vit/Def/Fue) | 11,6 s | 21,3 s | 16,0 s | 17,5 s |
| Equilibrada (375 × 8) | 13,6 s | 25,0 s | 18,8 s | 20,4 s |
| Minero (Min/Sue/Vit) | 29,1 s | 53,3 s | 40,1 s | 43,6 s |

- Sin el multiplicador ×0,06, un duelo entre dos builds equilibradas duraría 1,1 s.
- Con él, los duelos entre builds de combate duran entre 8 y 25 s.
- La habilidad V de una build Cristal haría el 48% de la vida base de un golpe; el tope la deja en el 35%.
- El Tanque sigue ganando al Cristal, con una ventaja de 1,33 veces (era 1,69 antes de la corrección de la Etapa 7). El Cristal lo compensa con movilidad y más usos de habilidad.

### 8.3 Arenas

| Regla | Valor |
|---|---|
| Modos | 1 contra 1, 2 contra 2 y 3 contra 3 |
| Igualación | Por tramos de 100 niveles; dentro del tramo, todos pelean con el nivel máximo del tramo y la potencia de arma de esa zona |
| Emparejamiento | Puntuación Elo: inicio 1.000, factor 32; se busca rival a ±100 puntos y el margen crece 50 cada 15 s |
| Qué se arriesga | Solo puntuación |
| Formato | Al mejor de 3 rondas de 90 s |

### 8.4 Reglas específicas de las Zonas Fracturadas

| Regla | Valor |
|---|---|
| PvP | Siempre activo **[CONFIRMADO]** |
| Sincronización de nivel | Nivel efectivo máximo `100 × z` (B3); la potencia de arma y pico se limita a la de un Ultra raro de esa zona al máximo |
| Escuadrón | Hasta 3 jugadores; sin fuego amigo; comparten la exclusividad del Cofre de Saqueo |
| Debuff de carga | Fórmula F17 de B3 |
| Invisibilidad | Manto Nocturno no oculta en el minimapa a quien lleve el 75% de carga o más |
| Extracción | No se puede curar ni usar habilidades mientras se canaliza |
| Qué se arriesga | Solo el mineral transportado **[CONFIRMADO]** |
| Escudos de novato y de entrada, anti-acampada | Ver B3, secciones 7.6 y 7.7 |

---

## 9. Controles

| Acción | PC | Móvil | Consola (mando) |
|---|---|---|---|
| Moverse | W A S D | Joystick izquierdo | Stick izquierdo |
| Cámara | Ratón | Arrastrar en la mitad derecha | Stick derecho |
| Ataque básico / picar | Clic izquierdo | Botón grande derecho | RT |
| Bloqueo | Clic derecho (mantener) | Botón de escudo (mantener) | LT |
| Habilidad Z | Z | Botón 1 del arco | LB + X |
| Habilidad X | X | Botón 2 del arco | LB + Y |
| Habilidad C | C | Botón 3 del arco | LB + B |
| Habilidad V | V | Botón 4 del arco | LB + A |
| Salto y doble salto | Espacio | Botón de salto | A |
| Dash | Q | Botón de dash | RB |
| Esquiva | Ctrl izquierdo + dirección | Deslizar sobre el botón de dash | B |
| Parpadeo | E | Botón de parpadeo | Y |
| Transformación | G | Botón superior (aparece al llenarse la barra) | Pulsar los dos sticks |
| Interactuar | F | Botón contextual | X |
| Fijar objetivo | Tab | Tocar al enemigo | Pulsar stick derecho |
| Postura de mascotas | R | Botón de mascotas | Cruceta arriba |

- **Móvil:** apuntado asistido hacia el enemigo más cercano en un cono de 30°; botones de tamaño mínimo de 48 puntos; posición de los botones ajustable.
- **Consola:** con LB pulsado, los botones X, Y, B y A lanzan las habilidades; sin LB hacen su acción normal.
- En las tres plataformas se pueden reasignar los controles.

---

## 10. Problemas de balance detectados y alternativas

### P1 — El combatiente ganaba más que el minero

- **Problema:** con los primeros valores, el combatiente equilibrado ganaba 1,14 veces lo que el minero y un 16% más de XP que el objetivo.
- **Corrección aplicada:** monedas de enemigo ×0,9 (Común 1,35; Élite 5,4; Guardián 16) y factor de XP 0,72. Ahora la relación es 1,00–1,07.

### P2 — Sin multiplicador PvP los duelos duran 1,3 s

- **Problema:** las armas y habilidades están calibradas contra enemigos con 20 veces la potencia de zona en vida; un jugador solo tiene 5.
- **Corrección aplicada:** `MultModo` (0,07 al principio; 0,06 desde la Etapa 7) y tope del 35% por golpe.
- **Alternativa equivalente:** multiplicar la vida de los jugadores por 14 solo en PvP. Se descarta porque obliga a mostrar dos barras de vida distintas.

### P3 — El Tanque sigue por delante del Cristal en duelo

- **Dato inicial:** ventaja de 1,69 veces con la Vitalidad a la mitad.
- **Corregido en la Etapa 7:** Vitalidad con `M = 1,0` y Defensa con `K = 4.500` y tope 50% en PvP. La ventaja baja a 1,33 veces.

### P4 — El máximo teórico de daño es 36 veces el de un arma Común

- **Problema:** es el producto de siete topes a la vez; nadie debería alcanzarlos todos, pero los enemigos están calibrados para ×3–8.
- **Alternativa:** si la Etapa 7 muestra builds por encima de ×15 en la práctica, bajar el tope de estados de +40% a +25% y el de crítico de ×2,0 a ×1,75 (máximo teórico: 30,7 veces).

### P5 — Diferencia de daño entre Núcleos

- **Dato:** Escarcha hace un 19% menos de daño que Prismático.
- **Riesgo:** que en PvE todos usen Prismático o Brasa.
- **Alternativa:** si la telemetría muestra menos del 10% de uso en PvE, subir Escarcha y Sísmico un 8%.

### P6 — Un jugador recién llegado tarda 14 s por enemigo

- **Dato:** con arma Común sin mejoras y solo la habilidad Z.
- **Corrección aplicada:** enemigos de tutorial con la mitad de vida hasta el nivel 10.

### Cómo probar los valores provisionales

| Valor | Prueba |
|---|---|
| Coeficientes de arma | Prueba de juego con cada tipo contra el mismo enemigo; diferencia de tiempo menor del 10% |
| Vida y daño de enemigos | 6–7 s por enemigo Común y menos de 2 muertes por hora para un jugador típico |
| `MultModo = 0,06` | Arenas de prueba: duelos de 8–25 s |
| Escalado de jefes | Tiempo real de derrota con 1, 4 y 8 jugadores |
| Maestría | Telemetría: horas hasta maestría 50 y 100 |
| Anti-combo | Prueba dirigida: intentar mantener a un jugador controlado; no debe superar 2,0 s |
