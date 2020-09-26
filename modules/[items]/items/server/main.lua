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
local items = class('items')

--- Set default values
items:set {
    items = {}
}

--- Add a item to framework
--- @param name string Item name
--- @param label string Label of item
--- @param weight number Weight of item
--- @param itemType string Type of item
function items:addItem(name, label, weight, itemType)
    if (name == nil or type(name) ~= 'string') then return nil, false end
    if (label == nil or type(label) ~= 'string') then label = 'UNKNOWN ITEM' end
    if (weight == nil or type(weight) ~= 'number') then weight = tonumber(weight or '1.00') end
    if (itemType == nil or type(itemType) ~= 'string') then return nil, false end

    name = string.lower(name)
    itemType = string.lower(itemType)

    if (self.items ~= nil and self.items[name] ~= nil) then return self.items[name], false end

    local item = self:createAItem(name, label, weight, itemType)

    if (item ~= nil) then
        return item, true
    end

    return nil, false
end

addModule('items', items)