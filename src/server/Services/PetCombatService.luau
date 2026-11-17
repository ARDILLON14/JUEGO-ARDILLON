-- Services/PetCombatService: las mascotas atacan al objetivo del dueño mientras está en combate (B5, secciones 4 y 6).
-- Todo golpe pasa por el factor de escala y la ventana deslizante de 5 s: nunca más del 40 % del DPS de referencia
-- del dueño en PvE (25 % en PvP). El Haz de Cuarzo del Guiverno (forma máxima) también cuenta.
-- Las mascotas de Defensa en forma desatada protegen con un escudo del 20 % de la vida si el dueño baja del 50 %.

local Players = game:GetService("Players")

local Shared = game:GetService("ReplicatedStorage").Shared
local Pets = require(Shared.Config.Pets)
local Weapons = require(Shared.Config.Weapons)
local Mascotas = require(Shared.Formulas.Mascotas)
local Inventario = require(Shared.Reglas.Inventario)
local Habilidades = require(Shared.Reglas.Habilidades)
local Criadero = require(Shared.Reglas.Criadero)
local Server = script.Parent.Parent
local Combate = require(Server.Reglas.Combate)
local TopeMascotas = require(Server.Reglas.TopeMascotas)
local Lugares = require(Server.Util.Lugares)

local PetCombatService = {}

local Datos, StatsSvc, Combat, Enemigos, PetSvc, Red
local estados = {}   -- [jugador] = { Tope, Proximo = { [hueco] = t }, Haz = t, Escudo = t }

local function estado(jugador)
	local e = estados[jugador]
	if not e then
		e = { Tope = TopeMascotas.nuevo(), Proximo = {}, Haz = -1e9, Escudo = -1e9 }
		estados[jugador] = e
	end
	return e
end

local function objetivo(jugador, raiz)
	local id = Combat.UltimoObjetivo(jugador)
	local en = id and Enemigos.Obtener(id)
	if en and en.Raiz and (en.Raiz.Position - raiz.Position).Magnitude <= Pets.Combat.AssistRadius then
		return en
	end
	return Enemigos.EnRadio(raiz.Position, Pets.Combat.AssistRadius)[1]
end

local function golpear(jugador, e, en, dano, ahora, dpsRef, hueco, especie)
	local aplicado = TopeMascotas.permitir(e.Tope, ahora, dano, dpsRef, "PvE")
	if aplicado <= 0 then
		return
	end
	local pos = en.Raiz and en.Raiz.Position
	Enemigos.Danar(en.Id, jugador, aplicado)
	if pos then
		local remote = Red:obtener("Combat.Hit")
		for _, otro in ipairs(Players:GetPlayers()) do
			local p = Lugares.posicion(otro)
			if p and (p - pos).Magnitude <= 150 then
				remote:FireClient(otro, { Pos = pos, Damage = math.floor(aplicado + 0.5), Crit = false, Pet = true, Owner = jugador.UserId, Slot = hueco, Species = especie, Own = otro == jugador })
			end
		end
	end
end

local function paso(jugador, ahora)
	local perfil = Datos.GetProfile(jugador)
	local raiz = Lugares.raiz(jugador)
	if not perfil or not raiz then
		return
	end
	local equipadas = Criadero.equipadas(perfil)
	if #equipadas == 0 then
		return
	end
	local e = estado(jugador)
	local personaje = jugador.Character
	local h = personaje and personaje:FindFirstChildOfClass("Humanoid")

	-- Escudo de las mascotas de Defensa en forma desatada (incluye el Escudo Facetado del Guiverno).
	local A = Pets.Abilities
	if h and h.Health > 0 and h.Health / h.MaxHealth < A.Shield.OwnerHealthBelow and ahora >= e.Escudo then
		for _, eq in ipairs(equipadas) do
			local d = Criadero.datos(eq.Mascota)
			if d.Role == "Defense" and eq.Mascota.Phase ~= "Hatchling" then
				e.Escudo = ahora + A.Shield.Cooldown
				Combat.FijarEscudo(jugador, h.MaxHealth * A.Shield.Fraction * Mascotas.utilityFactor(eq.Mascota, StatsSvc.GetStats(jugador).Effective.PetMastery), A.Shield.Seconds)
				Red:obtener("Notify"):FireClient(jugador, { Text = Pets.Species[eq.Mascota.Species].Name .. " te protege con un escudo", Short = true })
				break
			end
		end
	end

	if not StatsSvc.EnCombate(jugador) then
		return
	end
	local arma = Inventario.equipado(perfil, "Weapon")
	local d = StatsSvc.GetStats(jugador)
	if not arma or not d then
		return
	end
	local en = objetivo(jugador, raiz)
	if not en then
		return
	end
	local potencia = Inventario.potencia(arma)
	local dominio = d.Effective.PetMastery
	local postura = PetSvc.Postura(jugador)
	local dpsRef = Mascotas.dpsRef(potencia, d.Effective.Strength, Habilidades.maestriaArma(perfil, arma.Type))
	-- Factor de escala del tope conjunto (B5 6.1, paso 2).
	local total = 0
	for _, eq in ipairs(equipadas) do
		total = total + Mascotas.dps(potencia, Criadero.datos(eq.Mascota), dominio, postura)
	end
	local factor = Mascotas.capFactor(total, dpsRef, "PvE")
	for _, eq in ipairs(equipadas) do
		local datos = Criadero.datos(eq.Mascota)
		local hps = Mascotas.hitsPerSecond(datos.HitsPerSecond, datos.Level)
		if ahora >= (e.Proximo[eq.Hueco] or 0) then
			e.Proximo[eq.Hueco] = ahora + 1 / hps
			local porGolpe = Mascotas.dps(potencia, datos, dominio, postura) / hps * factor
			golpear(jugador, e, en, porGolpe, ahora, dpsRef, eq.Hueco, eq.Mascota.Species)
		end
		-- Haz de Cuarzo (Guiverno en forma máxima): golpe extra contra objetivos Refractados; cuenta para el tope.
		if eq.Mascota.Species == "GuivernoDeCuarzo" and eq.Mascota.Phase == "UnleashedMax" and ahora >= e.Haz
			and Combate.tieneEstado(en.Estados, "Refracted", ahora) then
			e.Haz = ahora + A.QuartzBeam.Cooldown
			local haz = Mascotas.dps(potencia, datos, dominio, postura) / hps * A.QuartzBeam.Coef * factor
			golpear(jugador, e, en, haz, ahora, dpsRef, eq.Hueco, eq.Mascota.Species)
		end
	end
end

function PetCombatService.Iniciar(deps)
	Datos, StatsSvc, Combat, Enemigos, PetSvc, Red = deps.Datos, deps.Stats, deps.Combat, deps.Enemigos, deps.Pets, deps.Red
	Players.PlayerRemoving:Connect(function(jugador)
		estados[jugador] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(Pets.Combat.TickSeconds)
			local ahora = os.clock()
			for _, jugador in ipairs(Players:GetPlayers()) do
				local ok, err = pcall(paso, jugador, ahora)
				if not ok then
					warn("PetCombatService: " .. tostring(err))
				end
			end
		end
	end)
end

PetCombatService.Weapons = Weapons
return PetCombatService
