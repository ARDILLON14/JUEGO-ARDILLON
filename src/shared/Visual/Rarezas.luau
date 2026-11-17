-- Visual/Rarezas: nombre en español y color de cada rareza (A_GDD, sección 2; Config/Rarity.Color).

local Rarezas = {}

Rarezas.Nombre = {
	Common = "Común", Uncommon = "Poco común", Rare = "Raro", Epic = "Épico", Legendary = "Legendario",
	Mythic = "Mítico", UltraRare = "Ultra raro", Celestial = "Celestial",
}

-- RGB de cada rareza. Ultra raro cicla colores en el cliente; aquí, su color base.
Rarezas.RGB = {
	Common = { 158, 158, 158 }, Uncommon = { 76, 175, 80 }, Rare = { 33, 150, 243 }, Epic = { 156, 39, 176 },
	Legendary = { 255, 193, 7 }, Mythic = { 229, 57, 53 }, UltraRare = { 255, 105, 180 }, Celestial = { 230, 250, 255 },
}

function Rarezas.color(rareza)
	local c = Rarezas.RGB[rareza] or Rarezas.RGB.Common
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- Tamaño del depósito en studs, para que la rareza se note también por la forma.
Rarezas.TamanoDeposito = {
	Common = 4, Uncommon = 4.3, Rare = 4.6, Epic = 5, Legendary = 5.5, Mythic = 6, UltraRare = 6.5, Celestial = 7,
}

Rarezas.Pasiva = {
	BladeEcho = "Eco del filo", LightBallast = "Lastre ligero", SureStrike = "Golpe certero",
	RunicSonar = "Sonar rúnico", OpenVein = "Veta abierta", SeismicWave = "Onda sísmica",
	ChainFracture = "Fractura en cadena", StellarEcho = "Eco estelar",
}

return Rarezas
