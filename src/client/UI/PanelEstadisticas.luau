-- Panel de estadísticas: reparto de puntos, efecto de cada estadística y reinicio.
-- Las cifras se calculan con las mismas reglas que el servidor (Shared/Reglas), pero solo para mostrar:
-- el servidor vuelve a comprobarlo todo.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Estadisticas = require(Shared:WaitForChild("Reglas"):WaitForChild("Estadisticas"))
local StatsConfig = require(Shared:WaitForChild("Config"):WaitForChild("Stats"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelEstadisticas = {}

local NOMBRES = {
	Strength = "Fuerza", Vitality = "Vitalidad", Defense = "Defensa", Speed = "Velocidad",
	Energy = "Energía", Mining = "Minería", Luck = "Suerte", PetMastery = "Dominio de mascotas",
}

local MOTIVOS = {
	sin_puntos = "No tienes puntos libres.",
	tope = "Esa estadística ya está al máximo (1.000).",
	en_combate = "No puedes reiniciar en combate.",
	lugar = "El reinicio solo se hace en la ciudad.",
	nada_que_reiniciar = "No tienes puntos asignados.",
	sin_tomo = "No tienes Tomos de Reajuste.",
	sin_saldo = "No tienes monedas suficientes.",
	frecuencia = "Espera un momento.",
	error_red = "Error de conexión. Inténtalo de nuevo.",
}

local function efecto(nombre, d)
	if nombre == "Strength" then
		return "Daño ×" .. Formato.decimal(d.Damage, 2)
	elseif nombre == "Vitality" then
		return "Vida " .. Formato.entero(d.MaxHealth)
	elseif nombre == "Defense" then
		return "Reduce " .. Formato.porcentaje(d.DefensePvE, 1) .. " (PvP " .. Formato.porcentaje(d.DefensePvP, 1) .. ")"
	elseif nombre == "Speed" then
		local texto = "Ataque ×" .. Formato.decimal(d.AttackSpeed, 2) .. " · Mov. " .. Formato.decimal(d.WalkSpeed, 1)
		if d.BlinkUnlocked then
			texto = texto .. " · Parpadeo"
		end
		return texto
	elseif nombre == "Energy" then
		return "Energía " .. Formato.entero(d.MaxEnergy) .. " · " .. Formato.decimal(d.EnergyRegenCombat, 1) .. "/s en combate"
	elseif nombre == "Mining" then
		return "Pico ×" .. Formato.decimal(d.Mining, 2)
	elseif nombre == "Luck" then
		return "Suerte ×" .. Formato.decimal(d.Luck, 2)
	elseif nombre == "PetMastery" then
		return "Mascotas ×" .. Formato.decimal(d.PetPower, 2)
	end
	return ""
end

function PanelEstadisticas.Iniciar(Estado)
	local pantalla = crear("ScreenGui", {
		Name = "PanelEstadisticas",
		ResetOnSpawn = false,
		Enabled = false,
		Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	})
	local marco = crear("Frame", {
		BackgroundColor3 = C.Panel,
		Size = UDim2.new(0, 560, 0, 470),
		Position = UDim2.new(0.5, -280, 0.5, -235),
		Parent = pantalla,
	}, {
		Componentes.esquinas(12),
		crear("UIStroke", { Color = C.Borde, Thickness = 1 }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Estadísticas", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	local libres = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 32), TextColor3 = C.XP, Parent = marco })
	local mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 1, -18), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })

	local lista = crear("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 8 * 40),
		Position = UDim2.new(0, 0, 0, 58),
		Parent = marco,
	}, { crear("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

	local function avisar(texto)
		mensaje.Text = texto or ""
	end

	local function pedir(remote, ...)
		local args = { ... }
		task.spawn(function()
			local ok, motivo = Estado.Invocar(remote, unpack(args))
			if ok then
				avisar("")
			else
				avisar(MOTIVOS[motivo] or ("No se pudo: " .. tostring(motivo)))
			end
		end)
	end

	local filas = {}
	for i, nombre in ipairs(StatsConfig.Names) do
		local fila = crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, 0, 0, 36), LayoutOrder = i, Parent = lista }, { Componentes.esquinas(6) })
		Componentes.texto({ Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 8, 0, 0), Text = NOMBRES[nombre], Font = Enum.Font.GothamBold, Parent = fila })
		local valor = Componentes.texto({ Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(0, 158, 0, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = fila })
		local detalle = Componentes.texto({ Size = UDim2.new(0, 190, 1, 0), Position = UDim2.new(0, 218, 0, 0), TextColor3 = C.TextoSuave, TextSize = 12, TextWrapped = true, Parent = fila })
		local botones = {}
		for j, paso in ipairs({ 1, 10, "Máx" }) do
			local b = Componentes.boton({
				Size = UDim2.new(0, 38, 0, 26),
				Position = UDim2.new(1, -42 * (4 - j), 0.5, -13),
				Text = paso == "Máx" and "Máx" or ("+" .. paso),
				TextSize = 12,
				Parent = fila,
			})
			b.Activated:Connect(function()
				local perfil = Estado.Perfil
				if not perfil then
					return
				end
				local n = paso
				if paso == "Máx" then
					n = Estadisticas.maximoAsignable(perfil, nombre)
				else
					n = math.min(paso, Estadisticas.maximoAsignable(perfil, nombre))
				end
				if n >= 1 then
					pedir("Stats.Allocate", nombre, n)
				end
			end)
			table.insert(botones, b)
		end
		filas[nombre] = { Valor = valor, Detalle = detalle, Botones = botones }
	end

	local reiniciar = Componentes.boton({ Size = UDim2.new(0, 250, 0, 34), Position = UDim2.new(0, 0, 1, -58), BackgroundColor3 = C.Peligro, Parent = marco })
	local tomo = Componentes.boton({ Size = UDim2.new(0, 200, 0, 34), Position = UDim2.new(0, 260, 1, -58), BackgroundColor3 = C.BotonApagado, Parent = marco })
	local confirmando = false
	reiniciar.Activated:Connect(function()
		if not confirmando then
			confirmando = true
			reiniciar.Text = "¿Seguro? Pulsa otra vez"
			task.delay(3, function()
				confirmando = false
				PanelEstadisticas.Refrescar()
			end)
			return
		end
		confirmando = false
		pedir("Stats.Respec", false)
	end)
	tomo.Activated:Connect(function()
		pedir("Stats.Respec", true)
	end)

	function PanelEstadisticas.Refrescar()
		local perfil = Estado.Perfil
		if not perfil then
			return
		end
		local d = Estadisticas.derivadas(perfil)
		local nLibres = Estadisticas.puntosLibres(perfil)
		libres.Text = "Puntos libres: " .. Formato.entero(nLibres) .. "   ·   Nivel " .. Formato.entero(perfil.Progress.Level)
		for nombre, f in pairs(filas) do
			f.Valor.Text = Formato.entero(perfil.Stats.Allocated[nombre] or 0)
			f.Detalle.Text = efecto(nombre, d)
			local puede = Estadisticas.maximoAsignable(perfil, nombre) > 0
			for _, b in ipairs(f.Botones) do
				b.BackgroundColor3 = puede and C.Boton or C.BotonApagado
				b.AutoButtonColor = puede
			end
		end
		if not confirmando then
			local coste = Estadisticas.costeReinicio(perfil)
			reiniciar.Text = coste == 0 and "Reiniciar puntos (gratis)" or ("Reiniciar puntos (" .. Formato.entero(coste) .. " monedas)")
		end
		local tomos = (perfil.Consumables and perfil.Consumables.RespecTome) or 0
		tomo.Text = "Usar Tomo de Reajuste (" .. tostring(tomos) .. ")"
		tomo.Visible = tomos > 0
	end

	Estado.Cambio:Connect(function(que)
		if que == "Perfil" and pantalla.Enabled then
			PanelEstadisticas.Refrescar()
		end
	end)

	function PanelEstadisticas.Alternar()
		pantalla.Enabled = not pantalla.Enabled
		if pantalla.Enabled then
			avisar("")
			PanelEstadisticas.Refrescar()
		end
	end
end

return PanelEstadisticas
