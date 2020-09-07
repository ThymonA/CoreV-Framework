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
---
--- Default information about supported games and versions
---
fx_version 'adamant'
game 'gta5'

---
--- Information about this resource (Custom Framework)
---
name 'CoreV'
version '1.0.0'
description 'Custom FiveM Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'


---
--- Default FiveM server_scripts
---
server_scripts {
    'vendors/regex.lua',
    'vendors/class.lua',
    'vendors/async.lua',
    'vendors/mustache.lua',

    'configs/shared_config.lua',
    'configs/others/brands_config.lua',
    'configs/others/vehicle_config.lua',
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
    'server/libs/compiler.lua',

    'server/functions.lua',
    'server/main.lua'
}

---
--- These files will later be placed in `corev_client` resource manifest as `client_scripts`
---
corevclients {
    'vendors/regex.lua',
    'vendors/class.lua',
    'vendors/entityiter.lua',
    'vendors/mustache.lua',

    'configs/shared_config.lua',
    'configs/others/brands_config.lua',
    'configs/others/vehicle_config.lua',
    'configs/client_config.lua',

    'libs/common.lua',
    'libs/framework/functions.lua',
    'libs/modules/cache.lua',
    'libs/modules/error.lua',
    'libs/framework/events.lua',
    'libs/framework/modules.lua',
    'libs/enums/markers.lua',
    'libs/enums/resource.lua',
    'libs/enums/vehicle.lua',

    'client/libs/callbacks.lua',
    'client/libs/resources.lua',
    'client/classes/menu.lua',
    'client/libs/menus.lua',

    'client/main.lua'
}

---
--- These files will later be placed in `corev_client` resource manifest as `files`
---
corevfiles {
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
    'hud/**/*.css',
    'hud/**/*.png',
    'hud/**/*.js',
    'hud/ui.html',
    'hud/assets/css/*.css',
    'hud/assets/images/*.png',
    'hud/assets/js/*.js',
    'langs/*.json'
}

---
--- These files will later be placed in `corev_client` resource manifest as `ui_page`
---
corevuipage 'hud/ui.html'

---
--- All modules with priority over other modules, load it first in the specified order,
--- modules not listed will be loaded after this list in a random order.
---
corevmodules {
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

---
--- All resources with priority over other resources, load it first in the specified order,
--- resources not listed will be loaded after this list in a random order.
---
corevresources {
    'parking'
}