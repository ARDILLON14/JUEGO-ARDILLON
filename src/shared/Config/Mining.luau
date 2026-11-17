-- Config/Mining: datos de minería. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B3). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Zone = { LevelPerZone = 100, MiningReqPerZone = 10, PickPowerReqFactor = 0.5,
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
		XPScale = 0.69, ValueBase = 10, ValueGrowth = 2.00, MinHits = 3, MaxReach = 10,
	},
	Spawn = { ActiveBase = 40, RespawnSeconds = 45, ExtraPerMinerAbove = 5, MinerThreshold = 8, ActiveMax = 80 },   -- B3 original (rocas sueltas); sin uso desde P3b
	Blocks = {   -- minería por bloques (DECISIONES P3b; calibrado con calculos/c3_mina_bloques.py)
		Size = 4,                      -- studs por bloque
		OreChance = 0.10,              -- probabilidad de que un bloque recién destapado sea mineral (1 de cada 10; P3c)
		OreValueScale = 0.65,          -- valor de cada mineral respecto a B3, para que las monedas/h no cambien (P3c)
		OreXPScale = 0.65,             -- XP de cada mineral respecto a B3, para que el ritmo de niveles no cambie (P3c)
		StoneHealthFactor = 1.0,       -- vida de la piedra = PotZona x dureza x 1: un golpe con el pico de la zona
		DefaultWidth = 24, DefaultLength = 24, DefaultDepth = 40,   -- tamaño de la cantera en bloques
		RegenSeconds = 240,            -- un hueco vuelve a ser piedra tras este tiempo
		RegenPlayerRadius = 12,        -- ... si no hay ningún jugador a menos de estos studs
		ReturnChannelSeconds = 3,      -- «Subir a la superficie»: segundos quieto antes de subir
	},
	Backpack = { Base = 90 },   -- 60 en B3; 90 desde P3c (más minerales por hora)
	Bank = { HoldSeconds = 3, Radius = 15 },             -- B3, sección 8: depositar lleva 3 s
	Merchant = { Radius = 15 },
	Hit = { TimingTolerance = 0.85, ReachTolerance = 2 },   -- margen por latencia en la validación del servidor
	Share = { MinFractionForUnit = 0.10 },               -- B3, 5.3: con el 10 % del daño, al menos 1 unidad
	MinerWindowSeconds = 60,                             -- un jugador cuenta como minero de la zona si picó en este tiempo
	PvEDeath = { LossFraction = 0.20, RecoverSeconds = 120, NoLossBelowLevel = 25 },
	Minerals = require(script.Parent.Catalogo.Minerales),   -- 66 minerales, generados de calculos/b3_minerales.csv
}
