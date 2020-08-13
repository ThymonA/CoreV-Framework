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
Resources = class('Resources')

-- Set default values
Resources:set {
    Resources = {},
    FrameworkModules = {},
    AllModulesLoaded = false,
    AllResourcesLoaded = false
}

--
-- Returns `true` if resource exits
-- @resourceName string Resource name
-- @return boolean `true` if resource exists
function Resources:Exists(resourceName)
    if (resourceName == nil or type(resourceName) ~= 'string') then
        return false
    end

    resourceName = string.lower(tostring(resourceName))

    return Resources.Resources[resourceName] ~= nil
end

--
-- Returns `true` if module exits
-- @moduleName string Module name
-- @return boolean `true` if module exists
function Resources:ModuleExists(moduleName)
    if (moduleName == nil or type(moduleName) ~= 'string') then
        return false
    end

    moduleName = string.lower(tostring(moduleName))

    return Resources.FrameworkModules[moduleName] ~= nil
end

--
-- Returns `true` if resource is loaded
-- @resourceName string Resource name
-- @return boolean `true` if resource is loaded
function Resources:IsLoaded(resourceName)
    if (resourceName == nil or type(resourceName) ~= 'string') then
        return true
    end

    resourceName = string.lower(tostring(resourceName))

    if (Resources:Exists(resourceName)) then
        return not (not Resources.Resources[resourceName].loaded or false)
    end
end

--
-- Returns `true` if module is loaded
-- @moduleName string Module name
-- @return boolean `true` if module is loaded
function Resources:IsModuleLoaded(moduleName)
    if (moduleName == nil or type(moduleName) ~= 'string') then
        return true
    end

    moduleName = string.lower(tostring(moduleName))

    if (Resources:ModuleExists(moduleName)) then
        return not (not Resources.FrameworkModules[moduleName].loaded or false)
    end
end

--
-- Returns a list of files in root directory of given resource
-- @resourceName string Name of the resource
-- @return array List of files in root directory
--
function Resources:GetResourceFiles(resourceName)
    if (resourceName == nil or type(resourceName) ~= 'string') then
        return false
    end

    local resourcePath = GetResourcePath(resourceName)

    return Resources:GetPathFiles(resourcePath)
end

--
-- Returns a list of files in root directory of given module
-- @moduleName string Name of the module
-- @return array List of files in root directory
--
function Resources:GetModuleFiles(moduleName)
    if (moduleName == nil or type(moduleName) ~= 'string') then
        return false
    end

    local resourcePath = GetResourcePath(GetCurrentResourceName()) .. '/modules/' .. moduleName .. '/'

    return Resources:GetPathFiles(resourcePath)
end

--- Returns a list of files in given path
--- @param path string path
function Resources:GetPathFiles(path)
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

--
-- Returns `true` if given resource is a framework resource
-- @resourceName string Name of the resource
-- @return boolean `true` if resource is framework resource
--
function Resources:IsFrameworkResource(resourceName)
    local resourceFiles = Resources:GetResourceFiles(resourceName)

    for _, file in pairs(resourceFiles or {}) do
        if (string.lower(file) == 'module.json') then
            return true, resourceFiles
        end
    end

    return false, '/'
end

--
-- Returns `true` if given module is a framework module
-- @moduleName string Name of the module
-- @return boolean `true` if module is framework module
--
function Resources:IsFrameworkModule(moduleName)
    local moduleFiles = Resources:GetModuleFiles(moduleName)

    for _, file in pairs(moduleFiles or {}) do
        if (string.lower(file) == 'module.json') then
            return true, moduleFiles
        end
    end

    return false, '/'
end

--
-- Returns a list of framework resources
-- @return array List of framework resources
--
function Resources:GetResources()
    local results = {}
    local resources = GetNumResources()

    for index = 0, resources, 1 do
        local resourceName = GetResourceByFindIndex(index)
        local isFrameworkResource, resourcePath = Resources:IsFrameworkResource(resourceName)

        if (isFrameworkResource) then
            local _object = class('resource')

            _object:set {
                name = resourceName,
                path = resourcePath
            }

            table.insert(results, _object)
        end
    end

    return results
end

--
-- Returns a list of framework modules
-- @return array List of framework modules
--
function Resources:GetModules()
    local results = {}
    local moduleDirectoryFiles = Resources:GetPathFiles(GetResourcePath(GetCurrentResourceName()) .. '/modules/')

    for _, moduleDir in pairs (moduleDirectoryFiles or {}) do
        local isFrameworkModule, resourcePath = Resources:IsFrameworkModule(moduleDir)

        if (isFrameworkModule) then
            local _object = class('resource-module')

            _object:set {
                name = moduleDir,
                path = GetResourcePath(GetCurrentResourceName()) .. '/modules/' .. moduleDir .. '/'
            }

            table.insert(results, _object)
        end
    end

    local metadataModules = {}

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'module'), 1 do
        table.insert(metadataModules, GetResourceMetadata(GetCurrentResourceName(), 'module', i))
    end

    if (#metadataModules > 0) then
        local sortedModules = {}

        while #metadataModules > 0 do
            for _, module in pairs(results or {}) do
                if (module ~= nil and string.lower(module.name) == string.lower(metadataModules[1])) then
                    table.insert(sortedModules, module)

                    table.remove(results, _)
                    table.remove(metadataModules, 1)
                end
            end

            table.remove(metadataModules, 1)
        end

        for _, module in pairs(results or {}) do
            if (module ~= nil) then
                table.insert(sortedModules, module)
            end
        end

        return sortedModules
    end

    return results
end

--
-- Generates a manifest object for resource
-- @resourceName string Resource name
-- @data array Raw json data from resource
-- @return object Resource manifest object
--
function Resources:GenerateManifestInfo(resourceName, module, data)
    local _manifest = class('manifest')

    _manifest:set {
        name = resourceName,
        module = module,
        isModule = resourceName == GetCurrentResourceName(),
        raw = data
    }

    for key, value in pairs(data) do
        if (key ~= nil) then
            _manifest:set(key, value)
        end
    end

    function _manifest:GetValue(key)
        if (key == nil or type(key) ~= 'string') then
            return nil
        end

        if (_manifest.raw ~= nil and _manifest.raw[key] ~= nil) then
            return _manifest.raw[key]
        end

        return nil
    end

    return _manifest
end

--
-- Returns a manifest for given resource
-- @resourceName string Resource name
-- @return object Resource manifest object
--
function Resources:GetResourceManifestInfo(resourceName)
    if (resourceName == nil or type(resourceName) ~= 'string') then
        return Resources:GenerateManifestInfo(resourceName, resourceName, {})
    end

    local content = LoadResourceFile(resourceName, 'module.json')

    if (content) then
        local data = json.decode(content)

        if (data) then
            return Resources:GenerateManifestInfo(resourceName, resourceName, data)
        end
    end

    return Resources:GenerateManifestInfo(resourceName, resourceName, {})
end

--
-- Returns a manifest for given resource
-- @resourceName string Resource name
-- @return object Resource manifest object
--
function Resources:GetModuleManifestInfo(moduleName)
    if (moduleName == nil or type(moduleName) ~= 'string') then
        return Resources:GenerateManifestInfo(GetCurrentResourceName(), moduleName, {})
    end

    local content = LoadResourceFile(GetCurrentResourceName(), 'modules/' .. moduleName .. '/module.json')

    if (content) then
        local data = json.decode(content)

        if (data) then
            return Resources:GenerateManifestInfo(GetCurrentResourceName(), moduleName, data)
        end
    end

    return Resources:GenerateManifestInfo(GetCurrentResourceName(), moduleName, {})
end

--
-- Execute all framework resources and modules
--
function Resources:Execute()
    local modules = Resources:GetModules()
    local resources = Resources:GetResources()

    for _, module in pairs(modules or {}) do
        if (not Resources:IsModuleLoaded(module.name)) then
            local manifest = Resources:GetModuleManifestInfo(module.name)
            local script = ''
            local _type = 'client'

            Resources:LoadTranslations(manifest)

            if (SERVER) then
                _type = 'server'
            end

            for _, _file in pairs(manifest:GetValue(('%s_scripts'):format(_type)) or {}) do
                local code = LoadResourceFile(GetCurrentResourceName(), 'modules/' .. module.name .. '/' .. _file)

                if (code) then
                    script = script .. code .. '\n'
                end
            end

            _ENV.CurrentFrameworkResource = GetCurrentResourceName()
            _ENV.CurrentFrameworkModule = module.name

            local fn = load(script, ('@%s:%s:%s'):format(GetCurrentResourceName(), module.name, _type), 't', _ENV)

            xpcall(fn, function(err)
                print(err)
            end)

            if (not Resources:ModuleExists(module.name)) then
                local _object = Resources:extend('resource-module')

                _object:set {
                    name = module.name,
                    manifest = manifest,
                    loaded = true
                }

                local moduleName = string.lower(tostring(module.name))

                Resources.FrameworkModules[moduleName] = _object
            end
        end
    end

    for _, resource in pairs(resources or {}) do
        if (not Resources:IsLoaded(resource.name)) then
            local manifest = Resources:GetResourceManifestInfo(resource.name)
            local script = ''
            local _type = 'client'

            Resources:LoadTranslations(manifest)

            if (SERVER) then
                _type = 'server'
            end

            for _, _file in pairs(manifest:GetValue(('%s_scripts'):format(_type)) or {}) do
                local code = LoadResourceFile(resource.name, _file)

                if (code) then
                    script = script .. code .. '\n'
                end
            end

            _ENV.CurrentFrameworkResource = resource.name

            local fn = load(script, ('@%s:%s'):format(resource.name, _type), 't', _ENV)

            xpcall(fn, function(err)
                print(err)
            end)

            if (not Resources:Exists(resource.name)) then
                local _object = Resources:extend('resource')

                _object:set {
                    manifest = manifest,
                    loaded = true
                }

                local resourceName = string.lower(tostring(resource.name))

                Resources.Resources[resourceName] = _object
            end
        end
    end

    _ENV.CurrentFrameworkResource = nil
    _ENV.CurrentFrameworkModule = nil

    Resources.AllResourcesLoaded = true
end

--- Load all translations from manifest
--- @param manifest manifest Manifest Info
function Resources:LoadTranslations(manifest)
    if (manifest ~= nil and string.lower(type(manifest)) == 'manifest') then
        local languages = manifest:GetValue('languages') or {}

        for key, location in pairs(languages or {}) do
            if (string.lower(tostring(key)) == LANGUAGE) then
                if (manifest.isModule or false) then
                    local content = LoadResourceFile(GetCurrentResourceName(), 'modules/' .. manifest.module .. '/' .. location)

                    if (content) then
                        local data = json.decode(content)

                        if (data) then
                            if (FXCore.Translations[GetCurrentResourceName()] == nil) then
                                FXCore.Translations[GetCurrentResourceName()] = {}
                            end

                            if (FXCore.Translations[GetCurrentResourceName()][manifest.module] == nil) then
                                FXCore.Translations[GetCurrentResourceName()][manifest.module] = {}
                            end

                            for _key, _value in pairs(data or {}) do
                                FXCore.Translations[GetCurrentResourceName()][manifest.module][_key] = _value
                            end
                        end
                    end
                else
                    local content = LoadResourceFile(manifest.name, location)

                    if (content) then
                        local data = json.decode(content)

                        if (data) then
                            if (FXCore.Translations[manifest.name] == nil) then
                                FXCore.Translations[manifest.name] = {}
                            end

                            if (FXCore.Translations[manifest.name][manifest.module] == nil) then
                                FXCore.Translations[manifest.name][manifest.module] = {}
                            end

                            for _key, _value in pairs(data or {}) do
                                FXCore.Translations[manifest.name][manifest.module][_key] = _value
                            end
                        end
                    end
                end
            end
        end
    end
end