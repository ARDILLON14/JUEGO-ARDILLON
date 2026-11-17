-- Services/MonetizationService: Cristales, cosméticos, servicios y pases (B6 sección 9; C_Tecnico 7.5).
--   * ProcessReceipt idempotente: cada recibo se apunta en Purchases.Receipts y se guarda ANTES de confirmar
--     la compra a Roblox; un recibo repetido no vuelve a dar Cristales.
--   * Cosmetic.Buy(id) / Cosmetic.Equip(hueco, id): estelas y auras (con Cristales; el Aura de Prestigio con monedas).
--   * Shop.CrystalService(id): almacén de mascotas +10 y tercera incubadora.
--   * Pases: sexto espacio de mascota (si el GamePassId no es 0).
--   * Settings.Save: guarda los ajustes del jugador (Reglas/Ajustes).
-- Nada de lo que se vende da poder.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Monetization = require(Shared.Config.Monetization)
local Tienda = require(Shared.Reglas.Tienda)
local Ajustes = require(Shared.Reglas.Ajustes)
local Criadero = require(Shared.Reglas.Criadero)
local Server = script.Parent.Parent
local Recibos = require(Server.Reglas.Recibos)

local MonetizationService = {}

local Datos, Economy, Analitica, Red

local function avisar(jugador, texto, color)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Color = color })
end

local function color(c)
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- Pone en el personaje la estela y el aura equipadas (y quita las anteriores).
local function vestir(jugador)
	local perfil = Datos.GetProfile(jugador)
	local personaje = jugador.Character
	local hrp = personaje and personaje:FindFirstChild("HumanoidRootPart")
	if not perfil or not hrp then
		return
	end
	for _, nombre in ipairs({ "CosmeticoTrail", "CosmeticoAura", "CosmeticoA0", "CosmeticoA1" }) do
		local viejo = hrp:FindFirstChild(nombre)
		if viejo then
			viejo:Destroy()
		end
	end
	local eq = perfil.Cosmetics.Equipped
	local estela = eq.Trail and Tienda.cosmetico(eq.Trail)
	if estela then
		local a0 = Instance.new("Attachment")
		a0.Name = "CosmeticoA0"
		a0.Position = Vector3.new(0, 1, 0)
		a0.Parent = hrp
		local a1 = Instance.new("Attachment")
		a1.Name = "CosmeticoA1"
		a1.Position = Vector3.new(0, -1, 0)
		a1.Parent = hrp
		local trail = Instance.new("Trail")
		trail.Name = "CosmeticoTrail"
		trail.Attachment0, trail.Attachment1 = a0, a1
		trail.Color = ColorSequence.new(color(estela.Color))
		trail.Transparency = NumberSequence.new(0.2, 1)
		trail.Lifetime = 0.45
		trail.LightEmission = 0.8
		trail.FaceCamera = true
		trail.Parent = hrp
	end
	local aura = eq.Aura and Tienda.cosmetico(eq.Aura)
	if aura then
		local p = Instance.new("ParticleEmitter")
		p.Name = "CosmeticoAura"
		p.Color = ColorSequence.new(color(aura.Color))
		p.LightEmission = 1
		p.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0) })
		p.Transparency = NumberSequence.new(0.1, 1)
		p.Lifetime = NumberRange.new(0.8, 1.4)
		p.Rate = 14
		p.Speed = NumberRange.new(1, 2.5)
		p.SpreadAngle = Vector2.new(180, 180)
		p.Parent = hrp
	end
end

-- Compra de Cristales con Robux. Debe devolver PurchaseGranted solo cuando lo entregado está guardado.
local function procesarRecibo(info)
	local jugador = Players:GetPlayerByUserId(info.PlayerId)
	local perfil = jugador and Datos.GetProfile(jugador)
	if not perfil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local r = Recibos.procesar(perfil, info.PurchaseId, info.ProductId)
	if r == "desconocido" then
		Analitica.Registrar(jugador, "ReciboDesconocido", info.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local ok = Datos.GuardarAhora(jugador)
	if not ok then
		return Enum.ProductPurchaseDecision.NotProcessedYet   -- Roblox lo reintentará; el recibo ya está apuntado
	end
	if r == "entregado" then
		local producto = Recibos.producto(info.ProductId)
		Analitica.Registrar(jugador, "CompraRobux", info.CurrencySpent, producto and producto.Id)
		Datos.Replicar(jugador, "Wallet")
		avisar(jugador, "+" .. (producto and producto.Crystals or 0) .. " Cristales. ¡Gracias por apoyar OREBOUND!", Color3.fromRGB(190, 240, 255))
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

local function comprobarPases(jugador)
	local id = Monetization.GamePasses.SixthPetSlot
	if id == 0 then
		return
	end
	local ok, tiene = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(jugador.UserId, id)
	end)
	local perfil = Datos.GetProfile(jugador)
	if ok and tiene and perfil and not perfil.Purchases.SixthPetSlot then
		perfil.Purchases.SixthPetSlot = true
		Datos.Replicar(jugador, "Pets")
	end
end

local MOTIVOS = {
	cosmetico = "Ese cosmético no existe",
	ya = "Ya lo tienes",
	saldo = "No tienes suficiente",
	maximo = "Ya está al máximo",
	servicio = "Ese servicio no existe",
	hueco = "Hueco no válido",
}

function MonetizationService.Iniciar(deps)
	Datos, Economy, Analitica, Red = deps.Datos, deps.Economia, deps.Analitica, deps.Red

	MarketplaceService.ProcessReceipt = procesarRecibo
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(jugador, id, comprado)
		if comprado and id == Monetization.GamePasses.SixthPetSlot then
			comprobarPases(jugador)
		end
	end)

	Red:conectar("Cosmetic.Buy", function(jugador, id)
		local perfil = Datos.GetProfile(jugador)
		local precio, motivo = Tienda.comprobar(perfil, id)
		if not precio then
			return false, MOTIVOS[motivo] or motivo
		end
		local ok, err = Economy.SpendCoins(jugador, precio.Cantidad, "Cosmetico:" .. id, precio.Moneda)
		if not ok then
			return false, MOTIVOS[err] or err
		end
		Tienda.otorgar(perfil, id)
		Tienda.equipar(perfil, Tienda.cosmetico(id).Kind, id)
		Analitica.Registrar(jugador, "CosmeticoComprado", precio.Cantidad, id)
		Datos.Replicar(jugador, "Cosmetics")
		vestir(jugador)
		return true
	end)

	Red:conectar("Cosmetic.Equip", function(jugador, hueco, id)
		local perfil = Datos.GetProfile(jugador)
		local ok, motivo = Tienda.equipar(perfil, hueco, id or "")
		if not ok then
			return false, MOTIVOS[motivo] or motivo
		end
		Datos.Replicar(jugador, "Cosmetics")
		vestir(jugador)
		return true
	end)

	Red:conectar("Shop.CrystalService", function(jugador, id)
		local perfil = Datos.GetProfile(jugador)
		local s, motivo = Tienda.servicio(perfil, id)
		if not s then
			return false, MOTIVOS[motivo] or motivo
		end
		Tienda.aplicarServicio(perfil, id)
		Criadero.asegurarIncubadoras(perfil)
		Analitica.Registrar(jugador, "ServicioCristales", s.Crystals, id)
		Datos.Replicar(jugador, "Wallet", "PetStorage", "Incubators")
		return true
	end)

	Red:conectar("Settings.Save", function(jugador, ajustes)
		local perfil = Datos.GetProfile(jugador)
		if perfil then
			perfil.Settings = Ajustes.limpiar(ajustes)
		end
	end)

	-- Puesto de cosméticos de la plaza (etiqueta "Cosmeticos"): abre el panel del cliente.
	local function conectarPuesto(parte)
		local prompt = parte:FindFirstChildWhichIsA("ProximityPrompt", true)
		if prompt then
			prompt.Triggered:Connect(function(jugador)
				Red:obtener("Notify"):FireClient(jugador, { Kind = "OpenCosmetics" })
			end)
		end
	end
	for _, parte in ipairs(CollectionService:GetTagged("Cosmeticos")) do
		conectarPuesto(parte)
	end
	CollectionService:GetInstanceAddedSignal("Cosmeticos"):Connect(conectarPuesto)

	Datos.AlCargar(function(jugador)
		task.spawn(comprobarPases, jugador)
		jugador.CharacterAdded:Connect(function()
			task.wait(0.2)
			vestir(jugador)
		end)
		if jugador.Character then
			vestir(jugador)
		end
	end)
end

return MonetizationService
