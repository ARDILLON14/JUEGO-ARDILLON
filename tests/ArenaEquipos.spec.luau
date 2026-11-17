-- Arena por equipos: emparejamiento, reparto y Elo (B4 9.3).

local Shared = game:GetService("ReplicatedStorage").Shared
local Arena = require(Shared.Reglas.Arena)

local function entrada(elo, nivel, desde)
	return { Elo = elo, Nivel = nivel or 150, Desde = desde or 0 }
end

return function(t)
	t.describe("Arena 2v2 y 3v3", function()
		t.it("jugadores por equipo de cada modo", function()
			t.equal(Arena.porEquipo("1v1"), 1)
			t.equal(Arena.porEquipo("2v2"), 2)
			t.equal(Arena.porEquipo("3v3"), 3)
		end)
		t.it("hacen falta 2 x n jugadores del mismo tramo dentro del margen", function()
			local cola = { entrada(1000), entrada(1050), entrada(1080) }
			t.equal(Arena.buscar(cola, 2, 0), nil, "solo 3 jugadores")
			table.insert(cola, entrada(1090))
			local r = Arena.buscar(cola, 2, 0)
			t.equal(#r, 4)
			-- uno de otro tramo no cuenta
			cola[4] = entrada(1090, 250)
			t.equal(Arena.buscar(cola, 2, 0), nil)
		end)
		t.it("el margen crece con la espera de todos", function()
			local cola = { entrada(1000), entrada(1100), entrada(1150), entrada(1250) }
			t.equal(Arena.buscar(cola, 2, 0), nil, "250 de diferencia con margen 100")
			t.ok(Arena.buscar(cola, 2, 46) ~= nil, "margen 250 tras 45 s")
		end)
		t.it("elige el grupo más ajustado y deja fuera al que no encaja", function()
			local cola = { entrada(1000), entrada(1500), entrada(1010), entrada(1020), entrada(1030) }
			local r = Arena.buscar(cola, 2, 0)
			table.sort(r)
			t.deepEqual(r, { 1, 3, 4, 5 })
		end)
		t.it("reparto en serpiente: 1-4-5 contra 2-3-6", function()
			local a, b = Arena.repartir({ entrada(1600), entrada(1500), entrada(1400), entrada(1300), entrada(1200), entrada(1100) })
			t.deepEqual({ a[1].Elo, a[2].Elo, a[3].Elo }, { 1600, 1300, 1200 })
			t.deepEqual({ b[1].Elo, b[2].Elo, b[3].Elo }, { 1500, 1400, 1100 })
		end)
		t.it("Elo por equipos: equipos iguales, ±16 cada uno; se conserva la suma", function()
			local na, nb = Arena.actualizarEquipos({ 1000, 1000 }, { 1000, 1000 }, 1)
			t.deepEqual(na, { 1016, 1016 })
			t.deepEqual(nb, { 984, 984 })
			local xa, xb = Arena.actualizarEquipos({ 1200, 1000, 900 }, { 1100, 1050, 950 }, 0)
			local s = 0
			for i = 1, 3 do
				s = s + xa[i] + xb[i] - ({ 1200, 1000, 900 })[i] - ({ 1100, 1050, 950 })[i]
			end
			t.ok(math.abs(s) <= 3, "la suma de Elo casi no cambia (redondeo)")
		end)
		t.it("1v1 sigue igual que antes", function()
			local na, nb = Arena.actualizarEquipos({ 1000 }, { 1000 }, 1)
			local a, b = Arena.actualizar(1000, 1000, 1)
			t.equal(na[1], a)
			t.equal(nb[1], b)
		end)
	end)
end
