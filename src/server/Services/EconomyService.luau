-- Services/EconomyService: única puerta para sumar o restar monedas (C_Tecnico, sección 3).
-- Fase 2: sumar, gastar y consultar. La venta y la compra llegan en la fase 3.
-- Cada movimiento se registra en analítica con su motivo, para medir fuentes y sumideros (B6).

local Monedero = require(script.Parent.Parent.Reglas.Monedero)

local EconomyService = {}

local Datos, Analitica

function EconomyService.Iniciar(deps)
	Datos = deps.Datos
	Analitica = deps.Analitica
end

function EconomyService.GetCoins(jugador, moneda)
	local perfil = Datos.GetProfile(jugador)
	return perfil and Monedero.saldo(perfil, moneda) or 0
end

-- motivo: texto corto para analítica ("Reinicio", "Venta", ...). Devuelve true, o false y el motivo del rechazo.
function EconomyService.AddCoins(jugador, cantidad, motivo, moneda)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return false, "sin_perfil"
	end
	local ok, resultado = Monedero.sumar(perfil, cantidad, moneda)
	if not ok then
		return false, resultado
	end
	Analitica.Registrar(jugador, "MonedasGanadas", cantidad, (moneda or "Coins") .. ":" .. tostring(motivo))
	Datos.Replicar(jugador, "Wallet")
	return true
end

function EconomyService.SpendCoins(jugador, cantidad, motivo, moneda)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return false, "sin_perfil"
	end
	local ok, resultado = Monedero.gastar(perfil, cantidad, moneda)
	if not ok then
		return false, resultado
	end
	Analitica.Registrar(jugador, "MonedasGastadas", cantidad, (moneda or "Coins") .. ":" .. tostring(motivo))
	Datos.Replicar(jugador, "Wallet")
	return true
end

return EconomyService
