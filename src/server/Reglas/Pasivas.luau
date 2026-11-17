-- Reglas/Pasivas: efecto de las pasivas del pico en cada golpe (B3, 3.3). Puro: el azar y el tiempo entran como parámetro.
--   SureStrike    Golpe certero: cada 10.º golpe hace daño doble
--   BladeEcho     Eco del filo: 10 % de golpear también otro depósito a 8 studs
--   SeismicWave   Onda sísmica: cada 12 s el golpe daña al 50 % a los depósitos a 8 studs
--   ChainFracture Fractura en cadena: tras agotar uno, el siguiente golpe quita además un 25 % de la vida máxima
--   OpenVein      Veta abierta: 10 % de sacar una unidad más
--   StellarEcho   Eco estelar: 5 % de que el depósito agotado reaparezca al instante (1 vez cada 60 s)
--   RunicSonar    Sonar rúnico: lo muestra el cliente (resalta depósitos Épicos o mejores a 30 studs)
--   LightBallast  Lastre ligero: solo en Zonas Fracturadas (fase 8)

local Shared = game:GetService("ReplicatedStorage").Shared
local Pickaxes = require(Shared.Config.Pickaxes)

local V = Pickaxes.PassiveValues
local Pasivas = {}

local function tiene(lista, id)
	return lista ~= nil and table.find(lista, id) ~= nil
end

function Pasivas.nuevoEstado()
	return { Golpes = 0, UltimaOnda = -1e9, UltimoEcoEstelar = -1e9, CadenaPendiente = false }
end

-- Efectos de un golpe. Devuelve { Multiplicador, Eco, Onda, CadenaFraccion }.
function Pasivas.alGolpear(pasivas, estado, ahora, aleatorio)
	estado.Golpes = estado.Golpes + 1
	local r = { Multiplicador = 1, Eco = false, Onda = false, CadenaFraccion = 0 }
	if tiene(pasivas, "SureStrike") and estado.Golpes % V.SureStrikeEvery == 0 then
		r.Multiplicador = V.SureStrikeMultiplier
	end
	if tiene(pasivas, "BladeEcho") and aleatorio() < V.BladeEcho then
		r.Eco = true
	end
	if tiene(pasivas, "SeismicWave") and ahora - estado.UltimaOnda >= V.SeismicWaveCooldown then
		estado.UltimaOnda = ahora
		r.Onda = true
	end
	if estado.CadenaPendiente then
		estado.CadenaPendiente = false
		if tiene(pasivas, "ChainFracture") then
			r.CadenaFraccion = V.ChainFractureFraction
		end
	end
	return r
end

-- Al agotar un depósito. Devuelve { UnidadExtra, Reaparece }.
function Pasivas.alAgotar(pasivas, estado, ahora, aleatorio)
	estado.CadenaPendiente = tiene(pasivas, "ChainFracture")
	local r = { UnidadExtra = false, Reaparece = false }
	if tiene(pasivas, "OpenVein") and aleatorio() < V.OpenVeinChance then
		r.UnidadExtra = true
	end
	if tiene(pasivas, "StellarEcho") and ahora - estado.UltimoEcoEstelar >= V.StellarEchoCooldown and aleatorio() < V.StellarEchoChance then
		estado.UltimoEcoEstelar = ahora
		r.Reaparece = true
	end
	return r
end

return Pasivas
