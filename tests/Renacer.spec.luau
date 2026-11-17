-- Renacimiento (A_GDD; Config/Economy.Rebirth).

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Renacer = require(Shared.Reglas.Renacer)
local Estadisticas = require(Shared.Reglas.Estadisticas)
local Niveles = require(Shared.Reglas.Niveles)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

return function(t)
	t.describe("Renacimiento", function()
		t.it("hace falta nivel 1.000", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Progress.Level = 999
			t.equal(select(2, Renacer.comprobar(p)), "nivel")
			p.Progress.Level = 1000
			t.ok(Renacer.comprobar(p))
		end)
		t.it("pierde nivel, puntos asignados y monedas; gana +10 puntos y +5 % de XP; conserva lo demás", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Progress.Level = 1000
			p.Progress.XP = 1234
			p.Progress.UnlockedZone = 3
			p.Wallet.Coins = 5e9
			p.Wallet.Crystals = 77
			Estadisticas.asignar(p, "Strength", 500)
			t.equal(Renacer.aplicar(p), 1)
			t.equal(p.Progress.Level, 1)
			t.equal(p.Progress.XP, 0)
			t.equal(p.Wallet.Coins, 0)
			t.equal(p.Wallet.Crystals, 77)
			t.equal(p.Progress.UnlockedZone, 3)
			t.equal(Estadisticas.puntosAsignados(p), 0)
			t.equal(p.Stats.BonusPoints, 10)
			t.near(Niveles.multiplicadorXP(p), 1.05, 1e-9)
		end)
		t.it("como mucho 10 veces (+50 % de XP y +100 puntos)", function()
			local p = PlantillaPerfil.nuevo(0)
			for _ = 1, 10 do
				p.Progress.Level = 1000
				t.ok(Renacer.comprobar(p))
				Renacer.aplicar(p)
			end
			p.Progress.Level = 1000
			t.equal(select(2, Renacer.comprobar(p)), "maximo")
			t.equal(p.Stats.BonusPoints, 100)
			t.near(Niveles.multiplicadorXP(p), 1.5, 1e-9)
		end)
		t.it("el resumen muestra lo que se gana y lo que se pierde", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Progress.Rebirths = 2
			p.Wallet.Coins = 1000
			local r = Renacer.resumen(p)
			t.equal(r.Siguiente, 3)
			t.near(r.BonoXP, 0.15, 1e-9)
			t.equal(r.PuntosExtra, 30)
			t.equal(r.MonedasPerdidas, 1000)
		end)
	end)
end
