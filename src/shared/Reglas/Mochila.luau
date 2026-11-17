-- Reglas/Mochila: mineral llevado y guardado, banco, venta, ampliaciones y pérdida al morir en PvE.
-- B3 (sección 8) y B6. Funciones puras sobre el perfil.
--   Minerals.Carried  = lo que se lleva encima (se puede perder)
--   Minerals.Banked   = lo guardado en el banco (no se pierde nunca)

local Shared = script.Parent.Parent
local Mining = require(Shared.Config.Mining)
local Economy = require(Shared.Config.Economy)
local Mineria = require(Shared.Formulas.Mineria)
local Economia = require(Shared.Formulas.Economia)

local Mochila = {}

-- Índice [zona][rareza] = id del mineral (uno por rareza y zona en el catálogo de B3).
local INDICE = {}
for id, m in pairs(Mining.Minerals) do
	INDICE[m.Zone] = INDICE[m.Zone] or {}
	INDICE[m.Zone][m.Rarity] = id
end

function Mochila.mineralDe(zona, rareza)
	return INDICE[zona] and INDICE[zona][rareza]
end

-- Quita n unidades de un mineral, primero del banco y después de la mochila. Devuelve true si había.
function Mochila.gastar(perfil, mineral, n)
	if Mochila.existencias(perfil, mineral) < n then
		return false
	end
	local delBanco = math.min(n, perfil.Minerals.Banked[mineral] or 0)
	local resto = (perfil.Minerals.Banked[mineral] or 0) - delBanco
	perfil.Minerals.Banked[mineral] = resto > 0 and resto or nil
	local deMochila = n - delBanco
	if deMochila > 0 then
		local r = (perfil.Minerals.Carried[mineral] or 0) - deMochila
		perfil.Minerals.Carried[mineral] = r > 0 and r or nil
	end
	return true
end

function Mochila.alBanco(perfil, mineral, n)
	if n > 0 then
		perfil.Minerals.Banked[mineral] = (perfil.Minerals.Banked[mineral] or 0) + n
	end
end

local function total(tabla)
	local n = 0
	for _, unidades in pairs(tabla) do
		n = n + unidades
	end
	return n
end

local function quitar(tabla, mineral, n)
	local resto = (tabla[mineral] or 0) - n
	if resto <= 0 then
		tabla[mineral] = nil
	else
		tabla[mineral] = resto
	end
end

-- Capacidad: 60 de base o la de la ampliación comprada; extra = bonos de mascotas (fase 6).
function Mochila.capacidad(perfil, extra)
	local tier = perfil.Backpack.Tier or 0
	local base = Mining.Backpack.Base
	if tier > 0 and Economy.Backpack[tier] then
		base = Economy.Backpack[tier].Capacity
	end
	return base + math.floor(extra or 0)
end

function Mochila.carga(perfil)
	return total(perfil.Minerals.Carried)
end

function Mochila.enBanco(perfil)
	return total(perfil.Minerals.Banked)
end

function Mochila.espacio(perfil, extra)
	return math.max(0, Mochila.capacidad(perfil, extra) - Mochila.carga(perfil))
end

-- Mete hasta n unidades. Devuelve las que entraron.
function Mochila.anadir(perfil, mineral, n, extra)
	assert(Mining.Minerals[mineral], "mineral desconocido")
	local entran = math.min(math.max(0, math.floor(n)), Mochila.espacio(perfil, extra))
	if entran > 0 then
		perfil.Minerals.Carried[mineral] = (perfil.Minerals.Carried[mineral] or 0) + entran
	end
	return entran
end

-- Banco ----------------------------------------------------------------

function Mochila.depositarTodo(perfil)
	local movidas = 0
	for mineral, n in pairs(perfil.Minerals.Carried) do
		perfil.Minerals.Banked[mineral] = (perfil.Minerals.Banked[mineral] or 0) + n
		movidas = movidas + n
	end
	perfil.Minerals.Carried = {}
	return movidas
end

-- Devuelve true y las unidades retiradas, o false y el motivo: "mineral" | "sin_existencias" | "mochila_llena".
function Mochila.retirar(perfil, mineral, n, extra)
	if not Mining.Minerals[mineral] then
		return false, "mineral"
	end
	local hay = perfil.Minerals.Banked[mineral] or 0
	if hay < 1 then
		return false, "sin_existencias"
	end
	local cantidad = math.min(math.floor(n), hay, Mochila.espacio(perfil, extra))
	if cantidad < 1 then
		return false, "mochila_llena"
	end
	quitar(perfil.Minerals.Banked, mineral, cantidad)
	perfil.Minerals.Carried[mineral] = (perfil.Minerals.Carried[mineral] or 0) + cantidad
	return true, cantidad
end

-- Venta ----------------------------------------------------------------

function Mochila.precioUnidad(mineral)
	local m = Mining.Minerals[mineral]
	return Mineria.unitValue(m.Zone, m.Rarity)
end

function Mochila.existencias(perfil, mineral)
	return (perfil.Minerals.Carried[mineral] or 0) + (perfil.Minerals.Banked[mineral] or 0)
end

-- Vende n unidades, primero de la mochila y después del banco. No toca las monedas: devuelve cuántas dar.
-- Devuelve true, monedas y unidades vendidas; o false y el motivo: "mineral" | "cantidad" | "sin_existencias".
-- Las monedas se redondean hacia abajo una vez por venta: conviene vender todo junto.
function Mochila.vender(perfil, mineral, n)
	if not Mining.Minerals[mineral] then
		return false, "mineral"
	end
	if type(n) ~= "number" or n < 1 or n ~= math.floor(n) then
		return false, "cantidad"
	end
	local cantidad = math.min(n, Mochila.existencias(perfil, mineral))
	if cantidad < 1 then
		return false, "sin_existencias"
	end
	local deMochila = math.min(cantidad, perfil.Minerals.Carried[mineral] or 0)
	quitar(perfil.Minerals.Carried, mineral, deMochila)
	quitar(perfil.Minerals.Banked, mineral, cantidad - deMochila)
	return true, math.floor(Mochila.precioUnidad(mineral) * cantidad + 1e-9), cantidad
end

-- Ampliaciones ---------------------------------------------------------

-- Siguiente ampliación: { Tier, Capacity, Zone, Price } o nil si ya están todas.
function Mochila.siguienteAmpliacion(perfil)
	local tier = (perfil.Backpack.Tier or 0) + 1
	local b = Economy.Backpack[tier]
	if not b then
		return nil
	end
	return { Tier = tier, Capacity = b.Capacity, Zone = b.Zone, Price = Economia.backpackPrice(tier) }
end

-- Comprueba si se puede comprar (sin cobrar). Devuelve la ampliación, o nil y el motivo: "maxima" | "zona".
function Mochila.puedeAmpliar(perfil)
	local s = Mochila.siguienteAmpliacion(perfil)
	if not s then
		return nil, "maxima"
	end
	if perfil.Progress.UnlockedZone < s.Zone then
		return nil, "zona"
	end
	return s
end

-- Muerte en PvE --------------------------------------------------------

-- Quita el 20 % de cada mineral llevado (redondeado) salvo por debajo del nivel 25.
-- Devuelve la tabla de lo perdido { [mineral] = unidades } (puede estar vacía).
function Mochila.perdidaMuertePvE(perfil)
	local perdido = {}
	if perfil.Progress.Level < Mining.PvEDeath.NoLossBelowLevel then
		return perdido
	end
	for mineral, n in pairs(perfil.Minerals.Carried) do
		local p = math.floor(n * Mining.PvEDeath.LossFraction + 0.5)
		if p > 0 then
			perdido[mineral] = p
		end
	end
	for mineral, p in pairs(perdido) do
		quitar(perfil.Minerals.Carried, mineral, p)
	end
	return perdido
end

-- Recoger el saco: devuelve lo que entra en la mochila; el resto se queda en el saco.
function Mochila.recogerSaco(perfil, saco, extra)
	local recogido = 0
	for mineral, n in pairs(saco) do
		local entra = Mochila.anadir(perfil, mineral, n, extra)
		recogido = recogido + entra
		if entra >= n then
			saco[mineral] = nil
		else
			saco[mineral] = n - entra
		end
	end
	return recogido
end

return Mochila
