-- Config/Bosses: los 3 jefes del MVP y su sala (B4, sección 8). Solo datos.
-- Las cifras comunes (fases, escalado, avisos, daño, vulnerabilidad, furia, botín) están en Config/Weapons.Boss.

return {
	Arena = { Radius = 40, GateRadius = 20, CountdownSeconds = 10 },
	PhaseInvulnerableSeconds = 2,            -- B4 8.1: invulnerable 2 s al cambiar de fase
	StuckSeconds = 4,                        -- fase 1: pico atascado / quieto tras emerger
	Adds = { EverySeconds = 20, Count = 2 }, -- fase 3 del Capataz: invoca enemigos comunes
	EnrageStep = { Seconds = 30, Bonus = 0.10 },
	SafeZoneRadius = 7,
	AttackEverySeconds = { [1] = 3.0, [2] = 2.6, [3] = 2.2 },   -- ritmo de ataques por fase [PROVISIONAL]
	LethalEverySeconds = 28,                 -- cada cuánto el ataque letal en fases 2 y 3 [PROVISIONAL]
	List = {
		[1] = {
			Id = "CapatazDePizarra", Name = "Capataz de Pizarra", Color = { 120, 112, 100 }, Size = 9, Moves = true, Core = "Seismic",
			Normal = { Shape = "Arc", Radius = 12, Name = "Barrido de pico" },
			Heavy = { Shape = "Around", Radius = 14, Name = "Pisotón" },
			Lethal = { Name = "Derrumbe", Safe = { [2] = 3, [3] = 2 }, Double = { [3] = false } },
			StuckAfterNormals = 3,
		},
		[2] = {
			Id = "MadreLiquen", Name = "Madre Liquen", Color = { 78, 140, 70 }, Size = 10, Moves = false, Core = "Umbral",
			Normal = { Shape = "Line", Length = 32, Width = 5, Name = "Látigo de raíz" },
			Heavy = { Shape = "OnPlayer", Radius = 10, Name = "Nube de esporas", Slow = 0.3 },
			Lethal = { Name = "Floración", Safe = { [2] = 3, [3] = 3 }, Double = { [3] = true } },
			StuckAfterNormals = 3,
		},
		[3] = {
			Id = "LeviatanDeSalmuera", Name = "Leviatán de Salmuera", Color = { 225, 225, 235 }, Size = 9, Moves = true, Core = "Storm",
			Normal = { Shape = "Arc", Radius = 11, Name = "Mordisco" },
			Heavy = { Shape = "Behind", Radius = 13, Name = "Coletazo" },
			Lethal = { Name = "Marea Seca", Safe = { [2] = 2, [3] = 2 }, Double = { [3] = true } },
			StuckAfterNormals = 3,
		},
	},
}
