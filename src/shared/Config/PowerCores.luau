-- Config/PowerCores: datos de Núcleos de Poder. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B4). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Starter = "Prismatic",
	SlotTypes = { Z = "Area", X = "Control", C = "Mobility", V = "Ultimate" },             -- GDD
	MasteryUnlocks = { [1] = "Z", [10] = "X", [25] = "C", [50] = "V", [100] = "Awaken" },
	SwapOutsideCityItem = "ReadjustSeal",                                                   -- GDD: cuesta un consumible
	Awaken = { MasteryRequired = 100, DamageBonusPvE = 0.15, DamageBonusPvP = 0.08, UnlocksTransform = true },   -- GDD
	Transform = { Duration = 20, Cooldown = 120, Gauge = "Resonance", BonusPvE = 0.25, BonusCapPvP = 0.10 },     -- GDD
	Cores = {
		Prismatic = { Rarity = "Epic", Element = "Light", Passive = "LightShards", PassiveEnergyOnCrit = 5,     -- GDD
			Abilities = {
				Z = { Id = "PrismaticLance",  Coef = 2.2, Energy = 20, Cooldown = 6,  Slow = 0.25, SlowSeconds = 1.5 },
				X = { Id = "RefractionField", Coef = 1.5, Energy = 25, Cooldown = 12, Radius = 14, RefractedSeconds = 6, RefractedBonus = 0.10 },
				C = { Id = "LightningStep",   Coef = 1.2, Energy = 25, Cooldown = 9,  Distance = 18, DistanceNoTarget = 10 },
				V = { Id = "TotalPrism",      Coef = 6.0, Energy = 40, Cooldown = 60, Seconds = 6, Slow = 0.20, Rays = 6 },
			},
			Transform = { Id = "PrismForm", LanceProjectiles = 3, PvPMoveSpeed = 0.10 } },
		Ember = { Rarity = "Rare", Element = "Fire",   -- propuesta (B4, 5.4); efectos por implementar en su fase
			Abilities = {
				Z = { Id = "VoraciousSpark", Coef = 2.0, Energy = 20, Cooldown = 6 },
				X = { Id = "EmberRing", Coef = 1.4, Energy = 25, Cooldown = 12 },
				C = { Id = "IgneousTrail", Coef = 1.3, Energy = 25, Cooldown = 9 },
				V = { Id = "LesserSun", Coef = 6.6, Energy = 40, Cooldown = 60 },
			} },
		Frost = { Rarity = "Rare", Element = "Ice",   -- propuesta (B4, 5.4); efectos por implementar en su fase
			Abilities = {
				Z = { Id = "GelidShard", Coef = 1.9, Energy = 20, Cooldown = 6 },
				X = { Id = "ShortBlizzard", Coef = 1.3, Energy = 25, Cooldown = 12 },
				C = { Id = "IceSkate", Coef = 1.0, Energy = 25, Cooldown = 9 },
				V = { Id = "AbsoluteZero", Coef = 5.4, Energy = 40, Cooldown = 60 },
			} },
		Storm = { Rarity = "Epic", Element = "Lightning",   -- propuesta (B4, 5.4); efectos por implementar en su fase
			Abilities = {
				Z = { Id = "VoltaicArc", Coef = 2.1, Energy = 20, Cooldown = 6 },
				X = { Id = "StaticCage", Coef = 1.4, Energy = 25, Cooldown = 12 },
				C = { Id = "SparkLeap", Coef = 1.3, Energy = 25, Cooldown = 9 },
				V = { Id = "ThunderJudgment", Coef = 6.0, Energy = 40, Cooldown = 60 },
			} },
		Seismic = { Rarity = "Legendary", Element = "Earth",   -- propuesta (B4, 5.4); efectos por implementar en su fase
			Abilities = {
				Z = { Id = "RockFist", Coef = 2.1, Energy = 20, Cooldown = 6 },
				X = { Id = "OpenFault", Coef = 1.4, Energy = 25, Cooldown = 12 },
				C = { Id = "StoneCharge", Coef = 1.0, Energy = 25, Cooldown = 9 },
				V = { Id = "Cataclysm", Coef = 5.6, Energy = 40, Cooldown = 60 },
			} },
		Umbral = { Rarity = "Legendary", Element = "Shadow",   -- propuesta (B4, 5.4); efectos por implementar en su fase
			Abilities = {
				Z = { Id = "VeiledSlash", Coef = 2.0, Energy = 20, Cooldown = 6 },
				X = { Id = "NightCloak", Coef = 1.2, Energy = 25, Cooldown = 12 },
				C = { Id = "ShadowStep", Coef = 1.3, Energy = 25, Cooldown = 9 },
				V = { Id = "Eclipse", Coef = 6.0, Energy = 40, Cooldown = 60 },
			} },
	},
}
