-- Config/Quests: misiones diarias y tutorial (A_GDD: «3 diarias, de minería, combate y mascotas; sin castigo por faltar»).
-- Solo datos. Las recompensas van en horas de ingreso de la zona más profunda desbloqueada (B6).

return {
	DailyRewardHours = 0.25,     -- por misión [PROVISIONAL]: un cuarto de hora de ingreso
	DailyXPActions = 20,         -- XP: 20 acciones de referencia de su nivel (F7) [PROVISIONAL]
	Daily = {                    -- se elige una de cada categoría cada día
		Mining = {
			{ Id = "ExtractOres", Event = "MineralExtraido", Count = 40, Text = "Extrae %d bloques de mineral" },
			{ Id = "DepositUnits", Event = "Deposito", Count = 150, Text = "Deposita %d unidades en el banco" },
		},
		Combat = {
			{ Id = "DefeatEnemies", Event = "EnemigoDerrotado", Count = 50, Text = "Derrota %d enemigos" },
			{ Id = "UseAbilities", Event = "HabilidadUsada", Count = 25, Text = "Usa %d habilidades" },
		},
		Pets = {
			{ Id = "PetXP", Event = "XPMascota", Count = 400, Text = "Haz que tus mascotas ganen %d de XP" },
			{ Id = "IncubateHits", Event = "GolpesIncubacion", Count = 400, Text = "Suma %d golpes de incubación" },
		},
	},
	Tutorial = {
		{ Event = "MineralExtraido", Count = 1, Text = "Equipa el Pico (1), ve a la Cantera del Alba y pica hasta encontrar un mineral" },
		{ Event = "Deposito", Count = 1, Text = "Lleva tus minerales al Banco y mantén R para depositar" },
		{ Event = "VentaMineral", Count = 1, Text = "Vende minerales al Mercader (R) para ganar monedas" },
		{ Event = "Asignacion", Count = 1, Text = "Abre tus estadísticas con P y reparte un punto" },
		{ Event = "EnemigoDerrotado", Count = 3, Text = "Equipa la Espada (2) y derrota 3 enemigos en la Llanura del Alba" },
		{ Event = "HabilidadUsada", Count = 1, Text = "Usa la Lanza Prismática con Z" },
		{ Event = "CajaAbierta", Count = 1, Text = "Abre una caja en el puesto de Geodas (R)" },
	},
	TutorialReward = { Hours = 0.5 },    -- al terminar el tutorial [PROVISIONAL]
}
