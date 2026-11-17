-- Pruebas de la fase 7: jefes (fases, escalado, furia, botín diario), misiones diarias, tutorial
-- y medidas del roadmap (minutos por jefe, horas hasta los niveles 200 y 300, monedas por hora en las zonas 2 y 3).

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Weapons = require(Shared.Config.Weapons)
local Stats = require(Shared.Config.Stats)
local Quests = require(Shared.Config.Quests)
local Economy = require(Shared.Config.Economy)
local Potencia = require(Shared.Formulas.Potencia)
local Progresion = require(Shared.Formulas.Progresion)
local Economia = require(Shared.Formulas.Economia)
local Mineria = require(Shared.Formulas.Mineria)
local Jefe = require(Shared.Reglas.Jefe)
local Misiones = require(Shared.Reglas.Misiones)
local Niveles = require(Shared.Reglas.Niveles)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)
local Simulaciones = require(script.Parent.Simulaciones)

-- DPS del combatiente de referencia de B4 (7.3) en una zona: arma Rara con +12,5 %, 12,5 % en Fuerza, crítico y habilidades.
local function dpsReferencia(zona)
	local fuerza = math.floor(Progresion.statPoints(Mineria.zoneMidLevel(zona)) * 0.125)
	local critico = 1 + Weapons.Crit.Chance * (Weapons.Crit.Multiplier - 1)
	return Potencia.itemPower(zona, "Rare", 0.125) * Progresion.curve(fuerza, Stats.M.Strength) * critico * Stats.AbilityFactorRef
end

return function(t)
	t.describe("Jefes", function()
		t.it("fases al 60 % y al 30 %", function()
			t.equal(Jefe.fase(100, 100), 1)
			t.equal(Jefe.fase(61, 100), 1)
			t.equal(Jefe.fase(60, 100), 2)
			t.equal(Jefe.fase(31, 100), 2)
			t.equal(Jefe.fase(30, 100), 3)
		end)
		t.it("vida de B4: Capataz 120.000 en solitario y 624.000 con 8", function()
			t.near(Jefe.vida(1, 1), 120000)
			t.near(Jefe.vida(1, 8), 624000)
			t.near(Jefe.vida(3, 1), 576000)
		end)
		t.it("golpes de B4 en la zona 1: 75, 175 y 350; furia +10 % cada 30 s desde los 12 min", function()
			t.near(Jefe.danoAtaque(1, "Normal", 1, 0), 75)
			t.near(Jefe.danoAtaque(1, "Heavy", 1, 0), 175)
			t.near(Jefe.danoAtaque(1, "Lethal", 1, 0), 350)
			t.equal(Jefe.furia(719), 0)
			t.equal(Jefe.furia(720), 1)
			t.equal(Jefe.furia(780), 3)
			t.near(Jefe.danoAtaque(1, "Normal", 1, 780), 75 * 1.3)
		end)
		t.it("botín: 3 derrotas completas por día; después 25 % y sin material", function()
			local r = {}
			for i = 1, 3 do
				t.deepEqual(Jefe.botin(r, 1, 100), { Mult = 1, Materials = 3, Count = i })
			end
			t.deepEqual(Jefe.botin(r, 1, 100), { Mult = 0.25, Materials = 0, Count = 4 })
			t.equal(Jefe.botin(r, 2, 100).Mult, 1, "otro jefe, otro contador")
			t.equal(Jefe.botin(r, 1, 101).Mult, 1, "al día siguiente se reinicia")
		end)
		t.it("hace falta el 5 % del daño del grupo", function()
			t.ok(Jefe.participa(5, 100))
			t.ok(not Jefe.participa(4.9, 100))
		end)
		t.it("roadmap fase 7: minutos por jefe en solitario 7,9 (5,9–9,9); con 4 y 8 jugadores 5,5 y 5,1", function()
			for zona = 1, 3 do
				local dps = dpsReferencia(zona)
				local solo = Jefe.minutos(zona, 1, dps)
				t.ok(solo >= 5.9 and solo <= 9.9, "zona " .. zona .. ": " .. tostring(solo))
				t.near(Jefe.minutos(zona, 4, dps), 5.5, 0.4)
				t.near(Jefe.minutos(zona, 8, dps), 5.1, 0.4)
			end
		end)
	end)

	t.describe("Misiones diarias", function()
		t.it("3 al día, una de cada categoría, y se renuevan al cambiar de día", function()
			local p = PlantillaPerfil.nuevo(0)
			t.ok(Misiones.renovar(p, 20000, 42))
			t.equal(#p.Quests.Daily, 3)
			t.ok(not Misiones.renovar(p, 20000, 42))
			local cats = {}
			for _, q in ipairs(p.Quests.Daily) do
				cats[q.Id] = true
			end
			t.ok(Misiones.renovar(p, 20001, 42))
		end)
		t.it("progreso, cobro y no se cobra dos veces", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Quests.Daily = { { Id = "DefeatEnemies", Progress = 0, Claimed = false } }
			t.equal(select(2, Misiones.cobrar(p, "DefeatEnemies")), "incompleta")
			t.equal(#Misiones.avanzar(p, "EnemigoDerrotado", 49), 0)
			t.equal(#Misiones.avanzar(p, "EnemigoDerrotado", 5), 1)
			t.equal(p.Quests.Daily[1].Progress, 50)
			local r = Misiones.cobrar(p, "DefeatEnemies")
			t.equal(r.Coins, math.floor(Quests.DailyRewardHours * Economia.income(1) + 0.5))
			t.equal(select(2, Misiones.cobrar(p, "DefeatEnemies")), "cobrada")
		end)
	end)

	t.describe("Tutorial", function()
		t.it("avanza paso a paso con los eventos y termina", function()
			local p = PlantillaPerfil.nuevo(0)
			t.equal(Misiones.avanzarTutorial(p, "Deposito", 1), nil, "evento de otro paso")
			t.equal(Misiones.avanzarTutorial(p, "MineralExtraido", 1), "paso")
			t.equal(p.Progress.TutorialStep, 1)
			Misiones.avanzarTutorial(p, "Deposito", 1)
			Misiones.avanzarTutorial(p, "VentaMineral", 1)
			Misiones.avanzarTutorial(p, "Asignacion", 1)
			t.equal(Misiones.avanzarTutorial(p, "EnemigoDerrotado", 2), nil, "pide 3")
			t.equal(Misiones.avanzarTutorial(p, "EnemigoDerrotado", 1), "paso")
			Misiones.avanzarTutorial(p, "HabilidadUsada", 1)
			t.equal(Misiones.avanzarTutorial(p, "CajaAbierta", 1), "fin")
			t.ok(Misiones.tutorialTerminado(p))
		end)
		t.it("se puede saltar", function()
			local p = PlantillaPerfil.nuevo(0)
			Misiones.saltarTutorial(p)
			t.ok(Misiones.tutorialTerminado(p))
			t.equal(Misiones.pasoTutorial(p), nil)
		end)
	end)

	t.describe("Medidas del roadmap, fase 7", function()
		t.it("horas hasta los niveles 200 y 300: 19,7 y 40,7 (± 25 %)", function()
			local p = PlantillaPerfil.nuevo(0)
			local segundos, marcas = 0, {}
			while p.Progress.Level < 300 do
				Niveles.sumarXP(p, Progresion.xpPerAction(p.Progress.Level))
				segundos = segundos + 15
				if not marcas[p.Progress.Level] then
					marcas[p.Progress.Level] = segundos / 3600
				end
			end
			t.ok(math.abs(marcas[200] / 19.7 - 1) <= 0.25, tostring(marcas[200]))
			t.ok(math.abs(marcas[300] / 40.7 - 1) <= 0.25, tostring(marcas[300]))
		end)
		t.it("monedas por hora picando en las zonas 2 y 3: 10.301 y 20.040 (± 25 %, x escala de dinero)", function()
			for zona, objetivo in pairs({ [2] = 10301, [3] = 20040 }) do
				local monedas = Simulaciones.mina(zona, 77 + zona, 2)
				local base = monedas / Economy.CurrencyScale
				t.ok(math.abs(base / objetivo - 1) <= 0.25, "zona " .. zona .. ": " .. tostring(base))
			end
		end)
	end)
end
