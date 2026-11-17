-- Arranque del cliente de OREBOUND.
-- Fase 2: estado local del perfil, HUD y panel de estadísticas (tecla P).
-- Fase 3: picar bloques (herramienta «Pico»), subir a la superficie (H), inventario (B) y tienda del mercader.
-- Fase 4: combate con el arma en la mano, Z/X/C/V, dash (Q), bloqueo (F), parpadeo (E), habilidades (K).
-- Fase 5: forja y puesto de geodas (cajas) con sus paneles.
-- Fase 6: mascotas que siguen al jugador (todas las de todos los jugadores), panel de mascotas (M) y postura (T).
-- Fase 7: barra del jefe, misiones diarias (J), tutorial y Núcleos en el panel de habilidades.
-- Fase 8: Zona Fracturada (diálogo, panel, extracción, avisos visuales), PvP y marcador de la arena.

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
local PanelForja = require(UI:WaitForChild("PanelForja"))
local PanelCajas = require(UI:WaitForChild("PanelCajas"))
local PanelMascotas = require(UI:WaitForChild("PanelMascotas"))
local PetsController = require(Controllers:WaitForChild("PetsController"))
local BossController = require(Controllers:WaitForChild("BossController"))
local FractureController = require(Controllers:WaitForChild("FractureController"))
local PanelMisiones = require(UI:WaitForChild("PanelMisiones"))
local PanelEstadisticas = require(UI:WaitForChild("PanelEstadisticas"))
local PanelInventario = require(UI:WaitForChild("PanelInventario"))
local PanelTienda = require(UI:WaitForChild("PanelTienda"))

Estado.Iniciar(carpeta)
PanelEstadisticas.Iniciar(Estado)
PanelInventario.Iniciar(Estado)
PanelTienda.Iniciar(Estado)
PanelHabilidades.Iniciar(Estado)
PanelForja.Iniciar(Estado)
PanelCajas.Iniciar(Estado, carpeta)
PanelMascotas.Iniciar(Estado)
PanelMisiones.Iniciar(Estado)
BossController.Iniciar(carpeta)
HUDController.Iniciar(Estado, function()
	PanelEstadisticas.Alternar()
end)
HUDController.AlAviso("OpenShop", function()
	PanelTienda.Abrir()
end)
HUDController.AlAviso("OpenForge", function()
	PanelForja.Abrir()
end)
HUDController.AlAviso("OpenBoxes", function()
	PanelCajas.Abrir()
end)
MiningController.Iniciar(Estado, carpeta, HUDController.Avisar)
HUDController.BotonSubir(MiningController.BajoTierra, MiningController.Subir)
CombatController.Iniciar(Estado, carpeta, HUDController.Avisar)
PetsController.Iniciar(Estado, carpeta, HUDController.Avisar)
FractureController.Iniciar(Estado, carpeta, HUDController.Avisar, HUDController.AlAviso)

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
	elseif entrada.KeyCode == Enum.KeyCode.M then
		PanelMascotas.Alternar()
	elseif entrada.KeyCode == Enum.KeyCode.J then
		PanelMisiones.Alternar()
	end
end)
