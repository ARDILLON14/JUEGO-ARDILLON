-- Util/Mover: todos los movimientos de personajes que hace el servidor (portales, dash, parpadeo, extracción,
-- sala del jefe, arena...) pasan por aquí, para que el antitrampas no los tome por movimientos imposibles.

local Mover = {}

local oyentes = {}

function Mover.alMover(fn)
	table.insert(oyentes, fn)
end

-- personaje: Model del jugador; cframe: destino.
function Mover.personaje(personaje, cframe)
	if not personaje then
		return
	end
	personaje:PivotTo(cframe)
	for _, fn in ipairs(oyentes) do
		fn(personaje, cframe)
	end
end

return Mover
