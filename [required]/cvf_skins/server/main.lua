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
local class = assert(class)

--- Mark this resource as `database` migration dependent resource
corev.db:migrationDependent()

--- Create a `skins` class
local skins = class "skins"

--- Set default values
skins:set('players', {})

--- Register callback for loading database skin
corev.callback:register('load', function(source, cb)
    if (skins.players ~= nil and skins.players[source] ~= nil) then
        cb(skins.players[source].data, skins.players[source].model)
        return
    end

    local playerIdentifier = corev:getPrimaryIdentifier(source)

    if (playerIdentifier == nil) then
        cb({}, nil)
        return
    end

    corev.db:fetchAllAsync('SELECT * FROM `player_skins` WHERE `identifier` = @identifier LIMIT 1', {
        ['@identifier'] = playerIdentifier
    }, function(results)
        results = corev:ensure(results, {})

        if (#results <= 0) then
            cb({}, nil)
        else
            skins.players[source] = {
                data = results[1].data or {},
                model = results[1].model or nil
            }

            cb(skins.players[source].data, skins.players[source].model)
        end
    end)
end)