-- Config/Worlds: datos de mundos y zonas. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/A_GDD. Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Hub = { Id = "PuertoVeta", PlaceId = 0 },      -- los PlaceId se rellenan al publicar
	Worlds = {
		{ Id = "SuperficieQuebrada",     PlaceId = 0, Zones = { 1, 2, 3 } },
		{ Id = "HondonadaDeLosExtremos", PlaceId = 0, Zones = { 4, 5, 6 } },
		{ Id = "AbismoNegro",            PlaceId = 0, Zones = { 7, 8 } },
		{ Id = "CorazonCeleste",         PlaceId = 0, Zones = { 9, 10 } },
	},
	Zones = {
		{ Id = 1, Name = "Cantera del Alba", Boss = "CapatazDePizarra" },
		{ Id = 2, Name = "Galerías de Musgo", Boss = "MadreLiquen" },
		{ Id = 3, Name = "Vetas Salinas", Boss = "LeviatanDeSalmuera" },
		{ Id = 4, Name = "Grutas de Brasa" },
		{ Id = 5, Name = "Sima Helada" },
		{ Id = 6, Name = "Bóveda de Ecos" },
		{ Id = 7, Name = "Minas Oscuras" },
		{ Id = 8, Name = "Mar de Magma" },
		{ Id = 9, Name = "Catedral de Cristal" },
		{ Id = 10, Name = "Núcleo Astral" },
	},
	Events = { MinIntervalMinutes = 25, MaxIntervalMinutes = 40, OneAtATime = true },
	ServerSize = 20,
}
