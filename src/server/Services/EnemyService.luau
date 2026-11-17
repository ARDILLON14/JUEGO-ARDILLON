-- Services/EnemyService: enemigos de cada zona, su IA sencilla y su vida (B4, sección 7).
-- Puntos de aparición: partes con la etiqueta «PuntoEnemigo» y atributo Zona (los crea el mapa de prueba).
-- La vida se lleva en el servidor; el cliente la ve por atributos (EnemigoId, Tipo, Zona, Vida, VidaMax) y la barra.
--
-- API: Obtener(id) | Danar(id, jugador, cantidad) -> aplicado, muerto | EnRadio(pos, radio) | EnLinea(origen, dir, alcance, ancho)
--      AlMorir(fn) fn(enemigo) | FijarAtaque(fn) fn(jugador, dano, enemigo) (lo pone CombatService)
--      PonerEstado(id, nombre, segundos, datos) | Empujar(id, desde, studs) | Aturdir(id, segundos)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Weapons = require(Shared.Config.Weapons)
local Dano = require(Shared.Formulas.Dano)
local Suerte = require(Shared.Formulas.Suerte)
local Nombres = require(Shared.Visual.Nombres)
local Server = script.Parent.Parent
local Combate = require(Server.Reglas.Combate)
local Lugares = require(Server.Util.Lugares)

local EnemyService = {}

local E = Weapons.Enemies
local AI = E.AI
local TIPOS = { "Common", "Elite", "Guardian" }
local ASPECTO = {
	Common = { Color = Color3.fromRGB(120, 100, 85), Tam = Vector3.new(3, 4, 2.4) },
	Elite = { Color = Color3.fromRGB(120, 70, 150), Tam = Vector3.new(3.6, 4.8, 2.8) },
	Guardian = { Color = Color3.fromRGB(200, 160, 60), Tam = Vector3.new(4.6, 6, 3.4) },
}

local azar = Random.new()
local enemigos = {}           -- [id] = { Id, Tipo, Zona, Vida, VidaMax, Modelo, Raiz, Humanoide, Origen, Danos, Estados, Control, ProximoAtaque, Objetivo, Barra }
local zonas = {}              -- [zona] = { Puntos = { parte }, Vivos = n, Pendientes = n }
local siguienteId = 0
local alMorir = {}
local atacar = function() end
local carpeta

local function aleatorio()
	return azar:NextNumber()
end

local function crearModelo(e, posicion)
	local a = ASPECTO[e.Tipo]
	local modelo = Instance.new("Model")
	modelo.Name = Nombres.Enemigo[e.Tipo] or e.Tipo
	local raiz = Instance.new("Part")
	raiz.Name = "HumanoidRootPart"
	raiz.Size = a.Tam
	raiz.Color = a.Color
	raiz.Material = Enum.Material.Slate
	raiz.CFrame = CFrame.new(posicion + Vector3.new(0, a.Tam.Y / 2 + 1, 0))
	raiz.Parent = modelo
	local cabeza = Instance.new("Part")
	cabeza.Name = "Cabeza"
	cabeza.Shape = Enum.PartType.Ball
	cabeza.Size = Vector3.new(a.Tam.X * 0.7, a.Tam.X * 0.7, a.Tam.X * 0.7)
	cabeza.Color = a.Color:Lerp(Color3.new(1, 1, 1), 0.15)
	cabeza.Material = Enum.Material.Rock
	cabeza.CanCollide = false
	cabeza.Massless = true
	cabeza.CFrame = raiz.CFrame * CFrame.new(0, a.Tam.Y / 2 + cabeza.Size.Y * 0.35, 0)
	local w = Instance.new("WeldConstraint")
	w.Part0 = raiz
	w.Part1 = cabeza
	w.Parent = cabeza
	cabeza.Parent = modelo
	for _, lado in ipairs({ -1, 1 }) do
		local ojo = Instance.new("Part")
		ojo.Name = "Ojo"
		ojo.Size = Vector3.new(0.4, 0.4, 0.2)
		ojo.Material = Enum.Material.Neon
		ojo.Color = e.Tipo == "Common" and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(255, 70, 70)
		ojo.CanCollide = false
		ojo.Massless = true
		ojo.CFrame = cabeza.CFrame * CFrame.new(lado * cabeza.Size.X * 0.2, 0.1, -cabeza.Size.Z * 0.45)
		local wo = Instance.new("WeldConstraint")
		wo.Part0 = cabeza
		wo.Part1 = ojo
		wo.Parent = ojo
		ojo.Parent = modelo
	end
	local h = Instance.new("Humanoid")
	h.HipHeight = 1
	h.WalkSpeed = AI.WalkSpeed
	h.MaxHealth = 1e9
	h.Health = 1e9
	h.BreakJointsOnDeath = false
	h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	h.Parent = modelo
	modelo.PrimaryPart = raiz

	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.new(0, 150, 0, 32)
	cartel.StudsOffset = Vector3.new(0, a.Tam.Y / 2 + 2.2, 0)
	cartel.MaxDistance = 80
	local nombre = Instance.new("TextLabel")
	nombre.BackgroundTransparency = 1
	nombre.Size = UDim2.new(1, 0, 0, 16)
	nombre.Font = Enum.Font.GothamBold
	nombre.TextScaled = true
	nombre.TextColor3 = e.Tipo == "Common" and Color3.new(1, 1, 1) or a.Color:Lerp(Color3.new(1, 1, 1), 0.4)
	nombre.TextStrokeTransparency = 0.3
	nombre.Text = modelo.Name
	nombre.Parent = cartel
	local fondo = Instance.new("Frame")
	fondo.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	fondo.BorderSizePixel = 0
	fondo.Position = UDim2.new(0.1, 0, 0, 20)
	fondo.Size = UDim2.new(0.8, 0, 0, 7)
	fondo.Parent = cartel
	local barra = Instance.new("Frame")
	barra.BackgroundColor3 = Color3.fromRGB(214, 64, 69)
	barra.BorderSizePixel = 0
	barra.Size = UDim2.fromScale(1, 1)
	barra.Parent = fondo
	cartel.Parent = raiz

	modelo:SetAttribute("EnemigoId", e.Id)
	modelo:SetAttribute("Tipo", e.Tipo)
	modelo:SetAttribute("Zona", e.Zona)
	modelo:SetAttribute("Vida", e.Vida)
	modelo:SetAttribute("VidaMax", e.VidaMax)
	CollectionService:AddTag(modelo, "Enemigo")
	modelo.Parent = carpeta
	pcall(function()
		raiz:SetNetworkOwner(nil)
	end)
	e.Modelo, e.Raiz, e.Humanoide, e.Barra = modelo, raiz, h, barra
end

local function crear(zona, tipo, posicion)
	siguienteId = siguienteId + 1
	local vida = Dano.enemyHealth(zona, tipo)
	local e = {
		Id = siguienteId, Tipo = tipo, Zona = zona, Vida = vida, VidaMax = vida, Origen = posicion,
		Danos = {}, Estados = {}, Control = Combate.nuevoControl(), ProximoAtaque = 0, Objetivo = nil,
	}
	crearModelo(e, posicion)
	enemigos[e.Id] = e
	zonas[zona].Vivos = zonas[zona].Vivos + 1
	return e
end

local function aparecerGrupo(zona)
	local z = zonas[zona]
	if #z.Puntos == 0 then
		return
	end
	local punto = z.Puntos[azar:NextInteger(1, #z.Puntos)]
	local tam = tonumber(Suerte.pickWeighted(E.PackWeights, { 1, 2, 3 }, aleatorio())) or 1
	for i = 1, tam do
		local pesos = { Common = E.Common.Share, Elite = E.Elite.Share, Guardian = E.Guardian.Share }
		local tipo = Suerte.pickWeighted(pesos, TIPOS, aleatorio())
		local desvio = i == 1 and Vector3.new() or Vector3.new(azar:NextNumber(-6, 6), 0, azar:NextNumber(-6, 6))
		crear(zona, tipo, punto.Position + desvio)
	end
end

local function jugadorMasCercano(pos, radio)
	local mejor, dist = nil, radio
	for _, jugador in ipairs(Players:GetPlayers()) do
		local p = Lugares.posicion(jugador)
		if p then
			local d = (p - pos).Magnitude
			if d <= dist then
				mejor, dist = jugador, d
			end
		end
	end
	return mejor, dist
end

local function pensar(e, ahora)
	if not e.Raiz or not e.Raiz.Parent then
		return
	end
	local pos = e.Raiz.Position
	if Combate.controlado(e.Control, ahora) then
		e.Humanoide.WalkSpeed = 0
		return
	end
	e.Humanoide.WalkSpeed = AI.WalkSpeed * (1 - Combate.lentitud(e.Estados, ahora))
	local lejosDeCasa = (pos - e.Origen).Magnitude > AI.LeashRadius
	local objetivo = e.Objetivo
	local posObjetivo = objetivo and Lugares.posicion(objetivo)
	if lejosDeCasa or not posObjetivo or (posObjetivo - pos).Magnitude > AI.AggroRadius * 1.5 then
		objetivo, posObjetivo = nil, nil
	end
	if not objetivo then
		objetivo = jugadorMasCercano(pos, AI.AggroRadius)
		posObjetivo = objetivo and Lugares.posicion(objetivo)
	end
	e.Objetivo = objetivo
	if lejosDeCasa or not objetivo then
		if (pos - e.Origen).Magnitude > 3 then
			e.Humanoide:MoveTo(e.Origen)
		end
		if lejosDeCasa then
			e.Vida = e.VidaMax   -- vuelve a casa y se cura: no se puede arrastrar lejos para matarlo gratis
			e.Danos = {}
			e.Modelo:SetAttribute("Vida", e.Vida)
			e.Barra.Size = UDim2.fromScale(1, 1)
		end
		return
	end
	local distancia = (posObjetivo - pos).Magnitude
	if distancia > AI.AttackRange then
		e.Humanoide:MoveTo(posObjetivo)
	else
		e.Humanoide:MoveTo(pos)
		e.Raiz.CFrame = CFrame.lookAt(pos, Vector3.new(posObjetivo.X, pos.Y, posObjetivo.Z))
		if ahora >= e.ProximoAtaque then
			e.ProximoAtaque = ahora + E[e.Tipo].Interval
			task.spawn(atacar, objetivo, Dano.enemyDamage(e.Zona, e.Tipo), e)
		end
	end
end

function EnemyService.Iniciar()
	carpeta = Instance.new("Folder")
	carpeta.Name = "Enemigos"
	carpeta.Parent = workspace
	for _, punto in ipairs(CollectionService:GetTagged("PuntoEnemigo")) do
		local zona = punto:GetAttribute("Zona")
		if punto:IsA("BasePart") and type(zona) == "number" then
			zonas[zona] = zonas[zona] or { Puntos = {}, Vivos = 0, Pendientes = 0 }
			table.insert(zonas[zona].Puntos, punto)
		end
	end
	for zona, z in pairs(zonas) do
		print(string.format("OREBOUND: zona %d con %d puntos de enemigos", zona, #z.Puntos))
	end
	task.spawn(function()
		while true do
			for zona, z in pairs(zonas) do
				if z.Vivos + z.Pendientes < AI.AlivePerZone then
					aparecerGrupo(zona)
				end
			end
			task.wait(1)
		end
	end)
	task.spawn(function()
		while true do
			local ahora = os.clock()
			for _, e in pairs(enemigos) do
				pensar(e, ahora)
			end
			task.wait(0.2)
		end
	end)
end

function EnemyService.Obtener(id)
	return enemigos[id]
end

function EnemyService.AlMorir(fn)
	table.insert(alMorir, fn)
end

function EnemyService.FijarAtaque(fn)
	atacar = fn
end

function EnemyService.Danar(id, jugador, cantidad)
	local e = enemigos[id]
	if not e or e.Vida <= 0 or cantidad <= 0 then
		return 0, false
	end
	local aplicado = math.min(cantidad, e.Vida)
	e.Vida = e.Vida - aplicado
	e.Danos[jugador.UserId] = (e.Danos[jugador.UserId] or 0) + aplicado
	e.Objetivo = e.Objetivo or jugador
	e.Modelo:SetAttribute("Vida", e.Vida)
	e.Barra.Size = UDim2.fromScale(math.clamp(e.Vida / e.VidaMax, 0, 1), 1)
	if e.Vida > 0 then
		return aplicado, false
	end
	enemigos[id] = nil
	local z = zonas[e.Zona]
	z.Vivos = z.Vivos - 1
	z.Pendientes = z.Pendientes + 1
	for _, fn in ipairs(alMorir) do
		local ok, err = pcall(fn, e)
		if not ok then
			warn("EnemyService: " .. tostring(err))
		end
	end
	for _, p in ipairs(e.Modelo:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.Transparency = 0.6
		end
	end
	task.delay(0.6, function()
		e.Modelo:Destroy()
	end)
	task.delay(AI.RespawnSeconds, function()
		z.Pendientes = z.Pendientes - 1
	end)
	return aplicado, true
end

-- Enemigos vivos a menos de radio studs de pos, del más cercano al más lejano.
function EnemyService.EnRadio(pos, radio)
	local lista = {}
	for _, e in pairs(enemigos) do
		if e.Raiz and (e.Raiz.Position - pos).Magnitude <= radio + e.Raiz.Size.X / 2 then
			table.insert(lista, e)
		end
	end
	table.sort(lista, function(a, b)
		return (a.Raiz.Position - pos).Magnitude < (b.Raiz.Position - pos).Magnitude
	end)
	return lista
end

-- Enemigos en una franja recta (proyectiles y estocadas), del más cercano al más lejano.
function EnemyService.EnLinea(origen, direccion, alcance, ancho)
	local lista = {}
	for _, e in pairs(enemigos) do
		if e.Raiz then
			local rel = e.Raiz.Position - origen
			local a = rel:Dot(direccion)
			if a >= 0 and a <= alcance + e.Raiz.Size.X / 2 then
				local lateral = (rel - direccion * a).Magnitude
				if lateral <= ancho + e.Raiz.Size.X / 2 then
					table.insert(lista, { Enemigo = e, Distancia = a })
				end
			end
		end
	end
	table.sort(lista, function(x, y)
		return x.Distancia < y.Distancia
	end)
	local salida = {}
	for i, x in ipairs(lista) do
		salida[i] = x.Enemigo
	end
	return salida
end

function EnemyService.PonerEstado(id, nombre, segundos, datos)
	local e = enemigos[id]
	if e then
		Combate.ponerEstado(e.Estados, nombre, os.clock(), segundos, datos)
	end
end

function EnemyService.Aturdir(id, segundos)
	local e = enemigos[id]
	if e then
		return Combate.aplicarControl(e.Control, os.clock(), segundos)
	end
	return 0
end

function EnemyService.Empujar(id, desde, studs)
	local e = enemigos[id]
	if not e or not e.Raiz then
		return
	end
	local dir = e.Raiz.Position - desde
	dir = Vector3.new(dir.X, 0, dir.Z)
	if dir.Magnitude < 0.01 then
		return
	end
	e.Raiz.CFrame = e.Raiz.CFrame + dir.Unit * studs
end

return EnemyService
