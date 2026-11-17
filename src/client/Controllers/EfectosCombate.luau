-- EfectosCombate: sensación de golpe en el cliente (P4b). Nada de esto decide daño: solo se ve.
--   brazo que golpea (derecha, izquierda y remate por arriba), tajo de luz, paso adelante, temblor de cámara,
--   destello y chispas en el enemigo golpeado, estela del dash, aviso rojo de los enemigos que van a golpear
--   y contador de combo. Las animaciones son por código (sin archivos de animación subidos a Roblox):
--   el brazo solo lo ve el propio jugador; tajos y chispas también son locales.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local EfectosCombate = {}

local jugador = Players.LocalPlayer
local temblor = 0
local contador, ultimoGolpe = 0, 0
local etiquetaCombo

local function personaje()
	return jugador.Character
end

local function hombro(lado)
	local p = personaje()
	if not p then
		return nil
	end
	local brazo = p:FindFirstChild(lado == "R" and "RightUpperArm" or "LeftUpperArm")
	if brazo then
		return brazo:FindFirstChild(lado == "R" and "RightShoulder" or "LeftShoulder")
	end
	local torso = p:FindFirstChild("Torso")
	return torso and torso:FindFirstChild(lado == "R" and "Right Shoulder" or "Left Shoulder")
end

local originales = {}
local function moverBrazo(lado, angulos, ida, vuelta)
	local m = hombro(lado)
	if not m then
		return
	end
	originales[m] = originales[m] or m.C0
	local base = originales[m]
	local t1 = TweenService:Create(m, TweenInfo.new(ida, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { C0 = base * angulos })
	t1:Play()
	task.delay(ida, function()
		TweenService:Create(m, TweenInfo.new(vuelta, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { C0 = base }):Play()
	end)
end

local function neon(tam, cf, color, transparencia, vida)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = transparencia
	p.Size = tam
	p.CFrame = cf
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(vida), { Transparency = 1, Size = tam * 1.15 }):Play()
	Debris:AddItem(p, vida)
	return p
end

-- Golpe básico n.º «indice» del combo (1 a 4). color = color de la rareza del arma; alcance en studs.
function EfectosCombate.ataque(indice, color, alcance)
	local p = personaje()
	local raiz = p and p:FindFirstChild("HumanoidRootPart")
	if not raiz then
		return
	end
	local remate = indice % 4 == 0
	if remate then
		moverBrazo("R", CFrame.Angles(math.rad(-150), 0, 0), 0.08, 0.18)
	elseif indice % 2 == 1 then
		moverBrazo("R", CFrame.Angles(math.rad(-60), math.rad(-70), 0), 0.06, 0.12)
	else
		moverBrazo("R", CFrame.Angles(math.rad(-60), math.rad(70), 0), 0.06, 0.12)
	end
	-- Tajo: varias láminas finas en arco delante del personaje.
	local frente = raiz.CFrame
	local radio = math.max(3, (alcance or 6) * 0.7)
	local tramos = 5
	for i = 0, tramos - 1 do
		local ang
		if remate then
			ang = CFrame.Angles(math.rad(-60 + i * 30), 0, 0)
		else
			local s = indice % 2 == 1 and 1 or -1
			ang = CFrame.Angles(0, math.rad(s * (60 - i * 30)), math.rad(s * 20))
		end
		local cf = frente * ang * CFrame.new(0, 0.5, -radio)
		neon(Vector3.new(remate and 0.25 or radio * 0.55, remate and radio * 0.55 or 0.25, 0.1), cf, color, 0.25, 0.18)
	end
	-- Pequeño paso adelante (el propio cliente mueve su personaje).
	raiz.AssemblyLinearVelocity = raiz.AssemblyLinearVelocity + raiz.CFrame.LookVector * (remate and 26 or 14)
	if remate then
		EfectosCombate.temblar(0.25)
	end
end

-- Se puede desactivar en Ajustes (accesibilidad, VFX.Accessibility.CameraShake).
EfectosCombate.TemblorActivo = true

function EfectosCombate.temblar(fuerza)
	if not EfectosCombate.TemblorActivo then
		return
	end
	temblor = math.max(temblor, fuerza)
end

-- Impacto: destello blanco en el enemigo más cercano a la posición, chispas, temblor y contador de combo.
function EfectosCombate.impacto(datos)
	local mejor, dist = nil, 6
	for _, modelo in ipairs(CollectionService:GetTagged("Enemigo")) do
		local r = modelo.PrimaryPart
		if r and (r.Position - datos.Pos).Magnitude < dist then
			mejor, dist = modelo, (r.Position - datos.Pos).Magnitude
		end
	end
	if mejor then
		local h = Instance.new("Highlight")
		h.FillColor = Color3.new(1, 1, 1)
		h.FillTransparency = 0.2
		h.OutlineTransparency = 1
		h.DepthMode = Enum.HighlightDepthMode.Occluded
		h.Parent = mejor
		Debris:AddItem(h, 0.08)
	end
	for _ = 1, datos.Crit and 9 or 5 do
		local dir = Vector3.new(math.random() - 0.5, math.random() * 0.8, math.random() - 0.5).Unit
		local p = neon(Vector3.new(0.2, 0.2, 0.9), CFrame.lookAt(datos.Pos, datos.Pos + dir), datos.Crit and Color3.fromRGB(255, 210, 60) or Color3.fromRGB(255, 240, 200), 0, 0.22)
		TweenService:Create(p, TweenInfo.new(0.22), { CFrame = p.CFrame + dir * 4 }):Play()
	end
	if datos.Pet then
		return   -- los golpes de mascotas no hacen temblar ni cuentan para el combo
	end
	if datos.Own then
		EfectosCombate.temblar(datos.Crit and 0.35 or 0.12)
		local ahora = os.clock()
		if ahora - ultimoGolpe > 2.5 then
			contador = 0
		end
		contador = contador + 1
		ultimoGolpe = ahora
		if etiquetaCombo and contador >= 3 then
			etiquetaCombo.Text = "x" .. contador
			etiquetaCombo.TextTransparency = 0
			etiquetaCombo.TextStrokeTransparency = 0.2
			etiquetaCombo.Size = UDim2.fromOffset(170, 70)
			TweenService:Create(etiquetaCombo, TweenInfo.new(0.15), { Size = UDim2.fromOffset(140, 56) }):Play()
		end
	elseif datos.Own == false then
		EfectosCombate.temblar(0.3)   -- daño recibido
	end
end

-- Estela del dash: copias fantasma del personaje que se desvanecen.
function EfectosCombate.estela()
	local p = personaje()
	if not p then
		return
	end
	for paso = 0, 3 do
		task.delay(paso * 0.04, function()
			for _, parte in ipairs(p:GetChildren()) do
				if parte:IsA("BasePart") and parte.Transparency < 1 and parte.Name ~= "HumanoidRootPart" then
					neon(parte.Size, parte.CFrame, Color3.fromRGB(150, 220, 255), 0.55, 0.25)
				end
			end
		end)
	end
end

-- Aviso rojo de los enemigos que están a punto de golpear (atributo «Preparando» del servidor).
local function vigilarEnemigo(modelo)
	modelo:GetAttributeChangedSignal("Preparando"):Connect(function()
		local resaltado = modelo:FindFirstChild("AvisoGolpe")
		if modelo:GetAttribute("Preparando") then
			if not resaltado then
				resaltado = Instance.new("Highlight")
				resaltado.Name = "AvisoGolpe"
				resaltado.FillColor = Color3.fromRGB(255, 40, 40)
				resaltado.FillTransparency = 0.45
				resaltado.OutlineColor = Color3.fromRGB(255, 80, 80)
				resaltado.Parent = modelo
			end
		elseif resaltado then
			resaltado:Destroy()
		end
	end)
end

function EfectosCombate.Iniciar()
	for _, m in ipairs(CollectionService:GetTagged("Enemigo")) do
		vigilarEnemigo(m)
	end
	CollectionService:GetInstanceAddedSignal("Enemigo"):Connect(vigilarEnemigo)
	jugador.CharacterAdded:Connect(function()
		originales = {}
	end)

	local pantalla = Instance.new("ScreenGui")
	pantalla.Name = "Combo"
	pantalla.ResetOnSpawn = false
	pantalla.Parent = jugador:WaitForChild("PlayerGui")
	etiquetaCombo = Instance.new("TextLabel")
	etiquetaCombo.BackgroundTransparency = 1
	etiquetaCombo.AnchorPoint = Vector2.new(0.5, 0.5)
	etiquetaCombo.Position = UDim2.new(0.78, 0, 0.42, 0)
	etiquetaCombo.Size = UDim2.fromOffset(140, 56)
	etiquetaCombo.Font = Enum.Font.GothamBlack
	etiquetaCombo.TextScaled = true
	etiquetaCombo.TextColor3 = Color3.fromRGB(255, 200, 70)
	etiquetaCombo.TextTransparency = 1
	etiquetaCombo.TextStrokeTransparency = 1
	etiquetaCombo.Rotation = -6
	etiquetaCombo.Parent = pantalla

	-- Después de la cámara de Roblox, para que el temblor no se pierda.
	RunService:BindToRenderStep("TemblorCombate", Enum.RenderPriority.Camera.Value + 1, function(dt)
		if temblor > 0.001 then
			local cam = workspace.CurrentCamera
			local f = temblor
			cam.CFrame = cam.CFrame * CFrame.Angles((math.random() - 0.5) * 0.02 * f, (math.random() - 0.5) * 0.02 * f, 0)
				* CFrame.new((math.random() - 0.5) * f, (math.random() - 0.5) * f, 0)
			temblor = math.max(0, temblor - dt * 2.5)
		end
		if etiquetaCombo.TextTransparency < 1 and os.clock() - ultimoGolpe > 2.5 then
			etiquetaCombo.TextTransparency = math.min(1, etiquetaCombo.TextTransparency + dt * 3)
			etiquetaCombo.TextStrokeTransparency = math.min(1, etiquetaCombo.TextStrokeTransparency + dt * 3)
			contador = 0
		end
	end)
end

return EfectosCombate
