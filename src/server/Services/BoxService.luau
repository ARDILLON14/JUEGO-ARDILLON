-- Services/BoxService: abrir cajas (B1; B6, sección 5; C_Tecnico 6.5).
-- Orden sin ceder el control: comprobar monedas y hueco, cobrar, sortear (garantía B, después A, después tabla con
-- Suerte), actualizar contadores, crear el premio y anotarlo en el registro. Después se envía Box.Result y el cliente
-- reproduce la Geoda. El puesto de cajas es una parte con la etiqueta «Cajas».

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Boxes = require(Shared.Config.Boxes)
local Economy = require(Shared.Config.Economy)
local Rarity = require(Shared.Config.Rarity)
local Cajas = require(Shared.Reglas.Cajas)
local Forja = require(Shared.Reglas.Forja)
local Nombres = require(Shared.Visual.Nombres)
local Rarezas = require(Shared.Visual.Rarezas)
local Server = script.Parent.Parent
local Combate = require(Server.Reglas.Combate)
local Lugares = require(Server.Util.Lugares)

local BoxService = {}

local Datos, Economia, Inventory, StatsSvc, Analitica, Red
local azar = Random.new()
local RADIO = 15

local function aleatorio()
	return azar:NextNumber()
end

local function abrir(jugador, tipo, cantidad)
	if not Lugares.cercaDe(jugador, "Cajas", RADIO) then
		return false, "lejos"
	end
	if not table.find(Boxes.Purchasable, tipo) then
		return false, "caja"
	end
	local perfil = Datos.GetProfile(jugador)
	if Cajas.necesitaHueco(tipo) and Forja.contarObjetos(perfil) + cantidad > Economy.MaxItems then
		return false, "inventario"
	end
	local precio = Cajas.precio(tipo, perfil) * cantidad
	local ok, motivo = Economia.SpendCoins(jugador, precio, "Caja" .. tipo)
	if not ok then
		return false, motivo
	end
	local d = StatsSvc.GetStats(jugador)
	local suerte = d and d.Effective.Luck or 0
	local premios = {}
	for _ = 1, cantidad do
		local premio = Cajas.abrir(perfil, tipo, suerte, aleatorio, Inventory.NuevoId, os.time())
		if premio.Kind == "CoreDuplicate" then
			local c = perfil.Cores[premio.Core]
			local registro = { Level = c.Mastery, XP = c.XP }
			Combate.sumarMaestria(registro, premio.Units)
			c.Mastery, c.XP = registro.Level, registro.XP
		end
		table.insert(premios, premio)
		Analitica.Registrar(jugador, "CajaAbierta", nil, tipo .. ":" .. premio.Rarity)
		if Rarity.Multiplier[premio.Rarity] >= Rarity.Multiplier.UltraRare then
			local texto = jugador.DisplayName .. " ha sacado algo " .. (Rarezas.Nombre[premio.Rarity] or premio.Rarity) .. " de una caja"
			for _, otro in ipairs(Players:GetPlayers()) do
				Red:obtener("Notify"):FireClient(otro, { Text = texto, Color = Rarezas.color(premio.Rarity) })
			end
		end
	end
	Datos.Replicar(jugador, "Items", "Eggs", "Cores", "Minerals", "Consumables", "Boxes")
	local faltaA, faltaB = Cajas.faltan(perfil, tipo)
	Red:obtener("Box.Result"):FireClient(jugador, { Box = tipo, Prizes = premios, UntilLegendary = faltaA, UntilMythic = faltaB })
	return true, #premios
end

local function conectarPuesto(parte)
	local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Ver cajas"
		prompt.ObjectText = "Geodas"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = parte
	end
	prompt.Triggered:Connect(function(jugador)
		Red:obtener("Notify"):FireClient(jugador, { Kind = "OpenBoxes" })
	end)
end

function BoxService.Iniciar(deps)
	Datos, Economia, Inventory, StatsSvc, Analitica, Red = deps.Datos, deps.Economia, deps.Inventory, deps.Stats, deps.Analitica, deps.Red
	Red:conectar("Box.Open", abrir)
	for _, parte in ipairs(CollectionService:GetTagged("Cajas")) do
		conectarPuesto(parte)
	end
	CollectionService:GetInstanceAddedSignal("Cajas"):Connect(conectarPuesto)
end

BoxService.Nombres = Nombres
return BoxService
