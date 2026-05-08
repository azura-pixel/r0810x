local Players = game:GetService("Players")

local Maid = require(script.Parent.Parent.Utils.Maid)
local Animator = require(script.Parent.Parent.Utils.Animator)
local Tween = require(script.Parent.Parent.Utils.Tween)
local LucideIcons = require(script.Parent.Parent.Utils.LucideIcons)
local InventoryGrid = require(script.Parent.InventoryGrid)
local SelectedPanel = require(script.Parent.SelectedPanel)

local Window = {}
Window.__index = Window

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

local function resolveParent(config)
	if config.Parent then
		return config.Parent
	end

	local player = Players.LocalPlayer
	if player then
		return player:WaitForChild("PlayerGui")
	end

	return nil
end

function Window.new(props)
	local self = setmetatable({
		Config = props.Config,
		State = props.State,
		Theme = props.Theme,
		OnAddItem = props.OnAddItem,
		OnSetQuantity = props.OnSetQuantity,
		OnRemoveItem = props.OnRemoveItem,
		OnSubmit = props.OnSubmit,
		OnOpen = props.OnOpen,
		OnClose = props.OnClose,
		OnDelivered = props.OnDelivered,
		Step = 1,
		AnimationToken = 0,
		Maid = Maid.new(),
	}, Window)

	self:_create()
	self:_connect()
	self:Render()

	return self
end

function Window:_create()
	local config = self.Config
	local theme = self.Theme
	local colors = theme.Colors
	local parent = resolveParent(config)

	assert(parent, "TradeKit needs Config.Parent or a LocalPlayer PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = config.Name
	screenGui.DisplayOrder = config.DisplayOrder
	screenGui.Enabled = true
	screenGui.IgnoreGuiInset = false
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parent
	self.ScreenGui = screenGui
	self.Maid:GiveTask(screenGui)

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.BackgroundColor3 = colors.Backdrop
	backdrop.BackgroundTransparency = 1
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Visible = false
	backdrop.Parent = screenGui
	self.Backdrop = backdrop

	local launcher = Instance.new("TextButton")
	launcher.Name = "OpenTradeKit"
	launcher.AnchorPoint = Vector2.new(1, 1)
	launcher.AutoButtonColor = false
	launcher.BackgroundColor3 = colors.AccentAlt
	launcher.BorderSizePixel = 0
	launcher.Font = Enum.Font.GothamBold
	launcher.Text = (config.Texts and config.Texts.Open) or "Abrir"
	launcher.TextColor3 = colors.Text
	launcher.TextSize = 14
	launcher.Size = UDim2.fromOffset(112, 42)
	launcher.Position = UDim2.new(1, -24, 1, -24)
	launcher.Visible = config.ShowLauncher ~= false
	launcher.Parent = screenGui
	addCorner(launcher, theme.Radius.Button)
	addStroke(launcher, colors.BorderBright, 1)
	Animator.bindHoverPress(launcher, self.Maid, { HoverScale = 1.025, PressScale = 0.97 })
	self.LauncherButton = launcher

	local launcherIcon = LucideIcons.new("ArrowRightLeft", {
		Color = colors.Text,
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(14, 13),
		TextSize = 16,
	})
	launcherIcon.Parent = launcher
	launcher.Text = "     " .. launcher.Text

	self.Maid:GiveTask(launcher.Activated:Connect(function()
		self:Open()
	end))

	local root = Instance.new("Frame")
	root.Name = "Window"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.BackgroundColor3 = colors.Background
	root.BackgroundTransparency = 0.04
	root.BorderSizePixel = 0
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(800, 640)
	root.Parent = backdrop
	addCorner(root, theme.Radius.Window)
	addStroke(root, colors.BorderBright, 1)
	self.Root = root

	local rootScale = Instance.new("UIScale")
	rootScale.Scale = 1
	rootScale.Parent = root
	self.RootScale = rootScale

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 16)
	padding.PaddingBottom = UDim.new(0, 16)
	padding.PaddingLeft = UDim.new(0, 18)
	padding.PaddingRight = UDim.new(0, 18)
	padding.Parent = root
	self.RootPadding = padding

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.Size = UDim2.fromScale(1, 1)
	body.Parent = root
	self.Body = body

	local hideButton = Instance.new("TextButton")
	hideButton.Name = "Hide"
	hideButton.AnchorPoint = Vector2.new(1, 0)
	hideButton.AutoButtonColor = false
	hideButton.BackgroundColor3 = colors.SurfaceAlt
	hideButton.BorderSizePixel = 0
	hideButton.Text = ""
	hideButton.Size = UDim2.fromOffset(36, 36)
	hideButton.Position = UDim2.new(1, -10, 0, 10)
	hideButton.ZIndex = 25
	hideButton.Visible = false
	hideButton.Parent = root
	addCorner(hideButton, theme.Radius.Button)
	addStroke(hideButton, colors.Border, 1)
	Animator.bindHoverPress(hideButton, self.Maid, { HoverScale = 1.06, PressScale = 0.94, HoverColor = colors.SurfaceRaised })
	self.HideButton = hideButton

	local hideIcon = LucideIcons.new("X", {
		Color = colors.MutedText,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		TextSize = 14,
		ZIndex = 26,
	})
	hideIcon.Parent = hideButton

	self.Maid:GiveTask(hideButton.Activated:Connect(function()
		self:Close()
	end))

	self.InventoryGrid = InventoryGrid.new({
		Config = self.Config,
		Theme = theme,
		OnSearchQuery = function(query)
			self.State:SetSearchQuery(query)
		end,
		OnCategoryClick = function(category)
			self.State:SetActiveCategory(category)
		end,
		OnRaritySelected = function(rarity)
			self.State:SetActiveRarity(rarity)
		end,
		OnReset = function()
			self.State:ClearSelection()
		end,
		OnNext = function()
			if self.State:GetSelectedTypeCount() > 0 then
				self:_setStep(2)
			end
		end,
		OnClose = function()
			self:Close()
		end,
		OnItemClick = function(item)
			self.State:ToggleItem(item.Id)
		end,
	})
	self.InventoryGrid.Instance.Size = UDim2.fromScale(1, 1)
	self.InventoryGrid.Instance.Parent = body

	self.SelectedPanel = SelectedPanel.new({
		Config = self.Config,
		Theme = theme,
		SubmitText = self.Config.SubmitText,
		MaxSelectedItems = self.Config.MaxSelectedItems,
		OnSetQuantity = self.OnSetQuantity,
		OnRemoveItem = self.OnRemoveItem,
		OnSubmit = self.OnSubmit,
		OnBack = function()
			self:_setStep(1)
		end,
		OnDelivered = function()
			local deliveredItems = self.State:GetSelectedItems()
			self.State:ClearSelection()
			if self.OnDelivered then
				self.OnDelivered(deliveredItems)
			end
		end,
	})
	self.SelectedPanel.Instance.Size = UDim2.fromScale(1, 1)
	self.SelectedPanel.Instance.Parent = body

	self:_setStep(1)
	self:_updateLayout()
end

function Window:_connect()
	self.Maid:GiveTask(self.State.Changed:Connect(function()
		self:Render()
	end))

	local camera = workspace.CurrentCamera
	if camera then
		self.Maid:GiveTask(camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			self:_updateLayout()
		end))
	end
end

function Window:_setStep(step)
	local previousStep = self.Step
	self.Step = step

	if self.InventoryGrid and self.InventoryGrid.Instance then
		self.InventoryGrid.Instance.Visible = step == 1
		if step == 1 and previousStep ~= step then
			Animator.popIn(self.InventoryGrid.Instance, 0.985)
		end
	end

	if self.SelectedPanel and self.SelectedPanel.Instance then
		self.SelectedPanel.Instance.Visible = step == 2
		if step == 2 and previousStep ~= step then
			Animator.popIn(self.SelectedPanel.Instance, 0.985)
		end
	end

	if self.Body then
		self.Body.Size = UDim2.fromScale(1, 1)
	end

	self:_updateLayout()
	self:Render()
end

function Window:_updateLayout()
	local camera = workspace.CurrentCamera
	local viewportSize = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local windowConfig = self.Config.Window
	local isShort = viewportSize.Y < 460
	local isNarrow = viewportSize.X < 700
	local mobile = isShort or isNarrow
	local paddingX = mobile and 16 or windowConfig.PaddingX
	local paddingY = mobile and 12 or windowConfig.PaddingY
	local width = math.min(windowConfig.MaxWidth, viewportSize.X - paddingX)
	local height = math.min(windowConfig.MaxHeight, viewportSize.Y - paddingY)

	if mobile then
		width = math.max(300, width)
		height = math.max(240, height)
	else
		width = math.max(windowConfig.MinWidth, width)
		height = math.max(windowConfig.MinHeight, height)
	end

	self.Root.Size = UDim2.fromOffset(width, height)

	if self.RootPadding then
		local verticalInset = mobile and 10 or 16
		self.RootPadding.PaddingTop = UDim.new(0, verticalInset)
		self.RootPadding.PaddingBottom = UDim.new(0, verticalInset)
		self.RootPadding.PaddingLeft = UDim.new(0, mobile and 12 or 18)
		self.RootPadding.PaddingRight = UDim.new(0, mobile and 12 or 18)
	end

	if self.HideButton then
		self.HideButton.Size = UDim2.fromOffset(mobile and 28 or 36, mobile and 28 or 36)
		self.HideButton.Position = UDim2.new(1, mobile and -8 or -10, 0, mobile and 8 or 10)
	end

	if self.InventoryGrid then
		self.InventoryGrid:UpdateLayout(Vector2.new(width, height))
	end

	if self.SelectedPanel then
		self.SelectedPanel:UpdateLayout(Vector2.new(width, height))
	end
end

function Window:Render()
	local categories = self.State.Categories
	local selectedTypes = self.State:GetSelectedTypeCount()
	local selectedTotal = self.State:GetSelectedAmountTotal()

	if #categories == 0 then
		categories = { "Todas" }
	end

	self.InventoryGrid:Render(self.State:GetFilteredInventory(), self.State.Selected, {
		Categories = categories,
		SelectedTypes = selectedTypes,
		TotalAmount = selectedTotal,
		MaxSelectedItems = self.Config.MaxSelectedItems,
		SearchQuery = self.State.SearchQuery,
		ActiveCategory = self.State.ActiveCategory,
		ActiveRarity = self.State.ActiveRarity,
		Rarities = self.State:GetRarities(),
	})
	self.SelectedPanel:Render(self.State:GetSelectedItems(), selectedTotal)



end

function Window:Open()
	if self.Backdrop and self.Backdrop.Visible then
		return
	end

	self.AnimationToken += 1
	self.ScreenGui.Enabled = true
	self:_updateLayout()

	if self.LauncherButton then
		self.LauncherButton.Visible = false
	end

	if self.HideButton then
		self.HideButton.Visible = false
	end

	if self.Backdrop then
		self.Backdrop.Visible = true
		self.Backdrop.BackgroundTransparency = 1
		Tween.to(self.Backdrop, { Time = 0.18, EasingStyle = Enum.EasingStyle.Quart }, {
			BackgroundTransparency = 1,
		})
	end

	if self.RootScale then
		self.RootScale.Scale = 0.965
		Tween.to(self.RootScale, { Time = 0.2, EasingStyle = Enum.EasingStyle.Quart }, { Scale = 1 })
	end

	if self.Root then
		self.Root.BackgroundTransparency = 0.12
		Tween.to(self.Root, { Time = 0.16, EasingStyle = Enum.EasingStyle.Quad }, { BackgroundTransparency = 0.04 })
	end

	if self.OnOpen then
		self.OnOpen()
	end
end

function Window:Close()
	if not self.Backdrop or not self.Backdrop.Visible then
		return
	end

	self.AnimationToken += 1
	local token = self.AnimationToken

	if self.HideButton then
		self.HideButton.Visible = false
	end

	Tween.to(self.Backdrop, { Time = 0.14, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.In }, {
		BackgroundTransparency = 1,
	})

	if self.RootScale then
		Tween.to(self.RootScale, { Time = 0.14, EasingStyle = Enum.EasingStyle.Quad, EasingDirection = Enum.EasingDirection.In }, { Scale = 0.965 })
	end

	task.delay(0.15, function()
		if self.AnimationToken ~= token or not self.ScreenGui then
			return
		end

		self.Backdrop.Visible = false
		self.Backdrop.BackgroundTransparency = 1

		if self.RootScale then
			self.RootScale.Scale = 1
		end

		if self.LauncherButton and self.Config.ShowLauncher ~= false then
			self.LauncherButton.Visible = true
			Animator.popIn(self.LauncherButton, 0.94)
		end
	end)

	if self.OnClose then
		self.OnClose()
	end
end

function Window:Destroy()
	if self.InventoryGrid then
		self.InventoryGrid:Destroy()
		self.InventoryGrid = nil
	end

	if self.SelectedPanel then
		self.SelectedPanel:Destroy()
		self.SelectedPanel = nil
	end

	self.Maid:Destroy()
end

return Window




















