-- Services/BankService: depositar y retirar mineral en los bancos (B3, sección 8).
-- Banco = parte con la etiqueta «Banco». Su ProximityPrompt (3 s pulsado) deposita todo.
-- Lo guardado en el banco no se pierde nunca.

local CollectionService = game:GetService("CollectionService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Mochila = require(Shared.Reglas.Mochila)
local Server = script.Parent.Parent
local Lugares = require(Server.Util.Lugares)
local Eventos = require(Server.Util.Eventos)

local BankService = {}

local Datos, Inventory, Red

local function avisar(jugador, texto)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto })
end

function BankService.Deposit(jugador)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return false, "sin_perfil"
	end
	if not Lugares.cercaDe(jugador, Lugares.Etiqueta.Banco, Mining.Bank.Radius) then
		return false, "lejos"
	end
	local n = Mochila.depositarTodo(perfil)
	Datos.Replicar(jugador, "Minerals")
	if n > 0 then
		Eventos.emitir("Deposito", jugador, n)
		avisar(jugador, "Depositadas " .. n .. " unidades en el banco")
	else
		avisar(jugador, "Tu mochila está vacía")
	end
	return true, n
end

function BankService.Withdraw(jugador, mineral, cantidad)
	local perfil = Datos.GetProfile(jugador)
	if not Lugares.cercaDe(jugador, Lugares.Etiqueta.Banco, Mining.Bank.Radius) then
		return false, "lejos"
	end
	local ok, r = Mochila.retirar(perfil, mineral, cantidad, Inventory.ExtraMochila(jugador))
	if ok then
		Datos.Replicar(jugador, "Minerals")
	end
	return ok, r
end

local function conectarBanco(parte)
	local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Depositar todo"
		prompt.ObjectText = "Banco"
		prompt.HoldDuration = Mining.Bank.HoldSeconds
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = parte
	end
	prompt.Triggered:Connect(function(jugador)
		BankService.Deposit(jugador)
	end)
end

function BankService.Iniciar(deps)
	Datos, Inventory, Red = deps.Datos, deps.Inventory, deps.Red
	for _, parte in ipairs(CollectionService:GetTagged(Lugares.Etiqueta.Banco)) do
		conectarBanco(parte)
	end
	CollectionService:GetInstanceAddedSignal(Lugares.Etiqueta.Banco):Connect(conectarBanco)
	-- Por Remote: el servidor cuenta los 3 s y vuelve a comprobar que sigue junto al banco.
	Red:conectar("Bank.Deposit", function(jugador)
		if not Lugares.cercaDe(jugador, Lugares.Etiqueta.Banco, Mining.Bank.Radius) then
			return false, "lejos"
		end
		task.wait(Mining.Bank.HoldSeconds)
		return BankService.Deposit(jugador)
	end)
	Red:conectar("Bank.Withdraw", BankService.Withdraw)
end

return BankService
