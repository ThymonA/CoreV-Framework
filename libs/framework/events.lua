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
local events = {
    client = {},
    server = {}
}

events.__onEvent = function(event, name, module, func, ...)
    if (event == nil or type(event) ~= 'string') then return end
    if (name ~= nil and (type(name) ~= 'string' and type(name) ~= 'table')) then name = tostring(name) end
    if (func == nil or type(func) ~= 'function') then func = function() end end

    if (type(name) == 'table') then
        for _, _name in pairs(name or {}) do
            if (type(_name) == 'string') then
                events.__onEvent(event, _name, func, ...)
            end
        end

        return
    end

    if (event ~= nil) then event = string.lower(event) end
    if (name ~= nil) then name = string.lower(name) end

    if (CLIENT) then
        if (events.client == nil) then events.client = {} end
        if (events.client[event] == nil) then events.client[event] = {} end
        if (name ~= nil and events.client[event][name] == nil) then events.client[event][name] = {} end

        local params = table.pack(...)

        if (name ~= nil) then
            table.insert(events.client[event][name], {
                module = module,
                name = name,
                func = func,
                params = params
            })
        else
            table.insert(events.client[event], {
                module = module,
                name = name,
                func = func,
                params = params
            })
        end
    else
        module = CurrentFrameworkModule or 'unknown'

        if (events.server == nil) then events.server = {} end
        if (events.server[event] == nil) then events.server[event] = {} end
        if (name ~= nil and events.server[event][name] == nil) then events.server[event][name] = {} end

        local params = table.pack(...)

        if (name ~= nil) then
            table.insert(events.server[event][name], {
                module = module,
                name = name,
                func = func,
                params = params
            })
        else
            table.insert(events.server[event], {
                module = module,
                name = name,
                func = func,
                params = params
            })
        end
    end
end

--- Register a new on event
--- @param event string Name of event example 'PlayerConnecting'
events.onEvent = function(event, ...)
    if (event == nil or type(event) ~= 'string') then return end

    local name = nil
    local nameIndex = 999
    local names = nil
    local namesIndex = 999
    local callback = nil
    local callbackIndex = 999
    local params = table.pack(...)

    for i, param in pairs(params or {}) do
        if (type(param) == 'function' and callback == nil) then
            callback = param
            callbackIndex = type(i) == 'number' and i or tonumber(i) or 0
            break
        elseif (type(param) == 'table' and names == nil) then
            for _, _name in pairs(param or {}) do
                if (type(_name) == 'string') then
                if (names == nil) then names = {} end
                table.insert(names, _name)
                namesIndex = type(i) == 'number' and i or tonumber(i) or 0
                end
            end
        elseif (name == nil) then
            local _name = tostring(param) or ''

            if (_name ~= '' and _name ~= 'nil') then
                name = _name
                nameIndex = type(i) == 'number' and i or tonumber(i) or 0
            end
        end
    end

    local _module = 'unknown'

    if (CLIENT) then _module = getCurrentModule() or 'unknown' end

    if (name ~= nil and callback ~= nil and nameIndex < namesIndex) then
        table.remove(params, nameIndex)
        table.remove(params, callbackIndex)

        events.__onEvent(event, name, _module, callback, table.unpack(params))
    elseif (names ~= nil and callback ~= nil and namesIndex < nameIndex) then
        table.remove(params, namesIndex)
        table.remove(params, callbackIndex)

        events.__onEvent(event, names, _module, callback, table.unpack(params))
    elseif (callback ~= nil) then
        table.remove(params, callbackIndex)

        events.__onEvent(event, nil, _module, callback, table.unpack(params))
    end
end

--- Remove a event from on event trigger
--- @param event string On event name
--- @param name string Name of entity etc.
events.clearOnEvents = function(event, name)
    if (event == nil or type(event) ~= 'string') then return end
    if (name ~= nil and (type(name) ~= 'string' and type(name) ~= 'table')) then name = tostring(name) end

    if (name ~= nil and type(name) == 'table') then
        for _, _name in pairs(name or {}) do
            if (_name ~= nil and type(_name) == 'string') then
                events.clearOnEvents(event, _name)
            end
        end

        return
    end

    if (CLIENT) then
        local moduleName = getCurrentModule() or 'unknown'

        if (name == nil) then
            local clientEvents = (events.client or {})[event] or nil

            if (clientEvents == nil or type(clientEvents) ~= 'table') then return end

            for i, clientEvent in pairs((events.client or {})[event] or {}) do
                if (clientEvent.func == nil and type(clientEvent) == 'table') then
                    for i2, clientSubEvent in pairs(((events.client or {})[event] or {})[i] or {}) do
                        if (clientSubEvent.func ~= nil and string.lower(clientSubEvent.module) == string.lower(moduleName)) then
                            table.remove(events.client[event][i], i2)
                        end
                    end
                elseif (clientEvent.func ~= nil and string.lower(clientEvent.module) == string.lower(moduleName)) then
                    table.remove(events.client[event], i)
                end
            end
        else
            local clientEvents = ((events.client or {})[event] or {})[name] or nil

            if (clientEvents == nil or type(clientEvents) ~= 'table') then return end

            for i, clientEvent in pairs(((events.client or {})[event] or {})[name] or {}) do
                if (clientEvent.func == nil and type(clientEvent) == 'table') then
                    for i2, clientSubEvent in pairs((((events.client or {})[event] or {})[name] or {})[i] or {}) do
                        if (clientSubEvent.func ~= nil and string.lower(clientSubEvent.module) == string.lower(moduleName)) then
                            table.remove(events.client[event][name][i], i2)
                        end
                    end
                elseif (clientEvent.func ~= nil and string.lower(clientEvent.module) == string.lower(moduleName)) then
                    table.remove(events.client[event][name], i)
                end
            end
        end
    else
        local moduleName = 'unknown'

        if (name == nil) then
            local serverEvents = (events.server or {})[event] or nil

            if (serverEvents == nil or type(serverEvents) ~= 'table') then return end

            for i, serverEvent in pairs((events.server or {})[event] or {}) do
                if (serverEvent.func == nil and type(serverEvent) == 'table') then
                    for i2, serverSubEvent in pairs(((events.server or {})[event] or {})[i] or {}) do
                        if (serverSubEvent.func ~= nil and string.lower(serverSubEvent.module) == string.lower(moduleName)) then
                            table.remove(events.server[event][i], i2)
                        end
                    end
                elseif (serverEvent.func ~= nil and string.lower(serverEvent.module) == string.lower(moduleName)) then
                    table.remove(events.server[event], i)
                end
            end
        else
            local serverEvents = ((events.server or {})[event] or {})[name] or nil

            if (serverEvents == nil or type(serverEvents) ~= 'table') then return end

            for i, serverEvent in pairs(((events.server or {})[event] or {})[name] or {}) do
                if (serverEvent.func == nil and type(serverEvent) == 'table') then
                    for i2, serverSubEvent in pairs((((events.server or {})[event] or {})[name] or {})[i] or {}) do
                        if (serverSubEvent.func ~= nil and string.lower(serverSubEvent.module) == string.lower(moduleName)) then
                            table.remove(events.server[event][name][i], i2)
                        end
                    end
                elseif (serverEvent.func ~= nil and string.lower(serverEvent.module) == string.lower(moduleName)) then
                    table.remove(events.server[event][name], i)
                end
            end
        end
    end
end

--- Returns if any event has been registerd based on event and name
--- @param event string On event name
--- @param name string Name of entity etc.
events.anyEventRegistered = function(event, name)
    if (event == nil or type(event) ~= 'string') then return false end
    if (name ~= nil and (type(name) ~= 'string' and type(name) ~= 'table')) then name = tostring(name) end

    if (CLIENT and name ~= nil) then
        return #((events.client or {})[event] or {})[name] or {} > 0
    elseif (CLIENT) then
        return #(events.client or {})[event] or {} > 0
    elseif (SERVER and name ~= nil) then
        return #((events.server or {})[event] or {})[name] or {} > 0
    elseif (SERVER) then
        return #(events.server or {})[event] or {} > 0
    end

    return false
end

if (CLIENT) then
    local triggerOnEvent = function(event, name, ...)
        if (event == nil or type(event) ~= 'string') then return end
        if (name ~= nil and type(name) ~= 'string') then name = tostring(name) end
        if (event ~= nil) then event = string.lower(event) end
        if (name ~= nil) then name = string.lower(name) end

        local clientEvents = (events.client or {})[event] or {}

        if (name ~= nil and type(name) == 'string') then
            clientEvents = clientEvents[name] or {}
        end

        local params = table.pack(...)

        for _, _event in pairs(clientEvents or {}) do
            if (_event ~= nil and _event.func ~= nil) then
                Citizen.CreateThread(function()
                    try(function()
                        _event.func(table.unpack(params))
                    end, function(err) end)
                    return
                end)
            end
        end
    end

    --- Trigger func by server
    ---@param name string Trigger name
    ---@param func function Function to trigger
    local onServerTrigger = function(name, func)
        RegisterNetEvent(name)
        AddEventHandler(name, func)
    end

    --- Trigger func by client
    ---@param name string Trigger name
    ---@param func function Function to trigger
    local onClientTrigger = function(name, func)
        AddEventHandler(name, func)
    end

    -- FiveM maniplulation
    _ENV.triggerOnEvent = triggerOnEvent
    _G.triggerOnEvent = triggerOnEvent
    _ENV.onServerTrigger = onServerTrigger
    _G.onServerTrigger = onServerTrigger
    _ENV.onClientTrigger = onClientTrigger
    _G.onClientTrigger = onClientTrigger
end

if (SERVER) then
    local triggerOnEvent = function(event, name, _source, ...)
        if (event == nil or type(event) ~= 'string') then return end
        if (name ~= nil and type(name) ~= 'string') then name = tostring(name) end
        if (_source == nil or type(_source) ~= 'number') then _source = source or -1 end
        if (event ~= nil) then event = string.lower(event) end
        if (name ~= nil) then name = string.lower(name) end

        local serverEvents = (events.server or {})[event] or {}

        if (name ~= nil and type(name) == 'string') then
            serverEvents = serverEvents[name] or {}
        end

        local params = table.pack(...)

        for _, _event in pairs(serverEvents or {}) do
            if (_event ~= nil and _event.func ~= nil) then
                Citizen.CreateThread(function()
                    try(function()
                        _event.func(_source, table.unpack(params))
                    end, function(err) end)
                    return
                end)
            end
        end
    end

    --- Trigger all player connecting events
    --- @param source int PlayerId
    local triggerPlayerConnecting = function(source, deferrals)
        local serverEvents = (events.server or {})['playerconnecting'] or {}

        for _, playerConnectingEvent in pairs(serverEvents) do
            if (playerConnectingEvent ~= nil and playerConnectingEvent.func ~= nil) then
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
        end

        deferrals.done()
    end

    --- Trigger all player connected events
    --- @param source int PlayerId
    local triggerPlayerConnected = function(source)
        local serverEvents = (events.server or {})['playerconnected'] or {}

        for _, playerConnectedEvent in pairs(serverEvents) do
            if (playerConnectedEvent ~= nil and playerConnectedEvent.func ~= nil) then
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
    end

    --- Trigger all player disconnect events
    --- @param source int PlayerId
    local triggerPlayerDisconnect = function(source, reason)
        local serverEvents = (events.server or {})['playerdisconnect'] or {}

        for _, playerDisconnectEvent in pairs(serverEvents) do
            if (playerDisconnectEvent ~= nil and playerDisconnectEvent.func ~= nil) then
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
    end

    --- Trigger func by client
    ---@param name string Trigger name
    ---@param func function Function to trigger
    local onClientTrigger = function(name, func)
        RegisterServerEvent(name)
        AddEventHandler(name, func)
    end

    --- Trigger func by server
    ---@param name string Trigger name
    ---@param func function Function to trigger
    local onServerTrigger = function(name, func)
        AddEventHandler(name, func)
    end

    -- FiveM maniplulation
    _ENV.triggerOnEvent = triggerOnEvent
    _G.triggerOnEvent = triggerOnEvent
    _ENV.triggerPlayerConnecting = triggerPlayerConnecting
    _G.triggerPlayerConnecting = triggerPlayerConnecting
    _ENV.triggerPlayerConnected = triggerPlayerConnected
    _G.triggerPlayerConnected = triggerPlayerConnected
    _ENV.triggerPlayerDisconnect = triggerPlayerDisconnect
    _G.triggerPlayerDisconnect = triggerPlayerDisconnect
    _ENV.onServerTrigger = onServerTrigger
    _G.onServerTrigger = onServerTrigger
    _ENV.onClientTrigger = onClientTrigger
    _G.onClientTrigger = onClientTrigger
end

local onFrameworkStarted = function(cb)
    if (cb ~= nil and type(cb) == 'function') then
        Citizen.CreateThread(function()
            repeat Citizen.Wait(0) until resource.tasks.loadingFramework == true

            cb()
        end)
    end
end

-- FiveM maniplulation
_ENV.onFrameworkStarted = onFrameworkStarted
_G.onFrameworkStarted = onFrameworkStarted
_ENV.on = events.onEvent
_G.on = events.onEvent
_ENV.clearOn = events.clearOnEvents
_G.clearOn = events.clearOnEvents
_ENV.onCount = events.anyEventRegistered
_G.onCount = events.anyEventRegistered