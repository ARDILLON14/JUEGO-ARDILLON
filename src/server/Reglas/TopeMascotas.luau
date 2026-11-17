-- Reglas/TopeMascotas: tope de daño de las mascotas con ventana deslizante (B5 6.1, F31). Puro.
-- Cada golpe de mascota se recorta para que la suma de los últimos 5 s no pase de Tope x DPSref x 5.

local Pets = require(game:GetService("ReplicatedStorage").Shared.Config.Pets)

local TopeMascotas = {}

function TopeMascotas.nuevo()
	return { Golpes = {} }   -- { { T, Dano } }
end

local function limpiar(estado, ahora)
	local v = Pets.DPSCap.WindowSeconds
	local i = 1
	while i <= #estado.Golpes and ahora - estado.Golpes[i].T >= v do
		i = i + 1
	end
	if i > 1 then
		local resto = {}
		for j = i, #estado.Golpes do
			table.insert(resto, estado.Golpes[j])
		end
		estado.Golpes = resto
	end
end

function TopeMascotas.enVentana(estado, ahora)
	limpiar(estado, ahora)
	local total = 0
	for _, g in ipairs(estado.Golpes) do
		total = total + g.Dano
	end
	return total
end

-- Devuelve el daño que se puede aplicar (0..dano) y lo apunta en la ventana.
-- dpsRef = Mascotas.dpsRef(...); modo = "PvE" | "PvP".
function TopeMascotas.permitir(estado, ahora, dano, dpsRef, modo)
	local cabe = math.max(0, Pets.DPSCap[modo] * dpsRef * Pets.DPSCap.WindowSeconds - TopeMascotas.enVentana(estado, ahora))
	local aplicado = math.min(dano, cabe)
	if aplicado > 0 then
		table.insert(estado.Golpes, { T = ahora, Dano = aplicado })
	end
	return aplicado
end

return TopeMascotas
