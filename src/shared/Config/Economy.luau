-- Config/Economy: datos de economía. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B6). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	CurrencyScale = 1000,           -- todo el dinero del juego x 1.000 respecto a B6 (P3c). Las horas de ingreso no cambian
	IncomePerZoneValue = 490,       -- aproximación: I(z) ~ 490 x V(z)
	ZoneIncome = { 5152.5, 10301.0, 20040.5, 39784.5, 79219.0, 157536.0, 305461.0, 606246.0, 1204210.5, 2393058.0 },   -- I(z) exacto, monedas por hora (B6)
	GearCostHours = { Common = 0.3, Uncommon = 0.6, Rare = 1.2, Epic = 2.5, Legendary = 5, Mythic = 10, UltraRare = 20 },
	Upgrade = { LevelCostFactor = 0.05, SlotCostFactor = 0.5, SlotGems = 6, AwakenCostFactor = 1.5, AwakenCatalysts = 4 },
	Sell = { GearFraction = 0.10, RecycleFraction = 0.30 },
	Backpack = { { Capacity = 120, Zone = 2, Hours = 0.5 }, { Capacity = 150, Zone = 3, Hours = 1 }, { Capacity = 180, Zone = 4, Hours = 2 },
	             { Capacity = 210, Zone = 5, Hours = 3 }, { Capacity = 240, Zone = 6, Hours = 5 }, { Capacity = 270, Zone = 8, Hours = 8 },
	             { Capacity = 300, Zone = 10, Hours = 12 } },   -- capacidades de B6 x 1,5 (P3c)
	Consumable = { HealthPotion = 0.01, EnergyTonic = 0.01, LuckElixir = 0.10, XPScroll = 0.15, ReadjustSeal = 0.05 },
	PetEvolveHours = { Unleashed = 2, UnleashedMax = 8 },
	CelestialForgeHours = 10, PrestigeSkinHours = 20,
	QuestCoinBonus = 0.10,
	Rebirth = { Max = 10, XPBonus = 0.05, StatPoints = 10 },
	UpgradeMaterials = {   -- minerales de la zona del objeto por cada mejora (B3: «nivel de objeto 1-5 / 6-10», ranuras, despertar) [PROVISIONAL]
		LevelLow = { Rarity = "Uncommon", Units = 5 },    -- niveles 1 a 5
		LevelHigh = { Rarity = "Rare", Units = 3 },       -- niveles 6 a 10
		Slot = { Rarity = "Epic", Units = 6 },            -- B6: 6 Gemas talladas por ranura
		Awaken = { Rarity = "Mythic", Units = 4 },        -- B6: 4 Catalizadores
	},
	InsuranceRecipe = { Uncommon = 8, Rare = 1 },        -- Seguro de carga (B6, 7.2): de la zona más profunda desbloqueada
	MaxItems = 120,                                      -- objetos en el inventario (C_Tecnico 6.1: tamaño del perfil)
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
