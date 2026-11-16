-- Services/AnalyticsService: punto único para registrar eventos (C_Tecnico, sección 3).
-- Envía a la analítica de Roblox y lleva un recuento en memoria para depurar.
-- Nunca detiene el juego: todo fallo de envío se ignora.
-- Nota: las llamadas a la API de analítica de Roblox están sin contrastar con su documentación
-- (no accesible al escribir esto); van protegidas con pcall y hay que revisarlas en Studio.

local RunService = game:GetService("RunService")

local AnalyticsService = {}

-- Eventos conocidos. Registrar uno que no esté aquí da un aviso (evita nombres mal escritos).
AnalyticsService.Eventos = {
	PerfilCargado = true, FalloCarga = true, FalloGuardado = true, SesionPerdida = true,
	EsquemaRechazado = true, FrecuenciaSuperada = true,
	CajaAbierta = true, Extraccion = true, MuertePvP = true, JefeDerrotado = true, Renacimiento = true,
}

local recuento = {}
local destino = nil   -- función opcional (evento, userId, valor, detalle) para pruebas o un panel propio

function AnalyticsService.Iniciar()
	if RunService:IsStudio() then
		destino = destino or function() end
	end
end

function AnalyticsService.FijarDestino(fn)
	destino = fn
end

-- jugador puede ser un Player o nil (evento del servidor). valor es un número opcional.
function AnalyticsService.Registrar(jugador, evento, valor, detalle)
	if not AnalyticsService.Eventos[evento] then
		warn("AnalyticsService: evento desconocido " .. tostring(evento))
		return
	end
	recuento[evento] = (recuento[evento] or 0) + 1
	if destino then
		pcall(destino, evento, jugador and jugador.UserId or 0, valor, detalle)
	end
	if jugador and not RunService:IsStudio() then
		pcall(function()
			game:GetService("AnalyticsService"):LogCustomEvent(jugador, evento, valor or 1)
		end)
	end
end

function AnalyticsService.Recuento()
	return table.clone(recuento)
end

return AnalyticsService
