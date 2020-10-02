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
local weapons = class('weapons')

--- Set default values
weapons:set {
    players = {},
    jobs = {},
    weapons = {},
    loaded = false
}

--- Returns a list of weapons for player based on there location
--- @param player number|string Player ID of Player Identifier
--- @param location string Location for weapons to be stored
function weapons:getPlayerWeapons(player, location)
    if (location == nil or type(location) ~= 'string') then return {} end

    local identifier, identifiers = 'none', m('identifiers')

    if (player == nil or (type(player) == 'number' and player == 0) or (type(player) == 'string' and player == 'console')) then
        identifier = 'console'
    elseif(player ~= nil and (type(player) == 'number' and player > 0)) then
        identifier = identifiers:getIdentifier(player)
    else
        identifier = player
    end

    if (identifier ~= 'none' and weapons.players ~= nil and weapons.players[identifier] ~= nil and weapons.players[identifier][location] ~= nil) then
        return weapons.players[identifier][location]
    end

    return {}
end

--- Returns a list of weapons for given job
--- @param source number|string Player ID of Player Identifier
--- @param job string Name of job
--- @param location string Location for weapons to be stored
function weapons:getJobWeapons(source, job, location)
    if (job == nil or type(job) ~= 'string') then return {} end
    if (location == nil or type(location) ~= 'string') then return {} end

    local player, players = nil, m('players')

    player = players:getPlayer(source) or nil

    if (player == nil or player.identifier == 'console' or player.identifier == 'none') then return {} end

    local playerAllowed = false

    if (string.lower((player.job or {}).name or 'unknown') == string.lower(job)) then playerAllowed = true end
    if (string.lower((player.job2 or {}).name or 'unknown') == string.lower(job)) then playerAllowed = true end
    if (type(source) == 'number' and IsPlayerAceAllowed(source, 'weapons.show')) then playerAllowed = true end
    if (IsPrincipalAceAllowed(('identifier.%s:%s'):format(string.lower(Config.IdentifierType), player.identifier), 'weapons.show')) then playerAllowed = true end

    if (not playerAllowed) then return {} end

    if (job ~= '' and weapons.jobs ~= nil and weapons.jobs[job] ~= nil and weapons.jobs[job][location] ~= nil) then
        return weapons.jobs[job][location]
    end

    return {}
end

--- Tell resource that server has been started
onFrameworkStarted(function()
    local database = m('database')

    database:fetchAllAsync('SELECT * FROM `weapons`', {}, function(results)
        if (results == nil or type(results) ~= 'table') then results = {} end

        if (#results <= 0) then
            weapons.loaded = true
            return
        end

        for _, weapon in pairs(results) do
            if (weapon == nil or type(weapon) ~= 'table') then weapon = {} end

            local weaponObject = weapons:createAWeapon(
                weapon.id or 0,
                weapon.player_id or 0,
                weapon.job_id or 0,
                weapon.name or 'unknown',
                weapon.bullets or 120,
                weapon.location or 'safe',
                json.decode(weapon.components or '{}'),
                weapon.tint or 1
            )

            if (weaponObject ~= nil) then
                if (weaponObject.ownerType == 'player') then
                    local weaponIdentifier = weaponObject:getIdentifier()

                    if (weapons.players == nil) then weapons.players = {} end
                    if (weapons.players[weaponIdentifier] == nil) then weapons.players[weaponIdentifier] = {} end
                    if (weapons.players[weaponIdentifier][weaponObject.location] == nil) then weapons.players[weaponIdentifier][weaponObject.location] = {} end

                    table.insert(weapons.players[weaponIdentifier][weaponObject.location], weaponObject)

                    weapons.weapons[tostring(weaponObject.id)] = weaponObject
                elseif (weaponObject.ownerType == 'job') then
                    local jobName = weaponObject:getJobName()

                    if (weapons.jobs == nil) then weapons.jobs = {} end
                    if (weapons.jobs[jobName] == nil) then weapons.jobs[jobName] = {} end
                    if (weapons.jobs[jobName][weaponObject.location] == nil) then weapons.jobs[jobName][weaponObject.location] = {} end

                    table.insert(weapons.jobs[jobName][weaponObject.location], weaponObject)

                    weapons.weapons[tostring(weaponObject.id)] = weaponObject
                end
            end
        end

        weapons.loaded = true
    end)
end)

--- Trigger when player is fully connected
registerCallback('corev:weapons:getWeapons', function(source, cb)
    local playerInventoryWeapons = weapons:getPlayerWeapons(source, 'inv')
    local playerInvWeapons = {}

    for _, invWeapon in pairs(playerInventoryWeapons or {}) do
        local ammoMaxClipSize = ((invWeapon.weapon or {}).ammo or {}).max or 0
        local waeponId = (invWeapon.weapon or {}).id or 'weapon_unknown'
        local weaponComponents = {}

        if (invWeapon.bullets > ammoMaxClipSize) then invWeapon.bullets = ammoMaxClipSize end

        for _, weaponComponent in pairs((invWeapon.weapon or {}).components or {}) do
            for _, invWeaponComponent in pairs(invWeapon.components or {}) do
                if (string.lower(invWeaponComponent) == string.lower(weaponComponent.id) or weaponComponent.default) then
                    weaponComponents[weaponComponent.id] = {
                        id = weaponComponent.id,
                        hash = weaponComponent.hash,
                        type = weaponComponent.type,
                        default = weaponComponent.default
                    }
                end
            end
        end

        playerInvWeapons[waeponId] = {
            id = invWeapon.id,
            name = invWeapon.name,
            bullets = invWeapon.bullets,
            location = invWeapon.location,
            tint = invWeapon.tint,
            components = weaponComponents
        }
    end

    cb(playerInvWeapons)
end)