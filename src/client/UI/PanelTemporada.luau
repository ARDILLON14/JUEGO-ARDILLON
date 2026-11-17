-- Pase de temporada (tecla N): nivel del pase, días que quedan y las 50 recompensas de las dos vías.
-- La XP del pase sale de las misiones diarias (100 cada una).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Season = require(Shared:WaitForChild("Config"):WaitForChild("Season"))
local Economia = require(Shared:WaitForChild("Formulas"):WaitForChild("Economia"))
local Temporada = require(Shared:WaitForChild("Reglas"):WaitForChild("Temporada"))
local Tienda = require(Shared.Reglas:WaitForChild("Tienda"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelTemporada = {}

local ROSA = Color3.fromRGB(255, 140, 220)
local Estado, pantalla, cabecera, fijarBarra, lista, mensaje, botonPago

local function textoRecompensa(perfil, r)
	if r.SeasonFragments then
		return r.SeasonFragments .. " Fragmentos"
	elseif r.CoinHours then
		return Formato.abreviado(math.floor(r.CoinHours * Economia.income(perfil.Progress.UnlockedZone) + 0.5)) .. " $"
	elseif r.Crystals then
		return r.Crystals .. " Cristales"
	elseif r.Cosmetic then
		local c = Tienda.cosmetico(r.Cosmetic)
		return c and c.Name or r.Cosmetic
	end
	return "?"
end

local function decir(ok, r, bien)
	mensaje.Text = ok and bien or ("No se pudo: " .. tostring(r))
	mensaje.TextColor3 = ok and ROSA or C.Peligro
end

local function botonRecompensa(f, perfil, nivel, via, x)
	local r = Temporada.recompensa(nivel, via)
	local b = Componentes.boton({ Size = UDim2.new(0, 190, 0, 28), Position = UDim2.new(0, x, 0.5, -14), TextSize = 11, Parent = f,
		Text = textoRecompensa(perfil, r) })
	local ok, motivo = Temporada.comprobar(perfil, nivel, via)
	if ok then
		b.BackgroundColor3 = via == "Paid" and ROSA or C.XP
		b.TextColor3 = C.Fondo
		b.Text = "Cobrar: " .. b.Text
		b.Activated:Connect(function()
			task.spawn(function()
				local bien, err = Estado.Invocar("Season.Claim", nivel, via)
				decir(bien, err, "¡Cobrado!")
			end)
		end)
	elseif motivo == "ya" then
		b.BackgroundColor3 = C.Fondo
		b.TextColor3 = C.TextoSuave
		b.Text = "✓ " .. b.Text
	else
		b.BackgroundColor3 = C.BotonApagado
		b.TextColor3 = motivo == "pago" and ROSA or C.TextoSuave
	end
end

function PanelTemporada.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla.Enabled or not perfil or not perfil.Season then
		return
	end
	local id, quedan = Temporada.actual(os.time())
	local nivel = Temporada.nivel(perfil)
	cabecera.Text = string.format("Temporada %d · quedan %d días · nivel del pase %d / %d · Fragmentos: %d",
		id, math.ceil(quedan / 86400), nivel, Season.Levels, perfil.Wallet.SeasonFragments or 0)
	local resto = perfil.Season.PassXP - nivel * Season.XPPerLevel
	if nivel >= Season.Levels then
		fijarBarra(1, "¡Pase completo!")
	else
		fijarBarra(resto / Season.XPPerLevel, resto .. " / " .. Season.XPPerLevel .. " XP del pase (100 por misión diaria)")
	end
	if perfil.Season.Paid then
		botonPago.Text = "Vía de pago activa"
		botonPago.BackgroundColor3 = C.BotonApagado
	else
		botonPago.Text = "Vía de pago: " .. Season.PaidCrystals .. " Cristales"
		botonPago.BackgroundColor3 = ROSA
	end
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	for n = 1, Season.Levels do
		local f = crear("Frame", { BackgroundColor3 = n <= nivel and C.Fondo or C.Panel, BackgroundTransparency = 0.2, Size = UDim2.new(1, -10, 0, 34), LayoutOrder = n, Parent = lista },
			{ Componentes.esquinas(6) })
		Componentes.texto({ Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(0, 8, 0, 0), Font = Enum.Font.GothamBold, Text = "Nv " .. n,
			TextColor3 = n <= nivel and ROSA or C.TextoSuave, Parent = f })
		botonRecompensa(f, perfil, n, "Free", 70)
		botonRecompensa(f, perfil, n, "Paid", 270)
	end
end

function PanelTemporada.Iniciar(estado)
	Estado = estado
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	pantalla = crear("ScreenGui", { Name = "PanelTemporada", ResetOnSpawn = false, Enabled = false, Parent = gui })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 520, 0, 470), Position = UDim2.new(0.5, -260, 0.5, -235), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = ROSA }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Pase de temporada", TextSize = 22, Font = Enum.Font.GothamBold, TextColor3 = ROSA, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	cabecera = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 32), TextSize = 12, TextColor3 = C.TextoSuave, Parent = marco })
	local _, fijar = Componentes.barra({ Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 54), Parent = marco }, ROSA)
	fijarBarra = fijar
	Componentes.texto({ Size = UDim2.new(0, 190, 0, 18), Position = UDim2.new(0, 70, 0, 78), TextSize = 12, Font = Enum.Font.GothamBold, Text = "Vía gratuita", Parent = marco })
	Componentes.texto({ Size = UDim2.new(0, 190, 0, 18), Position = UDim2.new(0, 270, 0, 78), TextSize = 12, Font = Enum.Font.GothamBold, Text = "Vía de pago", TextColor3 = ROSA, Parent = marco })
	lista = crear("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -150), Position = UDim2.new(0, 0, 0, 98),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
	botonPago = Componentes.boton({ Size = UDim2.new(0, 230, 0, 30), Position = UDim2.new(0, 0, 1, -50), TextSize = 13, TextColor3 = C.Fondo, Parent = marco })
	botonPago.Activated:Connect(function()
		task.spawn(function()
			local ok, r = Estado.Invocar("Season.BuyPaid")
			decir(ok, r, "¡Vía de pago activada!")
		end)
	end)
	mensaje = Componentes.texto({ Size = UDim2.new(1, -240, 0, 30), Position = UDim2.new(0, 240, 1, -50), TextSize = 12, TextColor3 = C.TextoSuave, TextWrapped = true,
		Text = "La vía de pago solo da cosméticos y Cristales.", Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelTemporada.Refrescar()
		end
	end)
end

function PanelTemporada.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	PanelTemporada.Refrescar()
end

return PanelTemporada
