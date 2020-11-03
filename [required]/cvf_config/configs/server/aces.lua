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
local config = {}

config.groups = {}

--- List all aces/permissions where group `user` has access to
config.groups.user = {
    parent = nil,
    permissions = {}
}

--- List all aces/permissions where group `console` has access to
config.groups.console = {
    parent = config.groups.user,
    permissions = {
        'admin.*'
    }
}

--- List all aces/permissions where group `superadmin` has access to
config.groups.superadmin = {
    parent = config.groups.console,
    permissions = {
        '*'
    }
}

return config