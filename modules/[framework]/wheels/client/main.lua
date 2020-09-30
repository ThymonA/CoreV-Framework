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
local wheels = class('wheels')

--- Set default values
wheels:set {
    currentWheel = nil,
    wheels = {},
    timer = GetGameTimer(),
    chunks = {},
    keybinds = m('keybinds'),
    canSelect = false,
    lastCanSelect = false
}

--- Open a wheel object
--- @param namespace string Wheel's namespace
--- @param name string Wheel's name
function wheels:open(namespace, name, onCursor)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end
    if (onCursor == nil or type(onCursor) ~= 'boolean') then onCursor = false end

    if (self.wheels ~= nil and self.wheels[namespace] ~= nil and self.wheels[namespace][name] ~= nil) then
        local anyWheelOpen, currentOpenWheel = self:anyWheelOpen()

        if (anyWheelOpen) then
            self.wheels[currentOpenWheel.namespace][currentOpenWheel.name].isOpen = false
        end

        self.wheels[namespace][name]:open(true)

        local wheelX, wheelY = 0, 0

        if (onCursor) then
            local mouseX, mouseY = GetNuiCursorPosition()

            wheelX, wheelY = round(mouseX or 0, 0), round(mouseY or 0, 0)
        else
            local screenX, screenY = GetActiveScreenResolution()

            wheelX, wheelY = round((screenX or 0) / 2, 0), round((screenY or 0) / 2, 0)
        end

        SendNUIMessage({
            action = 'SET_NAMESPACE',
            namespace = self.wheels[namespace][name].namespace,
            name = self.wheels[namespace][name].name,
            __namespace = self.wheels[namespace][name].namespace,
            __name = self.wheels[namespace][name].name,
            __resource = GetCurrentResourceName(),
            __module = 'wheel'
        })

        SendNUIMessage({
            action = 'ADD_ITEMS',
            items = self.wheels[namespace][name].items,
            removeAll = true,
            __namespace = self.wheels[namespace][name].namespace,
            __name = self.wheels[namespace][name].name,
            __resource = GetCurrentResourceName(),
            __module = 'wheel'
        })

        SendNUIMessage({
            action = 'CHANGE_STATE',
            shouldHide = false,
            x = wheelX,
            y = wheelY,
            __namespace = self.wheels[namespace][name].namespace,
            __name = self.wheels[namespace][name].name,
            __resource = GetCurrentResourceName(),
            __module = 'wheel'
        })

        self.currentWheel = self.wheels[namespace][name]
    end
end


--- Close a wheel object
--- @param namespace string Wheel's namespace
--- @param name string Wheel's name
function wheels:close(namespace, name)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end

    if (self.wheels ~= nil and self.wheels[namespace] ~= nil and self.wheels[namespace][name] ~= nil) then
        if (self.wheels[namespace][name].isOpen) then
            self.wheels[namespace][name]:close(true)

            SendNUIMessage({
                action = 'CLEAR_ITEMS',
                __namespace = self.wheels[namespace][name].namespace,
                __name = self.wheels[namespace][name].name,
                __resource = GetCurrentResourceName(),
                __module = 'wheel'
            })

            SendNUIMessage({
                action = 'CHANGE_STATE',
                shouldHide = true,
                x = 0,
                y = 0,
                __namespace = self.wheels[namespace][name].namespace,
                __name = self.wheels[namespace][name].name,
                __resource = GetCurrentResourceName(),
                __module = 'wheel'
            })

            self.currentWheel = nil
        end
    end
end

--- Create a wheel object
--- @param namespace string Wheel's namespace
--- @param name string Wheel's name
function wheels:create(namespace, name)
    if (namespace == nil or type(namespace) ~= 'string') then return false, false end
    if (name == nil or type(name) ~= 'string') then return false, false end
    if (self.wheels == nil) then self.wheels = {} end
    if (self.wheels[namespace] == nil) then self.wheels[namespace] = {} end
    if (self.wheels[namespace][name] ~= nil) then return self.wheels[namespace][name], false end

    local wheel = self:createWheel(namespace, name)

    self.wheels[namespace][name] = wheel

    return self.wheels[namespace][name], true
end

--- Add a wheel item to wheel
--- @param namespace string Wheel's namespace
--- @param name string Wheel's name
--- @param item table Wheel item
function wheels:addItem(namespace, name, item)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end
    if (item == nil or type(item) ~= 'table') then return end
    if (self.wheels == nil) then return end
    if (self.wheels[namespace] == nil) then return end
    if (self.wheels[namespace][name] == nil) then return end

    self.wheels[namespace][name]:addItem(item)
end

--- Add a wheel items to wheel
--- @param namespace string Wheel's namespace
--- @param name string Wheel's name
--- @param items table Wheel items
function wheels:addItems(namespace, name, items)
    if (namespace == nil or type(namespace) ~= 'string') then return end
    if (name == nil or type(name) ~= 'string') then return end
    if (items == nil or type(items) ~= 'table') then return end
    if (self.wheels == nil) then return end
    if (self.wheels[namespace] == nil) then return end
    if (self.wheels[namespace][name] == nil) then return end

    self.wheels[namespace][name]:addItems(items)
end

--- Returns `true` if any wheel is open
function wheels:anyWheelOpen()
    if (self.wheels == nil) then return false, nil end

    for namespace, namespaceWheels in pairs(self.wheels or {}) do
        if (namespace ~= nil and namespaceWheels ~= nil and type(namespace) == 'string' and type(namespaceWheels) == 'table') then
            for _, wheel in pairs(self.wheels[namespace] or {}) do
                if (wheel.isOpen) then
                    return true, wheel
                end
            end
        end
    end

    return false, nil
end

RegisterNUICallback('wheel_results', function(data, cb)
    local namespace = data.__namespace or 'unknown'
    local name = data.__name or 'unknown'

    if (namespace == nil or type(namespace) ~= 'string') then cb('ok') return end
    if (name == nil or type(name) ~= 'string') then cb('ok') return end

    if (wheels.wheels == nil) then cb('ok') return end
    if (wheels.wheels[namespace] == nil) then cb('ok') return end
    if (wheels.wheels[namespace][name] == nil) then cb('ok') return end

    local wheel = wheels.wheels[namespace][name]

    if (wheel ~= nil) then
        local currentSelected = data.selected or 0

        if (type(currentSelected) == 'string') then currentSelected = tonumber(currentSelected) end
        if (type(currentSelected) ~= 'number') then cb('ok') return end

        for _, item in pairs(wheel.items or {}) do
            if (item.id == currentSelected) then
                wheel:triggerEvents('submit', wheel, item)
                cb('ok')
                return
            end
        end
    end

    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        if (wheels.currentWheel ~= nil and wheels.currentWheel.isOpen) then
            if (wheels.keybinds:isControlReleased('raycast_click')) then
                wheels.canSelect = true
            end
        else
            wheels.canSelect = false
        end

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if (wheels.canSelect ~= wheels.lastCanSelect) then
            wheels.lastCanSelect = wheels.canSelect or false

            --- Update NUI Focus state
            nui:setNuiFocus(wheels.canSelect, wheels.canSelect, 'wheels')

            --- Update Controls state
            controls:disableControlAction(0, 1, wheels.canSelect, 'wheels')
            controls:disableControlAction(0, 2, wheels.canSelect, 'wheels')
            controls:disableControlAction(0, 24, wheels.canSelect, 'wheels')
            controls:disableControlAction(0, 25, wheels.canSelect, 'wheels')
            controls:disableControlAction(0, 142, wheels.canSelect, 'wheels')     -- MeleeAttackAlternate
            controls:disableControlAction(0, 106, wheels.canSelect, 'wheels')     -- VehicleMouseControlOverride
        end

        if (wheels.canSelect and wheels.keybinds:isControlPressed('wheel_select')) then
            if ((wheels.currentWheel or {}).isOpen) then
                wheels.canSelect = false

                wheels:close((wheels.currentWheel or {}).namespace or 'unknown', (wheels.currentWheel or {}).name or 'unknown')
            end
        end

        Citizen.Wait(0)
    end
end)

addModule('wheels', wheels)

onFrameworkStarted(function()
    wheels.keybinds:registerKey('wheel_select', _(CR(), 'wheels', 'keybind_wheel_select'), 'mouse', 'mouse_left')
end)