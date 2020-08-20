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
local logs = class('logs')

--- Set default values
logs:set {
    players = {}
}

--- Get a log object by source
--- @param player int Player ID
function logs:get(player)
    if (type(player) == 'number') then
        for identifier, playerLog in pairs(logs.players or {}) do
            if (playerLog.source == player) then
                return playerLog
            end
        end
        
        return logs:createLog(player)
    end

    if (type(player) == 'string') then
        if (logs.players ~= nil and logs.players[player] ~= nil) then
            return logs.players[player]
        end

        return logs:createLog(player)
    end

    return nil
end

--- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    local playerLog = logs:createLog(source)

    playerLog:log({
        title = _(CR(), 'logs', 'player_connecting_title', playerLog:getName()),
        action = 'connection.connecting',
        color = Colors.Orange,
        message = _(CR(), 'logs', 'player_connecting', playerLog:getName())
    })

    returnSuccess()
end)

--- Trigger when player is fully connected
onPlayerConnected(function(source, returnSuccess, returnError)
    local playerLog = logs:createLog(source)

    playerLog:log({
        title = _(CR(), 'logs', 'player_connected_title', playerLog:getName()),
        action = 'connection.connected',
        color = Colors.Green,
        message = _(CR(), 'logs', 'player_connected', playerLog:getName())
    })

    returnSuccess()
end)

--- Trigger when player is disconnected
onPlayerDisconnect(function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then return end

    local identifiers = m('identifiers')
    local identifier = identifiers:getIdentifier(source)

    if (logs.players ~= nil and logs.players[identifier] ~= nil) then
        logs.players[identifier].source = -1

        logs.players[identifier]:log({
            title = _(CR(), 'logs', 'player_disconnect_title', logs.players[identifier]:getName()),
            action = 'connection.disconnect',
            color = Colors.Red,
            message = _(CR(), 'logs', 'player_disconnect', logs.players[identifier]:getName())
        })
    end

    returnSuccess()
end)

addModule('logs', logs)