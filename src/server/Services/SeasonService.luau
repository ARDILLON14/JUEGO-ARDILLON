-- Services/SeasonService: pase de temporada (Config/Season; Reglas/Temporada).
--   * XP del pase: 100 por misión diaria cobrada (evento «MisionCobrada»).
--   * Season.Claim(nivel, vía): cobra una recompensa; Season.BuyPaid(): vía de pago con Cristales.
--   * El pase de Robux (Monetization.GamePasses.SeasonPass, si no es 0) también abre la vía de pago.
--   * Al empezar una temporada nueva, el pase vuelve a cero.

local MarketplaceService = game:GetService("MarketplaceService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Season = require(Shared.Config.Season)
local Monetization = require(Shared.Config.Monetization)
local Economia = require(Shared.Formulas.Economia)
local Temporada = require(Shared.Reglas.Temporada)
local Server = script.Parent.Parent
local Eventos = require(Server.Util.Eventos)

local SeasonService = {}

local Datos, Economy, Analitica, Red

local MOTIVOS = {
	recompensa = "No hay recompensa en ese nivel",
	nivel = "Aún no has llegado a ese nivel del pase",
	pago = "Esa recompensa es de la vía de pago",
	ya = "Ya la has cobrado",
	saldo = "No tienes suficientes Cristales",
}

local function avisar(jugador, texto, color)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color })
end

local function asegurar(jugador)
	local perfil = Datos.GetProfile(jugador)
	if perfil and Temporada.asegurar(perfil, (Temporada.actual(os.time()))) then
		Datos.Replicar(jugador, "Season")
	end
	return perfil
end

local function pasePagado(jugador)
	local id = Monetization.GamePasses.SeasonPass
	if id == 0 then
		return
	end
	local ok, tiene = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(jugador.UserId, id)
	end)
	local perfil = Datos.GetProfile(jugador)
	if ok and tiene and perfil and not perfil.Season.Paid then
		perfil.Season.Paid = true
		Datos.Replicar(jugador, "Season")
	end
end

local function cobrar(jugador, nivel, via)
	local perfil = asegurar(jugador)
	local ok, motivo = Temporada.comprobar(perfil, nivel, via)
	if not ok then
		return false, MOTIVOS[motivo] or motivo
	end
	local r = Temporada.cobrar(perfil, nivel, via)
	if r.CoinHours then
		Economy.AddCoins(jugador, math.floor(r.CoinHours * Economia.income(perfil.Progress.UnlockedZone) + 0.5), "Temporada")
	end
	Analitica.Registrar(jugador, "TemporadaCobrada", nivel, via)
	Datos.Replicar(jugador, "Season", "Wallet", "Cosmetics")
	return true, r
end

local function comprarPago(jugador)
	local perfil = asegurar(jugador)
	local ok, motivo = Temporada.comprarPago(perfil)
	if not ok then
		return false, MOTIVOS[motivo] or motivo
	end
	Analitica.Registrar(jugador, "PaseComprado", Season.PaidCrystals, "Crystals")
	Datos.Replicar(jugador, "Season", "Wallet")
	return true
end

function SeasonService.Iniciar(deps)
	Datos, Economy, Analitica, Red = deps.Datos, deps.Economia, deps.Analitica, deps.Red
	Red:conectar("Season.Claim", cobrar)
	Red:conectar("Season.BuyPaid", comprarPago)
	Eventos.escuchar("MisionCobrada", function(jugador)
		local perfil = asegurar(jugador)
		if not perfil then
			return
		end
		local subidos = Temporada.sumarXP(perfil, Season.XP.DailyQuest)
		Datos.Replicar(jugador, "Season")
		if subidos > 0 then
			avisar(jugador, "Pase de temporada: ¡nivel " .. Temporada.nivel(perfil) .. "! Cobra la recompensa con N", Color3.fromRGB(255, 140, 220))
		end
	end)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(jugador, id, comprado)
		if comprado and id == Monetization.GamePasses.SeasonPass then
			pasePagado(jugador)
		end
	end)
	Datos.AlCargar(function(jugador)
		asegurar(jugador)
		task.spawn(pasePagado, jugador)
	end)
end

return SeasonService
