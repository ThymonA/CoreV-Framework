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

--- Create a player object
--- @param int|string Player
function players:createPlayer(_player)
    local player = class('player')
    local identifiers, database, jobs = m('identifiers'), m('database'), m('jobs')
    local identifier, playerName = 'none', 'Unknown'

    if (_player == nil or (type(_player) == 'number' and _player == 0) or (type(_player) == 'string' and _player == 'console')) then
        identifier = 'console'
        playerName = 'Console'
    elseif(_player ~= nil and (type(_player) == 'number' and _player > 0)) then
        identifier = identifiers:getIdentifier(_player)
        playerName = GetPlayerName(_player)
    else
        identifier = _player
    end

    if (identifier == 'none') then
        return nil
    end

    if (players.players ~= nil and  players.players[identifier] ~= nil) then
        return players.players[identifier]
    end

    local playerCount = database:fetchScalar("SELECT COUNT(*) AS `count` FROM `players` WHERE `identifier` = @identifier", {
        ['@identifier'] = identifier
    })

    if (playerCount <= 0) then
        local unemployedJobs = jobs:getJobByName('unemployed')
        local unemployedGrade = unemployedJobs:getGradeByName('unemployed')

        database:execute('INSERT INTO `players` (`identifier`, `accounts`, `job`, `grade`, `job2`, `grade2`) VALUES (@identifier, @accounts, @job, @grade, @job2, @grade2)', {
            ['@identifier'] = playerIdentifier:getIdentifier(),
            ['@name'] = playerName,
            ['@job'] = unemployedJobs.id,
            ['@grade'] = unemployedGrade.grade,
            ['@job2'] = unemployedJobs.id,
            ['@grade2'] = unemployedGrade.grade,
        })

        print(_(CR(), 'players', 'player_created', playerName))

        return self:createPlayer(_player)
    end

    local playerData = database:fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['@identifier'] = identifier
    })[1]

    local job = jobs:getJob(playerData.job)
    local grade = job:getGrade(playerData.grade)
    local job2 = jobs:getJob(playerData.job2)
    local grade2 = job2:getGrade(playerData.grade2)

    if (type(_player) ~= 'number') then
        playerName = playerData.name
    end

    player:set {
        id = playerData.id,
        identifier = identifier,
        name = playerName,
        job = job,
        grade = grade,
        job2 = job2,
        grade2 = grade2,
        wallets = {}
    }

    local walletResults = {}
    local wallets = m('wallets')

    for walletName, defaultBalance in pairs(Config.Wallets or {}) do
        local wallet = wallets:getWallet(player.identifier, walletName)

        walletResults[wallet.name] = wallet
    end

    player.wallets = walletResults

    function player:save()
        local database = m('database')

        database:execute('UPDATE `players` SET `name` = @name, `job` = @job, `grade` = @grade, `job2` = @job2, `grade2` = @grade2 WHERE `identifier` = @identifier', {
            ['@name'] = self.name,
            ['@job'] = self.job.id,
            ['@grade'] = self.grade.grade,
            ['@job2'] = self.job2.id,
            ['@grade2'] = self.grade2.grade,
            ['@identifier'] = self.identifier
        })
    end

    --- Set money for player wallet
    --- @param name string wallet name
    --- @param money number balace of wallet
    function player:setWallet(name, money)
        if (name == nil or type(name) ~= 'string') then name = 'unknown' end
        if (money == nil or type(money) ~= 'number') then money = tonumber(money) or 0 end

        name = string.lower(name)

        if (self.wallets ~= nil and self.wallets[name] ~= nil) then
            self.wallets[name]:setBalance(money)
        end
    end

    --- Remove money from player wallet
    --- @param name string wallet name
    --- @param money number amount of money to remove
    function player:removeMoney(name, money)
        if (name == nil or type(name) ~= 'string') then name = 'unknown' end
        if (money == nil or type(money) ~= 'number') then money = tonumber(money) or 0 end

        name = string.lower(name)

        if (self.wallets ~= nil and self.wallets[name] ~= nil) then
            self.wallets[name]:removeMoney(money)
        end
    end

    --- Add money to player wallet
    --- @param name string wallet name
    --- @param money number amount of money to add
    function player:addMoney(name, money)
        if (name == nil or type(name) ~= 'string') then name = 'unknown' end
        if (money == nil or type(money) ~= 'number') then money = tonumber(money) or 0 end

        name = string.lower(name)

        if (self.wallets ~= nil and self.wallets[name] ~= nil) then
            self.wallets[name]:addMoney(money)
        end
    end

    --- Change player's primary job
    --- @param name string Job name
    --- @param grade number Grade
    function player:setJob(name, grade, cb)
        if (name == nil or type(name) ~= 'string') then name = 'unknown' end
        if (grade == nil or type(grade) ~= 'number') then grade = tonumber(grade) or 0 end

        local jobs = m('jobs')
        local job = jobs:getJobByName(name)

        if (job == nil) then
            if (cb ~= nil) then cb(false, _(CR(), 'players', 'job_empty_error')) end
            return
        end

        local jobGrade = job:getGrade(grade)

        if (jobGrade == nil) then
            if (cb ~= nil) then cb(false, _(CR(), 'players', 'grade_empty_error')) end
            return
        end

        self.job = job
        self.grade = jobGrade

        if (self.id ~= nil and self.id > 0) then
            TCE('corev:players:setJob', self.id, self.job, self.grade)
        end

        TSE('corev:players:setJob', self.identifier, self.job, self.grade)

        self:save()

        log(self.identifier, {
            title = _(CR(), 'players', 'job_set_title', self.name),
            color = Colors.Yellow,
            message = _(CR(), 'players', 'job_set_message', self.name, self.job.name, self.grade.name, self.grade.grade),
            args = {
                job = self.job.name,
                grade = self.grade.grade,
                name = self.grade.name
            },
            action = 'player.job.set'
        })

        if (cb ~= nil) then cb(true, '') end
    end

    --- Change player's secondary job
    --- @param name string Job name
    --- @param grade number Grade
    function player:setJob2(name, grade)
        if (name == nil or type(name) ~= 'string') then name = 'unknown' end
        if (grade == nil or type(grade) ~= 'number') then grade = tonumber(grade) or 0 end

        local jobs = m('jobs')
        local job = jobs:getJobByName(name)

        if (job == nil) then
            if (cb ~= nil) then cb(false, _(CR(), 'players', 'job_empty_error')) end
            return
        end

        local jobGrade = job:getGrade(grade)

        if (jobGrade == nil) then
            if (cb ~= nil) then cb(false, _(CR(), 'players', 'grade_empty_error')) end
            return
        end

        self.job2 = job
        self.grade2 = jobGrade

        if (self.id ~= nil and self.id > 0) then
            TCE('corev:players:setJob2', self.id, self.job2, self.grade2)
        end

        TSE('corev:players:setJob2', self.identifier, self.job2, self.grade2)

        self:save()

        log(self.identifier, {
            title = _(CR(), 'players', 'job2_set_title', self.name),
            color = Colors.Yellow,
            message = _(CR(), 'players', 'job2_set_message', self.name, self.job2.name, self.grade2.name, self.grade2.grade),
            args = {
                job = self.job2.name,
                grade = self.grade2.grade,
                name = self.grade2.name
            },
            action = 'player.job2.set'
        })

        if (cb ~= nil) then cb(true, '') end
    end

    player:save()

    players.players[player.identifier] = player

    return player
end