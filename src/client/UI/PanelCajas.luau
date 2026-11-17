-- Panel de cajas (puesto «Geodas»): precio, probabilidades con tu Suerte (se muestran antes de abrir, GDD),
-- cuántas aperturas faltan para las garantías, y abrir 1 o 10. El premio lo decide el servidor antes de la animación;
-- la Geoda (A_GDD 7.2) se agrieta 3 veces con la luz de la rareza real y se puede saltar con un clic.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Rarity = require(Config:WaitForChild("Rarity"))
local Boxes = require(Config:WaitForChild("Boxes"))
local Mining = require(Config:WaitForChild("Mining"))
local Pets = require(Config:WaitForChild("Pets"))
local Cajas = require(Shared:WaitForChild("Reglas"):WaitForChild("Cajas"))
local Estadisticas = require(Shared.Reglas:WaitForChild("Estadisticas"))
local Inventario = require(Shared.Reglas:WaitForChild("Inventario"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))
local Nombres = require(Shared.Visual:WaitForChild("Nombres"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelCajas = {}

local NOMBRE_CAJA = { Weapon = "Caja de armas", Zone = "Caja de zona", Pet = "Caja de mascotas", Core = "Caja de Núcleos" }
local CONTENIDO = { Weapon = "Un arma de tu zona", Zone = "Pico, minerales, materiales o Seguros de carga", Pet = "Un huevo de mascota", Core = "Un Núcleo de Poder (repetido: +200 de maestría)" }
local MOTIVOS = { lejos = "Acércate al puesto de geodas.", sin_saldo = "No tienes monedas suficientes.", inventario = "Inventario lleno.", frecuencia = "Espera un momento." }

local Estado, pantalla, lista, mensaje, titulo, capa

local function avisar(t)
	mensaje.Text = t or ""
end

local function describir(p)
	if p.Kind == "Weapon" or p.Kind == "Pickaxe" then
		return Inventario.nombreBase(p.Item)
	elseif p.Kind == "Minerals" then
		local m = Mining.Minerals[p.Mineral]
		return Formato.entero(p.Units) .. " × " .. (m and m.Name or p.Mineral) .. " (al banco)"
	elseif p.Kind == "Insurance" then
		return p.Units .. " Seguro(s) de carga"
	elseif p.Kind == "Egg" then
		local e = Pets.Species[p.Species]
		return "Huevo de " .. (e and e.Name or p.Species)
	elseif p.Kind == "Core" then
		return Nombres.Nucleo[p.Core] or p.Core
	elseif p.Kind == "CoreDuplicate" then
		return (Nombres.Nucleo[p.Core] or p.Core) .. " repetido: +" .. p.Units .. " de maestría"
	end
	return "?"
end

-- Geoda: 3 golpes con grietas del color de la rareza real y la revelación. Un clic la salta.
local function geoda(premios)
	capa.Visible = true
	for _, h in ipairs(capa:GetChildren()) do
		if not h:IsA("UICorner") then
			h:Destroy()
		end
	end
	local saltar = false
	local boton = crear("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 20, Parent = capa })
	boton.Activated:Connect(function()
		saltar = true
	end)
	local mejor = premios[1]
	for _, p in ipairs(premios) do
		if Rarity.Multiplier[p.Rarity] > Rarity.Multiplier[mejor.Rarity] then
			mejor = p
		end
	end
	local color = Rarezas.color(mejor.Rarity)
	local piedra = crear("Frame", { BackgroundColor3 = Color3.fromRGB(90, 85, 95), Size = UDim2.fromOffset(160, 160), Position = UDim2.new(0.5, -80, 0.4, -80), ZIndex = 11, Parent = capa },
		{ crear("UICorner", { CornerRadius = UDim.new(1, 0) }), crear("UIStroke", { Color = Color3.fromRGB(50, 48, 55), Thickness = 4 }) })
	local duracion = #premios > 1 and Boxes.Animation.FastSeconds or Boxes.Animation.Seconds
	for golpe = 1, 3 do
		if saltar then
			break
		end
		local grieta = crear("Frame", { BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 12, Parent = piedra,
			Size = UDim2.fromOffset(6, 40 + golpe * 25), Position = UDim2.new(0.5, -3 + (golpe - 2) * 30, 0.5, -(20 + golpe * 12)), Rotation = (golpe - 2) * 35 })
		grieta.Name = "Grieta"
		piedra.Position = UDim2.new(0.5, -84, 0.4, -80)
		task.wait(0.05)
		piedra.Position = UDim2.new(0.5, -80, 0.4, -80)
		task.wait(duracion / 3 - 0.05)
	end
	piedra:Destroy()
	local caja = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 460, 0, 60 + 26 * #premios), Position = UDim2.new(0.5, -230, 0.4, -(30 + 13 * #premios)), ZIndex = 11, Parent = capa },
		{ Componentes.esquinas(12), crear("UIStroke", { Color = color, Thickness = 3 }),
			crear("UIListLayout", { Padding = UDim.new(0, 2), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
			crear("UIPadding", { PaddingTop = UDim.new(0, 10) }) })
	for _, p in ipairs(premios) do
		Componentes.texto({ Size = UDim2.new(1, -20, 0, 24), ZIndex = 12, TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold,
			TextColor3 = Rarezas.color(p.Rarity), Text = (Rarezas.Nombre[p.Rarity] or p.Rarity) .. " · " .. describir(p), Parent = caja })
	end
	Componentes.texto({ Size = UDim2.new(1, -20, 0, 20), ZIndex = 12, TextXAlignment = Enum.TextXAlignment.Center, TextSize = 12, TextColor3 = C.TextoSuave,
		Text = "Clic para cerrar", Parent = caja })
	local cerrar = crear("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", ZIndex = 30, Parent = capa })
	cerrar.Activated:Connect(function()
		capa.Visible = false
	end)
	TweenService:Create(caja, TweenInfo.new(0.2), { Size = caja.Size }):Play()
end

function PanelCajas.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla or not pantalla.Enabled or not perfil then
		return
	end
	local suerte = Estadisticas.derivadas(perfil).Effective.Luck
	titulo.Text = "Geodas (cajas) · zona " .. perfil.Progress.UnlockedZone .. " · " .. Formato.abreviado(perfil.Wallet.Coins) .. " monedas · Suerte " .. Formato.entero(suerte)
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	for i, tipo in ipairs(Boxes.Purchasable) do
		local f = crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, 92), LayoutOrder = i, Parent = lista }, { Componentes.esquinas(8) })
		local precio = Cajas.precio(tipo, perfil)
		local faltaA, faltaB = Cajas.faltan(perfil, tipo)
		Componentes.texto({ Size = UDim2.new(0, 330, 0, 20), Position = UDim2.new(0, 8, 0, 4), Font = Enum.Font.GothamBold, Text = NOMBRE_CAJA[tipo] .. " · " .. Formato.abreviado(precio), Parent = f })
		Componentes.texto({ Size = UDim2.new(0, 330, 0, 16), Position = UDim2.new(0, 8, 0, 24), TextSize = 11, TextColor3 = C.TextoSuave, Text = CONTENIDO[tipo], Parent = f })
		Componentes.texto({ Size = UDim2.new(0, 330, 0, 16), Position = UDim2.new(0, 8, 0, 40), TextSize = 11, TextColor3 = C.XP,
			Text = "Legendario+ garantizado en " .. faltaA .. " · " .. (tipo == "Core" and "Legendario" or "Mítico+") .. " en " .. faltaB, Parent = f })
		local probs = Cajas.probabilidades(tipo, suerte)
		local partes = {}
		for _, r in ipairs(Rarity.Order) do
			if probs[r] and probs[r] > 0 then
				table.insert(partes, (Rarezas.Nombre[r] or r) .. " " .. Formato.decimal(probs[r], probs[r] < 1 and 2 or 1) .. "%")
			end
		end
		Componentes.texto({ Size = UDim2.new(0, 470, 0, 30), Position = UDim2.new(0, 8, 0, 58), TextSize = 10, TextWrapped = true, TextColor3 = C.TextoSuave,
			TextYAlignment = Enum.TextYAlignment.Top, Text = table.concat(partes, " · "), Parent = f })
		for j, n in ipairs({ 1, 10 }) do
			local b = Componentes.boton({ Size = UDim2.new(0, 110, 0, 32), Position = UDim2.new(1, -232 + (j - 1) * 118, 0, 10), TextSize = 12,
				Text = "Abrir " .. n .. "\n" .. Formato.abreviado(precio * n), Parent = f })
			b.BackgroundColor3 = perfil.Wallet.Coins >= precio * n and C.Boton or C.BotonApagado
			b.Activated:Connect(function()
				task.spawn(function()
					local ok, r = Estado.Invocar("Box.Open", tipo, n)
					if not ok then
						avisar(MOTIVOS[r] or ("No se pudo: " .. tostring(r)))
					else
						avisar("")
					end
				end)
			end)
		end
	end
end

function PanelCajas.Iniciar(estado, carpeta)
	Estado = estado
	pantalla = crear("ScreenGui", { Name = "PanelCajas", ResetOnSpawn = false, Enabled = false, DisplayOrder = 5, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 740, 0, 470), Position = UDim2.new(0.5, -370, 0.5, -235), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = C.Borde }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	titulo = Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), TextSize = 17, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	lista = crear("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -64), Position = UDim2.new(0, 0, 0, 36),
		ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })
	capa = crear("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 10, Parent = pantalla })
	carpeta:WaitForChild("Box.Result").OnClientEvent:Connect(function(resultado)
		pantalla.Enabled = true
		task.spawn(geoda, resultado.Prizes)
	end)
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelCajas.Refrescar()
		end
	end)
end

function PanelCajas.Abrir()
	pantalla.Enabled = true
	avisar("")
	PanelCajas.Refrescar()
end

return PanelCajas
