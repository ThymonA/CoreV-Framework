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
local identifiers = class('identifiers')

--- Default values
identifiers:set {
    players = {}
}

--- Returns a player identifier by type
--- @param source int Player ID
--- @param type string Identifier Type
function identifiers:getPlayer(source)
    if (identifiers.players ~= nil and identifiers.players[tostring(source)] ~= nil) then
        return identifiers.players[tostring(source)]
    end

    return nil
end

--- Returns a player identifier
--- @param source int Player ID
function identifiers:getIdentifier(source)
    if (source <= 0) then
        return 'console'
    end

    local player = self:getPlayer(source)

    if (player == nil) then
        local playerIdentifier = 'none'
        local _identifiers = GetPlayerIdentifiers(source)

        for _, identifier in pairs(_identifiers) do
            if (IDTYPE == 'steam' and string.match(string.lower(identifier), 'steam:')) then
                playerIdentifier = string.sub(identifier, 7)
            elseif (IDTYPE == 'license' and string.match(string.lower(identifier), 'license:')) then
                playerIdentifier = string.sub(identifier, 9)
            elseif (IDTYPE == 'xbl' and string.match(string.lower(identifier), 'xbl:')) then
                playerIdentifier = string.sub(identifier, 5)
            elseif (IDTYPE == 'live' and string.match(string.lower(identifier), 'live:')) then
                playerIdentifier = string.sub(identifier, 6)
            elseif (IDTYPE == 'discord' and string.match(string.lower(identifier), 'discord:')) then
                playerIdentifier = string.sub(identifier, 9)
            elseif (IDTYPE == 'fivem' and string.match(string.lower(identifier), 'fivem:')) then
                playerIdentifier = string.sub(identifier, 7)
            elseif (IDTYPE == 'ip' and string.match(string.lower(identifier), 'ip:')) then
                playerIdentifier = string.sub(identifier, 4)
            end
        end

        if (playerIdentifier == 'none') then
            return 'none'
        end

        return playerIdentifier
    end

    return player:getIdentifier()
end

--- Create a player identifier object
--- @param source int Player ID
--- @param primaryIdentifier string primary identifier
function identifiers:createPlayerIdentifier(source, primaryIdentifier)
    local _playerIdentifier = class('player-identifier')
    local _identifier = {}

    if (source == 0) then
        _identifier = {
            'steam:console',
            'license:console',
            'xbl:console',
            'live:console',
            'discord:console',
            'fivem:console',
            'ip:console'
        }
    else
        _identifier = GetPlayerIdentifiers(source)
    end

    --- Set default values
    _playerIdentifier:set {
        identifier = primaryIdentifier,
        identifiers = _identifier,
        id = source
    }

    --- Get identifier by Type
    --- @param type string Identifier Type
    function _playerIdentifier:getByType(type)
        for _, identifier in pairs(self.identifiers or {}) do
            if (type == 'steam' and string.match(string.lower(identifier), 'steam:')) then
                return string.sub(identifier, 7)
            elseif (type == 'license' and string.match(string.lower(identifier), 'license:')) then
                return string.sub(identifier, 9)
            elseif (type == 'xbl' and string.match(string.lower(identifier), 'xbl:')) then
                return string.sub(identifier, 5)
            elseif (type == 'live' and string.match(string.lower(identifier), 'live:')) then
                return string.sub(identifier, 6)
            elseif (type == 'discord' and string.match(string.lower(identifier), 'discord:')) then
                return string.sub(identifier, 9)
            elseif (type == 'fivem' and string.match(string.lower(identifier), 'fivem:')) then
                return string.sub(identifier, 7)
            elseif (type == 'ip' and string.match(string.lower(identifier), 'ip:')) then
                return string.sub(identifier, 4)
            end
        end

        return 'unknown'
    end

    --- Get identifier
    function _playerIdentifier:getIdentifier()
        return self.identifier or 'unknown'
    end

    --- Get identifiers
    function _playerIdentifier:getIdentifiers()
        return self.identifiers or {}
    end

    return _playerIdentifier
end

--- Create a default console identifier
identifiers.players[tostring(0)] = identifiers:createPlayerIdentifier(0, 'console')

-- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then
        returnError(_(CR(), 'identifiers', 'source_error'))
        return
    end

    local playerIdentifier = identifiers:getIdentifier(source)

    if (playerIdentifier == 'none') then
        returnError(_(CR(), 'identifiers', string.lower(IDTYPE) .. '_error'))
        return
    end

    identifiers.players[tostring(source)] = identifiers:createPlayerIdentifier(source, playerIdentifier)

    return returnSuccess()
end)

-- Trigger when player is fully connected
onPlayerConnected(function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then
        returnError(_(CR(), 'identifiers', 'source_error'))
        return
    end

    local found, identifier = false, identifiers:getIdentifier(source)

    for playerSource, playerIdentifier in pairs(identifiers.players or {}) do
        if (playerIdentifier.identifier == identifier) then
            found = true

            local _object = playerIdentifier:extend()

            _object.id = source

            identifiers.players[tostring(source)] = _object
            identifiers.players[playerSource] = nil
        end
    end

    if (not found) then
        identifiers.players[tostring(source)] = identifiers:createPlayerIdentifier(source, identifier)
    end

    returnSuccess()
end)

addModule('identifiers', identifiers)