-- Services/PowerCoreService: Núcleos de Poder, habilidades en Z, X, C y V, y técnicas de arma (B4, secciones 1.4 y 5).
-- Fase 4: Núcleo Prismático completo y técnicas de Espada, Daga y Bastón. Los otros Núcleos usan un efecto
-- genérico por tipo de ranura hasta su fase. Despertar y Transformación llegan en la expansión 1 (roadmap).

local Debris = game:GetService("Debris")

local Shared = game:GetService("ReplicatedStorage").Shared
local PowerCores = require(Shared.Config.PowerCores)
local Weapons = require(Shared.Config.Weapons)
local Habilidades = require(Shared.Reglas.Habilidades)
local Nombres = require(Shared.Visual.Nombres)
local Server = script.Parent.Parent
local Combate = require(Server.Reglas.Combate)
local Lugares = require(Server.Util.Lugares)
local Eventos = require(Server.Util.Eventos)

local PowerCoreService = {}

local Datos, StatsSvc, Combat, Enemigos, Analitica, Red

local function avisar(jugador, texto, kind)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Kind = kind, Short = true })
end

local function rechazar(jugador, ranura, motivo, restante)
	Red:obtener("Combat.Rejected"):FireClient(jugador, { Slot = ranura, Reason = motivo, Remaining = restante })
end

-- Efecto visual breve y sin colisión, visible para todos.
local function efecto(cframe, tam, color, forma, segundos, transparencia)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = transparencia or 0.4
	p.Shape = forma or Enum.PartType.Block
	p.Size = tam
	p.CFrame = cframe
	p.Parent = workspace
	Debris:AddItem(p, segundos or 0.3)
	return p
end

local LUZ = Color3.fromRGB(190, 240, 255)

local function horizontal(v, raiz)
	local d = Vector3.new(v.X, 0, v.Z)
	if d.Magnitude < 0.05 then
		d = Vector3.new(raiz.CFrame.LookVector.X, 0, raiz.CFrame.LookVector.Z)
	end
	return d.Unit
end

local function golpear(jugador, enemigo, coef, extra)
	return Combat.DanarEnemigo(jugador, enemigo, coef, { Extra = extra })
end

local function rayo(origen, dir, alcance, grosor, color)
	local fin = origen + dir * alcance
	efecto(CFrame.lookAt((origen + fin) / 2, fin), Vector3.new(grosor, grosor, alcance), color, Enum.PartType.Block, 0.25)
end

-- Efectos de cada habilidad: fn(jugador, raiz, dir, datos) -> true si se usó.
local EFECTOS = {}

-- Núcleo Prismático (GDD) ------------------------------------------------
EFECTOS.PrismaticLance = function(jugador, raiz, dir, h)
	local alcance = PowerCores.ProjectileRange
	local objetivo = Enemigos.EnLinea(raiz.Position, dir, alcance, 2)[1]
	rayo(raiz.Position, dir, objetivo and (objetivo.Raiz.Position - raiz.Position).Magnitude or alcance, 0.8, LUZ)
	if objetivo then
		golpear(jugador, objetivo, h.Coef)
		Enemigos.PonerEstado(objetivo.Id, "Lento", h.SlowSeconds, { Lento = h.Slow })
	end
	return true
end

EFECTOS.RefractionField = function(jugador, raiz, _dir, h)
	efecto(CFrame.new(raiz.Position), Vector3.new(h.Radius * 2, h.Radius * 2, h.Radius * 2), LUZ, Enum.PartType.Ball, 0.4, 0.75)
	for _, e in ipairs(Enemigos.EnRadio(raiz.Position, h.Radius)) do
		golpear(jugador, e, h.Coef)
		Enemigos.PonerEstado(e.Id, "Refracted", h.RefractedSeconds, { DanoRecibido = h.RefractedBonus })
	end
	return true
end

EFECTOS.LightningStep = function(jugador, raiz, dir, h)
	local ahora = os.clock()
	local objetivo
	for _, e in ipairs(Enemigos.EnRadio(raiz.Position, h.Distance)) do
		if Combate.tieneEstado(e.Estados, "Refracted", ahora) then
			objetivo = e
			break
		end
	end
	local inicio = raiz.Position
	if objetivo then
		local hacia = objetivo.Raiz.Position - raiz.Position
		Combat.Mover(jugador, hacia, math.max(0, hacia.Magnitude - 4))
		golpear(jugador, objetivo, h.Coef)
	else
		Combat.Mover(jugador, dir, h.DistanceNoTarget)
		for _, e in ipairs(Enemigos.EnRadio(raiz.Position, 5)) do
			golpear(jugador, e, h.Coef)
		end
	end
	rayo(inicio, horizontal(raiz.Position - inicio + dir * 0.01, raiz), (raiz.Position - inicio).Magnitude, 0.5, Color3.fromRGB(255, 255, 160))
	return true
end

EFECTOS.TotalPrism = function(jugador, raiz, _dir, h)
	local centro = raiz.Position
	local radio = PowerCores.AreaRadius
	efecto(CFrame.new(centro), Vector3.new(radio * 2, radio * 2, radio * 2), LUZ, Enum.PartType.Ball, h.Seconds, 0.8)
	task.spawn(function()
		for _ = 1, h.Rays do
			for _, e in ipairs(Enemigos.EnRadio(centro, radio)) do
				Enemigos.PonerEstado(e.Id, "Lento", 1.2, { Lento = h.Slow })
				if e.Raiz then
					efecto(CFrame.new(e.Raiz.Position + Vector3.new(0, 6, 0)), Vector3.new(0.6, 12, 0.6), LUZ, Enum.PartType.Block, 0.2)
				end
				golpear(jugador, e, h.Coef / h.Rays)
			end
			task.wait(h.Seconds / h.Rays)
		end
	end)
	return true
end

-- Técnicas de arma (B4, 1.4) ---------------------------------------------
local function masCercanoDelante(raiz, dir, alcance)
	return Enemigos.EnLinea(raiz.Position, dir, alcance, 4)[1] or Enemigos.EnRadio(raiz.Position, alcance)[1]
end

EFECTOS.SpinningSlash = function(jugador, raiz, _dir, h)
	efecto(CFrame.new(raiz.Position) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(1, 16, 16), Color3.fromRGB(230, 230, 255), Enum.PartType.Cylinder, 0.25, 0.6)
	for _, e in ipairs(Enemigos.EnRadio(raiz.Position, 8)) do
		golpear(jugador, e, h.Coef)
	end
	return true
end

EFECTOS.Riposte = function(jugador, raiz, dir, h)
	if os.clock() - Combat.UltimoBloqueo(jugador) > Weapons.Block.RiposteWindow then
		avisar(jugador, "Contragolpe: bloquea un golpe justo antes", "Warning")
		return false
	end
	local e = masCercanoDelante(raiz, dir, 8)
	if e then
		golpear(jugador, e, h.Coef)
	end
	return true
end

EFECTOS.DoubleStab = function(jugador, raiz, dir, h)
	local e = masCercanoDelante(raiz, dir, Weapons.Types.Dagger.Range * Weapons.RangeTolerance)
	if not e then
		return true
	end
	golpear(jugador, e, h.Coef / 2)
	task.delay(0.15, function()
		if e.Vida > 0 then
			golpear(jugador, e, h.Coef / 2)
		end
	end)
	return true
end

EFECTOS.FleetingShadow = function(jugador, raiz, dir, h)
	local e = masCercanoDelante(raiz, dir, 15)
	if not e then
		return true
	end
	local detras = e.Raiz.Position + horizontal(e.Raiz.Position - raiz.Position, raiz) * 4
	jugador.Character:PivotTo(CFrame.lookAt(detras, Vector3.new(e.Raiz.Position.X, detras.Y, e.Raiz.Position.Z)))
	golpear(jugador, e, h.Coef)
	return true
end

EFECTOS.ChargedOrb = function(jugador, raiz, dir, h)
	rayo(raiz.Position, dir, Weapons.Types.Staff.Range, 1.2, Color3.fromRGB(170, 120, 255))
	for _, e in ipairs(Enemigos.EnLinea(raiz.Position, dir, Weapons.Types.Staff.Range, 2)) do
		golpear(jugador, e, h.Coef)
	end
	return true
end

EFECTOS.ArcanePulse = function(jugador, raiz, _dir, h)
	efecto(CFrame.new(raiz.Position), Vector3.new(20, 20, 20), Color3.fromRGB(170, 120, 255), Enum.PartType.Ball, 0.35, 0.7)
	for _, e in ipairs(Enemigos.EnRadio(raiz.Position, 10)) do
		golpear(jugador, e, h.Coef)
		Enemigos.PonerEstado(e.Id, "Lento", 2, { Lento = 0.2 })
	end
	return true
end

-- Efecto genérico por tipo de ranura (Núcleos sin implementar todavía) ---
local GENERICO = {
	Z = function(jugador, raiz, dir, h)
		local e = Enemigos.EnLinea(raiz.Position, dir, PowerCores.ProjectileRange, 2)[1]
		rayo(raiz.Position, dir, PowerCores.ProjectileRange, 0.8, Color3.fromRGB(255, 160, 80))
		if e then
			golpear(jugador, e, h.Coef)
		end
		return true
	end,
	X = function(jugador, raiz, _dir, h)
		for _, e in ipairs(Enemigos.EnRadio(raiz.Position, 12)) do
			golpear(jugador, e, h.Coef)
			Enemigos.PonerEstado(e.Id, "Lento", 2, { Lento = 0.3 })
		end
		return true
	end,
	C = function(jugador, raiz, dir, h)
		Combat.Mover(jugador, dir, 14)
		for _, e in ipairs(Enemigos.EnRadio(raiz.Position, 5)) do
			golpear(jugador, e, h.Coef)
		end
		return true
	end,
	V = function(jugador, raiz, _dir, h)
		for _, e in ipairs(Enemigos.EnRadio(raiz.Position, PowerCores.AreaRadius)) do
			golpear(jugador, e, h.Coef)
		end
		return true
	end,
}

-- Combat.Cast -------------------------------------------------------------
local function lanzar(jugador, ranura, aim)
	local perfil = Datos.GetProfile(jugador)
	local id = perfil.Equipped.Loadout[ranura]
	if not id or id == "" then
		return rechazar(jugador, ranura, "vacia")
	end
	local h = Habilidades.buscar(perfil, id)
	if not h or not h.Desbloqueada then
		return rechazar(jugador, ranura, "bloqueada")
	end
	local arma = Combat.Arma(jugador)
	if not arma then
		avisar(jugador, "Equipa un arma para usar habilidades", "Warning")
		return rechazar(jugador, ranura, "sin_arma")
	end
	if Combat.Controlado(jugador) then
		return rechazar(jugador, ranura, "controlado")
	end
	local raiz = Lugares.raiz(jugador)
	if not raiz then
		return
	end
	local estado = Combat.Estado(jugador)
	local ahora = os.clock()
	if not Combate.listo(estado.Enfriamientos, id, ahora) then
		return rechazar(jugador, ranura, "enfriamiento", Combate.restante(estado.Enfriamientos, id, ahora))
	end
	local coste = h.Datos.Energy
	local descuento = Weapons.Types[arma.Type].EnergyDiscount
	if descuento then
		coste = coste * (1 - descuento)
	end
	if StatsSvc.GetEnergia(jugador) + 1e-6 < coste then
		avisar(jugador, "Sin energía", "Warning")
		return rechazar(jugador, ranura, "energia")
	end
	local dir = horizontal(aim, raiz)
	local fn = EFECTOS[id] or (h.Fuente == "Core" and GENERICO[h.Ranura]) or GENERICO.Z
	local ok, usado = pcall(fn, jugador, raiz, dir, h.Datos)
	if not ok then
		warn("PowerCoreService: " .. tostring(usado))
		return rechazar(jugador, ranura, "error")
	end
	if not usado then
		return rechazar(jugador, ranura, "condicion")
	end
	StatsSvc.GastarEnergia(jugador, coste)
	Combate.usar(estado.Enfriamientos, id, ahora, h.Datos.Cooldown)
	StatsSvc.MarcarCombate(jugador, "PvE")
	Analitica.Registrar(jugador, "HabilidadUsada", nil, id)
	Eventos.emitir("HabilidadUsada", jugador, 1, { Id = id })
end

-- Combat.SetLoadout y Core.Equip -----------------------------------------
local function fijarReparto(jugador, reparto)
	local perfil = Datos.GetProfile(jugador)
	if StatsSvc.EnCombate(jugador) then
		return false, "en_combate"
	end
	local ok, motivo = Habilidades.validarReparto(perfil, reparto)
	if not ok then
		return false, motivo
	end
	perfil.Equipped.Loadout = { Z = reparto.Z, X = reparto.X, C = reparto.C, V = reparto.V }
	Datos.Replicar(jugador, "Equipped")
	return true
end

-- Pone en su ranura las habilidades del Núcleo recién desbloqueadas si esa ranura está vacía.
local function rellenarReparto(perfil)
	local cambio = Habilidades.limpiarReparto(perfil)
	local inicial = Habilidades.repartoInicial(perfil)
	for _, ranura in ipairs(Habilidades.Ranuras) do
		if perfil.Equipped.Loadout[ranura] == "" and inicial[ranura] ~= "" then
			local usado = false
			for _, r in ipairs(Habilidades.Ranuras) do
				if perfil.Equipped.Loadout[r] == inicial[ranura] then
					usado = true
				end
			end
			if not usado then
				perfil.Equipped.Loadout[ranura] = inicial[ranura]
				cambio = true
			end
		end
	end
	return cambio
end
PowerCoreService.RellenarReparto = rellenarReparto

local enCiudad = function()
	return true
end
function PowerCoreService.FijarCiudad(fn)
	enCiudad = fn
end

local function equiparNucleo(jugador, nucleo)
	local perfil = Datos.GetProfile(jugador)
	if not PowerCores.Cores[nucleo] or not perfil.Cores[nucleo] then
		return false, "nucleo"
	end
	if perfil.Equipped.Core == nucleo then
		return true
	end
	if StatsSvc.EnCombate(jugador) then
		return false, "en_combate"
	end
	-- Fuera de la ciudad cuesta un Sello de Reajuste (GDD; B6 2.4).
	if not enCiudad(jugador) then
		if (perfil.Consumables.ReadjustSeal or 0) < 1 then
			return false, "sello"
		end
		perfil.Consumables.ReadjustSeal = perfil.Consumables.ReadjustSeal - 1
		Datos.Replicar(jugador, "Consumables")
	end
	perfil.Equipped.Core = nucleo
	rellenarReparto(perfil)
	Datos.Replicar(jugador, "Equipped")
	return true
end

-- Avisos de maestría: nivel nuevo y habilidad desbloqueada.
local function alSubirMaestria(jugador, clase, cual, nivel)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	local nombre = clase == "Core" and (Nombres.Nucleo[cual] or cual) or (Nombres.Arma[cual] or cual)
	Red:obtener("Notify"):FireClient(jugador, { Text = "Maestría de " .. nombre .. ": nivel " .. nivel, Color = Color3.fromRGB(190, 240, 255) })
	for _, h in ipairs(Habilidades.disponibles(perfil)) do
		local fuenteOk = (clase == "Core" and h.Fuente == "Core") or (clase == "Weapon" and h.Fuente == "Weapon")
		if fuenteOk and h.Requisito == nivel then
			Red:obtener("Notify"):FireClient(jugador, { Text = "¡Desbloqueada: " .. (Nombres.Habilidad[h.Id] or h.Id) .. "!", Color = Color3.fromRGB(255, 230, 120) })
		end
	end
	if rellenarReparto(perfil) then
		Datos.Replicar(jugador, "Equipped")
	end
end

function PowerCoreService.Iniciar(deps)
	Datos, StatsSvc, Combat, Enemigos, Analitica, Red = deps.Datos, deps.Stats, deps.Combat, deps.Enemigos, deps.Analitica, deps.Red
	Red:conectar("Combat.Cast", lanzar)
	Red:conectar("Combat.SetLoadout", fijarReparto)
	Red:conectar("Core.Equip", equiparNucleo)
	Combat.AlSubirMaestria(alSubirMaestria)
	Datos.AlCargar(function(jugador, perfil)
		if rellenarReparto(perfil) then
			Datos.Replicar(jugador, "Equipped")
		end
	end)
end

return PowerCoreService
