-- EfectosMineria: animación y sensación de picar (solo visual; el servidor decide todo).
--   * Ritmo de pico: el brazo sube mientras se carga el golpe y baja de golpe al picar, con el torso
--     inclinándose hacia delante; el pico gira en la mano en el impacto.
--   * Impacto en el bloque: destello, polvo y esquirlas del color del bloque (con brillo de la rareza si es
--     mineral) y un pequeño temblor de cámara (respeta el ajuste de temblor).
--   * Grietas estilo Minecraft: el bloque se va agrietando según la vida que le queda.
--   * Al romperse: estallido de trozos que caen rebotando.
-- Todo es local: solo lo ve el propio jugador.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rarezas = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Visual"):WaitForChild("Rarezas"))

local EfectosMineria = {}

local jugador = Players.LocalPlayer
local Efectos   -- EfectosCombate (para el temblor)
local originales = {}
local subiendo = {}   -- [motor] = tween en curso
local grietas = {}    -- [parte] = { Carpeta, Etapa, Conexion }

local ETAPAS = 4      -- grietas a 25 %, 50 %, 75 % y casi roto

local function motor(nombresR15, padreR15, nombreR6, padreR6)
	local p = jugador.Character
	if not p then
		return nil
	end
	local a = p:FindFirstChild(padreR15)
	if a and a:FindFirstChild(nombresR15) then
		return a[nombresR15]
	end
	local b = p:FindFirstChild(padreR6)
	return b and b:FindFirstChild(nombreR6)
end

local function hombro()
	return motor("RightShoulder", "RightUpperArm", "Right Shoulder", "Torso")
end

local function cintura()
	return motor("Waist", "UpperTorso", "RootJoint", "HumanoidRootPart")
end

local function tween(m, tiempo, estilo, direccion, c0)
	if subiendo[m] then
		subiendo[m]:Cancel()
	end
	local t = TweenService:Create(m, TweenInfo.new(tiempo, estilo, direccion), { C0 = c0 })
	subiendo[m] = t
	t:Play()
	return t
end

local function base(m)
	originales[m] = originales[m] or m.C0
	return originales[m]
end

-- Golpe: el brazo baja rápido (0,07 s) y después vuelve a subir durante el resto del intervalo,
-- listo para el siguiente golpe. intervalo = segundos entre golpes del pico.
function EfectosMineria.golpe(herramienta, intervalo)
	intervalo = math.clamp(intervalo or 0.5, 0.15, 2)
	local h = hombro()
	if h then
		local b = base(h)
		tween(h, 0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.In, b * CFrame.Angles(math.rad(-25), 0, math.rad(-8)))
		task.delay(0.09, function()
			if h.Parent then
				-- carga: brazo atrás y arriba, el pico por encima del hombro
				tween(h, intervalo * 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, b * CFrame.Angles(math.rad(-160), 0, math.rad(-12)))
			end
		end)
	end
	local c = cintura()
	if c then
		local b = base(c)
		tween(c, 0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.In, b * CFrame.Angles(math.rad(-14), math.rad(6), 0))
		task.delay(0.1, function()
			if c.Parent then
				tween(c, intervalo * 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, b * CFrame.Angles(math.rad(6), math.rad(-4), 0))
			end
		end)
	end
	if herramienta and herramienta:FindFirstChild("Handle") then
		local agarre = herramienta:GetAttribute("AgarreOriginal")
		if not agarre then
			agarre = herramienta.Grip
			herramienta:SetAttribute("AgarreOriginal", agarre)
		end
		herramienta.Grip = agarre * CFrame.Angles(math.rad(-35), 0, 0)
		task.delay(0.1, function()
			if herramienta.Parent then
				herramienta.Grip = agarre
			end
		end)
	end
end

-- Al soltar el clic, guardar el pico o morir: todo vuelve a su sitio.
function EfectosMineria.reposo()
	for _, m in ipairs({ hombro(), cintura() }) do
		if m and originales[m] then
			tween(m, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, originales[m])
		end
	end
end

local function colorBloque(parte)
	if parte:GetAttribute("Tipo") == "Mineral" then
		return parte.Color, Rarezas.color(parte:GetAttribute("Rareza"))
	end
	return parte.Color, nil
end

local function trozo(posicion, color, tam, velocidad, vida, brillo, choca)
	local p = Instance.new("Part")
	p.Size = Vector3.new(tam, tam, tam)
	p.CFrame = CFrame.new(posicion) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
	p.Color = color
	p.Material = brillo and Enum.Material.Neon or Enum.Material.Slate
	p.CanCollide = choca == true   -- solo los trozos de un bloque roto rebotan en el suelo
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Massless = true
	p.Parent = workspace
	p.AssemblyLinearVelocity = velocidad
	p.AssemblyAngularVelocity = Vector3.new(math.random() * 20 - 10, math.random() * 20 - 10, math.random() * 20 - 10)
	TweenService:Create(p, TweenInfo.new(vida * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, vida * 0.6),
		{ Transparency = 1, Size = p.Size * 0.3 }):Play()
	Debris:AddItem(p, vida)
	return p
end

local function polvo(posicion, color, cantidad)
	local a = Instance.new("Attachment")
	a.WorldPosition = posicion
	a.Parent = workspace.Terrain
	local e = Instance.new("ParticleEmitter")
	e.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.35))
	e.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1.4) })
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime = NumberRange.new(0.35, 0.7)
	e.Speed = NumberRange.new(3, 7)
	e.SpreadAngle = Vector2.new(70, 70)
	e.Drag = 6
	e.Rate = 0
	e.Parent = a
	e:Emit(cantidad)
	Debris:AddItem(a, 1)
end

-- Cara del bloque que mira al jugador (para poner ahí las grietas y el polvo).
local function caraHacia(parte, desde)
	local local_ = parte.CFrame:PointToObjectSpace(desde)
	local s = parte.Size / 2
	local ax, ay, az = math.abs(local_.X) / s.X, math.abs(local_.Y) / s.Y, math.abs(local_.Z) / s.Z
	if ax >= ay and ax >= az then
		return Vector3.new(math.sign(local_.X), 0, 0)
	elseif ay >= az then
		return Vector3.new(0, math.sign(local_.Y), 0)
	end
	return Vector3.new(0, 0, math.sign(local_.Z))
end

-- Grietas: líneas oscuras finas pegadas a las 6 caras; más líneas cuanto menos vida.
local function pintarGrietas(parte)
	local vida, maxima = parte:GetAttribute("Vida") or 0, parte:GetAttribute("VidaMax") or 1
	local etapa = math.clamp(math.floor((1 - vida / math.max(maxima, 1e-6)) * ETAPAS + 0.0001), 0, ETAPAS)
	local g = grietas[parte]
	if not g then
		if etapa == 0 then
			return
		end
		local carpeta = Instance.new("Folder")
		carpeta.Name = "Grietas"
		carpeta.Parent = workspace.CurrentCamera
		g = { Carpeta = carpeta, Etapa = 0 }
		grietas[parte] = g
		g.Conexion = parte.AncestryChanged:Connect(function()
			if not parte:IsDescendantOf(workspace) then
				carpeta:Destroy()
				g.Conexion:Disconnect()
				grietas[parte] = nil
			end
		end)
	end
	local s = parte.Size
	local oscuro = parte.Color:Lerp(Color3.new(0, 0, 0), 0.75)
	while g.Etapa < etapa do
		g.Etapa = g.Etapa + 1
		for _, normal in ipairs({ Vector3.xAxis, -Vector3.xAxis, Vector3.yAxis, -Vector3.yAxis, Vector3.zAxis, -Vector3.zAxis }) do
			for _ = 1, 2 do
				local largo = (0.35 + math.random() * 0.4) * s.X
				local u = (math.random() - 0.5) * s.X * 0.6
				local v = (math.random() - 0.5) * s.X * 0.6
				local centro = normal * (s.X / 2 + 0.01)
				local eje1 = math.abs(normal.X) > 0 and Vector3.yAxis or Vector3.xAxis
				local eje2 = normal:Cross(eje1)
				local pos = parte.CFrame:PointToWorldSpace(centro + eje1 * u + eje2 * v)
				local giro = math.random() * math.pi
				local cf = CFrame.lookAt(pos, pos + parte.CFrame:VectorToWorldSpace(normal)) * CFrame.Angles(0, 0, giro)
				local l = Instance.new("Part")
				l.Anchored = true
				l.CanCollide = false
				l.CanQuery = false
				l.CanTouch = false
				l.CastShadow = false
				l.Color = oscuro
				l.Material = Enum.Material.SmoothPlastic
				l.Size = Vector3.new(largo, 0.08 + g.Etapa * 0.02, 0.02)
				l.CFrame = cf
				l.Parent = g.Carpeta
			end
		end
	end
end

-- Impacto en un bloque (al enviar el golpe).
function EfectosMineria.impacto(parte)
	local p = jugador.Character
	local raiz = p and p:FindFirstChild("HumanoidRootPart")
	if not raiz or not parte or not parte.Parent then
		return
	end
	local normal = parte.CFrame:VectorToWorldSpace(caraHacia(parte, raiz.Position))
	local punto = parte.Position + normal * (parte.Size.X / 2 + 0.1)
	local color, brillo = colorBloque(parte)
	-- destello
	local h = Instance.new("Highlight")
	h.FillColor = brillo or Color3.new(1, 1, 1)
	h.FillTransparency = 0.55
	h.OutlineTransparency = 1
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Parent = parte
	TweenService:Create(h, TweenInfo.new(0.12), { FillTransparency = 1 }):Play()
	Debris:AddItem(h, 0.13)
	-- polvo y esquirlas
	polvo(punto, color, 6)
	for _ = 1, 4 do
		local dir = (normal * 1.2 + Vector3.new(math.random() - 0.5, math.random() * 0.8, math.random() - 0.5)).Unit
		trozo(punto, color, 0.25 + math.random() * 0.2, dir * (10 + math.random() * 8), 0.8, false)
	end
	if brillo then
		for _ = 1, 3 do
			local dir = (normal + Vector3.new(math.random() - 0.5, math.random(), math.random() - 0.5)).Unit
			trozo(punto, brillo, 0.18, dir * 14, 0.5, true)
		end
	end
	if Efectos then
		Efectos.temblar(brillo and 0.08 or 0.05)
	end
	-- Las grietas se actualizan cuando el servidor cambia la vida (atributo «Vida»).
	if not parte:GetAttribute("_VigiladoGrietas") then
		parte:SetAttribute("_VigiladoGrietas", true)
		parte:GetAttributeChangedSignal("Vida"):Connect(function()
			pintarGrietas(parte)
		end)
		local ultimo = parte.CFrame
		parte:GetPropertyChangedSignal("CFrame"):Connect(function()
			ultimo = parte.CFrame
		end)
		parte.AncestryChanged:Connect(function()
			if not parte:IsDescendantOf(workspace) then
				EfectosMineria.romper(ultimo.Position, parte.Size, color, brillo)
			end
		end)
	end
	pintarGrietas(parte)
end

-- Bloque roto: estallido de trozos que caen y rebotan.
function EfectosMineria.romper(posicion, tam, color, brillo)
	local p = jugador.Character
	local raiz = p and p:FindFirstChild("HumanoidRootPart")
	if not raiz or (raiz.Position - posicion).Magnitude > 40 then
		return
	end
	polvo(posicion, color, 14)
	local n = 10
	for _ = 1, n do
		local desvio = Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * tam.X * 0.7
		local vel = Vector3.new(math.random() * 12 - 6, 8 + math.random() * 8, math.random() * 12 - 6)
		trozo(posicion + desvio, color, 0.4 + math.random() * 0.5, vel, 1.4, false, true)
	end
	if brillo then
		for _ = 1, 6 do
			local vel = Vector3.new(math.random() * 16 - 8, 10 + math.random() * 10, math.random() * 16 - 8)
			trozo(posicion, brillo, 0.25, vel, 1, true)
		end
		if Efectos then
			Efectos.temblar(0.15)
		end
	elseif Efectos then
		Efectos.temblar(0.08)
	end
end

function EfectosMineria.Iniciar(efectosCombate)
	Efectos = efectosCombate
	jugador.CharacterAdded:Connect(function()
		originales = {}
		subiendo = {}
	end)
end

return EfectosMineria
