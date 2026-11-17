-- Cliente: copia local del perfil y de la vida/energía que envía el servidor. Solo para mostrar.
-- Estado.Cambio se dispara con "Perfil", "Stats" o "Aviso" cuando llega algo nuevo.

local Estado = {
	Perfil = nil,
	Stats = { Energy = 100, MaxEnergy = 100, InCombat = false, BlinkUnlocked = false },
}

local cambio = Instance.new("BindableEvent")
Estado.Cambio = cambio.Event

local carpeta = nil

function Estado.Iniciar(carpetaRemotes)
	carpeta = carpetaRemotes
	carpeta:WaitForChild("State.Profile").OnClientEvent:Connect(function(datos, parcial)
		if parcial and Estado.Perfil then
			for seccion, valor in pairs(datos) do
				Estado.Perfil[seccion] = valor
			end
		else
			Estado.Perfil = datos
		end
		cambio:Fire("Perfil")
	end)
	carpeta:WaitForChild("State.Stats").OnClientEvent:Connect(function(datos)
		Estado.Stats = datos
		cambio:Fire("Stats")
	end)
	carpeta:WaitForChild("Notify").OnClientEvent:Connect(function(aviso)
		cambio:Fire("Aviso", aviso)
	end)
end

-- Llama a un RemoteFunction. Devuelve ok y el resultado o el motivo. Nunca lanza errores.
function Estado.Invocar(nombre, ...)
	local remote = carpeta and carpeta:FindFirstChild(nombre)
	if not remote then
		return false, "no_disponible"
	end
	local args = { ... }
	local n = select("#", ...)
	local ok, resultado, extra = pcall(function()
		return remote:InvokeServer(unpack(args, 1, n))
	end)
	if not ok then
		return false, "error_red"
	end
	return resultado, extra
end

function Estado.Existe(nombre)
	return carpeta ~= nil and carpeta:FindFirstChild(nombre) ~= nil
end

return Estado
