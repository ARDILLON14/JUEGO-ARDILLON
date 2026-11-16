-- Datos/AlmacenPerfiles: carga, guardado y liberación de perfiles con sesión bloqueada (C_Tecnico, 6.2 a 6.4).
-- No usa servicios de Roblox directamente: todo entra por dependencias, así se prueba fuera del motor.
--   Almacen  = objeto con UpdateAsync (DataStore "Perfiles")
--   Copias   = objeto con SetAsync (DataStore "PerfilesCopia")
--   Reloj    = function() -> segundos de época (os.time)
--   Esperar  = function(segundos) (task.wait)
--   JobId, PlaceId = identidad de este servidor
--   Registrar = function(evento, userId, detalle) opcional (analítica)
-- Garantías:
--   * Nunca se crea un perfil vacío sobre un fallo de lectura ni sobre datos que no se entienden.
--   * Solo escribe quien tiene el bloqueo: cada guardado lo comprueba dentro de UpdateAsync.
--   * Un servidor antiguo no carga perfiles de una versión mayor.

local PlantillaPerfil = require(script.Parent.PlantillaPerfil)
local Migraciones = require(script.Parent.Migraciones)

local AlmacenPerfiles = {}
AlmacenPerfiles.__index = AlmacenPerfiles

AlmacenPerfiles.SESION_CADUCA = 30 * 60       -- s sin renovarse para dar la sesión por muerta
AlmacenPerfiles.BLOQUEO_REINTENTO = 5         -- s entre intentos si otro servidor tiene el perfil
AlmacenPerfiles.BLOQUEO_MAXIMO = 30           -- s en total antes de rendirse
AlmacenPerfiles.ESPERAS = { 2, 4, 8 }         -- s entre reintentos tras un error del almacén

function AlmacenPerfiles.nuevo(deps)
	assert(deps.Almacen and deps.Copias and deps.Reloj and deps.Esperar, "AlmacenPerfiles: faltan dependencias")
	assert(type(deps.JobId) == "string" and deps.JobId ~= "", "AlmacenPerfiles: JobId vacío")
	return setmetatable({
		_almacen = deps.Almacen,
		_copias = deps.Copias,
		_reloj = deps.Reloj,
		_esperar = deps.Esperar,
		_jobId = deps.JobId,
		_placeId = deps.PlaceId or 0,
		_registrar = deps.Registrar or function() end,
		_migraciones = deps.Migraciones,          -- solo pruebas
		_version = deps.Version or PlantillaPerfil.Version,
		_perfiles = {},                           -- [userId] = { Clave, Datos, Cargado, UltimoGuardado, Guardando }
	}, AlmacenPerfiles)
end

function AlmacenPerfiles.clave(userId)
	return "u_" .. tostring(userId)
end

-- Llama a fn con reintentos (2, 4 y 8 s). Devuelve ok y el resultado o el error.
function AlmacenPerfiles:_conReintentos(fn)
	local ultimo
	for intento = 1, #AlmacenPerfiles.ESPERAS + 1 do
		local ok, resultado = pcall(fn)
		if ok then
			return true, resultado
		end
		ultimo = resultado
		local espera = AlmacenPerfiles.ESPERAS[intento]
		if espera then
			self._esperar(espera)
		end
	end
	return false, ultimo
end

function AlmacenPerfiles:_sesionPropia()
	return { JobId = self._jobId, PlaceId = self._placeId, Time = self._reloj() }
end

-- Un intento de tomar el bloqueo. Devuelve estado y datos:
-- "cargado" | "nuevo" | "bloqueado" | "version_futura" | "corrupto" | "fallo_lectura"
function AlmacenPerfiles:_tomarBloqueo(clave)
	local estado
	local ok, datos = self:_conReintentos(function()
		return self._almacen:UpdateAsync(clave, function(actual)
			local ahora = self._reloj()
			if actual == nil then
				estado = "nuevo"
				local perfil = PlantillaPerfil.nuevo(ahora)
				perfil.Version = self._version
				perfil.Meta.Session = self:_sesionPropia()
				return perfil
			end
			if type(actual) ~= "table" or type(actual.Version) ~= "number" then
				estado = "corrupto"
				return nil
			end
			if actual.Version > self._version then
				estado = "version_futura"
				return nil
			end
			if type(actual.Meta) ~= "table" then
				actual.Meta = {}
			end
			local s = actual.Meta.Session
			if type(s) == "table" and type(s.JobId) == "string" and s.JobId ~= "" and s.JobId ~= self._jobId
				and ahora - (tonumber(s.Time) or 0) < AlmacenPerfiles.SESION_CADUCA then
				estado = "bloqueado"
				return nil
			end
			estado = "cargado"
			actual.Meta.Session = self:_sesionPropia()
			return actual
		end)
	end)
	if not ok then
		return "fallo_lectura", nil
	end
	return estado, datos
end

function AlmacenPerfiles:_soltarBloqueo(clave)
	self:_conReintentos(function()
		return self._almacen:UpdateAsync(clave, function(actual)
			if type(actual) ~= "table" or type(actual.Meta) ~= "table" or type(actual.Meta.Session) ~= "table"
				or actual.Meta.Session.JobId ~= self._jobId then
				return nil
			end
			actual.Meta.Session = PlantillaPerfil.copiar(PlantillaPerfil.SesionVacia)
			return actual
		end)
	end)
end

-- Carga el perfil y toma el bloqueo de sesión. Puede tardar (hasta 30 s si otro servidor lo tiene).
-- Devuelve los datos (la tabla viva que modifican los servicios), o nil y el motivo:
-- "ya_cargado" | "bloqueado" | "version_futura" | "corrupto" | "fallo_lectura" | "fallo_copia" | "fallo_migracion"
function AlmacenPerfiles:cargar(userId)
	if self._perfiles[userId] then
		return nil, "ya_cargado"
	end
	local clave = AlmacenPerfiles.clave(userId)
	local esperado, estado, datos = 0, nil, nil
	while true do
		estado, datos = self:_tomarBloqueo(clave)
		if estado ~= "bloqueado" or esperado >= AlmacenPerfiles.BLOQUEO_MAXIMO then
			break
		end
		self._esperar(AlmacenPerfiles.BLOQUEO_REINTENTO)
		esperado = esperado + AlmacenPerfiles.BLOQUEO_REINTENTO
	end
	if estado ~= "cargado" and estado ~= "nuevo" then
		self._registrar("FalloCarga", userId, estado)
		return nil, estado
	end

	if datos.Version < self._version then
		-- Copia de seguridad antes de migrar; sin copia no se migra.
		local nombreCopia = clave .. "_v" .. tostring(datos.Version) .. "_" .. tostring(self._reloj())
		local okCopia = self:_conReintentos(function()
			return self._copias:SetAsync(nombreCopia, datos)
		end)
		if not okCopia then
			self:_soltarBloqueo(clave)
			self._registrar("FalloCarga", userId, "fallo_copia")
			return nil, "fallo_copia"
		end
		local migrados = Migraciones.aplicar(datos, self._version, self._migraciones)
		if not migrados then
			self:_soltarBloqueo(clave)
			self._registrar("FalloCarga", userId, "fallo_migracion")
			return nil, "fallo_migracion"
		end
		datos = migrados
	end
	PlantillaPerfil.reconciliar(datos)

	if self._perfiles[userId] then   -- otra carga del mismo jugador terminó mientras esta esperaba
		return nil, "ya_cargado"
	end
	local ahora = self._reloj()
	self._perfiles[userId] = { Clave = clave, Datos = datos, Cargado = ahora, UltimoGuardado = ahora, Guardando = false }
	self._registrar("PerfilCargado", userId, estado)
	return datos
end

-- Datos del perfil cargado, o nil.
function AlmacenPerfiles:obtener(userId)
	local entrada = self._perfiles[userId]
	return entrada and entrada.Datos or nil
end

function AlmacenPerfiles:cargados()
	local lista = {}
	for userId in pairs(self._perfiles) do
		table.insert(lista, userId)
	end
	return lista
end

function AlmacenPerfiles:ultimoGuardado(userId)
	local entrada = self._perfiles[userId]
	return entrada and entrada.UltimoGuardado or nil
end

-- Guarda el perfil. Con liberar = true deja la sesión vacía y lo quita de memoria (al salir o teletransportar).
-- Devuelve true, o false y el motivo: "sin_perfil" | "sesion_perdida" | "fallo_escritura".
-- Con "sesion_perdida" el perfil se descarta de memoria: quien llama debe expulsar al jugador.
function AlmacenPerfiles:guardar(userId, liberar)
	local entrada = self._perfiles[userId]
	if not entrada then
		return false, "sin_perfil"
	end
	while entrada.Guardando do   -- un guardado a la vez por perfil
		self._esperar(0.1)
	end
	if self._perfiles[userId] ~= entrada then
		return false, "sin_perfil"
	end
	entrada.Guardando = true

	local ahora = self._reloj()
	local datos = entrada.Datos
	datos.Meta.PlayTime = (datos.Meta.PlayTime or 0) + math.max(0, ahora - entrada.UltimoGuardado)
	datos.Meta.LastSave = ahora
	-- Instantánea: lo que cambie mientras UpdateAsync espera entrará en el siguiente guardado.
	local instantanea = PlantillaPerfil.copiar(datos)
	if liberar then
		instantanea.Meta.Session = PlantillaPerfil.copiar(PlantillaPerfil.SesionVacia)
	else
		instantanea.Meta.Session = self:_sesionPropia()
	end

	local estado
	local ok = self:_conReintentos(function()
		return self._almacen:UpdateAsync(entrada.Clave, function(actual)
			local s = type(actual) == "table" and type(actual.Meta) == "table" and actual.Meta.Session or nil
			if type(s) ~= "table" or s.JobId ~= self._jobId then
				estado = "sesion_perdida"
				return nil
			end
			estado = "guardado"
			return instantanea
		end)
	end)
	entrada.Guardando = false

	if not ok then
		self._registrar("FalloGuardado", userId, "fallo_escritura")
		return false, "fallo_escritura"
	end
	if estado == "sesion_perdida" then
		self._perfiles[userId] = nil
		self._registrar("SesionPerdida", userId)
		return false, "sesion_perdida"
	end
	entrada.UltimoGuardado = ahora
	if liberar then
		self._perfiles[userId] = nil
	end
	return true
end

return AlmacenPerfiles
