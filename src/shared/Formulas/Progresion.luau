-- Formulas/Progresion: F6 a F11 y energía. Funciones puras.
-- Referencia: OREBOUND/B_Matematico/B2_Progresion.md.

local Stats = require(script.Parent.Parent.Config.Stats)

local Progresion = {}

-- F6 y F8: XP para pasar del nivel L al L+1.
function Progresion.xpForLevel(level)
	local xp = Stats.XP
	if level >= xp.MaxLevel then
		return xp.TailBase + xp.TailSlope * (level - xp.MaxLevel)
	end
	return math.ceil(xp.A + xp.B * level + xp.C * level * level)
end

-- F7: XP de una acción de referencia a nivel L.
function Progresion.xpPerAction(level)
	local a = Stats.XPPerAction
	return a.Base + a.PerLevel * level + a.PerLevelSq * level * level
end

-- Suma XP y sube los niveles que toque. Devuelve nivel, XP sobrante y niveles subidos.
function Progresion.addXP(level, xp, gained)
	assert(gained >= 0, "XP negativa")
	xp = xp + gained
	local ups = 0
	local need = Progresion.xpForLevel(level)
	while xp >= need do
		xp = xp - need
		level = level + 1
		ups = ups + 1
		need = Progresion.xpForLevel(level)
	end
	return level, xp, ups
end

-- F9: puntos de estadística ganados en total a nivel L (sin contar los de renacimiento).
function Progresion.statPoints(level)
	local p = Stats.Points
	local capped = math.min(level, Stats.XP.MaxLevel)
	local points = p.Start + p.PerLevel * (capped - 1)
	if level > Stats.XP.MaxLevel then
		points = points + p.PerLevelAfterMax * (level - Stats.XP.MaxLevel)
	end
	return points
end

-- Valor total de una estadística: puntos asignados (máx. 1.000) + bonos de equipo, mascotas y consumibles.
-- El total se limita a 5.000 (B2, F9).
function Progresion.capStat(stat)
	return math.clamp(stat or 0, 0, Stats.Points.CapTotal)
end

-- F10: 1 + M S / (S + 1000), con S = valor total de la estadística.
function Progresion.curve(stat, m)
	stat = Progresion.capStat(stat)
	return 1 + m * stat / (stat + Stats.Curve.K)
end

-- F11: vida base por nivel.
function Progresion.baseHealth(level)
	local h = Stats.BaseHealth
	return h.Base * h.Growth ^ ((level - 1) / h.LevelsPerStep)
end

-- Vida máxima: vida base x curva de Vitalidad (M = 3 en PvE; vitalityM = 1,0 en PvP).
function Progresion.maxHealth(level, vitality, vitalityM)
	return Progresion.baseHealth(level) * Progresion.curve(vitality, vitalityM or Stats.M.Vitality)
end

function Progresion.maxEnergy(energy)
	energy = Progresion.capStat(energy)
	return Stats.Energy.Base + Stats.Energy.Bonus * energy / (energy + Stats.Curve.K)
end

-- Regeneración de energía por segundo.
function Progresion.energyRegen(energy, inCombat)
	local base = Stats.Energy.RegenIdle
	if inCombat then
		base = Stats.Energy.RegenCombat
	end
	return base * Progresion.curve(energy, Stats.M.EnergyRegen)
end

-- Velocidad de movimiento en studs por segundo, con la ralentización por carga ya aplicada si se pasa.
function Progresion.walkSpeed(speedStat, slow)
	local speed = Stats.WalkSpeed.Base * Progresion.curve(speedStat, Stats.M.MoveSpeed)
	return math.min(speed, Stats.WalkSpeed.Max) * (1 - (slow or 0))
end

function Progresion.attackSpeedMultiplier(speedStat)
	return Progresion.curve(speedStat, Stats.M.AttackSpeed)
end

return Progresion
