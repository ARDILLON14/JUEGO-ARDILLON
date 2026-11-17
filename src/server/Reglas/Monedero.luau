-- Reglas/Monedero: sumar y restar monedas en el perfil. Puro. Solo lo usa EconomyService
-- («una sola puerta por recurso», C_Tecnico, sección 3).

local Monedero = {}

Monedero.MONEDAS = { "Coins", "Crystals", "EventTokens", "SeasonFragments", "CelestialFragments", "Bonds" }
local VALIDA = {}
for _, m in ipairs(Monedero.MONEDAS) do
	VALIDA[m] = true
end

local MAXIMO = 2 ^ 53   -- por encima, los números dejan de ser enteros exactos

local function cantidadValida(n)
	return type(n) == "number" and n == math.floor(n) and n >= 0 and n < MAXIMO
end

function Monedero.saldo(perfil, moneda)
	return perfil.Wallet[moneda or "Coins"] or 0
end

-- Devuelve true y el saldo nuevo, o false y el motivo: "moneda" | "cantidad".
function Monedero.sumar(perfil, cantidad, moneda)
	moneda = moneda or "Coins"
	if not VALIDA[moneda] then
		return false, "moneda"
	end
	if not cantidadValida(cantidad) then
		return false, "cantidad"
	end
	local nuevo = math.min(Monedero.saldo(perfil, moneda) + cantidad, MAXIMO - 1)
	perfil.Wallet[moneda] = nuevo
	return true, nuevo
end

-- Devuelve true y el saldo nuevo, o false y el motivo: "moneda" | "cantidad" | "sin_saldo". Todo o nada.
function Monedero.gastar(perfil, cantidad, moneda)
	moneda = moneda or "Coins"
	if not VALIDA[moneda] then
		return false, "moneda"
	end
	if not cantidadValida(cantidad) then
		return false, "cantidad"
	end
	local saldo = Monedero.saldo(perfil, moneda)
	if saldo < cantidad then
		return false, "sin_saldo"
	end
	perfil.Wallet[moneda] = saldo - cantidad
	return true, saldo - cantidad
end

return Monedero
