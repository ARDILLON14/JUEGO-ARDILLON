-- Arranque del servidor de OREBOUND. Carga los servicios en orden de dependencias (C_Tecnico, sección 3).
-- Fase 1: analítica, datos y red.  Fase 2: economía (monedas), estadísticas y progresión.
-- Los servicios de las fases siguientes conectan sus Remotes con Red:conectar(nombre, manejador).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Services = script.Services
local AnalyticsService = require(Services.AnalyticsService)
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local StatsService = require(Services.StatsService)
local ProgressionService = require(Services.ProgressionService)
local LimiteFrecuencia = require(script.Net.LimiteFrecuencia)
local Validador = require(script.Net.Validador)
local PlantillaPerfil = require(script.Datos.PlantillaPerfil)

local enStudio = RunService:IsStudio()

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
	Studio = enStudio,
})
Red:crear(ReplicatedStorage)

-- State.Profile: primero el perfil completo (parcial = false); después, solo las secciones que cambian.
local remotePerfil = Red:obtener("State.Profile")
DataService.FijarReplicador(function(jugador, parcial)
	remotePerfil:FireClient(jugador, parcial, true)
end)
DataService.AlCargar(function(jugador, datos)
	remotePerfil:FireClient(jugador, PlantillaPerfil.vistaCliente(datos), false)
end)
Players.PlayerRemoving:Connect(function(jugador)
	Red:olvidar(jugador)
end)

EconomyService.Iniciar({ Datos = DataService, Analitica = AnalyticsService })
StatsService.Iniciar({ Datos = DataService, Economia = EconomyService, Analitica = AnalyticsService, Red = Red })
ProgressionService.Iniciar({ Datos = DataService, Stats = StatsService, Analitica = AnalyticsService, Red = Red })

-- Ayudas para probar en Studio. Estos Remotes no existen en un servidor publicado.
if enStudio then
	Red:conectar("Dev.GiveXP", function(jugador, cantidad)
		local r = ProgressionService.AddXP(jugador, cantidad, "Studio")
		return r ~= nil, r and r.Nivel
	end)
	Red:conectar("Dev.GiveCoins", function(jugador, cantidad)
		return EconomyService.AddCoins(jugador, cantidad, "Studio")
	end)
end

DataService.Iniciar({ Analitica = AnalyticsService })

print("OREBOUND: servidor iniciado (fase 2)")
