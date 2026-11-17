-- Services/CombatService: ataque básico, bloqueo, dash, parpadeo, Ruptura y daño a jugadores (B4).
-- El cliente pide; el servidor valida alcance, ritmo, energía, cargas y enfriamientos, y calcula el daño (F19).
--
-- API para otros servicios:
--   DanarEnemigo(jugador, enemigo, coef, opciones) -> daño   (habilidades de PowerCoreService)
--   DanarJugador(jugador, dano, origen)                      (ataques de enemigos)
--   Aturdir(jugador, segundos) | Controlado(jugador) | UltimoBloqueo(jugador) | Mover(jugador, direccion, studs)
--   Arma(jugador) -> objeto | Hit(jugador, objetivoPos, dano, critico)

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Weapons = require(Shared.Config.Weapons)
local Stats = require(Shared.Config.Stats)
local Dano = require(Shared.Formulas.Dano)
local Inventario = require(Shared.Reglas.Inventario)
local Habilidades = require(Shared.Reglas.Habilidades)
local Server = script.Parent.Parent
local Combate = require(Server.Reglas.Combate)
local Lugares = require(Server.Util.Lugares)
local Eventos = require(Server.Util.Eventos)

local CombatService = {}

local Datos, StatsSvc, Enemigos, Progression, Economia, Analitica, Red
local estados = {}
local azar = Random.new()

local function aleatorio()
	return azar:NextNumber()
end

local function estado(jugador)
	local e = estados[jugador]
	if not e then
		e = {
			Dash = Combate.nuevoDash(), Enfriamientos = {}, Combo = {}, UltimoAtaque = -1e9,
			Bloqueando = false, UltimoBloqueo = -1e9, Control = Combate.nuevoControl(), InvulnHasta = -1e9,
			UltimoObjetivo = nil, Escudo = 0, EscudoHasta = -1e9,
		}
		estados[jugador] = e
	end
	return e
end

local function avisar(jugador, texto, kind)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Kind = kind, Short = true })
end

function CombatService.Arma(jugador)
	local perfil = Datos.GetProfile(jugador)
	return perfil and (Inventario.equipado(perfil, "Weapon")) or nil
end

-- Número de daño flotante para los jugadores cercanos.
function CombatService.Hit(jugador, posicion, dano, critico)
	local remote = Red:obtener("Combat.Hit")
	for _, otro in ipairs(Players:GetPlayers()) do
		local p = Lugares.posicion(otro)
		if p and (p - posicion).Magnitude <= 150 then
			remote:FireClient(otro, { Pos = posicion, Damage = math.floor(dano + 0.5), Crit = critico, Own = otro == jugador })
		end
	end
end

-- Daño de un jugador a un enemigo con un coeficiente (golpe básico o habilidad). Devuelve el daño aplicado.
-- opciones = { Secundario, Golpe, Extra }
function CombatService.DanarEnemigo(jugador, enemigo, coef, opciones)
	opciones = opciones or {}
	local perfil = Datos.GetProfile(jugador)
	local arma = CombatService.Arma(jugador)
	local d = StatsSvc.GetStats(jugador)
	if not perfil or not arma or not d or not enemigo or enemigo.Vida <= 0 then
		return 0
	end
	local tipo = Weapons.Types[arma.Type]
	local ahora = os.clock()
	local dano, critico = Combate.danoPvE({
		Potencia = Inventario.potencia(arma), Coef = coef, Fuerza = d.Effective.Strength,
		Maestria = Habilidades.maestriaArma(perfil, arma.Type), CritProb = Dano.critChance(tipo.CritBonus),
		Estados = enemigo.Estados, Golpe = opciones.Golpe or 1, Secundario = opciones.Secundario,
		Tutorial = enemigo.Zona == 1 and perfil.Progress.Level <= Weapons.Enemies.TutorialMaxLevel, Extra = opciones.Extra,
	}, ahora, aleatorio)
	local pos = enemigo.Raiz and enemigo.Raiz.Position
	estado(jugador).UltimoObjetivo = enemigo.Id
	local aplicado = Enemigos.Danar(enemigo.Id, jugador, dano)
	StatsSvc.MarcarCombate(jugador, "PvE")
	if pos and aplicado > 0 then
		CombatService.Hit(jugador, pos, aplicado, critico)
	end
	return aplicado
end

-- Ataque básico (Combat.Attack): hasta MaxTargets objetivos; el primero al 100 % y el resto al 25 %.
local function atacar(jugador, ids, _comboIndex)
	local e = estado(jugador)
	local ahora = os.clock()
	if Combate.controlado(e.Control, ahora) then
		return
	end
	local arma = CombatService.Arma(jugador)
	local d = StatsSvc.GetStats(jugador)
	local raiz = Lugares.raiz(jugador)
	if not arma or not d or not raiz then
		return
	end
	local tipo = Weapons.Types[arma.Type]
	local intervalo = 1 / (tipo.HitsPerSecond * d.AttackSpeed)
	if ahora - e.UltimoAtaque < intervalo * Weapons.AttackTimingTolerance then
		return
	end
	e.UltimoAtaque = ahora
	local alcance = tipo.Range * Weapons.RangeTolerance
	local usados, n = {}, 0
	for _, id in ipairs(ids) do
		local enemigo = Enemigos.Obtener(id)
		if enemigo and not usados[id] and n < tipo.MaxTargets and enemigo.Raiz
			and (enemigo.Raiz.Position - raiz.Position).Magnitude <= alcance + enemigo.Raiz.Size.X / 2 then
			usados[id] = true
			n = n + 1
			local golpe = Combate.contarGolpe(e.Combo, id, ahora)
			CombatService.DanarEnemigo(jugador, enemigo, tipo.Coef, { Secundario = n > 1, Golpe = golpe })
			-- Empuje: un poco en cada golpe y más en el remate del combo (cada 4.º golpe).
			local empuje = golpe % Weapons.ComboHits == 0 and Weapons.Feel.FinisherPushback or Weapons.Feel.HitPushback
			Enemigos.Empujar(id, raiz.Position, empuje)
		end
	end
end

-- Movimiento del servidor: hasta «studs» en horizontal sin atravesar paredes.
function CombatService.Mover(jugador, direccion, studs)
	local raiz = Lugares.raiz(jugador)
	if not raiz then
		return false
	end
	local dir = Vector3.new(direccion.X, 0, direccion.Z)
	if dir.Magnitude < 0.05 then
		dir = Vector3.new(raiz.CFrame.LookVector.X, 0, raiz.CFrame.LookVector.Z)
	end
	if dir.Magnitude < 0.05 then
		return false
	end
	dir = dir.Unit
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { jugador.Character }
	local distancia = studs
	local choque = workspace:Raycast(raiz.Position, dir * studs, params)
	if choque then
		distancia = math.max(0, (choque.Position - raiz.Position).Magnitude - 2)
	end
	jugador.Character:PivotTo(jugador.Character:GetPivot() + dir * distancia)
	return true
end

local function dash(jugador, direccion)
	local e = estado(jugador)
	local ahora = os.clock()
	if Combate.controlado(e.Control, ahora) then
		return
	end
	if Combate.cargasDash(e.Dash, ahora) < 1 then
		return
	end
	if not StatsSvc.GastarEnergia(jugador, Stats.Energy.Cost.Dash) then
		avisar(jugador, "Sin energía", "Warning")
		return
	end
	Combate.usarDash(e.Dash, ahora)
	CombatService.Mover(jugador, direccion, Stats.Dash.Distance)
end

local function parpadeo(jugador, direccion)
	local e = estado(jugador)
	local ahora = os.clock()
	local d = StatsSvc.GetStats(jugador)
	if not d or not d.BlinkUnlocked then
		avisar(jugador, "El parpadeo se desbloquea con 50 de Velocidad", "Warning")
		return
	end
	if Combate.controlado(e.Control, ahora) or not Combate.listo(e.Enfriamientos, "Blink", ahora) then
		return
	end
	if not StatsSvc.GastarEnergia(jugador, Stats.Energy.Cost.Blink) then
		avisar(jugador, "Sin energía", "Warning")
		return
	end
	Combate.usar(e.Enfriamientos, "Blink", ahora, Stats.Energy.Cooldown.Blink)
	CombatService.Mover(jugador, direccion, Stats.Blink.Distance)
end

local function bloquear(jugador, activo)
	local e = estado(jugador)
	if activo and Combate.controlado(e.Control, os.clock()) then
		return
	end
	e.Bloqueando = activo
	StatsSvc.FijarBloqueo(jugador, activo)
	local personaje = jugador.Character
	if personaje then
		personaje:SetAttribute("Bloqueando", activo)
	end
end

-- Control sobre un jugador (aturdir). Aplica la Tenacidad. Devuelve los segundos aplicados.
function CombatService.Aturdir(jugador, segundos)
	local e = estado(jugador)
	local ahora = os.clock()
	local aplicado = Combate.aplicarControl(e.Control, ahora, segundos)
	if aplicado <= 0 then
		return 0
	end
	bloquear(jugador, false)
	StatsSvc.FijarAturdido(jugador, true)
	local personaje = jugador.Character
	if personaje then
		personaje:SetAttribute("ControladoHasta", workspace:GetServerTimeNow() + (e.Control.ControladoHasta - ahora))
	end
	local hasta = e.Control.ControladoHasta
	task.delay(hasta - ahora, function()
		if estados[jugador] == e and not Combate.controlado(e.Control, os.clock()) then
			StatsSvc.FijarAturdido(jugador, false)
		end
	end)
	return aplicado
end

function CombatService.Controlado(jugador)
	local e = estados[jugador]
	return e ~= nil and Combate.controlado(e.Control, os.clock())
end

local function guardiaRota(jugador)
	avisar(jugador, "¡Guardia rota!", "Warning")
	CombatService.Aturdir(jugador, Weapons.Control.GuardBreakPvE)
end

-- Ruptura: tras 0,8 s bajo control, 50 de energía: se libera y empuja a los enemigos cercanos.
local function ruptura(jugador)
	local e = estado(jugador)
	local ahora = os.clock()
	if not Combate.puedeRuptura(e.Control, ahora) or not Combate.listo(e.Enfriamientos, "Break", ahora) then
		return
	end
	if not StatsSvc.GastarEnergia(jugador, Stats.Energy.Cost.Break) then
		avisar(jugador, "Sin energía para la Ruptura", "Warning")
		return
	end
	Combate.usar(e.Enfriamientos, "Break", ahora, Stats.Energy.Cooldown.Break)
	Combate.liberar(e.Control, ahora)
	StatsSvc.FijarAturdido(jugador, false)
	local pos = Lugares.posicion(jugador)
	if pos then
		for _, enemigo in ipairs(Enemigos.EnRadio(pos, 10)) do
			Enemigos.Empujar(enemigo.Id, pos, 10)
		end
	end
	avisar(jugador, "¡Ruptura!")
end

function CombatService.UltimoObjetivo(jugador)
	local e = estados[jugador]
	return e and e.UltimoObjetivo
end

function CombatService.FijarEscudo(jugador, cantidad, segundos)
	local e = estado(jugador)
	e.Escudo = cantidad
	e.EscudoHasta = os.clock() + segundos
end

function CombatService.UltimoBloqueo(jugador)
	return estado(jugador).UltimoBloqueo
end

-- Daño de un enemigo a un jugador: esquiva perfecta, invulnerabilidad, defensa y bloqueo frontal.
function CombatService.DanarJugador(jugador, dano, enemigo)
	local personaje = jugador.Character
	local h = personaje and personaje:FindFirstChildOfClass("Humanoid")
	local raiz = Lugares.raiz(jugador)
	if not h or h.Health <= 0 or not raiz then
		return 0
	end
	local e = estado(jugador)
	local ahora = os.clock()
	StatsSvc.MarcarCombate(jugador, "PvE")
	if ahora < e.InvulnHasta then
		return 0
	end
	if Combate.esquivaPerfecta(e.Dash, ahora) then
		e.InvulnHasta = ahora + Stats.Dash.PerfectDodgeInvuln
		avisar(jugador, "¡Esquiva perfecta!")
		return 0
	end
	local deFrente = false
	if enemigo and enemigo.Raiz then
		local haciaEnemigo = enemigo.Raiz.Position - raiz.Position
		haciaEnemigo = Vector3.new(haciaEnemigo.X, 0, haciaEnemigo.Z)
		if haciaEnemigo.Magnitude > 0.01 then
			deFrente = raiz.CFrame.LookVector:Dot(haciaEnemigo.Unit) > Weapons.Block.FrontDot
		end
	end
	local bloqueado = e.Bloqueando and deFrente
	if bloqueado then
		if StatsSvc.GastarEnergia(jugador, Stats.Energy.Cost.BlockHit) then
			e.UltimoBloqueo = ahora
		else
			bloqueado = false
			guardiaRota(jugador)
		end
	end
	local d = StatsSvc.GetStats(jugador)
	local final = Combate.danoRecibido(dano, d and d.DefensePvE or 0, bloqueado, true)
	if e.Escudo > 0 and ahora < e.EscudoHasta then   -- escudo de mascotas: absorbe primero
		local absorbe = math.min(e.Escudo, final)
		e.Escudo = e.Escudo - absorbe
		final = final - absorbe
	end
	h.Health = math.max(0, h.Health - final)
	CombatService.Hit(nil, raiz.Position, final, false)
	return final
end

-- Bloqueo sostenido: 8 de energía por segundo; sin energía, guardia rota.
local function bucleBloqueo()
	local paso = 0.25
	while true do
		task.wait(paso)
		for jugador, e in pairs(estados) do
			if e.Bloqueando then
				if not StatsSvc.GastarEnergia(jugador, Stats.Energy.Cost.BlockPerSec * paso) then
					bloquear(jugador, false)
					guardiaRota(jugador)
				end
			end
		end
	end
end

-- Recompensas al derrotar un enemigo: XP, monedas y maestría del arma y del Núcleo de cada participante.
local function alMorir(enemigo)
	if enemigo.Jefe then
		return   -- las recompensas de los jefes las reparte BossService (límite diario, materiales)
	end
	local xp = Dano.enemyXP(enemigo.Zona, enemigo.Tipo)
	local monedas = Dano.enemyCoins(enemigo.Zona, enemigo.Tipo)
	local puntos = Weapons.Mastery.Points[enemigo.Tipo] or 1
	for _, r in ipairs(Combate.reparto(enemigo.Danos, xp, monedas, puntos)) do
		local jugador = Players:GetPlayerByUserId(r.UserId)
		local perfil = jugador and Datos.GetProfile(jugador)
		if perfil then
			if r.XP >= 1 then
				Progression.AddXP(jugador, math.floor(r.XP), "Combate")
			end
			if r.Coins > 0 then
				Economia.AddCoins(jugador, r.Coins, "Enemigo")
			end
			if r.Mastery > 0 then
				CombatService.SumarMaestria(jugador, r.Mastery)
				Eventos.emitir("EnemigoDerrotado", jugador, 1, { Tipo = enemigo.Tipo })
			end
		end
	end
	Analitica.Registrar(nil, "EnemigoDerrotado", nil, enemigo.Tipo)
end

-- Maestría del arma y del Núcleo equipados. Avisa de los niveles y de lo que se desbloquea.
local maestriaHooks = {}
function CombatService.AlSubirMaestria(fn)
	table.insert(maestriaHooks, fn)
end

function CombatService.SumarMaestria(jugador, puntos)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	local arma = CombatService.Arma(jugador)
	if arma then
		perfil.WeaponMastery[arma.Type] = perfil.WeaponMastery[arma.Type] or { Level = 1, XP = 0 }
		local subidos = Combate.sumarMaestria(perfil.WeaponMastery[arma.Type], puntos)
		if subidos > 0 then
			for _, fn in ipairs(maestriaHooks) do
				task.spawn(fn, jugador, "Weapon", arma.Type, perfil.WeaponMastery[arma.Type].Level)
			end
		end
	end
	local nucleo = perfil.Equipped.Core
	if nucleo ~= "" then
		local c = perfil.Cores[nucleo]
		if c then
			local registro = { Level = c.Mastery, XP = c.XP }
			local subidos = Combate.sumarMaestria(registro, puntos)
			c.Mastery, c.XP = registro.Level, registro.XP
			if subidos > 0 then
				for _, fn in ipairs(maestriaHooks) do
					task.spawn(fn, jugador, "Core", nucleo, c.Mastery)
				end
			end
		end
	end
	Datos.Replicar(jugador, "WeaponMastery", "Cores")
end

function CombatService.Iniciar(deps)
	Datos, StatsSvc, Enemigos, Progression = deps.Datos, deps.Stats, deps.Enemigos, deps.Progression
	Economia, Analitica, Red = deps.Economia, deps.Analitica, deps.Red
	Red:conectar("Combat.Attack", atacar)
	Red:conectar("Combat.Block", bloquear)
	Red:conectar("Combat.Dash", dash)
	Red:conectar("Combat.Blink", parpadeo)
	Red:conectar("Combat.Break", ruptura)
	Enemigos.FijarAtaque(CombatService.DanarJugador)
	Enemigos.AlMorir(alMorir)
	Players.PlayerRemoving:Connect(function(jugador)
		estados[jugador] = nil
	end)
	Players.PlayerAdded:Connect(function(jugador)
		jugador.CharacterAdded:Connect(function()
			local e = estados[jugador]
			if e then
				e.Bloqueando = false
				e.Control = Combate.nuevoControl()
			end
		end)
	end)
	task.spawn(bucleBloqueo)
end

-- Estado de combate de un jugador (para PowerCoreService: enfriamientos y control).
function CombatService.Estado(jugador)
	return estado(jugador)
end

return CombatService
