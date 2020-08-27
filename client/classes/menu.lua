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
CoreV.CreateAMenu = function(namespace, name, info)
    local menu = class('menu')

    --- Default values
    menu:set {
        namespace = namespace,
        name = name,
        title = '',
        subtitle = '',
        items = {},
        events = {
            latest = '',
            open = {},
            close = {},
            change = {},
            submit = {}
        },
        isOpen = false
    }

    --- Set default title
    if (info.title == nil or type(info.title) ~= 'string') then
        menu.title = name:gsub('^%l', string.upper)
    else
        menu.title = info.title
    end

    --- Set category
    if (info.subtitle ~= nil and type(info.subtitle) == 'string') then
        menu.subtitle = info.subtitle
    end

    --- Register a callback and will be triggerd when event has been execute
    --- @param name string Event name
    --- @param cb function Callback function
    function menu:registerEvent(name, cb)
        if (name == nil or type(name) ~= 'string') then return end
        if (cb == nil or type(cb) ~= 'function') then return end

        name = string.lower(name)

        if (name == 'open') then
            table.insert(self.events.open, cb)
        elseif (name == 'close') then
            table.insert(self.events.close, cb)
        elseif (name == 'change') then
            table.insert(self.events.change, cb)
        elseif (name == 'submit') then
            table.insert(self.events.submit, cb)
        end
    end

    --- Trigger a callback function when event has been triggerd
    --- @param name string Event name
    --- @params ... any[] Parameters
    function menu:triggerEvents(name, ...)
        if (name == nil or type(name) ~= 'string') then return end

        name = string.lower(name)

        local events = {}

        if (name == 'open' and self.events.latest ~= 'open') then
            self.events.latest = 'open'
            events = self.events.open or {}
        elseif (name == 'close' and self.events.latest ~= 'close') then
            self.events.latest = 'close'
            events = self.events.close or {}
        elseif (name == 'change') then
            self.events.latest = 'change'
            events = self.events.change or {}
        elseif (name == 'submit') then
            self.events.latest = 'submit'
            events = self.events.submit or {}
        end

        local params = table.pack(...)

        for _, event in pairs(events or {}) do
            if (event ~= nil and type(event) == 'function') then
                try(function()
                    event(table.unpack(params))
                end, function(e)
                    error:print(e)
                end)
            end
        end
    end

    --- Return current menu data as object
    function menu:getData()
        return {
            title = self.title or 'Unknown',
            subtitle = self.subtitle or 'unknown',
            items = self.items or {},
            __namespace = self.namespace or 'unknown',
            __name = self.name or 'unknown'
        }
    end

    --- Close current menu
    function menu:close()
        if (self.isOpen) then
            self.isOpen = false

            SendNUIMessage({
                action = 'closeMenu',
                __namespace = self.namespace,
                __name = self.name
            })

            if (menus.currentMenu ~= nil and menus.currentMenu.namespace == self.namespace and menus.currentMenu.name == self.name) then
                menus.currentMenu = nil
            end
        end
    end

    --- Close current menu
    function menu:open(open)
        if (self.isOpen) then
            self.isOpen = true
        elseif(open) then
            self.isOpen = true

            menus.currentMenu = self
        else
            menus:open(self.namespace, self.name)
        end
    end

    --- Add a item to menu
    --- @param item table Item Information
    function menu:addItem(item)
        if (item == nil or type(item) ~= 'table') then
            return
        end

        local data = {}

        if (item.prefix ~= nil and type(item.prefix) == 'string') then
            data.prefix = item.prefix
        end

        if (item.label ~= nil and type(item.label) == 'string') then
            data.label = item.label
        end

        if (item.description ~= nil and type(item.description) == 'string') then
            data.description = item.description
        end

        table.insert(self.items, data)
    end

    --- Add a range of items
    --- @param items table List of items
    function menu:addItems(items)
        if (items == nil or type(items) ~= 'table') then
            return
        end

        for key, value in pairs(items or {}) do
            self:addItem(value)
        end
    end

    return menu
end