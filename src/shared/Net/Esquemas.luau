-- Net/Esquemas: comprobación de tipos y rangos de los parámetros de un Remote (C_Tecnico, 5.1, punto 1).
-- Un esquema es una tabla de datos:
--   { Type = "number",  Min = n, Max = n, Integer = true }
--   { Type = "string",  MaxLength = n, Enum = { "A", "B" } }
--   { Type = "boolean" }
--   { Type = "Vector3", MaxMagnitude = n }
--   { Type = "array",   Of = esquema, MaxLength = n }
--   { Type = "struct",  Fields = { clave = esquema } }
--   { Type = "table",   MaxSize = n }          tabla libre de valores simples, con tamaño limitado
-- Cualquier esquema admite Optional = true (acepta nil).
-- Nunca lanza errores: lo que envía el cliente no es de fiar.

local Esquemas = {}

local MAX_STRING = 64
local MAX_DEPTH = 4

local function finito(n)
	return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end

-- Tamaño aproximado de una tabla libre; nil si contiene algo que no sea cadena, número, booleano o tabla.
local function tamano(valor, profundidad)
	local tipo = type(valor)
	if tipo == "string" then
		return #valor + 2
	elseif tipo == "number" then
		if not finito(valor) then
			return nil
		end
		return 8
	elseif tipo == "boolean" then
		return 4
	elseif tipo == "table" then
		if profundidad >= MAX_DEPTH then
			return nil
		end
		local total = 2
		for k, v in pairs(valor) do
			local tk = type(k)
			if tk ~= "string" and not (tk == "number" and finito(k)) then
				return nil
			end
			local parte = tamano(v, profundidad + 1)
			if parte == nil then
				return nil
			end
			total = total + parte + (tk == "string" and #k + 3 or 9)
		end
		return total
	end
	return nil
end
Esquemas.tamano = function(valor)
	return tamano(valor, 0)
end

local comprobar

local COMPROBADORES = {
	number = function(e, v)
		if not finito(v) then
			return false, "no es un número finito"
		end
		if e.Integer and v ~= math.floor(v) then
			return false, "no es entero"
		end
		if (e.Min and v < e.Min) or (e.Max and v > e.Max) then
			return false, "fuera de rango"
		end
		return true
	end,
	string = function(e, v)
		if type(v) ~= "string" then
			return false, "no es una cadena"
		end
		if #v > (e.MaxLength or MAX_STRING) then
			return false, "cadena demasiado larga"
		end
		if e.Enum and not table.find(e.Enum, v) then
			return false, "valor no admitido"
		end
		return true
	end,
	boolean = function(_, v)
		if type(v) ~= "boolean" then
			return false, "no es un booleano"
		end
		return true
	end,
	Vector3 = function(e, v)
		if typeof(v) ~= "Vector3" then
			return false, "no es un Vector3"
		end
		if not (finito(v.X) and finito(v.Y) and finito(v.Z)) then
			return false, "vector no finito"
		end
		if e.MaxMagnitude and math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) > e.MaxMagnitude then
			return false, "vector demasiado largo"
		end
		return true
	end,
	array = function(e, v, profundidad)
		if type(v) ~= "table" then
			return false, "no es una lista"
		end
		local n = #v
		if n > (e.MaxLength or 32) then
			return false, "lista demasiado larga"
		end
		local claves = 0
		for _ in pairs(v) do
			claves = claves + 1
		end
		if claves ~= n then
			return false, "la lista tiene huecos o claves que no son posiciones"
		end
		for i = 1, n do
			local ok, motivo = comprobar(e.Of, v[i], profundidad + 1)
			if not ok then
				return false, motivo
			end
		end
		return true
	end,
	struct = function(e, v, profundidad)
		if type(v) ~= "table" then
			return false, "no es una tabla"
		end
		for clave in pairs(v) do
			if e.Fields[clave] == nil then
				return false, "campo desconocido"
			end
		end
		for clave, sub in pairs(e.Fields) do
			local ok, motivo = comprobar(sub, v[clave], profundidad + 1)
			if not ok then
				return false, motivo
			end
		end
		return true
	end,
	table = function(e, v)
		if type(v) ~= "table" then
			return false, "no es una tabla"
		end
		local t = tamano(v, 0)
		if t == nil or t > (e.MaxSize or 2048) then
			return false, "tabla no admitida o demasiado grande"
		end
		return true
	end,
}

comprobar = function(esquema, valor, profundidad)
	if valor == nil then
		if esquema.Optional then
			return true
		end
		return false, "falta un parámetro"
	end
	if profundidad > MAX_DEPTH then
		return false, "demasiados niveles"
	end
	local fn = COMPROBADORES[esquema.Type]
	if not fn then
		return false, "esquema desconocido"
	end
	return fn(esquema, valor, profundidad)
end

-- Comprueba un solo valor contra un esquema. Devuelve true, o false y el motivo.
function Esquemas.comprobar(esquema, valor)
	return comprobar(esquema, valor, 0)
end

-- Comprueba la lista de argumentos de un Remote contra su lista de esquemas.
-- Devuelve true y la lista de argumentos, o false y el motivo. Rechaza argumentos de más.
function Esquemas.validar(parametros, ...)
	local n = select("#", ...)
	if n > #parametros then
		return false, "sobran parámetros"
	end
	local args = { ... }
	for i, esquema in ipairs(parametros) do
		local ok, motivo = comprobar(esquema, args[i], 0)
		if not ok then
			return false, (esquema.Name or ("#" .. i)) .. ": " .. motivo
		end
	end
	return true, args
end

return Esquemas
