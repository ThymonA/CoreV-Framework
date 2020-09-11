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
local chat = class('chat')

--- Refresh client commands and resturn all commands to client
--- @param source number Player ID (source)
function chat:refreshCommands(source)
    if (source == nil) then return end
    if (type(source) == 'string') then source = tonumber(source) end
    if (type(source) ~= 'number') then return end
    if (source == 0) then return end

    local commands = m('commands')
    local playerCommands = commands:getPlayerCommands(source) or {}

    TCE('corev:chat:addSuggestions', source, playerCommands, true)
end

onClientTrigger('corev:chat:messageEntered', function(name, message)
    if (not message or message == '' or not name or name == '') then
        return
    end

    TSE('chatMessage', source, name, message)

    if (not WasEventCanceled()) then
        TCE('corev:chat:addMessage', -1, name, message)
    end
end)

onClientTrigger('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)

    TSE('chatMessage', source, name, '/' .. command)

    if not WasEventCanceled() then
        TCE('corev:chat:addMessage', -1, name, '/' .. command)
    end

    CancelEvent()
end)

onClientTrigger('corev:chat:init', function()
    chat:refreshCommands(source)
end)

onServerTrigger('onServerResourceStart', function()
    local async = m('async')
    local players = GetPlayers()

    async:parallel(function(playerId, cb)
        Citizen.Wait(500)

        chat:refreshCommands(playerId)

        cb()
    end, players, function()
    end)
end)

onServerTrigger('onServerResourceStop', function()
    local async = m('async')
    local players = GetPlayers()

    async:parallel(function(playerId, cb)
        Citizen.Wait(500)

        chat:refreshCommands(playerId)

        cb()
    end, players, function()
    end)
end)