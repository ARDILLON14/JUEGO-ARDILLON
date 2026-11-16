-- Formulas/Defensa: F12. Reducción de daño = min(D / (D + K), tope).
-- Referencia: OREBOUND/B_Matematico/B2_Progresion.md.

local Stats = require(script.Parent.Parent.Config.Stats)

local Defensa = {}

-- mode: "PvE" o "PvP". Devuelve la fracción de daño que se evita (0..tope).
function Defensa.reduction(defense, mode)
	local cfg = Stats.Defense[mode]
	assert(cfg, "modo de defensa desconocido")
	defense = math.max(defense or 0, 0)
	return math.min(defense / (defense + cfg.K), cfg.Cap)
end

return Defensa
