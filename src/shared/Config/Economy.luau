-- Config/Economy: datos de economía. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B6). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	IncomePerZoneValue = 490,       -- aproximación: I(z) ~ 490 x V(z)
	ZoneIncome = { 5152.5, 10301.0, 20040.5, 39784.5, 79219.0, 157536.0, 305461.0, 606246.0, 1204210.5, 2393058.0 },   -- I(z) exacto, monedas por hora (B6)
	GearCostHours = { Common = 0.3, Uncommon = 0.6, Rare = 1.2, Epic = 2.5, Legendary = 5, Mythic = 10, UltraRare = 20 },
	Upgrade = { LevelCostFactor = 0.05, SlotCostFactor = 0.5, SlotGems = 6, AwakenCostFactor = 1.5, AwakenCatalysts = 4 },
	Sell = { GearFraction = 0.10, RecycleFraction = 0.30 },
	Backpack = { { Capacity = 80, Zone = 2, Hours = 0.5 }, { Capacity = 100, Zone = 3, Hours = 1 }, { Capacity = 120, Zone = 4, Hours = 2 },
	             { Capacity = 140, Zone = 5, Hours = 3 }, { Capacity = 160, Zone = 6, Hours = 5 }, { Capacity = 180, Zone = 8, Hours = 8 },
	             { Capacity = 200, Zone = 10, Hours = 12 } },
	Consumable = { HealthPotion = 0.01, EnergyTonic = 0.01, LuckElixir = 0.10, XPScroll = 0.15, ReadjustSeal = 0.05 },
	PetEvolveHours = { Unleashed = 2, UnleashedMax = 8 },
	CelestialForgeHours = 10, PrestigeSkinHours = 20,
	QuestCoinBonus = 0.10,
	Rebirth = { Max = 10, XPBonus = 0.05, StatPoints = 10 },
	Recipes = {   -- materiales de la zona, por rareza del mineral de origen (B6, sección 2.2)
		Common    = { Common = 30 },
		Uncommon  = { Common = 40, Uncommon = 20 },
		Rare      = { Uncommon = 30, Rare = 15 },
		Epic      = { Rare = 30, Epic = 10 },
		Legendary = { Epic = 20, Legendary = 8, Boss = 2 },
		Mythic    = { Legendary = 15, Mythic = 6, Boss = 4 },
		UltraRare = { Mythic = 10, UltraRare = 4, Boss = 6, AncientGem = 1 },
	},
}
