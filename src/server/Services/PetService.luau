-- Services/PetService: huevos, incubadoras, mascotas equipadas, posturas, Nido, XP, liberar y evolución (B5).
-- Incluye PetEvolutionService (evolucionar y liberar duplicados) por ser pocas funciones en esta fase.
-- Las mascotas se ven en todos los clientes a partir del atributo «Mascotas» del personaje (PetsController).
--
-- API: Bonos(jugador) -> bonos de recolección | Equipadas(jugador) | Postura(jugador)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Shared = game:GetService("ReplicatedStorage").Shared
local Pets = require(Shared.Config.Pets)
local Rarity = require(Shared.Config.Rarity)
local Criadero = require(Shared.Reglas.Criadero)
local Mochila = require(Shared.Reglas.Mochila)
local Eventos = require(script.Parent.Parent.Util.Eventos)

local PetService = {}

local Datos, Economia, Inventory, Mining, Deposits, Enemigos, Analitica, Red
local posturas = {}        -- [jugador] = { Postura, Cambio }
local nidoResto = {}       -- [jugador] = XP fraccionaria del Nido

local ELEMENTOS = {}
do
	local vistos = {}
	for _, e in pairs(Pets.Species) do
		if not vistos[e.Element] then
			vistos[e.Element] = true
			table.insert(ELEMENTOS, e.Element)
		end
	end
	table.sort(ELEMENTOS)
end

local function nuevoId()
	return string.sub(string.gsub(HttpService:GenerateGUID(false), "-", ""), 1, 12)
end

local function avisar(jugador, texto, color)
	Red:obtener("Notify"):FireClient(jugador, { Text = texto, Short = true, Color = color })
end

function PetService.Postura(jugador)
	local p = posturas[jugador]
	return p and p.Postura or "Protect"
end

function PetService.Equipadas(jugador)
	local perfil = Datos.GetProfile(jugador)
	return perfil and Criadero.equipadas(perfil) or {}
end

function PetService.Bonos(jugador)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return Criadero.bonos({ Equipped = { Pets = {} }, Pets = {}, Progress = { Level = 1 } })
	end
	return Criadero.bonos(perfil, Mochila.capacidad(perfil))
end

-- Atributo del personaje que usan los clientes para dibujar las mascotas: "Especie:Fase,Especie:Fase".
local function publicar(jugador)
	local personaje = jugador.Character
	if not personaje then
		return
	end
	local partes = {}
	for _, e in ipairs(PetService.Equipadas(jugador)) do
		table.insert(partes, e.Mascota.Species .. ":" .. e.Mascota.Phase)
	end
	personaje:SetAttribute("Mascotas", table.concat(partes, ","))
	personaje:SetAttribute("PosturaMascotas", PetService.Postura(jugador))
end
PetService.Publicar = publicar

-- XP para las mascotas equipadas (y avisos de nivel).
local function darXP(jugador, xp)
	local perfil = Datos.GetProfile(jugador)
	if not perfil or xp <= 0 then
		return
	end
	if #Criadero.equipadas(perfil) > 0 then
		Eventos.emitir("XPMascota", jugador, xp)
	end
	for _, e in ipairs(Criadero.equipadas(perfil)) do
		local subidos = Criadero.sumarXP(e.Mascota, xp)
		if subidos > 0 then
			local nombre = Pets.Species[e.Mascota.Species].Name
			avisar(jugador, nombre .. " sube a nivel " .. e.Mascota.Level, Color3.fromRGB(150, 255, 170))
		end
	end
	Datos.Replicar(jugador, "Pets")
end

local function sumarGolpes(jugador, golpes)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return
	end
	local antes = {}
	for i, inc in ipairs(perfil.Incubators) do
		antes[i] = Criadero.lista(inc)
	end
	Criadero.sumarGolpes(perfil, golpes)
	Eventos.emitir("GolpesIncubacion", jugador, golpes)
	for i, inc in ipairs(perfil.Incubators) do
		if not antes[i] and Criadero.lista(inc) then
			avisar(jugador, "¡Un huevo está listo para eclosionar! (tecla M)", Color3.fromRGB(255, 230, 120))
		end
	end
	Datos.Replicar(jugador, "Incubators")
end

-- Remotes ----------------------------------------------------------------
local function incubar(jugador, huevoId, n)
	local perfil = Datos.GetProfile(jugador)
	Criadero.asegurarIncubadoras(perfil)
	local ok, motivo = Criadero.incubar(perfil, huevoId, n)
	if not ok then
		return false, motivo
	end
	Datos.Replicar(jugador, "Eggs", "Incubators")
	return true
end

local function eclosionar(jugador, n)
	local perfil = Datos.GetProfile(jugador)
	local id = nuevoId()
	local m, motivo = Criadero.eclosionar(perfil, n, id)
	if not m then
		return false, motivo
	end
	-- Si hay un hueco libre, se equipa sola.
	for i = 1, Criadero.espacios(perfil) do
		local actual = perfil.Equipped.Pets[i]
		if not actual or actual == "" then
			Criadero.equipar(perfil, id, i)
			break
		end
	end
	local e = Pets.Species[m.Species]
	avisar(jugador, "¡Ha nacido " .. e.Name .. "!", Color3.fromRGB(255, 230, 120))
	Analitica.Registrar(jugador, "MascotaNacida", nil, m.Species)
	Datos.Replicar(jugador, "Pets", "Incubators", "Equipped")
	publicar(jugador)
	return true, { Id = id }
end

local function equipar(jugador, id, hueco)
	local perfil = Datos.GetProfile(jugador)
	local ok, motivo = Criadero.equipar(perfil, id, hueco)
	if not ok then
		return false, motivo
	end
	Datos.Replicar(jugador, "Equipped", "Nest")
	publicar(jugador)
	return true
end

local function fijarPostura(jugador, postura)
	local p = posturas[jugador] or { Postura = "Protect", Cambio = -1e9 }
	posturas[jugador] = p
	local ahora = os.clock()
	if ahora - p.Cambio < Pets.Stance.SwitchCooldown or p.Postura == postura then
		return
	end
	p.Postura, p.Cambio = postura, ahora
	local perfil = Datos.GetProfile(jugador)
	perfil.Equipped.Stance = postura
	publicar(jugador)
	avisar(jugador, postura == "Gather" and "Mascotas: Recolectar (más radio de recogida, menos daño)" or "Mascotas: Proteger (más daño, menos radio)")
end

local function alNido(jugador, id, hueco)
	local ok, motivo = Criadero.alNido(Datos.GetProfile(jugador), id, hueco)
	if not ok then
		return false, motivo
	end
	Datos.Replicar(jugador, "Nest", "Equipped")
	return true
end

local function liberar(jugador, ids)
	local frag, motivo = Criadero.liberar(Datos.GetProfile(jugador), ids)
	if not frag then
		return false, motivo
	end
	Datos.Replicar(jugador, "Pets", "Materials")
	return true, frag
end

local function evolucionar(jugador, id)
	local perfil = Datos.GetProfile(jugador)
	local coste, motivo = Criadero.costeEvolucion(perfil, id)
	if not coste then
		return false, motivo
	end
	local ok, m = Criadero.puedeEvolucionar(perfil, coste)
	if not ok then
		return false, m
	end
	local pagado, m2 = Economia.SpendCoins(jugador, coste.Coins, "EvolucionMascota")
	if not pagado then
		return false, m2
	end
	local mascota = Criadero.evolucionar(perfil, id, coste)
	avisar(jugador, Pets.Species[mascota.Species].Name .. " ha evolucionado", Color3.fromRGB(255, 200, 90))
	Datos.Replicar(jugador, "Pets", "Materials")
	publicar(jugador)
	task.spawn(Datos.GuardarAhora, jugador)   -- C_Tecnico 6.4: guardado inmediato tras evolución
	return true
end

-- Fuentes de XP y de golpes ----------------------------------------------
local function alAgotarDeposito(entrada)
	local regla = entrada.Regla
	local total = 0
	for _, d in pairs(regla.Damage) do
		total = total + d
	end
	for userId, d in pairs(regla.Damage) do
		local jugador = Players:GetPlayerByUserId(userId)
		if jugador and total > 0 and d / total >= 0.10 then
			darXP(jugador, Pets.XPSource.Deposit[regla.Rarity] or 2)
		end
	end
	return nil
end

local function alMorirEnemigo(enemigo)
	local total = 0
	for _, d in pairs(enemigo.Danos) do
		total = total + d
	end
	for userId, d in pairs(enemigo.Danos) do
		local jugador = Players:GetPlayerByUserId(userId)
		local perfil = jugador and Datos.GetProfile(jugador)
		if perfil and total > 0 and d / total >= 0.10 then
			darXP(jugador, Pets.XPSource.Enemy[enemigo.Tipo] or 2)
			sumarGolpes(jugador, Pets.Hatch.HitsPerEnemy)
			local n = Pets.ElementDrops[enemigo.Tipo]
			if n then
				local elemento = ELEMENTOS[math.random(1, #ELEMENTOS)]
				perfil.Materials.Element[elemento] = (perfil.Materials.Element[elemento] or 0) + n
				Datos.Replicar(jugador, "Materials")
			end
		end
	end
end

-- Nido: 15 % del ritmo de XP de combate (717/h) mientras el dueño juega.
local function bucleNido()
	local porMinuto = 717 * Pets.XPSource.NestFraction / 60
	while true do
		task.wait(60)
		for _, jugador in ipairs(Players:GetPlayers()) do
			local perfil = Datos.GetProfile(jugador)
			if perfil then
				local xp = (nidoResto[jugador] or 0) + porMinuto
				local entero = math.floor(xp)
				nidoResto[jugador] = xp - entero
				if entero > 0 then
					for _, id in ipairs(perfil.Nest) do
						local m = id ~= "" and perfil.Pets[id]
						if m then
							Criadero.sumarXP(m, entero)
						end
					end
				end
			end
		end
	end
end

function PetService.Iniciar(deps)
	Datos, Economia, Inventory, Mining, Deposits = deps.Datos, deps.Economia, deps.Inventory, deps.Mining, deps.Deposits
	Enemigos, Analitica, Red = deps.Enemigos, deps.Analitica, deps.Red
	Red:conectar("Pet.StartHatch", incubar)
	Red:conectar("Pet.ClaimHatch", eclosionar)
	Red:conectar("Pet.Equip", equipar)
	Red:conectar("Pet.SetStance", fijarPostura)
	Red:conectar("Pet.SetNest", alNido)
	Red:conectar("Pet.Release", liberar)
	Red:conectar("Pet.Evolve", evolucionar)
	Mining.AlGolpear(function(jugador)
		sumarGolpes(jugador, 1)
	end)
	Deposits.AlAgotar(alAgotarDeposito)
	Enemigos.AlMorir(alMorirEnemigo)
	Inventory.RegistrarExtraMochila("Mascotas", function(jugador)
		return PetService.Bonos(jugador).BackpackUnits
	end)
	Datos.AlCargar(function(jugador, perfil)
		posturas[jugador] = { Postura = perfil.Equipped.Stance == "Gather" and "Gather" or "Protect", Cambio = -1e9 }
		if Criadero.asegurarIncubadoras(perfil) then
			Datos.Replicar(jugador, "Incubators")
		end
		jugador.CharacterAdded:Connect(function()
			task.wait(0.5)
			publicar(jugador)
		end)
		publicar(jugador)
	end)
	Players.PlayerRemoving:Connect(function(jugador)
		posturas[jugador] = nil
		nidoResto[jugador] = nil
	end)
	task.spawn(bucleNido)
	-- Recogida automática del saco propio dentro del radio de las mascotas (postura y bonos de radio).
	local Mascotas = require(Shared.Formulas.Mascotas)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, jugador in ipairs(Players:GetPlayers()) do
				local personaje = jugador.Character
				local raiz = personaje and personaje:FindFirstChild("HumanoidRootPart")
				if raiz and #PetService.Equipadas(jugador) > 0 then
					local radio = Mascotas.pickupRadius(PetService.Postura(jugador), PetService.Bonos(jugador).PickupRadius)
					Inventory.RecogerSacosCerca(jugador, raiz.Position, radio)
				end
			end
		end
	end)
end

-- Studio: termina las incubaciones y da XP a las mascotas equipadas.
function PetService.Impulso(jugador)
	local perfil = Datos.GetProfile(jugador)
	if not perfil then
		return false
	end
	sumarGolpes(jugador, 1e6)
	darXP(jugador, 2000)
	return true
end

PetService.Rarity = Rarity
return PetService
