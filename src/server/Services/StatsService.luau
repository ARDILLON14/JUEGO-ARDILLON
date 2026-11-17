-- Services/StatsService: estadísticas efectivas, valores derivados, vida y energía (B2; C_Tecnico, sección 3).
-- La vida vive en el Humanoid (el servidor la controla); la energía y el estado de combate, aquí.
--
-- API para otros servicios:
--   StatsService.GetStats(jugador)                 -> valores derivados (Reglas/Estadisticas.derivadas)
--   StatsService.Recalcular(jugador)               -> tras cambiar nivel, puntos, equipo o mascotas
--   StatsService.RegistrarBonos(nombre, fn)        -> fn(jugador) devuelve { [estadística] = bono } (equipo, mascotas...)
--   StatsService.GastarEnergia(jugador, coste)     -> true si alcanzaba
--   StatsService.MarcarCombate(jugador, modo)      -> "PvE" | "PvP"
--   StatsService.EnCombate(jugador)
--   StatsService.FijarBloqueo(jugador, activo)     -> sin regeneración de energía mientras bloquea
--   StatsService.Rellenar(jugador)                 -> vida y energía al máximo
--   StatsService.FijarLugarReinicio(fn)            -> fn(jugador) -> true si puede reiniciar ahí (ciudad; lo pone WorldService)

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Stats = require(Shared.Config.Stats)
local Estadisticas = require(Shared.Reglas.Estadisticas)
local Recursos = require(script.Parent.Parent.Reglas.Recursos)
local Eventos = require(script.Parent.Parent.Util.Eventos)

local StatsService = {}

local TICK = 0.1                 -- s entre pasos de regeneración
local ENVIO = 0.25               -- s mínimos entre envíos de State.Stats al cliente

local Datos, Economia, Analitica, Red
local estados = {}               -- [jugador] = { Recursos, Derivadas, UltimoEnvio, UltimaEnergia }
local fuentesBono = {}           -- [nombre] = fn(jugador)
local lugarReinicio = function()
	return true
end

local function bonos(jugador)
	local total = {}
	for nombre, fn in pairs(fuentesBono) do
		local ok, b = pcall(fn, jugador)
		if ok and type(b) == "table" then
			for stat, valor in pairs(b) do
				if Estadisticas.esEstadistica(stat) and type(valor) == "number" and valor == valor then
					total[stat] = (total[stat] or 0) + valor
				end
			end
		elseif not ok then
			warn("StatsService: fallo en la fuente de bonos " .. nombre .. ": " .. tostring(b))
		end
	end
	return total
end

local function humanoide(jugador)
	local personaje = jugador.Character
	return personaje and personaje:FindFirstChildOfClass("Humanoid")
end

-- Lleva vida máxima y velocidad al Humanoid, conservando la proporción de vida.
local function aplicarPersonaje(jugador, rellenar)
	local estado = estados[jugador]
	local h = humanoide(jugador)
	if not estado or not h then
		return
	end
	local d = estado.Derivadas
	local proporcion = 1
	if h.MaxHealth > 0 and not rellenar then
		proporcion = math.clamp(h.Health / h.MaxHealth, 0, 1)
	end
	if h.Health <= 0 then
		return   -- muerto: se aplica al reaparecer
	end
	h.MaxHealth = d.MaxHealth
	h.Health = math.max(1, d.MaxHealth * proporcion)
	if estado.Aturdido then
		h.WalkSpeed = 0
		h.JumpHeight = 0
	else
		h.WalkSpeed = d.WalkSpeed * (estado.MultiplicadorVelocidad or 1)
		h.JumpHeight = 7.2
	end
end

local function enviar(jugador, forzar)
	local estado = estados[jugador]
	if not estado then
		return
	end
	local ahora = os.clock()
	local r = estado.Recursos
	if not forzar then
		if ahora - estado.UltimoEnvio < ENVIO then
			return
		end
		if math.abs(r.Energy - estado.UltimaEnergia) < 0.5 and estado.UltimoCombateEnviado == Recursos.enCombate(r, ahora) then
			return
		end
	end
	estado.UltimoEnvio = ahora
	estado.UltimaEnergia = r.Energy
	estado.UltimoCombateEnviado = Recursos.enCombate(r, ahora)
	Red:obtener("State.Stats"):FireClient(jugador, {
		Energy = math.floor(r.Energy + 0.5),
		MaxEnergy = math.floor(r.MaxEnergy + 0.5),
		InCombat = estado.UltimoCombateEnviado,
		BlinkUnlocked = estado.Derivadas.BlinkUnlocked,
	})
end

local function alCargar(jugador)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	local d = Estadisticas.derivadas(perfil, bonos(jugador))
	estados[jugador] = { Recursos = Recursos.nuevo(d), Derivadas = d, UltimoEnvio = 0, UltimaEnergia = -1, MultiplicadorVelocidad = 1 }
	local function alAparecer(personaje)
		local h = personaje:WaitForChild("Humanoid", 10)
		if not h or not estados[jugador] then
			return
		end
		Recursos.rellenar(estados[jugador].Recursos)
		aplicarPersonaje(jugador, true)
		enviar(jugador, true)
	end
	jugador.CharacterAdded:Connect(alAparecer)
	if jugador.Character then
		task.spawn(alAparecer, jugador.Character)
	end
	enviar(jugador, true)
end

local function bucle()
	while true do
		task.wait(TICK)
		local ahora = os.clock()
		for jugador, estado in pairs(estados) do
			local vida = Recursos.avanzar(estado.Recursos, TICK, ahora)
			local h = humanoide(jugador)
			if h and h.Health > 0 and vida > 0 and h.Health < h.MaxHealth then
				h.Health = math.min(h.MaxHealth, h.Health + h.MaxHealth * vida)
			end
			enviar(jugador, false)
		end
	end
end

-- Manejadores de Remotes ---------------------------------------------------

local function asignar(jugador, stat, cantidad)
	local perfil = Datos.GetProfile(jugador)
	local ok, motivo = Estadisticas.asignar(perfil, stat, cantidad)
	if not ok then
		return false, motivo
	end
	StatsService.Recalcular(jugador)
	Datos.Replicar(jugador, "Stats")
	Eventos.emitir("Asignacion", jugador, cantidad)
	return true, { Free = Estadisticas.puntosLibres(perfil) }
end

local function reiniciar(jugador, usarTomo)
	local perfil = Datos.GetProfile(jugador)
	if Stats.Respec.OutOfCombatOnly and StatsService.EnCombate(jugador) then
		return false, "en_combate"
	end
	if not lugarReinicio(jugador) then
		return false, "lugar"
	end
	if Estadisticas.puntosAsignados(perfil) == 0 then
		return false, "nada_que_reiniciar"
	end
	local coste = 0
	if usarTomo then
		if (perfil.Consumables.RespecTome or 0) < 1 then
			return false, "sin_tomo"
		end
		perfil.Consumables.RespecTome = perfil.Consumables.RespecTome - 1
	else
		coste = Estadisticas.costeReinicio(perfil)
		if coste > 0 then
			local ok, motivo = Economia.SpendCoins(jugador, coste, "Reinicio")
			if not ok then
				return false, motivo
			end
		end
	end
	local devueltos = Estadisticas.reiniciarPuntos(perfil)
	StatsService.Recalcular(jugador)
	Analitica.Registrar(jugador, "ReinicioEstadisticas", coste, usarTomo and "Tomo" or "Monedas")
	Datos.Replicar(jugador, "Stats", "Consumables")
	return true, { Returned = devueltos, Cost = coste }
end

-- API ----------------------------------------------------------------------

function StatsService.Iniciar(deps)
	Datos, Economia, Analitica, Red = deps.Datos, deps.Economia, deps.Analitica, deps.Red
	Datos.AlCargar(alCargar)
	Players.PlayerRemoving:Connect(function(jugador)
		estados[jugador] = nil
	end)
	Red:conectar("Stats.Allocate", asignar)
	Red:conectar("Stats.Respec", reiniciar)
	task.spawn(bucle)
end

function StatsService.GetStats(jugador)
	local estado = estados[jugador]
	return estado and estado.Derivadas or nil
end

function StatsService.Recalcular(jugador)
	local estado = estados[jugador]
	local perfil = Datos.GetProfile(jugador)
	if not estado or not perfil then
		return
	end
	estado.Derivadas = Estadisticas.derivadas(perfil, bonos(jugador))
	Recursos.actualizar(estado.Recursos, estado.Derivadas)
	aplicarPersonaje(jugador, false)
	enviar(jugador, true)
end

function StatsService.RegistrarBonos(nombre, fn)
	fuentesBono[nombre] = fn
end

-- Multiplicador de velocidad de movimiento (p. ej. ralentización por carga, 0,6 = 40 % más lento).
function StatsService.FijarMultiplicadorVelocidad(jugador, multiplicador)
	local estado = estados[jugador]
	if estado then
		estado.MultiplicadorVelocidad = math.clamp(multiplicador, 0, 1)
		aplicarPersonaje(jugador, false)
	end
end

-- Aturdido: no se mueve ni salta (control de B4). Lo usa CombatService.
function StatsService.FijarAturdido(jugador, activo)
	local estado = estados[jugador]
	if estado then
		estado.Aturdido = activo == true
		aplicarPersonaje(jugador, false)
	end
end

function StatsService.GastarEnergia(jugador, coste)
	local estado = estados[jugador]
	if not estado then
		return false
	end
	local ok = Recursos.gastar(estado.Recursos, coste, os.clock())
	if ok then
		enviar(jugador, true)
	end
	return ok
end

function StatsService.MarcarCombate(jugador, modo)
	local estado = estados[jugador]
	if estado then
		Recursos.marcarCombate(estado.Recursos, os.clock(), modo)
	end
end

function StatsService.EnCombate(jugador)
	local estado = estados[jugador]
	return estado ~= nil and Recursos.enCombate(estado.Recursos, os.clock())
end

function StatsService.FijarBloqueo(jugador, activo)
	local estado = estados[jugador]
	if estado then
		estado.Recursos.Bloqueando = activo == true
	end
end

function StatsService.GetEnergia(jugador)
	local estado = estados[jugador]
	return estado and estado.Recursos.Energy or 0
end

function StatsService.Rellenar(jugador)
	local estado = estados[jugador]
	if not estado then
		return
	end
	Recursos.rellenar(estado.Recursos)
	aplicarPersonaje(jugador, true)
	enviar(jugador, true)
end

function StatsService.FijarLugarReinicio(fn)
	lugarReinicio = fn
end

return StatsService
