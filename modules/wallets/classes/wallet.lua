--- Returns if wallet exists and wallet default values
--- @param name string Wallet name
function wallets:getDefaultWallet(name)
    if (name == nil or name ~= 'string') then return false, 'unknown', 0 end

    for key, value in pairs(Config.Wallets or {}) do
        if (key == string.lower(name)) then
            return true, key, value
        end
    end

    return false, 'unknown', 0
end

--- Create a wallet object
--- @param source int Player ID
--- @param name string Wallet Name
function wallets:createWallet(identifier, name, balance)
    --- Create a wallet object
    local db = m('database')
    local wallet = class('wallet')
    local walletExists, walletName, walletDefaultBalance = self:getDefaultWallet(name)

    if (source == nil or not walletExists) then return nil end
    if (identifier == 'none') then return nil end

    local playerId = db:fetchScalar('SELECT `id` FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['@identifier'] = identifier
    })

    if (playerId == nil) then return nil end

    --- Set default wallet info
    wallet:set {
        identifier = identifier,
        name = walletName,
        balance = balance or walletDefaultBalance or 0,
        playerId = playerId
    }

    if (balance == nil) then
        local walletBalance = db:fetchScalar('SELECT `balance` FROM `wallets` WHERE `name` = @name AND `player_id` = @player_id', {
            ['@name'] = walletName,
            ['@player_id'] = playerId
        })
    
        if (walletBalance == nil) then
            db:execute('INSERT INTO `wallets` (`player_id`, `name`, `balance`) VALUES (@player_id, @name, @balance)', {
                ['@player_id'] = playerId,
                ['@name'] = walletName,
                ['@balance'] = walletDefaultBalance
            })
    
            walletBalance = walletDefaultBalance
        end

        wallet.balance = walletBalance
    end

    --- Returns wallet balance
    function wallet:getBalance()
        return self.balance or 0
    end

    --- Add money to wallet balance
    --- @param money int Amount of money
    function wallet:addMoney(money)
        if (money == nil) then money = 0 end
        if (type(money) == 'string') then money = tonumber(money) end
        if (type(money) ~= 'number') then money = 0 end

        money = round(money)

        if (money <= 0) then
            return
        end

        log(self.identifier, {
            args = {
                balance = self.balance,
                amount = money,
                name = self.name
            },
            action = 'wallet.add'
        })

        self.balance = (self.balance + money)
        self:save()
    end

    --- Remove money from wallet balance
    --- @param money int Amount of money
    function wallet:removeMoney(money)
        if (money == nil) then money = 0 end
        if (type(money) == 'string') then money = tonumber(money) end
        if (type(money) ~= 'number') then money = 0 end

        money = round(money)

        if (money <= 0) then
            return
        end

        log(self.identifier, {
            args = {
                balance = self.balance,
                amount = money,
                name = self.name
            },
            action = 'wallet.remove'
        })

        self.balance = (self.balance - money)
        self:save()
    end

    --- Set wallet balance
    --- @param money int Amount to set balance
    function wallet:setMoney(money)
        if (money == nil) then money = 0 end
        if (type(money) == 'string') then money = tonumber(money) end
        if (type(money) ~= 'number') then money = 0 end

        money = round(money)

        if (money <= 0) then
            return
        end

        log(self.identifier, {
            args = {
                balance = self.balance,
                amount = money,
                name = self.name
            },
            action = 'wallet.set'
        })

        self.balance = money
        self:save()
    end

    --- Save wallet to database
    function wallet:save()
        local database = m('database')

        database:execute('UPDATE `wallets` SET `balance` = @balance WHERE `name` = @name AND `player_id` = @player_id', {
            ['@balance'] = self.balance,
            ['@name'] = self.name,
            ['@player_id'] = self.playerId
        })
    end

    return wallet
end