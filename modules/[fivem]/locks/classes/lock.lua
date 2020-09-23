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
function locks:createLock(name, lockData)
    local lock = class('lock')

    --- Set default values
    lock:set {
        name = 'unknown',
        whitelist = { jobs = {}, groups = {} },
        locked = false,
        distance = -1,
        doors = {},
        numberOfDoors = 0,
        labelPosition = nil
    }

    --- Make sure that every lock has a name
    if (name == nil or type(name) ~= 'string') then name = getRandomString(24) end

    --- Make sure that every illegal character has been removed from name
    for _, character in pairs({ '.', ',', '/', '\\', ':', '"', '\'', '[', ']', '{', '}', '-', '<', '>', '*', '!', '@', '#', '$', '%', '^', '&', '(', ')', '+', '=', '|', '`', '~' }) do
        name = string.replace(name, character, '_')
    end

    --- Make sure that every lock has there own name
    if (self.locks ~= nil and self.locks[name] ~= nil) then return self:createLock(getRandomString(24), lockData) end

    lock.name = name

    if (lockData ~= nil and lockData.Authorized ~= nil and type(lockData.Authorized) == 'table') then
        local authorized = lockData.Authorized or {}

        for i, group in pairs(authorized.Groups or {}) do
            if (type(group) == 'string' and group ~= '') then
                if (string.lower(group) == 'all') then
                    for _i, _group in pairs(Config.PermissionGroups or {}) do
                        ExecuteCommand(('add_ace group.%s "lock.%s" allow'):format(_group, lock.name))
                    end
                else
                    ExecuteCommand(('add_ace group.%s  "lock.%s" allow'):format(group, lock.name))
                end
            end
        end

        lock.whitelist.jobs = authorized.Jobs or {}
        lock.whitelist.groups = authorized.Groups or {}
    end

    if (lockData ~= nil and lockData.Locked ~= nil and type(lockData.Locked) == 'boolean') then
        lock.locked = lockData.Locked or false
    elseif (lockData ~= nil and lockData.Locked ~= nil and type(lockData.Locked) == 'number') then
        lock.locked = (lockData.Locked or 0) == 1
    end

    if (lockData ~= nil and lockData.Distance ~= nil and type(lockData.Distance) == 'number') then
        lock.distance = lockData.Distance or -1
    end

    if (lockData.LabelPosition ~= nil and type(lockData.LabelPosition) == 'vector3') then
        lock.labelPosition = lockData.LabelPosition
    elseif (lockData.LabelPosition ~= nil and type(lockData.LabelPosition) == 'table') then
        lock.labelPosition = vector3(lockData.LabelPosition.x or 0.0, lockData.LabelPosition.y or 0.0, lockData.LabelPosition.z or 0.0)
    end

    if (lockData ~= nil and lockData.Doors ~= nil and type(lockData.Doors) == 'table') then
        for _, door in pairs(lockData.Doors or {}) do
            door.Locked = lock.locked or false

            local doorObject = self:createDoor(door or {})

            if (doorObject ~= nil) then
                lock.numberOfDoors = lock.numberOfDoors + 1
                table.insert(lock.doors, doorObject)
            end
        end
    end

    if (lockData ~= nil and lockData.Door ~= nil and type(lockData.Door) == 'table') then
        lockData.Door.Locked = lock.locked or false

        local doorObject = self:createDoor(lockData.Door or {})

        if (doorObject ~= nil) then
            lock.numberOfDoors = lock.numberOfDoors + 1
            table.insert(lock.doors, doorObject)
        end
    end

    if (lock.numberOfDoors <= 0) then return nil end

    --- Checks if a player is allowed to interact with lock
    --- @param source number Player ID
    function lock:playerAllowed(source)
        if (source == nil or type(source) ~= 'number') then
            return false
        end

        local aceAllowed = IsPlayerAceAllowed(source, ('lock.%s'):format(self.name))

        if (aceAllowed == true or aceAllowed == 1) then return true end

        local players = m('players')
        local player = players:getPlayer(source)

        if (player == nil) then return false end

        for i, job in pairs((locks.locks[self.name].whitelist or {}).jobs or {}) do
            if (job ~= nil and type(job) == 'string') then
                return string.lower(job) == string.lower(player.job.name) or string.lower(job) == string.lower(player.job2.name)
            elseif (job ~= nil and type(job) == 'table') then
                if (job.name ~= nil and type(job.name) == 'string') then
                    if (string.lower(job.name) == string.lower(player.job.name)) then
                        for _i, _grade in pairs(job.grades or {}) do
                            if (_grade ~= nil and type(_grade) == 'string' and string.lower(_grade) == string.lower(player.grade.name)) then
                                return true
                            elseif (_grade ~= nil and type(_grade) == 'number' and _grade == player.grade.grade) then
                                return true
                            end
                        end
                    elseif (string.lower(job.name) == string.lower(player.job2.name)) then
                        for _i, _grade in pairs(job.grades or {}) do
                            if (_grade ~= nil and type(_grade) == 'string' and string.lower(_grade) == string.lower(player.grade2.name)) then
                                return true
                            elseif (_grade ~= nil and type(_grade) == 'number' and _grade == player.grade2.grade) then
                                return true
                            end
                        end
                    end
                end
            end
        end

        return false
    end

    --- Update current lock state
    --- @param newState boolean New lock status
    function lock:updateState(newState)
        if (newState == nil or (type(newState) ~= 'boolean' and type(newState) ~= 'number')) then
            return
        end

        if (type(newState) == 'number') then newState = newState == 1 end

        if (self.locked == newState) then
            return
        else
            self.locked = newState
        end

        if (self.numberOfDoors > 0) then
            for i, _ in pairs(self.doors or {}) do
                self.doors[i].locked = newState
            end
        end

        TCE('corev:locks:updateLock', -1, self.name, self.locked)
    end

    return lock
end