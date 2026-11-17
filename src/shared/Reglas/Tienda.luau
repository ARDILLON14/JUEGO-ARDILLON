-- Reglas/Tienda: cosméticos y servicios con Cristales (o monedas para el aspecto de prestigio). Puro.

local Shared = script.Parent.Parent
local Monetization = require(Shared.Config.Monetization)
local Pets = require(Shared.Config.Pets)
local Economia = require(Shared.Formulas.Economia)

local Tienda = {}

local POR_ID = {}
for _, c in ipairs(Monetization.Cosmetics) do
	POR_ID[c.Id] = c
end

function Tienda.cosmetico(id)
	return POR_ID[id]
end

-- Precio: { Moneda = "Crystals" | "Coins", Cantidad }.
function Tienda.precio(perfil, id)
	local c = POR_ID[id]
	if not c then
		return nil
	end
	if c.Crystals then
		return { Moneda = "Crystals", Cantidad = c.Crystals }
	end
	return { Moneda = "Coins", Cantidad = math.floor(c.CoinHours * Economia.income(perfil.Progress.UnlockedZone) + 0.5) }
end

function Tienda.tiene(perfil, id)
	return table.find(perfil.Cosmetics.Owned, id) ~= nil
end

-- Comprueba la compra. Devuelve el precio o nil y el motivo: "cosmetico" | "ya" | "saldo".
function Tienda.comprobar(perfil, id)
	local p = Tienda.precio(perfil, id)
	if not p then
		return nil, "cosmetico"
	end
	if Tienda.tiene(perfil, id) then
		return nil, "ya"
	end
	if (perfil.Wallet[p.Moneda] or 0) < p.Cantidad then
		return nil, "saldo"
	end
	return p
end

function Tienda.otorgar(perfil, id)
	table.insert(perfil.Cosmetics.Owned, id)
end

-- Equipar en su hueco (Trail o Aura); id "" quita. Devuelve true o false y el motivo.
function Tienda.equipar(perfil, hueco, id)
	if hueco ~= "Trail" and hueco ~= "Aura" then
		return false, "hueco"
	end
	if id ~= "" then
		local c = POR_ID[id]
		if not c or c.Kind ~= hueco or not Tienda.tiene(perfil, id) then
			return false, "cosmetico"
		end
	end
	perfil.Cosmetics.Equipped[hueco] = id
	return true
end

-- Servicios: almacén de mascotas (+10 hasta 100) y tercera incubadora.
function Tienda.servicio(perfil, id)
	local s = Monetization.Services[id]
	if not s then
		return nil, "servicio"
	end
	if id == "PetStorage" and (perfil.PetStorage or Pets.Storage.Pets) >= s.Max then
		return nil, "maximo"
	end
	if id == "ThirdIncubator" and (perfil.Purchases.ThirdIncubator or #perfil.Incubators >= 3) then
		return nil, "ya"
	end
	if (perfil.Wallet.Crystals or 0) < s.Crystals then
		return nil, "saldo"
	end
	return s
end

function Tienda.aplicarServicio(perfil, id)
	local s = Monetization.Services[id]
	perfil.Wallet.Crystals = perfil.Wallet.Crystals - s.Crystals
	if id == "PetStorage" then
		perfil.PetStorage = (perfil.PetStorage or Pets.Storage.Pets) + s.Add
	else
		perfil.Purchases.ThirdIncubator = true
		table.insert(perfil.Incubators, { Egg = "", Species = "", PickHits = 0 })
	end
end

return Tienda
