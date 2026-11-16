# OREBOUND — Documento C: Especificación técnica

Etapa 9 · 2026-11-16 · Cálculos de apoyo: `calculos/b9_tecnico.py`.

> **Alcance.** Este documento especifica cómo construir el juego; no lo implementa. Los
> fragmentos de Luau son tablas de configuración o ejemplos cortos de un patrón.
>
> **Aviso de fuentes.** No se ha dispuesto de la sección 20 del prompt maestro: la arquitectura
> y la lista de operaciones a validar son propuestas **[PROVISIONAL]**. Los valores de las
> tablas de configuración vienen de los archivos B y heredan su estado. Son **[CONFIRMADO]**:
> el servidor decide el premio de una caja antes de la animación, los topes de DPS de mascotas
> (40% y 25%) y que en las Zonas Fracturadas solo se arriesga el mineral.
>
> **Datos de la plataforma sin verificar.** Los límites de DataStore y de MemoryStore que se
> citan proceden de conocimiento general de Roblox, no de una consulta a la documentación
> (el dominio `create.roblox.com` no es accesible desde esta sesión). Hay que comprobarlos
> antes de implementar.

---

## 1. Estructura del proyecto con Rojo

### 1.1 Punto de partida

El repositorio ya es un proyecto de Rojo 7.7.1 (gestionado con Rokit) con tres carpetas: `src/shared`, `src/server` y `src/client`. El proyecto se llama `ECLIPSE` en `default.project.json`; conviene renombrarlo a `OREBOUND` al empezar la fase 1.

### 1.2 Un lugar por mundo

Cada mundo es un lugar de Roblox distinto dentro de la misma experiencia (A_GDD, sección 5). Todos comparten el mismo código; solo cambia el mapa.

| Lugar | Archivo de proyecto | Contenido del mapa |
|---|---|---|
| Puerto Veta (lugar inicial) | `default.project.json` | Ciudad, arenas |
| Mundo 1 | `mundo1.project.json` | Zonas 1–3 y sus Zonas Fracturadas |
| Mundo 2 | `mundo2.project.json` | Zonas 4–6 |
| Mundo 3 | `mundo3.project.json` | Zonas 7–8 |
| Mundo 4 | `mundo4.project.json` | Zonas 9–10 |

Los mapas se construyen en Studio y no se versionan con Rojo; el código sí.

### 1.3 Árbol de carpetas

```
src/
  shared/                      -> ReplicatedStorage.Shared
    Config/                    Tablas de datos (sección 2). Sin lógica.
      Stats.luau  Rarity.luau  Mining.luau  Pickaxes.luau  Weapons.luau
      PowerCores.luau  Pets.luau  Economy.luau  Boxes.luau  Fracture.luau
      Worlds.luau  PvP.luau
    Formulas/                  Funciones puras F1 a F36 (B7, sección 7)
      Potencia.luau  Suerte.luau  Progresion.luau  Defensa.luau
      Mineria.luau  Dano.luau  Mascotas.luau  Economia.luau
    Net/                       Definición de Remotes y sus esquemas
      Remotes.luau  Esquemas.luau
    Tipos.luau                 Tipos compartidos
  server/                      -> ServerScriptService.Server
    init.server.luau           Arranque: carga servicios en orden de dependencias
    Services/
      DataService.luau         ProgressionService.luau   StatsService.luau
      InventoryService.luau    EconomyService.luau       BankService.luau
      CraftingService.luau     RarityService.luau        BoxService.luau
      DepositService.luau      MiningService.luau        EnemyService.luau
      CombatService.luau       BossService.luau          PowerCoreService.luau
      PetService.luau          PetEvolutionService.luau  PetCombatService.luau
      FractureService.luau     PvPService.luau           ArenaService.luau
      QuestService.luau        SeasonService.luau        EventService.luau
      RebirthService.luau      WorldService.luau         ComplianceService.luau
      AntiCheatService.luau    AnalyticsService.luau
    Net/
      Validador.luau           Comprobación de tipos y rangos de cada Remote
      LimiteFrecuencia.luau    Cubo de fichas por jugador y Remote
  client/                      -> StarterPlayerScripts.Client
    init.client.luau
    Controllers/
      InputController.luau     CombatController.luau     MiningController.luau
      PetController.luau       FractureController.luau   BoxController.luau
      InventoryController.luau ShopController.luau       HUDController.luau
      VFXController.luau       AudioController.luau      SettingsController.luau
      TutorialController.luau
    UI/                        Pantallas y componentes
tests/                         -> ServerScriptService.Tests (solo en el lugar de pruebas)
  Config.spec.luau  Formulas.spec.luau  Cajas.spec.luau  Mascotas.spec.luau ...
  Vectores/                    Valores de referencia exportados de calculos/*.py
```

### 1.4 `default.project.json` propuesto

```json
{
  "name": "OREBOUND",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": { "Shared": { "$path": "src/shared" } },
    "ServerScriptService": { "Server": { "$path": "src/server" } },
    "StarterPlayer": {
      "StarterPlayerScripts": { "Client": { "$path": "src/client" } }
    },
    "Workspace": { "$properties": { "StreamingEnabled": true } }
  }
}
```

El lugar de pruebas usa `pruebas.project.json`, igual que el anterior más `"Tests": { "$path": "tests" }` bajo `ServerScriptService`.

---

## 2. Módulos de configuración

Reglas comunes:

- Un módulo por sistema, en `Shared/Config`. Solo datos: ninguna función.
- Están en `ReplicatedStorage` porque el cliente los necesita para mostrar cifras. **No son un secreto y no dan autoridad:** el servidor calcula siempre con su propia copia.
- Las claves van en inglés y coinciden con los nombres de módulo pedidos. Los identificadores de contenido son cadenas estables (`"Rare"`, `"Sword"`), nunca posiciones.
- Los catálogos largos (66 minerales, 450 armas) se generan a partir de los CSV de `calculos/`.

### 2.1 `Stats`  (B2)

```lua
return {
	XP = { A = 100, B = 20, C = 0.8, MaxLevel = 1000, TailBase = 820100, TailSlope = 900 },
	XPPerAction = { Base = 25, PerLevel = 3.75, PerLevelSq = 0.002 },
	Points = { Start = 3, PerLevel = 3, PerLevelAfterMax = 1, CapPerStat = 1000, CapTotal = 5000 },
	Curve = { K = 1000 },
	M = { Strength = 3, Vitality = 3, Mining = 3, Luck = 3, PetMastery = 3,
	      PetUtility = 1.5, AttackSpeed = 0.8, MoveSpeed = 0.5, EnergyRegen = 1 },
	BaseHealth = { Base = 500, Growth = 1.65, LevelsPerStep = 100 },
	WalkSpeed = { Base = 16, Max = 24 },
	Defense = { PvE = { K = 1500, Cap = 0.75 }, PvP = { K = 4500, Cap = 0.50 } },
	HealthRegen = { InCombatPvE = 0.005, OutOfCombat = 0.05, CombatTimeout = 5 },
	Energy = { Base = 100, Bonus = 300, RegenCombat = 8, RegenIdle = 20, RegenPause = 1.5,
	           MaxCostReduction = 0.30,
	           Cost = { Dodge = 20, BlockPerSec = 8, BlockHit = 10, Dash = 20, Blink = 30 },
	           Cooldown = { Dodge = 1.2, Dash = 2.5, Blink = 8 } },
	Respec = { FreeBelowLevel = 50, CostIncomeHours = 1.5 },
}
```

### 2.2 `Rarity`  (B1)

```lua
return {
	Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "UltraRare", "Celestial" },
	Multiplier = { Common = 1.00, Uncommon = 1.15, Rare = 1.32, Epic = 1.52,
	               Legendary = 1.75, Mythic = 1.98, UltraRare = 2.20, Celestial = 2.60 },
	Color = { Common = "#9AA0A6", Uncommon = "#4CAF50", Rare = "#2F80ED", Epic = "#9B51E0",
	          Legendary = "#F2B01E", Mythic = "#E5383B", UltraRare = "#19D3C5", Celestial = "#FFF4D6" },
	Power = { ZoneBase = 100, ZoneGrowth = 1.65, BonusCap = 1.00,
	          LevelBonusMax = 0.50, UpgradeBonusMax = 0.30, AbilityBonusMax = 0.20 },
	Luck = { FMax = 3, K = 1000,
	         Exponent = { Common = 0, Uncommon = 0.2, Rare = 0.4, Epic = 0.6,
	                      Legendary = 0.8, Mythic = 1.0, UltraRare = 1.0 } },
	Celestial = { FragmentsPerItem = 60, MinAnchorZone = 6, EventBossFragments = 2,
	              EventBossWeeklyKills = 5, DirectDropChance = 0.005,
	              FractureChance = { [6] = 0.10, [7] = 0.125, [8] = 0.15, [9] = 0.175, [10] = 0.20 },
	              FractureWeeklyCap = 10 },
}
```

### 2.3 `Mining`  (B3)

```lua
return {
	Zone = { LevelPerZone = 100, MiningReqPerZone = 10, PickPowerReqFactor = 0.6,
	         HardnessBase = 1, HardnessPerZone = 0.1, HardnessMax = 2.0, ReqFreezeZone = 10 },
	ZonesWithUltraRare = { 3, 5, 7, 8, 9, 10 },
	SpawnWeights = {   -- suman 100
		WithUltraRare    = { Common = 55, Uncommon = 25, Rare = 12, Epic = 5.5, Legendary = 2, Mythic = 0.45, UltraRare = 0.05 },
		WithoutUltraRare = { Common = 55, Uncommon = 25, Rare = 12, Epic = 5.5, Legendary = 2, Mythic = 0.50, UltraRare = 0 },
	},
	Deposit = {
		HealthFactor = { Common = 6, Uncommon = 9, Rare = 14, Epic = 22, Legendary = 35, Mythic = 55, UltraRare = 90 },
		ValueFactor  = { Common = 1, Uncommon = 1.8, Rare = 3.2, Epic = 6, Legendary = 12, Mythic = 25, UltraRare = 60 },
		XPFactor     = { Common = 1, Uncommon = 1.4, Rare = 2, Epic = 3, Legendary = 4.5, Mythic = 7, UltraRare = 11 },
		Units        = { Common = 4, Uncommon = 4, Rare = 3, Epic = 3, Legendary = 2, Mythic = 2, UltraRare = 1 },
		MiningReqFactor = { Common = 1, Uncommon = 1, Rare = 1.5, Epic = 2.5, Legendary = 3.5, Mythic = 5, UltraRare = 7 },
		XPScale = 0.73, ValueBase = 10, ValueGrowth = 1.65, MinHits = 3, MaxReach = 10,
	},
	Spawn = { ActiveBase = 40, RespawnSeconds = 45, ExtraPerMinerAbove = 5, MinerThreshold = 8, ActiveMax = 80 },
	Backpack = { Base = 60 },
	PvEDeath = { LossFraction = 0.20, RecoverSeconds = 120, NoLossBelowLevel = 25 },
	Minerals = {},  -- 66 entradas generadas de calculos/b3_minerales.csv: Id, Zone, Rarity, Name
}
```

### 2.4 `Pickaxes`  (B3)

```lua
return {
	HitsPerSecond = { Common = 1.00, Uncommon = 1.02, Rare = 1.04, Epic = 1.06, Legendary = 1.08,
	                  Mythic = 1.10, UltraRare = 1.12, Celestial = 1.15 },
	HitsPerSecondMax = 2.0,
	EquipMiningPerZone = { Common = 10, Uncommon = 10, Rare = 12, Epic = 15, Legendary = 20,
	                       Mythic = 25, UltraRare = 30, Celestial = 30 },
	Ability = { Uncommon = "SureStrike", Rare = "OpenVein", Epic = "SeismicWave", Legendary = "Prospector",
	            Mythic = "ChainFracture", UltraRare = "Resonance", Celestial = "StellarEcho" },
	Upgrade = { LevelMax = 10, LevelBonus = 0.05, Slots = 3, SlotBonus = 0.10, AwakenBonus = 0.20 },
	ZonePrefix = { "Pizarra", "Verdín", "Sal", "Brasa", "Escarcha", "Eco", "Obsidiana", "Magma", "Vitral", "Astral" },
}
```

### 2.5 `Weapons`  (B4)

```lua
return {
	Types = {
		Sword  = { HitsPerSecond = 1.60, Coef = 0.625, Range = 8,  MaxTargets = 2, CritBonus = 0 },
		Axe    = { HitsPerSecond = 0.90, Coef = 1.150, Range = 9,  MaxTargets = 3, CritBonus = 0, GuardDamage = 1.5 },
		Dagger = { HitsPerSecond = 2.60, Coef = 0.365, Range = 6,  MaxTargets = 1, CritBonus = 0.10, BackstabBonus = 0.25 },
		Spear  = { HitsPerSecond = 1.20, Coef = 0.810, Range = 14, MaxTargets = 3, CritBonus = 0 },
		Staff  = { HitsPerSecond = 1.00, Coef = 0.960, Range = 35, MaxTargets = 1, CritBonus = 0, EnergyDiscount = 0.10 },
		Bow    = { HitsPerSecond = 1.10, Coef = 0.727, Range = 70, MaxTargets = 1, CritBonus = 0 },
	},
	SecondaryTargetDamage = 0.25,
	Crit = { Chance = 0.05, Multiplier = 1.5, ChanceCap = 0.30, MultiplierCap = 2.0 },
	Mastery = { XPBase = 10, XPLinear = 2, XPQuad = 0.04, MaxPowerLevel = 100, DamagePerLevel = 0.001,
	            Points = { Common = 1, Elite = 4, Guardian = 12, Boss = 80 },
	            Unlocks = { [1] = "Z", [10] = "X", [25] = "C", [50] = "V", [75] = "Awaken", [100] = "Transform" } },
	StatusCap = 0.40,
	Combo = { FullHits = 4, Falloff = { 0.9, 0.8, 0.7, 0.6, 0.5 }, Min = 0.5 },
	Control = { Window = 10, Durations = { 1.0, 0.5, 0.25 }, Immunity = 6, StunCap = 2.0, StunWindow = 4,
	            ChainBreakInvuln = 0.6, GuardBreakPvE = 2.0, GuardBreakPvP = 1.5, GuardBreakImmunity = 8 },
	Cancel = { FromFraction = 0.6, EnergySurcharge = 0.5, MinInterval = 1.5 },
	Enemies = {
		Common   = { Health = 20,   Damage = 0.03, Interval = 1.5, XP = 1,   Coins = 1.35, Share = 0.88 },
		Elite    = { Health = 80,   Damage = 0.06, Interval = 1.8, XP = 3.5, Coins = 5.4,  Share = 0.10 },
		Guardian = { Health = 300,  Damage = 0.10, Interval = 2.2, XP = 10,  Coins = 16,   Share = 0.02 },
		Boss     = { Health = 1500, Damage = 0.15, Interval = 2.5, XP = 60,  Coins = 60 },
		XPScale = 0.72, TutorialHealthFactor = 0.5, TutorialMaxLevel = 10,
		PackWeights = { [1] = 70, [2] = 25, [3] = 5 }, PackSpacing = 20,
	},
	Boss = { PhaseThresholds = { 0.60, 0.30 }, HealthPerExtraPlayer = 0.6, DamagePerExtraPlayer = 0.05, MaxPlayers = 8,
	         Telegraph = { Normal = 0.6, Heavy = 1.2, Lethal = 2.5 }, DamageFraction = { Normal = 0.15, Heavy = 0.35, Lethal = 0.70 },
	         VulnerableSeconds = 6, VulnerableBonus = 0.5, EnrageSeconds = 720, DailyFullLoot = 3, MaterialsPerKill = 3,
	         MinContribution = 0.05 },
}
```

### 2.6 `PowerCores`  (B4)

```lua
return {
	Starter = "Prismatic",
	Awaken = { MasteryRequired = 75, DamageBonusPvE = 0.15, DamageBonusPvP = 0.08 },
	Transform = { MasteryRequired = 100, Cooldown = 120,
	              PvE = { Duration = 20, Damage = 0.20, CooldownReduction = 0.20 },
	              PvP = { Duration = 12, Damage = 0.10, CooldownReduction = 0.10 } },
	Cores = {
		Prismatic = { Element = "Light", Passive = "Refraction", Abilities = {
			Z = { Id = "FacetedBeam",    Coef = 1.80,  Energy = 15, Cooldown = 4 },
			X = { Id = "SpectralFan",    Coef = 3.20,  Energy = 25, Cooldown = 8 },
			C = { Id = "SentinelPrism",  Coef = 5.00,  Energy = 35, Cooldown = 14 },
			V = { Id = "FullSpectrum",   Coef = 10.00, Energy = 50, Cooldown = 30 } } },
		-- Ember, Frost, Storm, Seismic y Umbral: misma forma; valores en B4, sección 4.5
	},
}
```

### 2.7 `Pets`  (B5)

```lua
return {
	Level = { Max = 100, XPBase = 15, XPLinear = 3, XPQuad = 0.09,
	          DamagePerLevel = 0.015, AttackSpeedPerLevel = 0.002, UtilityPerLevel = 0.005, HealthPerLevel = 0.01 },
	XPSource = { Enemy = { Common = 2, Elite = 8, Guardian = 24, Boss = 160 },
	             Deposit = { Common = 2, Uncommon = 3, Rare = 4, Epic = 6, Legendary = 9, Mythic = 14, UltraRare = 22 },
	             NestFraction = 0.15, NestSlots = 2 },
	Phase = { Hatchling = { Factor = 1.00 }, Unleashed = { Factor = 1.25, Level = 50 }, UnleashedMax = { Factor = 1.50, Level = 100 } },
	Role = { Attacker = { b = 0.030, h = 0.40 }, Control = { b = 0.018, h = 0.50 }, Tank = { b = 0.015, h = 1.00 },
	         Support = { b = 0.010, h = 0.50 }, Gatherer = { b = 0.008, h = 0.40 } },
	Utility = { TankRedirect = 0.05, TankRedirectCap = 0.30, TankShield = 0.02, TankShieldInterval = 20,
	            SupportHeal = 0.0015, SupportHealCap = 0.01, SupportHealCapPvP = 0.005,
	            ControlReduction = 0.08, ControlCap = 0.25, GathererPick = 0.04, OtherPick = 0.01, PickCap = 0.20 },
	DPSCap = { PvE = 0.40, PvP = 0.25, WindowSeconds = 5, RefAbilityFactor = 1.75, RefCritFactor = 1.025,
	           MaxActivePvP = 3, CombatTimeout = 5 },
	Stance = { Attack = 1.0, Gather = 0, Protect = 0.6, SwitchCooldown = 3, SwitchCooldownPvP = 6,
	           PickupRadius = 12, ChestOpenSeconds = 4.5, ChestMaxDistance = 15 },
	Respawn = { PvE = 20, Fracture = 30 },
	Slots = { Start = 3, Unlock = { [4] = { Level = 300 }, [5] = { Level = 700 }, [6] = { SeasonFragments = 60, GamePass = true } } },
	Hatch = { Minutes = { Common = 10, Uncommon = 20, Rare = 40, Epic = 90, Legendary = 180, Mythic = 360, UltraRare = 720 } },
	Bond = { FromDuplicate = { Common = 1, Uncommon = 2, Rare = 4, Epic = 8, Legendary = 16, Mythic = 32, UltraRare = 64 } },
	Species = {},   -- 12 entradas: Id, Rarity, Element, Role, HitsPerSecond (B5, sección 4)
}
```

### 2.8 `Economy`  (B6)

```lua
return {
	IncomePerZoneValue = 480,       -- I(z) ~ 480 x V(z)
	GearCostHours = { Common = 0.3, Uncommon = 0.6, Rare = 1.2, Epic = 2.5, Legendary = 5, Mythic = 10, UltraRare = 20 },
	Upgrade = { LevelCostFactor = 0.05, SlotCostFactor = 0.5, SlotGems = 6, AwakenCostFactor = 1.5, AwakenCatalysts = 4 },
	Sell = { GearFraction = 0.10, RecycleFraction = 0.30 },
	Backpack = { { Capacity = 80, Zone = 2, Hours = 0.5 }, { Capacity = 100, Zone = 3, Hours = 1 }, { Capacity = 120, Zone = 4, Hours = 2 },
	             { Capacity = 140, Zone = 5, Hours = 3 }, { Capacity = 160, Zone = 6, Hours = 5 }, { Capacity = 180, Zone = 8, Hours = 8 },
	             { Capacity = 200, Zone = 10, Hours = 12 } },
	Consumable = { HealthPotion = 0.01, EnergyTonic = 0.01, LuckElixir = 0.10, XPScroll = 0.15, ExtractionBeacon = 0.05 },
	PetEvolveHours = { Unleashed = 2, UnleashedMax = 8 },
	CelestialForgeHours = 10, PrestigeSkinHours = 20,
	QuestCoinBonus = 0.10,
	Rebirth = { Max = 10, XPBonus = 0.05, StatPoints = 10 },
	Recipes = {},                    -- por rareza: B6, sección 2.2
}
```

### 2.9 `Boxes`  (B1 y B6)

```lua
return {
	StandardWeights = { Common = 50, Uncommon = 26, Rare = 14, Epic = 7, Legendary = 2.4, Mythic = 0.5, UltraRare = 0.1 },
	Pity = { RampStart = 40, GuaranteeA = 50, RampExponent = 2, GuaranteeAMin = "Legendary",
	         GuaranteeB = 100, GuaranteeBMin = "Mythic" },
	Boxes = {
		Weapon = { PriceHours = 1.0, Currency = "Coins",
		           TypeWeights = { Sword = 17, Axe = 17, Dagger = 17, Spear = 17, Staff = 16, Bow = 16 } },
		Zone   = { PriceHours = 0.6, Currency = "Coins",
		           CategoryWeights = { Pickaxe = 35, Minerals = 40, Materials = 15, Consumables = 10 },
		           LotHours = { Common = 0.15, Uncommon = 0.25, Rare = 0.4, Epic = 0.8, Legendary = 2, Mythic = 5, UltraRare = 12 } },
		Pet    = { PriceHours = 0.75, Currency = "Coins", PriceZone = "HighestUnlocked" },
		Event  = { Currency = "EventTokens", LuckApplies = false, GuaranteeBMin = "UltraRare",
		           Weights = { Rare = 45, Epic = 33, Legendary = 15, Mythic = 5, UltraRare = 1.5, Celestial = 0.5 } },
	},
	Animation = { Seconds = 2.5, FastSeconds = 1.0, Skippable = true, MultiOpen = 10 },
	LogSize = 200,
}
```

### 2.10 `Fracture`  (B3 y B6)

```lua
return {
	ValueMultiplier = 2.0, XPMultiplier = 1.25, BackpackMultiplier = 2,
	Streak = { PerStep = 0.02, MaxSteps = 5, MinLoadFraction = 0.5 },
	LoadDebuff = { SpeedLoss = 0.30, Exponent = 1.5, DashCostBonus = 0.5, RevealFraction = 0.75, BlinkDistanceLoaded = 12 },
	PvPDeath = { DropFraction = 0.50, LootableFraction = 0.70, NoDropBelowLoad = 0.10, SameVictimMinutes = 10 },
	PvEDeath = { DropFraction = 0.20 },
	Chest = { Seconds = 90, ExclusiveSeconds = 10, OpenSeconds = 3 },
	Extraction = { Points = 3, RotationSeconds = 120, WarningSeconds = 20, ChannelSeconds = 8 },
	Exit = { ChannelSeconds = 3 },
	Entry = { ShieldSeconds = 5, NoviceEntries = 3, NoviceShieldSeconds = 120, NoviceBreakLoad = 0.5, ReentrySeconds = 30 },
	AntiCamp = { Radius = 25, Seconds = 45, HealthLossPerSecond = 0.05, RaiderKills = 3, RaiderWindowMinutes = 5, RaiderMarkSeconds = 60 },
	Insurance = { PremiumZoneValues = 6, PayoutFraction = 0.5, DailyLimit = 5 },
	Contracts = { Daily = 3, DailyIncomeHours = 0.20, WeeklyExtractions = 5, WeeklyAncientGems = 2 },
	Squad = { MaxSize = 3, FriendlyFire = false },
}
```

### 2.11 `Worlds`  (A_GDD)

```lua
return {
	Hub = { Id = "PuertoVeta", PlaceId = 0 },      -- los PlaceId se rellenan al publicar
	Worlds = {
		{ Id = "SuperficieQuebrada",     PlaceId = 0, Zones = { 1, 2, 3 } },
		{ Id = "HondonadaDeLosExtremos", PlaceId = 0, Zones = { 4, 5, 6 } },
		{ Id = "AbismoNegro",            PlaceId = 0, Zones = { 7, 8 } },
		{ Id = "CorazonCeleste",         PlaceId = 0, Zones = { 9, 10 } },
	},
	Zones = {
		{ Id = 1, Name = "Cantera del Alba",  Boss = "CapatazDePizarra" },
		{ Id = 2, Name = "Galerías de Musgo", Boss = "MadreLiquen" },
		{ Id = 3, Name = "Vetas Salinas",     Boss = "LeviatanDeSalmuera" },
		-- 4 a 10: nombres en B3; jefes por diseñar
	},
	Events = { MinIntervalMinutes = 25, MaxIntervalMinutes = 40, OneAtATime = true },
	ServerSize = 20,
}
```

### 2.12 `PvP`  (B4 y B7)

```lua
return {
	DamageMultiplier = 0.06,
	VitalityM = 1.0,
	HitCapFraction = 0.35,
	BurstCap = { Fraction = 0.60, WindowSeconds = 2 },
	HealingMultiplier = 0.5,
	EnergyConsumableSeconds = 30,
	LevelSync = { LevelsPerZone = 100, GearCapRarity = "UltraRare", GearCapBonus = 1.0 },
	Arena = { Modes = { "1v1", "2v2", "3v3" }, BestOf = 3, RoundSeconds = 90, BracketLevels = 100,
	          Elo = { Start = 1000, K = 32, SearchRange = 100, RangeGrowth = 50, GrowthSeconds = 15 } },
}
```

---

## 3. Servicios del servidor

Todos son módulos con `Init()` y `Start()`. `init.server.luau` los carga en el orden de la tabla; un servicio solo puede depender de los que están por encima.

| Servicio | Responsabilidad | Depende de | Expone |
|---|---|---|---|
| DataService | Cargar, bloquear, migrar y guardar el perfil | — | `GetProfile`, `Save`, `Release`, `OnLoaded` |
| ComplianceService | Consultar `PolicyService` al entrar y guardar el resultado | — | `CanSeePaidRandom`, `CanTrade` |
| AnalyticsService | Registrar eventos de economía y balance | — | `Log` |
| AntiCheatService | Límite de frecuencia, validación de movimiento, puntuación de sospecha | — | `Check`, `Flag` |
| WorldService | Zona actual del jugador, teletransportes entre lugares | DataService | `GetZone`, `TeleportToWorld` |
| StatsService | Estadísticas efectivas y valores derivados (vida, energía, velocidad) | DataService | `GetStats`, `AllocatePoint`, `Respec` |
| ProgressionService | XP, niveles, desbloqueo de zonas | StatsService | `AddXP`, `GetLevel` |
| InventoryService | Objetos, minerales, materiales, mochila y equipo | DataService | `Add`, `Remove`, `Equip`, `GetLoad` |
| EconomyService | Monedas y Cristales: única puerta para sumar o restar | InventoryService, AnalyticsService | `AddCoins`, `SpendCoins`, `Sell`, `Buy` |
| BankService | Depositar y retirar mineral | InventoryService | `Deposit`, `Withdraw` |
| RarityService | Sorteos con pesos, Suerte y contadores de garantía | DataService | `Roll`, `RollWithPity` |
| CraftingService | Fabricar, mejorar, reciclar | InventoryService, EconomyService | `Craft`, `Upgrade`, `Recycle` |
| BoxService | Abrir cajas: decide el premio, registra y entrega | RarityService, EconomyService, ComplianceService | `Open` |
| DepositService | Crear y regenerar depósitos; escalado por mineros | WorldService, RarityService | `GetDeposit`, `Damage` |
| MiningService | Validar golpes de pico y repartir mineral y XP | DepositService, StatsService, InventoryService, ProgressionService | `Hit` |
| EnemyService | Crear enemigos, IA, grupos | WorldService | `GetEnemy`, `Damage` |
| CombatService | Fórmula de daño F19, estados, anti-combo, energía | StatsService, EnemyService | `BasicAttack`, `ApplyDamage` |
| PowerCoreService | Equipar Núcleos, habilidades, enfriamientos, maestría, Despertar y Transformación | CombatService, InventoryService | `Cast`, `Equip`, `Awaken`, `Transform` |
| BossService | Instancias de jefe, fases, escalado, botín diario | CombatService, EnemyService | `Start`, `GetState` |
| PetService | Equipar, posturas, XP de mascota, incubación y Nido | InventoryService | `Equip`, `SetStance`, `Hatch` |
| PetEvolutionService | Evolución de fase: requisitos, costes y Vínculos | PetService, EconomyService | `Evolve`, `ReleaseDuplicate` |
| PetCombatService | Daño y utilidad de mascotas; tope de DPS | PetService, CombatService | `Tick` |
| PvPService | Reglas PvP: multiplicador, topes de golpe y ráfaga, sincronización de nivel | CombatService | `IsPvPAllowed`, `ScaleDamage` |
| FractureService | Zonas Fracturadas: entrada, carga, saqueo, cofres, extracción, racha, seguro, anti-acampada | PvPService, InventoryService, EconomyService, WorldService | `Enter`, `Extract`, `Exit`, `OnPlayerKilled` |
| ArenaService | Colas, emparejamiento e igualación | PvPService | `Queue`, `Leave` |
| QuestService | Diarias, semanales y contratos de grieta | EconomyService | `Progress`, `Claim` |
| SeasonService | Pase de temporada y fragmentos | QuestService | `AddPassXP`, `Claim` |
| EventService | Eventos aleatorios y jefes de evento | DepositService, EnemyService | `StartEvent` |
| RebirthService | Renacimiento | StatsService, EconomyService | `Rebirth` |

Reglas de arquitectura:

- **Una sola puerta por recurso.** Solo EconomyService toca monedas y solo InventoryService toca objetos y minerales. Cualquier otro servicio pasa por ellos, lo que deja un único punto para validar y registrar.
- **Los servicios no confían entre sí en datos del cliente:** el validador de Remotes limpia la entrada antes de que llegue a ningún servicio.
- Las fórmulas viven en `Shared/Formulas` como funciones puras, usadas por servidor y cliente. El cliente las usa solo para mostrar previsiones.

---

## 4. Controladores del cliente

El cliente dibuja, reproduce y **pide**. Nunca decide un resultado.

| Controlador | Qué hace | Qué puede pedir al servidor |
|---|---|---|
| InputController | Traduce teclado, táctil y mando a acciones (B4, sección 9) | Nada directamente |
| CombatController | Animaciones y predicción visual de ataques, dash y esquiva | Atacar, lanzar habilidad, bloquear, dash, esquiva, parpadeo, transformarse |
| MiningController | Animación de pico y barra del depósito | Golpear un depósito |
| PetController | Posición visual de mascotas, postura | Equipar, cambiar postura, incubar, evolucionar, liberar |
| FractureController | Interfaz de carga, minimapa, Puntos de Extracción | Entrar, extraer, salir, abrir cofre, contratar seguro |
| BoxController | Animación de la Geoda con el resultado ya recibido | Abrir caja |
| InventoryController | Mochila, equipo, banco | Equipar, depositar, retirar, vender, reciclar |
| ShopController | Mercader, forja, tienda de cosméticos | Comprar, fabricar, mejorar |
| HUDController | Vida, energía, enfriamientos, misiones | Reclamar misión, asignar punto, reiniciar puntos |
| VFXController | Efectos según la calidad elegida y el presupuesto | Nada |
| AudioController | Sonido y música por zona | Nada |
| SettingsController | Calidad, controles, accesibilidad | Guardar ajustes |
| TutorialController | Guía de los primeros 10 niveles | Marcar paso completado |

**Predicción en el cliente.** Para que el juego responda en móvil, el cliente reproduce al instante la animación y el efecto del ataque, del golpe de pico y del dash. El número de daño, el mineral y la posición definitiva llegan del servidor; si el servidor rechaza la acción, el cliente la deshace sin recompensa.

---

## 5. Remotes

Todos están en `ReplicatedStorage.Shared.Net`. Los que devuelven un resultado inmediato son `RemoteFunction` (C→S con respuesta); los demás, `RemoteEvent`.

### 5.1 Validación común (se aplica a todos antes de la específica)

1. **Tipos y rangos:** cada parámetro se comprueba contra su esquema; cadenas con longitud máxima; números finitos; identificadores que existan en la configuración.
2. **Límite de frecuencia:** cubo de fichas por jugador y Remote.
3. **Estado del jugador:** perfil cargado, personaje vivo y no en mitad de un teletransporte.
4. **Propiedad:** todo identificador de objeto o mascota debe pertenecer a quien llama.
5. **Sin confianza:** el cliente nunca envía daño, cantidades ganadas, probabilidades, precios ni posiciones de destino libres.

Ejemplo del patrón (ilustrativo):

```lua
-- Net/Validador.luau: envuelve cada Remote con esquema, límite y estado
local function conectar(remote, esquema, limite, manejador)
	remote.OnServerEvent:Connect(function(jugador, ...)
		if not LimiteFrecuencia.consumir(jugador, remote.Name, limite) then return end
		local ok, args = Esquemas.validar(esquema, ...)
		if not ok then AntiCheatService.Flag(jugador, "esquema", remote.Name) return end
		if not DataService.GetProfile(jugador) then return end
		manejador(jugador, table.unpack(args))
	end)
end
```

### 5.2 Límites de frecuencia

Derivados de la velocidad máxima legítima de cada acción con un 25% de margen.

| Acción | Máximo legítimo | Límite | Ráfaga |
|---|---|---|---|
| Atacar (Daga con Velocidad máxima) | 4,55/s | 5,7/s | 12 |
| Picar | 2,00/s | 2,5/s | 5 |
| Lanzar habilidad | 1,39/s | 1,8/s | 4 |
| Bloqueo (pulsar y soltar) | 2,00/s | 2,5/s | 5 |
| Esquiva | 0,83/s | 1,1/s | 3 |
| Dash | 0,40/s | 0,5/s | 2 |
| Cambiar postura | 0,33/s | 0,5/s | 2 |
| Parpadeo | 0,12/s | 0,2/s | 2 |

Un jugador genera como mucho 11,6 acciones de combate por segundo; un servidor de 20, unas 233 por segundo.

### 5.3 Lista de Remotes del cliente al servidor

| Remote | Tipo | Parámetros | Validación específica en el servidor | Límite |
|---|---|---|---|---|
| `Combat.Attack` | Evento | `targetIds: {number}` (máx. 3), `comboIndex: number` | Arma equipada; objetivos vivos y dentro del alcance del arma + 20%; tiempo desde el último golpe ≥ intervalo del arma; PvP permitido si el objetivo es un jugador | 5,7/s |
| `Combat.Cast` | Evento | `slot: "Z"\|"X"\|"C"\|"V"`, `aim: Vector3` | Habilidad desbloqueada por maestría; enfriamiento cumplido; energía suficiente; `aim` normalizado y dentro del alcance | 1,8/s |
| `Combat.Block` | Evento | `active: boolean` | Energía > 0; no aturdido | 2,5/s |
| `Combat.Dodge` | Evento | `direction: Vector3` | Enfriamiento y energía; dirección unitaria; el servidor calcula el destino | 1,1/s |
| `Combat.Dash` | Evento | `direction: Vector3` | Enfriamiento y energía (con recargo por carga); destino calculado por el servidor | 0,5/s |
| `Combat.Blink` | Evento | `direction: Vector3` | Enfriamiento y energía; sin atravesar paredes (trazado de rayo en el servidor); distancia según carga | 0,2/s |
| `Combat.Transform` | Función | — | Núcleo Despertado, maestría 100, barra llena, enfriamiento | 1 cada 5 s |
| `Mining.Hit` | Evento | `depositId: number` | Depósito existente y a ≤ 10 studs; pico equipado; Minería ≥ requisito; tiempo desde el último golpe ≥ intervalo del pico | 2,5/s |
| `Stats.Allocate` | Función | `stat: string`, `amount: number` | Puntos libres suficientes; tope de 1.000 por estadística; entero positivo | 5/s |
| `Stats.Respec` | Función | `useTome: boolean` | Fuera de combate y de Zona Fracturada; monedas o Tomo suficientes | 1 cada 10 s |
| `Inventory.Equip` | Función | `itemId: string`, `slot: string` | Propiedad; nivel y Minería requeridos; fuera de combate | 2/s |
| `Bank.Deposit` | Función | `all: boolean` | A ≤ 15 studs de un banco; no en Zona Fracturada | 1/s |
| `Bank.Withdraw` | Función | `mineralId: string`, `amount: number` | Existencias; hueco en la mochila | 2/s |
| `Shop.Sell` | Función | `mineralId: string`, `amount: number` o `itemId: string` | A ≤ 15 studs de un mercader; existencias; el precio lo calcula el servidor | 3/s |
| `Shop.BuyConsumable` | Función | `id: string`, `amount: number` (1–99) | Monedas; precio según la zona del jugador | 3/s |
| `Shop.BuyBackpack` | Función | — | Zona desbloqueada; siguiente ampliación en orden; monedas | 1/s |
| `Crafting.Craft` | Función | `kind: "Pickaxe"\|"Weapon"`, `type: string?`, `zone: number`, `rarity: string` | En la forja; zona desbloqueada; materiales y monedas; Celestial no se fabrica por esta vía | 2/s |
| `Crafting.Upgrade` | Función | `itemId: string`, `upgrade: "Level"\|"Slot"\|"Awaken"` | Propiedad; siguiente paso válido; materiales y monedas | 3/s |
| `Crafting.Recycle` | Función | `itemId: string` | Propiedad; no equipado | 2/s |
| `Crafting.ForgeCelestial` | Función | `kind: string`, `type: string?` | 60 fragmentos; monedas; zona de anclaje ≥ 6 | 1 cada 5 s |
| `Box.Open` | Función | `boxType: string`, `count: 1\|10` | Monedas o fichas; hueco en inventario; `ComplianceService` si la caja fuese de pago | 2/s |
| `Pet.Equip` | Función | `petId: string`, `slot: number` | Propiedad; espacio desbloqueado; fuera de combate | 2/s |
| `Pet.SetStance` | Evento | `stance: "Attack"\|"Gather"\|"Protect"` | Enfriamiento de 3 s (6 s tras daño de jugador) | 0,5/s |
| `Pet.StartHatch` | Función | `eggId: string`, `incubator: number` | Propiedad; incubadora libre y desbloqueada | 1/s |
| `Pet.ClaimHatch` | Función | `incubator: number` | Tiempo de juego cumplido según el servidor | 1/s |
| `Pet.Evolve` | Función | `petId: string` | Nivel 50 o 100; Vínculos, materiales y monedas | 1/s |
| `Pet.Release` | Función | `petIds: {string}` (máx. 50) | Propiedad; no equipadas | 1/s |
| `Pet.SetNest` | Función | `petId: string`, `slot: number` | Propiedad; no equipada | 1/s |
| `Core.Equip` | Función | `coreId: string` | Núcleo en propiedad; fuera de combate | 1/s |
| `Core.Awaken` | Función | `coreId: string` | Maestría 75; misión completada; materiales | 1 cada 5 s |
| `Boss.Join` | Función | `zone: number` | Zona desbloqueada; a ≤ 20 studs de la puerta; instancia no iniciada o con hueco | 1/s |
| `Fracture.Enter` | Función | `zone: number`, `insurance: boolean` | Zona desbloqueada; espera de reentrada cumplida; seguro: monedas, límite diario y sin marca de saqueador | 1 cada 2 s |
| `Fracture.Extract` | Evento | `start: boolean` | A ≤ 8 studs del Punto de Extracción activo; el servidor cuenta los 8 s y los corta si hay daño | 1/s |
| `Fracture.Exit` | Evento | `start: boolean` | En la entrada; 3 s contados por el servidor, interrumpidos por daño | 1/s |
| `Fracture.OpenChest` | Evento | `chestId: number`, `byPet: boolean` | Cofre existente; distancia; exclusividad; el servidor cuenta el tiempo y reparte según hueco | 1/s |
| `Arena.Queue` | Función | `mode: string` | Fuera de combate y de Zona Fracturada; sin cola activa | 1 cada 2 s |
| `Arena.Leave` | Evento | — | — | 1/s |
| `Quest.Claim` | Función | `questId: string` | Misión completada según el servidor y no reclamada | 3/s |
| `Season.Claim` | Función | `level: number`, `track: "Free"\|"Paid"` | Nivel alcanzado; vía de pago en propiedad; no reclamado | 3/s |
| `Rebirth.Confirm` | Función | `token: string` | Nivel 1.000; fuera de combate; `token` emitido por el servidor en el paso previo (doble confirmación) | 1 cada 10 s |
| `World.Teleport` | Función | `worldId: string` | Mundo desbloqueado; guardado completado antes de teletransportar | 1 cada 5 s |
| `Settings.Save` | Evento | `settings: table` | Claves conocidas y valores dentro de rango; tamaño máximo 2 KB | 1 cada 5 s |
| `Tutorial.Step` | Evento | `step: number` | Paso siguiente al guardado | 2/s |

### 5.4 Remotes del servidor al cliente

| Remote | Contenido | Destinatario |
|---|---|---|
| `State.Profile` | Copia de solo lectura de los datos visibles del perfil; después, solo cambios | El propio jugador |
| `State.Stats` | Vida, energía, enfriamientos, estados | El propio jugador (vida y estados, también a cercanos) |
| `Combat.Hit` | Objetivo, daño final, crítico, estado aplicado | Jugadores a ≤ 150 studs |
| `Combat.Rejected` | Acción rechazada, para deshacer la predicción | El propio jugador |
| `Mining.DepositState` | Aparición, vida y agotamiento de depósitos | Jugadores de la zona |
| `Mining.Loot` | Unidades y XP recibidas | El propio jugador |
| `Box.Result` | Lista de premios ya entregados y contadores de garantía | El propio jugador |
| `Pet.State` | Postura, vida y reaparición de mascotas | Cercanos |
| `Boss.State` | Fase, vida, aviso de ataque con posición y tiempo | Participantes |
| `Fracture.State` | Punto activo y siguiente, carga propia, racha, marcas en el minimapa | Jugadores de la Zona Fracturada |
| `Fracture.Chest` | Aparición y desaparición de Cofres de Saqueo | Cercanos |
| `Event.State` | Evento activo y tiempo restante | Todo el servidor |
| `Notify` | Avisos de sistema | El propio jugador |

---

## 6. Datos persistentes

### 6.1 Esquema del perfil (versión 1)

Una clave por jugador en el DataStore `Perfiles`: `u_<UserId>`.

```lua
{
	Version = 1,
	Meta = { Created = 0, LastSave = 0, PlayTime = 0, Session = { JobId = "", PlaceId = 0, Time = 0 } },
	Progress = { Level = 1, XP = 0, Rebirths = 0, UnlockedZone = 1, TutorialStep = 0 },
	Stats = { Allocated = { Strength = 0, Vitality = 0, Defense = 0, Speed = 0, Energy = 0, Mining = 0, Luck = 0, PetMastery = 0 },
	          BonusPoints = 0 },
	Wallet = { Coins = 0, Crystals = 0, EventTokens = 0, SeasonFragments = 0, CelestialFragments = 0, Bonds = 0 },
	Items = { -- por identificador único
		["a1b2c3d4"] = { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Rare", Level = 0, Slots = 0, Awakened = false },
	},
	Equipped = { Weapon = "", Pickaxe = "", Core = "Prismatic", Pets = { "", "", "" } },
	Minerals = { Carried = {}, Fractured = {}, Banked = {} },     -- por Id de mineral
	Materials = { Boss = {}, AncientGems = 0 },
	Backpack = { Tier = 0 },
	Pets = { ["p1"] = { Species = "TopilloDePizarra", Level = 1, XP = 0, Phase = "Hatchling" } },
	PetSlots = 3, PetStorage = 30, Incubators = { { Egg = "", PlaySeconds = 0 } }, Nest = { "", "" },
	Cores = { Prismatic = { Mastery = 1, XP = 0, Awakened = false } },
	WeaponMastery = { Sword = { Level = 1, XP = 0 } },
	Boxes = {
		Pity = { Weapon = { A = 0, B = 0 }, Zone = { A = 0, B = 0 }, Pet = { A = 0, B = 0 }, Event = { A = 0, B = 0 } },
		Log = {},      -- últimas 200: { T, Box, Zone, Rarity, Item, A, B }
		Opened = { Weapon = 0, Zone = 0, Pet = 0, Event = 0 },
	},
	Fracture = { Entries = 0, Streak = 0, InsuranceToday = 0, LastDeath = 0, WeeklyFragments = 0, Victims = {} },
	Bosses = { Daily = {}, WeeklyFirst = {}, EventKills = 0 },
	Quests = { Daily = {}, Weekly = {}, Contracts = {}, DayKey = "", WeekKey = "" },
	Season = { Id = 0, PassXP = 0, Paid = false, Claimed = {} },
	Arena = { Elo = { ["1v1"] = 1000, ["2v2"] = 1000, ["3v3"] = 1000 } },
	Codex = "", Achievements = "",     -- mapas de bits codificados
	Cosmetics = { Owned = {}, Equipped = {} },
	Purchases = { Receipts = {} },      -- últimos 100 identificadores de recibo
	Settings = {},
	Flags = { Suspicion = 0 },
}
```

- **Tamaño estimado:** 51 KB en el peor caso (120 objetos, 200 mascotas, registro completo), el 1,25% del límite de 4 MB por clave.
- Los contadores `A` y `B` son los de la protección contra mala suerte de B1, uno por tipo de caja.

### 6.2 Versiones y migraciones

- `Version` es un entero. Al cargar, si es menor que la actual, se aplican en orden las funciones `Migraciones[n]` (de `n` a `n+1`) hasta alcanzarla.
- Cada migración es pura, no falla con datos incompletos y tiene su prueba con un perfil de ejemplo de la versión anterior.
- Tras migrar se rellenan los campos nuevos con los valores por defecto (reconciliación con la plantilla).
- **Nunca se borra un campo en la misma versión en que deja de usarse:** se marca obsoleto y se elimina dos versiones después.
- Si el perfil tiene una versión **mayor** que la del servidor (servidor antiguo), no se carga y se expulsa al jugador con un aviso: evita que un servidor viejo estropee datos nuevos.

### 6.3 Sesión bloqueada contra duplicación

Problema: si dos servidores cargan el mismo perfil a la vez (teletransporte entre mundos, reconexión rápida), el segundo puede guardar encima del primero y duplicar o perder objetos.

Patrón:

1. **Cargar con `UpdateAsync`.** Dentro de la función de actualización se lee `Meta.Session`.
   - Si está vacía o caducada (más de 30 minutos sin renovarse), se escribe la sesión propia (`JobId`, `PlaceId`, hora) y se carga.
   - Si pertenece a otro servidor activo, **no se carga**: se reintenta cada 5 s hasta 30 s y, si sigue bloqueada, se expulsa al jugador con un aviso.
2. **Renovar** la marca de sesión en cada autoguardado.
3. **Liberar** al salir: último guardado con `Meta.Session` vacía. También en `BindToClose`.
4. **Teletransporte entre lugares:** `World.Teleport` guarda y libera antes de teletransportar. Los datos de teletransporte del cliente no se usan para nada que importe.
5. **Solo escribe quien tiene el bloqueo:** todo guardado comprueba dentro de `UpdateAsync` que `Meta.Session.JobId` sigue siendo el propio; si no, se descarta y se expulsa al jugador.

Se puede usar una biblioteca de perfiles con bloqueo de sesión ya probada en lugar de implementarlo desde cero **[PROVISIONAL]**; el comportamiento exigido es el de esta lista.

### 6.4 Guardado seguro

| Regla | Valor |
|---|---|
| Autoguardado | Cada 300 s, repartido entre jugadores para no coincidir |
| Guardado inmediato | Tras compra con Robux, renacimiento, evolución de mascota, fabricación Legendaria o superior y extracción |
| Al salir y al cerrar el servidor | Guardado y liberación; `BindToClose` espera a todos los perfiles |
| Reintentos | 3 intentos con espera creciente (2, 4 y 8 s) |
| Si no se pudo cargar | El jugador no entra a jugar: nunca se crea un perfil vacío sobre un fallo de lectura |
| Copia de seguridad | Antes de cada migración, copia del perfil en el DataStore `PerfilesCopia` |
| Presupuesto | Unas 18 escrituras por minuto con 20 jugadores, el 7% del presupuesto estimado |

- **Compras con Robux:** `ProcessReceipt` entrega el producto, guarda el identificador del recibo en `Purchases.Receipts` y solo entonces confirma la compra. Si el recibo ya está, confirma sin volver a entregar.
- **Operaciones atómicas:** fabricar, abrir caja, evolucionar o vender modifican el perfil en memoria en un solo paso sin esperas intermedias; o se aplica todo o nada.

### 6.5 Registro de aperturas de cajas

Para cada apertura, el servidor hace en este orden y sin ceder el control:

1. Comprueba monedas y hueco.
2. Lee los contadores `A` y `B` de ese tipo de caja.
3. Sortea con `Random` del servidor (B1: garantía B, después A, después tabla con Suerte).
4. Actualiza contadores, cobra, crea el objeto y añade la entrada al registro (`T`, caja, zona, rareza, objeto, `A` y `B` resultantes).
5. Envía `Box.Result` al cliente, que entonces reproduce la animación.

- El registro guarda las últimas 200 aperturas en el perfil y cada apertura se envía además a analítica, para auditar las tasas reales frente a las publicadas (4,449% de Legendario o superior).
- La apertura de 10 es un bucle de 10 aperturas individuales con sus contadores; no hay tabla especial.

### 6.6 Datos que no van en el perfil

| Dato | Dónde | Motivo |
|---|---|---|
| Depósitos, enemigos, cofres, Puntos de Extracción | Memoria del servidor | Estado de sesión |
| Colas de arena | MemoryStore | Compartido entre servidores, de corta vida |
| Clasificaciones | OrderedDataStore | Consulta ordenada |
| Estado de temporada y eventos globales | Configuración en vivo | Cambia sin publicar |

---

## 7. Seguridad

### 7.1 Principios

1. El servidor es la única autoridad sobre daño, botín, monedas, probabilidades, enfriamientos, energía y posición en acciones de movimiento.
2. El cliente envía **intenciones** («golpeo este depósito»), nunca resultados.
3. Toda entrada se valida por tipo, rango, frecuencia, estado, distancia y propiedad (sección 5.1).
4. Un rechazo no avisa de por qué al cliente; se registra en el servidor.

### 7.2 Validación por operación

| Operación | Cómo se valida |
|---|---|
| Golpe de pico | Depósito existente; distancia ≤ 10 studs medida por el servidor; intervalo del pico; requisito de Minería; el daño lo calcula el servidor con F16 |
| Ataque básico | Alcance del arma + 20%; intervalo del arma según Velocidad; línea de visión para Bastón y Arco; máximo 3 objetivos; daño con F19 |
| Habilidad | Desbloqueo por maestría; enfriamiento y energía en el servidor; el área de efecto se resuelve en el servidor |
| Movimiento | Cada 0,5 s se compara el desplazamiento con el máximo posible: 50 studs en 0,5 s, 65 en 1 s y 94 en 2 s, contando dash y parpadeo. Tres excesos seguidos devuelven al jugador a la última posición válida |
| Dash, esquiva, parpadeo | El servidor calcula el destino con la dirección recibida; trazado de rayo para paredes |
| XP y nivel | Solo ProgressionService añade XP, y solo desde eventos del servidor (muerte de enemigo, depósito agotado) |
| Puntos de estadística | Suma de asignados ≤ puntos del nivel; tope por estadística |
| Monedas | Solo EconomyService; toda variación lleva motivo y queda registrada; alerta si un jugador gana más de 3 veces el ingreso de referencia de su zona en una hora |
| Compra, fabricación, mejora | Precio y receta leídos de la configuración del servidor; operación atómica |
| Venta | Precio calculado por el servidor; mineral fracturado no extraído se vende a ×1,0 |
| Cajas | Sección 6.5; el cliente no envía semilla ni resultado |
| Equipar | Propiedad, nivel y Minería requeridos |
| Banco | Distancia al banco; prohibido en Zona Fracturada |
| Botín de jefe | Contribución ≥ 5% calculada por el servidor; contador diario en el perfil |
| Misiones | El progreso lo cuenta el servidor a partir de sus propios eventos |
| Compras con Robux | `ProcessReceipt` idempotente (sección 6.4) |

### 7.3 Carga, saqueo y extracción

| Operación | Cómo se valida |
|---|---|
| Carga | La mochila vive en el servidor (`Minerals.Carried` y `Minerals.Fractured`). El debuff de velocidad lo fija el servidor en el `WalkSpeed` del personaje; la validación de movimiento usa ese valor |
| Mineral fracturado | Se guarda aparte del normal. Solo pasa a valer ×2,0 al completar una extracción |
| Entrada | Escudo de 5 s y escudo de novato aplicados por el servidor; espera de reentrada contada en el servidor |
| Muerte contra jugador | `FractureService.OnPlayerKilled` se dispara desde CombatService, nunca desde el cliente. Calcula el 50%, elige las unidades más valiosas, destruye el 30% de lo soltado y crea el cofre con el 70% |
| Autoría de la muerte | Cuenta quien hizo más daño en los últimos 10 s. Una caída o un enemigo no cuentan como muerte PvP |
| Misma víctima | Lista `Victims` con la hora; si se repite en menos de 10 minutos, no se suelta nada |
| Desconexión en combate | Si el jugador sale habiendo recibido daño de otro jugador en los últimos 10 s, se trata como muerte contra ese jugador |
| Cofre de Saqueo | Existe solo en el servidor. Exclusividad de 10 s para el autor y su escuadrón; apertura de 3 s (4,5 s por mascota) contada en el servidor; se entrega solo lo que cabe |
| Extracción | Distancia ≤ 8 studs al punto **activo** según el servidor; 8 s contados por el servidor; cualquier daño recibido la cancela; al completarse, el mineral va al banco y se guarda de inmediato |
| Racha | Se incrementa solo con carga ≥ 50% de la capacidad, medida por el servidor al extraer |
| Seguro | Se cobra al entrar; el pago se calcula al morir con el valor base de lo soltado; contador diario |
| Fragmentos Celestiales | Sorteo en el servidor al extraer; tope semanal en el perfil; van directos a la cuenta |
| Anti-acampada | El servidor mide el tiempo de cada jugador a menos de 25 studs del punto activo sin canalizar |
| Traspaso entre cuentas | No hace falta regla especial: rinde 1,20 frente a 2,00 (B7). Aun así, analítica marca parejas atacante–víctima repetidas |

### 7.4 Transformaciones y Despertar

| Operación | Cómo se valida |
|---|---|
| Despertar | Maestría ≥ 75, misión propia completada y materiales, todo leído del perfil; no existe como producto de pago |
| Barra de Sincronía | La llena el servidor con el daño que él mismo calcula; el cliente solo la muestra |
| Activar Transformación | Núcleo Despertado, maestría 100, barra llena y enfriamiento de 120 s en el servidor |
| Duración y bonos | Los aplica y retira el servidor (20 s en PvE, 12 s en PvP); al morir o cambiar de Núcleo se cancela |
| Cambio de Núcleo | Prohibido en combate; reinicia la barra |

### 7.5 Tope de DPS de mascotas

1. **Las mascotas no existen como actores con autoridad en el cliente.** El cliente solo dibuja su posición; todo su daño lo genera `PetCombatService` en el servidor.
2. `DPSref` se recalcula en el servidor cada vez que cambian estadísticas, arma, maestría o mascotas: `PotenciaArma × MultFuerza × 1,025 × MultMaestría × 1,75`.
3. `Factor = mín(1, Tope × DPSref / Σ DPS teórico)`, con `Tope` = 0,40 en PvE y 0,25 en PvP y Zonas Fracturadas.
4. Cada golpe de mascota se multiplica por `Factor` y después se recorta con la ventana deslizante de 5 s: lo acumulado nunca supera `Tope × DPSref × 5`.
5. Las mascotas solo atacan si el jugador ha dado o recibido un golpe en los últimos 5 s.
6. En PvP y Zonas Fracturadas solo se activan las 3 primeras mascotas equipadas.
7. Prueba automática: la simulación de B5 (24 casos) se repite en TestEZ contra el servicio real.

### 7.6 Reglas PvP en el servidor

- `PvPService.ScaleDamage` aplica, en este orden: sincronización de nivel, fórmula F19 con `MultModo = 0,06`, tope del 35% por golpe y tope de ráfaga (60% de la vida máxima en 2 s, con una ventana por víctima).
- El daño entre jugadores solo se procesa si ambos están en una arena en curso o en la misma Zona Fracturada y ninguno tiene escudo.

### 7.7 Detección y respuesta

| Señal | Respuesta |
|---|---|
| Remote por encima del límite | Se descarta en silencio; suma sospecha |
| Parámetro fuera de esquema | Se descarta; suma sospecha (un cliente legítimo nunca lo envía) |
| Movimiento imposible repetido | Vuelta a la posición válida; suma sospecha |
| Ingresos anómalos | Alerta en analítica para revisión manual |
| Sospecha por encima del umbral | Expulsión de la sesión y marca en el perfil; las sanciones definitivas son manuales |

---

## 8. Rendimiento

### 8.1 Presupuesto de VFX y partículas

| Límite | Valor |
|---|---|
| Por habilidad | 60 partículas, 3 emisores, 2 luces dinámicas, 2 s (6 s las zonas persistentes) |
| Por mascota | 10 partículas |
| En pantalla | 300 (baja), 800 (media), 2.000 (alta) |

`VFXController` lleva la cuenta de partículas activas. Antes de lanzar un efecto comprueba el presupuesto; si no cabe, usa la versión reducida o lo omite, por este orden de prioridad:

1. Avisos de ataque de enemigos y jefes: nunca se omiten ni se reducen.
2. Efectos propios.
3. Efectos del jefe.
4. Efectos de otros jugadores.
5. Efectos de mascotas ajenas.
6. Ambiente.

### 8.2 Niveles de calidad

| Ajuste | Baja | Media | Alta |
|---|---|---|---|
| Efectos propios | 60% | 100% | 100% |
| Efectos de otros jugadores | 10% | 40% | 100% |
| Efectos de mascotas ajenas | Ninguno | 30% | 100% |
| Efectos de jefe | 50% | 100% | 100% |
| Luces dinámicas de habilidades | No | 1 por efecto | 2 por efecto |
| Sombras | No | Solo personajes | Todas |
| Distancia de efectos | 60 studs | 100 studs | 150 studs |
| Peor caso (jefe con 8 jugadores) | 273 de 300 | 739 de 800 | 1.390 de 2.000 |

- La calidad inicial se elige por dispositivo (táctil → baja) y se ajusta sola: si la media baja de 25 fotogramas por segundo durante 10 s, baja un nivel; el jugador puede fijarla a mano.
- Los efectos se reutilizan desde un fondo de instancias; no se crean y destruyen en cada uso.

### 8.3 Streaming de la mina

- `StreamingEnabled` activo en todos los lugares.
- Cada zona es un modelo propio; la sala de jefe y la Zona Fracturada son modelos aparte, lejos de la zona PvE, para que no se carguen a la vez.
- Radio objetivo de carga: 256 studs en móvil y 512 en PC **[PROVISIONAL]**; se ajusta con pruebas en dispositivo.
- Los depósitos son piezas simples con un único modelo por rareza y zona; el brillo es un material emisivo, no una luz dinámica.
- La entrada, el banco y el mercader de cada zona se marcan como persistentes para que siempre estén disponibles.
- El cliente no debe asumir que un depósito o un enemigo existe localmente: espera a que aparezca antes de dibujar su interfaz.

### 8.4 Servidor y red

| Aspecto | Presupuesto |
|---|---|
| Jugadores por servidor | 20 |
| Remotes de combate entrantes | Hasta 233 por segundo en el peor caso |
| Replicación por zona | Enemigos 6,2 KB/s; mascotas 2,9 KB/s; depósitos 0,2 KB/s; barras de vida 0,5 KB/s |
| IA de enemigos | Solo activa si hay un jugador a ≤ 120 studs; resto dormida |
| Mascotas | Posición simulada en cada cliente a partir de la del dueño; el servidor solo replica postura, vida y objetivo |
| Depósitos | Se replican cambios de estado, no la vida golpe a golpe; la barra de vida solo a quienes están picando |
| Bucle de mascotas | Un único bucle de servidor a 10 Hz para todas, no un hilo por mascota |

---

## 9. Pruebas

### 9.1 Automáticas (TestEZ, en el lugar de pruebas)

Los scripts de Python de `calculos/` son la referencia. Cada uno exporta vectores de prueba (entradas y resultado esperado) a `tests/Vectores/`, y las pruebas comparan las funciones de Luau con ellos.

| Prueba | Qué comprueba | Referencia |
|---|---|---|
| Configuración | Toda tabla de pesos suma exactamente 100; todos los identificadores existen; ningún valor negativo | B1, B3, B6 |
| Potencia y rareza | F1 para las 10 zonas × 8 rarezas × bonos 0 y 1 | `b1_rarezas.py` |
| Suerte | F2 y F3 con Suerte 0, 10, 100, 500, 1.000 y 2.500 | `b1_rarezas.py` |
| Protección contra mala suerte | 100.000 aperturas: Legendario+ en 4,449% ± 0,2; ninguna racha de más de 50; garantía de 100 | `b1_rarezas.py` |
| XP y niveles | F6 para los 1.000 niveles contra el CSV | `b2_xp_niveles.csv` |
| Estadísticas y Defensa | F10 y F12 en 0, 1, 100, 1.000 y 5.000; nunca por encima del tope | `b2_progresion.py` |
| Energía | El dash encadenado vacía la barra; ningún caso con energía infinita | `b2_progresion.py` |
| Minería | Vida, valor y tiempo de extracción de los 66 minerales | `b3_minerales.csv` |
| Daño | F19 paso a paso con el ejemplo de B4; topes de crítico y estados | `b4_combate.py` |
| Anti-combo | Escalado de combo, rendimientos del control, máximo 2,0 s de aturdimiento | `b4_combate.py` |
| Tope de mascotas | Los 24 casos: ni la media ni ninguna ventana de 5 s superan el tope | `b5_mascotas.py` |
| PvP | Tope del 35% por golpe y del 60% en 2 s con el combo del Núcleo Umbrío | `b7_simulaciones.py` |
| Precios | Coste de fabricar y mejorar para 10 zonas × 7 rarezas | `b6_precios_equipo.csv` |
| Saqueo | Con carga 100: conserva 50, cofre 35, destruye 15; misma víctima; carga mínima | B3 |
| Migraciones | Cada migración con un perfil de la versión anterior; perfil de versión futura rechazado | — |
| Sesión bloqueada | Con DataStore simulado: dos servidores no cargan a la vez; guardado sin bloqueo descartado | — |
| Recibos | El mismo recibo dos veces entrega una sola vez | — |
| Validador de Remotes | Tipos incorrectos, valores fuera de rango, exceso de frecuencia, objetos ajenos | — |

- Las pruebas de fórmulas son puras y corren fuera de Studio con una herramienta de línea de comandos para Luau **[PROVISIONAL]**, de modo que se ejecuten en cada cambio.
- Las pruebas de servicios usan DataStore y reloj simulados.
- Criterio: ninguna fase del roadmap se da por cerrada con pruebas en rojo.

### 9.2 Pruebas con herramientas, sin jugadores

| Prueba | Herramienta | Criterio |
|---|---|---|
| Carga de servidor | Bots que envían Remotes al ritmo máximo | 20 jugadores a 233 eventos por segundo sin bajar de 30 pasos de simulación por segundo |
| Rendimiento en móvil | Dispositivo de gama baja real | 30 fotogramas por segundo en el peor caso de la sección 8.2 |
| Memoria del cliente | Consola de desarrollador en móvil | Por debajo del límite del dispositivo de referencia tras 60 minutos |
| Economía | Volver a ejecutar `b6_economia.py` con los precios finales | Ahorro mediano entre 3 y 6 horas de ingreso |

### 9.3 Pruebas con jugadores

Lo que ningún cálculo puede decir:

| Qué | Cómo se mide | Objetivo |
|---|---|---|
| Sensación del combate y del picado | Sesiones observadas | 6–7 s por enemigo y por depósito sin que parezca lento |
| Legibilidad de los avisos de jefe | Muertes por ataque letal en el primer intento | Menos del 50% en el primer jefe |
| Tutorial | Porcentaje que llega al nivel 10 | Más del 70% |
| Primera Zona Fracturada | Porcentaje que vuelve a entrar tras su primera muerte | Más del 50% |
| Probabilidad real de morir en Zona Fracturada | Telemetría por zona | Entre el 15% y el 35% por viaje |
| Tanque frente a Cristal y escuadrones | Tasa de victoria por build en arenas | Ninguna build por encima del 60% |
| Uso de Núcleos | Reparto de uso en PvE | Ningún Núcleo por debajo del 10% |
| Controles en móvil | Errores de pulsación y abandono en la primera sesión | Sin quejas recurrentes de botones |
| Precios | Horas reales hasta cada objetivo de equipo | Desviación menor del 25% respecto a B6 |
| Comprensión de las cajas | Preguntas a jugadores sobre probabilidades y garantías | La mayoría sabe explicar la garantía de 50 |
