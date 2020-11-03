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

--- Mark this resource as `database` migration dependent resource
corev.db:migrationDependent()

--- Create a `identifiers` class
local identifiers = class 'identifiers'

--- Set default values
identifiers:set('players', {})

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