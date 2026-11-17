-- Pruebas de la fase 8: Zona Fracturada (carga, saqueo, extracción, racha, protecciones, seguro, contratos),
-- arena (Elo) y medidas del roadmap (duración de duelo, ingresos de la grieta frente al PvE).

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Fracture = require(Shared.Config.Fracture)
local PvP = require(Shared.Config.PvP)
local Stats = require(Shared.Config.Stats)
local Weapons = require(Shared.Config.Weapons)
local Mineria = require(Shared.Formulas.Mineria)
local Potencia = require(Shared.Formulas.Potencia)
local Progresion = require(Shared.Formulas.Progresion)
local Dano = require(Shared.Formulas.Dano)
local Defensa = require(Shared.Formulas.Defensa)
local Mochila = require(Shared.Reglas.Mochila)
local Fractura = require(Shared.Reglas.Fractura)
local Arena = require(Shared.Reglas.Arena)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

local function perfil(entradas)
	local p = PlantillaPerfil.nuevo(0)
	p.Progress.Level = 250
	p.Progress.UnlockedZone = 3
	p.Fracture.Entries = entradas or 10
	return p
end

return function(t)
	t.describe("Carga y contenedor de grieta", function()
		t.it("la mochila de grieta es el doble", function()
			local p = perfil()
			t.equal(Fractura.capacidad(p), 2 * Mochila.capacidad(p))
			t.equal(Fractura.anadir(p, "SalGema", 1000), 2 * Mochila.capacidad(p))
		end)
		t.it("F17 con el valor de lo que se lleva", function()
			local p = perfil()
			p.Minerals.Fractured.SalGema = 100
			local esperado = Mineria.load(100 * Mochila.precioUnidad("SalGema"), 3)
			t.near(Fractura.carga(p, 3), esperado)
			t.near(Fractura.lentitud(Fractura.carga(p, 3)), Mineria.loadSlow(esperado))
		end)
	end)

	t.describe("Saqueo", function()
		local function cargado()
			local p = perfil()
			p.Minerals.Fractured = { SalGema = 60, PlataSalobre = 30, ZafiroDeMarea = 10 }
			return p
		end
		t.it("se suelta el 50 %, primero lo más valioso; el 80 % va al cofre y el 20 % se destruye", function()
			local p = cargado()
			local r = Fractura.muertePvP(p, 3, {})
			t.equal(r.Soltadas, 50)
			t.equal(p.Minerals.Fractured.ZafiroDeMarea, nil, "lo más valioso sale primero")
			local enCofre = 0
			for _, n in pairs(r.Cofre) do
				enCofre = enCofre + n
			end
			t.equal(enCofre + r.Destruidas, 50)
			t.ok(enCofre >= 39 and enCofre <= 40)
			t.equal(Fractura.unidades(p), 50)
		end)
		t.it("con Seguro de carga se suelta el 25 %", function()
			t.equal(Fractura.muertePvP(cargado(), 3, { Asegurado = true }).Soltadas, 25)
		end)
		t.it("novato (5 primeras entradas), carga menor que 1 y misma víctima: no se suelta nada", function()
			local p = cargado()
			p.Fracture.Entries = 5
			t.equal(Fractura.muertePvP(p, 3, {}).Soltadas, 0)
			local q = perfil()
			q.Minerals.Fractured = { SalGema = 1 }
			t.equal(Fractura.muertePvP(q, 3, {}).Soltadas, 0)
			t.equal(Fractura.muertePvP(cargado(), 3, { MismaVictima = true }).Soltadas, 0)
		end)
		t.it("recompensa por cabeza: el cofre lo recoge todo", function()
			local r = Fractura.muertePvP(cargado(), 3, { Recompensa = true })
			t.equal(r.Destruidas, 0)
		end)
		t.it("misma víctima en menos de 10 minutos", function()
			local reg = {}
			t.ok(not Fractura.mismaVictima(reg, 42, 0))
			t.ok(Fractura.mismaVictima(reg, 42, 599))
			t.ok(not Fractura.mismaVictima(reg, 42, 599 + 600))
		end)
		t.it("roadmap fase 8: al morir solo se pierde mineral (nunca equipo, mascotas, monedas ni nivel)", function()
			local p = cargado()
			p.Items.a = { Kind = "Weapon", Type = "Sword", Zone = 3, Rarity = "Epic", Level = 0, Slots = 0 }
			p.Pets.m = { Species = "TopilloDePizarra", Level = 5, XP = 0, Phase = "Hatchling" }
			p.Wallet.Coins = 12345
			p.Minerals.Banked.SalGema = 7
			local antes = { Items = p.Items.a, Pets = p.Pets.m, Coins = p.Wallet.Coins, Level = p.Progress.Level, Banco = p.Minerals.Banked.SalGema }
			Fractura.muertePvP(p, 3, {})
			Fractura.muertePvE(p)
			t.equal(p.Items.a, antes.Items)
			t.equal(p.Pets.m, antes.Pets)
			t.equal(p.Wallet.Coins, antes.Coins)
			t.equal(p.Progress.Level, antes.Level)
			t.equal(p.Minerals.Banked.SalGema, antes.Banco)
		end)
	end)

	t.describe("Extracción y racha", function()
		t.it("al extraer: al banco, bono en monedas de ×1,5 × racha y la racha sube", function()
			local p = perfil()
			p.Minerals.Fractured = { SalGema = 10 }
			local valor = 10 * Mochila.precioUnidad("SalGema")
			local r = Fractura.extraer(p)
			t.equal(r.Unidades, 10)
			t.near(r.Multiplicador, 1.5)
			t.near(r.Bono, math.floor(valor * 0.5 + 1e-6), 1)
			t.equal(p.Minerals.Banked.SalGema, 10)
			t.equal(p.Fracture.Streak, 1)
			p.Fracture.Streak = 5
			p.Minerals.Fractured = { SalGema = 10 }
			t.near(Fractura.extraer(p).Multiplicador, 2.25)
		end)
		t.it("salir sin extraer: al banco a ×1,0 y la racha no se rompe", function()
			local p = perfil()
			p.Fracture.Streak = 3
			p.Minerals.Fractured = { SalGema = 4 }
			t.equal(Fractura.salirSinExtraer(p), 4)
			t.equal(p.Fracture.Streak, 3)
			t.equal(p.Minerals.Banked.SalGema, 4)
		end)
	end)

	t.describe("Seguro y contratos", function()
		t.it("como mucho 5 seguros al día", function()
			local p = perfil()
			p.Consumables.CargoInsurance = 10
			for _ = 1, 5 do
				t.ok(Fractura.puedeAsegurar(p, 1))
				Fractura.asegurar(p)
			end
			t.ok(not Fractura.puedeAsegurar(p, 1))
			t.ok(Fractura.puedeAsegurar(p, 2), "al día siguiente")
		end)
		t.it("contratos: extraer Raros o mejores y derrotar portadores; uno se puede cambiar al día", function()
			local p = perfil()
			t.ok(Fractura.renovarContratos(p, 9))
			t.equal(#p.Quests.Contracts, 3)
			local hechos = Fractura.avanzarContratos(p, "Extraccion", { Rarezas = { Common = 50, Rare = 2, Epic = 1 } })
			t.equal(#hechos, 2)
			t.equal(#Fractura.avanzarContratos(p, "Portador", {}), 0)
			t.equal(#Fractura.avanzarContratos(p, "Portador", {}), 1)
			local q = perfil()
			Fractura.renovarContratos(q, 9)
			t.ok(Fractura.cambiarContrato(q, "DefeatCarriers"))
			t.equal(select(2, Fractura.cambiarContrato(q, "DefeatCarriers")), "cambiado")
		end)
	end)

	t.describe("Arena", function()
		t.it("tramos de 100 niveles y margen de Elo que crece", function()
			t.equal(Arena.tramo(100), 0)
			t.equal(Arena.tramo(101), 1)
			t.equal(Arena.nivelTramo(150), 200)
			t.equal(Arena.margen(0), 100)
			t.equal(Arena.margen(31), 200)
			t.ok(Arena.compatibles({ Nivel = 50, Elo = 1000, Desde = 0 }, { Nivel = 80, Elo = 1090, Desde = 0 }, 0))
			t.ok(not Arena.compatibles({ Nivel = 50, Elo = 1000, Desde = 0 }, { Nivel = 150, Elo = 1000, Desde = 0 }, 0))
		end)
		t.it("Elo con K = 32", function()
			local a, b = Arena.actualizar(1000, 1000, 1)
			t.equal(a, 1016)
			t.equal(b, 984)
		end)
	end)

	t.describe("Medidas del roadmap, fase 8", function()
		t.it("segundos de duelo entre builds equilibradas: 17,9 (aceptable 13,4–22,4)", function()
			-- B4 9.2: nivel 1.000, arma Legendaria de la zona 10 al máximo, 375 puntos en cada estadística.
			local potencia = Potencia.itemPower(10, "Legendary", 0.5)
			local critico = 1 + Weapons.Crit.Chance * (Weapons.Crit.Multiplier - 1)
			local dps = potencia * Progresion.curve(375, Stats.M.Strength) * Dano.masteryMultiplier(100) * critico * Stats.AbilityFactorRef
				* PvP.DamageMultiplier * (1 - Defensa.reduction(375, "PvP"))
			local vida = Progresion.maxHealth(1000, 375, PvP.VitalityM)
			local s = vida / dps
			t.ok(s >= 13.4 and s <= 22.4, tostring(s))
		end)
		t.it("ingresos de la grieta frente al PvE: 1,3–2,1 con 15–35 % de muertes y nunca más de 2,5", function()
			t.near(Fractura.ingresosRelativos(0.15), 1.92, 0.02)
			t.near(Fractura.ingresosRelativos(0.30), 1.58, 0.02)
			for _, p in ipairs({ 0.15, 0.25, 0.35 }) do
				local r = Fractura.ingresosRelativos(p)
				t.ok(r >= 1.3 and r <= 2.1, tostring(p) .. ": " .. tostring(r))
			end
			t.ok(Fractura.ingresosRelativos(0) <= 2.5)
		end)
	end)
end
