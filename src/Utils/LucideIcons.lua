local LucideIcons = {}

-- Upload the Lucide SVG/PNG files you need to Roblox, then paste the asset ids here.
-- Icon names match lucide.dev names so the template stays easy to maintain.
LucideIcons.Assets = {
	ArrowRightLeft = "",
	ArrowLeft = "",
	Briefcase = "",
	ChevronDown = "",
	Check = "",
	Grid3X3 = "",
	HandCoins = "",
	List = "",
	Minus = "",
	Package = "",
	Plus = "",
	Search = "",
	X = "",
}

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
	stroke.Thickness = thickness or 2
	stroke.Parent = instance
	return stroke
end

local function makeRoot(name, props)
	local root = Instance.new("Frame")
	root.Name = props.Name or (name .. "Icon")
	root.BackgroundTransparency = 1
	root.Size = props.Size or UDim2.fromOffset(24, 24)
	root.Position = props.Position or UDim2.fromOffset(0, 0)
	root.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	root.ZIndex = props.ZIndex or 1
	return root
end

local function line(parent, color, size, position, rotation)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = color
	frame.BorderSizePixel = 0
	frame.Size = size
	frame.Position = position
	frame.Rotation = rotation or 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Parent = parent
	addCorner(frame, 99)
	return frame
end

local function drawSearch(root, color)
	local circle = Instance.new("Frame")
	circle.BackgroundTransparency = 1
	circle.Size = UDim2.fromScale(0.48, 0.48)
	circle.Position = UDim2.fromScale(0.18, 0.16)
	circle.Parent = root
	addCorner(circle, 99)
	addStroke(circle, color, 2)
	line(root, color, UDim2.fromScale(0.36, 0.1), UDim2.fromScale(0.68, 0.68), 45)
end

local function drawGrid(root, color)
	for row = 0, 2 do
		for column = 0, 2 do
			local dot = Instance.new("Frame")
			dot.BackgroundColor3 = color
			dot.BorderSizePixel = 0
			dot.Size = UDim2.fromScale(0.18, 0.18)
			dot.Position = UDim2.fromScale(0.2 + column * 0.28, 0.2 + row * 0.28)
			dot.Parent = root
			addCorner(dot, 3)
		end
	end
end

local function drawList(root, color)
	for index = 0, 2 do
		line(root, color, UDim2.fromScale(0.56, 0.1), UDim2.fromScale(0.58, 0.28 + index * 0.24), 0)
		local dot = Instance.new("Frame")
		dot.BackgroundColor3 = color
		dot.BorderSizePixel = 0
		dot.Size = UDim2.fromScale(0.12, 0.12)
		dot.Position = UDim2.fromScale(0.18, 0.22 + index * 0.24)
		dot.Parent = root
		addCorner(dot, 99)
	end
end

local function drawChevronDown(root, color)
	line(root, color, UDim2.fromScale(0.34, 0.1), UDim2.fromScale(0.39, 0.46), 45)
	line(root, color, UDim2.fromScale(0.34, 0.1), UDim2.fromScale(0.61, 0.46), -45)
end
local function drawCheck(root, color)
	line(root, color, UDim2.fromScale(0.28, 0.1), UDim2.fromScale(0.38, 0.58), 45)
	line(root, color, UDim2.fromScale(0.5, 0.1), UDim2.fromScale(0.58, 0.46), -45)
end

local function drawPlus(root, color)
	line(root, color, UDim2.fromScale(0.52, 0.12), UDim2.fromScale(0.5, 0.5), 0)
	line(root, color, UDim2.fromScale(0.52, 0.12), UDim2.fromScale(0.5, 0.5), 90)
end

local function drawMinus(root, color)
	line(root, color, UDim2.fromScale(0.52, 0.12), UDim2.fromScale(0.5, 0.5), 0)
end

local function drawX(root, color)
	line(root, color, UDim2.fromScale(0.58, 0.12), UDim2.fromScale(0.5, 0.5), 45)
	line(root, color, UDim2.fromScale(0.58, 0.12), UDim2.fromScale(0.5, 0.5), -45)
end

local function drawArrowLeft(root, color)
	line(root, color, UDim2.fromScale(0.56, 0.1), UDim2.fromScale(0.55, 0.5), 0)
	line(root, color, UDim2.fromScale(0.32, 0.1), UDim2.fromScale(0.34, 0.4), -45)
	line(root, color, UDim2.fromScale(0.32, 0.1), UDim2.fromScale(0.34, 0.6), 45)
end

local function drawArrowRightLeft(root, color)
	line(root, color, UDim2.fromScale(0.52, 0.09), UDim2.fromScale(0.48, 0.34), 0)
	line(root, color, UDim2.fromScale(0.22, 0.09), UDim2.fromScale(0.7, 0.27), 45)
	line(root, color, UDim2.fromScale(0.22, 0.09), UDim2.fromScale(0.7, 0.41), -45)
	line(root, color, UDim2.fromScale(0.52, 0.09), UDim2.fromScale(0.52, 0.66), 0)
	line(root, color, UDim2.fromScale(0.22, 0.09), UDim2.fromScale(0.3, 0.59), -45)
	line(root, color, UDim2.fromScale(0.22, 0.09), UDim2.fromScale(0.3, 0.73), 45)
end

local function drawBriefcase(root, color)
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Size = UDim2.fromScale(0.72, 0.5)
	box.Position = UDim2.fromScale(0.14, 0.34)
	box.Parent = root
	addCorner(box, 4)
	addStroke(box, color, 2)
	line(root, color, UDim2.fromScale(0.28, 0.09), UDim2.fromScale(0.5, 0.28), 0)
end

local function drawHandCoins(root, color)
	drawBriefcase(root, color)
	local coin = Instance.new("Frame")
	coin.BackgroundTransparency = 1
	coin.Size = UDim2.fromScale(0.26, 0.26)
	coin.Position = UDim2.fromScale(0.52, 0.1)
	coin.Parent = root
	addCorner(coin, 99)
	addStroke(coin, color, 2)
end

local Drawers = {
	ArrowLeft = drawArrowLeft,
	ArrowRightLeft = drawArrowRightLeft,
	Briefcase = drawBriefcase,
	ChevronDown = drawChevronDown,
	Check = drawCheck,
	Grid3X3 = drawGrid,
	HandCoins = drawHandCoins,
	List = drawList,
	Minus = drawMinus,
	Package = drawBriefcase,
	Plus = drawPlus,
	Search = drawSearch,
	X = drawX,
}

function LucideIcons.getAsset(name)
	local asset = LucideIcons.Assets[name]
	if asset and asset ~= "" then
		return asset
	end

	return nil
end

function LucideIcons.new(name, props)
	props = props or {}

	local asset = LucideIcons.getAsset(name)
	if asset then
		local image = Instance.new("ImageLabel")
		image.Name = props.Name or (name .. "Icon")
		image.BackgroundTransparency = 1
		image.Image = asset
		image.ImageColor3 = props.Color or Color3.new(1, 1, 1)
		image.ImageTransparency = props.Transparency or 0
		image.ScaleType = Enum.ScaleType.Fit
		image.Size = props.Size or UDim2.fromOffset(24, 24)
		image.Position = props.Position or UDim2.fromOffset(0, 0)
		image.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
		image.ZIndex = props.ZIndex or 1
		return image
	end

	local root = makeRoot(name, props)
	local drawer = Drawers[name]
	if drawer then
		drawer(root, props.Color or Color3.new(1, 1, 1))
	end

	return root
end

return LucideIcons

