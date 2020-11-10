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
local assert = assert

--- Cache global variables
local corev = assert(corev)
local class = assert(class)
local error = assert(error)
local lower = assert(string.lower)
local insert = assert(table.insert)
local pack = assert(pack or table.pack)
local unpack = assert(unpack or table.unpack)
local CreateThread  = assert(Citizen.CreateThread)

function createMenuItem(menu, itemType)
    if (corev:typeof(menu) ~= 'menu') then
        error(corev:t('menu_invalid_type'):format(corev:typeof(menu)))
        return
    end

    itemType = lower(corev:ensure(itemType, 'unknown'))

    if (itemType == 'unknown') then itemType = 'item' end

    if (itemType ~= 'item' and itemType ~= 'checkbox' and itemType ~= 'list' and itemType ~= 'submenu') then
        error(corev:t('menu_item_invalid_type'))
        return
    end

    --- Create a `menu-item` class
    local item = class "menu-item"

    --- Set default values
    item:set {
        __parent = menu,
        __type = itemType,
        value = nil,
        events = {}
    }

    --- Register a event handler based on this item
    --- @param event string Name of event
    --- @param callback function Callback function to trigger
    function item:on(event, callback)
        event = corev:ensure(event, 'unknown')
        callback = corev:ensure(callback, function() end)

        local eventKey = corev:hashString(event)

        if (self.events[eventKey] == nil) then self.events[eventKey] = {} end

        insert(self.events[eventKey], callback)
    end

    --- Trigger all registerd events parallel
    --- @param event string Name of event
    function item:trigger(event, ...)
        event = corev:ensure(event, 'unknown')

        local eventKey = corev:hashString(event)

        if (self.events[eventKey] == nil) then return end

        local arguments = pack(...)

        for i = 1, #self.events[eventKey], 1 do
            CreateThread(function()
                self.events[eventKey][i](self, unpack(arguments))
            end)
        end
    end

    if (itemType == 'checkbox') then
        --- Returns if item is checked or not
        --- @return boolean `true` if checked, otherwise `false`
        function item:isChecked()
            return corev:ensure(self.value, false)
        end

        --- Update item's value based on given `value`
        --- @param value boolean Set a value
        function item:setValue(value)
            self.value = corev:ensure(value, false)
        end

        --- Returns current value of item
        --- @return boolean `true` if checked, otherwise `false`
        function item:getValue()
            return corev:ensure(self.value, false)
        end
    elseif (itemType == 'item') then
    end
end