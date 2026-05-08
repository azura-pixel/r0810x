local TweenService = game:GetService("TweenService")

local Maid = require(script.Parent.Parent.Utils.Maid)
local Animator = require(script.Parent.Parent.Utils.Animator)
local LucideIcons = require(script.Parent.Parent.Utils.LucideIcons)

local SelectedPanel = {}
SelectedPanel.__index = SelectedPanel

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

local function makeButton(theme, text, width, height)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = theme.Colors.SurfaceDeep
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = theme.Colors.Text
	button.TextSize = 14
	button.Size = UDim2.fromOffset(width or 34, height or 34)
	addCorner(button, theme.Radius.Button)
	addStroke(button, theme.Colors.Border, 1)

	local iconName = ({
		["+"] = "Plus",
		["-"] = "Minus",
		["x"] = "X",
	})[text]

	if iconName then
		button.Text = ""
		local icon = LucideIcons.new(iconName, {
			Color = theme.Colors.Text,
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextSize = 18,
		})
		icon.Parent = button
	else
		button.Text = text
	end

	return button
end

local function getRarityColor(theme, item)
	return theme.Rarity[item.Rarity or "Default"] or theme.Rarity.Default
end

function SelectedPanel.new(props)
	local self = setmetatable({
		Config = props.Config or {},
		Theme = props.Theme,
		SubmitText = props.SubmitText or "Confirmar",
		MaxSelectedItems = props.MaxSelectedItems or 20,
		OnSetQuantity = props.OnSetQuantity,
		OnRemoveItem = props.OnRemoveItem,
		OnSubmit = props.OnSubmit,
		OnBack = props.OnBack,
		OnDelivered = props.OnDelivered,
		Maid = Maid.new(),
		RowMaid = Maid.new(),
		IsDelivering = false,
		Delivered = false,
	}, SelectedPanel)

	self.Instance = self:_create()
	return self
end

function SelectedPanel:_create()
	local theme = self.Theme
	local colors = theme.Colors

	local root = Instance.new("Frame")
	root.Name = "SelectedPanel"
	root.BackgroundColor3 = colors.SurfaceDeep
	root.BackgroundTransparency = 0.04
	root.BorderSizePixel = 0
	root.Size = UDim2.fromScale(1, 1)
	addCorner(root, 12)
	addStroke(root, colors.BorderBright, 1)

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 18)
	padding.PaddingBottom = UDim.new(0, 18)
	padding.PaddingLeft = UDim.new(0, 18)
	padding.PaddingRight = UDim.new(0, 18)
	padding.Parent = root
	self.RootPadding = padding

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 42)
	header.Parent = root
	self.Header = header


	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = (self.Config.Texts and self.Config.Texts.SelectedTitle) or "TUS ARMAS ELEGIDAS"
	title.TextColor3 = colors.Text
	title.TextSize = 17
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Size = UDim2.new(1, -130, 0, 34)
	title.Position = UDim2.fromOffset(0, 2)
	title.Parent = header
	self.Title = title

	local count = Instance.new("TextLabel")
	count.Name = "Count"
	count.AnchorPoint = Vector2.new(1, 0)
	count.BackgroundTransparency = 1
	count.Font = Enum.Font.GothamBold
	count.TextColor3 = colors.Text
	count.TextSize = 15
	count.TextXAlignment = Enum.TextXAlignment.Right
	count.Size = UDim2.fromOffset(120, 34)
	count.Position = UDim2.new(1, 0, 0, 4)
	count.Parent = header
	self.Count = count

	local rows = Instance.new("ScrollingFrame")
	rows.Name = "Rows"
	rows.Active = true
	rows.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rows.BackgroundTransparency = 1
	rows.BorderSizePixel = 0
	rows.CanvasSize = UDim2.fromOffset(0, 0)
	rows.ScrollBarImageColor3 = colors.BorderBright
	rows.ScrollBarThickness = 5
	rows.Size = UDim2.new(1, 0, 1, -120)
	rows.Position = UDim2.fromOffset(0, 48)
	rows.Parent = root

	local rowLayout = Instance.new("UIListLayout")
	rowLayout.Padding = UDim.new(0, 8)
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Parent = rows
	self.RowLayout = rowLayout
	self.Rows = rows

	local offer = Instance.new("Frame")
	offer.Name = "OfferPreview"
	offer.AnchorPoint = Vector2.new(0, 1)
	offer.BackgroundTransparency = 1
	offer.Size = UDim2.new(1, 0, 0, 188)
	offer.Position = UDim2.new(0, 0, 1, -196)
	offer.Visible = false
	offer.Parent = root
	addStroke(offer, colors.Border, 1)
	self.OfferPreview = offer

	local offerCorner = addCorner(offer, 10)
	offerCorner.CornerRadius = UDim.new(0, 10)

	local offerTitle = Instance.new("TextLabel")
	offerTitle.Name = "OfferTitle"
	offerTitle.BackgroundTransparency = 1
	offerTitle.Font = Enum.Font.GothamSemibold
	offerTitle.Text = "Tu oferta actual"
	offerTitle.TextColor3 = colors.Text
	offerTitle.TextSize = 18
	offerTitle.Size = UDim2.new(1, 0, 0, 34)
	offerTitle.Position = UDim2.fromOffset(0, 20)
	offerTitle.Parent = offer

	local previewStrip = Instance.new("Frame")
	previewStrip.Name = "PreviewStrip"
	previewStrip.BackgroundTransparency = 1
	previewStrip.Size = UDim2.new(1, -40, 0, 92)
	previewStrip.Position = UDim2.fromOffset(20, 70)
	previewStrip.Parent = offer
	self.PreviewStrip = previewStrip

	local previewLayout = Instance.new("UIListLayout")
	previewLayout.FillDirection = Enum.FillDirection.Horizontal
	previewLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	previewLayout.Padding = UDim.new(0, 16)
	previewLayout.SortOrder = Enum.SortOrder.LayoutOrder
	previewLayout.Parent = previewStrip

	local stats = Instance.new("Frame")
	stats.Name = "Stats"
	stats.AnchorPoint = Vector2.new(0, 1)
	stats.BackgroundTransparency = 1
	stats.Size = UDim2.new(1, 0, 0, 62)
	stats.Position = UDim2.new(0, 0, 1, -116)
	stats.Visible = false
	stats.Parent = root
	self.Stats = stats

	local totalBox = Instance.new("Frame")
	totalBox.Name = "TotalBox"
	totalBox.BackgroundColor3 = colors.SurfaceAlt
	totalBox.BorderSizePixel = 0
	totalBox.Size = UDim2.new(0.5, -4, 1, 0)
	totalBox.Parent = stats
	addCorner(totalBox, 8)

	local totalLabel = Instance.new("TextLabel")
	totalLabel.Name = "Label"
	totalLabel.BackgroundTransparency = 1
	totalLabel.Font = Enum.Font.Gotham
	totalLabel.Text = "TOTAL DE ARMAS"
	totalLabel.TextColor3 = colors.MutedText
	totalLabel.TextSize = 13
	totalLabel.TextXAlignment = Enum.TextXAlignment.Left
	totalLabel.Size = UDim2.new(1, -84, 1, 0)
	totalLabel.Position = UDim2.fromOffset(18, 0)
	totalLabel.Parent = totalBox

	local totalValue = Instance.new("TextLabel")
	totalValue.Name = "Value"
	totalValue.AnchorPoint = Vector2.new(1, 0)
	totalValue.BackgroundTransparency = 1
	totalValue.Font = Enum.Font.GothamBold
	totalValue.TextColor3 = colors.Text
	totalValue.TextSize = 18
	totalValue.TextXAlignment = Enum.TextXAlignment.Right
	totalValue.Size = UDim2.new(0, 64, 1, 0)
	totalValue.Position = UDim2.new(1, -18, 0, 0)
	totalValue.Parent = totalBox
	self.TotalValue = totalValue

	local slotsBox = totalBox:Clone()
	slotsBox.Name = "SlotsBox"
	slotsBox.Position = UDim2.new(0.5, 4, 0, 0)
	slotsBox.Parent = stats
	slotsBox.Label.Text = "ESPACIOS USADOS"
	self.SlotsValue = slotsBox.Value

	local delivered = Instance.new("TextLabel")
	delivered.Name = "DeliveredMessage"
	delivered.AnchorPoint = Vector2.new(0.5, 0.5)
	delivered.BackgroundTransparency = 1
	delivered.Font = Enum.Font.GothamBlack
	delivered.Text = (self.Config.Texts and self.Config.Texts.Delivered) or "ARMAS ENTREGADAS"
	delivered.TextColor3 = colors.Success
	delivered.TextSize = 28
	delivered.TextTransparency = 1
	delivered.Size = UDim2.new(1, -40, 0, 48)
	delivered.Position = UDim2.fromScale(0.5, 0.48)
	delivered.Visible = false
	delivered.Parent = root
	self.DeliveredMessage = delivered
	local back = Instance.new("TextButton")
	back.Name = "Back"
	back.AnchorPoint = Vector2.new(0, 1)
	back.AutoButtonColor = false
	back.BackgroundColor3 = colors.SurfaceAlt
	back.BorderSizePixel = 0
	back.Font = Enum.Font.GothamBold
	back.Text = "  " .. ((self.Config.Texts and self.Config.Texts.Back) or "Volver")
	back.TextColor3 = colors.Text
	back.TextSize = 13
	back.Size = UDim2.new(0, 118, 0, 52)
	back.Position = UDim2.fromScale(0, 1)
	back.Parent = root
	addCorner(back, theme.Radius.Button)
	addStroke(back, colors.BorderBright, 1)

	local backIcon = LucideIcons.new("ArrowLeft", {
		Color = colors.Text,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(14, 18),
		TextSize = 18,
	})
	backIcon.Parent = back
	self.BackIcon = backIcon

	Animator.bindHoverPress(back, self.Maid, { HoverScale = 1.018, PressScale = 0.98, HoverColor = colors.SurfaceRaised })

	self.BackButton = back

	self.Maid:GiveTask(back.Activated:Connect(function()
		if self.OnBack then
			self.OnBack()
		end
	end))

	local submit = Instance.new("TextButton")
	submit.Name = "Submit"
	submit.AnchorPoint = Vector2.new(0, 1)
	submit.AutoButtonColor = false
	submit.BackgroundColor3 = colors.AccentAlt
	submit.BorderSizePixel = 0
	submit.Font = Enum.Font.GothamBold
	submit.Text = self.SubmitText
	submit.TextColor3 = Color3.fromRGB(255, 255, 255)
	submit.TextSize = 18
	submit.Size = UDim2.new(1, -132, 0, 52)
	submit.Position = UDim2.new(0, 132, 1, 0)
	submit.Parent = root
	addCorner(submit, theme.Radius.Button)
	Animator.bindHoverPress(submit, self.Maid, { HoverScale = 1.012, PressScale = 0.985 })




	self.Maid:GiveTask(submit.Activated:Connect(function()
		if self.IsDelivering then
			return
		end

		if self.OnSubmit then
			self.OnSubmit()
		end

		self:PlayDelivered()
	end))

	self.Submit = submit
	return root
end

function SelectedPanel:UpdateLayout(windowSize)
	local width = (windowSize and windowSize.X) or (self.Instance and self.Instance.AbsoluteSize.X) or 800
	local height = (windowSize and windowSize.Y) or (self.Instance and self.Instance.AbsoluteSize.Y) or 640
	local short = height < 430
	local compact = short or width < 620
	self.LastLayoutSize = Vector2.new(width, height)
	self.ShortLayout = compact

	if self.RootPadding then
		local inset = compact and 8 or 18
		self.RootPadding.PaddingTop = UDim.new(0, inset)
		self.RootPadding.PaddingBottom = UDim.new(0, inset)
		self.RootPadding.PaddingLeft = UDim.new(0, compact and 10 or 18)
		self.RootPadding.PaddingRight = UDim.new(0, compact and 10 or 18)
	end

	if self.Header then
		self.Header.Size = UDim2.new(1, 0, 0, compact and 28 or 42)
	end

	if self.Title then
		self.Title.TextSize = compact and 13 or 17
		self.Title.Size = UDim2.new(1, compact and -70 or -130, 0, compact and 24 or 34)
		self.Title.Position = UDim2.fromOffset(0, compact and 0 or 2)
	end

	if self.Count then
		self.Count.TextSize = compact and 12 or 15
		self.Count.Size = UDim2.fromOffset(compact and 64 or 120, compact and 24 or 34)
		self.Count.Position = UDim2.new(1, 0, 0, compact and 0 or 4)
	end

	if self.RowLayout then
		self.RowLayout.Padding = UDim.new(0, compact and 6 or 8)
	end

	if self.Rows then
		local rowsY = compact and 34 or 48
		local footerSpace = compact and 54 or 120
		self.Rows.Position = UDim2.fromOffset(0, rowsY)
		self.Rows.Size = UDim2.new(1, 0, 1, -(rowsY + footerSpace))
		self.Rows.ScrollBarThickness = compact and 3 or 5
	end

	if self.BackButton then
		self.BackButton.Size = UDim2.new(0, compact and 88 or 118, 0, compact and 38 or 52)
		self.BackButton.TextSize = compact and 11 or 13
	end

	if self.BackIcon then
		self.BackIcon.Size = UDim2.fromOffset(compact and 12 or 16, compact and 12 or 16)
		self.BackIcon.Position = UDim2.fromOffset(compact and 10 or 14, compact and 13 or 18)
	end

	if self.Submit then
		local backWidth = compact and 96 or 132
		self.Submit.Size = UDim2.new(1, -backWidth, 0, compact and 38 or 52)
		self.Submit.Position = UDim2.new(0, backWidth, 1, 0)
		self.Submit.TextSize = compact and 13 or 18
	end
end
function SelectedPanel:_createRow(selectedItem, order)
	local theme = self.Theme
	local colors = theme.Colors
	local item = selectedItem.Item
	local rarityColor = getRarityColor(theme, item)
	local compact = self.ShortLayout == true
	local rowHeight = compact and 50 or 68
	local iconWidth = compact and 48 or 64
	local iconHeight = compact and 42 or 58
	local iconX = compact and 8 or 12
	local contentX = compact and 64 or 92
	local textReserve = compact and 330 or 438
	local buttonSize = compact and 30 or 36
	local removeWidth = compact and 32 or 38
	local maxWidth = compact and 42 or 48
	local amountWidth = compact and 90 or 128

	local row = Instance.new("Frame")
	row.Name = "Selected_" .. selectedItem.Id
	row.BackgroundColor3 = colors.SurfaceAlt
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Size = UDim2.new(1, -8, 0, rowHeight)
	addCorner(row, 8)
	addStroke(row, colors.Border, 1)

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.BackgroundColor3 = rarityColor
	accent.BorderSizePixel = 0
	accent.Size = UDim2.fromOffset(compact and 4 or 5, rowHeight)
	accent.Parent = row
	addCorner(accent, 8)

	local imageFrame = Instance.new("Frame")
	imageFrame.Name = "ImageFrame"
	imageFrame.BackgroundColor3 = colors.SurfaceDeep
	imageFrame.BorderSizePixel = 0
	imageFrame.Size = UDim2.fromOffset(iconWidth, iconHeight)
	imageFrame.Position = UDim2.fromOffset(iconX, 4)
	imageFrame.Parent = row
	addCorner(imageFrame, 8)

	local image = Instance.new("ImageLabel")
	image.Name = "Image"
	image.BackgroundTransparency = 1
	image.Image = item.Image or ""
	image.ScaleType = Enum.ScaleType.Fit
	image.Size = UDim2.fromScale(0.86, 0.86)
	image.Position = UDim2.fromScale(0.07, 0.07)
	image.Parent = imageFrame
	if item.Image == nil or item.Image == "" or item.Image == "rbxassetid://0" then
		local fallback = Instance.new("TextLabel")
		fallback.Name = "FallbackIcon"
		fallback.BackgroundTransparency = 1
		fallback.Font = Enum.Font.GothamBlack
		fallback.Text = item.IconText or string.upper(string.sub(item.Name, 1, 3))
		fallback.TextColor3 = rarityColor
		fallback.TextSize = compact and 13 or 16
		fallback.Size = UDim2.fromScale(1, 1)
		fallback.Parent = imageFrame
	end

	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.Text = selectedItem.Name
	name.TextColor3 = colors.Text
	name.TextSize = compact and 11 or 13
	name.TextTruncate = Enum.TextTruncate.AtEnd
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Size = UDim2.new(1, -textReserve, 0, compact and 18 or 24)
	name.Position = UDim2.fromOffset(contentX, compact and 7 or 10)
	name.Parent = row

	local stock = Instance.new("TextLabel")
	stock.Name = "Stock"
	stock.BackgroundTransparency = 1
	stock.Font = Enum.Font.Gotham
	stock.Text = "Disponible x" .. tostring(item.Amount)
	stock.TextColor3 = colors.MutedText
	stock.TextSize = compact and 9 or 11
	stock.TextTruncate = Enum.TextTruncate.AtEnd
	stock.TextXAlignment = Enum.TextXAlignment.Left
	stock.Size = UDim2.new(1, -textReserve, 0, compact and 14 or 18)
	stock.Position = UDim2.fromOffset(contentX, compact and 27 or 34)
	stock.Parent = row

	local remove = makeButton(theme, "x", removeWidth, buttonSize)
	remove.Name = "Remove"
	remove.AnchorPoint = Vector2.new(1, 0.5)
	remove.BackgroundColor3 = Color3.fromRGB(72, 26, 31)
	remove.TextColor3 = colors.Danger
	remove.Position = UDim2.new(1, compact and -6 or -8, 0.5, 0)
	remove.Parent = row

	local plus = makeButton(theme, "+", buttonSize, buttonSize)
	plus.Name = "Plus"
	plus.AnchorPoint = Vector2.new(1, 0.5)
	plus.Position = UDim2.new(1, compact and -44 or -52, 0.5, 0)
	plus.Parent = row

	local amountBox = Instance.new("TextBox")
	amountBox.Name = "Amount"
	amountBox.AnchorPoint = Vector2.new(1, 0.5)
	amountBox.BackgroundColor3 = colors.SurfaceDeep
	amountBox.BorderSizePixel = 0
	amountBox.ClearTextOnFocus = false
	amountBox.Font = Enum.Font.GothamBold
	amountBox.Text = tostring(selectedItem.Amount)
	amountBox.TextColor3 = colors.Text
	amountBox.TextSize = compact and 14 or 17
	amountBox.Size = UDim2.fromOffset(amountWidth, buttonSize)
	amountBox.Position = UDim2.new(1, compact and -80 or -96, 0.5, 0)
	amountBox.Parent = row
	addCorner(amountBox, 8)
	addStroke(amountBox, colors.Border, 1)

	local minus = makeButton(theme, "-", buttonSize, buttonSize)
	minus.Name = "Minus"
	minus.AnchorPoint = Vector2.new(1, 0.5)
	minus.Position = UDim2.new(1, compact and -176 or -232, 0.5, 0)
	minus.Parent = row

	local max = makeButton(theme, "MAX", maxWidth, buttonSize)
	max.Name = "Max"
	max.AnchorPoint = Vector2.new(1, 0.5)
	max.TextSize = compact and 10 or 12
	max.Position = UDim2.new(1, compact and -212 or -276, 0.5, 0)
	max.Parent = row

	Animator.bindHoverPress(max, self.RowMaid, { HoverScale = 1.035, PressScale = 0.95, HoverColor = colors.SurfaceRaised })
	Animator.bindHoverPress(minus, self.RowMaid, { HoverScale = 1.035, PressScale = 0.95, HoverColor = colors.SurfaceRaised })
	Animator.bindHoverPress(plus, self.RowMaid, { HoverScale = 1.035, PressScale = 0.95, HoverColor = colors.SurfaceRaised })
	Animator.bindHoverPress(remove, self.RowMaid, { HoverScale = 1.035, PressScale = 0.95, HoverColor = Color3.fromRGB(95, 32, 38) })

	self.RowMaid:GiveTask(minus.Activated:Connect(function()
		if self.OnSetQuantity then
			self.OnSetQuantity(selectedItem.Id, selectedItem.Amount - 1)
		end
	end))

	self.RowMaid:GiveTask(plus.Activated:Connect(function()
		if self.OnSetQuantity then
			self.OnSetQuantity(selectedItem.Id, selectedItem.Amount + 1)
		end
	end))

	self.RowMaid:GiveTask(remove.Activated:Connect(function()
		if self.OnRemoveItem then
			self.OnRemoveItem(selectedItem.Id)
		end
	end))

	self.RowMaid:GiveTask(max.Activated:Connect(function()
		if self.OnSetQuantity then
			self.OnSetQuantity(selectedItem.Id, item.Amount)
		end
	end))

	local rowHoverColor = colors.SurfaceAlt:Lerp(colors.SurfaceRaised, 0.35)
	local rowScale = Animator.ensureScale(row)
	self.RowMaid:GiveTask(row.MouseEnter:Connect(function()
		TweenService:Create(rowScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.006 }):Play()
		TweenService:Create(row, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = rowHoverColor }):Play()
	end))

	self.RowMaid:GiveTask(row.MouseLeave:Connect(function()
		TweenService:Create(rowScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		TweenService:Create(row, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = colors.SurfaceAlt }):Play()
	end))

	self.RowMaid:GiveTask(amountBox.FocusLost:Connect(function()
		if self.OnSetQuantity then
			self.OnSetQuantity(selectedItem.Id, tonumber(amountBox.Text) or selectedItem.Amount)
		end
	end))

	if not compact then
		Animator.popIn(row, 0.99)
	end
	return row
end

function SelectedPanel:_createPreview(selectedItem, order)
	local theme = self.Theme
	local colors = theme.Colors
	local item = selectedItem.Item
	local rarityColor = getRarityColor(theme, item)
	local preview = Instance.new("Frame")
	preview.Name = "Preview_" .. selectedItem.Id
	preview.BackgroundColor3 = colors.SurfaceDeep
	preview.BorderSizePixel = 0
	preview.LayoutOrder = order
	preview.Size = UDim2.fromOffset(92, 92)
	addCorner(preview, 8)
	addStroke(preview, rarityColor, 1)

	local image = Instance.new("ImageLabel")
	image.Name = "Image"
	image.BackgroundTransparency = 1
	image.Image = item.Image or ""
	image.ScaleType = Enum.ScaleType.Fit
	image.Size = UDim2.fromScale(0.8, 0.72)
	image.Position = UDim2.fromScale(0.1, 0.08)
	image.Parent = preview
	if item.Image == nil or item.Image == "" or item.Image == "rbxassetid://0" then
		local fallback = Instance.new("TextLabel")
		fallback.Name = "FallbackIcon"
		fallback.BackgroundTransparency = 1
		fallback.Font = Enum.Font.GothamBlack
		fallback.Text = item.IconText or string.upper(string.sub(item.Name, 1, 3))
		fallback.TextColor3 = rarityColor
		fallback.TextSize = 17
		fallback.Size = UDim2.new(1, 0, 0, 62)
		fallback.Position = UDim2.fromOffset(0, 8)
		fallback.Parent = preview
	end

	local amount = Instance.new("TextLabel")
	amount.Name = "Amount"
	amount.AnchorPoint = Vector2.new(1, 1)
	amount.BackgroundTransparency = 1
	amount.Font = Enum.Font.GothamBold
	amount.Text = "x" .. tostring(selectedItem.Amount)
	amount.TextColor3 = colors.Text
	amount.TextSize = 14
	amount.TextXAlignment = Enum.TextXAlignment.Right
	amount.Size = UDim2.new(1, -10, 0, 20)
	amount.Position = UDim2.new(1, -8, 1, -6)
	amount.Parent = preview

	return preview
end

function SelectedPanel:PlayDelivered()
	if self.IsDelivering then
		return
	end

	self.IsDelivering = true
	self.Delivered = false
	self.Submit.Active = false
	self.Submit.AutoButtonColor = false

	for _, child in ipairs(self.Rows:GetChildren()) do
		if not child:IsA("UIListLayout") then
			TweenService:Create(child, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -8, 0, 0),
			}):Play()

			for _, descendant in ipairs(child:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
					TweenService:Create(descendant, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextTransparency = 1,
						BackgroundTransparency = 1,
					}):Play()
				elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
					TweenService:Create(descendant, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 1,
						BackgroundTransparency = 1,
					}):Play()
				elseif descendant:IsA("Frame") then
					TweenService:Create(descendant, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 1,
					}):Play()
				elseif descendant:IsA("UIStroke") then
					TweenService:Create(descendant, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = 1,
					}):Play()
				end
			end
		end
	end

	task.delay(0.2, function()
		if not self.Instance then
			return
		end

		for _, child in ipairs(self.Rows:GetChildren()) do
			if not child:IsA("UIListLayout") then
				child.Visible = false
			end
		end

		self.Delivered = true
		self.IsDelivering = false
		self.DeliveredMessage.Visible = true
		self.DeliveredMessage.TextTransparency = 1

		local deliveredScale = Animator.ensureScale(self.DeliveredMessage)
		deliveredScale.Scale = 0.92
		TweenService:Create(deliveredScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1,
		}):Play()
		TweenService:Create(self.DeliveredMessage, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0,
		}):Play()

		if self.OnDelivered then
			self.OnDelivered()
		end
	end)
end

function SelectedPanel:Render(selectedItems, totalAmount)
	if self.IsDelivering then
		return
	end

	self.RowMaid:DoCleaning()

	for _, child in ipairs(self.Rows:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	for _, child in ipairs(self.PreviewStrip:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	self.Count.Text = string.format("%d/%d", #selectedItems, self.MaxSelectedItems)
	self.TotalValue.Text = tostring(totalAmount)
	self.SlotsValue.Text = string.format("%d/%d", #selectedItems, self.MaxSelectedItems)
	local canSubmit = #selectedItems > 0
	self.Submit.AutoButtonColor = canSubmit
	self.Submit.Active = canSubmit
	self.Submit.BackgroundColor3 = canSubmit and self.Theme.Colors.AccentAlt or self.Theme.Colors.SurfaceRaised
	self.Submit.TextColor3 = canSubmit and Color3.fromRGB(255, 255, 255) or self.Theme.Colors.MutedText
	self.Submit.BackgroundTransparency = 0
	self.Submit.TextTransparency = 0

	if self.Delivered and #selectedItems == 0 then
		self.DeliveredMessage.Visible = true
		self.DeliveredMessage.TextTransparency = 0
		return
	end

	self.Delivered = false
	self.DeliveredMessage.Visible = false
	self.DeliveredMessage.TextTransparency = 1

	if #selectedItems == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "Empty"
		empty.BackgroundTransparency = 1
		empty.Font = Enum.Font.Gotham
		empty.Text = (self.Config.Texts and self.Config.Texts.EmptySelected) or "Selecciona armas para continuar"
		empty.TextColor3 = self.Theme.Colors.MutedText
		empty.TextSize = 14
		empty.Size = UDim2.new(1, -8, 0, 44)
		empty.Parent = self.Rows
		return
	end

	for index, selectedItem in ipairs(selectedItems) do
		local row = self:_createRow(selectedItem, index)
		row.Parent = self.Rows

		if index <= 5 then
			local preview = self:_createPreview(selectedItem, index)
			preview.Parent = self.PreviewStrip
		end
	end
end

function SelectedPanel:Destroy()
	self.RowMaid:Destroy()
	self.Maid:Destroy()

	if self.Instance then
		self.Instance:Destroy()
		self.Instance = nil
	end
end

return SelectedPanel
































