-- Pruebas del guardado: plantilla, migraciones y sesión bloqueada (C_Tecnico, 6.2 a 6.4).

local Datos = game:GetService("ServerScriptService").Server.Datos
local PlantillaPerfil = require(Datos.PlantillaPerfil)
local Migraciones = require(Datos.Migraciones)
local AlmacenMemoria = require(Datos.AlmacenMemoria)
local AlmacenPerfiles = require(Datos.AlmacenPerfiles)

-- Dos "servidores" que comparten almacén y reloj.
local function mundo()
	local m = { Ahora = 1000000, Almacen = AlmacenMemoria.nuevo(), Copias = AlmacenMemoria.nuevo(), Esperado = 0, Eventos = {} }
	function m.servidor(jobId, extra)
		local deps = {
			Almacen = m.Almacen, Copias = m.Copias, JobId = jobId, PlaceId = 7,
			Reloj = function()
				return m.Ahora
			end,
			Esperar = function(s)
				m.Ahora = m.Ahora + s
				m.Esperado = m.Esperado + s
				if m.AlEsperar then
					m.AlEsperar()
				end
			end,
			Registrar = function(evento, userId, detalle)
				table.insert(m.Eventos, evento .. ":" .. tostring(detalle))
			end,
		}
		for k, v in pairs(extra or {}) do
			deps[k] = v
		end
		return AlmacenPerfiles.nuevo(deps)
	end
	return m
end

return function(t)
	t.describe("Plantilla", function()
		t.it("perfil nuevo: versión 1, nivel 1 y nada en riesgo", function()
			local p = PlantillaPerfil.nuevo(123)
			t.equal(p.Version, 1)
			t.equal(p.Meta.Created, 123)
			t.equal(p.Progress.Level, 1)
			t.equal(p.Wallet.Coins, 0)
			t.equal(p.Equipped.Core, "Prismatic")
			t.deepEqual(p.Minerals, { Carried = {}, Fractured = {}, Banked = {} })
			t.deepEqual(p.Boxes.Pity.Weapon, { A = 0, B = 0 })
		end)
		t.it("cada perfil nuevo es independiente", function()
			local a, b = PlantillaPerfil.nuevo(0), PlantillaPerfil.nuevo(0)
			a.Stats.Allocated.Luck = 9
			a.Items.x = {}
			t.equal(b.Stats.Allocated.Luck, 0)
			t.equal(b.Items.x, nil)
		end)
		t.it("reconciliar rellena lo que falta sin tocar lo que hay", function()
			local p = { Version = 1, Progress = { Level = 250 }, Wallet = { Coins = 77 }, Equipped = { Pets = { "p1" } },
				Items = { a = { Kind = "Weapon" } } }
			PlantillaPerfil.reconciliar(p)
			t.equal(p.Progress.Level, 250)
			t.equal(p.Progress.XP, 0)
			t.equal(p.Wallet.Coins, 77)
			t.equal(p.Wallet.Crystals, 0)
			t.deepEqual(p.Equipped.Pets, { "p1" }, "las listas no se tocan")
			t.equal(p.Items.a.Kind, "Weapon")
			t.equal(p.Fracture.Streak, 0)
		end)
		t.it("la vista del cliente no lleva datos internos", function()
			local p = PlantillaPerfil.nuevo(5)
			p.Meta.Session = { JobId = "abc", PlaceId = 1, Time = 2 }
			local v = PlantillaPerfil.vistaCliente(p)
			t.equal(v.Flags, nil)
			t.equal(v.Purchases, nil)
			t.equal(v.Meta.Session, nil)
			t.equal(v.Wallet.Coins, 0)
			t.ok(p.Flags ~= nil, "no modifica el original")
		end)
	end)

	t.describe("Migraciones", function()
		local pasos = {
			[1] = function(d)
				d.Wallet.Gemas = 5
				return d
			end,
			[2] = function(d)
				d.Nuevo = true
				return d
			end,
		}
		t.it("aplica los pasos en orden hasta la versión objetivo", function()
			local d = Migraciones.aplicar({ Version = 1, Wallet = {} }, 3, pasos)
			t.equal(d.Version, 3)
			t.equal(d.Wallet.Gemas, 5)
			t.equal(d.Nuevo, true)
		end)
		t.it("no hace nada si ya está al día", function()
			local d = Migraciones.aplicar({ Version = 1 })
			t.equal(d.Version, 1)
		end)
		t.it("falla sin romper si falta un paso o el paso da error", function()
			t.equal(Migraciones.aplicar({ Version = 1 }, 3, { [2] = pasos[2] }), nil)
			t.equal(Migraciones.aplicar({ Version = 1 }, 2, { [1] = function()
				error("x")
			end }), nil)
		end)
	end)

	t.describe("Sesión bloqueada", function()
		t.it("jugador nuevo: crea el perfil y toma el bloqueo", function()
			local m = mundo()
			local a = m.servidor("A")
			local datos = a:cargar(1)
			t.ok(datos)
			t.equal(datos.Progress.Level, 1)
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "A")
			t.equal(a:obtener(1), datos)
			t.equal(select(2, a:cargar(1)), "ya_cargado")
		end)
		t.it("guardar y liberar conserva los cambios y vacía la sesión", function()
			local m = mundo()
			local a = m.servidor("A")
			local datos = a:cargar(1)
			datos.Wallet.Coins = 500
			m.Ahora = m.Ahora + 60
			t.ok(a:guardar(1, false))
			t.equal(m.Almacen.Datos.u_1.Wallet.Coins, 500)
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "A")
			t.equal(m.Almacen.Datos.u_1.Meta.PlayTime, 60)
			datos.Wallet.Coins = 900
			t.ok(a:guardar(1, true))
			t.equal(m.Almacen.Datos.u_1.Wallet.Coins, 900)
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "")
			t.equal(a:obtener(1), nil)
			local b = m.servidor("B")
			t.equal(b:cargar(1).Wallet.Coins, 900)
		end)
		t.it("otro servidor no carga un perfil bloqueado: espera 30 s y se rinde", function()
			local m = mundo()
			local a, b = m.servidor("A"), m.servidor("B")
			a:cargar(1)
			local datos, motivo = b:cargar(1)
			t.equal(datos, nil)
			t.equal(motivo, "bloqueado")
			t.equal(m.Esperado, 30)
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "A", "el bloqueo sigue siendo de A")
		end)
		t.it("si el primer servidor libera durante la espera, el segundo carga", function()
			local m = mundo()
			local a, b = m.servidor("A"), m.servidor("B")
			a:cargar(1).Wallet.Coins = 42
			local veces = 0
			m.AlEsperar = function()
				veces = veces + 1
				if veces == 2 then
					m.AlEsperar = nil
					a:guardar(1, true)
				end
			end
			local datos = b:cargar(1)
			t.ok(datos)
			t.equal(datos.Wallet.Coins, 42, "teletransporte: el segundo servidor ve lo último guardado")
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "B")
		end)
		t.it("una sesión caducada (30 min sin renovar) se puede tomar", function()
			local m = mundo()
			local a, b = m.servidor("A"), m.servidor("B")
			a:cargar(1)
			m.Ahora = m.Ahora + 30 * 60 + 1
			t.ok(b:cargar(1))
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "B")
		end)
		t.it("quien pierde el bloqueo no puede escribir (sin duplicación)", function()
			local m = mundo()
			local a, b = m.servidor("A"), m.servidor("B")
			local datosA = a:cargar(1)
			m.Ahora = m.Ahora + 30 * 60 + 1
			local datosB = b:cargar(1)
			datosB.Wallet.Coins = 10
			t.ok(b:guardar(1, false))
			datosA.Wallet.Coins = 999999
			local ok, motivo = a:guardar(1, true)
			t.ok(not ok)
			t.equal(motivo, "sesion_perdida")
			t.equal(a:obtener(1), nil, "el perfil se descarta en el servidor que perdió el bloqueo")
			t.equal(m.Almacen.Datos.u_1.Wallet.Coins, 10)
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "B")
		end)
		t.it("el autoguardado renueva la sesión", function()
			local m = mundo()
			local a, b = m.servidor("A"), m.servidor("B")
			a:cargar(1)
			for _ = 1, 8 do   -- 40 min con autoguardado cada 5
				m.Ahora = m.Ahora + 300
				t.ok(a:guardar(1, false))
			end
			m.Esperado = 0
			t.equal(select(2, b:cargar(1)), "bloqueado")
		end)
		t.it("un fallo de lectura no crea un perfil vacío encima", function()
			local m = mundo()
			local a = m.servidor("A")
			a:cargar(1).Wallet.Coins = 300
			a:guardar(1, true)
			local b = m.servidor("B")
			m.Almacen:fallar(99)
			local datos, motivo = b:cargar(1)
			t.equal(datos, nil)
			t.equal(motivo, "fallo_lectura")
			t.equal(m.Esperado, 14, "reintentos con esperas de 2, 4 y 8 s")
			m.Almacen:fallar(0)
			t.equal(m.Almacen.Datos.u_1.Wallet.Coins, 300)
		end)
		t.it("un fallo pasajero se recupera con los reintentos", function()
			local m = mundo()
			local a = m.servidor("A")
			m.Almacen:fallar(2)
			t.ok(a:cargar(1))
			m.Almacen:fallar(1)
			t.ok(a:guardar(1, false))
		end)
		t.it("si no se puede escribir, el perfil sigue en memoria para reintentar", function()
			local m = mundo()
			local a = m.servidor("A")
			local datos = a:cargar(1)
			datos.Wallet.Coins = 5
			m.Almacen:fallar(99)
			local ok, motivo = a:guardar(1, true)
			t.ok(not ok)
			t.equal(motivo, "fallo_escritura")
			t.equal(a:obtener(1), datos)
			m.Almacen:fallar(0)
			t.ok(a:guardar(1, true))
			t.equal(m.Almacen.Datos.u_1.Wallet.Coins, 5)
		end)
		t.it("datos que no se entienden no se sobrescriben", function()
			local m = mundo()
			m.Almacen.Datos.u_1 = "basura"
			local a = m.servidor("A")
			t.equal(select(2, a:cargar(1)), "corrupto")
			t.equal(m.Almacen.Datos.u_1, "basura")
		end)
		t.it("un servidor antiguo no carga un perfil de versión mayor", function()
			local m = mundo()
			m.servidor("Nuevo", { Version = 2, Migraciones = { [1] = function(d)
				return d
			end } }):cargar(1)
			m.Ahora = m.Ahora + 3600
			local datos, motivo = m.servidor("Viejo"):cargar(1)
			t.equal(datos, nil)
			t.equal(motivo, "version_futura")
			t.equal(m.Almacen.Datos.u_1.Version, 2)
		end)
		t.it("migra con copia de seguridad previa", function()
			local m = mundo()
			local a = m.servidor("A")
			a:cargar(1).Wallet.Coins = 123
			a:guardar(1, true)
			local b = m.servidor("B", { Version = 2, Migraciones = { [1] = function(d)
				d.Wallet.Coins = d.Wallet.Coins * 2
				return d
			end } })
			local datos = b:cargar(1)
			t.equal(datos.Version, 2)
			t.equal(datos.Wallet.Coins, 246)
			local copias = 0
			for clave, copia in pairs(m.Copias.Datos) do
				copias = copias + 1
				t.ok(string.find(clave, "u_1_v1_", 1, true))
				t.equal(copia.Version, 1)
				t.equal(copia.Wallet.Coins, 123)
			end
			t.equal(copias, 1)
		end)
		t.it("sin copia de seguridad no se migra y se suelta el bloqueo", function()
			local m = mundo()
			local a = m.servidor("A")
			a:cargar(1)
			a:guardar(1, true)
			local b = m.servidor("B", { Version = 2, Migraciones = { [1] = function(d)
				return d
			end } })
			m.Copias:fallar(99)
			t.equal(select(2, b:cargar(1)), "fallo_copia")
			t.equal(m.Almacen.Datos.u_1.Version, 1)
			t.equal(m.Almacen.Datos.u_1.Meta.Session.JobId, "")
		end)
		t.it("guardar sin perfil cargado no hace nada", function()
			local m = mundo()
			t.equal(select(2, m.servidor("A"):guardar(1, true)), "sin_perfil")
			t.equal(m.Almacen.Escrituras, 0)
		end)
	end)
end
