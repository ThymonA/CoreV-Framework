----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.arens.io/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: Thymon Arens <contact@arens.io>
-- Name: CoreV
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ CoreV ] -----------------------
async = class('async')

--- Set default values
async:set {
    createThread = Citizen.CreateThread
}

--- Run a function parallel from each other
--- @param func function Executable function
--- @param params table Parameters
--- @param cb function Callback function
function async:parallel(func, params, cb)
    if (#params == 0 and params == {}) then
        if (cb ~= nil) then cb({}) end
        return
    end

    local remaining, results = #params, {}

    if (remaining == 0) then
        for _, __ in pairs(params or {}) do
            remaining = remaining + 1
        end
    end

    if (remaining == 0) then
        if (cb ~= nil) then cb(results) end
    else
        for _, param in pairs(params or {}) do
            self.createThread(function()
                func(param, function(result)
                    table.insert(results, result)

                    remaining = remaining - 1;

                    if (remaining == 0) then
                        if (cb ~= nil) then cb(results) end
                    end
                end, _)
            end)
        end
    end
end

--- Run a function parallel from each other with max number of threads
--- @param func function Executable function
--- @param params table Parameters
--- @param limit number Limiter max number of executing threads
--- @param cb function Callback function
function async:parallelLimit(func, params, limit, cb)
    if (#params == 0) then
        if (cb ~= nil) then cb({}) end
        return
    end

    local remaining, running, results = #params, 0, {}

    local function processQueue()
        if (remaining <= 0) then
            return
        end

        while running < limit and remaining > 0 do
            local paramIndex = (#params - remaining) + 1

            running = running + 1

            func(params[paramIndex], function(result)
                table.insert(results, result)

                remaining = remaining - 1
                running = running - 1

                if (remaining == 0) then
                    if (cb ~= nil) then cb(results) end
                end
            end)
        end

        self.createThread(processQueue)
    end

    self.createThread(processQueue)
end

--- Run a function after each other in a series
--- @param func function Executable function
--- @param params table Parameters
--- @param cb function Callback function
function async:series(func, params, cb)
    self:parallelLimit(func, params, 1, cb)
end

--- Add async as module when available
Citizen.CreateThread(function()
    while true do
        if (addModule ~= nil and type(addModule) == 'function') then
            addModule('async', async)
            return
        end

        Citizen.Wait(0)
    end
end)