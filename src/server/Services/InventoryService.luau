-- Services/InventoryService: objetos, minerales y mochila; pico inicial; herramienta «Pico»; saco al morir en PvE.
-- Única puerta para tocar objetos y minerales (C_Tecnico, sección 3).
--
-- API: GetPickaxe(jugador) | AddMineral(jugador, mineral, n) -> entraron | Capacidad(jugador) | Espacio(jugador)
--      RegistrarExtraMochila(nombre, fn)   fn(jugador) -> unidades extra (mascotas, fase 6)
--      AlEquipar(fn)                       fn(jugador, ranura)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Pickaxes = require(Shared.Config.Pickaxes)
local Mining = require(Shared.Config.Mining)
local Mochila = require(Shared.Reglas.Mochila)
local Inventario = require(Shared.Reglas.Inventario)
local Rarezas = require(Shared.Visual.Rarezas)

local InventoryService = {}

local Datos, Stats, Analitica, Red
local extrasMochila = {}
local alEquipar = {}

function InventoryService.NuevoId()
	return string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 12)
end

local function extra(jugador)
	local total = 0
	for _, fn in pairs(extrasMochila) do
		local ok, n = pcall(fn, jugador)
		if ok and type(n) == "number" and n == n then
			total = total + n
		end
	end
	return total
end

function InventoryService.Capacidad(jugador)
	local perfil = Datos.GetProfile(jugador)
	return perfil and Mochila.capacidad(perfil, extra(jugador)) or 0
end

function InventoryService.Espacio(jugador)
	local perfil = Datos.GetProfile(jugador)
	return perfil and Mochila.espacio(perfil, extra(jugador)) or 0
end

function InventoryService.ExtraMochila(jugador)
	return extra(jugador)
end

function InventoryService.RegistrarExtraMochila(nombre, fn)
	extrasMochila[nombre] = fn
end

function InventoryService.AlEquipar(fn)
	table.insert(alEquipar, fn)
end

function InventoryService.GetPickaxe(jugador)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return nil
	end
	return Inventario.equipado(perfil, "Pickaxe")
end

function InventoryService.AddMineral(jugador, mineral, n)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return 0
	end
	return Mochila.anadir(perfil, mineral, n, extra(jugador))
end

-- Herramienta «Pico» que el jugador lleva en la mano para picar.
local function darHerramienta(jugador)
	local pico = InventoryService.GetPickaxe(jugador)
	local mochila = jugador:FindFirstChildOfClass("Backpack") or jugador:WaitForChild("Backpack", 5)
	if not mochila then
		return
	end
	local personaje = jugador.Character
	for _, contenedor in ipairs({ mochila, personaje }) do
		local vieja = contenedor and contenedor:FindFirstChild("Pico")
		if vieja then
			vieja:Destroy()
		end
	end
	if not pico then
		return
	end
	local herramienta = Instance.new("Tool")
	herramienta.Name = "Pico"
	herramienta.CanBeDropped = false
	herramienta.ToolTip = Inventario.nombreBase(pico) .. " (" .. (Rarezas.Nombre[pico.Rarity] or pico.Rarity) .. ")"
	herramienta.GripPos = Vector3.new(0, -1.2, 0)
	local mango = Instance.new("Part")
	mango.Name = "Handle"
	mango.Size = Vector3.new(0.4, 3.2, 0.4)
	mango.Color = Color3.fromRGB(110, 75, 45)
	mango.Material = Enum.Material.Wood
	mango.CanCollide = false
	mango.Massless = true
	mango.Parent = herramienta
	local cabeza = Instance.new("Part")
	cabeza.Name = "Cabeza"
	cabeza.Size = Vector3.new(2.4, 0.5, 0.5)
	cabeza.Color = Rarezas.color(pico.Rarity)
	cabeza.Material = Enum.Material.Metal
	cabeza.CanCollide = false
	cabeza.Massless = true
	cabeza.CFrame = mango.CFrame * CFrame.new(0, 1.5, 0)
	local union = Instance.new("WeldConstraint")
	union.Part0 = mango
	union.Part1 = cabeza
	union.Parent = cabeza
	cabeza.Parent = herramienta
	herramienta.Parent = mochila
end

-- Saco al morir en PvE: solo su dueño lo recoge durante 120 s; después se destruye (B3, sección 8).
local function crearSaco(jugador, posicion, contenido)
	local saco = Instance.new("Part")
	saco.Name = "Saco de " .. jugador.Name
	saco.Size = Vector3.new(2, 2, 2)
	saco.Shape = Enum.PartType.Ball
	saco.Material = Enum.Material.Fabric
	saco.Color = Color3.fromRGB(150, 110, 70)
	saco.Anchored = true
	saco.CanCollide = false
	saco.Position = posicion
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Recoger"
	prompt.ObjectText = "Tu saco"
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = saco
	prompt.Triggered:Connect(function(quien)
		if quien ~= jugador then
			return
		end
		local perfil = Datos.GetProfile(jugador)
		if not perfil then
			return
		end
		local n = Mochila.recogerSaco(perfil, contenido, extra(jugador))
		Datos.Replicar(jugador, "Minerals")
		if next(contenido) == nil then
			saco:Destroy()
		end
		Red:obtener("Notify"):FireClient(jugador, { Text = "Recuperas " .. n .. " unidades del saco" })
	end)
	saco.Parent = workspace
	task.delay(Mining.PvEDeath.RecoverSeconds, function()
		if saco.Parent then
			saco:Destroy()
		end
	end)
end

local function alMorir(jugador, posicion)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	local perdido = Mochila.perdidaMuertePvE(perfil)
	local total = 0
	for _, n in pairs(perdido) do
		total = total + n
	end
	if total > 0 then
		Datos.Replicar(jugador, "Minerals")
		crearSaco(jugador, posicion, perdido)
		Analitica.Registrar(jugador, "MuertePvE", total)
		Red:obtener("Notify"):FireClient(jugador, { Text = "Has perdido " .. total .. " unidades. Tu saco te espera 120 s donde caíste." })
	end
end

local function alCargar(jugador, perfil)
	-- Pico inicial: si no tiene ninguno, se le da el Común de zona 1.
	if not Inventario.tieneDeTipo(perfil, "Pickaxe") then
		local s = Pickaxes.Starter
		local id = InventoryService.NuevoId()
		perfil.Items[id] = Inventario.crearPico(s.Zone, s.Rarity, s.Passives)
		perfil.Equipped.Pickaxe = id
		Datos.Replicar(jugador, "Items", "Equipped")
	elseif perfil.Equipped.Pickaxe == "" then
		for id, item in pairs(perfil.Items) do
			if item.Kind == "Pickaxe" then
				perfil.Equipped.Pickaxe = id
				break
			end
		end
	end
	local function alAparecer(personaje)
		local h = personaje:WaitForChild("Humanoid", 10)
		if not h then
			return
		end
		darHerramienta(jugador)
		h.Died:Connect(function()
			local raiz = personaje:FindFirstChild("HumanoidRootPart")
			alMorir(jugador, raiz and raiz.Position or Vector3.new())
		end)
	end
	jugador.CharacterAdded:Connect(alAparecer)
	if jugador.Character then
		task.spawn(alAparecer, jugador.Character)
	end
end

local function equipar(jugador, id, ranura)
	local perfil = Datos.GetProfile(jugador)
	if Stats.EnCombate(jugador) then
		return false, "en_combate"
	end
	local d = Stats.GetStats(jugador)
	local ok, motivo = Inventario.equipar(perfil, id, ranura, d and d.Effective.Mining or 0)
	if not ok then
		return false, motivo
	end
	Datos.Replicar(jugador, "Equipped")
	if ranura == "Pickaxe" then
		darHerramienta(jugador)
	end
	for _, fn in ipairs(alEquipar) do
		task.spawn(fn, jugador, ranura)
	end
	return true
end

function InventoryService.Iniciar(deps)
	Datos, Stats, Analitica, Red = deps.Datos, deps.Stats, deps.Analitica, deps.Red
	Datos.AlCargar(alCargar)
	Red:conectar("Inventory.Equip", equipar)
end

return InventoryService
