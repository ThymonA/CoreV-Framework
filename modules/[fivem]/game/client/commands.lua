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

onServerTrigger('corev:game:deleteVehicle', function(radius)
    local vehicle, attempt = nil, 0
    local playerPed = PlayerPedId()
    
    Citizen.CreateThread(function()
        if (IsPedInAnyVehicle(playerPed, true)) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
    
            while (not NetworkHasControlOfEntity(vehicle) and attempt < 50 and DoesEntityExist(vehicle)) do
                Citizen.Wait(200)
    
                NetworkRequestControlOfEntity(vehicle)
    
                attempt = attempt + 1
            end
    
            if (DoesEntityExist(vehicle)) then
                game:deleteVehicle(vehicle)
            end
        end
    
        if (radius ~= nil and type(radius) == 'number' and radius > 0) then
            radius = radius + 0.01
    
            local vehicles = game:getVehiclesInArea(GetEntityCoords(playerPed), radius)
    
            for i, _vehicle in pairs(vehicles or {}) do
                attempt = 0
    
                while (not NetworkHasControlOfEntity(_vehicle) and attempt < 50 and DoesEntityExist(_vehicle)) do
                    Citizen.Wait(200)
        
                    NetworkRequestControlOfEntity(_vehicle)
        
                    attempt = attempt + 1
                end
    
                if (DoesEntityExist(_vehicle)) then
                    game:deleteVehicle(_vehicle)
                end
            end
        end
    end)
end)