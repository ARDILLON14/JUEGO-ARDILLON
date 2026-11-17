-- Reglas/Jefe: fases, escalado, daño de ataques, furia y botín diario de los jefes (B4, sección 8). Puro.

local Shared = script.Parent.Parent
local Weapons = require(Shared.Config.Weapons)
local Bosses = require(Shared.Config.Bosses)
local Dano = require(Shared.Formulas.Dano)
local Progresion = require(Shared.Formulas.Progresion)
local Mineria = require(Shared.Formulas.Mineria)

local Jefe = {}

local B = Weapons.Boss

-- Fase según la vida: 1 (100–60 %), 2 (60–30 %), 3 (30–0 %).
function Jefe.fase(vida, maxima)
	local f = vida / maxima
	if f > B.PhaseThresholds[1] then
		return 1
	elseif f > B.PhaseThresholds[2] then
		return 2
	end
	return 3
end

-- F25: vida y daño con n jugadores (fijado al empezar).
function Jefe.vida(zona, jugadores)
	return Dano.enemyHealth(zona, "Boss") * Dano.bossScale(jugadores).Health
end

-- Capas de furia: a partir de 12 min, +10 % de daño cada 30 s.
function Jefe.furia(segundos)
	if segundos < B.EnrageSeconds then
		return 0
	end
	return math.floor((segundos - B.EnrageSeconds) / Bosses.EnrageStep.Seconds) + 1
end

-- Daño de un ataque: % de la vida base del jugador de la zona, escalado y con furia. tipo: "Normal" | "Heavy" | "Lethal".
function Jefe.danoAtaque(zona, tipo, jugadores, segundos)
	local base = Progresion.baseHealth(Mineria.zoneLevel(zona)) * B.DamageFraction[tipo]
	return base * Dano.bossScale(jugadores).Damage * (1 + Bosses.EnrageStep.Bonus * Jefe.furia(segundos))
end

-- Botín diario: 3 derrotas con botín completo por jefe y día; después 25 % de monedas y XP y sin material.
-- registro = perfil.Bosses.Daily; clave "z<zona>". Devuelve { Mult, Materials, Count } y lo apunta.
function Jefe.botin(registro, zona, dia)
	local clave = "z" .. zona
	local r = registro[clave]
	if not r or r.Day ~= dia then
		r = { Day = dia, Count = 0 }
		registro[clave] = r
	end
	r.Count = r.Count + 1
	if r.Count <= B.DailyFullLoot then
		return { Mult = 1, Materials = B.MaterialsPerKill, Count = r.Count }
	end
	return { Mult = 0.25, Materials = 0, Count = r.Count }
end

-- ¿Contribuyó lo suficiente? (5 % del daño del grupo)
function Jefe.participa(danoPropio, danoTotal)
	return danoTotal > 0 and danoPropio / danoTotal >= B.MinContribution
end

-- Minutos de combate en solitario o en grupo con el DPS de referencia de cada jugador (sin ventanas de vulnerabilidad).
function Jefe.minutos(zona, jugadores, dpsJugador)
	return Jefe.vida(zona, jugadores) / (dpsJugador * jugadores) / 60
end

return Jefe
