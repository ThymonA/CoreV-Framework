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
local assert = assert

--- Cache global variables
local __global = assert(_G)
local __environment = assert(_ENV)
local type = assert(type)
local rawget = assert(rawget)
local rawset = assert(rawset)
local tonumber = assert(tonumber)
local tostring = assert(tostring)
local encode = assert(json.encode)
local lower = assert(string.lower)
local sub = assert(string.sub)
local len = assert(string.len)
local match = assert(string.match)
local gmatch = assert(string.gmatch)
local insert = assert(table.insert)
local load = assert(load)
local pcall = assert(pcall)
local xpcall = assert(xpcall)
local pairs = assert(pairs)
local next = assert(next)
local traceback = assert(debug.traceback)
local error = assert(error)
local print = assert(print)
local vector3 = assert(vector3)
local vector2 = assert(vector2)
local setmetatable = assert(setmetatable)
local pack = assert(pack or table.pack)
local unpack = assert(unpack or table.unpack)
local CreateThread = assert(Citizen.CreateThread)
local Wait = assert(Citizen.Wait)

--- FiveM cached global variables
local LoadResourceFile = assert(LoadResourceFile)
local GetResourceState = assert(GetResourceState)
local _TCE = assert(TriggerClientEvent)
local _RSE = assert(RegisterServerEvent)
local _AEH = assert(AddEventHandler)
local IsDuplicityVersion = assert(IsDuplicityVersion)
local GetPlayerIdentifiers = assert(GetPlayerIdentifiers)
local GetCurrentResourceName = assert(GetCurrentResourceName)

--- Required resource variables
local isServer = IsDuplicityVersion()
local currentResourceName = GetCurrentResourceName()

--- Cahce FiveM globals
local exports = assert(exports)
local __exports = assert({})

--- Prevent loading from crashing
local function try(func, catch_func)
    if (type(func) ~= 'function') then return end
    if (type(catch_func) ~= 'function') then return end

    local ok, exp = pcall(func)

    if (not ok) then
        catch_func(exp)
    end
end

local function load_export(_le, index)
    CreateThread(function()
        while GetResourceState(_le.r) ~= 'started' do Wait(0) end

        try(function()
            if (currentResourceName ~= _le.r) then
                __exports[index] = { self = assert(exports[_le.r]), func = nil }
                __exports[index].func = assert(__exports[index].self[_le.f])
            else
                __exports[index] = { self = nil, func = __global[_le.f] or __environment[_le.f] or function() return nil end }
            end
        end, function()
            __exports[index] = { self = nil, func = function() end }
        end)
    end)
end

--- Load those exports
local __loadExports = {
    { r = 'cvf_config', f = '__c' },
    { r = 'cvf_ids', f = '__id' },
    { r = 'cvf_translations', f = '__t' },
    { r = 'mysql-async', f = 'is_ready'},
    { r = 'mysql-async', f = 'mysql_insert' },
    { r = 'mysql-async', f = 'mysql_fetch_scalar' },
    { r = 'mysql-async', f = 'mysql_fetch_all' },
    { r = 'mysql-async', f = 'mysql_execute' },
    { r = 'cvf_jobs', f = '__a' },
    { r = 'cvf_jobs', f = '__l' },
    { r = 'cvf_events', f = '__add' },
    { r = 'cvf_events', f = '__del' }
}

--- Store global exports as local variable
for index, _le in pairs(__loadExports) do
    try(function()
        if (currentResourceName ~= _le.r) then
            __exports[index] = { self = assert(exports[_le.r]), func = nil }
            __exports[index].func = assert(__exports[index].self[_le.f])
        else
            __exports[index] = { self = nil, func = __global[_le.f] or __environment[_le.f] or function() return nil end }
        end
    end, function()
        __exports[index] = { self = nil, func = function() end }

        load_export(_le, index)
    end)
end

--- Remove table from memory
__loadExports = nil

if (not isServer) then
    error('You are trying to load a server file which is only allowed on the server side')
    return
end

--- Modify global variable
global = setmetatable({}, {
    __newindex = function(_, n, v)
        __global[n]         = v
        __environment[n]    = v
        rawset(_, n, v)
    end
})

--- Makes sure that class is available
local function getClass()
    if (class ~= nil) then return class end
    if (class) then return class end
    if (_G.class ~= nil) then return _G.class end
    if (_G.class) then return _G.class end

    local rawClassFile = LoadResourceFile('corev', 'vendors/class.lua')

    if (rawClassFile) then
        local func, _ = load(rawClassFile, 'corev/vendors/class.lua')

        if (func) then
            local ok, result = xpcall(func, traceback)

            if (ok) then
                global.class = result

                return global.class
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end
end

--- Cache global variables
local class = assert(getClass())

--- Create CoreV class
--- @class CoreV
local corev = class "corev"

--- Set default values for `corev` class
corev:set('db', class "corev-db")
corev:set('callback', class "corev-callback")
corev:set('jobs', class "corev-jobs")
corev:set('events', class "corev-events")

--- Set default values for `corev-db` class
corev.db:set('ready', false)
corev.db:set('hasMigrations', false)

--- Set default values for `corev-callback` class
corev.callback:set('callbacks', {})

--- Tries to execute `func`, if any error occur, `catch_func` will be triggerd
--- @param func function Function to execute
--- @param catch_func function Fallback function when error occur
function corev:try(func, catch_func)
    return try(func, catch_func)
end

--- Return a value type of any CFX object
--- @param value any Any value
--- @return string Type of value
function corev:typeof(value)
    if (value == nil) then return 'nil' end

    local rawType = type(value) or 'nil'

    if (rawType ~= 'table') then return rawType end

    local isFunction = rawget(value, '__cfx_functionReference') ~= nil or
        rawget(value, '__cfx_async_retval') ~= nil

    if (isFunction) then return 'function' end

    local isSource = rawget(value, '__cfx_functionSource') ~= nil

    if (isSource) then return 'number' end
    if (value.__class) then return class.name(value) end

    return rawType
end

--- Makes sure your input matches your type of defaultValue
--- @param input any Any type of value you want to match with defaultValue
--- @param defaultValue any Any default value when input don't match with defaultValue's type
--- @return any DefaultValue or translated/transformed input
function corev:ensure(input, defaultValue)
    if (defaultValue == nil) then
        return nil
    end

    local inputType = self:typeof(defaultValue)

    if (input == nil) then
        return defaultValue
    end

    local currentInputType = self:typeof(input)

    if (currentInputType == inputType) then
        return input
    end

    if (inputType == 'number') then
        if (currentInputType == 'string') then return tonumber(input) or defaultValue end
        if (currentInputType == 'boolean') then return input and 1 or 0 end

        return defaultValue
    end

    if (inputType == 'string') then
        if (currentInputType == 'number') then return tostring(input) or defaultValue end
        if (currentInputType == 'boolean') then return input and 'yes' or 'no' end
        if (currentInputType == 'table') then return encode(input) or defaultValue end
        if (currentInputType == 'vector3') then return encode({input.x, input.y, input.z}) or defaultValue end
        if (currentInputType == 'vector2') then return encode({input.x, input.y}) or defaultValue end

        return defaultValue
    end

    if (inputType == 'boolean') then
        if (currentInputType == 'string') then
            input = lower(input)

            if (input == 'true') then return true end
            if (input == 'false') then return false end
            if (input == '1') then return true end
            if (input == '0') then return false end
            if (input == 'yes') then return true end
            if (input == 'no') then return false end
            if (input == 'y') then return true end
            if (input == 'n') then return false end

            return defaultValue
        end

        if (currentInputType == 'number') then
            if (input == 1) then return true end
            if (input == 0) then return false end

            return defaultValue
        end

        return defaultValue
    end

    if (inputType == 'vector3') then
        if (currentInputType == 'table') then
            local _x = self:ensure(input.x, defaultValue.x)
            local _y = self:ensure(input.y, defaultValue.y)
            local _z = self:ensure(input.z, defaultValue.z)

            return vector3(_x, _y, _z)
        end

        if (currentInputType == 'vector2') then
            local _x = self:ensure(input.x, defaultValue.x)
            local _y = self:ensure(input.y, defaultValue.y)

            return vector3(_x, _y, 0)
        end

        if (currentInputType == 'number') then
            return vector3(input, input, input)
        end

        return defaultValue
    end

    if (inputType == 'vector2') then
        if (currentInputType == 'table') then
            local _x = self:ensure(input.x, defaultValue.x)
            local _y = self:ensure(input.y, defaultValue.y)

            return vector2(_x, _y)
        end

        if (currentInputType == 'vector3') then
            local _x = self:ensure(input.x, defaultValue.x)
            local _y = self:ensure(input.y, defaultValue.y)

            return vector2(_x, _y)
        end

        if (currentInputType == 'number') then
            return vector2(input, input)
        end

        return defaultValue
    end

    return defaultValue
end

--- Load or return cached configuration based on name
--- @param name string Name of configuration to load
--- @params ... string[] Filer results by key
--- @return any|nil Returns `any` data from cached configuration or `nil` if not found
function corev:cfg(name, ...)
    name = self:ensure(name, 'unknown')

    if (name == 'unknown') then return {} end

    if (__exports[1].self == nil) then
        return __exports[1].func(name, ...)
    else
        return __exports[1].func(__exports[1].self, name, ...)
    end
end

--- Generates a ID for given string
--- @param name string|number|nil String to generate a ID for
--- @return number Generated ID or Cached ID
function corev:id(name)
    if (name == nil) then return 0 end
    if (self:typeof(name) == 'number') then return name end

    name = self:ensure(name, 'unknown')

    if (name == 'unknown') then return 0 end

    if (__exports[2].self == nil) then
        return __exports[2].func(name)
    else
        return __exports[2].func(__exports[2].self, name)
    end
end

--- Returns translation key founded or 'MISSING TRANSLATION'
--- @param language string? (optional) Needs to be a two letter identifier, example: EN, DE, NL, BE, FR etc.
--- @param module string? (optional) Register translation for a module, example: core
--- @param key string Key of translation
--- @returns string Translation or 'MISSING TRANSLATION'
function corev:t(...)
    if (__exports[3].self == nil) then
        return __exports[3].func(...)
    else
        return __exports[3].func(__exports[3].self, ...) 
    end
end

--- Checks if a string starts with given word
--- @param str string String to search in
--- @param word string Word to search for
--- @return boolean `true` if word has been found, otherwise `false`
function corev:startswith(str, word)
    str = self:ensure(str, '')
    word = self:ensure(word, '')

    return sub(str, 1, #word) == word
end

--- Checks if a string ends with given word
--- @param str string String to search in
--- @param word string Word to search for
--- @return boolean `true` if word has been found, otherwise `false`
function corev:endswith(str, word)
    str = self:ensure(str, '')
    word = self:ensure(word, '')

    return sub(str, -#word) == word
end

--- Replace a string that contains `this` to `that`
--- @param str string String where to replace in
--- @param this string Word that's need to be replaced
--- @param that string Replace `this` whit given string
--- @returns string String where `this` has been replaced with `that`
function corev:replace(str, this, that)
    local b, e = str:find(this, 1, true)

    if b == nil then
        return str
    else
        return str:sub(1, b - 1) .. that .. self:replace(str:sub(e + 1), this, that)
    end
end

--- Split a string by given delim
--- @param str string String that's need to be split
--- @param delim string Split string by every given delim
--- @returns string[] List of strings, splitted at given delim
function corev:split(str, delim)
    local t = {}

    for substr in gmatch(self:ensure(str, ''), "[^".. delim .. "]*") do
        if substr ~= nil and len(substr) > 0 then
            insert(t, substr)
        end
    end

    return t
end

--- Trigger callback when database is ready
--- @param callback function Callback function to execute
function corev.db:dbReady(callback)
    callback = corev:ensure(callback, function() end)

    CreateThread(function()
        while GetResourceState('mysql-async') ~= 'started' do Wait(0) end
        while not __exports[4].func(__exports[4].self) do Wait(0) end

        callback()
    end)
end

--- Update ready state when database is ready
corev.db:dbReady(function()
    corev.db.ready = true
end)

--- Escape database params
--- @param params table Parameters to escape
--- @return table Safe parameters
function corev.db:safeParameters(params)
    params = corev:ensure(params, {})

    if (next(params) == nil) then
        return {[''] = ''}
    end

    return params
end

--- Execute async insert
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @param callback function Callback function to execute
function corev.db:insertAsync(query, params, callback)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})
    callback = corev:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev.db:dbReady(function()
            __exports[5].func(__exports[5].self, query, params, callback)
        end)
    else
        __exports[5].func(__exports[5].self, query, params, callback)
    end
end

--- Returns first column of first row
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @param callback function Callback function to execute
function corev.db:fetchScalarAsync(query, params, callback)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})
    callback = corev:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev.db:dbReady(function()
            __exports[6].func(__exports[6].self, query, params, callback)
        end)
    else
        __exports[6].func(__exports[6].self, query, params, callback)
    end
end

--- Fetch all results from database query
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @param callback function Callback function to execute
function corev.db:fetchAllAsync(query, params, callback)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})
    callback = corev:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev.db:dbReady(function()
            __exports[7].func(__exports[7].self, query, params, callback)
        end)
    else
        __exports[7].func(__exports[7].self, query, params, callback)
    end
end

--- Execute a query on database
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @param callback function Callback function to execute
function corev.db:executeAsync(query, params, callback)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})
    callback = corev:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev.db:dbReady(function()
            __exports[8].func(__exports[8].self, query, params, callback)
        end)
    else
        __exports[8].func(__exports[8].self, query, params, callback)
    end
end

--- Execute async insert
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @return any Returns results from database
function corev.db:insert(query, params)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})

    if (query == 'unknown') then return nil end

    local res, finished = nil, false

    self:insertAsync(query, params, function(result)
        res = result
        finished = true
    end)

    repeat Wait(0) until finished == true

    return res
end

--- Returns first column of first row
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @return any Returns results from database
function corev.db:fetchScalar(query, params)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})

    if (query == 'unknown') then return nil end

    local res, finished = nil, false

    self:fetchScalarAsync(query, params, function(result)
        res = result
        finished = true
    end)

    repeat Wait(0) until finished == true

    return res
end

--- Fetch all results from database query
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @return any Returns results from database
function corev.db:fetchAll(query, params)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})

    if (query == 'unknown') then return nil end

    local res, finished = nil, false

    self:fetchAllAsync(query, params, function(result)
        res = result
        finished = true
    end)

    repeat Wait(0) until finished == true

    return res
end

--- Execute a query on database
--- @param query string Query to execute
--- @param params table Parameters to execute
--- @return any Returns results from database
function corev.db:execute(query, params)
    query = corev:ensure(query, 'unknown')
    params = corev:ensure(params, {})

    if (query == 'unknown') then return nil end

    local res, finished = nil, false

    self:executeAsync(query, params, function(result)
        res = result
        finished = true
    end)

    repeat Wait(0) until finished == true

    return res
end

--- This function returns `true` if resource and migration exists in database
--- @param resourceName string Name of resource
--- @param sqlVersion number SQL version number
--- @return boolean `true` if exsits, otherwise `false`
function corev.db:migrationExists(resourceName, sqlVersion)
    resourceName = corev:ensure(resourceName, 'unknown')
    sqlVersion = corev:ensure(sqlVersion, 0)

    if (resourceName == 'unknown') then return false end

    local res, finished = nil, false

    __exports[7].func(__exports[7].self, 'SELECT `id` FROM `migrations` WHERE `resource` = @resource AND `name` = @name LIMIT 1', {
        ['@resource'] = resourceName,
        ['@name'] = ('%s.lua'):format(sqlVersion)
    }, function(foundedResults)
        foundedResults = corev:ensure(foundedResults, {})

        res = #foundedResults > 0
        finished = true
    end)

    repeat Wait(0) until finished == true

    return res
end

--- Apply migrations
function corev.db:migrationDependent()
    self.hasMigrations = true

    --- Execute this function when database is ready
    self:dbReady(function()
        local sql_index, migrations, finished = 0, nil, false

        __exports[7].func(__exports[7].self, 'SELECT * FROM `migrations` WHERE `resource` = @resource', {
            ['@resource'] = currentResourceName
        }, function(result)
            migrations = corev:ensure(result, {})
            finished = true
        end)

        repeat Wait(0) until finished == true

        while (self.hasMigrations) do
            local lua_file = ('%s.lua'):format(sql_index)
            local lua_exists = false

            for _, migration in pairs(migrations) do
                local db_name = corev:ensure(migration.name, 'unknown')

                if (db_name == lua_file) then
                    lua_exists = true
                end
            end

            local rawLuaMigration = LoadResourceFile(currentResourceName, ('migrations/%s'):format(lua_file))

            if (rawLuaMigration) then
                if (not lua_exists) then
                    local migrationFinished = false

                    local migrationFunc, _ = load(rawLuaMigration, ('@%s/migration/%s'):format(currentResourceName, lua_file))

                    if (migrationFunc) then
                        local migrationLoaded, migrationData = xpcall(migrationFunc, traceback)

                        if (migrationLoaded) then
                            local migrationDependencies = corev:ensure(migrationData.dependencies, {})

                            for dependencyResource, sqlVersion in pairs(migrationDependencies) do
                                dependencyResource = corev:ensure(dependencyResource, 'unknown')
                                sqlVersion = corev:ensure(sqlVersion, 0)

                                if (dependencyResource == 'unknown') then
                                    print(corev:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                                    return
                                end

                                while GetResourceState(dependencyResource) ~= 'started' do Wait(0) end
                                while not self:migrationExists(dependencyResource, sqlVersion) do Wait(500) end
                            end

                            local migrationSql = corev:ensure(migrationData.sql, 'unknown')

                            if (migrationSql == 'unknown') then
                                print(corev:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                                return
                            end

                            __exports[8].func(__exports[8].self, migrationSql, {}, function()
                                __exports[7].func(__exports[7].self, 'INSERT INTO `migrations` (`resource`, `name`) VALUES (@resource, @name)', {
                                    ['@resource'] = currentResourceName,
                                    ['@name'] = lua_file
                                }, function()
                                    migrationFinished = true
                                end)
                            end)
                        else
                            print(corev:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                        end
                    else
                        print(corev:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                    end

                    repeat Wait(0) until migrationFinished == true
                end
            else
                self.hasMigrations = false
            end

            sql_index = sql_index + 1

            Wait(0)
        end

        print(corev:t('core', 'database_migration'):format(currentResourceName))
    end)
end

--- This function returns if a table exists or not
--- @param tableName string Name of table
--- @return boolean `true` if table exists, otherwise `false`
function corev.db:tableExists(tableName)
    tableName = corev:ensure(tableName, 'unknown')

    if (tableName == 'unknown') then
        return false
    end

    local result = self:fetchScalar('SHOW TABLES LIKE @tableName', {
        ['@tableName'] = tableName
    })

    result = lower(corev:ensure(result, 'unknown'))

    return lower(tableName) == result
end

--- Trigger func by server
--- @param name string Name of trigger
--- @param callback function Trigger this function
function corev:onServerTrigger(name, callback)
    name = self:ensure(name, 'unknown')
    callback = self:ensure(callback, function() end)

    if (name == 'unknown') then return end

    _AEH(name, callback)
end

--- Trigger func by client
--- @param name string Name of trigger
--- @param callback function Trigger this function
function corev:onClientTrigger(name, callback)
    name = self:ensure(name, 'unknown')
    callback = self:ensure(callback, function() end)

    if (name == 'unknown') then return end

    _RSE(name)
    _AEH(name, callback)
end

--- Register server callback
--- @param name string Name of callback
--- @param callback function Trigger this function on server return
function corev.callback:register(name, callback)
    name = corev:ensure(name, 'unknown')
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown') then return end

    corev.callback.callbacks[name] = callback
end

--- Trigger callback when callback exists
--- @param name string Name of callback
--- @param source number Player Source ID
--- @param callback function Trigger this function on callback trigger
function corev.callback:triggerCallback(name, source, callback, ...)
    name = corev:ensure(name, 'unknown')
    source = corev:ensure(source, -1)
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown' or source == -1) then return end

    if ((self.callbacks or {})[name] ~= nil) then
        self.callbacks[name](source, callback, ...)
    end
end

--- This function will return player's primary identifier or nil
--- @param playerId number Source or Player ID to get identifier for
--- @return string|nil Founded primary identifier or nil
function corev:getIdentifier(playerId)
    playerId = self:ensure(playerId, -1)

    if (playerId < 0) then return nil end
    if (playerId == 0) then return 'console' end

    local identifierType = self:cfg('core', 'identifierType') or 'license'
    local identifiers = GetPlayerIdentifiers(playerId)

    identifierType = self:ensure(identifierType, 'license')
    identifierType = lower(identifierType)
    identifiers = self:ensure(identifiers, {})

    for _, identifier in pairs(identifiers) do
        identifier = self:ensure(identifier, 'none')

        local lowIdenti = lower(identifier)

        if (identifierType == 'steam' and match(lowIdenti, 'steam:')) then
            return sub(identifier, 7)
        elseif (identifierType == 'license' and match(lowIdenti, 'license:')) then
            return sub(identifier, 9)
        elseif (identifierType == 'xbl' and match(lowIdenti, 'xbl:')) then
            return sub(identifier, 5)
        elseif (identifierType == 'live' and match(lowIdenti, 'live:')) then
            return sub(identifier, 6)
        elseif (identifierType == 'discord' and match(lowIdenti, 'discord:')) then
            return sub(identifier, 9)
        elseif (identifierType == 'fivem' and match(lowIdenti, 'fivem:')) then
            return sub(identifier, 7)
        elseif (identifierType == 'ip' and match(lowIdenti, 'ip:')) then
            return sub(identifier, 4)
        end
    end

    return nil
end

--- Returns `job` bases on given `name`
--- @param name string Name of job
--- @return job|nil Returns a `job` class or nil
function corev.jobs:getJob(name)
    name = corev:ensure(name, 'unknown')

    if (name == 'unknown') then
        return nil
    end

    name = lower(name)

    if (__exports[10].self == nil) then
        return __exports[10].func(name)
    else
        return __exports[10].func(__exports[10].self, name)
    end
end

--- Creates a job object based on given `name` and `grades`
--- @param name string Name of job, example: unemployed, police etc. (lowercase)
--- @param label string Label of job, this will be displayed as name of given job
--- @param grades table List of grades as table, every grade needs to be a table as well
--- @return job|nil Returns a `job` class if found or created, otherwise `nil`
function corev.jobs:addJob(name, label, grades)
    name = corev:ensure(name, 'unknown')
    label = corev:ensure(label, 'Unknown')
    grades = corev:ensure(grades, {})

    if (name == 'unknown') then
        return nil
    end

    name = lower(name)

    if (__exports[9].self == nil) then
        return __exports[9].func(name, label, grades)
    else
        return __exports[9].func(__exports[9].self, name, label, grades)
    end
end

--- Register a new on event
--- @param event string Name of event
function corev.events:register(event, ...)
    event = corev:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    if (__exports[11].self == nil) then
        return __exports[11].func(event, ...)
    else
        return __exports[11].func(__exports[11].self, event, ...)
    end
end

--- Unregister events based on event and/or names
--- @param event string Name of event
function corev.events:unregister(event, ...)
    event = corev:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    if (__exports[12].self == nil) then
        return __exports[12].func(event, ...)
    else
        return __exports[12].func(__exports[12].self, event, ...)
    end
end

--- Register a function as `playerConnecting`
--- @param func function Execute this function when player is connecting
function corev.events:onPlayerConnect(func)
    func = corev:ensure(func, function(_, done) done() end)

    self:register('playerConnecting', func)
end

--- Register a function as `playerDropped`
--- @param func function Execute this function when player is disconnected
function corev.events:onPlayerDisconnect(func)
    func = corev:ensure(func, function(_, done) done() end)

    self:register('playerDropped', func)
end

--- Returns stored resource name or call `GetCurrentResourceName`
--- @return string Returns name of current resource
function corev:getCurrentResourceName()
    if (self:typeof(currentResourceName) == 'string') then
        return currentResourceName
    end

    return GetCurrentResourceName()
end

--- Trigger event when client is requesting callback
corev:onClientTrigger(('corev:%s:serverCallback'):format(currentResourceName), function(name, requestId, ...)
    name = corev:ensure(name, 'unknown')
    requestId = corev:ensure(requestId, 0)

    local playerId = corev:ensure(source, -1)

    if (playerId == -1) then return end
    if (name == 'unknown') then return end
    if (requestId <= 0 or requestId > 65535) then return end
    if (((corev.callback or {}).callbacks or {})[name] == nil) then return end

    local params = pack(...)

    CreateThread(function()
        corev.callback:triggerCallback(name, playerId, function(...)
            _TCE(('corev:%s:serverCallback'):format(currentResourceName), playerId, requestId, ...)
        end, unpack(params))
    end)
end)

--- Prevent users from joining the server while database is updating
corev.events:onPlayerConnect(function(_, done, presentCard)
    presentCard.setTitle(corev:t('core', 'checking_server'), false)
    presentCard.setDescription(corev:t('core', 'check_for_database_updates'))

    if (corev.db.hasMigrations) then
        done(corev:t('core', 'database_is_updating'):format(currentResourceName))
        return
    end

    done()
end)

--- Register corev as global variable
global.corev = corev