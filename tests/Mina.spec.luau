-- Pruebas de la minería por bloques (DECISIONES P3b): volumen, destape, sorteo, regeneración y ritmo.

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Mining = require(Shared.Config.Mining)
local Pickaxes = require(Shared.Config.Pickaxes)
local Mineria = require(Shared.Formulas.Mineria)
local Potencia = require(Shared.Formulas.Potencia)
local Progresion = require(Shared.Formulas.Progresion)
local Mina = require(Server.Reglas.Mina)
local Simulaciones = require(script.Parent.Simulaciones)

local function generador(semilla)
	local estado = semilla % 2147483647
	return function()
		estado = (estado * 48271) % 2147483647
		return (estado - 1) / 2147483646
	end
end

local function contar(t)
	local n = 0
	for _ in pairs(t) do
		n = n + 1
	end
	return n
end

local function nueva(ancho, largo, profundidad)
	return Mina.nueva({ Zona = 1, Ancho = ancho or 6, Largo = largo or 6, Profundidad = profundidad or 5 })
end

return function(t)
	t.describe("Volumen", function()
		t.it("claves y coordenadas son inversas", function()
			local m = nueva(7, 5, 9)
			for _, c in ipairs({ { 1, 1, 1 }, { 7, 9, 5 }, { 3, 4, 2 } }) do
				local x, y, z = Mina.coords(m, Mina.clave(m, c[1], c[2], c[3]))
				t.deepEqual({ x, y, z }, c)
			end
		end)
		t.it("al empezar solo se ve la capa de arriba", function()
			local m = nueva(6, 6, 5)
			local novedades = Mina.iniciar(m, generador(1))
			t.equal(#novedades, 36)
			t.equal(contar(m.Bloques), 36)
			for _, n in ipairs(novedades) do
				t.equal(n.Y, 1)
			end
		end)
		t.it("picar destapa los vecinos y deja el hueco", function()
			local m = nueva(6, 6, 5)
			Mina.iniciar(m, generador(1))
			local b, novedades = Mina.picar(m, 3, 1, 3, 0, generador(2), 0)
			t.ok(b)
			t.ok(Mina.esAire(m, 3, 1, 3))
			t.equal(#novedades, 1, "debajo; los lados de la capa 1 ya estaban a la vista")
			t.equal(novedades[1].Y, 2)
			local _, mas = Mina.picar(m, 3, 2, 3, 0, generador(3), 0)
			t.equal(#mas, 5, "4 lados y debajo")
		end)
		t.it("no se pica lo que no está a la vista ni fuera del volumen", function()
			local m = nueva(6, 6, 5)
			Mina.iniciar(m, generador(1))
			t.equal(Mina.picar(m, 3, 3, 3, 0, generador(2), 0), nil)
			t.equal(Mina.picar(m, 0, 1, 1, 0, generador(2), 0), nil)
		end)
		t.it("en los bordes y el fondo aparece roca madre", function()
			local m = nueva(3, 3, 2)
			Mina.iniciar(m, generador(1))
			local _, n1 = Mina.picar(m, 1, 1, 1, 0, generador(2), 0)
			local madre = 0
			for _, n in ipairs(n1) do
				if n.Tipo == "RocaMadre" then
					madre = madre + 1
				end
			end
			t.equal(madre, 2, "un lado en x y otro en z")
			Mina.picar(m, 1, 2, 1, 0, generador(3), 0)
			t.ok(m.RocaMadre["1,3,1"], "fondo")
		end)
	end)

	t.describe("Sorteo", function()
		t.it("un 10 % de los bloques son mineral, con la tabla de la zona 1", function()
			local rng, minerales, comunes, n = generador(5), 0, 0, 200000
			for _ = 1, n do
				local b = Mina.sortear(1, 0, rng(), rng())
				if b.Tipo == "Mineral" then
					minerales = minerales + 1
					t.ok(Mining.Minerals[b.Mineral])
					if b.Rareza == "Common" then
						comunes = comunes + 1
					end
				end
			end
			t.near(minerales / n, Mining.Blocks.OreChance, 0.004)
			t.near(comunes / minerales, 0.55, 0.02)
		end)
	end)

	t.describe("Regeneración", function()
		t.it("un hueco vuelve a ser bloque a los 240 s y tapa a los vecinos que ya no ven aire", function()
			local m = nueva(6, 6, 5)
			Mina.iniciar(m, generador(1))
			Mina.picar(m, 3, 1, 3, 0, generador(2), 0)
			Mina.picar(m, 3, 2, 3, 0, generador(3), 0)
			t.equal(#Mina.huecosParaRegenerar(m, 239), 0)
			local huecos = Mina.huecosParaRegenerar(m, 240)
			t.equal(#huecos, 2)
			local k2 = Mina.clave(m, 3, 2, 3)
			local nuevo, tapados = Mina.regenerar(m, k2, generador(4))
			t.ok(nuevo, "toca el hueco de arriba: queda a la vista")
			t.equal(#tapados, 5, "los 4 lados y el de abajo vuelven a estar tapados")
			local k1 = Mina.clave(m, 3, 1, 3)
			nuevo = Mina.regenerar(m, k1, generador(5))
			t.ok(nuevo, "la capa de arriba ve el cielo")
			t.equal(m.NumAire, 0)
		end)
	end)

	t.describe("Ritmo del minero de referencia (calculos/c3_mina_bloques.py)", function()
		-- Misma forma de excavar que la simulación de Python, con el código real del juego.
		t.it("monedas por hora en la zona 1 dentro de 3.864–6.441 (x escala de dinero) y minutos por carga en 2,6–4,4", function()
			local totalM, totalC = 0, 0
			for s = 1, 3 do
				local monedas, _, minutos = Simulaciones.mina(1, s * 101, 2)
				totalM = totalM + monedas
				totalC = totalC + minutos
			end
			local monedas, minutos = totalM / 3, totalC / 3
			local escala = require(Shared.Config.Economy).CurrencyScale
			t.ok(monedas >= 3864 * escala and monedas <= 6441 * escala, "monedas/h " .. tostring(monedas))
			t.ok(minutos >= 2.6 and minutos <= 4.4, "min/carga " .. tostring(minutos))
		end)
	end)
end
