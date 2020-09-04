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
resource = class('resource')

--- Set default values
resource:set {
    externalResources = {},
    internalResources = {},
    internalModules = {},
    internalResourceStructure = {},
    internalModuleStructure = {},
    tasks = {
        loadingInternalStructures = false,
        loadingExecutables = false,
        loadingFramework = false
    }
}

--- Returns `true` if resource/module exists
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:exists(name, _type)
    if (name == nil or type(name) ~= 'string') then return false end

    name = string.lower(name)

    if (string.lower(_type) == string.lower(ResourceTypes.ExternalResource)) then
        return self.externalResources[name] ~= nil
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalResource)) then
        return self.internalResources[name] ~= nil
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalModule)) then
        return self.internalModules[name] ~= nil
    end
end

--- Returns `true` if resource is loaded
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:isLoaded(name, _type)
    if (not self:exists(name, _type)) then return false end

    name = string.lower(name)

    if (string.lower(_type) == string.lower(ResourceTypes.ExternalResource)) then
        return self.externalResources[name].loaded == true
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalResource)) then
        return self.internalResources[name].loaded == true
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalModule)) then
        return self.internalModules[name].loaded == true
    end

    return false
end

--- Returns a path
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:getPath(name, _type)
    local path = 'none'

    if (string.lower(_type) == string.lower(ResourceTypes.ExternalResource)) then
        path = GetResourcePath(name)
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalResource)) then
        repeat Citizen.Wait(0) until self.tasks.loadingInternalStructures == true

        if (self.internalResourceStructure ~= nil and self.internalResourceStructure[name] ~= nil) then
            path = self.internalResourceStructure[name].fullPath
        end
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalModule)) then
        repeat Citizen.Wait(0) until self.tasks.loadingInternalStructures == true

        if (self.internalModuleStructure ~= nil and self.internalModuleStructure[name] ~= nil) then
            path = self.internalModuleStructure[name].fullPath
        end
    end

    return path
end

--- Returns `true` if Resource/Module is a framework resource
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:isFrameworkExecutable(name, _type)
    if (name == nil or type(name) ~= 'string') then return false end

    local content = self:getFilesByPath(name, _type, 'module.json')

    return content ~= nil
end

--- Generates a framework manifest for Resource/Module
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:generateFrameworkManifest(name, _type)
    local resource = ''
    local internalPath = ''

    if (string.lower(_type) == string.lower(ResourceTypes.ExternalResource)) then
        resource = name
        internalPath = '/module.json'
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalResource)) then
        repeat Citizen.Wait(0) until self.tasks.loadingInternalStructures == true

        if (self.internalResourceStructure ~= nil and self.internalResourceStructure[name] ~= nil) then
            resource = GetCurrentResourceName()
            internalPath = ('%s/module.json'):format(self.internalResourceStructure[name].path)
        end
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalModule)) then
        repeat Citizen.Wait(0) until self.tasks.loadingInternalStructures == true

        if (self.internalModuleStructure ~= nil and self.internalModuleStructure[name] ~= nil) then
            resource = GetCurrentResourceName()
            internalPath = ('%s/module.json'):format(self.internalModuleStructure[name].path)
        end
    end

    local manifest = class('manifest')

    --- set default values
    manifest:set {
        name = name,
        type = _type,
        data = {}
    }

    --- Returns a value from data in manifest
    --- @key string key to search for
    function manifest:getValue(key)
        if (key == nil or type(key) ~= 'string') then
            return nil
        end

        if (self.data ~= nil and self.data[key] ~= nil) then
            return self.data[key]
        end

        return nil
    end

    if (resource == '' or internalPath == '') then
        return manifest
    end

    local content = LoadResourceFile(resource, internalPath)

    if (content) then
        local data = json.decode(content)

        if (data) then
            for key, value in pairs(data) do
                if (key ~= nil) then
                    manifest.data[key] = value
                end
            end
        end
    end

    return manifest
end

--- Load Resources/Modules
function resource:loadFrameworkExecutables()
    local enabledInternalResources, enabledInternalModules = {}, {}

    repeat Citizen.Wait(0) until self.tasks.loadingInternalStructures == true

    --- Load all enabled resources
    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevresource'), 1 do
        table.insert(enabledInternalResources, GetResourceMetadata(GetCurrentResourceName(), 'corevresource', i))
    end

    --- Load all enabled modules
    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevmodule'), 1 do
        table.insert(enabledInternalModules, GetResourceMetadata(GetCurrentResourceName(), 'corevmodule', i))
    end

    --- Add all internal executable resources
    for i, internalResource in pairs(self.internalResourceStructure or {}) do
        local internalResourceEnabled = false

        for i2, internalResourceName in pairs(enabledInternalResources or {}) do
            if (string.lower(internalResourceName) == string.lower(internalResource.name)) then
                internalResourceEnabled = true
            end
        end

        if (self:isFrameworkExecutable(internalResource.name, ResourceTypes.InternalResource)) then
            self.internalResources[internalResource.name] = {
                name = internalResource.name,
                path = internalResource.path,
                fullPath = internalResource.fullPath,
                enabled = internalResourceEnabled,
                loaded = false,
                error = {
                    status = false,
                    message = ''
                },
                type =  ResourceTypes.InternalResource,
                manifest = self:generateFrameworkManifest(internalResource.name, ResourceTypes.InternalResource)
            }
        end
    end

    --- Add all internal executable modules
    for i, internalModule in pairs(self.internalModuleStructure or {}) do
        local internalModuleEnabled = false

        for i2, internalModuleName in pairs(enabledInternalModules or {}) do
            if (string.lower(internalModuleName) == string.lower(internalModule.name)) then
                internalModuleEnabled = true
            end
        end

        if (self:isFrameworkExecutable(internalModule.name, ResourceTypes.InternalModule)) then
            self.internalModules[internalModule.name] = {
                name = internalModule.name,
                path = internalModule.path,
                fullPath = internalModule.fullPath,
                enabled = internalModuleEnabled,
                loaded = false,
                error = {
                    status = false,
                    message = ''
                },
                type =  ResourceTypes.InternalModule,
                manifest = self:generateFrameworkManifest(internalModule.name, ResourceTypes.InternalModule)
            }
        end
    end

    self.tasks.loadingExecutables = true
end

--- Load all translations for 
--- @object Any Executable Resource/Module
function resource:loadTranslations(object)
    if (object.enabled and object.manifest ~= nil and type(object.manifest) == 'manifest') then
        local languages = object.manifest:getValue('languages') or {}

        for key, location in pairs(languages) do
            if (string.lower(key) == LANGUAGE) then
                local resourceName = ''
                local content = nil

                if (string.lower(object.type) == string.lower(ResourceTypes.ExternalResource)) then
                    content = LoadResourceFile(object.name, location)
                    resourceName = object.name
                end

                if (string.lower(object.type) == string.lower(ResourceTypes.InternalResource) or
                    string.lower(object.type) == string.lower(ResourceTypes.InternalModule)) then
                    content = LoadResourceFile(GetCurrentResourceName(), ('%s/%s'):format(object.path, location))
                    resourceName = GetCurrentResourceName()
                end

                if (content) then
                    local data = json.decode(content)

                    if (data) then
                        if (CoreV.Translations[resourceName] == nil) then
                            CoreV.Translations[resourceName] = {}
                        end

                        if (CoreV.Translations[resourceName][object.name] == nil) then
                            CoreV.Translations[resourceName][object.name] = {}
                        end

                        for _key, _value in pairs(data or {}) do
                            CoreV.Translations[resourceName][object.name][_key] = _value
                        end
                    end
                end
            end
        end
    end
end

--- Returns a list of files by path
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
--- @internalPath string Internal path of Resource/Module
function resource:getFilesByPath(name, _type, internalPath)
    local content = nil

    if (string.lower(_type) == string.lower(ResourceTypes.ExternalResource)) then        
        content = LoadResourceFile(name, internalPath)
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalResource)) then
        if (self.internalResourceStructure ~= nil and self.internalResourceStructure[name] ~= nil) then
            content = LoadResourceFile(GetCurrentResourceName(), ('%s/%s'):format(self.internalResourceStructure[name].path, internalPath))
        end
    end

    if (string.lower(_type) == string.lower(ResourceTypes.InternalModule)) then
        if (self.internalModuleStructure ~= nil and self.internalModuleStructure[name] ~= nil) then
            content = LoadResourceFile(GetCurrentResourceName(), ('%s/%s'):format(self.internalModuleStructure[name].path, internalPath))
        end
    end

    if (content) then
        return tostring(content)
    end

    return nil
end

--- Returns generated executable
--- @object Any Executable Resource/Module
function resource:loadExecutable(object)
    local script = nil

    for i2, file in pairs(object.manifest:getValue('client_scripts') or {}) do
        local code = self:getFilesByPath(object.name, object.type, file)

        if (code) then
            local ff, nl, cr, ht, vt, ws = ("\f\n\r\t\v "):byte(1,6)

            if (script == nil) then
                script = code
            else
                script = script .. utf8.char(nl) .. code
            end
        end
    end

    return script
end

--- Load all framework Resources/Modules
function resource:loadAll()
    self:loadFrameworkExecutables()

    repeat Citizen.Wait(0) until self.tasks.loadingExecutables == true

    local enabledInternalModules = {}

    --- Load all enabled modules
    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevmodule'), 1 do
        local _module = GetResourceMetadata(GetCurrentResourceName(), 'corevmodule', i)

        if (_module ~= nil and type(_module) == 'string') then
            table.insert(enabledInternalModules, string.lower(_module))
        end
    end

    _ENV.CurrentFrameworkModule = nil
    _G.CurrentFrameworkModule = nil

    --- Load and execute all internal modules
    for i, internalModuleName in pairs(enabledInternalModules or {}) do
        _ENV.CurrentFrameworkResource = GetCurrentResourceName()
        _ENV.CurrentFrameworkModule = internalModuleName
        _G.CurrentFrameworkResource = GetCurrentResourceName()
        _G.CurrentFrameworkModule = internalModuleName

        if (self.internalModules ~= nil and self.internalModules[internalModuleName] ~= nil) then
            local internalModule = self.internalModules[internalModuleName]

            if (internalModule.enabled) then
                self:loadTranslations(internalModule)

                local script = self:loadExecutable(internalModule)

                if (script ~= nil) then
                    local fn, _error = load(script, ('@%s:internal_modules:%s:client'):format(CurrentFrameworkResource, CurrentFrameworkModule), 't', _ENV)

                    if (fn) then
                        xpcall(fn, function(err)
                            self.internalModules[internalModuleName].error.status = true
                            self.internalModules[internalModuleName].error.message = err

                            error:print(err)
                        end)
                    end

                    if (_error and _error ~= '') then
                        self.internalModules[internalModuleName].error.status = true
                        self.internalModules[internalModuleName].error.message = _error

                        error:print(_error)
                    end
                end

                self.internalModules[internalModuleName].loaded = true
            end
        end
    end

    _ENV.CurrentFrameworkModule = nil
    _G.CurrentFrameworkModule = nil

    --- Load and execute all internal modules
    for i, internalModule in pairs(self.internalModules or {}) do
        _ENV.CurrentFrameworkResource = GetCurrentResourceName()
        _ENV.CurrentFrameworkModule = internalModule.name
        _G.CurrentFrameworkResource = GetCurrentResourceName()
        _G.CurrentFrameworkModule = internalModule.name

        if (not internalModule.loaded) then
            self:loadTranslations(internalModule)

            local script = self:loadExecutable(internalModule)

            if (script ~= nil) then
                local fn, _error = load(script, ('@%s:internal_modules:%s:client'):format(CurrentFrameworkResource, CurrentFrameworkModule), 't', _ENV)

                if (fn) then
                    xpcall(fn, function(err)
                        self.internalModules[i].error.status = true
                        self.internalModules[i].error.message = err

                        error:print(err)
                    end)
                end

                if (_error and _error ~= '') then
                    self.internalModules[i].error.status = true
                    self.internalModules[i].error.message = _error

                    error:print(_error)
                end
            end

            self.internalModules[i].loaded = true
        end
    end

    _ENV.CurrentFrameworkModule = nil
    _G.CurrentFrameworkModule = nil

    --- Load and execute all internal resources
    for i, internalResource in pairs(self.internalResources or {}) do
        _ENV.CurrentFrameworkResource = GetCurrentResourceName()
        _ENV.CurrentFrameworkModule = internalResource.name
        _G.CurrentFrameworkResource = GetCurrentResourceName()
        _G.CurrentFrameworkModule = internalResource.name

        if (internalResource.enabled) then
            self:loadTranslations(internalResource)

            local script = self:loadExecutable(internalResource)

            if (script ~= nil) then
                local fn, _error = load(script, ('@%s:internal_resources:%s:client'):format(CurrentFrameworkResource, CurrentFrameworkModule), 't', _ENV)

                if (fn) then
                    xpcall(fn, function(err)
                        self.internalResources[i].error.status = true
                        self.internalResources[i].error.message = err

                        error:print(err)
                    end)
                end

                if (_error and _error ~= '') then
                    self.internalResources[i].error.status = true
                    self.internalResources[i].error.message = _error

                    error:print(_error)
                end
            end

            self.internalResources[i].loaded = true
        end
    end

    _ENV.CurrentFrameworkModule = nil
    _G.CurrentFrameworkModule = nil

    self.tasks.loadingFramework = true
end

--- Returns how many executables are loaded
function resource:countAllLoaded()
    local externalResources, internalResources, internalModules = 0, 0, 0

    for i, externalResource in pairs(self.externalResources or {}) do
        if (externalResource.enabled and externalResource.loaded) then
            externalResources = externalResources + 1
        end
    end

    for i, internalResource in pairs(self.internalResources or {}) do
        if (internalResource.enabled and internalResource.loaded) then
            internalResources = internalResources + 1
        end
    end

    for i, internalModule in pairs(self.internalModules or {}) do
        if (internalModule.loaded) then
            internalModules = internalModules + 1
        end
    end

    return externalResources, internalResources, internalModules
end

--- Load internal structures
triggerServerCallback('corev:resource:loadStructure', function(internalResourceStructure, internalModuleStructure)
    resource.internalResourceStructure = internalResourceStructure
    resource.internalModuleStructure = internalModuleStructure
    resource.tasks.loadingInternalStructures = true
end)

--- FiveM maniplulation
_ENV.getFrameworkFile = function(name, _type, internalPath) return resource:getFilesByPath(name, _type, internalPath) end
_G.getFrameworkFile = function(name, _type, internalPath) return resource:getFilesByPath(name, _type, internalPath) end