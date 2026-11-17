-- MiningController: picar manteniendo el clic (o el toque) con la herramienta «Pico» en la mano.
-- El cliente solo elige el depósito que tiene bajo el cursor y respeta el ritmo del pico; el servidor lo valida todo.
-- También muestra el botín (Mining.Loot) y, con Sonar rúnico, resalta los depósitos Épicos o mejores cercanos.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pickaxes = require(Shared:WaitForChild("Config"):WaitForChild("Pickaxes"))
local Mining = require(Shared.Config:WaitForChild("Mining"))
local Rarity = require(Shared.Config:WaitForChild("Rarity"))
local Mineria = require(Shared:WaitForChild("Formulas"):WaitForChild("Mineria"))
local Inventario = require(Shared:WaitForChild("Reglas"):WaitForChild("Inventario"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))

local MiningController = {}

local jugador = Players.LocalPlayer
local raton = jugador:GetMouse()
local Estado, avisar
local pulsando = false
local siguiente = 0
local ultimoAvisoLejos = 0
local remoteGolpe

local function picoEquipado()
	local perfil = Estado.Perfil
	if not perfil then
		return nil
	end
	return (Inventario.equipado(perfil, "Pickaxe"))
end

local function depositoBajoCursor()
	local objetivo = raton.Target
	while objetivo and objetivo ~= workspace do
		if objetivo:GetAttribute("DepositoId") then
			return objetivo
		end
		objetivo = objetivo.Parent
	end
	return nil
end

local function enAlcance(parte)
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not raiz then
		return false
	end
	return (raiz.Position - parte.Position).Magnitude <= Mining.Deposit.MaxReach + parte.Size.X / 2
end

local function balancear(herramienta)
	local mango = herramienta:FindFirstChild("Handle")
	if not mango then
		return
	end
	local agarre = herramienta.Grip
	herramienta.Grip = agarre * CFrame.Angles(math.rad(-50), 0, 0)
	task.delay(0.12, function()
		if herramienta.Parent then
			herramienta.Grip = agarre
		end
	end)
end

local function conectarHerramienta(herramienta)
	if not herramienta:IsA("Tool") or herramienta.Name ~= "Pico" then
		return
	end
	herramienta.Activated:Connect(function()
		pulsando = true
	end)
	herramienta.Deactivated:Connect(function()
		pulsando = false
	end)
	herramienta.Unequipped:Connect(function()
		pulsando = false
	end)
end

local function vigilarPersonaje(personaje)
	pulsando = false
	for _, h in ipairs(personaje:GetChildren()) do
		conectarHerramienta(h)
	end
	personaje.ChildAdded:Connect(conectarHerramienta)
end

local function paso()
	if not pulsando then
		return
	end
	local ahora = os.clock()
	if ahora < siguiente then
		return
	end
	local personaje = jugador.Character
	local herramienta = personaje and personaje:FindFirstChild("Pico")
	local pico = picoEquipado()
	if not herramienta or not pico then
		return
	end
	local parte = depositoBajoCursor()
	if not parte then
		return
	end
	if not enAlcance(parte) then
		if ahora - ultimoAvisoLejos > 3 then
			ultimoAvisoLejos = ahora
			avisar({ Text = "Acércate más al depósito", Kind = "Warning", Short = true })
		end
		siguiente = ahora + 0.2
		return
	end
	siguiente = ahora + 1 / Mineria.pickHitsPerSecond(pico.Rarity, 0) + 0.02
	balancear(herramienta)
	remoteGolpe:FireServer(parte:GetAttribute("DepositoId"))
end

-- Sonar rúnico: resalta los depósitos Épicos o mejores a 30 studs (B3, 3.3).
local resaltados = {}
local function sonar()
	local pico = picoEquipado()
	local activo = pico and Inventario.tienePasiva(pico, "RunicSonar")
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	local minimo = Rarity.Multiplier[Pickaxes.PassiveValues.RunicSonarMinRarity]
	for _, parte in ipairs(CollectionService:GetTagged("Deposito")) do
		local rareza = parte:GetAttribute("Rareza")
		local cerca = activo and raiz and (parte.Position - raiz.Position).Magnitude <= Pickaxes.PassiveValues.RunicSonarStuds
		local quiere = cerca and Rarity.Multiplier[rareza] and Rarity.Multiplier[rareza] >= minimo
		if quiere and not resaltados[parte] then
			local h = Instance.new("Highlight")
			h.FillTransparency = 0.7
			h.OutlineColor = Rarezas.color(rareza)
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = parte
			resaltados[parte] = h
		elseif not quiere and resaltados[parte] then
			resaltados[parte]:Destroy()
			resaltados[parte] = nil
		end
	end
	for parte, h in pairs(resaltados) do
		if not parte.Parent then
			h:Destroy()
			resaltados[parte] = nil
		end
	end
end

function MiningController.Iniciar(estado, carpeta, funcionAviso)
	Estado = estado
	avisar = funcionAviso
	remoteGolpe = carpeta:WaitForChild("Mining.Hit")
	carpeta:WaitForChild("Mining.Loot").OnClientEvent:Connect(function(botin)
		local texto = "+" .. tostring(botin.Entered) .. " " .. tostring(botin.Name)
		if botin.Extra then
			texto = texto .. " (Veta abierta)"
		end
		if botin.XP and botin.XP > 0 then
			texto = texto .. "  ·  +" .. tostring(botin.XP) .. " XP"
		end
		avisar({ Text = texto, Color = Rarezas.color(botin.Rarity), Short = true })
		if botin.Respawn then
			avisar({ Text = "¡Eco estelar! El depósito reaparece", Color = Rarezas.color("Celestial") })
		end
	end)
	jugador.CharacterAdded:Connect(vigilarPersonaje)
	if jugador.Character then
		vigilarPersonaje(jugador.Character)
	end
	RunService.Heartbeat:Connect(paso)
	task.spawn(function()
		while true do
			task.wait(0.5)
			sonar()
		end
	end)
end

return MiningController
