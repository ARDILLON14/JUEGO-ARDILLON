-- Services/EconomyService: única puerta para sumar o restar monedas (C_Tecnico, sección 3).
-- Fase 2: sumar, gastar y consultar. Fase 3: venta de minerales y objetos al mercader y ampliaciones de mochila.
-- El mercader es una parte con la etiqueta «Mercader»; su ProximityPrompt abre la tienda en el cliente.
-- Cada movimiento se registra en analítica con su motivo, para medir fuentes y sumideros (B6).

local CollectionService = game:GetService("CollectionService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Mochila = require(Shared.Reglas.Mochila)
local Inventario = require(Shared.Reglas.Inventario)
local Server = script.Parent.Parent
local Monedero = require(Server.Reglas.Monedero)
local Lugares = require(Server.Util.Lugares)
local Eventos = require(Server.Util.Eventos)

local EconomyService = {}

local Datos, Analitica, Red

local function cercaMercader(jugador)
	return Lugares.cercaDe(jugador, Lugares.Etiqueta.Mercader, Mining.Merchant.Radius)
end

-- Shop.Sell: (mineralId, amount) vende mineral; (nil, nil, itemId) vende un objeto. El precio lo pone el servidor.
local function vender(jugador, mineral, cantidad, itemId)
	if not cercaMercader(jugador) then
		return false, "lejos"
	end
	local perfil = Datos.GetProfile(jugador)
	local ok, monedas, vendidas
	if mineral and cantidad then
		ok, monedas, vendidas = Mochila.vender(perfil, mineral, cantidad)
	elseif itemId then
		ok, monedas = Inventario.vender(perfil, itemId)
		vendidas = 1
	else
		return false, "parametros"
	end
	if not ok then
		return false, monedas
	end
	if monedas > 0 then
		EconomyService.AddCoins(jugador, monedas, mineral and "VentaMineral" or "VentaObjeto")
		Eventos.emitir("VentaMineral", jugador, monedas)
	end
	Datos.Replicar(jugador, "Minerals", "Items")
	return true, { Coins = monedas, Sold = vendidas }
end

local function comprarMochila(jugador)
	if not cercaMercader(jugador) then
		return false, "lejos"
	end
	local perfil = Datos.GetProfile(jugador)
	local s, motivo = Mochila.puedeAmpliar(perfil)
	if not s then
		return false, motivo
	end
	local ok, m = EconomyService.SpendCoins(jugador, s.Price, "Mochila")
	if not ok then
		return false, m
	end
	perfil.Backpack.Tier = s.Tier
	Analitica.Registrar(jugador, "MochilaComprada", s.Price, tostring(s.Capacity))
	Datos.Replicar(jugador, "Backpack")
	return true, { Capacity = s.Capacity }
end

-- Shop.BuyConsumable: por ahora solo el Sello de Reajuste (los demás consumibles llegan con su uso).
local VENDIBLES = { ReadjustSeal = true }
local function comprarConsumible(jugador, id, cantidad)
	if not cercaMercader(jugador) then
		return false, "lejos"
	end
	if not VENDIBLES[id] then
		return false, "consumible"
	end
	local perfil = Datos.GetProfile(jugador)
	local precio = require(Shared.Formulas.Economia).consumablePrice(id, perfil.Progress.UnlockedZone) * cantidad
	local ok, m = EconomyService.SpendCoins(jugador, precio, "Consumible")
	if not ok then
		return false, m
	end
	perfil.Consumables[id] = (perfil.Consumables[id] or 0) + cantidad
	Datos.Replicar(jugador, "Consumables")
	return true
end

local function conectarMercader(parte)
	local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Abrir tienda"
		prompt.ObjectText = "Mercader"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = parte
	end
	prompt.Triggered:Connect(function(jugador)
		Red:obtener("Notify"):FireClient(jugador, { Kind = "OpenShop" })
	end)
end

function EconomyService.Iniciar(deps)
	Datos = deps.Datos
	Analitica = deps.Analitica
	Red = deps.Red
	if Red then
		Red:conectar("Shop.Sell", vender)
		Red:conectar("Shop.BuyBackpack", comprarMochila)
		Red:conectar("Shop.BuyConsumable", comprarConsumible)
		for _, parte in ipairs(CollectionService:GetTagged(Lugares.Etiqueta.Mercader)) do
			conectarMercader(parte)
		end
		CollectionService:GetInstanceAddedSignal(Lugares.Etiqueta.Mercader):Connect(conectarMercader)
	end
end

function EconomyService.GetCoins(jugador, moneda)
	local perfil = Datos.GetProfile(jugador)
	return perfil and Monedero.saldo(perfil, moneda) or 0
end

-- motivo: texto corto para analítica ("Reinicio", "Venta", ...). Devuelve true, o false y el motivo del rechazo.
local oyentesIngreso = {}

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
	if (moneda == nil or moneda == "Coins") then
		for _, fn in ipairs(oyentesIngreso) do
			fn(jugador, cantidad, motivo)
		end
	end
	return true
end

-- Avisa de cada ingreso de monedas (lo usa AntiCheatService para la alerta de ingresos anómalos).
function EconomyService.AlGanar(fn)
	table.insert(oyentesIngreso, fn)
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
