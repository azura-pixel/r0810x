local Maid = require(script.Parent.Parent.Utils.Maid)
local Animator = require(script.Parent.Parent.Utils.Animator)
local LucideIcons = require(script.Parent.Parent.Utils.LucideIcons)

local ItemCard = {}
ItemCard.__index = ItemCard

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

local function formatCompactAmount(amount)
	amount = tonumber(amount) or 0

	if amount >= 1000000000 then
		return string.format("%.1fB", amount / 1000000000):gsub("%.0B", "B")
	elseif amount >= 1000000 then
		return string.format("%.1fM", amount / 1000000):gsub("%.0M", "M")
	elseif amount >= 1000 then
		return string.format("%.1fK", amount / 1000):gsub("%.0K", "K")
	end

	return tostring(amount)
end


function ItemCard.new(props)
	local self = setmetatable({
		Theme = props.Theme,
		Item = props.Item,
		SelectedAmount = props.SelectedAmount or 0,
		OnActivated = props.OnActivated,
		Compact = props.Compact == true,
		Short = props.Short == true,
		Maid = Maid.new(),
	}, ItemCard)

	self.Instance = self:_create()
	return self
end

function ItemCard:_create()
	local theme = self.Theme
	local colors = theme.Colors
	local item = self.Item
	local rarityColor = theme.Rarity[item.Rarity or "Default"] or theme.Rarity.Default
	local compact = self.Compact
	local short = self.Short
	local imageHeight = short and 30 or compact and 38 or 48
	local imageTop = short and 14 or compact and 18 or 22
	local nameHeight = short and 11 or compact and 14 or 18
	local amountHeight = short and 9 or compact and 12 or 14
	local bottomInset = short and 6 or compact and 8 or 10
	local labelGap = short and 1 or 2

	local button = Instance.new("TextButton")
	button.Name = "ItemCard_" .. item.Id
	button.AutoButtonColor = false
	button.BackgroundColor3 = colors.SurfaceAlt
	button.BorderSizePixel = 0
	button.ClipsDescendants = true
	button.Text = ""
	button.Size = UDim2.fromOffset(short and 96 or compact and 112 or 134, short and 70 or compact and 94 or 118)

	addCorner(button, theme.Radius.Card)
	local stroke = addStroke(button, rarityColor, self.SelectedAmount > 0 and 2 or 1)

	local image = Instance.new("ImageLabel")
	image.Name = "Image"
	image.BackgroundTransparency = 1
	image.Image = item.Image or ""
	image.ScaleType = Enum.ScaleType.Fit
	image.Size = UDim2.new(1, short and -28 or -36, 0, imageHeight)
	image.Position = UDim2.fromOffset(short and 14 or 18, imageTop)
	image.ZIndex = 2
	image.Parent = button


	if item.Image == nil or item.Image == "" or item.Image == "rbxassetid://0" then
		local fallback = Instance.new("TextLabel")
		fallback.Name = "FallbackIcon"
		fallback.BackgroundTransparency = 1
		fallback.Font = Enum.Font.GothamBlack
		fallback.Text = item.IconText or string.upper(string.sub(item.Name, 1, 3))
		fallback.TextColor3 = rarityColor
		fallback.TextSize = short and 13 or compact and 15 or 18
		fallback.Size = UDim2.new(1, -16, 0, short and 28 or compact and 36 or 44)
		fallback.Position = UDim2.fromOffset(8, short and 18 or compact and 24 or 28)
		fallback.ZIndex = 3
		fallback.Parent = button
	end

	local amount = Instance.new("TextLabel")
	amount.Name = "Amount"
	amount.BackgroundTransparency = 1
	amount.Font = Enum.Font.GothamSemibold
	amount.Text = "x" .. formatCompactAmount(item.Amount)
	amount.TextColor3 = colors.MutedText
	amount.TextSize = short and 8 or compact and 9 or 10
	amount.TextXAlignment = Enum.TextXAlignment.Left
	amount.AnchorPoint = Vector2.new(0, 1)
	amount.Size = UDim2.new(1, -16, 0, amountHeight)
	amount.Position = UDim2.new(0, 8, 1, -(bottomInset + nameHeight + labelGap))
	amount.Parent = button
	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.Text = item.Name
	name.TextColor3 = colors.Text
	name.TextSize = short and 9 or compact and 10 or 11
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.AnchorPoint = Vector2.new(0, 1)
	name.Size = UDim2.new(1, -16, 0, nameHeight)
	name.Position = UDim2.new(0, 8, 1, -bottomInset)
	name.Parent = button

	if self.SelectedAmount > 0 then
		local selectedBadge = Instance.new("Frame")
		selectedBadge.Name = "SelectedBadge"
		selectedBadge.AnchorPoint = Vector2.new(1, 0)
		selectedBadge.BackgroundColor3 = colors.Accent
		selectedBadge.BorderSizePixel = 0
		selectedBadge.Size = UDim2.fromOffset(short and 20 or 26, short and 18 or 22)
		selectedBadge.Position = UDim2.new(1, short and -6 or -8, 0, short and 6 or 8)
		selectedBadge.Parent = button
		addCorner(selectedBadge, 7)

		local check = LucideIcons.new("Check", {
			Color = colors.Text,
			Size = UDim2.fromOffset(short and 11 or 15, short and 11 or 15),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextSize = short and 11 or 15,
		})
		check.Parent = selectedBadge
	end

	Animator.bindHoverPress(button, self.Maid, {
		HoverScale = 1.01,
		PressScale = 0.985,
		HoverColor = colors.SurfaceRaised,
	})

	self.Maid:GiveTask(button.MouseEnter:Connect(function()
		if button.Active == false then
			return
		end

		stroke.Thickness = self.SelectedAmount > 0 and 2 or 1.5
		stroke.Color = rarityColor:Lerp(colors.Text, 0.18)
	end))

	self.Maid:GiveTask(button.MouseLeave:Connect(function()
		stroke.Thickness = self.SelectedAmount > 0 and 2 or 1
		stroke.Color = rarityColor
	end))

	self.Maid:GiveTask(button.Activated:Connect(function()
		if self.OnActivated then
			self.OnActivated(item)
		end
	end))

	return button
end

function ItemCard:Destroy()
	self.Maid:Destroy()

	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

return ItemCard
















