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
Config.Markers = {
    ['cars'] = {
        ['spawn'] = {
            type = 1,
            color = '#00FF8B',
            size = vector3(1.5, 1.5, 0.5)
        },
        ['delete'] = {
            type = 1,
            color = '#FF3D33',
            size = vector3(5.0, 5.0, 0.5)
        }
    }
}

Config.Locations = {
    ['BP_PARKING'] = {
        type = 'cars',
        location = vector3(215.93, -809.83, 29.74),
        spawn = { x = 229.5, y = -798.46, z = 29.59, h = 162.5 },
        delete = vector3(227.02, -750.03, 29.82)
    },
    ['PILLBOX_HILL_PARKING_01'] = {
        type = 'cars',
        location = vector3(-281.95, -890.83, 30.07),
        spawn = { x = -282.32, y = -893.12, z = 30.07, h = 252.5 },
        delete = vector3(-278.88, -904.61, 30.07)
    },
    ['PILLBOX_HILL_PARKING_02'] = {
        type = 'cars',
        location = vector3(-349.08, -877.07, 30.07),
        spawn = { x = -348.79, y = -879.22, z = 30.07, h = 77.5 },
        delete = vector3(-360.52, -889.48, 30.07)
    }
}