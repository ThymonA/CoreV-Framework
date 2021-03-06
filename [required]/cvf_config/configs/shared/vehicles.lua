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

--- Vehicle configuration
config.vehicles = {
    ['hevo'] = {
        price = 325000,
        name = 'Huracan Evo',
        label = '2020 Huracan Evo Spyder',
        brand = 'lamborghini',
        type = 'car'
    },
    ['rs62'] = {
        price = 275000,
        name = 'Audi RS6',
        label = 'Audi RS6 Avant',
        brand = 'audi',
        type = 'car'
    }
}

return config