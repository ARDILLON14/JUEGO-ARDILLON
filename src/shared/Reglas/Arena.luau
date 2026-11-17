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

-- Jugadores por equipo de cada modo.
function Arena.porEquipo(modo)
	return tonumber(string.sub(modo, 1, 1)) or 1
end

-- Busca 2 x n jugadores de la cola que puedan pelear juntos: mismo tramo y todos dentro del margen de Elo
-- (el menor de sus márgenes). Devuelve la lista de índices de la cola o nil.
function Arena.buscar(cola, n, ahora)
	local total = 2 * n
	if #cola < total then
		return nil
	end
	local orden = {}
	for i = 1, #cola do
		orden[i] = i
	end
	table.sort(orden, function(a, b)
		local ca, cb = cola[a], cola[b]
		if Arena.tramo(ca.Nivel) ~= Arena.tramo(cb.Nivel) then
			return Arena.tramo(ca.Nivel) < Arena.tramo(cb.Nivel)
		end
		return ca.Elo < cb.Elo
	end)
	for inicio = 1, #orden - total + 1 do
		local primero, ultimo = cola[orden[inicio]], cola[orden[inicio + total - 1]]
		if Arena.tramo(primero.Nivel) == Arena.tramo(ultimo.Nivel) then
			local margen = math.huge
			for k = inicio, inicio + total - 1 do
				margen = math.min(margen, Arena.margen(ahora - cola[orden[k]].Desde))
			end
			if ultimo.Elo - primero.Elo <= margen then
				local r = {}
				for k = inicio, inicio + total - 1 do
					table.insert(r, orden[k])
				end
				return r
			end
		end
	end
	return nil
end

-- Reparte jugadores en 2 equipos equilibrados (en serpiente por Elo: 1-4-5 contra 2-3-6).
-- entradas: lista con campo Elo. Devuelve equipoA, equipoB.
function Arena.repartir(entradas)
	local orden = {}
	for _, e in ipairs(entradas) do
		table.insert(orden, e)
	end
	table.sort(orden, function(a, b)
		return a.Elo > b.Elo
	end)
	local a, b = {}, {}
	for i, e in ipairs(orden) do
		local ronda = math.floor((i - 1) / 2)
		local primero = (i - 1) % 2 == 0
		if (ronda % 2 == 0) == primero then
			table.insert(a, e)
		else
			table.insert(b, e)
		end
	end
	return a, b
end

function Arena.media(elos)
	local s = 0
	for _, e in ipairs(elos) do
		s = s + e
	end
	return s / math.max(1, #elos)
end

-- Elo por equipos: cada jugador cambia K x (resultado - esperado), con el esperado de las medias.
-- Devuelve las listas nuevas. resultado = 1 si gana el equipo A.
function Arena.actualizarEquipos(elosA, elosB, resultado)
	local ea = Arena.esperado(Arena.media(elosA), Arena.media(elosB))
	local da = E.K * (resultado - ea)
	local na, nb = {}, {}
	for i, e in ipairs(elosA) do
		na[i] = math.floor(e + da + 0.5)
	end
	for i, e in ipairs(elosB) do
		nb[i] = math.floor(e - da + 0.5)
	end
	return na, nb
end

return Arena
