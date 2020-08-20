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
onServerTrigger('corev:game:spawnVehicle', function(vehicle)
    local playerPed = PlayerPedId()
    local playerPedCoords, playerPedHeading = GetEntityCoords(playerPed), GetEntityHeading(playerPed)
    
    game:spawnVehicle(vehicle, playerPedCoords, playerPedHeading, function(vehicle)
        SetVehicleEngineOn(vehicle, true, true, true)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        if (GetVehicleClass(vehicle) == VehicleClasses.Helicopters and GetEntityHeightAboveGround(playerPed) > 10.0) then
            SetHeliBladesFullSpeed(vehicle)
        else
            SetVehicleOnGroundProperly(vehicle)
        end
    end)
end)