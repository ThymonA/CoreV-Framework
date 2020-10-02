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
function weapons:createAWeapon(id, player, job, name, bullets, location, components, tint)
    local weapon = class('weapon')
    local identifiers, jobs = m('identifiers'), m('jobs')

    weapon:set {
        id = id or 0,
        playerId = player or 0,
        jobId = job or 0,
        name = name or 'unknown',
        bullets = bullets or 120,
        location = location or 'unknown',
        components = components or {},
        tint = tint or 1,
        ownerType = 'unknown',
        identifier = nil,
        job = nil,
        weapon = Config.Weapons[string.lower(name or 'unknown')] or {}
    }

    if (weapon.id <= 0 or (weapon.playerId <= 0 and weapon.jobId <= 0)) then
        return nil
    end

    if (weapon.playerId > 0) then weapon.ownerType = 'player' end
    if (weapon.jobId > 0) then weapon.ownerType = 'job' end

    if (weapon.ownerType == 'player') then
        weapon.identifier = identifiers:getIdentifierByPlayerId(weapon.playerId)

        if (weapon.identifier == nil) then return nil end
    elseif (weapon.ownerType == 'job') then
        weapon.job = jobs:getJob(weapon.jobId)

        if (weapon.job == nil) then return nil end
    end

    --- Returns current primary identifier
    function weapon:getIdentifier()
        return (self.identifier or {}).identifier or 'none'
    end

    --- Returns weapon job name
    function weapon:getJobName()
        return (self.job or {}).name or 'unknown'
    end

    --- Returns weapon id
    function weapon:getId()
        return (self.weapon or {}).id or 'weapon_unknown'
    end

    --- Returns weapon label
    function weapon:getLabel()
        return (self.weapon or {}).name or 'unknown'
    end

    --- Returns weapon label
    function weapon:getHash()
        return (self.weapon or {}).hash or 0x0
    end

    --- Returns weapon category
    function weapon:getCategory()
        return (self.weapon or {}).category or 'unknown'
    end

    return weapon
end