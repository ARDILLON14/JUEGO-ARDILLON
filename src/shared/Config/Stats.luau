-- Config/Stats: datos de estadísticas y progresión. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B2). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Names = { "Strength", "Vitality", "Defense", "Speed", "Energy", "Mining", "Luck", "PetMastery" },
	XP = { A = 100, B = 20, C = 0.8, MaxLevel = 1000, TailBase = 820100, TailSlope = 900 },
	XPPerAction = { Base = 25, PerLevel = 3.75, PerLevelSq = 0.002 },
	Points = { Start = 3, PerLevel = 3, PerLevelAfterMax = 1, CapPerStat = 1000, CapTotal = 5000 },
	Curve = { K = 1000 },
	M = { Strength = 3, Vitality = 3, Mining = 3, Luck = 3, PetMastery = 3,
	      PetUtility = 1.5, AttackSpeed = 0.8, MoveSpeed = 0.5, EnergyRegen = 1 },
	BaseHealth = { Base = 500, Growth = 2.00, LevelsPerStep = 100 },
	WalkSpeed = { Base = 16, Max = 24 },
	Defense = { PvE = { K = 1500, Cap = 0.75 }, PvP = { K = 4500, Cap = 0.50 } },
	HealthRegen = { InCombatPvE = 0.005, OutOfCombat = 0.05, CombatTimeout = 5 },
	Energy = { Base = 100, Bonus = 300, RegenCombat = 8, RegenIdle = 20, RegenPause = 1.5, MaxCostReduction = 0.30,
	           Cost = { BlockPerSec = 8, BlockHit = 10, Dash = 20, Blink = 30, Break = 50 },
	           Cooldown = { Blink = 8, Break = 15 } },
	Dash = { Charges = 2, RechargeSeconds = 3, Distance = 12, PerfectDodgeWindow = 0.25, PerfectDodgeInvuln = 0.3 },   -- GDD
	Blink = { Distance = 12, UnlockSpeedStat = 50 },                                                                    -- GDD
	Break = { MinControlledSeconds = 0.8 },                                                                             -- GDD: Ruptura
	AbilityFactorRef = 1.39,
	Respec = { FreeBelowLevel = 50, CostIncomeHours = 1.5, OutOfCombatOnly = true },
	LevelUpRefill = true,   -- al subir de nivel se rellenan vida y energía [PROVISIONAL]
}
