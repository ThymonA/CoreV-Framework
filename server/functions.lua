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

--- Returns a webhook by action
--- @param action string Action
--- @param fallback string fallback webhook
local function getWebhooks(action, fallback)
    action = string.lower(action or 'none')

    if (Config.Webhooks ~= nil and Config.Webhooks[action] ~= nil) then
        return Config.Webhooks[action]
    end

    local actionParts = split(action, '.')

    table.remove(actionParts, #actionParts)

    if (actionParts ~= nil and #actionParts > 0) then
        local newAction = ''

        for i = 1, #actionParts, 1 do
            if (i == 1) then
                newAction = actionParts[i]
            else
                newAction = newAction .. '.' .. actionParts[i]
            end
        end

        return getWebhooks(newAction)
    end

    if (fallback ~= nil and fallback) then
        return Config.FallbackWebhook
    end

    return nil
end

--- Log a event with module `logs`
--- @param player int|string Player
--- @param object array Log info
--- @param fallback string|boolean Use fallback
local function log(player, object, fallback)
    local logs = m('logs')

    if (logs == nil) then return end

    local playerLogObject = logs:get(player)

    if (playerLogObject == nil) then return end

    playerLogObject:log(object or {}, (fallback or false))
end

-- FiveM maniplulation
_ENV.getWebhooks = getWebhooks
_G.getWebhooks = getWebhooks
_ENV.log = log
_G.log = log