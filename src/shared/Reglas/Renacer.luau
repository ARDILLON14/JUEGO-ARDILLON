-- Reglas/Renacimiento (A_GDD; Config/Economy.Rebirth). Puro.
-- A nivel 1.000, hasta 10 veces: +5 % de XP y +10 puntos de estadística por vuelta.
-- Se pierden el nivel, los puntos asignados y todas las monedas; se conserva todo lo demás
-- (objetos, mascotas, Núcleos, banco de minerales, Cristales, cosméticos y zonas desbloqueadas).

local Shared = script.Parent.Parent
local Economy = require(Shared.Config.Economy)
local Stats = require(Shared.Config.Stats)
local Estadisticas = require(script.Parent.Estadisticas)

local Renacer = {}

local R = Economy.Rebirth

-- true, o false y el motivo: "nivel" | "maximo".
function Renacer.comprobar(perfil)
	if (perfil.Progress.Rebirths or 0) >= R.Max then
		return false, "maximo"
	end
	if perfil.Progress.Level < Stats.XP.MaxLevel then
		return false, "nivel"
	end
	return true
end

-- Lo que el jugador verá antes de confirmar.
function Renacer.resumen(perfil)
	local n = perfil.Progress.Rebirths or 0
	return {
		Rebirths = n,
		Siguiente = n + 1,
		Max = R.Max,
		NivelNecesario = Stats.XP.MaxLevel,
		BonoXP = R.XPBonus * (n + 1),
		PuntosExtra = R.StatPoints * (n + 1),
		MonedasPerdidas = perfil.Wallet.Coins or 0,
	}
end

-- Aplica el renacimiento (comprobar antes). Devuelve el número de renacimientos.
function Renacer.aplicar(perfil)
	local p = perfil.Progress
	p.Rebirths = (p.Rebirths or 0) + 1
	p.Level = 1
	p.XP = 0
	Estadisticas.reiniciarPuntos(perfil)
	perfil.Stats.BonusPoints = (perfil.Stats.BonusPoints or 0) + R.StatPoints
	perfil.Wallet.Coins = 0
	return p.Rebirths
end

return Renacer
