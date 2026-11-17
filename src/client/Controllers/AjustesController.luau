-- Ajustes del cliente (C_Tecnico 8.2): calidad gráfica (automática o fija), temblor de cámara y efectos de otros
-- jugadores. Mide los FPS y, en "Auto", baja la calidad un nivel tras 10 s por debajo de 25 FPS (Reglas/Calidad).
--   Baja:  sin sombras globales y sin estelas/auras de otros jugadores.
--   Media / Alta: sombras; los efectos de otros según el ajuste.
-- Los ajustes se guardan en el servidor (Settings.Save) y vuelven al entrar.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reglas = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Reglas")
local Calidad = require(Reglas:WaitForChild("Calidad"))
local Ajustes = require(Reglas:WaitForChild("Ajustes"))

local AjustesController = {}

local Estado, EfectosCombate, remoteGuardar
local actuales = Ajustes.efectivos(nil)
local auto = Calidad.nuevo("High")
local fps = 60
local cargados = false
local cambio = Instance.new("BindableEvent")
AjustesController.Cambio = cambio.Event

function AjustesController.Nivel()
	if actuales.Quality == "Auto" then
		return auto.Nivel
	end
	return actuales.Quality
end

function AjustesController.FPS()
	return fps
end

function AjustesController.Actuales()
	return actuales
end

local function efectosAjenos(visibles)
	for _, otro in ipairs(Players:GetPlayers()) do
		if otro ~= Players.LocalPlayer and otro.Character then
			local hrp = otro.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				for _, nombre in ipairs({ "CosmeticoTrail", "CosmeticoAura" }) do
					local e = hrp:FindFirstChild(nombre)
					if e then
						e.Enabled = visibles
					end
				end
			end
		end
	end
end

local function aplicar()
	local nivel = AjustesController.Nivel()
	Lighting.GlobalShadows = nivel ~= "Low"
	efectosAjenos(actuales.OthersVFX and nivel ~= "Low")
	if EfectosCombate then
		EfectosCombate.TemblorActivo = actuales.Shake
	end
	cambio:Fire()
end

-- Cambia un ajuste y lo guarda en el servidor.
function AjustesController.Fijar(clave, valor)
	actuales[clave] = valor
	if clave == "Quality" and valor == "Auto" then
		auto = Calidad.nuevo("High")
	end
	aplicar()
	if remoteGuardar then
		remoteGuardar:FireServer({ Quality = actuales.Quality, Shake = actuales.Shake, OthersVFX = actuales.OthersVFX })
	end
end

function AjustesController.Iniciar(estado, carpeta, efectosCombate)
	Estado, EfectosCombate = estado, efectosCombate
	remoteGuardar = carpeta:WaitForChild("Settings.Save")
	Estado.Cambio:Connect(function(que)
		if que == "Perfil" and not cargados and Estado.Perfil then
			cargados = true
			actuales = Ajustes.efectivos(Estado.Perfil.Settings)
			aplicar()
		end
	end)
	-- FPS medidos cada segundo
	local cuadros, acumulado = 0, 0
	RunService.RenderStepped:Connect(function(dt)
		cuadros = cuadros + 1
		acumulado = acumulado + dt
		if acumulado >= 1 then
			fps = cuadros / acumulado
			local antes = auto.Nivel
			Calidad.paso(auto, acumulado, fps)
			cuadros, acumulado = 0, 0
			if actuales.Quality == "Auto" and auto.Nivel ~= antes then
				aplicar()
			else
				cambio:Fire()
			end
		end
	end)
	-- Los personajes que aparecen después también respetan el ajuste.
	task.spawn(function()
		while true do
			task.wait(3)
			efectosAjenos(actuales.OthersVFX and AjustesController.Nivel() ~= "Low")
		end
	end)
	aplicar()
end

return AjustesController
