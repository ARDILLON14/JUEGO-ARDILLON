-- Reglas/Arena: emparejamiento por Elo y tramos de nivel, y actualización de la puntuación (B4 9.3). Puro.

local PvP = require(script.Parent.Parent.Config.PvP)

local Arena = {}

local E = PvP.Arena.Elo

function Arena.tramo(nivel)
	return math.floor((nivel - 1) / PvP.Arena.BracketLevels)
end

-- Nivel con el que se pelea: el máximo del tramo.
function Arena.nivelTramo(nivel)
	return (Arena.tramo(nivel) + 1) * PvP.Arena.BracketLevels
end

-- Margen de Elo según el tiempo esperando: ±100, +50 cada 15 s.
function Arena.margen(segundos)
	return E.SearchRange + E.RangeGrowth * math.floor(segundos / E.GrowthSeconds)
end

function Arena.compatibles(a, b, ahora)
	if Arena.tramo(a.Nivel) ~= Arena.tramo(b.Nivel) then
		return false
	end
	local m = math.min(Arena.margen(ahora - a.Desde), Arena.margen(ahora - b.Desde))
	return math.abs(a.Elo - b.Elo) <= m
end

function Arena.esperado(a, b)
	return 1 / (1 + 10 ^ ((b - a) / 400))
end

-- Nuevas puntuaciones tras un combate (resultado 1 = gana a, 0 = gana b).
function Arena.actualizar(a, b, resultado)
	local ea = Arena.esperado(a, b)
	local na = a + E.K * (resultado - ea)
	local nb = b + E.K * ((1 - resultado) - (1 - ea))
	return math.floor(na + 0.5), math.floor(nb + 0.5)
end

return Arena
