-- Formulas/Mineria: F13 a F17, F34 a F36. Funciones puras.
-- Referencia: OREBOUND/B_Matematico/B3_Mineria.md y B6_Economia.md.

local Config = script.Parent.Parent.Config
local Mining = require(Config.Mining)
local Pickaxes = require(Config.Pickaxes)
local Fracture = require(Config.Fracture)
local Stats = require(Config.Stats)
local Economy = require(Config.Economy)
local Potencia = require(script.Parent.Potencia)
local Progresion = require(script.Parent.Progresion)

local Mineria = {}

-- F13 ------------------------------------------------------------------
function Mineria.zoneLevel(zone)
	return math.max(1, Mining.Zone.LevelPerZone * (zone - 1))
end

-- Nivel medio de la zona: el que se usa para calibrar la XP de depósitos y enemigos.
function Mineria.zoneMidLevel(zone)
	return Mining.Zone.LevelPerZone * (zone - 1) + Mining.Zone.LevelPerZone / 2
end

function Mineria.zoneMiningReq(zone)
	return Mining.Zone.MiningReqPerZone * (math.min(zone, Mining.Zone.ReqFreezeZone) - 1)
end

function Mineria.pickPowerReq(zone)
	return Mining.Zone.PickPowerReqFactor * Potencia.zonePower(zone)
end

function Mineria.hardness(zone)
	return math.min(Mining.Zone.HardnessMax, Mining.Zone.HardnessBase + Mining.Zone.HardnessPerZone * (zone - 1))
end

-- V(z) = 10 x 2,00^(z-1) x escala de dinero: la unidad de valor de la zona.
function Mineria.zoneValue(zone)
	return Mining.Deposit.ValueBase * Mining.Deposit.ValueGrowth ^ (zone - 1) * Economy.CurrencyScale
end

function Mineria.zoneHasUltraRare(zone)
	return table.find(Mining.ZonesWithUltraRare, zone) ~= nil
end

function Mineria.spawnWeights(zone)
	if Mineria.zoneHasUltraRare(zone) then
		return Mining.SpawnWeights.WithUltraRare
	end
	return Mining.SpawnWeights.WithoutUltraRare
end

-- F14 y F15 ------------------------------------------------------------
function Mineria.depositMiningReq(zone, rarity)
	return Mineria.zoneMiningReq(zone) * Mining.Deposit.MiningReqFactor[rarity]
end

function Mineria.depositHealth(zone, rarity)
	return Potencia.zonePower(zone) * Mining.Deposit.HealthFactor[rarity] * Mineria.hardness(zone)
end

function Mineria.depositValue(zone, rarity)
	return Mineria.zoneValue(zone) * Mining.Deposit.ValueFactor[rarity] * Mining.Blocks.OreValueScale
end

function Mineria.depositUnits(rarity)
	return Mining.Deposit.Units[rarity]
end

function Mineria.unitValue(zone, rarity)
	return Mineria.depositValue(zone, rarity) / Mining.Deposit.Units[rarity]
end

function Mineria.depositXP(zone, rarity)
	return Mining.Deposit.XPScale * Progresion.xpPerAction(Mineria.zoneMidLevel(zone)) * Mining.Deposit.XPFactor[rarity] * Mining.Blocks.OreXPScale
end

-- F16 ------------------------------------------------------------------
-- Golpes para agotar un depósito: nunca menos de MinHits.
function Mineria.hitsToDeplete(health, pickPower, miningStat)
	local perHit = pickPower * Progresion.curve(miningStat, Stats.M.Mining)
	return math.max(Mining.Deposit.MinHits, math.ceil(health / perHit))
end

-- Daño de un golpe de pico a un depósito. Respeta MinHits limitando el golpe a vida / MinHits.
function Mineria.hitDamage(maxHealth, pickPower, miningStat)
	local perHit = pickPower * Progresion.curve(miningStat, Stats.M.Mining)
	return math.min(perHit, maxHealth / Mining.Deposit.MinHits)
end

-- Minería por bloques: la piedra cae de un golpe con el pico de la zona y no tiene mínimo de golpes.
function Mineria.stoneHealth(zone)
	return Potencia.zonePower(zone) * Mineria.hardness(zone) * Mining.Blocks.StoneHealthFactor
end

function Mineria.stoneHitDamage(pickPower, miningStat)
	return pickPower * Progresion.curve(miningStat, Stats.M.Mining)
end

function Mineria.pickHitsPerSecond(rarity, extractSpeedBonus)
	local hps = Pickaxes.HitsPerSecond[rarity] * (1 + (extractSpeedBonus or 0))
	return math.min(hps, Pickaxes.HitsPerSecondMax)
end

function Mineria.extractionSeconds(health, pickPower, miningStat, hitsPerSecond)
	return Mineria.hitsToDeplete(health, pickPower, miningStat) / hitsPerSecond
end

-- Minería necesaria para equipar un pico de esa zona y rareza.
function Mineria.pickEquipMining(zone, rarity)
	return Pickaxes.EquipMiningPerZone[rarity] * (math.min(zone, Mining.Zone.ReqFreezeZone) - 1)
end

-- Depósitos activos según los mineros que hay en la zona.
function Mineria.activeDeposits(miners)
	local s = Mining.Spawn
	return math.min(s.ActiveMax, s.ActiveBase + s.ExtraPerMinerAbove * math.max(0, miners - s.MinerThreshold))
end

-- F17: carga y ralentización en Zona Fracturada ------------------------
function Mineria.load(carriedValue, zone)
	return carriedValue / (Fracture.Load.ZoneValueDivisor * Mineria.zoneValue(zone))
end

function Mineria.loadSlow(load)
	return math.min(Fracture.Load.SlowCap, Fracture.Load.SlowLogFactor * math.log(1 + math.max(load, 0)))
end

-- F34: multiplicador del mineral fracturado al extraer -----------------
-- streak = extracciones seguidas sin morir (0 la primera vez).
function Mineria.streakMultiplier(streak)
	local steps = Fracture.Streak.Steps
	return steps[math.clamp(math.floor(streak or 0) + 1, 1, #steps)]
end

function Mineria.fracturedMultiplier(streak, extracted)
	if not extracted then
		return 1
	end
	return Fracture.ValueMultiplier * Mineria.streakMultiplier(streak)
end

-- F35 y F36: reparto al morir en PvP -----------------------------------
-- Devuelve { Kept, Dropped, Lootable, Destroyed } como fracciones de la carga (suman 1 entre Kept y Dropped).
function Mineria.pvpDeathSplit(load, insured, noviceProtected)
	local d = Fracture.PvPDeath
	local drop = d.DropFraction
	if noviceProtected or load < d.ProtectedBelowLoad then
		drop = 0
	elseif insured then
		drop = drop * (1 - Fracture.Insurance.ProtectedFraction)
	end
	local lootable = drop * d.LootableFraction
	return { Kept = 1 - drop, Dropped = drop, Lootable = lootable, Destroyed = drop - lootable }
end

return Mineria
