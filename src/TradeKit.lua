local Config = require(script.Parent.Core.Config)
local Events = require(script.Parent.Core.Events)
local State = require(script.Parent.Core.State)
local Window = require(script.Parent.Components.Window)

local Themes = {
	VantaDark = require(script.Parent.Themes.VantaDark),
}

local TradeKit = {}
TradeKit.__index = TradeKit

local function resolveTheme(themeConfig)
	if type(themeConfig) == "table" then
		return themeConfig
	end

	return Themes[tostring(themeConfig or "VantaDark")] or Themes.VantaDark
end

function TradeKit.new(config)
	local resolvedConfig = Config.resolve(config)

	local self = setmetatable({
		Config = resolvedConfig,
		Theme = resolveTheme(resolvedConfig.Theme),
		Events = Events.new({ "Submit", "Delivered", "Open", "Close" }),
	}, TradeKit)

	self.State = State.new(resolvedConfig)
	self.Window = Window.new({
		Config = resolvedConfig,
		State = self.State,
		Theme = self.Theme,
		OnAddItem = function(item, amount)
			self.State:AddItem(item.Id, amount)
		end,
		OnSetQuantity = function(itemId, amount)
			self.State:SetQuantity(itemId, amount)
		end,
		OnRemoveItem = function(itemId)
			self.State:RemoveItem(itemId)
		end,
		OnSubmit = function()
			local selectedItems = self.State:GetSelectedItems()
			if #selectedItems > 0 then
				self.Events:Fire("Submit", selectedItems)
			end
		end,
		OnOpen = function()
			self.Events:Fire("Open")
		end,
		OnClose = function()
			self.Events:Fire("Close")
		end,
		OnDelivered = function(deliveredItems)
			self.Events:Fire("Delivered", deliveredItems)
		end,
	})

	return self
end

function TradeKit:SetInventory(items)
	self.State:SetInventory(items)
	return self
end

function TradeKit:SetCategories(categories)
	self.State:SetCategories(categories)
	return self
end

function TradeKit:OnSubmit(callback)
	return self.Events:On("Submit", callback)
end

function TradeKit:OnDelivered(callback)
	return self.Events:On("Delivered", callback)
end

function TradeKit:OnOpen(callback)
	return self.Events:On("Open", callback)
end

function TradeKit:OnClose(callback)
	return self.Events:On("Close", callback)
end

function TradeKit:Open()
	self.Window:Open()
	return self
end

function TradeKit:Close()
	self.Window:Close()
	return self
end

function TradeKit:SelectItem(itemId, amount)
	self.State:AddItem(itemId, amount or 1)
	return self
end

function TradeKit:ToggleItem(itemId)
	self.State:ToggleItem(itemId)
	return self
end

function TradeKit:SetSelectedQuantity(itemId, amount)
	self.State:SetQuantity(itemId, amount)
	return self
end

function TradeKit:GetSelectedItems()
	return self.State:GetSelectedItems()
end

function TradeKit:ClearSelection()
	self.State:ClearSelection()
	return self
end

function TradeKit:Destroy()
	if self.Window then
		self.Window:Destroy()
		self.Window = nil
	end

	if self.State then
		self.State:Destroy()
		self.State = nil
	end

	if self.Events then
		self.Events:Destroy()
		self.Events = nil
	end
end

return TradeKit






