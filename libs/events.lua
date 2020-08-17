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
events = {
    onPlayerConnecting = {
        server = {}
    },
    onPlayerConnected = {
        server = {}
    },
    onPlayerDisconnect = {
        server = {}
    }
}

if (SERVER) then
    --- Trigger func when player is connecting
    --- @param func function Function to execute
    onPlayerConnecting = function(func)
        local module = CurrentFrameworkModule or 'unknown'

        table.insert(events.onPlayerConnecting.server, {
            module = module,
            func = func
        })
    end

    --- Trigger func when player is fully connected
    --- @param func function Function to execute
    onPlayerConnected = function(func)
        local module = CurrentFrameworkModule or 'unknown'

        table.insert(events.onPlayerConnected.server, {
            module = module,
            func = func
        })
    end

    --- Trigger func when player is disconnecting
    --- @param func function Function to execute
    onPlayerDisconnect = function(func)
        local module = CurrentFrameworkModule or 'unknown'

        table.insert(events.onPlayerDisconnect.server, {
            module = module,
            func = func
        })
    end

    --- Trigger func by client
    ---@param name string Trigger name
    ---@param func function Function to trigger
    onClientTrigger = function(name, func)
        RegisterServerEvent(name)
        AddEventHandler(name, func)
    end

    --- Trigger all player connecting events
    --- @param source int PlayerId
    triggerPlayerConnecting = function(source, deferrals)
        for _, playerConnectingEvent in pairs(events.onPlayerConnecting.server or {}) do
            try(function()
                local continue, error, error_message = false, false, ''
            
                playerConnectingEvent.func(source, function()
                    continue = true
                end, function(err_message)
                    continue = true
                    error = true
                    error_message = err_message or 'Unknown Error'
                end, deferrals)

                while not continue do
                    Citizen.Wait(0)
                end

                if (error) then
                    deferrals.done(error_message)
                    return
                end
            end, function(err)
                deferrals.done('[SCRIPT ERROR]: ' .. err)
            end)
        end

        deferrals.done()
    end

    --- Trigger all player connected events
    --- @param source int PlayerId
    triggerPlayerConnected = function(source)
        for _, playerConnectedEvent in pairs(events.onPlayerConnected.server or {}) do
            try(function()
                local continue, error, error_message = false, false, ''
            
                playerConnectedEvent.func(source, function()
                    continue = true
                end, function(err_message)
                    continue = true
                    error = true
                    error_message = err_message or 'Unknown Error'
                end)

                while not continue do
                    Citizen.Wait(0)
                end

                if (error) then
                    error:print(error)
                    return
                end
            end, function(err) end)
        end
    end

    --- Trigger all player disconnect events
    --- @param source int PlayerId
    triggerPlayerDisconnect = function(source, reason)
        for _, playerDisconnectEvent in pairs(events.onPlayerDisconnect.server or {}) do
            try(function()
                local continue, error, error_message = false, false, ''
            
                playerDisconnectEvent.func(source, function()
                    continue = true
                end, function(err_message)
                    continue = true
                    error = true
                    error_message = err_message or 'Unknown Error'
                end, reason)

                while not continue do
                    Citizen.Wait(0)
                end

                if (error) then
                    error:print(error)
                    return
                end
            end, function(err) end)
        end
    end

    -- FiveM maniplulation
    _ENV.onPlayerConnecting = onPlayerConnecting
    _G.onPlayerConnecting = onPlayerConnecting
    _ENV.triggerPlayerConnecting = triggerPlayerConnecting
    _G.triggerPlayerConnecting = triggerPlayerConnecting
    _ENV.triggerPlayerDisconnect = triggerPlayerDisconnect
    _G.triggerPlayerDisconnect = triggerPlayerDisconnect
end