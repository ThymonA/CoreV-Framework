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
    if (coords == nil) then coords = GetEntityCoords(PlayerPedId()) end
    if (type(coords) == 'table') then coords = vector3(coords.x, coords.y, coords.z) end
    if (type(coords) ~= 'vector3') then return {} end

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
--- @param vehicle table Vehicle object
function game:deleteVehicle(vehicle)
    if (vehicle ~= nil) then
        if (IsVehiclePreviouslyOwnedByPlayer(vehicle)) then
            SetVehicleHasBeenOwnedByPlayer(vehicle, false)
        end

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    end
end

--- Returns closest vehicle in a given distance
--- @param coords vector3|table|nil Information about coordinates
--- @param maxDistance number Max distance to search for
function game:getClosestVehicle(coords, maxDistance)
    maxDistance = maxDistance or 10.0

    if (type(maxDistance) == 'string') then maxDistance = tonumber(maxDistance) end
    if (type(maxDistance) ~= 'number') then maxDistance = 10.0 end
    if (coords == nil or (type(coords) ~= 'table' and type(coords) ~= 'vector3')) then coords = GetEntityCoords(PlayerPedId()) end

    local entities = self:getVehiclesInArea(coords, maxDistance)

    return self:getClosestEntity(entities, false, coords)
end

--- Returns the closest entity from given entities
--- @param entities table List of entities
--- @param isPlayerEntities boolean List are player entities
--- @param coords vector3|table|nil Information about coordinates
--- @param modelFilter table List of entity to filter on
function game:getClosestEntity(entities, isPlayerEntities, coords, modelFilter)
    local entityFound, closestEntity, closestEntityDistance, filteredEntities = false, -1, -1, nil

    if (coords == nil) then coords = GetEntityCoords(PlayerPedId()) end
    if (type(coords) == 'table') then coords = vector3(coords.x, coords.y, coords.z) end
    if (type(coords) ~= 'vector3') then coords = GetEntityCoords(PlayerPedId()) end

    if (modelFilter) then
        filteredEntities = {}

        for _, entity in pairs(entities or {}) do
            if (modelFilter[GetEntityModel(entity)]) then
                table.insert(filteredEntities, entity)
            end
        end
    end

    for i, entity in pairs(filteredEntities or entities or {}) do
        local distance = #(coords - GetEntityCoords(entity))

        if (closestEntityDistance == -1 or distance < closestEntityDistance) then
            entityFound, closestEntity, closestEntityDistance = true, isPlayerEntities and i or entity, distance
        end
    end

    return entityFound, closestEntity, closestEntityDistance
end

--- Returns a object with all vehicle properties
--- @param vehicle any Vehicle object
--- @param ignoreDefaultOrNull boolean|number Ignore if empty, null or default
--- @param ignoreModel boolean|number Ignore model when returning results
--- @param ignorePlate boolean|number Ignore license plate when returning results
--- @param ignoreStatus boolean|number Ignore vehicle health and fuel
function game:getVehicleProperties(vehicle, ignoreDefaultOrNull, ignoreModel, ignorePlate, ignoreStatus)
    ignoreDefaultOrNull = ignoreDefaultOrNull or false

    --- Make sure that all parameters has been set
    if (ignoreDefaultOrNull == nil) then ignoreDefaultOrNull = false end
    if (ignoreModel == nil) then ignoreModel = false end
    if (ignorePlate == nil) then ignorePlate = false end
    if (ignoreStatus == nil) then ignoreStatus = false end
    if (type(ignoreDefaultOrNull) ~= 'boolean') then ignoreDefaultOrNull = tonumber(ignoreDefaultOrNull) end
    if (type(ignoreModel) ~= 'boolean') then ignoreModel = tonumber(ignoreModel) end
    if (type(ignorePlate) ~= 'boolean') then ignorePlate = tonumber(ignorePlate) end
    if (type(ignoreStatus) ~= 'boolean') then ignoreStatus = tonumber(ignoreStatus) end
    if (type(ignoreDefaultOrNull) == 'number') then ignoreDefaultOrNull = ignoreDefaultOrNull == 1 end
    if (type(ignoreModel) == 'number') then ignoreModel = ignoreModel == 1 end
    if (type(ignorePlate) == 'number') then ignorePlate = ignorePlate == 1 end
    if (type(ignoreStatus) == 'number') then ignoreStatus = ignoreStatus == 1 end

    if (vehicle ~= nil and DoesEntityExist(vehicle)) then
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

        local results = {
            ['colors'] = {
                ['primary'] = colorPrimary,
                ['secondary'] = colorSecondary,
                ['pearlescent'] = pearlescentColor,
                ['wheel'] = wheelColor
            }
        }
        local vehicleExtras = {}
        local vehicleNeonEnabled = {}

        --- Load all vehicle's extra's
        for extra = 0, 14, 1 do
            if (DoesExtraExist(vehicle, extra) and IsVehicleExtraTurnedOn(vehicle, extra) == 1) then
                table.insert(vehicleExtras, extra)
            end
        end

        --- Set neon lights of vehicle entity
        for neon = 0, 3, 1 do
            local neonEnabled = IsVehicleNeonLightEnabled(vehicle, neon) == 1

            if (neonEnabled) then
                table.insert(vehicleNeonEnabled, neon)
            end
        end

        --- Set all mod type values of vehicle entity
        for name, modIndex in pairs(VehicleModType or {}) do
            local modValue = GetVehicleMod(vehicle, modIndex)
            local modKey = ('mod%s'):format(name)

            if ((not ignoreDefaultOrNull or modValue >= 0) and modIndex ~= VehicleModType.Livery) then
                results[modKey] = modValue
            end
        end

        --- Set all toggable options of vehicle entity
        for name, modIndex in pairs(VehicleToggleModType or {}) do
            local modValue = IsToggleModOn(vehicle, modIndex)
            local modKey = ('mod%s'):format(name)

            if (not ignoreDefaultOrNull or modValue) then
                results[modKey] = modValue
            end
        end

        if (not ignoreModel) then results['model'] = GetEntityModel(vehicle) end
        if (not ignorePlate) then results['plate'] = GetVehicleNumberPlateText(vehicle) end

        if (not ignoreStatus) then
            local bodyHealth = round(GetVehicleBodyHealth(vehicle), 1)
            local engineHealth = round(GetVehicleEngineHealth(vehicle), 1)
            local tankHealth = round(GetVehiclePetrolTankHealth(vehicle), 1)
            local fuelLevel = round(GetVehicleFuelLevel(vehicle), 1)
            local dirtLevel = round(GetVehicleDirtLevel(vehicle), 1)

            if (not ignoreDefaultOrNull or bodyHealth <= 950) then results['bodyHealth'] = bodyHealth end
            if (not ignoreDefaultOrNull or engineHealth <= 950) then results['engineHealth'] = engineHealth end
            if (not ignoreDefaultOrNull or tankHealth <= 950) then results['tankHealth'] = tankHealth end
            if (not ignoreDefaultOrNull or fuelLevel <= 950) then results['fuelLevel'] = fuelLevel end
            if (not ignoreDefaultOrNull or dirtLevel >= 1) then results['dirtLevel'] = dirtLevel end
        end

        if (not ignoreDefaultOrNull or #vehicleExtras > 0) then results['extras'] = vehicleExtras end
        if (not ignoreDefaultOrNull or #vehicleNeonEnabled > 0) then results['neonEnabled'] = vehicleNeonEnabled end

        local plateIndex = GetVehicleNumberPlateTextIndex(vehicle)
        local windowTint = GetVehicleWindowTint(vehicle)
        local xenonColor = GetVehicleXenonLightsColour(vehicle)
        local livery = GetVehicleLivery(vehicle)

        if (not ignoreDefaultOrNull or plateIndex > 0) then results['plateIndex'] = plateIndex end
        if (not ignoreDefaultOrNull or (windowTint > 0 and windowTint ~= 4)) then results['windowTint'] = windowTint end
        if (not ignoreDefaultOrNull or (xenonColor >= 0 and xenonColor ~= 255)) then results['colors']['xenon'] = xenonColor end
        if (not ignoreDefaultOrNull or (#vehicleNeonEnabled > 0)) then results['colors']['neon'] = table.pack(GetVehicleNeonLightsColour(vehicle)) end
        if (not ignoreDefaultOrNull or IsToggleModOn(vehicle, VehicleToggleModType.TireSmoke)) then results['colors']['tyreSmoke'] = table.pack(GetVehicleTyreSmokeColor(vehicle)) end
        if (not ignoreDefaultOrNull or livery > 0) then results['modLivery'] = livery end

        results['wheels'] = GetVehicleWheelType(vehicle)

        return results
    end
end

--- Apply props to given vehicle
--- @param vehicle any Vehicle object
--- @param props table Vehicle properties
--- @param setNullToDefault boolean|number When prop don't exists in props set default value
function game:setVehicleProperties(vehicle, props, setNullToDefault)
    if (setNullToDefault == nil) then setNullToDefault = false end
    if (type(setNullToDefault) ~= 'boolean') then setNullToDefault = tonumber(setNullToDefault) end
    if (type(setNullToDefault) == 'number') then setNullToDefault = setNullToDefault == 1 end
    if (type(props) ~= 'table') then props = nil end
    if (not setNullToDefault and props == nil) then return end
    if (props == nil) then props = {} end

    if (vehicle == nil or not DoesEntityExist(vehicle)) then
        return
    end

    SetVehicleModKit(vehicle, 0)

    local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

    if ((props.plateIndex == nil or not props.plateIndex) and setNullToDefault) then props.plateIndex = 0 end
    if ((props.bodyHealth == nil or not props.bodyHealth) and setNullToDefault) then props.bodyHealth = 1000 end
    if ((props.engineHealth == nil or not props.engineHealth) and setNullToDefault) then props.engineHealth = 1000 end
    if ((props.tankHealth == nil or not props.tankHealth) and setNullToDefault) then props.tankHealth = 1000 end
    if ((props.fuelLevel == nil or not props.fuelLevel) and setNullToDefault) then props.fuelLevel = 1000 end
    if ((props.dirtLevel == nil or not props.dirtLevel) and setNullToDefault) then props.dirtLevel = 0 end
    if ((props.windowTint == nil or not props.windowTint) and setNullToDefault) then props.windowTint = 4 end
    if (props.colors == nil or not props.colors) then props.colors = {} end
    if ((props.colors.xenon == nil or not props.colors.xenon) and setNullToDefault) then props.colors.xenon = -1 end

    if ((props.extras == nil or not props.extras) and setNullToDefault) then
        props.extras = { [0] = false, [1] = false, [2] = false, [3] = false, [4] = false, [5] = false, [6] = false, [7] = false, [8] = false, [9] = false, [10] = false, [11] = false, [12] = false, [13] = false, [14] = false }
    elseif(props.extras ~= nil and props.extras) then
        local extras = {}

        for _, index in pairs(props.extras or {}) do
            extras[index] = true
        end

        props.extras = extras
    else
        props.extras = {}
    end

    if ((props.neonEnabled == nil or not props.neonEnabled) and setNullToDefault) then
        props.neonEnabled = { [0] = false, [1] = false, [2] = false, [3] = false }
    elseif(props.neonEnabled ~= nil and props.neonEnabled) then
        local neonEnabled = {}

        for _, index in pairs(props.neonEnabled or {}) do
            neonEnabled[index] = true
        end

        props.neonEnabled = neonEnabled
    else
        props.neonEnabled = {}
    end

    if (props.plate ~= nil and props.plate) then SetVehicleNumberPlateText(vehicle, props.plate) end
    if (props.plateIndex ~= nil and props.plateIndex) then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if (props.bodyHealth ~= nil and props.bodyHealth) then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if (props.engineHealth ~= nil and props.engineHealth) then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if (props.tankHealth ~= nil and props.tankHealth) then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
    if (props.fuelLevel ~= nil and props.fuelLevel) then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if (props.dirtLevel ~= nil and props.dirtLevel) then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end

    if ((props.colors.primary ~= nil and props.colors.primary) or (props.colors.secondary ~= nil and props.colors.secondary)) then
        SetVehicleColours(vehicle, props.colors.primary or colorPrimary, props.colors.secondary or colorSecondary)
    end

    if ((props.colors.pearlescent ~= nil and props.colors.pearlescent) or (props.colors.wheel ~= nil and props.colors.wheel)) then
        SetVehicleExtraColours(vehicle, props.colors.pearlescent or pearlescentColor, props.colors.wheel or wheelColor)
    end

    if (props.colors.neon ~= nil and props.colors.neon) then
        SetVehicleNeonLightsColour(vehicle, props.colors.neon[1] or 255, props.colors.neon[2] or 255, props.colors.neon[3] or 255)
    end

    if (props.colors.tyreSmoke ~= nil and props.colors.tyreSmoke) then
        SetVehicleTyreSmokeColor(vehicle, props.colors.tyreSmoke[1] or 255, props.colors.tyreSmoke[2] or 255, props.colors.tyreSmoke[3] or 255)
    end

    if (props.colors.xenon ~= nil and props.colors.xenon) then SetVehicleXenonLightsColour(vehicle, props.colors.xenon) end
    if (props.wheels ~= nil and props.wheels) then SetVehicleWheelType(vehicle, props.wheels) end
    if (props.windowTint ~= nil and props.windowTint) then SetVehicleWindowTint(vehicle, props.windowTint) end

    -- Enable or disbale neon's
    for i = 0, 3, 1 do
        if (props.neonEnabled[i]) then
            SetVehicleNeonLightEnabled(vehicle, i, true)
        elseif (setNullToDefault) then
            SetVehicleNeonLightEnabled(vehicle, i, false)
        end
    end

    -- Enable or disable extra's
    for i = 0, 14, 1 do
        local extraExits = DoesExtraExist(vehicle, i)

        if (extraExits and props.extras[i]) then
            SetVehicleExtra(vehicle, i, false)
        elseif (extraExits and setNullToDefault) then
            SetVehicleExtra(vehicle, i, true)
        end
    end

    --- Set all mod type values of vehicle entity
    for name, modIndex in pairs(VehicleModType or {}) do
        local modKey = ('mod%s'):format(name)

        if ((props[modKey] == nil or not props[modKey]) and setNullToDefault) then props[modKey] = -1 end

        if (props[modKey] ~= nil and props[modKey]) then
            SetVehicleMod(vehicle, modIndex, props[modKey], false)

            if (modIndex == VehicleModType.Livery) then
                if (props[modKey] == -1) then props[modKey] = 0 end

                SetVehicleLivery(vehicle, props[modKey])
            end
        end
    end

    --- Set all mod type values of vehicle entity
    for name, modIndex in pairs(VehicleToggleModType or {}) do
        local modKey = ('mod%s'):format(name)

        if (props[modKey] == nil and setNullToDefault) then props[modKey] = false end
        if (props[modKey] ~= nil) then ToggleVehicleMod(vehicle, modIndex, props[modKey]) end
    end
end

addModule("game", game)