----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
-- Name: CoreV
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ CoreV ] -----------------------
error = class('error')

--- Log a error message
--- @param message string Message
function error:print(msg, resource, module)
    if (resource ~= nil and type(resource) == 'string') then
        resource = (' [%s]'):format(tostring(resource))
    elseif (CurrentFrameworkResource ~= nil and type(CurrentFrameworkResource) == 'string') then
        resource = (' [%s]'):format(tostring(CurrentFrameworkResource))
    else
        resource = ''
    end

    if (module ~= nil and type(module) == 'string') then
        module = (' [%s]'):format(tostring(module))
    elseif (CurrentFrameworkModule ~= nil and type(CurrentFrameworkModule) == 'string') then
        module = (' [%s]'):format(tostring(CurrentFrameworkModule))
    else
        module = ''
    end

    if (SERVER) then
        local currentFile = LoadResourceFile(GetCurrentResourceName(), 'corev_error.log') or ''

        if (not currentFile) then
            currentFile = ''
        end

        local newData = ('%s%s ERROR%s%s %s\n'):format(currentFile, currentTimeString(), resource, module, msg)

        SaveResourceFile(GetCurrentResourceName(), 'corev_error.log', newData)
    end

    print(('[%s][ERROR]%s%s %s'):format(GetCurrentResourceName(), resource, module, msg))
end

--- Add error as module when available
Citizen.CreateThread(function()
    while true do
        if (addModule ~= nil and type(addModule) == 'function') then
            addModule('error', error)
            return
        end

        Citizen.Wait(0)
    end
end)