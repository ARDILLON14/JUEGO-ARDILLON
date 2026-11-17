-- Misiones (tecla J) y aviso del tutorial. El tutorial se ve siempre arriba hasta terminarlo (o saltarlo).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Quests = require(Shared:WaitForChild("Config"):WaitForChild("Quests"))
local Misiones = require(Shared:WaitForChild("Reglas"):WaitForChild("Misiones"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelMisiones = {}

local CATEGORIA = { Mining = "Minería", Combat = "Combate", Pets = "Mascotas" }
local Estado, pantalla, lista, mensaje, tutorial, textoTutorial

local function pintarTutorial()
	local perfil = Estado.Perfil
	if not perfil then
		return
	end
	local paso, i = Misiones.pasoTutorial(perfil)
	if not paso then
		tutorial.Visible = false
		return
	end
	tutorial.Visible = true
	local cuenta = paso.Count > 1 and ("  (" .. (perfil.Progress.TutorialCount or 0) .. "/" .. paso.Count .. ")") or ""
	textoTutorial.Text = "Tutorial " .. i .. "/" .. #Quests.Tutorial .. ": " .. paso.Text .. cuenta
end

function PanelMisiones.Refrescar()
	pintarTutorial()
	local perfil = Estado.Perfil
	if not pantalla.Enabled or not perfil then
		return
	end
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	local recompensa = Misiones.recompensa(perfil)
	for i, q in ipairs(perfil.Quests.Daily or {}) do
		local d = Misiones.definicion(q.Id)
		if d then
			local f = crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, 54), LayoutOrder = i, Parent = lista }, { Componentes.esquinas(8) })
			local cat = "?"
			for c, l in pairs(Quests.Daily) do
				for _, x in ipairs(l) do
					if x.Id == q.Id then
						cat = CATEGORIA[c]
					end
				end
			end
			Componentes.texto({ Size = UDim2.new(0, 380, 0, 20), Position = UDim2.new(0, 10, 0, 4), Font = Enum.Font.GothamBold, Parent = f,
				Text = cat .. ": " .. string.format(d.Text, d.Count) })
			local _, fijar = Componentes.barra({ Size = UDim2.new(0, 260, 0, 14), Position = UDim2.new(0, 10, 0, 30), Parent = f }, C.XP)
			fijar(q.Progress / d.Count, Formato.entero(q.Progress) .. " / " .. Formato.entero(d.Count))
			local b = Componentes.boton({ Size = UDim2.new(0, 150, 0, 36), Position = UDim2.new(1, -158, 0.5, -18), TextSize = 12, Parent = f })
			if q.Claimed then
				b.Text = "Cobrada"
				b.BackgroundColor3 = C.BotonApagado
			else
				b.Text = "Cobrar\n" .. Formato.abreviado(recompensa.Coins) .. " · " .. Formato.abreviado(recompensa.XP) .. " XP"
				b.BackgroundColor3 = q.Progress >= d.Count and C.XP or C.BotonApagado
				b.TextColor3 = q.Progress >= d.Count and C.Fondo or C.Texto
				b.Activated:Connect(function()
					task.spawn(function()
						local ok, r = Estado.Invocar("Quest.Claim", q.Id)
						mensaje.Text = ok and "¡Cobrada!" or (r == "incompleta" and "Aún no está completa." or ("No se pudo: " .. tostring(r)))
					end)
				end)
			end
		end
	end
end

function PanelMisiones.Iniciar(estado)
	Estado = estado
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	-- Aviso del tutorial
	local capa = crear("ScreenGui", { Name = "Tutorial", ResetOnSpawn = false, Parent = gui })
	tutorial = crear("Frame", { BackgroundColor3 = C.Panel, BackgroundTransparency = 0.15, Size = UDim2.new(0, 620, 0, 40), Position = UDim2.new(0.5, -310, 0, 82), Visible = false, Parent = capa },
		{ Componentes.esquinas(10), crear("UIStroke", { Color = C.Energia }) })
	textoTutorial = Componentes.texto({ Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 12, 0, 0), TextSize = 13, TextWrapped = true, TextColor3 = C.Energia, Parent = tutorial })
	local saltar = Componentes.boton({ Size = UDim2.new(0, 90, 0, 28), Position = UDim2.new(1, -96, 0.5, -14), Text = "Saltar", TextSize = 12, BackgroundColor3 = C.BotonApagado, Parent = tutorial })
	saltar.Activated:Connect(function()
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Tutorial.Step"):FireServer(100)
	end)
	-- Panel de misiones
	pantalla = crear("ScreenGui", { Name = "PanelMisiones", ResetOnSpawn = false, Enabled = false, Parent = gui })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 560, 0, 300), Position = UDim2.new(0.5, -280, 0.5, -150), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = C.Borde }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Misiones diarias", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 30), TextSize = 12, TextColor3 = C.TextoSuave, Text = "Se renuevan cada día (UTC). No pasa nada si un día no las haces.", Parent = marco })
	lista = crear("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 54), Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelMisiones.Refrescar()
		end
	end)
	PanelMisiones.Refrescar()
end

function PanelMisiones.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	mensaje.Text = ""
	PanelMisiones.Refrescar()
end

return PanelMisiones
