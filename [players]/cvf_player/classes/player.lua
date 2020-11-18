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
---@type corev_server
local corev = assert(corev_server)
local lower = assert(string.lower)
local CreateThread = assert(Citizen.CreateThread)

--- Create a players class
---@class players
local players = setmetatable({ __class = 'players' }, {})

players.players = {}
players.sources = {}

--- Load a `job` class for given job
---@param input string|number Name or ID of job
---@param grade number Grade of given job
---@return job|nil Generated `job` class or `nil`
function players:getJobObject(input, grade)
    input = corev:typeof(input) == 'number' and input or corev:ensure(input, 'unknown')
    grade = corev:ensure(grade, 0)

    local _job = corev.jobs:getJob(input)

    if (_job == nil) then return nil end

    --- Create a `player_job` class
    ---@class player_job
    local job = setmetatable({ __class = 'player_job' }, {})

    --- Set default values
    job.id = corev:ensure(_job.id, 0)
    job.name = corev:ensure(_job.name, 'unknown')
    job.label = corev:ensure(_job.label, 'Unknown')
    job.grades = corev:ensure(_job.grades, {})
    job.grade = nil

    local _grade = job.grades[grade] or nil

    if (_grade == nil) then return job end

    --- Create a `player_grade` class
    ---@class player_grade
    local gradeObj = setmetatable({ __class = 'player_grade' }, {})

    --- Set default values
    gradeObj.grade = _grade.grade
    gradeObj.name = _grade.name
    gradeObj.label = _grade.label

    job.grade = gradeObj

    return job
end

--- Create a `vPlayer` class
---@param input string|number Player identifier or Player source
local function createPlayer(input)
    local player = corev:getPlayerIdentifiers(input)

    if (player == nil or player.identifier == nil) then return nil end

    local key = corev:ensure(player.identifier, 'unknown')

    if (players.players[key] ~= nil) then
        players.players[key].source = player.source or nil

        return players.players[key]
    end

    --- Create a `vPlayer` class
    ---@class vPlayer
    local vPlayer = setmetatable({ __class = 'vPlayer' }, {})

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
    vPlayer.id = dbPlayer[1].id
    vPlayer.source = player.source or nil
    vPlayer.name = player.name
    vPlayer.group = playerGroup
    vPlayer.identifier = player.identifier
    vPlayer.identifiers = player.identifiers
    vPlayer.job = players:getJobObject(dbPlayer[1].job, dbPlayer[1].grade)
    vPlayer.job2 = players:getJobObject(dbPlayer[1].job2, dbPlayer[1].grade2)

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
_G.players = players
_G.createPlayer = createPlayer