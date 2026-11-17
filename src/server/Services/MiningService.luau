-- Services/MiningService: valida cada golpe de pico y reparte mineral y XP al agotar un depósito (B3).
-- Minería por bloques (P3b): la piedra solo abre camino; los bloques de mineral son los depósitos de B3.
-- El cliente solo dice a qué bloque golpea; distancia, ritmo, requisitos y daño los decide el servidor.
--
-- API: AlGolpear(fn)  fn(jugador, entrada)  cada golpe válido (incubación de huevos, fase 6)

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Pickaxes = require(Shared.Config.Pickaxes)
local Mineria = require(Shared.Formulas.Mineria)
local Inventario = require(Shared.Reglas.Inventario)
local Server = script.Parent.Parent
local Deposito = require(Server.Reglas.Deposito)
local Pasivas = require(Server.Reglas.Pasivas)
local Lugares = require(Server.Util.Lugares)

local MiningService = {}

local Datos, Stats, Inventory, Deposits, Progression, Analitica, Red
local estados = {}         -- [jugador] = { UltimoGolpe, Pasivas = estado de Pasivas, Avisos = { [motivo] = momento } }
local subiendo
local alGolpear = {}
local azar = Random.new()

local MENSAJES = {
	mochila_llena = "Mochila llena. Ve al banco a depositar.",
	zona = "Aún no has desbloqueado esta zona.",
	pico = "Tu pico no tiene potencia suficiente para esta zona.",
	mineria = "Necesitas más Minería para este depósito.",
	sin_pico = "No tienes un pico equipado.",
}

local function estado(jugador)
	local e = estados[jugador]
	if not e then
		e = { UltimoGolpe = -1e9, Pasivas = Pasivas.nuevoEstado(), Avisos = {} }
		estados[jugador] = e
	end
	return e
end

-- Aviso al jugador, como mucho uno cada 2 s por motivo.
local function avisar(jugador, motivo)
	local e = estado(jugador)
	local ahora = os.clock()
	if ahora - (e.Avisos[motivo] or -1e9) < 2 then
		return
	end
	e.Avisos[motivo] = ahora
	Red:obtener("Notify"):FireClient(jugador, { Text = MENSAJES[motivo] or motivo, Kind = "Warning" })
end

local function aleatorio()
	return azar:NextNumber()
end

local function golpear(jugador, depositoId)
	local entrada = Deposits.Obtener(depositoId)
	if not entrada then
		return
	end
	local raiz = Lugares.raiz(jugador)
	if not raiz then
		return
	end
	local regla = entrada.Regla
	local esMineral = entrada.Tipo == "Mineral"
	local alcance = Mining.Deposit.MaxReach + entrada.Parte.Size.X / 2 + Mining.Hit.ReachTolerance
	if (raiz.Position - entrada.Parte.Position).Magnitude > alcance then
		return
	end
	local perfil = Datos.GetProfile(jugador)
	local pico = Inventario.equipado(perfil, "Pickaxe")
	if not pico then
		avisar(jugador, "sin_pico")
		return
	end
	local d = Stats.GetStats(jugador)
	if not d then
		return
	end
	if perfil.Progress.UnlockedZone < regla.Zone then
		avisar(jugador, "zona")
		return
	end
	local potencia = Inventario.potencia(pico)
	if potencia < Mineria.pickPowerReq(regla.Zone) then
		avisar(jugador, "pico")
		return
	end
	local mineria = d.Effective.Mining
	if esMineral and mineria < Mineria.depositMiningReq(regla.Zone, regla.Rarity) then
		avisar(jugador, "mineria")
		return
	end
	local e = estado(jugador)
	local ahora = os.clock()
	local intervalo = 1 / Mineria.pickHitsPerSecond(pico.Rarity, 0)
	if ahora - e.UltimoGolpe < intervalo * Mining.Hit.TimingTolerance then
		return
	end
	if esMineral and Inventory.Espacio(jugador) <= 0 then
		avisar(jugador, "mochila_llena")
		return
	end
	e.UltimoGolpe = ahora
	local suerte = d.Effective.Luck

	local efectos = Pasivas.alGolpear(pico.Passives, e.Pasivas, ahora, aleatorio)
	local dano
	if esMineral then
		dano = Mineria.hitDamage(regla.MaxHealth, potencia, mineria) * efectos.Multiplicador + efectos.CadenaFraccion * regla.MaxHealth
	else
		dano = Mineria.stoneHitDamage(potencia, mineria) * efectos.Multiplicador
	end
	Deposits.Danar(depositoId, jugador.UserId, dano, suerte)
	local V = Pickaxes.PassiveValues
	if efectos.Eco then
		local otro = Deposits.Cercanos(depositoId, V.BladeEchoRadius)[1]
		local o = otro and Deposits.Obtener(otro)
		if o then
			Deposits.Danar(otro, jugador.UserId, Mineria.hitDamage(o.Regla.MaxHealth, potencia, mineria), suerte)
		end
	end
	if efectos.Onda then
		for _, otro in ipairs(Deposits.Cercanos(depositoId, V.SeismicWaveRadius)) do
			local o = Deposits.Obtener(otro)
			if o then
				Deposits.Danar(otro, jugador.UserId, V.SeismicWaveFraction * Mineria.hitDamage(o.Regla.MaxHealth, potencia, mineria), suerte)
			end
		end
	end
	for _, fn in ipairs(alGolpear) do
		task.spawn(fn, jugador, entrada)
	end
end

-- «Subir a la superficie»: 3 s sin moverse y sin recibir daño; después, a la salida de la mina.
subiendo = {}
local function subir(jugador)
	if subiendo[jugador] then
		return
	end
	local raiz = Lugares.raiz(jugador)
	if not raiz then
		return
	end
	local zona = Deposits.MinaEn(raiz.Position)
	local salida = zona and Deposits.Salida(zona)
	if not salida then
		Red:obtener("Notify"):FireClient(jugador, { Text = "Solo puedes subir desde dentro de una mina.", Kind = "Warning", Short = true })
		return
	end
	local personaje = jugador.Character
	local h = personaje and personaje:FindFirstChildOfClass("Humanoid")
	local inicio, vida = raiz.Position, h and h.Health or 0
	subiendo[jugador] = true
	Red:obtener("Notify"):FireClient(jugador, { Text = "Subiendo a la superficie… no te muevas", Short = true })
	task.wait(Mining.Blocks.ReturnChannelSeconds)
	subiendo[jugador] = nil
	local r2 = Lugares.raiz(jugador)
	if not r2 or r2 ~= raiz or (r2.Position - inicio).Magnitude > 4 or (h and h.Health < vida) then
		Red:obtener("Notify"):FireClient(jugador, { Text = "Te has movido: subida cancelada", Kind = "Warning", Short = true })
		return
	end
	personaje:PivotTo(CFrame.new(salida + Vector3.new(0, 3, 0)))
end

-- Reparto al agotarse un depósito. Devuelve true si debe reaparecer al instante (Eco estelar).
local function alAgotar(entrada, azarDep)
	local regla = entrada.Regla
	local reaparece = false
	local m = Mining.Minerals[regla.Mineral]
	for _, parte in ipairs(Deposito.reparto(regla)) do
		local jugador = Players:GetPlayerByUserId(parte.UserId)
		local perfil = jugador and Datos.GetProfile(jugador)
		if perfil then
			local pico = Inventario.equipado(perfil, "Pickaxe")
			local unidades = parte.Units
			local efectos = Pasivas.alAgotar(pico and pico.Passives or {}, estado(jugador).Pasivas, os.clock(), azarDep)
			if efectos.UnidadExtra and unidades > 0 then
				unidades = unidades + 1
			end
			if efectos.Reaparece then
				reaparece = true
			end
			local entraron = 0
			if unidades > 0 then
				entraron = Inventory.AddMineral(jugador, regla.Mineral, unidades)
			end
			local xp = math.floor(parte.XP)
			if xp > 0 then
				Progression.AddXP(jugador, xp, "Mineria")
			end
			Datos.Replicar(jugador, "Minerals")
			Red:obtener("Mining.Loot"):FireClient(jugador, {
				Mineral = regla.Mineral, Name = m and m.Name or regla.Mineral, Rarity = regla.Rarity,
				Units = unidades, Entered = entraron, XP = xp, Extra = efectos.UnidadExtra, Respawn = efectos.Reaparece,
			})
			if entraron < unidades then
				avisar(jugador, "mochila_llena")
			end
		end
	end
	Analitica.Registrar(nil, "DepositoAgotado", nil, regla.Rarity)
	return reaparece
end

function MiningService.Iniciar(deps)
	Datos, Stats, Inventory, Deposits = deps.Datos, deps.Stats, deps.Inventory, deps.Deposits
	Progression, Analitica, Red = deps.Progression, deps.Analitica, deps.Red
	Deposits.AlAgotar(alAgotar)
	Red:conectar("Mining.Hit", golpear)
	Red:conectar("World.ReturnToSurface", subir)
	Players.PlayerRemoving:Connect(function(jugador)
		estados[jugador] = nil
		subiendo[jugador] = nil
	end)
end

function MiningService.AlGolpear(fn)
	table.insert(alGolpear, fn)
end

return MiningService
