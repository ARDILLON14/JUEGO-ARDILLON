-- Panel de inventario (tecla B): pico equipado con sus pasivas, mochila y banco. Solo lectura.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Mining = require(Shared:WaitForChild("Config"):WaitForChild("Mining"))
local Rarity = require(Shared.Config:WaitForChild("Rarity"))
local Mochila = require(Shared:WaitForChild("Reglas"):WaitForChild("Mochila"))
local Inventario = require(Shared.Reglas:WaitForChild("Inventario"))
local Mineria = require(Shared:WaitForChild("Formulas"):WaitForChild("Mineria"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelInventario = {}

local DESCRIPCION = {
	SureStrike = "cada 10.º golpe hace daño doble",
	BladeEcho = "10 % de golpear también otro depósito cercano",
	LightBallast = "la carga pesa un 15 % menos en Zonas Fracturadas",
	RunicSonar = "resalta depósitos Épicos o mejores a 30 studs",
	OpenVein = "10 % de sacar una unidad más",
	SeismicWave = "cada 12 s daña también a los depósitos cercanos",
	ChainFracture = "tras agotar uno, el siguiente golpe quita un 25 % extra",
	StellarEcho = "5 % de que el depósito reaparezca al instante",
}

local Estado, pantalla, cabecera, columnaMochila, columnaBanco, listaObjetos, mensaje

local function rellenar(columna, tabla)
	for _, h in ipairs(columna:GetChildren()) do
		if h:IsA("TextLabel") and h.Name ~= "Titulo" then
			h:Destroy()
		end
	end
	local filas = {}
	for id, n in pairs(tabla) do
		local m = Mining.Minerals[id]
		if m then
			table.insert(filas, { m = m, n = n })
		end
	end
	table.sort(filas, function(a, b)
		if a.m.Zone ~= b.m.Zone then
			return a.m.Zone < b.m.Zone
		end
		return Rarity.Multiplier[a.m.Rarity] < Rarity.Multiplier[b.m.Rarity]
	end)
	for i, f in ipairs(filas) do
		Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), LayoutOrder = i + 1, TextSize = 13, TextColor3 = Rarezas.color(f.m.Rarity),
			Text = Formato.entero(f.n) .. " × " .. f.m.Name, Parent = columna })
	end
	if #filas == 0 then
		Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), LayoutOrder = 2, TextSize = 13, TextColor3 = C.TextoSuave, Text = "Vacío", Parent = columna })
	end
end

function PanelInventario.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla or not pantalla.Enabled or not perfil then
		return
	end
	local pico = Inventario.equipado(perfil, "Pickaxe")
	if pico then
		local pasivas = {}
		for _, p in ipairs(pico.Passives or {}) do
			table.insert(pasivas, (Rarezas.Pasiva[p] or p) .. ": " .. (DESCRIPCION[p] or ""))
		end
		cabecera.Text = Inventario.nombreBase(pico) .. " (" .. (Rarezas.Nombre[pico.Rarity] or pico.Rarity) .. ")"
			.. "   ·   Potencia " .. Formato.entero(Inventario.potencia(pico))
			.. "   ·   " .. Formato.decimal(Mineria.pickHitsPerSecond(pico.Rarity, 0), 2) .. " golpes/s"
			.. (#pasivas > 0 and ("\n" .. table.concat(pasivas, "\n")) or "\nSin pasivas")
		cabecera.TextColor3 = Rarezas.color(pico.Rarity)
	else
		cabecera.Text = "Sin pico equipado"
	end
	columnaMochila:FindFirstChild("Titulo").Text = "Mochila " .. Formato.entero(Mochila.carga(perfil)) .. " / " .. Formato.entero(Mochila.capacidad(perfil))
	columnaBanco:FindFirstChild("Titulo").Text = "Banco " .. Formato.entero(Mochila.enBanco(perfil))
	rellenar(columnaMochila, perfil.Minerals.Carried)
	rellenar(columnaBanco, perfil.Minerals.Banked)

	-- Objetos: equipar picos y armas.
	for _, h in ipairs(listaObjetos:GetChildren()) do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	local ids = {}
	for id in pairs(perfil.Items) do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		local ia, ib = perfil.Items[a], perfil.Items[b]
		if ia.Kind ~= ib.Kind then
			return ia.Kind == "Pickaxe"
		end
		return Inventario.potencia(ia) > Inventario.potencia(ib)
	end)
	local huevos = 0
	for _ in pairs(perfil.Eggs or {}) do
		huevos = huevos + 1
	end
	listaObjetos:FindFirstChild("Titulo").Text = "Objetos " .. #ids .. "   ·   Huevos " .. huevos .. "   ·   Seguros de carga " .. (perfil.Consumables.CargoInsurance or 0)
	for i, id in ipairs(ids) do
		local item = perfil.Items[id]
		local f = Componentes.crear("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 26), LayoutOrder = i + 1, Parent = listaObjetos })
		Componentes.texto({ Size = UDim2.new(1, -110, 1, 0), TextSize = 12, TextColor3 = Rarezas.color(item.Rarity), Parent = f,
			Text = Inventario.nombreBase(item) .. " (" .. (Rarezas.Nombre[item.Rarity] or item.Rarity) .. ") · potencia " .. Formato.abreviado(Inventario.potencia(item))
				.. (item.Level and item.Level > 0 and (" · +" .. item.Level) or "") })
		if Inventario.estaEquipado(perfil, id) then
			Componentes.texto({ Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -100, 0, 0), TextSize = 12, TextColor3 = C.XP, Text = "Equipado", Parent = f })
		else
			local b = Componentes.boton({ Size = UDim2.new(0, 96, 0, 22), Position = UDim2.new(1, -100, 0, 2), TextSize = 12, Text = "Equipar", Parent = f })
			b.Activated:Connect(function()
				task.spawn(function()
					local ok, motivo = Estado.Invocar("Inventory.Equip", id, item.Kind)
					local textos = { nivel = "Necesitas más nivel para ese objeto.", mineria = "Necesitas más Minería para ese pico.", en_combate = "No puedes cambiar de equipo en combate." }
					mensaje.Text = ok and "Equipado" or (textos[motivo] or ("No se pudo: " .. tostring(motivo)))
				end)
			end)
		end
	end
end

local function columna(posicion, padre)
	local c = crear("ScrollingFrame", {
		BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, BorderSizePixel = 0, Size = UDim2.new(0.5, -6, 0, 190),
		Position = posicion, ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = padre,
	}, {
		Componentes.esquinas(8),
		crear("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6) }),
	})
	Componentes.texto({ Name = "Titulo", Size = UDim2.new(1, 0, 0, 22), LayoutOrder = 1, Font = Enum.Font.GothamBold, Parent = c })
	return c
end

function PanelInventario.Iniciar(estado)
	Estado = estado
	pantalla = crear("ScreenGui", { Name = "PanelInventario", ResetOnSpawn = false, Enabled = false, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", {
		BackgroundColor3 = C.Panel, Size = UDim2.new(0, 600, 0, 600), Position = UDim2.new(0.5, -300, 0.5, -300), Parent = pantalla,
	}, {
		Componentes.esquinas(12),
		crear("UIStroke", { Color = C.Borde, Thickness = 1 }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Inventario", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	cabecera = Componentes.texto({ Size = UDim2.new(1, 0, 0, 64), Position = UDim2.new(0, 0, 0, 32), TextSize = 13, TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top, Font = Enum.Font.GothamBold, Parent = marco })
	columnaMochila = columna(UDim2.new(0, 0, 0, 104), marco)
	columnaBanco = columna(UDim2.new(0.5, 6, 0, 104), marco)
	listaObjetos = columna(UDim2.new(0, 0, 0, 302), marco)
	listaObjetos.Size = UDim2.new(1, 0, 1, -330)
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), TextSize = 13, TextColor3 = C.TextoSuave, Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelInventario.Refrescar()
		end
	end)
end

function PanelInventario.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	PanelInventario.Refrescar()
end

return PanelInventario
