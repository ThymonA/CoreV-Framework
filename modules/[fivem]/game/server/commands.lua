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
local commands = m('commands')

--- Spawn a vehicle with /car {vehicle}
commands:register('car', { 'superadmin' }, function(source, arguments, showError)
    local playerId = source

    if (source <= 0) then
        showError(_(CR(), 'game', 'console_not_allowed'))
        return
    end

    if (arguments.name ~= nil and type(arguments.name) == 'string') then arguments.name = GetHashKey(arguments.name) end
    if (arguments.name == nil or type(arguments.name) ~= 'number') then
        showError(_(CR(), 'game', 'empty_or_invalid_name'))
        return
    end

    TCE('corev:game:spawnVehicle', playerId, arguments.name)
end, false, {
    help = _(CR(), 'game', 'help_car'),
    validate = true,
    arguments = {
        { name = 'name', help = _(CR(), 'game', 'vehicle_name'), type = 'any' }
    }
})