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

--- Create a marker object
--- @param name string Marker name
--- @param event string Marker event
--- @param whitelist array Whitelist
--- @param markerType int Marker type
--- @param position vector3 Marker position
--- @param size vector3 Marker size
--- @param colors array Marker colors
function markers:createMarker(name, event, whitelist, markerType, position, size, colors)
    local marker = class('marker')

    marker:set {
        name = name,
        whitelist = whitelist,
        type = markerType,
        position = position,
        size = size,
        colors = colors,
        event = event
    }

    if (markers.markers ~= nil and markers.markers[name] ~= nil) then
        error:print(_(CR(), 'markers', 'override_marker', name))

        for i, group in pairs((markers.markers[name].whitelist or {}).groups or {}) do
            if (string.lower(group) == 'all') then
                for _i, _group in pairs(Config.PermissionGroups or {}) do
                    ExecuteCommand(('remove_ace group.%s "marker.%s" allow'):format(_group, name))
                end
            else
                ExecuteCommand(('remove_ace group.%s "marker.%s" allow'):format(group, name))
            end
        end
    end

    for i, group in pairs((marker.whitelist or {}).groups or {}) do
        if (type(group) == 'string' and group ~= '') then
            if (string.lower(group) == 'all') then
                for _i, _group in pairs(Config.PermissionGroups or {}) do
                    ExecuteCommand(('add_ace group.%s "marker.%s" allow'):format(_group, name))
                end
            else
                ExecuteCommand(('add_ace group.%s  "marker.%s" allow'):format(group, name))
            end
        end
    end

    --- Check if player is allowed to see marker
    --- @param source int player source
    function marker:playerAllowed(source)
        if (source == nil or type(source) ~= 'number') then
            return false
        end

        local aceAllowed = IsPlayerAceAllowed(source, ('marker.%s'):format(self.name))

        if (aceAllowed == true or aceAllowed == 1) then return true end

        local players = m('players')
        local player = players:getPlayer(source)

        if (player == nil) then return false end

        for i, job in pairs((markers.markers[name].jobs or {}).groups or {}) do
            if (job ~= nil and type(job) == 'string') then
                return string.lower(job) == string.lower(player.job.name) or string.lower(job) == string.lower(player.job2.name)
            elseif (job ~= nil and type(job) == 'table') then
                if (job.name ~= nil and type(job) == 'string') then
                    if (string.lower(job.name) == string.lower(player.job.name)) then
                        for _i, _grade in pairs(job.grades or {}) do
                            if (_grade ~= nil and type(_grade) == 'string' and string.lower(_grade) == string.lower(player.grade.name)) then
                                return true
                            elseif (_grade ~= nil and type(_grade) == 'number' and _grade == player.grade.grade) then
                                return true
                            end
                        end
                    elseif (string.lower(job.name) == string.lower(player.job2.name)) then
                        for _i, _grade in pairs(job.grades or {}) do
                            if (_grade ~= nil and type(_grade) == 'string' and string.lower(_grade) == string.lower(player.grade2.name)) then
                                return true
                            elseif (_grade ~= nil and type(_grade) == 'number' and _grade == player.grade2.grade) then
                                return true
                            end
                        end
                    end
                end
            end
        end

        return false
    end

    --- Returns marker position
    function marker:getPosition()
        return self.position or vector3(0.0, 0.0, 0.0)
    end

    --- Store marker
    markers.markers[marker.name] = marker

    return marker
end