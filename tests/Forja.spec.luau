-- Pruebas de la fase 5: forja (fabricar, mejorar, reciclar, Seguro de carga), cajas y medidas del roadmap.

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Economy = require(Shared.Config.Economy)
local Boxes = require(Shared.Config.Boxes)
local Mining = require(Shared.Config.Mining)
local Rarity = require(Shared.Config.Rarity)
local Economia = require(Shared.Formulas.Economia)
local Mineria = require(Shared.Formulas.Mineria)
local Potencia = require(Shared.Formulas.Potencia)
local Mochila = require(Shared.Reglas.Mochila)
local Forja = require(Shared.Reglas.Forja)
local Cajas = require(Shared.Reglas.Cajas)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

local function generador(semilla)
	local estado = semilla % 2147483647
	return function()
		estado = (estado * 48271) % 2147483647
		return (estado - 1) / 2147483646
	end
end

local function contador()
	local n = 0
	return function()
		n = n + 1
		return "id" .. n
	end
end

local function rico(zona)
	local p = PlantillaPerfil.nuevo(0)
	p.Progress.UnlockedZone = zona or 1
	p.Progress.Level = Mineria.zoneLevel(zona or 1) + 1
	p.Wallet.Coins = 1e15
	for z = 1, zona or 1 do
		for _, r in ipairs(Rarity.Order) do
			local m = Mochila.mineralDe(z, r)
			if m then
				p.Minerals.Banked[m] = 100000
			end
		end
	end
	return p
end

return function(t)
	t.describe("Fabricar", function()
		t.it("receta del arma Rara de zona 1: 1,2 h de ingreso, 30 Poco común y 15 Raro", function()
			local r = Forja.receta(1, "Rare")
			t.equal(r.Coins, Economia.gearCost(1, "Rare"))
			t.near(r.Coins / Economia.income(1), 1.2, 0.001)
			t.deepEqual({ r.Minerals[1].Id, r.Minerals[1].Units, r.Minerals[2].Id, r.Minerals[2].Units }, { "CobreRosado", 30, "EstanoLunar", 15 })
		end)
		t.it("fabrica, cobra monedas y gasta primero del banco", function()
			local p = rico(1)
			p.Minerals.Banked.PizarraClara = 20
			p.Minerals.Carried.PizarraClara = 15
			local monedas = p.Wallet.Coins
			local item = Forja.fabricar(p, { Kind = "Weapon", Type = "Dagger", Zone = 1, Rarity = "Common" }, "a")
			t.ok(item)
			t.equal(p.Items.a.Type, "Dagger")
			t.equal(p.Wallet.Coins, monedas - Economia.gearCost(1, "Common"))
			t.equal(p.Minerals.Banked.PizarraClara, nil)
			t.equal(p.Minerals.Carried.PizarraClara, 5)
		end)
		t.it("picos con pasivas válidas y estadística de combate desde Épico", function()
			local p = rico(1)
			t.ok(Forja.fabricar(p, { Kind = "Pickaxe", Zone = 1, Rarity = "Rare", Passives = { "BladeEcho" } }, "a"))
			t.equal(select(2, Forja.fabricar(p, { Kind = "Pickaxe", Zone = 1, Rarity = "Rare", Passives = { "RunicSonar" } }, "b")), "pasivas")
			t.equal(select(2, Forja.fabricar(p, { Kind = "Pickaxe", Zone = 1, Rarity = "Epic", Passives = { "RunicSonar" } }, "c")), "estadistica")
			t.ok(Forja.fabricar(p, { Kind = "Pickaxe", Zone = 1, Rarity = "Epic", Passives = { "RunicSonar" }, CombatStat = "Defense" }, "d"))
			t.deepEqual(Forja.pasivasPorDefecto("Mythic"), { "RunicSonar", "BladeEcho" })
		end)
		t.it("rechazos: zona, tipo, Celestial, materiales, monedas, materiales de jefe e inventario", function()
			local p = rico(1)
			t.equal(select(2, Forja.comprobar(p, { Kind = "Weapon", Type = "Sword", Zone = 2, Rarity = "Common" })), "zona")
			t.equal(select(2, Forja.comprobar(p, { Kind = "Weapon", Type = "Bow", Zone = 1, Rarity = "Common" })), "tipo")
			t.equal(select(2, Forja.comprobar(p, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Celestial" })), "rareza")
			t.equal(select(2, Forja.comprobar(p, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Legendary" })), "jefe")
			local pobre = PlantillaPerfil.nuevo(0)
			t.equal(select(2, Forja.comprobar(pobre, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Common" })), "monedas")
			pobre.Wallet.Coins = 1e12
			t.equal(select(2, Forja.comprobar(pobre, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Common" })), "materiales")
			for i = 1, Economy.MaxItems do
				p.Items["x" .. i] = { Kind = "Weapon" }
			end
			t.equal(select(2, Forja.comprobar(p, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Common" })), "inventario")
		end)
	end)

	t.describe("Mejorar y reciclar", function()
		t.it("niveles 1 a 10, 3 ranuras y despertar: +50 % de potencia", function()
			local p = rico(1)
			Forja.fabricar(p, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Rare" }, "a")
			for _ = 1, 10 do
				t.ok(Forja.mejorar(p, "a", "Level"))
			end
			t.equal(select(2, Forja.mejorar(p, "a", "Level")), "maximo")
			for _ = 1, 3 do
				t.ok(Forja.mejorar(p, "a", "Slot"))
			end
			t.ok(Forja.mejorar(p, "a", "Awaken"))
			t.equal(select(2, Forja.mejorar(p, "a", "Awaken")), "maximo")
			t.near(Potencia.ofItem(p.Items.a), Potencia.itemPower(1, "Rare", 0.5))
		end)
		t.it("coste de nivel n: 0,05 x n x coste base; materiales de la zona del objeto", function()
			local c = Forja.costeMejora({ Zone = 1, Rarity = "Rare", Level = 4 }, "Level")
			t.equal(c.Coins, Economia.upgradeLevelCost(1, "Rare", 5))
			t.equal(c.Minerals[1].Id, "CobreRosado")
			c = Forja.costeMejora({ Zone = 1, Rarity = "Rare", Level = 5 }, "Level")
			t.equal(c.Minerals[1].Id, "EstanoLunar")
		end)
		t.it("reciclar devuelve el 30 % de los minerales al banco; nunca lo equipado", function()
			local p = rico(1)
			p.Minerals.Banked = {}
			p.Minerals.Banked.CobreRosado = 30
			p.Minerals.Banked.EstanoLunar = 15
			Forja.fabricar(p, { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Rare" }, "a")
			p.Equipped.Weapon = "a"
			t.equal(select(2, Forja.reciclar(p, "a")), "equipado")
			p.Equipped.Weapon = ""
			t.deepEqual(Forja.reciclar(p, "a"), { CobreRosado = 9, EstanoLunar = 4 })
			t.equal(p.Items.a, nil)
		end)
		t.it("Seguro de carga: 8 Poco común + 1 Raro por unidad", function()
			local p = rico(1)
			p.Minerals.Banked = { CobreRosado = 16, EstanoLunar = 2 }
			t.equal(Forja.fabricarSeguro(p, 2), 2)
			t.equal(p.Consumables.CargoInsurance, 2)
			t.equal(select(2, Forja.fabricarSeguro(p, 1)), "materiales")
		end)
	end)

	t.describe("Cajas", function()
		t.it("las probabilidades mostradas suman 100 y la Suerte sube las altas", function()
			for _, tipo in ipairs(Boxes.Purchasable) do
				local total = 0
				for _, v in pairs(Cajas.probabilidades(tipo, 0)) do
					total = total + v
				end
				t.near(total, 100, 1e-9, tipo)
			end
			t.ok(Cajas.probabilidades("Weapon", 1000).Legendary > Cajas.probabilidades("Weapon", 0).Legendary)
		end)
		t.it("caja de armas: un arma de la zona, contadores y registro", function()
			local p = rico(3)
			local premio = Cajas.abrir(p, "Weapon", 0, generador(3), contador(), 5)
			t.equal(premio.Kind, "Weapon")
			t.equal(p.Items[premio.Id].Zone, 3)
			t.equal(#p.Boxes.Log, 1)
			t.equal(p.Boxes.Opened.Weapon, 1)
			t.ok(p.Boxes.Pity.Weapon.A >= 0)
		end)
		t.it("caja de zona: pico, lote de minerales, materiales o Seguros", function()
			local p, vistos = rico(1), {}
			local rng, ids = generador(11), contador()
			for _ = 1, 300 do
				vistos[Cajas.abrir(p, "Zone", 0, rng, ids, 0).Kind] = true
			end
			t.ok(vistos.Pickaxe and vistos.Minerals and vistos.Insurance)
			t.ok(#p.Boxes.Log <= Boxes.LogSize)
		end)
		t.it("caja de mascotas da huevos; caja de Núcleos da Núcleos o maestría si se repite", function()
			local p = rico(1)
			local rng, ids = generador(5), contador()
			local huevo = Cajas.abrir(p, "Pet", 0, rng, ids, 0)
			t.equal(huevo.Kind, "Egg")
			t.ok(p.Eggs[huevo.Id].Species)
			local nucleos, repetidos = 0, 0
			for _ = 1, 200 do
				local r = Cajas.abrir(p, "Core", 0, rng, ids, 0)
				if r.Kind == "Core" then
					nucleos = nucleos + 1
				else
					repetidos = repetidos + 1
					t.equal(r.Units, 200)
				end
			end
			t.equal(nucleos, 5, "los 5 que no tenía (el Prismático ya era suyo)")
			t.ok(repetidos > 0)
		end)
		t.it("roadmap fase 5: 100.000 aperturas con Legendario+ en 4,449 % ± 0,2 y nunca más de 50 sin él", function()
			local p = rico(1)
			local rng, n, leg, racha, peor = generador(2026), 100000, 0, 0, 0
			local ids = function()
				return "x"
			end
			for _ = 1, n do
				p.Items = {}
				local r = Cajas.abrir(p, "Weapon", 0, rng, ids, 0)
				racha = racha + 1
				if Rarity.Multiplier[r.Rarity] >= Rarity.Multiplier.Legendary then
					leg = leg + 1
					peor = math.max(peor, racha)
					racha = 0
				end
			end
			t.near(100 * leg / n, 4.449, 0.2)
			t.ok(peor <= 50, tostring(peor))
		end)
		t.it("roadmap fase 5: horas hasta fabricar el arma Rara de la zona, 1,2 h de ingreso ± 25 %", function()
			-- Monedas: 1,2 h por construcción (B6). Materiales: 30 Poco común y 15 Raro al ritmo de la cantera
			-- (382 minerales/h, calculos/c3_mina_bloques.py), con la tabla de aparición de la zona 1.
			local pesos = Mineria.spawnWeights(1)
			local porHora = 382
			local horasMat = math.max(30 / (porHora * pesos.Uncommon / 100 * 4), 15 / (porHora * pesos.Rare / 100 * 3))
			local horasMonedas = Economia.gearCost(1, "Rare") / Economia.income(1)
			-- Mientras se juntan las monedas también se pica: cuenta la mayor de las dos.
			local horas = math.max(horasMonedas, horasMat)
			t.ok(horas >= 0.9 and horas <= 1.5, tostring(horas))
		end)
	end)
end
