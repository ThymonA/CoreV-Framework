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
module = class('module')

--- Set default values
module:set {
    modules = {}
}

--- Check if module exists
--- @name Name of module
function module:exists(name)
    if (name == nil or type(name) ~= 'string') then return false end

    return module.modules ~= nil and module.modules[name] ~= nil
end

--- Check if module exists
--- @name Name of module
--- @argument function|object Module arguments
function module:create(name, argument)
    local executable = class('executable')

    if (type(argument) == 'function') then
        local info = debug.getinfo(argument)
        local numberOfParams = info.nparams or 0
        local params = {}

        if (numberOfParams > 0) then
            for i = 1, numberOfParams, 1 do
                local paramName = debug.getlocal(argument, i)

                if (paramName ~= nil and type(paramName) ~= 'string') then
                    error:print(('Dependency at index #%s is empty'):format(i))
                    return nil
                end

                if (string.lower(name) == string.lower(paramName)) then
                    error:print(('Dependency refers to itself at index #%s'):format(i))
                    return nil
                end

                table.insert(params, paramName)
            end
        end

        executable:set {
            name = name,
            resource = CurrentFrameworkResource,
            module = CurrentFrameworkModule,
            func = argument,
            loaded = false,
            error = false,
            params = params,
            value = nil
        }
    else
        executable:set {
            name = name,
            resource = CurrentFrameworkResource,
            module = CurrentFrameworkModule,
            func = function()
                return argument
            end,
            loaded = true,
            error = false,
            params = {},
            value = argument
        }
    end

    --- Check if module is loaded
    function executable:isLoaded()
        return self.loaded or false
    end

    --- Check if module has error
    function executable:hasError()
        return self.error or false
    end

    --- Check if module can be started
    function executable:canStart()
        if (self:isLoaded() or self:hasError()) then return false end
        if (#self.params <= 0) then return false end

        for i, param in pairs(self.params or {}) do
            local paramKey = string.lower(param)
            local paramExecutable = (module.modules[paramKey] or nil)

            if (paramExecutable ~= nil) then
                if (not paramExecutable:isLoaded() and paramExecutable:hasError()) then
                    self.error = true

                    error:print(('Dependency \'%s\' at index #%s failed to load, module can\'t be started'):format(i), self.resource, self.module)

                    return false
                elseif (not paramExecutable:isLoaded()) then
                    return false
                end
            elseif (resource.tasks.loadingFramework) then
                self.error = true

                error:print(('Dependency \'%s\' at index #%s failed to load, module doesn\'t exists'):format(i), self.resource, self.module)

                return false
            end
        end

        return true
    end

    --- Returns module if exists
    function executable:get()
        return self.value or nil
    end

    --- Execute module code
    function executable:execute()
        if (self.isLoaded() or self:hasError()) then
            return
        end

        if (self.func ~= nil and self:canStart()) then
            if (#self.params <= 0) then
                self.value = self.func()
            else
                local params = {}

                for i, param in pairs(self.params or {}) do
                    local paramKey = string.lower(param)
                    local paramExecutable = (module.modules[paramKey] or nil)

                    if (paramExecutable ~= nil) then
                        table.insert(params, paramExecutable:get())
                    else
                        table.insert(params, nil)
                    end
                end

                self.value = self.func(table.unpack(params))
            end
        end
    end

    return executable
end

--- Check if module exists
--- @name Name of module
--- @argument function|object Module function or object
--- @override boolean Overide if exsits
function module:load(name, argument, override)
    if (name == nil or type(name) ~= 'string') then return end

    name = string.lower(name)

    try(function()
        _ENV.CurrentFrameworkModule = name
        _G.CurrentFrameworkModule = name

        override = override == true

        if (not override and self:exists(name)) then
            return
        end

        local executable = self:create(name, argument)

        module.modules[name] = executable

        if (module.modules[name]:canStart()) then
            module.modules[name]:execute()
        end
    end, function(e)
        error:print(e)

        if (module.modules[name] ~= nil) then
            module.modules[name].error = true
        end
    end)
end

--- Returns module or nil
--- @name Name of module
function module:get(name)
    if (name == nil or type(name) ~= 'string') then return nil end

    name = string.lower(name)

    if (not module:exists(name)) then
        return nil
    end

    local executable = module.modules[name]

    if (executable:isLoaded()) then
        return executable:get()
    end

    if (executable:hasError()) then
        return nil
    end

    return self:get(name)
end

--- FiveM manipulation
_ENV.addModule = function(name, arguments, override) module:load(name, arguments, override) end
_G.addModule = function(name, arguments, override) module:load(name, arguments, override) end
_ENV.m = function(moduleName) return module:get(moduleName) end
_G.m = function(moduleName) return module:get(moduleName) end