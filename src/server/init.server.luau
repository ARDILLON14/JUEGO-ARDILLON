-- Arranque del servidor de OREBOUND. Carga los servicios en orden de dependencias.
-- Fase 1 (Cimientos): analítica, datos y red. Los servicios de juego se añaden en las fases siguientes
-- y conectan sus Remotes con Red:conectar(nombre, manejador).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local AnalyticsService = require(script.Services.AnalyticsService)
local DataService = require(script.Services.DataService)
local LimiteFrecuencia = require(script.Net.LimiteFrecuencia)
local Validador = require(script.Net.Validador)
local PlantillaPerfil = require(script.Datos.PlantillaPerfil)

AnalyticsService.Iniciar()

local Red = Validador.nuevo({
	Limite = LimiteFrecuencia.nuevo(os.clock),
	PerfilCargado = function(jugador)
		return DataService.GetProfile(jugador) ~= nil
	end,
	Marcar = function(jugador, motivo, remote)
		AnalyticsService.Registrar(jugador, "EsquemaRechazado", nil, remote)
		local datos = DataService.GetProfile(jugador)
		if datos then
			datos.Flags.Suspicion = datos.Flags.Suspicion + 1
		end
	end,
})
Red:crear(ReplicatedStorage)

DataService.AlCargar(function(jugador, datos)
	Red:obtener("State.Profile"):FireClient(jugador, PlantillaPerfil.vistaCliente(datos))
end)
Players.PlayerRemoving:Connect(function(jugador)
	Red:olvidar(jugador)
end)

DataService.Iniciar({ Analitica = AnalyticsService })

print("OREBOUND: servidor iniciado (fase 1)")
