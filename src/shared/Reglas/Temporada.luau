-- Reglas/Temporada: pase de temporada (Config/Season). Puro.
-- perfil.Season = { Id, PassXP, Paid, Claimed = { ["F5"] = true, ["P10"] = true } }

local Shared = script.Parent.Parent
local Season = require(Shared.Config.Season)

local Temporada = {}

local DURACION = Season.Weeks * 7 * 86400

-- Número de temporada y segundos que le quedan.
function Temporada.actual(ahora)
	local id = math.max(1, math.floor((ahora - Season.StartUnix) / DURACION) + 1)
	local fin = Season.StartUnix + id * DURACION
	return id, math.max(0, fin - ahora)
end

-- Al cambiar de temporada se empieza el pase de cero (los Fragmentos y lo cobrado se quedan).
function Temporada.asegurar(perfil, id)
	local s = perfil.Season
	if s.Id ~= id then
		s.Id = id
		s.PassXP = 0
		s.Paid = false
		s.Claimed = {}
		return true
	end
	return false
end

function Temporada.nivel(perfil)
	return math.min(Season.Levels, math.floor(perfil.Season.PassXP / Season.XPPerLevel))
end

function Temporada.sumarXP(perfil, cantidad)
	local antes = Temporada.nivel(perfil)
	perfil.Season.PassXP = math.min(perfil.Season.PassXP + cantidad, Season.Levels * Season.XPPerLevel)
	return Temporada.nivel(perfil) - antes
end

local function clave(nivel, via)
	return (via == "Paid" and "P" or "F") .. nivel
end

function Temporada.recompensa(nivel, via)
	return (via == "Paid" and Season.Paid or Season.Free)[nivel]
end

function Temporada.cobrada(perfil, nivel, via)
	return perfil.Season.Claimed[clave(nivel, via)] == true
end

-- true o false y el motivo: "recompensa" | "nivel" | "pago" | "ya".
function Temporada.comprobar(perfil, nivel, via)
	if not Temporada.recompensa(nivel, via) then
		return false, "recompensa"
	end
	if Temporada.nivel(perfil) < nivel then
		return false, "nivel"
	end
	if via == "Paid" and not perfil.Season.Paid then
		return false, "pago"
	end
	if Temporada.cobrada(perfil, nivel, via) then
		return false, "ya"
	end
	return true
end

-- Marca como cobrada y aplica lo que no son monedas. Devuelve la recompensa; las monedas (CoinHours) las paga el servicio.
function Temporada.cobrar(perfil, nivel, via)
	local r = Temporada.recompensa(nivel, via)
	perfil.Season.Claimed[clave(nivel, via)] = true
	if r.SeasonFragments then
		perfil.Wallet.SeasonFragments = (perfil.Wallet.SeasonFragments or 0) + r.SeasonFragments
	elseif r.Crystals then
		perfil.Wallet.Crystals = (perfil.Wallet.Crystals or 0) + r.Crystals
	elseif r.Cosmetic and not table.find(perfil.Cosmetics.Owned, r.Cosmetic) then
		table.insert(perfil.Cosmetics.Owned, r.Cosmetic)
	end
	return r
end

-- Vía de pago con Cristales. true o false y el motivo: "ya" | "saldo".
function Temporada.comprarPago(perfil)
	if perfil.Season.Paid then
		return false, "ya"
	end
	if (perfil.Wallet.Crystals or 0) < Season.PaidCrystals then
		return false, "saldo"
	end
	perfil.Wallet.Crystals = perfil.Wallet.Crystals - Season.PaidCrystals
	perfil.Season.Paid = true
	return true
end

return Temporada
