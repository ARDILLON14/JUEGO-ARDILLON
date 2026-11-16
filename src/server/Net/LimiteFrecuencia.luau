-- Net/LimiteFrecuencia: cubo de fichas por jugador y Remote (C_Tecnico, 5.2).
-- Cada cubo empieza lleno (Burst fichas) y se rellena a PerSecond fichas por segundo.

local LimiteFrecuencia = {}
LimiteFrecuencia.__index = LimiteFrecuencia

-- reloj: función que devuelve segundos (os.clock por defecto). Se inyecta para las pruebas.
function LimiteFrecuencia.nuevo(reloj)
	return setmetatable({ _reloj = reloj or os.clock, _cubos = {} }, LimiteFrecuencia)
end

-- clave: identificador del jugador (UserId). limite: { PerSecond, Burst }.
-- Devuelve true si la llamada se admite (y gasta una ficha).
function LimiteFrecuencia:consumir(clave, nombre, limite)
	local porJugador = self._cubos[clave]
	if not porJugador then
		porJugador = {}
		self._cubos[clave] = porJugador
	end
	local ahora = self._reloj()
	local cubo = porJugador[nombre]
	if not cubo then
		cubo = { Fichas = limite.Burst, Momento = ahora }
		porJugador[nombre] = cubo
	else
		local pasado = math.max(0, ahora - cubo.Momento)
		cubo.Fichas = math.min(limite.Burst, cubo.Fichas + pasado * limite.PerSecond)
		cubo.Momento = ahora
	end
	if cubo.Fichas < 1 then
		return false
	end
	cubo.Fichas = cubo.Fichas - 1
	return true
end

-- Se llama cuando el jugador sale, para no acumular memoria.
function LimiteFrecuencia:olvidar(clave)
	self._cubos[clave] = nil
end

return LimiteFrecuencia
