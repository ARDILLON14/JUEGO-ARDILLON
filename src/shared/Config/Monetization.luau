-- Config/Monetization: Cristales, productos de Robux, pases, cosméticos y servicios (B6, sección 9). Solo datos.
-- Los ProductId y GamePassId son 0 hasta crearlos en el panel de creadores de Roblox (Creator Dashboard).
-- Nada de esto da poder: ni Celestiales, ni Núcleos Despertados, ni Seguro de carga, ni cajas, ni Suerte, ni monedas.

return {
	CrystalProducts = {
		{ Id = "Crystals100", ProductId = 0, Crystals = 100 },
		{ Id = "Crystals550", ProductId = 0, Crystals = 550 },
		{ Id = "Crystals1200", ProductId = 0, Crystals = 1200 },
	},
	GamePasses = {
		SixthPetSlot = 0,      -- sexto espacio de mascota (también con 60 Fragmentos de temporada)
		SeasonPass = 0,        -- vía de pago del pase de temporada (cosméticos y Cristales)
	},
	ReceiptsKept = 100,
	-- Cosméticos: Kind = "Trail" (estela) | "Aura" (partículas alrededor) ; Price en Cristales o, si Coins, en horas de ingreso.
	Cosmetics = {
		{ Id = "TrailCuarzo", Name = "Estela de Cuarzo", Kind = "Trail", Color = { 220, 160, 255 }, Crystals = 150 },
		{ Id = "TrailBrasa", Name = "Estela de Brasa", Kind = "Trail", Color = { 255, 120, 60 }, Crystals = 150 },
		{ Id = "TrailEscarcha", Name = "Estela de Escarcha", Kind = "Trail", Color = { 170, 230, 255 }, Crystals = 150 },
		{ Id = "AuraPrisma", Name = "Aura Prismática", Kind = "Aura", Color = { 190, 240, 255 }, Crystals = 400 },
		{ Id = "AuraMusgo", Name = "Aura de Musgo", Kind = "Aura", Color = { 120, 220, 120 }, Crystals = 400 },
		{ Id = "AuraPrestigio", Name = "Aura de Prestigio", Kind = "Aura", Color = { 255, 210, 80 }, CoinHours = 20 },   -- B6: aspecto de prestigio (sumidero)
		-- Solo en la vía de pago del pase de temporada (sin precio: no se venden sueltos).
		{ Id = "TrailAurora", Name = "Estela Aurora", Kind = "Trail", Color = { 120, 255, 200 }, Season = true },
		{ Id = "AuraTemporada", Name = "Aura de Temporada", Kind = "Aura", Color = { 255, 140, 220 }, Season = true },
		{ Id = "TrailEstelar", Name = "Estela Estelar", Kind = "Trail", Color = { 255, 255, 255 }, Season = true },
		{ Id = "AuraCorona", Name = "Aura de la Corona", Kind = "Aura", Color = { 255, 190, 60 }, Season = true },
	},
	-- Servicios con Cristales (B6 9.1): no dan poder.
	Services = {
		PetStorage = { Crystals = 200, Add = 10, Max = 100 },
		ThirdIncubator = { Crystals = 300 },
		SixthPetSlot = { SeasonFragments = 60 },   -- también con el pase de Robux GamePasses.SixthPetSlot
	},
}
