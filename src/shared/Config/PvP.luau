-- Config/PvP: datos de PvP. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B4 y B7). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	DamageMultiplier = 0.062,
	VitalityM = 1.0,
	HitCapFraction = 0.35,
	BurstCap = { Fraction = 0.60, WindowSeconds = 2 },
	HealingMultiplier = 0.5,
	EnergyConsumableSeconds = 30,
	LevelSync = { LevelsPerZone = 100, GearCapRarity = "UltraRare", GearCapBonus = 0.5 },
	Arena = { Modes = { "1v1", "2v2", "3v3" }, BestOf = 3, RoundSeconds = 90, BracketLevels = 100,
	          Elo = { Start = 1000, K = 32, SearchRange = 100, RangeGrowth = 50, GrowthSeconds = 15 } },
}
