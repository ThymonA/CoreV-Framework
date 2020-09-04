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
    for i = 0, GetNumResourceMetadata(manifest.name, 'client_script'), 1 do
        local file = GetResourceMetadata(manifest.name, 'client_script', i)

        if (file ~= nil) then
            local _file = string.trim(file)

            _file = string.replace(_file, '\\', '/')
            _file = string.replace(_file, '//', '/')
            _file = string.replace(_file, '**', '.*')

            table.insert(manifest.clients, _file)
        end
    end

    --- Load all required files
    for i = 0, GetNumResourceMetadata(manifest.name, 'file'), 1 do
        local file = GetResourceMetadata(manifest.name, 'file', i)

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
        os.execute('find "' .. internalPath .. '" | grep -v / >' .. callit)
        local f = io.open(callit, 'r')
        local rv = f:read('*all')
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

--- Generates and compiles a resource folder
function compiler:generateResource()
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
    local includedFiles = {
        clients = {},
        files = {}
    }

    for _, structure in pairs(fileStructure.structures or {}) do
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

    for _, clientFile in pairs(allClientFiles or {}) do
        print(('^7[^4CoreV^7] ^1%s'):format(clientFile))
    end
end