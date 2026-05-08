local Maid = require(script.Parent.Parent.Utils.Maid)
local Animator = require(script.Parent.Parent.Utils.Animator)
local Tween = require(script.Parent.Parent.Utils.Tween)
local LucideIcons = require(script.Parent.Parent.Utils.LucideIcons)
local ItemCard = require(script.Parent.ItemCard)

local InventoryGrid = {}
InventoryGrid.__index = InventoryGrid

local function clearChildren(container, keepLayouts)
	for _, child in ipairs(container:GetChildren()) do
		local keep = keepLayouts and (child:IsA("UIGridLayout") or child:IsA("UIPadding"))
		if not keep then
			child:Destroy()
		end
	end
end

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function addStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = color
	stroke.Thickness = thickness or 1
	stroke.Parent = instance
	return stroke
end

local function makeButton(theme, text)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = theme.Colors.SurfaceAlt
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamSemibold
	button.Text = text or ""
	button.TextColor3 = theme.Colors.MutedText
	button.TextSize = 13
	button.Size = UDim2.fromOffset(96, 38)
	addCorner(button, theme.Radius.Button)
	return button
end

function InventoryGrid.new(props)
	local self = setmetatable({
		Config = props.Config or {},
		Theme = props.Theme,
		OnItemClick = props.OnItemClick,
		OnSearchQuery = props.OnSearchQuery,
		OnCategoryClick = props.OnCategoryClick,
		OnRaritySelected = props.OnRaritySelected or props.OnRarityClick,
		OnReset = props.OnReset,
		OnNext = props.OnNext,
		OnClose = props.OnClose,
		Maid = Maid.new(),
		CategoryMaid = Maid.new(),
		DropdownMaid = Maid.new(),
		Cards = {},
		DropdownOpen = false,
		RarityDropdownHeight = 40,
	}, InventoryGrid)

	self.Instance = self:_create()
	return self
end

function InventoryGrid:_create()
	local colors = self.Theme.Colors

	local root = Instance.new("Frame")
	root.Name = "InventoryGrid"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Parent = root
	self.Header = header

	local logoWrap = Instance.new("Frame")
	logoWrap.Name = "LogoWrap"
	logoWrap.BackgroundTransparency = 1
	logoWrap.Size = UDim2.new(0, 180, 1, 0)
	logoWrap.Parent = header
	self.LogoWrap = logoWrap

	local logoImage = self.Config.LogoImage or ""
	if string.match(logoImage, "^rbxasset") or string.match(logoImage, "^rbxthumb") then
		local logo = Instance.new("ImageLabel")
		logo.Name = "Logo"
		logo.BackgroundTransparency = 1
		logo.Image = logoImage
		logo.ScaleType = Enum.ScaleType.Fit
		logo.Size = UDim2.new(1, 0, 1, -6)
		logo.Position = UDim2.fromOffset(0, 3)
		logo.Parent = logoWrap
	else
		local logo = Instance.new("TextLabel")
		logo.Name = "LogoText"
		logo.BackgroundTransparency = 1
		logo.Font = Enum.Font.GothamBlack
		logo.Text = self.Config.LogoText or "TradeKit"
		logo.TextColor3 = colors.Text
		logo.TextSize = 24
		logo.TextXAlignment = Enum.TextXAlignment.Left
		logo.Size = UDim2.fromScale(1, 1)
		logo.Parent = logoWrap
	end

	local resetButton = makeButton(self.Theme, self.Config.Texts.Reset)
	resetButton.Name = "Reset"
	resetButton.AnchorPoint = Vector2.new(1, 0)
	resetButton.Size = UDim2.fromOffset(82, 38)
	resetButton.Position = UDim2.new(1, -200, 0, 6)
	resetButton.Parent = header
	addStroke(resetButton, colors.Border, 1)
	self.ResetButton = resetButton

	local nextButton = makeButton(self.Theme, self.Config.Texts.Next)
	nextButton.Name = "Next"
	nextButton.AnchorPoint = Vector2.new(1, 0)
	nextButton.BackgroundColor3 = colors.AccentAlt
	nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	nextButton.TextSize = 13
	nextButton.Size = UDim2.fromOffset(154, 38)
	nextButton.Position = UDim2.new(1, -46, 0, 6)
	nextButton.Parent = header
	self.NextButton = nextButton

	local closeButton = makeButton(self.Theme, "")
	closeButton.Name = "Close"
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Size = UDim2.fromOffset(38, 38)
	closeButton.Position = UDim2.new(1, 0, 0, 6)
	closeButton.Parent = header
	addStroke(closeButton, colors.Border, 1)
	self.CloseButton = closeButton

	local closeIcon = LucideIcons.new("X", {
		Color = colors.MutedText,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextSize = 14,
	})
	closeIcon.Parent = closeButton

	Animator.bindHoverPress(resetButton, self.Maid, { HoverScale = 1.02, PressScale = 0.98 })
	Animator.bindHoverPress(nextButton, self.Maid, { HoverScale = 1.018, PressScale = 0.98 })
	Animator.bindHoverPress(closeButton, self.Maid, { HoverScale = 1.04, PressScale = 0.96, HoverColor = colors.SurfaceRaised })

	self.Maid:GiveTask(resetButton.Activated:Connect(function()
		if self.OnReset then
			self.OnReset()
		end
	end))

	self.Maid:GiveTask(nextButton.Activated:Connect(function()
		if self.OnNext then
			self.OnNext()
		end
	end))

	self.Maid:GiveTask(closeButton.Activated:Connect(function()
		if self.OnClose then
			self.OnClose()
		end
	end))

	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.BackgroundColor3 = colors.Border
	divider.BorderSizePixel = 0
	divider.BackgroundTransparency = 0.25
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.fromOffset(0, 50)
	divider.Parent = header
	self.Divider = divider

	local controls = Instance.new("Frame")
	controls.Name = "Controls"
	controls.BackgroundTransparency = 1
	controls.Size = UDim2.new(1, 0, 0, 38)
	controls.Position = UDim2.fromOffset(0, 62)
	controls.Parent = root
	self.Controls = controls

	local search = Instance.new("TextBox")
	search.Name = "Search"
	search.BackgroundColor3 = colors.SurfaceDeep
	search.BorderSizePixel = 0
	search.ClearTextOnFocus = false
	search.Font = Enum.Font.Gotham
	search.PlaceholderText = self.Config.Texts.SearchPlaceholder
	search.PlaceholderColor3 = colors.SubtleText
	search.Text = ""
	search.TextColor3 = colors.Text
	search.TextSize = 14
	search.TextXAlignment = Enum.TextXAlignment.Left
	search.Size = UDim2.new(1, -166, 1, 0)
	search.Parent = controls
	addCorner(search, 8)
	local searchStroke = addStroke(search, colors.Border, 1)

	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 16)
	searchPadding.PaddingRight = UDim.new(0, 12)
	searchPadding.Parent = search
	self.SearchBox = search
	self.SearchStroke = searchStroke

	local rarity = makeButton(self.Theme, self.Config.Texts.RarityFilter)
	rarity.Name = "RarityFilter"
	rarity.Size = UDim2.fromOffset(150, 38)
	rarity.Position = UDim2.new(1, -158, 0, 0)
	rarity.TextXAlignment = Enum.TextXAlignment.Left
	rarity.Parent = controls
	addStroke(rarity, colors.Border, 1)
	local rarityPadding = Instance.new("UIPadding")
	rarityPadding.PaddingLeft = UDim.new(0, 14)
	rarityPadding.PaddingRight = UDim.new(0, 28)
	rarityPadding.Parent = rarity

	local rarityChevron = LucideIcons.new("ChevronDown", {
		Color = colors.MutedText,
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextSize = 12,
	})
	rarityChevron.Parent = rarity
	self.RarityButton = rarity
	self.RarityChevron = rarityChevron
	Animator.bindHoverPress(rarity, self.Maid, {
		HoverScale = 1.018,
		PressScale = 0.98,
		HoverColor = colors.SurfaceRaised,
	})

	local dropdown = Instance.new("Frame")
	dropdown.Name = "RarityDropdown"
	dropdown.BackgroundColor3 = colors.SurfaceAlt
	dropdown.Active = true
	dropdown.BorderSizePixel = 0
	dropdown.Position = UDim2.new(1, -158, 0, 104)
	dropdown.Size = UDim2.fromOffset(150, 40)
	dropdown.Visible = false
	dropdown.ZIndex = 80
	dropdown.Parent = root
	addCorner(dropdown, 8)
	addStroke(dropdown, colors.BorderBright, 1)

	local dropdownList = Instance.new("ScrollingFrame")
	dropdownList.Name = "Options"
	dropdownList.Active = true
	dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dropdownList.BackgroundTransparency = 1
	dropdownList.BorderSizePixel = 0
	dropdownList.CanvasSize = UDim2.fromOffset(0, 0)
	dropdownList.Position = UDim2.fromOffset(4, 4)
	dropdownList.ScrollBarImageColor3 = colors.BorderBright
	dropdownList.ScrollBarThickness = 3
	dropdownList.Size = UDim2.new(1, -8, 1, -8)
	dropdownList.ZIndex = 81
	dropdownList.Parent = dropdown

	local dropdownLayout = Instance.new("UIListLayout")
	dropdownLayout.Padding = UDim.new(0, 4)
	dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
	dropdownLayout.Parent = dropdownList

	self.RarityDropdown = dropdown
	self.RarityOptionList = dropdownList

	self.Maid:GiveTask(search.Focused:Connect(function()
		self:_setDropdownOpen(false)
		Tween.to(searchStroke, { Time = 0.14 }, { Color = colors.BorderBright, Transparency = 0 })
	end))

	self.Maid:GiveTask(search.FocusLost:Connect(function()
		Tween.to(searchStroke, { Time = 0.14 }, { Color = colors.Border, Transparency = 0 })
	end))

	self.Maid:GiveTask(search:GetPropertyChangedSignal("Text"):Connect(function()
		if self.OnSearchQuery then
			self.OnSearchQuery(search.Text)
		end
	end))

	self.Maid:GiveTask(rarity.Activated:Connect(function()
		self:_setDropdownOpen(not self.DropdownOpen)
	end))

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Scroller"
	scroller.Active = true
	scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroller.BackgroundColor3 = colors.SurfaceDeep
	scroller.BackgroundTransparency = 0.08
	scroller.BorderSizePixel = 0
	scroller.CanvasSize = UDim2.fromOffset(0, 0)
	scroller.ScrollBarImageColor3 = colors.BorderBright
	scroller.ScrollBarThickness = 7
	scroller.Size = UDim2.new(1, 0, 1, -106)
	scroller.Position = UDim2.fromOffset(0, 106)
	scroller.ZIndex = 1
	scroller.Parent = root
	addCorner(scroller, 8)

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = scroller

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(134, 118)
	layout.CellPadding = UDim2.fromOffset(8, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroller
	self.GridLayout = layout
	self.Scroller = scroller

	return root
end

function InventoryGrid:_setCardsInputEnabled(enabled)
	for _, card in ipairs(self.Cards) do
		if card.Instance then
			card.Instance.Active = enabled
		end
	end
end

function InventoryGrid:_setDropdownOpen(open)
	self.DropdownOpen = open

	if self.RarityDropdown then
		self.RarityDropdown.Visible = open
	end

	self:_setCardsInputEnabled(not open)

	if self.RarityChevron then
		Tween.to(self.RarityChevron, { Time = 0.12 }, { Rotation = open and 180 or 0 })
	end
end

function InventoryGrid:_renderRarityDropdown(rarities, activeRarity)
	if not self.RarityOptionList then
		return
	end

	rarities = rarities or { "Todas" }
	activeRarity = activeRarity or "Todas"
	self.DropdownMaid:DoCleaning()

	for _, child in ipairs(self.RarityOptionList:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	local colors = self.Theme.Colors
	for index, rarity in ipairs(rarities) do
		local selected = rarity == activeRarity
		local option = Instance.new("TextButton")
		option.Name = "Option_" .. tostring(rarity)
		option.AutoButtonColor = false
		option.BackgroundColor3 = selected and colors.AccentAlt or colors.SurfaceDeep
		option.BackgroundTransparency = selected and 0 or 0.22
		option.BorderSizePixel = 0
		option.Font = Enum.Font.GothamSemibold
		option.LayoutOrder = index
		option.Text = rarity == "Todas" and "Todas" or tostring(rarity)
		option.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or colors.MutedText
		option.TextSize = 12
		option.TextXAlignment = Enum.TextXAlignment.Left
		option.Size = UDim2.new(1, 0, 0, 30)
		option.ZIndex = 82
		option.Parent = self.RarityOptionList
		addCorner(option, 6)

		local optionPadding = Instance.new("UIPadding")
		optionPadding.PaddingLeft = UDim.new(0, 10)
		optionPadding.PaddingRight = UDim.new(0, 10)
		optionPadding.Parent = option

		self.DropdownMaid:GiveTask(option.Activated:Connect(function()
			self:_setDropdownOpen(false)
			if self.OnRaritySelected then
				self.OnRaritySelected(rarity)
			end
		end))

		Animator.bindHoverPress(option, self.DropdownMaid, {
			HoverScale = 1,
			PressScale = 0.99,
			HoverColor = selected and colors.AccentAlt or colors.SurfaceRaised,
		})
	end

	local height = math.min(240, (#rarities * 34) + 8)
	self.RarityDropdownHeight = height
	if self.RarityDropdown then
		local width = self.RarityDropdown.AbsoluteSize.X > 0 and self.RarityDropdown.AbsoluteSize.X or 150
		self.RarityDropdown.Size = UDim2.fromOffset(width, height)
	end
end

function InventoryGrid:UpdateLayout(windowSize)
	local width = (windowSize and windowSize.X) or (self.Instance and self.Instance.AbsoluteSize.X) or 800
	local height = (windowSize and windowSize.Y) or (self.Instance and self.Instance.AbsoluteSize.Y) or 640
	if width < 320 then
		width = (self.Config.Window and self.Config.Window.MaxWidth) or 800
	end

	local compact = width < 620
	local narrow = width < 460
	local short = height < 430
	local mobile = compact or (short and width < 700)
	self.LastLayoutSize = Vector2.new(width, height)

	local headerHeight = short and 34 or 50
	local controlY = short and 42 or 62
	local controlHeight = short and 34 or 38
	local scrollerY = short and 82 or 106

	if self.Header then
		self.Header.Size = UDim2.new(1, 0, 0, headerHeight)
	end

	if self.Divider then
		self.Divider.Position = UDim2.fromOffset(0, headerHeight)
	end

	if self.Controls then
		self.Controls.Size = UDim2.new(1, 0, 0, controlHeight)
		self.Controls.Position = UDim2.fromOffset(0, controlY)
	end

	if self.LogoWrap then
		self.LogoWrap.Size = UDim2.new(0, narrow and 96 or mobile and 132 or 180, 1, 0)
	end

	local buttonY = short and 1 or 6
	local buttonHeight = short and 32 or 38
	local closeWidth = buttonHeight
	local nextWidth = mobile and 116 or narrow and 120 or 154
	local resetWidth = mobile and 70 or 82
	local buttonGap = 8

	if self.CloseButton then
		self.CloseButton.Size = UDim2.fromOffset(closeWidth, buttonHeight)
		self.CloseButton.Position = UDim2.new(1, 0, 0, buttonY)
	end

	if self.NextButton then
		self.NextButton.Size = UDim2.fromOffset(nextWidth, buttonHeight)
		self.NextButton.Position = UDim2.new(1, -(closeWidth + buttonGap), 0, buttonY)
	end

	if self.ResetButton then
		self.ResetButton.Size = UDim2.fromOffset(resetWidth, buttonHeight)
		self.ResetButton.Position = UDim2.new(1, -(closeWidth + buttonGap + nextWidth + buttonGap), 0, buttonY)
	end

	local rarityWidth = mobile and 112 or compact and 130 or 150
	local rarityX = -(rarityWidth + 8)

	if self.SearchBox then
		self.SearchBox.Size = UDim2.new(1, -(rarityWidth + 16), 1, 0)
		self.SearchBox.TextSize = mobile and 12 or 14
	end

	if self.RarityButton then
		self.RarityButton.Size = UDim2.fromOffset(rarityWidth, controlHeight)
		self.RarityButton.Position = UDim2.new(1, rarityX, 0, 0)
		self.RarityButton.TextSize = mobile and 11 or 13
	end

	if self.RarityDropdown then
		self.RarityDropdown.Size = UDim2.fromOffset(rarityWidth, self.RarityDropdownHeight or 40)
		self.RarityDropdown.Position = UDim2.new(1, rarityX, 0, scrollerY - 2)
	end

	if self.Scroller then
		self.Scroller.Position = UDim2.fromOffset(0, scrollerY)
		self.Scroller.Size = UDim2.new(1, 0, 1, -scrollerY)
		self.Scroller.ScrollBarThickness = mobile and 5 or 7
	end

	if self.GridLayout and self.Scroller then
		local available = math.max(120, width - (mobile and 40 or 64))
		local gap = mobile and 6 or compact and 6 or 8
		local targetColumns = 5

		if width < 780 then
			targetColumns = 4
		end
		if width < 620 then
			targetColumns = 3
		end
		if width < 460 then
			targetColumns = 2
		end
		if short and width < 430 then
			targetColumns = 3
		elseif short and width < 620 then
			targetColumns = 4
		elseif short then
			targetColumns = 5
		end

		local cardWidth = math.floor((available - (targetColumns - 1) * gap) / targetColumns)
		local dense = mobile and targetColumns >= 5
		local minWidth = short and 86 or dense and 104 or mobile and 104 or 118
		local maxWidth = short and 112 or dense and 128 or mobile and 136 or 148
		cardWidth = math.clamp(cardWidth, minWidth, maxWidth)

		local cardHeight
		if mobile and short then
			cardHeight = math.max(68, math.floor(cardWidth * 0.7))
		elseif dense then
			cardHeight = math.max(86, math.floor(cardWidth * 0.72))
		else
			cardHeight = math.max(112, math.floor(cardWidth * 0.82))
		end

		self.GridLayout.CellPadding = UDim2.fromOffset(gap, gap)
		self.GridLayout.CellSize = UDim2.fromOffset(cardWidth, cardHeight)
		self.CardCompact = mobile or dense
		self.CardShort = mobile and short
	end
end

function InventoryGrid:Render(items, selectedMap, viewState)
	viewState = viewState or {}
	local instanceSize = self.Instance.AbsoluteSize
	if instanceSize.X > 0 and instanceSize.Y > 0 then
		self:UpdateLayout(instanceSize)
	else
		self:UpdateLayout(self.LastLayoutSize or instanceSize)
	end

	for _, card in ipairs(self.Cards) do
		card:Destroy()
	end
	table.clear(self.Cards)
	clearChildren(self.Scroller, true)

	if self.SearchBox and not self.SearchBox:IsFocused() then
		self.SearchBox.Text = viewState.SearchQuery or ""
	end

	if self.RarityButton then
		self.RarityButton.Text = viewState.ActiveRarity == "Todas" and self.Config.Texts.RarityFilter or viewState.ActiveRarity
	end
	self:_renderRarityDropdown(viewState.Rarities, viewState.ActiveRarity)

	if self.ResetButton then
		local hasSelection = (viewState.SelectedTypes or 0) > 0
		self.ResetButton.Active = hasSelection
		self.ResetButton.AutoButtonColor = hasSelection
		self.ResetButton.BackgroundTransparency = 0
		self.ResetButton.TextTransparency = 0
		self.ResetButton.TextColor3 = hasSelection and self.Theme.Colors.Text or self.Theme.Colors.MutedText
	end

	if self.NextButton then
		local enabled = (viewState.SelectedTypes or 0) > 0
		self.NextButton.Active = enabled
		self.NextButton.AutoButtonColor = enabled
		self.NextButton.BackgroundColor3 = enabled and self.Theme.Colors.AccentAlt or self.Theme.Colors.SurfaceRaised
		self.NextButton.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or self.Theme.Colors.MutedText
		self.NextButton.BackgroundTransparency = 0
		self.NextButton.TextTransparency = 0
	end

	if #items == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "Empty"
		empty.BackgroundTransparency = 1
		empty.Font = Enum.Font.Gotham
		empty.Text = self.Config.Texts.EmptyInventory
		empty.TextColor3 = self.Theme.Colors.MutedText
		empty.TextSize = 14
		empty.Size = UDim2.new(1, -20, 0, 44)
		empty.Parent = self.Scroller
	else
		for index, item in ipairs(items) do
			local selected = selectedMap[item.Id]
			local selectedAmount = selected and selected.Amount or 0

			local card = ItemCard.new({
				Theme = self.Theme,
				Item = item,
				SelectedAmount = selectedAmount,
				OnActivated = self.OnItemClick,
				Compact = self.CardCompact,
				Short = self.CardShort,
			})

			card.Instance.LayoutOrder = index
			card.Instance.Active = not self.DropdownOpen
			card.Instance.Parent = self.Scroller
			table.insert(self.Cards, card)
		end
	end
end

function InventoryGrid:Destroy()
	for _, card in ipairs(self.Cards) do
		card:Destroy()
	end
	table.clear(self.Cards)

	self.CategoryMaid:Destroy()
	self.DropdownMaid:Destroy()
	self.Maid:Destroy()

	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

return InventoryGrid