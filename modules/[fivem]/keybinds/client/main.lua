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
local keybinds = class('keybinds')

keybinds:set {
    keys = {},
    eventBinds = {},
    pressed = {}
}

function keybinds:registerKey(name, description, keyType, default)
    if (name == nil or type(name) ~= 'string') then return end
    if (description == nil or type(description) ~= 'string') then description = 'unknown' end
    if (keyType == nil or type(keyType) ~= 'string') then keyType = 'keyboard' end
    if (default == nil or type(default) ~= 'string') then default = 'e' end
    if (string.lower(keyType) ~= 'keyboard' and string.lower(keyType) ~= 'mouse') then return end
    if (string.lower(keyType) == 'mouse') then keyType = 'mouse_button' end

    name = string.replace(name, ' ', '')
    name = string.lower(name)

    if (self.keys ~= nil and self.keys[name] ~= nil) then return end

    self.keys[name] = {
        name = name,
        description = description,
        default = default,
        type = keyType
    }

    self.eventBinds[('+%s'):format(name)] = name
    self.eventBinds[('-%s'):format(name)] = name

    RegisterKeyMapping(('+%s'):format(name), description, keyType, default)

    RegisterCommand(('+%s'):format(name), function()
        local keyName = keybinds.eventBinds[('+%s'):format(name)] or nil

        if (keyName == nil) then return end

        keybinds.pressed[keyName] = true
    end)

    RegisterCommand(('-%s'):format(name), function()
        local keyName = keybinds.eventBinds[('+%s'):format(name)] or nil

        if (keyName == nil) then return end

        keybinds.pressed[keyName] = false
    end)
end

function keybinds:isControlPressed(name)
    if (name == nil or type(name) ~= 'string') then return end

    name = string.replace(name, ' ', '')
    name = string.lower(name)

    return (self.pressed or {})[name] or false
end

function keybinds:isControlReleased(name)
    if (name == nil or type(name) ~= 'string') then return end

    name = string.replace(name, ' ', '')
    name = string.lower(name)

    return not ((self.pressed or {})[name] or false)
end

addModule('keybinds', keybinds)