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
    requestId  = 1,
    callbacks = {}
}

--- Trigger server callback
--- @name string event
--- @cb function callback
function callbacks:triggerServerCallback(name, cb, ...)
    self.callbacks[self.requestId] = cb

    TSE('corev:triggerServerCallback', name, self.requestId, ...)

    if (self.requestId < 65535) then
        self.requestId = self.requestId + 1
    else
        self.requestId = 1
    end
end

--- When server trigger this event
onServerTrigger('corev:triggerCallback', function(requestId, ...)
    if (requestId == nil or type(requestId) ~= 'number') then return end
    if (callbacks.callbacks == nil or callbacks.callbacks[requestId] == nil) then return end

    callbacks.callbacks[requestId](...)
    callbacks.callbacks[requestId] = nil
end)

--- FiveM manipulation
_ENV.triggerServerCallback = function(name, cb, ...) callbacks:triggerServerCallback(name, cb, ...) end
_G.triggerServerCallback = function(name, cb, ...) callbacks:triggerServerCallback(name, cb, ...) end

--- Regsiter callbacks as module
addModule('callbacks', callbacks)