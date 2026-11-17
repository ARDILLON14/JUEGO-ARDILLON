-- Services/ComplianceService: normas de Roblox por país y edad (C_Tecnico 7.6), con PolicyService.
-- OREBOUND no vende nada aleatorio con dinero real: las cajas se pagan solo con monedas del juego y los Cristales
-- solo compran cosméticos y servicios fijos. Aun así se consulta la política de cada jugador y se guarda como
-- atributos del Player para que la interfaz pueda ocultar lo que no esté permitido:
--   PaidRandomRestricted  (cajas de pago aleatorias; aquí no hay, pero se respeta si llegaran)
--   ExternalLinksAllowed  (enlaces a redes sociales en la interfaz)
-- Si la consulta falla se asume lo más restrictivo.

local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")

local ComplianceService = {}

local politicas = {}   -- [jugador] = { PaidRandomRestricted, ExternalLinksAllowed }

local function consultar(jugador)
	local ok, info = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(jugador)
	end)
	local p
	if ok and info then
		local enlaces = info.AllowedExternalLinkReferences or {}
		p = {
			PaidRandomRestricted = info.ArePaidRandomItemsRestricted == true,
			ExternalLinksAllowed = #enlaces > 0,
		}
	else
		p = { PaidRandomRestricted = true, ExternalLinksAllowed = false }
	end
	politicas[jugador] = p
	jugador:SetAttribute("PaidRandomRestricted", p.PaidRandomRestricted)
	jugador:SetAttribute("ExternalLinksAllowed", p.ExternalLinksAllowed)
end

-- ¿Puede este jugador ver / comprar objetos aleatorios de pago? (Hoy no se usa: no existen en el juego.)
function ComplianceService.PuedeAleatorioDePago(jugador)
	local p = politicas[jugador]
	return p ~= nil and not p.PaidRandomRestricted
end

function ComplianceService.PuedeEnlacesExternos(jugador)
	local p = politicas[jugador]
	return p ~= nil and p.ExternalLinksAllowed
end

function ComplianceService.Iniciar()
	Players.PlayerAdded:Connect(function(jugador)
		task.spawn(consultar, jugador)
	end)
	for _, j in ipairs(Players:GetPlayers()) do
		task.spawn(consultar, j)
	end
	Players.PlayerRemoving:Connect(function(jugador)
		politicas[jugador] = nil
	end)
end

return ComplianceService
