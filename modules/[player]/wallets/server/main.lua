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
local wallets = class('wallets')

--- Set default value
wallets:set {
    players = {}
}

--- Load a player wallet
--- @param player int|string Player
function wallets:getWallet(player, name)
    local identifiers = m('identifiers')
    local identifier = 'none'

    if (player == nil or (type(player) == 'number' and player == 0) or (type(player) == 'string' and player == 'console')) then
        identifier = 'console'
    elseif(player ~= nil and (type(player) == 'number' and player > 0)) then
        identifier = identifiers:getIdentifier(player)
    else
        identifier = player
    end

    if (identifier ~= 'none' and wallets.players ~= nil and wallets.players[identifier] ~= nil and wallets.players[identifier][walletName] ~= nil) then
        return wallets.players[identifier][walletName]
    end

    if (identifier == 'none') then
        return nil
    end

    return self:createWallet(player, name)
end

addModule('wallets', wallets)