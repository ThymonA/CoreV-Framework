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

--- Cache global variables
local assert = assert
local corev = assert(corev)
local class = assert(class)
local pack = assert(pack or table.pack)
local insert = assert(table.insert)
local remove = assert(table.remove)
local ipairs = assert(ipairs)
local pairs = assert(pairs)
local lower = assert(string.lower)
local match = assert(string.match)
local sub = assert(string.sub)
local xpcall = assert(xpcall)
local traceback = assert(debug.traceback)
local Wait = assert(Citizen.Wait)
local CreateThread = assert(Citizen.CreateThread)

--- FiveM cached global variables
local GetCurrentResourceName = assert(GetCurrentResourceName)
local GetInvokingResource = assert(GetInvokingResource)
local GetNumPlayerIdentifiers = assert(GetNumPlayerIdentifiers)
local GetPlayerIdentifier = assert(GetPlayerIdentifier)
local _AEH = assert(AddEventHandler)
local exports = assert(exports)

--- Create a `events` class
local events = class "events"

--- Set default values
events:set {
    events = {},
    resourceName = GetCurrentResourceName()
}

--- Register a function as on event trigger
--- @param resource string Name of resource where event came from
--- @param event string Name of event
--- @param name table|string Name or Names of entities, categories etc.
--- @param func function Function to execute on event trigger
function events:onEvent(resource, event, name, func)
    resource = corev:ensure(resource, self.resourceName)
    event = corev:ensure(event, 'unknown')
    name = corev:ensure(name, corev:typeof(name) == 'table' and {} or 'unknown')
    func = corev:ensure(func, function() end)

    if (corev:typeof(name) == 'table') then
        for _, n in pairs(name) do
            if (corev:typeof(n) == 'string') then
                self:onEvent(event, n, func)
            end
        end

        return
    end

    event = lower(event)

    if (name == 'unknown') then name = nil else name = lower(name) end

    if (self.events == nil) then self.events = {} end
    if (self.events[event] == nil) then
        self.events[event] = {
            triggers = {},
            parameters = {}
        }
    end

    if (name == nil) then
        insert(self.events[event].triggers, {
            resource = resource,
            func = func
        })
    else
        if (self.events[event].parameters[name] == nil) then
            self.events[event].parameters[name] = {}
        end

        insert(self.events[event].parameters[name], {
            resource = resource,
            func = func
        })
    end
end

--- Filter given arguments on `function` and `name/names`
function events:filterArguments(...)
    local _n, _ns, _c = nil, nil, nil
    local _ni, _nsi = 999, 999
    local arguments = pack(...)

    for i, argument in ipairs(arguments) do
        local argumentType = corev:typeof(argument)

        if (argumentType == 'function' and _c == nil) then
            _c = argument
        elseif (argumentType == 'table' and _ns == nil) then
            for _, name in ipairs(argument) do
                local _arg = corev:ensure(name, 'unknown')

                if (_arg ~= 'unknown') then
                    if (_ns == nil) then
                        _ns = {}
                        _nsi = i
                    end

                    insert(_ns, _arg)
                end
            end
        elseif (_n == nil) then
            local _arg = corev:ensure(argument, 'unknown')

            if (_arg ~= 'unknown') then
                _n = _arg
                _ni = i
            end
        end
    end

    if (_n ~= nil and _c ~= nil and _ni < _nsi) then
        return _c, _n
    elseif (_ns ~= nil and _c ~= nil and _nsi < _ni) then
        return _c, _ns
    elseif (_c ~= nil) then
        return _c, nil
    end
end

--- Register a new on event
--- @param resource string Name of resource where event came from
--- @param event string Name of event
function events:registerOnEvents(resource, event, ...)
    resource = corev:ensure(resource, self.resourceName)
    event = corev:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    local callback, name = self:filterArguments(...)

    if (callback == nil) then return end

    self:onEvent(resource, event, name, callback)
end

--- Unregister a on event
--- @param resource string Name of resource where event came from
--- @param event string Name of event
function events:removeEvents(resource, event, ...)
    resource = corev:ensure(resource, self.resourceName)
    event = corev:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    local _, name = self:filterArguments(...)

    if (name == nil) then
        local triggers = ((self.events or {})[event] or {}).triggers or {}
        local parameters = ((self.events or {})[event] or {}).parameters or {}

        for index, triggerInfo in ipairs(triggers) do
            if (triggerInfo.resource == resource) then
                remove(self.events[event].triggers, index)
            end
        end

        for pName, parameterTable in ipairs(parameters) do
            for index, triggerInfo in ipairs(parameterTable) do
                if (triggerInfo.resource == resource) then
                    remove(self.events[event].parameters[pName], index)
                end
            end
        end
    elseif (corev:typeof(name) == 'table') then
        for _, n in pairs(name) do
            local parameters = (((self.events or {})[event] or {}).parameters or {})[n] or {}

            for index, triggerInfo in ipairs(parameters) do
                if (triggerInfo.resource == resource) then
                    remove(self.events[event].parameters[n], index)
                end
            end
        end
    else
        local parameters = (((self.events or {})[event] or {}).parameters or {})[name] or {}

        for index, triggerInfo in ipairs(parameters) do
            if (triggerInfo.resource == resource) then
                remove(self.events[event].parameters[name], index)
            end
        end
    end
end

--- This function will return player's identifiers as table
--- @param playerId number Source or Player ID to get identifiers for
--- @return table Founded identifiers for player
function events:getIdentifiersBySource(source)
    source = corev:ensure(source, -1)

    local tableResults = {
        steam = nil,
        license = nil,
        xbl = nil,
        live = nil,
        discord = nil,
        fivem = nil,
        ip = nil
    }

    if (source < 0 or source == 0) then return tableResults end

    local numIds = GetNumPlayerIdentifiers(source)

    for i = 0, numIds - 1, 1 do
        local identifier = corev:ensure(GetPlayerIdentifier(source, i), 'none')

        if (match(identifier, 'steam:')) then
            tableResults.steam = sub(identifier, 7)
        elseif (match(identifier, 'license:')) then
            tableResults.license = sub(identifier, 9)
        elseif (match(identifier, 'xbl:')) then
            tableResults.xbl = sub(identifier, 5)
        elseif (match(identifier, 'live:')) then
            tableResults.live = sub(identifier, 6)
        elseif (match(identifier, 'discord:')) then
            tableResults.discord = sub(identifier, 9)
        elseif (match(identifier, 'fivem:')) then
            tableResults.fivem = sub(identifier, 7)
        elseif (match(identifier, 'ip:')) then
            tableResults.ip = sub(identifier, 4)
        end
    end

    return tableResults
end

--- This event will be triggerd when a player is connecting
_AEH('playerConnecting', function(name, _, deferrals)
    deferrals.defer()

    local source = corev:ensure(source, 0)
    local triggers = ((events.events or {})['playerconnecting'] or {}).triggers or {}

    if (#triggers == 0) then
        deferrals.done()
        return
    end

    CreateThread(function()
        local pIdentifiers = events:getIdentifiersBySource(source)
        local identifierType = corev:ensure(corev:cfg('core', 'identifierType'), 'license')

        identifierType = lower(identifierType)

        --- Create a `player` class
        local player = class "player"

        --- Set default values
        player:set {
            source = source,
            name = name,
            identifiers = pIdentifiers,
            identifier = pIdentifiers[identifierType] or nil
        }

        local continue, canConnect, rejectMessage = false, false, nil

        for _, trigger in pairs(triggers) do
            local func = corev:ensure(trigger.func, function(_, done, _) done() end)
            local ok = xpcall(func, traceback, player, function(msg)
                msg = corev:ensure(msg, '')
                canConnect = corev:ensure(msg == '', false)

                if (not canConnect) then
                    rejectMessage = msg
                end

                continue = true
            end, deferrals.presentCard)

            repeat Wait(0) until continue == true

            if (not ok) then
                canConnect = false
                rejectMessage = corev:t('events', 'connecting_error'):format(trigger.resource)
            end

            if (not canConnect) then
                deferrals.done(rejectMessage)
                return
            end
        end

        deferrals.done()
    end)
end)

--- Register a new on event
--- @param event string Name of event
function registerEvent(event, ...)
    local _r = GetInvokingResource()
    local resource = corev:ensure(_r, events.resourceName)

    events:registerOnEvents(resource, event, ...)
end

--- Unregister a on event
--- @param event string Name of event
function removeEvent(event, ...)
    local _r = GetInvokingResource()
    local resource = corev:ensure(_r, events.resourceName)

    events:removeEvents(resource, event, ...)
end

--- Register `registerEvent` and `removeEvent` as export function
exports('__add', registerEvent)
exports('__del', removeEvent)