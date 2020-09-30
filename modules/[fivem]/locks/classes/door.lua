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
function locks:createDoor(doorData)
    local door = class('door')

    door:set {
        name = nil,
        hash = -1,
        heading = 0.000,
        position = nil,
        rotation = nil,
        locked = false,
        resetPosition = false,
        latest = {}
    }

    if (doorData.Name ~= nil and type(doorData.Name) == 'string') then
        door.name = doorData.Name
    end

    if (doorData.Hash ~= nil and type(doorData.Hash) == 'number') then
        door.hash = doorData.Hash or GetHashKey(door.name or 'unknown')
    else
        door.hash = GetHashKey(door.name or 'unknown')
    end

    if (doorData.Heading ~= nil and type(doorData.Heading) == 'number') then
        door.heading = doorData.Heading
    end

    if (doorData.Position ~= nil and type(doorData.Position) == 'vector3') then
        door.position = doorData.Position
    elseif (doorData.Position ~= nil and type(doorData.Position) == 'table') then
        door.position = vector3(doorData.Position.x or 0.0, doorData.Position.y or 0.0, doorData.Position.z or 0.0)
    end

    if (doorData.Rotation ~= nil and type(doorData.Rotation) == 'vector3') then
        door.rotation = doorData.Rotation
    elseif (doorData.Rotation ~= nil and type(doorData.Rotation) == 'table') then
        door.rotation = vector3(doorData.Rotation.x or 0.0, doorData.Rotation.y or 0.0, doorData.Rotation.z or 0.0)
    end

    if (doorData.Locked ~= nil and type(doorData.Locked) == 'boolean') then
        door.locked = doorData.Locked or false
    end

    if (doorData.ResetPosition ~= nil and type(doorData.ResetPosition) == 'boolean') then
        door.resetPosition = doorData.ResetPosition or false
    end

    if (door.name == nil or door.hash == -1 or door.position == nil) then return nil end

    return door
end