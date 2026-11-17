-- Config/Security: antitrampas y acceso a la beta (C_Tecnico, secciones 7.2 y 7.7). Solo datos.

return {
	Movement = {
		SampleSeconds = 0.25,
		Windows = { { Seconds = 0.5, MaxStuds = 75 }, { Seconds = 1, MaxStuds = 100 }, { Seconds = 2, MaxStuds = 130 } },   -- horizontal (caer no cuenta)
		StrikesToRubberband = 3,
	},
	Suspicion = { Schema = 1, Rate = 0, Movement = 1, KickAt = 30 },   -- el límite de frecuencia descarta en silencio
	Income = { AlertHoursMultiplier = 3 },                              -- alerta si gana más de 3 h de ingreso en 1 h
	Beta = { Enabled = false, AllowedUserIds = {}, AllowGroupId = 0 },  -- beta cerrada: rellenar antes de abrirla
}
