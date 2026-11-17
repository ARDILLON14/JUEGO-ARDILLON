-- Pruebas de Shared/Net (definiciones y esquemas) y Server/Net (límite de frecuencia y validación común).

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Remotes = require(Shared.Net.Remotes)
local Esquemas = require(Shared.Net.Esquemas)
local LimiteFrecuencia = require(Server.Net.LimiteFrecuencia)
local Validador = require(Server.Net.Validador)

-- En Roblox se usa Vector3.new; fuera, una tabla que typeof reconoce (herramientas/pruebas.py).
local function vector(x, y, z)
	if Vector3 then
		return Vector3.new(x, y, z)
	end
	return { __typeof = "Vector3", X = x, Y = y, Z = z }
end

return function(t)
	t.describe("Definiciones", function()
		t.it("hay 47 Remotes del cliente al servidor (46 de C_Tecnico + subir a la superficie) y 13 del servidor al cliente", function()
			local n = 0
			for nombre, def in pairs(Remotes.ClientToServer) do
				n = n + 1
				t.ok(def.Kind == "Event" or def.Kind == "Function", nombre)
				t.ok(type(def.Params) == "table", nombre)
				t.ok(def.Rate.PerSecond > 0 and def.Rate.Burst >= 1, nombre)
			end
			t.equal(n, 47)
			t.equal(#Remotes.ServerToClient, 13)
		end)
		t.it("límites de combate de C_Tecnico 5.2", function()
			t.deepEqual(Remotes.ClientToServer["Combat.Attack"].Rate, { PerSecond = 5.7, Burst = 12 })
			t.deepEqual(Remotes.ClientToServer["Mining.Hit"].Rate, { PerSecond = 2.5, Burst = 5 })
			t.deepEqual(Remotes.ClientToServer["Combat.Break"].Rate, { PerSecond = 0.1, Burst = 2 })
			t.deepEqual(Remotes.ClientToServer["Rebirth.Confirm"].Rate, { PerSecond = 0.1, Burst = 1 })
		end)
	end)

	t.describe("Esquemas", function()
		local function valida(nombre, ...)
			return (Esquemas.validar(Remotes.ClientToServer[nombre].Params, ...))
		end
		t.it("números: finitos, enteros y en rango", function()
			t.ok(valida("Stats.Allocate", "Strength", 5))
			t.ok(not valida("Stats.Allocate", "Strength", 0))
			t.ok(not valida("Stats.Allocate", "Strength", 1.5))
			t.ok(not valida("Stats.Allocate", "Strength", 1001))
			t.ok(not valida("Stats.Allocate", "Strength", math.huge))
			t.ok(not valida("Stats.Allocate", "Strength", 0 / 0))
			t.ok(not valida("Stats.Allocate", "Strength", "5"))
			t.ok(not valida("Stats.Allocate", "Fuerza", 5))
		end)
		t.it("faltan o sobran parámetros", function()
			t.ok(not valida("Stats.Allocate", "Strength"))
			t.ok(not valida("Stats.Allocate", "Strength", 5, "extra"))
			t.ok(valida("Combat.Break"))
			t.ok(not valida("Combat.Break", 1))
		end)
		t.it("cadenas con longitud máxima", function()
			t.ok(valida("Inventory.Equip", "a1b2c3d4", "Weapon"))
			t.ok(not valida("Inventory.Equip", string.rep("x", 41), "Weapon"))
			t.ok(not valida("Inventory.Equip", 12, "Weapon"))
		end)
		t.it("listas: tamaño, huecos y tipo de los elementos", function()
			t.ok(valida("Combat.Attack", { 1, 2, 3 }, 1))
			t.ok(valida("Combat.Attack", {}, 4))
			t.ok(not valida("Combat.Attack", { 1, 2, 3, 4 }, 1))
			t.ok(not valida("Combat.Attack", { 1, "x" }, 1))
			t.ok(not valida("Combat.Attack", { 1, clave = 2 }, 1))
			t.ok(not valida("Combat.Attack", { 1 }, 5))
			t.ok(not valida("Combat.Attack", "1", 1))
		end)
		t.it("vectores de dirección", function()
			t.ok(valida("Combat.Dash", vector(1, 0, 0)))
			t.ok(not valida("Combat.Dash", vector(50, 0, 0)))
			t.ok(not valida("Combat.Dash", vector(0 / 0, 0, 0)))
			t.ok(not valida("Combat.Dash", { X = 1, Y = 0, Z = 0 }))
			t.ok(valida("Combat.Cast", "Z", vector(0, 0, -1)))
			t.ok(not valida("Combat.Cast", "Q", vector(0, 0, -1)))
		end)
		t.it("estructuras: sin campos desconocidos ni ausentes", function()
			t.ok(valida("Combat.SetLoadout", { Z = "a", X = "b", C = "c", V = "d" }))
			t.ok(not valida("Combat.SetLoadout", { Z = "a", X = "b", C = "c" }))
			t.ok(not valida("Combat.SetLoadout", { Z = "a", X = "b", C = "c", V = "d", W = "e" }))
		end)
		t.it("parámetros opcionales", function()
			t.ok(valida("Crafting.Craft", "Pickaxe", nil, 1, "Rare", { "BladeEcho" }))
			t.ok(valida("Crafting.Craft", "Weapon", "Sword", 3, "Epic"))
			t.ok(not valida("Crafting.Craft", "Weapon", "Sword", 11, "Epic"))
			t.ok(not valida("Crafting.Craft", "Weapon", "Katana", 3, "Epic"))
			t.ok(valida("Shop.Sell", "PizarraClara", 10))
			t.ok(valida("Shop.Sell", nil, nil, "a1b2c3d4"))
			t.ok(not valida("Shop.Sell", "MineralInventado", 10))
		end)
		t.it("tabla de ajustes: tamaño y contenido limitados", function()
			t.ok(valida("Settings.Save", { Quality = "Low", Shake = false, Volume = 0.5 }))
			t.ok(not valida("Settings.Save", { Texto = string.rep("x", 3000) }))
			t.ok(not valida("Settings.Save", { Fn = function() end }))
			t.ok(not valida("Settings.Save", { a = { b = { c = { d = { e = 1 } } } } }))
		end)
		t.it("apertura de cajas: de 1 a 10", function()
			t.ok(valida("Box.Open", "Weapon", 10))
			t.ok(not valida("Box.Open", "Weapon", 11))
			t.ok(not valida("Box.Open", "Premium", 1))
		end)
	end)

	t.describe("Límite de frecuencia", function()
		t.it("ráfaga, rechazo y relleno", function()
			local ahora = 0
			local limite = LimiteFrecuencia.nuevo(function()
				return ahora
			end)
			local regla = { PerSecond = 2.5, Burst = 5 }
			for _ = 1, 5 do
				t.ok(limite:consumir(1, "Mining.Hit", regla))
			end
			t.ok(not limite:consumir(1, "Mining.Hit", regla))
			t.ok(limite:consumir(2, "Mining.Hit", regla), "otro jugador tiene su propio cubo")
			t.ok(limite:consumir(1, "Combat.Block", regla), "otro Remote tiene su propio cubo")
			ahora = 0.4
			t.ok(limite:consumir(1, "Mining.Hit", regla))
			t.ok(not limite:consumir(1, "Mining.Hit", regla))
			ahora = 1000
			local admitidas = 0
			for _ = 1, 20 do
				if limite:consumir(1, "Mining.Hit", regla) then
					admitidas = admitidas + 1
				end
			end
			t.equal(admitidas, 5, "el cubo no pasa de la ráfaga")
		end)
		t.it("a largo plazo no admite más que el límite", function()
			local ahora = 0
			local limite = LimiteFrecuencia.nuevo(function()
				return ahora
			end)
			local regla, admitidas = { PerSecond = 5.7, Burst = 12 }, 0
			for paso = 1, 6000 do   -- 60 s a 100 llamadas por segundo
				ahora = paso / 100
				if limite:consumir(7, "Combat.Attack", regla) then
					admitidas = admitidas + 1
				end
			end
			t.ok(admitidas <= 5.7 * 60 + 12 and admitidas >= 5.7 * 60, tostring(admitidas))
		end)
		t.it("olvidar libera el estado del jugador", function()
			local limite = LimiteFrecuencia.nuevo(function()
				return 0
			end)
			local regla = { PerSecond = 0.1, Burst = 1 }
			t.ok(limite:consumir(1, "X", regla))
			t.ok(not limite:consumir(1, "X", regla))
			limite:olvidar(1)
			t.ok(limite:consumir(1, "X", regla))
		end)
	end)

	t.describe("Validación común", function()
		local function montar(conPerfil)
			local marcas = {}
			local v = Validador.nuevo({
				Limite = LimiteFrecuencia.nuevo(function()
					return 0
				end),
				PerfilCargado = function()
					return conPerfil
				end,
				Marcar = function(_, motivo, remote)
					table.insert(marcas, motivo .. ":" .. remote)
				end,
			})
			return v, marcas
		end
		local jugador = { UserId = 42 }
		t.it("admite una llamada correcta y devuelve los argumentos", function()
			local v = montar(true)
			local ok, args = v:comprobar(jugador, "Stats.Allocate", "Luck", 3)
			t.ok(ok)
			t.deepEqual(args, { "Luck", 3 })
		end)
		t.it("rechaza por esquema y avisa al anticheat", function()
			local v, marcas = montar(true)
			local ok, motivo = v:comprobar(jugador, "Stats.Allocate", "Luck", -3)
			t.ok(not ok)
			t.equal(motivo, "esquema")
			t.deepEqual(marcas, { "esquema:Stats.Allocate" })
		end)
		t.it("los Remotes de Studio solo existen con Studio = true", function()
			local v = montar(true)
			t.equal(select(2, v:comprobar(jugador, "Dev.GiveXP", 100)), "desconocido")
			local s = Validador.nuevo({ Limite = LimiteFrecuencia.nuevo(function()
				return 0
			end), PerfilCargado = function()
				return true
			end, Studio = true })
			t.ok(s:comprobar(jugador, "Dev.GiveXP", 100))
		end)
		t.it("rechaza sin perfil, por frecuencia y Remotes desconocidos", function()
			local v = montar(false)
			t.equal(select(2, v:comprobar(jugador, "Stats.Respec", false)), "sin_perfil")
			t.equal(select(2, v:comprobar(jugador, "Stats.Respec", false)), "frecuencia")
			t.equal(select(2, v:comprobar(jugador, "Admin.DarMonedas", 1e9)), "desconocido")
		end)
	end)
end
