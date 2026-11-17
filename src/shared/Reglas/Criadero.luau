-- Reglas/Criadero: huevos, incubadoras, mascotas, espacios, Nido, XP, liberar, evolucionar y bonos de recolección (B5).
-- Funciones puras sobre el perfil. El servidor decide; el cliente las usa para mostrar.

local Shared = script.Parent.Parent
local Pets = require(Shared.Config.Pets)
local Economy = require(Shared.Config.Economy)
local Rarity = require(Shared.Config.Rarity)
local Mascotas = require(Shared.Formulas.Mascotas)
local Economia = require(Shared.Formulas.Economia)

local Criadero = {}

local function contar(t)
	local n = 0
	for _ in pairs(t or {}) do
		n = n + 1
	end
	return n
end
Criadero.contar = contar

function Criadero.especie(id)
	return Pets.Species[id]
end

-- Espacios de mascotas: 3; el 4.º a nivel 300 y el 5.º a 700 (B5 8). El 6.º es de pago (fase 9).
function Criadero.espacios(perfil)
	local n = Pets.Slots.Start
	for hueco = 4, 5 do
		local u = Pets.Slots.Unlock[hueco]
		if u and u.Level and perfil.Progress.Level >= u.Level then
			n = hueco
		end
	end
	if perfil.Purchases and perfil.Purchases.SixthPetSlot then
		n = math.max(n, 6)
	end
	return n
end

-- Incubadoras disponibles (añade la segunda a nivel 200).
function Criadero.asegurarIncubadoras(perfil)
	local cambio = false
	local quiere = Pets.Incubators.Start
	if perfil.Progress.Level >= Pets.Incubators.SecondAtLevel then
		quiere = 2
	end
	while #perfil.Incubators < quiere do
		table.insert(perfil.Incubators, { Egg = "", Species = "", PickHits = 0 })
		cambio = true
	end
	return cambio
end

function Criadero.golpesNecesarios(especie)
	return Pets.Hatch.PickHits[Pets.Species[especie].Rarity]
end

-- Pone un huevo en una incubadora libre. Devuelve true o false y el motivo: "huevo" | "incubadora" | "ocupada".
function Criadero.incubar(perfil, huevoId, n)
	local huevo = perfil.Eggs[huevoId]
	if not huevo then
		return false, "huevo"
	end
	local inc = perfil.Incubators[n]
	if not inc then
		return false, "incubadora"
	end
	if inc.Egg ~= "" then
		return false, "ocupada"
	end
	perfil.Eggs[huevoId] = nil
	inc.Egg, inc.Species, inc.PickHits = huevoId, huevo.Species, 0
	return true
end

-- Suma golpes de pico (o su equivalente) a todas las incubadoras ocupadas.
function Criadero.sumarGolpes(perfil, golpes)
	for _, inc in ipairs(perfil.Incubators) do
		if inc.Egg ~= "" then
			inc.PickHits = math.min(inc.PickHits + golpes, Criadero.golpesNecesarios(inc.Species))
		end
	end
end

function Criadero.lista(inc)
	return inc.Egg ~= "" and inc.PickHits >= Criadero.golpesNecesarios(inc.Species)
end

-- Saca la cría de una incubadora terminada. Devuelve la mascota o nil y el motivo: "incubadora" | "no_lista" | "almacen".
function Criadero.eclosionar(perfil, n, id)
	local inc = perfil.Incubators[n]
	if not inc or inc.Egg == "" then
		return nil, "incubadora"
	end
	if not Criadero.lista(inc) then
		return nil, "no_lista"
	end
	if contar(perfil.Pets) >= Pets.Storage.Pets then
		return nil, "almacen"
	end
	local mascota = { Species = inc.Species, Level = 1, XP = 0, Phase = "Hatchling" }
	perfil.Pets[id] = mascota
	inc.Egg, inc.Species, inc.PickHits = "", "", 0
	return mascota
end

-- Datos de combate de una mascota guardada (rol y rareza vienen de su especie).
function Criadero.datos(m)
	local e = Pets.Species[m.Species]
	return { Role = e.Role, Rarity = e.Rarity, Level = m.Level, Phase = m.Phase, HitsPerSecond = e.HitsPerSecond, Element = e.Element }
end

function Criadero.equipadas(perfil)
	local salida = {}
	for i = 1, Criadero.espacios(perfil) do
		local id = perfil.Equipped.Pets[i]
		if id and id ~= "" and perfil.Pets[id] then
			table.insert(salida, { Id = id, Mascota = perfil.Pets[id], Hueco = i })
		end
	end
	return salida
end

local function enUso(perfil, id)
	return table.find(perfil.Equipped.Pets, id) ~= nil or table.find(perfil.Nest, id) ~= nil
end
Criadero.enUso = enUso

-- Equipa en un hueco (id "" lo vacía). Si la mascota estaba en otro hueco o en el Nido, se mueve.
-- Devuelve true o false y el motivo: "mascota" | "hueco".
function Criadero.equipar(perfil, id, hueco)
	if hueco < 1 or hueco > Criadero.espacios(perfil) then
		return false, "hueco"
	end
	if id ~= "" and not perfil.Pets[id] then
		return false, "mascota"
	end
	for i = 1, #perfil.Equipped.Pets do
		if perfil.Equipped.Pets[i] == id then
			perfil.Equipped.Pets[i] = ""
		end
	end
	for i = 1, #perfil.Nest do
		if perfil.Nest[i] == id then
			perfil.Nest[i] = ""
		end
	end
	for i = #perfil.Equipped.Pets + 1, hueco do
		perfil.Equipped.Pets[i] = ""
	end
	perfil.Equipped.Pets[hueco] = id
	return true
end

-- Nido: 2 huecos para mascotas no equipadas (ganan el 15 % de la XP de combate mientras el dueño juega).
function Criadero.alNido(perfil, id, hueco)
	if hueco < 1 or hueco > Pets.XPSource.NestSlots then
		return false, "hueco"
	end
	if id ~= "" then
		if not perfil.Pets[id] then
			return false, "mascota"
		end
		if table.find(perfil.Equipped.Pets, id) then
			return false, "equipada"
		end
		for i = 1, #perfil.Nest do
			if perfil.Nest[i] == id then
				perfil.Nest[i] = ""
			end
		end
	end
	perfil.Nest[hueco] = id
	return true
end

-- Suma XP a una mascota (hasta nivel 100). Devuelve los niveles subidos.
function Criadero.sumarXP(m, xp)
	if m.Level >= Pets.Level.Max then
		return 0
	end
	m.XP = m.XP + xp
	local subidos = 0
	while m.Level < Pets.Level.Max and m.XP >= Mascotas.levelXP(m.Level) do
		m.XP = m.XP - Mascotas.levelXP(m.Level)
		m.Level = m.Level + 1
		subidos = subidos + 1
	end
	if m.Level >= Pets.Level.Max then
		m.XP = 0
	end
	return subidos
end

-- Liberar: da fragmentos de su elemento (B5 3). Nunca equipadas ni en el Nido.
function Criadero.liberar(perfil, ids)
	local fragmentos = {}
	for _, id in ipairs(ids) do
		local m = perfil.Pets[id]
		if not m then
			return nil, "mascota"
		end
		if enUso(perfil, id) then
			return nil, "en_uso"
		end
	end
	for _, id in ipairs(ids) do
		local e = Pets.Species[perfil.Pets[id].Species]
		local n = Pets.Evolve.FragmentsFromDuplicate[e.Rarity] or 1
		perfil.Materials.Element[e.Element] = (perfil.Materials.Element[e.Element] or 0) + n
		fragmentos[e.Element] = (fragmentos[e.Element] or 0) + n
		perfil.Pets[id] = nil
	end
	return fragmentos
end

-- Evolución: cría (nivel 50) -> forma desatada; desatada (nivel 100) -> máxima. Coste: fragmentos o material de jefe y monedas.
-- Devuelve { Siguiente, Coins, Fragments, Element, Boss } o nil y el motivo: "mascota" | "nivel" | "maxima".
function Criadero.costeEvolucion(perfil, id)
	local m = perfil.Pets[id]
	if not m then
		return nil, "mascota"
	end
	local e = Pets.Species[m.Species]
	if m.Phase == "Hatchling" then
		if m.Level < Pets.Phase.Unleashed.Level then
			return nil, "nivel"
		end
		return { Siguiente = "Unleashed", Element = e.Element, Fragments = Pets.Evolve.ElementFragments[e.Rarity], Boss = 0,
			Coins = math.floor(Economy.PetEvolveHours.Unleashed * Economia.income(perfil.Progress.UnlockedZone) + 0.5) }
	elseif m.Phase == "Unleashed" then
		if m.Level < Pets.Phase.UnleashedMax.Level then
			return nil, "nivel"
		end
		return { Siguiente = "UnleashedMax", Element = e.Element, Fragments = 0, Boss = Pets.Evolve.BossMaterials[e.Rarity],
			Coins = math.floor(Economy.PetEvolveHours.UnleashedMax * Economia.income(perfil.Progress.UnlockedZone) + 0.5) }
	end
	return nil, "maxima"
end

function Criadero.materialesJefe(perfil)
	local n = 0
	for _, v in pairs(perfil.Materials.Boss or {}) do
		n = n + v
	end
	return n
end

-- Comprueba fragmentos y material de jefe (las monedas las cobra EconomyService). Devuelve true o false y el motivo.
function Criadero.puedeEvolucionar(perfil, coste)
	if (perfil.Materials.Element[coste.Element] or 0) < coste.Fragments then
		return false, "fragmentos"
	end
	if coste.Boss > 0 and Criadero.materialesJefe(perfil) < coste.Boss then
		return false, "jefe"
	end
	if (perfil.Wallet.Coins or 0) < coste.Coins then
		return false, "monedas"
	end
	return true
end

function Criadero.evolucionar(perfil, id, coste)
	local m = perfil.Pets[id]
	perfil.Materials.Element[coste.Element] = (perfil.Materials.Element[coste.Element] or 0) - coste.Fragments
	local resto = coste.Boss
	for clave, v in pairs(perfil.Materials.Boss or {}) do
		if resto <= 0 then
			break
		end
		local usa = math.min(v, resto)
		perfil.Materials.Boss[clave] = v - usa
		resto = resto - usa
	end
	m.Phase = coste.Siguiente
	return m
end

-- Bonos de recolección de las mascotas equipadas, con los topes de B5 (sección 5).
-- { ExtractSpeed, ExtraUnitChance, BackpackUnits, PickupRadius, RevealDeposits (studs, 0 si no), DetectChests }
function Criadero.bonos(perfil, capacidadBase)
	local b = { ExtractSpeed = 0, ExtraUnitChance = 0, BackpackUnits = 0, PickupRadius = 0, RevealDeposits = 0, DetectChests = 0 }
	for _, e in ipairs(Criadero.equipadas(perfil)) do
		local p = Pets.Species[e.Mascota.Species].GatherPassive
		if p.Kind == "RevealDeposits" or p.Kind == "DetectChests" then
			b[p.Kind] = math.max(b[p.Kind], p.Studs)
		elseif b[p.Kind] ~= nil then
			b[p.Kind] = b[p.Kind] + p.Value
		end
	end
	local topes = Pets.GatherCaps
	b.ExtractSpeed = math.min(b.ExtractSpeed, topes.ExtractSpeed)
	b.ExtraUnitChance = math.min(b.ExtraUnitChance, topes.ExtraUnitChance)
	b.PickupRadius = math.min(b.PickupRadius, topes.PickupRadius)
	if capacidadBase then
		b.BackpackUnits = math.min(b.BackpackUnits, math.floor(capacidadBase * topes.Backpack))
	end
	return b
end

-- Orden de rareza para mostrar.
function Criadero.ordenRareza(especie)
	return table.find(Rarity.Order, Pets.Species[especie].Rarity) or 0
end

return Criadero
