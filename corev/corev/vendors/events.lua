----------------------- [ CoreV ] -----------------------
-- ɢɪᴛʜᴜʙ: https://github.com/ThymonA/CoreV-Framework
-- ʟɪᴄᴇɴꜱᴇ: GNU General Public License v3.0
-- ᴅᴇᴠᴇʟᴏᴘᴇʀ: ThymonA
-- ᴘʀᴏᴊᴇᴄᴛ: CoreV-Framework
-- ᴠᴇʀꜱɪᴏɴ: 1.0.0
-- ᴅᴇꜱᴄʀɪᴘᴛɪᴏɴ: Events handler for CoreV Framework
----------------------- [ CoreV ] -----------------------

--- cache globals
local assert = assert
local corev = assert(corev)
local class = assert(class)
local lower = assert(string.lower)
local pack = assert(pack or table.pack)
local remove = assert(remove or table.remove)
local pairs = assert(pairs)
local isClient = not IsDuplicityVersion()

--- Create a events class
local events = class "events"

--- Set default values
events:set {
    events = {}
}

--- Register a event as onEvent
--- @param event string Name of event
--- @param name string?|string[]? (optional) Entity, Category, Type etc.
--- @param func function Trigger this function when on event matches
function events:innerOnEventTrigger(event, name, func)
    event = corev:ensure(event, 'unknown')
    func = corev:ensure(func, function() end)

    if (event == 'unknown' or name == nil) then return end

    if (corev:typeof(name) == 'table') then
        for _, _name in pairs(name) do
            if (corev:typeof(_name) == 'string') then
                self:innerOnEventTrigger(event, _name, func)
            end
        end

        return
    end

    event = lower(event)

    if (name ~= nil and corev:typeof(name) == 'string') then name = lower(name) end

    if (self.events == nil) then self.events = {} end

    if (name ~= nil) then
        event = ('%s:%s'):format(event, corev:ensure(name, 'unknown'))
    end

    if (self.events[event] == nil) then self.events[event] = {} end

    local eventObject = {
        event = event,
        name = name,
        func = func
    }

    table.insert(self.events[event], eventObject)
end

--- Register a event as onEvent
--- @param event string Name of event
--- @param name string? (optional) Entity, Category, Type etc. example: -1523513 or cars or player
--- @param names string[]? (optional) List of Entities, Categories, Types etc. examples: [-123124123, -53412341] or ['cars', 'bikes'] or ['peds', 'players']
--- @param callback function Trigger this function when on event matches
--- @param ... Optional parameters
function events:onEventTrigger(event, ...)
    event = corev:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    local name, names, callback = nil, nil, nil
    local nameIndex, namesIndex, callbackIndex = 999, 999, 999
    local arguments = pack(...)

    for i, argument in pairs(arguments) do
        if (corev:typeof(i) == 'number' and argument ~= nil) then
            local argumentType = corev:typeof(argument)

            if (argumentType == 'function' and callback == nil) then
                callback = argument
                callbackIndex = i
            elseif (argumentType == 'table' and names == nil) then
                names = argument
                namesIndex = i
            elseif (name == nil) then
                local _n = corev:ensure(argument, 'unknown')

                if (_n ~= 'unknown') then
                    name = _n
                    nameIndex = i
                end
            end
        end
    end

    if (name ~= nil and callback ~= nil and nameIndex < namesIndex) then
        remove(arguments, nameIndex)
        remove(arguments, callbackIndex)

        self:innerOnEventTrigger(event, name, callback)
    elseif (names ~= nil and callback ~= nil and namesIndex < nameIndex) then
        remove(arguments, namesIndex)
        remove(arguments, callbackIndex)

        self:innerOnEventTrigger(event, names, callback)
    elseif (callback ~= nil) then
        remove(arguments, callbackIndex)

        self:innerOnEventTrigger(event, nil, callback)
    end
end