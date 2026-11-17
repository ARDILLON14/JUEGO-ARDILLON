-- tests/Simulaciones: simulaciones compartidas por varias pruebas (no es un .spec).
-- mina(zona, semilla, horas): minero de referencia de B3 en la cantera de bloques (misma forma de excavar que
-- calculos/c3_mina_bloques.py). Devuelve monedas por hora, minerales por hora y minutos por carga de mochila.

local Shared = game:GetService("ReplicatedStorage").Shared
local Server = game:GetService("ServerScriptService").Server
local Mining = require(Shared.Config.Mining)
local Pickaxes = require(Shared.Config.Pickaxes)
local Mineria = require(Shared.Formulas.Mineria)
local Potencia = require(Shared.Formulas.Potencia)
local Progresion = require(Shared.Formulas.Progresion)
local Mina = require(Server.Reglas.Mina)

local Simulaciones = {}

local function generador(semilla)
	local estado = semilla % 2147483647
	return function()
		estado = (estado * 48271) % 2147483647
		return (estado - 1) / 2147483646
	end
end

function Simulaciones.mina(zona, semilla, horas)
		local rng = generador(semilla)
		local m = Mina.nueva({ Zona = zona, Ancho = 24, Largo = 24, Profundidad = 40 })
		Mina.iniciar(m, rng)
		local pico, hps = Potencia.itemPower(zona, "Rare"), Pickaxes.HitsPerSecond.Rare
		local mineria = math.floor(Progresion.statPoints(Mineria.zoneMidLevel(zona)) * 0.125)
		local tPiedra = math.max(1, math.ceil(Mineria.stoneHealth(zona) / Mineria.stoneHitDamage(pico, mineria))) / hps
		local t, monedas, menas, unidades, cargas = 0, 0, 0, 0, 0
		local fin = horas * 3600
		local function picar(x, y, z)
			local b = Mina.picar(m, x, y, z, t, rng, 0)
			if not b then
				return false
		end
			if b.Tipo == "Mineral" then
				t = t + Mineria.extractionSeconds(Mineria.depositHealth(zona, b.Rareza), pico, mineria, hps)
				menas = menas + 1
				monedas = monedas + Mineria.depositValue(zona, b.Rareza)
				unidades = unidades + Mineria.depositUnits(b.Rareza)
				if unidades >= Mining.Backpack.Base then
					t = t + 18
					unidades = 0
					cargas = cargas + 1
			end
			else
				t = t + tPiedra
		end
			return true
	end
		local function pozoNuevo()
			for _ = 1, 50 do
				local x, z = math.floor(rng() * 24) + 1, math.floor(rng() * 24) + 1
				if not Mina.esAire(m, x, 1, z) then
					return x, 0, z
			end
		end
			return math.floor(rng() * 24) + 1, 0, math.floor(rng() * 24) + 1
	end
		local px, py, pz = pozoNuevo()
		local objetivo, dx, dz, largo, tramos, enAire = 6 + math.floor(rng() * 25), nil, nil, 0, 0, 0
		local DIRS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
		local proximaRegen = 10
		while t < fin do
			if t >= proximaRegen then
				proximaRegen = t + 10
				for _, k in ipairs(Mina.huecosParaRegenerar(m, t)) do
					local x, y, z = Mina.coords(m, k)
					if math.max(math.abs(x - px), math.abs(y - py), math.abs(z - pz)) > 3 then
						Mina.regenerar(m, k, rng)
				end
			end
		end
			local mejor, dist
			for k, b in pairs(m.Bloques) do
				if b.Tipo == "Mineral" then
					local x, y, z = Mina.coords(m, k)
					if math.abs(x - px) <= 2 and math.abs(z - pz) <= 2 and math.abs(y - py) <= 2 and Mina.expuesta(m, x, y, z) then
						local d = math.abs(x - px) + math.abs(y - py) + math.abs(z - pz)
						if not dist or d < dist or (d == dist and k < mejor) then
							mejor, dist = k, d
					end
				end
			end
		end
			if mejor then
				local x, y, z = Mina.coords(m, mejor)
				picar(x, y, z)
			elseif py < objetivo and py < 40 then
				if not Mina.esAire(m, px, py + 1, pz) then
					picar(px, py + 1, pz)
			end
				py = py + 1
				t = t + 0.1
			else
				if not dx or largo <= 0 then
					if tramos >= 2 or enAire >= 6 then
						t = t + 11
						px, py, pz = pozoNuevo()
						objetivo, dx, largo, tramos, enAire = 6 + math.floor(rng() * 25), nil, 0, 0, 0
					else
						local d = DIRS[math.floor(rng() * 4) + 1]
						dx, dz, largo, tramos = d[1], d[2], 8 + math.floor(rng() * 13), tramos + 1
				end
				else
					local sx, sz = px + dx, pz + dz
					if not Mina.dentro(m, sx, py, sz) or py - 1 < 1 then
						dx = nil
					else
						local nuevos = 0
						if not Mina.esAire(m, sx, py, sz) and picar(sx, py, sz) then
							nuevos = nuevos + 1
					end
						if not Mina.esAire(m, sx, py - 1, sz) and picar(sx, py - 1, sz) then
							nuevos = nuevos + 1
					end
						if nuevos == 0 then
							enAire = enAire + 1
						else
							enAire = 0
					end
						px, pz = sx, sz
						t = t + 0.3
						largo = largo - 1
				end
			end
		end
	end
		local h = t / 3600
		return monedas / h, menas / h, 60 * h / math.max(cargas, 1)
	end

return Simulaciones
