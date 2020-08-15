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
local players = class('players')

--- Set default value
players:set {
    players = {}
}

--- Load a player
--- @param self desc1
--- @param source desc2
function players:loadPlayerData(source)
    if (self.players ~= nil and self.players[tostring(source)] ~= nil) then
        return self.players[tostring(source)]
    end

    local database = m('database')
    local identifiers = m('identifiers')
    local jobs = m('jobs')
    local playerIdentifier = identifiers:getPlayer(source)
    
    local playerExists = database:fetchScalar("SELECT COUNT(*) AS `count` FROM `players` WHERE `identifier` = @identifier", {
        ['@identifier'] = playerIdentifier:getIdentifier()
    })

    if (playerExists <= 0) then
        local unemployedJobs = jobs:getJobByName('unemployed')
        local unemployedGrade = unemployedJobs:getGradeByName('unemployed')
        
        database:execute('INSERT INTO `players` (`identifier`, `accounts`, `job`, `grade`, `job2`, `grade2`) VALUES (@identifier, @accounts, @job, @grade, @job2, @grade2)', {
            ['@identifier'] = playerIdentifier:getIdentifier(),
            ['@accounts'] = json.encode({}),
            ['@job'] = unemployedJobs.id,
            ['@grade'] = unemployedGrade.grade,
            ['@job2'] = unemployedJobs.id,
            ['@grade2'] = unemployedGrade.grade,
        })

        print(_(CR(), 'players', 'player_created', GetPlayerName(source)))

        return self:loadPlayerData(source)
    end

    local playerData = database:fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier', {
        ['@identifier'] = playerIdentifier:getIdentifier()
    })[1]

    local job = jobs:getJob(playerData.job)
    local grade = job:getGrade(playerData.grade)
    local job2 = jobs:getJob(playerData.job2)
    local grade2 = job:getGrade(playerData.grade2)
    local player = class('player')

    --- Set default values
    player:set {
        identifier = playerIdentifier:getIdentifier(),
        name = GetPlayerName(source),
        job = job,
        grade = grade,
        job2 = job2,
        grade2 = grade2,
        accounts = json.decode(playerData.accounts)
    }

    players.players[tostring(source)] = player

    return player
end

--- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    local loadPlayer = players:loadPlayerData(source)

    returnSuccess()
end)

--- Trigger when player is connecting
onPlayerConnected(function(source, returnSuccess, returnError)
    local found, identifiers = false, m('identifiers')
    local identifier = identifiers:getIdentifier(source)

    for playerSource, playerObject in pairs(players.players or {}) do
        if (playerObject.identifier == identifier) then
            found = true

            players.players[tostring(source)] = playerObject:extend()
            players.players[playerSource] = nil
        end
    end

    if (not found) then
        local loadPlayer = players:loadPlayerData(source)
    end

    returnSuccess()
end)

addModule('players', players)