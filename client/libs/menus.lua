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
menus = class('menus')

--- Set default values
menus:set {
    menus = {},
    pools = {}
}

--- Returns a existing menu by namespace
--- @param namespace string Namespace
function menus:getNamespaceMenu(namespace)
    if (namespace == nil or type(namespace) ~= 'string') then return nil, 'none', 'none' end

    namespace = string.lower(namespace)

    local _poolName = self:generatePoolName(namespace)

    if (self.menus ~= nil and self.menus[namespace] ~= nil) then
        return self.menus[namespace], namespace, self.pools[_poolName] ~= nil
    end

    local namespaceParts = split(namespace, '.')

    table.remove(namespaceParts, #namespaceParts)

    if (namespaceParts ~= nil and #namespaceParts > 0) then
        local newNamespace = ''

        for i = 1, #namespaceParts, 1 do
            if (i == 1) then
                newNamespace = namespaceParts[i]
            else
                newNamespace = ('%s.%s'):format(newNamespace, namespaceParts[i])
            end
        end

        return self:getNamespaceMenu(newNamespace)
    end

    return nil, 'none', self.pools[_poolName] ~= nil
end

--- Returns a namespace pool name
--- @param namespace string Namespace
function menus:generatePoolName(namespace)
    if (namespace == nil or type(namespace) ~= 'string') then return 'none' end

    namespace = string.lower(namespace)

    local namespaceParts = split(namespace, '.')

    if (namespaceParts ~= nil and #namespaceParts > 0) then
        return namespaceParts[1]
    end

    return namespace
end

--- Create a menu or submenu depends on namespace
--- @param namespace string Menu namespace
--- @param title string Menu title
--- @param description string Menu cateogry or menu description
function menus:getOrCreate(namespace, title, description)
    if (description == nil or type(description) ~= 'string') then description = '' end

    local poolName, poolData, menu = self:generatePoolName(namespace), nil, nil
    local _menu, _namespace, _poolExists = self:getNamespaceMenu(namespace)

    if (_menu ~= nil and _namespace == namespace) then
        return self.menus[namespace], self.pools[poolName]
    end

    if (title == nill or type(title) ~= 'string') then
        title = namespace
    end

    if (_poolExists) then
        poolData = self.pools[poolName]
    else
        poolData = NativeUI.CreatePool()
    end

    if (_menu ~= nil) then
        menu = poolData:AddSubMenu(_menu, title, description)
    else
        menu = NativeUI.CreateMenu(title, description)

        poolData:Add(menu)
    end

    self.pools[poolName] = poolData
    self.menus[namespace] = menu

    return self.menus[namespace], self.pools[poolName]
end

--- Add menus as module when available
Citizen.CreateThread(function()
    while true do
        if (addModule ~= nil and type(addModule) == 'function') then
            addModule('menus', menus)
            return
        end

        Citizen.Wait(0)
    end
end)