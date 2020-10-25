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

--- Brand configuration
config.brands = {
    ['audi'] = {
        brand = 'audi',
        label = 'Audi',
        logos = {
            square_small = 'https://i.imgur.com/UU9H34O.png', -- 250px x 250px
            square_large = 'https://i.imgur.com/HS9exOd.png' -- 750px x 750px
        }
    },
    ['lamborghini'] = {
        brand = 'lamborghini',
        label = 'Lamborghini',
        logos = {
            square_small = 'https://i.imgur.com/BJmQlZA.png', -- 250px x 250px
            square_large = 'https://i.imgur.com/l4smrcd.png' -- 750px x 750px
        }
    }
}

return config