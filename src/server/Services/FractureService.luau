-- Services/FractureService: Zonas Fracturadas (B3 sección 7; B6 sección 7). Roadmap fase 8: la grieta de la zona 3.
-- Mapa: «EntradaGrieta» (Zona) en la zona PvE; dentro, «LlegadaGrieta» (Zona), «SalidaGrieta» (Zona),
-- 3 «PuntoExtraccion» (Zona) y una Mina con atributo Grieta = true.
--
-- Mientras está dentro, el mineral va a Minerals.Fractured, la carga ralentiza, hay PvP (PvPService) y se ve en
-- la interfaz cuánto se perdería al morir. Al extraer (8 s junto al punto activo, el daño lo reinicia) todo va al
-- banco con el bono de ×1,5 × racha en monedas. Morir contra un jugador suelta la mitad (un cuarto con Seguro).

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Fracture = require(Shared.Config.Fracture)
local Rarity = require(Shared.Config.Rarity)
local PvPConfig = require(Shared.Config.PvP)
local Mining = require(Shared.Config.Mining)
local Mineria = require(Shared.Formulas.Mineria)
local Potencia = require(Shared.Formulas.Potencia)
local Fractura = require(Shared.Reglas.Fractura)
local Misiones = require(Shared.Reglas.Misiones)
local Inventario = require(Shared.Reglas.Inventario)
local Rarezas = require(Shared.Visual.Rarezas)
local Server = script.Parent.Parent
local Mover = require(Server.Util.Mover)
local Lugares = require(Server.Util.Lugares)
local Eventos = require(Server.Util.Eventos)

local FractureService = {}

local Datos, StatsSvc, PvP, Inventory, Mining_, Combat, Economia, Analitica, Red
local grietas = {}     -- [zona] = { Llegada, Salida, Puntos = { parte }, Activo = n, Cambio = t, Aviso }
local dentro = {}      -- [jugador] = { Zona, Asegurado, Canal = { Tipo, Fin }, CercaPunto = s }
local cofres = {}      -- [parte] = { Contenido, Asesino, ExclusivoHasta, Zona }

local function avisar(jugador, texto, color, corto)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color, Short = corto })
end

function FractureService.EnGrieta(jugador)
	return dentro[jugador] ~= nil
end

local function zonaDe(jugador)
	local d = dentro[jugador]
	return d and d.Zona
end

local function publicar(jugador, carga)
	local personaje = jugador.Character
	if personaje then
		personaje:SetAttribute("EnGrieta", dentro[jugador] ~= nil)
		personaje:SetAttribute("Carga", carga or 0)
	end
end

local function salirEstado(jugador)
	dentro[jugador] = nil
	PvP.Salir(jugador)
	StatsSvc.FijarModoPvP(jugador, nil)
	StatsSvc.FijarMultiplicadorVelocidad(jugador, 1)
	publicar(jugador, 0)
	Red:obtener("Fracture.State"):FireClient(jugador, { Inside = false })
end

-- Llevar fuera de la grieta (a la entrada PvE de su zona).
local function sacar(jugador, zona)
	local g = grietas[zona]
	salirEstado(jugador)
	if g and jugador.Character then
		Mover.personaje(jugador.Character, CFrame.new(g.Fuera + Vector3.new(0, 3, 0)))
	end
end

-- Fracture.Enter --------------------------------------------------------
local function entrar(jugador, zona, asegurar, confirmado)
	local g = grietas[zona]
	if not g or not table.find(Fracture.EnabledZones, zona) then
		return false, "grieta"
	end
	if not confirmado then
		return false, "confirmar"
	end
	if dentro[jugador] then
		return false, "dentro"
	end
	local perfil = Datos.GetProfile(jugador)
	if perfil.Progress.UnlockedZone < zona or perfil.Progress.Level < Mineria.zoneLevel(zona) then
		return false, "zona"
	end
	local pico = Inventario.equipado(perfil, "Pickaxe")
	if not pico or Inventario.potencia(pico) < Mineria.pickPowerReq(zona) then
		return false, "pico"
	end
	if os.time() - (perfil.Fracture.LastDeath or 0) < Fracture.Entry.ReentrySeconds then
		return false, "espera"
	end
	if StatsSvc.EnCombate(jugador) then
		return false, "combate"
	end
	local asegurado = false
	if asegurar then
		if not Fractura.puedeAsegurar(perfil, Misiones.dia(os.time())) then
			return false, "seguro"
		end
		Fractura.asegurar(perfil)
		asegurado = true
	end
	perfil.Fracture.Entries = (perfil.Fracture.Entries or 0) + 1
	Fractura.renovarContratos(perfil, Misiones.dia(os.time()))
	dentro[jugador] = { Zona = zona, Asegurado = asegurado, CercaPunto = 0 }
	PvP.Entrar(jugador, {
		Tipo = "Grieta", Clave = "Grieta" .. zona, Zona = zona,
		NivelSync = PvPConfig.LevelSync.LevelsPerZone * zona,
		PotenciaMax = Potencia.itemPower(zona, PvPConfig.LevelSync.GearCapRarity, PvPConfig.LevelSync.GearCapBonus),
	})
	StatsSvc.FijarModoPvP(jugador, PvPConfig.LevelSync.LevelsPerZone * zona)
	Mover.personaje(jugador.Character, CFrame.new(g.Llegada + Vector3.new(0, 3, 0)))
	Datos.Replicar(jugador, "Fracture", "Consumables", "Quests")
	local textos = { "Zona Fracturada: PvP siempre activo. Solo arriesgas el mineral que picas aquí." }
	if perfil.Fracture.Entries <= Fracture.Entry.NoviceEntriesWithoutLoss then
		table.insert(textos, "Protección de novato: entrada " .. perfil.Fracture.Entries .. " de " .. Fracture.Entry.NoviceEntriesWithoutLoss .. " sin pérdidas")
	elseif perfil.Fracture.Entries == Fracture.Entry.NoviceEntriesWithoutLoss + 1 then
		table.insert(textos, "Se acabó la protección de novato: desde ahora, morir contra un jugador suelta la mitad de tu carga")
	end
	if asegurado then
		table.insert(textos, "Seguro de carga activo: solo soltarías un 25 %")
	end
	for _, t in ipairs(textos) do
		avisar(jugador, t, Color3.fromRGB(255, 110, 90))
	end
	return true
end

-- Extraer y salir --------------------------------------------------------
local function canalizar(jugador, tipo, segundos, posicion, radio, alTerminar)
	local d = dentro[jugador]
	if not d or d.Canal then
		return
	end
	local personaje = jugador.Character
	local inicio = os.clock()
	local fin = inicio + segundos
	d.Canal = { Tipo = tipo, Fin = workspace:GetServerTimeNow() + segundos, Segundos = segundos }
	while os.clock() < fin do
		task.wait(0.2)
		local pos = Lugares.posicion(jugador)
		local dano = personaje and personaje:GetAttribute("UltimoDano")
		if dentro[jugador] ~= d or not pos or (pos - posicion).Magnitude > radio or (dano and dano > inicio) then
			if dentro[jugador] == d then
				d.Canal = nil
				avisar(jugador, tipo == "Extract" and "Extracción interrumpida" or "Salida interrumpida", Color3.fromRGB(255, 90, 90), true)
			end
			return
		end
	end
	d.Canal = nil
	alTerminar()
end

local function extraer(jugador)
	local d = dentro[jugador]
	if not d then
		return
	end
	local g = grietas[d.Zona]
	local punto = g.Puntos[g.Activo]
	local pos = Lugares.posicion(jugador)
	if not pos or (pos - punto.Position).Magnitude > Fracture.ExtractRadius + 2 then
		avisar(jugador, "Ve al Punto de Extracción activo", nil, true)
		return
	end
	canalizar(jugador, "Extract", Fracture.Extraction.ChannelSeconds, punto.Position, Fracture.ExtractRadius + 2, function()
		local perfil = Datos.GetProfile(jugador)
		local valor = Fractura.valor(perfil)
		local r = Fractura.extraer(perfil)
		if r.Bono > 0 then
			Economia.AddCoins(jugador, r.Bono, "Extraccion")
		end
		perfil.Fracture.SeasonExtractedValue = (perfil.Fracture.SeasonExtractedValue or 0) + valor
		for _, c in ipairs(Fractura.avanzarContratos(perfil, "Extraccion", r)) do
			local pago = Fractura.recompensaContrato(perfil)
			c.Claimed = true
			Economia.AddCoins(jugador, pago, "Contrato")
			avisar(jugador, "Contrato de grieta cumplido: +" .. pago .. " monedas", Color3.fromRGB(255, 230, 120))
		end
		avisar(jugador, string.format("¡Extracción! %d unidades al banco (×%.2f) · +%d monedas · racha %d", r.Unidades, r.Multiplicador, r.Bono, perfil.Fracture.Streak),
			Color3.fromRGB(120, 255, 160))
		Analitica.Registrar(jugador, "Extraccion", r.Bono, tostring(r.Unidades))
		Eventos.emitir("Extraccion", jugador, r.Unidades)
		Datos.Replicar(jugador, "Minerals", "Fracture", "Quests")
		task.spawn(Datos.GuardarAhora, jugador)   -- C_Tecnico 6.4: guardado inmediato tras extraer
		sacar(jugador, d.Zona)
	end)
end

local function salir(jugador)
	local d = dentro[jugador]
	if not d then
		return
	end
	local g = grietas[d.Zona]
	canalizar(jugador, "Exit", Fracture.Exit.ChannelSeconds, g.Salida, 12, function()
		local n = Fractura.salirSinExtraer(Datos.GetProfile(jugador))
		if n > 0 then
			avisar(jugador, "Has salido sin extraer: " .. n .. " unidades al banco a ×1,0", nil, true)
		end
		Datos.Replicar(jugador, "Minerals")
		sacar(jugador, d.Zona)
	end)
end

-- Cofres de Saqueo -------------------------------------------------------
local function crearCofre(zona, posicion, contenido, asesino)
	local parte = Instance.new("Part")
	parte.Name = "CofreDeSaqueo"
	parte.Size = Vector3.new(3, 2.4, 2.2)
	parte.Color = Color3.fromRGB(190, 140, 60)
	parte.Material = Enum.Material.Wood
	parte.Anchored = true
	parte.CanCollide = false
	parte.Position = posicion
	local luz = Instance.new("PointLight")
	luz.Color = Color3.fromRGB(255, 200, 90)
	luz.Range = 12
	luz.Parent = parte
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Abrir cofre"
	prompt.ObjectText = "Cofre de Saqueo"
	prompt.HoldDuration = Fracture.Chest.OpenSeconds
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.KeyboardKeyCode = Enum.KeyCode.R
	prompt.Parent = parte
	local c = { Contenido = contenido, Asesino = asesino, ExclusivoHasta = os.clock() + Fracture.Chest.ExclusiveSeconds, Zona = zona }
	cofres[parte] = c
	local inicioPorJugador = {}
	prompt.PromptButtonHoldBegan:Connect(function(jugador)
		inicioPorJugador[jugador] = os.clock()
	end)
	prompt.Triggered:Connect(function(jugador)
		if not dentro[jugador] then
			return
		end
		if os.clock() < c.ExclusivoHasta and jugador ~= c.Asesino then
			avisar(jugador, "Este cofre es de quien derrotó a su dueño durante unos segundos", nil, true)
			return
		end
		local dano = jugador.Character and jugador.Character:GetAttribute("UltimoDano")
		if dano and inicioPorJugador[jugador] and dano > inicioPorJugador[jugador] then
			avisar(jugador, "Te han golpeado: apertura interrumpida", Color3.fromRGB(255, 90, 90), true)
			return
		end
		local recogido = 0
		for id, n in pairs(c.Contenido) do
			local entra = Inventory.AddMineral(jugador, id, n)
			recogido = recogido + entra
			c.Contenido[id] = (n - entra > 0) and (n - entra) or nil
		end
		Datos.Replicar(jugador, "Minerals")
		avisar(jugador, "Has saqueado " .. recogido .. " unidades (aún hay que extraerlas)", Color3.fromRGB(255, 200, 90), true)
		if next(c.Contenido) == nil then
			parte:Destroy()
		end
	end)
	parte.Destroying:Connect(function()
		cofres[parte] = nil
	end)
	parte.Parent = workspace
	task.delay(Fracture.Chest.Seconds, function()
		if parte.Parent then
			parte:Destroy()
		end
	end)
end

-- Muertes dentro de la grieta --------------------------------------------
local function alMorir(asesino, victima, area)
	if area.Tipo ~= "Grieta" then
		return
	end
	local d = dentro[victima]
	local perfil = Datos.GetProfile(victima)
	if not d or not perfil then
		return
	end
	local zona = d.Zona
	local raiz = victima.Character and victima.Character:FindFirstChild("HumanoidRootPart")
	local posicion = raiz and raiz.Position or grietas[zona].Llegada
	local cargaAntes = Fractura.carga(perfil, zona)
	if asesino and Datos.GetProfile(asesino) then
		local pa = Datos.GetProfile(asesino)
		local misma = Fractura.mismaVictima(pa.Fracture.Victims, victima.UserId, os.time())
		local r = Fractura.muertePvP(perfil, zona, {
			Asegurado = d.Asegurado, MismaVictima = misma, Recompensa = (perfil.Fracture.Streak or 0) >= Fracture.Streak.BountyAtStreak,
		})
		if next(r.Cofre) then
			crearCofre(zona, posicion, r.Cofre, asesino)
		end
		perfil.Fracture.LastKiller = { UserId = asesino.UserId, Time = os.time() }
		if asesino.Character then
			asesino.Character:SetAttribute("Venganza", tostring(victima.UserId))
			task.delay(Fracture.Revenge.MarkSeconds, function()
				if asesino.Character and asesino.Character:GetAttribute("Venganza") == tostring(victima.UserId) then
					asesino.Character:SetAttribute("Venganza", nil)
				end
			end)
		end
		if cargaAntes >= Fracture.Contracts.CarrierMinLoad then
			for _, c in ipairs(Fractura.avanzarContratos(pa, "Portador", {})) do
				local pago = Fractura.recompensaContrato(pa)
				c.Claimed = true
				Economia.AddCoins(asesino, pago, "Contrato")
				avisar(asesino, "Contrato de grieta cumplido: +" .. pago .. " monedas", Color3.fromRGB(255, 230, 120))
			end
		end
		avisar(victima, asesino.DisplayName .. " te ha derrotado y ha soltado " .. r.Soltadas .. " unidades (" .. r.Destruidas .. " destruidas)", Color3.fromRGB(255, 90, 90))
		avisar(asesino, "Has derrotado a " .. victima.DisplayName .. (next(r.Cofre) and ": ¡su cofre te espera!" or ""), Color3.fromRGB(255, 200, 90), true)
		Datos.Replicar(asesino, "Fracture", "Quests")
		Analitica.Registrar(victima, "MuertePvP", r.Soltadas)
	else
		Fractura.muertePvE(perfil)
	end
	perfil.Fracture.Streak = 0
	perfil.Fracture.LastDeath = os.time()
	Datos.Replicar(victima, "Minerals", "Fracture")
	salirEstado(victima)
end

-- Bucle: carga, ralentización, estado para la interfaz, puntos de extracción y anti-acampada.
local function paso(dt)
	local ahora = os.clock()
	for zona, g in pairs(grietas) do
		if ahora >= g.Cambio - Fracture.Extraction.WarningSeconds and not g.Aviso then
			g.Aviso = true
			for j, d in pairs(dentro) do
				if d.Zona == zona then
					avisar(j, "El Punto de Extracción cambiará de sitio en 30 s", Color3.fromRGB(255, 230, 120), true)
				end
			end
		end
		if ahora >= g.Cambio then
			g.Puntos[g.Activo]:SetAttribute("Activo", false)
			local siguiente = g.Activo
			while siguiente == g.Activo and #g.Puntos > 1 do
				siguiente = math.random(1, #g.Puntos)
			end
			g.Activo, g.Cambio, g.Aviso = siguiente, ahora + Fracture.Extraction.RelocateMinutes * 60, false
			g.Puntos[g.Activo]:SetAttribute("Activo", true)
		end
	end
	for jugador, d in pairs(dentro) do
		local perfil = Datos.GetProfile(jugador)
		if perfil and jugador.Parent then
			local g = grietas[d.Zona]
			local carga = Fractura.carga(perfil, d.Zona)
			StatsSvc.FijarMultiplicadorVelocidad(jugador, 1 - Fractura.lentitud(carga))
			publicar(jugador, math.floor(carga * 10) / 10)
			local punto = g.Puntos[g.Activo]
			local pos = Lugares.posicion(jugador)
			-- Anti-acampada: 60 s cerca del punto activo sin extraer -> marcado para todos.
			if pos and (pos - punto.Position).Magnitude <= Fracture.AntiCamp.Radius and not (d.Canal and d.Canal.Tipo == "Extract") then
				d.CercaPunto = d.CercaPunto + dt
			else
				d.CercaPunto = 0
			end
			if jugador.Character then
				jugador.Character:SetAttribute("Acampando", d.CercaPunto >= Fracture.AntiCamp.Seconds)
			end
			Red:obtener("Fracture.State"):FireClient(jugador, {
				Inside = true, Zone = d.Zona, Load = carga, Slow = Fractura.lentitud(carga), Streak = perfil.Fracture.Streak or 0,
				Loss = Fractura.perdidaPosible(perfil, d.Zona, d.Asegurado), Insured = d.Asegurado, Units = Fractura.unidades(perfil),
				Capacity = Fractura.capacidad(perfil, Inventory.ExtraMochila(jugador)), Point = punto.Position,
				NextChange = math.max(0, g.Cambio - ahora), Protected = PvP.Protegido(jugador), Channel = d.Canal,
				Multiplier = Mineria.fracturedMultiplier(perfil.Fracture.Streak or 0, true), Novice = Fractura.protegido(perfil, 99),
				Contracts = perfil.Quests.Contracts,
			})
		end
	end
end

local function conectarPrompt(parte, accion, objeto, fn)
	local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = accion
		prompt.ObjectText = objeto
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = parte
	end
	prompt.Triggered:Connect(fn)
end

function FractureService.Iniciar(deps)
	Datos, StatsSvc, PvP, Inventory, Mining_ = deps.Datos, deps.Stats, deps.PvP, deps.Inventory, deps.Mining
	Combat, Economia, Analitica, Red = deps.Combat, deps.Economia, deps.Analitica, deps.Red
	for _, p in ipairs(CollectionService:GetTagged("LlegadaGrieta")) do
		local z = p:GetAttribute("Zona")
		grietas[z] = grietas[z] or { Puntos = {} }
		grietas[z].Llegada = p.Position
	end
	for _, p in ipairs(CollectionService:GetTagged("SalidaGrieta")) do
		local z = p:GetAttribute("Zona")
		if grietas[z] then
			grietas[z].Salida = p.Position
			conectarPrompt(p, "Salir sin extraer (3 s)", "Salida de la grieta", function(jugador)
				salir(jugador)
			end)
		end
	end
	for _, p in ipairs(CollectionService:GetTagged("PuntoExtraccion")) do
		local z = p:GetAttribute("Zona")
		if grietas[z] then
			table.insert(grietas[z].Puntos, p)
			conectarPrompt(p, "Extraer (8 s)", "Punto de Extracción", function(jugador)
				if p:GetAttribute("Activo") then
					extraer(jugador)
				else
					avisar(jugador, "Este punto no está activo ahora", nil, true)
				end
			end)
		end
	end
	for _, p in ipairs(CollectionService:GetTagged("EntradaGrieta")) do
		local z = p:GetAttribute("Zona")
		if grietas[z] then
			grietas[z].Fuera = p.Position + Vector3.new(0, 0, -8)
			conectarPrompt(p, "Entrar", "Zona Fracturada", function(jugador)
				local perfil = Datos.GetProfile(jugador)
				Red:obtener("Notify"):FireClient(jugador, { Kind = "OpenFracture", Zone = z, Insurance = perfil.Consumables.CargoInsurance or 0,
					Entries = perfil.Fracture.Entries or 0, Novice = Fracture.Entry.NoviceEntriesWithoutLoss, Streak = perfil.Fracture.Streak or 0 })
			end)
		end
	end
	for z, g in pairs(grietas) do
		if #g.Puntos > 0 then
			g.Activo, g.Cambio = 1, os.clock() + Fracture.Extraction.RelocateMinutes * 60
			g.Puntos[1]:SetAttribute("Activo", true)
		end
		print(string.format("OREBOUND: Zona Fracturada de la zona %d con %d puntos de extracción", z, #g.Puntos))
	end
	Red:conectar("Fracture.Enter", entrar)
	Red:conectar("Fracture.Extract", function(jugador, empezar)
		if empezar then
			extraer(jugador)
		end
	end)
	Red:conectar("Fracture.Exit", function(jugador, empezar)
		if empezar then
			salir(jugador)
		end
	end)
	Red:conectar("Quest.SwapContract", function(jugador, id)
		local ok, motivo = Fractura.cambiarContrato(Datos.GetProfile(jugador), id)
		if ok then
			Datos.Replicar(jugador, "Quests")
		end
		return ok, motivo
	end)
	Inventory.FijarGrieta(FractureService.EnGrieta)
	Mining_.FijarMultXP(function(jugador)
		return dentro[jugador] and Fracture.XPMultiplier or 1
	end)
	Combat.FijarRecargoMovilidad(function(jugador)
		local d = dentro[jugador]
		local perfil = d and Datos.GetProfile(jugador)
		if perfil and Fractura.carga(perfil, d.Zona) >= Fracture.Load.MobilityEnergySurchargeAtLoad then
			return 1 + Fracture.Load.MobilityEnergySurcharge
		end
		return 1
	end)
	PvP.AlMatar(alMorir)
	-- Desconectarse dentro: si estaba en combate cuenta como muerte PvE; si no, como salir sin extraer.
	Datos.AlSalir(function(jugador, perfil)
		if dentro[jugador] then
			if StatsSvc.EnCombate(jugador) then
				Fractura.muertePvE(perfil)
				perfil.Fracture.Streak = 0
			end
			Fractura.salirSinExtraer(perfil)
			dentro[jugador] = nil
		end
	end)
	Players.PlayerRemoving:Connect(function(jugador)
		dentro[jugador] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			local ok, err = pcall(paso, 0.5)
			if not ok then
				warn("FractureService: " .. tostring(err))
			end
		end
	end)
end

FractureService.Rarity, FractureService.Rarezas, FractureService.Mining = Rarity, Rarezas, Mining
return FractureService
