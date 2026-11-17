-- Services/WorldService: zonas del mundo, portales, ciudad y reaparición (C_Tecnico, sección 3; A_GDD, sección 5).
-- En esta versión todas las zonas están en un mismo lugar de Roblox y los portales mueven al jugador dentro de él.
-- Cuando se publiquen los mundos como lugares distintos (Worlds.Worlds[i].PlaceId ~= 0), un portal a otro mundo
-- guarda, suelta el perfil y teletransporta con TeleportService (World.Teleport).
--
-- Mapa: partes «Portal» (atributo Destino = número de zona o "Ciudad"), «LlegadaZona» (atributo Zona),
-- «Ciudad» (zona segura: el reinicio de estadísticas y cambiar de Núcleo son gratis ahí).
--
-- API: ZonaDe(jugador) | EnCiudad(jugador) | Viajar(jugador, destino)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Worlds = require(Shared.Config.Worlds)
local Server = script.Parent.Parent
local Mover = require(Server.Util.Mover)
local Lugares = require(Server.Util.Lugares)

local WorldService = {}

local Datos, StatsSvc, Analitica, Red
local llegadas = {}     -- [zona] = Vector3 ; ["Ciudad"] = Vector3
local ultimaZona = {}   -- [jugador] = zona o "Ciudad"
local RADIO_CIUDAD = 45

local function nombreZona(z)
	for _, info in ipairs(Worlds.Zones) do
		if info.Id == z then
			return info.Name
		end
	end
	return "Zona " .. tostring(z)
end
WorldService.NombreZona = nombreZona

local function mundoDe(zona)
	for _, w in ipairs(Worlds.Worlds) do
		if table.find(w.Zones, zona) then
			return w
		end
	end
	return nil
end

function WorldService.EnCiudad(jugador)
	local pos = Lugares.posicion(jugador)
	if not pos then
		return false
	end
	for _, parte in ipairs(CollectionService:GetTagged("Ciudad")) do
		if parte:IsA("BasePart") and (parte.Position - pos).Magnitude <= RADIO_CIUDAD then
			return true
		end
	end
	return false
end

function WorldService.ZonaDe(jugador)
	return ultimaZona[jugador] or "Ciudad"
end

-- destino: número de zona o "Ciudad". Devuelve true, o false y el motivo: "zona" | "destino" | "combate".
function WorldService.Viajar(jugador, destino)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return false, "perfil"
	end
	if type(destino) == "number" and perfil.Progress.UnlockedZone < destino then
		return false, "zona"
	end
	if StatsSvc.EnCombate(jugador) then
		return false, "combate"
	end
	-- Otro mundo publicado como lugar aparte: guardar, soltar el perfil y teletransportar.
	local mundo = type(destino) == "number" and mundoDe(destino)
	if mundo and mundo.PlaceId ~= 0 and mundo.PlaceId ~= game.PlaceId then
		local liberado = Datos.Liberar(jugador)
		if not liberado then
			return false, "guardado"
		end
		local ok = pcall(function()
			TeleportService:TeleportAsync(mundo.PlaceId, { jugador })
		end)
		return ok, ok and nil or "teletransporte"
	end
	local llegada = llegadas[destino]
	if not llegada then
		return false, "destino"
	end
	Mover.personaje(jugador.Character, CFrame.new(llegada + Vector3.new(0, 3, 0)))
	ultimaZona[jugador] = destino
	Analitica.Registrar(jugador, "Viaje", nil, tostring(destino))
	local texto = destino == "Ciudad" and "Puerto Veta" or nombreZona(destino)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Short = false, Color = Color3.fromRGB(255, 230, 160) })
	return true
end

-- Llevar sin comprobaciones (al terminar una partida de arena o salir de la grieta).
function WorldService.Llevar(jugador, destino)
	local llegada = llegadas[destino]
	if llegada and jugador.Character then
		Mover.personaje(jugador.Character, CFrame.new(llegada + Vector3.new(0, 3, 0)))
		ultimaZona[jugador] = destino
	end
end

local function conectarPortal(parte)
	local destino = parte:GetAttribute("Destino")
	if destino == nil then
		return
	end
	local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Viajar"
		prompt.ObjectText = destino == "Ciudad" and "Puerto Veta" or nombreZona(destino)
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.KeyboardKeyCode = Enum.KeyCode.R
		prompt.Parent = parte
	end
	prompt.Triggered:Connect(function(jugador)
		local ok, motivo = WorldService.Viajar(jugador, destino)
		if not ok then
			local textos = { zona = "Aún no has desbloqueado esta zona (nivel " .. ((tonumber(destino) or 1) - 1) * 100 .. ").",
				combate = "No puedes viajar en combate." }
			Red:obtener("Notify"):FireClient(jugador, { Text = textos[motivo] or "No puedes viajar ahora", Kind = "Warning", Short = true })
		end
	end)
end

function WorldService.Iniciar(deps)
	Datos, StatsSvc, Analitica, Red = deps.Datos, deps.Stats, deps.Analitica, deps.Red
	for _, p in ipairs(CollectionService:GetTagged("LlegadaZona")) do
		local z = p:GetAttribute("Zona")
		if z ~= nil then
			llegadas[z] = p.Position
		end
	end
	for _, p in ipairs(CollectionService:GetTagged("Portal")) do
		conectarPortal(p)
	end
	CollectionService:GetInstanceAddedSignal("Portal"):Connect(conectarPortal)
	-- Reinicio de estadísticas solo en la ciudad (P2-06).
	StatsSvc.FijarLugarReinicio(WorldService.EnCiudad)
	-- World.Teleport (otros mundos publicados): mismo camino que los portales.
	Red:conectar("World.Teleport", function(jugador, worldId)
		for _, w in ipairs(Worlds.Worlds) do
			if w.Id == worldId then
				return WorldService.Viajar(jugador, w.Zones[1])
			end
		end
		if worldId == Worlds.Hub.Id then
			return WorldService.Viajar(jugador, "Ciudad")
		end
		return false, "destino"
	end)
	-- Reaparición en la entrada de la última zona visitada (B3, sección 8).
	Players.PlayerAdded:Connect(function(jugador)
		jugador.CharacterAdded:Connect(function(personaje)
			local z = ultimaZona[jugador]
			if type(z) == "number" and llegadas[z] then
				task.wait(0.2)
				Mover.personaje(personaje, CFrame.new(llegadas[z] + Vector3.new(0, 3, 0)))
			end
		end)
	end)
	Players.PlayerRemoving:Connect(function(jugador)
		ultimaZona[jugador] = nil
	end)
end

return WorldService
