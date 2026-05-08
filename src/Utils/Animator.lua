local Tween = require(script.Parent.Tween)

local Animator = {}

local FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local SOFT = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local EXIT = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function ensureScale(instance)
	local scale = instance:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = instance
	end

	return scale
end

function Animator.ensureScale(instance)
	return ensureScale(instance)
end

function Animator.popIn(instance, fromScale)
	local scale = ensureScale(instance)
	scale.Scale = fromScale or 0.97
	Tween.to(scale, SOFT, { Scale = 1 })
end

function Animator.popOut(instance, toScale)
	local scale = ensureScale(instance)
	return Tween.to(scale, EXIT, { Scale = toScale or 0.97 })
end

function Animator.fade(instance, transparency, tweenInfo)
	return Tween.to(instance, tweenInfo or SOFT, { BackgroundTransparency = transparency })
end

function Animator.bindHoverPress(button, maid, options)
	options = options or {}

	local scale = ensureScale(button)
	local normalScale = options.NormalScale or 1
	local hoverScale = options.HoverScale or 1.025
	local pressScale = options.PressScale or 0.975
	local normalColor = options.NormalColor or button.BackgroundColor3
	local hoverColor = options.HoverColor

	button.AutoButtonColor = false

	maid:GiveTask(button.MouseEnter:Connect(function()
		if button.Active == false then
			return
		end

		Tween.to(scale, FAST, { Scale = hoverScale })
		if hoverColor then
			Tween.to(button, FAST, { BackgroundColor3 = hoverColor })
		end
	end))

	maid:GiveTask(button.MouseLeave:Connect(function()
		Tween.to(scale, FAST, { Scale = normalScale })
		if hoverColor then
			Tween.to(button, FAST, { BackgroundColor3 = normalColor })
		end
	end))

	maid:GiveTask(button.MouseButton1Down:Connect(function()
		if button.Active == false then
			return
		end

		Tween.to(scale, FAST, { Scale = pressScale })
	end))

	maid:GiveTask(button.MouseButton1Up:Connect(function()
		if button.Active == false then
			return
		end

		Tween.to(scale, FAST, { Scale = hoverScale })
	end))
end

return Animator


