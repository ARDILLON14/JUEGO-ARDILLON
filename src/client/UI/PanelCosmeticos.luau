-- Panel de Cosméticos y Cristales (puesto «Cosméticos» de la plaza o tecla L).
-- Estelas y auras (solo aspecto), servicios con Cristales y paquetes de Cristales con Robux.
-- Nada de lo que se vende aquí da poder (B6 9.2).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared:WaitForChild("Config"):WaitForChild("Monetization"))
local Tienda = require(Shared:WaitForChild("Reglas"):WaitForChild("Tienda"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelCosmeticos = {}

local CRISTAL = Color3.fromRGB(190, 240, 255)
local NOMBRE_SERVICIO = {
	PetStorage = "Almacén de mascotas +10",
	ThirdIncubator = "Tercera incubadora",
}
local Estado, pantalla, lista, saldo, mensaje

local function decir(ok, r, bien)
	mensaje.Text = ok and bien or ("No se pudo: " .. tostring(r))
	mensaje.TextColor3 = ok and C.XP or C.Peligro
end

local function fila(orden, alto)
	return crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, alto or 44), LayoutOrder = orden, Parent = lista }, { Componentes.esquinas(8) })
end

local function titulo(orden, texto)
	local t = Componentes.texto({ Size = UDim2.new(1, -8, 0, 22), LayoutOrder = orden, Font = Enum.Font.GothamBold, TextSize = 15, Text = texto, Parent = lista })
	t.Name = "Titulo"
end

function PanelCosmeticos.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla.Enabled or not perfil then
		return
	end
	saldo.Text = "Cristales: " .. Formato.entero(perfil.Wallet.Crystals or 0) .. "    Monedas: " .. Formato.abreviado(perfil.Wallet.Coins or 0)
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("Frame") or h.Name == "Titulo" then
			h:Destroy()
		end
	end
	local orden = 0
	local function siguiente()
		orden = orden + 1
		return orden
	end
	titulo(siguiente(), "Estelas y auras")
	local equipados = perfil.Cosmetics and perfil.Cosmetics.Equipped or {}
	for _, c in ipairs(Monetization.Cosmetics) do
		local f = fila(siguiente())
		crear("Frame", { BackgroundColor3 = Color3.fromRGB(c.Color[1], c.Color[2], c.Color[3]), Size = UDim2.fromOffset(26, 26), Position = UDim2.new(0, 10, 0.5, -13), Parent = f }, { Componentes.esquinas(13) })
		Componentes.texto({ Size = UDim2.new(0, 260, 1, 0), Position = UDim2.new(0, 46, 0, 0), Parent = f,
			Text = c.Name .. "  (" .. (c.Kind == "Trail" and "estela" or "aura") .. ")" })
		local b = Componentes.boton({ Size = UDim2.new(0, 170, 0, 32), Position = UDim2.new(1, -178, 0.5, -16), TextSize = 12, Parent = f })
		if Tienda.tiene(perfil, c.Id) then
			local puesto = equipados[c.Kind] == c.Id
			b.Text = puesto and "Quitar" or "Equipar"
			b.BackgroundColor3 = puesto and C.BotonApagado or C.Boton
			b.Activated:Connect(function()
				task.spawn(function()
					local ok, r = Estado.Invocar("Cosmetic.Equip", c.Kind, puesto and "" or c.Id)
					decir(ok, r, puesto and "Quitado." or "¡Equipado!")
				end)
			end)
		else
			local precio = Tienda.precio(perfil, c.Id)
			b.Text = precio.Moneda == "Crystals" and (Formato.entero(precio.Cantidad) .. " Cristales") or (Formato.abreviado(precio.Cantidad) .. " monedas")
			b.BackgroundColor3 = precio.Moneda == "Crystals" and Color3.fromRGB(70, 120, 150) or Color3.fromRGB(150, 120, 40)
			b.Activated:Connect(function()
				task.spawn(function()
					local ok, r = Estado.Invocar("Cosmetic.Buy", c.Id)
					decir(ok, r, "¡Comprado y equipado!")
				end)
			end)
		end
	end
	titulo(siguiente(), "Servicios")
	for _, id in ipairs({ "PetStorage", "ThirdIncubator" }) do
		local s = Monetization.Services[id]
		local f = fila(siguiente())
		local detalle = id == "PetStorage" and ("ahora " .. tostring(perfil.PetStorage or 30) .. " / " .. s.Max) or ""
		Componentes.texto({ Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(0, 10, 0, 0), Parent = f, Text = NOMBRE_SERVICIO[id] .. "  " .. detalle })
		local b = Componentes.boton({ Size = UDim2.new(0, 170, 0, 32), Position = UDim2.new(1, -178, 0.5, -16), TextSize = 12, Parent = f,
			Text = s.Crystals .. " Cristales", BackgroundColor3 = Color3.fromRGB(70, 120, 150) })
		b.Activated:Connect(function()
			task.spawn(function()
				local ok, r = Estado.Invocar("Shop.CrystalService", id)
				decir(ok, r, "¡Listo!")
			end)
		end)
	end
	titulo(siguiente(), "Cristales")
	for _, p in ipairs(Monetization.CrystalProducts) do
		local f = fila(siguiente())
		Componentes.texto({ Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextColor3 = CRISTAL, Parent = f, Text = Formato.entero(p.Crystals) .. " Cristales" })
		local b = Componentes.boton({ Size = UDim2.new(0, 170, 0, 32), Position = UDim2.new(1, -178, 0.5, -16), TextSize = 12, Parent = f,
			Text = p.ProductId ~= 0 and "Comprar con Robux" or "Próximamente", BackgroundColor3 = p.ProductId ~= 0 and C.Boton or C.BotonApagado })
		b.Activated:Connect(function()
			if p.ProductId == 0 then
				decir(false, "aún no está a la venta (falta crear el producto en Roblox)")
				return
			end
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, p.ProductId)
		end)
	end
end

function PanelCosmeticos.Iniciar(estado)
	Estado = estado
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	pantalla = crear("ScreenGui", { Name = "PanelCosmeticos", ResetOnSpawn = false, Enabled = false, Parent = gui })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 560, 0, 440), Position = UDim2.new(0.5, -280, 0.5, -220), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = CRISTAL }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Cosméticos y Cristales", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	saldo = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 32), TextSize = 13, TextColor3 = CRISTAL, Parent = marco })
	lista = crear("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -86), Position = UDim2.new(0, 0, 0, 56),
		CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }) })
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), TextColor3 = C.TextoSuave, TextSize = 13,
		Text = "Solo aspecto: nada de esto da poder.", Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelCosmeticos.Refrescar()
		end
	end)
end

function PanelCosmeticos.Abrir()
	pantalla.Enabled = true
	PanelCosmeticos.Refrescar()
end

function PanelCosmeticos.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	PanelCosmeticos.Refrescar()
end

return PanelCosmeticos
