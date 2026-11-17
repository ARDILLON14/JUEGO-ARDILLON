-- Services/PvPService: reglas entre jugadores (B4 9.1 y 9.4). Solo hay PvP dentro de un «área PvP»
-- (Zona Fracturada o combate de arena). Lleva quién puede atacar a quién, la protección al entrar, los topes de golpe
-- y de ráfaga, y a quién se atribuye cada muerte.
--
-- Los jugadores como objetivo viajan por los Remotes con un id codificado: 1e11 + UserId.
-- API: Entrar(jugador, area) | Salir(jugador) | Area(jugador) | Hostiles(a, b) | Protegido(j) | QuitarProteccion(j)
--      Codificar(userId) | Decodificar(id) | Objetivos(atacante, pos, radio) | EnLinea(atacante, origen, dir, alcance, ancho)
--      TopeGolpe(victima, dano) | AlMatar(fn(asesino, victima, area))

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local PvP = require(Shared.Config.PvP)
local Fracture = require(Shared.Config.Fracture)
local Server = script.Parent.Parent
local Lugares = require(Server.Util.Lugares)

local PvPService = {}

local BASE = 1e11
local areas = {}          -- [jugador] = { Tipo, Clave, Equipo, Zona, NivelSync, PotenciaMax, ProtegidoHasta }
local golpes = {}         -- [victima] = { { T, Dano } } (tope de ráfaga)
local ultimo = {}         -- [victima] = { Atacante, T }
local alMatar = {}

function PvPService.Codificar(userId)
	return BASE + userId
end

function PvPService.Decodificar(id)
	if type(id) == "number" and id >= BASE / 2 then
		return id - BASE
	end
	return nil
end

local function publicar(jugador)
	local personaje = jugador.Character
	if personaje then
		local a = areas[jugador]
		personaje:SetAttribute("PvP", a and a.Clave or nil)
		personaje:SetAttribute("Equipo", a and a.Equipo or nil)
		personaje:SetAttribute("ProtegidoHasta", a and workspace:GetServerTimeNow() + math.max(0, a.ProtegidoHasta - os.clock()) or nil)
	end
end

function PvPService.Entrar(jugador, area)
	area.ProtegidoHasta = area.ProtegidoHasta or (os.clock() + Fracture.Entry.ProtectionSeconds)
	areas[jugador] = area
	golpes[jugador] = {}
	publicar(jugador)
end

function PvPService.Salir(jugador)
	areas[jugador] = nil
	golpes[jugador] = nil
	ultimo[jugador] = nil
	publicar(jugador)
end

function PvPService.Area(jugador)
	return areas[jugador]
end

function PvPService.Proteger(jugador, segundos)
	local a = areas[jugador]
	if a then
		a.ProtegidoHasta = os.clock() + segundos
		publicar(jugador)
	end
end

function PvPService.Protegido(jugador)
	local a = areas[jugador]
	return a ~= nil and os.clock() < a.ProtegidoHasta
end

-- La protección de entrada se pierde al atacar (B3 7.1).
function PvPService.QuitarProteccion(jugador)
	local a = areas[jugador]
	if a and os.clock() < a.ProtegidoHasta then
		a.ProtegidoHasta = 0
		publicar(jugador)
	end
end

function PvPService.Hostiles(a, b)
	if a == b then
		return false
	end
	local x, y = areas[a], areas[b]
	if not x or not y or x.Clave ~= y.Clave then
		return false
	end
	if x.Equipo and y.Equipo and x.Equipo == y.Equipo then
		return false   -- sin fuego amigo
	end
	return not PvPService.Protegido(b)
end

local function entrada(jugador)
	local raiz = Lugares.raiz(jugador)
	if not raiz then
		return nil
	end
	local h = jugador.Character:FindFirstChildOfClass("Humanoid")
	return { Id = BASE + jugador.UserId, Jugador = jugador, Raiz = raiz, Estados = {}, Vida = h and h.Health or 0, Zona = 0 }
end

-- Jugadores hostiles a menos de radio studs, como objetivos para habilidades.
function PvPService.Objetivos(atacante, pos, radio)
	local lista = {}
	if not areas[atacante] then
		return lista
	end
	for _, otro in ipairs(Players:GetPlayers()) do
		if PvPService.Hostiles(atacante, otro) then
			local e = entrada(otro)
			if e and (e.Raiz.Position - pos).Magnitude <= radio + 1.5 then
				table.insert(lista, e)
			end
		end
	end
	return lista
end

function PvPService.EnLinea(atacante, origen, dir, alcance, ancho)
	local lista = {}
	if not areas[atacante] then
		return lista
	end
	for _, otro in ipairs(Players:GetPlayers()) do
		if PvPService.Hostiles(atacante, otro) then
			local e = entrada(otro)
			if e then
				local rel = e.Raiz.Position - origen
				local a = rel:Dot(dir)
				if a >= 0 and a <= alcance + 1.5 and (rel - dir * a).Magnitude <= ancho + 1.5 then
					table.insert(lista, e)
				end
			end
		end
	end
	return lista
end

function PvPService.ObjetivoPorId(atacante, id)
	local userId = PvPService.Decodificar(id)
	local otro = userId and Players:GetPlayerByUserId(userId)
	if otro and PvPService.Hostiles(atacante, otro) then
		return entrada(otro)
	end
	return nil
end

-- Topes PvP: ningún golpe quita más del 35 % de la vida máxima, y nadie pierde más del 60 % en 2 s.
function PvPService.TopeGolpe(victima, atacante, dano, vidaMax)
	dano = math.min(dano, PvP.HitCapFraction * vidaMax)
	local ahora = os.clock()
	local lista = golpes[victima] or {}
	local recientes, suma = {}, 0
	for _, g in ipairs(lista) do
		if ahora - g.T < PvP.BurstCap.WindowSeconds then
			table.insert(recientes, g)
			suma = suma + g.Dano
		end
	end
	dano = math.clamp(dano, 0, math.max(0, PvP.BurstCap.Fraction * vidaMax - suma))
	if dano > 0 then
		table.insert(recientes, { T = ahora, Dano = dano })
	end
	golpes[victima] = recientes
	ultimo[victima] = { Atacante = atacante, T = ahora }
	return dano
end

function PvPService.AlMatar(fn)
	table.insert(alMatar, fn)
end

-- Quién mató al jugador (si un jugador hostil le golpeó en los últimos 5 s).
function PvPService.Asesino(victima)
	local u = ultimo[victima]
	if u and os.clock() - u.T <= Fracture.KillCreditSeconds and u.Atacante.Parent then
		return u.Atacante
	end
	return nil
end

function PvPService.Iniciar()
	local function vigilar(jugador)
		jugador.CharacterAdded:Connect(function(personaje)
			local h = personaje:WaitForChild("Humanoid", 10)
			if not h then
				return
			end
			publicar(jugador)
			h.Died:Connect(function()
				local area = areas[jugador]
				if not area then
					return
				end
				local asesino = PvPService.Asesino(jugador)
				for _, fn in ipairs(alMatar) do
					task.spawn(fn, asesino, jugador, area)
				end
			end)
		end)
	end
	for _, j in ipairs(Players:GetPlayers()) do
		vigilar(j)
	end
	Players.PlayerAdded:Connect(vigilar)
	Players.PlayerRemoving:Connect(function(jugador)
		areas[jugador], golpes[jugador], ultimo[jugador] = nil, nil, nil
	end)
end

return PvPService
