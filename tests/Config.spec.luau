-- Pruebas de coherencia de Shared/Config: lo que debe cumplirse siempre aunque se ajusten cifras.

local Config = game:GetService("ReplicatedStorage").Shared.Config
local Rarity = require(Config.Rarity)
local Mining = require(Config.Mining)
local Boxes = require(Config.Boxes)
local Weapons = require(Config.Weapons)
local Pets = require(Config.Pets)
local Fracture = require(Config.Fracture)
local Pickaxes = require(Config.Pickaxes)
local PowerCores = require(Config.PowerCores)
local Economy = require(Config.Economy)
local Worlds = require(Config.Worlds)
local Stats = require(Config.Stats)

local MODULOS = { "Stats", "Rarity", "Mining", "Pickaxes", "Weapons", "PowerCores", "Pets", "Economy", "Boxes", "Fracture", "Worlds", "PvP", "VFX" }

local function suma(t)
	local total = 0
	for _, v in pairs(t) do
		total = total + v
	end
	return total
end

local function esRareza(nombre)
	return table.find(Rarity.Order, nombre) ~= nil
end

return function(t)
	t.it("los 13 módulos cargan y solo contienen datos", function()
		local function sinFunciones(valor, ruta)
			t.ok(type(valor) ~= "function", ruta .. " es una función")
			if type(valor) == "table" then
				for k, v in pairs(valor) do
					sinFunciones(v, ruta .. "." .. tostring(k))
				end
			end
		end
		for _, nombre in ipairs(MODULOS) do
			local modulo = require(Config[nombre])
			t.equal(type(modulo), "table", nombre)
			sinFunciones(modulo, nombre)
		end
	end)

	t.describe("Rarezas", function()
		t.it("8 rarezas con multiplicador creciente", function()
			t.equal(#Rarity.Order, 8)
			for i = 2, #Rarity.Order do
				t.ok(Rarity.Multiplier[Rarity.Order[i]] > Rarity.Multiplier[Rarity.Order[i - 1]])
			end
		end)
		t.it("los bonos parciales suman el tope", function()
			local p = Rarity.Power
			t.near(p.LevelBonusMax + p.UpgradeBonusMax + p.AbilityBonusMax, p.BonusCap)
		end)
	end)

	t.describe("Tablas de probabilidad: suman exactamente 100", function()
		t.it("caja estándar, depósitos y caja de evento", function()
			t.near(suma(Boxes.StandardWeights), 100, 1e-9)
			t.near(suma(Mining.SpawnWeights.WithUltraRare), 100, 1e-9)
			t.near(suma(Mining.SpawnWeights.WithoutUltraRare), 100, 1e-9)
			t.near(suma(Boxes.Boxes.Event.Weights), 100, 1e-9)
			t.near(suma(Boxes.Boxes.Core.Weights), 100, 1e-9)
			t.near(suma(Boxes.Boxes.Weapon.TypeWeights), 100, 1e-9)
			t.near(suma(Boxes.Boxes.Zone.CategoryWeights), 100, 1e-9)
			t.near(suma(Weapons.Enemies.PackWeights), 100, 1e-9)
		end)
		t.it("Celestial nunca sale de cajas estándar ni de depósitos", function()
			t.equal(Boxes.StandardWeights.Celestial, nil)
			t.equal(Mining.SpawnWeights.WithUltraRare.Celestial, nil)
			t.equal(Mining.SpawnWeights.WithoutUltraRare.Celestial, nil)
		end)
		t.it("todas las claves de rareza existen", function()
			for _, tabla in ipairs({ Boxes.StandardWeights, Mining.SpawnWeights.WithUltraRare, Boxes.Boxes.Event.Weights,
				Mining.Deposit.HealthFactor, Mining.Deposit.Units, Pickaxes.HitsPerSecond, Economy.GearCostHours, Pets.Hatch.PickHits }) do
				for clave in pairs(tabla) do
					t.ok(esRareza(clave), tostring(clave))
				end
			end
		end)
	end)

	t.describe("Minería", function()
		t.it("66 minerales con zona y rareza válidas, y Ultra raro solo donde toca", function()
			local n = 0
			for id, m in pairs(Mining.Minerals) do
				n = n + 1
				t.ok(m.Zone >= 1 and m.Zone <= 10, id)
				t.ok(esRareza(m.Rarity), id)
				if m.Rarity == "UltraRare" then
					t.ok(table.find(Mining.ZonesWithUltraRare, m.Zone), id)
				end
			end
			t.equal(n, 66)
		end)
		t.it("10 zonas en 4 mundos, sin repetir", function()
			t.equal(#Worlds.Zones, 10)
			local vistas = {}
			for _, mundo in ipairs(Worlds.Worlds) do
				for _, z in ipairs(mundo.Zones) do
					t.equal(vistas[z], nil)
					vistas[z] = true
					t.equal(Worlds.Zones[z].Id, z)
				end
			end
			for z = 1, 10 do
				t.ok(vistas[z], "zona " .. z)
			end
		end)
	end)

	t.describe("Decisiones fijas", function()
		t.it("tope conjunto de mascotas: 40 % en PvE y 25 % en PvP", function()
			t.equal(Pets.DPSCap.PvE, 0.40)
			t.equal(Pets.DPSCap.PvP, 0.25)
		end)
		t.it("al morir en PvP se suelta el 50 % de la carga", function()
			t.equal(Fracture.PvPDeath.DropFraction, 0.50)
			t.near(Fracture.PvPDeath.DropFraction * (1 - Fracture.Insurance.ProtectedFraction), 0.25)
		end)
		t.it("la Zona Fracturada rinde como mucho 2,5 veces el PvE", function()
			local racha = Fracture.Streak.Steps[#Fracture.Streak.Steps]
			t.ok(Fracture.ValueMultiplier * racha <= 2.5)
		end)
		t.it("4 ranuras Z, X, C y V", function()
			local n = 0
			for _ in pairs(PowerCores.SlotTypes) do
				n = n + 1
			end
			t.equal(n, 4)
			for _, nucleo in pairs(PowerCores.Cores) do
				for _, ranura in ipairs({ "Z", "X", "C", "V" }) do
					t.ok(nucleo.Abilities[ranura].Coef > 0)
				end
			end
			t.ok(PowerCores.Cores[PowerCores.Starter])
		end)
		t.it("el Seguro de carga se fabrica, no se vende", function()
			t.equal(Fracture.Insurance.Craftable, true)
			t.equal(Economy.Consumable.CargoInsurance, nil)
		end)
		t.it("6 tipos de arma con 2 técnicas cada uno", function()
			local n = 0
			for tipo in pairs(Weapons.Types) do
				n = n + 1
				t.equal(#Weapons.Techniques[tipo], 2, tipo)
			end
			t.equal(n, 6)
		end)
		t.it("12 mascotas de lanzamiento con rol y rareza válidos, ninguna Celestial", function()
			local n = 0
			for id, e in pairs(Pets.Species) do
				n = n + 1
				t.ok(Pets.Role[e.Role], id)
				t.ok(esRareza(e.Rarity) and e.Rarity ~= "Celestial", id)
			end
			t.equal(n, 12)
		end)
		t.it("puntos de estadística: 8 estadísticas con tope de 1.000", function()
			t.equal(Stats.Points.CapPerStat, 1000)
			t.equal(#Economy.ZoneIncome, 10)
		end)
	end)
end
