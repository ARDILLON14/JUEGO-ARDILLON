-- Config/Weapons: datos de armas, enemigos y jefes. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B4). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Types = {
		Sword  = { HitsPerSecond = 1.60, Coef = 0.625, Range = 8,  MaxTargets = 2, CritBonus = 0 },
		Axe    = { HitsPerSecond = 0.90, Coef = 1.150, Range = 9,  MaxTargets = 3, CritBonus = 0, GuardDamage = 1.5 },
		Dagger = { HitsPerSecond = 2.60, Coef = 0.365, Range = 6,  MaxTargets = 1, CritBonus = 0.10, BackstabBonus = 0.25 },
		Spear  = { HitsPerSecond = 1.20, Coef = 0.810, Range = 14, MaxTargets = 3, CritBonus = 0 },
		Staff  = { HitsPerSecond = 1.00, Coef = 0.960, Range = 35, MaxTargets = 1, CritBonus = 0, EnergyDiscount = 0.10 },
		Bow    = { HitsPerSecond = 1.10, Coef = 0.727, Range = 70, MaxTargets = 1, CritBonus = 0 },
	},
	EnabledTypes = { "Sword", "Dagger", "Staff" },   -- MVP
	ComboHits = 4,                                   -- GDD
	SecondaryTargetDamage = 0.25,
	Techniques = {   -- 2 por arma; se equipan en Z, X, C o V junto a las del Núcleo (GDD)
		Sword = { { Id = "SpinningSlash", Coef = 1.5, Energy = 15, Cooldown = 5,  Mastery = 10 },
		          { Id = "Riposte",       Coef = 3.0, Energy = 30, Cooldown = 12, Mastery = 50 } },
		Axe = { { Id = "Cleave", Coef = 1.7, Energy = 15, Cooldown = 6, Mastery = 10 },
		         { Id = "MinorQuake", Coef = 3.2, Energy = 30, Cooldown = 14, Mastery = 50 } },
		Dagger = { { Id = "DoubleStab", Coef = 1.6, Energy = 15, Cooldown = 5, Mastery = 10 },
		         { Id = "FleetingShadow", Coef = 2.8, Energy = 30, Cooldown = 12, Mastery = 50 } },
		Spear = { { Id = "LongThrust", Coef = 1.6, Energy = 15, Cooldown = 5, Mastery = 10 },
		         { Id = "ShaftSweep", Coef = 3.0, Energy = 30, Cooldown = 12, Mastery = 50 } },
		Staff = { { Id = "ChargedOrb", Coef = 1.7, Energy = 15, Cooldown = 5, Mastery = 10 },
		         { Id = "ArcanePulse", Coef = 3.0, Energy = 30, Cooldown = 12, Mastery = 50 } },
		Bow = { { Id = "ChargedShot", Coef = 1.9, Energy = 15, Cooldown = 6, Mastery = 10 },
		         { Id = "ArrowRain", Coef = 3.2, Energy = 30, Cooldown = 14, Mastery = 50 } },
	},
	Crit = { Chance = 0.05, Multiplier = 1.5, ChanceCap = 0.30, MultiplierCap = 2.0 },
	Mastery = { XPBase = 10, XPLinear = 2, XPQuad = 0.04, MaxPowerLevel = 100, DamagePerLevel = 0.001,
	            Points = { Common = 1, Elite = 4, Guardian = 12, Boss = 80 } },
	StatusCap = 0.40,
	Combo = { FullHits = 4, Falloff = { 0.9, 0.8, 0.7, 0.6, 0.5 }, Min = 0.5 },
	Control = { Window = 6, SecondFactor = 0.5, TenacitySeconds = 5, StunCap = 2.5,        -- GDD; Tenacidad ampliada de 2 a 5 s
	            GuardBreakPvE = 2.0, GuardBreakPvP = 1.5, GuardBreakImmunity = 8 },
	Cancel = { DashCancelsBasicRecovery = true, DashCancelsAbilities = false },           -- GDD
	Enemies = {
		Common   = { Health = 16,   Damage = 0.03, Interval = 1.5, XP = 1,   Coins = 1.40,  Share = 0.88 },
		Elite    = { Health = 64,   Damage = 0.06, Interval = 1.8, XP = 3.5, Coins = 5.60,  Share = 0.10 },
		Guardian = { Health = 240,  Damage = 0.10, Interval = 2.2, XP = 10,  Coins = 16.80, Share = 0.02 },
		Boss     = { Health = 1200, Damage = 0.15, Interval = 2.5, XP = 60,  Coins = 60 },
		XPScale = 0.71, TutorialHealthFactor = 0.5, TutorialMaxLevel = 10,
		PackWeights = { [1] = 70, [2] = 25, [3] = 5 }, PackSpacing = 20,
	},
	Boss = { PhaseThresholds = { 0.60, 0.30 }, HealthPerExtraPlayer = 0.6, DamagePerExtraPlayer = 0.05, MaxPlayers = 8,
	         Telegraph = { Normal = 0.6, Heavy = 1.2, Lethal = 2.5 }, DamageFraction = { Normal = 0.15, Heavy = 0.35, Lethal = 0.70 },
	         VulnerableSeconds = 6, VulnerableBonus = 0.5, EnrageSeconds = 720, DailyFullLoot = 3, MaterialsPerKill = 3,
	         MinContribution = 0.05, CoreDropChance = 0.01 },
}
