-- Reglas/Mina: la cantera como volumen de bloques (DECISIONES P3b). Puro: no crea partes ni usa el tiempo real.
-- Coordenadas en bloques: x de 1 a Ancho, z de 1 a Largo, y de 1 (capa de arriba) a Profundidad (y crece hacia abajo).
-- Cada celda es:
--   sólida sin destapar  -> no está en ninguna tabla; aún no se sabe qué es
--   destapada            -> Bloques[clave] = { Tipo = "Piedra" | "Mineral", Rareza, Mineral }; se ve y se puede picar
--   aire                 -> Aire[clave] = momento en que se picó
-- Fuera del volumen (lados y fondo) hay «roca madre»: se ve pero no se puede picar. Encima de la capa 1, cielo.
-- Un bloque se sortea en el momento en que queda a la vista: mineral con probabilidad OreChance, si no, piedra.

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Generador = require(script.Parent.Generador)

local Mina = {}

local VECINOS = { { 1, 0, 0 }, { -1, 0, 0 }, { 0, 1, 0 }, { 0, -1, 0 }, { 0, 0, 1 }, { 0, 0, -1 } }

-- dim = { Zona, Ancho, Largo, Profundidad }
function Mina.nueva(dim)
	return {
		Zona = dim.Zona, Ancho = dim.Ancho, Largo = dim.Largo, Profundidad = dim.Profundidad,
		Bloques = {}, Aire = {}, RocaMadre = {}, NumAire = 0,
	}
end

function Mina.clave(m, x, y, z)
	return x + m.Ancho * ((z - 1) + m.Largo * (y - 1))
end

-- Inversa de clave para celdas dentro del volumen.
function Mina.coords(m, clave)
	local i = clave - 1
	local x = i % m.Ancho + 1
	i = math.floor(i / m.Ancho)
	local z = i % m.Largo + 1
	local y = math.floor(i / m.Largo) + 1
	return x, y, z
end

function Mina.dentro(m, x, y, z)
	return x >= 1 and x <= m.Ancho and z >= 1 and z <= m.Largo and y >= 1 and y <= m.Profundidad
end

-- Roca madre: celdas justo fuera del volumen por los lados o por debajo (no por arriba).
local function esRocaMadre(m, x, y, z)
	if y < 1 then
		return false
	end
	return not Mina.dentro(m, x, y, z) and x >= 0 and x <= m.Ancho + 1 and z >= 0 and z <= m.Largo + 1 and y <= m.Profundidad + 1
end

function Mina.esAire(m, x, y, z)
	if y < 1 then
		return true   -- cielo
	end
	return Mina.dentro(m, x, y, z) and m.Aire[Mina.clave(m, x, y, z)] ~= nil
end

-- ¿Toca aire (o el cielo) por alguna cara?
function Mina.expuesta(m, x, y, z)
	for _, d in ipairs(VECINOS) do
		if Mina.esAire(m, x + d[1], y + d[2], z + d[3]) then
			return true
		end
	end
	return false
end

-- Sorteo del contenido. u1 decide mineral o piedra; u2, la rareza; suerte = Suerte de quien lo destapa.
function Mina.sortear(zona, suerte, u1, u2)
	if u1 < Mining.Blocks.OreChance then
		local rareza = Generador.rareza(zona, suerte, u2)
		return { Tipo = "Mineral", Rareza = rareza, Mineral = Generador.mineral(zona, rareza) }
	end
	return { Tipo = "Piedra" }
end

-- Destapa una celda sólida si está a la vista. Devuelve la lista de novedades:
-- { { Tipo = "Bloque", Clave, X, Y, Z, Bloque } } o { { Tipo = "RocaMadre", X, Y, Z } }.
local function destapar(m, x, y, z, aleatorio, suerte, salida)
	if Mina.dentro(m, x, y, z) then
		local k = Mina.clave(m, x, y, z)
		if m.Aire[k] or m.Bloques[k] then
			return
		end
		local b = Mina.sortear(m.Zona, suerte, aleatorio(), aleatorio())
		m.Bloques[k] = b
		table.insert(salida, { Tipo = "Bloque", Clave = k, X = x, Y = y, Z = z, Bloque = b })
	elseif esRocaMadre(m, x, y, z) then
		local k = x .. "," .. y .. "," .. z
		if not m.RocaMadre[k] then
			m.RocaMadre[k] = true
			table.insert(salida, { Tipo = "RocaMadre", X = x, Y = y, Z = z })
		end
	end
end

-- Capa de arriba al empezar: todas sus celdas están a la vista del cielo.
function Mina.iniciar(m, aleatorio)
	local salida = {}
	for x = 1, m.Ancho do
		for z = 1, m.Largo do
			destapar(m, x, 1, z, aleatorio, 0, salida)
		end
	end
	return salida
end

-- Pica (quita) un bloque destapado. Devuelve el bloque quitado y la lista de lo que queda a la vista.
function Mina.picar(m, x, y, z, ahora, aleatorio, suerte)
	if not Mina.dentro(m, x, y, z) then
		return nil, {}
	end
	local k = Mina.clave(m, x, y, z)
	local b = m.Bloques[k]
	if not b then
		return nil, {}
	end
	m.Bloques[k] = nil
	m.Aire[k] = ahora
	m.NumAire = m.NumAire + 1
	local salida = {}
	for _, d in ipairs(VECINOS) do
		destapar(m, x + d[1], y + d[2], z + d[3], aleatorio, suerte or 0, salida)
	end
	return b, salida
end

-- Huecos que ya pueden volver a ser piedra (picados hace más de RegenSeconds). Devuelve claves.
function Mina.huecosParaRegenerar(m, ahora)
	local lista = {}
	for k, momento in pairs(m.Aire) do
		if ahora - momento >= Mining.Blocks.RegenSeconds then
			table.insert(lista, k)
		end
	end
	table.sort(lista)
	return lista
end

-- Vuelve a llenar un hueco: queda como bloque nuevo (se ve, porque toca otros huecos o el cielo) o sin destapar.
-- Los vecinos que ya no tocan aire vuelven a «sin destapar» (su contenido se sorteará de nuevo).
-- Devuelve: el bloque nuevo (o nil si quedó tapado) y la lista de claves de vecinos que se han tapado.
function Mina.regenerar(m, k, aleatorio)
	if not m.Aire[k] then
		return nil, {}
	end
	m.Aire[k] = nil
	m.NumAire = m.NumAire - 1
	local x, y, z = Mina.coords(m, k)
	local nuevo = nil
	if Mina.expuesta(m, x, y, z) then
		nuevo = Mina.sortear(m.Zona, 0, aleatorio(), aleatorio())
		m.Bloques[k] = nuevo
	end
	local tapados = {}
	for _, d in ipairs(VECINOS) do
		local vx, vy, vz = x + d[1], y + d[2], z + d[3]
		if Mina.dentro(m, vx, vy, vz) then
			local vk = Mina.clave(m, vx, vy, vz)
			if m.Bloques[vk] and not Mina.expuesta(m, vx, vy, vz) then
				m.Bloques[vk] = nil
				table.insert(tapados, vk)
			end
		end
	end
	return nuevo, tapados
end

return Mina
