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
local lower = assert(string.lower)
local match = assert(string.match)
local sub = assert(string.sub)
local pairs = assert(pairs)
local exports = assert(exports)

--- Mark this resource as `database` migration dependent resource
corev.db:migrationDependent()

--- Create a `identifiers` class
local identifiers = class 'identifiers'

--- Set default values
identifiers:set('players', {})

--- Generates a `player` class for console, with source '0'
--- @return player Generated `player` class for console
function identifiers:createConsole()
    --- Create a new `player` class
    local player = class 'player'

    --- Set default values
    player:set {
        source = 0,
        name = 'Console',
        identifier = 'console',
        identifiers = {
            steam = 'console',
            license = 'console',
            xbl = 'console',
            live = 'console',
            discord = 'console',
            fivem = 'console',
            ip = '127.0.0.1'
        }
    }

    return player
end

--- Add console as player
identifiers.players['console'] = identifiers:createConsole()

--- Validate given identifier
--- @param identifier string Identifier to check on
--- @return string Identifier without `steam:`, `license:` etc.
--- @return string Identifier Type: `steam`, `license` etc.
--- @return boolean `true` if identifier is a primary identifier, otherwise `false`
function identifiers:getIdentifierInfo(identifier)
    identifier = corev:ensure(identifier, 'unknown')

    if (identifier == 'unknown') then
        return identifier, identifier, false
    end

    local primaryIdentifierType = corev:ensure(corev:cfg('core', 'identifierType'), 'license')

    primaryIdentifierType = lower(primaryIdentifierType)

    if (match(identifier, 'steam:')) then
        return sub(identifier, 7), 'steam', primaryIdentifierType == 'steam'
    elseif (match(identifier, 'license:')) then
        return sub(identifier, 9), 'license', primaryIdentifierType == 'license'
    elseif (match(identifier, 'xbl:')) then
        return sub(identifier, 5), 'xbl', primaryIdentifierType == 'xbl'
    elseif (match(identifier, 'live:')) then
        return sub(identifier, 6), 'live', primaryIdentifierType == 'live'
    elseif (match(identifier, 'discord:')) then
        return sub(identifier, 9), 'discord', primaryIdentifierType == 'discord'
    elseif (match(identifier, 'fivem:')) then
        return sub(identifier, 7), 'fivem', primaryIdentifierType == 'fivem'
    elseif (match(identifier, 'ip:')) then
        return sub(identifier, 4), 'ip', primaryIdentifierType == 'ip'
    end

    local stringParts = corev:split(identifier, ':')

    if (#stringParts == 2) then
        local identifierType = corev:ensure(stringParts[2], 'unknown')
        local identifierValue = corev:ensure(stringParts[1], 'unknown')

        return identifierType, identifierValue, primaryIdentifierType == identifierType
    end

    return identifier, primaryIdentifierType, true
end

--- Will load all players identifiers based on given rawInput, returns live information or cached database information
--- @param rawInput string|number Identifier like `steam:...`, `license:...` etc.
--- @return player|nil A generated `player` class or nil if identifier can't be found
function getPlayerIdentifiers(rawInput)
    if (corev:typeof(rawInput) == 'number') then
        for _, player in pairs(identifiers.players) do
            if (corev:ensure(player.source, -2) == rawInput) then
                return player
            end
        end

        return nil
    end

    rawInput = corev:ensure(rawInput, 'unknown')

    if (rawInput == 'unknown') then return nil end

    local identifier, identifierType, isPrimaryIdentifier =
        identifiers:getIdentifierInfo(rawInput)

    if (identifierType == 'unknown') then return nil end

    if (isPrimaryIdentifier) then
        if (identifiers.players[identifier] ~= nil) then
            return identifiers.players[identifier]
        end
    end

    local primaryIdentifierType = lower(corev:ensure(corev:cfg('core', 'identifierType'), 'license'))
    local sqlQuery = ('SELECT * FROM `player_identifiers` WHERE `%s` = @identifier ORDER BY `id` DESC LIMIT 1'):format(identifierType)
    local latestIdentifiers = corev.db:fetchAll(sqlQuery, {
        ['@identifier'] = identifier
    })

    latestIdentifiers = corev:ensure(latestIdentifiers, {})

    if (#latestIdentifiers > 0) then
        --- Create a new `player` class
        local player = class 'player'

        --- Set default values
        player:set {
            source = nil,
            name = corev:ensure(latestIdentifiers[1].name, 'Unknown'),
            identifiers = {
                steam = latestIdentifiers[1].steam,
                license = latestIdentifiers[1].license,
                xbl = latestIdentifiers[1].xbl,
                live = latestIdentifiers[1].live,
                discord = latestIdentifiers[1].discord,
                fivem = latestIdentifiers[1].fivem,
                ip = latestIdentifiers[1].ip
            },
            identifier = (latestIdentifiers[1] or {})[primaryIdentifierType] or nil
        }

        if (player.identifier == nil) then return player end

        identifiers.players[player.identifier] = player

        return player
    end

    return nil
end

--- This event will be trigger when a player is connecting
corev.events:onPlayerConnect(function(player, done)
    --- Store player identifiers for later use
    corev.db:execute('INSERT INTO `player_identifiers` (`name`, `steam`, `license`, `xbl`, `live`, `discord`, `fivem`, `ip`) VALUES (@name, @steam, @license, @xbl, @live, @discord, @fivem, @ip)', {
        ['@name'] = player.name,
        ['@steam'] = player.identifiers.stream,
        ['@license'] = player.identifiers.license,
        ['@xbl'] = player.identifiers.xbl,
        ['@live'] = player.identifiers.live,
        ['@discord'] = player.identifiers.discord,
        ['@fivem'] = player.identifiers.fivem,
        ['@ip'] = player.identifiers.ip
    })

    if (player.identifier == nil) then
        --- Load default framework's identifier
        local identifierType = corev:ensure(corev:cfg('core', 'identifierType'), 'license')

        identifierType = lower(identifierType)

        done(corev:t('identifier', ('%s_not_found'):format(identifierType)))
        return
    end

    --- Create a new `player` class
    local vPlayer = class 'player'

    --- Set default values
    vPlayer:set {
        source = player.source,
        name = player.name,
        identifiers = player.identifiers,
        identifier = player.identifier
    }

    --- Save player for later access
    identifiers.players[vPlayer.identifier] = vPlayer

    done()
end)

--- This event will be triggerd when a player is disconnected
corev.events:onPlayerDisconnect(function(player)
    if (player.identifier == nil) then
        return
    end

    if (identifiers.players[player.identifier] ~= nil) then
        identifiers.players[player.identifier].source = nil
    end
end)

--- Register `getPlayerIdentifiers` as export function
exports('__g', getPlayerIdentifiers)