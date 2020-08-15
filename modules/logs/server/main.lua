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
local logs = class('logs')

--- Set default values
logs:set {
    players = {}
}

--- Create a log object
--- @param source int Player ID
function logs:create(source)
    local playerLog = class('playerlog')
    local identifierModule = m('identifiers')
    local playerIdentifiers = identifierModule:getPlayer(source)
    local steamIdentifier = playerIdentifiers:getByType('steam')

    --- Set default values
    playerLog:set {
        source = source,
        name = GetPlayerName(source),
        identifier = playerIdentifiers:getIdentifier(),
        identifiers = playerIdentifiers:getIdentifiers(),
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
    function playerLog:getName()
        return self.name or 'Unknown'
    end

    --- Returns a player id
    function playerLog:getSource()
        return self.source or 0
    end

    --- Returns a player avatar
    function playerLog:getAvatar()
        return self.avatar or Config.DefaultAvatar or 'none'
    end

    --- Log a player action
    function playerLog:log(object, fallback)
        fallback = fallback or false

        local args = object.args or {}
        local action = object.action or 'none'
        local color = object.color or Colors.Grey
        local footer = object.footer or (self.identifier .. ' | ' .. action .. ' | ' .. currentTimeString())
        local message = object.message or nil
        local title = object.title or (self.name .. ' => ' .. action:gsub("^%l", string.upper))
        local username = '[Logs] ' .. self.name
        local webhook = getWebhooks(action, fallback)

        if (webhook ~= nil) then
            self:logToDiscord(username, title, message, footer, webhook, color, args)
        end

        self:logToDatabase(action, args)
    end

    --- Log to discord
    --- @param username string Username
    --- @param title string Title
    --- @param message string Message
    --- @param footer string Footer
    --- @param webhooks string|array Webhook(s)
    --- @param color int Color
    --- @param args array Arguments
    function playerLog:logToDiscord(username, title, message, footer, webhooks, color, args)
        if (webhooks ~= nil and type(webhooks) == 'table') then
            for _, webhook in pairs(webhooks or {}) do
                self:logToDiscord(username, title, message, footer, webhook, color, args)
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

            PerformHttpRequest(webhooks, function(error, text, headers) end, 'POST', json.encode({ username = username, embeds = { requestInfo }, avatar_url = self:getAvatar() }), { ['Content-Type'] = 'application/json' })
        end
    end

    --- Log to database
    --- @param action string Action
    --- @param args array Arguments
    function playerLog:logToDatabase(action, args)
        args = args or {}

        if (type(args) ~= 'table') then
            args = {}
        end

        local database = m('database')

        database:executeAsync('INSERT INTO `logs` (`identifier`, `name`, `action`, `args`) VALUES (@identifier, @name, @action, @args)', {
            ['@identifier'] = self.identifier,
            ['@name'] = self.name,
            ['@action'] = tostring(action),
            ['@args'] = json.encode(args)
        }, function() end)
    end

    --- Intialize player avatar
    playerLog:initialize()

    return playerLog
end

-- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    local playerLog = logs:create(source)

    logs.players[tostring(playerLog:getSource())] = playerLog

    playerLog:log({
        title = _(CR(), 'logs', 'player_connecting_title', playerLog:getName()),
        action = 'connecting',
        color = Colors.Orange,
        message = _(CR(), 'logs', 'player_connecting', playerLog:getName())
    })

    returnSuccess()
end)

addModule('logs', logs)