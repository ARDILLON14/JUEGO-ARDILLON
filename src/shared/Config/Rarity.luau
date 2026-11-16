-- Config/Rarity: datos de rarezas, potencia y suerte. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B1). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Order = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "UltraRare", "Celestial" },
	Multiplier = { Common = 1.00, Uncommon = 1.25, Rare = 1.50, Epic = 1.90,
	               Legendary = 2.50, Mythic = 3.30, UltraRare = 4.50, Celestial = 5.20 },   -- GDD
	Color = { Common = "Gray", Uncommon = "Green", Rare = "Blue", Epic = "Purple", Legendary = "Gold",
	          Mythic = "Red", UltraRare = "RainbowCycle", Celestial = "PearlWhiteCyanCore" },   -- GDD
	Announce = { UltraRare = "Server", Celestial = "Global" },                                  -- GDD
	Power = { ZoneBase = 100, ZoneGrowth = 2.00, BonusCap = 0.50,
	          LevelBonusMax = 0.25, UpgradeBonusMax = 0.15, AbilityBonusMax = 0.10 },
	Luck = { FMax = 3, K = 1000,
	         Exponent = { Common = 0, Uncommon = 0.2, Rare = 0.4, Epic = 0.6,
	                      Legendary = 0.8, Mythic = 1.0, UltraRare = 1.0 } },
	Celestial = { FragmentsPerItem = 50, MinAnchorZone = 6, FractureDepositChance = 0.0025, RiftEventMultiplier = 4,
	              EventBossFragments = 2, EventBossWeeklyKills = 5, DirectDropChance = 0.005 },
}
