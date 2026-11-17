-- Pruebas de la fase 6: incubación, mascotas, espacios, Nido, XP, liberar, evolución, bonos de recolección,
-- tope de daño con ventana de 5 s y medidas del roadmap.

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Pets = require(Shared.Config.Pets)
local Weapons = require(Shared.Config.Weapons)
local Mascotas = require(Shared.Formulas.Mascotas)
local Economia = require(Shared.Formulas.Economia)
local Criadero = require(Shared.Reglas.Criadero)
local TopeMascotas = require(Server.Reglas.TopeMascotas)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

local function perfil(nivel)
	local p = PlantillaPerfil.nuevo(0)
	p.Progress.Level = nivel or 1
	return p
end

local function conMascota(p, id, especie, nivel, fase)
	p.Pets[id] = { Species = especie, Level = nivel or 1, XP = 0, Phase = fase or "Hatchling" }
	return p.Pets[id]
end

return function(t)
	t.describe("Incubación", function()
		t.it("un huevo Común necesita 500 golpes de pico", function()
			local p = perfil(1)
			p.Eggs.h = { Species = "TopilloDePizarra" }
			t.ok(Criadero.incubar(p, "h", 1))
			t.equal(p.Eggs.h, nil)
			t.equal(select(2, Criadero.incubar(p, "h", 1)), "huevo")
			Criadero.sumarGolpes(p, 499)
			t.equal(select(2, Criadero.eclosionar(p, 1, "m")), "no_lista")
			Criadero.sumarGolpes(p, 50)
			local m = Criadero.eclosionar(p, 1, "m")
			t.deepEqual(m, { Species = "TopilloDePizarra", Level = 1, XP = 0, Phase = "Hatchling" })
			t.equal(p.Incubators[1].Egg, "")
		end)
		t.it("la segunda incubadora llega a nivel 200", function()
			local p = perfil(199)
			t.ok(not Criadero.asegurarIncubadoras(p))
			p.Progress.Level = 200
			t.ok(Criadero.asegurarIncubadoras(p))
			t.equal(#p.Incubators, 2)
		end)
		t.it("una incubadora ocupada no admite otro huevo", function()
			local p = perfil(1)
			p.Eggs.a = { Species = "TopilloDePizarra" }
			p.Eggs.b = { Species = "ZorroDeAscua" }
			Criadero.incubar(p, "a", 1)
			t.equal(select(2, Criadero.incubar(p, "b", 1)), "ocupada")
			t.equal(select(2, Criadero.incubar(p, "b", 2)), "incubadora")
		end)
	end)

	t.describe("Espacios, Nido y liberar", function()
		t.it("3 espacios; el 4.º a nivel 300 y el 5.º a 700", function()
			t.equal(Criadero.espacios(perfil(1)), 3)
			t.equal(Criadero.espacios(perfil(300)), 4)
			t.equal(Criadero.espacios(perfil(700)), 5)
		end)
		t.it("equipar mueve la mascota de hueco y respeta los espacios", function()
			local p = perfil(1)
			conMascota(p, "a", "TopilloDePizarra")
			t.ok(Criadero.equipar(p, "a", 1))
			t.ok(Criadero.equipar(p, "a", 3))
			t.deepEqual(p.Equipped.Pets, { "", "", "a" })
			t.equal(select(2, Criadero.equipar(p, "a", 4)), "hueco")
			t.ok(Criadero.equipar(p, "", 3))
			t.equal(#Criadero.equipadas(p), 0)
		end)
		t.it("Nido solo para no equipadas; liberar solo lo que no está en uso", function()
			local p = perfil(1)
			conMascota(p, "a", "TopilloDePizarra")
			conMascota(p, "b", "MantisVitral")
			Criadero.equipar(p, "a", 1)
			t.equal(select(2, Criadero.alNido(p, "a", 1)), "equipada")
			t.ok(Criadero.alNido(p, "b", 1))
			t.equal(select(2, Criadero.liberar(p, { "b" })), "en_uso")
			Criadero.alNido(p, "", 1)
			t.deepEqual(Criadero.liberar(p, { "b" }), { Light = 16 })
			t.equal(p.Materials.Element.Light, 16)
		end)
	end)

	t.describe("Nivel y evolución", function()
		t.it("XP de mascota de B5: 19 del nivel 1 al 2; 8.073 hasta el 50", function()
			local m = { Species = "TopilloDePizarra", Level = 1, XP = 0, Phase = "Hatchling" }
			t.equal(Criadero.sumarXP(m, 18), 0)
			t.equal(Criadero.sumarXP(m, 1), 1)
			m = { Species = "TopilloDePizarra", Level = 1, XP = 0, Phase = "Hatchling" }
			Criadero.sumarXP(m, 8073)
			t.equal(m.Level, 50)
			Criadero.sumarXP(m, 1e9)
			t.equal(m.Level, 100)
		end)
		t.it("evolucionar: nivel 50, fragmentos de su elemento y 2 h de ingreso", function()
			local p = perfil(60)
			local m = conMascota(p, "g", "GuivernoDeCuarzo", 49)
			t.equal(select(2, Criadero.costeEvolucion(p, "g")), "nivel")
			m.Level = 50
			local c = Criadero.costeEvolucion(p, "g")
			t.deepEqual({ c.Siguiente, c.Element, c.Fragments }, { "Unleashed", "Crystal", 60 })
			t.equal(c.Coins, math.floor(2 * Economia.income(1) + 0.5))
			p.Wallet.Coins = 1e15
			t.equal(select(2, Criadero.puedeEvolucionar(p, c)), "fragmentos")
			p.Materials.Element.Crystal = 60
			t.ok(Criadero.puedeEvolucionar(p, c))
			Criadero.evolucionar(p, "g", c)
			t.equal(m.Phase, "Unleashed")
			t.equal(p.Materials.Element.Crystal, 0)
			m.Level = 100
			t.equal(select(2, Criadero.puedeEvolucionar(p, Criadero.costeEvolucion(p, "g"))), "jefe")
		end)
	end)

	t.describe("Bonos de recolección", function()
		t.it("se suman con sus topes", function()
			local p = perfil(1)
			conMascota(p, "a", "GuivernoDeCuarzo")
			conMascota(p, "b", "NutriaSalina")
			conMascota(p, "c", "TopilloDePizarra")
			Criadero.equipar(p, "a", 1)
			Criadero.equipar(p, "b", 2)
			Criadero.equipar(p, "c", 3)
			t.near(Criadero.bonos(p).ExtractSpeed, 0.15 + 0.08 + 0.05)
			p.Pets.d = { Species = "TortugaGeoda", Level = 1, XP = 0, Phase = "Hatchling" }
			Criadero.equipar(p, "d", 3)
			t.equal(Criadero.bonos(p, 90).BackpackUnits, 6)
			t.equal(Criadero.bonos(p, 10).BackpackUnits, 3, "tope del 30 % de la mochila")
		end)
	end)

	t.describe("Tope de daño de mascotas (F31)", function()
		t.it("nunca más del 40 % del DPS de referencia en una ventana de 5 s", function()
			local ref = Mascotas.dpsRef(1000, 0, 0)
			local e = TopeMascotas.nuevo()
			local total, peor = 0, 0
			local golpes = {}
			for paso = 0, 1200 do   -- 120 s a pasos de 0,1 s; ráfagas enormes cada 2 s
				local ahora = paso / 10
				local intento = (paso % 20 == 0) and ref * 50 or ref * 0.3
				local aplicado = TopeMascotas.permitir(e, ahora, intento, ref, "PvE")
				total = total + aplicado
				table.insert(golpes, { ahora, aplicado })
			end
			for i = 1, #golpes do
				local suma = 0
				for j = i, #golpes do
					if golpes[j][1] - golpes[i][1] >= 5 then
						break
					end
					suma = suma + golpes[j][2]
				end
				peor = math.max(peor, suma)
			end
			t.ok(peor <= 0.40 * ref * 5 + 1e-6, tostring(peor / (ref * 5)))
			t.ok(total <= 0.40 * ref * 5 * 25 + 1e-6, "120,1 s abarcan como mucho 25 ventanas de 5 s")
		end)
		t.it("en PvP el tope es del 25 %", function()
			local e = TopeMascotas.nuevo()
			t.near(TopeMascotas.permitir(e, 0, 1e9, 100, "PvP"), 0.25 * 100 * 5)
			t.equal(TopeMascotas.permitir(e, 1, 10, 100, "PvP"), 0)
			t.equal(TopeMascotas.permitir(e, 5.01, 10, 100, "PvP"), 10, "la ventana se vacía a los 5 s")
		end)
		t.it("roadmap fase 6: Prismático + Guiverno, los Haces de Cuarzo cuentan para el tope", function()
			-- 3 mascotas de nivel 100 en forma máxima, Guiverno disparando Haces cada 2 s a objetivos Refractados.
			local ref = Mascotas.dpsRef(1000, 1000, 100)
			local guiverno = { Role = "Defense", Rarity = "Legendary", Level = 100, Phase = "UnleashedMax" }
			local mantis = { Role = "Offense", Rarity = "Legendary", Level = 100, Phase = "UnleashedMax" }
			local dpsTotal = Mascotas.dps(1000, guiverno, 1000, "Protect") + 2 * Mascotas.dps(1000, mantis, 1000, "Protect")
			local factor = Mascotas.capFactor(dpsTotal, ref, "PvE")
			local e, golpes = TopeMascotas.nuevo(), {}
			for paso = 0, 600 do
				local ahora = paso / 10
				local intento = dpsTotal * factor * 0.1
				if paso % 20 == 0 then
					intento = intento + Mascotas.dps(1000, guiverno, 1000, "Protect") * Pets.Abilities.QuartzBeam.Coef * 5
				end
				table.insert(golpes, { ahora, TopeMascotas.permitir(e, ahora, intento, ref, "PvE") })
			end
			for i = 1, #golpes do
				local suma = 0
				for j = i, #golpes do
					if golpes[j][1] - golpes[i][1] >= 5 then
						break
					end
					suma = suma + golpes[j][2]
				end
				t.ok(suma <= 0.40 * ref * 5 + 1e-6)
			end
		end)
		t.it("roadmap fase 6: horas hasta mascota de nivel 50, unas 11", function()
			-- Combatiente de referencia de B4: 241 enemigos por hora con la mezcla 88/10/2.
			local x = Pets.XPSource.Enemy
			local porHora = 241 * (Weapons.Enemies.Common.Share * x.Common + Weapons.Enemies.Elite.Share * x.Elite + Weapons.Enemies.Guardian.Share * x.Guardian)
			local necesaria = 0
			for n = 1, 49 do
				necesaria = necesaria + Mascotas.levelXP(n)
			end
			local horas = necesaria / porHora
			t.ok(horas >= 9.5 and horas <= 12.5, tostring(horas))
		end)
	end)
end
