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

Config.ModeratorGroups = {
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
    },
    ['weapon'] = {
        'https://discordapp.com/api/webhooks/761168369659150356/tTRT7bmfBNQtW5zULMXb2Qv5SpdrRGus-SYMw5hsU68cre6-DSw1COHOICqek1-Tlbrn'
    },
    ['weapon.transfer'] = {
        'https://discordapp.com/api/webhooks/761168517977735168/sB3LG5y6VLknusLsjINGeDpmjXr7Su23ibF7yi2cMPFvTEWHd3JGAOKvf8W9gocolotC'
    },
    ['weapon.new'] = {
        'https://discordapp.com/api/webhooks/761168601080135721/RvuOwwfruS1Vrf4JsDhGjGvPObhpXfuOH1jNd0Hd9kQR2Y5n2sJU-4PG1xXFvU4KhXrS'
    },
    ['weapon.delete'] = {
        'https://discordapp.com/api/webhooks/761168681362915328/Du1HjMHSbUb6u_uTla4mTDs1e9AgNK-AeCmq28T7eONfzQeIzHx6OUB2OEMumVTNZww-'
    }
}

--- When webhook don't exists, this webhook will be used
Config.FallbackWebhook = ''