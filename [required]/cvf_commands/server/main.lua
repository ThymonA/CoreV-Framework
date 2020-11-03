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
local class = assert(class)
local corev = assert(corev)
local pairs = assert(pairs)
local print = assert(print)
local xpcall = assert(xpcall)
local unpack = assert(unpack or table.unpack)
local insert = assert(table.insert)
local lower = assert(string.lower)
local traceback = assert(debug.traceback)

--- FiveM cached global variables
local RegisterCommand = assert(RegisterCommand)
local GetInvokingResource = assert(GetInvokingResource)
local exports = assert(exports)

--- Create a `commands` class
local commands = class 'commands'

--- Set default values
commands:set {
    commands = {},
    parsers = {},
    players = {}
}

--- Execute function based on used `command`
--- @param source number Player source
--- @param rawArguments table Arguments given
--- @param raw string Raw command
local function __executeCommand(source, rawArguments, raw)
    raw = corev:ensure(raw, 'unknown')

    local commandName = lower(corev:ensure(corev:split(raw, ' ')[1], 'unknown'))

    if (commandName == 'unknown') then return end

    local vPlayer = commands.players[source] or corev:getPlayer(source)

    if (vPlayer == nil) then return end
    if (commands.players[source] == nil) then commands.players[source] = vPlayer end

    local cmd = commands.commands[commandName] or nil

    if (cmd == nil or not vPlayer:aceAllowed(cmd.aces)) then return end

    rawArguments = corev:ensure(rawArguments, {})

    local arguments = {}
    local parser = commands.parsers[commandName] or nil

    if (parser) then
        for index, argument in pairs(parser.parameters) do
            if (argument.type == 'any') then
                arguments[index] = rawArguments[index] or argument.default
            else
                arguments[index] = corev:ensure(rawArguments[index], argument.default)
            end
        end
    else
        arguments = rawArguments
    end

    xpcall(cmd.func, traceback, vPlayer, unpack(arguments))
end

--- Register a command
--- @param resource string Name of resource where command is from
--- @param name string|table Name of command to execute
--- @param aces string|table Aces allowed to execute this command
--- @param callback function Execute this function when player is allowed
function commands:register(resource, name, aces, callback)
    if (corev:typeof(name) == 'tables') then
        for _, _name in pairs(name) do
            if (corev:typeof(_name) == 'string') then
                self:register(resource, name, aces, callback)
            end
        end

        return
    end

    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')
    aces = corev:typeof(aces) == 'table' and aces or corev:ensure(aces, '*')
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown') then return end

    if (self.commands[name] ~= nil) then
        print(corev:t('commands', 'command_exsits'):format(name))
    end

    --- Create a `command` class
    local command = class 'command'

    --- Set default information
    command:set {
        resource = resource,
        name = name,
        aces = aces,
        func = callback
    }

    self.commands[lower(name)] = command

    --- Register command
    RegisterCommand(name, __executeCommand, false)
end

--- Create a parser for generated command
--- @param resource string Name of resource where command is from
--- @param name string Name of command
--- @param parseInfo table Information about parser
function commands:parser(resource, name, parseInfo)
    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')
    parseInfo = corev:ensure(parseInfo, {})

    if (name == 'unknown') then return end
    if (self.commands[name] == nil or self.commands[name].resource ~= resource) then return end

    --- Create a `parser` class
    local parser = class 'parser'

    --- Set default value
    parser:set {
        name = name,
        resource = resource,
        parameters = {}
    }

    for _, info in pairs(parseInfo) do
        local type = corev:ensure(info.type, 'any')
        local default = info.default or nil

        if (corev:typeof(default) ~= type) then type = 'any' end

        insert(parser.parameters, {
            type = type,
            default = default
        })
    end

    self.parsers[name] = parser
end

--- Register a command
--- @param name string|table Name of command to execute
--- @param aces string|table Aces allowed to execute this command
--- @param callback function Execute this function when player is allowed
function registerCommand(name, aces, callback)
    local _r = GetInvokingResource()
    local resource = corev:ensure(_r, corev:getCurrentResourceName())

    commands:register(resource, name, aces, callback)
end

--- Create a parser for generated command
--- @param name string Name of command
--- @param parseInfo table Information about parser
function registerParser(name, parseInfo)
    local _r = GetInvokingResource()
    local resource = corev:ensure(_r, corev:getCurrentResourceName())

    commands:parser(resource, name, parseInfo)
end

--- Register `registerEvent` and `removeEvent` as export function
exports('__rc', registerCommand)
exports('__rp', registerParser)