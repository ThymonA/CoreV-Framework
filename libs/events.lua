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
events = {
    onPlayerConnecting = {
        server = {}
    }
}

if (SERVER) then
    --- Trigger func when player is connecting
    --- @param func function Function to execute
    onPlayerConnecting = function(func)
        local module = CurrentFrameworkModule or 'unknown'

        table.insert(events.onPlayerConnecting.server, {
            module = module,
            func = func
        })
    end

    --- Trigger all player connecting events
    --- @param source int PlayerId
    triggerPlayerConnecting = function(source, deferrals)
        for _, playerConnectingEvent in pairs(events.onPlayerConnecting.server or {}) do
            try(function()
                local continue, error, error_message = false, false, ''
            
                playerConnectingEvent.func(source, function()
                    continue = true
                end, function(err_message)
                    continue = true
                    error = true
                    error_message = err_message or 'Unknown Error'
                end)

                while not continue do
                    Citizen.Wait(0)
                end

                if (error) then
                    deferrals.done(error_message)
                    return
                end
            end, function(err)
                deferrals.done('[SCRIPT ERROR]: ' .. err)
            end)
        end

        deferrals.done()
    end

    -- FiveM maniplulation
    _ENV.onPlayerConnecting = onPlayerConnecting
    _G.onPlayerConnecting = onPlayerConnecting
    _ENV.triggerPlayerConnecting = triggerPlayerConnecting
    _G.triggerPlayerConnecting = triggerPlayerConnecting
end