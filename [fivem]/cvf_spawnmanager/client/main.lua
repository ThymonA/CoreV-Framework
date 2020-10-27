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

--- Cache global variables
local assert = assert
local corev = assert(corev)
local wait = assert(Citizen.Wait)

--- This thread allowes you to spawn in a server
Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            local modelName = corev:cfg('spawnmanager', 'defaultModel')
            local defaultModel = GetHashKey(corev:ensure(modelName, 'mp_m_freemode_01'))
            local defaultLocation = corev:cfg('spawnmanager', 'defaultSpawnLocation')

            if (GetEntityModel(PlayerPedId()) == defaultModel) then
                return;
            end

            RequestModel(defaultModel)

            while not HasModelLoaded(defaultModel) do
                wait(0)
            end

            SetPlayerModel(PlayerId(), defaultModel)
            SetPedDefaultComponentVariation(PlayerPedId())
            SetPedRandomComponentVariation(PlayerPedId(), true)
            SetModelAsNoLongerNeeded(defaultModel)

            ShutdownLoadingScreen()
            DoScreenFadeIn(2500)
            FreezeEntityPosition(PlayerPedId(), true)
            SetCanAttackFriendly(PlayerPedId(), true, false)
            NetworkSetFriendlyFireOption(true)
            ClearPlayerWantedLevel(PlayerId())
            SetMaxWantedLevel(0)

            local coords, timeout = defaultLocation or vector3(-206.79, -1015.12, 29.14), 0

            RequestCollisionAtCoord(coords.x, coords.y, coords.z)

            while not HasCollisionLoadedAroundEntity(PlayerPedId()) and timeout < 2000 do
                timeout = timeout + 1
                wait(0)
            end

            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
            FreezeEntityPosition(PlayerPedId(), false)

            return;
        end

        wait(0)
    end
end)