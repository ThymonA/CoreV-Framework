----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
-- Name: CoreV
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ CoreV ] -----------------------
local callbacks = class('callbacks')

--- Set default value
callbacks:set {
    callbacks = {}
}

--- Register server callback
--- @name string Event name
--- @cb function callback function
function callbacks:registerCallback(name, cb)
    self.callbacks[name] = cb
end

--- Trigger server callback by name
--- @name string Event name
--- @source int PlayerID
--- @cb function callback function
function callbacks:triggerCallback(name, source, cb, ...)
    if (self.callbacks ~= nil and self.callbacks[name] ~= nil) then
        self.callbacks[name](source, cb, ...)
    end
end

--- When client trigger this event
onClientTrigger('corev:triggerServerCallback', function(name, requestId, ...)
    local source = source or -1

    Citizen.CreateThread(function()
        if (type(source) == 'string') then source = tostring(source) end
        if (type(source) ~= 'number') then source = -1 end

        callbacks:triggerCallback(name, source, function(...)
            TCE('corev:triggerCallback', source, requestId, ...)
        end)
    end)
end)

--- FiveM manipulation
_ENV.registerCallback = function(name, cb) callbacks:registerCallback(name, cb) end
_G.registerCallback = function(name, cb) callbacks:registerCallback(name, cb) end

--- Regsiter callbacks as module
addModule('callbacks', callbacks)