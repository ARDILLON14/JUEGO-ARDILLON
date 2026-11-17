-- Reglas/Inventario: picos y armas del perfil (Items), requisitos para equipar y venta.
-- Funciones puras. Los identificadores los genera el servidor.

local Shared = script.Parent.Parent
local Pickaxes = require(Shared.Config.Pickaxes)
local Rarity = require(Shared.Config.Rarity)
local Potencia = require(Shared.Formulas.Potencia)
local Mineria = require(Shared.Formulas.Mineria)
local Economia = require(Shared.Formulas.Economia)
local Nombres = require(Shared.Visual.Nombres)

local Inventario = {}

local CATEGORIA = {}
for categoria, lista in pairs(Pickaxes.Passives) do
	for _, id in ipairs(lista) do
		CATEGORIA[id] = categoria
	end
end
Inventario.CategoriaPasiva = CATEGORIA

-- ¿Encajan esas pasivas en las ranuras de un pico de esa rareza? (GDD: menor, mayor, única)
function Inventario.pasivasValidas(rareza, pasivas)
	local ranuras = Pickaxes.PassiveSlots[rareza]
	if not ranuras then
		return false
	end
	local usadas = {}
	local vistas = {}
	for _, id in ipairs(pasivas or {}) do
		local categoria = CATEGORIA[id]
		if not categoria or vistas[id] then
			return false
		end
		vistas[id] = true
		usadas[categoria] = (usadas[categoria] or 0) + 1
		if usadas[categoria] > (ranuras[categoria] or 0) then
			return false
		end
	end
	return true
end

function Inventario.crearPico(zona, rareza, pasivas, combatStat)
	assert(Rarity.Multiplier[rareza], "rareza desconocida")
	assert(Inventario.pasivasValidas(rareza, pasivas), "pasivas no válidas para la rareza")
	return {
		Kind = "Pickaxe", Zone = zona, Rarity = rareza, Level = 0, Slots = 0, Awakened = false,
		Passives = pasivas or {}, CombatStat = combatStat,
	}
end

function Inventario.potencia(item)
	return Potencia.ofItem(item)
end

function Inventario.tienePasiva(item, id)
	if not item or not item.Passives then
		return false
	end
	return table.find(item.Passives, id) ~= nil
end

function Inventario.equipado(perfil, ranura)
	local id = perfil.Equipped[ranura]
	if not id or id == "" then
		return nil, nil
	end
	return perfil.Items[id], id
end

function Inventario.tieneDeTipo(perfil, kind)
	for _, item in pairs(perfil.Items) do
		if item.Kind == kind then
			return true
		end
	end
	return false
end

-- Requisitos: nivel de la zona del objeto; los picos, además, Minería (B3, 3.2).
-- mineria = estadística Minería efectiva. Devuelve true, o false y el motivo: "nivel" | "mineria".
function Inventario.cumpleRequisitos(perfil, item, mineria)
	if perfil.Progress.Level < Mineria.zoneLevel(item.Zone) then
		return false, "nivel"
	end
	if item.Kind == "Pickaxe" and (mineria or 0) < Mineria.pickEquipMining(item.Zone, item.Rarity) then
		return false, "mineria"
	end
	return true
end

-- ranura: "Pickaxe" | "Weapon". Devuelve true, o false y el motivo:
-- "objeto" | "ranura" | "nivel" | "mineria"
function Inventario.equipar(perfil, id, ranura, mineria)
	local item = perfil.Items[id]
	if not item then
		return false, "objeto"
	end
	if item.Kind ~= ranura then
		return false, "ranura"
	end
	local ok, motivo = Inventario.cumpleRequisitos(perfil, item, mineria)
	if not ok then
		return false, motivo
	end
	perfil.Equipped[ranura] = id
	return true
end

function Inventario.estaEquipado(perfil, id)
	return perfil.Equipped.Weapon == id or perfil.Equipped.Pickaxe == id
end

-- Vende un objeto no equipado al mercader (10 % de su coste de fabricación).
-- Devuelve true y las monedas, o false y el motivo: "objeto" | "equipado" | "ultimo".
function Inventario.crearArma(tipo, zona, rareza)
	assert(Rarity.Multiplier[rareza], "rareza desconocida")
	return { Kind = "Weapon", Type = tipo, Zone = zona, Rarity = rareza, Level = 0, Slots = 0, Awakened = false }
end

function Inventario.vender(perfil, id)
	local item = perfil.Items[id]
	if not item then
		return false, "objeto"
	end
	if Inventario.estaEquipado(perfil, id) then
		return false, "equipado"
	end
	if item.Rarity == "Celestial" then   -- no tiene precio de fabricación: no se vende
		return false, "objeto"
	end
	local precio = Economia.gearSellPrice(item.Zone, item.Rarity)
	perfil.Items[id] = nil
	return true, precio
end

-- Nombre para mostrar: «Pico de Pizarra» + rareza (la rareza la traduce la interfaz).
function Inventario.nombreBase(item)
	local prefijo = Pickaxes.ZonePrefix[item.Zone] or tostring(item.Zone)
	if item.Kind == "Pickaxe" then
		return "Pico de " .. prefijo
	end
	return (Nombres.Arma[item.Type] or tostring(item.Type)) .. " de " .. prefijo
end

return Inventario
