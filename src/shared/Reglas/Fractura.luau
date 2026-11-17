-- Reglas/Fractura: carga, saqueo, extracción, racha, protecciones y contratos de las Zonas Fracturadas (B3 sección 7;
-- B6 sección 7). Puro. El mineral de la grieta se guarda en Minerals.Fractured hasta extraerlo.

local Shared = script.Parent.Parent
local Fracture = require(Shared.Config.Fracture)
local Mining = require(Shared.Config.Mining)
local Rarity = require(Shared.Config.Rarity)
local Pickaxes = require(Shared.Config.Pickaxes)
local Mineria = require(Shared.Formulas.Mineria)
local Economia = require(Shared.Formulas.Economia)
local Mochila = require(script.Parent.Mochila)
local Inventario = require(script.Parent.Inventario)

local Fractura = {}

local function total(t)
	local n = 0
	for _, v in pairs(t or {}) do
		n = n + v
	end
	return n
end
Fractura.unidades = function(perfil)
	return total(perfil.Minerals.Fractured)
end

-- Valor a ×1,0 de lo que se lleva en la grieta.
function Fractura.valor(perfil)
	local v = 0
	for id, n in pairs(perfil.Minerals.Fractured) do
		v = v + Mochila.precioUnidad(id) * n
	end
	return v
end

-- F17: Carga = valor / (20 × V(z)); Lastre ligero hace que cuente un 15 % menos.
function Fractura.carga(perfil, zona)
	local c = Mineria.load(Fractura.valor(perfil), zona)
	local pico = Inventario.equipado(perfil, "Pickaxe")
	if pico and Inventario.tienePasiva(pico, "LightBallast") then
		c = c * (1 - Pickaxes.PassiveValues.LightBallast)
	end
	return c
end

function Fractura.lentitud(carga)
	return Mineria.loadSlow(carga)
end

-- Contenedor de grieta: la mochila admite el doble.
function Fractura.capacidad(perfil, extra)
	return Mochila.capacidad(perfil, extra) * Fracture.BackpackMultiplier
end

function Fractura.anadir(perfil, mineral, n, extra)
	local cabe = math.max(0, Fractura.capacidad(perfil, extra) - Fractura.unidades(perfil))
	local entran = math.min(math.floor(n), cabe)
	if entran > 0 then
		perfil.Minerals.Fractured[mineral] = (perfil.Minerals.Fractured[mineral] or 0) + entran
	end
	return entran
end

-- ¿Las protecciones evitan soltar carga? Novato (5 primeras entradas) o carga menor que 1.
function Fractura.protegido(perfil, carga)
	return (perfil.Fracture.Entries or 0) <= Fracture.Entry.NoviceEntriesWithoutLoss or carga < Fracture.PvPDeath.ProtectedBelowLoad
end

-- Quita n unidades empezando por las más valiosas. Devuelve la tabla de lo quitado.
local function quitarValiosas(perfil, n)
	local ids = {}
	for id in pairs(perfil.Minerals.Fractured) do
		table.insert(ids, id)
	end
	table.sort(ids, function(a, b)
		local va, vb = Mochila.precioUnidad(a), Mochila.precioUnidad(b)
		if va ~= vb then
			return va > vb
		end
		return a < b
	end)
	local quitado = {}
	for _, id in ipairs(ids) do
		if n <= 0 then
			break
		end
		local hay = perfil.Minerals.Fractured[id]
		local q = math.min(hay, n)
		quitado[id] = q
		n = n - q
		perfil.Minerals.Fractured[id] = (hay - q > 0) and (hay - q) or nil
	end
	return quitado
end

-- Muerte contra otro jugador (F35 y F36). Devuelve { Cofre = { [id] = n }, Destruidas = n, Soltadas = n }.
-- opciones = { Asegurado, Novato, MismaVictima, Recompensa (racha de la víctima >= 5: el cofre lo recoge todo) }.
function Fractura.muertePvP(perfil, zona, opciones)
	local carga = Fractura.carga(perfil, zona)
	local reparto = Mineria.pvpDeathSplit(carga, opciones.Asegurado, opciones.Novato or Fractura.protegido(perfil, carga) or opciones.MismaVictima)
	local unidades = Fractura.unidades(perfil)
	local soltadas = math.floor(unidades * reparto.Dropped + 1e-9)
	local quitado = quitarValiosas(perfil, soltadas)
	local fraccionCofre = opciones.Recompensa and Fracture.Bounty.LootableFraction or Fracture.PvPDeath.LootableFraction
	local cofre, destruidas = {}, 0
	for id, n in pairs(quitado) do
		local c = math.floor(n * fraccionCofre + 1e-9)
		if c > 0 then
			cofre[id] = c
		end
		destruidas = destruidas + (n - c)
	end
	return { Cofre = cofre, Destruidas = destruidas, Soltadas = soltadas }
end

-- Muerte contra enemigos o el entorno dentro de la grieta: se pierde el 20 % (regla PvE), destruido.
function Fractura.muertePvE(perfil)
	return quitarValiosas(perfil, math.floor(Fractura.unidades(perfil) * Fracture.PvEDeath.DropFraction + 1e-9))
end

-- Extraer (F34): todo al banco y la diferencia de valor (×1,5 × racha − 1) en monedas. Sube la racha.
-- Devuelve { Unidades, Multiplicador, Bono, Rarezas = { [rareza] = unidades } }.
function Fractura.extraer(perfil)
	local mult = Mineria.fracturedMultiplier(perfil.Fracture.Streak or 0, true)
	local valor, unidades, rarezas = 0, 0, {}
	for id, n in pairs(perfil.Minerals.Fractured) do
		valor = valor + Mochila.precioUnidad(id) * n
		unidades = unidades + n
		local r = Mining.Minerals[id].Rarity
		rarezas[r] = (rarezas[r] or 0) + n
		Mochila.alBanco(perfil, id, n)
	end
	perfil.Minerals.Fractured = {}
	perfil.Fracture.Streak = (perfil.Fracture.Streak or 0) + 1
	return { Unidades = unidades, Multiplicador = mult, Bono = math.floor(valor * (mult - 1) + 1e-6), Rarezas = rarezas }
end

-- Salir sin extraer: el mineral va al banco a ×1,0; la racha no se rompe (B3 7.2).
function Fractura.salirSinExtraer(perfil)
	local n = 0
	for id, u in pairs(perfil.Minerals.Fractured) do
		Mochila.alBanco(perfil, id, u)
		n = n + u
	end
	perfil.Minerals.Fractured = {}
	return n
end

-- Lo que se perdería al morir ahora contra un jugador (para la interfaz): fracción de unidades.
function Fractura.perdidaPosible(perfil, zona, asegurado)
	local carga = Fractura.carga(perfil, zona)
	if Fractura.protegido(perfil, carga) then
		return 0
	end
	return Mineria.pvpDeathSplit(carga, asegurado, false).Dropped
end

-- Misma víctima: derrotarla otra vez en menos de 10 min no suelta carga. registro = perfil.Fracture.Victims (del asesino).
function Fractura.mismaVictima(registro, userId, ahora)
	local clave = tostring(userId)
	local antes = registro[clave]
	registro[clave] = ahora
	return antes ~= nil and ahora - antes < Fracture.PvPDeath.SameVictimMinutes * 60
end

-- Seguro de carga: como mucho 5 al día.
function Fractura.puedeAsegurar(perfil, dia)
	if perfil.Fracture.InsuranceDay ~= dia then
		perfil.Fracture.InsuranceDay = dia
		perfil.Fracture.InsuranceToday = 0
	end
	return (perfil.Consumables.CargoInsurance or 0) >= 1 and (perfil.Fracture.InsuranceToday or 0) < Fracture.Insurance.DailyLimit
end

function Fractura.asegurar(perfil)
	perfil.Consumables.CargoInsurance = perfil.Consumables.CargoInsurance - 1
	perfil.Fracture.InsuranceToday = (perfil.Fracture.InsuranceToday or 0) + 1
end

-- Contratos de grieta (B6 7.3): 3 al día (2 de extraer una rareza y 1 de derrotar portadores); 0,20 h entre los tres.
function Fractura.renovarContratos(perfil, dia)
	local clave = tostring(dia)
	if perfil.Quests.ContractDay == clave then
		return false
	end
	perfil.Quests.ContractDay = clave
	perfil.Quests.ContractSwapped = false
	perfil.Quests.Contracts = {
		{ Id = "ExtractRarity", Progress = 0, Claimed = false },
		{ Id = "ExtractRarity2", Progress = 0, Claimed = false },
		{ Id = "DefeatCarriers", Progress = 0, Claimed = false },
	}
	return true
end

function Fractura.objetivoContrato(id)
	if id == "DefeatCarriers" then
		return Fracture.ContractTargets.DefeatCarriers.Count
	end
	return Fracture.ContractTargets.ExtractRarity.Count
end

-- Avanza los contratos al extraer (rarezas extraídas) o al derrotar portadores. Devuelve los completados.
function Fractura.avanzarContratos(perfil, tipo, datos)
	local hechos = {}
	for _, c in ipairs(perfil.Quests.Contracts or {}) do
		local suma = 0
		if tipo == "Extraccion" and string.sub(c.Id, 1, 13) == "ExtractRarity" then
			local minimo = Rarity.Multiplier[Fracture.ContractTargets.ExtractRarity.MinRarity]
			for r, n in pairs(datos.Rarezas or {}) do
				if Rarity.Multiplier[r] >= minimo then
					suma = suma + n
				end
			end
		elseif tipo == "Portador" and c.Id == "DefeatCarriers" then
			suma = 1
		end
		local objetivo = Fractura.objetivoContrato(c.Id)
		if suma > 0 and c.Progress < objetivo then
			c.Progress = math.min(objetivo, c.Progress + suma)
			if c.Progress >= objetivo then
				table.insert(hechos, c)
			end
		end
	end
	return hechos
end

-- Cambiar el contrato de portadores por uno de extracción (una vez al día).
function Fractura.cambiarContrato(perfil, id)
	if id ~= "DefeatCarriers" then
		return false, "contrato"
	end
	if perfil.Quests.ContractSwapped then
		return false, "cambiado"
	end
	for _, c in ipairs(perfil.Quests.Contracts or {}) do
		if c.Id == "DefeatCarriers" and not c.Claimed then
			c.Id, c.Progress = "ExtractRarity3", 0
			perfil.Quests.ContractSwapped = true
			return true
		end
	end
	return false, "contrato"
end

function Fractura.recompensaContrato(perfil)
	return math.floor(Fracture.Contracts.DailyIncomeHours / Fracture.Contracts.Daily * Economia.income(perfil.Progress.UnlockedZone) + 0.5)
end

-- Modelo de ingresos de B3 7.5 (relativos a picar en PvE) para comprobar el techo de 2,5.
local T_PVE, T_ZF, CAP, UDS = 246.65, 466.30, 60, 3.7745
local function rachaMedia(p)
	local tope = Fracture.Streak.Steps[#Fracture.Streak.Steps]
	if p == 0 then
		return tope
	end
	local s = 0
	for k = 0, 399 do
		s = s + p * (1 - p) ^ k * math.min(1 + 0.1 * k, tope)
	end
	return s
end
Fractura.rachaMedia = rachaMedia

function Fractura.ingresosRelativos(p)
	local t = (1 - p) * T_ZF + p * (0.6 * T_ZF + 30)
	return ((1 - p) * Fracture.ValueMultiplier * rachaMedia(p) + p * 0.6 * (1 - Fracture.PvPDeath.DropFraction)) / t * T_PVE / (CAP / UDS) * (2 * CAP / UDS)
end

return Fractura
