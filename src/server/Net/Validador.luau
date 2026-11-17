-- Net/Validador: crea los Remotes y envuelve cada manejador con la validación común (C_Tecnico, 5.1):
--   1. límite de frecuencia   2. tipos y rangos (esquema)   3. perfil cargado
-- La propiedad de objetos y el resto de reglas de cada operación las comprueba el servicio que la atiende.
-- Dependencias inyectadas (para poder probarlo fuera de Roblox):
--   Limite        = LimiteFrecuencia.nuevo()
--   PerfilCargado = function(jugador) -> boolean
--   Marcar        = function(jugador, motivo, remote, detalle)   aviso para AntiCheatService

local Shared = game:GetService("ReplicatedStorage").Shared
local Remotes = require(Shared.Net.Remotes)
local Esquemas = require(Shared.Net.Esquemas)

local Validador = {}
Validador.__index = Validador

function Validador.nuevo(deps)
	assert(deps and deps.Limite and deps.PerfilCargado, "Validador: faltan dependencias")
	return setmetatable({
		_limite = deps.Limite,
		_perfilCargado = deps.PerfilCargado,
		_marcar = deps.Marcar or function() end,
		_instancias = {},
		_conectados = {},
		_studio = deps.Studio == true,   -- crea y admite también Remotes.SoloStudio
	}, Validador)
end

-- Validación común de una llamada. Devuelve true y la lista de argumentos, o false y el motivo:
-- "desconocido", "frecuencia", "esquema" o "sin_perfil".
function Validador:_definicion(nombre)
	local def = Remotes.ClientToServer[nombre]
	if not def and self._studio then
		def = Remotes.SoloStudio[nombre]
	end
	return def
end

function Validador:comprobar(jugador, nombre, ...)
	local def = self:_definicion(nombre)
	if not def then
		return false, "desconocido"
	end
	if not self._limite:consumir(jugador.UserId, nombre, def.Rate) then
		return false, "frecuencia"
	end
	local ok, args = Esquemas.validar(def.Params, ...)
	if not ok then
		self._marcar(jugador, "esquema", nombre, args)
		return false, "esquema"
	end
	if not self._perfilCargado(jugador) then
		return false, "sin_perfil"
	end
	return true, args
end

-- Crea la carpeta y todas las instancias. Se llama una vez al arrancar el servidor.
function Validador:crear(padre)
	local carpeta = Instance.new("Folder")
	carpeta.Name = Remotes.FolderName
	local definiciones = {}
	for nombre, def in pairs(Remotes.ClientToServer) do
		definiciones[nombre] = def
	end
	if self._studio then
		for nombre, def in pairs(Remotes.SoloStudio) do
			definiciones[nombre] = def
		end
	end
	for nombre, def in pairs(definiciones) do
		local remote = Instance.new(def.Kind == "Function" and "RemoteFunction" or "RemoteEvent")
		remote.Name = nombre
		remote.Parent = carpeta
		self._instancias[nombre] = remote
	end
	for _, nombre in ipairs(Remotes.ServerToClient) do
		local remote = Instance.new("RemoteEvent")
		remote.Name = nombre
		remote.Parent = carpeta
		self._instancias[nombre] = remote
	end
	-- Un RemoteFunction sin manejador dejaría al cliente esperando: se responde "no disponible" hasta que su servicio se conecte.
	for nombre, def in pairs(definiciones) do
		if def.Kind == "Function" then
			self._instancias[nombre].OnServerInvoke = function()
				return false, "no_disponible"
			end
		end
	end
	carpeta.Parent = padre
	return carpeta
end

-- true si este validador admite el Remote (los de Studio solo existen en Studio).
function Validador:existe(nombre)
	return self:_definicion(nombre) ~= nil
end

-- Conecta el manejador de un Remote del cliente al servidor: manejador(jugador, ...args ya validados).
-- En los RemoteFunction, lo que devuelva el manejador vuelve al cliente; si se rechaza, devuelve false y el motivo.
function Validador:conectar(nombre, manejador)
	local def = self:_definicion(nombre)
	assert(def, "Remote desconocido: " .. tostring(nombre))
	assert(not self._conectados[nombre], "Remote ya conectado: " .. nombre)
	local remote = self._instancias[nombre]
	assert(remote, "Validador:crear no se ha llamado")
	self._conectados[nombre] = true
	local n = #def.Params
	if def.Kind == "Function" then
		remote.OnServerInvoke = function(jugador, ...)
			local ok, args = self:comprobar(jugador, nombre, ...)
			if not ok then
				return false, args
			end
			return manejador(jugador, table.unpack(args, 1, n))
		end
	else
		remote.OnServerEvent:Connect(function(jugador, ...)
			local ok, args = self:comprobar(jugador, nombre, ...)
			if ok then
				manejador(jugador, table.unpack(args, 1, n))
			end
		end)
	end
end

-- Remote del servidor al cliente, para FireClient / FireAllClients.
function Validador:obtener(nombre)
	local remote = self._instancias[nombre]
	assert(remote, "Remote inexistente: " .. tostring(nombre))
	return remote
end

function Validador:olvidar(jugador)
	self._limite:olvidar(jugador.UserId)
end

return Validador
