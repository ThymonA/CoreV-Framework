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
    items = {},
    cachedItems = nil,
    frameworkLoaded = false
}

--- Add a item to framework
--- @param name string Item name
--- @param label string Label of item
--- @param weight number Weight of item
--- @param itemType string Type of item
function items:addItem(name, label, weight, itemType, giveable, dropable, isUnique)
    if (name == nil or type(name) ~= 'string') then return nil, false end
    if (label == nil or type(label) ~= 'string') then label = 'UNKNOWN ITEM' end
    if (weight == nil or type(weight) ~= 'number') then weight = tonumber(weight or '1.00') end
    if (itemType == nil or type(itemType) ~= 'string') then return nil, false end
    if (giveable == nil or (type(giveable) ~= 'boolean' and type(giveable) ~= 'number')) then giveable = tonumber(giveable or '0') end
    if (dropable == nil or (type(dropable) ~= 'boolean' and type(dropable) ~= 'number')) then dropable = tonumber(dropable or '0') end
    if (isUnique == nil or (type(isUnique) ~= 'boolean' and type(isUnique) ~= 'number')) then isUnique = tonumber(isUnique or '0') end
    if (type(giveable) == 'number') then giveable = giveable == 1 end
    if (type(dropable) == 'number') then dropable = dropable == 1 end
    if (type(isUnique) == 'number') then isUnique = isUnique == 1 end

    name = string.lower(name)
    itemType = string.lower(itemType)

    if (self.items ~= nil and self.items[name] ~= nil) then return self.items[name], false end

    local item = self:createAItem(name, label, weight, itemType, giveable, dropable, isUnique)

    if (item ~= nil) then
        return item, true
    end

    return nil, false
end

--- Returns all registerd items
function items:getAllItems()
    if (self.cachedItems == nil) then
        repeat Wait(0) until self.frameworkLoaded == true

        local _items = {}

        for _, item in pairs(self.items or {}) do
            _items[item.name] = {
                id = item.id,
                name = item.name,
                label = item.label,
                weight = item.weight,
                type = item.type,
                giveable = item.giveable,
                dropable = item.dropable,
                isUnique = item.isUnique,
                isUsable = anyEvent(('item:%s:use'):format(item.name))
            }
        end

        self.cachedItems = _items
    end

    return self.cachedItems or {}
end

--- Will be triggerd by client end returns result in cb
registerCallback('corev:items:receive', function(source, cb)
    repeat Wait(0) until items.frameworkLoaded == true

    local _items = items:getAllItems()

    cb(_items)
end)

--- Tell resource that server has been started
onFrameworkStarted(function()
    items.frameworkLoaded = true
end)

--- Register items as module
addModule('items', items)