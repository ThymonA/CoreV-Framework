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
events = {
    onPlayerConnecting = {
        server = {}
    },
    onPlayerConnected = {
        server = {}
    },
    onPlayerDisconnect = {
        server = {}
    },
    onMarkerEvent = {
        client = {}
    },
    onMarkerLeave = {
        client = {}
    }
}

if (CLIENT) then
    --- Trigger func when event has been triggerd by marker
    --- @param event string Event name
    --- @param func function Callback function
    onMarkerEvent = function(event, func)
        local module = CurrentFrameworkModule or 'unknown'

        if (events.onMarkerEvent.client == nil) then
            events.onMarkerEvent.client = {}
        end

        if (events.onMarkerEvent.client[event] == nil) then
            events.onMarkerEvent.client[event] = {}
        end

        table.insert(events.onMarkerEvent.client[event], {
            module = module,
            event = event,
            func = func
        })
    end

    --- Trigger func when event has been triggerd by leaving a marker
    --- @param event string Event name
    --- @param func function Callback function
    onMarkerLeave = function(event, func)
        local module = CurrentFrameworkModule or 'unknown'

        if (events.onMarkerLeave.client == nil) then
            events.onMarkerLeave.client = {}
        end

        if (events.onMarkerLeave.client[event] == nil) then
            events.onMarkerLeave.client[event] = {}
        end

        table.insert(events.onMarkerLeave.client[event], {
            module = module,
            event = event,
            func = func
        })
    end

    --- Trigger all player enter a marker events
    --- @param event string Event name
    --- @param marker marker Marker that current is triggerd
    triggerMarkerEvent = function(event, marker)
        if (event == nil or type(event) ~= 'string') then return end
        if (events.onMarkerEvent.client == nil or #(events.onMarkerEvent.client[event] or {}) <= 0) then return end

        for i, markerEvent in pairs(events.onMarkerEvent.client[event] or {}) do
            Citizen.CreateThread(function()
                try(function()                
                    markerEvent.func(marker)
                end, function(err) end)
                return
            end)
        end
    end

    --- Trigger all player leave a marker events
    --- @param event string Event name
    --- @param marker marker Marker that current is triggerd
    triggerMarkerLeaveEvent = function(event, marker)
        if (event == nil or type(event) ~= 'string') then return end
        if (events.onMarkerLeave.client == nil or #(events.onMarkerLeave.client[event] or {}) <= 0) then return end

        for i, markerEvent in pairs(events.onMarkerLeave.client[event] or {}) do
            Citizen.CreateThread(function()
                try(function()                
                    markerEvent.func(marker)
                end, function(err) end)
                return
            end)
        end
    end

    --- Trigger func by server
    ---@param name string Trigger name
    ---@param func function Function to trigger
    onServerTrigger = function(name, func)
        RegisterNetEvent(name)
        AddEventHandler(name, func)
    end

    --- Trigger func by client
    ---@param name string Trigger name
    ---@param func function Function to trigger
    onClientTrigger = function(name, func)
        AddEventHandler(name, func)
    end

    -- FiveM maniplulation
    _ENV.onMarkerEvent = onMarkerEvent
    _G.onMarkerEvent = onMarkerEvent
    _ENV.onMarkerLeave = onMarkerLeave
    _G.onMarkerLeave = onMarkerLeave
    _ENV.triggerMarkerEvent = triggerMarkerEvent
    _G.triggerMarkerEvent = triggerMarkerEvent
    _ENV.triggerMarkerLeaveEvent = triggerMarkerLeaveEvent
    _G.triggerMarkerLeaveEvent = triggerMarkerLeaveEvent
    _ENV.onServerTrigger = onServerTrigger
    _G.onServerTrigger = onServerTrigger
    _ENV.onClientTrigger = onClientTrigger
    _G.onClientTrigger = onClientTrigger
end

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

    --- Trigger func by server
    ---@param name string Trigger name
    ---@param func function Function to trigger
    onServerTrigger = function(name, func)
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
                    error:print(error_message)
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
                    error:print(error_message)
                    return
                end
            end, function(err) end)
        end
    end

    -- FiveM maniplulation
    _ENV.onPlayerConnecting = onPlayerConnecting
    _G.onPlayerConnecting = onPlayerConnecting
    _ENV.onPlayerDisconnect = onPlayerDisconnect
    _G.onPlayerDisconnect = onPlayerDisconnect
    _ENV.onPlayerConnected = onPlayerConnected
    _G.onPlayerConnected = onPlayerConnected
    _ENV.triggerPlayerConnecting = triggerPlayerConnecting
    _G.triggerPlayerConnecting = triggerPlayerConnecting
    _ENV.triggerPlayerDisconnect = triggerPlayerDisconnect
    _G.triggerPlayerDisconnect = triggerPlayerDisconnect
    _ENV.triggerPlayerConnected = triggerPlayerConnected
    _G.triggerPlayerConnected = triggerPlayerConnected
    _ENV.onClientTrigger = onClientTrigger
    _G.onClientTrigger = onClientTrigger
    _ENV.onServerTrigger = onServerTrigger
    _G.onServerTrigger = onServerTrigger
end