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
local resource_parking = class('resource_parking')

resource_parking:set {
    inMarker = false,
    inMarkerEvent = nil,
    currentMenu = nil,
    currentEvent = nil,
    currentMarker = nil,
    currentSelectedVehicle = nil,
    vehicles = {}
}

onMarkerEvent('parking:spawn:cars', function(marker)
    local notifications = m('notifications')

    if (notifications ~= nil and resource_parking.currentEvent == nil) then
        notifications:showHelpNotification(_(CR(), 'parking', 'press_e_to_spawn_vehicle'))
    end

    resource_parking.inMarker = true
    resource_parking.currentMarker = marker
    resource_parking.inMarkerEvent = 'spawn:cars'
end)

onMarkerLeave('parking:spawn:cars', function()
    resource_parking.inMarker = false
    resource_parking.currentMarker = nil
    resource_parking.inMarkerEvent = nil

    if (resource_parking.currentMenu ~= nil and resource_parking.currentMenu.isOpen) then
        resource_parking.currentMenu:close()
    end

    resource_parking.currentMenu = nil
    resource_parking.currentEvent = nil
end)

--- Loop to check if user pressed required key
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if (resource_parking.inMarker and resource_parking.currentEvent == nil) then
            if (IsControlJustPressed(0, 38)) then
                if (resource_parking.inMarkerEvent == 'spawn:cars') then
                    resource_parking:openParkingMenu()
                end

                resource_parking.currentEvent = resource_parking.inMarkerEvent
            end
        elseif (not resource_parking.inMarker and resource_parking.currentMenu ~= nil) then
            resource_parking.currentMenu:close()
            resource_parking.currentMenu = nil
        else
            Citizen.Wait(250)
        end
    end
end)

--- Spawn a vehicle on specified coords
--- @param code string|number Vehicle's spawn name or hash
--- @param vehicleInfo table Information about props etc.
--- @param coords vector3|table Information about cordinates
--- @param heading number direction to headidng vehicle
function resource_parking:spawnVehicle(code, vehicleInfo, coords, heading)
    local done = false
    local game = m('game')
    local vehicleFound, closestVehicle = game:getClosestVehicle(coords, 5.0)

    if (vehicleFound and DoesEntityExist(closestVehicle)) then
        local notifications = m('notifications')

        notifications:showNotification(_(CR(), 'parking', 'vehicle_blocking'))
        return done
    end

    game:spawnVehicle(code, coords, heading, function(vehicle)
        local playerPed = PlayerPedId()

        SetVehicleEngineOn(vehicle, false, true, false)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        if (vehicleInfo ~= nil and type(vehicleInfo) == 'string') then vehicleInfo = json.decode(vehicleInfo) end
        if (vehicleInfo == nil or type(vehicleInfo) ~= 'table' or not vehicleInfo) then vehicleInfo = {} end

        vehicleInfo.plate = resource_parking.currentSelectedVehicle.plate or vehicleInfo.plate or nil

        game:setVehicleProperties(vehicle, vehicleInfo, true)

        done = true
    end)

    repeat Citizen.Wait(0) until done == true

    return done
end