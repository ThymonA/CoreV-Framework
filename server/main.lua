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
Citizen.CreateThread(function()
    Resources:Execute()

    while not Resources.AllResourcesLoaded do
        Citizen.Wait(0)
    end

    print('Resources loaded!!!!')
end)

AddEventHandler('playerConnecting', function(name, setCallback, deferrals)
    deferrals.defer()

    local _source = source
    
    while not Resources.AllResourcesLoaded do
        Citizen.Wait(0)
    end

    triggerPlayerConnecting(_source, deferrals)
end)

AddEventHandler('playerDropped', function(reason)
    local _source = source
    
    while not Resources.AllResourcesLoaded do
        Citizen.Wait(0)
    end

    triggerPlayerDisconnect(_source, reason)
end)

onClientTrigger('corev:core:playerLoaded', function()
    local _source = source

    while not Resources.AllResourcesLoaded do
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