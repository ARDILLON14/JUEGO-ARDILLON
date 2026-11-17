-- Formulas/Economia: F32 y F33, precios de cajas y de venta. Funciones puras.
-- Referencia: OREBOUND/B_Matematico/B6_Economia.md.

local Config = script.Parent.Parent.Config
local Economy = require(Config.Economy)
local Boxes = require(Config.Boxes)
local Pickaxes = require(Config.Pickaxes)
local Mineria = require(script.Parent.Mineria)

local Economia = {}

local function round(x)
	return math.floor(x + 0.5)
end

-- F32: ingreso de referencia de la zona, en monedas por hora.
function Economia.income(zone)
	local exact = Economy.ZoneIncome[zone]
	if exact then
		return exact * Economy.CurrencyScale
	end
	return Economy.IncomePerZoneValue * Mineria.zoneValue(zone)
end

-- F33: coste en monedas de fabricar un pico o un arma.
function Economia.gearCost(zone, rarity)
	local hours = Economy.GearCostHours[rarity]
	assert(hours, "rareza sin precio de fabricación")
	return round(hours * Economia.income(zone))
end

-- Coste de subir al nivel n de objeto (1..10).
function Economia.upgradeLevelCost(zone, rarity, level)
	return round(Economy.Upgrade.LevelCostFactor * level * Economy.GearCostHours[rarity] * Economia.income(zone))
end

function Economia.upgradeAllLevelsCost(zone, rarity)
	local n = Pickaxes.Upgrade.LevelMax
	return round(Economy.Upgrade.LevelCostFactor * n * (n + 1) / 2 * Economy.GearCostHours[rarity] * Economia.income(zone))
end

function Economia.slotCost(zone, rarity)
	return round(Economy.Upgrade.SlotCostFactor * Economy.GearCostHours[rarity] * Economia.income(zone))
end

function Economia.awakenCost(zone, rarity)
	return round(Economy.Upgrade.AwakenCostFactor * Economy.GearCostHours[rarity] * Economia.income(zone))
end

-- Venta de equipo al mercader: 10 % del coste base.
function Economia.gearSellPrice(zone, rarity)
	return round(Economy.Sell.GearFraction * Economy.GearCostHours[rarity] * Economia.income(zone))
end

-- Venta de minerales: valor por unidad x cantidad x multiplicador de fractura (F34).
function Economia.mineralSellPrice(zone, rarity, amount, fracturedMultiplier)
	return Mineria.unitValue(zone, rarity) * amount * (fracturedMultiplier or 1)
end

-- Precio de una caja que se paga con monedas, en la zona indicada.
function Economia.boxPrice(boxType, zone)
	local box = Boxes.Boxes[boxType]
	assert(box and box.PriceHours, "caja sin precio en monedas")
	return round(box.PriceHours * Economia.income(zone))
end

function Economia.consumablePrice(id, zone)
	local hours = Economy.Consumable[id]
	assert(hours, "consumible desconocido")
	return round(hours * Economia.income(zone))
end

function Economia.backpackUpgrade(tier)
	return Economy.Backpack[tier]
end

function Economia.backpackPrice(tier)
	local b = Economy.Backpack[tier]
	assert(b, "ampliación de mochila inexistente")
	return round(b.Hours * Economia.income(b.Zone))
end

return Economia
