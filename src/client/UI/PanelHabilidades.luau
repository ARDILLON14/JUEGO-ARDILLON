-- Panel de habilidades (tecla K): las 6 disponibles (4 del Núcleo y 2 técnicas del arma), con su maestría,
-- y qué lleva cada ranura Z, X, C y V. Cada botón de ranura cambia a la siguiente habilidad que encaja.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Habilidades = require(Shared:WaitForChild("Reglas"):WaitForChild("Habilidades"))
local Inventario = require(Shared.Reglas:WaitForChild("Inventario"))
local Dano = require(Shared:WaitForChild("Formulas"):WaitForChild("Dano"))
local Nombres = require(Shared:WaitForChild("Visual"):WaitForChild("Nombres"))

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelHabilidades = {}

local MOTIVOS = {
	en_combate = "No puedes cambiar las habilidades en combate.",
	bloqueada = "Esa habilidad aún está bloqueada.",
	ranura = "Esa habilidad no va en esa ranura.",
	repetida = "No puedes llevar la misma habilidad dos veces.",
}

local Estado, pantalla, lista, cabecera, mensaje
local botones = {}
local borrador = nil

local function texto(h)
	local d = h.Datos
	local base = (Nombres.Habilidad[h.Id] or h.Id) .. "  ·  " .. Formato.entero(d.Coef * 100) .. " %  ·  " .. d.Energy .. " energía  ·  " .. d.Cooldown .. " s"
	if not h.Desbloqueada then
		base = base .. "   (maestría " .. h.Requisito .. ")"
	end
	return base
end

function PanelHabilidades.Refrescar()
	local perfil = Estado.Perfil
	if not pantalla or not pantalla.Enabled or not perfil then
		return
	end
	borrador = borrador or table.clone(perfil.Equipped.Loadout)
	local nucleo = perfil.Equipped.Core
	local mNucleo = perfil.Cores[nucleo] and perfil.Cores[nucleo].Mastery or 1
	local arma = Inventario.equipado(perfil, "Weapon")
	local textoArma = "sin arma"
	if arma then
		local m = perfil.WeaponMastery[arma.Type] or { Level = 1, XP = 0 }
		textoArma = (Nombres.Arma[arma.Type] or arma.Type) .. " (maestría " .. m.Level .. ", " .. Formato.entero(m.XP) .. "/" .. Formato.entero(Dano.masteryXP(m.Level)) .. ")"
	end
	local cn = perfil.Cores[nucleo] or { XP = 0 }
	cabecera.Text = (Nombres.Nucleo[nucleo] or nucleo) .. " (maestría " .. mNucleo .. ", " .. Formato.entero(cn.XP or 0) .. "/" .. Formato.entero(Dano.masteryXP(mNucleo)) .. ")   ·   " .. textoArma
	for _, h in ipairs(lista:GetChildren()) do
		if h:IsA("TextLabel") then
			h:Destroy()
		end
	end
	for i, h in ipairs(Habilidades.disponibles(perfil)) do
		Componentes.texto({ Size = UDim2.new(1, 0, 0, 22), LayoutOrder = i, TextSize = 13, Text = (h.Fuente == "Core" and "Núcleo: " or "Arma: ") .. texto(h),
			TextColor3 = h.Desbloqueada and C.Texto or C.TextoSuave, Parent = lista })
	end
	for _, ranura in ipairs(Habilidades.Ranuras) do
		local id = borrador[ranura]
		botones[ranura].Text = ranura .. ": " .. ((id and id ~= "" and (Nombres.Habilidad[id] or id)) or "vacía")
	end
end

-- Siguiente habilidad desbloqueada que encaja en la ranura (o vacía).
local function siguiente(ranura)
	local perfil = Estado.Perfil
	local opciones = { "" }
	for _, h in ipairs(Habilidades.disponibles(perfil)) do
		if h.Desbloqueada and Habilidades.encaja(h, ranura) then
			table.insert(opciones, h.Id)
		end
	end
	local actual = table.find(opciones, borrador[ranura] or "") or 1
	borrador[ranura] = opciones[actual % #opciones + 1]
	PanelHabilidades.Refrescar()
end

function PanelHabilidades.Iniciar(estado)
	Estado = estado
	pantalla = crear("ScreenGui", { Name = "PanelHabilidades", ResetOnSpawn = false, Enabled = false, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 640, 0, 400), Position = UDim2.new(0.5, -320, 0.5, -200), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = C.Borde }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Habilidades", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	cabecera = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 32), TextSize = 13, TextColor3 = C.Energia, Parent = marco })
	lista = crear("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 6 * 24), Position = UDim2.new(0, 0, 0, 60), Parent = marco },
		{ crear("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
	local fila = crear("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 220), Parent = marco },
		{ crear("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6) }) })
	for _, ranura in ipairs(Habilidades.Ranuras) do
		local b = Componentes.boton({ Size = UDim2.new(0.25, -5, 1, 0), TextSize = 12, TextWrapped = true, Parent = fila })
		b.Activated:Connect(function()
			siguiente(ranura)
		end)
		botones[ranura] = b
	end
	local guardar = Componentes.boton({ Size = UDim2.new(0, 200, 0, 36), Position = UDim2.new(0, 0, 0, 272), Text = "Guardar habilidades", BackgroundColor3 = C.XP, TextColor3 = C.Fondo, Parent = marco })
	guardar.Activated:Connect(function()
		task.spawn(function()
			local ok, motivo = Estado.Invocar("Combat.SetLoadout", borrador)
			if ok then
				mensaje.Text = "Guardado"
				borrador = nil
			else
				mensaje.Text = MOTIVOS[motivo] or ("No se pudo: " .. tostring(motivo))
			end
		end)
	end)
	Componentes.texto({ Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 0, 316), TextSize = 12, TextWrapped = true, TextColor3 = C.TextoSuave,
		Text = "Pulsa una ranura para cambiar su habilidad. V solo admite la definitiva del Núcleo o la segunda técnica del arma. La maestría sube derrotando enemigos con el arma y el Núcleo equipados.",
		Parent = marco })
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 210, 0, 281), TextColor3 = C.TextoSuave, TextSize = 13, Parent = marco })
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" then
			PanelHabilidades.Refrescar()
		end
	end)
end

function PanelHabilidades.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	borrador = nil
	mensaje.Text = ""
	PanelHabilidades.Refrescar()
end

return PanelHabilidades
