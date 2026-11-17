-- Datos/PlantillaPerfil: esquema del perfil, versión 1 (C_Tecnico, 6.1). Una clave por jugador: u_<UserId>.
-- Solo riesgo de pérdida: Minerals.Carried y Minerals.Fractured. Nunca armas, picos, mascotas, monedas ni nivel.

local PlantillaPerfil = {}

PlantillaPerfil.Version = 1
PlantillaPerfil.SesionVacia = { JobId = "", PlaceId = 0, Time = 0 }

local function plantilla()
	return {
		Version = PlantillaPerfil.Version,
		Meta = { Created = 0, LastSave = 0, PlayTime = 0, Session = { JobId = "", PlaceId = 0, Time = 0 } },
		Progress = { Level = 1, XP = 0, Rebirths = 0, UnlockedZone = 1, TutorialStep = 0 },
		Stats = {
			Allocated = { Strength = 0, Vitality = 0, Defense = 0, Speed = 0, Energy = 0, Mining = 0, Luck = 0, PetMastery = 0 },
			BonusPoints = 0,
		},
		Wallet = { Coins = 0, Crystals = 0, EventTokens = 0, SeasonFragments = 0, CelestialFragments = 0, Bonds = 0 },
		Items = {},        -- [id] = { Kind, Type, Zone, Rarity, Level, Slots, Awakened, Passives, CombatStat }
		Equipped = { Weapon = "", Pickaxe = "", Core = "Prismatic", Pets = { "", "", "" }, Stance = "Protect",
			Loadout = { Z = "PrismaticLance", X = "", C = "", V = "" } },
		Minerals = { Carried = {}, Fractured = {}, Banked = {} },
		Materials = { Boss = {}, Element = {}, AncientGems = 0 },
		Consumables = { CargoInsurance = 0, ReadjustSeal = 0, RespecTome = 0 },
		Backpack = { Tier = 0 },
		Pets = {},         -- [id] = { Species, Level, XP, Phase }
		PetSlots = 3,
		PetStorage = 30,
		Incubators = { { Egg = "", PickHits = 0 } },
		Nest = { "", "" },
		Cores = { Prismatic = { Mastery = 1, XP = 0, Awakened = false } },
		WeaponMastery = {},
		Boxes = {
			Pity = { Weapon = { A = 0, B = 0 }, Zone = { A = 0, B = 0 }, Pet = { A = 0, B = 0 }, Core = { A = 0, B = 0 }, Event = { A = 0, B = 0 } },
			Log = {},
			Opened = { Weapon = 0, Zone = 0, Pet = 0, Core = 0, Event = 0 },
		},
		Fracture = { Entries = 0, Streak = 0, InsuranceToday = 0, LastDeath = 0, Victims = {}, LastKiller = { UserId = 0, Time = 0 },
			SeasonExtractedValue = 0 },
		Bosses = { Daily = {}, WeeklyFirst = {}, EventKills = 0 },
		Quests = { Daily = {}, Weekly = {}, Contracts = {}, DayKey = "", WeekKey = "" },
		Season = { Id = 0, PassXP = 0, Paid = false, Claimed = {} },
		Arena = { Elo = { ["1v1"] = 1000, ["2v2"] = 1000, ["3v3"] = 1000 } },
		Codex = "",
		Achievements = "",
		Cosmetics = { Owned = {}, Equipped = {} },
		Purchases = { Receipts = {} },
		Settings = {},
		Flags = { Suspicion = 0 },
	}
end

function PlantillaPerfil.copiar(valor)
	if type(valor) ~= "table" then
		return valor
	end
	local copia = {}
	for k, v in pairs(valor) do
		copia[k] = PlantillaPerfil.copiar(v)
	end
	return copia
end

-- Perfil nuevo. ahora = os.time().
function PlantillaPerfil.nuevo(ahora)
	local p = plantilla()
	p.Meta.Created = ahora or 0
	return p
end

local function esLista(t)
	return t[1] ~= nil
end

-- Rellena en datos los campos que falten respecto a la plantilla, sin tocar los que existen.
-- Las listas y los mapas por identificador (Items, Pets...) no se recorren: solo se crean si faltan.
local function reconciliar(datos, molde)
	for clave, valor in pairs(molde) do
		local actual = datos[clave]
		if actual == nil then
			datos[clave] = PlantillaPerfil.copiar(valor)
		elseif type(valor) == "table" and type(actual) == "table" and not esLista(valor) then
			reconciliar(actual, valor)
		end
	end
	return datos
end

function PlantillaPerfil.reconciliar(datos)
	return reconciliar(datos, plantilla())
end

-- Copia que se envía al propio jugador (State.Profile): sin datos internos.
function PlantillaPerfil.vistaCliente(datos)
	local vista = PlantillaPerfil.copiar(datos)
	vista.Meta = { Created = datos.Meta.Created, PlayTime = datos.Meta.PlayTime }
	vista.Flags = nil
	vista.Purchases = nil
	return vista
end

return PlantillaPerfil
