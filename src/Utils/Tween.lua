local TweenService = game:GetService("TweenService")

local Tween = {}

function Tween.to(instance, tweenInfo, properties)
	local info = tweenInfo

	if type(tweenInfo) == "table" then
		info = TweenInfo.new(
			tweenInfo.Time or 0.18,
			tweenInfo.EasingStyle or Enum.EasingStyle.Quad,
			tweenInfo.EasingDirection or Enum.EasingDirection.Out,
			tweenInfo.RepeatCount or 0,
			tweenInfo.Reverses or false,
			tweenInfo.DelayTime or 0
		)
	elseif typeof(tweenInfo) ~= "TweenInfo" then
		info = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end

	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

return Tween
