-- Pruebas de la fase 9: movimiento imposible, compras con Robux idempotentes, tienda de cosméticos y servicios,
-- calidad automática y reglas de monetización (lo que nunca se vende).

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Monetization = require(Shared.Config.Monetization)
local Stats = require(Shared.Config.Stats)
local Economia = require(Shared.Formulas.Economia)
local Tienda = require(Shared.Reglas.Tienda)
local Calidad = require(Shared.Reglas.Calidad)
local Ajustes = require(Shared.Reglas.Ajustes)
local Criadero = require(Shared.Reglas.Criadero)
local Movimiento = require(Server.Reglas.Movimiento)
local Recibos = require(Server.Reglas.Recibos)
local PlantillaPerfil = require(Server.Datos.PlantillaPerfil)

local function v(x, z)
	if Vector3 then
		return Vector3.new(x, 0, z)
	end
	return { X = x, Y = 0, Z = z }
end

return function(t)
	t.describe("Movimiento (C_Tecnico 7.2)", function()
		t.it("andar y correr al máximo con 2 dash, parpadeo y Paso de Relámpago es válido", function()
			local e = Movimiento.nuevo(v(0, 0), 0)
			-- 24 studs/s andando + 12 + 12 (dash) + 12 (parpadeo) + 18 (Paso) en el primer medio segundo
			local pos = 0
			for paso = 1, 8 do
				local tiempo = paso * 0.25
				pos = pos + 24 * 0.25 + (paso == 1 and 54 or 0)
				t.equal(Movimiento.muestra(e, v(pos, 0), tiempo), "ok", "paso " .. paso)
			end
		end)
		t.it("teletransportarse 200 studs cuenta como falta; 3 seguidas devuelven a la última posición válida", function()
			local e = Movimiento.nuevo(v(0, 0), 0)
			Movimiento.muestra(e, v(5, 0), 0.25)
			Movimiento.muestra(e, v(10, 0), 0.5)
			t.equal(Movimiento.muestra(e, v(210, 0), 0.75), "falta")
			t.equal(Movimiento.muestra(e, v(410, 0), 1.0), "falta")
			t.equal(Movimiento.muestra(e, v(610, 0), 1.25), "devolver")
			t.equal(e.Valida.X, 10)
		end)
		t.it("caer no cuenta (solo el desplazamiento horizontal)", function()
			local e = Movimiento.nuevo(v(0, 0), 0)
			local caida = Vector3 and Vector3.new(0, -160, 0) or { X = 0, Y = -160, Z = 0 }
			t.equal(Movimiento.muestra(e, caida, 0.5), "ok")
		end)
		t.it("tras un movimiento del servidor se empieza de nuevo", function()
			local e = Movimiento.nuevo(v(0, 0), 0)
			Movimiento.reiniciar(e, v(500, 500), 0.2)
			t.equal(Movimiento.muestra(e, v(505, 500), 0.5), "ok")
		end)
		t.it("la marca de WalkSpeed máximo (24) está muy por debajo del límite", function()
			t.ok(Stats.WalkSpeed.Max * 0.5 < 75)
		end)
	end)

	t.describe("Compras con Robux", function()
		t.it("un recibo se entrega una sola vez", function()
			local p = PlantillaPerfil.nuevo(0)
			local producto = Monetization.CrystalProducts[1]
			local id = producto.ProductId
			if id == 0 then
				producto.ProductId = 12345
			end
			t.equal(Recibos.procesar(p, "r1", producto.ProductId), "entregado")
			t.equal(p.Wallet.Crystals, producto.Crystals)
			t.equal(Recibos.procesar(p, "r1", producto.ProductId), "repetido")
			t.equal(p.Wallet.Crystals, producto.Crystals)
			t.equal(Recibos.procesar(p, "r2", 999), "desconocido")
			producto.ProductId = id
		end)
		t.it("se guardan como mucho los últimos 100 recibos", function()
			local p = PlantillaPerfil.nuevo(0)
			for i = 1, 130 do
				Recibos.apuntar(p, "r" .. i)
			end
			t.equal(#p.Purchases.Receipts, 100)
			t.equal(p.Purchases.Receipts[1], "r31")
		end)
	end)

	t.describe("Tienda de cosméticos y servicios", function()
		t.it("comprar con Cristales, no dos veces, y equipar en su hueco", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Wallet.Crystals = 500
			local precio = Tienda.comprobar(p, "TrailCuarzo")
			t.deepEqual(precio, { Moneda = "Crystals", Cantidad = 150 })
			Tienda.otorgar(p, "TrailCuarzo")
			t.equal(select(2, Tienda.comprobar(p, "TrailCuarzo")), "ya")
			t.ok(Tienda.equipar(p, "Trail", "TrailCuarzo"))
			t.equal(select(2, Tienda.equipar(p, "Aura", "TrailCuarzo")), "cosmetico")
			t.equal(select(2, Tienda.equipar(p, "Trail", "TrailBrasa")), "cosmetico", "no la tiene")
		end)
		t.it("el aspecto de prestigio cuesta 20 h de ingreso en monedas (sumidero de B6)", function()
			local p = PlantillaPerfil.nuevo(0)
			t.deepEqual(Tienda.precio(p, "AuraPrestigio"), { Moneda = "Coins", Cantidad = math.floor(20 * Economia.income(1) + 0.5) })
		end)
		t.it("almacén de mascotas +10 hasta 100 y tercera incubadora una vez", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Wallet.Crystals = 10000
			t.ok(Tienda.servicio(p, "PetStorage"))
			Tienda.aplicarServicio(p, "PetStorage")
			t.equal(p.PetStorage, 40)
			t.ok(Tienda.servicio(p, "ThirdIncubator"))
			Tienda.aplicarServicio(p, "ThirdIncubator")
			t.equal(#p.Incubators, 2)
			t.equal(select(2, Tienda.servicio(p, "ThirdIncubator")), "ya")
		end)
		t.it("B6 9.2: nunca se venden Celestiales, Núcleos Despertados, Seguro de carga, cajas, Suerte ni monedas", function()
			for _, c in ipairs(Monetization.Cosmetics) do
				t.ok(c.Kind == "Trail" or c.Kind == "Aura", c.Id .. " solo puede ser cosmético")
			end
			for id in pairs(Monetization.Services) do
				t.ok(id == "PetStorage" or id == "ThirdIncubator" or id == "SixthPetSlot", id)
			end
			for _, p in ipairs(Monetization.CrystalProducts) do
				t.ok(p.Crystals > 0 and p.Coins == nil and p.Item == nil)
			end
		end)
	end)

	t.describe("Ajustes guardados", function()
		t.it("solo se guardan claves conocidas con valores válidos", function()
			local r = Ajustes.limpiar({ Quality = "Ultra", Shake = false, OthersVFX = "si", Hack = 1e9 })
			t.deepEqual(r, { Shake = false })
			t.deepEqual(Ajustes.efectivos({ Quality = "Low" }), { Quality = "Low", Shake = true, OthersVFX = true })
			t.deepEqual(Ajustes.limpiar("x"), {})
		end)
	end)

	t.describe("Tercera incubadora", function()
		t.it("comprada antes del nivel 200 no se pierde al llegar a la segunda gratuita", function()
			local p = PlantillaPerfil.nuevo(0)
			p.Wallet.Crystals = 300
			Criadero.asegurarIncubadoras(p)
			Tienda.aplicarServicio(p, "ThirdIncubator")
			Criadero.asegurarIncubadoras(p)
			t.equal(#p.Incubators, 2)
			p.Progress.Level = 200
			Criadero.asegurarIncubadoras(p)
			t.equal(#p.Incubators, 3)
		end)
	end)

	t.describe("Calidad automática (C_Tecnico 8.2)", function()
		t.it("baja un nivel tras 10 s por debajo de 25 FPS y nunca sube sola", function()
			local e = Calidad.nuevo("High")
			for _ = 1, 9 do
				t.equal(Calidad.paso(e, 1, 20), "High")
			end
			t.equal(Calidad.paso(e, 1, 20), "Medium")
			for _ = 1, 30 do
				Calidad.paso(e, 1, 60)
			end
			t.equal(e.Nivel, "Medium")
			for _ = 1, 20 do
				Calidad.paso(e, 1, 10)
			end
			t.equal(e.Nivel, "Low")
		end)
		t.it("topes de partículas 800 / 1.400 / 2.000 y efectos ajenos al 40 % en Baja", function()
			t.equal(Calidad.config("Low").ParticleCap, 800)
			t.equal(Calidad.config("Medium").ParticleCap, 1400)
			t.equal(Calidad.config("High").ParticleCap, 2000)
			t.equal(Calidad.config("Low").OthersFraction, 0.40)
		end)
	end)
end
