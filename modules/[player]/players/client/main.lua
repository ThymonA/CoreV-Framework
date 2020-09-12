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
local hud = class('hud')

hud:set {
    loaded = false,
    status = {
        health = 100,
        thirst = 100,
        hunger = 100,
        armor = 100
    },
    oldStatus = {
        health = 100,
        thirst = 100,
        hunger = 100,
        armor = 100
    },
    hidden = false,
    resourceName = GetCurrentResourceName()
}

RegisterNUICallback('hud_loaded', function(data, cb)
    TSE('corev:hud:init');

    hud.loaded = true

    cb('ok')
end)

onServerTrigger('corev:hud:updateJobs', function(job_name, job_grade, job2_name, job2_grade)
    SendNUIMessage({
        action = 'UPDATE_JOB',
        jobName = job_name,
        jobGrade = job_grade,
        __resource = hud.resourceName,
        __module = 'hud'
    })
    SendNUIMessage({
        action = 'UPDATE_JOB2',
        jobName = job2_name,
        jobGrade = job2_grade,
        __resource = hud.resourceName,
        __module = 'hud'
    })
end)

onServerTrigger('corev:players:setJob', function(job, grade)
    SendNUIMessage({
        action = 'UPDATE_JOB',
        jobName = job.label,
        jobGrade = grade.label,
        __resource = hud.resourceName,
        __module = 'hud'
    })
end)

onServerTrigger('corev:players:setJob2', function(job, grade)
    SendNUIMessage({
        action = 'UPDATE_JOB2',
        jobName = job.label,
        jobGrade = grade.label,
        __resource = hud.resourceName,
        __module = 'hud'
    })
end)

--- Thread to manage game input
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        if (hud.loaded) then
            local shouldBeHidden = false

            if (IsScreenFadedOut() or IsPauseMenuActive()) then
                shouldBeHidden = true
            end

            if (hud.hidden ~= shouldBeHidden) then
                hud.hidden = shouldBeHidden

                SendNUIMessage({
                    action = 'CHANGE_STATE',
                    shouldHide = shouldBeHidden,
                    __resource = hud.resourceName,
                    __module = 'hud'
                })
            end

            hud.oldStatus.health = hud.status.health + 0.0
            hud.oldStatus.thirst = hud.status.thirst + 0.0
            hud.oldStatus.hunger = hud.status.hunger + 0.0
            hud.oldStatus.armor = hud.status.armor + 0.0

            hud.status.health = round((GetEntityHealth(PlayerPedId()) - 100), 0) + 0.0
            hud.status.thirst = 100 + 0.0
            hud.status.hunger = 100 + 0.0
            hud.status.armor = round(GetPedArmour(PlayerPedId())) + 0.0

            if (hud.status.health ~= hud.oldStatus.health) then
                SendNUIMessage({
                    action = 'UPDATE_STATUS',
                    status = 'health',
                    value = hud.status.health,
                    __resource = hud.resourceName,
                    __module = 'hud'
                })
            end

            if (hud.status.thirst ~= hud.oldStatus.thirst) then
                SendNUIMessage({
                    action = 'UPDATE_STATUS',
                    status = 'thirst',
                    value = hud.status.thirst,
                    __resource = hud.resourceName,
                    __module = 'hud'
                })
            end

            if (hud.status.hunger ~= hud.oldStatus.hunger) then
                SendNUIMessage({
                    action = 'UPDATE_STATUS',
                    status = 'hunger',
                    value = hud.status.hunger,
                    __resource = hud.resourceName,
                    __module = 'hud'
                })
            end

            if (hud.status.armor ~= hud.oldStatus.armor) then
                SendNUIMessage({
                    action = 'UPDATE_STATUS',
                    status = 'armor',
                    value = hud.status.armor,
                    __resource = hud.resourceName,
                    __module = 'hud'
                })
            end
        end
    end
end)