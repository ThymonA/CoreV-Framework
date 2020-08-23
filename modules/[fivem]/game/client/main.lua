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
local game = class('game')

--- Returns a list of vehicles in area
--- @coords vector3 coords
--- @maxDistance int max distance between coords and vehicle
function game:getVehiclesInArea(coords, maxDistance)
    local vehicles = {}

    for vehicle in EnumerateVehicles() do
        if DoesEntityExist(vehicle) and #(coords - GetEntityCoords(vehicle)) <= maxDistance then
            table.insert(vehicles, vehicle)
        end
    end

    return vehicles
end

--- Spawn a vehicle at specified coords
--- @moduleName string Hash|string Vehicle hash or name
--- @coords vector3|table Coords where vehicle needs to be spawned
--- @heading int vehicle's heading
--- @cb function vehicle callback
function game:spawnVehicle(moduleName, coords, heading, cb)
    local model = moduleName

    if (moduleName == nil or (type(moduleName) ~= 'number' and type(moduleName) ~= 'string')) then return end
    if (type(moduleName) == 'string') then model = GetHashKey(moduleName) end

    Citizen.CreateThread(function()
        local streaming = m('streaming')

        streaming:requestModel(model, function()
            local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z + 1.0, heading, true, false)
            local timeout = 0

            SetVehicleNeedsToBeHotwired(vehicle, false)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleIsStolen(vehicle, false)
            SetVehicleIsWanted(vehicle, false)
            SetVehRadioStation(vehicle, 'OFF')
            
            if (cb ~= nil and type(cb) == 'function') then
                cb(vehicle)
            end
        end)
    end)
end

--- Delete specified vehicle
--- @vehicle vehicle object
function game:deleteVehicle(vehicle)
    if (vehicle ~= nil) then
        if (IsVehiclePreviouslyOwnedByPlayer(vehicle)) then
            SetVehicleHasBeenOwnedByPlayer(vehicle, false)
        end

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    end
end

addModule('game', game)