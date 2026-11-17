-- Services/CraftingService: forja (fabricar, mejorar, reciclar y Seguro de carga). B6, 2.2; C_Tecnico 5.3.
-- La forja es una parte con la etiqueta «Forja»; su aviso de proximidad abre el panel en el cliente.
-- Las monedas se cobran siempre con EconomyService; los materiales y el objeto, con Reglas/Forja, sin esperas entre medias.

local CollectionService = game:GetService("CollectionService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Rarity = require(Shared.Config.Rarity)
local Forja = require(Shared.Reglas.Forja)
local Server = script.Parent.Parent
local Lugares = require(Server.Util.Lugares)

local CraftingService = {}

local Datos, Economia, Inventory, Analitica, Red
local RADIO = 15

local function cerca(jugador)
	return Lugares.cercaDe(jugador, "Forja", RADIO)
end

local function fabricar(jugador, kind, tipo, zona, rareza, pasivas, stat)
	if not cerca(jugador) then
		return false, "lejos"
	end
	local perfil = Datos.GetProfile(jugador)
	local p = { Kind = kind, Type = tipo, Zone = zona, Rarity = rareza, Passives = pasivas, CombatStat = stat }
	local coste, motivo = Forja.comprobar(perfil, p)
	if not coste then
		return false, motivo
	end
	local ok, m = Economia.SpendCoins(jugador, coste.Coins, "Fabricar")
	if not ok then
		return false, m
	end
	local id = Inventory.NuevoId()
	local item = Forja.fabricar(perfil, p, id, true)
	if not item then
		Economia.AddCoins(jugador, coste.Coins, "Devolucion")   -- no debería pasar: se comprobó antes
		return false, "error"
	end
	Datos.Replicar(jugador, "Items", "Minerals", "Materials")
	Analitica.Registrar(jugador, "ObjetoFabricado", coste.Coins, kind .. ":" .. rareza)
	if Rarity.Multiplier[rareza] >= Rarity.Multiplier.Legendary then
		task.spawn(Datos.GuardarAhora, jugador)   -- C_Tecnico 6.4: guardado inmediato tras fabricar Legendario o superior
	end
	return true, { Id = id }
end

local function mejorar(jugador, id, tipo)
	if not cerca(jugador) then
		return false, "lejos"
	end
	local perfil = Datos.GetProfile(jugador)
	local item = perfil.Items[id]
	if not item then
		return false, "objeto"
	end
	local coste, motivo = Forja.costeMejora(item, tipo)
	if not coste then
		return false, motivo
	end
	local alcanza, m0 = Forja.alcanza(perfil, coste)
	if not alcanza then
		return false, m0
	end
	local ok, m = Economia.SpendCoins(jugador, coste.Coins, "Mejora")
	if not ok then
		return false, m
	end
	Forja.mejorar(perfil, id, tipo, true)
	Datos.Replicar(jugador, "Items", "Minerals")
	return true
end

local function reciclar(jugador, id)
	if not cerca(jugador) then
		return false, "lejos"
	end
	local devuelto, motivo = Forja.reciclar(Datos.GetProfile(jugador), id)
	if not devuelto then
		return false, motivo
	end
	Datos.Replicar(jugador, "Items", "Minerals")
	return true, devuelto
end

local function consumible(jugador, id, cantidad)
	if not cerca(jugador) then
		return false, "lejos"
	end
	if id ~= "CargoInsurance" then
		return false, "consumible"   -- el Sello de Reajuste se compra (fase 7, con la ciudad)
	end
	local n, motivo = Forja.fabricarSeguro(Datos.GetProfile(jugador), cantidad)
	if not n then
		return false, motivo
	end
	Datos.Replicar(jugador, "Consumables", "Minerals")
	return true, n
end

local function conectarForja(parte)
	local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Abrir forja"
		prompt.ObjectText = "Forja"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = parte
	end
	prompt.Triggered:Connect(function(jugador)
		Red:obtener("Notify"):FireClient(jugador, { Kind = "OpenForge" })
	end)
end

function CraftingService.Iniciar(deps)
	Datos, Economia, Inventory, Analitica, Red = deps.Datos, deps.Economia, deps.Inventory, deps.Analitica, deps.Red
	Red:conectar("Crafting.Craft", fabricar)
	Red:conectar("Crafting.Upgrade", mejorar)
	Red:conectar("Crafting.Recycle", reciclar)
	Red:conectar("Crafting.CraftConsumable", consumible)
	for _, parte in ipairs(CollectionService:GetTagged("Forja")) do
		conectarForja(parte)
	end
	CollectionService:GetInstanceAddedSignal("Forja"):Connect(conectarForja)
end

return CraftingService
