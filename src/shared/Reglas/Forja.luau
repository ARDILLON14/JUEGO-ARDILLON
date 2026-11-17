-- Reglas/Forja: fabricar, mejorar y reciclar picos y armas (B6, 2.2; C_Tecnico 5.3). Puro.
-- Los «materiales» son minerales de la zona del objeto: «30 Lingotes Común» = 30 unidades del mineral Común de esa zona.
-- Se gastan primero del banco y después de la mochila. Los materiales de jefe y las gemas antiguas llegan en las fases 7 y 8.

local Shared = script.Parent.Parent
local Economy = require(Shared.Config.Economy)
local Weapons = require(Shared.Config.Weapons)
local Pickaxes = require(Shared.Config.Pickaxes)
local Rarity = require(Shared.Config.Rarity)
local Economia = require(Shared.Formulas.Economia)
local Mochila = require(script.Parent.Mochila)
local Inventario = require(script.Parent.Inventario)

local Forja = {}

local function contarObjetos(perfil)
	local n = 0
	for _ in pairs(perfil.Items) do
		n = n + 1
	end
	return n
end
Forja.contarObjetos = contarObjetos

-- Coste completo de fabricar: { Coins, Minerals = { { Id, Units } }, Boss, AncientGem }.
function Forja.receta(zona, rareza)
	local r = Economy.Recipes[rareza]
	if not r then
		return nil
	end
	local coste = { Coins = Economia.gearCost(zona, rareza), Minerals = {}, Boss = r.Boss or 0, AncientGem = r.AncientGem or 0, Zone = zona }
	for _, rz in ipairs(Rarity.Order) do
		if r[rz] then
			table.insert(coste.Minerals, { Id = Mochila.mineralDe(zona, rz), Rarity = rz, Units = r[rz] })
		end
	end
	return coste
end

-- ¿Tiene todo lo del coste? Devuelve true, o false y el motivo: "monedas" | "materiales" | "jefe" | "gema".
function Forja.alcanza(perfil, coste)
	if (perfil.Wallet.Coins or 0) < coste.Coins then
		return false, "monedas"
	end
	for _, m in ipairs(coste.Minerals) do
		if not m.Id or Mochila.existencias(perfil, m.Id) < m.Units then
			return false, "materiales"
		end
	end
	if (coste.Boss or 0) > ((perfil.Materials.Boss or {})["z" .. tostring(coste.Zone)] or 0) then
		return false, "jefe"   -- material del jefe de esa zona (fase 7)
	end
	if (coste.AncientGem or 0) > (perfil.Materials.AncientGems or 0) then
		return false, "gema"
	end
	return true
end

local function cobrarMateriales(perfil, coste)
	for _, m in ipairs(coste.Minerals) do
		Mochila.gastar(perfil, m.Id, m.Units)
	end
	perfil.Materials.AncientGems = (perfil.Materials.AncientGems or 0) - (coste.AncientGem or 0)
	if (coste.Boss or 0) > 0 then
		local clave = "z" .. tostring(coste.Zone)
		perfil.Materials.Boss[clave] = perfil.Materials.Boss[clave] - coste.Boss
	end
end

-- p = { Kind = "Pickaxe" | "Weapon", Type, Zone, Rarity, Passives, CombatStat }.
-- Comprueba sin cambiar nada. Devuelve el coste, o nil y el motivo:
-- "clase" | "tipo" | "zona" | "rareza" | "pasivas" | "estadistica" | "inventario" | (los de Forja.alcanza)
function Forja.comprobar(perfil, p)
	if p.Kind ~= "Pickaxe" and p.Kind ~= "Weapon" then
		return nil, "clase"
	end
	if p.Kind == "Weapon" and not table.find(Weapons.EnabledTypes, p.Type) then
		return nil, "tipo"
	end
	if type(p.Zone) ~= "number" or p.Zone < 1 or p.Zone > perfil.Progress.UnlockedZone then
		return nil, "zona"
	end
	if not Economy.Recipes[p.Rarity] then
		return nil, "rareza"   -- Celestial no se fabrica por esta vía
	end
	if p.Kind == "Pickaxe" then
		if not Inventario.pasivasValidas(p.Rarity, p.Passives or {}) then
			return nil, "pasivas"
		end
		local conStat = Pickaxes.CombatStat[p.Rarity] ~= nil
		if (conStat and p.CombatStat ~= "Defense" and p.CombatStat ~= "AttackSpeed") or (not conStat and p.CombatStat ~= nil) then
			return nil, "estadistica"
		end
	end
	if contarObjetos(perfil) >= Economy.MaxItems then
		return nil, "inventario"
	end
	local coste = Forja.receta(p.Zone, p.Rarity)
	local ok, motivo = Forja.alcanza(perfil, coste)
	if not ok then
		return nil, motivo
	end
	return coste
end

-- Fabrica (todo o nada): cobra monedas y materiales y crea el objeto con el id dado. Devuelve el objeto o nil y el motivo.
-- sinMonedas = true cuando las monedas ya las ha cobrado EconomyService (la única puerta para las monedas).
function Forja.fabricar(perfil, p, id, sinMonedas)
	local coste, motivo = Forja.comprobar(perfil, p)
	if not coste then
		return nil, motivo
	end
	if not sinMonedas then
		perfil.Wallet.Coins = perfil.Wallet.Coins - coste.Coins
	end
	cobrarMateriales(perfil, coste)
	local item
	if p.Kind == "Pickaxe" then
		item = Inventario.crearPico(p.Zone, p.Rarity, p.Passives or {}, p.CombatStat)
	else
		item = Inventario.crearArma(p.Type, p.Zone, p.Rarity)
	end
	perfil.Items[id] = item
	return item, coste
end

-- Pasivas por defecto para un pico de esa rareza (la primera de cada categoría).
function Forja.pasivasPorDefecto(rareza)
	local salida = {}
	for _, categoria in ipairs({ "Unique", "Major", "Minor" }) do
		local n = (Pickaxes.PassiveSlots[rareza] or {})[categoria] or 0
		for i = 1, n do
			table.insert(salida, Pickaxes.Passives[categoria][i])
		end
	end
	return salida
end

-- Mejoras -----------------------------------------------------------------
-- tipo: "Level" | "Slot" | "Awaken". Devuelve el coste o nil y el motivo: "objeto" | "maximo" | "celestial".
function Forja.costeMejora(item, tipo)
	if not item or not Economy.GearCostHours[item.Rarity] then
		return nil, "celestial"
	end
	local U = Economy.UpgradeMaterials
	local coste = { Coins = 0, Minerals = {} }
	local mat
	if tipo == "Level" then
		local n = (item.Level or 0) + 1
		if n > Pickaxes.Upgrade.LevelMax then
			return nil, "maximo"
		end
		coste.Coins = Economia.upgradeLevelCost(item.Zone, item.Rarity, n)
		mat = n <= 5 and U.LevelLow or U.LevelHigh
	elseif tipo == "Slot" then
		if (item.Slots or 0) >= Pickaxes.Upgrade.Slots then
			return nil, "maximo"
		end
		coste.Coins = Economia.slotCost(item.Zone, item.Rarity)
		mat = U.Slot
	elseif tipo == "Awaken" then
		if item.Awakened then
			return nil, "maximo"
		end
		coste.Coins = Economia.awakenCost(item.Zone, item.Rarity)
		mat = U.Awaken
	else
		return nil, "objeto"
	end
	table.insert(coste.Minerals, { Id = Mochila.mineralDe(item.Zone, mat.Rarity), Rarity = mat.Rarity, Units = mat.Units })
	return coste
end

function Forja.mejorar(perfil, id, tipo, sinMonedas)
	local item = perfil.Items[id]
	if not item then
		return nil, "objeto"
	end
	local coste, motivo = Forja.costeMejora(item, tipo)
	if not coste then
		return nil, motivo
	end
	local ok, m = Forja.alcanza(perfil, coste)
	if not ok then
		return nil, m
	end
	if not sinMonedas then
		perfil.Wallet.Coins = perfil.Wallet.Coins - coste.Coins
	end
	cobrarMateriales(perfil, coste)
	if tipo == "Level" then
		item.Level = (item.Level or 0) + 1
	elseif tipo == "Slot" then
		item.Slots = (item.Slots or 0) + 1
	else
		item.Awakened = true
	end
	return item, coste
end

-- Reciclar: el objeto desaparece y devuelve al banco el 30 % de los minerales de su receta (B6: RecycleFraction).
function Forja.reciclar(perfil, id)
	local item = perfil.Items[id]
	if not item then
		return nil, "objeto"
	end
	if Inventario.estaEquipado(perfil, id) then
		return nil, "equipado"
	end
	local receta = Forja.receta(item.Zone, item.Rarity)
	perfil.Items[id] = nil
	local devuelto = {}
	if receta then
		for _, m in ipairs(receta.Minerals) do
			local n = math.floor(m.Units * Economy.Sell.RecycleFraction)
			if n > 0 and m.Id then
				Mochila.alBanco(perfil, m.Id, n)
				devuelto[m.Id] = n
			end
		end
	end
	return devuelto
end

-- Seguro de carga (B6, 7.2): 8 Poco común + 1 Raro de la zona más profunda desbloqueada, por unidad.
function Forja.costeSeguro(perfil, cantidad)
	local z = perfil.Progress.UnlockedZone
	local coste = { Coins = 0, Minerals = {} }
	for rz, n in pairs(Economy.InsuranceRecipe) do
		table.insert(coste.Minerals, { Id = Mochila.mineralDe(z, rz), Rarity = rz, Units = n * cantidad })
	end
	table.sort(coste.Minerals, function(a, b)
		return Rarity.Multiplier[a.Rarity] < Rarity.Multiplier[b.Rarity]
	end)
	return coste
end

function Forja.fabricarSeguro(perfil, cantidad)
	local coste = Forja.costeSeguro(perfil, cantidad)
	local ok, motivo = Forja.alcanza(perfil, coste)
	if not ok then
		return nil, motivo
	end
	cobrarMateriales(perfil, coste)
	perfil.Consumables.CargoInsurance = (perfil.Consumables.CargoInsurance or 0) + cantidad
	return cantidad
end

return Forja
