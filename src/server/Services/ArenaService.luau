-- Services/ArenaService: arenas PvP 1 contra 1, 2 contra 2 y 3 contra 3 (B4 9.3). Una arena por servidor.
-- Cola en este servidor, una por modo; se empareja por tramo de 100 niveles y Elo (±100, +50 cada 15 s);
-- en equipos se reparten en serpiente por Elo y el Elo cambia con la media de cada equipo.
-- Todos pelean con el nivel máximo de su tramo y la potencia de arma limitada a la de un Ultra raro de esa zona.
-- Al mejor de 3 rondas de 90 s: gana la ronda el equipo que deja sin nadie en pie al otro; al acabar el tiempo,
-- el que conserve más vida (en proporción). Quien cae en una ronda espera en la grada hasta la siguiente.
-- Solo se arriesga la puntuación. Mapa: «ArenaPvP» (centro), 2 «ArenaInicio» (Lado 1 y 2), «GradaArena» (opcional)
-- y «ColaArena» (atributo Modo; sin él, 1v1).

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
local colas = {}          -- [modo] = { { Jugador, Nivel, Elo, Desde } }
local partida = nil       -- { Modo, Equipos = { {j...}, {j...} }, Rondas = { 0, 0 }, Ronda, Fin, Estado, Caidos = {}, Area }
local inicios = {}        -- [1|2] = Vector3
local grada = nil         -- Vector3
local ORO = Color3.fromRGB(255, 200, 90)

for _, modo in ipairs(PvPConfig.Arena.Modes) do
	colas[modo] = {}
end

local function avisar(jugador, texto, color)
	if jugador and jugador.Parent then
		Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color })
	end
end

local function todos()
	local r = {}
	if partida then
		for _, eq in ipairs(partida.Equipos) do
			for _, j in ipairs(eq) do
				table.insert(r, j)
			end
		end
	end
	return r
end

local function estadoArena(datos)
	for _, j in ipairs(todos()) do
		if j.Parent then
			Red:obtener("Notify"):FireClient(j, { Kind = "Arena", Data = datos })
		end
	end
end

local function equipoDe(jugador)
	if not partida then
		return nil
	end
	for i, eq in ipairs(partida.Equipos) do
		if table.find(eq, jugador) then
			return i
		end
	end
	return nil
end

function ArenaService.EnPartida(jugador)
	return equipoDe(jugador) ~= nil
end

local function enCola(jugador)
	for modo, cola in pairs(colas) do
		for i, c in ipairs(cola) do
			if c.Jugador == jugador then
				return modo, i
			end
		end
	end
	return nil
end

-- Posición de salida: los del mismo equipo, separados 6 studs en línea.
local function colocar(jugador, lado, puesto, cuantos)
	if not jugador.Character or not inicios[lado] then
		return
	end
	local desde, hacia = inicios[lado], inicios[3 - lado]
	local frente = (hacia - desde)
	frente = Vector3.new(frente.X, 0, frente.Z).Unit
	local lateral = frente:Cross(Vector3.yAxis)
	local pos = desde + lateral * ((puesto - (cuantos + 1) / 2) * 6)
	Mover.personaje(jugador.Character, CFrame.lookAt(pos + Vector3.new(0, 3, 0), pos + frente * 10 + Vector3.new(0, 3, 0)))
end

local function aGrada(jugador)
	if jugador.Character and grada then
		Mover.personaje(jugador.Character, CFrame.new(grada + Vector3.new(math.random(-6, 6), 3, math.random(-2, 2))))
	end
end

local function vida(j)
	local h = j.Character and j.Character:FindFirstChildOfClass("Humanoid")
	return h and h.Health / math.max(1, h.MaxHealth) or 0
end

local function vidaEquipo(i)
	local s = 0
	for _, j in ipairs(partida.Equipos[i]) do
		if not partida.Caidos[j] then
			s = s + vida(j)
		end
	end
	return s
end

local function entrarArea(j, lado)
	PvP.Entrar(j, {
		Tipo = "Arena", Clave = "Arena1", Equipo = lado, NivelSync = partida.Area.Nivel,
		PotenciaMax = partida.Area.Potencia, ProtegidoHasta = os.clock() + 3,
	})
end

local function terminarPartida(ganadorEquipo)
	local p = partida
	local modo = p.Modo
	local elos, perfiles = { {}, {} }, { {}, {} }
	for i, eq in ipairs(p.Equipos) do
		for k, j in ipairs(eq) do
			local perfil = Datos.GetProfile(j)
			perfiles[i][k] = perfil
			elos[i][k] = perfil and perfil.Arena.Elo[modo] or PvPConfig.Arena.Elo.Start
		end
	end
	local na, nb = Arena.actualizarEquipos(elos[1], elos[2], ganadorEquipo == 1 and 1 or 0)
	local nuevos = { na, nb }
	for i, eq in ipairs(p.Equipos) do
		for k, j in ipairs(eq) do
			local perfil = perfiles[i][k]
			if perfil then
				perfil.Arena.Elo[modo] = nuevos[i][k]
				Datos.Replicar(j, "Arena")
				avisar(j, (ganadorEquipo == i and "¡Victoria!" or "Derrota") .. " · Elo " .. modo .. " " .. elos[i][k] .. " → " .. nuevos[i][k], ORO)
			end
		end
	end
	estadoArena({ Ended = true })
	local jugadores = todos()
	partida = nil
	for _, j in ipairs(jugadores) do
		if j.Parent then
			PvP.Salir(j)
			StatsSvc.FijarModoPvP(j, nil)
			StatsSvc.Rellenar(j)
			World.Llevar(j, "Ciudad")
		end
	end
	for _, j in ipairs(p.Equipos[ganadorEquipo] or {}) do
		if j.Parent then
			Analitica.Registrar(j, "ArenaGanada", nil, modo)
		end
	end
end

local function ronda()
	local p = partida
	p.Ronda = p.Ronda + 1
	p.Caidos = {}
	for lado, eq in ipairs(p.Equipos) do
		for puesto, j in ipairs(eq) do
			if j.Parent then
				entrarArea(j, lado)
				colocar(j, lado, puesto, #eq)
				StatsSvc.Rellenar(j)
				PvP.Proteger(j, 3)   -- 3 s de cuenta atrás
			end
		end
	end
	p.Fin = os.clock() + 3 + PvPConfig.Arena.RoundSeconds
	p.Estado = "Ronda"
	estadoArena({ Round = p.Ronda, Score = p.Rondas, Ends = workspace:GetServerTimeNow() + 3 + PvPConfig.Arena.RoundSeconds })
	for lado, eq in ipairs(p.Equipos) do
		for _, j in ipairs(eq) do
			local nuestro, suyo = p.Rondas[lado], p.Rondas[3 - lado]
			avisar(j, "Ronda " .. p.Ronda .. " · " .. nuestro .. " - " .. suyo .. " · ¡en 3 s!", ORO)
		end
	end
end

local function finRonda(ganador)
	local p = partida
	if not p or p.Estado ~= "Ronda" then
		return
	end
	p.Estado = "Pausa"
	p.Rondas[ganador] = p.Rondas[ganador] + 1
	local necesarias = math.ceil(PvPConfig.Arena.BestOf / 2)
	if p.Rondas[ganador] >= necesarias then
		terminarPartida(ganador)
		return
	end
	task.delay(3, function()
		if partida == p then
			ronda()
		end
	end)
end

local function enPie(i)
	for _, j in ipairs(partida.Equipos[i]) do
		if j.Parent and not partida.Caidos[j] then
			return true
		end
	end
	return false
end

-- Un jugador cae (muere o se va): fuera de la ronda; si su equipo se queda sin nadie, la ronda es del otro.
local function caer(j)
	local i = equipoDe(j)
	if not i or partida.Estado ~= "Ronda" or partida.Caidos[j] then
		return
	end
	partida.Caidos[j] = true
	PvP.Salir(j)
	if not enPie(i) then
		finRonda(3 - i)
	end
end

local function empezar(modo, entradas)
	local a, b = Arena.repartir(entradas)
	local nivel = 1
	for _, e in ipairs(entradas) do
		nivel = math.max(nivel, e.Nivel)
	end
	nivel = Arena.nivelTramo(nivel)
	local zona = math.clamp(math.floor(nivel / 100), 1, 10)
	partida = {
		Modo = modo, Rondas = { 0, 0 }, Ronda = 0, Estado = "Pausa", Caidos = {},
		Equipos = { {}, {} },
		Area = { Nivel = nivel, Potencia = Potencia.itemPower(zona, PvPConfig.LevelSync.GearCapRarity, PvPConfig.LevelSync.GearCapBonus) },
	}
	for lado, eq in ipairs({ a, b }) do
		for _, e in ipairs(eq) do
			table.insert(partida.Equipos[lado], e.Jugador)
			StatsSvc.FijarModoPvP(e.Jugador, nivel)
			local texto = modo == "1v1" and "¡Rival encontrado!" or "¡Partida " .. modo .. " encontrada! Eres del equipo " .. (lado == 1 and "azul" or "rojo")
			avisar(e.Jugador, texto .. " Al mejor de 3 rondas de 90 s (nivel igualado a " .. nivel .. ")", ORO)
		end
	end
	ronda()
end

local NOMBRE_MODO = { ["1v1"] = "1 contra 1", ["2v2"] = "2 contra 2", ["3v3"] = "3 contra 3" }

local function encolar(jugador, modo)
	if not colas[modo] then
		return false, "modo"
	end
	if enCola(jugador) or ArenaService.EnPartida(jugador) then
		return false, "ya"
	end
	if StatsSvc.EnCombate(jugador) or PvP.Area(jugador) then
		return false, "combate"
	end
	local perfil = Datos.GetProfile(jugador)
	local elo = perfil.Arena.Elo[modo] or PvPConfig.Arena.Elo.Start
	table.insert(colas[modo], { Jugador = jugador, Nivel = perfil.Progress.Level, Elo = elo, Desde = os.clock() })
	local faltan = 2 * Arena.porEquipo(modo) - #colas[modo]
	avisar(jugador, "En cola de arena " .. NOMBRE_MODO[modo] .. " (Elo " .. elo .. ")" .. (faltan > 0 and (" · faltan " .. faltan .. " jugadores") or ""))
	return true
end

local function salirCola(jugador)
	local modo, i = enCola(jugador)
	if modo then
		table.remove(colas[modo], i)
		avisar(jugador, "Has salido de la cola")
	elseif ArenaService.EnPartida(jugador) then
		-- Abandonar: si no queda nadie de su equipo, pierde la partida entera.
		local equipo = equipoDe(jugador)
		local eq = partida.Equipos[equipo]
		table.remove(eq, table.find(eq, jugador))
		PvP.Salir(jugador)
		StatsSvc.FijarModoPvP(jugador, nil)
		if jugador.Parent then
			World.Llevar(jugador, "Ciudad")
		end
		if #eq == 0 then
			terminarPartida(3 - equipo)
		elseif partida.Estado == "Ronda" and not enPie(equipo) then
			finRonda(3 - equipo)
		end
	end
end

local function conectarCola(p)
	local modo = p:GetAttribute("Modo") or "1v1"
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Entrar en la cola " .. modo
	prompt.ObjectText = "Arena " .. NOMBRE_MODO[modo]
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.R
	prompt.Parent = p
	prompt.Triggered:Connect(function(jugador)
		if enCola(jugador) then
			salirCola(jugador)
		else
			local ok, motivo = encolar(jugador, modo)
			if not ok then
				avisar(jugador, ({ combate = "No puedes entrar en combate", ya = "Ya estás en cola o en partida" })[motivo] or "No puedes ahora")
			end
		end
	end)
end

function ArenaService.Iniciar(deps)
	Datos, StatsSvc, PvP, World, Analitica, Red = deps.Datos, deps.Stats, deps.PvP, deps.World, deps.Analitica, deps.Red
	for _, p in ipairs(CollectionService:GetTagged("ArenaInicio")) do
		inicios[p:GetAttribute("Lado")] = p.Position
	end
	for _, p in ipairs(CollectionService:GetTagged("GradaArena")) do
		grada = p.Position
	end
	for _, p in ipairs(CollectionService:GetTagged("ColaArena")) do
		conectarCola(p)
	end
	Red:conectar("Arena.Queue", encolar)
	Red:conectar("Arena.Leave", salirCola)
	PvP.AlMatar(function(asesino, victima, area)
		if area.Tipo == "Arena" and partida then
			caer(victima)
		end
	end)
	-- Al reaparecer: si su equipo sigue en la ronda, a la grada; si no, a su sitio.
	local function vigilar(j)
		j.CharacterAdded:Connect(function()
			task.wait(0.2)
			local lado = equipoDe(j)
			if lado then
				if partida.Estado == "Ronda" and partida.Caidos[j] then
					aGrada(j)
				else
					local eq = partida.Equipos[lado]
					colocar(j, lado, table.find(eq, j), #eq)
				end
			end
		end)
	end
	for _, j in ipairs(Players:GetPlayers()) do
		vigilar(j)
	end
	Players.PlayerAdded:Connect(vigilar)
	Players.PlayerRemoving:Connect(function(j)
		local modo, i = enCola(j)
		if modo then
			table.remove(colas[modo], i)
		end
		if ArenaService.EnPartida(j) then
			salirCola(j)
		end
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			local ahora = os.clock()
			if not partida then
				for _, modo in ipairs(PvPConfig.Arena.Modes) do
					local cola = colas[modo]
					local indices = not partida and Arena.buscar(cola, Arena.porEquipo(modo), ahora)
					if indices then
						table.sort(indices, function(a, b)
							return a > b
						end)
						local entradas = {}
						for _, i in ipairs(indices) do
							table.insert(entradas, table.remove(cola, i))
						end
						empezar(modo, entradas)
					end
				end
			elseif partida.Estado == "Ronda" and ahora >= partida.Fin then
				-- Tiempo: gana el equipo con más vida (en proporción) entre los que siguen en pie.
				finRonda(vidaEquipo(1) >= vidaEquipo(2) and 1 or 2)
			end
		end
	end)
end

return ArenaService
