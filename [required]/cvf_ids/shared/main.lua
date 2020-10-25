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

--- Cache globals
local assert = assert
local type = assert(type)
local tostring = assert(tostring)
local lower = assert(string.lower)

--- Create ids object to store information
local ids = {}
local ids_counter = 0

--- Generates a ID for given string
--- @param name string|number|nil String to generate a ID for
--- @return number Generated ID or Cached ID
local function generatedId(name)
    if (name == nil) then return 0 end
    if (type(name) == 'number') then return name end

    name = tostring(name)
    name = lower(name)

    if (ids[name] ~= nil) then return ids[name] end

    ids_counter = ids_counter + 1

    ids[name] = ids_counter

    return ids[name]
end

--- Register `generatedId` as export function
exports('__id', generatedId)