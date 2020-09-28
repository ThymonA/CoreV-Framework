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
local controls = class('controls')

--- Set default values
controls:set {
    controls = {},
    modules = {}
}

--- Enable or Disable a button
function controls:disableControlAction(group, key, disabled, moduleName)
    moduleName = moduleName or getCurrentModule() or CurrentFrameworkModule or 'unknown'

    if (moduleName == nil) then moduleName = 'unknown' end
    if (type(moduleName) ~= 'string') then moduleName = tostring(moduleName) end
    if (group == nil or type(group) ~= 'number') then group = tonumber(group or '0') end
    if (key == nil or type(key) ~= 'number') then key = tonumber(key or '0') end
    if (disabled == nil or (type(disabled) ~= 'boolean' and type(disabled) ~= 'number')) then disabled = tonumber(disabled or '0') end
    if (type(disabled) == 'number') then disabled = disabled == 1 end
    if (self.modules == nil) then self.modules = {} end
    if (self.modules[moduleName] == nil) then self.modules[moduleName] = { } end
    if (self.modules[moduleName][tostring(group)] == nil) then self.modules[moduleName][tostring(group)] = { group = group, keys = {} } end
    if (self.controls[tostring(group)] == nil) then self.controls[tostring(group)] = { group = group, keys = {} } end
    if (self.modules[moduleName][tostring(group)].keys[tostring(key)] == nil) then self.modules[moduleName][tostring(group)].keys[tostring(key)] = { key = key, disabled = disabled } end
    if (self.controls[tostring(group)].keys[tostring(key)] == nil) then self.controls[tostring(group)].keys[tostring(key)] = { key = key, anyDisabled = false, lastStatus = nil } end

    self.modules[moduleName][tostring(group)].keys[tostring(key)].disabled = disabled
end

--- Update NUI focus and mouse input status
Citizen.CreateThread(function()
    while true do
        for group, groupInfo in pairs(controls.controls or {}) do
            for key, keyInfo in pairs(groupInfo.keys or {}) do
                controls.controls[group].keys[key].anyDisabled = false

                for moduleName, _ in pairs(controls.modules or {}) do
                    local isDisabled, module = false, controls.modules[moduleName] or nil

                    if (module ~= nil) then
                        local moduleGroup = module[tostring(group)] or nil

                        if (moduleGroup ~= nil) then
                            local moduleKeys = moduleGroup.keys or nil

                            if (moduleKeys ~= nil) then
                                local moduleKey = moduleKeys[key] or nil

                                if (moduleKey ~= nil) then
                                    isDisabled = moduleKey.disabled or false

                                    if (isDisabled) then controls.controls[group].keys[key].anyDisabled = true end
                                end
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(250)
    end
end)

--- Enable/Disable NUI Focus and input
Citizen.CreateThread(function()
    while true do
        for group, groupInfo in pairs(controls.controls or {}) do
            for key, keyInfo in pairs(groupInfo.keys or {}) do
                if (keyInfo.anyDisabled) then
                    DisableControlAction(groupInfo.group, keyInfo.key, keyInfo.anyDisabled)
                end
            end
        end

        Citizen.Wait(0)
    end
end)

--- FiveM maniplulation
_ENV.controls = controls
_G.controls = controls

--- Add NUI as module
addModule('controls', controls)