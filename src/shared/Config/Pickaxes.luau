-- Config/Pickaxes: datos de picos. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B3). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	HitsPerSecond = { Common = 1.00, Uncommon = 1.02, Rare = 1.04, Epic = 1.06, Legendary = 1.08,
	                  Mythic = 1.10, UltraRare = 1.12, Celestial = 1.15 },
	HitsPerSecondMax = 2.0,
	EquipMiningPerZone = { Common = 10, Uncommon = 10, Rare = 12, Epic = 15, Legendary = 20,
	                       Mythic = 25, UltraRare = 30, Celestial = 30 },
	PassiveSlots = {   -- GDD
		Common = { Minor = 1 }, Uncommon = { Minor = 1 }, Rare = { Minor = 1 },
		Epic = { Major = 1 }, Legendary = { Major = 1 },
		Mythic = { Major = 1, Minor = 1 }, UltraRare = { Major = 1, Minor = 1 }, Celestial = { Unique = 1 },
	},
	Passives = {
		Minor  = { "BladeEcho", "LightBallast", "SureStrike" },            -- Eco del filo, Lastre ligero (GDD), Golpe certero
		Major  = { "RunicSonar", "OpenVein", "SeismicWave", "ChainFracture" },   -- Sonar rúnico (GDD) y propuestas
		Unique = { "StellarEcho" },
	},
	PassiveValues = { BladeEcho = 0.10, LightBallast = 0.15, RunicSonarStuds = 30 },   -- GDD
	CombatStat = {   -- GDD: defensa o velocidad de ataque; tope en PvP
		Epic = { PvE = 0.03, PvP = 0.02 }, Legendary = { PvE = 0.03, PvP = 0.02 },
		Mythic = { PvE = 0.05, PvP = 0.03 }, UltraRare = { PvE = 0.05, PvP = 0.03 }, Celestial = { PvE = 0.06, PvP = 0.03 },
	},
	Upgrade = { LevelMax = 10, LevelBonus = 0.025, Slots = 3, SlotBonus = 0.05, AwakenBonus = 0.10 },
	ZonePrefix = { "Pizarra", "Verdín", "Sal", "Brasa", "Escarcha", "Eco", "Obsidiana", "Magma", "Vitral", "Astral" },
}
