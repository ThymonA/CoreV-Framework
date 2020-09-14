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
    local playerX, playerY, playerZ = table.unpack(GetGameplayCamCoord())
    local distance = GetDistanceBetweenCoords(playerX, playerY, playerZ, (coords.x or 0), (coords.y or 0), (coords.z or 0), 1)
    local scale = ((1 / distance) * 2) * (1 / GetGameplayCamFov()) * 100

    if (onScreen) then
        SetTextColour(255, 255, 255, 215)
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextCentre(true)

        BeginTextCommandWidth("STRING")
        AddTextComponentString(text)

        local height = GetTextScaleHeight(0.50 * scale, 4)
        local width = EndTextCommandGetWidth(0)

        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(x, y)

        DrawRect(x, y + scale / 90, width, height, 0, 0, 0, 100)
    end
end

addModule("utils", utils)