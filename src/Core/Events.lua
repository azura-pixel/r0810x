local Signal = require(script.Parent.Parent.Utils.Signal)

local Events = {}
Events.__index = Events

function Events.new(names)
	local self = setmetatable({
		_signals = {},
	}, Events)

	for _, name in ipairs(names or {}) do
		self._signals[name] = Signal.new()
	end

	return self
end

function Events:Get(name)
	if not self._signals[name] then
		self._signals[name] = Signal.new()
	end

	return self._signals[name]
end

function Events:On(name, callback)
	return self:Get(name):Connect(callback)
end

function Events:Fire(name, ...)
	local signal = self._signals[name]
	if signal then
		signal:Fire(...)
	end
end

function Events:Destroy()
	for _, signal in pairs(self._signals) do
		signal:Destroy()
	end

	table.clear(self._signals)
end

return Events
