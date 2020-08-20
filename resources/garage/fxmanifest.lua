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
fx_version 'adamant'
game 'gta5'

name 'CoreV'
version '1.0.0'
description 'Custom FiveM Framework'
author 'ThymonA'
contact 'contact@thymonarens.nl'
url 'https://git.thymonarens.nl/ThymonA/corev-framework/'

files {
    'module.json',
    'config/config.lua',
    'client/**/*.lua',
    'langs/**/*.json',
}

isModule 'true'