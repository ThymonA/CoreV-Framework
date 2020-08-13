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
fx_version 'adamant'
game 'gta5'

name 'FXCore'
description 'Custom FiveM Framework'
author 'ThymonA'
contact 'contact@thymonarens.nl'
url 'https://github.com/ThymonA/FXCore'

version '1.0.0'

server_scripts {
    'shared/functions.lua',

    'vendors/MySQL.lua',
    'vendors/regex.lua',
    'vendors/class.lua',

    'configs/shared_config.lua',
    'configs/server_config.lua',

    'shared/common.lua',
    'shared/functions.lua',

    'libs/events.lua',
    'libs/modules.lua',
    'libs/resources.lua',

    'server/functions.lua',
    'server/main.lua'
}

modules {
    'identifiers',
    'logs'
}