-- Util/Lugares: distancias del servidor a partes etiquetadas (bancos, mercaderes) y posición de jugadores.
-- Las etiquetas (CollectionService) las ponen el mapa de Studio o Mundo/ConstructorPrueba.

local CollectionService = game:GetService("CollectionService")

local Lugares = {}

Lugares.Etiqueta = { Banco = "Banco", Mercader = "Mercader", PuntoDeposito = "PuntoDeposito", Deposito = "Deposito" }

function Lugares.raiz(jugador)
	local personaje = jugador.Character
	if not personaje then
		return nil
	end
	local h = personaje:FindFirstChildOfClass("Humanoid")
	if not h or h.Health <= 0 then
		return nil
	end
	return personaje:FindFirstChild("HumanoidRootPart")
end

function Lugares.posicion(jugador)
	local raiz = Lugares.raiz(jugador)
	return raiz and raiz.Position or nil
end

-- true si el jugador está vivo y a menos de radio studs (más la mitad del tamaño de la parte) de una parte con esa etiqueta.
function Lugares.cercaDe(jugador, etiqueta, radio)
	local pos = Lugares.posicion(jugador)
	if not pos then
		return false
	end
	for _, parte in ipairs(CollectionService:GetTagged(etiqueta)) do
		if parte:IsA("BasePart") then
			local margen = math.max(parte.Size.X, parte.Size.Z) / 2
			if (parte.Position - pos).Magnitude <= radio + margen then
				return true
			end
		end
	end
	return false
end

return Lugares
