-- Panel de la forja: pestaña «Fabricar» (picos y armas de una zona, por rareza) y «Mejorar» (niveles, ranuras,
-- despertar y reciclar), más el Seguro de carga. Se abre con el aviso de la forja (Notify «OpenForge»).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("Config")
local Rarity = require(Config:WaitForChild("Rarity"))
local Weapons = require(Config:WaitForChild("Weapons"))
local Pickaxes = require(Config:WaitForChild("Pickaxes"))
local Mining = require(Config:WaitForChild("Mining"))
local Forja = require(Shared:WaitForChild("Reglas"):WaitForChild("Forja"))
local Mochila = require(Shared.Reglas:WaitForChild("Mochila"))
local Inventario = require(Shared.Reglas:WaitForChild("Inventario"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))
local Nombres = require(Shared.Visual:WaitForChild("Nombres"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelForja = {}

local MOTIVOS = {
	lejos = "Acércate a la forja.", monedas = "No tienes monedas suficientes.", sin_saldo = "No tienes monedas suficientes.",
	materiales = "Te faltan minerales (cuentan los del banco y los de la mochila).", jefe = "Necesitas materiales de jefe (llegan con los jefes).",
	gema = "Necesitas una gema antigua.", inventario = "Inventario lleno.", zona = "Esa zona no está desbloqueada.",
	maximo = "Ya está al máximo.", equipado = "No puedes reciclar lo que llevas equipado.", rareza = "Esa rareza no se fabrica.",
	frecuencia = "Espera un momento.", error_red = "Error de conexión.",
}

local CLASES = { { Kind = "Pickaxe", Nombre = "Pico" } }
for _, tipo in ipairs(Weapons.EnabledTypes) do
	table.insert(CLASES, { Kind = "Weapon", Type = tipo, Nombre = Nombres.Arma[tipo] or tipo })
end

local Estado, pantalla, contenido, mensaje, titulo
local pestana, clase, zona = "Fabricar", 1, 1
local eleccion = { Minor = 1, Major = 1, Unique = 1, Stat = "Defense" }

local function avisar(t)
	mensaje.Text = t or ""
end

local function pedir(remote, exito, ...)
	local args = { ... }
	local n = select("#", ...)
	task.spawn(function()
		local ok, r = Estado.Invocar(remote, unpack(args, 1, n))
		if ok then
			avisar(exito)
		else
			avisar(MOTIVOS[r] or ("No se pudo: " .. tostring(r)))
		end
	end)
end

local function textoMateriales(perfil, coste)
	local partes = {}
	for _, m in ipairs(coste.Minerals) do
		local nombre = (Mining.Minerals[m.Id] and Mining.Minerals[m.Id].Name) or m.Rarity
		table.insert(partes, Formato.entero(Mochila.existencias(perfil, m.Id)) .. "/" .. m.Units .. " " .. nombre)
	end
	if (coste.Boss or 0) > 0 then
		table.insert(partes, coste.Boss .. " de jefe")
	end
	if (coste.AncientGem or 0) > 0 then
		table.insert(partes, coste.AncientGem .. " gema antigua")
	end
	return table.concat(partes, " · ")
end

local function pasivasElegidas(rareza)
	local salida = {}
	for _, cat in ipairs({ "Unique", "Major", "Minor" }) do
		local n = (Pickaxes.PassiveSlots[rareza] or {})[cat] or 0
		if n > 0 then
			local lista = Pickaxes.Passives[cat]
			table.insert(salida, lista[(eleccion[cat] - 1) % #lista + 1])
		end
	end
	return salida
end

local function limpiar()
	for _, h in ipairs(contenido:GetChildren()) do
		if not h:IsA("UIListLayout") then
			h:Destroy()
		end
	end
end

local function fila(alto, orden)
	return crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, alto), LayoutOrder = orden, Parent = contenido }, { Componentes.esquinas(6) })
end

local function pintarFabricar(perfil)
	local c = CLASES[clase]
	local cab = fila(36, 0)
	local b1 = Componentes.boton({ Size = UDim2.new(0, 150, 0, 28), Position = UDim2.new(0, 4, 0, 4), Text = "◀ " .. c.Nombre .. " ▶", Parent = cab })
	b1.Activated:Connect(function()
		clase = clase % #CLASES + 1
		PanelForja.Refrescar()
	end)
	local b2 = Componentes.boton({ Size = UDim2.new(0, 120, 0, 28), Position = UDim2.new(0, 160, 0, 4), Text = "◀ Zona " .. zona .. " ▶", Parent = cab })
	b2.Activated:Connect(function()
		zona = zona % perfil.Progress.UnlockedZone + 1
		PanelForja.Refrescar()
	end)
	if c.Kind == "Pickaxe" then
		local x = 286
		for _, cat in ipairs({ "Minor", "Major" }) do
			local lista = Pickaxes.Passives[cat]
			local nombre = Rarezas.Pasiva[lista[(eleccion[cat] - 1) % #lista + 1]]
			local b = Componentes.boton({ Size = UDim2.new(0, 130, 0, 28), Position = UDim2.new(0, x, 0, 4), TextSize = 11, BackgroundColor3 = C.BotonApagado,
				Text = (cat == "Minor" and "Menor: " or "Mayor: ") .. nombre, Parent = cab })
			b.Activated:Connect(function()
				eleccion[cat] = eleccion[cat] % #lista + 1
				PanelForja.Refrescar()
			end)
			x = x + 134
		end
	end
	for i, rareza in ipairs(Rarity.Order) do
		local coste = Forja.receta(zona, rareza)
		if coste then
			local f = fila(40, i)
			Componentes.texto({ Size = UDim2.new(0, 110, 1, 0), Position = UDim2.new(0, 8, 0, 0), Text = Rarezas.Nombre[rareza], TextColor3 = Rarezas.color(rareza), Font = Enum.Font.GothamBold, Parent = f })
			Componentes.texto({ Size = UDim2.new(0, 330, 1, 0), Position = UDim2.new(0, 120, 0, 0), TextSize = 11, TextWrapped = true, TextColor3 = C.TextoSuave,
				Text = Formato.abreviado(coste.Coins) .. " monedas · " .. textoMateriales(perfil, coste), Parent = f })
			local b = Componentes.boton({ Size = UDim2.new(0, 96, 0, 28), Position = UDim2.new(1, -102, 0.5, -14), Text = "Fabricar", TextSize = 12, Parent = f })
			local ok = Forja.alcanza(perfil, coste)
			b.BackgroundColor3 = ok and C.Boton or C.BotonApagado
			b.Activated:Connect(function()
				local pasivas, stat = nil, nil
				if c.Kind == "Pickaxe" then
					pasivas = pasivasElegidas(rareza)
					if Pickaxes.CombatStat[rareza] then
						stat = eleccion.Stat
					end
				end
				pedir("Crafting.Craft", "¡Fabricado! Equípalo desde el inventario (B).", c.Kind, c.Type, zona, rareza, pasivas, stat)
			end)
		end
	end
	local seguro = fila(40, 20)
	local cs = Forja.costeSeguro(perfil, 1)
	Componentes.texto({ Size = UDim2.new(0, 430, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextSize = 12, TextWrapped = true,
		Text = "Seguro de carga (tienes " .. (perfil.Consumables.CargoInsurance or 0) .. "): " .. textoMateriales(perfil, cs), Parent = seguro })
	local bs = Componentes.boton({ Size = UDim2.new(0, 96, 0, 28), Position = UDim2.new(1, -102, 0.5, -14), Text = "Fabricar", TextSize = 12, Parent = seguro })
	bs.Activated:Connect(function()
		pedir("Crafting.CraftConsumable", "Seguro de carga fabricado", "CargoInsurance", 1)
	end)
end

local function pintarMejorar(perfil)
	local ids = {}
	for id in pairs(perfil.Items) do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		local ea, eb = Inventario.estaEquipado(perfil, a), Inventario.estaEquipado(perfil, b)
		if ea ~= eb then
			return ea
		end
		return Inventario.potencia(perfil.Items[a]) > Inventario.potencia(perfil.Items[b])
	end)
	for i, id in ipairs(ids) do
		local item = perfil.Items[id]
		local f = fila(46, i)
		local nombre = Inventario.nombreBase(item) .. " (" .. (Rarezas.Nombre[item.Rarity] or item.Rarity) .. ")"
		Componentes.texto({ Size = UDim2.new(0, 250, 0, 20), Position = UDim2.new(0, 8, 0, 2), Text = nombre .. (Inventario.estaEquipado(perfil, id) and "  [equipado]" or ""),
			TextColor3 = Rarezas.color(item.Rarity), Font = Enum.Font.GothamBold, TextSize = 13, Parent = f })
		Componentes.texto({ Size = UDim2.new(0, 250, 0, 18), Position = UDim2.new(0, 8, 0, 24), TextSize = 11, TextColor3 = C.TextoSuave,
			Text = "Potencia " .. Formato.abreviado(Inventario.potencia(item)) .. " · nivel " .. (item.Level or 0) .. "/10 · ranuras " .. (item.Slots or 0) .. "/3" .. (item.Awakened and " · despertado" or ""), Parent = f })
		local x = 262
		for _, accion in ipairs({ { "Level", "+Nivel" }, { "Slot", "+Ranura" }, { "Awaken", "Despertar" } }) do
			local coste = Forja.costeMejora(item, accion[1])
			local b = Componentes.boton({ Size = UDim2.new(0, 92, 0, 36), Position = UDim2.new(0, x, 0.5, -18), TextSize = 10, TextWrapped = true, Parent = f,
				Text = coste and (accion[2] .. "\n" .. Formato.abreviado(coste.Coins)) or (accion[2] .. "\nmáximo") })
			b.BackgroundColor3 = (coste and Forja.alcanza(perfil, coste)) and C.Boton or C.BotonApagado
			b.Activated:Connect(function()
				if coste then
					avisar("Necesita: " .. textoMateriales(perfil, coste))
					pedir("Crafting.Upgrade", "¡Mejorado!", id, accion[1])
				end
			end)
			x = x + 96
		end
		if not Inventario.estaEquipado(perfil, id) then
			local r = Componentes.boton({ Size = UDim2.new(0, 70, 0, 36), Position = UDim2.new(1, -76, 0.5, -18), Text = "Reciclar", TextSize = 11, BackgroundColor3 = C.Peligro, Parent = f })
			r.Activated:Connect(function()
				pedir("Crafting.Recycle", "Reciclado: el 30 % de sus minerales vuelve al banco", id)
			end)
		end
	end
end

function PanelForja.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla or not pantalla.Enabled or not perfil then
		return
	end
	zona = math.clamp(zona, 1, perfil.Progress.UnlockedZone)
	titulo.Text = "Forja · " .. pestana .. "   ·   " .. Formato.abreviado(perfil.Wallet.Coins) .. " monedas"
	limpiar()
	if pestana == "Fabricar" then
		pintarFabricar(perfil)
	else
		pintarMejorar(perfil)
	end
end

function PanelForja.Iniciar(estado)
	Estado = estado
	pantalla = crear("ScreenGui", { Name = "PanelForja", ResetOnSpawn = false, Enabled = false, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 720, 0, 500), Position = UDim2.new(0.5, -360, 0.5, -250), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = C.Borde }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	titulo = Componentes.texto({ Size = UDim2.new(1, -260, 0, 28), Text = "Forja", TextSize = 20, Font = Enum.Font.GothamBold, Parent = marco })
	for i, nombre in ipairs({ "Fabricar", "Mejorar" }) do
		local b = Componentes.boton({ Size = UDim2.new(0, 100, 0, 28), Position = UDim2.new(1, -250 + (i - 1) * 106, 0, 0), Text = nombre, TextSize = 13, Parent = marco })
		b.Activated:Connect(function()
			pestana = nombre
			avisar("")
			PanelForja.Refrescar()
		end)
	end
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	contenido = crear("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -64), Position = UDim2.new(0, 0, 0, 36),
		ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelForja.Refrescar()
		end
	end)
end

function PanelForja.Abrir()
	pantalla.Enabled = true
	avisar("")
	PanelForja.Refrescar()
end

return PanelForja
