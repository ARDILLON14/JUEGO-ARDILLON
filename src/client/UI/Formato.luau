-- Formato de números en español: 1.234.567 y 2,5.

local Formato = {}

function Formato.entero(n)
	n = math.floor((n or 0) + 0.5)
	local signo = ""
	if n < 0 then
		signo = "-"
		n = -n
	end
	local s = tostring(n)
	local partes = {}
	while #s > 3 do
		table.insert(partes, 1, string.sub(s, -3))
		s = string.sub(s, 1, -4)
	end
	table.insert(partes, 1, s)
	return signo .. table.concat(partes, ".")
end

function Formato.decimal(x, decimales)
	local s = string.format("%." .. tostring(decimales or 2) .. "f", x or 0)
	return (string.gsub(s, "%.", ","))
end

function Formato.porcentaje(x, decimales)
	return Formato.decimal(100 * (x or 0), decimales or 0) .. " %"
end

return Formato
