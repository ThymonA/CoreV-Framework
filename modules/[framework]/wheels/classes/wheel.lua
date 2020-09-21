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
function wheels:createWheel(namespace, name)
    local wheel = class('wheel')

    wheel:set {
        namespace = namespace,
        name = name,
        items = {},
        addon = {},
        events = {
            latest = '',
            open = {},
            close = {},
            submit = {}
        },
        isOpen = false
    }

    --- Register a callback and will be triggerd when event has been execute
    --- @param name string Event name
    --- @param cb function Callback function
    function wheel:registerEvent(name, cb)
        if (name == nil or type(name) ~= 'string') then return end
        if (cb == nil or type(cb) ~= 'function') then return end

        name = string.lower(name)

        if (name == 'open') then
            table.insert(self.events.open, cb)
        elseif (name == 'close') then
            table.insert(self.events.close, cb)
        elseif (name == 'submit') then
            table.insert(self.events.submit, cb)
        end
    end

    --- Trigger a callback function when event has been triggerd
    --- @param name string Event name
    --- @params ... any[] Parameters
    function wheel:triggerEvents(name, ...)
        if (name == nil or type(name) ~= 'string') then return end

        name = string.lower(name)

        if (name == 'open' and self.events.latest ~= 'open') then
            self.events.latest = 'open'
            self:triggerOpenEvents(...)
        elseif (name == 'close' and self.events.latest ~= 'close') then
            self.events.latest = 'close'
            self:triggerCloseEvents(...)
        elseif (name == 'submit') then
            self.events.latest = 'submit'
            self:triggerSubmitEvents(...)
        end
    end

    --- Trigger all open event callbacks
    --- @param wheel wheel Wheel that has been triggerd
    --- @param data table Information about trigger
    function wheel:triggerOpenEvents(wheel, data)
        for _, event in pairs(self.events.open or {}) do
            if (event ~= nil and type(event) == 'function') then
                try(function()
                    event(self, data)
                end, function(e)
                    error:print(e)
                end)
            end
        end
    end

    --- Trigger all change event callbacks
    --- @param wheel wheel Wheel that has been triggerd
    --- @param data table Information about trigger
    function wheel:triggerCloseEvents(wheel, data)
        for _, event in pairs(self.events.close or {}) do
            if (event ~= nil and type(event) == 'function') then
                try(function()
                    event(self, data)
                end, function(e)
                    error:print(e)
                end)
            end
        end
    end

    --- Trigger all submit callbacks
    --- @param wheel wheel Wheel that has been triggerd
    --- @param data table Information about trigger
    function wheel:triggerSubmitEvents(wheel, selectedItem)
        for _, event in pairs(self.events.submit or {}) do
            if (event ~= nil and type(event) == 'function') then
                try(function()
                    event(self, selectedItem)
                end, function(e)
                    error:print(e)
                end)
            end
        end
    end

    --- Return current wheel data as object
    function wheel:getData()
        return {
            items = self.items or {},
            __namespace = self.namespace or 'unknown',
            __name = self.name or 'unknown'
        }
    end

    --- Close current wheel
    function wheel:close(isFromWheels)
        if (isFromWheels and isFromWheels == true) then
            if (self.isOpen) then
                self.isOpen = false

                SendNUIMessage({
                    action = 'CHANGE_STATE',
                    __namespace = self.namespace,
                    __name = self.name,
                    __resource = GetCurrentResourceName(),
                    __module = 'wheel',
                    shouldHide = true
                })

                if (wheels.currentWheel ~= nil and wheels.currentWheel.namespace == self.namespace and wheels.currentWheel.name == self.name) then
                    wheels.currentWheel = nil
                end
            end
        else
            wheels:close(self.namespace, self.name)
        end
    end

    --- Close current wheel
    function wheel:open(open)
        if (self.isOpen) then
            self.isOpen = true
        elseif(open) then
            self.isOpen = true

            wheels.currentWheel = self
        else
            wheels:open(self.namespace, self.name)
        end
    end

    --- Add a item to wheel
    --- @param item table Item Information
    function wheel:addItem(item)
        if (item == nil or type(item) ~= 'table') then
            return
        end

        local data = {}

        if (item.icon ~= nil and type(item.icon) == 'string') then
            data.icon = item.icon
        end

        if (item.lib ~= nil and type(item.lib) == 'string') then
            data.lib = item.lib
        end

        if (item.addon ~= nil) then
            data.addon = item.addon
        else
            data.addon = {}
        end

        data.id = #(self.items or {}) + 1

        table.insert(self.items, data)
    end

    --- Add a range of items
    --- @param items table List of items
    function wheel:addItems(items)
        if (items == nil or type(items) ~= 'table') then
            return
        end

        for key, value in pairs(items or {}) do
            self:addItem(value)
        end
    end

    --- Clear all wheel items
    function wheel:clearItems()
        self.items = {}
    end

    --- Set custom addon on wheel instead of item
    --- @param addon table Addon information
    function wheel:setAddon(addon)
        if (addon ~= nil and type(addon) == 'table') then
            self.addon = addon or {}
        end
    end

    --- Returns addon of current wheel
    function wheel:getAddon()
        if (self.addon ~= nil and type(self.addon) == 'table') then
            return self.addon or {}
        end

        return {}
    end

    return wheel
end