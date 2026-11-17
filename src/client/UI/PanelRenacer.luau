-- Panel del Altar de renacimiento (se abre en el altar de la plaza). Doble confirmación:
-- «Renacer» pide al servidor el resumen y una ficha; «Sí, renacer» la confirma.

local Players = game:GetService("Players")

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local Formato = require(script.Parent:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelRenacer = {}

local ORO = Color3.fromRGB(255, 210, 80)
local Estado, pantalla, cuerpo, boton, mensaje
local ficha

local function pintar(resumen)
	local r = resumen
	cuerpo.Text = string.format(
		"Renacimientos: %d / %d\n\nAl renacer (n.º %d):\n  • Ganas: +%d %% de XP para siempre y +%d puntos de estadística en total\n  • Pierdes: el nivel (vuelves al 1), los puntos asignados y %s monedas\n  • Conservas: objetos, mascotas, Núcleos, minerales del banco, Cristales, cosméticos y zonas",
		r.Rebirths, r.Max, r.Siguiente, math.floor(r.BonoXP * 100 + 0.5), r.PuntosExtra, Formato.abreviado(r.MonedasPerdidas))
end

local function preparar()
	ficha = nil
	boton.Text = "..."
	local ok, r = Estado.Invocar("Rebirth.Prepare")
	if type(r) ~= "table" then
		boton.Text = "Renacer"
		mensaje.Text = "No se pudo: " .. tostring(r)
		return
	end
	pintar(r)
	if ok then
		ficha = r.Token
		boton.Text = "Sí, renacer"
		boton.BackgroundColor3 = C.Peligro
		mensaje.Text = "¿Seguro? Pulsa otra vez en menos de 60 s para confirmar."
		mensaje.TextColor3 = C.Peligro
	else
		boton.Text = "Renacer"
		boton.BackgroundColor3 = C.BotonApagado
		mensaje.Text = r.Motivo or "Aún no puedes renacer"
		mensaje.TextColor3 = C.TextoSuave
	end
end

local function confirmar()
	local f = ficha
	ficha = nil
	local ok, r = Estado.Invocar("Rebirth.Confirm", f)
	if ok then
		mensaje.Text = "¡Has renacido! Renacimiento " .. tostring(r)
		mensaje.TextColor3 = ORO
	else
		mensaje.Text = "No se pudo: " .. tostring(r)
		mensaje.TextColor3 = C.Peligro
	end
	boton.Text = "Renacer"
	boton.BackgroundColor3 = ORO
end

function PanelRenacer.Iniciar(estado)
	Estado = estado
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	pantalla = crear("ScreenGui", { Name = "PanelRenacer", ResetOnSpawn = false, Enabled = false, Parent = gui })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 520, 0, 300), Position = UDim2.new(0.5, -260, 0.5, -150), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = ORO }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Altar de renacimiento", TextSize = 22, Font = Enum.Font.GothamBold, TextColor3 = ORO, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	cuerpo = Componentes.texto({ Size = UDim2.new(1, 0, 0, 150), Position = UDim2.new(0, 0, 0, 36), TextSize = 14, TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top, Text = "Requisito: nivel 1.000. Hasta 10 renacimientos.", Parent = marco })
	boton = Componentes.boton({ Size = UDim2.new(0, 200, 0, 40), Position = UDim2.new(0.5, -100, 1, -70), Text = "Renacer", TextSize = 16,
		BackgroundColor3 = ORO, TextColor3 = C.Fondo, Parent = marco })
	boton.Activated:Connect(function()
		task.spawn(function()
			if ficha then
				confirmar()
			else
				preparar()
			end
		end)
	end)
	mensaje = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -22), TextSize = 13, TextColor3 = C.TextoSuave,
		TextXAlignment = Enum.TextXAlignment.Center, Parent = marco })
end

function PanelRenacer.Abrir()
	pantalla.Enabled = true
	ficha = nil
	boton.Text = "Renacer"
	boton.BackgroundColor3 = ORO
	mensaje.Text = ""
	task.spawn(function()
		local _, r = Estado.Invocar("Rebirth.Prepare")
		ficha = nil   -- al abrir solo se muestra el resumen; la ficha se pide al pulsar
		if type(r) == "table" then
			pintar(r)
			if r.Motivo then
				mensaje.Text = r.Motivo
			end
		end
	end)
end

return PanelRenacer
