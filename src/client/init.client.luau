-- Arranque del cliente de OREBOUND.
-- Fase 2: estado local del perfil, HUD (nivel, XP, vida, energía, monedas) y panel de estadísticas (tecla P).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"):WaitForChild("Remotes"))
local carpeta = ReplicatedStorage:WaitForChild(Remotes.FolderName)

local Estado = require(script:WaitForChild("Estado"))
local HUDController = require(script:WaitForChild("Controllers"):WaitForChild("HUDController"))
local PanelEstadisticas = require(script:WaitForChild("UI"):WaitForChild("PanelEstadisticas"))

Estado.Iniciar(carpeta)
PanelEstadisticas.Iniciar(Estado)
HUDController.Iniciar(Estado, function()
	PanelEstadisticas.Alternar()
end)

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if not procesado and entrada.KeyCode == Enum.KeyCode.P then
		PanelEstadisticas.Alternar()
	end
end)
