-- PetsController: dibuja en cada cliente las mascotas de todos los jugadores (atributo «Mascotas» del personaje)
-- y las mueve suavemente detrás de su dueño. Cuando una mascota golpea (Combat.Hit con Pet = true), salta hacia el
-- objetivo y deja un rayo. También la tecla T para cambiar de postura y el resaltado de depósitos de la Luciérnaga.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared:WaitForChild("Config"):WaitForChild("Pets"))
local Rarity = require(Shared.Config:WaitForChild("Rarity"))
local Criadero = require(Shared:WaitForChild("Reglas"):WaitForChild("Criadero"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))

local PetsController = {}

local jugador = Players.LocalPlayer
local Estado, avisar, remotePostura
local dibujadas = {}   -- [dueño] = { Clave, Modelos = { { Parte, Especie } } }

local COLOR_ELEMENTO = {
	Earth = Color3.fromRGB(150, 120, 80), Light = Color3.fromRGB(255, 240, 150), Fire = Color3.fromRGB(255, 120, 60),
	Sound = Color3.fromRGB(150, 130, 200), Water = Color3.fromRGB(80, 170, 230), Ice = Color3.fromRGB(190, 230, 255),
	Crystal = Color3.fromRGB(220, 160, 255), Astral = Color3.fromRGB(120, 110, 255),
}

local function crearMascota(especie, fase, carpeta)
	local e = Pets.Species[especie]
	if not e then
		return nil
	end
	local tam = (fase == "Hatchling") and 1.4 or 2.5
	local cuerpo = Instance.new("Part")
	cuerpo.Name = especie
	cuerpo.Shape = Enum.PartType.Ball
	cuerpo.Size = Vector3.new(tam, tam, tam)
	cuerpo.Color = COLOR_ELEMENTO[e.Element] or Color3.new(1, 1, 1)
	cuerpo.Material = Enum.Material.SmoothPlastic
	cuerpo.Anchored = true
	cuerpo.CanCollide = false
	cuerpo.CanQuery = false
	cuerpo.CanTouch = false
	cuerpo.CastShadow = false
	for _, lado in ipairs({ -1, 1 }) do
		local ojo = Instance.new("Part")
		ojo.Shape = Enum.PartType.Ball
		ojo.Size = Vector3.new(tam * 0.22, tam * 0.22, tam * 0.22)
		ojo.Color = Color3.new(0.05, 0.05, 0.05)
		ojo.Anchored = false
		ojo.CanCollide = false
		ojo.CanQuery = false
		ojo.Massless = true
		ojo.CFrame = cuerpo.CFrame * CFrame.new(lado * tam * 0.2, tam * 0.12, -tam * 0.42)
		local w = Instance.new("WeldConstraint")
		w.Part0 = cuerpo
		w.Part1 = ojo
		w.Parent = ojo
		ojo.Parent = cuerpo
	end
	if (Rarity.Multiplier[e.Rarity] or 1) >= Rarity.Multiplier.Epic or fase ~= "Hatchling" then
		local luz = Instance.new("PointLight")
		luz.Color = Rarezas.color(e.Rarity)
		luz.Range = 8
		luz.Brightness = 1
		luz.Parent = cuerpo
	end
	local aura = Instance.new("SelectionSphere")
	aura.Adornee = cuerpo
	aura.Color3 = Rarezas.color(e.Rarity)
	aura.SurfaceTransparency = 0.85
	aura.Transparency = 0.6
	aura.Parent = cuerpo
	cuerpo.Parent = carpeta
	return cuerpo
end

local carpeta
local function actualizarDueno(dueno)
	local personaje = dueno.Character
	local clave = personaje and personaje:GetAttribute("Mascotas") or ""
	local d = dibujadas[dueno]
	if d and d.Clave == clave then
		return
	end
	if d then
		for _, m in ipairs(d.Modelos) do
			m.Parte:Destroy()
		end
	end
	d = { Clave = clave, Modelos = {} }
	dibujadas[dueno] = d
	if clave == "" then
		return
	end
	for _, trozo in ipairs(string.split(clave, ",")) do
		local partes = string.split(trozo, ":")
		local parte = crearMascota(partes[1], partes[2], carpeta)
		if parte then
			table.insert(d.Modelos, { Parte = parte, Especie = partes[1], Ataque = nil })
		end
	end
end

local function mover(dt)
	local t = os.clock()
	for dueno, d in pairs(dibujadas) do
		local personaje = dueno.Character
		local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
		if raiz and #d.Modelos > 0 then
			local n = #d.Modelos
			for i, m in ipairs(d.Modelos) do
				local ang = math.rad(180 + (i - (n + 1) / 2) * 40)
				local destino = raiz.CFrame * CFrame.new(math.sin(ang) * 5, 1.5 + math.sin(t * 3 + i) * 0.4, -math.cos(ang) * 5)
				if m.Ataque and t < m.Ataque.Hasta then
					destino = CFrame.new(m.Ataque.Pos + Vector3.new(0, 1.5, 0))
				end
				local actual = m.Parte.CFrame
				local mira = CFrame.lookAt(destino.Position, destino.Position + raiz.CFrame.LookVector)
				m.Parte.CFrame = actual:Lerp(mira, math.clamp(dt * 8, 0, 1))
			end
		end
	end
end

-- Golpe de mascota: salta hacia el objetivo y deja un rayo de su color.
local function alGolpe(datos)
	if not datos.Pet then
		return
	end
	local dueno = Players:GetPlayerByUserId(datos.Owner or 0)
	local d = dueno and dibujadas[dueno]
	if not d then
		return
	end
	for _, m in ipairs(d.Modelos) do
		if m.Especie == datos.Species then
			local origen = m.Parte.Position
			m.Ataque = { Pos = datos.Pos, Hasta = os.clock() + 0.18 }
			local fin = datos.Pos
			local rayo = Instance.new("Part")
			rayo.Anchored = true
			rayo.CanCollide = false
			rayo.CanQuery = false
			rayo.Material = Enum.Material.Neon
			rayo.Color = m.Parte.Color
			rayo.Size = Vector3.new(0.25, 0.25, (fin - origen).Magnitude)
			rayo.CFrame = CFrame.lookAt((origen + fin) / 2, fin)
			rayo.Parent = workspace
			TweenService:Create(rayo, TweenInfo.new(0.2), { Transparency = 1 }):Play()
			Debris:AddItem(rayo, 0.2)
			break
		end
	end
end

-- Luciérnaga de Veta: resalta depósitos Épicos o mejores a 40 studs (su pasiva de recolección).
local resaltados = {}
local function revelar()
	local perfil = Estado.Perfil
	local studs = perfil and Criadero.bonos(perfil).RevealDeposits or 0
	local personaje = jugador.Character
	local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
	for _, parte in ipairs(CollectionService:GetTagged("Deposito")) do
		local r = parte:GetAttribute("Tipo") == "Mineral" and parte:GetAttribute("Rareza")
		local quiere = studs > 0 and raiz and r and Rarity.Multiplier[r] >= Rarity.Multiplier.Epic and (parte.Position - raiz.Position).Magnitude <= studs
		if quiere and not resaltados[parte] and not parte:FindFirstChildOfClass("Highlight") then
			local h = Instance.new("Highlight")
			h.Name = "Luciernaga"
			h.FillTransparency = 0.75
			h.OutlineColor = Color3.fromRGB(255, 240, 150)
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = parte
			resaltados[parte] = h
		elseif not quiere and resaltados[parte] then
			resaltados[parte]:Destroy()
			resaltados[parte] = nil
		end
	end
end

function PetsController.Iniciar(estado, carpetaRemotes, funcionAviso)
	Estado = estado
	avisar = funcionAviso
	remotePostura = carpetaRemotes:WaitForChild("Pet.SetStance")
	carpeta = Instance.new("Folder")
	carpeta.Name = "MascotasVisibles"
	carpeta.Parent = workspace
	carpetaRemotes:WaitForChild("Combat.Hit").OnClientEvent:Connect(alGolpe)
	local function vigilar(dueno)
		dueno.CharacterAdded:Connect(function(personaje)
			personaje:GetAttributeChangedSignal("Mascotas"):Connect(function()
				actualizarDueno(dueno)
			end)
			actualizarDueno(dueno)
		end)
		if dueno.Character then
			dueno.Character:GetAttributeChangedSignal("Mascotas"):Connect(function()
				actualizarDueno(dueno)
			end)
			actualizarDueno(dueno)
		end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		vigilar(p)
	end
	Players.PlayerAdded:Connect(vigilar)
	Players.PlayerRemoving:Connect(function(dueno)
		local d = dibujadas[dueno]
		if d then
			for _, m in ipairs(d.Modelos) do
				m.Parte:Destroy()
			end
			dibujadas[dueno] = nil
		end
	end)
	RunService.RenderStepped:Connect(mover)
	UserInputService.InputBegan:Connect(function(entrada, procesado)
		if not procesado and entrada.KeyCode == Enum.KeyCode.T then
			local personaje = jugador.Character
			local actual = personaje and personaje:GetAttribute("PosturaMascotas") or "Protect"
			remotePostura:FireServer(actual == "Gather" and "Protect" or "Gather")
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			revelar()
		end
	end)
end

return PetsController
