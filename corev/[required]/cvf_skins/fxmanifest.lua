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

---
--- Information about this resource
---
name '[CVF] Skin Resource'
version '1.0.0'
description 'Skin resource for CoreV Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'

---
--- Load client files
---
files {
    'data/tattoos_female.lua',
    'data/tattoos_male.lua'
}

---
--- Register client scripts
---
client_scripts {
    '@corev/client/import.lua',
    'classes/tattoo.lua',
    'classes/skin_funcs.lua',
    'classes/skin.lua',
    'client/main.lua'
}

---
--- Register server scripts
---
server_scripts {
    '@corev/server/import.lua',
    'server/main.lua'
}

---
--- Register all dependencies
---
dependencies {
    'cvf_translations'
}