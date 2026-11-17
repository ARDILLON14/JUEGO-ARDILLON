-- Mundo/ConstructorPrueba: crea un mapa mínimo para jugar la zona 1 si el lugar no trae uno propio.
-- Un mapa hecho en Studio solo necesita etiquetar (CollectionService):
--   «Mina»  una parte en el centro de la cara de arriba de la cantera, con atributos Zona, Ancho, Largo,
--           Profundidad (en bloques de 4 studs) y Salida (Vector3, opcional). Debajo no debe haber nada.
--   «Banco» y «Mercader»  partes con las que se interactúa
-- Si existe al menos una Mina, este constructor no hace nada.

local CollectionService = game:GetService("CollectionService")

local Mining = require(game:GetService("ReplicatedStorage").Shared.Config.Mining)
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
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = p
	return p
end

function ConstructorPrueba.construirSiFalta()
	if #CollectionService:GetTagged(Lugares.Etiqueta.Mina) > 0 then
		return false
	end
	local B = Mining.Blocks
	local S = B.Size
	local ancho, largo = B.DefaultWidth * S, B.DefaultLength * S
	local centroMina = Vector3.new(0, 0, 100)

	-- El suelo de la plantilla Baseplate taparía la cantera: se sustituye por un suelo con un hueco.
	local base = workspace:FindFirstChild("Baseplate")
	if base and base:IsA("BasePart") then
		base:Destroy()
	end
	local mapa = Instance.new("Folder")
	mapa.Name = "MapaPrueba"
	local suelo = Instance.new("Folder")
	suelo.Name = "Suelo"
	suelo.Parent = mapa
	local grosor, lejos = 4, 400
	local x0, x1 = centroMina.X - ancho / 2, centroMina.X + ancho / 2
	local z0, z1 = centroMina.Z - largo / 2, centroMina.Z + largo / 2
	local function losa(nombre, xa, xb, za, zb)
		parte({ Name = nombre, Size = Vector3.new(xb - xa, grosor, zb - za), Position = Vector3.new((xa + xb) / 2, -grosor / 2, (za + zb) / 2),
			Material = Enum.Material.Grass, Color = Color3.fromRGB(96, 128, 70) }, suelo)
	end
	losa("Sur", -lejos, lejos, -lejos, z0)
	losa("Norte", -lejos, lejos, z1, lejos)
	losa("Oeste", -lejos, x0, z0, z1)
	losa("Este", x1, lejos, z0, z1)

	-- Ciudad (Puerto Veta, versión mínima)
	local ciudad = Instance.new("Folder")
	ciudad.Name = "PuertoVeta"
	ciudad.Parent = mapa
	parte({ Name = "Plaza", Size = Vector3.new(70, 0.4, 44), Position = Vector3.new(0, 0.2, 0), Material = Enum.Material.Cobblestone, Color = Color3.fromRGB(150, 140, 125) }, ciudad)
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
	interactuable("Banco", Lugares.Etiqueta.Banco, Vector3.new(-20, 4, 12), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, ciudad)
	interactuable("Mercader", Lugares.Etiqueta.Mercader, Vector3.new(20, 4, 12), Color3.fromRGB(70, 130, 90), "Abrir tienda", 0, ciudad)

	-- Zona 1: Cantera del Alba (24 x 24 bloques y 40 de profundidad)
	local zona = Instance.new("Folder")
	zona.Name = "Zona1"
	zona.Parent = mapa
	local ancla = parte({ Name = "Mina", Size = Vector3.new(4, 1, 4), Position = centroMina, Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false }, zona)
	ancla:SetAttribute("Zona", 1)
	ancla:SetAttribute("Ancho", B.DefaultWidth)
	ancla:SetAttribute("Largo", B.DefaultLength)
	ancla:SetAttribute("Profundidad", B.DefaultDepth)
	ancla:SetAttribute("Salida", Vector3.new(-40, 1, z0 - 8))
	CollectionService:AddTag(ancla, Lugares.Etiqueta.Mina)
	local cartelZona = parte({ Name = "Cartel", Size = Vector3.new(1, 1, 1), Position = Vector3.new(0, 1, z0 - 4), Transparency = 1, CanCollide = false, CanQuery = false }, zona)
	cartel(cartelZona, "Cantera del Alba · Zona 1", 8, Color3.fromRGB(255, 230, 160))
	interactuable("Banco de la cantera", Lugares.Etiqueta.Banco, Vector3.new(-40, 4, z0 - 14), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, zona)
	mapa.Parent = workspace
	return true
end

return ConstructorPrueba
