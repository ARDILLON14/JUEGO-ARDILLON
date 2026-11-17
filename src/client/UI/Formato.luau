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

-- Cantidades grandes de dinero: 9.999 / 12,5 K / 5,15 M / 2,4 B / 1,2 T (estilo de los juegos de Roblox actuales).
local SUFIJOS = { { 1e15, "Qa" }, { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
function Formato.abreviado(n)
	n = n or 0
	local a = math.abs(n)
	if a < 10000 then
		return Formato.entero(n)
	end
	for _, s in ipairs(SUFIJOS) do
		if a >= s[1] then
			local v = n / s[1]
			local decimales = 2
			if math.abs(v) >= 100 then
				decimales = 0
			elseif math.abs(v) >= 10 then
				decimales = 1
			end
			local texto = string.format("%." .. decimales .. "f", v)
			if decimales > 0 then
				texto = string.gsub(string.gsub(texto, "0+$", ""), "%.$", "")
			end
			return (string.gsub(texto, "%.", ",")) .. " " .. s[2]
		end
	end
	return Formato.entero(n)
end

function Formato.porcentaje(x, decimales)
	return Formato.decimal(100 * (x or 0), decimales or 0) .. " %"
end

return Formato
