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
local raycast = class('raycast')

-- Set default values
raycast:set {
}

--- Transform a enumerator to a table
--- @param enumerator function Enumerator
--- @param entityType string Entity type
--- @param table table Table (optional)
function raycast:toTable(enumerator, entityType, table)
    local output = table or {}

    if (output == nil or type(output) ~= 'table') then output = {} end
    if (entityType == nil or type(entityType) ~= 'string') then entityType = 'unknown' end

    for entity in enumerator() do
        output[tostring(entity)] = {
            entity = entity,
            type = entityType,
            coords = nil
        }
    end

    return output
end

--- Get a objects from enumerator and returns a table
--- @param table table Table to add results to (optional)
function raycast:getObjects(table)
    return self:toTable(EnumerateObjects, 'object', table)
end

--- Get a peds from enumerator and returns a table
--- @param table table Table to add results to (optional)
function raycast:getPeds(table)
    return self:toTable(EnumeratePeds, 'ped', table)
end

--- Get a vehicles from enumerator and returns a table
--- @param table table Table to add results to (optional)
function raycast:getVehicles(table)
    return self:toTable(EnumerateVehicles, 'vehicle', table)
end

--- Removes y from x flag
--- @param x number Flag
--- @param y number Flag to remove
function raycast:xor(x, y)
    local z = 0

    for i = 0, 31 do
        if (x % 2 == 0) then
            if ( y % 2 == 1) then
                y = y - 1
                z = z + 2 ^ i
            end
        else
            x = x - 1

            if (y % 2 == 0) then
                z = z + 2 ^ i
            else
                y = y - 1
            end
        end

        y = y / 2
        x = x / 2
    end

    return z
end

--- Checks if flagType exists in flag
--- @param flagType number Flag type like: 1,2,4,8,16,32...
--- @param flag number Flag like 3,5,6,7,9,10....
function raycast:flagExists(flagType, flag)
    if (flagType == nil or type(flagType) ~= 'number') then return false end
    if (flag == nil or type(flag) ~= 'number') then return false end

    local result = self:xor(flag, flagType)

    return flag - result == flagType
end

--- Returns all world vehicles, peds and objects based on given flag
--- @param flag number Flag
function raycast:getAllWordEntities(flag)
    if (flag == nil or type(flag) ~= 'number') then flag = 30 end

    local worldEntities = {}

    if (self:flagExists(2, flag)) then
        worldEntities = self:getVehicles(worldEntities)
    elseif (self:flagExists(4, flag) or self:flagExists(8, flag)) then
        worldEntities = self:getPeds(worldEntities)
    elseif (self:flagExists(16, flag)) then
        worldEntities = self:getObjects(worldEntities)
    end

    return worldEntities
end

--- Returns the clostest entity on screen based on camera location and max distance to search for
--- @param distance number Max distance from camera
--- @param flag number Flag to search entities for
function raycast:GetEntitiesOnScreen(distance, flag)
    if (flag == nil or type(flag) ~= 'number') then flag = 30 end
    if (distance == nil or type(distance) ~= 'number') then distance = 10 end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local anyEntityFound, entitiesInSide = false, {}

    for k, entityInfo in pairs(self:getAllWordEntities(flag)) do
        local entityInDistance, entityCoords = EnumerateEntityWithinDistance(entityInfo.entity, playerCoords, 4)

        if (entityInDistance) then
            local onScreen = GetScreenCoordFromWorldCoord(entityCoords.x, entityCoords.y, entityCoords.z)

            if (onScreen) then
                anyEntityFound = true

                entityInfo.coords = entityCoords

                entitiesInSide[k] = entityInfo
            end
        end
    end

    return anyEntityFound, entitiesInSide
end

--- Thread to look for entities on screen
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(250)

        local playerPed = PlayerPedId()

        if (not IsPedInAnyVehicle(playerPed)) then
            local anyEntityFound, entities = raycast:GetEntitiesOnScreen(10.0, 2)

            if (anyEntityFound) then
                for _, entity in pairs(entities or {}) do
                    if (entity.type == 'vehicle') then
                        print(GetVehicleNumberPlateText(entity.entity))
                    end
                end
            end
        end
    end
end)