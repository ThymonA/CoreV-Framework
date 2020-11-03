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

--- Cache global variables
local assert = assert
local class = assert(class)
local corev = assert(corev)
local pairs = assert(pairs)
local insert = assert(table.insert)
local match = assert(string.match)
local lower = assert(string.lower)
local CreateThread = assert(Citizen.CreateThread)

--- Create a players class
local players = class 'players'

--- Set default values
players:set {
    players = {}
}

--- Load a `job` class for given job
--- @param input string|number Name or ID of job
--- @param grade number Grade of given job
--- @return job|nil Generated `job` class or `nil`
function players:getJobObject(input, grade)
    input = corev:typeof(input) == 'number' and input or corev:ensure(input, 'unknown')
    grade = corev:ensure(grade, 0)

    local _job = corev.jobs:getJob(input)

    if (_job == nil) then return nil end

    --- Create a `job` class
    local job = class 'job'

    --- Set default values
    job:set {
        id = corev:ensure(_job.id, 0),
        name = corev:ensure(_job.name, 'unknown'),
        label = corev:ensure(_job.label, 'Unknown'),
        grades = corev:ensure(_job.grades, {}),
        grade = nil
    }

    local _grade = job.grades[grade] or nil

    if (_grade == nil) then return job end

    --- Create a `grade` class
    local gradeObj = class 'grade'

    --- Set default values
    gradeObj:set {
        grade = _grade.grade,
        name = _grade.name,
        label = _grade.label
    }

    job:set('grade', gradeObj)

    return job
end

--- Transform a ace table to string table
--- @param aces table Aces from @cvf_config -> aces.lua
--- @return table All founded aces as string table
local function acesToTable(aces)
    aces = corev:ensure(aces, {})

    local results = {}

    if (aces.parent) then
        results = acesToTable(aces.parent)
    end

    local permissions = corev:ensure(aces.permissions, {})

    for _, permission in pairs(permissions) do
        insert(results, corev:ensure(permission, 'unknown'))
    end

    return results
end

--- Load all aces for given group
--- @param group string Name of group
--- @return table All founded aces as string table
local function loadAces(group)
    group = corev:ensure(group, 'user')

    local aces = corev:cfg('aces', 'groups', group)

    aces = corev:ensure(aces, {})

    return acesToTable(aces)
end

--- Create a `vPlayer` class
--- @param input string|number Player identifier or Player source
local function createPlayer(input)
    local player = corev:getPlayerIdentifiers(input)

    if (player == nil or player.identifier == nil) then return nil end

    local key = corev:ensure(player.identifier, 'unknown')

    if (players.players[key] ~= nil) then
        players.players[key].source = player.source or nil

        return players.players[key]
    end

    --- Create a `vPlayer` class
    local vPlayer = class 'vPlayer'

    local dbPlayer = corev.db:fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['@identifier'] = player.identifier
    })

    dbPlayer = corev:ensure(dbPlayer, {})

    if (#dbPlayer == 0 and player.identifier == 'console') then
        local defaultJobName = lower(corev:ensure(corev:cfg('jobs', 'defaultJob', 'name'), 'unemployed'))
        local defaultJob = corev.jobs:getJob(defaultJobName)

        dbPlayer[1] = {
            id = -999,
            identifier = 'console',
            name = 'Console',
            group = 'console',
            job = defaultJob.id or 0,
            grade = 0,
            job2 = defaultJob.id or 0,
            grade2 = 0
        }
    elseif (#dbPlayer == 0) then
        return nil
    end

    local playerGroup = corev:ensure(dbPlayer[1].group, 'user')

    --- Set default values
    vPlayer:set {
        id = dbPlayer[1].id,
        source = player.source or nil,
        name = player.name,
        group = playerGroup,
        identifier = player.identifier,
        identifiers = player.identifiers,
        job = players:getJobObject(dbPlayer[1].job, dbPlayer[1].grade),
        job2 = players:getJobObject(dbPlayer[1].job2, dbPlayer[1].grade2),
        aces = loadAces(playerGroup)
    }

    --- This function will returns vPlayer primary identifier
    function vPlayer:getIdentifier()
        return corev:ensure(self.identifier, 'unknown')
    end

    --- Checks if player has access to given `ace`
    --- @param ace string|table Ace(s) to check: 'example.*'
    --- @return boolean `true` if player has access, otherwise `false`
    function vPlayer:aceAllowed(ace)
        ace = corev:typeof(ace) == 'table' and ace or corev:ensure(ace, '*')

        if (corev:typeof(ace) == 'table') then
            for _, _ace in pairs(ace) do
                if (corev:typeof(_ace) == self:aceAllowed(_ace)) then
                    return true
                end
            end

            return false
        end

        if (ace == '*') then return true end

        local hasDots = #corev:split(ace, '.') > 0

        for _, _ace in pairs(self.aces) do
            _ace = corev:ensure(_ace, 'none')

            if (_ace == '*') then return true end

            if (hasDots) then
                local pattern = corev:replace(_ace, '.*', '%..*')

                pattern = '^' .. pattern

                if (match(ace, pattern) ~= nil) then
                    return true
                end
            else
                if (ace == _ace) then
                    return true
                end
            end
        end

        return false
    end

    players.players[vPlayer.identifier] = vPlayer

    return vPlayer
end

--- Create a `vPlayer` object for `console`
CreateThread(function()
    createPlayer('console')
end)

--- Register `createPlayer` as global function
global.createPlayer = createPlayer