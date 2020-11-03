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
local load = assert(load)
local xpcall = assert(xpcall)
local pairs = assert(pairs)
local traceback = assert(debug.traceback)
local lower = assert(string.lower)
local LoadResourceFile = assert(LoadResourceFile)
local GetCurrentResourceName = assert(GetCurrentResourceName)

--- Load tattoo configuration based on given `type`
--- @param type string Two options: `male` or `female`
--- @return table|nil Tattoo configuraiton or nil
local function loadConfigurationFile(type)
    type = corev:ensure(type, 'unknown')

    local filePath = ('data/tattoos_%s.lua'):format(type)
    local rawFile = LoadResourceFile(GetCurrentResourceName(), filePath)

    if (rawFile) then
        local func, _ = load(rawFile, ('%s/%s'):format(GetCurrentResourceName(), filePath))

        if (func) then
            local ok, result = xpcall(func, traceback)

            if (ok) then
                return result
            end
        end
    end

    return {}
end

function getTattooData(type)
    type = corev:ensure(type, 'unknown')

    return loadConfigurationFile(type)
end

--- Load tattoo information into skin
--- @param skin_options skin_options Skin option to add information in
function loadTattoos(skin_options)
    local tattooInformation = {}

    if (skin_options.isMale) then
        tattooInformation = loadConfigurationFile('male')
    elseif (skin_options.isFemale) then
        tattooInformation = loadConfigurationFile('female')
    end

    skin_options:set('tattoos', {
        tattoo_torso = skin_options:createCategory('tattoo_torso'),
        tattoo_head = skin_options:createCategory('tattoo_head'),
        tattoo_left_arm = skin_options:createCategory('tattoo_left_arm'),
        tattoo_right_arm = skin_options:createCategory('tattoo_right_arm'),
        tattoo_left_leg = skin_options:createCategory('tattoo_left_leg'),
        tattoo_right_leg = skin_options:createCategory('tattoo_right_leg'),
        tattoo_badges = skin_options:createCategory('tattoo_badges')
    })

    for categoryType, categoryInfo in pairs(tattooInformation) do
        local categoryName = ('tattoo_%s'):format(lower(categoryType))

        if (skin_options.tattoos[categoryName] ~= nil) then
            for categoryOption, _options in pairs(categoryInfo) do
                _options = corev:ensure(_options, {})

                skin_options.tattoos[categoryName]:addOption(categoryOption, 0, #_options, 0)
            end
        end
    end
end

--- Register `loadTattoos` and `getTattooData` as global function
global.loadTattoos = loadTattoos
global.getTattooData = getTattooData