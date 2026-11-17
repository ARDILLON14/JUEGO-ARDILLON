-- Reglas/Niveles: XP, subida de nivel y desbloqueo de zonas (B2 F6 a F8; B3 F13). Funciones puras.

local Shared = script.Parent.Parent
local Economy = require(Shared.Config.Economy)
local Worlds = require(Shared.Config.Worlds)
local Progresion = require(Shared.Formulas.Progresion)
local Mineria = require(Shared.Formulas.Mineria)

local Niveles = {}

-- Zona más profunda que permite el nivel (nivel de zona = 100 x (z - 1)).
-- La Minería y la potencia de pico se comprueban al entrar a picar, no aquí.
function Niveles.zonaPorNivel(nivel)
	for z = #Worlds.Zones, 1, -1 do
		if nivel >= Mineria.zoneLevel(z) then
			return z
		end
	end
	return 1
end

-- Bono de XP por renacimiento: +5 % por cada uno.
function Niveles.multiplicadorXP(perfil)
	return 1 + Economy.Rebirth.XPBonus * (perfil.Progress.Rebirths or 0)
end

-- Suma XP al perfil. cantidad = XP base de la acción (ya calculada por el servidor).
-- Devuelve { Ganado, Subidos, NivelAnterior, Nivel, ZonaAnterior, Zona }.
function Niveles.sumarXP(perfil, cantidad)
	assert(type(cantidad) == "number" and cantidad == cantidad and cantidad >= 0 and cantidad < math.huge, "XP no válida")
	local p = perfil.Progress
	local ganado = math.floor(cantidad * Niveles.multiplicadorXP(perfil))
	local antes, zonaAntes = p.Level, p.UnlockedZone
	local nivel, xp, subidos = Progresion.addXP(p.Level, p.XP, ganado)
	p.Level = nivel
	p.XP = xp
	p.UnlockedZone = math.max(p.UnlockedZone, Niveles.zonaPorNivel(nivel))
	return { Ganado = ganado, Subidos = subidos, NivelAnterior = antes, Nivel = nivel, ZonaAnterior = zonaAntes, Zona = p.UnlockedZone }
end

-- Progreso hacia el siguiente nivel, de 0 a 1 (para la barra).
function Niveles.progreso(perfil)
	return math.clamp(perfil.Progress.XP / Progresion.xpForLevel(perfil.Progress.Level), 0, 1)
end

return Niveles
