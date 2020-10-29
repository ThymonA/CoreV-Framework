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
local class = assert(class)
local corev = assert(corev)
local pairs = assert(pairs)
local lower = assert(string.lower)
local match = assert(string.match)
local sub = assert(string.sub)
local GetPlayerIdentifiers = assert(GetPlayerIdentifiers)
local GetPlayerName = assert(GetPlayerName)
local exports = assert(exports)

--- Create a `identifiers` class
local identifiers = class 'identifiers'

--- Set default values
identifiers:set('players', {})

--- This function returns `player-identifier` class or nil
--- @param player string|number Player Identifier or Player Source ID
--- @return player-identifier|nil `player-identifier` class or nil
function identifiers:getPlayerIdentifierObject(player)
    local playerId = nil

    if (player == nil) then return end

    if (corev:typeof(player) == 'number') then
        playerId = corev:ensrue(player, -1)
        player = corev:getIdentifier(playerId)
    end

    player = corev:ensure(player, 'unknown')

    if (player == 'unknown') then return nil end

    --- Remove identifier prefix from given player identifier
    local playerParts = corev:split(player, ':')

    if (#playerParts > 1) then
        player = playerParts[#playerParts]
    end

    --- Returns stored identifier and update source if exists
    if (self.players[player] ~= nil) then
        if (playerId ~= nil) then
            self.players[player].source = playerId
        end

        return self.players[player]
    end

    --- Load default framework's identifier
    local identifierType = self:cfg('core', 'identifierType') or 'license'

    identifierType = self:ensure(identifierType, 'license')
    identifierType = lower(identifierType)

    --- Create a `player-identifier` class
    local playerIdentifier = class "player-identifier"

    --- Set default values
    playerIdentifier:set {
        source = nil,
        identifier = nil,
        identifiers = {
            steam = nil,
            license = nil,
            xbl = nil,
            live = nil,
            discord = nil,
            fivem = nil,
            ip = nil
        },
        name = 'Unknown'
    }

    --- If playerId isn't nil, than player soruce exists
    if (playerId ~= nil) then
        local playerIdentifiers = GetPlayerIdentifiers(playerId)

        playerIdentifiers = corev:ensure(playerIdentifiers, {})

        --- Apply all identifiers on `player-identifier` class
        for _, identifier in pairs(playerIdentifiers) do
            identifier = self:ensure(identifier, 'none')

            local lowIdenti = lower(identifier)

            if (match(lowIdenti, 'steam:')) then
                playerIdentifier.identifiers.steam = sub(identifier, 7)
            elseif (match(lowIdenti, 'license:')) then
                playerIdentifier.identifiers.license = sub(identifier, 9)
            elseif (match(lowIdenti, 'xbl:')) then
                playerIdentifier.identifiers.xbl = sub(identifier, 5)
            elseif (match(lowIdenti, 'live:')) then
                playerIdentifier.identifiers.live = sub(identifier, 6)
            elseif (match(lowIdenti, 'discord:')) then
                playerIdentifier.identifiers.discord = sub(identifier, 9)
            elseif (match(lowIdenti, 'fivem:')) then
                playerIdentifier.identifiers.fivem = sub(identifier, 7)
            elseif (match(lowIdenti, 'ip:')) then
                playerIdentifier.identifiers.ip = sub(identifier, 4)
            end
        end

        --- Apply primary identifier on `player-identifier` class
        if (identifierType == 'steam') then playerIdentifier.identifier = playerIdentifier.identifiers.steam end
        if (identifierType == 'license') then playerIdentifier.identifier = playerIdentifier.identifiers.license end
        if (identifierType == 'xbl') then playerIdentifier.identifier = playerIdentifier.identifiers.xbl end
        if (identifierType == 'live') then playerIdentifier.identifier = playerIdentifier.identifiers.live end
        if (identifierType == 'discord') then playerIdentifier.identifier = playerIdentifier.identifiers.discord end
        if (identifierType == 'fivem') then playerIdentifier.identifier = playerIdentifier.identifiers.fivem end
        if (identifierType == 'ip') then playerIdentifier.identifier = playerIdentifier.identifiers.ip end

        --- Apply player name on `player-identifier` class
        playerIdentifier.name = GetPlayerName(playerId)

        --- Store `player-identifier` class for later use
        self.players[playerIdentifier.identifier] = playerIdentifier

        --- Returns `player-identifier` class
        return playerIdentifier
    end

    local dbQuery = ('SELECT * FROM `identifiers` WHERE `%s` = @identifier ORDER BY `id` DESC LIMIT 1'):format(identifierType)

    local storedIdentifiers = corev.db:fetchAll(dbQuery, {
        ['@identifier'] = ('%s:%s'):format(identifierType, player)
    })

    storedIdentifiers = corev:ensure(storedIdentifiers, {})

    if (#storedIdentifiers == 0) then
        return nil
    end

    local playerStoredIdentifiers = storedIdentifiers[1]

    playerStoredIdentifiers = corev:ensure(playerStoredIdentifiers, {})

    --- Apply stored information on `player-identifier` class
    playerIdentifier.name = corev:ensure(playerStoredIdentifiers.name, 'Unknown')
    playerIdentifier.identifiers = {
        steam = playerStoredIdentifiers.steam,
        license = playerStoredIdentifiers.license,
        xbl = playerStoredIdentifiers.xbl,
        live = playerStoredIdentifiers.live,
        discord = playerStoredIdentifiers.discord,
        fivem = playerStoredIdentifiers.fivem,
        ip = playerStoredIdentifiers.ip
    }

    --- Apply primary identifier on `player-identifier` class
    if (identifierType == 'steam') then playerIdentifier.identifier = playerIdentifier.identifiers.steam end
    if (identifierType == 'license') then playerIdentifier.identifier = playerIdentifier.identifiers.license end
    if (identifierType == 'xbl') then playerIdentifier.identifier = playerIdentifier.identifiers.xbl end
    if (identifierType == 'live') then playerIdentifier.identifier = playerIdentifier.identifiers.live end
    if (identifierType == 'discord') then playerIdentifier.identifier = playerIdentifier.identifiers.discord end
    if (identifierType == 'fivem') then playerIdentifier.identifier = playerIdentifier.identifiers.fivem end
    if (identifierType == 'ip') then playerIdentifier.identifier = playerIdentifier.identifiers.ip end

    --- Store `player-identifier` class for later use
    self.players[playerIdentifier.identifier] = playerIdentifier

    --- Returns `player-identifier` class
    return playerIdentifier
end

--- Returns a list of player identifiers
--- @param player string|number Player primary identifier or Player source ID
--- @return table All founded identifiers
--- @return string Founded player name
function identifiers:getPlayerIdentifiers(player)
    if (player == nil) then return end

    local playerIdentifiers = self:getPlayerIdentifierObject(player)

    if (playerIdentifiers == nil) then
        return {
            steam = nil,
            license = nil,
            xbl = nil,
            live = nil,
            discord = nil,
            fivem = nil,
            ip = nil
        }, 'Unknown'
    end

    return playerIdentifiers.identifiers, corev:ensure(playerIdentifiers.name, 'Unknown')
end

--- Returns a list of player identifiers
--- @param player string|number Player primary identifier or Player source ID
--- @return table All founded identifiers
--- @return string Founded player name
function getPlayerIdentifiers(player)
    return identifiers:getPlayerIdentifiers(player)
end

--- Register `__getPlayerIdentifiers` as export
exports('__i', getPlayerIdentifiers)