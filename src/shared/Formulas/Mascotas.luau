-- Formulas/Mascotas: F26 a F31. Funciones puras.
-- Referencia: OREBOUND/B_Matematico/B5_Mascotas.md.

local Config = script.Parent.Parent.Config
local Pets = require(Config.Pets)
local Rarity = require(Config.Rarity)
local Stats = require(Config.Stats)
local Progresion = require(script.Parent.Progresion)
local Dano = require(script.Parent.Dano)

local Mascotas = {}

-- F26
function Mascotas.levelXP(level)
	local l = Pets.Level
	return math.ceil(l.XPBase + l.XPLinear * level + l.XPQuad * level * level)
end

function Mascotas.levelDamage(level)
	return 1 + Pets.Level.DamagePerLevel * (level - 1)
end

-- F29: multiplicador de velocidad de ataque por nivel y golpes por segundo finales (máximo 2,0).
function Mascotas.levelAttackSpeed(level)
	return 1 + Pets.Level.AttackSpeedPerLevel * (level - 1)
end

function Mascotas.hitsPerSecond(baseHitsPerSecond, level)
	return math.min(baseHitsPerSecond * Mascotas.levelAttackSpeed(level), 2.0)
end

-- F27: DPS de una mascota. pet = { Role, Rarity, Level, Phase }; stance = "Gather" | "Protect".
function Mascotas.dps(weaponPower, pet, petMastery, stance)
	return weaponPower
		* Pets.Role[pet.Role].b
		* Rarity.Multiplier[pet.Rarity]
		* Mascotas.levelDamage(pet.Level)
		* Pets.Phase[pet.Phase].Factor
		* Progresion.curve(petMastery, Stats.M.PetMastery)
		* Mascotas.levelAttackSpeed(pet.Level)
		* Pets.Stance[stance or "Protect"].Damage
end

-- F28: vida de una mascota a partir de la vida base de su dueño.
function Mascotas.health(ownerLevel, pet, petMastery)
	return Progresion.baseHealth(ownerLevel)
		* Pets.Role[pet.Role].h
		* Rarity.Multiplier[pet.Rarity]
		* (1 + Pets.Level.HealthPerLevel * (pet.Level - 1))
		* Pets.Phase[pet.Phase].Factor
		* Progresion.curve(petMastery, Stats.M.PetMastery)
end

-- F30: factor de utilidad respecto a la referencia del GDD (forma desatada de nivel 50 sin Dominio = 1).
function Mascotas.utilityFactor(pet, petMastery)
	local u = Pets.Phase[pet.Phase].Factor
		* (1 + Pets.Level.UtilityPerLevel * (pet.Level - 1))
		* Progresion.curve(petMastery, Stats.M.PetUtility)
	return u / Pets.Utility.RefFactor
end

function Mascotas.pickupRadius(stance, bonus)
	return Pets.PickupRadius * Pets.Stance[stance].Radius * (1 + math.min(bonus or 0, Pets.GatherCaps.PickupRadius))
end

-- F31: DPS de referencia del dueño y factor de escala del tope conjunto.
function Mascotas.dpsRef(weaponPower, strength, mastery)
	local c = Pets.DPSCap
	return weaponPower * Progresion.curve(strength, Stats.M.Strength) * c.RefCritFactor * Dano.masteryMultiplier(mastery) * c.RefAbilityFactor
end

-- mode: "PvE" | "PvP" (PvP incluye las Zonas Fracturadas). Devuelve un factor en (0, 1].
function Mascotas.capFactor(totalPetDPS, dpsRef, mode)
	if totalPetDPS <= 0 then
		return 1
	end
	return math.min(1, Pets.DPSCap[mode] * dpsRef / totalPetDPS)
end

-- Daño de mascotas que aún cabe en la ventana deslizante de 5 s.
function Mascotas.windowRoom(dpsRef, mode, dealtInWindow)
	local c = Pets.DPSCap
	return math.max(0, c[mode] * dpsRef * c.WindowSeconds - dealtInWindow)
end

return Mascotas
