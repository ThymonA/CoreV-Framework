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
---@type corev_server
local corev = assert(corev_server)

--- Mark this resource as `database` migration dependent resource
corev.db:migrationDependent()

--- Create a `skins` class
---@class skins
local skins = setmetatable({ __class = 'skins' }, {})

--- Set default values
skins.players = {}

--- Register callback for loading database skin
corev.callback:register('load', function(vPlayer, cb)
    if (vPlayer == nil) then
        cb('{}', nil)
        return
    end

    if (skins.players ~= nil and skins.players[vPlayer.identifier] ~= nil) then
        cb(skins.players[vPlayer.identifier].data, skins.players[vPlayer.identifier].model)
        return
    end

    corev.db:fetchAllAsync('SELECT * FROM `player_skins` WHERE `player_id` = @id LIMIT 1', {
        ['@id'] = vPlayer.id
    }, function(results)
        results = corev:ensure(results, {})

        if (#results <= 0) then
            cb('{}', nil)
        else
            skins.players[vPlayer.identifier] = {
                data = results[1].data or '{}',
                model = results[1].model or nil
            }

            cb(skins.players[vPlayer.identifier].data, skins.players[vPlayer.identifier].model)
        end
    end)
end)