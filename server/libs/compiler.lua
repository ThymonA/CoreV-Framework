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
compiler = class('compiler')

--- Default values
compiler:set {
    externalResources = {},
    internalResources = {},
    internalModules = {},
    tasks = {
    }
}

--- Returns a list of files of given path
--- @param path string Path
function compiler:getPathFiles(path)
    local results = {}

    if ((string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') and path ~= nil) then
        for _file in io.popen(('dir "%s" /b'):format(path)):lines() do
            table.insert(results, _file)
        end
    elseif ((string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') and path ~= nil) then
        local callit = os.tmpname()

        os.execute("ls ".. path .. " | grep -v / >"..callit)

        local f = io.open(callit,"r")
        local rv = f:read("*a")

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

--- Generates and load framework meta files
function compiler:loadCurrentResourceManifest()
    local manifest = class('framework-manifest')

    --- Set default values
    manifest:set {
        name = GetCurrentResourceName(),
        files = {},
        clients = {}
    }

    --- Load all required client files
    for i = 0, GetNumResourceMetadata(manifest.name, 'corevclient'), 1 do
        local file = GetResourceMetadata(manifest.name, 'corevclient', i)

        if (file ~= nil) then
            local _file = string.trim(file)

            _file = string.replace(_file, '\\', '/')
            _file = string.replace(_file, '//', '/')
            _file = string.replace(_file, '**', '.*')

            table.insert(manifest.clients, _file)
        end
    end

    --- Load all required files
    for i = 0, GetNumResourceMetadata(manifest.name, 'corevfile'), 1 do
        local file = GetResourceMetadata(manifest.name, 'corevfile', i)

        if (file ~= nil) then
            local _file = string.trim(file)

            _file = string.replace(_file, '\\', '/')
            _file = string.replace(_file, '//', '/')
            _file = string.replace(_file, '**', '.*')

            table.insert(manifest.files, _file)
        end
    end

    return manifest
end

--- Returns a list with all the files in current resource
function compiler:loadCurrentResourceFileStructure()
    local internalPath = GetResourcePath(GetCurrentResourceName())
    internalPath = internalPath:gsub('//', '/')

    local manifest = class('framework-structure')

    --- Set default values
    manifest:set {
        name = GetCurrentResourceName(),
        structures = {}
    }

    local structures = {}

    if (string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') then
        for file in io.popen(('dir "%s" /b /S'):format(internalPath)):lines() do
            local _file = string.trim(file)

            _file = _file:gsub('\\', '/')
            _file = _file:gsub('//', '/')
            _file = _file:sub(internalPath:len() + 2, _file:len())

            table.insert(structures, _file)
        end
    elseif (string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') then
        local callit = os.tmpname()

        os.execute(('find %s -print > %s'):format(internalPath, callit))

        local f = io.open(callit,"r")
        local rv = f:read("*a")

        f:close()
        os.remove(callit)

        local from  = 1
        local delim_from, delim_to = string.find(rv, "\n", from)

        while delim_from do
            local _file = string.trim(string.sub(rv, from , delim_from-1))

            _file = _file:gsub('\\', '/')
            _file = _file:gsub('//', '/')
            _file = _file:sub(internalPath:len() + 2, _file:len())

            table.insert(structures, _file)

            from  = delim_to + 1
            delim_from, delim_to = string.find(rv, "\n", from)
        end
    end

    for _, structure in pairs(structures or {}) do
        local ignoreFile = false

        if (string.startswith(string.trim(structure), '.')) then
            ignoreFile = true
        elseif (string.startswith(string.trim(structure), 'cache')) then
            ignoreFile = true
        end

        if (not ignoreFile) then
            table.insert(manifest.structures, structure)
        end
    end

    return manifest
end

--- Filter all filestructures files based on framework manifest
--- @param frameworkManifest framework-manifest Framework's Manifest
--- @param fileStructures framework-structure Framework's File Strcuture
function compiler:filterAllResourceFiles(frameworkManifest, fileStructures)
    local includedFiles = { clients = {}, files = {} }

    for _, structure in pairs(fileStructures.structures or {}) do
        local _hasMatch = false

        for __, clientFile in pairs(frameworkManifest.clients or {}) do
            local _match = string.find(structure, clientFile)

            if (_match ~= nil and _match == 1) then
                _hasMatch = true
            end
        end

        if (_hasMatch) then
            table.insert(includedFiles.clients, structure)
        end

        _hasMatch = false

        for __, clientFile in pairs(frameworkManifest.files or {}) do
            local _match = string.find(structure, clientFile)

            if (_match ~= nil and _match == 1) then
                _hasMatch = true
            end
        end

        if (_hasMatch) then
            table.insert(includedFiles.files, structure)
        end
    end

    local allClientFiles = {}

    for _, clientFile in pairs(includedFiles.clients or {}) do
        local _found = false

        for _, _clientFile in pairs(allClientFiles or {}) do
            if (_clientFile == clientFile) then
                _found = true
            end
        end

        if (not _found) then
            table.insert(allClientFiles, clientFile)
        end
    end

    for _, clientFile in pairs(includedFiles.files or {}) do
        local _found = false

        for _, _clientFile in pairs(allClientFiles or {}) do
            if (_clientFile == clientFile) then
                _found = true
            end
        end

        if (not _found) then
            table.insert(allClientFiles, clientFile)
        end
    end

    return allClientFiles, includedFiles.clients, includedFiles.files
end

--- Returns a path type: directory or file
--- @param path string Path to check
function compiler:pathType(path)
    path = string.replace(path, '\\', '/')
    path = string.replace(path, '//', '/')

    local pathInfo = string.split(path, '/') or {}

    if (#pathInfo <= 0) then
        return 'unknown'
    end

    if (string.find(pathInfo[#pathInfo], '.', 1, true) and not string.startswith(pathInfo[#pathInfo], '.')) then
        return 'file'
    end

    return 'directory'
end

--- Create a directory if not exists
function compiler:createDirectoryIfNotExists(path)
    if (string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') then
        path = string.replace(path, '//', '/')
        path = string.replace(path, '/', '\\')
        path = string.replace(path, '\\\\', '\\')

        os.execute(('md "%s"'):format(path))
    elseif (string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') then
        path = string.replace(path, '\\\\', '\\')
        path = string.replace(path, '\\', '/')
        path = string.replace(path, '//', '/')

        os.execute(('mkdir -p %s'):format(path))
    end
end

--- Generates and compiles a resource folder
function compiler:generateResource()
    local done = false

    Citizen.CreateThread(function()
        local clientResourceFound = false
        local clientResourceName = ('%s_client'):format(GetCurrentResourceName())
        local internalPath = GetResourcePath(GetCurrentResourceName())

        local internalPathParent = internalPath:gsub('%/' .. GetCurrentResourceName(), '/')
        internalPathParent = internalPathParent:gsub('%\\' .. GetCurrentResourceName(), '\\')

        local clientResourcePath = internalPath:gsub('%/' .. GetCurrentResourceName(), ('/%s'):format(clientResourceName))
        clientResourcePath = clientResourcePath:gsub('%\\' .. GetCurrentResourceName(), ('\\%s'):format(clientResourceName))

        for _, directory in pairs(self:getPathFiles(internalPathParent) or {}) do
            if (directory ~= nil and string.lower(directory) == clientResourceName) then
                clientResourceFound = true
                break
            end
        end

        if (clientResourceFound) then
            print(('[^5Core^4V^7] Deleting resource "^5%s^7"'):format(clientResourceName))

            if ((string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') and clientResourcePath ~= nil) then
                os.execute(('rmdir /s /q "%s"'):format(clientResourcePath))
            elseif ((string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') and clientResourcePath ~= nil) then
                os.execute(('rm --recursive %s'):format(clientResourcePath))
            end

            print(('[^5Core^4V^7] Resource "^5%s^7" deleted'):format(clientResourceName))
        end

        local frameworkManifest = self:loadCurrentResourceManifest()
        local fileStructure = self:loadCurrentResourceFileStructure()
        local publicFiles, clientFiles, fileFiles = self:filterAllResourceFiles(frameworkManifest, fileStructure)
        local frameworkPath = internalPath
        local frameworkClientPath = clientResourcePath
        local pathsCreated = {}

        if (not string.endswith(frameworkPath, '/')) then frameworkPath = frameworkPath .. '/' end
        if (not string.endswith(frameworkClientPath, '/')) then frameworkClientPath = frameworkClientPath .. '/' end

        local asyncTaskDone = false
        local async = m('async')

        print(('[^5Core^4V^7] Generate folder structure for "^5%s^7"'):format(clientResourceName))

        --- Create all required directories
        async:parallel(function(file, cb)
            local currentFileLocation = frameworkPath .. file
            local newFileLocation = frameworkClientPath .. file

            currentFileLocation = string.replace(currentFileLocation, '\\\\', '\\')
            currentFileLocation = string.replace(currentFileLocation, '\\', '/')
            currentFileLocation = string.replace(currentFileLocation, '//', '/')
            newFileLocation = string.replace(newFileLocation, '\\\\', '\\')
            newFileLocation = string.replace(newFileLocation, '\\', '/')
            newFileLocation = string.replace(newFileLocation, '//', '/')

            local filePathInfo = string.split(file, '/')
            local currentFilePath = nil

            compiler:createDirectoryIfNotExists(clientResourcePath)

            for _, pathInfo in pairs(filePathInfo or {}) do
                if (currentFilePath == nil and string.find(pathInfo, '.', 1, true) == nil) then
                    currentFilePath = pathInfo
                elseif (self:pathType(currentFilePath .. '/' .. pathInfo) == 'directory' and not (string.find(pathInfo, '.', 1, true) or false)) then
                    currentFilePath = currentFilePath .. '/' .. pathInfo
                else
                    break
                end
            end

            if (pathsCreated[currentFilePath] == nil) then
                pathsCreated[currentFilePath] = currentFilePath

                if (not (string.find(frameworkClientPath .. currentFilePath, '.', 1, true) or false)) then
                    compiler:createDirectoryIfNotExists(frameworkClientPath .. currentFilePath)
                end
            end

            cb()
        end, publicFiles, function()
            asyncTaskDone = true
        end)

        repeat Citizen.Wait(0) until asyncTaskDone == true

        print(('[^5Core^4V^7] Folder structure for "^5%s^7" has been generated'):format(clientResourceName))

        self:generateExecutables(frameworkPath, frameworkClientPath, publicFiles, clientFiles, fileFiles)

        done = true
    end)

    repeat Wait(0) until done == true
end

function compiler:generateExecutables(frameworkPath, clientPath, publicFiles, clientFiles, fileFiles)
    print(('[^5Core^4V^7] Copy files from "^5%s^7" to "^5%s^7"'):format(GetCurrentResourceName(), GetCurrentResourceName() .. '_client'))

    local enabledInternalModules = {}
    local additionalClientFiles = {}
    local addedModules = {}

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevmodule'), 1 do
        local _module = GetResourceMetadata(GetCurrentResourceName(), 'corevmodule', i)

        if (_module ~= nil and type(_module) == 'string') then
            table.insert(enabledInternalModules, string.lower(_module))
        end
    end

    for _, internalModuleName in pairs(enabledInternalModules or {}) do
        addedModules[internalModuleName] = true

        table.insert(additionalClientFiles, ('client/%s_module_client.lua'):format(internalModuleName))
    end

    for _, internalModule in pairs(resource.internalModules or {}) do
        local internalModuleName = internalModule.name

        if (string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') then
        elseif (string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') then
            local frameworkFilePath = ('%s/debug/internal_modules/client/%s_client.lua'):format(frameworkPath, internalModuleName)
            local frameworkClientFilePath = ('%s/client/%s_module_client.lua'):format(clientPath, internalModuleName)

            if (addedModules[internalModuleName] == nil) then
                table.insert(additionalClientFiles, ('client/%s_module_client.lua'):format(internalModuleName))
            end

            frameworkFilePath = string.replace(frameworkFilePath, '\\\\', '\\')
            frameworkFilePath = string.replace(frameworkFilePath, '\\', '/')
            frameworkFilePath = string.replace(frameworkFilePath, '//', '/')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\\\', '\\')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\', '/')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '//', '/')

            os.execute(('cp -r %s %s'):format(frameworkFilePath, frameworkClientFilePath))
        end
    end

    for _, internalResource in pairs(resource.internalResources or {}) do
        local internalResourceName = internalResource.name

        if (string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') then
        elseif (string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') then
            local frameworkFilePath = ('%s/debug/internal_resources/client/%s_client.lua'):format(frameworkPath, internalResourceName)
            local frameworkClientFilePath = ('%s/client/%s_resource_client.lua'):format(clientPath, internalResourceName)

            table.insert(additionalClientFiles, ('client/%s_resource_client.lua'):format(internalResourceName))

            frameworkFilePath = string.replace(frameworkFilePath, '\\\\', '\\')
            frameworkFilePath = string.replace(frameworkFilePath, '\\', '/')
            frameworkFilePath = string.replace(frameworkFilePath, '//', '/')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\\\', '\\')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\', '/')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '//', '/')

            os.execute(('cp -r %s %s'):format(frameworkFilePath, frameworkClientFilePath))
        end
    end

    for _, publicFile in pairs(publicFiles or {}) do
        if (string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') then
        elseif (string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') then
            local frameworkFilePath = ('%s/%s'):format(frameworkPath, publicFile)
            local frameworkClientFilePath = ('%s/%s'):format(clientPath, publicFile)

            frameworkFilePath = string.replace(frameworkFilePath, '\\\\', '\\')
            frameworkFilePath = string.replace(frameworkFilePath, '\\', '/')
            frameworkFilePath = string.replace(frameworkFilePath, '//', '/')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\\\', '\\')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\', '/')
            frameworkClientFilePath = string.replace(frameworkClientFilePath, '//', '/')

            os.execute(('cp -r %s %s'):format(frameworkFilePath, frameworkClientFilePath))
        end
    end

    print(('[^5Core^4V^7] Files copied from "^5%s^7" to "^5%s^7"'):format(GetCurrentResourceName(), GetCurrentResourceName() .. '_client'))
    print(('[^5Core^4V^7] Generate ^5fxmanifest^7 for "^5%s^7"'):format(GetCurrentResourceName() .. '_client'))

    ---
    local fxManifestTemplate = [[
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
fx_version 'adamant'
game 'gta5'

name 'CoreV'
version '1.0.0'
description 'Custom FiveM Framework'
author 'ThymonA'
contact 'contact@arens.io'
url 'https://git.arens.io/ThymonA/corev-framework/'

ui_page '{{{ui}}}'
ui_page_preload 'yes'

client_scripts {
    {{{client_scripts}}}
}

files {
    {{{files}}}
}

modules {
    {{{modules}}}
}

resources {
    {{{resources}}}
}
]]

    local fx_client_scripts, fx_files, fx_ui, fx_modules, fx_resources = {}, {}, '', {}, {}

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevclient'), 1 do
        local _file = GetResourceMetadata(GetCurrentResourceName(), 'corevclient', i)

        if (_file ~= nil and type(_file) == 'string') then
            table.insert(fx_client_scripts, string.lower(_file))
        end
    end

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevfile'), 1 do
        local _file = GetResourceMetadata(GetCurrentResourceName(), 'corevfile', i)

        if (_file ~= nil and type(_file) == 'string') then
            table.insert(fx_files, string.lower(_file))
        end
    end

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevuipage'), 1 do
        local _file = GetResourceMetadata(GetCurrentResourceName(), 'corevuipage', i)

        if (_file ~= nil and type(_file) == 'string') then
            fx_ui = _file
            break
        end
    end

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevmodule'), 1 do
        local _file = GetResourceMetadata(GetCurrentResourceName(), 'corevmodule', i)

        if (_file ~= nil and type(_file) == 'string') then
            table.insert(fx_modules, string.lower(_file))
        end
    end

    for i = 0, GetNumResourceMetadata(GetCurrentResourceName(), 'corevresource'), 1 do
        local _file = GetResourceMetadata(GetCurrentResourceName(), 'corevresource', i)

        if (_file ~= nil and type(_file) == 'string') then
            table.insert(fx_resources, string.lower(_file))
        end
    end

    for _, additionalClientFile in pairs(additionalClientFiles) do
        if (additionalClientFile ~= nil and type(additionalClientFile) == 'string') then
            table.insert(fx_client_scripts, additionalClientFile)
        end
    end

    local fxManifest = mustache:render(fxManifestTemplate, {
        client_scripts = self:tableToString(fx_client_scripts),
        files = self:tableToString(fx_files),
        ui = fx_ui,
        modules = self:tableToString(fx_modules),
        resources = self:tableToString(fx_resources)
    })

    SaveResourceFile(GetCurrentResourceName(), 'debug/__fxmanifest.lua', fxManifest)

    if (string.lower(OperatingSystem) == 'win' or string.lower(OperatingSystem) == 'windows') then
    elseif (string.lower(OperatingSystem) == 'lux' or string.lower(OperatingSystem) == 'linux') then
        local frameworkFilePath = ('%s/debug/__fxmanifest.lua'):format(frameworkPath)
        local frameworkClientFilePath = ('%s/fxmanifest.lua'):format(clientPath)

        frameworkFilePath = string.replace(frameworkFilePath, '\\\\', '\\')
        frameworkFilePath = string.replace(frameworkFilePath, '\\', '/')
        frameworkFilePath = string.replace(frameworkFilePath, '//', '/')
        frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\\\', '\\')
        frameworkClientFilePath = string.replace(frameworkClientFilePath, '\\', '/')
        frameworkClientFilePath = string.replace(frameworkClientFilePath, '//', '/')

        os.execute(('cp -r %s %s'):format(frameworkFilePath, frameworkClientFilePath))
    end

    print(('[^5Core^4V^7] ^5fxmanifest^7 generated for "^5%s^7"'):format(GetCurrentResourceName() .. '_client'))

    print(('[^5Core^4V^7] Execute command "^5stop %s^7"'):format(GetCurrentResourceName() .. '_client'))

    ExecuteCommand(('stop %s_client'):format(GetCurrentResourceName()))

    Wait(250)

    print('[^5Core^4V^7] Execute command "^5refresh^7"')
    ExecuteCommand('refresh')

    Wait(250)

    print(('[^5Core^4V^7] Execute command "^5start %s^7"'):format(GetCurrentResourceName() .. '_client'))
    ExecuteCommand(('start %s_client'):format(GetCurrentResourceName()))
end

function compiler:tableToString(table)
    if (table == nil or type(table) ~= 'table') then
        if (table == nil or type(table) == 'string') then
            return table
        end

        return ''
    end

    local tempString = nil

    for i = 1, #table, 1 do
        if (i < #table) then
            if (tempString == nil) then tempString = ("'%s',"):format(table[i])
            else
                tempString = ("%s\n    '%s',"):format(tempString, table[i])
            end
        else
            if (tempString == nil) then tempString = ("'%s'"):format(table[i])
            else
                tempString = ("%s\n    '%s'"):format(tempString, table[i])
            end
        end
    end

    return tempString or ''
end