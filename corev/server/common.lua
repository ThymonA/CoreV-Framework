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
local corev = assert(corev)
local print = assert(print)

--- This event will be trigger when a player is connecting
corev.events:onPlayerConnect(function(player, done)
    print(corev:t('core', 'player_connecting'):format(player.name))
    done()
end)

--- This event will be triggerd when a player is disconnected
corev.events:onPlayerDisconnect(function(player)
    print(corev:t('core', 'player_disconnect'):format(player.name))
end)