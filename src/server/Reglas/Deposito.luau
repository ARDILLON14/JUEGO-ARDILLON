-- Reglas/Deposito: un depósito de mineral, sus golpes y el reparto al agotarse (B3, F15 y 5.3). Puro.

local Shared = game:GetService("ReplicatedStorage").Shared
local Mining = require(Shared.Config.Mining)
local Mineria = require(Shared.Formulas.Mineria)

local Deposito = {}

function Deposito.nuevo(id, zona, rareza, mineral)
	local vida = Mineria.depositHealth(zona, rareza)
	return { Id = id, Zone = zona, Rarity = rareza, Mineral = mineral, MaxHealth = vida, Health = vida, Damage = {}, Depleted = false }
end

-- Aplica daño de un jugador. Devuelve el daño aplicado y si se ha agotado con este golpe.
function Deposito.golpear(dep, userId, cantidad)
	if dep.Depleted or cantidad <= 0 then
		return 0, false
	end
	local aplicado = math.min(cantidad, dep.Health)
	dep.Health = dep.Health - aplicado
	dep.Damage[userId] = (dep.Damage[userId] or 0) + aplicado
	if dep.Health <= dep.MaxHealth * 1e-9 then
		dep.Health = 0
		dep.Depleted = true
		return aplicado, true
	end
	return aplicado, false
end

-- Reparto al agotarse: unidades y XP en proporción al daño. Quien hizo al menos el 10 % recibe 1 unidad
-- como mínimo (aunque eso supere las unidades del depósito). Devuelve { { UserId, Units, XP, Share } }.
-- El orden es estable (por UserId) para que el resultado no dependa de pairs.
function Deposito.reparto(dep)
	local unidades = Mineria.depositUnits(dep.Rarity)
	local xp = Mineria.depositXP(dep.Zone, dep.Rarity)
	local total, filas = 0, {}
	for userId, dano in pairs(dep.Damage) do
		total = total + dano
		table.insert(filas, { UserId = userId, Dano = dano })
	end
	if total <= 0 then
		return {}
	end
	table.sort(filas, function(a, b)
		return a.UserId < b.UserId
	end)
	local asignadas = 0
	for _, f in ipairs(filas) do
		f.Share = f.Dano / total
		local exacto = unidades * f.Share
		f.Units = math.floor(exacto + 1e-9)
		f.Resto = exacto - f.Units
		f.XP = xp * f.Share
		asignadas = asignadas + f.Units
	end
	local orden = {}
	for i, f in ipairs(filas) do
		orden[i] = f
	end
	table.sort(orden, function(a, b)
		if a.Resto ~= b.Resto then
			return a.Resto > b.Resto
		end
		return a.UserId < b.UserId
	end)
	local i = 1
	while asignadas < unidades and i <= #orden do
		orden[i].Units = orden[i].Units + 1
		asignadas = asignadas + 1
		i = i + 1
	end
	local salida = {}
	for _, f in ipairs(filas) do
		if f.Units < 1 and f.Share >= Mining.Share.MinFractionForUnit then
			f.Units = 1
		end
		table.insert(salida, { UserId = f.UserId, Units = f.Units, XP = f.XP, Share = f.Share })
	end
	return salida
end

return Deposito
