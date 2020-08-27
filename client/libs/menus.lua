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
menus = class('menus')

--- Set default values
menus:set {
    currentMenu = nil,
    menus = {},
    timer = GetGameTimer(),
    chunks = {}
}

--- Open a menu object
--- @param namespace string Menu's namespace
--- @param name string Menu's name
function menus:open(namespace, name)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end

    if (self.menus ~= nil and self.menus[namespace] ~= nil and self.menus[namespace][name] ~= nil) then
        if (self.menus[namespace][name].isOpen) then
            return
        end

        local anyMenuOpen, currentOpenMenu = self:anyMenuOpen()
        local menuClossed = false

        if (anyMenuOpen) then
            self.menus[currentOpenMenu.namespace][currentOpenMenu.name].isOpen = false
        end

        self.menus[namespace][name]:open(true)

        print('SEND OPENMENU EVENT')

        SendNUIMessage({
            action = 'openMenu',
            data = self.menus[namespace][name]:getData(),
            __namespace = self.menus[namespace][name].namespace,
            __name = self.menus[namespace][name].name
        })

        print('DONE SENDING OPENMENU EVENT')

        menus.currentMenu = self.menus[namespace][name]
    end
end

--- Close a menu object
--- @param namespace string Menu's namespace
--- @param name string Menu's name
function menus:close(namespace, name)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end

    if (self.menus ~= nil and self.menus[namespace] ~= nil and self.menus[namespace][name] ~= nil) then
        if (self.menus[namespace][name].isOpen) then
            self.menus[namespace][name]:close()

            SendNUIMessage({
                action = 'closeMenu',
                data = self.menus[namespace][name]:getData(),
                __namespace = self.menus[namespace][name].namespace,
                __name = self.menus[namespace][name].name
            })

            menus.currentMenu = nil
        end
    end
end

--- Create a menu object
--- @param namespace string Menu's namespace
--- @param name string Menu's name
--- @param info table Information about menu
function menus:create(namespace, name, info)
    if (namespace == nil or type(namespace) ~= 'string') then return false end
    if (name == nil or type(name) ~= 'string') then return false end
    if (info == nil or type(info) ~= 'table') then return false end
    if (self.menus == nil) then self.menus = {} end
    if (self.menus[namespace] == nil) then self.menus[namespace] = {} end
    if (self.menus[namespace][name] ~= nil) then return self.menus[namespace][name] end

    local menu = CoreV.CreateAMenu(namespace, name, info)

    self.menus[namespace][name] = menu

    return self.menus[namespace][name]
end

--- Add a menu item to menu
--- @param namespace string Menu's namespace
--- @param name string Menu's name
--- @param item table Menu item
function menus:addItem(namespace, name, item)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end
    if (item == nil or type(item) ~= 'table') then return end
    if (self.menus == nil) then return end
    if (self.menus[namespace] == nil) then return end
    if (self.menus[namespace][name] == nil) then return end

    self.menus[namespace][name]:addItem(item)
end

--- Add a menu items to menu
--- @param namespace string Menu's namespace
--- @param name string Menu's name
--- @param items table Menu items
function menus:addItems(namespace, name, items)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end
    if (items == nil or type(items) ~= 'table') then return end
    if (self.menus == nil) then return end
    if (self.menus[namespace] == nil) then return end
    if (self.menus[namespace][name] == nil) then return end

    self.menus[namespace][name]:addItems(items)
end

--- Returns `true` if any menu is open
function menus:anyMenuOpen()
    if (self.menus == nil) then return false, nil end

    for namespace, namespaceMenus in pairs(self.menus or {}) do
        if (namespace ~= nil and namespaceMenus ~= nil and type(namespace) == 'string' and type(namespaceMenus) == 'table') then
            for name, menu in pairs(self.menus[namespace] or {}) do
                if (menu.isOpen) then
                    return true, menu
                end
            end
        end
    end

    return false, nil
end

--- Register user input and communcate with frontend
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)

        SetNuiFocus(false, false)

        if (menus.currentMenu ~= nil and IsControlPressed(0, 18) and IsInputDisabled(0) and (GetGameTimer() - menus.timer) > 150) then
            SendNUIMessage({ action = 'controlPressed', control = 'ENTER', __namespace = menus.currentMenu.namespace, __name = menus.currentMenu.name })
            menus.timer = GetGameTimer()
        end

        if (menus.currentMenu ~= nil and IsControlPressed(0, 177) and IsInputDisabled(0) and (GetGameTimer() - menus.timer) > 150) then
            SendNUIMessage({ action = 'controlPressed', control = 'BACKSPACE', __namespace = menus.currentMenu.namespace, __name = menus.currentMenu.name })
            menus.timer = GetGameTimer()
        end

        if (menus.currentMenu ~= nil and IsControlPressed(0, 27) and IsInputDisabled(0) and (GetGameTimer() - menus.timer) > 150) then
            SendNUIMessage({ action = 'controlPressed', control = 'TOP', __namespace = menus.currentMenu.namespace, __name = menus.currentMenu.name })
            menus.timer = GetGameTimer()
        end

        if (menus.currentMenu ~= nil and IsControlPressed(0, 173) and IsInputDisabled(0) and (GetGameTimer() - menus.timer) > 150) then
            SendNUIMessage({ action = 'controlPressed', control = 'DOWN', __namespace = menus.currentMenu.namespace, __name = menus.currentMenu.name })
            menus.timer = GetGameTimer()
        end

        if (menus.currentMenu ~= nil and IsControlPressed(0, 174) and IsInputDisabled(0) and (GetGameTimer() - menus.timer) > 150) then
            SendNUIMessage({ action = 'controlPressed', control = 'LEFT', __namespace = menus.currentMenu.namespace, __name = menus.currentMenu.name })
            menus.timer = GetGameTimer()
        end

        if (menus.currentMenu ~= nil and IsControlPressed(0, 175) and IsInputDisabled(0) and (GetGameTimer() - menus.timer) > 150) then
            SendNUIMessage({ action = 'controlPressed', control = 'RIGHT', __namespace = menus.currentMenu.namespace, __name = menus.currentMenu.name })
            menus.timer = GetGameTimer()
        end
    end
end)

--- Add menus as module when available
Citizen.CreateThread(function()
    while true do
        if (addModule ~= nil and type(addModule) == 'function') then
            addModule('menus', menus)
            return
        end

        Citizen.Wait(0)
    end
end)

RegisterNUICallback('__chunk', function(data, cb)
	menus.chunks[data.id] = menus.chunks[data.id] or ''
	menus.chunks[data.id] = menus.chunks[data.id] .. data.chunk

    if data['end'] then
        local namespace = data.__namespace or 'unknown'
        local name = data.__name or 'unknown'

        if (namespace == nil or type(namespace) ~= 'string') then cb('ok') return end
        if (name == nil or type(name) ~= 'string') then cb('ok') return end
        if (menus.menus == nil) then cb('ok') return end
        if (menus.menus[namespace] == nil) then cb('ok') return end
        if (menus.menus[namespace][name] == nil) then cb('ok') return end

        local menu = menus.menus[namespace][name]
        local data = json.decode(menus.chunks[data.id])
        
        if (data.__type ~= nil and data.__type == 'close') then
            menus:close(namespace, name)
        elseif (data) then
            menu:triggerEvents(data.__type, menu, data)
        end

        if (data.id ~= nil and menus.chunks ~= nil and menus.chunks[data.id] ~= nil) then
            menus.chunks[data.id] = nil
        end
	end

	cb('ok')
end)