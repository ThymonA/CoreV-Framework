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
local lower = assert(string.lower)
local CreateThread = assert(Citizen.CreateThread)

--- Create a players class
local players = class 'players'

--- Set default values
players:set {
    players = {},
    sources = {}
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
        job2 = players:getJobObject(dbPlayer[1].job2, dbPlayer[1].grade2)
    }

    --- This function will returns vPlayer primary identifier
    function vPlayer:getIdentifier()
        return corev:ensure(self.identifier, 'unknown')
    end

    players.players[vPlayer.identifier] = vPlayer

    if (vPlayer.source ~= nil) then
        players.sources[vPlayer.source] = players.players[vPlayer.identifier]
    end

    return vPlayer
end

--- Create a `vPlayer` object for `console`
CreateThread(function()
    createPlayer('console')
end)

--- Register `createPlayer` as global function and `players` as global variable
global.players = players
global.createPlayer = createPlayer