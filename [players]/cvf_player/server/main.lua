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
local print = assert(print)
local lower = assert(string.lower)

--- Cahce FiveM globals
local exports = assert(exports)

--- Mark this resource as `database` migration dependent resource
corev.db:migrationDependent()

--- Returns a `vPlayer` class based on given input
---@param input string|number Player identifier or Player source
---@return vPlayer|nil Founded/Generated `vPlayer` class or nil
local function getPlayer(input)
    input = corev:typeof(input) == 'number' and input or corev:ensure(input, 'unknown')

    if (corev:typeof(input) == 'number') then
        local vPlayer = players.sources[input] or nil

        if (vPlayer) then return vPlayer end

        return createPlayer(input)
    end

    local vPlayer = players.players[input] or nil

    if (vPlayer) then return vPlayer end

    return createPlayer(input)
end

--- This event will be triggerd when client is connecting
corev.events:onPlayerConnect(function(player, done, presentCard)
    presentCard:setTitle(corev:t('connect_title'), false)
    presentCard:setDescription(corev:t('connect_description'))

    local exists = corev.db:fetchScalar('SELECT COUNT(*) FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['@identifier'] = player.identifier
    })

    if (exists == 1) then
        corev.db:execute('UPDATE `players` SET `name` = @name WHERE `identifier` = @identifier LIMIT 1', {
            ['@name'] = player.name,
            ['@identifier'] = player.identifier
        })

        createPlayer(player.identifier)
        done()
        return
    end

    local defaultConfigJob = corev:cfg('jobs', 'defaultJob')
    local defaultJobName = lower(corev:ensure(defaultConfigJob.name, 'unemployed'))
    local defaultJob = corev.jobs:getJob(defaultJobName)

    if (defaultJob == nil or (defaultJob.grades or {})[0] == nil) then
        done(corev:t('default_job_not_found'))
        return
    end

    local defaultGrade = defaultJob.grades[0]

    corev.db:execute('INSERT INTO `players` (`identifier`, `name`, `job`, `job2`, `grade`, `grade2`) VALUES (@identifier, @name, @job, @job2, @grade, @grade2)', {
        ['@identifier'] = player.identifier,
        ['@name'] = player.name,
        ['@job'] = defaultGrade.job_id,
        ['@job2'] = defaultGrade.job_id,
        ['@grade'] = defaultGrade.grade,
        ['@grade2'] = defaultGrade.grade
    })

    print(corev:t('player_created'):format(corev:getCurrentResourceName(), player.name))

    createPlayer(player.identifier)
    done()
end)

--- Register `GetPlayer` as export function
exports('__g', getPlayer)