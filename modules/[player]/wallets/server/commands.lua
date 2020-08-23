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
local commands = m('commands')

commands:register('setwallet', { 'superadmin' }, function(source, arguments, showError)
    local playerId = arguments.playerId or 0

    if (playerId <= 0) then
        showError(_(CR(), 'wallets', 'invalid_playerId'))
        return
    end

    local players = m('players')
    local player = players:getPlayer(playerId)

    if (player == nil) then
        showError(_(CR(), 'wallets', 'invalid_playerId'))
        return
    end

    player:setWallet(arguments.name, arguments.saldo)
end, true, {
    help = _(CR(), 'wallets', 'help_setwallet'),
    validate = true,
    arguments = {
        { name = 'playerId', help = _(CR(), 'wallets', 'playerId'), type = 'number' },
        { name = 'name', help = _(CR(), 'wallets', 'wallet_name'), type = 'string' },
        { name = 'saldo', help = _(CR(), 'wallets', 'saldo'), type = 'number' }
    }
})

commands:register('addwallet', { 'superadmin' }, function(source, arguments, showError)
    local playerId = arguments.playerId or 0

    if (playerId <= 0) then
        showError(_(CR(), 'wallets', 'invalid_playerId'))
        return
    end

    local players = m('players')
    local player = players:getPlayer(playerId)

    if (player == nil) then
        showError(_(CR(), 'wallets', 'invalid_playerId'))
        return
    end

    player:addMoney(arguments.name, arguments.saldo)
end, true, {
    help = _(CR(), 'wallets', 'help_addwallet'),
    validate = true,
    arguments = {
        { name = 'playerId', help = _(CR(), 'wallets', 'playerId'), type = 'number' },
        { name = 'name', help = _(CR(), 'wallets', 'wallet_name'), type = 'string' },
        { name = 'saldo', help = _(CR(), 'wallets', 'saldo'), type = 'number' }
    }
})

commands:register('removewallet', { 'superadmin' }, function(source, arguments, showError)
    local playerId = arguments.playerId or 0

    if (playerId <= 0) then
        showError(_(CR(), 'wallets', 'invalid_playerId'))
        return
    end

    local players = m('players')
    local player = players:getPlayer(playerId)

    if (player == nil) then
        showError(_(CR(), 'wallets', 'invalid_playerId'))
        return
    end

    player:removeMoney(arguments.name, arguments.saldo)
end, true, {
    help = _(CR(), 'wallets', 'help_removewallet'),
    validate = true,
    arguments = {
        { name = 'playerId', help = _(CR(), 'wallets', 'playerId'), type = 'number' },
        { name = 'name', help = _(CR(), 'wallets', 'wallet_name'), type = 'string' },
        { name = 'saldo', help = _(CR(), 'wallets', 'saldo'), type = 'number' }
    }
})