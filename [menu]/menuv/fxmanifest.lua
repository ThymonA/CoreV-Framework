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
name '[CVF] CoreV Framework'
version '1.0.0'
description 'Core resource of CoreV Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'

---
--- Load client files
---
files {
    'html/*.html',
    'html/assets/css/*.css',
    'html/assets/js/*.js',
    'html/assets/images/*.png',
    'html/assets/images/*.jpg',
    'html/assets/images/*.jpeg',
    'html/assets/images/*.gif',
    'translations/*.json'
}

---
--- Main .html file
---
ui_page 'html/menuv.html'

---
--- Register server scripts
---
server_scripts {
    '@corev/server/import.lua',
    'server/main.lua'
}

---
--- Load translations
---
translations {
    'translations/nl.json',
    'translations/en.json'
}