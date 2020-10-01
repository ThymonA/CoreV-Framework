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
local identifiers = class('identifiers')

--- Default values
identifiers:set {
    players = {},
    playerIdIdentifiers = {}
}

--- Returns a player identifier by type
--- @param source int Player ID
--- @param type string Identifier Type
function identifiers:getPlayer(player)
    if (type(player) == 'string') then
        if (identifiers.players ~= nil and identifiers.players[player] ~= nil) then
            return identifiers.players[player]
        end

        return self:createIdentifier(player)
    end

    if (type(player) == 'number') then
        if (identifiers.players ~= nil) then
            for _identifier, _identifiers in pairs(identifiers.players or {}) do
                if (_identifiers.source == player) then
                    identifiers.players[_identifier].source = player

                    return identifiers.players[_identifier]
                end
            end
        end

        return self:createIdentifier(player)
    end

    return nil
end

--- Returns a player identifier by player id (not player source)
--- @param playerId number|string PlayerID
function identifiers:getIdentifierByPlayerId(playerId)
    if (playerId == nil) then return nil end
    if (type(playerId) ~= 'number') then playerId = tonumber(playerId) end
    if (playerId <= 0) then return nil end

    local _identifier = 'none'

    if (self.playerIdIdentifiers ~= nil and self.playerIdIdentifiers[tostring(playerId)] ~= nil) then
        _identifier = self.playerIdIdentifiers[tostring(playerId)]

        return self:getPlayer(_identifier)
    end

    local database = m('database')
    
    _identifier = (database:fetchScalar("SELECT `identifier` FROM `players` WHERE `id` = @id LIMIT 1", {
        ['@id'] = playerId
    }) or 'none')

    if (_identifier == 'none') then return nil end

    self.playerIdIdentifiers[tostring(playerId)] = _identifier

    return self:getPlayer(_identifier)
end

--- Returns a player identifier
--- @param source int Player ID
function identifiers:getIdentifier(source)
    if (source <= 0) then
        return 'console'
    end

    local _identifiers = GetPlayerIdentifiers(source)

    for _, identifier in pairs(_identifiers) do
        if (IDTYPE == 'steam' and string.match(string.lower(identifier), 'steam:')) then
            return string.sub(identifier, 7)
        elseif (IDTYPE == 'license' and string.match(string.lower(identifier), 'license:')) then
            return string.sub(identifier, 9)
        elseif (IDTYPE == 'xbl' and string.match(string.lower(identifier), 'xbl:')) then
            return string.sub(identifier, 5)
        elseif (IDTYPE == 'live' and string.match(string.lower(identifier), 'live:')) then
            return string.sub(identifier, 6)
        elseif (IDTYPE == 'discord' and string.match(string.lower(identifier), 'discord:')) then
            return string.sub(identifier, 9)
        elseif (IDTYPE == 'fivem' and string.match(string.lower(identifier), 'fivem:')) then
            return string.sub(identifier, 7)
        elseif (IDTYPE == 'ip' and string.match(string.lower(identifier), 'ip:')) then
            return string.sub(identifier, 4)
        end
    end

    return 'none'
end

--- Trigger when player is connecting
on('playerConnecting', function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then
        returnError(_(CR(), 'identifiers', 'source_error'))
        return
    end

    local primaryIdentifier = 'none'
    local playerIdentifiers = {
        ['steam'] = nil,
        ['license'] = nil,
        ['xbl'] = nil,
        ['live'] = nil,
        ['discord'] = nil,
        ['fivem'] = nil,
        ['ip'] = nil
    }

    for _, _identifier in pairs(GetPlayerIdentifiers(source)) do
        if (string.match(string.lower(_identifier), 'steam:')) then
            playerIdentifiers['steam'] = _identifier
            primaryIdentifier = string.sub(_identifier, 7)
        elseif (string.match(string.lower(_identifier), 'license:')) then
            playerIdentifiers['license'] = _identifier
            primaryIdentifier = string.sub(_identifier, 9)
        elseif (string.match(string.lower(_identifier), 'xbl:')) then
            playerIdentifiers['xbl'] = _identifier
            primaryIdentifier = string.sub(_identifier, 5)
        elseif (string.match(string.lower(_identifier), 'live:')) then
            playerIdentifiers['live'] = _identifier
            primaryIdentifier = string.sub(_identifier, 6)
        elseif (string.match(string.lower(_identifier), 'discord:')) then
            playerIdentifiers['discord'] = _identifier
            primaryIdentifier = string.sub(_identifier, 9)
        elseif (string.match(string.lower(_identifier), 'fivem:')) then
            playerIdentifiers['fivem'] = _identifier
            primaryIdentifier = string.sub(_identifier, 7)
        elseif (string.match(string.lower(_identifier), 'ip:')) then
            playerIdentifiers['ip'] = _identifier
            primaryIdentifier = string.sub(_identifier, 4)
        end
    end

    local database = m('database')

    database:execute('INSERT INTO `identifiers` (`name`, `steam`, `license`, `xbl`, `live`, `discord`, `fivem`, `ip`) VALUES (@name, @steam, @license, @xbl, @live, @discord, @fivem, @ip)', {
        ['@name'] = GetPlayerName(source),
        ['@steam'] = playerIdentifiers['steam'] or nil,
        ['@license'] = playerIdentifiers['license'] or nil,
        ['@xbl'] = playerIdentifiers['xbl'] or nil,
        ['@live'] = playerIdentifiers['live'] or nil,
        ['@discord'] = playerIdentifiers['discord'] or nil,
        ['@fivem'] = playerIdentifiers['fivem'] or nil,
        ['@ip'] = playerIdentifiers['ip'] or nil
    })

    identifiers:createIdentifier(source)

    returnSuccess()
end)

--- Trigger when player is fully connected
on('playerConnected', function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then
        returnError(_(CR(), 'identifiers', 'source_error'))
        return
    end

    identifiers:createPlayerIdentifier(source)

    returnSuccess()
end)

--- Trigger when player is disconnecting
on('playerDisconnect', function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then return end

    for _identifier, _identifiers in pairs(identifiers.players or {}) do
        if (_identifiers.source == source) then
            identifiers.players[_identifier].source = -1
            returnSuccess()
            return
        end
    end

    returnSuccess()
end)

addModule('identifiers', identifiers)