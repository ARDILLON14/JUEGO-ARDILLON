-- Panel de Ajustes (tecla O): calidad gráfica, temblor de cámara y efectos de otros jugadores.

local Players = game:GetService("Players")

local Componentes = require(script.Parent:WaitForChild("Componentes"))
local C = Componentes.Colores
local crear = Componentes.crear

local PanelAjustes = {}

local NOMBRE_CALIDAD = { Auto = "Automática", Low = "Baja", Medium = "Media", High = "Alta" }
local Ajustes, pantalla, botonesCalidad, botonTemblor, botonAjenos, info

local function pintar()
	if not pantalla.Enabled then
		return
	end
	local a = Ajustes.Actuales()
	for clave, b in pairs(botonesCalidad) do
		b.BackgroundColor3 = a.Quality == clave and C.Boton or C.BotonApagado
	end
	botonTemblor.Text = "Temblor de cámara: " .. (a.Shake and "Sí" or "No")
	botonTemblor.BackgroundColor3 = a.Shake and C.Boton or C.BotonApagado
	botonAjenos.Text = "Estelas y auras de otros: " .. (a.OthersVFX and "Sí" or "No")
	botonAjenos.BackgroundColor3 = a.OthersVFX and C.Boton or C.BotonApagado
	info.Text = string.format("Calidad en uso: %s  ·  %d FPS", NOMBRE_CALIDAD[Ajustes.Nivel()], math.floor(Ajustes.FPS() + 0.5))
end

function PanelAjustes.Iniciar(ajustesController)
	Ajustes = ajustesController
	local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
	pantalla = crear("ScreenGui", { Name = "PanelAjustes", ResetOnSpawn = false, Enabled = false, Parent = gui })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, Size = UDim2.new(0, 440, 0, 270), Position = UDim2.new(0.5, -220, 0.5, -135), Parent = pantalla }, {
		Componentes.esquinas(12), crear("UIStroke", { Color = C.Borde }),
		crear("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) }),
	})
	Componentes.texto({ Size = UDim2.new(1, -40, 0, 28), Text = "Ajustes", TextSize = 22, Font = Enum.Font.GothamBold, Parent = marco })
	local cerrar = Componentes.boton({ Size = UDim2.new(0, 30, 0, 28), Position = UDim2.new(1, -30, 0, 0), Text = "X", BackgroundColor3 = C.BotonApagado, Parent = marco })
	cerrar.Activated:Connect(function()
		pantalla.Enabled = false
	end)
	Componentes.texto({ Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 36), TextSize = 13, TextColor3 = C.TextoSuave,
		Text = "Calidad gráfica (Automática baja sola si el juego va lento)", Parent = marco })
	botonesCalidad = {}
	for i, clave in ipairs({ "Auto", "Low", "Medium", "High" }) do
		local b = Componentes.boton({ Size = UDim2.new(0.25, -6, 0, 32), Position = UDim2.new((i - 1) * 0.25, 0, 0, 58), Text = NOMBRE_CALIDAD[clave], TextSize = 13, Parent = marco })
		b.Activated:Connect(function()
			Ajustes.Fijar("Quality", clave)
		end)
		botonesCalidad[clave] = b
	end
	botonTemblor = Componentes.boton({ Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 104), TextSize = 14, Parent = marco })
	botonTemblor.Activated:Connect(function()
		Ajustes.Fijar("Shake", not Ajustes.Actuales().Shake)
	end)
	botonAjenos = Componentes.boton({ Size = UDim2.new(1, 0, 0, 34), Position = UDim2.new(0, 0, 0, 146), TextSize = 14, Parent = marco })
	botonAjenos.Activated:Connect(function()
		Ajustes.Fijar("OthersVFX", not Ajustes.Actuales().OthersVFX)
	end)
	info = Componentes.texto({ Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -24), TextSize = 13, TextColor3 = C.Energia, Parent = marco })
	Ajustes.Cambio:Connect(pintar)
end

function PanelAjustes.Alternar()
	pantalla.Enabled = not pantalla.Enabled
	pintar()
end

return PanelAjustes
