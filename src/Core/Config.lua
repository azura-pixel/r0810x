local Config = {}

Config.Defaults = {
	Title = "TradeKit",
	Name = "TradeKitGui",
	Theme = "VantaDark",
	MaxSelectedItems = 20,
	MobileMode = false,
	SubmitText = "DAR ARMAS",
	LogoImage = "",
	LogoText = "TradeKit",
	Parent = nil,
	DisplayOrder = 50,
	ShowLauncher = true,
	Window = {
		MinWidth = 360,
		MinHeight = 520,
		MaxWidth = 860,
		MaxHeight = 640,
		PaddingX = 32,
		PaddingY = 40,
	},
	Texts = {
		SearchPlaceholder = "Buscar arma...",
		RarityFilter = "Rareza",
		Reset = "Limpiar",
		Next = "SIGUIENTE",
		Back = "Volver",
		SelectedTitle = "TUS ARMAS ELEGIDAS",
		Delivered = "ARMAS ENTREGADAS",
		EmptyInventory = "No hay armas",
		EmptySelected = "Selecciona armas para continuar",
		Hide = "Ocultar",
		Open = "Abrir",
	},
	Categories = {},
	RarityOrder = {
		"Mythic",
		"Godly",
		"Legendary",
		"Epic",
		"Rare",
		"Uncommon",
		"Common",
		"Default",
	},
}

local function isArray(value)
	return type(value) == "table" and #value > 0
end

local function deepMerge(base, override)
	local result = table.clone(base or {})

	for key, value in pairs(override or {}) do
		if type(value) == "table" and type(result[key]) == "table" and not isArray(value) then
			result[key] = deepMerge(result[key], value)
		else
			result[key] = value
		end
	end

	return result
end

local function normalizeWindow(window)
	window.MinWidth = math.max(320, tonumber(window.MinWidth) or Config.Defaults.Window.MinWidth)
	window.MinHeight = math.max(420, tonumber(window.MinHeight) or Config.Defaults.Window.MinHeight)
	window.MaxWidth = math.max(window.MinWidth, tonumber(window.MaxWidth) or Config.Defaults.Window.MaxWidth)
	window.MaxHeight = math.max(window.MinHeight, tonumber(window.MaxHeight) or Config.Defaults.Window.MaxHeight)
	window.PaddingX = math.max(0, tonumber(window.PaddingX) or Config.Defaults.Window.PaddingX)
	window.PaddingY = math.max(0, tonumber(window.PaddingY) or Config.Defaults.Window.PaddingY)
end

function Config.resolve(config)
	local resolved = deepMerge(Config.Defaults, config or {})

	resolved.MaxSelectedItems = math.max(1, tonumber(resolved.MaxSelectedItems) or Config.Defaults.MaxSelectedItems)
	resolved.Title = tostring(resolved.Title or Config.Defaults.Title)
	resolved.SubmitText = tostring(resolved.SubmitText or Config.Defaults.SubmitText)
	resolved.LogoImage = tostring(resolved.LogoImage or "")
	resolved.LogoText = tostring(resolved.LogoText or Config.Defaults.LogoText)
	resolved.ShowLauncher = resolved.ShowLauncher ~= false
	resolved.Texts = deepMerge(Config.Defaults.Texts, resolved.Texts or {})
	resolved.Categories = table.clone(resolved.Categories or {})
	resolved.RarityOrder = table.clone(resolved.RarityOrder or Config.Defaults.RarityOrder)
	resolved.Window = deepMerge(Config.Defaults.Window, resolved.Window or {})
	normalizeWindow(resolved.Window)

	return resolved
end

return Config


