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
local garage = class('garage')

--- Set default values
garage:set {
    locations = {
    }
}

--- Load all location
for garageName, garageInfo in pairs(Config.Locations or {}) do
    if (garageInfo.type == nil or type(garageInfo.type) ~= 'string') then
        garageInfo.type = 'cars'
    end

    --- Make sure that type = cars, planes or boats
    if (string.lower(garageInfo.type) == 'cars' or string.lower(garageInfo.type) == 'car') then
        garageInfo.type = 'cars'
    elseif (string.lower(garageInfo.type) == 'planes' or string.lower(garageInfo.type) == 'plane') then
        garageInfo.type = 'planes'
    elseif (string.lower(garageInfo.type) == 'boats' or string.lower(garageInfo.type) == 'boat') then
        garageInfo.type = 'boats'
    else
        garageInfo.type = 'cars'
    end

    --- Make sure that location has a location
    if (garageInfo.location ~= nil and type(garageInfo.location) == 'vector3') then
        garageInfo.location = garageInfo.location
    elseif (garageInfo.location ~= nil and type(garageInfo.location) == 'table') then
        garageInfo.location = vector3(
            garageInfo.location.x or 0.0,
            garageInfo.location.y or 0.0,
            garageInfo.location.z or 0.0
        )
    else
        garageInfo.location = vector3(0.0, 0.0, 0.0)
    end

    --- Make sure that spawn has a location
    if (garageInfo.spawn ~= nil and type(garageInfo.spawn) == 'vector3') then
        garageInfo.spawn = { 
            x = garageInfo.location.x,
            y = garageInfo.location.y,
            z = garageInfo.location.z,
            h = 0.0 }
    elseif (garageInfo.spawn ~= nil and type(garageInfo.spawn) == 'table') then
        garageInfo.spawn = {
            x = garageInfo.spawn.x or 0.0,
            y = garageInfo.spawn.y or 0.0,
            z = garageInfo.spawn.z or 0.0,
            h = garageInfo.spawn.h or 0.0
        }
    else
        garageInfo.spawn = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 }
    end

    --- Make sure that delete has a location
    if (garageInfo.delete ~= nil and type(garageInfo.delete) == 'vector3') then
        garageInfo.delete = garageInfo.delete
    elseif (garageInfo.delete ~= nil and type(garageInfo.delete) == 'table') then
        garageInfo.delete = vector3(
            garageInfo.delete.x or 0.0,
            garageInfo.delete.y or 0.0,
            garageInfo.delete.z or 0.0
        )
    else
        garageInfo.delete = vector3(0.0, 0.0, 0.0)
    end

    garageInfo.addonInfo = {
        name = garageName or 'unknown'
    }

    garage.locations[garageName] = garageInfo
end

local markers = m('markers')

--- Create a marker for each location
for garageName, garageInfo in pairs(garage.locations or {}) do
    --- Add spawn marker
    markers:add(('garage.%s.%s'):format('spawn', garageName),
        ('garage:spawn:%s'):format(garageInfo.type),
        garage.permissions or { groups = { 'all' }, jobs = { 'all' } },
        Config.Markers[garageInfo.type]['spawn'].type,
        garageInfo.location,
        Config.Markers[garageInfo.type]['spawn'].size,
        Config.Markers[garageInfo.type]['spawn'].color,
        garageInfo.addonInfo or {})

--- Add delete marker
    markers:add(('garage.%s.%s'):format('delete', garageName),
        ('garage:delete:%s'):format(garageInfo.type),
        garage.permissions or { groups = { 'all' }, jobs = { 'all' } },
        Config.Markers[garageInfo.type]['delete'].type,
        garageInfo.delete,
        Config.Markers[garageInfo.type]['delete'].size,
        Config.Markers[garageInfo.type]['delete'].color,
        garageInfo.addonInfo or {})
end
