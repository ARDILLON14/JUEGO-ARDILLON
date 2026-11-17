-- FractureController: diálogo de entrada a la Zona Fracturada, panel con carga, ralentización, racha, pérdida
-- posible y contratos, progreso de la extracción, borde rojo, avisos visuales (punto activo, portadores con mucha
-- carga, acampados, venganza) y marcador de la arena.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Fracture = require(Shared:WaitForChild("Config"):WaitForChild("Fracture"))
local Fractura = require(Shared:WaitForChild("Reglas"):WaitForChild("Fractura"))

local UI = script.Parent.Parent:WaitForChild("UI")
local Componentes = require(UI:WaitForChild("Componentes"))
local Formato = require(UI:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local FractureController = {}

local jugador = Players.LocalPlayer
local Estado, avisar
local pantalla, panel, lineas, barraCanal, fijarCanal, borde, dialogo, marcador
local ultimo = nil
local arenaFin = nil
local ROJO = Color3.fromRGB(255, 80, 80)

local function texto(props)
	return Componentes.texto(props)
end

local function crearInterfaz()
	pantalla = crear("ScreenGui", { Name = "Grieta", ResetOnSpawn = false, IgnoreGuiInset = true, Parent = jugador:WaitForChild("PlayerGui") })
	borde = crear("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, Parent = pantalla },
		{ crear("UIStroke", { Color = ROJO, Thickness = 6, Transparency = 0.2 }) })
	panel = crear("Frame", { BackgroundColor3 = C.Panel, BackgroundTransparency = 0.15, Size = UDim2.new(0, 280, 0, 210), Position = UDim2.new(0, 16, 0, 230),
		Visible = false, Parent = pantalla }, { Componentes.esquinas(10), crear("UIStroke", { Color = ROJO }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 6) }),
		crear("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
	texto({ Size = UDim2.new(1, -10, 0, 20), Text = "ZONA FRACTURADA · PvP", Font = Enum.Font.GothamBlack, TextColor3 = ROJO, LayoutOrder = 0, Parent = panel })
	lineas = {}
	for i = 1, 8 do
		lineas[i] = texto({ Size = UDim2.new(1, -10, 0, 18), TextSize = 12, LayoutOrder = i, TextWrapped = true, Parent = panel })
	end
	barraCanal, fijarCanal = Componentes.barra({ Size = UDim2.new(0, 320, 0, 22), Position = UDim2.new(0.5, -160, 0.62, 0), Parent = pantalla }, C.Energia)
	barraCanal.Visible = false
	marcador = texto({ Size = UDim2.new(0, 420, 0, 30), Position = UDim2.new(0.5, -210, 0, 130), TextXAlignment = Enum.TextXAlignment.Center, TextSize = 18,
		Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(255, 200, 90), TextStrokeTransparency = 0.3, Visible = false, Parent = pantalla })
end

local function pintar(d)
	ultimo = d
	panel.Visible = d.Inside == true
	borde.Visible = d.Inside == true
	if not d.Inside then
		barraCanal.Visible = false
		return
	end
	lineas[1].Text = string.format("Carga %s  ·  ralentización %s", Formato.decimal(d.Load, 1), Formato.porcentaje(d.Slow, 0))
	lineas[2].Text = "Mineral " .. Formato.entero(d.Units) .. " / " .. Formato.entero(d.Capacity)
	lineas[3].Text = string.format("Racha %d  ·  al extraer ×%s", d.Streak, Formato.decimal(d.Multiplier, 2))
	lineas[4].Text = "Si te derrota un jugador pierdes: " .. Formato.porcentaje(d.Loss, 0)
	lineas[4].TextColor3 = d.Loss > 0 and ROJO or Color3.fromRGB(120, 255, 160)
	lineas[5].Text = (d.Insured and "Seguro de carga activo" or "Sin seguro") .. (d.Protected and "  ·  PROTEGIDO" or "")
	local pos = jugador.Character and jugador.Character:FindFirstChild("HumanoidRootPart")
	local dist = pos and math.floor((d.Point - pos.Position).Magnitude) or 0
	lineas[6].Text = "Punto de Extracción activo a " .. dist .. " studs · cambia en " .. math.floor(d.NextChange / 60) .. ":" .. string.format("%02d", math.floor(d.NextChange % 60))
	local contratos = {}
	for _, c in ipairs(d.Contracts or {}) do
		local objetivo = Fractura.objetivoContrato(c.Id)
		local nombre = c.Id == "DefeatCarriers" and "Derrota portadores (carga 5+)" or "Extrae Raros o mejores"
		table.insert(contratos, nombre .. " " .. c.Progress .. "/" .. objetivo .. (c.Claimed and " ✓" or ""))
	end
	lineas[7].Text = #contratos > 0 and ("Contratos: " .. table.concat(contratos, " · ")) or ""
	lineas[7].Size = UDim2.new(1, -10, 0, 36)
	lineas[8].Text = "R en el punto: extraer (8 s) · R en la salida: salir (3 s)"
	lineas[8].TextColor3 = C.TextoSuave
end

local function dialogoEntrada(datos)
	if dialogo then
		dialogo:Destroy()
	end
	local usarSeguro = false
	dialogo = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 520, 0, 300), Position = UDim2.new(0.5, -260, 0.5, -150), Parent = pantalla },
		{ Componentes.esquinas(12), crear("UIStroke", { Color = ROJO, Thickness = 2 }),
			crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12) }) })
	texto({ Size = UDim2.new(1, 0, 0, 26), Text = "Zona Fracturada de la zona " .. datos.Zone, TextSize = 20, Font = Enum.Font.GothamBlack, TextColor3 = ROJO, Parent = dialogo })
	local novato = datos.Entries < datos.Novice
	texto({ Size = UDim2.new(1, 0, 0, 170), Position = UDim2.new(0, 0, 0, 32), TextSize = 13, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, Parent = dialogo,
		Text = "• PvP siempre activo. Solo arriesgas el mineral que piques aquí: nunca equipo, mascotas, monedas ni nivel.\n"
			.. "• El mineral vale ×1,5 al extraerlo (y más con la racha: ahora " .. datos.Streak .. "). Si no lo extraes, vale ×1,0.\n"
			.. "• Cuanta más carga, más lento vas. Si te derrota un jugador sueltas la mitad (un cuarto con Seguro).\n"
			.. "• Tienes 10 s de protección al entrar si no atacas.\n"
			.. (novato and ("• Protección de novato: entrada " .. (datos.Entries + 1) .. " de " .. datos.Novice .. " sin pérdidas.") or "• Ya no tienes protección de novato.") })
	local seguro = Componentes.boton({ Size = UDim2.new(0, 230, 0, 32), Position = UDim2.new(0, 0, 1, -82), TextSize = 12, BackgroundColor3 = C.BotonApagado, Parent = dialogo,
		Text = "Usar Seguro de carga: NO (tienes " .. datos.Insurance .. ")" })
	seguro.Activated:Connect(function()
		if datos.Insurance > 0 then
			usarSeguro = not usarSeguro
			seguro.Text = "Usar Seguro de carga: " .. (usarSeguro and "SÍ" or "NO") .. " (tienes " .. datos.Insurance .. ")"
			seguro.BackgroundColor3 = usarSeguro and C.XP or C.BotonApagado
		end
	end)
	local entrar = Componentes.boton({ Size = UDim2.new(0, 130, 0, 36), Position = UDim2.new(1, -140, 1, -84), Text = "Entrar", BackgroundColor3 = ROJO, Parent = dialogo })
	local cancelar = Componentes.boton({ Size = UDim2.new(0, 110, 0, 36), Position = UDim2.new(1, -260, 1, -84), Text = "Cancelar", BackgroundColor3 = C.BotonApagado, Parent = dialogo })
	cancelar.Activated:Connect(function()
		dialogo:Destroy()
		dialogo = nil
	end)
	entrar.Activated:Connect(function()
		local d = dialogo
		task.spawn(function()
			local ok, motivo = Estado.Invocar("Fracture.Enter", datos.Zone, usarSeguro, true)
			if ok then
				d:Destroy()
				dialogo = nil
			else
				local textos = { zona = "Necesitas el nivel de la zona.", pico = "Tu pico no tiene potencia para esta zona.", espera = "Espera unos segundos antes de volver a entrar.",
					seguro = "No tienes Seguros o ya usaste 5 hoy.", combate = "Sal de combate primero." }
				avisar({ Text = textos[motivo] or ("No se pudo: " .. tostring(motivo)), Kind = "Warning", Short = true })
			end
		end)
	end)
end

-- Avisos visuales en el mundo.
local resaltes = {}
local function resaltar(objeto, clave, color, activo)
	local h = objeto:FindFirstChild(clave)
	if activo and not h then
		h = Instance.new("Highlight")
		h.Name = clave
		h.FillColor = color
		h.OutlineColor = color
		h.FillTransparency = 0.7
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = objeto
		resaltes[h] = true
	elseif not activo and h then
		h:Destroy()
	end
end

local function visuales()
	for _, p in ipairs(CollectionService:GetTagged("PuntoExtraccion")) do
		resaltar(p, "Activo", Color3.fromRGB(80, 255, 140), p:GetAttribute("Activo") == true and (ultimo and ultimo.Inside))
	end
	for _, otro in ipairs(Players:GetPlayers()) do
		local c = otro.Character
		if c then
			local carga = c:GetAttribute("Carga") or 0
			resaltar(c, "Portador", Color3.fromRGB(255, 210, 60), otro ~= jugador and carga >= Fracture.Load.MinimapAtLoad)
			resaltar(c, "Acampado", ROJO, otro ~= jugador and c:GetAttribute("Acampando") == true)
			resaltar(c, "Venganza", Color3.fromRGB(255, 40, 40), c:GetAttribute("Venganza") == tostring(jugador.UserId))
			local raiz = c:FindFirstChild("HumanoidRootPart")
			if raiz then
				local brillo = raiz:FindFirstChild("BrilloCarga")
				if carga >= Fracture.Load.ParticlesAtLoad and not brillo then
					brillo = Instance.new("Sparkles")
					brillo.Name = "BrilloCarga"
					brillo.SparkleColor = Color3.fromRGB(255, 220, 100)
					brillo.Parent = raiz
				elseif carga < Fracture.Load.ParticlesAtLoad and brillo then
					brillo:Destroy()
				end
			end
		end
	end
end

function FractureController.Iniciar(estado, carpeta, funcionAviso, alAviso)
	Estado = estado
	avisar = funcionAviso
	crearInterfaz()
	carpeta:WaitForChild("Fracture.State").OnClientEvent:Connect(pintar)
	alAviso("OpenFracture", dialogoEntrada)
	alAviso("Arena", function(datos)
		local d = datos.Data or {}
		if d.Ended then
			marcador.Visible = false
			arenaFin = nil
			return
		end
		marcador.Visible = true
		arenaFin = d.Ends
		marcador:SetAttribute("Base", "Arena · ronda " .. d.Round .. " · azul " .. d.Score[1] .. " - " .. d.Score[2] .. " rojo")
	end)
	RunService.RenderStepped:Connect(function()
		if ultimo and ultimo.Inside and ultimo.Channel then
			local resto = ultimo.Channel.Fin - workspace:GetServerTimeNow()
			barraCanal.Visible = resto > 0
			fijarCanal(1 - resto / ultimo.Channel.Segundos, (ultimo.Channel.Tipo == "Extract" and "Extrayendo… " or "Saliendo… ") .. Formato.decimal(math.max(0, resto), 1) .. " s")
		else
			barraCanal.Visible = false
		end
		if marcador.Visible and arenaFin then
			marcador.Text = (marcador:GetAttribute("Base") or "") .. " · " .. math.max(0, math.ceil(arenaFin - workspace:GetServerTimeNow())) .. " s"
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			visuales()
		end
	end)
end

return FractureController
