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
local ExecuteCommand = assert(ExecuteCommand)
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

    local player = commands.players[source] or corev:getPlayerIdentifiers(source)

    if (player == nil) then return end
    if (commands.players[source] == nil) then commands.players[source] = player end

    local key = corev:hashString(commandName)
    local cmd = commands.commands[key] or nil

    if (cmd == nil) then return end

    rawArguments = corev:ensure(rawArguments, {})

    local arguments = {}
    local parser = commands.parsers[key] or nil

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

    xpcall(cmd.func, traceback, player, unpack(arguments))
end

--- Register a command
--- @param resource string Name of resource where command is from
--- @param name string|table Name of command to execute
--- @param groups string|table Group(s) allowed to execute this command
--- @param callback function Execute this function when player is allowed
function commands:register(resource, name, groups, callback)
    if (corev:typeof(name) == 'tables') then
        for _, _name in pairs(name) do
            if (corev:typeof(_name) == 'string') then
                self:register(resource, name, groups, callback)
            end
        end

        return
    end

    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = lower(corev:ensure(name, 'unknown'))
    groups = corev:typeof(groups) == 'table' and groups or corev:ensure(groups, 'superadmin')
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown') then return end

    local key = corev:hashString(name)

    if (self.commands[key] ~= nil) then
        print(corev:t('command_exsits'):format(name))
    end

    --- Create a `command` class
    local command = class 'command'

    --- Set default information
    command:set {
        resource = resource,
        name = name,
        groups = groups,
        func = callback
    }

    self.commands[key] = command

    --- Register command
    RegisterCommand(name, __executeCommand, false)

    --- Whitelist a group
    if corev:typeof(groups) == 'table' then
		for _, group in pairs(groups) do
            if (corev:typeof(group) == 'string') then
                ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
            end
		end
	elseif corev:typeof(groups) == 'string' then
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(groups, name))
	end
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

    local key = corev:hashString(name)

    if (self.commands[key] == nil or self.commands[key].resource ~= resource) then return end

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
        local rawType = corev:typeof(default)

        if (rawType ~= type) then
            if (rawType == 'nil' and type == 'boolean') then
                default = false
            else
                type = 'any'
            end
        end

        insert(parser.parameters, {
            type = type,
            default = default
        })
    end

    self.parsers[key] = parser
end

--- Register a command
--- @param name string|table Name of command to execute
--- @param groups string|table Group(s) allowed to execute this command
--- @param callback function Execute this function when player is allowed
function registerCommand(name, groups, callback)
    local _r = GetInvokingResource()
    local resource = corev:ensure(_r, corev:getCurrentResourceName())

    commands:register(resource, name, groups, callback)
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