-- Services/BossService: combates contra los 3 jefes del MVP (B4, sección 8).
-- Sala: parte con la etiqueta «ArenaJefe» (atributo Zona) en el centro; puerta: parte «PuertaJefe» (atributo Zona).
-- Flujo: alguien se apunta en la puerta -> cuenta atrás de 10 s en la que se apuntan más (máx. 8) -> el número de
-- jugadores queda fijado (F25) -> 3 fases con ataques avisados en el suelo, ataque letal con zonas seguras,
-- ventanas de vulnerabilidad, furia a los 12 min -> botín por jugador con al menos el 5 % del daño.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Shared = game:GetService("ReplicatedStorage").Shared
local Weapons = require(Shared.Config.Weapons)
local Bosses = require(Shared.Config.Bosses)
local Boxes = require(Shared.Config.Boxes)
local Dano = require(Shared.Formulas.Dano)
local Jefe = require(Shared.Reglas.Jefe)
local Misiones = require(Shared.Reglas.Misiones)
local Rarezas = require(Shared.Visual.Rarezas)
local Nombres = require(Shared.Visual.Nombres)
local Server = script.Parent.Parent
local Combate = require(Server.Reglas.Combate)
local Lugares = require(Server.Util.Lugares)
local Eventos = require(Server.Util.Eventos)

local BossService = {}

local Datos, StatsSvc, Combat, Enemigos, Economia, Progression, Analitica, Red
local salas = {}     -- [zona] = { Centro, Puerta, Estado, Participantes, ... }
local azar = Random.new()
local B = Weapons.Boss

local function aviso(jugadores, texto, color)
	for jugador in pairs(jugadores) do
		if jugador.Parent then
			Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color })
		end
	end
end

-- Marca en el suelo (roja: peligro; verde: zona segura). Disco plano de radio r.
local function marca(posicion, radio, color, segundos, altura)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Cylinder
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = 0.55
	p.Size = Vector3.new(altura or 0.3, radio * 2, radio * 2)
	p.CFrame = CFrame.new(posicion) * CFrame.Angles(0, 0, math.rad(90))
	p.Parent = workspace
	Debris:AddItem(p, segundos)
	return p
end

local function rectangulo(desde, hacia, ancho, color, segundos)
	local largo = (hacia - desde).Magnitude
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = 0.55
	p.Size = Vector3.new(ancho, 0.3, largo)
	p.CFrame = CFrame.lookAt((desde + hacia) / 2, hacia)
	p.Parent = workspace
	Debris:AddItem(p, segundos)
end

local ROJO, VERDE = Color3.fromRGB(255, 50, 50), Color3.fromRGB(60, 255, 120)

local function vivos(sala)
	local lista = {}
	for jugador in pairs(sala.Participantes) do
		local pos = Lugares.posicion(jugador)
		if jugador.Parent and pos and (pos - sala.Centro).Magnitude <= Bosses.Arena.Radius + 30 then
			table.insert(lista, jugador)
		end
	end
	return lista
end

local function suelo(sala, pos)
	return Vector3.new(pos.X, sala.Centro.Y + 0.2, pos.Z)
end

-- ¿Está la posición dentro de la forma del ataque?
local function dentro(forma, ataque, jefe, pos, objetivoPos)
	local raiz = jefe.Raiz
	local rel = Vector3.new(pos.X - raiz.Position.X, 0, pos.Z - raiz.Position.Z)
	local frente = Vector3.new(raiz.CFrame.LookVector.X, 0, raiz.CFrame.LookVector.Z).Unit
	if forma == "Arc" then
		return rel.Magnitude <= ataque.Radius and (rel.Magnitude < 1 or rel.Unit:Dot(frente) > 0.3)
	elseif forma == "Behind" then
		return rel.Magnitude <= ataque.Radius and (rel.Magnitude < 1 or rel.Unit:Dot(frente) < -0.3)
	elseif forma == "Around" then
		return rel.Magnitude <= ataque.Radius
	elseif forma == "OnPlayer" then
		return (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(objetivoPos.X, 0, objetivoPos.Z)).Magnitude <= ataque.Radius
	elseif forma == "Line" then
		local a = rel:Dot(frente)
		return a >= 0 and a <= ataque.Length and (rel - frente * a).Magnitude <= ataque.Width / 2
	end
	return false
end

local function dibujarAtaque(sala, forma, ataque, jefe, objetivoPos, segundos)
	local raiz = jefe.Raiz
	local frente = Vector3.new(raiz.CFrame.LookVector.X, 0, raiz.CFrame.LookVector.Z).Unit
	if forma == "Arc" then
		marca(suelo(sala, raiz.Position + frente * ataque.Radius * 0.5), ataque.Radius * 0.6, ROJO, segundos)
	elseif forma == "Behind" then
		marca(suelo(sala, raiz.Position - frente * ataque.Radius * 0.5), ataque.Radius * 0.6, ROJO, segundos)
	elseif forma == "Around" then
		marca(suelo(sala, raiz.Position), ataque.Radius, ROJO, segundos)
	elseif forma == "OnPlayer" then
		marca(suelo(sala, objetivoPos), ataque.Radius, ROJO, segundos)
	elseif forma == "Line" then
		rectangulo(suelo(sala, raiz.Position), suelo(sala, raiz.Position + frente * ataque.Length), ataque.Width, ROJO, segundos)
	end
end

local function tiempoCombate(sala)
	return os.clock() - sala.Inicio
end

-- Golpe normal o fuerte con aviso.
local function atacar(sala, tipo)
	local jefe = sala.Jefe
	local def = sala.Def
	local ataque = tipo == "Normal" and def.Normal or def.Heavy
	local candidatos = vivos(sala)
	if #candidatos == 0 or not jefe.Raiz then
		return
	end
	local objetivo = candidatos[azar:NextInteger(1, #candidatos)]
	local objetivoPos = Lugares.posicion(objetivo)
	if not objetivoPos then
		return
	end
	if def.Moves or ataque.Shape ~= "OnPlayer" then
		jefe.Modelo:PivotTo(CFrame.lookAt(jefe.Raiz.Position, Vector3.new(objetivoPos.X, jefe.Raiz.Position.Y, objetivoPos.Z)))
	end
	local espera = B.Telegraph[tipo]
	jefe.Modelo:SetAttribute("Preparando", true)
	dibujarAtaque(sala, ataque.Shape, ataque, jefe, objetivoPos, espera)
	task.wait(espera)
	if sala.Jefe ~= jefe or jefe.Vida <= 0 then
		return
	end
	jefe.Modelo:SetAttribute("Preparando", false)
	local dano = Jefe.danoAtaque(sala.Zona, tipo, sala.N, tiempoCombate(sala))
	for _, jugador in ipairs(vivos(sala)) do
		local pos = Lugares.posicion(jugador)
		if pos and dentro(ataque.Shape, ataque, jefe, pos, objetivoPos) then
			-- El golpe normal se puede bloquear de frente; el fuerte solo se evita saliendo de la marca.
			Combat.DanarJugador(jugador, dano, tipo == "Normal" and jefe or nil)
			if ataque.Slow then
				StatsSvc.FijarMultiplicadorVelocidad(jugador, 1 - ataque.Slow)
				task.delay(2, function()
					StatsSvc.FijarMultiplicadorVelocidad(jugador, 1)
				end)
			end
		end
	end
	if tipo == "Normal" then
		sala.Normales = sala.Normales + 1
		if sala.Fase == 1 and sala.Normales % def.StuckAfterNormals == 0 then
			sala.VulnerableHasta = os.clock() + Bosses.StuckSeconds
			aviso(sala.Participantes, def.Name .. " se ha quedado atascado: ¡ataca ahora!", Color3.fromRGB(255, 230, 120))
		end
	end
end

-- Ataque letal: toda la sala salvo unas zonas seguras. Si nadie recibe el golpe, 6 s de vulnerabilidad.
local function letal(sala)
	local def = sala.Def
	local oleadas = def.Lethal.Double[sala.Fase] and 2 or 1
	local alguien = false
	for ola = 1, oleadas do
		if sala.Jefe == nil then
			return
		end
		local seguras = {}
		for _ = 1, def.Lethal.Safe[sala.Fase] or 3 do
			local ang = azar:NextNumber(0, math.pi * 2)
			local r = azar:NextNumber(10, Bosses.Arena.Radius - 10)
			local pos = sala.Centro + Vector3.new(math.cos(ang) * r, 0, math.sin(ang) * r)
			table.insert(seguras, pos)
			marca(suelo(sala, pos) + Vector3.new(0, 0.05, 0), Bosses.SafeZoneRadius, VERDE, B.Telegraph.Lethal, 0.4)
		end
		marca(suelo(sala, sala.Centro), Bosses.Arena.Radius, ROJO, B.Telegraph.Lethal)
		aviso(sala.Participantes, "¡" .. def.Lethal.Name .. "! Ponte en una zona verde", ROJO)
		task.wait(B.Telegraph.Lethal)
		if sala.Jefe == nil or sala.Jefe.Vida <= 0 then
			return
		end
		local dano = Jefe.danoAtaque(sala.Zona, "Lethal", sala.N, tiempoCombate(sala))
		for _, jugador in ipairs(vivos(sala)) do
			local pos = Lugares.posicion(jugador)
			local salvo = false
			for _, s in ipairs(seguras) do
				if (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(s.X, 0, s.Z)).Magnitude <= Bosses.SafeZoneRadius then
					salvo = true
				end
			end
			if not salvo then
				alguien = true
				Combat.DanarJugador(jugador, dano, nil)
			end
		end
		if ola < oleadas then
			task.wait(3)
		end
	end
	if not alguien then
		sala.VulnerableHasta = os.clock() + B.VulnerableSeconds
		aviso(sala.Participantes, "¡Nadie ha caído! " .. def.Name .. " está expuesto 6 s (+50 % de daño)", Color3.fromRGB(255, 230, 120))
	end
end

local function crearJefe(sala)
	local def = sala.Def
	local t = def.Size
	local modelo = Instance.new("Model")
	modelo.Name = def.Name
	local raiz = Instance.new("Part")
	raiz.Name = "HumanoidRootPart"
	raiz.Size = Vector3.new(t * 1.2, t, t * 0.8)
	raiz.Color = Color3.fromRGB(def.Color[1], def.Color[2], def.Color[3])
	raiz.Material = Enum.Material.Slate
	raiz.Anchored = true
	raiz.CFrame = CFrame.new(sala.Centro + Vector3.new(0, t / 2 + 0.5, 0))
	raiz.Parent = modelo
	local cabeza = Instance.new("Part")
	cabeza.Shape = Enum.PartType.Ball
	cabeza.Size = Vector3.new(t * 0.7, t * 0.7, t * 0.7)
	cabeza.Color = raiz.Color:Lerp(Color3.new(1, 1, 1), 0.2)
	cabeza.Material = Enum.Material.Rock
	cabeza.Anchored = true
	cabeza.CanCollide = false
	cabeza.CFrame = raiz.CFrame * CFrame.new(0, t * 0.65, 0)
	cabeza.Parent = modelo
	for _, lado in ipairs({ -1, 1 }) do
		local ojo = Instance.new("Part")
		ojo.Size = Vector3.new(t * 0.12, t * 0.12, 0.3)
		ojo.Material = Enum.Material.Neon
		ojo.Color = Color3.fromRGB(255, 80, 60)
		ojo.Anchored = true
		ojo.CanCollide = false
		ojo.CFrame = cabeza.CFrame * CFrame.new(lado * t * 0.15, t * 0.05, -t * 0.34)
		ojo.Parent = modelo
	end
	modelo.PrimaryPart = raiz
	local cartel = Instance.new("BillboardGui")
	cartel.Size = UDim2.new(0, 260, 0, 40)
	cartel.StudsOffset = Vector3.new(0, t * 1.2, 0)
	cartel.MaxDistance = 150
	local nombre = Instance.new("TextLabel")
	nombre.BackgroundTransparency = 1
	nombre.Size = UDim2.new(1, 0, 0, 22)
	nombre.Font = Enum.Font.GothamBlack
	nombre.TextScaled = true
	nombre.TextColor3 = Color3.fromRGB(255, 200, 80)
	nombre.TextStrokeTransparency = 0.2
	nombre.Text = def.Name
	nombre.Parent = cartel
	local fondo = Instance.new("Frame")
	fondo.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	fondo.BorderSizePixel = 0
	fondo.Position = UDim2.new(0.05, 0, 0, 26)
	fondo.Size = UDim2.new(0.9, 0, 0, 10)
	fondo.Parent = cartel
	local barra = Instance.new("Frame")
	barra.BackgroundColor3 = Color3.fromRGB(214, 64, 69)
	barra.BorderSizePixel = 0
	barra.Size = UDim2.fromScale(1, 1)
	barra.Parent = fondo
	cartel.Parent = raiz
	local vida = Jefe.vida(sala.Zona, sala.N)
	modelo:SetAttribute("Tipo", "Boss")
	modelo:SetAttribute("Zona", sala.Zona)
	modelo:SetAttribute("Vida", vida)
	modelo:SetAttribute("VidaMax", vida)
	modelo.Parent = workspace
	return Enemigos.Registrar({ Tipo = "Boss", Zona = sala.Zona, Jefe = true, Vida = vida, VidaMax = vida, Modelo = modelo, Raiz = raiz, Barra = barra, MultDano = 1 })
end

local function moverJefe(sala, jefe)
	if not sala.Def.Moves or not jefe.Raiz then
		return
	end
	local candidatos = vivos(sala)
	if #candidatos == 0 then
		return
	end
	local pos = Lugares.posicion(candidatos[1])
	if not pos then
		return
	end
	local actual = jefe.Raiz.Position
	local hacia = Vector3.new(pos.X - actual.X, 0, pos.Z - actual.Z)
	if hacia.Magnitude > 10 then
		local paso = hacia.Unit * math.min(hacia.Magnitude - 8, 1.6)
		local nueva = actual + paso
		local desdeCentro = Vector3.new(nueva.X - sala.Centro.X, 0, nueva.Z - sala.Centro.Z)
		if desdeCentro.Magnitude <= Bosses.Arena.Radius - 6 then
			jefe.Modelo:PivotTo(CFrame.lookAt(nueva, Vector3.new(pos.X, nueva.Y, pos.Z)))
		end
	end
end

local function enviarEstado(sala, extra)
	local jefe = sala.Jefe
	local datos = extra or {
		Zone = sala.Zona, Name = sala.Def.Name, Health = jefe and jefe.Vida or 0, Max = jefe and jefe.VidaMax or 1, Phase = sala.Fase,
		Vulnerable = os.clock() < (sala.VulnerableHasta or 0), Invulnerable = os.clock() < (sala.InvulnerableHasta or 0),
		Enrage = Jefe.furia(tiempoCombate(sala)), Players = sala.N,
	}
	for jugador in pairs(sala.Participantes) do
		if jugador.Parent then
			Red:obtener("Boss.State"):FireClient(jugador, datos)
		end
	end
end

local function terminar(sala, victoria)
	if sala.Jefe and not victoria then
		Enemigos.Retirar(sala.Jefe.Id)
	end
	for _, id in ipairs(sala.Invocados or {}) do
		Enemigos.Retirar(id)
	end
	enviarEstado(sala, { Zone = sala.Zona, Ended = true, Victory = victoria })
	if not victoria then
		aviso(sala.Participantes, sala.Def.Name .. " se ha reiniciado", ROJO)
	end
	sala.Jefe, sala.Estado, sala.Participantes, sala.Invocados = nil, "Espera", {}, {}
end

local function combate(sala)
	local def = sala.Def
	sala.Inicio = os.clock()
	sala.Fase, sala.Normales = 1, 0
	sala.VulnerableHasta, sala.InvulnerableHasta = 0, 0
	sala.Invocados = {}
	local jefe = crearJefe(sala)
	sala.Jefe = jefe
	aviso(sala.Participantes, "¡" .. def.Name .. " despierta! (" .. sala.N .. " jugador" .. (sala.N > 1 and "es" or "") .. ")", Color3.fromRGB(255, 200, 80))
	local proximoAtaque = os.clock() + 2
	local proximoLetal, proximaInvocacion = math.huge, math.huge
	local turno = 0
	while sala.Jefe == jefe and jefe.Vida > 0 do
		local ahora = os.clock()
		if #vivos(sala) == 0 then
			terminar(sala, false)
			return
		end
		-- Fases e invulnerabilidad al cambiar.
		local fase = Jefe.fase(jefe.Vida, jefe.VidaMax)
		if fase > sala.Fase then
			sala.Fase = fase
			sala.InvulnerableHasta = ahora + Bosses.PhaseInvulnerableSeconds
			aviso(sala.Participantes, def.Name .. ": fase " .. fase, Color3.fromRGB(255, 120, 80))
			proximoLetal = ahora + 8
			if fase == 3 and def.Id == "CapatazDePizarra" then
				proximaInvocacion = ahora + 3
			end
		end
		if ahora < sala.InvulnerableHasta then
			jefe.MultDano = 0
		elseif ahora < sala.VulnerableHasta then
			jefe.MultDano = 1 + B.VulnerableBonus
		else
			jefe.MultDano = 1
		end
		jefe.Modelo:SetAttribute("Vulnerable", jefe.MultDano > 1)
		moverJefe(sala, jefe)
		if ahora >= proximoLetal then
			proximoLetal = ahora + Bosses.LethalEverySeconds
			letal(sala)
			proximoAtaque = os.clock() + 1.5
		elseif ahora >= proximoAtaque and ahora >= sala.VulnerableHasta then
			turno = turno + 1
			atacar(sala, turno % 3 == 0 and "Heavy" or "Normal")
			proximoAtaque = os.clock() + Bosses.AttackEverySeconds[sala.Fase]
		end
		if ahora >= proximaInvocacion then
			proximaInvocacion = ahora + Bosses.Adds.EverySeconds
			for i = 1, Bosses.Adds.Count do
				local pos = jefe.Raiz.Position + Vector3.new(i == 1 and 8 or -8, -def.Size / 2, 4)
				local e = Enemigos.Invocar(sala.Zona, "Common", pos)
				table.insert(sala.Invocados, e.Id)
			end
		end
		enviarEstado(sala)
		task.wait(0.25)
	end
end

-- Botín al derrotar al jefe (B4 8.4).
local function alMorir(enemigo)
	if not enemigo.Jefe then
		return
	end
	local sala = salas[enemigo.Zona]
	if not sala or sala.Jefe ~= enemigo then
		return
	end
	local total = 0
	for _, d in pairs(enemigo.Danos) do
		total = total + d
	end
	local dia = Misiones.dia(os.time())
	local def = sala.Def
	for userId, d in pairs(enemigo.Danos) do
		local jugador = Players:GetPlayerByUserId(userId)
		local perfil = jugador and Datos.GetProfile(jugador)
		if perfil and Jefe.participa(d, total) then
			local botin = Jefe.botin(perfil.Bosses.Daily, sala.Zona, dia)
			local monedas = math.floor(Dano.enemyCoins(sala.Zona, "Boss") * botin.Mult)
			local xp = math.floor(Dano.enemyXP(sala.Zona, "Boss") * botin.Mult)
			Economia.AddCoins(jugador, monedas, "Jefe")
			Progression.AddXP(jugador, xp, "Jefe")
			Combat.SumarMaestria(jugador, Weapons.Mastery.Points.Boss)
			local textos = { "¡Has derrotado a " .. def.Name .. "!", "+" .. monedas .. " monedas · +" .. xp .. " XP" }
			if botin.Materials > 0 then
				local clave = "z" .. sala.Zona
				perfil.Materials.Boss[clave] = (perfil.Materials.Boss[clave] or 0) + botin.Materials
				table.insert(textos, "+" .. botin.Materials .. " materiales de jefe (" .. botin.Count .. "/" .. B.DailyFullLoot .. " hoy)")
				if azar:NextNumber() < B.CoreDropChance then
					local nucleo = def.Core
					if perfil.Cores[nucleo] then
						local c = perfil.Cores[nucleo]
						local r = { Level = c.Mastery, XP = c.XP }
						Combate.sumarMaestria(r, Boxes.Boxes.Core.DuplicateMasteryPoints)
						c.Mastery, c.XP = r.Level, r.XP
					else
						perfil.Cores[nucleo] = { Mastery = 1, XP = 0, Awakened = false }
					end
					table.insert(textos, "¡Ha soltado el " .. (Nombres.Nucleo[nucleo] or nucleo) .. "!")
				end
			else
				table.insert(textos, "Botín reducido: ya has hecho las " .. B.DailyFullLoot .. " de hoy")
			end
			Datos.Replicar(jugador, "Materials", "Bosses", "Cores")
			Eventos.emitir("JefeDerrotado", jugador, 1, { Zone = sala.Zona })
			Analitica.Registrar(jugador, "JefeDerrotado", sala.Zona, def.Id)
			for _, texto in ipairs(textos) do
				Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = Rarezas.color("Legendary") })
			end
		end
	end
	task.defer(terminar, sala, true)
end

-- Apuntarse en la puerta (aviso de proximidad o Remote Boss.Join).
local function unirse(jugador, zona)
	local sala = salas[zona]
	if not sala then
		return false, "jefe"
	end
	local perfil = Datos.GetProfile(jugador)
	if not perfil or perfil.Progress.UnlockedZone < zona then
		return false, "zona"
	end
	local pos = Lugares.posicion(jugador)
	if not pos or (pos - sala.Puerta).Magnitude > Bosses.Arena.GateRadius then
		return false, "lejos"
	end
	if sala.Estado == "Combate" then
		return false, "en_curso"
	end
	sala.Participantes[jugador] = true
	local n = 0
	for _ in pairs(sala.Participantes) do
		n = n + 1
	end
	if n > B.MaxPlayers then
		sala.Participantes[jugador] = nil
		return false, "lleno"
	end
	if sala.Estado == "Espera" then
		sala.Estado = "Cuenta"
		task.spawn(function()
			for s = Bosses.Arena.CountdownSeconds, 1, -1 do
				if s == Bosses.Arena.CountdownSeconds or s <= 3 or s == 5 then
					aviso(sala.Participantes, sala.Def.Name .. " en " .. s .. " s (los que estén en la puerta pueden unirse)")
				end
				task.wait(1)
			end
			local lista = {}
			for j in pairs(sala.Participantes) do
				if j.Parent and Lugares.posicion(j) then
					table.insert(lista, j)
				else
					sala.Participantes[j] = nil
				end
			end
			if #lista == 0 then
				sala.Estado = "Espera"
				return
			end
			sala.N = #lista
			for i, j in ipairs(lista) do
				local ang = (i / #lista) * math.pi * 2
				j.Character:PivotTo(CFrame.new(sala.Centro + Vector3.new(math.cos(ang) * 22, 4, math.sin(ang) * 22), sala.Centro + Vector3.new(0, 4, 0)))
			end
			sala.Estado = "Combate"
			combate(sala)
		end)
	end
	Red:obtener("Notify"):FireClient(jugador, { Text = "Te has apuntado contra " .. sala.Def.Name, Short = true })
	return true
end

local function prepararSala(arena)
	local zona = arena:GetAttribute("Zona")
	local def = Bosses.List[zona]
	if not def or salas[zona] then
		return
	end
	local puerta
	for _, p in ipairs(CollectionService:GetTagged("PuertaJefe")) do
		if p:GetAttribute("Zona") == zona then
			puerta = p
		end
	end
	if not puerta then
		return
	end
	salas[zona] = { Zona = zona, Def = def, Centro = arena.Position, Puerta = puerta.Position, Estado = "Espera", Participantes = {}, Invocados = {} }
	local prompt = puerta:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Enfrentar al jefe"
		prompt.ObjectText = def.Name
		prompt.MaxActivationDistance = 14
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = puerta
	end
	prompt.Triggered:Connect(function(jugador)
		local ok, motivo = unirse(jugador, zona)
		if not ok then
			local textos = { zona = "Necesitas desbloquear esta zona.", en_curso = "Hay un combate en curso: espera a que termine.", lleno = "Ya hay 8 jugadores." }
			Red:obtener("Notify"):FireClient(jugador, { Text = textos[motivo] or "No puedes unirte ahora", Kind = "Warning", Short = true })
		end
	end)
end

function BossService.Iniciar(deps)
	Datos, StatsSvc, Combat, Enemigos = deps.Datos, deps.Stats, deps.Combat, deps.Enemigos
	Economia, Progression, Analitica, Red = deps.Economia, deps.Progression, deps.Analitica, deps.Red
	for _, arena in ipairs(CollectionService:GetTagged("ArenaJefe")) do
		prepararSala(arena)
	end
	Red:conectar("Boss.Join", unirse)
	Enemigos.AlMorir(alMorir)
	Players.PlayerRemoving:Connect(function(jugador)
		for _, sala in pairs(salas) do
			sala.Participantes[jugador] = nil
		end
	end)
end

return BossService
