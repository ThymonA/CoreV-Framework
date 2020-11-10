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
local assert = assert

--- Cache global variables
local corev = assert(corev)
local class = assert(class)

local function createMenu(resource, name)
    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, 'unknown')

    if (name == 'unknown') then name = corev:getRandomString() end

    --- Create a `menu` class
    local menu = class "menu"

    --- Set default information
    menu:set {
        __name = name,
        __resource = resource,
        events = {},
        items = {}
    }
end