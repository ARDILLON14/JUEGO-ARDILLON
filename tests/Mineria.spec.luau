-- Pruebas de la fase 3: mochila, banco, venta, inventario, depósitos, generación, pasivas y medidas del roadmap.

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Mining = require(Shared.Config.Mining)
local Pickaxes = require(Shared.Config.Pickaxes)
local Rarity = require(Shared.Config.Rarity)
local Mineria = require(Shared.Formulas.Mineria)
local Potencia = require(Shared.Formulas.Potencia)
local Progresion = require(Shared.Formulas.Progresion)
local Economia = require(Shared.Formulas.Economia)
local Mochila = require(Shared.Reglas.Mochila)
local Inventario = require(Shared.Reglas.Inventario)
local Deposito = require(Server.Reglas.Deposito)
local Generador = require(Server.Reglas.Generador)
local Pasivas = require(Server.Reglas.Pasivas)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

local function perfil(nivel)
	local p = PlantillaPerfil.nuevo(0)
	p.Progress.Level = nivel or 1
	return p
end

local function generador(semilla)
	local estado = semilla % 2147483647
	return function()
		estado = (estado * 48271) % 2147483647
		return (estado - 1) / 2147483646
	end
end

local function fijo(valor)
	return function()
		return valor
	end
end

return function(t)
	t.describe("Mochila", function()
		t.it("60 de base; las ampliaciones fijan la capacidad; las mascotas suman", function()
			local p = perfil(1)
			t.equal(Mochila.capacidad(p), 60)
			p.Backpack.Tier = 1
			t.equal(Mochila.capacidad(p), 80)
			t.equal(Mochila.capacidad(p, 6), 86)
		end)
		t.it("no entra más de lo que cabe", function()
			local p = perfil(1)
			t.equal(Mochila.anadir(p, "PizarraClara", 50), 50)
			t.equal(Mochila.anadir(p, "CobreRosado", 30), 10)
			t.equal(Mochila.carga(p), 60)
			t.equal(Mochila.anadir(p, "PizarraClara", 5), 0)
			t.throws(function()
				Mochila.anadir(p, "Inventado", 1)
			end)
		end)
		t.it("depositar todo vacía la mochila y no se pierde nada", function()
			local p = perfil(1)
			Mochila.anadir(p, "PizarraClara", 10)
			Mochila.anadir(p, "EstanoLunar", 3)
			t.equal(Mochila.depositarTodo(p), 13)
			t.equal(Mochila.carga(p), 0)
			t.equal(Mochila.enBanco(p), 13)
			Mochila.anadir(p, "PizarraClara", 2)
			Mochila.depositarTodo(p)
			t.equal(p.Minerals.Banked.PizarraClara, 12)
		end)
		t.it("retirar del banco respeta existencias y hueco", function()
			local p = perfil(1)
			p.Minerals.Banked.PizarraClara = 100
			t.deepEqual({ Mochila.retirar(p, "PizarraClara", 70) }, { true, 60 })
			t.equal(p.Minerals.Banked.PizarraClara, 40)
			t.equal(select(2, Mochila.retirar(p, "PizarraClara", 1)), "mochila_llena")
			t.equal(select(2, Mochila.retirar(p, "CobreRosado", 1)), "sin_existencias")
		end)
	end)

	t.describe("Venta de minerales", function()
		t.it("precio de B3 y B6: Pizarra Clara a 2,5 la unidad", function()
			t.near(Mochila.precioUnidad("PizarraClara"), 2.5)
		end)
		t.it("vende primero de la mochila y después del banco, todo junto", function()
			local p = perfil(1)
			p.Minerals.Carried.PizarraClara = 3
			p.Minerals.Banked.PizarraClara = 10
			local ok, monedas, vendidas = Mochila.vender(p, "PizarraClara", 5)
			t.ok(ok)
			t.equal(monedas, 12)
			t.equal(vendidas, 5)
			t.equal(p.Minerals.Carried.PizarraClara, nil)
			t.equal(p.Minerals.Banked.PizarraClara, 8)
		end)
		t.it("vende como mucho lo que hay y rechaza lo raro", function()
			local p = perfil(1)
			p.Minerals.Carried.EstanoLunar = 2
			local _, monedas, vendidas = Mochila.vender(p, "EstanoLunar", 99)
			t.equal(vendidas, 2)
			t.equal(monedas, math.floor(2 * Mochila.precioUnidad("EstanoLunar") + 1e-9))
			t.equal(select(2, Mochila.vender(p, "EstanoLunar", 1)), "sin_existencias")
			t.equal(select(2, Mochila.vender(p, "PizarraClara", 0)), "cantidad")
			t.equal(select(2, Mochila.vender(p, "Oro", 1)), "mineral")
		end)
	end)

	t.describe("Ampliaciones de mochila", function()
		t.it("en orden, con zona desbloqueada y precio de B6", function()
			local p = perfil(1)
			t.equal(select(2, Mochila.puedeAmpliar(p)), "zona")
			p.Progress.UnlockedZone = 2
			local s = Mochila.puedeAmpliar(p)
			t.equal(s.Capacity, 80)
			t.equal(s.Price, Economia.backpackPrice(1))
			p.Backpack.Tier = 7
			t.equal(select(2, Mochila.puedeAmpliar(p)), "maxima")
		end)
	end)

	t.describe("Muerte en PvE", function()
		t.it("por debajo del nivel 25 no se pierde nada", function()
			local p = perfil(24)
			p.Minerals.Carried.PizarraClara = 50
			t.deepEqual(Mochila.perdidaMuertePvE(p), {})
			t.equal(p.Minerals.Carried.PizarraClara, 50)
		end)
		t.it("se pierde el 20 % de la carga; el banco nunca", function()
			local p = perfil(30)
			p.Minerals.Carried.PizarraClara = 50
			p.Minerals.Carried.EstanoLunar = 2
			p.Minerals.Banked.PizarraClara = 100
			local perdido = Mochila.perdidaMuertePvE(p)
			t.deepEqual(perdido, { PizarraClara = 10 })
			t.equal(p.Minerals.Carried.PizarraClara, 40)
			t.equal(p.Minerals.Banked.PizarraClara, 100)
		end)
		t.it("el saco se recoge hasta llenar la mochila", function()
			local p = perfil(30)
			p.Minerals.Carried.PizarraClara = 55
			local saco = { PizarraClara = 10 }
			t.equal(Mochila.recogerSaco(p, saco), 5)
			t.deepEqual(saco, { PizarraClara = 5 })
		end)
	end)

	t.describe("Inventario", function()
		t.it("ranuras de pasivas por rareza (GDD)", function()
			t.ok(Inventario.pasivasValidas("Common", { "SureStrike" }))
			t.ok(Inventario.pasivasValidas("Common", {}))
			t.ok(not Inventario.pasivasValidas("Common", { "RunicSonar" }))
			t.ok(not Inventario.pasivasValidas("Common", { "SureStrike", "BladeEcho" }))
			t.ok(Inventario.pasivasValidas("Mythic", { "RunicSonar", "BladeEcho" }))
			t.ok(not Inventario.pasivasValidas("Mythic", { "RunicSonar", "OpenVein" }))
			t.ok(Inventario.pasivasValidas("Celestial", { "StellarEcho" }))
			t.ok(not Inventario.pasivasValidas("Rare", { "Inventada" }))
		end)
		t.it("el pico inicial es Común de zona 1 y su potencia es 100", function()
			local s = Pickaxes.Starter
			local pico = Inventario.crearPico(s.Zone, s.Rarity, s.Passives)
			t.equal(Inventario.potencia(pico), 100)
			t.ok(Inventario.tienePasiva(pico, "SureStrike"))
			t.equal(Inventario.nombreBase(pico), "Pico de Pizarra")
		end)
		t.it("equipar exige nivel de zona y Minería", function()
			local p = perfil(150)
			p.Items.a = Inventario.crearPico(2, "Epic", { "RunicSonar" })
			p.Items.b = Inventario.crearPico(3, "Common", {})
			p.Items.c = { Kind = "Weapon", Type = "Sword", Zone = 1, Rarity = "Common", Level = 0, Slots = 0 }
			t.equal(select(2, Inventario.equipar(p, "a", "Pickaxe", 0)), "mineria")
			t.ok(Inventario.equipar(p, "a", "Pickaxe", 15))
			t.equal(p.Equipped.Pickaxe, "a")
			t.equal(select(2, Inventario.equipar(p, "b", "Pickaxe", 999)), "nivel")
			t.equal(select(2, Inventario.equipar(p, "c", "Pickaxe", 999)), "ranura")
			t.equal(select(2, Inventario.equipar(p, "x", "Pickaxe", 999)), "objeto")
		end)
		t.it("vender un objeto: 10 % de su coste; nunca el equipado", function()
			local p = perfil(1)
			p.Items.a = Inventario.crearPico(1, "Rare", { "BladeEcho" })
			p.Items.b = Inventario.crearPico(1, "Common", {})
			p.Equipped.Pickaxe = "b"
			t.equal(select(2, Inventario.vender(p, "b")), "equipado")
			local ok, monedas = Inventario.vender(p, "a")
			t.ok(ok)
			t.equal(monedas, Economia.gearSellPrice(1, "Rare"))
			t.equal(p.Items.a, nil)
		end)
	end)

	t.describe("Depósitos", function()
		t.it("vida y golpes: Común de zona 1 con el pico inicial son 6 golpes", function()
			local d = Deposito.nuevo(1, 1, "Common", "PizarraClara")
			t.equal(d.MaxHealth, 600)
			local golpes, agotado = 0, false
			while not agotado do
				golpes = golpes + 1
				local _, a = Deposito.golpear(d, 7, Mineria.hitDamage(d.MaxHealth, 100, 0))
				agotado = a
			end
			t.equal(golpes, 6)
			t.equal(Deposito.golpear(d, 7, 100), 0, "agotado no recibe más daño")
		end)
		t.it("un minero solo se lleva todas las unidades y la XP", function()
			local d = Deposito.nuevo(1, 1, "Common", "PizarraClara")
			Deposito.golpear(d, 7, 600)
			local r = Deposito.reparto(d)
			t.equal(#r, 1)
			t.equal(r[1].Units, 4)
			t.near(r[1].XP, Mineria.depositXP(1, "Common"))
		end)
		t.it("reparto proporcional y mínimo de 1 unidad con el 10 % del daño", function()
			local d = Deposito.nuevo(1, 1, "Common", "PizarraClara")
			Deposito.golpear(d, 1, 420)
			Deposito.golpear(d, 2, 120)
			Deposito.golpear(d, 3, 60)
			local r = Deposito.reparto(d)
			t.equal(r[1].Units + r[2].Units + r[3].Units >= 4, true)
			t.equal(r[1].Units, 3)
			t.equal(r[3].Units, 1, "el 10 % recibe al menos 1")
			t.near(r[1].XP + r[2].XP + r[3].XP, Mineria.depositXP(1, "Common"))
		end)
		t.it("quien hace menos del 10 % puede quedarse sin unidades pero recibe su XP", function()
			local d = Deposito.nuevo(1, 1, "UltraRare", "x")
			Deposito.golpear(d, 1, d.MaxHealth * 0.95)
			Deposito.golpear(d, 2, d.MaxHealth)
			local r = Deposito.reparto(d)
			t.equal(r[1].Units, 1)
			t.equal(r[2].Units, 0)
			t.ok(r[2].XP > 0)
		end)
	end)

	t.describe("Generación", function()
		t.it("cada zona tiene un mineral por rareza que puede aparecer", function()
			for zona = 1, 10 do
				for rareza, peso in pairs(Mineria.spawnWeights(zona)) do
					if peso > 0 then
						t.ok(Generador.mineral(zona, rareza), "zona " .. zona .. " " .. rareza)
					end
				end
			end
		end)
		t.it("frecuencias de aparición de la zona 1 sin suerte", function()
			local rng, cuenta, n = generador(42), {}, 100000
			for _ = 1, n do
				local r = Generador.rareza(1, 0, rng())
				cuenta[r] = (cuenta[r] or 0) + 1
			end
			t.near(100 * cuenta.Common / n, 55, 0.6)
			t.near(100 * (cuenta.Legendary or 0) / n, 2, 0.2)
			t.equal(cuenta.UltraRare, nil, "la zona 1 no tiene Ultra raro")
			t.equal(cuenta.Celestial, nil)
		end)
		t.it("la suerte sube las rarezas altas", function()
			local rng1, rng2, n, a, b = generador(9), generador(9), 50000, 0, 0
			for _ = 1, n do
				if Rarity.Multiplier[Generador.rareza(1, 0, rng1())] >= 2.5 then
					a = a + 1
				end
				if Rarity.Multiplier[Generador.rareza(1, 1000, rng2())] >= 2.5 then
					b = b + 1
				end
			end
			t.ok(b > a * 1.5)
		end)
		t.it("depósitos activos con el escalado y el límite de puntos del mapa", function()
			t.equal(Generador.activos(4, 100), 40)
			t.equal(Generador.activos(12, 100), 60)
			t.equal(Generador.activos(12, 48), 48)
		end)
	end)

	t.describe("Pasivas del pico", function()
		t.it("Golpe certero: cada 10.º golpe hace daño doble", function()
			local e, dobles = Pasivas.nuevoEstado(), 0
			for i = 1, 30 do
				local r = Pasivas.alGolpear({ "SureStrike" }, e, i, fijo(0.5))
				if r.Multiplicador == 2 then
					dobles = dobles + 1
					t.equal(i % 10, 0)
				end
			end
			t.equal(dobles, 3)
		end)
		t.it("Eco del filo al 10 % y Onda sísmica cada 12 s", function()
			local e = Pasivas.nuevoEstado()
			t.ok(Pasivas.alGolpear({ "BladeEcho" }, e, 0, fijo(0.05)).Eco)
			t.ok(not Pasivas.alGolpear({ "BladeEcho" }, e, 0, fijo(0.2)).Eco)
			t.ok(Pasivas.alGolpear({ "SeismicWave" }, e, 100, fijo(0.5)).Onda)
			t.ok(not Pasivas.alGolpear({ "SeismicWave" }, e, 111, fijo(0.5)).Onda)
			t.ok(Pasivas.alGolpear({ "SeismicWave" }, e, 112, fijo(0.5)).Onda)
		end)
		t.it("Fractura en cadena solo en el golpe siguiente a agotar", function()
			local e = Pasivas.nuevoEstado()
			Pasivas.alAgotar({ "ChainFracture" }, e, 0, fijo(0.5))
			t.equal(Pasivas.alGolpear({ "ChainFracture" }, e, 1, fijo(0.5)).CadenaFraccion, 0.25)
			t.equal(Pasivas.alGolpear({ "ChainFracture" }, e, 2, fijo(0.5)).CadenaFraccion, 0)
		end)
		t.it("Veta abierta y Eco estelar (1 vez cada 60 s)", function()
			local e = Pasivas.nuevoEstado()
			t.ok(Pasivas.alAgotar({ "OpenVein" }, e, 0, fijo(0.05)).UnidadExtra)
			t.ok(not Pasivas.alAgotar({ "OpenVein" }, e, 0, fijo(0.5)).UnidadExtra)
			t.ok(Pasivas.alAgotar({ "StellarEcho" }, e, 100, fijo(0.01)).Reaparece)
			t.ok(not Pasivas.alAgotar({ "StellarEcho" }, e, 150, fijo(0.01)).Reaparece)
			t.ok(Pasivas.alAgotar({ "StellarEcho" }, e, 160, fijo(0.01)).Reaparece)
		end)
		t.it("sin pasivas no pasa nada", function()
			local e = Pasivas.nuevoEstado()
			for i = 1, 20 do
				local r = Pasivas.alGolpear({}, e, i, fijo(0))
				t.equal(r.Multiplicador, 1)
				t.ok(not r.Eco and not r.Onda)
			end
		end)
	end)

	t.describe("Medidas del roadmap, fase 3", function()
		-- Minero de referencia de B3 (sección 6): zona 1, nivel 50, build equilibrada (Minería 18), pico Raro,
		-- 6 s para llegar a cada depósito, mochila de 60 y 40 s por viaje al banco.
		local VIAJE, BANCO = 6, 40
		local function ritmo(zona, mineria, potenciaPico, hps)
			local pesos = Mineria.spawnWeights(zona)
			local tm, uds, valor, total = 0, 0, 0, 0
			for _, r in ipairs(Rarity.Order) do
				local p = (pesos[r] or 0) / 100
				if p > 0 and mineria >= Mineria.depositMiningReq(zona, r) then
					tm = tm + p * Mineria.extractionSeconds(Mineria.depositHealth(zona, r), potenciaPico, mineria, hps)
					uds = uds + p * Mineria.depositUnits(r)
					valor = valor + p * Mineria.depositValue(zona, r)
					total = total + p
				end
			end
			tm, uds, valor = tm / total, uds / total, valor / total
			local porHora = 3600 / (tm + VIAJE + BANCO * uds / Mining.Backpack.Base)
			return { Segundos = tm, Unidades = uds, DepositosHora = porHora, Monedas = porHora * valor }
		end
		local equilibrado = ritmo(1, math.floor(Progresion.statPoints(50) * 0.125), Potencia.itemPower(1, "Rare"), Pickaxes.HitsPerSecond.Rare)

		t.it("segundos por depósito Común con el pico Común de la zona: 6,0 (aceptable 4,5–7,5)", function()
			local s = Mineria.extractionSeconds(Mineria.depositHealth(1, "Common"), Potencia.itemPower(1, "Common"), 0, Pickaxes.HitsPerSecond.Common)
			t.near(s, 6.0, 1e-9)
		end)
		t.it("minutos por carga de mochila: 3,5 (aceptable 2,6–4,4)", function()
			local minutos = Mining.Backpack.Base / equilibrado.Unidades / equilibrado.DepositosHora * 60
			t.ok(minutos >= 2.6 and minutos <= 4.4, tostring(minutos))
		end)
		t.it("monedas por hora en la zona 1: 5.152 (aceptable 3.864–6.441) y cerca de B3", function()
			t.ok(equilibrado.Monedas >= 3864 and equilibrado.Monedas <= 6441, tostring(equilibrado.Monedas))
			t.near(equilibrado.Monedas, 5175, 5175 * 0.02, "B3, sección 6")
		end)
		t.it("tiempo sin depósito libre con 8 mineros: menos del 5 %", function()
			-- 2 horas simuladas a pasos de 0,5 s. Cada minero busca un depósito libre, tarda 6 s en llegar y lo pica.
			local rng = generador(7)
			local puntos, dt, duracion = 40, 0.5, 7200
			local activos = {}            -- [punto] = { Ocupado, Rareza } o nil si está regenerándose
			local regenera = {}           -- [punto] = segundo en que reaparece
			for i = 1, puntos do
				activos[i] = { Ocupado = false, Rareza = Generador.rareza(1, 0, rng()) }
			end
			local mineros, esperando = {}, 0
			for i = 1, 8 do
				mineros[i] = { Hasta = 0, Punto = nil }
			end
			local potencia, hps = Potencia.itemPower(1, "Rare"), Pickaxes.HitsPerSecond.Rare
			local tiempo = 0
			while tiempo < duracion do
				for i = 1, puntos do
					if not activos[i] and tiempo >= regenera[i] then
						activos[i] = { Ocupado = false, Rareza = Generador.rareza(1, 0, rng()) }
					end
				end
				for _, m in ipairs(mineros) do
					if tiempo >= m.Hasta then
						if m.Punto then
							activos[m.Punto] = nil
							regenera[m.Punto] = tiempo + Generador.regeneracion()
							m.Punto = nil
						end
						local libre
						for i = 1, puntos do
							if activos[i] and not activos[i].Ocupado then
								libre = i
								break
							end
						end
						if libre then
							activos[libre].Ocupado = true
							m.Punto = libre
							m.Hasta = tiempo + VIAJE + Mineria.extractionSeconds(Mineria.depositHealth(1, activos[libre].Rareza), potencia, 18, hps)
						else
							esperando = esperando + dt
						end
					end
				end
				tiempo = tiempo + dt
			end
			local fraccion = esperando / (duracion * #mineros)
			t.ok(fraccion < 0.05, tostring(fraccion))
		end)
	end)
end
