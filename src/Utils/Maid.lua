local Maid = {}
Maid.__index = Maid

local function cleanupTask(task)
	local taskType = typeof(task)

	if taskType == "RBXScriptConnection" then
		if task.Connected then
			task:Disconnect()
		end
	elseif taskType == "Instance" then
		task:Destroy()
	elseif type(task) == "function" then
		task()
	elseif type(task) == "table" then
		if type(task.Destroy) == "function" then
			task:Destroy()
		elseif type(task.Disconnect) == "function" then
			task:Disconnect()
		end
	end
end

function Maid.new()
	return setmetatable({
		_tasks = {},
	}, Maid)
end

function Maid:GiveTask(task)
	if task == nil then
		return nil
	end

	table.insert(self._tasks, task)
	return task
end

function Maid:DoCleaning()
	for index = #self._tasks, 1, -1 do
		local task = self._tasks[index]
		self._tasks[index] = nil
		cleanupTask(task)
	end
end

function Maid:Destroy()
	self:DoCleaning()
end

return Maid
