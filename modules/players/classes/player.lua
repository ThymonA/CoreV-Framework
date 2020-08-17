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

        return players:createPlayer(_player)
    end

    local playerData = database:fetchAll('SELECT * FROM `players` WHERE `identifier` = @identifier LIMIT 1', {
        ['@identifier'] = identifier
    })[1]

    local job = jobs:getJob(playerData.job)
    local grade = job:getGrade(playerData.grade)
    local job2 = jobs:getJob(playerData.job2)
    local grade2 = job:getGrade(playerData.grade2)

    if (type(_player) ~= 'number') then
        playerName = playerData.name
    end

    player:set {
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

    player:save()

    players.players[player.identifier] = player

    return player
end