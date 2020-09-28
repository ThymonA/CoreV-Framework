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
    latestMouseState = false,
    showMouse = false,
    lastShowMouseState = false,
    keybinds = m('keybinds'),
    hashList = hashList or m('hashList'),
    flag = Config.EnableCustomFilter == true and 2 or 30,
    flags = {
        [1] = 'self',       --- Player's own entity
        [2] = 'vehicle',    --- Vehicles in world
        [4] = 'ped',        --- Peds in world
        [8] = 'ped',        --- Peds in world
        [16] = 'object',    --- Objects in world
        [32] = 'player'     --- Players in world
    },
    pi = math.pi,
    abs = math.abs,
    cos = math.cos,
    sin = math.sin
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
            coords = nil,
            screenCoords = nil
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


--- Get a vehicles from enumerator and returns a table
--- @param table table Table to add results to (optional)
function raycast:getSelfPlayerPed(table)
    local output, entityType = table or {}, 'self'

    if (output == nil or type(output) ~= 'table') then output = {} end

    local playerPed = PlayerPedId()

    output[tostring(playerPed)] = {
        entity = playerPed,
        type = entityType,
        coords = nil,
        screenCoords = nil
    }

    return output
end

--- Transform position to 2D screen coords
--- @param position vector3|table Position
function raycast:world3dToScreen2D(position)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)

    return onScreen, vector2(screenX, screenY)
end

--- Returns closest entity on screen based on mouse position
--- @param flags number Flags can be found in raycast.flags [1,2,4,8,16,32]
function raycast:screen2dToWorld3D(flags)
    local camRotation = GetGameplayCamRot(0)
    local camPosition = GetGameplayCamCoord()
    local mousePosition = vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
    local camera3dPositon, forwardDirection = self:screenToWorld(camPosition, camRotation, mousePosition)
    local cameraDirection = camPosition + forwardDirection * (Config.RaycastLength or 50.0)
    local raycastHandle = StartShapeTestRay(camera3dPositon, cameraDirection, flags, 0, 0)
    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(raycastHandle)

    if (entityHit ~= nil and entityHit >= 1) then
        return true, endCoords, surfaceNormal, entityHit, GetEntityType(entityHit), cameraDirection
    end

    return false, nil, nil, 0, 0, nil
end

--- Based on current camera position, calculates where mousePosition is poiting at
--- @param camPosition vector3|table Position of camera
--- @param camRotation vector3|table Rotation of camera
--- @param mousePosition vecot2|table Position of mouse
function raycast:screenToWorld(camPosition, camRotation, mousePosition)
    local cameraForward = self:rotateToDirection(camRotation)

    local rotationUp = vector3(camRotation.x + 1.0, camRotation.y, camRotation.z)
    local rotationDown = vector3(camRotation.x - 1.0, camRotation.y, camRotation.z)
    local rotationLeft = vector3(camRotation.x, camRotation.y, camRotation.z - 1.0)
    local rotationRight = vector3(camRotation.x, camRotation.y, camRotation.z + 1.0)

    local cameraRight = self:rotateToDirection(rotationRight) - self:rotateToDirection(rotationLeft)
    local cameraUp = self:rotateToDirection(rotationUp) - self:rotateToDirection(rotationDown)

    local roll = -(camRotation.y * self.pi / 180.0)

    local cameraRightRoll = cameraRight * self.cos(roll) - cameraUp * self.sin(roll)
    local cameraUpRoll = cameraRight * self.sin(roll) + cameraUp * self.cos(roll)

    local point3dZero = camPosition + cameraForward * 1.0
    local point3d = point3dZero + cameraRightRoll + cameraUpRoll

    local _, point2dZero = self:world3dToScreen2D(point3dZero)
    local _, point2D = self:world3dToScreen2D(point3d)

    local scaleX = (mousePosition.x - point2dZero.x) / (point2D.x - point2dZero.x)
    local scaleY = (mousePosition.y - point2dZero.y) / (point2D.y - point2dZero.y)

    local point3d = point3dZero + cameraRightRoll * scaleX + cameraUpRoll * scaleY
    local forwardDirection = cameraForward + cameraRightRoll * scaleX + cameraUpRoll * scaleY

    return point3d, forwardDirection
end

--- Rotate rotation
--- @param rotation vector3|table Position
function raycast:rotateToDirection(rotation)
    local x = rotation.x * self.pi / 180.0
    local z = rotation.z * self.pi / 180.0
    local num = self.abs(self.cos(x))

    return vector3((-self.sin(z) * num), (self.cos(z) * num), self.sin(x))
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

function raycast:enableFlag(flag)
    if (not Config.EnableCustomFilter) then return end
    if (flag == nil or (type(flag) ~= 'number' and type(flag) ~= 'string')) then return end
    if (type(flag) == 'string') then flag = tonumber(flag) end

    if (self:flagExists(flag, self.flag)) then return end

    self.flag = self.flag + flag
end

function raycast:disableFlag(flag)
    if (not Config.EnableCustomFilter) then return end
    if (flag == nil or (type(flag) ~= 'number' and type(flag) ~= 'string')) then return end
    if (type(flag) == 'string') then flag = tonumber(flag) end

    if (not self:flagExists(flag, self.flag)) then return end

    self.flag = self.flag - flag
end

Citizen.CreateThread(function()
    while true do
        if (raycast.keybinds:isControlPressed('raycast_select') and not raycast.showMouse) then
            raycast.showMouse = true
        end

        if (raycast.showMouse ~= raycast.lastShowMouseState) then
            raycast.lastShowMouseState = raycast.showMouse or false

            --- Update NUI Focus state
            nui:setNuiFocus(false, raycast.showMouse, 'raycast')

            --- Update Controls state
            controls:disableControlAction(0, 1, raycast.showMouse, 'raycast')       -- LookLeftRight
            controls:disableControlAction(0, 2, raycast.showMouse, 'raycast')       -- LookUpDown
            controls:disableControlAction(0, 142, raycast.showMouse, 'raycast')     -- MeleeAttackAlternate
            controls:disableControlAction(0, 106, raycast.showMouse, 'raycast')     -- VehicleMouseControlOverride
        end

        if (raycast.showMouse) then
            if (raycast.keybinds:isControlPressed('raycast_click')) then
                raycast.showMouse = false

                local anyEntityFound, entityCoords, surfaceNormal, entityHit, entityType, cameraDirection = raycast:screen2dToWorld3D(raycast.flag)

                if (anyEntityFound) then
                    local entityHash = GetEntityModel(entityHit)
                    local hashFound, hashName = raycast.hashList:getName(entityHash)

                    if (hashFound) then
                        triggerOnEvent('raycast:hash', hashName, entityHit, entityCoords)
                    end

                    triggerOnEvent('raycast:entity', entityHit, entityHit, entityCoords)

                    if (entityType == 1 or entityType == '1') then
                        triggerOnEvent('raycast:type', 'ped', entityHit, entityCoords)
                    elseif (entityType == 2 or entityType == '2') then
                        triggerOnEvent('raycast:type', 'vehicle', entityHit, entityCoords)
                    elseif (entityType == 3 or entityType == '3') then
                        triggerOnEvent('raycast:type', 'object', entityHit, entityCoords)
                    elseif (entityType == 4 or entityType == '4') then
                        triggerOnEvent('raycast:type', 'self', entityHit, entityCoords)
                    elseif (entityType == 5 or entityType == '5') then
                        triggerOnEvent('raycast:type', 'player', entityHit, entityCoords)
                    end
                end
            end
        end

        Citizen.Wait(0)
    end
end)

addModule('raycast', raycast)

onFrameworkStarted(function()
    raycast.keybinds:registerKey('raycast_select', _(CR(), 'raycast', 'keybind_raycast_select'), 'mouse', 'mouse_right')
    raycast.keybinds:registerKey('raycast_click', _(CR(), 'raycast', 'keybind_raycast_click'), 'mouse', 'mouse_left')
end)