-- Pruebas de la fase 4: combo, estados, daño, dash, enfriamientos, control y Tenacidad, maestría, reparto,
-- habilidades en Z, X, C y V, y la medida del roadmap (segundos por enemigo Común).

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Weapons = require(Shared.Config.Weapons)
local Stats = require(Shared.Config.Stats)
local Dano = require(Shared.Formulas.Dano)
local Potencia = require(Shared.Formulas.Potencia)
local Progresion = require(Shared.Formulas.Progresion)
local Habilidades = require(Shared.Reglas.Habilidades)
local Inventario = require(Shared.Reglas.Inventario)
local Combate = require(Server.Reglas.Combate)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

local function fijo(v)
	return function()
		return v
	end
end

local function perfilConArma(tipo, maestriaArma, maestriaNucleo)
	local p = PlantillaPerfil.nuevo(0)
	p.Items.w = { Kind = "Weapon", Type = tipo, Zone = 1, Rarity = "Common", Level = 0, Slots = 0, Awakened = false }
	p.Equipped.Weapon = "w"
	p.WeaponMastery[tipo] = { Level = maestriaArma or 1, XP = 0 }
	p.Cores.Prismatic.Mastery = maestriaNucleo or 1
	return p
end

return function(t)
	t.describe("Combo y estados", function()
		t.it("golpes 1 a 4 al 100 % y después 90, 80, 70, 60 y 50 %", function()
			local esperado = { 1, 1, 1, 1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.5, 0.5 }
			for n, f in ipairs(esperado) do
				t.equal(Combate.factorCombo(n), f)
			end
		end)
		t.it("el combo se reinicia tras 2 s sin golpear a ese objetivo", function()
			local r = {}
			t.equal(Combate.contarGolpe(r, 1, 0), 1)
			t.equal(Combate.contarGolpe(r, 1, 1), 2)
			t.equal(Combate.contarGolpe(r, 2, 1), 1, "otro objetivo, otra cuenta")
			t.equal(Combate.contarGolpe(r, 1, 3.5), 1)
		end)
		t.it("los aumentos de daño recibido se suman hasta +40 %", function()
			local e = {}
			Combate.ponerEstado(e, "Refracted", 0, 6, { DanoRecibido = 0.10 })
			Combate.ponerEstado(e, "Vulnerable", 0, 3, { DanoRecibido = 0.15 })
			t.near(Combate.bonoEstados(e, 1), 0.25)
			t.near(Combate.bonoEstados(e, 4), 0.10, 1e-9, "Vulnerable ya terminó")
			Combate.ponerEstado(e, "A", 0, 9, { DanoRecibido = 0.5 })
			t.equal(Combate.bonoEstados(e, 1), 0.40)
			t.ok(Combate.tieneEstado(e, "Refracted", 5.9))
			t.ok(not Combate.tieneEstado(e, "Refracted", 6))
		end)
		t.it("la ralentización más fuerte manda", function()
			local e = {}
			Combate.ponerEstado(e, "L1", 0, 2, { Lento = 0.25 })
			Combate.ponerEstado(e, "L2", 0, 1, { Lento = 0.4 })
			t.equal(Combate.lentitud(e, 0.5), 0.4)
			t.equal(Combate.lentitud(e, 1.5), 0.25)
			t.equal(Combate.lentitud(e, 3), 0)
		end)
	end)

	t.describe("Daño", function()
		local base = { Potencia = 100, Coef = 0.625, Fuerza = 0, Maestria = 0, Golpe = 1 }
		t.it("golpe básico de Espada Común de zona 1: 62,5", function()
			local d, critico = Combate.danoPvE(base, 0, fijo(0.99))
			t.near(d, 62.5)
			t.ok(not critico)
		end)
		t.it("crítico ×1,5, secundario al 25 % y tutorial al doble", function()
			t.near((Combate.danoPvE(base, 0, fijo(0.01))), 62.5 * 1.5)
			local p = { Potencia = 100, Coef = 0.625, Fuerza = 0, Maestria = 0, Golpe = 1, Secundario = true }
			t.near((Combate.danoPvE(p, 0, fijo(0.99))), 62.5 * 0.25)
			p = { Potencia = 100, Coef = 0.625, Fuerza = 0, Maestria = 0, Golpe = 1, Tutorial = true }
			t.near((Combate.danoPvE(p, 0, fijo(0.99))), 125)
		end)
		t.it("el combo largo y los estados cambian el daño", function()
			local e = {}
			Combate.ponerEstado(e, "Refracted", 0, 6, { DanoRecibido = 0.10 })
			local p = { Potencia = 100, Coef = 1, Fuerza = 0, Maestria = 0, Golpe = 9, Estados = e }
			t.near((Combate.danoPvE(p, 1, fijo(0.99))), 100 * 0.5 * 1.1)
		end)
		t.it("daño recibido: defensa y bloqueo frontal (−70 %)", function()
			t.near(Combate.danoRecibido(100, 0.4, false, true), 60)
			t.near(Combate.danoRecibido(100, 0, true, true), 30)
			t.near(Combate.danoRecibido(100, 0, true, false), 100, 1e-9, "por la espalda no se bloquea")
		end)
	end)

	t.describe("Dash", function()
		t.it("2 cargas, cada una tarda 3 s en volver", function()
			local d = Combate.nuevoDash()
			t.ok(Combate.usarDash(d, 0))
			t.ok(Combate.usarDash(d, 0.5))
			t.ok(not Combate.usarDash(d, 1))
			t.equal(Combate.cargasDash(d, 2.9), 0)
			t.equal(Combate.cargasDash(d, 3), 1)
			t.equal(Combate.cargasDash(d, 6), 2)
			t.equal(Combate.cargasDash(d, 60), 2)
		end)
		t.it("esquiva perfecta: el golpe llega en los 0,25 s siguientes al dash", function()
			local d = Combate.nuevoDash()
			Combate.usarDash(d, 10)
			t.ok(Combate.esquivaPerfecta(d, 10.2))
			t.ok(not Combate.esquivaPerfecta(d, 10.3))
			t.ok(not Combate.esquivaPerfecta(d, 9.9))
		end)
	end)

	t.describe("Control y Tenacidad", function()
		t.it("el primero entero, el segundo al 50 %, el tercero no entra y deja 5 s de inmunidad", function()
			local c = Combate.nuevoControl()
			t.near(Combate.aplicarControl(c, 0, 1.5), 1.5)
			t.near(Combate.aplicarControl(c, 2, 1.5), 0.75)
			t.equal(Combate.aplicarControl(c, 3, 1.5), 0)
			t.equal(Combate.aplicarControl(c, 2.75 + 4.9, 1.5), 0, "Tenacidad: 5 s tras el segundo")
			t.ok(Combate.aplicarControl(c, 2.75 + 5.1 + 6, 1.5) > 0)
		end)
		t.it("nadie queda controlado más de 2,5 s seguidos", function()
			local c = Combate.nuevoControl()
			Combate.aplicarControl(c, 0, 2.0)
			Combate.aplicarControl(c, 1.5, 3.0)
			t.ok(c.ControladoHasta - c.ControladoDesde <= Weapons.Control.StunCap + 1e-9)
		end)
		t.it("Ruptura: solo tras 0,8 s bajo control", function()
			local c = Combate.nuevoControl()
			Combate.aplicarControl(c, 0, 2)
			t.ok(not Combate.puedeRuptura(c, 0.5))
			t.ok(Combate.puedeRuptura(c, 0.8))
			Combate.liberar(c, 0.9)
			t.ok(not Combate.controlado(c, 0.95))
		end)
	end)

	t.describe("Maestría y reparto", function()
		t.it("XP de maestría de B4: 13 puntos del nivel 1 al 2", function()
			local r = { Level = 1, XP = 0 }
			t.equal(Combate.sumarMaestria(r, 12), 0)
			t.equal(Combate.sumarMaestria(r, 1), 1)
			t.equal(r.Level, 2)
			r = { Level = 1, XP = 0 }
			t.equal(Combate.sumarMaestria(r, 196), 9, "196 puntos llevan al nivel 10")
			t.equal(r.Level, 10)
		end)
		t.it("reparto proporcional; maestría entera con el 10 % del daño", function()
			local r = Combate.reparto({ [1] = 700, [2] = 250, [3] = 50 }, 100, 1000, 4)
			t.near(r[1].XP, 70)
			t.equal(r[2].Coins, 250)
			t.equal(r[2].Mastery, 4)
			t.equal(r[3].Mastery, 0)
		end)
	end)

	t.describe("Habilidades en Z, X, C y V", function()
		t.it("Núcleo Prismático: Z con maestría 1, X con 10, C con 25, V con 50", function()
			local p = perfilConArma("Sword", 1, 25)
			local d = {}
			for _, h in ipairs(Habilidades.disponibles(p)) do
				d[h.Id] = h.Desbloqueada
			end
			t.ok(d.PrismaticLance and d.RefractionField and d.LightningStep)
			t.equal(d.TotalPrism, false)
			t.equal(d.SpinningSlash, false, "técnica 1 con maestría de arma 10")
			t.equal(d.Riposte, false)
		end)
		t.it("reparto inicial con lo desbloqueado", function()
			t.deepEqual(Habilidades.repartoInicial(perfilConArma("Sword", 1, 1)), { Z = "PrismaticLance", X = "", C = "", V = "" })
		end)
		t.it("mezclar Núcleo y arma; V solo admite la definitiva o la segunda técnica", function()
			local p = perfilConArma("Sword", 50, 50)
			t.ok(Habilidades.validarReparto(p, { Z = "PrismaticLance", X = "SpinningSlash", C = "LightningStep", V = "Riposte" }))
			t.ok(Habilidades.validarReparto(p, { Z = "SpinningSlash", X = "", C = "", V = "TotalPrism" }))
			t.equal(select(2, Habilidades.validarReparto(p, { Z = "TotalPrism", X = "", C = "", V = "" })), "ranura")
			t.equal(select(2, Habilidades.validarReparto(p, { Z = "", X = "", C = "", V = "SpinningSlash" })), "ranura")
			t.equal(select(2, Habilidades.validarReparto(p, { Z = "PrismaticLance", X = "PrismaticLance", C = "", V = "" })), "repetida")
			t.equal(select(2, Habilidades.validarReparto(p, { Z = "ChargedOrb", X = "", C = "", V = "" })), "habilidad", "técnica de otra arma")
			local q = perfilConArma("Sword", 1, 1)
			t.equal(select(2, Habilidades.validarReparto(q, { Z = "", X = "RefractionField", C = "", V = "" })), "bloqueada")
		end)
		t.it("al cambiar de arma se quitan sus técnicas del reparto", function()
			local p = perfilConArma("Sword", 50, 50)
			p.Equipped.Loadout = { Z = "SpinningSlash", X = "RefractionField", C = "", V = "Riposte" }
			p.Items.d = { Kind = "Weapon", Type = "Dagger", Zone = 1, Rarity = "Common", Level = 0, Slots = 0 }
			p.Equipped.Weapon = "d"
			t.ok(Habilidades.limpiarReparto(p))
			t.deepEqual(p.Equipped.Loadout, { Z = "", X = "RefractionField", C = "", V = "" })
		end)
		t.it("el arma inicial es una Espada Común de zona 1", function()
			local s = Weapons.Starter
			t.equal(s.Type, "Sword")
			t.ok(table.find(Weapons.EnabledTypes, s.Type))
			t.equal(Inventario.nombreBase(Inventario.crearArma("Sword", 1, "Common")), "Espada de Pizarra")
		end)
	end)

	t.describe("Medida del roadmap, fase 4", function()
		t.it("segundos por enemigo Común: 6,3 (aceptable 4,7–7,9)", function()
			-- Combatiente de referencia de B4 (7.3): nivel 50, 12,5 % en Fuerza, arma Rara con +12,5 % de mejoras,
			-- crítico medio y factor de habilidades de referencia (×1,39).
			local fuerza = math.floor(Progresion.statPoints(50) * 0.125)
			local potencia = Potencia.itemPower(1, "Rare", 0.125)
			local critico = 1 + Weapons.Crit.Chance * (Weapons.Crit.Multiplier - 1)
			local dps = potencia * Progresion.curve(fuerza, Stats.M.Strength) * critico * Stats.AbilityFactorRef
			local s = Dano.enemyHealth(1, "Common") / dps
			t.ok(s >= 4.7 and s <= 7.9, tostring(s))
			t.near(s, 6.3, 0.1)
		end)
	end)
end
