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
---@type corev_client
local corev = assert(corev_client)
local GeneratePedSkin = assert(GeneratePedSkin)
local CreateThread = assert(Citizen.CreateThread)
local Wait = assert(Citizen.Wait)
local NetworkIsPlayerActive = assert(NetworkIsPlayerActive)
local GetEntityModel = assert(GetEntityModel)
local GetHashKey = assert(GetHashKey)
local RequestModel = assert(RequestModel)
local HasModelLoaded = assert(HasModelLoaded)
local SetPlayerModel = assert(SetPlayerModel)
local SetPedDefaultComponentVariation = assert(SetPedDefaultComponentVariation)
local SetModelAsNoLongerNeeded = assert(SetModelAsNoLongerNeeded)
local DoScreenFadeIn = assert(DoScreenFadeIn)
local ShutdownLoadingScreen = assert(ShutdownLoadingScreen)
local FreezeEntityPosition = assert(FreezeEntityPosition)
local SetCanAttackFriendly = assert(SetCanAttackFriendly)
local NetworkSetFriendlyFireOption = assert(NetworkSetFriendlyFireOption)
local ClearPlayerWantedLevel = assert(ClearPlayerWantedLevel)
local SetMaxWantedLevel = assert(SetMaxWantedLevel)
local RequestCollisionAtCoord = assert(RequestCollisionAtCoord)
local HasCollisionLoadedAroundEntity = assert(HasCollisionLoadedAroundEntity)
local SetEntityCoords = assert(SetEntityCoords)
local PlayerId = assert(PlayerId)
local PlayerPedId = assert(PlayerPedId)
local decode = assert(json.decode)
local vector3 = assert(vector3)

--- Load a player and apply skin to it
CreateThread(function()
    while true do
        if (NetworkIsPlayerActive(PlayerId())) then
            local defaultModel = corev:cfg('skins', 'defaultModel')
            local spawnLocation = corev:cfg('skins', 'defaultSpawnLocation')
            local result_data, result_model, finished = nil, nil, false

            corev.callback:triggerCallback('load', function(data, model)
                result_data = data
                result_model = model
                finished = true
            end)

            repeat Wait(0) until finished == true

            local model = GetHashKey(result_model or defaultModel)

            if (GetEntityModel(PlayerPedId()) == model) then
                return
            end

            RequestModel(model)

            while not HasModelLoaded(model) do
                Wait(0)
            end

            local pId = PlayerId()

            SetPlayerModel(pId, model)

            local ped = PlayerPedId()

            SetPedDefaultComponentVariation(ped)

            --- @type skin_options
            local skin = GeneratePedSkin(ped)
            local skin_info = decode(result_data or '{}')

            skin:update(skin_info)
            skin:refresh()

            SetModelAsNoLongerNeeded(model)

            DoScreenFadeIn(2500)
            ShutdownLoadingScreen()

            FreezeEntityPosition(ped, true)
            SetCanAttackFriendly(ped, true, false)

            NetworkSetFriendlyFireOption(true)
            ClearPlayerWantedLevel(pId)
            SetMaxWantedLevel(0)

            local coords, timeout = corev:ensure(spawnLocation, vector3(0.0, 0.0, 0.0)), 0

            RequestCollisionAtCoord(coords.x, coords.y, coords.z)

            while not HasCollisionLoadedAroundEntity(ped) and timeout < 2000 do
                timeout = timeout + 1
                Wait(0)
            end

            SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
            FreezeEntityPosition(ped, false)

            return
        end

        Wait(0)
    end
end)