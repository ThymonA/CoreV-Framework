----------------------- [ FXCore ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/fx_core/
-- GitHub: https://github.com/ThymonA/FXCore/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
-- Name: FXCore
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ FXCore ] -----------------------
Modules = class('Modules')

-- Set default value
Modules:set {
    Modules = {}
}

--- Returns a list of modules
function Modules:GetModules()
    return Modules.Modules or {}
end

--- Returns `true` if module exsits
--- @param moduleName string Module name
function Modules:Exists(moduleName)
    if (moduleName == nil or type(moduleName) ~= 'string') then
        return false
    end

    return Modules:GetModules()[moduleName] ~= nil
end

--- Create a module object
--- @param name string Module name
--- @argument function|object Function or Object
function Modules:Create(name, argument)
    local _object = class('module')

    if (type(argument) == 'function') then
        local info = debug.getinfo(func)
        local numberOfParameters = info.nparams or 0
        local params = {}

        if (numberOfParameters > 0) then
            for i = 1, numberOfParameters, 1 do
                local paramName = debug.getlocal(func, i)

                if (paramName ~= nil and type(paramName) ~= 'string') then
                    error(('Dependency at index #%s is empty'):format(i), 4)
                    return
                end

                if (string.lower(name) == string.lower(paramName)) then
                    error(('Dependency refers to module itself at index #%s'):format(i), 4)
                    return
                end

                table.insert(params, paramName)
            end
        end

        -- Set default values
        _object:set {
            name = name,
            resource = CurrentFrameworkModule,
            func = func,
            loaded = false,
            error = false,
            params = params,
            value = nil
        }
    else
        -- Set default values
        _object:set {
            name = name,
            resource = CurrentFrameworkModule,
            func = function()
                return argument
            end,
            loaded = true,
            error = false,
            params = {},
            value = argument
        }
    end

    -- Check if module is loaded
    function _object:IsLoaded()
        return self.loaded or false
    end

    -- Check if module has error
    function _object:HasError()
        return self.error or false
    end

    -- Check if module can be started
    function _object:CanStart()
        if (self:IsLoaded()) then
            return false
        end

        if (#self.params <= 0) then
            return true
        end

        for i, param in pairs(self.params or {}) do
            local key = string.lower(tostring(param))
            local _module = (Module.Modules or {})[key] or nil

            if (_module ~= nil) then
                if (not _module:IsLoaded() and _module:HasError()) then
                    self.error = true

                    print(("Dependency '%s' at index #%s failed to load, module can't be started"):format(_module.name, i), self.resource, self.name)

                    return false
                elseif (not _module:IsLoaded()) then
                    return false
                end
            elseif (Resource.AllResourcesLoaded) then
                self.error = true

                print(("Dependency '%s' at index #%s failed to load, module doesn't exists"):format(key, i), self.resource, self.name)

                return false
            else
                return false
            end
        end

        return true 
    end

    -- Returns module value
    function _object:Get()
        return self.value or false
    end

    -- Execute module code
    function _object:Execute()
        if (self:IsLoaded() or self:HasError()) then
            return
        end

        if (self.func ~= nil and self:CanStart()) then
            if (#self.params <= 0) then
                self.value = self.func()
            else
                local _params = {}

                for _, param in pairs(self.params or {}) do
                    local key = string.lower(tostring(param))
                    local _module = Modules:GetModules()[key] or nil

                    if (_module ~= nil) then
                        Citizen.CreateThread(function()
                            table.insert(_params, _module:Get())
                        end)
                    else
                        table.insert(_params, nil)
                    end
                end

                self.value = self.func(table.unpack(_params))
            end
        else
            return
        end
    end

    return _object
end

--- Load a framework modules
--- @param name string Module name
--- @param argument function|object Function or Object
--- @param override boolean Override if exits
function Modules:Load(name, argument, override)
    local key = string.lower(tostring(name))

    try(function()
        _ENV.CurrentFrameworkModule = key
        _G.CurrentFrameworkModule = key

        if (key == nil or type(key) ~= 'string') then
            return
        end

        override = not (not override or false)

        if (not override and Modules:Exists(key)) then
            return
        end

        local module = Modules:Create(key, argument)

        Modules.Modules[key] = module

        if (module:CanStart()) then
            module:Execute()
        end
    end, function(e)
        print(e)

        if (Modules.Modules[key] ~= nil) then
            Modules.Modules[key].error = true
        end
    end)
end

--
-- Returns module if exsits
-- @module string Module name
--
function Modules:Get(moduleName)
    if (moduleName == nil or type(moduleName) ~= 'string') then
        return nil
    end

    local key = string.lower(tostring(moduleName))

    if (Modules:Exists(key)) then
        local _module = Modules.Modules[key]

        if (_module:IsLoaded()) then
            return _module:Get()
        end

        if (_module:HasError()) then
            return nil
        end

        Citizen.Wait(500)

        return m(moduleName)
    end

    return nil
end

-- FiveM manipulation
_ENV.module = function(name, arguments, override) Modules:Load(name, arguments, override) end
_G.module = function(name, arguments, override) Modules:Load(name, arguments, override) end
_ENV.m = function(moduleName) return Modules:Get(moduleName) end
_G.m = function(moduleName) return Modules:Get(moduleName) end