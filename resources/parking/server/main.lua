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
local parking = class('parking')

--- Set default values
parking:set {
    locations = {
    }
}

--- Load all location
for parkingName, parkingInfo in pairs(Config.Locations or {}) do
    if (parkingInfo.type == nil or type(parkingInfo.type) ~= 'string') then
        parkingInfo.type = 'cars'
    end

    --- Make sure that type = cars, planes or boats
    if (string.lower(parkingInfo.type) == 'cars' or string.lower(parkingInfo.type) == 'car') then
        parkingInfo.type = 'cars'
    elseif (string.lower(parkingInfo.type) == 'planes' or string.lower(parkingInfo.type) == 'plane') then
        parkingInfo.type = 'planes'
    elseif (string.lower(parkingInfo.type) == 'boats' or string.lower(parkingInfo.type) == 'boat') then
        parkingInfo.type = 'boats'
    else
        parkingInfo.type = 'cars'
    end

    --- Make sure that location has a location
    if (parkingInfo.location ~= nil and type(parkingInfo.location) == 'vector3') then
        parkingInfo.location = parkingInfo.location
    elseif (parkingInfo.location ~= nil and type(parkingInfo.location) == 'table') then
        parkingInfo.location = vector3(
            parkingInfo.location.x or 0.0,
            parkingInfo.location.y or 0.0,
            parkingInfo.location.z or 0.0
        )
    else
        parkingInfo.location = vector3(0.0, 0.0, 0.0)
    end

    --- Make sure that spawn has a location
    if (parkingInfo.spawn ~= nil and type(parkingInfo.spawn) == 'vector3') then
        parkingInfo.spawn = {
            x = parkingInfo.location.x,
            y = parkingInfo.location.y,
            z = parkingInfo.location.z,
            h = 0.0 }
    elseif (parkingInfo.spawn ~= nil and type(parkingInfo.spawn) == 'table') then
        parkingInfo.spawn = {
            x = parkingInfo.spawn.x or 0.0,
            y = parkingInfo.spawn.y or 0.0,
            z = parkingInfo.spawn.z or 0.0,
            h = parkingInfo.spawn.h or 0.0
        }
    else
        parkingInfo.spawn = { x = 0.0, y = 0.0, z = 0.0, h = 0.0 }
    end

    --- Make sure that delete has a location
    if (parkingInfo.delete ~= nil and type(parkingInfo.delete) == 'vector3') then
        parkingInfo.delete = parkingInfo.delete
    elseif (parkingInfo.delete ~= nil and type(parkingInfo.delete) == 'table') then
        parkingInfo.delete = vector3(
            parkingInfo.delete.x or 0.0,
            parkingInfo.delete.y or 0.0,
            parkingInfo.delete.z or 0.0
        )
    else
        parkingInfo.delete = vector3(0.0, 0.0, 0.0)
    end

    parkingInfo.addonInfo = {
        name = parkingName or 'unknown',
        spawn = parkingInfo.spawn or { x = 0.0, y = 0.0, z = 0.0, h = 0.0 },
        delete = parkingInfo.delete or { x = 0.0, y = 0.0, z = 0.0, h = 0.0 }
    }

    parking.locations[parkingName] = parkingInfo
end

local markers = m('markers')

--- Create a marker for each location
for parkingName, parkingInfo in pairs(parking.locations or {}) do
    --- Add spawn marker
    markers:add(('parking.%s.%s'):format('spawn', parkingName),
        ('parking:spawn:%s'):format(parkingInfo.type),
        parking.permissions or { groups = { 'all' }, jobs = { 'all' } },
        Config.Markers[parkingInfo.type]['spawn'].type,
        parkingInfo.location,
        Config.Markers[parkingInfo.type]['spawn'].size,
        Config.Markers[parkingInfo.type]['spawn'].color,
        parkingInfo.addonInfo or {})

    --- Add delete marker
    markers:add(('parking.%s.%s'):format('delete', parkingName),
        ('parking:delete:%s'):format(parkingInfo.type),
        parking.permissions or { groups = { 'all' }, jobs = { 'all' } },
        Config.Markers[parkingInfo.type]['delete'].type,
        parkingInfo.delete,
        Config.Markers[parkingInfo.type]['delete'].size,
        Config.Markers[parkingInfo.type]['delete'].color,
        parkingInfo.addonInfo or {})
end