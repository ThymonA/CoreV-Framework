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

chat:set {
    inputActive = false,
    inputActivating = false,
    hidden = false,
    loaded = false
}

onServerTrigger('corev:chat:addSuggestion', function(name, help, params)
    SendNUIMessage({
        action = 'ADD_SUGGESTION',
        suggestion = {
            name = name,
            help = help,
            params = params or {}
        },
        __resource = GetCurrentResourceName(),
        __module = 'chat'
    })
end)

onServerTrigger('corev:chat:addMessage', function(rawMessage)
    local message = {
        type = 'core-chat-' .. (rawMessage.type or 'ooc'),
        time = rawMessage.time or nil,
        icon = 'fa-' .. (rawMessage.icon or 'globe-europe'),
        sender = rawMessage.sender or 'Anoniem',
        message = rawMessage.message or ''
    }

    SendNUIMessage({
        action = 'ADD_MESSAGE',
        message = message,
        __resource = GetCurrentResourceName(),
        __module = 'chat'
    })
end)

onServerTrigger('corev:chat:addError', function(msg)
    local message = {
        type = 'core-chat-error',
        time = nil,
        icon = 'fa-exclamation-triangle',
        sender = 'ERROR',
        message = msg or ''
    }

    SendNUIMessage({
        action = 'ADD_MESSAGE',
        message = message,
        __resource = GetCurrentResourceName(),
        __module = 'chat'
    })
end)

onServerTrigger('corev:chat:removeSuggestion', function(name)
    SendNUIMessage({
        action = 'REMOVE_SUGGESTION',
        name = name,
        __resource = GetCurrentResourceName(),
        __module = 'chat'
    })
end)

onServerTrigger('corev:chat:addSuggestions', function(suggestions, removeAll)
    removeAll = removeAll or false

    if (type(removeAll) == 'string') then removeAll = tonumber(removeAll) end
    if (type(removeAll) == 'number') then removeAll = removeAll == 1 end
    if (type(removeAll) ~= 'boolean') then removeAll = false end

    SendNUIMessage({
        action = 'ADD_SUGGESTIONS',
        suggestions = suggestions,
        removeAll = removeAll,
        __resource = GetCurrentResourceName(),
        __module = 'chat'
    })
end)

onServerTrigger('corev:chat:clear', function()
    SendNUIMessage({
        action = 'CLEAR_CHAT',
        __resource = GetCurrentResourceName(),
        __module = 'chat'
    })
end)

RegisterNUICallback('chat_results', function(data, cb)
    chat.inputActive = false
    SetNuiFocus(false)

    if not data.canceled then
        local id = PlayerId()

        if data.message:sub(1, 1) == '/' then
            local commandParts = split(data.message, ' ')
            local command = (commandParts[1] or '/unknown'):sub(2)

            SendNUIMessage({
                action = 'ADD_MESSAGE',
                message = {
                    sender = 'Console',
                    time = nil,
                    message = _(CR(), 'chat', 'command_used', command),
                    iconlib = 'fas',
                    icon = 'fa-terminal',
                    type = 'core-chat-command'
                },
                __resource = GetCurrentResourceName(),
                __module = 'chat'
            })

            ExecuteCommand(data.message:sub(2))
        else
            TSE('corev:chat:messageEntered', GetPlayerName(id), data.message)
        end
    end

    cb('ok')
end)

RegisterNUICallback('chat_loaded', function(data, cb)
    TSE('corev:chat:init');

    chat.loaded = true

    cb('ok')
end)

--- Thread to manage game input
Citizen.CreateThread(function()
    SetTextChatEnabled(false)
    SetNuiFocus(false)

    while true do
        Citizen.Wait(0)

        if ((not chat.inputActive) and IsControlPressed(0, 245)) then
            chat.inputActive = true
            chat.inputActivating = true

            SendNUIMessage({
                action = 'OPEN_CHAT',
                __resource = GetCurrentResourceName(),
                __module = 'chat'
            })
        end

        if (chat.inputActivating and (not IsControlPressed(0, 245))) then
            SetNuiFocus(true)

            chat.inputActivating = false
        end

        if (chat.loaded) then
            local shouldBeHidden = false

            if (IsScreenFadedOut() or IsPauseMenuActive()) then
                shouldBeHidden = true
            end

            if ((shouldBeHidden and not chat.hidden) or (not shouldBeHidden and chat.hidden)) then
                chat.hidden = shouldBeHidden

                SendNUIMessage({
                    type = 'CHANGE_STATE',
                    shouldHide = shouldBeHidden,
                    __resource = GetCurrentResourceName(),
                    __module = 'chat'
                })
            end
        end
    end
end)