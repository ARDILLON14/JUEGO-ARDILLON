-- Reglas/Calidad: niveles de calidad y ajuste automático (C_Tecnico 8.2). Puro.
-- Si la media baja de 25 FPS durante 10 s, baja un nivel. Nunca sube sola (se evita el vaivén).

local VFX = require(script.Parent.Parent.Config.VFX)

local Calidad = {}

Calidad.Niveles = { "Low", "Medium", "High" }
Calidad.UmbralFPS = 25
Calidad.SegundosBajos = 10

function Calidad.nuevo(nivel)
	return { Nivel = nivel or "High", Bajo = 0 }
end

-- dt en segundos, fps medidos en ese intervalo. Devuelve el nivel (cambia si toca).
function Calidad.paso(estado, dt, fps)
	if fps < Calidad.UmbralFPS then
		estado.Bajo = estado.Bajo + dt
	else
		estado.Bajo = 0
	end
	if estado.Bajo >= Calidad.SegundosBajos then
		estado.Bajo = 0
		local i = table.find(Calidad.Niveles, estado.Nivel) or 3
		estado.Nivel = Calidad.Niveles[math.max(1, i - 1)]
	end
	return estado.Nivel
end

function Calidad.config(nivel)
	return VFX.Quality[nivel] or VFX.Quality.High
end

return Calidad
