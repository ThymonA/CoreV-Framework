----------------------- [ CoreV ] -----------------------
-- ɢɪᴛʜᴜʙ: https://gist.github.com/IllidanS4/9865ed17f60576425369fc1da70259b2
-- ʟɪᴄᴇɴꜱᴇ: MIT License
-- ᴅᴇᴠᴇʟᴏᴘᴇʀ: IllidanS4
-- ᴘʀᴏᴊᴇᴄᴛ: entityiter.lua
-- ᴠᴇʀꜱɪᴏɴ: 14 Jul 2017
-- ᴅᴇꜱᴄʀɪᴘᴛɪᴏɴ: Enumerator for FiveM entities
----------------------- [ CoreV ] -----------------------
local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end

        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)

        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next

        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumerateEntityWithinDistance(entity, coords, maxDistance, entityType)
    if (entityType) then
        if (entityType == 'self') then return true, GetEntityCoords(entity) end

        if coords then
            coords = vector3(coords.x, coords.y, coords.z)
        else
            local playerPed = PlayerPedId()
            coords = GetEntityCoords(playerPed)
        end
    
        local entityCoords = GetEntityCoords(entity)
        local distance = #(coords - entityCoords)
    
        if distance <= maxDistance then
            return true, entityCoords
        end
    
        return false, nil
    else
        if coords then
            coords = vector3(coords.x, coords.y, coords.z)
        else
            local playerPed = PlayerPedId()
            coords = GetEntityCoords(playerPed)
        end
    
        local entityCoords = GetEntityCoords(entity)
        local distance = #(coords - entityCoords)
    
        if distance <= maxDistance then
            return true, entityCoords
        end
    
        return false, nil
    end
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end