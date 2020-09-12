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
Config.OS               = 'linux'
Config.DatabaseName     = 'corev'

-------------------------
--- Permission Groups ---
-------------------------
Config.PermissionGroups = {
    'superadmin'
}

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
    ['connection.disconnect'] = {
        'https://discordapp.com/api/webhooks/745233064266956880/7u9qFNQE09q1hReYfYcfQ5L-X3XvyJPHGoHnhIZn7jTM92NRaDGj-A8Jx1QGvyvCxLVD'
    },
    ['execute'] = {
        'https://discordapp.com/api/webhooks/744228535115186296/9NKlvtxajH--ga52IoHHsXYdeeN4uXf1lkETrswYd3wlqyrRFn4XE6b043zGo8pPAjDi'
    },
    ['player.job'] = {
        'https://discordapp.com/api/webhooks/754306754355003453/uznoR98VO4rLd60UrhrFreYL8bb6rSkVYaQnW-Fwm6KWn1vFI0qsHhKeem6Noa9F_niQ'
    },
    ['player.job2'] = {
        'https://discordapp.com/api/webhooks/754306754355003453/uznoR98VO4rLd60UrhrFreYL8bb6rSkVYaQnW-Fwm6KWn1vFI0qsHhKeem6Noa9F_niQ'
    }
}

--- When webhook don't exists, this webhook will be used
Config.FallbackWebhook = ''