-- Services/AntiCheatService: antitrampas (C_Tecnico 7.2). El servidor ya decide todo lo importante (daño, botín,
-- precios); aquí se vigila lo que el cliente controla: la posición del personaje.
--   * Cada 0,25 s se toma la posición horizontal; un desplazamiento imposible es una falta y 3 seguidas
--     devuelven al jugador a su última posición válida.
--   * Los movimientos del propio servidor (Util/Mover) reinician la vigilancia.
--   * Sospecha acumulada en Flags.Suspicion (esquemas rechazados y movimiento); con 30 se expulsa
--     (en Studio solo avisa).
--   * Alerta de analítica si alguien gana más de 3 h de ingreso en 1 h (no se castiga: solo se mira).

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Security = require(Shared.Config.Security)
local Economia = require(Shared.Formulas.Economia)
local Server = script.Parent.Parent
local Movimiento = require(Server.Reglas.Movimiento)
local Mover = require(Server.Util.Mover)

local AntiCheatService = {}

local Datos, Analitica
local enStudio = RunService:IsStudio()

local vigilados = {}   -- [jugador] = estado de Movimiento
local ingresos = {}    -- [jugador] = { Inicio, Monedas, Avisado }

local function raiz(jugador)
	local personaje = jugador.Character
	return personaje and personaje:FindFirstChild("HumanoidRootPart")
end

-- Suma sospecha. tipo: "Schema" | "Movement" | "Rate".
function AntiCheatService.Marcar(jugador, tipo, detalle)
	local perfil = Datos.GetProfile(jugador)
	local puntos = Security.Suspicion[tipo] or 1
	if not perfil or puntos <= 0 then
		return
	end
	perfil.Flags.Suspicion = (perfil.Flags.Suspicion or 0) + puntos
	Analitica.Registrar(jugador, "Sospecha", puntos, tipo .. ":" .. tostring(detalle))
	if perfil.Flags.Suspicion >= Security.Suspicion.KickAt then
		if enStudio then
			warn(("OREBOUND antitrampas: %s llegó a %d de sospecha (en un servidor publicado sería expulsado)"):format(
				jugador.Name, perfil.Flags.Suspicion))
			perfil.Flags.Suspicion = 0
		else
			Analitica.Registrar(jugador, "Expulsado", perfil.Flags.Suspicion, tipo)
			perfil.Flags.Suspicion = math.floor(Security.Suspicion.KickAt / 2)
			jugador:Kick("Se ha detectado un comportamiento extraño. Vuelve a entrar; si se repite, avísanos.")
		end
	end
end

local function vigilar()
	local t = os.clock()
	for _, jugador in ipairs(Players:GetPlayers()) do
		local hrp = raiz(jugador)
		local humanoide = hrp and hrp.Parent:FindFirstChildOfClass("Humanoid")
		if hrp and humanoide and humanoide.Health > 0 then
			local estado = vigilados[jugador]
			if not estado then
				vigilados[jugador] = Movimiento.nuevo(hrp.Position, t)
			else
				local r = Movimiento.muestra(estado, hrp.Position, t)
				if r == "falta" then
					AntiCheatService.Marcar(jugador, "Movement", "falta")
				elseif r == "devolver" then
					AntiCheatService.Marcar(jugador, "Movement", "devuelto")
					local valida = estado.Valida
					Mover.personaje(hrp.Parent, CFrame.new(valida + Vector3.new(0, 3, 0)))
				end
			end
		else
			vigilados[jugador] = nil
		end
	end
end

-- Llamado por EconomyService cada vez que alguien gana monedas.
function AntiCheatService.Ingreso(jugador, cantidad, motivo)
	if motivo == "Studio" then
		return
	end
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	local ahora = os.clock()
	local r = ingresos[jugador]
	if not r or ahora - r.Inicio > 3600 then
		r = { Inicio = ahora, Monedas = 0, Avisado = false }
		ingresos[jugador] = r
	end
	r.Monedas = r.Monedas + cantidad
	local tope = Security.Income.AlertHoursMultiplier * Economia.income(perfil.Progress.UnlockedZone)
	if not r.Avisado and r.Monedas > tope then
		r.Avisado = true
		Analitica.Registrar(jugador, "AlertaIngresos", r.Monedas, tostring(motivo))
		if enStudio then
			print(("OREBOUND antitrampas: %s ha ganado %d monedas en menos de 1 h (más de %d)"):format(jugador.Name, r.Monedas, tope))
		end
	end
end

function AntiCheatService.Iniciar(deps)
	Datos, Analitica = deps.Datos, deps.Analitica
	Mover.alMover(function(personaje, cframe)
		local jugador = Players:GetPlayerFromCharacter(personaje)
		if jugador then
			if vigilados[jugador] then
				Movimiento.reiniciar(vigilados[jugador], cframe.Position, os.clock())
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(jugador)
		vigilados[jugador] = nil
		ingresos[jugador] = nil
	end)
	local function alAparecer(jugador)
		jugador.CharacterAdded:Connect(function()
			vigilados[jugador] = nil
		end)
	end
	Players.PlayerAdded:Connect(alAparecer)
	for _, j in ipairs(Players:GetPlayers()) do
		alAparecer(j)
	end
	task.spawn(function()
		while true do
			task.wait(Security.Movement.SampleSeconds)
			vigilar()
		end
	end)
end

return AntiCheatService
