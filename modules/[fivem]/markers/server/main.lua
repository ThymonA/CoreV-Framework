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
local markers = class('markers')

--- Default values
markers:set {
    markers = {}
}

--- Hex to RGB
--- @param hex string Hex as #FFF or #FFFFFF
function markers:hex2rgb(hex)
    if (hex == nil or type(hex) ~= 'string') then return 255, 255, 255 end
    if (hex:startswith('#')) then hex = hex:gsub('#', '') end

    if (string.len(hex) == 3) then
        return tonumber(('0x%s'):format(hex:sub(1,1))), 
            tonumber(('0x%s'):format(hex:sub(2,2))),
            tonumber(('0x%s'):format(hex:sub(3,3)))
    elseif (string.len(hex) == 6) then
        return tonumber(('0x%s'):format(hex:sub(1,2))), 
            tonumber(('0x%s'):format(hex:sub(3,4))),
            tonumber(('0x%s'):format(hex:sub(5,6)))
    end

    return 255, 255, 255
end

--- Add a marker to global framework
--- @param name string name of marker
--- @param whitelist array whitelist
--- @param mType int marker type
--- @param pos array|vector3|int position of marker
--- @param info array|vector3|int size of marker
--- @param hex string color of marker
function markers:add(name, event, whitelist, mType, pos, info, hex, addon)
    local position = nil
    local size = nil
    local red, green, blue = 255, 255, 255
    
    if (name == nil or type(name) ~= 'string' or name == '' or event == nil or type(event) ~= 'string' or event == '') then
        return
    end

    --- define position as vector3
    if (string.lower(type(pos)) == 'vector3') then
        position = pos
    elseif (type(pos) == 'table') then
        position = vector3((pos.x or 0.0), (pos.y or 0.0), (pos.z or 0.0))
    elseif (type(pos) == 'number') then
        position = vector3((pos or 0.0), (pos or 0.0), (pos or 0.0))
    else
        return
    end

    --- define size as vector3
    if (string.lower(type(info)) == 'vector3') then
        size = info
    elseif (type(info) == 'table') then
        size = vector3((info.x or 0.0), (info.y or 0.0), (info.z or 0.0))
    elseif (type(info) == 'number') then
        size = vector3((info or 0.0), (info or 0.0), (info or 0.0))
    else
        size = vector3(1.5, 1.5, 1.5)
    end

    --- transform hex to rgb color
    red, green, blue = self:hex2rgb(hex)

    --- define marker type
    if (mType == nil or (type(mType) == 'number' and (mType < 0 or mType > 43))) then
        mType = MarkerTypes.MarkerTypeHorizontalSplitArrowCircle or 27
    elseif (type(mType) == 'number') then
        mType = mType
    elseif ((type(mType) == 'string')) then
        local mType = tonumber(mType or '0')

        if ((type(mType) == 'number' and (mType < 0 or mType > 43))) then
            mType = MarkerTypes.MarkerTypeHorizontalSplitArrowCircle or 27
        end
    else
        mType = MarkerTypes.MarkerTypeHorizontalSplitArrowCircle or 27
    end

    --- define marker whitelist
    if (whitelist == nil and type(whitelist) ~= 'table') then
        whitelist = { groups = { 'all' }, jobs = { 'all' } }
    else
        whitelist = { groups = whitelist.groups or {}, jobs = whitelist.jobs or {} }
    end

    --- create marker
    self:createMarker(name, event, whitelist, mType, position, size, {
        red = red,
        green = green,
        blue = blue
    }, (addon or {}))
end

--- Get a list of markers
--- @param source int|string Player
function markers:getPlayerMarkers(source)
    local _markers = {}

    for i, marker in pairs(markers.markers or {}) do
        if (marker:playerAllowed(source)) then
            table.insert(_markers, {
                name = marker.name,
                type = marker.type,
                position = marker.position,
                size = marker.size,
                colors = marker.colors,
                event = marker.event,
                addon = marker.addon or {}
            })
        end
    end

    return _markers
end

--- Trigger when player is connected
onPlayerConnected(function(source, returnSuccess, returnError)
    if (source == nil or type(source) ~= 'number') then returnSuccess() end

    local playerMarkers = markers:getPlayerMarkers(source) or {}

    print(#playerMarkers)

    TCE('corev:markers:receive', source, playerMarkers)

    returnSuccess()
end)

addModule('markers', markers)