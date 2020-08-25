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

--- Returns a list of files of given path
--- @path string Path
function resource:getPathFiles(path)
    local results = {}

    if ((string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') and path ~= nil) then
        for _file in io.popen(('dir "%s" /b'):format(path)):lines() do
            table.insert(results, _file)
        end
    elseif ((string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') and path ~= nil) then
        local callit = os.tmpname()
        os.execute("ls -aF ".. path .. " | grep -v / >"..callit)
        local f = io.open(callit,"r")
        local rv = f:read("*all")
        f:close()
        os.remove(callit)

        local from  = 1
        local delim_from, delim_to = string.find( rv, "\n", from  )

        while delim_from do
            table.insert( results, string.sub( rv, from , delim_from-1 ) )
            from  = delim_to + 1
            delim_from, delim_to = string.find( rv, "\n", from  )
        end
    end

    return results
end

--- Load internal structures by path
--- @newPath string internal path
function resource:loadPathStructures(newPath)
    newPath = newPath or ''

    local results = {}
    local internalPath = GetResourcePath(GetCurrentResourceName())
    local directoryFiles = self:getPathFiles(('%s/%s/'):format(internalPath, newPath))

    for i, directory in pairs(directoryFiles or {}) do
        if (directory:startswith('[') and directory:endswith(']')) then
            local files = resource:loadPathStructures(('%s/%s'):format(newPath, directory))

            for i2, file in pairs(files or {}) do
                results[file.name] = {
                    name = file.name,
                    path = file.path,
                    fullPath = file.fullPath
                }
            end
        else
            results[directory] = {
                name = directory,
                path = (('%s/%s'):format(newPath, directory)),
                fullPath = (('%s/%s/%s'):format(internalPath, newPath, directory))
            }
        end
    end

    return results
end

--- Load internal structures
function resource:loadStructures()
    if (self.tasks.loadingInternalStructures) then return end

    local resources = self:loadPathStructures('resources')
    local modules = self:loadPathStructures('modules')

    self.internalResourceStructure = resources
    self.internalModuleStructure = modules

    self.tasks.loadingInternalStructures = true
end

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

--- Returns a list of files of module
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:getFiles(name, _type)
    if (name == nil or type(name) ~= 'string') then return false end

    local path = self:getPath(name, _type)

    if (path ~= 'none') then
        return self:getPathFiles(path)
    end

    return {}
end

--- Returns `true` if Resource/Module is a framework resource
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:isFrameworkExecutable(name, _type)
    if (name == nil or type(name) ~= 'string') then return false end

    local content = self:getFilesByPath(name, _type, 'module.json')

    return content ~= nil
end

--- Returns `true` if Resource/Module is a framework resource
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:hasFrameworkMigrations(name, _type)
    if (name == nil or type(name) ~= 'string') then return false end

    local files = self:getFiles(name, _type)

    for i, file in pairs(files or {}) do
        if (string.lower(file) == 'migrations') then
            return true
        end
    end

    return false
end

--- Returns `true` if Resource/Module is a framework resource
--- @name string Resource/Module name
--- @_type string Type of Resource/Module
function resource:getFrameworkMigrations(name, _type)
    if (not self:hasFrameworkMigrations(name, _type)) then return {} end

    local results = {}
    local path = ('%s/migrations/'):format(self:getPath(name, _type))

    if (path ~= 'none') then
        local files = self:getPathFiles(path)

        for i, file in pairs(files or {}) do
            if (file:endswith('.sql')) then
                table.insert(results, file)
            end
        end
    end

    return results
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
    local internalResources, internalModules = {}, {}
    
    self:loadStructures()

    repeat Citizen.Wait(0) until self.tasks.loadingInternalStructures == true

    --- Load all enabled resources
    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'resource'), 1 do
        table.insert(enabledInternalResources, GetResourceMetadata(GetCurrentResourceName(), 'resource', i))
    end

    --- Load all enabled modules
    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'module'), 1 do
        table.insert(enabledInternalModules, GetResourceMetadata(GetCurrentResourceName(), 'module', i))
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
                hasMigrations = self:hasFrameworkMigrations(internalResource.name, ResourceTypes.InternalResource),
                migrations = self:getFrameworkMigrations(internalResource.name, ResourceTypes.InternalResource),
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
                hasMigrations = self:hasFrameworkMigrations(internalModule.name, ResourceTypes.InternalModule),
                migrations = self:getFrameworkMigrations(internalModule.name, ResourceTypes.InternalModule),
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

    return content
end

--- Save and returns generated executable
--- @object Any Executable Resource/Module
function resource:saveExecutable(object)
    local script = nil
    local path = 'unknown'

    if (string.lower(object.type) == string.lower(ResourceTypes.ExternalResource)) then
        path = 'external_resources'
    elseif (string.lower(object.type) == string.lower(ResourceTypes.InternalResource)) then
        path = 'internal_resources'
    elseif (string.lower(object.type) == string.lower(ResourceTypes.InternalModule)) then
        path = 'internal_modules'
    end

    for i2, file in pairs(object.manifest:getValue('client_scripts') or {}) do
        local code = self:getFilesByPath(object.name, object.type, file)

        if (code) then
            if (script == nil) then
                script = code
            else
                script = ('%s\n%s'):format(script, code)
            end
        end
    end

    if (script ~= nil) then
        SaveResourceFile(GetCurrentResourceName(), ('debug/%s/client/%s_%s.lua'):format(path, object.name, 'client'), script)
    end

    script = nil

    for i2, file in pairs(object.manifest:getValue('server_scripts') or {}) do
        local code = self:getFilesByPath(object.name, object.type, file)

        if (code) then
            if (script == nil) then
                script = code
            else
                script = ('%s\n%s'):format(script, code)
            end
        end
    end

    if (script ~= nil) then
        SaveResourceFile(GetCurrentResourceName(), ('debug/%s/server/%s_%s.lua'):format(path, object.name, 'server'), script)
    end

    return script
end

--- Load all framework Resources/Modules
function resource:loadAll()
    self:loadFrameworkExecutables()

    repeat Citizen.Wait(0) until self.tasks.loadingExecutables == true

    local enabledInternalModules = {}

    --- Load all enabled modules
    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'module'), 1 do
        local _module = GetResourceMetadata(GetCurrentResourceName(), 'module', i)

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
    
                if (internalModule.hasMigrations) then
                    local database = m('database')
                    
                    for i2, migration in pairs(internalModule.migrations) do
                        local migrationTaskDone = database:applyMigration(internalModule, migration)
    
                        repeat Citizen.Wait(0) until migrationTaskDone == true
                    end
                end
    
                local script = self:saveExecutable(internalModule)
    
                if (script ~= nil) then
                    local fn, _error = load(script, ('@%s:%s:server'):format(CurrentFrameworkResource, CurrentFrameworkModule), 't', _ENV)
        
                    if (fn) then
                        xpcall(fn, function(err)
                            self.internalModules[internalModuleName].error.status = true
                            self.internalModules[internalModuleName].error.message = err
        
                            error:print(err)
                        end)
                    end
        
                    if (_error and error ~= '') then
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

            if (internalModule.hasMigrations) then
                local database = m('database')
                
                for i2, migration in pairs(internalModule.migrations) do
                    local migrationTaskDone = database:applyMigration(internalModule, migration)

                    repeat Citizen.Wait(0) until migrationTaskDone == true
                end
            end

            local script = self:saveExecutable(internalModule)

            if (scirpt ~= nil) then
                local fn, _error = load(script, ('@%s:%s:server'):format(CurrentFrameworkResource, CurrentFrameworkModule), 't', _ENV)

                if (fn) then
                    xpcall(fn, function(err)
                        self.internalModules[i].error.status = true
                        self.internalModules[i].error.message = err

                        error:print(err)
                    end)
                end

                if (_error and error ~= '') then
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

            if (internalResource.hasMigrations) then
                local database = m('database')
                
                for i2, migration in pairs(internalResource.migrations) do
                    local migrationTaskDone = database:applyMigration(internalResource, migration)

                    repeat Citizen.Wait(0) until migrationTaskDone == true
                end
            end

            local script = self:saveExecutable(internalResource)

            if (script ~= nil) then
                local fn, _error = load(script, ('@%s:%s:server'):format(CurrentFrameworkResource, CurrentFrameworkModule), 't', _ENV)

                if (fn) then
                    xpcall(fn, function(err)
                        self.internalResources[i].error.status = true
                        self.internalResources[i].error.message = err

                        error:print(err)
                    end)
                end

                if (_error and error ~= '') then
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

--- Sent internal structures to client
registerCallback('corev:resource:loadStructure', function(source, cb)
    while not resource.tasks.loadingFramework do
        Citizen.Wait(0)
    end

    local resourceStructures, moduleStructures = {}, {}

    for i, resourceStructure in pairs(resource.internalResourceStructure or {}) do
        resourceStructures[i] = {
            name = resourceStructure.name,
            path = resourceStructure.path,
            fullPath = resourceStructure.path
        }
    end

    for i, moduleStructure in pairs(resource.internalModuleStructure or {}) do
        moduleStructures[i] = {
            name = moduleStructure.name,
            path = moduleStructure.path,
            fullPath = moduleStructure.path
        }
    end

    cb(resourceStructures, moduleStructures)
end)

--- FiveM maniplulation
_ENV.getFrameworkFile = function(name, _type, internalPath) return resource:getFilesByPath(name, _type, internalPath) end
_G.getFrameworkFile = function(name, _type, internalPath) return resource:getFilesByPath(name, _type, internalPath) end