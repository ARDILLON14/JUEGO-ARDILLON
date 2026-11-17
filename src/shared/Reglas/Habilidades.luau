-- Reglas/Habilidades: qué habilidades puede llevar el jugador en Z, X, C y V (B4, 2.1 y 5.1). Puro.
-- 6 disponibles: las 4 del Núcleo equipado (Z con maestría 1, X con 10, C con 25, V con 50) y las 2 técnicas
-- del arma equipada (maestría de arma 10 y 50). V solo admite la definitiva o la segunda técnica.

local Shared = script.Parent.Parent
local PowerCores = require(Shared.Config.PowerCores)
local Weapons = require(Shared.Config.Weapons)
local Inventario = require(script.Parent.Inventario)

local Habilidades = {}

Habilidades.Ranuras = { "Z", "X", "C", "V" }

local NIVEL_RANURA = {}
for nivel, ranura in pairs(PowerCores.MasteryUnlocks) do
	if ranura ~= "Awaken" then
		NIVEL_RANURA[ranura] = nivel
	end
end

local function maestriaNucleo(perfil, nucleo)
	local m = perfil.Cores[nucleo]
	return m and m.Mastery or 0
end

function Habilidades.maestriaArma(perfil, tipo)
	local m = perfil.WeaponMastery[tipo]
	return m and m.Level or 1
end

-- Lista de las 6 habilidades con su origen y si están desbloqueadas.
-- { Id, Fuente = "Core" | "Weapon", Ranura (del Núcleo) o Indice (técnica 1 o 2), Datos, Desbloqueada, Requisito }
function Habilidades.disponibles(perfil)
	local lista = {}
	local nucleo = perfil.Equipped.Core
	local datos = PowerCores.Cores[nucleo]
	if datos then
		local m = maestriaNucleo(perfil, nucleo)
		for _, ranura in ipairs(Habilidades.Ranuras) do
			local h = datos.Abilities[ranura]
			if h then
				table.insert(lista, { Id = h.Id, Fuente = "Core", Ranura = ranura, Datos = h, Requisito = NIVEL_RANURA[ranura], Desbloqueada = m >= NIVEL_RANURA[ranura] })
			end
		end
	end
	local arma = Inventario.equipado(perfil, "Weapon")
	if arma and Weapons.Techniques[arma.Type] then
		local m = Habilidades.maestriaArma(perfil, arma.Type)
		for i, h in ipairs(Weapons.Techniques[arma.Type]) do
			table.insert(lista, { Id = h.Id, Fuente = "Weapon", Indice = i, Datos = h, Requisito = h.Mastery, Desbloqueada = m >= h.Mastery })
		end
	end
	return lista
end

function Habilidades.buscar(perfil, id)
	for _, h in ipairs(Habilidades.disponibles(perfil)) do
		if h.Id == id then
			return h
		end
	end
	return nil
end

-- ¿Se puede poner esta habilidad en esta ranura? V: definitiva del Núcleo o segunda técnica.
function Habilidades.encaja(h, ranura)
	local esDefinitiva = (h.Fuente == "Core" and h.Ranura == "V") or (h.Fuente == "Weapon" and h.Indice == 2)
	if ranura == "V" then
		return esDefinitiva
	end
	return not (h.Fuente == "Core" and h.Ranura == "V")
end

-- Valida un reparto { Z = id, X = id, C = id, V = id } ("" = vacía). Devuelve true, o false y el motivo:
-- "habilidad" | "bloqueada" | "ranura" | "repetida"
function Habilidades.validarReparto(perfil, reparto)
	local vistas = {}
	for _, ranura in ipairs(Habilidades.Ranuras) do
		local id = reparto[ranura]
		if id and id ~= "" then
			local h = Habilidades.buscar(perfil, id)
			if not h then
				return false, "habilidad"
			end
			if not h.Desbloqueada then
				return false, "bloqueada"
			end
			if not Habilidades.encaja(h, ranura) then
				return false, "ranura"
			end
			if vistas[id] then
				return false, "repetida"
			end
			vistas[id] = true
		end
	end
	return true
end

-- Reparto por defecto: las del Núcleo en su ranura, si están desbloqueadas.
function Habilidades.repartoInicial(perfil)
	local r = { Z = "", X = "", C = "", V = "" }
	for _, h in ipairs(Habilidades.disponibles(perfil)) do
		if h.Fuente == "Core" and h.Desbloqueada then
			r[h.Ranura] = h.Id
		end
	end
	return r
end

-- Quita del reparto lo que ya no se puede llevar (por ejemplo, al cambiar de arma). Devuelve true si cambió algo.
function Habilidades.limpiarReparto(perfil)
	local cambio = false
	for _, ranura in ipairs(Habilidades.Ranuras) do
		local id = perfil.Equipped.Loadout[ranura]
		if id and id ~= "" then
			local h = Habilidades.buscar(perfil, id)
			if not h or not h.Desbloqueada or not Habilidades.encaja(h, ranura) then
				perfil.Equipped.Loadout[ranura] = ""
				cambio = true
			end
		end
	end
	return cambio
end

return Habilidades
