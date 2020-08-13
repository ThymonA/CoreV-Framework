----------------------- [ FXCore ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/fx_core/
-- GitHub: https://github.com/ThymonA/FXCore/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
-- Name: FXCore
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ FXCore ] -----------------------
local logs = class('logs')

--- Set default values
logs:set {
    players = {}
}

--- Create a log object
--- @param source int Player ID
function logs:Create(source)
    local playerLog = class('playerlog')
    local identifierModule = m('identifiers')
    local playerIdentifiers = identifierModule:GetPlayer(source)
    local steamIdentifier = playerIdentifiers:GetByType('steam')

    --- Set default values
    playerLog:set {
        source = source,
        name = GetPlayerName(source),
        identifier = playerIdentifiers:GetIdentifier(),
        identifiers = playerIdentifiers:GetIdentifiers(),
        avatar = Config.DefaultAvatar or 'none'
    }

    --- Initialize avatar
    function playerLog:initialize()
        local done = false

        if (steamIdentifier ~= 'none' and steamIdentifier ~= 'console' and steamIdentifier ~= 'unknown' and type(steamIdentifier) == 'string') then
            local steam64ID = tonumber(steamIdentifier, 16)
            local steamKey = GetConvar('steam_webApiKey', 'none') or 'none'
        
            if (steamKey ~= 'none') then
                PerformHttpRequest('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. steamKey .. '&steamids=' .. steam64ID,
                    function(status, response, headers)
                        if (status == 200) then
                            local rawData = response or '{}'
                            local jsonData = json.decode(rawData)
    
                            if (not (not jsonData)) then
                                local players = (jsonData.response or {}).players or {}
    
                                if (players ~= nil and #players > 0) then
                                    self.avatar = players[1].avatarfull
                                    done = true
                                else
                                    done = true
                                end
                            else
                                done = true
                            end
                        else
                            done = true
                        end
                    end, 'GET', '', { ['Content-Type'] = 'application/json' })
            else
                done = true
            end
        else
            done = true
        end

        while not done do
            Wait(0)
        end

        return
    end

    --- Returns a player name
    function playerLog:GetName()
        return self.name or 'Unknown'
    end

    --- Returns a player id
    function playerLog:GetSource()
        return self.source or 0
    end

    --- Returns a player avatar
    function playerLog:GetAvatar()
        return self.avatar or Config.DefaultAvatar or 'none'
    end

    --- Log a player action
    function playerLog:Log(object, fallback)
        fallback = fallback or false

        local args = object.args or {}
        local action = object.action or 'none'
        local color = object.color or Colors.Grey
        local footer = object.footer or (self.identifier .. ' | ' .. action .. ' | ' .. currentTimeString())
        local message = object.message or nil
        local title = object.title or (self.name .. ' => ' .. action:gsub("^%l", string.upper))
        local username = '[Logs] ' .. self.name
        local webhook = getWebhooks(action, fallback)

        print(self:GetAvatar())

        if (webhook ~= nil) then
            self:LogToDiscord(username, title, message, footer, webhook, color, args)
        end

        self:LogToDatabase(action, object)
    end

    --- Log to discord
    --- @param username string Username
    --- @param title string Title
    --- @param message string Message
    --- @param footer string Footer
    --- @param webhooks string|array Webhook(s)
    --- @param color int Color
    --- @param args array Arguments
    function playerLog:LogToDiscord(username, title, message, footer, webhooks, color, args)
        if (webhooks ~= nil and type(webhooks) == 'table') then
            for _, webhook in pairs(webhooks or {}) do
                self:LogToDiscord(username, title, message, footer, webhook, color, args)
            end
        elseif (webhooks ~= nil and type(webhooks) == 'string') then
            color = color or 98707270

            local requestInfo = {
                ['color'] = color,
                ['type'] = 'rich'
            }

            if (title ~= nil and type(title) == 'string') then
                requestInfo['title'] = title
            end

            if (message ~= nil and type(message) == 'string') then
                requestInfo['description'] = message
            end

            if (footer ~= nil and type(footer) == 'string') then
                requestInfo['footer'] = {
                    ['text'] = footer
                }
            end

            PerformHttpRequest(webhooks, function(error, text, headers) end, 'POST', json.encode({ username = username, embeds = { requestInfo }, avatar_url = self:GetAvatar() }), { ['Content-Type'] = 'application/json' })
        end
    end

    --- Log to database
    --- @param action string Action
    --- @param args array Arguments
    function playerLog:LogToDatabase(action, args)
    end

    --- Intialize player avatar
    playerLog:initialize()

    return playerLog
end

-- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    local playerLog = logs:Create(source)

    logs.players[tostring(playerLog:GetSource())] = playerLog

    playerLog:Log({
        title = _(GetCurrentResourceName(), 'logs', 'player_connecting_title', playerLog:GetName()),
        action = 'connecting',
        color = Colors.Orange,
        message = _(GetCurrentResourceName(), 'logs', 'player_connecting', playerLog:GetName())
    })

    returnSuccess()
end)

module('logs', logs)