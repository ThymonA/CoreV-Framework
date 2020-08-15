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
            self:register(_name, groups, callback, consoleAllowed)
        end

        return
    end

    if (type(name) ~= 'string') then
        return
    end

    if (commands.commands ~= nil and commands.commands[name] ~= nil) then
        error:print(_(CR(), 'commands', 'command_already_registered', name))

        if (commands.commands[name].suggestion ~= nil) then
            TCE('core:chat:removeSuggestion', -1, ('/%s'):format(name))
        end
    end

    if (suggestion) then
        if (not suggestion.arguments) then suggestion.arguments = {} end
        if (not suggestion.help) then suggestion.help = '' end

        TCE('core:chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
    end

    commands.commands[name] = {
        groups = groups,
        callback = callback,
        consoleAllowed = consoleAllowed,
        suggestion = suggestion
    }

    RegisterCommand(name, function(source, args, rawCommand)
        local playerName = 'unknown' 
        local identifiers = m('identifiers')
        local logs = m('logs')
        
        if (type(source) == 'string') then source = tonumber(source) end
        if (type(source) ~= 'number') then source = 0 end

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

        if (cmd.suggestion and #cmd.suggestion > 0) then
            if (cmd.suggestion.validate and #args ~= #cmd.suggestion.arguments) then
                TCE('core:chat:addError', source, _(CR(), 'commands', 'command_mismatch_arguemnts', #cmd.suggestion.arguments, #args))
                return
            end
        end

        if (cmd.suggestion and cmd.suggestion.arguments) then
            local newArguments = {}

            for _, argument in pairs(cmd.suggestion.arguments or {}) do
                if (argument.type) then
                    if (string.lower(argument.type) == 'number') then
                        local newArgument = tonumber(argument.type)

                        if (newArgument) then
                            newArguments[argument.name] = newArgument
                        else
                            TCE('core:chat:addError', source, _(CR(), 'commands', 'command_argument_number_error', _))
                            return
                        end
                    elseif (string.lower(argument.type) == 'string') then
                        newArguments[argument.name] = tostring(argument)
                    elseif (string.lower(argument.type) == 'any') then
                        newArguments[argument.name] = argument
                    end
                end
            end

            args = newArguments
        end

        local logger = logs:get(source)

        logger:log({
            args = args,
            action = 'execute.command',
            color = Colors.Blue,
            footer = ('command "%s" | %s | %s'):format(name, logger.identifier, currentTimeString()),
            message = _(CR(), 'commands', 'command_message', logger:getName(), name, json.encode(args)),
            title = _(CR(), 'commands', 'command_title', logger:getName()),
            username = ('[COMMAND] /%s LOG'):format(name)
        })

        cmd.callback(source, args)
    end, true)

    if (groups and type(groups) == 'string') then
        ExecuteCommand(('add_ace group.%s command.%s allow'):format(tostring(groups), name))
    elseif (groups and type(groups) == 'table') then
        for _, group in pairs(groups or {}) do
            ExecuteCommand(('add_ace group.%s command.%s allow'):format(tostring(group), name))
        end
    end
end

addModule('commands', commands)