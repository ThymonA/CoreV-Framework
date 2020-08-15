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
    elseif (not CurrentFrameworkResource ~= nil and type(CurrentFrameworkResource) == 'string') then
        resource = (' [%s]'):format(tostring(CurrentFrameworkResource))
    end

    if (module ~= nil and type(module) == 'string') then
        module = (' [%s]'):format(tostring(module))
    elseif (not CurrentFrameworkModule ~= nil and type(CurrentFrameworkModule) == 'string') then
        module = (' [%s]'):format(tostring(CurrentFrameworkModule))
    end

    if (SERVER) then
        local currentFile = LoadResourceFile(CR(), 'corev_error.log') or ''

        if (not currentFile) then
            currentFile = ''
        end

        local newData = ('%s%s ERROR%s%s %s\n'):format(currentFile, currentTimeString(), resource, module, msg)

        SaveResourceFile(CR(), 'corev_error.log', newData)
    end

    print(('[%s][ERROR]%s%s %s'):format(CR(), resource, module, msg))
end

addModule('error', error)