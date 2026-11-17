-- Arranque del cliente de OREBOUND.
-- Fase 2: estado local del perfil, HUD y panel de estadísticas (tecla P).
-- Fase 3: picar bloques (herramienta «Pico»), subir a la superficie (H), inventario (B) y tienda del mercader.
-- Fase 4: combate con el arma en la mano, Z/X/C/V, dash (Q), bloqueo (F), parpadeo (E), habilidades (K).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"):WaitForChild("Remotes"))
local carpeta = ReplicatedStorage:WaitForChild(Remotes.FolderName)

local Estado = require(script:WaitForChild("Estado"))
local Controllers = script:WaitForChild("Controllers")
local UI = script:WaitForChild("UI")
local HUDController = require(Controllers:WaitForChild("HUDController"))
local MiningController = require(Controllers:WaitForChild("MiningController"))
local CombatController = require(Controllers:WaitForChild("CombatController"))
local PanelHabilidades = require(UI:WaitForChild("PanelHabilidades"))
local PanelEstadisticas = require(UI:WaitForChild("PanelEstadisticas"))
local PanelInventario = require(UI:WaitForChild("PanelInventario"))
local PanelTienda = require(UI:WaitForChild("PanelTienda"))

Estado.Iniciar(carpeta)
PanelEstadisticas.Iniciar(Estado)
PanelInventario.Iniciar(Estado)
PanelTienda.Iniciar(Estado)
PanelHabilidades.Iniciar(Estado)
HUDController.Iniciar(Estado, function()
	PanelEstadisticas.Alternar()
end)
HUDController.AlAviso("OpenShop", function()
	PanelTienda.Abrir()
end)
MiningController.Iniciar(Estado, carpeta, HUDController.Avisar)
HUDController.BotonSubir(MiningController.BajoTierra, MiningController.Subir)
CombatController.Iniciar(Estado, carpeta, HUDController.Avisar)

UserInputService.InputBegan:Connect(function(entrada, procesado)
	if procesado then
		return
	end
	if entrada.KeyCode == Enum.KeyCode.P then
		PanelEstadisticas.Alternar()
	elseif entrada.KeyCode == Enum.KeyCode.B then
		PanelInventario.Alternar()
	elseif entrada.KeyCode == Enum.KeyCode.K then
		PanelHabilidades.Alternar()
	end
end)
