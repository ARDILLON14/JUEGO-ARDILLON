-- Formulas/Suerte: F2 a F5 (factor de suerte, pesos con suerte y protección contra mala suerte).
-- Referencia: OREBOUND/B_Matematico/B1_Rarezas.md. Funciones puras: el azar entra como parámetro.

local Rarity = require(script.Parent.Parent.Config.Rarity)
local Boxes = require(script.Parent.Parent.Config.Boxes)

local Suerte = {}

local ORDER = Rarity.Order
local INDEX = {}
for i, name in ipairs(ORDER) do
	INDEX[name] = i
end
Suerte.RarityIndex = INDEX

-- F2: F(S) = 1 + 3 S / (S + 1000)
function Suerte.factor(luck)
	luck = math.max(luck or 0, 0)
	return 1 + Rarity.Luck.FMax * luck / (luck + Rarity.Luck.K)
end

-- F3: peso x F^e, normalizado a 100. Devuelve una tabla nueva { [rareza] = porcentaje }.
-- Las rarezas sin exponente (Celestial en la caja de evento) no cambian de peso.
function Suerte.applyLuck(weights, luck)
	local f = Suerte.factor(luck)
	local out, total = {}, 0
	for rarity, weight in pairs(weights) do
		local w = weight * f ^ (Rarity.Luck.Exponent[rarity] or 0)
		out[rarity] = w
		total = total + w
	end
	for rarity, w in pairs(out) do
		out[rarity] = 100 * w / total
	end
	return out
end

-- Suma de los pesos de las rarezas iguales o superiores a minRarity.
function Suerte.shareAtLeast(weights, minRarity)
	local minIndex = INDEX[minRarity]
	local total = 0
	for rarity, weight in pairs(weights) do
		if INDEX[rarity] >= minIndex then
			total = total + weight
		end
	end
	return total
end

-- F4: probabilidad de Legendario+ en la apertura n desde el último (n empieza en 1).
-- p0 es la probabilidad base (0..1) ya con suerte.
function Suerte.pityChance(p0, n)
	local pity = Boxes.Pity
	if n <= pity.RampStart then
		return p0
	elseif n >= pity.GuaranteeA then
		return 1
	end
	local t = (n - pity.RampStart) / (pity.GuaranteeA - pity.RampStart)
	return p0 + (1 - p0) * t ^ pity.RampExponent
end

-- Elige una rareza entre las que cumplen el filtro, en proporción a sus pesos.
-- El recorrido sigue Rarity.Order para que el resultado no dependa del orden de pairs.
local function pick(weights, minIndex, maxIndex, u)
	local total = 0
	for i = minIndex, maxIndex do
		total = total + (weights[ORDER[i]] or 0)
	end
	assert(total > 0, "tabla de pesos vacía en el tramo pedido")
	local target, acc, last = u * total, 0, nil
	for i = minIndex, maxIndex do
		local w = weights[ORDER[i]] or 0
		if w > 0 then
			acc = acc + w
			last = ORDER[i]
			if target < acc then
				return last
			end
		end
	end
	return last
end

-- Una apertura de caja con protección (F4 y F5). Pura: no toca el perfil.
--   weights: pesos base de la caja, por rareza
--   luck:    estadística Suerte (0 si la caja no la usa)
--   pity:    { A = aperturas desde el último Legendario+, B = desde el último Mítico+ }
--   random:  función que devuelve un número en [0, 1)
--   opts:    { GuaranteeBMin = rareza } para cajas cuya garantía B es otra (evento: UltraRare)
-- Devuelve la rareza y los contadores nuevos { A, B }.
function Suerte.roll(weights, luck, pity, random, opts)
	local cfg = Boxes.Pity
	local minA = INDEX[cfg.GuaranteeAMin]
	local minB = INDEX[(opts and opts.GuaranteeBMin) or cfg.GuaranteeBMin]
	local w = Suerte.applyLuck(weights, luck)
	local a, b = pity.A + 1, pity.B + 1
	local rarity
	if b >= cfg.GuaranteeB then
		rarity = pick(w, minB, #ORDER, random())   -- si coincide con A, manda B
	else
		local p0 = Suerte.shareAtLeast(w, cfg.GuaranteeAMin) / 100
		if random() < Suerte.pityChance(p0, a) then
			rarity = pick(w, minA, #ORDER, random())
		else
			rarity = pick(w, 1, minA - 1, random())
		end
	end
	local index = INDEX[rarity]
	if index >= minA then
		a = 0
	end
	if index >= minB then
		b = 0
	end
	return rarity, { A = a, B = b }
end

-- Sorteo simple sin protección (depósitos, tipos de arma, categorías): devuelve la clave elegida.
-- order es la lista de claves en el orden en que se recorren.
function Suerte.pickWeighted(weights, order, u)
	local total = 0
	for _, key in ipairs(order) do
		total = total + (weights[key] or 0)
	end
	local target, acc, last = u * total, 0, nil
	for _, key in ipairs(order) do
		local w = weights[key] or 0
		if w > 0 then
			acc = acc + w
			last = key
			if target < acc then
				return key
			end
		end
	end
	return last
end

return Suerte
