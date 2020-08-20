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

--- Create a log object
--- @param player int|string Player
function logs:createLog(player)
    local log, identifiers = class('log'), m('identifiers')
    local source = -1
    local identifier = identifiers:getPlayer(player)

    if (identifier == nil) then
        return nil
    end

    if (logs.players ~= nil and logs.players[identifier.identifier] ~= nil) then
        if (type(player) == 'number') then
            logs.players[identifier.identifier].source = player
        end

        return logs.players[identifier.identifier]
    end

    log:set {
        source = identifier.source,
        identifier = identifier.identifier,
        identifiers = identifier.identifiers,
        name = identifier.name,
        avatar = Config.DefaultAvatar or 'none',
        identifierObject = identifier
    }

    --- Load player's avatar
    function log:loadAvatar()
        local done = false
        local steamIdentifier = self.identifierObject:getByType('steam')

        if (steamIdentifier ~= 'none' and steamIdentifier ~= 'console' and steamIdentifier ~= 'unknown' and type(steamIdentifier) == 'string') then
            local steam64ID = tonumber(steamIdentifier, 16)
            local steamKey = GetConvar('steam_webApiKey', 'none') or 'none'

            if (type(steamKey) == 'string' and steamKey ~= 'none' and steamKey ~= '') then
                PerformHttpRequest(('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=%s&steamids=%s'):format(steamKey, steam64ID),
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
    end

    --- Returns a player name
    function log:getName()
        return self.name or 'Unknown'
    end

    --- Returns a player source
    function log:getSource()
        return self.source or -1
    end

    --- Returns a player avatar
    function log:getAvatar()
        return self.avatar or Config.DefaultAvatar or 'none'
    end

    --- Replate placeholders by tekst
    --- @param string string String to change
    function log:replacePlaceholders(string)
        if (string and type(string) == 'string') then
            string = string:gsub('{playername}', self.name)
            string = string:gsub('{identifier}', self.identifier)
        end

        return string
    end

    --- Log a event to database and/or discord
    --- @param object array event information
    --- @param fallback string webhook fallback
    function log:log(object, fallback)
        fallback = fallback or false

        local args = object.args or {}
        local action = object.action or 'none'
        local color = object.color or Colors.Grey
        local footer = object.footer or (self.identifier .. ' | ' .. action .. ' | ' .. currentTimeString())
        local message = object.message or nil
        local title = object.title or (self.name .. ' => ' .. action:gsub("^%l", string.upper))
        local username = '[Logs] ' .. self.name
        local webhook = getWebhooks(action, fallback)

        username = self:replacePlaceholders(username)
        title = self:replacePlaceholders(title)
        message = self:replacePlaceholders(message)
        footer = self:replacePlaceholders(footer)

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
    function log:logToDiscord(username, title, message, footer, webhooks, color, args)
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
    function log:logToDatabase(action, args)
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

    --- Initialize avartar
    log:loadAvatar()

    logs.players[log.identifier] = log

    return log
end

--- Create console logs
logs.players['console'] = logs:createLog(0)