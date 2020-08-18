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

--- Create a identifier object
--- @param player int|string Player
function identifiers:createIdentifier(player)
    local identifier = class('identifier')

    identifier:set {
        source = -1,
        identifier = 'none',
        identifiers = {},
        name = 'unknown'
    }

    --- Get a identifier by type
    --- @param type string identifier type
    function identifier:getByType(type, identifiers)
        if (identifiers) then identifiers = identifiers else identifiers = (self.identifiers or {}) end

        for i, _identifier in pairs(identifiers) do
            if (type == 'steam' and string.match(string.lower(_identifier), 'steam:')) then
                return string.sub(_identifier, 7)
            elseif (type == 'license' and string.match(string.lower(_identifier), 'license:')) then
                return string.sub(_identifier, 9)
            elseif (type == 'xbl' and string.match(string.lower(_identifier), 'xbl:')) then
                return string.sub(_identifier, 5)
            elseif (type == 'live' and string.match(string.lower(_identifier), 'live:')) then
                return string.sub(_identifier, 6)
            elseif (type == 'discord' and string.match(string.lower(_identifier), 'discord:')) then
                return string.sub(_identifier, 9)
            elseif (type == 'fivem' and string.match(string.lower(_identifier), 'fivem:')) then
                return string.sub(_identifier, 7)
            elseif (type == 'ip' and string.match(string.lower(_identifier), 'ip:')) then
                return string.sub(_identifier, 4)
            end
        end

        return 'none'
    end

    if (player ~= nil and type(player) == 'number') then
        local identifiers = GetPlayerIdentifiers(player)
        local primaryIdentifier = identifier:getByType(IDTYPE, identifiers)

        if (primaryIdentifier ~= 'none' and identifiers.players ~= nil and identifiers.players[primaryIdentifier] ~= nil) then
            identifiers.players[primaryIdentifier].source = player

            return identifiers.players[primaryIdentifier]
        end
    elseif(player ~= nil and type(player) == 'string') then
        if (player ~= 'none' and identifiers.players ~= nil and identifiers.players[player] ~= nil) then
            return identifiers.players[player]
        end
    end

    if (player == nil or (type(player) == 'number' and player == 0) or (type(player) == 'string' and player == 'console')) then
        identifier.source = 0
        identifier.name = 'Console'
        identifier.identifiers = {
            'steam:console',
            'license:console',
            'xbl:console',
            'live:console',
            'discord:console',
            'fivem:console',
            'ip:console'
        }
        identifier.identifier = 'console'
    elseif(player ~= nil and (type(player) == 'number' and player > 0)) then
        identifier.source = player
        identifier.name = GetPlayerName(player)
        identifier.identifiers = GetPlayerIdentifiers(player)
        identifier.identifier = identifier:getByType(IDTYPE, identifier.identifiers)
    else
        identifier.source = -1
        
        local query = 'SELECT * FROM `identifiers` WHERE %s ORDER BY `id` DESC LIMIT 1'

        if (IDTYPE == 'steam') then
            query = query:format('`steam` = @identifier')
        elseif (IDTYPE == 'license') then
            query = query:format('`license` = @identifier')
        elseif (IDTYPE == 'xbl') then
            query = query:format('`xbl` = @identifier')
        elseif (IDTYPE == 'live') then
            query = query:format('`live` = @identifier')
        elseif (IDTYPE == 'discord') then
            query = query:format('`discord` = @identifier')
        elseif (IDTYPE == 'fivem') then
            query = query:format('`fivem` = @identifier')
        elseif (IDTYPE == 'ip') then
            query = query:format('`ip` = @identifier')
        end

        local database = m('database')
        local rows = database:fetchAll(query, {
            ['@identifier'] = ('%s:%s'):format(IDTYPE, player)
        })

        if (rows ~= nil and #rows > 0) then
            local row = rows[1]

            identifier.source = -1
            identifier.identifiers = {}

            if (row.steam and row.steam ~= '') then
                table.insert(identifier.identifiers, row.steam)
                if(IDTYPE == 'steam') then identifier.identifier = string.sub(row.steam, 7) end
            end

            if (row.license and row.license ~= '') then
                table.insert(identifier.identifiers, row.license)
                if(IDTYPE == 'license') then identifier.identifier = string.sub(row.license, 9) end
            end
            if (row.xbl and row.xbl ~= '') then
                table.insert(identifier.identifiers, row.xbl)
                if(IDTYPE == 'xbl') then identifier.identifier = string.sub(row.xbl, 5) end
            end
            if (row.live and row.live ~= '')
            then table.insert(identifier.identifiers, row.live)
                if(IDTYPE == 'live') then identifier.identifier = string.sub(row.live, 6) end
            end
            if (row.discord and row.discord ~= '') then
                table.insert(identifier.identifiers, row.discord)
                if(IDTYPE == 'discord') then identifier.identifier = string.sub(row.discord, 9) end
            end
            if (row.fivem and row.fivem ~= '') then
                table.insert(identifier.identifiers, row.fivem)
                if(IDTYPE == 'fivem') then identifier.identifier = string.sub(row.fivem, 7) end
            end
            if (row.ip and row.ip ~= '') then
                table.insert(identifier.identifiers, row.ip)
                if(IDTYPE == 'ip') then identifier.identifier = string.sub(row.ip, 4) end
            end
            if (row.name and row.name ~= '') then
                identifier.name = row.name
            end

            identifier.identifier = identifier.identifiers[IDTYPE] or player
        else
            identifier.source = -1
            identifier.name = 'Unknown'
            identifier.identifier = player
            identifier.identifiers = {
                ('%s:%s'):format(IDTYPE, player)
            }
        end
    end

    --- Returns current primary identifier
    function identifier:getIdentifier()
        return self.identifier or 'none'
    end

    --- Returns current player identifiers
    function identifier:getIdentifiers()
        return self.identifiers or {}
    end

    --- Store identifier in current module
    identifiers.players[identifier.identifier] = identifier

    return identifier
end

--- Create a default console identifier
identifiers.players['console'] = identifiers:createIdentifier('console')