-- Services/ProgressionService: XP, niveles y desbloqueo de zonas (B2; C_Tecnico, sección 3).
-- API: ProgressionService.AddXP(jugador, cantidad, fuente) -> resultado de Reglas/Niveles.sumarXP
--      ProgressionService.GetLevel(jugador)
--      ProgressionService.AlSubirNivel(fn)   fn(jugador, resultado)
-- La XP la calcula siempre el servidor (minería, enemigos, misiones): el cliente nunca la envía.

local Shared = game:GetService("ReplicatedStorage").Shared
local Stats = require(Shared.Config.Stats)
local Niveles = require(Shared.Reglas.Niveles)

local ProgressionService = {}

local Datos, StatsSvc, Analitica, Red
local alSubir = {}

function ProgressionService.Iniciar(deps)
	Datos, StatsSvc, Analitica, Red = deps.Datos, deps.Stats, deps.Analitica, deps.Red
end

function ProgressionService.GetLevel(jugador)
	local perfil = Datos.GetProfile(jugador)
	return perfil and perfil.Progress.Level or 0
end

function ProgressionService.AlSubirNivel(fn)
	table.insert(alSubir, fn)
end

function ProgressionService.AddXP(jugador, cantidad, fuente)
	local perfil = Datos.GetProfile(jugador)
	if not perfil or type(cantidad) ~= "number" or cantidad ~= cantidad or cantidad <= 0 or cantidad == math.huge then
		return nil
	end
	local r = Niveles.sumarXP(perfil, cantidad)
	if r.Subidos > 0 then
		StatsSvc.Recalcular(jugador)
		if Stats.LevelUpRefill then
			StatsSvc.Rellenar(jugador)
		end
		Analitica.Registrar(jugador, "SubidaNivel", r.Nivel, fuente)
		local aviso = { Kind = "LevelUp", Level = r.Nivel, Points = 3 * r.Subidos }
		if r.Zona > r.ZonaAnterior then
			aviso.Zone = r.Zona
			Analitica.Registrar(jugador, "ZonaDesbloqueada", r.Zona)
		end
		Red:obtener("Notify"):FireClient(jugador, aviso)
		Datos.Replicar(jugador, "Progress", "Stats")
		for _, fn in ipairs(alSubir) do
			task.spawn(fn, jugador, r)
		end
	else
		Datos.Replicar(jugador, "Progress")
	end
	return r
end

return ProgressionService
