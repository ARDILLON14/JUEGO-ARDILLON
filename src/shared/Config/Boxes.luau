-- Config/Boxes: datos de cajas. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/B_Matematico (B1 y B6). Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	StandardWeights = { Common = 50, Uncommon = 26, Rare = 14, Epic = 7, Legendary = 2.4, Mythic = 0.5, UltraRare = 0.1 },
	Pity = { RampStart = 40, GuaranteeA = 50, RampExponent = 2, GuaranteeAMin = "Legendary",
	         GuaranteeB = 100, GuaranteeBMin = "Mythic" },
	Boxes = {
		Weapon = { PriceHours = 1.0, Currency = "Coins",
		           TypeWeights = { Sword = 17, Axe = 17, Dagger = 17, Spear = 17, Staff = 16, Bow = 16 } },
		Zone   = { PriceHours = 0.6, Currency = "Coins",
		           CategoryWeights = { Pickaxe = 35, Minerals = 40, Materials = 15, Consumables = 10 },
		           LotHours = { Common = 0.15, Uncommon = 0.25, Rare = 0.4, Epic = 0.8, Legendary = 2, Mythic = 5, UltraRare = 12 } },
		Pet    = { PriceHours = 0.75, Currency = "Coins", PriceZone = "HighestUnlocked" },
		Core   = { PriceHours = 3.0, Currency = "Coins", PriceZone = "HighestUnlocked", DuplicateMasteryPoints = 200,   -- GDD: cajas de Núcleos
		           Weights = { Ember = 30, Frost = 30, Prismatic = 15, Storm = 15, Seismic = 5, Umbral = 5 } },
		Event  = { Currency = "EventTokens", LuckApplies = false, GuaranteeBMin = "UltraRare",
		           Weights = { Rare = 45, Epic = 33, Legendary = 15, Mythic = 5, UltraRare = 1.5, Celestial = 0.5 } },
	},
	ShowOddsBeforeOpen = true,       -- GDD
	Animation = { Seconds = 2.5, FastSeconds = 1.0, Skippable = true, MultiOpen = 10 },
	LogSize = 200,
}
