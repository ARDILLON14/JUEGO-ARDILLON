-- Services/DepositService: la cantera de bloques de cada zona (DECISIONES P3b).
-- Cada zona minable es una parte con la etiqueta «Mina» y los atributos Zona, Ancho, Largo, Profundidad
-- (en bloques) y, opcional, Salida (Vector3 adonde lleva «Subir a la superficie»). La parte marca el centro
-- de la cara de arriba del volumen. Solo existen partes para los bloques que se ven (los que tocan aire).
--
-- Cada bloque visible lleva atributos que Roblox replica solo: DepositoId, Tipo («Piedra» | «Mineral»),
-- Rareza, Mineral, Zona, Vida, VidaMax. Los de «RocaMadre» (bordes y fondo) no se pueden picar.
--
-- API: Obtener(id) -> { Regla, Parte, Zona, Tipo } | Danar(id, userId, cantidad, suerte) -> aplicado, agotado
--      Cercanos(id, radio) (solo minerales) | AlAgotar(fn) | MinaEn(posicion) -> zona, mina | Salida(zona)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Mineria = require(Shared.Formulas.Mineria)
local Rarezas = require(Shared.Visual.Rarezas)
local Server = script.Parent.Parent
local Deposito = require(Server.Reglas.Deposito)
local Mina = require(Server.Reglas.Mina)
local Lugares = require(Server.Util.Lugares)

local DepositService = {}

local S = Mining.Blocks.Size
local ID_POR_ZONA = 10000000
local azar = Random.new()
local minas = {}          -- [zona] = { Modelo (Reglas/Mina), Ancla, Origen (esquina de arriba), Carpeta, Partes = { [clave] = parte } }
local entradas = {}       -- [id] = { Regla, Parte, Zona, Tipo, Clave }
local alAgotar = {}

local function aleatorio()
	return azar:NextNumber()
end

local function centro(mina, x, y, z)
	return mina.Origen + Vector3.new((x - 0.5) * S, -(y - 0.5) * S, (z - 0.5) * S)
end

local function idDe(zona, clave)
	return zona * ID_POR_ZONA + clave
end

local function crearRocaMadre(mina, x, y, z)
	local p = Instance.new("Part")
	p.Name = "RocaMadre"
	p.Anchored = true
	p.Size = Vector3.new(S, S, S)
	p.Position = centro(mina, x, y, z)
	p.Material = Enum.Material.Basalt
	p.Color = Color3.fromRGB(38, 36, 40)
	p:SetAttribute("Tipo", "RocaMadre")
	p.Parent = mina.Carpeta
end

local function crearBloque(mina, clave, x, y, z, bloque)
	local zona = mina.Modelo.Zona
	local id = idDe(zona, clave)
	local regla
	local p = Instance.new("Part")
	p.Anchored = true
	p.Size = Vector3.new(S, S, S)
	p.Position = centro(mina, x, y, z)
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if bloque.Tipo == "Mineral" then
		regla = Deposito.nuevo(id, zona, bloque.Rareza, bloque.Mineral)
		p.Name = "Mineral"
		p.Material = Enum.Material.Rock
		p.Color = Rarezas.color(bloque.Rareza)
		p:SetAttribute("Rareza", bloque.Rareza)
		p:SetAttribute("Mineral", bloque.Mineral)
		if bloque.Rareza ~= "Common" and bloque.Rareza ~= "Uncommon" and bloque.Rareza ~= "Rare" then
			local luz = Instance.new("PointLight")
			luz.Color = p.Color
			luz.Range = 12
			luz.Brightness = 1.2
			luz.Parent = p
		end
	else
		local vida = Mineria.stoneHealth(zona)
		regla = { Id = id, Zone = zona, MaxHealth = vida, Health = vida, Damage = {}, Depleted = false }
		p.Name = "Piedra"
		p.Material = Enum.Material.Slate
		local tono = 105 + azar:NextInteger(-12, 12)
		p.Color = Color3.fromRGB(tono, tono - 4, tono - 8)
	end
	regla.Tipo = bloque.Tipo
	p:SetAttribute("DepositoId", id)
	p:SetAttribute("Tipo", bloque.Tipo)
	p:SetAttribute("Zona", zona)
	p:SetAttribute("Vida", regla.Health)
	p:SetAttribute("VidaMax", regla.MaxHealth)
	CollectionService:AddTag(p, Lugares.Etiqueta.Deposito)
	p.Parent = mina.Carpeta
	mina.Partes[clave] = p
	entradas[id] = { Regla = regla, Parte = p, Zona = zona, Tipo = bloque.Tipo, Clave = clave }
end

local function quitarParte(mina, clave)
	local p = mina.Partes[clave]
	if p then
		mina.Partes[clave] = nil
		entradas[idDe(mina.Modelo.Zona, clave)] = nil
		p:Destroy()
	end
end

local function aplicarNovedades(mina, novedades)
	for _, n in ipairs(novedades) do
		if n.Tipo == "Bloque" then
			crearBloque(mina, n.Clave, n.X, n.Y, n.Z, n.Bloque)
		else
			crearRocaMadre(mina, n.X, n.Y, n.Z)
		end
	end
end

local function hayJugadorCerca(posicion, radio)
	for _, jugador in ipairs(Players:GetPlayers()) do
		local pos = Lugares.posicion(jugador)
		if pos and (pos - posicion).Magnitude <= radio then
			return true
		end
	end
	return false
end

local function regenerar(mina)
	local m = mina.Modelo
	local ahora = os.clock()
	for _, clave in ipairs(Mina.huecosParaRegenerar(m, ahora)) do
		local x, y, z = Mina.coords(m, clave)
		if not hayJugadorCerca(centro(mina, x, y, z), Mining.Blocks.RegenPlayerRadius) then
			local nuevo, tapados = Mina.regenerar(m, clave, aleatorio)
			for _, t in ipairs(tapados) do
				quitarParte(mina, t)
			end
			if nuevo then
				crearBloque(mina, clave, x, y, z, nuevo)
			end
		end
	end
end

local function prepararMina(ancla)
	local zona = ancla:GetAttribute("Zona")
	if type(zona) ~= "number" or zona < 1 or zona > 10 or zona ~= math.floor(zona) or minas[zona] then
		return
	end
	local B = Mining.Blocks
	local ancho = ancla:GetAttribute("Ancho") or B.DefaultWidth
	local largo = ancla:GetAttribute("Largo") or B.DefaultLength
	local profundidad = ancla:GetAttribute("Profundidad") or B.DefaultDepth
	local carpeta = Instance.new("Folder")
	carpeta.Name = "Mina" .. zona
	carpeta.Parent = workspace
	local mina = {
		Modelo = Mina.nueva({ Zona = zona, Ancho = ancho, Largo = largo, Profundidad = profundidad }),
		Ancla = ancla,
		Origen = ancla.Position - Vector3.new(ancho * S / 2, 0, largo * S / 2),
		Carpeta = carpeta,
		Partes = {},
	}
	minas[zona] = mina
	aplicarNovedades(mina, Mina.iniciar(mina.Modelo, aleatorio))
	print(string.format("OREBOUND: mina de la zona %d con %d x %d x %d bloques", zona, ancho, largo, profundidad))
end

function DepositService.Iniciar()
	for _, ancla in ipairs(CollectionService:GetTagged(Lugares.Etiqueta.Mina)) do
		prepararMina(ancla)
	end
	task.spawn(function()
		while true do
			task.wait(5)
			for _, mina in pairs(minas) do
				regenerar(mina)
			end
		end
	end)
end

function DepositService.Obtener(id)
	return entradas[id]
end

function DepositService.AlAgotar(fn)
	table.insert(alAgotar, fn)
end

-- Aplica daño a un bloque. Al romperse: si es mineral, avisa a los AlAgotar (reparto); después lo quita,
-- destapa lo que hay detrás (sorteado con la Suerte de quien lo rompe) y, con Eco estelar, vuelve a ponerlo.
function DepositService.Danar(id, userId, cantidad, suerte)
	local e = entradas[id]
	if not e then
		return 0, false
	end
	local aplicado, agotado = Deposito.golpear(e.Regla, userId, cantidad)
	e.Parte:SetAttribute("Vida", e.Regla.Health)
	if not agotado then
		return aplicado, false
	end
	local reaparece = false
	if e.Tipo == "Mineral" then
		for _, fn in ipairs(alAgotar) do
			local ok, r = pcall(fn, e, aleatorio)
			if ok and r == true then
				reaparece = true
			elseif not ok then
				warn("DepositService: " .. tostring(r))
			end
		end
	end
	local mina = minas[e.Zona]
	local m = mina.Modelo
	local x, y, z = Mina.coords(m, e.Clave)
	local bloque = m.Bloques[e.Clave]
	quitarParte(mina, e.Clave)
	local _, novedades = Mina.picar(m, x, y, z, os.clock(), aleatorio, suerte or 0)
	aplicarNovedades(mina, novedades)
	if reaparece and bloque then
		-- Eco estelar: el mismo mineral vuelve a estar ahí.
		m.Aire[e.Clave] = nil
		m.NumAire = m.NumAire - 1
		m.Bloques[e.Clave] = bloque
		crearBloque(mina, e.Clave, x, y, z, bloque)
	end
	return aplicado, true
end

-- Otros bloques de mineral visibles a menos de radio studs (para Eco del filo y Onda sísmica), del más cercano al más lejano.
function DepositService.Cercanos(id, radio)
	local e = entradas[id]
	local lista = {}
	if not e then
		return lista
	end
	local mina = minas[e.Zona]
	local m = mina.Modelo
	local x0, y0, z0 = Mina.coords(m, e.Clave)
	local r = math.ceil(radio / S)
	local origen = e.Parte.Position
	for dx = -r, r do
		for dy = -r, r do
			for dz = -r, r do
				local x, y, z = x0 + dx, y0 + dy, z0 + dz
				if (dx ~= 0 or dy ~= 0 or dz ~= 0) and Mina.dentro(m, x, y, z) then
					local otro = entradas[idDe(e.Zona, Mina.clave(m, x, y, z))]
					if otro and otro.Tipo == "Mineral" and (otro.Parte.Position - origen).Magnitude <= radio then
						table.insert(lista, otro.Regla.Id)
					end
				end
			end
		end
	end
	table.sort(lista, function(a, b)
		return (entradas[a].Parte.Position - origen).Magnitude < (entradas[b].Parte.Position - origen).Magnitude
	end)
	return lista
end

-- Zona de la mina en la que está esa posición (dentro del volumen o hasta 6 studs por encima), o nil.
function DepositService.MinaEn(posicion)
	for zona, mina in pairs(minas) do
		local m = mina.Modelo
		local rel = posicion - mina.Origen
		if rel.X >= 0 and rel.X <= m.Ancho * S and rel.Z >= 0 and rel.Z <= m.Largo * S and rel.Y <= 6 and rel.Y >= -(m.Profundidad + 1) * S then
			return zona, mina
		end
	end
	return nil
end

-- Adónde lleva «Subir a la superficie»: el atributo Salida de la mina o el borde de la cara de arriba.
function DepositService.Salida(zona)
	local mina = minas[zona]
	if not mina then
		return nil
	end
	local salida = mina.Ancla:GetAttribute("Salida")
	if typeof(salida) == "Vector3" then
		return salida
	end
	return mina.Origen + Vector3.new(-6, 4, -6)
end

function DepositService.RegistrarMinero()
	-- Sin uso con la minería por bloques: la Suerte la pone quien destapa cada bloque.
end

return DepositService
