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
function menus:createAMenu(namespace, name, info)
    local menu = class('menu')

    --- Default values
    menu:set {
        namespace = namespace,
        name = name,
        title = '',
        subtitle = '',
        image = 'default.png',
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

    --- Set image
    if (info.image ~= nil and type(info.image) == 'string') then
        if (not string.match(info.image, '%A.%A')) then
            info.image = ('%s.png'):format(info.image)
        end

        menu.image = info.image
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

        if (name == 'open' and self.events.latest ~= 'open') then
            self.events.latest = 'open'
            self:triggerOpenEvents(...)
        elseif (name == 'close' and self.events.latest ~= 'close') then
            self.events.latest = 'close'
            self:triggerCloseEvents(...)
        elseif (name == 'change') then
            self.events.latest = 'change'
            self:triggerChangeEvents(...)
        elseif (name == 'submit') then
            self.events.latest = 'submit'
            self:triggerSubmitEvents(...)
        end
    end

    --- Trigger all open event callbacks
    --- @param menu menu Menu that has been triggerd
    --- @param data table Information about trigger
    function menu:triggerOpenEvents(menu, data)
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
    --- @param menu menu Menu that has been triggerd
    --- @param data table Information about trigger
    function menu:triggerCloseEvents(menu, data)
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

    --- Trigger all change event callbacks
    --- @param menu menu Menu that has been triggerd
    --- @param data table Information about trigger
    function menu:triggerChangeEvents(menu, data)
        local oldIndex = data.oldIndex or 0
        local newIndex = data.newIndex or 0
        local oldItem = self.items[(oldIndex + 1)] or false
        local newItem = self.items[(newIndex + 1)] or false

        for _, event in pairs(self.events.change or {}) do
            if (event ~= nil and type(event) == 'function') then
                try(function()
                    event(self, oldItem, newItem, data)
                end, function(e)
                    error:print(e)
                end)
            end
        end
    end

    --- Trigger all submit callbacks
    --- @param menu menu Menu that has been triggerd
    --- @param data table Information about trigger
    function menu:triggerSubmitEvents(menu, data)
        local selectedIndex = data.index or 0
        local selectedItem = self.items[(selectedIndex + 1)] or false

        for _, event in pairs(self.events.submit or {}) do
            if (event ~= nil and type(event) == 'function') then
                try(function()
                    event(self, selectedItem, data)
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
            image = self.image or 'default.png',
            items = self.items or {},
            __namespace = self.namespace or 'unknown',
            __name = self.name or 'unknown'
        }
    end

    --- Close current menu
    function menu:close(isFromMenus)
        if (isFromMenus and isFromMenus == true) then
            if (self.isOpen) then
                self.isOpen = false

                SendNUIMessage({
                    action = 'closeMenu',
                    __namespace = self.namespace,
                    __name = self.name,
                    __resource = GetCurrentResourceName(),
                    __module = 'menu'
                })

                if (menus.currentMenu ~= nil and menus.currentMenu.namespace == self.namespace and menus.currentMenu.name == self.name) then
                    menus.currentMenu = nil
                end
            end
        else
            menus:close(self.namespace, self.name)
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

        if (item.image ~= nil and type(item.image) == 'string') then
            data.item_image = item.image
        end

        if (item.addon ~= nil) then
            data.addon = item.addon
        else
            data.addon = {}
        end

        table.insert(self.items, data)
    end

    --- Add a range of items
    --- @param items table List of items
    function menu:addItems(items)
        if (items == nil or type(items) ~= 'table') then
            return
        end

        for _, value in pairs(items or {}) do
            self:addItem(value)
        end
    end

    --- Clear all menu items
    function menu:clearItems()
        self.items = {}
    end

    return menu
end