-- Net/Remotes: definición de todos los Remotes (C_Tecnico, sección 5). Solo definiciones.
-- El servidor crea las instancias con Server/Net/Validador; el cliente las busca por nombre en
-- ReplicatedStorage[Remotes.FolderName].
--   Kind:   "Event" (RemoteEvent) o "Function" (RemoteFunction, con respuesta)
--   Params: lista de esquemas (Net/Esquemas), en el orden de los argumentos
--   Rate:   cubo de fichas { PerSecond, Burst }
-- El cliente nunca envía daño, cantidades ganadas, probabilidades, precios ni destinos libres.

local Config = script.Parent.Parent.Config
local Rarity = require(Config.Rarity)
local Weapons = require(Config.Weapons)
local Boxes = require(Config.Boxes)
local Worlds = require(Config.Worlds)
local PvP = require(Config.PvP)
local Economy = require(Config.Economy)
local Mining = require(Config.Mining)

local function claves(t)
	local lista = {}
	for k in pairs(t) do
		table.insert(lista, k)
	end
	table.sort(lista)
	return lista
end

local STATS = require(Config.Stats).Names
local SLOTS = { "Z", "X", "C", "V" }
local RARITIES = Rarity.Order
local WEAPON_TYPES = claves(Weapons.Types)
local BOX_TYPES = claves(Boxes.Boxes)
local ZONES = #Worlds.Zones
local WORLD_IDS = { Worlds.Hub.Id }
for _, mundo in ipairs(Worlds.Worlds) do
	table.insert(WORLD_IDS, mundo.Id)
end

-- Constructores de esquemas (solo para abreviar esta tabla).
local function id(name)
	return { Name = name, Type = "string", MaxLength = 40 }
end
local function enum(name, values)
	return { Name = name, Type = "string", Enum = values }
end
local function int(name, min, max)
	return { Name = name, Type = "number", Integer = true, Min = min, Max = max }
end
local function bool(name)
	return { Name = name, Type = "boolean" }
end
local function dir(name)
	return { Name = name, Type = "Vector3", MaxMagnitude = 1.01 }
end
local function opt(schema)
	schema.Optional = true
	return schema
end
local function rate(perSecond, burst)
	return { PerSecond = perSecond, Burst = burst or math.max(1, math.ceil(perSecond * 2)) }
end
local function every(seconds)
	return { PerSecond = 1 / seconds, Burst = 1 }
end
local function zone(name)
	return int(name, 1, ZONES)
end

local MAX_UNITS = 1000000

local Remotes = {
	FolderName = "Remotes",
	Stats = STATS,
}

Remotes.ClientToServer = {
	["Combat.Attack"] = { Kind = "Event", Rate = rate(5.7, 12),
		Params = { { Name = "targetIds", Type = "array", MaxLength = 3, Of = { Type = "number", Integer = true, Min = 0 } }, int("comboIndex", 1, Weapons.ComboHits) } },
	["Combat.Cast"] = { Kind = "Event", Rate = rate(0.9, 2), Params = { enum("slot", SLOTS), dir("aim") } },
	["Combat.SetLoadout"] = { Kind = "Function", Rate = rate(1),
		Params = { { Name = "slots", Type = "struct", Fields = { Z = id(), X = id(), C = id(), V = id() } } } },
	["Combat.Block"] = { Kind = "Event", Rate = rate(2.5, 5), Params = { bool("active") } },
	["Combat.Dash"] = { Kind = "Event", Rate = rate(0.5, 2), Params = { dir("direction") } },
	["Combat.Break"] = { Kind = "Event", Rate = rate(0.1, 2), Params = {} },
	["Combat.Blink"] = { Kind = "Event", Rate = rate(0.2, 2), Params = { dir("direction") } },
	["Combat.Transform"] = { Kind = "Function", Rate = every(5), Params = {} },

	["Mining.Hit"] = { Kind = "Event", Rate = rate(2.5, 5), Params = { int("depositId", 0) } },

	["Stats.Allocate"] = { Kind = "Function", Rate = rate(5), Params = { enum("stat", STATS), int("amount", 1, 1000) } },
	["Stats.Respec"] = { Kind = "Function", Rate = every(10), Params = { bool("useTome") } },

	["Inventory.Equip"] = { Kind = "Function", Rate = rate(2), Params = { id("itemId"), enum("slot", { "Weapon", "Pickaxe" }) } },

	["Bank.Deposit"] = { Kind = "Function", Rate = rate(1), Params = { bool("all") } },
	["Bank.Withdraw"] = { Kind = "Function", Rate = rate(2), Params = { enum("mineralId", claves(Mining.Minerals)), int("amount", 1, MAX_UNITS) } },

	-- Vender minerales (mineralId y amount) o un objeto (itemId): se rellena una de las dos formas.
	["Shop.Sell"] = { Kind = "Function", Rate = rate(3),
		Params = { opt(enum("mineralId", claves(Mining.Minerals))), opt(int("amount", 1, MAX_UNITS)), opt(id("itemId")) } },
	["Shop.BuyConsumable"] = { Kind = "Function", Rate = rate(3), Params = { enum("id", claves(Economy.Consumable)), int("amount", 1, 99) } },
	["Shop.BuyBackpack"] = { Kind = "Function", Rate = rate(1), Params = {} },

	["Crafting.Craft"] = { Kind = "Function", Rate = rate(2),
		Params = { enum("kind", { "Pickaxe", "Weapon" }), opt(enum("type", WEAPON_TYPES)), zone("zone"), enum("rarity", RARITIES),
			opt({ Name = "passives", Type = "array", MaxLength = 2, Of = { Type = "string", MaxLength = 40 } }),
			opt(enum("combatStat", { "Defense", "AttackSpeed" })) } },
	["Crafting.Upgrade"] = { Kind = "Function", Rate = rate(3), Params = { id("itemId"), enum("upgrade", { "Level", "Slot", "Awaken" }) } },
	["Crafting.Recycle"] = { Kind = "Function", Rate = rate(2), Params = { id("itemId") } },
	["Crafting.CraftConsumable"] = { Kind = "Function", Rate = rate(2), Params = { enum("id", { "CargoInsurance", "ReadjustSeal" }), int("amount", 1, 20) } },
	["Crafting.ForgeCelestial"] = { Kind = "Function", Rate = every(5), Params = { enum("kind", { "Pickaxe", "Weapon" }), opt(enum("type", WEAPON_TYPES)) } },

	["Box.Open"] = { Kind = "Function", Rate = rate(2), Params = { enum("boxType", BOX_TYPES), int("count", 1, Boxes.Animation.MultiOpen) } },

	["Pet.Equip"] = { Kind = "Function", Rate = rate(2), Params = { id("petId"), int("slot", 1, 6) } },
	["Pet.SetStance"] = { Kind = "Event", Rate = rate(0.3, 2), Params = { enum("stance", { "Gather", "Protect" }) } },
	["Pet.StartHatch"] = { Kind = "Function", Rate = rate(1), Params = { id("eggId"), int("incubator", 1, 4) } },
	["Pet.ClaimHatch"] = { Kind = "Function", Rate = rate(1), Params = { int("incubator", 1, 4) } },
	["Pet.Evolve"] = { Kind = "Function", Rate = rate(1), Params = { id("petId") } },
	["Pet.Release"] = { Kind = "Function", Rate = rate(1), Params = { { Name = "petIds", Type = "array", MaxLength = 50, Of = { Type = "string", MaxLength = 40 } } } },
	["Pet.SetNest"] = { Kind = "Function", Rate = rate(1), Params = { id("petId"), int("slot", 1, 2) } },

	["Core.Equip"] = { Kind = "Function", Rate = rate(1), Params = { id("coreId") } },
	["Core.Awaken"] = { Kind = "Function", Rate = every(5), Params = { id("coreId") } },

	["Boss.Join"] = { Kind = "Function", Rate = rate(1), Params = { zone("zone") } },

	["Fracture.Enter"] = { Kind = "Function", Rate = every(2), Params = { zone("zone"), bool("useInsurance"), bool("confirmed") } },
	["Fracture.Extract"] = { Kind = "Event", Rate = rate(1), Params = { bool("start") } },
	["Fracture.Exit"] = { Kind = "Event", Rate = rate(1), Params = { bool("start") } },
	["Fracture.OpenChest"] = { Kind = "Event", Rate = rate(1), Params = { int("chestId", 0), bool("byPet") } },

	["Arena.Queue"] = { Kind = "Function", Rate = every(2), Params = { enum("mode", PvP.Arena.Modes) } },
	["Arena.Leave"] = { Kind = "Event", Rate = rate(1), Params = {} },

	["Quest.Claim"] = { Kind = "Function", Rate = rate(3), Params = { id("questId") } },
	["Quest.SwapContract"] = { Kind = "Function", Rate = every(5), Params = { id("contractId") } },
	["Season.Claim"] = { Kind = "Function", Rate = rate(3), Params = { int("level", 1, 200), enum("track", { "Free", "Paid" }) } },
	["Rebirth.Confirm"] = { Kind = "Function", Rate = every(10), Params = { id("token") } },
	["World.Teleport"] = { Kind = "Function", Rate = every(5), Params = { enum("worldId", WORLD_IDS) } },
	["Settings.Save"] = { Kind = "Event", Rate = every(5), Params = { { Name = "settings", Type = "table", MaxSize = 2048 } } },
	["Tutorial.Step"] = { Kind = "Event", Rate = rate(2), Params = { int("step", 0, 100) } },
}

-- Solo se crean en Roblox Studio (nunca en un servidor publicado): ayudas para probar.
Remotes.SoloStudio = {
	["Dev.GiveXP"] = { Kind = "Function", Rate = rate(2), Params = { int("amount", 1, 100000000) } },
	["Dev.GiveCoins"] = { Kind = "Function", Rate = rate(2), Params = { int("amount", 1, 1000000000) } },
}

-- Del servidor al cliente: todos son RemoteEvent.
Remotes.ServerToClient = {
	"State.Profile", "State.Stats", "Combat.Hit", "Combat.Rejected", "Mining.DepositState", "Mining.Loot", "Box.Result",
	"Pet.State", "Boss.State", "Fracture.State", "Fracture.Chest", "Event.State", "Notify",
}

return Remotes
