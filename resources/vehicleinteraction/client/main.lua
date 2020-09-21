onFrameworkStarted(function()
    local wheels, vehicleSelectionWheel, wheelCreated = m('wheels'), nil, false

    onEntityTypeEvent('vehicle', function(entity, coords)
        vehicleSelectionWheel, wheelCreated = wheels:create('interaction', 'vehicle')

        if (wheelCreated) then
            vehicleSelectionWheel:addItem({
                icon = 'fa-lightbulb-on',
                lib = 'far',
                addon = { action = 'light_on' }
            })

            vehicleSelectionWheel:addItem({
                icon = 'fa-lightbulb-slash',
                lib = 'far',
                addon = { action = 'light_off' }
            })

            vehicleSelectionWheel:registerEvent('submit', function(wheel, selectedItem)
                local addon = wheel:getAddon()
                local itemAddon = selectedItem.addon or {}

                if (itemAddon.action == 'light_on') then
                    SetVehicleLights(addon.entity, 2)
                elseif (itemAddon.action == 'light_off') then
                    SetVehicleLights(addon.entity, 1)
                end
            end)
        end

        vehicleSelectionWheel:setAddon({ entity = entity })

        wheels:open('interaction', 'vehicle', true)
    end)
end)