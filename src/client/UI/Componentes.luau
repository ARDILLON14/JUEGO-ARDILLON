-- Piezas de interfaz reutilizables, creadas por código (sin depender de archivos de Studio).

local Componentes = {}

Componentes.Colores = {
	Fondo = Color3.fromRGB(22, 24, 32),
	Panel = Color3.fromRGB(34, 37, 48),
	Borde = Color3.fromRGB(70, 76, 96),
	Texto = Color3.fromRGB(235, 238, 245),
	TextoSuave = Color3.fromRGB(160, 166, 184),
	Vida = Color3.fromRGB(214, 64, 69),
	Energia = Color3.fromRGB(64, 196, 230),
	XP = Color3.fromRGB(240, 196, 64),
	Boton = Color3.fromRGB(58, 110, 200),
	BotonApagado = Color3.fromRGB(70, 72, 82),
	Peligro = Color3.fromRGB(180, 70, 60),
}

function Componentes.crear(clase, propiedades, hijos)
	local instancia = Instance.new(clase)
	for clave, valor in pairs(propiedades or {}) do
		if clave ~= "Parent" then
			instancia[clave] = valor
		end
	end
	for _, hijo in ipairs(hijos or {}) do
		hijo.Parent = instancia
	end
	if propiedades and propiedades.Parent then
		instancia.Parent = propiedades.Parent
	end
	return instancia
end

local crear = Componentes.crear

function Componentes.esquinas(radio)
	return crear("UICorner", { CornerRadius = UDim.new(0, radio or 6) })
end

function Componentes.texto(propiedades)
	local p = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Componentes.Colores.Texto,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}
	for k, v in pairs(propiedades) do
		p[k] = v
	end
	return crear("TextLabel", p)
end

function Componentes.boton(propiedades)
	local p = {
		BackgroundColor3 = Componentes.Colores.Boton,
		Font = Enum.Font.GothamBold,
		TextColor3 = Componentes.Colores.Texto,
		TextSize = 14,
		AutoButtonColor = true,
	}
	for k, v in pairs(propiedades) do
		p[k] = v
	end
	return crear("TextButton", p, { Componentes.esquinas(6) })
end

-- Barra con relleno y texto centrado. Devuelve el marco y una función fijar(fraccion, texto).
function Componentes.barra(propiedades, color)
	local marco = crear("Frame", {
		BackgroundColor3 = Componentes.Colores.Fondo,
		BorderSizePixel = 0,
		Size = propiedades.Size,
		Position = propiedades.Position,
		LayoutOrder = propiedades.LayoutOrder,
		Parent = propiedades.Parent,
	}, { Componentes.esquinas(4) })
	local relleno = crear("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = marco,
	}, { Componentes.esquinas(4) })
	local etiqueta = Componentes.texto({
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextStrokeTransparency = 0.6,
		ZIndex = 2,
		Parent = marco,
	})
	local function fijar(fraccion, texto)
		relleno.Size = UDim2.fromScale(math.clamp(fraccion or 0, 0, 1), 1)
		etiqueta.Text = texto or ""
	end
	return marco, fijar
end

return Componentes
