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
        else
            Citizen.Wait(250)
        end
    end
end)

--- Open cars 
function resource_parking:openParkingMenu()    
    local menu, isNew = menus:create(('%s_parking'):format(CR()), 'spawn_cars', {
        title = _(CR(), 'parking', 'parking'),
        subtitle = _(CR(), 'parking', 'car_parking')
    })

    if (menu) then    
        if (isNew) then
            menu:registerEvent('open', function(_menu)
                resource_parking.currentMenu = _menu
            end)
            
            menu:registerEvent('close', function()
                resource_parking.currentMenu = nil
                resource_parking.currentEvent = nil
            end)
    
            menu:registerEvent('submit', function(menu, selectedItem, menuInfo)
                if (selectedItem and resource_parking.currentMarker ~= nil) then
                    print(json.encode(resource_parking.currentMarker.addon))
                end
            end)
        end

        menu:clearItems()

        local vehicles = self:loadCars()

        repeat Wait(0) until vehicles ~= nil

        for brand, brandVehicles in pairs(vehicles or {}) do
            local brandInfo = Config.Brands[brand] or {}

            menu:addItem({ prefix = #brandVehicles, label = brandInfo.label, description = _(CR(), 'parking', 'brand_description', #brandVehicles, brandInfo.label), image = brandInfo.logos.square_small })
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