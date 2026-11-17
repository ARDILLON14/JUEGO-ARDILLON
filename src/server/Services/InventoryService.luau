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
local Weapons = require(Shared.Config.Weapons)
local Habilidades = require(Shared.Reglas.Habilidades)
local Nombres = require(Shared.Visual.Nombres)
local Mining = require(Shared.Config.Mining)
local Mochila = require(Shared.Reglas.Mochila)
local Inventario = require(Shared.Reglas.Inventario)
local Rarezas = require(Shared.Visual.Rarezas)

local InventoryService = {}

local Datos, Stats, Analitica, Red
local extrasMochila = {}
local sacos = {}   -- [saco] = { Jugador, Contenido, Recoger = fn }
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

-- Las mascotas recogen solas el saco del dueño si está dentro de su radio (B5 1).
function InventoryService.RecogerSacosCerca(jugador, posicion, radio)
	for saco, s in pairs(sacos) do
		if s.Jugador == jugador and saco.Parent and (saco.Position - posicion).Magnitude <= radio then
			s.Recoger(jugador)
		end
	end
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
	herramienta:SetAttribute("Pico", true)
	herramienta.Parent = mochila
end

-- Herramienta del arma equipada: con ella en la mano, el clic ataca (CombatController).
local function darArma(jugador)
	local perfil = Datos.GetProfile(jugador)
	local arma = perfil and Inventario.equipado(perfil, "Weapon")
	local mochila = jugador:FindFirstChildOfClass("Backpack") or jugador:WaitForChild("Backpack", 5)
	if not mochila then
		return
	end
	for _, contenedor in ipairs({ mochila, jugador.Character }) do
		if contenedor then
			for _, h in ipairs(contenedor:GetChildren()) do
				if h:IsA("Tool") and h:GetAttribute("Arma") then
					h:Destroy()
				end
			end
		end
	end
	if not arma then
		return
	end
	local herramienta = Instance.new("Tool")
	herramienta.Name = Nombres.Arma[arma.Type] or arma.Type
	herramienta.CanBeDropped = false
	herramienta.ToolTip = Inventario.nombreBase(arma) .. " (" .. (Rarezas.Nombre[arma.Rarity] or arma.Rarity) .. ")"
	local largo = ({ Sword = 4, Dagger = 2.2, Staff = 5.5, Axe = 4, Spear = 6.5, Bow = 4 })[arma.Type] or 4
	herramienta.GripPos = Vector3.new(0, -largo / 2 + 0.6, 0)
	local mango = Instance.new("Part")
	mango.Name = "Handle"
	mango.Size = Vector3.new(0.35, largo, 0.35)
	mango.Color = arma.Type == "Staff" and Color3.fromRGB(110, 75, 45) or Rarezas.color(arma.Rarity)
	mango.Material = arma.Type == "Staff" and Enum.Material.Wood or Enum.Material.Metal
	mango.CanCollide = false
	mango.Massless = true
	mango.Parent = herramienta
	if arma.Type == "Staff" then
		local orbe = Instance.new("Part")
		orbe.Name = "Orbe"
		orbe.Shape = Enum.PartType.Ball
		orbe.Size = Vector3.new(0.9, 0.9, 0.9)
		orbe.Material = Enum.Material.Neon
		orbe.Color = Rarezas.color(arma.Rarity)
		orbe.CanCollide = false
		orbe.Massless = true
		orbe.CFrame = mango.CFrame * CFrame.new(0, largo / 2, 0)
		local w = Instance.new("WeldConstraint")
		w.Part0 = mango
		w.Part1 = orbe
		w.Parent = orbe
		orbe.Parent = herramienta
	end
	herramienta:SetAttribute("Arma", arma.Type)
	herramienta.Parent = mochila
end
InventoryService.DarArma = darArma

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
	prompt.KeyboardKeyCode = Enum.KeyCode.R
	prompt.Parent = saco
	local function recoger(quien)
		if quien ~= jugador or not saco.Parent then
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
	end
	prompt.Triggered:Connect(recoger)
	sacos[saco] = { Jugador = jugador, Recoger = recoger }
	saco.Destroying:Connect(function()
		sacos[saco] = nil
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
	end
	-- Arma inicial: si no tiene ninguna, Espada Común de zona 1.
	if not Inventario.tieneDeTipo(perfil, "Weapon") then
		local s = Weapons.Starter
		local id = InventoryService.NuevoId()
		perfil.Items[id] = Inventario.crearArma(s.Type, s.Zone, s.Rarity)
		perfil.Equipped.Weapon = id
		perfil.WeaponMastery[s.Type] = perfil.WeaponMastery[s.Type] or { Level = 1, XP = 0 }
		Datos.Replicar(jugador, "Items", "Equipped", "WeaponMastery")
	end
	for _, ranura in ipairs({ "Pickaxe", "Weapon" }) do
		if perfil.Equipped[ranura] == "" then
			for id, item in pairs(perfil.Items) do
				if item.Kind == ranura then
					perfil.Equipped[ranura] = id
					break
				end
			end
		end
	end
	local function alAparecer(personaje)
		local h = personaje:WaitForChild("Humanoid", 10)
		if not h then
			return
		end
		darHerramienta(jugador)
		darArma(jugador)
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
	if ranura == "Weapon" then
		local item = perfil.Items[id]
		perfil.WeaponMastery[item.Type] = perfil.WeaponMastery[item.Type] or { Level = 1, XP = 0 }
		Habilidades.limpiarReparto(perfil)
		darArma(jugador)
	end
	Datos.Replicar(jugador, "Equipped", "WeaponMastery")
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
