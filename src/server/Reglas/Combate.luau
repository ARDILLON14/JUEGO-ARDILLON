-- Reglas/Combate: piezas puras del combate (B4). El tiempo y el azar entran como parámetro.
--   combo, estados, daño de un golpe, cargas de dash, enfriamientos, control y Tenacidad, maestría, reparto.

local Shared = game:GetService("ReplicatedStorage").Shared
local Weapons = require(Shared.Config.Weapons)
local Stats = require(Shared.Config.Stats)
local Dano = require(Shared.Formulas.Dano)

local Combate = {}

-- Combo ----------------------------------------------------------------
-- Golpes 1 a 4 al 100 %; después 90, 80, 70, 60 y 50 % (mínimo 50 %). n = número de golpe seguido a ese objetivo.
function Combate.factorCombo(n)
	local c = Weapons.Combo
	if n <= c.FullHits then
		return 1
	end
	return c.Falloff[n - c.FullHits] or c.Min
end

-- registro = { [objetivo] = { N, Ultimo } }. Devuelve el número de golpe seguido para este.
function Combate.contarGolpe(registro, objetivo, ahora)
	local r = registro[objetivo]
	if not r or ahora - r.Ultimo > Weapons.ComboResetSeconds then
		r = { N = 0, Ultimo = ahora }
		registro[objetivo] = r
	end
	r.N = r.N + 1
	r.Ultimo = ahora
	return r.N
end

-- Estados alterados ----------------------------------------------------
-- estados = { [nombre] = { Hasta, Valor } }. Suma de aumentos de daño recibido activos, máximo +40 %.
function Combate.bonoEstados(estados, ahora)
	local total = 0
	for _, e in pairs(estados or {}) do
		if e.Hasta > ahora and e.DanoRecibido then
			total = total + e.DanoRecibido
		end
	end
	return math.min(total, Weapons.StatusCap)
end

function Combate.ponerEstado(estados, nombre, ahora, segundos, datos)
	local e = { Hasta = ahora + segundos }
	for k, v in pairs(datos or {}) do
		e[k] = v
	end
	estados[nombre] = e
	return e
end

function Combate.tieneEstado(estados, nombre, ahora)
	local e = estados and estados[nombre]
	return e ~= nil and e.Hasta > ahora
end

-- Ralentización activa más fuerte (0..1).
function Combate.lentitud(estados, ahora)
	local maxima = 0
	for _, e in pairs(estados or {}) do
		if e.Hasta > ahora and e.Lento then
			maxima = math.max(maxima, e.Lento)
		end
	end
	return maxima
end

-- Daño de un golpe o habilidad contra un enemigo (PvE) ----------------
-- p = { Potencia, Coef, Fuerza, Maestria, CritProb, CritMult, Estados, Golpe (n.º en el combo), Secundario, Tutorial, Extra }
-- aleatorio() en [0, 1). Devuelve daño y si fue crítico.
function Combate.danoPvE(p, ahora, aleatorio)
	local critico = aleatorio() < (p.CritProb or Weapons.Crit.Chance)
	local extra = (p.Extra or 1) * Combate.factorCombo(p.Golpe or 1)
	if p.Secundario then
		extra = extra * Weapons.SecondaryTargetDamage
	end
	if p.Tutorial then
		extra = extra / Weapons.Enemies.TutorialHealthFactor
	end
	local dano = Dano.final({
		WeaponPower = p.Potencia, Coef = p.Coef, Strength = p.Fuerza, Mastery = p.Maestria,
		Crit = critico, CritMultiplier = p.CritMult, Status = Combate.bonoEstados(p.Estados, ahora),
		TargetDefense = 0, Mode = "PvE", Extra = extra,
	})
	return dano, critico
end

-- Daño que recibe un jugador: defensa PvE y bloqueo frontal.
function Combate.danoRecibido(dano, defensaPvE, bloqueando, deFrente)
	local d = dano * (1 - defensaPvE)
	if bloqueando and deFrente then
		d = d * (1 - Weapons.Block.Reduction)
	end
	return d
end

-- Dash: 2 cargas, cada una se recarga en 3 s --------------------------
function Combate.nuevoDash()
	return { Cargas = Stats.Dash.Charges, Recarga = 0, UltimoDash = -1e9 }
end

local function recargar(d, ahora)
	local max = Stats.Dash.Charges
	while d.Cargas < max and d.Recarga <= ahora do
		d.Cargas = d.Cargas + 1
		if d.Cargas < max then
			d.Recarga = d.Recarga + Stats.Dash.RechargeSeconds
		end
	end
end

function Combate.cargasDash(d, ahora)
	recargar(d, ahora)
	return d.Cargas
end

-- Gasta una carga si hay. La recarga empieza al gastar la primera de un depósito lleno.
function Combate.usarDash(d, ahora)
	recargar(d, ahora)
	if d.Cargas < 1 then
		return false
	end
	if d.Cargas == Stats.Dash.Charges then
		d.Recarga = ahora + Stats.Dash.RechargeSeconds
	end
	d.Cargas = d.Cargas - 1
	d.UltimoDash = ahora
	return true
end

-- Esquiva perfecta: el golpe llega en los 0,25 s posteriores a un dash.
function Combate.esquivaPerfecta(d, momentoGolpe)
	local dt = momentoGolpe - d.UltimoDash
	return dt >= 0 and dt <= Stats.Dash.PerfectDodgeWindow
end

-- Enfriamientos --------------------------------------------------------
function Combate.listo(enfriamientos, id, ahora)
	return (enfriamientos[id] or 0) <= ahora
end

function Combate.restante(enfriamientos, id, ahora)
	return math.max(0, (enfriamientos[id] or 0) - ahora)
end

function Combate.usar(enfriamientos, id, ahora, segundos)
	enfriamientos[id] = ahora + segundos
end

-- Control y Tenacidad (GDD; B4, sección 6) -----------------------------
-- estado = { Aplicaciones = { momentos }, InmuneHasta, ControladoDesde, ControladoHasta }
function Combate.nuevoControl()
	return { Aplicaciones = {}, InmuneHasta = -1e9, ControladoDesde = -1e9, ControladoHasta = -1e9 }
end

-- Aplica un control (aturdir, congelar...) de «segundos». Devuelve los segundos que de verdad se aplican.
-- En 6 s: el primero entero, el segundo al 50 % y deja 5 s de Tenacidad; nadie queda controlado más de 2,5 s seguidos.
function Combate.aplicarControl(c, ahora, segundos)
	if ahora < c.InmuneHasta then
		return 0
	end
	local cfg = Weapons.Control
	local recientes = {}
	for _, t in ipairs(c.Aplicaciones) do
		if ahora - t < cfg.Window then
			table.insert(recientes, t)
		end
	end
	c.Aplicaciones = recientes
	local factor = 1
	if #recientes == 1 then
		factor = cfg.SecondFactor
	elseif #recientes >= 2 then
		return 0
	end
	table.insert(c.Aplicaciones, ahora)
	local desde = c.ControladoDesde
	if ahora > c.ControladoHasta then
		desde = ahora
	end
	local hasta = math.max(c.ControladoHasta, ahora + segundos * factor)
	hasta = math.min(hasta, desde + cfg.StunCap)
	local aplicado = math.max(0, hasta - math.max(ahora, c.ControladoHasta))
	c.ControladoDesde = desde
	c.ControladoHasta = hasta
	if #c.Aplicaciones >= 2 then
		c.InmuneHasta = hasta + cfg.TenacitySeconds
	end
	return aplicado
end

function Combate.controlado(c, ahora)
	return ahora < c.ControladoHasta
end

-- Ruptura: tras 0,8 s bajo control se puede liberar.
function Combate.puedeRuptura(c, ahora)
	return Combate.controlado(c, ahora) and ahora - c.ControladoDesde >= Stats.Break.MinControlledSeconds
end

function Combate.liberar(c, ahora)
	c.ControladoHasta = ahora
end

-- Maestría -------------------------------------------------------------
-- registro = { Level, XP }. Suma puntos y sube los niveles que toque. Devuelve los niveles subidos.
function Combate.sumarMaestria(registro, puntos)
	registro.XP = (registro.XP or 0) + puntos
	registro.Level = registro.Level or 1
	local subidos = 0
	while registro.XP >= Dano.masteryXP(registro.Level) do
		registro.XP = registro.XP - Dano.masteryXP(registro.Level)
		registro.Level = registro.Level + 1
		subidos = subidos + 1
	end
	return subidos
end

-- Reparto de un enemigo derrotado: XP y monedas en proporción al daño; puntos de maestría enteros para
-- quien hizo al menos el 10 %. Devuelve { { UserId, Share, XP, Coins, Mastery } } ordenado por UserId.
function Combate.reparto(danos, xp, monedas, puntosMaestria)
	local total, filas = 0, {}
	for userId, d in pairs(danos) do
		total = total + d
		table.insert(filas, { UserId = userId, Dano = d })
	end
	table.sort(filas, function(a, b)
		return a.UserId < b.UserId
	end)
	local salida = {}
	if total <= 0 then
		return salida
	end
	for _, f in ipairs(filas) do
		local share = f.Dano / total
		table.insert(salida, {
			UserId = f.UserId, Share = share, XP = xp * share, Coins = math.floor(monedas * share + 1e-6),
			Mastery = share >= 0.10 and puntosMaestria or 0,
		})
	end
	return salida
end

return Combate
