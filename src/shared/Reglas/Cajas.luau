-- Reglas/Cajas: probabilidades que se muestran y apertura de cajas (B1 y B6, sección 5). Puro.
-- Garantías por tipo de caja (B1): Legendario+ en 50 aperturas y Mítico+ en 100; si coinciden, manda la de Mítico.
-- El premio se decide aquí, antes de cualquier animación.

local Shared = script.Parent.Parent
local Boxes = require(Shared.Config.Boxes)
local Rarity = require(Shared.Config.Rarity)
local Weapons = require(Shared.Config.Weapons)
local Pets = require(Shared.Config.Pets)
local PowerCores = require(Shared.Config.PowerCores)
local Pickaxes = require(Shared.Config.Pickaxes)
local Suerte = require(Shared.Formulas.Suerte)
local Economia = require(Shared.Formulas.Economia)
local Mochila = require(script.Parent.Mochila)
local Inventario = require(script.Parent.Inventario)

local Cajas = {}

local function ordenadas(t)
	local k = {}
	for clave in pairs(t) do
		table.insert(k, clave)
	end
	table.sort(k)
	return k
end

-- Especies de mascota y Núcleos agrupados por rareza.
local ESPECIES, NUCLEOS = {}, {}
for id, e in pairs(Pets.Species) do
	ESPECIES[e.Rarity] = ESPECIES[e.Rarity] or {}
	table.insert(ESPECIES[e.Rarity], id)
end
for _, lista in pairs(ESPECIES) do
	table.sort(lista)
end
local PESO_NUCLEO_RAREZA = {}
for id, peso in pairs(Boxes.Boxes.Core.Weights) do
	local r = PowerCores.Cores[id].Rarity
	NUCLEOS[r] = NUCLEOS[r] or {}
	table.insert(NUCLEOS[r], id)
	PESO_NUCLEO_RAREZA[r] = (PESO_NUCLEO_RAREZA[r] or 0) + peso
end
for _, lista in pairs(NUCLEOS) do
	table.sort(lista)
end

-- Tabla de rarezas de cada caja (antes de la Suerte).
function Cajas.pesos(tipo)
	if tipo == "Core" then
		return PESO_NUCLEO_RAREZA
	elseif tipo == "Event" then
		return Boxes.Boxes.Event.Weights
	end
	return Boxes.StandardWeights
end

function Cajas.usaSuerte(tipo)
	return Boxes.Boxes[tipo].LuckApplies ~= false
end

-- Probabilidades que se muestran antes de abrir (GDD): con la Suerte del jugador, en %.
function Cajas.probabilidades(tipo, suerte)
	return Suerte.applyLuck(Cajas.pesos(tipo), Cajas.usaSuerte(tipo) and suerte or 0)
end

-- Zona en la que se compra: la más profunda desbloqueada (C_Tecnico: Box.Open no lleva zona).
function Cajas.precio(tipo, perfil)
	return Economia.boxPrice(tipo, perfil.Progress.UnlockedZone)
end

local function elegir(lista, u)
	return lista[math.min(#lista, math.floor(u * #lista) + 1)]
end

-- Abre una caja (sin cobrar). Cambia contadores, registro y contenido del perfil.
-- aleatorio() en [0, 1); nuevoId() da identificadores de objeto. Devuelve el premio:
-- { Box, Rarity, Kind = "Weapon"|"Pickaxe"|"Minerals"|"Insurance"|"Egg"|"Core"|"CoreDuplicate", Id, Item, Mineral, Units, Species, Core }
function Cajas.abrir(perfil, tipo, suerte, aleatorio, nuevoId, ahora)
	local caja = Boxes.Boxes[tipo]
	local zona = perfil.Progress.UnlockedZone
	local contador = perfil.Boxes.Pity[tipo]
	local rareza, nuevo = Suerte.roll(Cajas.pesos(tipo), Cajas.usaSuerte(tipo) and suerte or 0, contador, aleatorio,
		{ GuaranteeBMin = caja.GuaranteeBMin })
	perfil.Boxes.Pity[tipo] = nuevo
	perfil.Boxes.Opened[tipo] = (perfil.Boxes.Opened[tipo] or 0) + 1
	local premio = { Box = tipo, Rarity = rareza, Zone = zona }

	if tipo == "Weapon" then
		local arma = Suerte.pickWeighted(caja.TypeWeights, ordenadas(caja.TypeWeights), aleatorio())
		premio.Kind, premio.Id = "Weapon", nuevoId()
		premio.Item = Inventario.crearArma(arma, zona, rareza)
		perfil.Items[premio.Id] = premio.Item
	elseif tipo == "Zone" then
		local categoria = Suerte.pickWeighted(caja.CategoryWeights, { "Pickaxe", "Minerals", "Materials", "Consumables" }, aleatorio())
		if categoria == "Pickaxe" then
			local pasivas = {}
			for _, cat in ipairs({ "Unique", "Major", "Minor" }) do
				local lista = Pickaxes.Passives[cat]
				for _ = 1, ((Pickaxes.PassiveSlots[rareza] or {})[cat] or 0) do
					local p
					repeat
						p = elegir(lista, aleatorio())
					until not table.find(pasivas, p) or #lista <= 1
					table.insert(pasivas, p)
				end
			end
			local stat = nil
			if Pickaxes.CombatStat[rareza] then
				stat = aleatorio() < 0.5 and "Defense" or "AttackSpeed"
			end
			premio.Kind, premio.Id = "Pickaxe", nuevoId()
			premio.Item = Inventario.crearPico(zona, rareza, pasivas, stat)
			perfil.Items[premio.Id] = premio.Item
		elseif categoria == "Consumables" then
			premio.Kind, premio.Units = "Insurance", caja.InsuranceLot[rareza] or 1
			perfil.Consumables.CargoInsurance = (perfil.Consumables.CargoInsurance or 0) + premio.Units
		else
			-- Lote de minerales (o materiales: el mineral de la rareza siguiente) por valor de LotHours horas de ingreso.
			local rz = rareza
			if categoria == "Materials" then
				local i = table.find(Rarity.Order, rareza)
				rz = Rarity.Order[math.min(i + 1, 7)]
			end
			local mineral = Mochila.mineralDe(zona, rz) or Mochila.mineralDe(zona, rareza) or Mochila.mineralDe(zona, "Mythic")
			local valor = caja.LotHours[rareza] * Economia.income(zona)
			premio.Kind, premio.Mineral = "Minerals", mineral
			premio.Units = math.max(1, math.floor(valor / Mochila.precioUnidad(mineral)))
			Mochila.alBanco(perfil, mineral, premio.Units)
		end
	elseif tipo == "Pet" then
		local especie = elegir(ESPECIES[rareza] or ESPECIES.Common, aleatorio())
		premio.Kind, premio.Id, premio.Species = "Egg", nuevoId(), especie
		perfil.Eggs[premio.Id] = { Species = especie }
	elseif tipo == "Core" then
		local nucleo = elegir(NUCLEOS[rareza] or NUCLEOS.Rare, aleatorio())
		premio.Core = nucleo
		if perfil.Cores[nucleo] then
			premio.Kind = "CoreDuplicate"
			premio.Units = caja.DuplicateMasteryPoints
		else
			premio.Kind = "Core"
			perfil.Cores[nucleo] = { Mastery = 1, XP = 0, Awakened = false }
		end
	end

	table.insert(perfil.Boxes.Log, { T = ahora or 0, Box = tipo, Zone = zona, Rarity = rareza, Item = premio.Id or premio.Mineral or premio.Core or premio.Species,
		A = nuevo.A, B = nuevo.B })
	while #perfil.Boxes.Log > Boxes.LogSize do
		table.remove(perfil.Boxes.Log, 1)
	end
	return premio
end

-- Huecos que necesita una apertura (para no superar el máximo de objetos).
function Cajas.necesitaHueco(tipo)
	return tipo == "Weapon" or tipo == "Zone"
end

-- Aperturas que faltan para cada garantía.
function Cajas.faltan(perfil, tipo)
	local c = perfil.Boxes.Pity[tipo] or { A = 0, B = 0 }
	return Boxes.Pity.GuaranteeA - c.A, Boxes.Pity.GuaranteeB - c.B
end

return Cajas
