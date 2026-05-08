local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TradeKit = require(ReplicatedStorage:WaitForChild("TradeKit"))

local player = Players.LocalPlayer

-- Template knobs: cambia estos valores para adaptar el example a tu juego.
local START_WITH_EXAMPLE_SELECTION = false
local LOGO_SOURCE_URL = "https://duels-mxs.vercel.app/logotipo.png"

-- Reemplaza Image por tus rbxassetid reales cuando tengas thumbnails/imports.
-- IconText solo existe para que el template se vea decente mientras no hay imagenes.
local INVENTORY = {
	{
		Id = "DivineArcbow",
		Name = "DivineArcbow",
		Image = "",
		IconText = "BOW",
		Amount = 27,
		Rarity = "Mythic",
		Category = "Arcos",
	},
	{
		Id = "DivineEmberlock",
		Name = "DivineEmberlock",
		Image = "",
		IconText = "GUN",
		Amount = 16,
		Rarity = "Mythic",
		Category = "Pistolas",
	},
	{
		Id = "EternalBow",
		Name = "EternalBow",
		Image = "",
		IconText = "BOW",
		Amount = 86,
		Rarity = "Mythic",
		Category = "Arcos",
	},
	{
		Id = "DragonTailGun",
		Name = "DragonTail Gun",
		Image = "",
		IconText = "DTG",
		Amount = 18,
		Rarity = "Mythic",
		Category = "Pistolas",
	},
	{
		Id = "SkyForgeCrossbow",
		Name = "SkyForgeCrossbow",
		Image = "",
		IconText = "XBOW",
		Amount = 35,
		Rarity = "Rare",
		Category = "Arcos",
	},
	{
		Id = "SpiritGun",
		Name = "Spirit Gun",
		Image = "",
		IconText = "SG",
		Amount = 20,
		Rarity = "Rare",
		Category = "Rifles",
	},
	{
		Id = "PlasmaCannon",
		Name = "Plasma Cannon",
		Image = "",
		IconText = "PC",
		Amount = 18,
		Rarity = "Rare",
		Category = "Rifles",
	},
	{
		Id = "CosmicBlade",
		Name = "Cosmic Blade",
		Image = "",
		IconText = "CB",
		Amount = 65,
		Rarity = "Rare",
		Category = "Espadas",
	},
	{
		Id = "GalacticScythe",
		Name = "Galactic Scythe",
		Image = "",
		IconText = "SCY",
		Amount = 7,
		Rarity = "Rare",
		Category = "Espadas",
	},
	{
		Id = "VoidDagger",
		Name = "Void Dagger",
		Image = "",
		IconText = "VD",
		Amount = 182,
		Rarity = "Epic",
		Category = "Espadas",
	},
	{
		Id = "GoldenRevolver",
		Name = "Golden Revolver",
		Image = "",
		IconText = "REV",
		Amount = 36,
		Rarity = "Legendary",
		Category = "Pistolas",
	},
	{
		Id = "CorazonRoto",
		Name = "Corazon Roto",
		Image = "",
		IconText = "CR",
		Amount = 14,
		Rarity = "Mythic",
		Category = "Otras",
	},
	{
		Id = "FrostBlade",
		Name = "Frost Blade",
		Image = "",
		IconText = "FB",
		Amount = 45,
		Rarity = "Rare",
		Category = "Espadas",
	},
	{
		Id = "ShadowDagger",
		Name = "Shadow Dagger",
		Image = "",
		IconText = "SD",
		Amount = 12,
		Rarity = "Epic",
		Category = "Espadas",
	},
	{
		Id = "NebulaKatana",
		Name = "Nebula Katana",
		Image = "",
		IconText = "NK",
		Amount = 41,
		Rarity = "Mythic",
		Category = "Espadas",
	},
	{
		Id = "PhantomRifle",
		Name = "Phantom Rifle",
		Image = "",
		IconText = "PR",
		Amount = 33,
		Rarity = "Legendary",
		Category = "Rifles",
	},
	{
		Id = "AuroraBow",
		Name = "Aurora Bow",
		Image = "",
		IconText = "AB",
		Amount = 58,
		Rarity = "Epic",
		Category = "Arcos",
	},
	{
		Id = "TitanBlaster",
		Name = "Titan Blaster",
		Image = "",
		IconText = "TB",
		Amount = 24,
		Rarity = "Legendary",
		Category = "Rifles",
	},
	{
		Id = "CrystalDagger",
		Name = "Crystal Dagger",
		Image = "",
		IconText = "CD",
		Amount = 74,
		Rarity = "Epic",
		Category = "Espadas",
	},
	{
		Id = "VortexGun",
		Name = "Vortex Gun",
		Image = "",
		IconText = "VG",
		Amount = 29,
		Rarity = "Rare",
		Category = "Pistolas",
	},
	{
		Id = "InfernoRevolver",
		Name = "Inferno Revolver",
		Image = "",
		IconText = "IR",
		Amount = 19,
		Rarity = "Legendary",
		Category = "Pistolas",
	},
	{
		Id = "PulseScythe",
		Name = "Pulse Scythe",
		Image = "",
		IconText = "PS",
		Amount = 11,
		Rarity = "Mythic",
		Category = "Espadas",
	},
	{
		Id = "SolarRifle",
		Name = "Solar Rifle",
		Image = "",
		IconText = "SR",
		Amount = 22,
		Rarity = "Legendary",
		Category = "Rifles",
	},
}

local ui = TradeKit.new({
	Title = "Dar armas",
	Theme = "VantaDark",
	MaxSelectedItems = 20,
	SubmitText = "DAR ARMAS",
	LogoText = "DUELS",
	-- Roblox ImageLabels necesitan rbxassetid://. Sube LOGO_SOURCE_URL y pega el id aca.
	LogoImage = "",
	ShowLauncher = true,
	Categories = { "Todas", "Arcos", "Espadas", "Pistolas", "Rifles", "Otras" },
	RarityOrder = { "Mythic", "Godly", "Legendary", "Epic", "Rare", "Uncommon", "Common", "Default" },
	Texts = {
		SearchPlaceholder = "Buscar arma...",
		RarityFilter = "Rareza",
		Reset = "Reset",
		Next = "Siguiente",
		Back = "Volver",
		SelectedTitle = "TUS ARMAS ELEGIDAS",
		Delivered = "ARMAS ENTREGADAS",
		EmptyInventory = "No hay armas",
		EmptySelected = "Selecciona armas para continuar",
		Hide = "Ocultar",
		Open = "Abrir",
	},
	Window = {
		MinWidth = 360,
		MinHeight = 520,
		MaxWidth = 860,
		MaxHeight = 640,
	},
	Parent = player:WaitForChild("PlayerGui"),
})

ui:SetInventory(INVENTORY)

if START_WITH_EXAMPLE_SELECTION then
	ui:SelectItem("DivineArcbow", 12)
	ui:SelectItem("EternalBow", 30)
	ui:SelectItem("SkyForgeCrossbow", 10)
	ui:SelectItem("GalacticScythe", 7)
end

-- Se dispara cuando el usuario toca DAR ARMAS.
ui:OnSubmit(function(selectedItems)
	print("TradeKit submit:")
	for _, selectedItem in ipairs(selectedItems) do
		print(selectedItem.Id, selectedItem.Amount)
	end
end)

-- Se dispara al terminar la animacion de entrega y luego de limpiar la seleccion.
ui:OnDelivered(function(deliveredItems)
	print("TradeKit delivered:", #deliveredItems, "item types")
end)

ui:Open()






