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
local nui = class('nui')

--- Set default values
nui:set {
    enableFocus = false,
    nuiFocusEnabled = false,
    enableMouseInput = false,
    mouseInputEnabled = false,
    modules = {}
}

--- Update NUI based on module
--- @param enableFocus number|boolean Enable NUI Focus
--- @param enableMouseInput number|boolean Enable NUI Mouse
function nui:setNuiFocus(enableFocus, enableMouseInput, moduleName)
    moduleName = moduleName or getCurrentModule() or CurrentFrameworkModule or 'unknown'

    if (moduleName == nil) then moduleName = 'unknown' end
    if (type(moduleName) ~= 'string') then moduleName = tostring(moduleName) end
    if (enableFocus == nil or (type(enableFocus) ~= 'boolean' and type(enableFocus) ~= 'number')) then enableFocus = tonumber(enableFocus or '0') end
    if (enableMouseInput == nil or (type(enableMouseInput) ~= 'boolean' and type(enableMouseInput) ~= 'number')) then enableMouseInput = tonumber(enableMouseInput or '0') end
    if (type(enableFocus) == 'number') then enableFocus = enableFocus == 1 end
    if (type(enableMouseInput) == 'number') then enableMouseInput = enableMouseInput == 1 end
    if (self.modules == nil) then self.modules = {} end
    if (self.modules[moduleName] == nil) then self.modules[moduleName] = { enableFocus = false, enableMouseInput = false } end

    self.modules[moduleName].enableFocus = enableFocus
    self.modules[moduleName].enableMouseInput = enableMouseInput
end

--- Update NUI focus and mouse input status
Citizen.CreateThread(function()
    while true do
        local anyFocusEnabled, anyMouseInputEnabled = false, false

        for _, moduleNUIFocus in pairs(nui.modules or {}) do
            if (moduleNUIFocus.enableFocus) then anyFocusEnabled = true end
            if (moduleNUIFocus.enableMouseInput) then anyMouseInputEnabled = true end
            if (anyFocusEnabled and anyMouseInputEnabled) then break end
        end

        nui.enableFocus = anyFocusEnabled
        nui.enableMouseInput = anyMouseInputEnabled

        Citizen.Wait(250)
    end
end)

--- Enable/Disable NUI Focus and input
Citizen.CreateThread(function()
    while true do
        if ((nui.enableFocus ~= nui.nuiFocusEnabled) or (nui.enableMouseInput ~= nui.mouseInputEnabled)) then
            SetNuiFocus(nui.enableFocus, nui.enableMouseInput)
            SetNuiFocusKeepInput(nui.enableMouseInput)

            nui.nuiFocusEnabled = nui.enableFocus
            nui.mouseInputEnabled = nui.enableMouseInput
        end

        Citizen.Wait(0)
    end
end)

--- FiveM maniplulation
_ENV.nui = nui
_G.nui = nui

--- Add NUI as module
addModule('nui', nui)