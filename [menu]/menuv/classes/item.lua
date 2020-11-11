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
local remove = assert(table.remove)
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

    if (itemType ~= 'item' and itemType ~= 'checkbox' and itemType ~= 'list' and itemType ~= 'menu') then
        error(corev:t('menu_item_invalid_type'))
        return
    end

    local item = class "menu-item"

    item:set {
        __parent = menu,
        __type = itemType,
        value = nil,
        events = {},
        addon = nil
    }

    function item:on(event, callback)
        event = ('%s:%s'):format(self.__type, corev:ensure(event, 'unknown'))
        callback = corev:ensure(callback, function() end)

        local eventKey = corev:hashString(event)

        if (self.events[eventKey] == nil) then self.events[eventKey] = {} end

        insert(self.events[eventKey], callback)
    end

    function item:trigger(event, ...)
        event = ('%s:%s'):format(self.__type, corev:ensure(event, 'unknown'))

        local eventKey = corev:hashString(event)

        if (self.events[eventKey] == nil) then return end

        local arguments = pack(...)

        for i = 1, #self.events[eventKey], 1 do
            CreateThread(function()
                self.events[eventKey][i](self, unpack(arguments))
            end)
        end
    end

    function item:setAddon(addon)
        self.addon = addon
    end

    function item:getAddon()
        return self.addon
    end

    if (itemType == 'checkbox') then
        function item:isChecked()
            return corev:ensure(self.value, false)
        end

        function item:setValue(value)
            self.value = corev:ensure(value, false)
            self:trigger((self.value and 'checkbox:checked' or 'checkbox:unchecked'), self)
        end

        function item:getValue()
            return corev:ensure(self.value, false)
        end
    elseif (itemType == 'menu') then
        function item:setValue(submenu)
            self.value = corev:typeof(submenu) == 'menu' and submenu or self.value
            self:trigger('menu:change', self.value, self)
        end

        function item:getValue()
            return corev:typeof(self.value) == 'menu' and self.value or nil
        end
    elseif (itemType == 'list') then
        function item:addItem(value, title, description)
            if (self.values == nil or corev:typeof(self.values) ~= 'table') then self.set('values', {}) end
            if (value == nil) then value = 0 end

            title = corev:ensure(title, ('#%s'):format(#self.values + 1))
            description = corev:ensure(description, string.empty)

            local itemObj = { title = title, description = description, value = value, __parent = self, __index = #self.values + 1 }

            insert(self.values, itemObj)

            self:trigger('item:add', itemObj, self)
        end

        function item:addItems(values)
            if (values == nil or corev:typeof(values) ~= 'table') then return end

            for i = 0, #values, 1 do
                if (values[i] ~= nil and corev:typeof(values[i]) == 'table') then
                    self:addItem(unpack(values[i]))
                end
            end
        end

        function item:removeItem(index)
            index = corev:ensure(index, 0)

            if (index <= 0 or corev:typeof(self.values) ~= 'table' or #self.values < index) then return end
            if (self.value ~= nil and self.value.__index == index) then self.value = nil end

            local itemObj = self.values[index]

            remove(self.values, index)

            self:trigger('item:remove', itemObj, self)
        end

        function item:removeItems(items, ...)
            if (items == nil) then return end
            if (corev:typeof(items) == 'table') then
                for i = 0, #items, 1 do
                    self:removeItem(corev:ensure(items[i], 0))
                end
            else
                items = pack(items, ...)

                for i = 0, #items, 1 do
                    self:removeItem(corev:ensure(items[i], 0))
                end
            end
        end

        function item:setValue(index)
            index = corev:ensure(index, 0)

            if (index <= 0 or corev:typeof(self.values) ~= 'table' or #self.values > index) then return end

            self.value = self.values[index]
            self:trigger('item:change', self.value, self)
        end

        function item:getValue()
            if (self.value == nil or self.value.value == nil) then return nil end

            return self.value.value
        end

        function item:getItem(index)
            index = corev:ensure(index, 0)

            if (index <= 0 or corev:typeof(self.values) ~= 'table' or #self.values > index) then return end

            return self.values[index]
        end

        function item:clear()
            self.values = {}
            self.value = nil
            self:trigger('item:clear', self)
        end
    elseif (itemType == 'item') then
        function item:setValue(value)
            self.value = value
        end

        function item:getValue()
            return self.value or nil
        end
    end

    return item
end

--- Register `createMenuItem` as global function
global.createMenuItem = createMenuItem