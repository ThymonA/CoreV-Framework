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
fx_version 'adamant'
game 'gta5'

name 'CoreV'
version '1.0.0'
description 'Custom FiveM Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'

ui_page 'hud/ui.html'
ui_page_preload 'yes'

files {
    'modules/**/module.json',
    'modules/**/client/**/*.lua',
    'modules/**/langs/**/*.json',
    'modules/**/client/**/client_*.lua',
    'modules/**/html/**/*',
    'modules/**/html/**/*.png',
    'modules/**/html/**/*.jpg',
    'modules/**/html/**/*.html',
    'modules/**/html/**/*.js',
    'modules/**/html/**/*.css',
    'resources/**/module.json',
    'resources/**/client/**/*.lua',
    'resources/**/langs/**/*.json',
    'resources/**/client/**/client_*.lua',
    'resources/**/html/**/*',
    'resources/**/html/**/*.png',
    'resources/**/html/**/*.jpg',
    'resources/**/html/**/*.html',
    'resources/**/html/**/*.js',
    'resources/**/html/**/*.css',
    'hud/**/*'
}

client_scripts {
    'shared/functions.lua',

    '@NativeUI/NativeUI.lua',
    'vendors/regex.lua',
    'vendors/class.lua',
    'vendors/entityiter.lua',

    'configs/shared_config.lua',
    'configs/client_config.lua',

    'libs/common.lua',
    'libs/framework/functions.lua',
    'libs/modules/cache.lua',
    'libs/modules/error.lua',
    'libs/framework/events.lua',
    'libs/framework/modules.lua',
    'libs/enums/*.lua',

    'client/libs/callbacks.lua',
    'client/libs/resources.lua',
    'client/libs/menus.lua',

    'client/main.lua'
}

server_scripts {
    'shared/functions.lua',

    'vendors/regex.lua',
    'vendors/class.lua',

    'configs/shared_config.lua',
    'configs/server_config.lua',

    'libs/common.lua',
    'libs/framework/functions.lua',
    'libs/modules/cache.lua',
    'libs/modules/error.lua',
    'libs/framework/events.lua',
    'libs/framework/modules.lua',
    'libs/enums/*.lua',

    'server/libs/callbacks.lua',
    'server/libs/resources.lua',

    'server/functions.lua',
    'server/main.lua'
}

modules {
    'spawnmanager',
    'database',
    'identifiers',
    'logs',
    'commands',
    'wallets',
    'jobs',
    'players',
    'streaming',
    'markers',
    'game'
}

resources {
    'garage'
}

exports {
	'getFrameworkCore'
}

server_exports {
	'getFrameworkCore'
}