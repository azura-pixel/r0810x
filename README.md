# TradeKit

TradeKit es un framework de UI para Roblox/Rojo pensado para un flujo concreto: elegir armas, ajustar cantidades y entregar una seleccion final.

El template actual usa dos pasos:

1. Elegir armas desde el inventario.
2. Revisar cantidades y tocar `DAR ARMAS`.

Al entregar, las filas se animan, la seleccion se limpia y aparece `ARMAS ENTREGADAS`.

## Estructura

```text
src/
  TradeKit.lua              -- API publica
  Core/Config.lua           -- defaults configurables
  Core/State.lua            -- inventario, filtros, seleccion y cantidades
  Components/Window.lua     -- ventana principal y flujo por steps
  Components/InventoryGrid.lua
  Components/ItemCard.lua
  Components/SelectedPanel.lua
  Themes/VantaDark.lua
  Utils/Animator.lua        -- microanimaciones reutilizables
examples/basic.client.lua   -- example editable
```

## Rojo

`default.project.json` monta:

- `src` en `ReplicatedStorage.TradeKit`
- `examples/basic.client.lua` en `StarterPlayer.StarterPlayerScripts.TradeKitDemo`

Corre el server:

```powershell
rojo serve
```

Luego conecta desde el plugin de Rojo en Roblox Studio.

## Uso Basico

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local TradeKit = require(ReplicatedStorage:WaitForChild("TradeKit"))

local ui = TradeKit.new({
	Theme = "VantaDark",
	MaxSelectedItems = 20,
	SubmitText = "DAR ARMAS",
	LogoText = "DUELS",
	LogoImage = "", -- usa rbxassetid://... si quieres imagen real
	ShowLauncher = true, -- deja un boton visible para volver a abrir la UI
	Categories = { "Todas", "Arcos", "Espadas", "Pistolas", "Rifles", "Otras" },
	RarityOrder = { "Mythic", "Godly", "Legendary", "Epic", "Rare", "Uncommon", "Common", "Default" },
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
})

ui:SetInventory({
	{
		Id = "DivineArcbow",
		Name = "DivineArcbow",
		Image = "",
		IconText = "BOW",
		Amount = 27,
		Rarity = "Mythic",
		Category = "Arcos",
	},
})

ui:OnSubmit(function(selectedItems)
	print("Submit", selectedItems)
end)

ui:OnDelivered(function(deliveredItems)
	print("Delivered", deliveredItems)
end)

ui:Open()
```

## Item Contract

Campos obligatorios:

- `Id`: string o numero unico.
- `Name`: nombre visible.
- `Amount`: stock disponible. La UI no deja entregar mas que esto.

Campos opcionales:

- `Image`: `rbxassetid://...` para imagen real.
- `IconText`: fallback corto cuando no hay imagen.
- `Rarity`: usado para color y orden.
- `Category`: usado para filtros/categorias.
- `Metadata`: datos propios del juego.

## Eventos

```lua
ui:OnSubmit(function(selectedItems) end)
ui:OnDelivered(function(deliveredItems) end)
ui:OnOpen(function() end)
ui:OnClose(function() end)
```

`OnSubmit` corre al tocar el boton. `OnDelivered` corre cuando termina la animacion de entrega y la seleccion ya fue limpiada.

## Personalizacion

Puedes cambiar textos sin tocar componentes:

```lua
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
}
```

Tambien puedes ajustar ventana:

```lua
Window = {
	MinWidth = 360,
	MinHeight = 520,
	MaxWidth = 860,
	MaxHeight = 640,
}
```

## Metodos utiles

```lua
ui:SetInventory(items)
ui:SetCategories(categories)
ui:SelectItem(itemId, amount)
ui:ToggleItem(itemId)
ui:SetSelectedQuantity(itemId, amount)
ui:GetSelectedItems()
ui:ClearSelection()
ui:Open()
ui:Close()
ui:Destroy()
```


`ui:Close()` esconde la ventana. Si `ShowLauncher` esta activo, queda un boton flotante para abrirla otra vez.
## Notas de Template

- Si no tienes imagenes, usa `IconText` para que el layout siga viendose bien.
- Para logos externos como `https://duels-mxs.vercel.app/logotipo.png`, sube la imagen a Roblox y usa el `rbxassetid://...` resultante.
- El example trae varias armas falsas para que se vea el scroll y el orden por rareza.


