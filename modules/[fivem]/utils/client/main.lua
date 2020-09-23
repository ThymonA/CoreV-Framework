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
local utils = class('utils')

function utils:drawText3Ds(coords, text)
    if (coords == nil) then coords = GetEntityCoords(PlayerPedId()) end
    if (type(coords) == 'table') then coords = vector3(coords.x, coords.y, coords.z) end
    if (type(coords) ~= 'vector3') then return end

    local onScreen, x, y = GetScreenCoordFromWorldCoord((coords.x or 0), (coords.y or 0), (coords.z or 0))

    if (onScreen) then
        local camCoords = GetGameplayCamCoords()
        local distance = #(coords - camCoords)
        local scale = (1 / distance) * 2
        local fov = (1 / GetGameplayCamFov()) * 100

        scale = scale * fov

        SetTextColour(255, 255, 255, 255)
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextDropshadow(0, 0, 0, 0)
        SetTextDropShadow()
        SetTextOutline()
        SetTextFont(0)
        SetTextProportional(1)
        SetTextCentre(true)

        SetDrawOrigin(coords, 0)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(0.0, 0.0)
        ClearDrawOrigin()
    end
end

addModule('utils', utils)