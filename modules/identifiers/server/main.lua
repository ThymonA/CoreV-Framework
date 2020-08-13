----------------------- [ FXCore ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/fx_core/
-- GitHub: https://github.com/ThymonA/FXCore/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
-- Name: FXCore
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ FXCore ] -----------------------
local identifiers = class('identifiers')

--- Default values
identifiers:set {
    players = {}
}

--- Returns a player identifier by type
--- @param source int Player ID
--- @param type string Identifier Type
function identifiers:GetPlayer(source)
    if (identifiers.players ~= nil and identifiers.players[tostring(source)] ~= nil) then
        return identifiers.players[tostring(source)]
    end

    return nil
end

-- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then
        returnError(_(GetCurrentResourceName(), 'identifiers', 'source_error'))
        return
    end

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
        returnError(_(GetCurrentResourceName(), 'identifiers', string.lower(IDTYPE) .. '_error'))
        return
    end

    local _playerIdentifier = class('player-identifier')

    --- Set default values
    _playerIdentifier:set {
        identifier = playerIdentifier,
        identifiers = _identifiers,
        id = source
    }

    --- Get identifier by Type
    --- @param type string Identifier Type
    function _playerIdentifier:GetByType(type)
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
    function _playerIdentifier:GetIdentifier()
        return self.identifier or 'unknown'
    end

    --- Get identifiers
    function _playerIdentifier:GetIdentifiers()
        return self.identifiers or {}
    end

    identifiers.players[tostring(source)] = _playerIdentifier

    return returnSuccess()
end)

module('identifiers', identifiers)