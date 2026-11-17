-- Reglas/Misiones: misiones diarias y tutorial (puro). El día es el número de días desde 1970 (UTC).

local Shared = script.Parent.Parent
local Quests = require(Shared.Config.Quests)
local Economia = require(Shared.Formulas.Economia)
local Progresion = require(Shared.Formulas.Progresion)

local Misiones = {}

Misiones.CATEGORIAS = { "Mining", "Combat", "Pets" }

function Misiones.dia(tiempo)
	return math.floor(tiempo / 86400)
end

local DEF = {}
for categoria, lista in pairs(Quests.Daily) do
	for _, q in ipairs(lista) do
		DEF[q.Id] = { Categoria = categoria, Def = q }
	end
end

function Misiones.definicion(id)
	return DEF[id] and DEF[id].Def
end

-- Si cambió el día, genera las 3 misiones nuevas (una por categoría), deterministas por día y jugador.
-- Devuelve true si se renovaron.
function Misiones.renovar(perfil, dia, semilla)
	local clave = tostring(dia)
	if perfil.Quests.DayKey == clave then
		return false
	end
	perfil.Quests.DayKey = clave
	local lista = {}
	for i, categoria in ipairs(Misiones.CATEGORIAS) do
		local opciones = Quests.Daily[categoria]
		local indice = ((dia * 7 + (semilla or 0) * 13 + i * 31) % #opciones) + 1
		table.insert(lista, { Id = opciones[indice].Id, Progress = 0, Claimed = false })
	end
	perfil.Quests.Daily = lista
	return true
end

-- Suma progreso por un evento. Devuelve la lista de misiones que se acaban de completar.
function Misiones.avanzar(perfil, evento, cantidad)
	local completadas = {}
	for _, q in ipairs(perfil.Quests.Daily or {}) do
		local d = Misiones.definicion(q.Id)
		if d and d.Event == evento and q.Progress < d.Count then
			q.Progress = math.min(d.Count, q.Progress + cantidad)
			if q.Progress >= d.Count then
				table.insert(completadas, q)
			end
		end
	end
	return completadas
end

-- Recompensa de una misión: monedas (horas de ingreso de la zona desbloqueada) y XP.
function Misiones.recompensa(perfil)
	return {
		Coins = math.floor(Quests.DailyRewardHours * Economia.income(perfil.Progress.UnlockedZone) + 0.5),
		XP = math.floor(Quests.DailyXPActions * Progresion.xpPerAction(perfil.Progress.Level)),
	}
end

-- Marca como cobrada. Devuelve la recompensa o nil y el motivo: "mision" | "incompleta" | "cobrada".
function Misiones.cobrar(perfil, id)
	for _, q in ipairs(perfil.Quests.Daily or {}) do
		if q.Id == id then
			local d = Misiones.definicion(id)
			if q.Claimed then
				return nil, "cobrada"
			end
			if q.Progress < d.Count then
				return nil, "incompleta"
			end
			q.Claimed = true
			return Misiones.recompensa(perfil)
		end
	end
	return nil, "mision"
end

-- Tutorial ---------------------------------------------------------------
-- Progress.TutorialStep: 0 = paso 1 sin empezar ... #Tutorial = terminado. Progreso del paso en TutorialCount.
function Misiones.pasoTutorial(perfil)
	local i = (perfil.Progress.TutorialStep or 0) + 1
	return Quests.Tutorial[i], i
end

function Misiones.tutorialTerminado(perfil)
	return (perfil.Progress.TutorialStep or 0) >= #Quests.Tutorial
end

-- Avanza el tutorial con un evento. Devuelve "paso" si pasó al siguiente, "fin" si terminó, o nil.
function Misiones.avanzarTutorial(perfil, evento, cantidad)
	local paso = Misiones.pasoTutorial(perfil)
	if not paso or paso.Event ~= evento then
		return nil
	end
	perfil.Progress.TutorialCount = (perfil.Progress.TutorialCount or 0) + cantidad
	if perfil.Progress.TutorialCount < paso.Count then
		return nil
	end
	perfil.Progress.TutorialStep = (perfil.Progress.TutorialStep or 0) + 1
	perfil.Progress.TutorialCount = 0
	if Misiones.tutorialTerminado(perfil) then
		return "fin"
	end
	return "paso"
end

function Misiones.saltarTutorial(perfil)
	perfil.Progress.TutorialStep = #Quests.Tutorial
	perfil.Progress.TutorialCount = 0
end

return Misiones
