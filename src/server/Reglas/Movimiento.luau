-- Reglas/Movimiento: ¿es posible este desplazamiento? (C_Tecnico 7.2). Puro.
-- Se guardan muestras de posición; se compara el desplazamiento horizontal con el máximo de cada ventana.

local Security = require(game:GetService("ReplicatedStorage").Shared.Config.Security)

local Movimiento = {}

local M = Security.Movement

function Movimiento.nuevo(pos, t)
	return { Muestras = { { T = t, Pos = pos } }, Faltas = 0, Valida = pos }
end

-- Tras un movimiento del servidor (portal, dash...): se empieza de nuevo desde ahí.
function Movimiento.reiniciar(estado, pos, t)
	estado.Muestras = { { T = t, Pos = pos } }
	estado.Faltas = 0
	estado.Valida = pos
end

local function horizontal(a, b)
	local dx, dz = a.X - b.X, a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

-- Añade una muestra. Devuelve "ok", "falta" o "devolver" (3 faltas seguidas: volver a la última posición válida).
function Movimiento.muestra(estado, pos, t)
	local exceso = false
	for _, v in ipairs(M.Windows) do
		-- la muestra más reciente que tenga al menos v.Seconds de antigüedad
		local ref
		for i = #estado.Muestras, 1, -1 do
			if t - estado.Muestras[i].T >= v.Seconds - 1e-6 then
				ref = estado.Muestras[i]
				break
			end
		end
		if ref and horizontal(pos, ref.Pos) > v.MaxStuds * ((t - ref.T) / v.Seconds) + 1e-6 and t - ref.T <= v.Seconds * 1.5 then
			exceso = true
		end
	end
	table.insert(estado.Muestras, { T = t, Pos = pos })
	while #estado.Muestras > 1 and t - estado.Muestras[1].T > 2.5 do
		table.remove(estado.Muestras, 1)
	end
	if not exceso then
		estado.Faltas = 0
		estado.Valida = pos
		return "ok"
	end
	estado.Faltas = estado.Faltas + 1
	if estado.Faltas >= M.StrikesToRubberband then
		estado.Faltas = 0
		return "devolver"
	end
	return "falta"
end

return Movimiento
