local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_bindings = {},
		_destroyed = false,
	}, Signal)
end

function Signal:Connect(callback)
	assert(type(callback) == "function", "Signal:Connect expects a function")
	assert(not self._destroyed, "Cannot connect to a destroyed signal")

	local connection = {
		Connected = true,
	}

	function connection:Disconnect()
		if not self.Connected then
			return
		end

		self.Connected = false
	end

	table.insert(self._bindings, {
		Callback = callback,
		Connection = connection,
	})

	return connection
end

function Signal:Once(callback)
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)

	return connection
end

function Signal:Fire(...)
	if self._destroyed then
		return
	end

	local bindings = table.clone(self._bindings)
	for _, binding in ipairs(bindings) do
		if binding.Connection.Connected then
			binding.Callback(...)
		end
	end

	for index = #self._bindings, 1, -1 do
		if not self._bindings[index].Connection.Connected then
			table.remove(self._bindings, index)
		end
	end
end

function Signal:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	for _, binding in ipairs(self._bindings) do
		binding.Connection.Connected = false
	end
	table.clear(self._bindings)
end

return Signal
