-- Services/RebirthService: renacimiento con doble confirmación (C_Tecnico; Reglas/Renacer).
--   Rebirth.Prepare()       -> resumen y una ficha (token) válida 60 s, o el motivo por el que no se puede.
--   Rebirth.Confirm(token)  -> renace. Fuera de combate; guarda el perfil al momento.
-- El Altar de renacimiento de la plaza (etiqueta «Renacimiento») abre el panel del cliente.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Renacer = require(Shared.Reglas.Renacer)

local RebirthService = {}

local Datos, StatsSvc, Analitica, Red
local fichas = {}   -- [jugador] = { Token, Hasta }

local MOTIVOS = {
	nivel = "Necesitas nivel 1.000",
	maximo = "Ya has renacido el máximo de veces",
	combate = "No puedes renacer en combate",
	ficha = "La confirmación ha caducado; vuelve a intentarlo",
}

local function preparar(jugador)
	local perfil = Datos.GetProfile(jugador)
	local ok, motivo = Renacer.comprobar(perfil)
	local resumen = Renacer.resumen(perfil)
	if not ok then
		resumen.Motivo = MOTIVOS[motivo]
		return false, resumen
	end
	local token = HttpService:GenerateGUID(false):sub(1, 36)
	fichas[jugador] = { Token = token, Hasta = os.clock() + 60 }
	resumen.Token = token
	return true, resumen
end

local function confirmar(jugador, token)
	local f = fichas[jugador]
	fichas[jugador] = nil
	if not f or f.Token ~= token or os.clock() > f.Hasta then
		return false, MOTIVOS.ficha
	end
	if StatsSvc.EnCombate(jugador) then
		return false, MOTIVOS.combate
	end
	local perfil = Datos.GetProfile(jugador)
	local ok, motivo = Renacer.comprobar(perfil)
	if not ok then
		return false, MOTIVOS[motivo]
	end
	local monedas = perfil.Wallet.Coins
	local n = Renacer.aplicar(perfil)
	Analitica.Registrar(jugador, "Renacimiento", n, tostring(monedas))
	Datos.GuardarAhora(jugador)
	StatsSvc.Recalcular(jugador)
	StatsSvc.Rellenar(jugador)
	Datos.Replicar(jugador, "Progress", "Stats", "Wallet")
	Red:obtener("Notify"):FireClient(jugador, { Text = "¡Has renacido! Renacimiento " .. n .. ": +" .. (n * 5) .. " % de XP", Color = Color3.fromRGB(255, 210, 80) })
	return true, n
end

function RebirthService.Iniciar(deps)
	Datos, StatsSvc, Analitica, Red = deps.Datos, deps.Stats, deps.Analitica, deps.Red
	Red:conectar("Rebirth.Prepare", preparar)
	Red:conectar("Rebirth.Confirm", confirmar)
	Players.PlayerRemoving:Connect(function(jugador)
		fichas[jugador] = nil
	end)
	local function conectarAltar(parte)
		local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Triggered:Connect(function(jugador)
				Red:obtener("Notify"):FireClient(jugador, { Kind = "OpenRebirth" })
			end)
		end
	end
	for _, parte in ipairs(CollectionService:GetTagged("Renacimiento")) do
		conectarAltar(parte)
	end
	CollectionService:GetInstanceAddedSignal("Renacimiento"):Connect(conectarAltar)
end

return RebirthService
