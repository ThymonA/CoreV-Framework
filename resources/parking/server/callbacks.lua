--- Load player's cars
registerCallback('corev:parking:loadCars', function(source, cb, category)
    while not resource.tasks.frameworkLoaded do
        Citizen.Wait(0)
    end

    local database = m('database')
    local players = m('players')

    local player = players:getPlayer(source)

    if (player ~= nil) then
        database:fetchAllAsync('SELECT * FROM `player_vehicles` WHERE `player_id` = @playerId AND `type` = @type ORDER BY `brand` ASC', {
            ['@playerId'] = player.id,
            ['@type'] = 'car'
        }, function(results)
            local vehicles = {}

            if (results == nil or type(results) ~= 'table' or #results <= 0) then
                cb(vehicles)
                return
            end

            for _, vehicle in pairs(results or {}) do
                table.insert(vehicles, {
                    plate = vehicle.plate,
                    name = vehicle.name,
                    vehicle = vehicle.vehicle,
                    status = 1
                })
            end

            cb(vehicles)
        end)
    else
        cb({})
    end
end)