-- Reglas/Ajustes: los ajustes del jugador que se guardan (calidad, temblor de cámara, efectos de otros jugadores). Puro.
-- El cliente envía una tabla; aquí se queda solo lo conocido y con valores válidos.

local Ajustes = {}

Ajustes.Defecto = { Quality = "Auto", Shake = true, OthersVFX = true }

local CALIDADES = { Auto = true, Low = true, Medium = true, High = true }

function Ajustes.limpiar(entrada)
	local salida = {}
	if type(entrada) ~= "table" then
		return salida
	end
	if type(entrada.Quality) == "string" and CALIDADES[entrada.Quality] then
		salida.Quality = entrada.Quality
	end
	if type(entrada.Shake) == "boolean" then
		salida.Shake = entrada.Shake
	end
	if type(entrada.OthersVFX) == "boolean" then
		salida.OthersVFX = entrada.OthersVFX
	end
	return salida
end

-- Ajustes efectivos: lo guardado encima de los valores por defecto.
function Ajustes.efectivos(guardados)
	local r = {}
	for k, v in pairs(Ajustes.Defecto) do
		r[k] = v
	end
	if type(guardados) == "table" then
		for k, v in pairs(Ajustes.limpiar(guardados)) do
			r[k] = v
		end
	end
	return r
end

return Ajustes
