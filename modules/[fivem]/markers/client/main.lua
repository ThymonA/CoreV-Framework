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
local markers = class('markers')

--- Default values
markers:set {
    markers = {},
    anyMarkerDrawed = false,
    drawMarkers = {},
    inMarker = false,
    currentMarker = nil,
    lastMarker = nil
}

--- Load markers in > markers.drawMarkers
Citizen.CreateThread(function()
    while true do
        local coords = GetEntityCoords(GetPlayerPed(-1))

        markers.drawMarkers = {}

        for i, marker in pairs(markers.markers or {}) do
            if (marker ~= nil and marker.position ~= nil and #(marker.position - coords) < Config.DrawMarkerDistance) then
                table.insert(markers.drawMarkers, marker)
            end
        end 

        Citizen.Wait(1000)
    end
end)

--- Draw markers from > markers.drawMarkers
Citizen.CreateThread(function()
    while true do
        markers.anyMarkerDrawed = false

        for i, marker in pairs(markers.drawMarkers or {}) do
            markers.anyMarkerDrawed = true

            DrawMarker(
                marker.type,
                marker.position.x,
                marker.position.y,
                marker.position.z,
                0.0, 0.0, 0.0, 0, 0.0, 0.0,
                marker.size.x,
                marker.size.y,
                marker.size.z,
                marker.colors.red,
                marker.colors.green,
                marker.colors.blue,
                100,
                false,
                true,
                2,
                false,
                false,
                false,
                false)
        end

        Citizen.Wait(0)
    end
end)

--- Trigger marker event
Citizen.CreateThread(function()
    while true do
        markers.inMarker = false
        markers.currentMarker = nil

        if (markers.anyMarkerDrawed) then
            local coords = GetEntityCoords(GetPlayerPed(-1))

            for _, marker in pairs(markers.drawMarkers or {}) do
                if (not markers.inMarker and #(marker.position - coords) < marker.size.x) then
                    markers.inMarker = true
                    markers.currentMarker = marker
                    markers.lastMarker = marker

                    triggerOnEvent('marker:enter', marker.event, marker)
                end
            end

            if (markers.currentMarker == nil and markers.lastMarker ~= nil) then
                triggerOnEvent('marker:leave', markers.lastMarker.event, markers.lastMarker)
                markers.lastMarker = nil
            end
        end

        Citizen.Wait(0)
    end
end)

--- Request all markers
Citizen.CreateThread(function()
    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    triggerServerCallback('corev:markers:receive', function(_markers)
        markers.markers = _markers or {}
    end)
end)

onServerTrigger('corev:players:setJob', function(job, grade)
    while not resource.tasks.loadingFramework do
        Wait(0)
    end

    triggerServerCallback('corev:markers:receive', function(_markers)
        markers.markers = _markers or {}
    end)
end)

onServerTrigger('corev:players:setJob2', function(job, grade)
    while not resource.tasks.loadingFramework do
        Wait(0)
    end

    triggerServerCallback('corev:markers:receive', function(_markers)
        markers.markers = _markers or {}
    end)
end)

onFrameworkStarted(function()
    local keybinds = m('keybinds')

    keybinds:registerKey('marker_trigger', _(CR(), 'markers', 'keybind_markers'), 'keyboard', 'e')
end)

addModule('markers', markers)