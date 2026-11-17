-- Config/Season: pase de temporada (A_GDD: 50 niveles; la vía de pago solo da cosméticos y Cristales; la gratuita da
-- los 60 Fragmentos de temporada del sexto espacio de mascota en 6,6 semanas). Solo datos.
-- XP del pase: 100 por misión diaria cobrada (3 al día = 300). 280 por nivel: nivel 50 en 46,7 días = 6,7 semanas.

local Season = {
	StartUnix = 1794787200,   -- lunes 16-11-2026 00:00 UTC; cada temporada dura Weeks semanas
	Weeks = 8,
	Levels = 50,
	XPPerLevel = 280,
	XP = { DailyQuest = 100 },
	PaidCrystals = 800,       -- la vía de pago con Cristales (o con el pase de Robux, Monetization.GamePasses.SeasonPass)
	Free = {},                -- [nivel] = { SeasonFragments = n } | { CoinHours = h }
	Paid = {},                -- [nivel] = { Crystals = n } | { Cosmetic = id }
}

local COSMETICOS_PAGO = { [10] = "TrailAurora", [25] = "AuraTemporada", [40] = "TrailEstelar", [50] = "AuraCorona" }

for nivel = 1, Season.Levels do
	if nivel % 5 == 0 then
		Season.Free[nivel] = { SeasonFragments = 6 }    -- 10 x 6 = 60 al nivel 50
	else
		Season.Free[nivel] = { CoinHours = 0.2 }
	end
	if COSMETICOS_PAGO[nivel] then
		Season.Paid[nivel] = { Cosmetic = COSMETICOS_PAGO[nivel] }
	else
		Season.Paid[nivel] = { Crystals = 15 }          -- 46 x 15 = 690 Cristales
	end
end

return Season
