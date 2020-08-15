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

onClientTrigger('corev:core:playerLoaded', function()
    local _source = source

    while not Resources.AllResourcesLoaded do
        Citizen.Wait(0)
    end

    triggerPlayerConnected(_source)
end)