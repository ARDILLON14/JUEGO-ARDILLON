-- Services/ArenaService: arena PvP 1 contra 1 (B4 9.3). Roadmap fase 8: una arena.
-- Cola en este servidor; se empareja por tramo de 100 niveles y Elo (±100, +50 cada 15 s). Todos pelean con el nivel
-- máximo de su tramo y la potencia de arma limitada a la de un Ultra raro de esa zona al máximo. Al mejor de 3 rondas
-- de 90 s. Solo se arriesga la puntuación. Mapa: «ArenaPvP» (centro), 2 «ArenaInicio» (Lado 1 y 2), «ColaArena».

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local PvPConfig = require(Shared.Config.PvP)
local Potencia = require(Shared.Formulas.Potencia)
local Arena = require(Shared.Reglas.Arena)
local Server = script.Parent.Parent
local Mover = require(Server.Util.Mover)

local ArenaService = {}

local Datos, StatsSvc, PvP, World, Analitica, Red
local cola = {}           -- { { Jugador, Nivel, Elo, Desde } }
local partida = nil       -- { Jugadores = { a, b }, Rondas = { 0, 0 }, Ronda, Fin, Estado }
local inicios = {}        -- [1|2] = Vector3

local function avisar(jugador, texto, color)
	if jugador and jugador.Parent then
		Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color })
	end
end

local function estadoArena(datos)
	if not partida then
		return
	end
	for _, j in ipairs(partida.Jugadores) do
		if j.Parent then
			Red:obtener("Notify"):FireClient(j, { Kind = "Arena", Data = datos })
		end
	end
end

function ArenaService.EnPartida(jugador)
	return partida ~= nil and table.find(partida.Jugadores, jugador) ~= nil
end

local function enCola(jugador)
	for i, c in ipairs(cola) do
		if c.Jugador == jugador then
			return i
		end
	end
	return nil
end

local function colocar(jugador, lado)
	if jugador.Character and inicios[lado] then
		Mover.personaje(jugador.Character, CFrame.lookAt(inicios[lado] + Vector3.new(0, 3, 0), inicios[3 - lado] + Vector3.new(0, 3, 0)))
	end
end

local function vida(j)
	local h = j.Character and j.Character:FindFirstChildOfClass("Humanoid")
	return h and h.Health / math.max(1, h.MaxHealth) or 0
end

local function terminarPartida(ganador)
	local a, b = partida.Jugadores[1], partida.Jugadores[2]
	local pa, pb = Datos.GetProfile(a), Datos.GetProfile(b)
	if pa and pb then
		local ea, eb = pa.Arena.Elo["1v1"] or PvPConfig.Arena.Elo.Start, pb.Arena.Elo["1v1"] or PvPConfig.Arena.Elo.Start
		local na, nb = Arena.actualizar(ea, eb, ganador == a and 1 or 0)
		pa.Arena.Elo["1v1"], pb.Arena.Elo["1v1"] = na, nb
		Datos.Replicar(a, "Arena")
		Datos.Replicar(b, "Arena")
		avisar(a, (ganador == a and "¡Victoria!" or "Derrota") .. " · Elo " .. ea .. " → " .. na, Color3.fromRGB(255, 200, 90))
		avisar(b, (ganador == b and "¡Victoria!" or "Derrota") .. " · Elo " .. eb .. " → " .. nb, Color3.fromRGB(255, 200, 90))
	end
	estadoArena({ Ended = true })
	local jugadores = partida.Jugadores
	partida = nil
	for _, j in ipairs(jugadores) do
		if j.Parent then
			PvP.Salir(j)
			StatsSvc.FijarModoPvP(j, nil)
			StatsSvc.Rellenar(j)
			World.Llevar(j, "Ciudad")
		end
	end
	Analitica.Registrar(ganador, "ArenaGanada")
end

local function ronda()
	local p = partida
	p.Ronda = p.Ronda + 1
	for lado, j in ipairs(p.Jugadores) do
		colocar(j, lado)
		StatsSvc.Rellenar(j)
		PvP.Proteger(j, 3)   -- 3 s de cuenta atrás
	end
	p.Fin = os.clock() + 3 + PvPConfig.Arena.RoundSeconds
	p.Estado = "Ronda"
	estadoArena({ Round = p.Ronda, Score = p.Rondas, Ends = workspace:GetServerTimeNow() + 3 + PvPConfig.Arena.RoundSeconds })
	for _, j in ipairs(p.Jugadores) do
		avisar(j, "Ronda " .. p.Ronda .. " · " .. p.Rondas[1] .. " - " .. p.Rondas[2] .. " · ¡en 3 s!", Color3.fromRGB(255, 200, 90))
	end
end

local function finRonda(ganador)
	local p = partida
	if not p or p.Estado ~= "Ronda" then
		return
	end
	p.Estado = "Pausa"
	local i = table.find(p.Jugadores, ganador)
	if i then
		p.Rondas[i] = p.Rondas[i] + 1
	end
	local necesarias = math.ceil(PvPConfig.Arena.BestOf / 2)
	if p.Rondas[1] >= necesarias or p.Rondas[2] >= necesarias then
		terminarPartida(p.Rondas[1] > p.Rondas[2] and p.Jugadores[1] or p.Jugadores[2])
		return
	end
	task.delay(3, function()
		if partida == p then
			ronda()
		end
	end)
end

local function empezar(a, b)
	partida = { Jugadores = { a.Jugador, b.Jugador }, Rondas = { 0, 0 }, Ronda = 0, Estado = "Pausa" }
	local nivel = Arena.nivelTramo(math.max(a.Nivel, b.Nivel))
	local zona = math.clamp(math.floor(nivel / 100), 1, 10)
	for lado, c in ipairs({ a, b }) do
		PvP.Entrar(c.Jugador, {
			Tipo = "Arena", Clave = "Arena1", Equipo = lado, NivelSync = nivel,
			PotenciaMax = Potencia.itemPower(zona, PvPConfig.LevelSync.GearCapRarity, PvPConfig.LevelSync.GearCapBonus),
			ProtegidoHasta = os.clock() + 3,
		})
		StatsSvc.FijarModoPvP(c.Jugador, nivel)
		avisar(c.Jugador, "¡Rival encontrado! Al mejor de 3 rondas de 90 s (nivel igualado a " .. nivel .. ")", Color3.fromRGB(255, 200, 90))
	end
	ronda()
end

local function encolar(jugador, modo)
	if modo ~= "1v1" then
		return false, "modo"   -- 2v2 y 3v3 en una fase posterior
	end
	if enCola(jugador) or ArenaService.EnPartida(jugador) then
		return false, "ya"
	end
	if StatsSvc.EnCombate(jugador) or PvP.Area(jugador) then
		return false, "combate"
	end
	local perfil = Datos.GetProfile(jugador)
	table.insert(cola, { Jugador = jugador, Nivel = perfil.Progress.Level, Elo = perfil.Arena.Elo["1v1"] or PvPConfig.Arena.Elo.Start, Desde = os.clock() })
	avisar(jugador, "En cola de arena 1 contra 1 (Elo " .. (perfil.Arena.Elo["1v1"] or 1000) .. ")")
	return true
end

local function salirCola(jugador)
	local i = enCola(jugador)
	if i then
		table.remove(cola, i)
		avisar(jugador, "Has salido de la cola")
	elseif ArenaService.EnPartida(jugador) then
		local otro = partida.Jugadores[1] == jugador and partida.Jugadores[2] or partida.Jugadores[1]
		terminarPartida(otro)   -- abandonar cuenta como derrota
	end
end

function ArenaService.Iniciar(deps)
	Datos, StatsSvc, PvP, World, Analitica, Red = deps.Datos, deps.Stats, deps.PvP, deps.World, deps.Analitica, deps.Red
	for _, p in ipairs(CollectionService:GetTagged("ArenaInicio")) do
		inicios[p:GetAttribute("Lado")] = p.Position
	end
	for _, p in ipairs(CollectionService:GetTagged("ColaArena")) do
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Entrar en la cola 1v1"
		prompt.ObjectText = "Arena"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = p
		prompt.Triggered:Connect(function(jugador)
			if enCola(jugador) then
				salirCola(jugador)
			else
				local ok, motivo = encolar(jugador, "1v1")
				if not ok then
					avisar(jugador, ({ combate = "No puedes entrar en combate", ya = "Ya estás en cola o en partida" })[motivo] or "No puedes ahora")
				end
			end
		end)
	end
	Red:conectar("Arena.Queue", encolar)
	Red:conectar("Arena.Leave", salirCola)
	PvP.AlMatar(function(asesino, victima, area)
		if area.Tipo == "Arena" and partida and table.find(partida.Jugadores, victima) then
			local otro = partida.Jugadores[1] == victima and partida.Jugadores[2] or partida.Jugadores[1]
			finRonda(otro)
		end
	end)
	-- Tras morir en una ronda se reaparece en la arena.
	local function vigilar(j)
		j.CharacterAdded:Connect(function()
			task.wait(0.2)
			if partida and ArenaService.EnPartida(j) then
				colocar(j, table.find(partida.Jugadores, j))
			end
		end)
	end
	for _, j in ipairs(Players:GetPlayers()) do
		vigilar(j)
	end
	Players.PlayerAdded:Connect(vigilar)
	Players.PlayerRemoving:Connect(function(j)
		local i = enCola(j)
		if i then
			table.remove(cola, i)
		end
		if ArenaService.EnPartida(j) then
			local otro = partida.Jugadores[1] == j and partida.Jugadores[2] or partida.Jugadores[1]
			terminarPartida(otro)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			local ahora = os.clock()
			if not partida then
				for i = 1, #cola do
					for k = i + 1, #cola do
						if not partida and Arena.compatibles(cola[i], cola[k], ahora) then
							local a, b = cola[i], cola[k]
							table.remove(cola, k)
							table.remove(cola, i)
							empezar(a, b)
						end
					end
				end
			elseif partida.Estado == "Ronda" and ahora >= partida.Fin then
				-- Tiempo: gana quien conserve más vida (en proporción).
				local a, b = partida.Jugadores[1], partida.Jugadores[2]
				finRonda(vida(a) >= vida(b) and a or b)
			end
		end
	end)
end

ArenaService.Server = Server
return ArenaService
