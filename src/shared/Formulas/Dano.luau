-- Formulas/Dano: F18 a F25. Funciones puras.
-- Referencia: OREBOUND/B_Matematico/B4_Combate.md.

local Config = script.Parent.Parent.Config
local Weapons = require(Config.Weapons)
local Stats = require(Config.Stats)
local PvP = require(Config.PvP)
local Potencia = require(script.Parent.Potencia)
local Progresion = require(script.Parent.Progresion)
local Defensa = require(script.Parent.Defensa)
local Mineria = require(script.Parent.Mineria)

local Dano = {}

-- F18: daño base de un golpe básico.
function Dano.hitDamage(weaponPower, weaponType)
	return weaponPower * Weapons.Types[weaponType].Coef
end

function Dano.baseDPS(weaponPower, weaponType)
	local t = Weapons.Types[weaponType]
	return weaponPower * t.Coef * t.HitsPerSecond
end

-- F20: XP para pasar del nivel n al n+1 de maestría, y multiplicador de daño.
function Dano.masteryXP(level)
	local m = Weapons.Mastery
	return math.ceil(m.XPBase + m.XPLinear * level + m.XPQuad * level * level)
end

function Dano.masteryMultiplier(level)
	local m = Weapons.Mastery
	return 1 + m.DamagePerLevel * math.clamp(level or 0, 0, m.MaxPowerLevel)
end

-- Probabilidad y multiplicador de crítico con sus topes.
function Dano.critChance(bonus)
	return math.min(Weapons.Crit.Chance + (bonus or 0), Weapons.Crit.ChanceCap)
end

function Dano.critMultiplier(bonus)
	return math.min(Weapons.Crit.Multiplier + (bonus or 0), Weapons.Crit.MultiplierCap)
end

-- Factor de la cadena de control (GDD): 1.º completo, 2.º al 50 %, después Tenacidad (0).
function Dano.controlFactor(applicationsInWindow)
	if applicationsInWindow <= 0 then
		return 1
	elseif applicationsInWindow == 1 then
		return Weapons.Control.SecondFactor
	end
	return 0
end

-- F19: daño final. p = {
--   WeaponPower, Coef (del golpe o de la habilidad), Strength, Mastery,
--   Crit = boolean, CritMultiplier = número opcional, Status = suma de bonos de estado,
--   TargetDefense = estadística Defensa del objetivo, Mode = "PvE" | "PvP", Extra = multiplicador opcional }
function Dano.final(p)
	local mode = p.Mode or "PvE"
	local dmg = p.WeaponPower * p.Coef
	dmg = dmg * Progresion.curve(p.Strength, Stats.M.Strength)
	dmg = dmg * Dano.masteryMultiplier(p.Mastery)
	if p.Crit then
		dmg = dmg * (p.CritMultiplier or Weapons.Crit.Multiplier)
	end
	dmg = dmg * (1 + math.min(p.Status or 0, Weapons.StatusCap))
	dmg = dmg * (1 - Defensa.reduction(p.TargetDefense, mode))
	dmg = dmg * (p.Extra or 1)
	if mode == "PvP" then
		dmg = dmg * PvP.DamageMultiplier
	end
	return dmg
end

-- Tope por golpe en PvP: 35 % de la vida máxima del objetivo.
function Dano.capPvPHit(damage, targetMaxHealth)
	return math.min(damage, PvP.HitCapFraction * targetMaxHealth)
end

-- Tope de ráfaga en PvP: lo que aún se puede recibir en la ventana de 2 s.
-- takenInWindow = daño ya recibido en la ventana. Devuelve el daño que se aplica.
function Dano.capPvPBurst(damage, takenInWindow, targetMaxHealth)
	local room = PvP.BurstCap.Fraction * targetMaxHealth - takenInWindow
	return math.clamp(damage, 0, math.max(room, 0))
end

-- F21 a F24: enemigos ---------------------------------------------------
-- kind: "Common" | "Elite" | "Guardian" | "Boss"
function Dano.enemyHealth(zone, kind)
	return Potencia.zonePower(zone) * Mineria.hardness(zone) * Weapons.Enemies[kind].Health
end

function Dano.enemyDamage(zone, kind)
	return Progresion.baseHealth(Mineria.zoneLevel(zone)) * Weapons.Enemies[kind].Damage
end

function Dano.enemyXP(zone, kind)
	return Weapons.Enemies.XPScale * Progresion.xpPerAction(Mineria.zoneMidLevel(zone)) * Weapons.Enemies[kind].XP
end

function Dano.enemyCoins(zone, kind)
	return Mineria.zoneValue(zone) * Weapons.Enemies[kind].Coins
end

-- F25: escalado del jefe con n jugadores (1..MaxPlayers).
function Dano.bossScale(players)
	local b = Weapons.Boss
	local n = math.clamp(players, 1, b.MaxPlayers)
	return { Health = 1 + b.HealthPerExtraPlayer * (n - 1), Damage = 1 + b.DamagePerExtraPlayer * (n - 1) }
end

return Dano
