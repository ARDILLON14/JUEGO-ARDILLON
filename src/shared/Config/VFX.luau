-- Config/VFX: datos de efectos visuales. Solo datos, sin lógica.
-- Origen de las cifras: OREBOUND/A_GDD, sección 2; módulo añadido por el GDD. Etiquetas [CONFIRMADO]/[PROVISIONAL] en DECISIONES.md.
-- El cliente puede leerlo; el servidor calcula siempre con su propia copia.

return {
	Quality = {   -- GDD: 2.000 en Alto y 800 en Bajo; ajenos al 50 %
		Low    = { ParticleCap = 800,  OthersFraction = 0.40, OthersCutoffStuds = 120 },   -- 0,40 propuesto: con 0,50 no cabe el peor caso
		Medium = { ParticleCap = 1400, OthersFraction = 0.50, OthersCutoffStuds = 120 },
		High   = { ParticleCap = 2000, OthersFraction = 0.50, OthersCutoffStuds = 120 },
	},
	PerAbility = { Particles = 60, Emitters = 3, DynamicLights = 2, Seconds = 2 },
	PerPet = { Particles = 10 },
	Accessibility = { Distortion = true, CameraShake = true, ChromaticAberration = true },   -- desactivables (GDD)
	CritAberrationSeconds = 0.12,
}
