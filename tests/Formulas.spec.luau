-- Pruebas de Shared/Formulas contra los valores de referencia de OREBOUND/calculos (tests/Vectores).

local Shared = game:GetService("ReplicatedStorage").Shared
local F = Shared.Formulas
local Potencia = require(F.Potencia)
local Suerte = require(F.Suerte)
local Progresion = require(F.Progresion)
local Defensa = require(F.Defensa)
local Mineria = require(F.Mineria)
local Dano = require(F.Dano)
local Mascotas = require(F.Mascotas)
local Economia = require(F.Economia)
local Boxes = require(Shared.Config.Boxes)

local V = script.Parent.Vectores

-- Generador determinista (Park-Miller) para que las simulaciones den lo mismo en Lua 5.1 y en Luau.
-- El producto no pasa de 2^47, así que es exacto con números de doble precisión.
local function generador(semilla)
	local estado = semilla % 2147483647
	return function()
		estado = (estado * 48271) % 2147483647
		return (estado - 1) / 2147483646
	end
end

return function(t)
	t.describe("Potencia (F1)", function()
		t.it("PotZona se duplica por zona", function()
			t.equal(Potencia.zonePower(1), 100)
			t.equal(Potencia.zonePower(4), 800)
			t.equal(Potencia.zonePower(10), 51200)
		end)
		t.it("coincide con los 75 picos de B3 (base y al máximo)", function()
			for _, p in ipairs(require(V.Picos)) do
				t.near(Potencia.itemPower(p.Zone, p.Rarity), p.Power, 0.5)
				t.near(Potencia.itemPower(p.Zone, p.Rarity, 1), p.PowerMax, 0.5)
			end
		end)
		t.it("los bonos se limitan a +50 %", function()
			t.near(Potencia.upgradeBonus({ Level = 10, Slots = 3, Awakened = true }), 0.50)
			t.near(Potencia.upgradeBonus({ Level = 4, Slots = 1, Awakened = false }), 0.10 + 0.05)
			t.equal(Potencia.upgradeBonus({ Level = 99, Slots = 99, Awakened = true }), 0.50)
			t.equal(Potencia.ofItem({ Zone = 4, Rarity = "Epic", Level = 10, Slots = 0, Awakened = false }), 800 * 1.9 * 1.25)
		end)
		t.it("un Común sin mejoras de zona 4 supera a un Ultra raro de zona 1", function()
			t.ok(Potencia.itemPower(4, "Common") > Potencia.itemPower(1, "UltraRare"))
		end)
	end)

	t.describe("Suerte (F2 a F5)", function()
		t.it("factor de suerte", function()
			t.equal(Suerte.factor(0), 1)
			t.near(Suerte.factor(1000), 2.5)
			t.ok(Suerte.factor(1e9) < 4)
		end)
		t.it("los pesos con suerte suman 100 y no cambian sin suerte", function()
			for _, s in ipairs({ 0, 10, 500, 1000, 1e9 }) do
				local w, total = Suerte.applyLuck(Boxes.StandardWeights, s), 0
				for _, p in pairs(w) do
					total = total + p
				end
				t.near(total, 100, 1e-9)
			end
			t.near(Suerte.applyLuck(Boxes.StandardWeights, 0).Legendary, 2.4)
			t.near(Suerte.shareAtLeast(Boxes.StandardWeights, "Legendary"), 3.0)
		end)
		t.it("rampa de protección", function()
			t.equal(Suerte.pityChance(0.03, 1), 0.03)
			t.equal(Suerte.pityChance(0.03, 40), 0.03)
			t.near(Suerte.pityChance(0.03, 45), 0.03 + 0.97 * 0.25)
			t.equal(Suerte.pityChance(0.03, 50), 1)
		end)
		t.it("garantías en la apertura 50 y en la 100", function()
			local nunca = function()
				return 0.999999
			end
			local r, p = Suerte.roll(Boxes.StandardWeights, 0, { A = 49, B = 10 }, nunca)
			t.ok(Suerte.RarityIndex[r] >= Suerte.RarityIndex.Legendary)
			t.equal(p.A, 0)
			r, p = Suerte.roll(Boxes.StandardWeights, 0, { A = 49, B = 99 }, nunca)
			t.ok(Suerte.RarityIndex[r] >= Suerte.RarityIndex.Mythic, "si coinciden, manda B")
			t.deepEqual(p, { A = 0, B = 0 })
			r, p = Suerte.roll(Boxes.StandardWeights, 0, { A = 0, B = 0 }, function()
				return 0.5
			end)
			t.equal(r, "Common")
			t.deepEqual(p, { A = 1, B = 1 })
		end)
		t.it("200.000 aperturas: tasas reales de B1 y nunca Celestial", function()
			local rng, pity = generador(20261116), { A = 0, B = 0 }
			local n, leg, mit, peor, racha = 200000, 0, 0, 0, 0
			for _ = 1, n do
				local r
				r, pity = Suerte.roll(Boxes.StandardWeights, 0, pity, rng)
				t.ok(r ~= "Celestial")
				local i = Suerte.RarityIndex[r]
				racha = racha + 1
				if i >= 5 then
					leg = leg + 1
					peor = math.max(peor, racha)
					racha = 0
				end
				if i >= 6 then
					mit = mit + 1
				end
			end
			t.near(100 * leg / n, 4.449, 0.15, "Legendario o superior")
			t.near(100 * mit / n, 1.399, 0.10, "Mítico o superior")
			t.ok(peor <= 50, "nadie pasa de 50 aperturas sin Legendario+")
		end)
		t.it("caja de evento: la garantía B exige Ultra raro o superior", function()
			local r = Suerte.roll(Boxes.Boxes.Event.Weights, 0, { A = 0, B = 99 }, function()
				return 0
			end, { GuaranteeBMin = "UltraRare" })
			t.equal(r, "UltraRare")
		end)
	end)

	t.describe("Progresión (F6 a F11)", function()
		t.it("XP por nivel y acumulada coinciden con b2_xp_niveles.csv (1.000 niveles)", function()
			local acumulada = 0
			for _, fila in ipairs(require(V.XP)) do
				t.equal(Progresion.xpForLevel(fila[1]), fila[2])
				t.equal(acumulada, fila[3])
				acumulada = acumulada + fila[2]
			end
		end)
		t.it("cola por encima de 1.000", function()
			t.equal(Progresion.xpForLevel(1000), 820100)
			t.equal(Progresion.xpForLevel(1010), 820100 + 9000)
		end)
		t.it("sumar XP sube varios niveles", function()
			local nivel, xp, subidos = Progresion.addXP(1, 0, 121 + 144 + 10)
			t.equal(nivel, 3)
			t.equal(xp, 10)
			t.equal(subidos, 2)
		end)
		t.it("puntos de estadística", function()
			t.equal(Progresion.statPoints(1), 3)
			t.equal(Progresion.statPoints(1000), 3000)
			t.equal(Progresion.statPoints(1100), 3100)
			t.equal(Progresion.statPoints(2000), 4000)
		end)
		t.it("curva, vida y energía", function()
			t.equal(Progresion.curve(0, 3), 1)
			t.near(Progresion.curve(1000, 3), 2.5)
			t.near(Progresion.curve(5000, 3), 3.5, 1e-9, "B2: Fuerza 5.000 da ×3,5")
			t.near(Progresion.curve(99999, 3), 3.5, 1e-9, "tope de 5.000 de valor total")
			t.near(Progresion.curve(5000, 1.5), 2.25)
			t.near(Progresion.maxEnergy(5000), 350)
			t.near(Progresion.walkSpeed(5000), 16 * (1 + 0.5 * 5000 / 6000))
			t.equal(Progresion.baseHealth(1), 500)
			t.near(Progresion.baseHealth(101), 1000)
			t.near(Progresion.maxEnergy(1000), 250)
			t.near(Progresion.energyRegen(0, true), 8)
			t.near(Progresion.energyRegen(1000, false), 30)
			t.near(Progresion.walkSpeed(1000), 20)
			t.near(Progresion.walkSpeed(0, 0.40), 9.6)
		end)
	end)

	t.describe("Defensa (F12)", function()
		t.it("PvE y PvP con sus topes", function()
			t.equal(Defensa.reduction(0, "PvE"), 0)
			t.near(Defensa.reduction(1500, "PvE"), 0.5)
			t.equal(Defensa.reduction(1e9, "PvE"), 0.75)
			t.near(Defensa.reduction(1000, "PvP"), 1000 / 5500)
			t.equal(Defensa.reduction(1e9, "PvP"), 0.50)
		end)
	end)

	t.describe("Minería (F13 a F17, F34 a F36)", function()
		t.it("los 66 depósitos coinciden con b3_minerales.csv", function()
			for _, m in ipairs(require(V.Minerales)) do
				t.near(Mineria.depositHealth(m.Zone, m.Rarity), m.Health, 0.5, m.Id .. " vida")
				t.near(Mineria.depositValue(m.Zone, m.Rarity), m.Value, 0.5, m.Id .. " valor")
				t.equal(Mineria.depositUnits(m.Rarity), m.Units)
				t.near(Mineria.depositXP(m.Zone, m.Rarity), m.XP, 0.5, m.Id .. " XP")
				t.near(Mineria.pickPowerReq(m.Zone), m.PickReq, 0.5)
				t.near(Mineria.depositMiningReq(m.Zone, m.Rarity), m.MiningReq, 0.5, m.Id .. " Minería")
				t.near(Mineria.spawnWeights(m.Zone)[m.Rarity], m.Chance, 1e-9, m.Id .. " probabilidad")
			end
		end)
		t.it("requisitos de equipar picos coinciden con b3_picos.csv", function()
			for _, p in ipairs(require(V.Picos)) do
				t.near(Mineria.pickEquipMining(p.Zone, p.Rarity), p.Mining, 0.5)
				t.equal(Mineria.zoneLevel(p.Zone), p.Level)
				t.equal(Mineria.pickHitsPerSecond(p.Rarity), p.HitsPerSecond)
			end
		end)
		t.it("las tablas de aparición suman 100", function()
			for zona = 1, 10 do
				local total = 0
				for _, p in pairs(Mineria.spawnWeights(zona)) do
					total = total + p
				end
				t.near(total, 100, 1e-9)
			end
		end)
		t.it("tiempo de extracción con mínimo de 3 golpes", function()
			t.equal(Mineria.hitsToDeplete(600, 100, 0), 6)
			t.equal(Mineria.hitsToDeplete(600, 100000, 0), 3)
			t.equal(Mineria.hitDamage(600, 100000, 0), 200)
			t.near(Mineria.extractionSeconds(600, 100, 0, 1.0), 6)
			t.equal(Mineria.pickHitsPerSecond("Celestial", 5), 2.0)
		end)
		t.it("depósitos activos", function()
			t.equal(Mineria.activeDeposits(1), 40)
			t.equal(Mineria.activeDeposits(10), 50)
			t.equal(Mineria.activeDeposits(20), 80)
		end)
		t.it("carga y ralentización", function()
			t.near(Mineria.load(200, 1), 1)
			t.near(Mineria.loadSlow(1), 0.12 * math.log(2))
			t.equal(Mineria.loadSlow(1000), 0.40)
			t.equal(Mineria.loadSlow(0), 0)
		end)
		t.it("racha y mineral fracturado", function()
			t.equal(Mineria.fracturedMultiplier(0, false), 1)
			t.near(Mineria.fracturedMultiplier(0, true), 1.5)
			t.near(Mineria.fracturedMultiplier(5, true), 2.25)
			t.near(Mineria.fracturedMultiplier(40, true), 2.25)
		end)
		t.it("reparto al morir en PvP", function()
			t.deepEqual(Mineria.pvpDeathSplit(5, false, false), { Kept = 0.5, Dropped = 0.5, Lootable = 0.4, Destroyed = 0.5 - 0.4 })
			t.near(Mineria.pvpDeathSplit(5, true, false).Dropped, 0.25)
			t.equal(Mineria.pvpDeathSplit(0.5, false, false).Dropped, 0)
			t.equal(Mineria.pvpDeathSplit(50, false, true).Dropped, 0)
		end)
	end)

	t.describe("Daño (F18 a F25)", function()
		t.it("las 450 armas coinciden con b4_armas.csv", function()
			for _, a in ipairs(require(V.Armas)) do
				local potencia = Potencia.itemPower(a.Zone, a.Rarity)
				t.near(potencia, a.Power, 0.5)
				t.near(Dano.hitDamage(potencia, a.Type), a.HitDamage, 0.06)
				t.near(Dano.baseDPS(potencia, a.Type), a.BaseDPS, 0.0006 * a.BaseDPS + 0.06)
			end
		end)
		t.it("daño final en PvE y PvP", function()
			local base = { WeaponPower = 1000, Coef = 1, Strength = 0, Mastery = 0, TargetDefense = 0 }
			t.equal(Dano.final(base), 1000)
			base.Mode = "PvP"
			t.near(Dano.final(base), 62)
			t.near(Dano.final({ WeaponPower = 1000, Coef = 0.625, Strength = 1000, Mastery = 100, Crit = true, Status = 0.9,
				TargetDefense = 1500, Mode = "PvE" }), 1000 * 0.625 * 2.5 * 1.1 * 1.5 * 1.4 * 0.5)
		end)
		t.it("topes de PvP", function()
			t.equal(Dano.capPvPHit(900, 1000), 350)
			t.equal(Dano.capPvPBurst(350, 400, 1000), 200)
			t.equal(Dano.capPvPBurst(350, 700, 1000), 0)
		end)
		t.it("maestría y crítico", function()
			t.equal(Dano.masteryXP(10), 34)
			t.near(Dano.masteryMultiplier(250), 1.1)
			t.equal(Dano.critChance(0.9), 0.30)
			t.equal(Dano.critMultiplier(3), 2.0)
			t.equal(Dano.controlFactor(0), 1)
			t.equal(Dano.controlFactor(1), 0.5)
			t.equal(Dano.controlFactor(2), 0)
		end)
		t.it("enemigos y jefes", function()
			t.equal(Dano.enemyHealth(1, "Common"), 1600)
			t.near(Dano.enemyHealth(3, "Boss"), 400 * 1.2 * 1200)
			t.near(Dano.enemyDamage(1, "Common"), 15)
			t.near(Dano.enemyDamage(2, "Boss"), 500 * 2 ^ (99 / 100) * 0.15)
			t.near(Dano.enemyCoins(1, "Common"), 14)
			t.near(Dano.enemyCoins(2, "Boss"), 1200)
			t.near(Dano.enemyXP(1, "Common"), 0.71 * 217.5)
			t.near(Dano.bossScale(8).Health, 5.2)
			t.near(Dano.bossScale(99).Damage, 1.35)
		end)
	end)

	t.describe("Mascotas (F26 a F31)", function()
		local mantis = { Role = "Offense", Rarity = "Legendary", Level = 50, Phase = "Unleashed" }
		t.it("nivel", function()
			t.equal(Mascotas.levelXP(1), 19)
			t.near(Mascotas.levelDamage(100), 2.485)
			t.equal(Mascotas.hitsPerSecond(1.9, 100), 2.0)
		end)
		t.it("DPS, vida y posturas", function()
			local dps = Mascotas.dps(1000, mantis, 0, "Protect")
			t.near(dps, 1000 * 0.016 * 2.5 * (1 + 0.015 * 49) * 1.25 * 1 * (1 + 0.002 * 49) * 1.5)
			t.near(Mascotas.dps(1000, mantis, 0, "Gather"), dps / 3)
			t.near(Mascotas.health(1, mantis, 0), 500 * 0.40 * 2.5 * 1.49 * 1.25)
			t.near(Mascotas.pickupRadius("Gather", 0), 30)
			t.near(Mascotas.pickupRadius("Protect", 9), 15)
		end)
		t.it("utilidad de referencia del GDD", function()
			t.near(Mascotas.utilityFactor({ Level = 50, Phase = "Unleashed" }, 0), 1, 0.001)
		end)
		t.it("tope conjunto de DPS", function()
			local ref = Mascotas.dpsRef(1000, 0, 0)
			t.near(ref, 1000 * 1.025 * 1.39)
			t.equal(Mascotas.capFactor(0.1 * ref, ref, "PvE"), 1)
			t.near(Mascotas.capFactor(0.8 * ref, ref, "PvE"), 0.5)
			t.near(Mascotas.capFactor(1.0 * ref, ref, "PvP"), 0.25)
			t.near(Mascotas.windowRoom(ref, "PvE", 0), 0.4 * ref * 5)
			t.equal(Mascotas.windowRoom(ref, "PvE", 1e12), 0)
		end)
	end)

	t.describe("Economía (F32 y F33)", function()
		t.it("los 70 precios de equipo coinciden con b6_precios_equipo.csv", function()
			for _, e in ipairs(require(V.PreciosEquipo)) do
				-- tolerancia de 1 moneda: Python redondea los empates (x,5) al par y el juego, hacia arriba
				t.near(Economia.gearCost(e.Zone, e.Rarity), e.Craft, 1)
				t.near(Economia.upgradeAllLevelsCost(e.Zone, e.Rarity), e.Levels, 1)
				t.near(3 * Economia.slotCost(e.Zone, e.Rarity), e.Slots, 2)
				t.near(Economia.awakenCost(e.Zone, e.Rarity), e.Awaken, 1)
				t.near(Economia.gearSellPrice(e.Zone, e.Rarity), e.Sell, 1)
			end
		end)
		t.it("precio de venta de los 66 minerales", function()
			local catalogo = require(Shared.Config.Mining).Minerals
			for _, m in ipairs(require(V.PreciosMinerales)) do
				local c = catalogo[m.Id]
				t.ok(c, m.Id)
				t.near(Economia.mineralSellPrice(c.Zone, c.Rarity, 1), m.Sell, 0.051)
				t.near(Economia.mineralSellPrice(c.Zone, c.Rarity, 1, Mineria.fracturedMultiplier(0, true)), m.Fractured, 0.13)
			end
		end)
		t.it("cajas y mochila", function()
			t.equal(Economia.boxPrice("Weapon", 1), 5153)
			t.equal(Economia.boxPrice("Zone", 2), math.floor(0.6 * 10301 + 0.5))
			t.throws(function()
				Economia.boxPrice("Event", 1)
			end)
			t.equal(Economia.backpackPrice(1), math.floor(0.5 * 10301 + 0.5))
		end)
	end)
end
