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
    inventory = {}
}

on('playerSpawned', function(playerPed, playerCoords)
    --- Update player weapons
    triggerServerCallback('corev:weapons:getWeapons', function(_weapons)
        RemoveAllPedWeapons(playerPed, true)

        print(json.encode(_weapons))

        for weaponName, weapon in pairs(_weapons or {}) do
            local weaponHash = GetHashKey(weaponName)

            GiveWeaponToPed(playerPed, weaponHash, weapon.bullets, false, false)
            SetPedWeaponTintIndex(playerPed, weaponHash, weapon.tint)

            for _, component in pairs(weapon.components or {}) do
                local component_name = component.id or 'UNKNOWN_COMPONENT'
                local component_hash = GetHashKey(component_name)

                GiveWeaponComponentToPed(playerPed, weaponHash, component_hash)
            end
        end
    end)
end)