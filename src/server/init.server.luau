-- Arranque del servidor de OREBOUND. Carga los servicios en orden de dependencias (C_Tecnico, sección 3).
-- Fase 1: analítica, datos y red.  Fase 2: economía (monedas), estadísticas y progresión.
-- Fase 3: mapa de prueba, inventario, depósitos, minería, banco y tienda.
-- Fase 4: enemigos, combate (ataque, bloqueo, dash, parpadeo, Ruptura) y Núcleos de Poder con sus habilidades.
-- Fase 5: forja (fabricar, mejorar, reciclar) y cajas con Suerte, protección contra mala suerte y registro.
-- Fase 6: mascotas (incubación, posturas, Nido, XP, evolución) y su combate con el tope de daño.
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
local InventoryService = require(Services.InventoryService)
local DepositService = require(Services.DepositService)
local MiningService = require(Services.MiningService)
local BankService = require(Services.BankService)
local EnemyService = require(Services.EnemyService)
local CombatService = require(Services.CombatService)
local PowerCoreService = require(Services.PowerCoreService)
local CraftingService = require(Services.CraftingService)
local BoxService = require(Services.BoxService)
local PetService = require(Services.PetService)
local PetCombatService = require(Services.PetCombatService)
local ConstructorPrueba = require(script.Mundo.ConstructorPrueba)
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

if ConstructorPrueba.construirSiFalta() then
	print("OREBOUND: no hay ninguna Mina en el mapa; se ha creado el mapa de prueba de la zona 1")
end

EconomyService.Iniciar({ Datos = DataService, Analitica = AnalyticsService, Red = Red })
StatsService.Iniciar({ Datos = DataService, Economia = EconomyService, Analitica = AnalyticsService, Red = Red })
ProgressionService.Iniciar({ Datos = DataService, Stats = StatsService, Analitica = AnalyticsService, Red = Red })
InventoryService.Iniciar({ Datos = DataService, Stats = StatsService, Analitica = AnalyticsService, Red = Red })
BankService.Iniciar({ Datos = DataService, Inventory = InventoryService, Red = Red })
DepositService.Iniciar()
MiningService.Iniciar({
	Datos = DataService, Stats = StatsService, Inventory = InventoryService, Deposits = DepositService,
	Progression = ProgressionService, Analitica = AnalyticsService, Red = Red,
})
EnemyService.Iniciar()
CombatService.Iniciar({
	Datos = DataService, Stats = StatsService, Enemigos = EnemyService, Progression = ProgressionService,
	Economia = EconomyService, Analitica = AnalyticsService, Red = Red,
})
CraftingService.Iniciar({ Datos = DataService, Economia = EconomyService, Inventory = InventoryService, Analitica = AnalyticsService, Red = Red })
BoxService.Iniciar({
	Datos = DataService, Economia = EconomyService, Inventory = InventoryService, Stats = StatsService,
	Analitica = AnalyticsService, Red = Red,
})
PetService.Iniciar({
	Datos = DataService, Economia = EconomyService, Inventory = InventoryService, Mining = MiningService,
	Deposits = DepositService, Enemigos = EnemyService, Analitica = AnalyticsService, Red = Red,
})
MiningService.FijarBonos(PetService.Bonos)
PetCombatService.Iniciar({ Datos = DataService, Stats = StatsService, Combat = CombatService, Enemigos = EnemyService, Pets = PetService, Red = Red })
PowerCoreService.Iniciar({
	Datos = DataService, Stats = StatsService, Combat = CombatService, Enemigos = EnemyService,
	Analitica = AnalyticsService, Red = Red,
})

-- Ayudas para probar en Studio. Estos Remotes no existen en un servidor publicado.
if enStudio then
	Red:conectar("Dev.GiveXP", function(jugador, cantidad)
		local r = ProgressionService.AddXP(jugador, cantidad, "Studio")
		return r ~= nil, r and r.Nivel
	end)
	Red:conectar("Dev.GiveMastery", function(jugador, puntos)
		CombatService.SumarMaestria(jugador, puntos)
		return true
	end)
	Red:conectar("Dev.PetBoost", function(jugador)
		return PetService.Impulso(jugador)
	end)
	Red:conectar("Dev.GiveCoins", function(jugador, cantidad)
		return EconomyService.AddCoins(jugador, cantidad, "Studio")
	end)
end

DataService.Iniciar({ Analitica = AnalyticsService })

print("OREBOUND: servidor iniciado (fase 6)")
