-- Datos/AlmacenMemoria: almacén en memoria con la misma interfaz que un DataStore (GetAsync, SetAsync, UpdateAsync).
-- Usos: las pruebas, y Studio cuando no hay acceso a la API de DataStore (nada se conserva al cerrar).
-- Copia los valores al entrar y al salir, como hace un DataStore al serializar.

local AlmacenMemoria = {}
AlmacenMemoria.__index = AlmacenMemoria

local function copiar(valor)
	if type(valor) ~= "table" then
		return valor
	end
	local c = {}
	for k, v in pairs(valor) do
		c[k] = copiar(v)
	end
	return c
end

function AlmacenMemoria.nuevo()
	return setmetatable({ Datos = {}, Escrituras = 0, FallosPendientes = 0 }, AlmacenMemoria)
end

-- Pruebas: las siguientes n llamadas fallan, como un DataStore con errores de servicio.
function AlmacenMemoria:fallar(n)
	self.FallosPendientes = n
end

function AlmacenMemoria:_puedeFallar()
	if self.FallosPendientes > 0 then
		self.FallosPendientes = self.FallosPendientes - 1
		error("AlmacenMemoria: fallo simulado", 0)
	end
end

function AlmacenMemoria:GetAsync(clave)
	self:_puedeFallar()
	return copiar(self.Datos[clave])
end

function AlmacenMemoria:SetAsync(clave, valor)
	self:_puedeFallar()
	self.Datos[clave] = copiar(valor)
	self.Escrituras = self.Escrituras + 1
end

function AlmacenMemoria:UpdateAsync(clave, transformar)
	self:_puedeFallar()
	local nuevo = transformar(copiar(self.Datos[clave]))
	if nuevo == nil then
		return nil
	end
	self.Datos[clave] = copiar(nuevo)
	self.Escrituras = self.Escrituras + 1
	return copiar(nuevo)
end

return AlmacenMemoria
