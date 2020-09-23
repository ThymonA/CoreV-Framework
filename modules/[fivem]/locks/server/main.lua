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
local locks = class('locks')

locks:set {
    locks = {},
    loaded = false
}

Citizen.CreateThread(function()
    for name, lock in pairs((Config.Locks or {}).Doors or {}) do
        local lockObject = locks:createLock(name, lock)

        if (lockObject ~= nil) then
            locks.locks[lockObject.name] = lockObject
        end
    end

    locks.loaded = true
end)

--- Returns all current locks
function locks:getPlayerLocks(source)
    local _locks = {}

    for _, lock in pairs(locks.locks or {}) do
        _locks[lock.name] = {
            name = lock.name,
            locked = lock.locked or false,
            distance = lock.distance or 5,
            doors = lock.doors or {},
            numberOfDoors = lock.numberOfDoors or 0,
            allowed = lock:playerAllowed(source),
            labelPosition = lock.labelPosition or false
        }
    end

    return _locks
end

registerCallback('corev:locks:receive', function(source, cb)
    repeat Wait(0) until locks.loaded == true

    local doorLocks = locks:getPlayerLocks(source) or {}

    cb(doorLocks)
end)

registerCallback('corev:locks:lock', function(source, cb, name)
    repeat Wait(0) until locks.loaded == true

    local lock = (locks.locks or {})[name] or nil

    if (lock == nil) then cb(false) return end
    if (not lock:playerAllowed(source)) then cb(false) return end

    lock:updateState(true)

    cb(true)
end)

registerCallback('corev:locks:unlock', function(source, cb, name)
    repeat Wait(0) until locks.loaded == true

    local lock = (locks.locks or {})[name] or nil

    if (lock == nil) then cb(false) return end
    if (not lock:playerAllowed(source)) then cb(false) return end

    lock:updateState(false)

    cb(true)
end)

addModule('locks', locks)