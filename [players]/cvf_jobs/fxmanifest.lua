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
name '[CVF] Job Resource'
version '1.0.0'
description 'Job resource for CoreV Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'

---
--- Load client files
---
files {
    'translations/*.json'
}

---
--- Register server scripts
---
server_scripts {
    '@corev/server/import.lua',
    'classes/job.lua',
    'server/main.lua'
}

---
--- Load translations
---
translations {
    'translations/nl.json',
    'translations/en.json'
}


---
--- Register all dependencies
---
dependencies {
    'cvf_utils',
    'cvf_translations'
}