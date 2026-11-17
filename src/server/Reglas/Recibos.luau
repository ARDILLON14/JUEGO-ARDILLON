-- Reglas/Recibos: compras con Robux idempotentes (C_Tecnico 6.4). Puro.
-- Si el recibo ya está en el perfil, se confirma sin volver a entregar. Se guardan los últimos 100.

local Monetization = require(game:GetService("ReplicatedStorage").Shared.Config.Monetization)

local Recibos = {}

function Recibos.yaEntregado(perfil, reciboId)
	return table.find(perfil.Purchases.Receipts, reciboId) ~= nil
end

function Recibos.apuntar(perfil, reciboId)
	table.insert(perfil.Purchases.Receipts, reciboId)
	while #perfil.Purchases.Receipts > Monetization.ReceiptsKept do
		table.remove(perfil.Purchases.Receipts, 1)
	end
end

function Recibos.producto(productId)
	for _, p in ipairs(Monetization.CrystalProducts) do
		if p.ProductId ~= 0 and p.ProductId == productId then
			return p
		end
	end
	return nil
end

-- Entrega (todo o nada). Devuelve "entregado", "repetido" o "desconocido".
function Recibos.procesar(perfil, reciboId, productId)
	if Recibos.yaEntregado(perfil, reciboId) then
		return "repetido"
	end
	local p = Recibos.producto(productId)
	if not p then
		return "desconocido"
	end
	perfil.Wallet.Crystals = (perfil.Wallet.Crystals or 0) + p.Crystals
	Recibos.apuntar(perfil, reciboId)
	return "entregado"
end

return Recibos
