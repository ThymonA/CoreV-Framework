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
Citizen.CreateThread(function()
    local resourceStarted = os:currentTimeInMilliseconds()

    print('[^5Core^4V^7] Is now loading.....')

    resource:loadAll()

    local serverSideLoadedAfter = os:currentTimeInMilliseconds() - resourceStarted

    print(('[^5Core^4V^7] Server been loaded after %s seconds'):format(round(serverSideLoadedAfter / 1000, 2)))

    compiler:generateResource()

    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    local frameworkLoadedAfter = os:currentTimeInMilliseconds() - resourceStarted

    local numberOfResources, numberOfInternalResources, numberOfModules = resource:countAllLoaded()
    print(('============= [ ^5Core^4V^7 ] =============\n^2All framework executables are loaded ^7\n=====================================\n-> ^1External Resources:  ^7%s ^7\n-> ^1Internal Resources:  ^7%s ^7\n-> ^1Internal Modules:    ^7%s ^7\n-> ^1Framework Load Time: ^7%s seconds ^7\n=====================================\n^3VERSION: ^71.0.0\n============= [ ^5Core^4V^7 ] =============')
        :format(numberOfResources, numberOfInternalResources, numberOfModules, round(frameworkLoadedAfter / 1000, 2)))
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    deferrals.defer()

    local _source = source
    
    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    triggerPlayerConnecting(_source, deferrals)
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    
    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    triggerPlayerDisconnect(_source, reason)
end)

onClientTrigger('corev:core:playerLoaded', function()
    local _source = source

    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    triggerPlayerConnected(_source)
end)

AddEventHandler('core:chat:addError', function(msg)
    print('[ERROR] ' .. msg)
end)

AddEventHandler('corev:core:kickPlayer', function(playerId, message, cb)
    if (source == nil) then source = 0 end
    if (type(source) == 'string') then source = tonumber(source) end
    if (type(source) ~= 'number') then source = 0 end
    if (source > 0) then if (cb ~= nil) then cb(false, 'Unknown') end return end

    local getIds = GetPlayerIdentifiers(playerId) or {}
    local anyId = #getIds > 0

    if (anyId) then 
        local playerName = GetPlayerName(playerId)

        DropPlayer(playerId, message)

        if (cb ~= nil) then cb(true, playerName) end
    else
        if (cb ~= nil) then cb(false, 'Unknown') end
    end
end)

Citizen.CreateThread(function()
    while true do
        local _commands = m('commands')

        if (_commands ~= nil) then
            _commands:register('reload', { 'superadmin' }, function(source, arguments, showError)
                ExecuteCommand(('stop ddrp_%s'):format(arguments.script))
                ExecuteCommand('refresh')
                ExecuteCommand(('start ddrp_%s'):format(arguments.script))
            end, true, {
                help = 'Restart a CoreV resource',
                validate = true,
                arguments = {
                    { name = 'script', help = 'name of script', type = 'string' }
                }
            })

            break;
        end

        Citizen.Wait(0)
    end
end)