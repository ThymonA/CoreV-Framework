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
local createMenu = assert(createMenu)
local pack = assert(pack or table.pack)

--- Cahce FiveM globals
local exports = assert(exports)
local GetInvokingResource = assert(GetInvokingResource)

--- Create a `menus` class
local menus = class "menus"

--- Set default values
menus:set {
    __curent = nil,
    menus = {},
    chuncks = {}
}

function menus:open(resource, name)
    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')

    if (self.menus == nil or corev:typeof(self.menus) ~= 'table') then return end

    local resourceKey = corev:hashString(resource)
    local nameKey = corev:hashString(name)

    if (self.menus[resourceKey] == nil or self.menus[resourceKey][nameKey] == nil) then return end

    if (self.__curent ~= nil and corev:typeof(self.__curent) == 'menu') then
        self.__curent:close()
    end

    local m = self.menus[resourceKey][nameKey]

    self.__curent = m
    self.__curent:open()
end

function menus:close(resource, name)
    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')

    if (self.menus == nil or corev:typeof(self.menus) ~= 'table') then return end

    local resourceKey = corev:hashString(resource)
    local nameKey = corev:hashString(name)

    if (self.menus[resourceKey] == nil or self.menus[resourceKey][nameKey] == nil) then return end

    if (self.__curent.__resource == resource and self.__curent.__name == name) then
        self.__curent:close()
        self.__curent = nil
    end
end

function menus:create(resource, name, title, subtitle)
    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')
    title = corev:ensure(title, 'MenuV')
    subtitle = corev:ensure(subtitle, '')

    if (self.menus == nil or corev:typeof(self.menus) ~= 'table') then return end

    local m
    local resourceKey = corev:hashString(resource)
    local nameKey = corev:hashString(name)

    if (self.menus[resourceKey] ~= nil and self.menus[resourceKey][nameKey] ~= nil) then
        m = self.menus[resourceKey][nameKey]
        m:trigger('destroyed', m)
    end

    m = createMenu(resource, name, title, subtitle)

    self.menus[resourceKey][nameKey] = m

    return m
end

local function __openMenu(...)
    local r = GetInvokingResource()

    r = corev:ensure(r, corev:getCurrentResourceName())

    local arguments = pack(...)

    if (#arguments == 0) then
        return
    elseif (#arguments == 1) then
        menus:open(r, arguments[1])
    else
        menus:open(corev:ensure(arguments[1], r), arguments[2])
    end
end

local function __closeMenu(...)
    local r = GetInvokingResource()

    r = corev:ensure(r, corev:getCurrentResourceName())

    local arguments = pack(...)

    if (#arguments == 0) then
        return
    elseif (#arguments == 1) then
        menus:close(r, arguments[1])
    else
        menus:close(corev:ensure(arguments[1], r), arguments[2])
    end
end

local function __createMenu(name, title, subtitle)
    local r = GetInvokingResource()

    r = corev:ensure(r, corev:getCurrentResourceName())

    name = corev:ensure(name, 'unknown')
    title = corev:ensure(title, 'MenuV')
    subtitle = corev:ensure(subtitle, '')

    return menus:create(r, name, title, subtitle)
end

--- Register `createMenu` as global function
global.menus = menus

--- Register menuv's exports
exports('__open', __openMenu)
exports('__close', __closeMenu)
exports('__create', __createMenu)