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

--- Open cars 
function resource_parking:openParkingMenu()    
    local menu, isNew = menus:create(('%s_parking'):format(CR()), 'spawn_cars', {
        title = _(CR(), 'parking', 'parking'),
        subtitle = _(CR(), 'parking', 'select_category')
    })

    if (menu) then
        if (isNew) then
            menu:registerEvent('open', function(_menu)
                resource_parking.currentMenu = _menu
                resource_parking.currentEvent = 'spawn:cars'
            end)

            menu:registerEvent('close', function()
                resource_parking.currentMenu = nil
                resource_parking.currentEvent = nil
            end)

            menu:registerEvent('submit', function(menu, selectedItem, menuInfo)
                if (selectedItem and resource_parking.currentMarker ~= nil) then
                    local selectedBrand = Config.Brands[selectedItem.addon.brand] or {}
                    local selectVehicleMenu, selectVehicleNew = menus:create(('%s_parking_select_%s'):format(CR(), selectedBrand.brand), 'select_spawn_cars', {
                        title = _(CR(), 'parking', 'parking'),
                        subtitle = _(CR(), 'parking', 'select_vehicle', selectedBrand.label)
                    })

                    if (selectVehicleMenu) then
                        if (selectVehicleNew) then
                            selectVehicleMenu:registerEvent('open', function(_menu)
                                resource_parking.currentMenu = _menu
                                resource_parking.currentEvent = 'spawn:cars'
                            end)

                            selectVehicleMenu:registerEvent('close', function()
                                if (resource_parking.currentSelectedVehicle ~= nil) then
                                    resource_parking.currentMenu = nil
                                    resource_parking.currentEvent = nil
                                else
                                    resource_parking.currentMenu = menu
                                    resource_parking.currentEvent = 'spawn:cars'

                                    menu:open()
                                end
                            end)

                            selectVehicleMenu:registerEvent('submit', function(menu, selectedItem, menuInfo)
                                if (selectedItem and resource_parking.currentMarker ~= nil) then
                                    resource_parking.currentSelectedVehicle = selectedItem.addon

                                    menu:close()

                                    local spawn = ((self.currentMarker or {}).addon or {}).spawn

                                    if (spawn) then
                                        local selectedVehicle = resource_parking.currentSelectedVehicle
                                        local vehicleSpawned = self:spawnVehicle(selectedVehicle.code, selectedVehicle.vehicle, spawn, spawn.h)

                                        repeat Citizen.Wait(0) until vehicleSpawned == true or vehicleSpawned == false

                                        resource_parking.currentSelectedVehicle = nil

                                        if (not vehicleSpawned) then
                                            menu:open()
                                        end
                                    else
                                        local notifications = m('notifications')

                                        notifications:showNotification(_(CR(), 'parking', 'spawn_not_available'))
                                        menu:open()
                                    end
                                end
                            end)
                        end

                        selectVehicleMenu:clearItems()

                        local vehicles = self:loadCars()

                        repeat Wait(0) until vehicles ~= nil

                        local categoryVehicles = vehicles[selectedBrand.brand]

                        for _, categoryVehicle in pairs(categoryVehicles or {}) do
                            local currentVehicle = Config.Vehicles[categoryVehicle.name] or {}

                            selectVehicleMenu:addItem({ prefix = categoryVehicle.plate, label = currentVehicle.label, description = '', addon = categoryVehicle })
                        end

                        selectVehicleMenu:open()
                    end
                end
            end)
        end

        menu:clearItems()

        local vehicles = self:loadCars()

        repeat Wait(0) until vehicles ~= nil

        for brand, brandVehicles in pairs(vehicles or {}) do
            local brandInfo = Config.Brands[brand] or {}

            menu:addItem({ prefix = #brandVehicles, label = brandInfo.label, description = _(CR(), 'parking', 'brand_description', #brandVehicles, brandInfo.label), image = brandInfo.logos.square_small, addon = brandInfo })
        end

        menu:open()
    end
end

--- Load vehicles from cache or request all vehicles from databse
function resource_parking:loadCars()
    if (self.vehicles ~= nil and self.vehicles['cars'] ~= nil) then
        return self.vehicles['cars']
    end

    triggerServerCallback('corev:parking:loadCars', function(vehicles)
        local cars = {}

        for _, vehicle in pairs(vehicles or {}) do
            local vehicleInfo = Config.Vehicles[vehicle.name] or {}

            if (cars == nil) then cars = {} end
            if (cars[vehicleInfo.brand] == nil) then cars[vehicleInfo.brand] = {} end

            table.insert(cars[vehicleInfo.brand], {
                plate = vehicle.plate,
                code = vehicle.name,
                vehicle = vehicle.vehicle,
                status = vehicle.status,
                price = vehicle.price,
                name = vehicle.name,
                label = vehicle.label,
                brand = Config.Brands[vehicleInfo.brand],
                type = vehicleInfo.type
            })
        end

        self.vehicles['cars'] = cars
    end)

    repeat Citizen.Wait(0) until self.vehicles['cars'] ~= nil

    return self.vehicles['cars']
end

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