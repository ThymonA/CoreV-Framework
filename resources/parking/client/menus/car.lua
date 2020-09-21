--- Open car menu
function resource_parking:openParkingMenu()
    local menus = m('menus')

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
                self:openParkingSpawnMenu(selectedItem, menu)
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

--- Open submenu for parking when selected item
--- @param selectedItem table Selected item from previous menu
--- @param previousMenu menu Previous menu
function resource_parking:openParkingSpawnMenu(selectedItem, previousMenu)
    if (selectedItem and resource_parking.currentMarker ~= nil) then
        local menus = m('menus')
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
                        resource_parking.currentMenu = previousMenu
                        resource_parking.currentEvent = 'spawn:cars'

                        previousMenu:open()
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
end

--- Load vehicles from cache or request all cars from databse
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