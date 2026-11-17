-- Reglas/Recursos: energía, estado de combate y regeneración de vida de un jugador (B2, sección 8).
-- Estado en memoria (no se guarda). Puro: el tiempo entra como parámetro.

local Stats = require(game:GetService("ReplicatedStorage").Shared.Config.Stats)

local Recursos = {}

local NUNCA = -1e9

-- derivadas = Reglas/Estadisticas.derivadas(...)
function Recursos.nuevo(derivadas)
	return {
		Energy = derivadas.MaxEnergy,
		MaxEnergy = derivadas.MaxEnergy,
		RegenCombat = derivadas.EnergyRegenCombat,
		RegenIdle = derivadas.EnergyRegenIdle,
		UltimoCombate = NUNCA,
		ModoCombate = "PvE",
		PausaHasta = NUNCA,
		Bloqueando = false,
	}
end

-- Cambian las estadísticas: se conserva la proporción de energía.
function Recursos.actualizar(estado, derivadas)
	local proporcion = 1
	if estado.MaxEnergy > 0 then
		proporcion = estado.Energy / estado.MaxEnergy
	end
	estado.MaxEnergy = derivadas.MaxEnergy
	estado.Energy = derivadas.MaxEnergy * proporcion
	estado.RegenCombat = derivadas.EnergyRegenCombat
	estado.RegenIdle = derivadas.EnergyRegenIdle
end

function Recursos.rellenar(estado)
	estado.Energy = estado.MaxEnergy
	estado.PausaHasta = NUNCA
end

-- «En combate» = menos de 5 s desde el último golpe dado o recibido.
function Recursos.enCombate(estado, ahora)
	return ahora - estado.UltimoCombate < Stats.HealthRegen.CombatTimeout
end

-- modo: "PvE" | "PvP" (PvP incluye las Zonas Fracturadas).
function Recursos.marcarCombate(estado, ahora, modo)
	estado.UltimoCombate = ahora
	estado.ModoCombate = modo or "PvE"
end

-- Gasta energía si alcanza. Tras gastar no se regenera durante 1,5 s.
function Recursos.gastar(estado, coste, ahora)
	if coste < 0 or coste ~= coste then
		return false
	end
	if estado.Energy + 1e-9 < coste then
		return false
	end
	estado.Energy = math.max(0, estado.Energy - coste)
	estado.PausaHasta = ahora + Stats.Energy.RegenPause
	return true
end

-- Avanza dt segundos. Devuelve la vida que hay que sumar (fracción de la vida máxima).
function Recursos.avanzar(estado, dt, ahora)
	local combate = Recursos.enCombate(estado, ahora)
	if not estado.Bloqueando and ahora >= estado.PausaHasta then
		local ritmo = estado.RegenIdle
		if combate then
			ritmo = estado.RegenCombat
		end
		estado.Energy = math.min(estado.MaxEnergy, estado.Energy + ritmo * dt)
	end
	local vida = Stats.HealthRegen.OutOfCombat
	if combate then
		vida = 0
		if estado.ModoCombate == "PvE" then
			vida = Stats.HealthRegen.InCombatPvE
		end
	end
	return vida * dt
end

return Recursos
