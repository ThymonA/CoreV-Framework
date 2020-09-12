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
local commands = class('commands')

--- Set default value
commands:set {
    commands = {}
}

--- Register a commands
--- @param name commands
--- @param groups groups allowed
--- @param callback function callback function
--- @param consoleAllowed boolean console allowed
function commands:register(name, groups, callback, consoleAllowed, suggestion)
    if (type(name) == 'table') then
        for _, _name in pairs(name or {}) do
            self:register(_name, groups, callback, consoleAllowed, suggestion)
        end

        return
    end

    if (type(name) ~= 'string') then
        return
    end

    if (commands.commands ~= nil and commands.commands[name] ~= nil) then
        error:print(_(CR(), 'commands', 'command_already_registered', name))

        if (commands.commands[name].suggestion ~= nil) then
            TCE('corev:chat:removeSuggestion', -1, ('/%s'):format(name))
        end
    end

    if (suggestion) then
        if (not suggestion.arguments) then suggestion.arguments = {} end
        if (not suggestion.help) then suggestion.help = '' end

        TCE('corev:chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
    end

    commands.commands[name] = {
        groups = groups,
        callback = callback,
        consoleAllowed = consoleAllowed,
        suggestion = suggestion
    }

    RegisterCommand(name, function(source, args, rawCommand)
        local identifiers = m('identifiers')

        if (type(source) == 'string') then source = tonumber(source) end
        if (type(source) ~= 'number') then source = 0 end

        local identifier = identifiers:getIdentifier(source)
        local cmd = commands.commands[name]

        if (not cmd.consoleAllowed and source == 0) then
            error:print(_(CR(), 'commands', 'command_console_not_allowed', name))
            return
        end

        if (source > 0) then
            if (not IsPlayerAceAllowed(source, ('command.%s'):format(name))) then
                error:print(_(CR(), 'commands', 'command_not_allowed', name))
                return
            end
        end

        if (cmd.suggestion and #cmd.suggestion.arguments > 0) then
            if (cmd.suggestion.validate and #args ~= #cmd.suggestion.arguments) then
                TCE('corev:chat:addError', source, _(CR(), 'commands', 'command_mismatch_arguemnts', #cmd.suggestion.arguments, #args))
                return
            end
        end

        if (cmd.suggestion and #(cmd.suggestion.arguments or {}) > 0) then
            local newArguments = {}

            for i, argument in pairs(cmd.suggestion.arguments or {}) do
                if (argument.type) then
                    if (string.lower(argument.type) == 'number') then
                        local newArgument = tonumber(args[i])

                        if (newArgument) then
                            newArguments[argument.name] = newArgument
                        else
                            TCE('corev:chat:addError', source, _(CR(), 'commands', 'command_argument_number_error', i))
                            return
                        end
                    elseif (string.lower(argument.type) == 'string') then
                        newArguments[argument.name] = tostring(args[i])
                    elseif (string.lower(argument.type) == 'any') then
                        newArguments[argument.name] = args[i]
                    end
                end
            end

            args = newArguments
        end

        log(identifier, {
            args = {
                command = name,
                arguments = args
            },
            action = 'execute.command',
            color = Colors.Blue,
            footer = ('command "%s" | %s | %s'):format(name, '{identifier}', currentTimeString()),
            message = _(CR(), 'commands', 'command_message', '{playername}', name, json.encode(args)),
            title = _(CR(), 'commands', 'command_title', '{playername}'),
            username = ('[COMMAND] /%s LOG'):format(name)
        })

        cmd.callback(source, args, function(msg)
            if (msg ~= nil and type(msg) == 'string') then
                TCE('corev:chat:addError', source, msg)
            end
        end)
    end, true)

    if (groups and type(groups) == 'string') then
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(groups, name))
    elseif (groups and type(groups) == 'table') then
        for _, group in pairs(groups or {}) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(tostring(group), name))
        end
    end
end

--- Returns a list of commands available for player
--- @param playerId number Player ID (source)
function commands:getPlayerCommands(playerId)
    if (playerId == nil or type(playerId) ~= 'number') then return {} end

    if (playerId ~= 0) then
        local _commands = {}

        for name, command in pairs(self.commands or {}) do
            if (IsPlayerAceAllowed(playerId, ('commands.%s'):format(name))) then
                table.insert(_commands, {
                    name = name,
                    suggestion = command.suggestion or {}
                })
            end
        end

        return _commands
    end

    return {}
end

addModule('commands', commands)