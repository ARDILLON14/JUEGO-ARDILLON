-- Datos/Migraciones: cambios de versión del perfil (C_Tecnico, 6.2).
-- Pasos[n] convierte un perfil de la versión n a la n+1. Cada paso es puro y no falla con datos incompletos.
-- Nunca se borra un campo en la versión en que deja de usarse: se elimina dos versiones después.

local PlantillaPerfil = require(script.Parent.PlantillaPerfil)

local Migraciones = {}

Migraciones.Pasos = {
	-- [1] = function(datos) ... return datos end,   -- de la versión 1 a la 2 (aún no existe)
}

-- Lleva datos hasta la versión objetivo. Devuelve los datos, o nil y el motivo si falta algún paso.
-- pasos y objetivo se pueden inyectar en las pruebas.
function Migraciones.aplicar(datos, objetivo, pasos)
	objetivo = objetivo or PlantillaPerfil.Version
	pasos = pasos or Migraciones.Pasos
	while datos.Version < objetivo do
		local paso = pasos[datos.Version]
		if not paso then
			return nil, "falta la migración de la versión " .. tostring(datos.Version)
		end
		local desde = datos.Version
		local ok, resultado = pcall(paso, datos)
		if not ok or type(resultado) ~= "table" then
			return nil, "falló la migración de la versión " .. tostring(desde)
		end
		datos = resultado
		datos.Version = desde + 1
	end
	return datos
end

return Migraciones
