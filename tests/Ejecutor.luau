-- tests/Ejecutor: ejecutor de pruebas mínimo y sin dependencias.
-- Cada archivo *.spec.luau devuelve function(t) ... end y usa:
--   t.describe(nombre, fn)   t.it(nombre, fn)
--   t.equal(a, b)   t.near(a, b, tolerancia)   t.ok(v)   t.deepEqual(a, b)   t.throws(fn)
-- Funciona igual en Roblox Studio (tests/init.server.luau) y fuera de Roblox (herramientas/pruebas.py).

local Ejecutor = {}

local function describir(v)
	if type(v) == "string" then
		return '"' .. v .. '"'
	end
	return tostring(v)
end

local function iguales(a, b)
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for k, v in pairs(a) do
		if not iguales(v, b[k]) then
			return false
		end
	end
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end
	return true
end

-- specs: lista de { Name = string, Run = function(t) }. Devuelve { Passed, Failed, Failures = { string } }.
function Ejecutor.run(specs, write)
	write = write or print
	local result = { Passed = 0, Failed = 0, Failures = {} }
	local ruta = {}

	local t = {}
	function t.describe(name, fn)
		table.insert(ruta, name)
		fn()
		table.remove(ruta)
	end
	function t.it(name, fn)
		table.insert(ruta, name)
		local titulo = table.concat(ruta, " > ")
		local ok, err = pcall(fn)
		if ok then
			result.Passed = result.Passed + 1
		else
			result.Failed = result.Failed + 1
			table.insert(result.Failures, titulo .. "\n    " .. tostring(err))
		end
		table.remove(ruta)
	end
	function t.ok(v, msg)
		if not v then
			error(msg or "se esperaba un valor verdadero", 2)
		end
	end
	function t.equal(a, b, msg)
		if a ~= b then
			error((msg and (msg .. ": ") or "") .. "se esperaba " .. describir(b) .. " y se obtuvo " .. describir(a), 2)
		end
	end
	function t.near(a, b, tol, msg)
		tol = tol or 1e-9
		if type(a) ~= "number" or a ~= a or math.abs(a - b) > tol then
			error((msg and (msg .. ": ") or "") .. "se esperaba " .. describir(b) .. " +/- " .. tostring(tol) .. " y se obtuvo " .. describir(a), 2)
		end
	end
	function t.deepEqual(a, b, msg)
		if not iguales(a, b) then
			error(msg or "las tablas no coinciden", 2)
		end
	end
	function t.throws(fn, msg)
		if pcall(fn) then
			error(msg or "se esperaba un error", 2)
		end
	end

	for _, spec in ipairs(specs) do
		table.insert(ruta, spec.Name)
		local ok, err = pcall(spec.Run, t)
		if not ok then
			result.Failed = result.Failed + 1
			table.insert(result.Failures, spec.Name .. " (error al cargar)\n    " .. tostring(err))
		end
		ruta = {}
	end

	for _, f in ipairs(result.Failures) do
		write("FALLO  " .. f)
	end
	write(string.format("Pruebas: %d correctas, %d fallidas", result.Passed, result.Failed))
	return result
end

return Ejecutor
