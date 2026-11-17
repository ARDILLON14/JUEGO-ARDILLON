-- Panel de la tienda del mercader: vender minerales (de la mochila y del banco) y ampliar la mochila.
-- Se abre con el ProximityPrompt del mercader (el servidor envía Notify { Kind = "OpenShop" }).
-- Los precios mostrados son los mismos que calcula el servidor (Shared/Reglas/Mochila); cobra y paga el servidor.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Mining = require(Shared:WaitForChild("Config"):WaitForChild("Mining"))
local Rarity = require(Shared.Config:WaitForChild("Rarity"))
local Mochila = require(Shared:WaitForChild("Reglas"):WaitForChild("Mochila"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))
local Inventario = require(Shared.Reglas:WaitForChild("Inventario"))
local Economia = require(Shared:WaitForChild("Formulas"):WaitForChild("Economia"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelTienda = {}

local MOTIVOS = {
	lejos = "Acércate al mercader.",
	sin_existencias = "Ya no te queda ese mineral.",
	sin_saldo = "No tienes monedas suficientes.",
	zona = "Necesitas desbloquear una zona más profunda.",
	maxima = "Ya tienes la mochila más grande.",
	frecuencia = "Espera un momento.",
	error_red = "Error de conexión. Inténtalo de nuevo.",
}

local Estado, pantalla, lista, resumen, mensaje, botonTodo, botonMochila

local function minerales()
	local perfil = Estado.Perfil
	local filas = {}
	if not perfil then
		return filas
	end
	local vistos = {}
	for _, tabla in ipairs({ perfil.Minerals.Carried, perfil.Minerals.Banked }) do
		for id in pairs(tabla) do
			if not vistos[id] and Mining.Minerals[id] then
				vistos[id] = true
				local m = Mining.Minerals[id]
				table.insert(filas, {
					Id = id, Name = m.Name, Zone = m.Zone, Rarity = m.Rarity,
					Carried = perfil.Minerals.Carried[id] or 0, Banked = perfil.Minerals.Banked[id] or 0,
					Price = Mochila.precioUnidad(id),
				})
			end
		end
	end
	table.sort(filas, function(a, b)
		if a.Zone ~= b.Zone then
			return a.Zone < b.Zone
		end
		return Rarity.Multiplier[a.Rarity] < Rarity.Multiplier[b.Rarity]
	end)
	return filas
end

local function avisar(texto)
	mensaje.Text = texto or ""
end

local function vender(id, cantidad)
	task.spawn(function()
		local ok, r = Estado.Invocar("Shop.Sell", id, cantidad)
		if ok then
			avisar("Vendido por " .. Formato.abreviado(r.Coins) .. " monedas")
		else
			avisar(MOTIVOS[r] or ("No se pudo: " .. tostring(r)))
		end
	end)
end

function PanelTienda.Refrescar()
	if not pantalla or not pantalla.Enabled then
		return
	end
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	local filas, total = minerales(), 0
	for i, f in ipairs(filas) do
		local unidades = f.Carried + f.Banked
		local valor = math.floor(f.Price * unidades + 1e-9)
		total = total + valor
		local fila = crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, 34), LayoutOrder = i, Parent = lista }, { Componentes.esquinas(6) })
		Componentes.texto({ Size = UDim2.new(0, 190, 1, 0), Position = UDim2.new(0, 8, 0, 0), Text = f.Name, TextColor3 = Rarezas.color(f.Rarity), Font = Enum.Font.GothamBold, Parent = fila })
		Componentes.texto({ Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 200, 0, 0), TextSize = 12, TextColor3 = C.TextoSuave,
			Text = Formato.entero(f.Carried) .. " en mochila · " .. Formato.entero(f.Banked) .. " en banco", Parent = fila })
		Componentes.texto({ Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(0, 352, 0, 0), TextSize = 12, Text = Formato.abreviado(f.Price) .. " c/u", Parent = fila })
		local b = Componentes.boton({ Size = UDim2.new(0, 110, 0, 26), Position = UDim2.new(1, -116, 0.5, -13), TextSize = 12,
			Text = "Vender " .. Formato.abreviado(valor), Parent = fila })
		b.Activated:Connect(function()
			vender(f.Id, unidades)
		end)
	end
	if #filas == 0 then
		local vacia = crear("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Parent = lista })
		Componentes.texto({ Size = UDim2.fromScale(1, 1), Text = "No tienes minerales. Ve a picar a la Cantera del Alba.", TextColor3 = C.TextoSuave, Parent = vacia })
	end
	-- Objetos que no se llevan equipados: se venden por el 10 % de su coste de fabricación.
	local n = #filas
	for id, item in pairs(Estado.Perfil.Items) do
		if not Inventario.estaEquipado(Estado.Perfil, id) and item.Rarity ~= "Celestial" then
			n = n + 1
			local precio = Economia.gearSellPrice(item.Zone, item.Rarity)
			local fila = crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, 34), LayoutOrder = 1000 + n, Parent = lista }, { Componentes.esquinas(6) })
			Componentes.texto({ Size = UDim2.new(0, 380, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextColor3 = Rarezas.color(item.Rarity), Font = Enum.Font.GothamBold, Parent = fila,
				Text = Inventario.nombreBase(item) .. " (" .. (Rarezas.Nombre[item.Rarity] or item.Rarity) .. ")" })
			local b = Componentes.boton({ Size = UDim2.new(0, 110, 0, 26), Position = UDim2.new(1, -116, 0.5, -13), TextSize = 12, BackgroundColor3 = C.Peligro,
				Text = "Vender " .. Formato.abreviado(precio), Parent = fila })
			b.Activated:Connect(function()
				task.spawn(function()
					local ok, r = Estado.Invocar("Shop.Sell", nil, nil, id)
					avisar(ok and ("Vendido por " .. Formato.abreviado(r.Coins) .. " monedas") or (MOTIVOS[r] or ("No se pudo: " .. tostring(r))))
				end)
			end)
		end
	end
	lista.CanvasSize = UDim2.new(0, 0, 0, n * 38)
	resumen.Text = "Valor total: " .. Formato.abreviado(total) .. " monedas   ·   Tienes " .. Formato.abreviado(Estado.Perfil and Estado.Perfil.Wallet.Coins or 0)
	botonTodo.Text = "Vender todo (" .. Formato.abreviado(total) .. ")"
	local perfil = Estado.Perfil
	local s = perfil and Mochila.siguienteAmpliacion(perfil)
	if not s then
		botonMochila.Text = "Mochila al máximo"
		botonMochila.BackgroundColor3 = C.BotonApagado
	elseif perfil.Progress.UnlockedZone < s.Zone then
		botonMochila.Text = "Mochila de " .. s.Capacity .. ": desbloquea la zona " .. s.Zone
		botonMochila.BackgroundColor3 = C.BotonApagado
	else
		botonMochila.Text = "Ampliar mochila a " .. s.Capacity .. " (" .. Formato.abreviado(s.Price) .. ")"
		botonMochila.BackgroundColor3 = C.Boton
	end
end

function PanelTienda.Iniciar(estado)
	Estado = estado
	pantalla = crear("ScreenGui", { Name = "PanelTienda", ResetOnSpawn = false, Enabled = false, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", {
		BackgroundColor3 = C.Panel, Size = UDim2.new(0, 600, 0, 460), Position = UDim2.new(0.5, -300, 0.5, -230), Parent = pantalla,
	}, {
		Componentes.esquinas(12),
		crear("UIStroke", { Color = C.Borde, Thickness = 1 }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Mercader", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	resumen = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 32), TextColor3 = C.XP, Parent = marco })
	lista = crear("ScrollingFrame", {
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -150), Position = UDim2.new(0, 0, 0, 58),
		ScrollBarThickness = 6, CanvasSize = UDim2.new(), Parent = marco,
	}, { crear("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
	botonTodo = Componentes.boton({ Size = UDim2.new(0, 230, 0, 36), Position = UDim2.new(0, 0, 1, -64), BackgroundColor3 = C.XP, TextColor3 = C.Fondo, Parent = marco })
	botonTodo.Activated:Connect(function()
		for _, f in ipairs(minerales()) do
			vender(f.Id, f.Carried + f.Banked)
		end
	end)
	botonMochila = Componentes.boton({ Size = UDim2.new(0, 320, 0, 36), Position = UDim2.new(1, -320, 1, -64), Parent = marco })
	botonMochila.Activated:Connect(function()
		task.spawn(function()
			local ok, r = Estado.Invocar("Shop.BuyBackpack")
			if ok then
				avisar("Mochila ampliada a " .. tostring(r.Capacity))
			else
				avisar(MOTIVOS[r] or ("No se pudo: " .. tostring(r)))
			end
		end)
	end)
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 1, -20), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelTienda.Refrescar()
		end
	end)
	-- Se cierra al alejarse del mercader.
	task.spawn(function()
		while true do
			task.wait(1)
			if pantalla.Enabled then
				local personaje = Players.LocalPlayer.Character
				local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
				local cerca = false
				for _, p in ipairs(game:GetService("CollectionService"):GetTagged("Mercader")) do
					if raiz and p:IsA("BasePart") and (p.Position - raiz.Position).Magnitude <= Mining.Merchant.Radius + 8 then
						cerca = true
					end
				end
				if not cerca then
					pantalla.Enabled = false
				end
			end
		end
	end)
end

function PanelTienda.Abrir()
	pantalla.Enabled = true
	avisar("")
	PanelTienda.Refrescar()
end

return PanelTienda
