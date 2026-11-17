-- CombatController: ataque con el arma en la mano, habilidades Z/X/C/V, dash (Q), bloqueo (F), parpadeo (E),
-- Ruptura (Espacio bajo control), barra de habilidades y números de daño.
-- El cliente solo pide; el servidor valida todo y calcula el daño.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Weapons = require(Config:WaitForChild("Weapons"))
local Stats = require(Config:WaitForChild("Stats"))
local Inventario = require(Shared:WaitForChild("Reglas"):WaitForChild("Inventario"))
local Habilidades = require(Shared.Reglas:WaitForChild("Habilidades"))
local Estadisticas = require(Shared.Reglas:WaitForChild("Estadisticas"))
local Nombres = require(Shared:WaitForChild("Visual"):WaitForChild("Nombres"))

local UI = script.Parent.Parent:WaitForChild("UI")
local Componentes = require(UI:WaitForChild("Componentes"))
local Formato = require(UI:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local CombatController = {}

local jugador = Players.LocalPlayer
local raton = jugador:GetMouse()
local Estado, R, avisar
local pulsando = false
local siguienteAtaque = 0
local comboIndice = 0
local enfriamientos = {}          -- [idHabilidad] = os.clock() en que vuelve a estar lista
local dashCargas, dashRecarga = Stats.Dash.Charges, 0
local casillas = {}
local etiquetaDash

local TECLAS = { [Enum.KeyCode.Z] = "Z", [Enum.KeyCode.X] = "X", [Enum.KeyCode.C] = "C", [Enum.KeyCode.V] = "V" }

local function raiz()
	local p = jugador.Character
	return p and p:FindFirstChild("HumanoidRootPart")
end

local function armaEnMano()
	local p = jugador.Character
	if not p then
		return nil
	end
	for _, h in ipairs(p:GetChildren()) do
		if h:IsA("Tool") and h:GetAttribute("Arma") then
			return h
		end
	end
	return nil
end

local function armaEquipada()
	return Estado.Perfil and (Inventario.equipado(Estado.Perfil, "Weapon")) or nil
end

local function controlado()
	local p = jugador.Character
	local hasta = p and p:GetAttribute("ControladoHasta")
	return hasta ~= nil and workspace:GetServerTimeNow() < hasta
end

-- Dirección hacia el cursor, en horizontal.
local function apuntado()
	local r = raiz()
	if not r then
		return Vector3.new(0, 0, -1)
	end
	local d = raton.Hit.Position - r.Position
	d = Vector3.new(d.X, 0, d.Z)
	if d.Magnitude < 0.1 then
		d = Vector3.new(r.CFrame.LookVector.X, 0, r.CFrame.LookVector.Z)
	end
	return d.Unit
end

-- Objetivos del golpe básico: enemigos al alcance, primero los de delante.
local function objetivos(tipo)
	local r = raiz()
	if not r then
		return {}
	end
	local alcance = Weapons.Types[tipo].Range
	local frente = apuntado()
	local lista = {}
	for _, modelo in ipairs(CollectionService:GetTagged("Enemigo")) do
		local p = modelo.PrimaryPart
		if p and (modelo:GetAttribute("Vida") or 0) > 0 then
			local rel = p.Position - r.Position
			local d = rel.Magnitude - p.Size.X / 2
			if d <= alcance then
				local plano = Vector3.new(rel.X, 0, rel.Z)
				local delante = plano.Magnitude < 0.1 or plano.Unit:Dot(frente) > 0.2
				table.insert(lista, { Id = modelo:GetAttribute("EnemigoId"), D = d, Delante = delante })
			end
		end
	end
	table.sort(lista, function(a, b)
		if a.Delante ~= b.Delante then
			return a.Delante
		end
		return a.D < b.D
	end)
	local ids = {}
	for i = 1, math.min(#lista, Weapons.Types[tipo].MaxTargets) do
		ids[i] = lista[i].Id
	end
	return ids
end

local function balancear(herramienta)
	local agarre = herramienta.Grip
	herramienta.Grip = agarre * CFrame.Angles(math.rad(-70), 0, 0)
	task.delay(0.1, function()
		if herramienta.Parent then
			herramienta.Grip = agarre
		end
	end)
end

local function paso()
	if not pulsando or controlado() then
		return
	end
	local ahora = os.clock()
	if ahora < siguienteAtaque then
		return
	end
	local herramienta = armaEnMano()
	local arma = armaEquipada()
	if not herramienta or not arma or not Estado.Perfil then
		return
	end
	local d = Estadisticas.derivadas(Estado.Perfil)
	siguienteAtaque = ahora + 1 / (Weapons.Types[arma.Type].HitsPerSecond * d.AttackSpeed) + 0.02
	balancear(herramienta)
	local ids = objetivos(arma.Type)
	if #ids > 0 then
		comboIndice = comboIndice % Weapons.ComboHits + 1
		R["Combat.Attack"]:FireServer(ids, comboIndice)
	end
end

local function lanzar(ranura)
	local perfil = Estado.Perfil
	if not perfil or controlado() then
		return
	end
	local id = perfil.Equipped.Loadout[ranura]
	if not id or id == "" then
		avisar({ Text = "La ranura " .. ranura .. " está vacía (tecla K para elegir habilidades)", Short = true })
		return
	end
	local h = Habilidades.buscar(perfil, id)
	if not h then
		return
	end
	local ahora = os.clock()
	if (enfriamientos[id] or 0) > ahora then
		return
	end
	if Estado.Stats.Energy + 0.5 < h.Datos.Energy * 0.9 then
		avisar({ Text = "Sin energía", Kind = "Warning", Short = true })
		return
	end
	enfriamientos[id] = ahora + h.Datos.Cooldown
	R["Combat.Cast"]:FireServer(ranura, apuntado())
end

local function dash()
	local ahora = os.clock()
	while dashCargas < Stats.Dash.Charges and dashRecarga <= ahora do
		dashCargas = dashCargas + 1
		dashRecarga = dashRecarga + Stats.Dash.RechargeSeconds
	end
	if dashCargas < 1 or controlado() then
		return
	end
	if dashCargas == Stats.Dash.Charges then
		dashRecarga = ahora + Stats.Dash.RechargeSeconds
	end
	dashCargas = dashCargas - 1
	local p = jugador.Character
	local h = p and p:FindFirstChildOfClass("Humanoid")
	local dir = h and h.MoveDirection or Vector3.new()
	if dir.Magnitude < 0.1 then
		local cam = workspace.CurrentCamera.CFrame.LookVector
		dir = Vector3.new(cam.X, 0, cam.Z)
	end
	R["Combat.Dash"]:FireServer(dir.Magnitude > 0 and dir.Unit or Vector3.new(0, 0, -1))
end

-- Números de daño flotantes.
local function numero(datos)
	local a = Instance.new("Attachment")
	a.WorldPosition = datos.Pos + Vector3.new(math.random() * 2 - 1, 3, math.random() * 2 - 1)
	a.Parent = workspace.Terrain
	local b = Instance.new("BillboardGui")
	b.Size = UDim2.new(0, 120, 0, 36)
	b.AlwaysOnTop = true
	b.MaxDistance = 120
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextStrokeTransparency = 0.2
	t.Text = Formato.abreviado(datos.Damage) .. (datos.Crit and "!" or "")
	if datos.Own == false and not datos.Crit then
		t.TextColor3 = Color3.fromRGB(255, 90, 90)
	elseif datos.Crit then
		t.TextColor3 = Color3.fromRGB(255, 210, 60)
	else
		t.TextColor3 = Color3.new(1, 1, 1)
	end
	t.Parent = b
	b.Adornee = a
	b.Parent = a
	task.spawn(function()
		for i = 1, 15 do
			a.WorldPosition = a.WorldPosition + Vector3.new(0, 0.12, 0)
			t.TextTransparency = i / 15
			task.wait(0.04)
		end
		a:Destroy()
	end)
end

-- Barra de habilidades -------------------------------------------------
local function crearBarra()
	local pantalla = crear("ScreenGui", { Name = "Habilidades", ResetOnSpawn = false, Parent = jugador:WaitForChild("PlayerGui") })
	local fila = crear("Frame", {
		BackgroundTransparency = 1, Size = UDim2.new(0, 4 * 78 + 110, 0, 72), Position = UDim2.new(0.5, -(4 * 78 + 110) / 2, 1, -92), Parent = pantalla,
	}, { crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Bottom }) })
	for i, ranura in ipairs(Habilidades.Ranuras) do
		local caja = crear("Frame", { BackgroundColor3 = C.Panel, BackgroundTransparency = 0.15, Size = UDim2.new(0, 72, 0, 72), LayoutOrder = i, Parent = fila },
			{ Componentes.esquinas(10), crear("UIStroke", { Color = C.Borde }) })
		Componentes.texto({ Size = UDim2.new(0, 20, 0, 18), Position = UDim2.new(0, 5, 0, 3), Text = ranura, Font = Enum.Font.GothamBlack, TextColor3 = C.XP, Parent = caja })
		local nombre = Componentes.texto({ Size = UDim2.new(1, -8, 0, 40), Position = UDim2.new(0, 4, 0, 22), TextSize = 11, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top, Parent = caja })
		local sombra = crear("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Size = UDim2.fromScale(1, 0), AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1), ZIndex = 3, Parent = caja }, { Componentes.esquinas(10) })
		local cuenta = Componentes.texto({ Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 22, Font = Enum.Font.GothamBlack, ZIndex = 4, Parent = caja })
		casillas[ranura] = { Caja = caja, Nombre = nombre, Sombra = sombra, Cuenta = cuenta }
	end
	local extra = crear("Frame", { BackgroundColor3 = C.Panel, BackgroundTransparency = 0.15, Size = UDim2.new(0, 104, 0, 72), LayoutOrder = 5, Parent = fila },
		{ Componentes.esquinas(10), crear("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }) })
	etiquetaDash = Componentes.texto({ Size = UDim2.new(1, -6, 1, -6), TextSize = 12, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = extra })
end

local function pintarBarra()
	local perfil = Estado.Perfil
	if not perfil then
		return
	end
	local ahora = os.clock()
	for _, ranura in ipairs(Habilidades.Ranuras) do
		local c = casillas[ranura]
		local id = perfil.Equipped.Loadout[ranura]
		if id and id ~= "" then
			c.Nombre.Text = Nombres.Habilidad[id] or id
			local h = Habilidades.buscar(perfil, id)
			local cd = h and h.Datos.Cooldown or 1
			local resto = math.max(0, (enfriamientos[id] or 0) - ahora)
			c.Sombra.Size = UDim2.fromScale(1, math.clamp(resto / cd, 0, 1))
			c.Cuenta.Text = resto > 0 and tostring(math.ceil(resto)) or ""
		else
			c.Nombre.Text = "—"
			c.Sombra.Size = UDim2.fromScale(1, 0)
			c.Cuenta.Text = ""
		end
	end
	while dashCargas < Stats.Dash.Charges and dashRecarga <= ahora do
		dashCargas = dashCargas + 1
		dashRecarga = dashRecarga + Stats.Dash.RechargeSeconds
	end
	local textoParpadeo = Estado.Stats.BlinkUnlocked and "E parpadeo" or "E (Velocidad 50)"
	etiquetaDash.Text = "Q dash: " .. dashCargas .. "/" .. Stats.Dash.Charges .. "\nF bloquear\n" .. textoParpadeo .. "\nK habilidades"
	if controlado() then
		etiquetaDash.Text = "¡Controlado!\nEspacio: Ruptura"
	end
end

function CombatController.Iniciar(estado, carpeta, funcionAviso)
	Estado = estado
	avisar = funcionAviso
	R = {}
	for _, nombre in ipairs({ "Combat.Attack", "Combat.Cast", "Combat.Dash", "Combat.Block", "Combat.Blink", "Combat.Break", "Combat.Hit", "Combat.Rejected" }) do
		R[nombre] = carpeta:WaitForChild(nombre)
	end
	crearBarra()
	R["Combat.Hit"].OnClientEvent:Connect(numero)
	R["Combat.Rejected"].OnClientEvent:Connect(function(datos)
		local perfil = Estado.Perfil
		local id = perfil and datos.Slot and perfil.Equipped.Loadout[datos.Slot]
		if id then
			if datos.Reason == "enfriamiento" and datos.Remaining then
				enfriamientos[id] = os.clock() + datos.Remaining
			else
				enfriamientos[id] = nil
			end
		end
	end)
	local function vigilar(personaje)
		pulsando = false
		personaje.ChildAdded:Connect(function(h)
			if h:IsA("Tool") and h:GetAttribute("Arma") then
				h.Activated:Connect(function()
					pulsando = true
				end)
				h.Deactivated:Connect(function()
					pulsando = false
				end)
				h.Unequipped:Connect(function()
					pulsando = false
				end)
			end
		end)
	end
	jugador.CharacterAdded:Connect(vigilar)
	if jugador.Character then
		vigilar(jugador.Character)
	end
	UserInputService.InputBegan:Connect(function(entrada, procesado)
		if procesado then
			return
		end
		local ranura = TECLAS[entrada.KeyCode]
		if ranura then
			lanzar(ranura)
		elseif entrada.KeyCode == Enum.KeyCode.Q then
			dash()
		elseif entrada.KeyCode == Enum.KeyCode.F then
			R["Combat.Block"]:FireServer(true)
		elseif entrada.KeyCode == Enum.KeyCode.E then
			R["Combat.Blink"]:FireServer(apuntado())
		elseif entrada.KeyCode == Enum.KeyCode.Space and controlado() then
			R["Combat.Break"]:FireServer()
		end
	end)
	UserInputService.InputEnded:Connect(function(entrada)
		if entrada.KeyCode == Enum.KeyCode.F then
			R["Combat.Block"]:FireServer(false)
		end
	end)
	RunService.Heartbeat:Connect(paso)
	RunService.RenderStepped:Connect(pintarBarra)
end

return CombatController
