Async = {
	TaskID = 0,
	Tasks = {}
}

Async.Parallel = function(tasks, cb)
	if (type(tasks) ~= 'table' or #tasks == 0) then
		if(cb ~= nil) then cb({}) end
		return
	end

	if (Async.TaskID < 65535) then
		Async.TaskID = Async.TaskID + 1
	else
		Async.TaskID = 1
	end

	local currentTaskId = Async.TaskID

	Async.Tasks[currentTaskId] = {
		remaining = #tasks,
		results = {}
	}

	for _, task in ipairs(tasks) do
		Citizen.CreateThread(function()
			local taskId = currentTaskId

			task(function(result)
				Async.Tasks[taskId].remaining = Async.Tasks[taskId].remaining - 1

				table.insert(Async.Tasks[taskId].results, result)
			end)
		end)
	end

	Citizen.CreateThread(function()
		local taskId = currentTaskId
		local callback = cb

		while true do
			if (Async.Tasks[taskId].remaining <= 0) then
                callback(Async.Tasks[taskId].results)
                Async.Tasks[taskId] = nil
				return
			end

			Citizen.Wait(0)
		end
	end)
end

Async.ParallelLimit = function(tasks, limit, cb)
	if (type(tasks) ~= 'table' or #tasks == 0) then
		if(cb ~= nil) then cb({}) end
		return
	end

	if (Async.TaskID < 65535) then
		Async.TaskID = Async.TaskID + 1
	else
		Async.TaskID = 1
	end

	local currentTaskId = Async.TaskID

	Async.Tasks[currentTaskId] = {
        remaining = #tasks,
        running = 0,
        results = {},
        queue = tasks,
        limit = limit
	}

    Citizen.CreateThread(function()
        local taskId = currentTaskId
        local callback = cb

        for _, task in ipairs(Async.Tasks[taskId].queue) do
            while Async.Tasks[taskId].running >= Async.Tasks[taskId].limit do
                Citizen.Wait(0)
            end

            Citizen.CreateThread(function()
                Async.Tasks[taskId].running = Async.Tasks[taskId].running + 1

                task(function(result)
                    Async.Tasks[taskId].remaining = Async.Tasks[taskId].remaining - 1
                    Async.Tasks[taskId].running = Async.Tasks[taskId].running - 1

                    table.insert(Async.Tasks[taskId].results, result)
                end)
            end)
        end

        while true do
			if (Async.Tasks[taskId].remaining <= 0) then
                callback(Async.Tasks[taskId].results)
                Async.Tasks[taskId] = nil
				return
			end

			Citizen.Wait(0)
		end
    end)
end

Async.Series = function(tasks, cb)
	Async.parallelLimit(tasks, 1, cb)
end

Async.ParamParallel = function(func, params, cb)
	if (type(params) ~= 'table' or #params == 0) then
		if(cb ~= nil) then cb({}) end
		return
	end

	if (Async.TaskID < 65535) then
		Async.TaskID = Async.TaskID + 1
	else
		Async.TaskID = 1
	end

	local currentTaskId = Async.TaskID

	Async.Tasks[currentTaskId] = {
		remaining = #params,
		results = {}
	}

	for _, param in ipairs(params) do
		Citizen.CreateThread(function()
			local taskId = currentTaskId

			func(param, function(result)
				Async.Tasks[taskId].remaining = Async.Tasks[taskId].remaining - 1

				table.insert(Async.Tasks[taskId].results, result)
			end)
		end)
	end

	Citizen.CreateThread(function()
		local taskId = currentTaskId
		local callback = cb

		while true do
			if (Async.Tasks[taskId].remaining <= 0) then
                callback(Async.Tasks[taskId].results)
                Async.Tasks[taskId] = nil
				return
			end

			Citizen.Wait(0)
		end
	end)
end

Async.ParamParallelLimit = function(func, params, limit, cb)
	if (type(params) ~= 'table' or #params == 0) then
		if(cb ~= nil) then cb({}) end
		return
	end

	if (Async.TaskID < 65535) then
		Async.TaskID = Async.TaskID + 1
	else
		Async.TaskID = 1
	end

	local currentTaskId = Async.TaskID

	Async.Tasks[currentTaskId] = {
        remaining = #params,
        running = 0,
        results = {},
        queue = params,
        limit = limit
	}

    Citizen.CreateThread(function()
        local taskId = currentTaskId
        local callback = cb

        for _, param in ipairs(Async.Tasks[taskId].queue) do
            while Async.Tasks[taskId].running >= Async.Tasks[taskId].limit do
                Citizen.Wait(0)
            end

            Citizen.CreateThread(function()
                Async.Tasks[taskId].running = Async.Tasks[taskId].running + 1

                func(param, function(result)
                    Async.Tasks[taskId].remaining = Async.Tasks[taskId].remaining - 1
                    Async.Tasks[taskId].running = Async.Tasks[taskId].running - 1

                    table.insert(Async.Tasks[taskId].results, result)
                end)
            end)
        end

        while true do
			if (Async.Tasks[taskId].remaining <= 0) then
                callback(Async.Tasks[taskId].results)
                Async.Tasks[taskId] = nil
				return
			end

			Citizen.Wait(0)
		end
    end)
end

Async.ParamSeries = function(func, params, cb)
    Async.ParamParallelLimit(func, params, 1, cb)
end

Async.CreatePool = function()
    local self = {}

    self.tasks = {}

    self.add = function(func)
        table.insert(self.tasks, func)
    end

    self.getTasks = function()
        return self.tasks or {}
    end

    self.startParallelAsync = function(cb)
        if (type(self.tasks) == 'table' and #self.tasks > 0) then
            Async.parallel(self.tasks, cb)
        else
            cb({})
        end
    end

    self.startParallel = function()
        if (type(self.tasks) == 'table' and #self.tasks > 0) then
            local done = false
            local results = {}

            Async.parallel(self.tasks, function(_results)
                results = _results
                done = true
            end)

            while done == false do
                Citizen.Wait(0)
            end

            return results
        else
            return {}
        end
    end

    self.startParallelLimitAsync = function(limit, cb)
        if (type(self.tasks) == 'table' and #self.tasks > 0) then
            Async.parallelLimit(self.tasks, limit, cb)
        else
            cb({})
        end
    end

    self.startParallelLimit = function(limit)
        if (type(self.tasks) == 'table' and #self.tasks > 0) then
            local done = false
            local results = {}

            Async.parallelLimit(self.tasks, limit, function(_results)
                results = _results
                done = true
            end)

            while done == false do
                Citizen.Wait(0)
            end

            return results
        else
            return {}
        end
    end

    self.startSeriesAsync = function(cb)
        self.startParallelLimitAsync(1, cb)
    end

    self.startSeries = function()
        return self.startParallelLimit(1)
    end

    return self
end

Async.parallel = Async.Parallel
Async.parallelLimit = Async.ParallelLimit
Async.series = Async.Series
Async.createPool = Async.CreatePool