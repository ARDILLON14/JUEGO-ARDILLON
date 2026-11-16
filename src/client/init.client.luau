-- Arranque del cliente de OREBOUND. Fase 1: recibe el perfil y lo deja disponible para los controladores,
-- que se añaden en las fases siguientes (src/client/Controllers).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"):WaitForChild("Remotes"))
local carpeta = ReplicatedStorage:WaitForChild(Remotes.FolderName)

carpeta:WaitForChild("State.Profile").OnClientEvent:Connect(function(perfil)
	print(string.format("OREBOUND: perfil recibido (nivel %d, %d monedas)", perfil.Progress.Level, perfil.Wallet.Coins))
end)
