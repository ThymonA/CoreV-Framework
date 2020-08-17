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
Config.OS               = 'windows'
Config.DatabaseName     = 'corev'

---------------
--- Wallets ---
---------------
Config.Wallets = {
    ['cash'] = 500,
    ['bank'] = 2500,
    ['crime'] = 0
}

------------------------
--- Discord Webhooks ---
------------------------
Config.Webhooks = {
    ['connection'] = {
        'https://discordapp.com/api/webhooks/744092761455722497/en3QUnePwO_6z14kfk9HIdWMpXpyzu7GwJv1pW3dAckabTB7ZgUarJvKPFKmChNlIUWd'
    },
    ['execute'] = {
        'https://discordapp.com/api/webhooks/744228535115186296/9NKlvtxajH--ga52IoHHsXYdeeN4uXf1lkETrswYd3wlqyrRFn4XE6b043zGo8pPAjDi'
    }
}

--- When webhook don't exists, this webhook will be used
Config.FallbackWebhook = ''