-- Services/QuestService: misiones diarias y tutorial (A_GDD; Config/Quests).
-- Escucha los eventos de los demás servicios (Util/Eventos), avanza el tutorial y las 3 misiones del día,
-- y paga al cobrar. Remotes: Quest.Claim(questId) y Tutorial.Step(100) para saltar el tutorial.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Quests = require(Shared.Config.Quests)
local Economia = require(Shared.Formulas.Economia)
local Misiones = require(Shared.Reglas.Misiones)
local Server = script.Parent.Parent
local Eventos = require(Server.Util.Eventos)

local QuestService = {}

local Datos, Economy, Progression, Analitica, Red

local EVENTOS = { "MineralExtraido", "Deposito", "VentaMineral", "Asignacion", "EnemigoDerrotado", "HabilidadUsada",
	"ObjetoFabricado", "CajaAbierta", "JefeDerrotado", "XPMascota", "GolpesIncubacion" }

local function avisar(jugador, texto, color)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color })
end

local function renovar(jugador)
	local perfil = Datos.GetProfile(jugador)
	if perfil and Misiones.renovar(perfil, Misiones.dia(os.time()), jugador.UserId) then
		Datos.Replicar(jugador, "Quests")
		return true
	end
	return false
end

local function alEvento(nombre, jugador, cantidad)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	-- Tutorial
	local r = Misiones.avanzarTutorial(perfil, nombre, cantidad)
	if r == "paso" then
		local paso = Misiones.pasoTutorial(perfil)
		avisar(jugador, "Tutorial: " .. paso.Text, Color3.fromRGB(120, 220, 255))
		Datos.Replicar(jugador, "Progress")
	elseif r == "fin" then
		local monedas = math.floor(Quests.TutorialReward.Hours * Economia.income(perfil.Progress.UnlockedZone) + 0.5)
		Economy.AddCoins(jugador, monedas, "Tutorial")
		avisar(jugador, "¡Tutorial completado! +" .. monedas .. " monedas. Mira tus misiones diarias con J", Color3.fromRGB(255, 230, 120))
		Analitica.Registrar(jugador, "TutorialTerminado")
		Datos.Replicar(jugador, "Progress")
	elseif perfil.Progress.TutorialCount and perfil.Progress.TutorialCount > 0 then
		Datos.Replicar(jugador, "Progress")
	end
	-- Misiones diarias
	renovar(jugador)
	local completadas = Misiones.avanzar(perfil, nombre, cantidad)
	for _, q in ipairs(completadas) do
		local d = Misiones.definicion(q.Id)
		avisar(jugador, "Misión completada: " .. string.format(d.Text, d.Count) .. " (cóbrala con J)", Color3.fromRGB(255, 230, 120))
	end
	if #(perfil.Quests.Daily or {}) > 0 then
		Datos.Replicar(jugador, "Quests")
	end
end

local function cobrar(jugador, id)
	local perfil = Datos.GetProfile(jugador)
	renovar(jugador)
	local r, motivo = Misiones.cobrar(perfil, id)
	if not r then
		return false, motivo
	end
	Economy.AddCoins(jugador, r.Coins, "Mision")
	Progression.AddXP(jugador, r.XP, "Mision")
	Analitica.Registrar(jugador, "MisionCobrada", r.Coins, id)
	Datos.Replicar(jugador, "Quests")
	return true, r
end

local function paso(jugador, n)
	local perfil = Datos.GetProfile(jugador)
	if n == 100 and not Misiones.tutorialTerminado(perfil) then
		Misiones.saltarTutorial(perfil)
		Datos.Replicar(jugador, "Progress")
	end
end

function QuestService.Iniciar(deps)
	Datos, Economy, Progression, Analitica, Red = deps.Datos, deps.Economia, deps.Progression, deps.Analitica, deps.Red
	for _, nombre in ipairs(EVENTOS) do
		Eventos.escuchar(nombre, function(jugador, cantidad)
			alEvento(nombre, jugador, cantidad)
		end)
	end
	Red:conectar("Quest.Claim", cobrar)
	Red:conectar("Tutorial.Step", paso)
	Datos.AlCargar(function(jugador, perfil)
		renovar(jugador)
		local p = Misiones.pasoTutorial(perfil)
		if p then
			task.delay(3, function()
				avisar(jugador, "Tutorial: " .. p.Text, Color3.fromRGB(120, 220, 255))
			end)
		end
	end)
	-- Cambio de día con el jugador conectado.
	task.spawn(function()
		while true do
			task.wait(60)
			for _, jugador in ipairs(Players:GetPlayers()) do
				if renovar(jugador) then
					avisar(jugador, "Nuevas misiones diarias (J)")
				end
			end
		end
	end)
end

return QuestService
