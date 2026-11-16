-- Lugar de pruebas (pruebas.project.json): ejecuta todos los *.spec al arrancar el servidor en Studio.

local Ejecutor = require(script.Ejecutor)

local specs = {}
for _, modulo in ipairs(script:GetChildren()) do
	if modulo:IsA("ModuleScript") and string.sub(modulo.Name, -5) == ".spec" then
		table.insert(specs, { Name = modulo.Name, Run = require(modulo) })
	end
end
table.sort(specs, function(a, b)
	return a.Name < b.Name
end)

local resultado = Ejecutor.run(specs, print)
if resultado.Failed > 0 then
	warn("OREBOUND: hay pruebas fallidas")
end
