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
    markers = {},
    drawMarkers = {},
    inMarker = false
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
        for i, marker in pairs(markers.drawMarkers or {}) do
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

        local coords = GetEntityCoords(GetPlayerPed(-1))

        for i, marker in pairs(markers.drawMarkers or {}) do
            if (#(marker.position - coords) < marker.size.x) then
                triggerMarkerEvent(marker.event, marker)
            end
        end

        Citizen.Wait(0)
    end
end)

onServerTrigger('corev:markers:receive', function(_markers)
    markers.markers = _markers or {}
end)

addModule('markers', markers)