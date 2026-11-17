-- Reglas/Estadisticas: reparto de puntos, reinicio y valores derivados (B2, F9 a F12 y energía).
-- Funciones puras sobre el perfil. El servidor las usa para decidir; el cliente, solo para mostrar.

local Shared = script.Parent.Parent
local Stats = require(Shared.Config.Stats)
local PvP = require(Shared.Config.PvP)
local Progresion = require(Shared.Formulas.Progresion)
local Defensa = require(Shared.Formulas.Defensa)
local Suerte = require(Shared.Formulas.Suerte)
local Economia = require(Shared.Formulas.Economia)

local Estadisticas = {}

Estadisticas.Lista = Stats.Names

local ES_ESTADISTICA = {}
for _, nombre in ipairs(Stats.Names) do
	ES_ESTADISTICA[nombre] = true
end

function Estadisticas.esEstadistica(nombre)
	return ES_ESTADISTICA[nombre] == true
end

-- Puntos ---------------------------------------------------------------

function Estadisticas.puntosTotales(perfil)
	return Progresion.statPoints(perfil.Progress.Level) + (perfil.Stats.BonusPoints or 0)
end

function Estadisticas.puntosAsignados(perfil)
	local total = 0
	for _, nombre in ipairs(Stats.Names) do
		total = total + (perfil.Stats.Allocated[nombre] or 0)
	end
	return total
end

function Estadisticas.puntosLibres(perfil)
	return math.max(0, Estadisticas.puntosTotales(perfil) - Estadisticas.puntosAsignados(perfil))
end

-- Lo máximo que se puede asignar ahora a una estadística.
function Estadisticas.maximoAsignable(perfil, nombre)
	local actual = perfil.Stats.Allocated[nombre] or 0
	return math.max(0, math.min(Estadisticas.puntosLibres(perfil), Stats.Points.CapPerStat - actual))
end

-- Asigna puntos. Devuelve true, o false y el motivo: "estadistica" | "cantidad" | "sin_puntos" | "tope".
function Estadisticas.asignar(perfil, nombre, cantidad)
	if not ES_ESTADISTICA[nombre] then
		return false, "estadistica"
	end
	if type(cantidad) ~= "number" or cantidad < 1 or cantidad ~= math.floor(cantidad) then
		return false, "cantidad"
	end
	if cantidad > Estadisticas.puntosLibres(perfil) then
		return false, "sin_puntos"
	end
	local actual = perfil.Stats.Allocated[nombre] or 0
	if actual + cantidad > Stats.Points.CapPerStat then
		return false, "tope"
	end
	perfil.Stats.Allocated[nombre] = actual + cantidad
	return true
end

-- Reinicio -------------------------------------------------------------

-- Coste en monedas del reinicio en la ciudad: gratis por debajo del nivel 50; después 1,5 horas de ingreso
-- de la zona más profunda desbloqueada.
function Estadisticas.costeReinicio(perfil)
	if perfil.Progress.Level < Stats.Respec.FreeBelowLevel then
		return 0
	end
	return math.floor(Stats.Respec.CostIncomeHours * Economia.income(perfil.Progress.UnlockedZone) + 0.5)
end

-- Devuelve todos los puntos (no hay reinicio parcial). No cobra: lo hace el servicio. Devuelve los puntos devueltos.
function Estadisticas.reiniciarPuntos(perfil)
	local devueltos = Estadisticas.puntosAsignados(perfil)
	for _, nombre in ipairs(Stats.Names) do
		perfil.Stats.Allocated[nombre] = 0
	end
	return devueltos
end

-- Valores --------------------------------------------------------------

-- Valor total de cada estadística: asignado + bonos (tabla { [estadística] = número }, opcional), máximo 5.000.
function Estadisticas.efectivas(perfil, bonos)
	local out = {}
	for _, nombre in ipairs(Stats.Names) do
		local valor = (perfil.Stats.Allocated[nombre] or 0) + ((bonos and bonos[nombre]) or 0)
		out[nombre] = Progresion.capStat(valor)
	end
	return out
end

-- Todo lo que se deriva de nivel y estadísticas. Lo usan StatsService (servidor) y el panel (cliente).
function Estadisticas.derivadas(perfil, bonos)
	local s = Estadisticas.efectivas(perfil, bonos)
	local nivel = perfil.Progress.Level
	local M = Stats.M
	return {
		Level = nivel,
		Effective = s,
		MaxHealth = Progresion.maxHealth(nivel, s.Vitality),
		MaxHealthPvP = Progresion.maxHealth(nivel, s.Vitality, PvP.VitalityM),
		MaxEnergy = Progresion.maxEnergy(s.Energy),
		EnergyRegenCombat = Progresion.energyRegen(s.Energy, true),
		EnergyRegenIdle = Progresion.energyRegen(s.Energy, false),
		WalkSpeed = Progresion.walkSpeed(s.Speed),
		AttackSpeed = Progresion.attackSpeedMultiplier(s.Speed),
		Damage = Progresion.curve(s.Strength, M.Strength),
		Mining = Progresion.curve(s.Mining, M.Mining),
		Luck = Suerte.factor(s.Luck),
		PetPower = Progresion.curve(s.PetMastery, M.PetMastery),
		PetUtility = Progresion.curve(s.PetMastery, M.PetUtility),
		DefensePvE = Defensa.reduction(s.Defense, "PvE"),
		DefensePvP = Defensa.reduction(s.Defense, "PvP"),
		BlinkUnlocked = s.Speed >= Stats.Blink.UnlockSpeedStat,
	}
end

return Estadisticas
