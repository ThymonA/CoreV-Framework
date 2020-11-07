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

--- FiveM cached global variables
local GetInvokingResource = assert(GetInvokingResource)

--- Create a `menu` class
local menuv = class "menuv"

--- Set default values
menuv:set {
    menus = {}
}

--- Create a new `menu` for `menuv`
function menuv:createMenu(name)
    local resource = GetInvokingResource()

    resource = corev:ensure(resource, corev:getCurrentResourceName())
    name = corev:ensure(name, '')

    local resourceKey = corev:hashString(resource)
    local menuKey = corev:hashString(name)

    if (menuv.menus[resourceKey] ~= nil and menuv.menus[resourceKey][menuKey] ~= nil) then
        return
    end
end