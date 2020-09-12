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
local players = class('players')

--- Set default value
players:set {
    players = {}
}

--- Load a player
--- @param player int|string Player
function players:getPlayer(player)
    local identifiers = m('identifiers')
    local identifier = 'none'

    if (player == nil or (type(player) == 'number' and player == 0) or (type(player) == 'string' and player == 'console')) then
        identifier = 'console'
    elseif(player ~= nil and (type(player) == 'number' and player > 0)) then
        identifier = identifiers:getIdentifier(player)
    else
        identifier = player
    end

    if (identifier ~= 'none' and players.players ~= nil and players.players[identifier] ~= nil) then
        return players.players[identifier]
    end

    if (identifier == 'none') then
        return nil
    end

    return self:createPlayer(player)
end

--- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    players:getPlayer(source)

    returnSuccess()
end)

--- Trigger when player is connecting
onPlayerConnected(function(source, returnSuccess, returnError)
    local found, identifiers = false, m('identifiers')
    local identifier = identifiers:getIdentifier(source)

    players:getPlayer(source)

    returnSuccess()
end)

onClientTrigger('corev:hud:init', function()
    local playerId = source
    local player = players:getPlayer(playerId)

    TCE('corev:hud:updateJobs', playerId,
        ((player.job or {}).label or 'Unknown'),
        ((player.grade or {}).label or 'Unknown'),
        ((player.job2 or {}).label or 'Unknown'),
        ((player.grade2 or {}).label or 'Unknown'))
end)

addModule('players', players)