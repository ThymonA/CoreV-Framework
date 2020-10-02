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
Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            if (GetEntityModel(PlayerPedId()) == GetHashKey('a_f_y_epsilon_01')) then
                return;
            end

            local defaultModel = GetHashKey('a_f_y_epsilon_01')

            RequestModel(defaultModel)

            while not HasModelLoaded(defaultModel) do
                Citizen.Wait(0)
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

            local coords, timeout = Config.DefaultSpawnLocation or vector3(-206.79, -1015.12, 29.14), 0

            RequestCollisionAtCoord(coords.x, coords.y, coords.z)

            while not HasCollisionLoadedAroundEntity(PlayerPedId()) and timeout < 2000 do
                timeout = timeout + 1
                Citizen.Wait(0)
            end

            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
            FreezeEntityPosition(PlayerPedId(), false)

            triggerOnEvent('playerSpawned', nil, PlayerPedId(), coords)

            return;
        end

        Citizen.Wait(0)
    end
end)