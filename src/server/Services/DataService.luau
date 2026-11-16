-- Services/DataService: perfiles de los jugadores conectados (C_Tecnico, sección 6).
-- Toda la lógica de sesión bloqueada, reintentos y migraciones está en Datos/AlmacenPerfiles (con pruebas);
-- este servicio la conecta con Roblox: entrada y salida de jugadores, autoguardado y cierre del servidor.
--
-- Uso desde otros servicios:
--   local datos = DataService.GetProfile(jugador)      -- tabla viva del perfil, o nil si aún no está
--   DataService.AlCargar(function(jugador, datos) end)  -- se llama al cargar cada perfil
--   DataService.AlSalir(function(jugador, datos) end)   -- antes del último guardado
--   DataService.GuardarAhora(jugador)                   -- tras compra, renacimiento, extracción...
--   DataService.Liberar(jugador)                        -- guarda y suelta el bloqueo (antes de teletransportar)
-- Las operaciones sobre el perfil se hacen sin esperas intermedias: o se aplica todo o nada.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local Datos = script.Parent.Parent.Datos
local AlmacenPerfiles = require(Datos.AlmacenPerfiles)
local AlmacenMemoria = require(Datos.AlmacenMemoria)

local DataService = {}

local AUTOGUARDADO = 300          -- s entre guardados de un mismo jugador
local REPARTO = 30                -- s de desfase aleatorio inicial, para que no coincidan
local MENSAJES = {
	bloqueado = "Tu partida sigue abierta en otro servidor. Espera un minuto y vuelve a entrar.",
	version_futura = "Este servidor es antiguo. Vuelve a entrar para usar uno actualizado.",
	sesion_perdida = "Tu partida se abrió en otro servidor. No se ha perdido nada: vuelve a entrar.",
	cierre = "El servidor se está cerrando. Tu progreso está guardado.",
	otro = "No se pudieron cargar tus datos. No se ha perdido nada: vuelve a entrar en unos minutos.",
}

local almacen = nil               -- AlmacenPerfiles
local analitica = nil             -- AnalyticsService (opcional)
local proximoGuardado = {}        -- [userId] = os.clock() del siguiente autoguardado
local cargando = {}               -- [userId] = true mientras se carga
local alCargar, alSalir = {}, {}
local cerrando = false

local function jugadorPorId(userId)
	return Players:GetPlayerByUserId(userId)
end

local function crearAlmacenes()
	local ok, perfiles, copias = pcall(function()
		return DataStoreService:GetDataStore("Perfiles"), DataStoreService:GetDataStore("PerfilesCopia")
	end)
	if ok then
		-- En Studio sin acceso a la API, GetDataStore no falla pero las lecturas sí: se comprueba una vez.
		local lee = pcall(function()
			perfiles:GetAsync("__comprobacion")
		end)
		if lee then
			return perfiles, copias
		end
	end
	if RunService:IsStudio() then
		warn("DataService: sin acceso a DataStore en Studio; se usa memoria y NADA se guardará al cerrar.")
		return AlmacenMemoria.nuevo(), AlmacenMemoria.nuevo()
	end
	error("DataService: no hay acceso a DataStore")
end

local function expulsar(jugador, motivo)
	if jugador and jugador.Parent then
		jugador:Kick(MENSAJES[motivo] or MENSAJES.otro)
	end
end

local function alEntrar(jugador)
	local userId = jugador.UserId
	if cargando[userId] or cerrando then
		return
	end
	cargando[userId] = true
	local datos, motivo = almacen:cargar(userId)
	if motivo == "ya_cargado" then
		-- Reconexión antes de que terminara el guardado de salida: se espera a que se libere y se reintenta.
		local limite = os.clock() + 30
		while almacen:obtener(userId) and os.clock() < limite do
			task.wait(0.5)
		end
		datos, motivo = almacen:cargar(userId)
	end
	cargando[userId] = nil
	if not datos then
		expulsar(jugador, motivo)
		return
	end
	if not jugador:IsDescendantOf(Players) then
		almacen:guardar(userId, true)   -- se fue mientras cargaba
		return
	end
	proximoGuardado[userId] = os.clock() + AUTOGUARDADO + math.random() * REPARTO
	for _, fn in ipairs(alCargar) do
		task.spawn(fn, jugador, datos)
	end
end

local function alIrse(jugador)
	local userId = jugador.UserId
	proximoGuardado[userId] = nil
	local datos = almacen:obtener(userId)
	if not datos then
		return
	end
	for _, fn in ipairs(alSalir) do
		pcall(fn, jugador, datos)
	end
	local ok, motivo = almacen:guardar(userId, true)
	if not ok and motivo == "fallo_escritura" then
		-- Los reintentos ya se agotaron; un último intento antes de dar el guardado por perdido.
		task.wait(5)
		almacen:guardar(userId, true)
	end
end

local function guardar(userId)
	local ok, motivo = almacen:guardar(userId, false)
	if not ok and motivo == "sesion_perdida" then
		expulsar(jugadorPorId(userId), "sesion_perdida")
	end
	return ok, motivo
end

local function bucleAutoguardado()
	while not cerrando do
		task.wait(1)
		local ahora = os.clock()
		for userId, momento in pairs(proximoGuardado) do
			if ahora >= momento then
				proximoGuardado[userId] = ahora + AUTOGUARDADO
				task.spawn(guardar, userId)
			end
		end
	end
end

local function alCerrar()
	cerrando = true
	local pendientes = 0
	for _, jugador in ipairs(Players:GetPlayers()) do
		pendientes = pendientes + 1
		task.spawn(function()
			alIrse(jugador)
			pendientes = pendientes - 1
		end)
	end
	local limite = os.clock() + 25   -- BindToClose da 30 s
	while pendientes > 0 and os.clock() < limite do
		task.wait(0.1)
	end
end

-- API ---------------------------------------------------------------------

function DataService.Iniciar(deps)
	assert(not almacen, "DataService ya iniciado")
	analitica = deps and deps.Analitica or nil
	local perfiles, copias = crearAlmacenes()
	local jobId = game.JobId
	if jobId == "" then
		jobId = "studio-" .. tostring(os.time())   -- en Studio JobId está vacío
	end
	almacen = AlmacenPerfiles.nuevo({
		Almacen = perfiles,
		Copias = copias,
		Reloj = os.time,
		Esperar = task.wait,
		JobId = jobId,
		PlaceId = game.PlaceId,
		Registrar = function(evento, userId, detalle)
			if analitica then
				analitica.Registrar(jugadorPorId(userId), evento, nil, detalle)
			end
		end,
	})
	Players.PlayerAdded:Connect(alEntrar)
	Players.PlayerRemoving:Connect(alIrse)
	game:BindToClose(alCerrar)
	task.spawn(bucleAutoguardado)
	for _, jugador in ipairs(Players:GetPlayers()) do
		task.spawn(alEntrar, jugador)
	end
end

function DataService.GetProfile(jugador)
	if not almacen then
		return nil
	end
	return almacen:obtener(jugador.UserId)
end

function DataService.AlCargar(fn)
	table.insert(alCargar, fn)
end

function DataService.AlSalir(fn)
	table.insert(alSalir, fn)
end

-- Guardado inmediato (cede el control hasta terminar). Devuelve ok y, si falla, el motivo.
function DataService.GuardarAhora(jugador)
	local userId = jugador.UserId
	if proximoGuardado[userId] then
		proximoGuardado[userId] = os.clock() + AUTOGUARDADO
	end
	return guardar(userId)
end

-- Guarda y suelta el bloqueo: después de esto el perfil ya no está en este servidor.
function DataService.Liberar(jugador)
	alIrse(jugador)
	return almacen:obtener(jugador.UserId) == nil
end

return DataService
