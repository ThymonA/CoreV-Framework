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
local commands = m('commands')

commands:register({ 'setjob', 'sj', 'setprimaryjob' }, { 'superadmin' }, function(source, arguments, showError)
    if (arguments.playerId == nil and type(arguments.playerId) ~= 'number') then return end
    if (arguments.jobName == nil and type(arguments.jobName) ~= 'string') then return end
    if (arguments.jobGrade == nil and type(arguments.jobGrade) ~= 'number') then return end

    local players = m('players')
    local player = players:getPlayer(arguments.playerId)

    if (player == nil) then
        showError(_(CR(), 'jobs', 'player_not_found_error', arguments.playerId))
        return
    end

    player:setJob(arguments.jobName, arguments.jobGrade, function(done, message)
        if (not done) then
            showError(message)
        else
            TCE('corev:players:setJob', arguments.playerId, player.job.label, player.grade.label)
        end
    end)
end, true, {
    help = _(CR(), 'jobs', 'help_setjob'),
    validate = true,
    arguments = {
        { name = 'playerId', help = _(CR(), 'jobs', 'help_playerId'), type = 'number' },
        { name = 'jobName', help = _(CR(), 'jobs', 'help_jobName'), type = 'string' },
        { name = 'jobGrade', help = _(CR(), 'jobs', 'help_jobGrade'), type = 'number' }
    }
})

commands:register({ 'setjob2', 'sj2', 'setsecondjob' }, { 'superadmin' }, function(source, arguments, showError)
    if (arguments.playerId == nil and type(arguments.playerId) ~= 'number') then return end
    if (arguments.jobName == nil and type(arguments.jobName) ~= 'string') then return end
    if (arguments.jobGrade == nil and type(arguments.jobGrade) ~= 'number') then return end

    local players = m('players')
    local player = players:getPlayer(arguments.playerId)

    if (player == nil) then
        showError(_(CR(), 'jobs', 'player_not_found_error', arguments.playerId))
        return
    end

    player:setJob2(arguments.jobName, arguments.jobGrade, function(done, message)
        if (not done) then
            showError(message)
        else
            TCE('corev:players:setJob2', arguments.playerId, player.job2.label, player.grade2.label)
        end
    end)
end, true, {
    help = _(CR(), 'jobs', 'help_setjob2'),
    validate = true,
    arguments = {
        { name = 'playerId', help = _(CR(), 'jobs', 'help_playerId'), type = 'number' },
        { name = 'jobName', help = _(CR(), 'jobs', 'help_jobName'), type = 'string' },
        { name = 'jobGrade', help = _(CR(), 'jobs', 'help_jobGrade'), type = 'number' }
    }
})