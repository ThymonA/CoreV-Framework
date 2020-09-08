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
local commands = m('commands')

commands:register('setjob', { 'superadmin' }, function(source, arguments, showError)
    local playerId = source

    if (source <= 0) then
        showError(_(CR(), 'jobs', 'console_not_allowed'))
        return
    end
end)