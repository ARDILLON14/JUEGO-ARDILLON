-- Config/Fracture: datos de Zonas Fracturadas. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B3 y B6; el GDD pide un módulo así: «FractureConfig»). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	ValueMultiplier = 1.5, XPMultiplier = 1.25, BackpackMultiplier = 2,
	Streak = { Steps = { 1.0, 1.1, 1.2, 1.3, 1.4, 1.5 }, BountyAtStreak = 5 },                       -- GDD
	Load = { ZoneValueDivisor = 20, SlowLogFactor = 0.12, SlowCap = 0.40,                             -- GDD
	         MobilityEnergySurchargeAtLoad = 10, MobilityEnergySurcharge = 0.25,
	         ParticlesAtLoad = 5, ParticlesStuds = 60, MinimapAtLoad = 10, ZoneAnnounceAtLoad = 30 },
	PvPDeath = { DropFraction = 0.50, LootableFraction = 0.80, ProtectedBelowLoad = 1, SameVictimMinutes = 10 },   -- GDD salvo SameVictim
	PvEDeath = { DropFraction = 0.20 },
	Chest = { Seconds = 90, ExclusiveSeconds = 10, OpenSeconds = 3 },
	Extraction = { Positions = 3, RelocateMinutes = 10, WarningSeconds = 30, ChannelSeconds = 8, DamageResets = true,
	               SquadChannelSeconds = { [2] = 6, [3] = 5 }, SquadRadius = 10 },                    -- GDD salvo valores de escuadrón
	Exit = { ChannelSeconds = 3 },
	Entry = { ProtectionSeconds = 10, ProtectionOnRespawn = true, NoviceEntriesWithoutLoss = 5, ReentrySeconds = 30,
	          LevelSyncPerZone = 100 },                                                               -- GDD salvo reentrada y sincronización
	AntiCamp = { Radius = 25, Seconds = 60, RevealOnMinimap = true },
	Insurance = { Craftable = true, ProtectedFraction = 0.5, DailyLimit = 5,                          -- GDD
	              Recipe = { UncommonIngot = 8, RarePlate = 1 } },
	Contracts = { Daily = 3, DailyIncomeHours = 0.20, Types = { "ExtractRarity", "DefeatCarriers" },  -- GDD
	              CarrierMinLoad = 5, SwapPvPContractPerDay = 1, WeeklyExtractions = 5, WeeklyAncientGems = 2 },
	Bounty = { LootableFraction = 1.0 },
	Revenge = { MarkSeconds = 180 },                                                                  -- GDD
	CelestialRift = { EveryMinutes = 120, AnnounceMinutes = 5, DurationMinutes = 10, FragmentMultiplier = 4 },   -- GDD
	RiftBoss = { FightersRequired = 6, WindowMinutes = 5, BossMaterials = 2 },
	Season = { Weeks = 8, RankBy = "ExtractedValue" },                                                -- GDD
	Squad = { MaxSize = 3, FriendlyFire = false, SharedLoad = true },
	ContractTargets = { ExtractRarity = { Count = 3, MinRarity = "Rare" }, DefeatCarriers = { Count = 2 } },   -- propuesta (B6 7.3)
	KillCreditSeconds = 5,     -- una muerte cuenta como PvP si otro jugador le golpeó en los últimos 5 s [PROVISIONAL]
	ExtractRadius = 8,
	EnabledZones = { 3 },      -- roadmap fase 8: la grieta de la zona 3                                 -- GDD
}
