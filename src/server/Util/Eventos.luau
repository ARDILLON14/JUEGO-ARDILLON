-- Util/Eventos: avisos entre servicios de lo que hace cada jugador (para el tutorial y las misiones).
-- Eventos.emitir(nombre, jugador, cantidad, datos)  |  Eventos.escuchar(nombre, fn(jugador, cantidad, datos))
-- Nombres: MineralExtraido, Deposito, VentaMineral, Asignacion, EnemigoDerrotado, HabilidadUsada,
--          ObjetoFabricado, CajaAbierta, JefeDerrotado, XPMascota, GolpesIncubacion

local Eventos = {}

local oyentes = {}

function Eventos.escuchar(nombre, fn)
	oyentes[nombre] = oyentes[nombre] or {}
	table.insert(oyentes[nombre], fn)
end

function Eventos.emitir(nombre, jugador, cantidad, datos)
	for _, fn in ipairs(oyentes[nombre] or {}) do
		task.spawn(fn, jugador, cantidad or 1, datos)
	end
end

return Eventos
