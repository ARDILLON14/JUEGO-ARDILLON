-- BossController: barra grande del jefe arriba de la pantalla mientras se participa en su combate (Boss.State).

local Players = game:GetService("Players")

local UI = script.Parent.Parent:WaitForChild("UI")
local Componentes = require(UI:WaitForChild("Componentes"))
local Formato = require(UI:WaitForChild("Formato"))
local C = Componentes.Colores
local crear = Componentes.crear

local BossController = {}

function BossController.Iniciar(carpeta)
	local pantalla = crear("ScreenGui", { Name = "Jefe", ResetOnSpawn = false, Enabled = false, Parent = Players.LocalPlayer:WaitForChild("PlayerGui") })
	local marco = crear("Frame", { BackgroundColor3 = C.Panel, BackgroundTransparency = 0.15, Size = UDim2.new(0, 560, 0, 62), Position = UDim2.new(0.5, -280, 0, 12), Parent = pantalla },
		{ Componentes.esquinas(10), crear("UIStroke", { Color = Color3.fromRGB(255, 160, 80) }) })
	local nombre = Componentes.texto({ Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 10, 0, 4), Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = Color3.fromRGB(255, 200, 80), Parent = marco })
	local _, fijar = Componentes.barra({ Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 10, 0, 32), Parent = marco }, C.Vida)
	local finalizado = 0
	carpeta:WaitForChild("Boss.State").OnClientEvent:Connect(function(d)
		if d.Ended then
			finalizado = os.clock()
			nombre.Text = d.Victory and "¡Victoria!" or "El jefe se ha reiniciado"
			fijar(d.Victory and 0 or 1, "")
			task.delay(4, function()
				if os.clock() - finalizado >= 3.9 then
					pantalla.Enabled = false
				end
			end)
			return
		end
		pantalla.Enabled = true
		local estado = "Fase " .. d.Phase
		if d.Invulnerable then
			estado = estado .. " · INVULNERABLE"
		elseif d.Vulnerable then
			estado = estado .. " · ¡EXPUESTO! +50 %"
		end
		if d.Enrage and d.Enrage > 0 then
			estado = estado .. " · Furia +" .. (d.Enrage * 10) .. " %"
		end
		nombre.Text = d.Name .. "   ·   " .. estado .. "   ·   " .. d.Players .. " jugador" .. (d.Players > 1 and "es" or "")
		fijar(d.Health / d.Max, Formato.abreviado(d.Health) .. " / " .. Formato.abreviado(d.Max))
	end)
end

return BossController
