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
local game = class('game')

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

addModule('game', game)