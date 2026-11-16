-- Formulas/Potencia: F1 (potencia de objeto) y valor de zona. Funciones puras.
-- Referencia: OREBOUND/B_Matematico/B1_Rarezas.md.

local Rarity = require(script.Parent.Parent.Config.Rarity)

local Potencia = {}

-- PotZona(z) = 100 x 2,00^(z-1)
function Potencia.zonePower(zone)
	return Rarity.Power.ZoneBase * Rarity.Power.ZoneGrowth ^ (zone - 1)
end

-- Suma de bonos de un objeto (nivel, ranuras y despertar), limitada a +50 %.
-- upgrade = { Level = 0..10, Slots = 0..3, Awakened = boolean }
function Potencia.upgradeBonus(upgrade)
	if upgrade == nil then
		return 0
	end
	local p = Rarity.Power
	local level = math.clamp(upgrade.Level or 0, 0, 10) / 10 * p.LevelBonusMax
	local slots = math.clamp(upgrade.Slots or 0, 0, 3) / 3 * p.UpgradeBonusMax
	local awaken = 0
	if upgrade.Awakened then
		awaken = p.AbilityBonusMax
	end
	return math.min(level + slots + awaken, p.BonusCap)
end

-- F1: PotZona(z) x MultRareza x (1 + min(bonos, 0,50))
function Potencia.itemPower(zone, rarity, bonus)
	local mult = Rarity.Multiplier[rarity]
	assert(mult, "rareza desconocida")
	return Potencia.zonePower(zone) * mult * (1 + math.min(bonus or 0, Rarity.Power.BonusCap))
end

-- Potencia de un objeto guardado en el perfil ({ Zone, Rarity, Level, Slots, Awakened }).
function Potencia.ofItem(item)
	return Potencia.itemPower(item.Zone, item.Rarity, Potencia.upgradeBonus(item))
end

return Potencia
