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
function items:createAItem(name, label, weight, itemType, giveable, dropable, isUnique)
    local item = class('item')
    local database = m('database')

    item:set {
        id = 0,
        name = name or 'unknown',
        label = label or 'UNKNOWN ITEM',
        weight = weight or 1.00,
        type = itemType or 'unknown',
        giveable = giveable or false,
        dropable = dropable or false,
        isUnique = isUnique or false
    }

    item.id = (database:fetchScalar("SELECT `id` FROM `items` WHERE `name` = @name LIMIT 1", {
        ['@name'] = item.name or 'unknown'
    }) or 0)

    if (item.id > 0) then
        database:execute('UPDATE `items` SET `weight` = @weight, `type` = @type, `giveable` = @giveable, `dropable` = @dropable, `isUnique` = @isUnique WHERE `id` = @id', {
            ['@weight'] = round(item.weight, 2),
            ['@type'] = item.type,
            ['@giveable'] = item.giveable and 1 or 0,
            ['@dropable'] = item.dropable and 1 or 0,
            ['@isUnique'] = item.isUnique and 1 or 0,
            ['@id'] = item.id
        })
    else
        local id = database:insert('INSERT INTO `items` (`name`, `weight`, `type`, `giveable`, `dropable`, `isUnique`) VALUES (@name, @weight, @type, @giveable, @dropable, @isUnique)', {
            ['@name'] = item.name,
            ['@weight'] = round(item.weight, 2),
            ['@type'] = item.type,
            ['@giveable'] = item.giveable and 1 or 0,
            ['@dropable'] = item.dropable and 1 or 0,
            ['@isUnique'] = item.isUnique and 1 or 0
        })

        if (type(id) ~= 'number') then id = tonumber(id or '0') end

        if (id <= 0) then 
            error:print(_(CR(), 'items', 'cant_load_item', item.name))
            return nil
        end

        item.id = id
    end

    self.items[item.name] = item

    return self.items[item.name]
end

--- Register some demo items for test purpose
items:addItem('bread', 'Brood', 0.25, 'default', true, true, false)
items:addItem('water_025', 'Flesje water 0.25L', 0.25, 'default', true, true, false)
items:addItem('water_050', 'Flesje water 0.50L', 0.50, 'default', true, true, false)
items:addItem('water_100', 'Flesje water 1.00L', 1.00, 'default', true, true, false)