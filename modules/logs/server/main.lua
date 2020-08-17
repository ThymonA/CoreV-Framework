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
--- @param player int Player ID
function logs:create(player)
    local playerLog = class('playerlog')
    local identifierModule, database = m('identifiers'), m('database')
    local playerIdentifiers = identifierModule:getPlayer(player)
    local steamIdentifier = playerIdentifiers:getByType('steam')
    local playerName = 'unknown'

    --- Set default values
    playerLog:set {
        source = nil,
        name = 'Unknown',
        identifier = {},
        identifiers = {},
        avatar = Config.DefaultAvatar or 'none'
    }

    if (player == nil or (type(player) == 'number' and player == 0) or (type(player) == 'string' and player == 'console')) then
        playerLog.source = 0
        playerLog.name = 'console'
        playerLog.identifier = 'console'
        playerLog.identifiers = {
            'steam:console',
            'license:console',
            'live:console',
            'xbl:console',
            'fivem:console',
            'discord:console',
            'ip:127.0.0.1'
        }
    elseif(player ~= nil and (type(player) == 'number' and player > 0)) then
        playerLog.source = player
        playerLog.name = GetPlayerName(player)
        playerLog.identifier = playerIdentifiers:getIdentifier()
        playerLog.identifiers = playerIdentifiers:getIdentifiers()
    elseif(player ~= nil and (type(player) == 'string' and player ~= 'none')) then
        local playerInfo = database:fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier', {
            ['@identifier'] = player
        })

        if (playerInfo == nil or #playerInfo <= 0) then
            playerLog.name = 'Unknown'
        else
            playerLog.name = playerInfo[1].name
        end

        playerLog.identifier = player
        playerLog.identifiers = { player }
    end

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
        return self.source or -1
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

    logs.players[playerLog.identifier] = playerLog

    return playerLog
end

--- Get a log object by source
--- @param player int Player ID
function logs:get(player)
    if (type(player) == 'number') then
        for identifier, playerLog in pairs(logs.players or {}) do
            if (playerLog.source == player) then
                return playerLog
            end
        end
        
        return logs:create(player)
    end

    if (type(player) == 'string') then
        if (logs.players ~= nil and logs.players[player] ~= nil) then
            return logs.players[player]
        end

        return logs:create(player)
    end

    return nil
end

--- Create console logs
logs.players['console'] = logs:create(0)

--- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError)
    local playerLog = logs:create(source)

    logs.players[playerLog.identifier] = playerLog

    playerLog:log({
        title = _(CR(), 'logs', 'player_connecting_title', playerLog:getName()),
        action = 'connection.connecting',
        color = Colors.Orange,
        message = _(CR(), 'logs', 'player_connecting', playerLog:getName())
    })

    returnSuccess()
end)

--- Trigger when player is fully connected
onPlayerConnected(function(source, returnSuccess, returnError)
    local found, identifiers = false, m('identifiers')
    local identifier = identifiers:getIdentifier(source)

    logs.players[identifier]:log({
        title = _(CR(), 'logs', 'player_connected_title', playerLog:getName()),
        action = 'connection.connected',
        color = Colors.Green,
        message = _(CR(), 'logs', 'player_connected', playerLog:getName())
    })

    returnSuccess()
end)

addModule('logs', logs)