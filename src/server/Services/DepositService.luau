-- Services/DepositService: crea, daña y regenera los depósitos de cada zona (B3, sección 5).
-- Los depósitos son compartidos: todos ven los mismos. Su estado llega al cliente por atributos de la parte
-- (DepositoId, Rareza, Mineral, Zona, Vida, VidaMax), que Roblox replica solo; así no hace falta el Remote
-- Mining.DepositState de C_Tecnico.
--
-- API: Obtener(id) | Danar(id, userId, cantidad) -> aplicado, agotado | Cercanos(id, radio) | RegistrarMinero(jugador, zona)
--      AlAgotar(fn)   fn(entrada, aleatorio) se llama una vez por depósito agotado, antes de quitarlo

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Rarezas = require(Shared.Visual.Rarezas)
local Server = script.Parent.Parent
local Deposito = require(Server.Reglas.Deposito)
local Generador = require(Server.Reglas.Generador)
local Lugares = require(Server.Util.Lugares)

local DepositService = {}

local Stats
local azar = Random.new()
local zonas = {}          -- [zona] = { Puntos = { parte }, Ocupado = { [parte] = id }, Regenera = { [parte] = os.clock() } }
local depositos = {}      -- [id] = { Regla, Parte, Punto, Zona, Barra }
local mineros = {}        -- [zona] = { [jugador] = os.clock() del último golpe }
local alAgotar = {}
local siguienteId = 0
local carpeta

local function nuevoId()
	siguienteId = siguienteId + 1
	return siguienteId
end

local function crearParte(regla, punto)
	local tam = Rarezas.TamanoDeposito[regla.Rarity] or 4
	local p = Instance.new("Part")
	p.Name = "Deposito"
	p.Anchored = true
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(tam, tam * 0.8, tam)
	p.Material = Enum.Material.Rock
	p.Color = Rarezas.color(regla.Rarity)
	p.CFrame = CFrame.new(punto.Position + Vector3.new(0, tam * 0.35, 0)) * CFrame.Angles(0, azar:NextNumber(0, math.pi * 2), 0)
	p:SetAttribute("DepositoId", regla.Id)
	p:SetAttribute("Rareza", regla.Rarity)
	p:SetAttribute("Mineral", regla.Mineral)
	p:SetAttribute("Zona", regla.Zone)
	p:SetAttribute("Vida", regla.Health)
	p:SetAttribute("VidaMax", regla.MaxHealth)
	if regla.Rarity ~= "Common" and regla.Rarity ~= "Uncommon" and regla.Rarity ~= "Rare" then
		local luz = Instance.new("PointLight")
		luz.Color = p.Color
		luz.Range = 10 + tam
		luz.Brightness = 1.5
		luz.Parent = p
	end
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.new(0, 160, 0, 34)
	cartel.StudsOffset = Vector3.new(0, tam * 0.6 + 1, 0)
	cartel.MaxDistance = 60
	local nombre = Instance.new("TextLabel")
	nombre.BackgroundTransparency = 1
	nombre.Size = UDim2.new(1, 0, 0, 18)
	nombre.Font = Enum.Font.GothamBold
	nombre.TextScaled = true
	nombre.TextColor3 = p.Color
	nombre.TextStrokeTransparency = 0.2
	local m = Mining.Minerals[regla.Mineral]
	nombre.Text = (m and m.Name or regla.Mineral) .. " · " .. (Rarezas.Nombre[regla.Rarity] or regla.Rarity)
	nombre.Parent = cartel
	local fondo = Instance.new("Frame")
	fondo.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	fondo.BorderSizePixel = 0
	fondo.Position = UDim2.new(0.1, 0, 0, 22)
	fondo.Size = UDim2.new(0.8, 0, 0, 8)
	fondo.Parent = cartel
	local barra = Instance.new("Frame")
	barra.BackgroundColor3 = Color3.fromRGB(120, 220, 120)
	barra.BorderSizePixel = 0
	barra.Size = UDim2.fromScale(1, 1)
	barra.Parent = fondo
	cartel.Parent = p
	CollectionService:AddTag(p, Lugares.Etiqueta.Deposito)
	p.Parent = carpeta
	return p, barra
end

local function suerteMedia(zona)
	local total, n = 0, 0
	local ahora = os.clock()
	for jugador, momento in pairs(mineros[zona] or {}) do
		if ahora - momento <= Mining.MinerWindowSeconds and jugador.Parent then
			local d = Stats.GetStats(jugador)
			if d then
				total = total + d.Effective.Luck
				n = n + 1
			end
		end
	end
	return n > 0 and total / n or 0, n
end

local function aparecer(zona, punto)
	local suerte = suerteMedia(zona)
	local rareza = Generador.rareza(zona, suerte, azar:NextNumber())
	local mineral = Generador.mineral(zona, rareza)
	if not mineral then
		return
	end
	local id = nuevoId()
	local regla = Deposito.nuevo(id, zona, rareza, mineral)
	local parte, barra = crearParte(regla, punto)
	depositos[id] = { Regla = regla, Parte = parte, Punto = punto, Zona = zona, Barra = barra }
	zonas[zona].Ocupado[punto] = id
end

local function activos(z)
	local n = 0
	for _ in pairs(z.Ocupado) do
		n = n + 1
	end
	return n
end

local function rellenarZona(zona)
	local z = zonas[zona]
	local _, presentes = suerteMedia(zona)
	local objetivo = Generador.activos(presentes, #z.Puntos)
	local ahora = os.clock()
	local libres = {}
	for _, punto in ipairs(z.Puntos) do
		if not z.Ocupado[punto] and ahora >= (z.Regenera[punto] or 0) then
			table.insert(libres, punto)
		end
	end
	local faltan = objetivo - activos(z)
	while faltan > 0 and #libres > 0 do
		local i = azar:NextInteger(1, #libres)
		aparecer(zona, libres[i])
		table.remove(libres, i)
		faltan = faltan - 1
	end
end

local function quitar(id, alInstante)
	local e = depositos[id]
	if not e then
		return
	end
	depositos[id] = nil
	local z = zonas[e.Zona]
	z.Ocupado[e.Punto] = nil
	z.Regenera[e.Punto] = os.clock() + (alInstante and 0 or Generador.regeneracion())
	e.Parte:Destroy()
	if alInstante then
		aparecer(e.Zona, e.Punto)
	end
end

function DepositService.Iniciar(deps)
	Stats = deps.Stats
	carpeta = Instance.new("Folder")
	carpeta.Name = "Depositos"
	carpeta.Parent = workspace
	for _, punto in ipairs(CollectionService:GetTagged(Lugares.Etiqueta.PuntoDeposito)) do
		local zona = punto:GetAttribute("Zona")
		if punto:IsA("BasePart") and type(zona) == "number" and zona >= 1 and zona <= 10 and zona == math.floor(zona) then
			zonas[zona] = zonas[zona] or { Puntos = {}, Ocupado = {}, Regenera = {} }
			table.insert(zonas[zona].Puntos, punto)
		end
	end
	for zona, z in pairs(zonas) do
		mineros[zona] = {}
		print(string.format("OREBOUND: zona %d con %d puntos de depósito", zona, #z.Puntos))
	end
	Players.PlayerRemoving:Connect(function(jugador)
		for _, m in pairs(mineros) do
			m[jugador] = nil
		end
	end)
	task.spawn(function()
		while true do
			for zona in pairs(zonas) do
				rellenarZona(zona)
			end
			task.wait(1)
		end
	end)
end

function DepositService.Obtener(id)
	return depositos[id]
end

function DepositService.AlAgotar(fn)
	table.insert(alAgotar, fn)
end

-- Aplica daño. Si se agota, avisa a los AlAgotar y lo quita (o lo hace reaparecer si alguno lo pide).
function DepositService.Danar(id, userId, cantidad)
	local e = depositos[id]
	if not e then
		return 0, false
	end
	local aplicado, agotado = Deposito.golpear(e.Regla, userId, cantidad)
	e.Parte:SetAttribute("Vida", e.Regla.Health)
	e.Barra.Size = UDim2.fromScale(math.clamp(e.Regla.Health / e.Regla.MaxHealth, 0, 1), 1)
	if agotado then
		local reaparece = false
		for _, fn in ipairs(alAgotar) do
			local ok, r = pcall(fn, e, function()
				return azar:NextNumber()
			end)
			if ok and r == true then
				reaparece = true
			elseif not ok then
				warn("DepositService: " .. tostring(r))
			end
		end
		quitar(id, reaparece)
	end
	return aplicado, agotado
end

-- Otros depósitos activos a menos de radio studs de este (para Eco del filo y Onda sísmica).
function DepositService.Cercanos(id, radio)
	local e = depositos[id]
	local lista = {}
	if not e then
		return lista
	end
	local origen = e.Parte.Position
	for otroId, otro in pairs(depositos) do
		if otroId ~= id and otro.Zona == e.Zona and (otro.Parte.Position - origen).Magnitude <= radio then
			table.insert(lista, otroId)
		end
	end
	table.sort(lista, function(a, b)
		return (depositos[a].Parte.Position - origen).Magnitude < (depositos[b].Parte.Position - origen).Magnitude
	end)
	return lista
end

function DepositService.RegistrarMinero(jugador, zona)
	if mineros[zona] then
		mineros[zona][jugador] = os.clock()
	end
end

return DepositService
