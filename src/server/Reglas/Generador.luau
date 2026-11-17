-- Reglas/Generador: qué depósito aparece y cuántos hay activos (B3, sección 5). Puro.

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Rarity = require(Shared.Config.Rarity)
local Mineria = require(Shared.Formulas.Mineria)
local Suerte = require(Shared.Formulas.Suerte)

local Generador = {}

-- Índice [zona][rareza] = id de mineral (un mineral por rareza y zona en el catálogo de B3).
local INDICE = {}
for id, m in pairs(Mining.Minerals) do
	INDICE[m.Zone] = INDICE[m.Zone] or {}
	assert(INDICE[m.Zone][m.Rarity] == nil, "dos minerales con la misma zona y rareza: " .. id)
	INDICE[m.Zone][m.Rarity] = id
end

function Generador.mineral(zona, rareza)
	return INDICE[zona] and INDICE[zona][rareza]
end

-- Rareza de un depósito nuevo: tabla de la zona con la Suerte media de los presentes (B3, 5.3).
-- u = número en [0, 1).
function Generador.rareza(zona, suerteMedia, u)
	local pesos = Suerte.applyLuck(Mineria.spawnWeights(zona), suerteMedia or 0)
	return Suerte.pickWeighted(pesos, Rarity.Order, u)
end

-- Depósitos activos con esos mineros, sin pasar de los puntos que tiene el mapa.
function Generador.activos(mineros, puntos)
	return math.min(Mineria.activeDeposits(mineros), puntos)
end

function Generador.regeneracion()
	return Mining.Spawn.RespawnSeconds
end

return Generador
