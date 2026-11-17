-- Mundo/ConstructorPrueba: crea un mapa mínimo para jugar la zona 1 si el lugar no trae uno propio.
-- Un mapa hecho en Studio solo necesita etiquetar (CollectionService):
--   «PuntoDeposito» (con atributo Zona = número)  donde pueden aparecer depósitos
--   «Banco» y «Mercader»                           partes con las que se interactúa
-- Si existe al menos un PuntoDeposito, este constructor no hace nada.

local CollectionService = game:GetService("CollectionService")

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
	if #CollectionService:GetTagged(Lugares.Etiqueta.PuntoDeposito) > 0 then
		return false
	end
	local mapa = Instance.new("Folder")
	mapa.Name = "MapaPrueba"

	-- Ciudad (Puerto Veta, versión mínima)
	local ciudad = Instance.new("Folder")
	ciudad.Name = "PuertoVeta"
	ciudad.Parent = mapa
	parte({ Name = "Plaza", Size = Vector3.new(70, 1, 44), Position = Vector3.new(0, 0.5, 0), Material = Enum.Material.Cobblestone, Color = Color3.fromRGB(150, 140, 125) }, ciudad)
	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = Vector3.new(0, 1.05, -10)
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Material = Enum.Material.Neon
	spawn.Color = Color3.fromRGB(255, 220, 120)
	spawn.Transparency = 0.4
	spawn.Parent = ciudad
	interactuable("Banco", Lugares.Etiqueta.Banco, Vector3.new(-20, 5, 12), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, ciudad)
	interactuable("Mercader", Lugares.Etiqueta.Mercader, Vector3.new(20, 5, 12), Color3.fromRGB(70, 130, 90), "Abrir tienda", 0, ciudad)

	-- Zona 1: Cantera del Alba
	local zona = Instance.new("Folder")
	zona.Name = "Zona1"
	zona.Parent = mapa
	local suelo = parte({ Name = "Suelo", Size = Vector3.new(130, 1, 120), Position = Vector3.new(0, 0.5, 100), Material = Enum.Material.Slate, Color = Color3.fromRGB(110, 105, 100) }, zona)
	cartel(suelo, "Cantera del Alba · Zona 1", 4, Color3.fromRGB(255, 230, 160))
	suelo:FindFirstChildOfClass("BillboardGui").StudsOffsetWorldSpace = Vector3.new(0, 0, -55)
	interactuable("Banco de la cantera", Lugares.Etiqueta.Banco, Vector3.new(-56, 5, 46), Color3.fromRGB(212, 175, 55), "Depositar todo", 3, zona)
	local puntos = Instance.new("Folder")
	puntos.Name = "PuntosDeposito"
	puntos.Parent = zona
	local azar = Random.new(1)
	for fila = 0, 5 do
		for col = 0, 7 do
			local x = -52 + col * 15 + azar:NextNumber(-3, 3)
			local z = 58 + fila * 17 + azar:NextNumber(-3, 3)
			local p = parte({ Name = "Punto", Size = Vector3.new(1, 1, 1), Position = Vector3.new(x, 1, z), Transparency = 1, CanCollide = false, CanQuery = false, CanTouch = false }, puntos)
			p:SetAttribute("Zona", 1)
			CollectionService:AddTag(p, Lugares.Etiqueta.PuntoDeposito)
		end
	end
	mapa.Parent = workspace
	return true
end

return ConstructorPrueba
