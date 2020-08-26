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
local resource_garage = class('resource_garage')

resource_garage:set {
    inMarker = false,
    inMarkerEvent = nil,
    currentMenu = nil,
    currentEvent = nil
}

onMarkerEvent('garage:spawn:cars', function(marker)
    local notifications = m('notifications')

    if (notifications ~= nil and resource_garage.currentEvent == nil) then
        notifications:showHelpNotification(_(CR(), 'garage', 'press_e_to_spawn_vehicle'))
    end

    resource_garage.inMarker = true
    resource_garage.inMarkerEvent = 'spawn:cars'
end)

onMarkerLeave('garage:spawn:cars', function()
    inMarker = false
    inMarkerEvent = nil

    if (resource_garage.currentMenu ~= nil and resource_garage.currentMenu:Visible()) then
        resource_garage.currentMenu:Visible(false)
    end

    resource_garage.currentMenu = nil
    resource_garage.currentEvent = nil
end)

--- Loop to check if user pressed required key
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if (resource_garage.inMarker and resource_garage.currentEvent == nil) then
            if (IsControlJustPressed(0, 38)) then
                if (resource_garage.inMarkerEvent == 'spawn:cars') then
                    resource_garage:openGarageMenu()
                end

                resource_garage.currentEvent = resource_garage.inMarkerEvent
            end
        else
            Citizen.Wait(250)
        end
    end
end)

function resource_garage:openGarageMenu()
    local menus = m('menus')
    
    local menu = menus:create(('%s_garage'):format(CR()), 'spawn_cars', {
        title = _(CR(), 'garage', 'car_garage'),
        subtitle = _(CR(), 'garage', 'garage')
    });

    menu:addItems({
        { prefix = 'MER 512', label = 'Mercedes GLA45', description = 'Dikke Mercedes!' },
        { prefix = 'BMW 512', label = 'BMW M5', description = 'Dikke BMW!' },
        { prefix = 'TOY 512', label = 'Toyota Z4', description = 'Dikke Toyota!' }
    });

    menus:open(('%s_garage'):format(CR()), 'spawn_cars');
end