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
    closeLocks = {},
    drawLocks = {},
    utils = m('utils'),
    raycast = m('raycast'),
    entityEvents = {},
    flagState = false,
    anyInRange = false
}

--- Load locks in > locks.closeLocks
Citizen.CreateThread(function()
    while true do
        local coords = GetEntityCoords(GetPlayerPed(-1))

        locks.drawLocks = {}
        locks.anyInRange = false

        for lockName, lock in pairs(locks.locks or {}) do
            if (lock.numberOfDoors > 0) then
                local doorDistance = -1

                if (lock.numberOfDoors == 1 and lock.doors[1].position ~= nil) then
                    doorDistance = #(lock.doors[1].position - coords)
                else
                    for _, door in pairs(lock.doors or {}) do
                        if (door.position ~= nil) then
                            local _distance = #(door.position - coords)

                            if (doorDistance == -1 or doorDistance > _distance) then
                                doorDistance = _distance
                            end
                        end
                    end
                end

                if (doorDistance ~= -1 and doorDistance < Config.LockDoorDistance) then
                    locks.anyInRange = true
                    locks.closeLocks[lockName] = locks.closeLocks[lockName] or lock
                elseif (locks.closeLocks[lockName] ~= nil) then
                    locks.closeLocks[lockName] = nil
                end

                if (doorDistance ~= -1 and doorDistance < (lock.distance or -1) and type(lock.labelPosition) == 'vector3' and lock.allowed) then
                    local label = 'unknown'

                    if (lock.locked) then
                        label = _(CR(), 'locks', 'door_locked')
                    else
                        label = _(CR(), 'locks', 'door_unlocked')
                    end

                    table.insert(locks.drawLocks, {
                        position = lock.labelPosition,
                        label = label
                    })
                end
            end
        end

        if (not locks.anyInRange) then
            locks.closeLocks = {}
            locks.drawLocks = {}
            locks.entityEvents = {}

            clearOn('raycast:entity')
        end

        Citizen.Wait(500)
    end
end)

--- Draw labels for locks from > locks.drawLocks
Citizen.CreateThread(function()
    while true do
        for _, lockLabel in pairs(locks.drawLocks or {}) do
            locks.utils:drawText3Ds(lockLabel.position, lockLabel.label)
        end

        Citizen.Wait(0)
    end
end)

--- Find entities for doorlocks > locks.closeLocks
Citizen.CreateThread(function()
    while true do
        local coords = GetEntityCoords(GetPlayerPed(-1))

        for _, lock in pairs(locks.closeLocks or {}) do
            if (lock.numberOfDoors > 0) then
                for i, _ in pairs(lock.doors or {}) do
                    if (lock.doors[i].position ~= nil and lock.doors[i].entity == nil) then
                        if (#(lock.doors[i].position - coords) <= lock.distance) then
                            lock.doors[i].entity = GetClosestObjectOfType(lock.doors[i].position.x, lock.doors[i].position.y, lock.doors[i].position.z, 1.0, lock.doors[i].hash, false, false, false)
                        end
                    end
                end
            end
        end

        Citizen.Wait(500)
    end
end)

--- Find entities for doorlocks > locks.closeLocks
Citizen.CreateThread(function()
    local wheels, unlockWheel, wheelCreated = nil, nil, false

    while true do
        local coords = GetEntityCoords(GetPlayerPed(-1))

        for _, lock in pairs(locks.closeLocks or {}) do
            if (lock.numberOfDoors > 0) then
                for i, door in pairs(lock.doors or {}) do
                    if (lock.doors[i].latest == nil) then lock.doors[i].latest = {} end

                    if (lock.doors[i].position ~= nil and lock.doors[i].entity ~= nil) then
                        if (lock.locked and lock.doors[i].resetPosition ~= nil and lock.doors[i].resetPosition) then
                            if (lock.doors[i].latest.coords == nil or not lock.doors[i].latest.coords) then
                                lock.doors[i].latest.coords = true

                                SetEntityCoords(lock.doors[i].entity, lock.doors[i].position.x, lock.doors[i].position.y, lock.doors[i].position.z, 1, 1, 1, false)
                            end
                        end

                        if (#(lock.doors[i].position - coords) <= lock.distance) then
                            if (lock.doors[i].latest.freeze == nil or lock.doors[i].latest.freeze ~= lock.locked) then
                                lock.doors[i].latest.freeze = lock.locked

                                FreezeEntityPosition(lock.doors[i].entity, lock.locked)
                            end
                        end

                        if (lock.locked and lock.doors[i].rotation ~= nil) then
                            if (lock.doors[i].latest.rotation == nil or not lock.doors[i].latest.rotation) then
                                lock.doors[i].latest.rotation = true

                                SetEntityRotation(lock.doors[i].entity, lock.doors[i].rotation.x, lock.doors[i].rotation.y, lock.doors[i].rotation.z, 2, true)
                            end
                        end

                        if (lock.allowed and (locks.entityEvents ~= nil and locks.entityEvents[tostring(lock.doors[i].entity)] == nil)) then
                            locks.entityEvents[tostring(lock.doors[i].entity)] = true

                            on('raycast:entity', lock.doors[i].entity, function(entity, coords)
                                if (lock.allowed) then
                                    if (wheels == nil) then wheels = m('wheels') end

                                    unlockWheel, wheelCreated = wheels:create('unlock', 'unlock')

                                    if (wheelCreated) then
                                        unlockWheel:addItem({
                                            icon = 'fa-unlock',
                                            lib = 'far',
                                            addon = { action = 'unlock' }
                                        })

                                        unlockWheel:addItem({
                                            icon = 'fa-lock',
                                            lib = 'far',
                                            addon = { action = 'lock' }
                                        })

                                        unlockWheel:registerEvent('submit', function(wheel, selectedItem)
                                            local addon = wheel:getAddon()
                                            local itemAddon = selectedItem.addon or {}

                                            if (itemAddon.action == 'unlock') then
                                                triggerServerCallback('corev:locks:unlock', function(changed)
                                                end, addon.name)

                                            elseif (itemAddon.action == 'lock') then
                                                triggerServerCallback('corev:locks:lock', function(changed)
                                                end, addon.name)
                                            end
                                        end)
                                    end

                                    unlockWheel:setAddon({ entity = entity, name = lock.name })

                                    wheels:open('unlock', 'unlock', true)
                                end
                            end)
                        end
                    end
                end
            end
        end

        Citizen.Wait(100)
    end
end)

--- Request all locks
Citizen.CreateThread(function()
    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    triggerServerCallback('corev:locks:receive', function(_locks)
        locks.locks = _locks or {}
    end)
end)

onServerTrigger('corev:locks:updateLock', function(name, locked)
    if (locks.locks ~= nil and locks.locks[name] ~= nil) then
        locks.locks[name].locked = locked

        for i, _ in pairs(locks.locks[name].doors or {}) do
            locks.locks[name].doors[i].locked = locked
            locks.locks[name].doors[i].latest = {}
        end
    end
end)

onServerTrigger('corev:players:setJob', function(job, grade)
    while not resource.tasks.loadingFramework do
        Wait(0)
    end

    triggerServerCallback('corev:locks:receive', function(_locks)
        locks.locks = _locks or {}
    end)
end)

onServerTrigger('corev:players:setJob2', function(job, grade)
    while not resource.tasks.loadingFramework do
        Wait(0)
    end

    triggerServerCallback('corev:locks:receive', function(_locks)
        locks.locks = _locks or {}
    end)
end)

addModule('locks', locks)