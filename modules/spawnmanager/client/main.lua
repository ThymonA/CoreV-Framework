Citizen.CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            if (GetEntityModel(PlayerPedId()) == GetHashKey('PLAYER_ZERO')) then
                local defaultModel = GetHashKey('a_f_m_beach_01')

                RequestModel(defaultModel)

                while not HasModelLoaded(defaultModel) do
                    Citizen.Wait(0)
                end

                SetPlayerModel(PlayerId(), defaultModel)
                SetPedDefaultComponentVariation(PlayerPedId())
                SetPedRandomComponentVariation(PlayerPedId(), true)
                SetModelAsNoLongerNeeded(defaultModel)
            end

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

            ShutdownLoadingScreen()
            FreezeEntityPosition(PlayerPedId(), false)
            DoScreenFadeIn(2500)

            break;
        end

        Citizen.Wait(0)
    end
end)