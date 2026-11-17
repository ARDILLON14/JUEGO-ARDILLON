-- Panel de mascotas (tecla M): huevos e incubadoras, mascotas con nivel y fase, equipar en los espacios, Nido,
-- evolucionar y liberar. La postura (Recolectar / Proteger) se cambia con T.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Pets = require(Shared:WaitForChild("Config"):WaitForChild("Pets"))
local Mascotas = require(Shared:WaitForChild("Formulas"):WaitForChild("Mascotas"))
local Criadero = require(Shared:WaitForChild("Reglas"):WaitForChild("Criadero"))
local Rarezas = require(Shared:WaitForChild("Visual"):WaitForChild("Rarezas"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelMascotas = {}

local FASE = { Hatchling = "Cría", Unleashed = "Forma desatada", UnleashedMax = "Forma máxima" }
local ROL = { Offense = "Ofensiva", Control = "Control", Defense = "Defensa", Support = "Apoyo", Mining = "Minería" }
local PASIVA = {
	ExtractSpeed = "+%d %% velocidad de extracción", PickupRadius = "+%d %% radio de recogida", BackpackUnits = "+%d de mochila",
	ExtraUnitChance = "+%d %% de unidad extra", RevealDeposits = "revela Épicos a %d studs", DetectChests = "detecta cofres a %d studs",
}
local MOTIVOS = {
	ocupada = "Esa incubadora está ocupada.", no_lista = "Aún no ha terminado de incubarse.", almacen = "Almacén de mascotas lleno (30).",
	hueco = "Ese espacio no está desbloqueado.", equipada = "Quita la mascota de su espacio antes.", en_uso = "No puedes liberar una mascota equipada o en el Nido.",
	nivel = "Necesita nivel 50 (o 100 para la forma máxima).", fragmentos = "Faltan fragmentos de su elemento.", jefe = "Faltan materiales de jefe.",
	monedas = "No tienes monedas suficientes.", sin_saldo = "No tienes monedas suficientes.", maxima = "Ya está en su forma máxima.", frecuencia = "Espera un momento.",
}

local Estado, pantalla, lista, cabecera, mensaje

local function avisar(t)
	mensaje.Text = t or ""
end

local function pedir(remote, exito, ...)
	local args, n = { ... }, select("#", ...)
	task.spawn(function()
		local ok, r = Estado.Invocar(remote, unpack(args, 1, n))
		avisar(ok and exito or (MOTIVOS[r] or ("No se pudo: " .. tostring(r))))
	end)
end

local function textoPasiva(e)
	local p = e.GatherPassive
	local v = p.Value or p.Studs or 0
	if p.Kind == "ExtractSpeed" or p.Kind == "PickupRadius" or p.Kind == "ExtraUnitChance" then
		v = math.floor(v * 100 + 0.5)
	end
	return string.format(PASIVA[p.Kind] or p.Kind, v)
end

local function fila(alto, orden)
	return crear("Frame", { BackgroundColor3 = C.Fondo, BackgroundTransparency = 0.3, Size = UDim2.new(1, -8, 0, alto), LayoutOrder = orden, Parent = lista }, { Componentes.esquinas(6) })
end

local function titulo(texto, orden)
	local f = crear("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 24), LayoutOrder = orden, Parent = lista })
	Componentes.texto({ Size = UDim2.fromScale(1, 1), Text = texto, Font = Enum.Font.GothamBold, TextColor3 = C.XP, Parent = f })
end

function PanelMascotas.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla or not pantalla.Enabled or not perfil then
		return
	end
	local espacios = Criadero.espacios(perfil)
	local personaje = Players.LocalPlayer.Character
	local postura = personaje and personaje:GetAttribute("PosturaMascotas") or "Protect"
	cabecera.Text = "Espacios " .. #Criadero.equipadas(perfil) .. "/" .. espacios .. "   ·   Postura: " .. (postura == "Gather" and "Recolectar" or "Proteger") .. " (T)"
		.. "   ·   Almacén " .. Criadero.contar(perfil.Pets) .. "/" .. Pets.Storage.Pets
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("Frame") then
			h:Destroy()
		end
	end
	local orden = 0
	local function sig()
		orden = orden + 1
		return orden
	end

	titulo("Incubadoras (se llenan picando; cada enemigo cuenta 5 golpes)", sig())
	for i, inc in ipairs(perfil.Incubators) do
		local f = fila(34, sig())
		if inc.Egg == "" then
			Componentes.texto({ Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextSize = 12, TextColor3 = C.TextoSuave, Text = "Incubadora " .. i .. ": vacía (elige un huevo abajo)", Parent = f })
		else
			local e = Pets.Species[inc.Species]
			local necesita = Criadero.golpesNecesarios(inc.Species)
			Componentes.texto({ Size = UDim2.new(0, 300, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextSize = 12, TextColor3 = Rarezas.color(e.Rarity),
				Text = "Huevo de " .. e.Name .. ": " .. Formato.entero(inc.PickHits) .. " / " .. Formato.entero(necesita) .. " golpes", Parent = f })
			local _, fijar = Componentes.barra({ Size = UDim2.new(0, 160, 0, 12), Position = UDim2.new(0, 310, 0.5, -6), Parent = f }, C.XP)
			fijar(inc.PickHits / necesita, "")
			if Criadero.lista(inc) then
				local b = Componentes.boton({ Size = UDim2.new(0, 100, 0, 26), Position = UDim2.new(1, -106, 0.5, -13), Text = "¡Eclosionar!", TextSize = 12, BackgroundColor3 = C.XP, TextColor3 = C.Fondo, Parent = f })
				b.Activated:Connect(function()
					pedir("Pet.ClaimHatch", "¡Ha nacido!", i)
				end)
			end
		end
	end

	titulo("Huevos (" .. Criadero.contar(perfil.Eggs) .. ") · de la caja de mascotas en el puesto de Geodas", sig())
	for id, huevo in pairs(perfil.Eggs) do
		local e = Pets.Species[huevo.Species]
		local f = fila(30, sig())
		Componentes.texto({ Size = UDim2.new(0, 400, 1, 0), Position = UDim2.new(0, 8, 0, 0), TextSize = 12, TextColor3 = Rarezas.color(e.Rarity),
			Text = "Huevo de " .. e.Name .. " (" .. Rarezas.Nombre[e.Rarity] .. ") · " .. Formato.entero(Criadero.golpesNecesarios(huevo.Species)) .. " golpes", Parent = f })
		local b = Componentes.boton({ Size = UDim2.new(0, 100, 0, 24), Position = UDim2.new(1, -106, 0.5, -12), Text = "Incubar", TextSize = 12, Parent = f })
		b.Activated:Connect(function()
			local libre
			for i, inc in ipairs(perfil.Incubators) do
				if inc.Egg == "" then
					libre = i
					break
				end
			end
			if libre then
				pedir("Pet.StartHatch", "Incubando: sigue picando", id, libre)
			else
				avisar("No hay incubadoras libres.")
			end
		end)
	end

	titulo("Mascotas", sig())
	local ids = {}
	for id in pairs(perfil.Pets) do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		local ea, eb = table.find(perfil.Equipped.Pets, a) ~= nil, table.find(perfil.Equipped.Pets, b) ~= nil
		if ea ~= eb then
			return ea
		end
		return perfil.Pets[a].Level > perfil.Pets[b].Level
	end)
	for _, id in ipairs(ids) do
		local m = perfil.Pets[id]
		local e = Pets.Species[m.Species]
		local hueco = table.find(perfil.Equipped.Pets, id)
		local nido = table.find(perfil.Nest, id)
		local f = fila(48, sig())
		Componentes.texto({ Size = UDim2.new(0, 330, 0, 20), Position = UDim2.new(0, 8, 0, 3), TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = Rarezas.color(e.Rarity),
			Text = e.Name .. " · nv " .. m.Level .. " · " .. FASE[m.Phase] .. (hueco and ("  [espacio " .. hueco .. "]") or "") .. (nido and "  [Nido]" or ""), Parent = f })
		Componentes.texto({ Size = UDim2.new(0, 330, 0, 18), Position = UDim2.new(0, 8, 0, 25), TextSize = 11, TextColor3 = C.TextoSuave, Parent = f,
			Text = ROL[e.Role] .. " · " .. textoPasiva(e) .. " · XP " .. Formato.entero(m.XP) .. "/" .. Formato.entero(Mascotas.levelXP(m.Level)) })
		local x = 340
		local function boton(texto, color, fn)
			local b = Componentes.boton({ Size = UDim2.new(0, 84, 0, 34), Position = UDim2.new(0, x, 0.5, -17), Text = texto, TextSize = 11, TextWrapped = true, BackgroundColor3 = color or C.Boton, Parent = f })
			b.Activated:Connect(fn)
			x = x + 88
		end
		if hueco then
			boton("Quitar", C.BotonApagado, function()
				pedir("Pet.Equip", "Quitada", "", hueco)
			end)
		else
			boton("Equipar", C.Boton, function()
				local libre = espacios
				for i = 1, espacios do
					local actual = perfil.Equipped.Pets[i]
					if not actual or actual == "" then
						libre = i
						break
					end
				end
				pedir("Pet.Equip", "Equipada", id, libre)
			end)
			boton(nido and "Sacar del Nido" or "Al Nido", C.BotonApagado, function()
				if nido then
					pedir("Pet.SetNest", "Fuera del Nido", "", nido)
				else
					local libre = (perfil.Nest[1] == "" and 1) or (perfil.Nest[2] == "" and 2) or 1
					pedir("Pet.SetNest", "En el Nido (gana XP mientras juegas)", id, libre)
				end
			end)
		end
		local coste = Criadero.costeEvolucion(perfil, id)
		if coste then
			boton("Evolucionar\n" .. Formato.abreviado(coste.Coins), C.XP, function()
				avisar("Necesita " .. coste.Fragments .. " fragmentos de " .. coste.Element .. (coste.Boss > 0 and (" y " .. coste.Boss .. " de jefe") or ""))
				pedir("Pet.Evolve", "¡Ha evolucionado!", id)
			end)
		elseif not hueco and not nido then
			boton("Liberar", C.Peligro, function()
				pedir("Pet.Release", "Liberada: fragmentos de su elemento", { id })
			end)
		end
	end
end

function PanelMascotas.Iniciar(estado)
	Estado = estado
	pantalla = crear("ScreenGui", { Name = "PanelMascotas", ResetOnSpawn = false, Enabled = false, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 720, 0, 540), Position = UDim2.new(0.5, -360, 0.5, -270), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = C.Borde }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Mascotas", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	cabecera = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 32), TextSize = 13, TextColor3 = C.Energia, Parent = marco })
	lista = crear("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, -82), Position = UDim2.new(0, 0, 0, 56),
		ScrollBarThickness = 6, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelMascotas.Refrescar()
		end
	end)
end

function PanelMascotas.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	avisar("")
	PanelMascotas.Refrescar()
end

return PanelMascotas
