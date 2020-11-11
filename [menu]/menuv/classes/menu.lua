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
local createMenuItem = assert(createMenuItem)
local lower = assert(string.lower)
local insert = assert(table.insert)
local remove = assert(table.remove)
local pack = assert(pack or table.pack)
local unpack = assert(unpack or table.unpack)
local CreateThread  = assert(Citizen.CreateThread)

--- Cahce FiveM globals
local GetInvokingResource = assert(GetInvokingResource)

local function createMenu(resource, name)
    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')

    if (name == 'unknown') then name = corev:getRandomString() end

    --- Create a `menu` class
    local menu = class "menu"

    --- Set default information
    menu:set {
        __name = name,
        __resource = resource,
        __open = false,
        events = {},
        items = {}
    }

    function menu:addItem(itemType)
        itemType = lower(corev:ensure(itemType, 'unknown'))

        local item = createMenuItem(self, itemType)

        insert(self.items, item)

        self:trigger('item:add', self.items[#self.items], self)

        return self.items[#self.items]
    end

    function menu:removeItem(index)
        index = corev:ensure(index, 0)

        if (index <= 0 or #self.items < index) then return end

        local itemObj = self.items[index]

        remove(self.items, index)

        self:trigger('item:remove', itemObj, self)
    end

    function menu:on(event, callback)
        event = ('menu:%s'):format(corev:ensure(event, 'unknown'))
        callback = corev:ensure(callback, function() end)

        local eventKey = corev:hashString(event)

        if (self.events[eventKey] == nil) then self.events[eventKey] = {} end

        insert(self.events[eventKey], callback)
    end

    function menu:trigger(event, ...)
        event = ('menu:%s'):format(corev:ensure(event, 'unknown'))

        local eventKey = corev:hashString(event)

        if (self.events[eventKey] == nil) then return end

        local arguments = pack(...)

        for i = 1, #self.events[eventKey], 1 do
            CreateThread(function()
                self.events[eventKey][i](self, unpack(arguments))
            end)
        end
    end

    function menu:isOpen()
        return corev:ensure(self.__open, false)
    end

    function menu:close()
        local _r = GetInvokingResource()

        _r = corev:ensure(_r, corev:getCurrentResourceName())
    end

    function menu:open()
        local _r = GetInvokingResource()

        _r = corev:ensure(_r, corev:getCurrentResourceName())
    end

    return menu
end

--- Register `createMenu` as global function
global.createMenu = createMenu