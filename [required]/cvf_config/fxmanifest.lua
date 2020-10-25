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
--- Information about this resource (CoreV Framework Config's)
---
name 'CoreV\'s Config'
version '1.0.0'
description 'Config resource for CoreV Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'

---
--- Client available files
---
files {
    'configs/client/*.lua',
    'configs/shared/*.lua'
}

---
--- Register client scripts
---
server_scripts {
    'shared/main.lua'
}

---
--- Register client scripts
---
client_scripts {
    'shared/main.lua'
}

dependencies {
    'cvf_ids'
}