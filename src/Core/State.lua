local Signal = require(script.Parent.Parent.Utils.Signal)

local State = {}
State.__index = State

local function buildRarityRank(config)
	local rank = {}

	for index, rarity in ipairs(config.RarityOrder or {}) do
		rank[tostring(rarity)] = index
	end

	rank.Default = rank.Default or (#(config.RarityOrder or {}) + 1)
	rank.Item = rank.Item or rank.Default
	return rank
end

local function normalizeAmount(amount)
	return math.max(0, math.floor(tonumber(amount) or 0))
end

local function normalizeItem(item)
	assert(type(item) == "table", "Inventory item must be a table")
	assert(item.Id ~= nil, "Inventory item is missing Id")
	assert(item.Name ~= nil, "Inventory item is missing Name")
	assert(item.Amount ~= nil, "Inventory item is missing Amount")

	local normalized = table.clone(item)
	normalized.Id = tostring(item.Id)
	normalized.Name = tostring(item.Name)
	normalized.Amount = normalizeAmount(item.Amount)

	return normalized
end

function State.new(config)
	return setmetatable({
		Config = config,
		Inventory = {},
		ItemById = {},
		Categories = table.clone(config.Categories or {}),
		SearchQuery = "",
		ActiveCategory = "Todas",
		ActiveRarity = "Todas",
		Selected = {},
		SelectedOrder = {},
		RarityRank = buildRarityRank(config),
		Changed = Signal.new(),
	}, State)
end

function State:SetInventory(items)
	assert(type(items) == "table", "SetInventory expects an array of item tables")

	self.Inventory = {}
	self.ItemById = {}

	for _, item in ipairs(items) do
		local normalized = normalizeItem(item)
		table.insert(self.Inventory, normalized)
		self.ItemById[normalized.Id] = normalized
	end

	for index = #self.SelectedOrder, 1, -1 do
		local itemId = self.SelectedOrder[index]
		local selected = self.Selected[itemId]
		local inventoryItem = self.ItemById[itemId]

		if not inventoryItem or inventoryItem.Amount <= 0 then
			self.Selected[itemId] = nil
			table.remove(self.SelectedOrder, index)
		else
			selected.Item = inventoryItem
			selected.Amount = math.clamp(selected.Amount, 1, inventoryItem.Amount)
		end
	end

	self.Changed:Fire()
end

function State:SetCategories(categories)
	self.Categories = table.clone(categories or self.Config.Categories or {})
	self.Changed:Fire()
end

function State:SetSearchQuery(query)
	self.SearchQuery = string.lower(tostring(query or ""))
	self.Changed:Fire()
end

function State:SetActiveCategory(category)
	self.ActiveCategory = tostring(category or "Todas")
	self.Changed:Fire()
end

function State:SetActiveRarity(rarity)
	self.ActiveRarity = tostring(rarity or "Todas")
	self.Changed:Fire()
end

function State:GetRarities()
	local seen = {}
	local rarities = { "Todas" }

	local function addRarity(rarity)
		rarity = tostring(rarity or "Item")
		if not seen[rarity] then
			seen[rarity] = true
			table.insert(rarities, rarity)
		end
	end

	for _, rarity in ipairs(self.Config.RarityOrder or {}) do
		addRarity(rarity)
	end

	for _, item in ipairs(self.Inventory) do
		addRarity(item.Rarity or "Item")
	end

	return rarities
end

function State:GetFilteredInventory()
	local filtered = {}
	local query = self.SearchQuery
	local category = self.ActiveCategory
	local rarity = self.ActiveRarity

	for _, item in ipairs(self.Inventory) do
		local matchesSearch = query == ""
			or string.find(string.lower(item.Name), query, 1, true) ~= nil
			or string.find(string.lower(item.Id), query, 1, true) ~= nil
		local matchesCategory = category == "Todas" or item.Category == category
		local matchesRarity = rarity == "Todas" or item.Rarity == rarity

		if matchesSearch and matchesCategory and matchesRarity then
			table.insert(filtered, item)
		end
	end

	table.sort(filtered, function(left, right)
		local leftRank = self.RarityRank[left.Rarity or "Default"] or self.RarityRank.Default
		local rightRank = self.RarityRank[right.Rarity or "Default"] or self.RarityRank.Default

		if leftRank == rightRank then
			return left.Name < right.Name
		end

		return leftRank < rightRank
	end)

	return filtered
end

function State:AddItem(itemId, amount)
	local id = tostring(itemId)
	local item = self.ItemById[id]

	if not item or item.Amount <= 0 then
		return false, "ItemUnavailable"
	end

	local selected = self.Selected[id]
	if not selected then
		if #self.SelectedOrder >= self.Config.MaxSelectedItems then
			return false, "MaxSelectedItems"
		end

		selected = {
			Item = item,
			Amount = 0,
		}

		self.Selected[id] = selected
		table.insert(self.SelectedOrder, id)
	end

	selected.Amount = math.clamp(selected.Amount + normalizeAmount(amount or 1), 1, item.Amount)
	self.Changed:Fire()

	return true
end

function State:ToggleItem(itemId)
	local id = tostring(itemId)

	if self.Selected[id] then
		self:RemoveItem(id)
		return true, "Removed"
	end

	return self:AddItem(id, 1)
end

function State:SetQuantity(itemId, amount)
	local id = tostring(itemId)
	local selected = self.Selected[id]
	local item = self.ItemById[id]

	if not selected or not item then
		return false, "ItemNotSelected"
	end

	local nextAmount = normalizeAmount(amount)
	if nextAmount <= 0 then
		self:RemoveItem(id)
		return true
	end

	selected.Amount = math.clamp(nextAmount, 1, item.Amount)
	self.Changed:Fire()

	return true
end

function State:Increment(itemId, delta)
	local id = tostring(itemId)
	local selected = self.Selected[id]

	if not selected then
		return self:AddItem(id, delta)
	end

	return self:SetQuantity(id, selected.Amount + (tonumber(delta) or 0))
end

function State:RemoveItem(itemId)
	local id = tostring(itemId)

	if not self.Selected[id] then
		return
	end

	self.Selected[id] = nil
	for index = #self.SelectedOrder, 1, -1 do
		if self.SelectedOrder[index] == id then
			table.remove(self.SelectedOrder, index)
			break
		end
	end

	self.Changed:Fire()
end

function State:ClearSelection()
	table.clear(self.Selected)
	table.clear(self.SelectedOrder)
	self.Changed:Fire()
end

function State:GetSelectedItems()
	local selectedItems = {}

	for _, itemId in ipairs(self.SelectedOrder) do
		local selected = self.Selected[itemId]
		if selected then
			table.insert(selectedItems, {
				Id = selected.Item.Id,
				Name = selected.Item.Name,
				Amount = selected.Amount,
				Item = selected.Item,
			})
		end
	end

	return selectedItems
end

function State:GetSelectedTypeCount()
	return #self.SelectedOrder
end

function State:GetSelectedAmountTotal()
	local total = 0

	for _, itemId in ipairs(self.SelectedOrder) do
		local selected = self.Selected[itemId]
		if selected then
			total += selected.Amount
		end
	end

	return total
end

function State:Destroy()
	self.Changed:Destroy()
	table.clear(self.Inventory)
	table.clear(self.ItemById)
	table.clear(self.Selected)
	table.clear(self.SelectedOrder)
end

return State
