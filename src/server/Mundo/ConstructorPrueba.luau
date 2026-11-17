-- Mundo/ConstructorPrueba: crea un mapa mínimo para jugar la zona 1 si el lugar no trae uno propio.
-- Un mapa hecho en Studio solo necesita etiquetar (CollectionService):
--   «Mina»  una parte en el centro de la cara de arriba de la cantera, con atributos Zona, Ancho, Largo,
--           Profundidad (en bloques de 4 studs) y Salida (Vector3, opcional). Debajo no debe haber nada.
--   «Banco», «Mercader», «Forja», «Cajas»  partes con las que se interactúa
--   «PuntoEnemigo» (Zona), «ArenaJefe» y «PuertaJefe» (Zona), «Portal» (Destino), «LlegadaZona» (Zona), «Ciudad»
-- Si existe al menos una Mina, este constructor no hace nada.

local CollectionService = game:GetService("CollectionService")

local Mining = require(game:GetService("ReplicatedStorage").Shared.Config.Mining)
local Worlds = require(game:GetService("ReplicatedStorage").Shared.Config.Worlds)

local function WorldsNombre(zona)
	for _, z in ipairs(Worlds.Zones) do
		if z.Id == zona then
			return z.Name
		end
	end
	return "Zona " .. zona
end
local Lugares = require(script.Parent.Parent.Util.Lugares)

local ConstructorPrueba = {}

local function parte(props, padre)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do
		p[k] = v
	end
	p.Parent = padre
	return p
end

local function cartel(adorno, texto, alto, color)
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.new(0, 220, 0, 40)
	b.StudsOffset = Vector3.new(0, alto or 6, 0)
	b.AlwaysOnTop = false
	b.MaxDistance = 120
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = UDim2.fromScale(1, 1)
	l.Font = Enum.Font.GothamBold
	l.TextScaled = true
	l.TextColor3 = color or Color3.new(1, 1, 1)
	l.TextStrokeTransparency = 0.3
	l.Text = texto
	l.Parent = b
	b.Parent = adorno
end

local function interactuable(nombre, etiqueta, posicion, color, accion, espera, padre)
	local p = parte({ Name = nombre, Size = Vector3.new(8, 8, 4), Position = posicion, Color = color, Material = Enum.Material.SmoothPlastic }, padre)
	CollectionService:AddTag(p, etiqueta)
	cartel(p, nombre, 6)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = accion
	prompt.ObjectText = nombre
	prompt.HoldDuration = espera or 0
	prompt.KeyboardKeyCode = Enum.KeyCode.R   -- E es el parpadeo (B4, 2.2: interactuar con R)
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = p
	return p
end

-- Zonas del mapa de prueba: centro de la cantera (en la rejilla de 96 studs), lado (x) y colores.
local ZONAS = {
	[1] = { Mina = Vector3.new(0, 0, 100), Lado = 0, Suelo = Color3.fromRGB(96, 128, 70), Llanura = Color3.fromRGB(120, 105, 80) },
	[2] = { Mina = Vector3.new(-288, 0, 100), Lado = -1, Suelo = Color3.fromRGB(70, 110, 70), Llanura = Color3.fromRGB(60, 95, 60) },
	[3] = { Mina = Vector3.new(288, 0, 100), Lado = 1, Suelo = Color3.fromRGB(210, 205, 195), Llanura = Color3.fromRGB(190, 185, 175) },
}
local REGION = { XMin = 200, XMax = 420, ZMin = -80, ZMax = 280 }   -- zonas 2 y 3 (a cada lado), cerradas por barreras

local function enRegion(x, z)
	local ax = math.abs(x)
	if ax >= REGION.XMin and ax <= REGION.XMax and z >= REGION.ZMin and z <= REGION.ZMax then
		return x < 0 and 2 or 3
	end
	return nil
end

local function etiqueta(p, nombre, atributos)
	CollectionService:AddTag(p, nombre)
	for k, v in pairs(atributos or {}) do
		p:SetAttribute(k, v)
	end
	return p
end

local function invisible(nombre, posicion, padre)
	return parte({ Name = nombre, Size = Vector3.new(2, 1, 2), Position = posicion, Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false }, padre)
end

local function portal(nombre, posicion, destino, padre, color)
	local p = parte({ Name = nombre, Size = Vector3.new(6, 9, 1), Position = posicion, Material = Enum.Material.Neon, Color = color or Color3.fromRGB(120, 200, 255),
		Transparency = 0.25, CanCollide = false }, padre)
	etiqueta(p, "Portal", { Destino = destino })
	cartel(p, nombre, 6)
	return p
end

local function sala(zona, centro, padre)
	local suelo = parte({ Name = "SalaJefe", Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.4, 80, 80), CFrame = CFrame.new(centro + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90)),
		Material = Enum.Material.Slate, Color = Color3.fromRGB(70, 60, 60) }, padre)
	etiqueta(invisible("ArenaJefe", centro + Vector3.new(0, 0.5, 0), padre), "ArenaJefe", { Zona = zona })
	local puerta = parte({ Name = "PuertaJefe", Size = Vector3.new(10, 8, 1), Position = centro + Vector3.new(0, 4, -58), Material = Enum.Material.Neon,
		Color = Color3.fromRGB(255, 120, 60), Transparency = 0.3, CanCollide = false }, padre)
	etiqueta(puerta, "PuertaJefe", { Zona = zona })
	cartel(puerta, "Jefe de la zona " .. zona, 7, Color3.fromRGB(255, 170, 120))
	return suelo
end

function ConstructorPrueba.construirSiFalta()
	if #CollectionService:GetTagged(Lugares.Etiqueta.Mina) > 0 then
		return false
	end
	local B = Mining.Blocks
	local S = B.Size
	local lado = B.DefaultWidth * S   -- 96: una baldosa de la rejilla por cantera

	-- El suelo de la plantilla taparía las canteras: se sustituye por baldosas de 96 studs con huecos.
	local base = workspace:FindFirstChild("Baseplate")
	if base and base:IsA("BasePart") then
		base:Destroy()
	end
	local mapa = Instance.new("Folder")
	mapa.Name = "MapaPrueba"
	local suelo = Instance.new("Folder")
	suelo.Name = "Suelo"
	suelo.Parent = mapa
	local huecos = {}
	for _, z in pairs(ZONAS) do
		huecos[z.Mina.X .. "," .. z.Mina.Z] = true
	end
	for i = -5, 4 do
		for j = -6, 5 do
			local cx, cz = -48 + lado * i + lado / 2, 52 + lado * j + lado / 2
			if not huecos[cx .. "," .. cz] then
				local zona = enRegion(cx, cz)
				parte({ Name = "Baldosa", Size = Vector3.new(lado, 4, lado), Position = Vector3.new(cx, -2, cz), Material = Enum.Material.Grass,
					Color = zona and ZONAS[zona].Suelo or ZONAS[1].Suelo }, suelo)
			end
		end
	end

	-- Ciudad (Puerto Veta, versión mínima)
	local ciudad = Instance.new("Folder")
	ciudad.Name = "PuertoVeta"
	ciudad.Parent = mapa
	local plaza = parte({ Name = "Plaza", Size = Vector3.new(70, 0.4, 44), Position = Vector3.new(0, 0.2, 0), Material = Enum.Material.Cobblestone, Color = Color3.fromRGB(150, 140, 125) }, ciudad)
	etiqueta(plaza, "Ciudad")
	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 0.5, -10)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(255, 220, 120)
	spawn.Transparency = 0.4
	spawn.Parent = ciudad
	etiqueta(invisible("LlegadaCiudad", Vector3.new(0, 1, -10), ciudad), "LlegadaZona", { Zona = "Ciudad" })
	interactuable("Banco", Lugares.Etiqueta.Banco, Vector3.new(-20, 4, 12), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, ciudad)
	interactuable("Mercader", Lugares.Etiqueta.Mercader, Vector3.new(20, 4, 12), Color3.fromRGB(70, 130, 90), "Abrir tienda", 0, ciudad)
	interactuable("Forja", "Forja", Vector3.new(-24, 4, -14), Color3.fromRGB(150, 70, 40), "Abrir forja", 0, ciudad)
	interactuable("Geodas", "Cajas", Vector3.new(24, 4, -14), Color3.fromRGB(110, 90, 160), "Ver cajas", 0, ciudad)
	portal("Galerías de Musgo (nivel 100)", Vector3.new(-31, 4.5, -2), 2, ciudad, Color3.fromRGB(90, 200, 110))
	portal("Vetas Salinas (nivel 200)", Vector3.new(31, 4.5, -2), 3, ciudad, Color3.fromRGB(230, 230, 255))

	for numero, z in pairs(ZONAS) do
		local carpeta = Instance.new("Folder")
		carpeta.Name = "Zona" .. numero
		carpeta.Parent = mapa
		local mina = z.Mina
		local x0, z0 = mina.X - lado / 2, mina.Z - lado / 2
		local ancla = invisible("Mina", mina, carpeta)
		etiqueta(ancla, Lugares.Etiqueta.Mina, { Zona = numero, Ancho = B.DefaultWidth, Largo = B.DefaultLength, Profundidad = B.DefaultDepth })
		local nombre = WorldsNombre(numero)
		local cartelZona = invisible("Cartel", Vector3.new(mina.X, 1, z0 - 4), carpeta)
		cartel(cartelZona, nombre .. " · Zona " .. numero, 8, Color3.fromRGB(255, 230, 160))

		-- Llanura de enemigos y su suelo
		local fx = numero == 1 and 128 or z.Lado * 350
		local llanura = parte({ Name = "Llanura", Size = Vector3.new(numero == 1 and 90 or 110, 0.3, 100), Position = Vector3.new(fx, 0.15, numero == 1 and 0 or -20),
			Material = Enum.Material.Ground, Color = z.Llanura }, carpeta)
		cartel(invisible("CartelLlanura", Vector3.new(fx, 1, numero == 1 and -48 or -68), carpeta), "Enemigos de la zona " .. numero, 8, Color3.fromRGB(255, 170, 150))
		local azar = Random.new(numero * 4)
		for _ = 1, 14 do
			local p = invisible("PuntoEnemigo", Vector3.new(fx + azar:NextNumber(-40, 40), 0.5, llanura.Position.Z + azar:NextNumber(-42, 42)), carpeta)
			etiqueta(p, "PuntoEnemigo", { Zona = numero })
		end

		-- Sala del jefe, detrás de la cantera
		sala(numero, Vector3.new(mina.X, 0, mina.Z + 130), carpeta)

		if numero == 1 then
			ancla:SetAttribute("Salida", Vector3.new(-40, 1, z0 - 8))
			interactuable("Banco de la cantera", Lugares.Etiqueta.Banco, Vector3.new(-40, 4, z0 - 14), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, carpeta)
			etiqueta(invisible("Llegada1", Vector3.new(-30, 1, z0 - 8), carpeta), "LlegadaZona", { Zona = 1 })
		else
			local entrada = Vector3.new(z.Lado * 225, 1, -60)
			ancla:SetAttribute("Salida", Vector3.new(z.Lado * 230, 1, 40))
			etiqueta(invisible("Llegada" .. numero, entrada, carpeta), "LlegadaZona", { Zona = numero })
			interactuable("Banco de la zona " .. numero, Lugares.Etiqueta.Banco, Vector3.new(z.Lado * 225, 4, -30), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, carpeta)
			portal("Volver a Puerto Veta", entrada + Vector3.new(z.Lado * -12, 3.5, -10), "Ciudad", carpeta, Color3.fromRGB(255, 220, 120))
			-- Barreras: solo se entra por el portal.
			local xa, xb = math.min(z.Lado * REGION.XMin, z.Lado * REGION.XMax), math.max(z.Lado * REGION.XMin, z.Lado * REGION.XMax)
			local function muro(pos, tam)
				parte({ Name = "Barrera", Size = tam, Position = pos, Material = Enum.Material.ForceField, Color = z.Suelo, Transparency = 0.5 }, carpeta)
			end
			local alto = 80
			muro(Vector3.new((xa + xb) / 2, alto / 2 - 4, REGION.ZMin), Vector3.new(xb - xa, alto, 2))
			muro(Vector3.new((xa + xb) / 2, alto / 2 - 4, REGION.ZMax), Vector3.new(xb - xa, alto, 2))
			muro(Vector3.new(xa, alto / 2 - 4, (REGION.ZMin + REGION.ZMax) / 2), Vector3.new(2, alto, REGION.ZMax - REGION.ZMin))
			muro(Vector3.new(xb, alto / 2 - 4, (REGION.ZMin + REGION.ZMax) / 2), Vector3.new(2, alto, REGION.ZMax - REGION.ZMin))
		end
	end
	mapa.Parent = workspace
	return true
end

return ConstructorPrueba
