-- HUDController: nivel y barra de XP, vida, energía, monedas, avisos y botón del panel de estadísticas.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Progresion = require(Shared:WaitForChild("Formulas"):WaitForChild("Progresion"))
local Estadisticas = require(Shared:WaitForChild("Reglas"):WaitForChild("Estadisticas"))

local UI = script.Parent.Parent:WaitForChild("UI")
local Componentes = require(UI:WaitForChild("Componentes"))
local Formato = require(UI:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local HUDController = {}

local jugador = Players.LocalPlayer
local Estado
local fijarVida, fijarEnergia, fijarXP
local etiquetaNivel, etiquetaMonedas, botonPanel, contenedorAvisos

local function actualizarPerfil()
	local perfil = Estado.Perfil
	if not perfil then
		return
	end
	local nivel = perfil.Progress.Level
	local necesaria = Progresion.xpForLevel(nivel)
	etiquetaNivel.Text = "Nivel " .. Formato.entero(nivel)
	fijarXP(perfil.Progress.XP / necesaria, Formato.entero(perfil.Progress.XP) .. " / " .. Formato.entero(necesaria) .. " XP")
	etiquetaMonedas.Text = Formato.entero(perfil.Wallet.Coins) .. " monedas"
	local libres = Estadisticas.puntosLibres(perfil)
	if libres > 0 then
		botonPanel.Text = "Estadísticas (P) · " .. Formato.entero(libres) .. " libres"
		botonPanel.BackgroundColor3 = C.XP
	else
		botonPanel.Text = "Estadísticas (P)"
		botonPanel.BackgroundColor3 = C.Boton
	end
end

local function actualizarEnergia()
	local s = Estado.Stats
	fijarEnergia(s.Energy / math.max(1, s.MaxEnergy), Formato.entero(s.Energy) .. " / " .. Formato.entero(s.MaxEnergy))
end

local function vigilarVida(personaje)
	local h = personaje:WaitForChild("Humanoid", 10)
	if not h then
		return
	end
	local function pintar()
		fijarVida(h.Health / math.max(1, h.MaxHealth), Formato.entero(h.Health) .. " / " .. Formato.entero(h.MaxHealth))
	end
	h.HealthChanged:Connect(pintar)
	h:GetPropertyChangedSignal("MaxHealth"):Connect(pintar)
	pintar()
end

local function aviso(texto, color)
	local etiqueta = Componentes.texto({
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 0.15,
		BackgroundColor3 = C.Panel,
		Text = texto,
		TextColor3 = color or C.Texto,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = contenedorAvisos,
	})
	Componentes.esquinas(8).Parent = etiqueta
	task.delay(3.5, function()
		etiqueta:Destroy()
	end)
end

local function alAviso(datos)
	if type(datos) ~= "table" then
		return
	end
	if datos.Kind == "LevelUp" then
		aviso("¡Nivel " .. Formato.entero(datos.Level) .. "! +" .. Formato.entero(datos.Points) .. " puntos de estadística", C.XP)
		if datos.Zone then
			aviso("Nueva zona desbloqueada: zona " .. tostring(datos.Zone), C.Energia)
		end
	elseif type(datos.Text) == "string" then
		aviso(datos.Text)
	end
end

local function crearBotonesStudio(pantalla)
	local fila = crear("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 260, 0, 32),
		Position = UDim2.new(1, -276, 0, 16),
		Parent = pantalla,
	}, { crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }) })
	local function boton(texto, remote, cantidad)
		local b = Componentes.boton({ Size = UDim2.new(0, 82, 1, 0), Text = texto, TextSize = 12, BackgroundColor3 = C.Peligro, Parent = fila })
		b.Activated:Connect(function()
			task.spawn(function()
				local perfil = Estado.Perfil
				local n = cantidad
				if remote == "Dev.GiveXP" and perfil then
					n = Progresion.xpForLevel(perfil.Progress.Level)   -- un nivel exacto
				end
				Estado.Invocar(remote, n)
			end)
		end)
	end
	boton("+1 nivel", "Dev.GiveXP")
	boton("+10.000 $", "Dev.GiveCoins", 10000)
	crear("TextLabel", {
		BackgroundTransparency = 1, Size = UDim2.new(0, 80, 1, 0), Text = "solo Studio", TextColor3 = C.TextoSuave,
		TextSize = 11, Font = Enum.Font.Gotham, Parent = fila,
	})
end

function HUDController.Iniciar(estado, alPulsarPanel)
	Estado = estado
	local pantalla = crear("ScreenGui", {
		Name = "HUD",
		ResetOnSpawn = false,
		IgnoreGuiInset = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = jugador:WaitForChild("PlayerGui"),
	})

	local marco = crear("Frame", {
		BackgroundColor3 = C.Panel,
		BackgroundTransparency = 0.2,
		Size = UDim2.new(0, 280, 0, 132),
		Position = UDim2.new(0, 16, 0, 16),
		Parent = pantalla,
	}, {
		Componentes.esquinas(10),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
		crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	etiquetaNivel = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), TextSize = 18, Font = Enum.Font.GothamBold, Text = "Nivel 1", LayoutOrder = 1, Parent = marco })
	local _, fx = Componentes.barra({ Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2, Parent = marco }, C.XP)
	local _, fv = Componentes.barra({ Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 3, Parent = marco }, C.Vida)
	local _, fe = Componentes.barra({ Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 4, Parent = marco }, C.Energia)
	fijarXP, fijarVida, fijarEnergia = fx, fv, fe
	etiquetaMonedas = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Text = "0 monedas", TextColor3 = C.XP, LayoutOrder = 5, Parent = marco })

	botonPanel = Componentes.boton({
		Size = UDim2.new(0, 230, 0, 40),
		Position = UDim2.new(1, -246, 1, -56),
		Text = "Estadísticas (P)",
		Parent = pantalla,
	})
	botonPanel.Activated:Connect(alPulsarPanel)

	contenedorAvisos = crear("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 420, 0, 200),
		Position = UDim2.new(0.5, -210, 0, 70),
		Parent = pantalla,
	}, { crear("UIListLayout", { Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center }) })

	if RunService:IsStudio() then
		task.spawn(function()
			task.wait(2)
			if Estado.Existe("Dev.GiveXP") then
				crearBotonesStudio(pantalla)
			end
		end)
	end

	fijarXP(0, "")
	fijarVida(1, "")
	actualizarEnergia()
	Estado.Cambio:Connect(function(que, datos)
		if que == "Perfil" then
			actualizarPerfil()
		elseif que == "Stats" then
			actualizarEnergia()
		elseif que == "Aviso" then
			alAviso(datos)
		end
	end)
	actualizarPerfil()
	jugador.CharacterAdded:Connect(vigilarVida)
	if jugador.Character then
		task.spawn(vigilarVida, jugador.Character)
	end
end

return HUDController
