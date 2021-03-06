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
local string = assert(string)
local rawget = assert(rawget)
local rawset = assert(rawset)
local tonumber = assert(tonumber)
local tostring = assert(tostring)
local encode = assert(json.encode)
local lower = assert(string.lower)
local sub = assert(string.sub)
local len = assert(string.len)
local gmatch = assert(string.gmatch)
local char = assert(string.char)
local byte = assert(string.byte)
local insert = assert(table.insert)
local modf = assert(math.modf)
local randomseed = assert(math.randomseed)
local random = assert(math.random)
local floor = assert(math.floor)
local clock = assert(os.clock)
local time = assert(os.time)
local date = assert(os.date)
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
local pack = assert(table.pack)
local unpack = assert(table.unpack)
local CreateThread = assert(Citizen.CreateThread)
local Wait = assert(Citizen.Wait)

--- FiveM cached global variables
local LoadResourceFile = assert(LoadResourceFile)
local GetResourceState = assert(GetResourceState)
local _TCE = assert(TriggerClientEvent)
local _RSE = assert(RegisterServerEvent)
local _AEH = assert(AddEventHandler)
local IsDuplicityVersion = assert(IsDuplicityVersion)
local GetCurrentResourceName = assert(GetCurrentResourceName)
local GetGameTimer = assert(GetGameTimer)

--- Required resource variables
local isServer = IsDuplicityVersion()
local currentResourceName = GetCurrentResourceName()
local INT32_MAX, INT64_MAX = 2147483648, 4294967296

--- Cahce FiveM globals
local exports = assert(exports)
local __exports = assert({})

--- Prevent this file from executing from wrong side
if (not isServer) then
    error('You are trying to load a server file which is only allowed on the server side')
    return
end

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
    [1] = { r = 'cvf_config', f = '__c', s = false },
    [2] = { r = 'cvf_translations', f = '__t', s = false },
    [3] = { r = 'mysql-async', f = 'is_ready', s = false },
    [4] = { r = 'mysql-async', f = 'mysql_insert', s = false },
    [5] = { r = 'mysql-async', f = 'mysql_fetch_scalar', s = false },
    [6] = { r = 'mysql-async', f = 'mysql_fetch_all', s = false },
    [7] = { r = 'mysql-async', f = 'mysql_execute', s = false },
    [8] = { r = 'cvf_jobs', f = '__a', s = false },
    [9] = { r = 'cvf_jobs', f = '__l', s = false },
    [10] = { r = 'cvf_events', f = '__add', s = false },
    [11] = { r = 'cvf_events', f = '__del', s = false },
    [12] = { r = 'cvf_identifier', f = '__g', s = false },
    [13] = { r = 'cvf_player', f = '__g', s = false },
    [14] = { r = 'cvf_commands', f = '__rc', s = false },
    [15] = { r = 'cvf_commands', f = '__rp', s = false }
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

_AEH('onResourceStart', function(resourceName)
    for index, _le in pairs(__loadExports) do
        if (resourceName == _le.r) then
            if (_le.s) then
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

                __loadExports[index].s = false
            end

            return
        end
    end
end)

_AEH('onResourceStop', function(resourceName)
    for index, _le in pairs(__loadExports) do
        if (resourceName == _le.r) then
            __loadExports[index].s = true
            __exports[index].self = nil
            __exports[index].func = function() error(('Resource %s has been stopped'):format(resourceName)) end
        end
    end
end)

--- Create CoreV class
---@class corev_server
local corev_server = setmetatable({ __class = 'corev_server' }, {})

---@class corev_server_db
corev_server.db = setmetatable({ __class = 'corev_server_db' }, {})
---@class corev_server_callback
corev_server.callback = setmetatable({ __class = 'corev_server_callback' }, {})
---@class corev_server_jobs
corev_server.jobs = setmetatable({ __class = 'corev_server_jobs' }, {})
---@class corev_server_events
corev_server.events = setmetatable({ __class = 'corev_server_events' }, {})
---@class corev_server_classes
corev_server.classes = setmetatable({ __class = 'corev_server_classes' }, {})

--- Set default values for `corev-db` class
corev_server.db.ready = false
corev_server.db.hasMigrations = false

--- Set default values for `corev-callback` class
corev_server.callback.callbacks = {}

--- Tries to execute `func`, if any error occur, `catch_func` will be triggerd
---@param func function Function to execute
---@param catch_func function Fallback function when error occur
function corev_server:try(func, catch_func)
    return try(func, catch_func)
end

--- Return a value type of any CFX object
---@param value any Any value
---@return string Type of value
function corev_server:typeof(value)
    if (value == nil) then return 'nil' end

    local rawType = type(value) or 'nil'

    if (rawType ~= 'table') then return rawType end

    local isFunction = rawget(value, '__cfx_functionReference') ~= nil or
        rawget(value, '__cfx_async_retval') ~= nil

    if (isFunction) then return 'function' end

    local isSource = rawget(value, '__cfx_functionSource') ~= nil

    if (isSource) then return 'number' end
    if (value.__class) then return value.__class end
    if (value.__type) then return value.__type end

    return rawType
end

--- Convert value to number
---@param value any Any value
---@return number A integer
function corev_server:toInt(value)
    local rawType = self:typeof(value)

    if (rawType == 'nil') then return 0 end
    if (rawType == 'number') then return value or 0 end

    return tonumber(value) or 0
end

--- Convert value to int32
---@param value any Any value to int32
---@return number Int32 value
function corev_server:maxInt32(value)
    local input = self:toInt(value)

    if (input >= INT32_MAX) then
        return input & (INT64_MAX - 1)
    end

    return input
end

--- Makes sure your input matches your type of defaultValue
---@param input any Any type of value you want to match with defaultValue
---@param defaultValue any Any default value when input don't match with defaultValue's type
---@return any DefaultValue or translated/transformed input
function corev_server:ensure(input, defaultValue)
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

        return tostring(input) or defaultValue
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
---@param name string Name of configuration to load
---@params ... string[] Filer results by key
---@return any|nil Returns `any` data from cached configuration or `nil` if not found
function corev_server:cfg(name, ...)
    name = self:ensure(name, 'unknown')

    if (name == 'unknown') then return {} end

    if (__exports[1].self == nil) then
        return __exports[1].func(name, ...)
    else
        return __exports[1].func(__exports[1].self, name, ...)
    end
end

--- Returns translation key founded or 'MISSING TRANSLATION'
---@params language string? (optional) Needs to be a two letter identifier, example: EN, DE, NL, BE, FR etc.
---@params module string? (optional) Register translation for a module, example: core
---@params key string Key of translation
---@return string Translation or 'MISSING TRANSLATION'
function corev_server:t(...)
    if (__exports[2].self == nil) then
        return __exports[2].func(...)
    else
        return __exports[2].func(__exports[2].self, ...) 
    end
end

--- Checks if a string ends with given word
---@param str string String to search in
---@param word string Word to search for
---@return boolean `true` if word has been found, otherwise `false`
function corev_server:endswith(str, word)
    str = self:ensure(str, '')
    word = self:ensure(word, '')

    return sub(str, -#word) == word
end

--- Replace a string that contains `this` to `that`
---@param str string String where to replace in
---@param this string Word that's need to be replaced
---@param that string Replace `this` whit given string
---@return string String where `this` has been replaced with `that`
function corev_server:replace(str, this, that)
    local b, e = str:find(this, 1, true)

    if b == nil then
        return str
    else
        return str:sub(1, b - 1) .. that .. self:replace(str:sub(e + 1), this, that)
    end
end

--- Split a string by given delim
---@param str string String that's need to be split
---@param delim string Split string by every given delim
---@return string[] List of strings, splitted at given delim
function corev_server:split(str, delim)
    local t = {}

    for substr in gmatch(self:ensure(str, ''), "[^".. delim .. "]*") do
        if substr ~= nil and len(substr) > 0 then
            insert(t, substr)
        end
    end

    return t
end

--- Trigger callback when database is ready
---@param callback function Callback function to execute
function corev_server.db:dbReady(callback)
    callback = corev_server:ensure(callback, function() end)

    CreateThread(function()
        while GetResourceState('mysql-async') ~= 'started' do Wait(0) end
        while not __exports[3].func(__exports[3].self) do Wait(0) end

        callback()
    end)
end

--- Update ready state when database is ready
corev_server.db:dbReady(function()
    corev_server.db.ready = true
end)

--- Escape database params
---@param params table Parameters to escape
---@return table Safe parameters
function corev_server.db:safeParameters(params)
    params = corev_server:ensure(params, {})

    if (next(params) == nil) then
        return {[''] = ''}
    end

    return params
end

--- Execute async insert
---@param query string Query to execute
---@param params table Parameters to execute
---@param callback function Callback function to execute
function corev_server.db:insertAsync(query, params, callback)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})
    callback = corev_server:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev_server.db:dbReady(function()
            __exports[4].func(__exports[4].self, query, params, callback)
        end)
    else
        __exports[4].func(__exports[4].self, query, params, callback)
    end
end

--- Returns first column of first row
---@param query string Query to execute
---@param params table Parameters to execute
---@param callback function Callback function to execute
function corev_server.db:fetchScalarAsync(query, params, callback)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})
    callback = corev_server:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev_server.db:dbReady(function()
            __exports[5].func(__exports[5].self, query, params, callback)
        end)
    else
        __exports[5].func(__exports[5].self, query, params, callback)
    end
end

--- Fetch all results from database query
---@param query string Query to execute
---@param params table Parameters to execute
---@param callback function Callback function to execute
function corev_server.db:fetchAllAsync(query, params, callback)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})
    callback = corev_server:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev_server.db:dbReady(function()
            __exports[6].func(__exports[6].self, query, params, callback)
        end)
    else
        __exports[6].func(__exports[6].self, query, params, callback)
    end
end

--- Execute a query on database
---@param query string Query to execute
---@param params table Parameters to execute
---@param callback function Callback function to execute
function corev_server.db:executeAsync(query, params, callback)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})
    callback = corev_server:ensure(callback, function() end)

    if (query == 'unknown') then return end

    params = self:safeParameters(params)

    if (self.hasMigrations) then
        repeat Wait(0) until self.hasMigrations == false
    end

    if (not self.ready) then
        corev_server.db:dbReady(function()
            __exports[7].func(__exports[7].self, query, params, callback)
        end)
    else
        __exports[7].func(__exports[7].self, query, params, callback)
    end
end

--- Execute async insert
---@param query string Query to execute
---@param params table Parameters to execute
---@return any Returns results from database
function corev_server.db:insert(query, params)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})

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
---@param query string Query to execute
---@param params table Parameters to execute
---@return any Returns results from database
function corev_server.db:fetchScalar(query, params)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})

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
---@param query string Query to execute
---@param params table Parameters to execute
---@return any Returns results from database
function corev_server.db:fetchAll(query, params)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})

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
---@param query string Query to execute
---@param params table Parameters to execute
---@return any Returns results from database
function corev_server.db:execute(query, params)
    query = corev_server:ensure(query, 'unknown')
    params = corev_server:ensure(params, {})

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
---@param resourceName string Name of resource
---@param sqlVersion number SQL version number
---@return boolean `true` if exsits, otherwise `false`
function corev_server.db:migrationExists(resourceName, sqlVersion)
    resourceName = corev_server:ensure(resourceName, 'unknown')
    sqlVersion = corev_server:ensure(sqlVersion, 0)

    if (resourceName == 'unknown') then return false end

    local res, finished = nil, false

    __exports[6].func(__exports[6].self, 'SELECT `id` FROM `migrations` WHERE `resource` = @resource AND `name` = @name LIMIT 1', {
        ['@resource'] = resourceName,
        ['@name'] = ('%s.lua'):format(sqlVersion)
    }, function(foundedResults)
        foundedResults = corev_server:ensure(foundedResults, {})

        res = #foundedResults > 0
        finished = true
    end)

    repeat Wait(0) until finished == true

    return res
end

--- Apply migrations
function corev_server.db:migrationDependent()
    self.hasMigrations = true

    --- Execute this function when database is ready
    self:dbReady(function()
        local sql_index, migrations, finished = 0, nil, false

        __exports[6].func(__exports[6].self, 'SELECT * FROM `migrations` WHERE `resource` = @resource', {
            ['@resource'] = currentResourceName
        }, function(result)
            migrations = corev_server:ensure(result, {})
            finished = true
        end)

        repeat Wait(0) until finished == true

        while (self.hasMigrations) do
            local lua_file = ('%s.lua'):format(sql_index)
            local lua_exists = false

            for _, migration in pairs(migrations) do
                local db_name = corev_server:ensure(migration.name, 'unknown')

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
                            local migrationDependencies = corev_server:ensure(migrationData.dependencies, {})

                            for dependencyResource, sqlVersion in pairs(migrationDependencies) do
                                dependencyResource = corev_server:ensure(dependencyResource, 'unknown')
                                sqlVersion = corev_server:ensure(sqlVersion, 0)

                                if (dependencyResource == 'unknown') then
                                    print(corev_server:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                                    return
                                end

                                while GetResourceState(dependencyResource) ~= 'started' do Wait(0) end
                                while not self:migrationExists(dependencyResource, sqlVersion) do Wait(500) end
                            end

                            local migrationSql = corev_server:ensure(migrationData.sql, 'unknown')

                            if (migrationSql == 'unknown') then
                                print(corev_server:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                                return
                            end

                            __exports[7].func(__exports[7].self, migrationSql, {}, function()
                                __exports[6].func(__exports[6].self, 'INSERT INTO `migrations` (`resource`, `name`) VALUES (@resource, @name)', {
                                    ['@resource'] = currentResourceName,
                                    ['@name'] = lua_file
                                }, function()
                                    migrationFinished = true
                                end)
                            end)
                        else
                            print(corev_server:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                        end
                    else
                        print(corev_server:t('core', 'database_migration_not_loaded'):format(currentResourceName))
                    end

                    repeat Wait(0) until migrationFinished == true
                end
            else
                self.hasMigrations = false
            end

            sql_index = sql_index + 1

            Wait(0)
        end

        print(corev_server:t('core', 'database_migration'):format(currentResourceName))
    end)
end

--- This function returns if a table exists or not
---@param tableName string Name of table
---@return boolean `true` if table exists, otherwise `false`
function corev_server.db:tableExists(tableName)
    tableName = corev_server:ensure(tableName, 'unknown')

    if (tableName == 'unknown') then
        return false
    end

    local result = self:fetchScalar('SHOW TABLES LIKE @tableName', {
        ['@tableName'] = tableName
    })

    result = lower(corev_server:ensure(result, 'unknown'))

    return lower(tableName) == result
end

--- Trigger func by server
---@param name string Name of trigger
---@param callback function Trigger this function
function corev_server:onServerTrigger(name, callback)
    name = self:ensure(name, 'unknown')
    callback = self:ensure(callback, function() end)

    if (name == 'unknown') then return end

    _AEH(name, callback)
end

--- Trigger func by client
---@param name string Name of trigger
---@param callback function Trigger this function
function corev_server:onClientTrigger(name, callback)
    name = self:ensure(name, 'unknown')
    callback = self:ensure(callback, function() end)

    if (name == 'unknown') then return end

    _RSE(name)
    _AEH(name, callback)
end

--- Register server callback
---@param name string Name of callback
---@param callback function Trigger this function on server return
function corev_server.callback:register(name, callback)
    name = corev_server:ensure(name, 'unknown')
    callback = corev_server:ensure(callback, function() end)

    if (name == 'unknown') then return end

    corev_server.callback.callbacks[name] = callback
end

--- Trigger callback when callback exists
---@param name string Name of callback
---@param source number Player Source ID
---@param callback function Trigger this function on callback trigger
function corev_server.callback:triggerCallback(name, source, callback, ...)
    name = corev_server:ensure(name, 'unknown')
    source = corev_server:ensure(source, -1)
    callback = corev_server:ensure(callback, function() end)

    if (name == 'unknown' or source == -1) then return end

    if ((self.callbacks or {})[name] ~= nil) then
        local vPlayer = corev_server:getPlayer(source)

        self.callbacks[name](vPlayer, callback, ...)
    end
end

--- Returns `job` bases on given `name`
---@param input string|number Name of job or ID of job
---@return job|nil Returns a `job` class or nil
function corev_server.jobs:getJob(input)
    if (__exports[9].self == nil) then
        return __exports[9].func(input)
    else
        return __exports[9].func(__exports[9].self, input)
    end
end

--- Creates a job object based on given `name` and `grades`
---@param name string Name of job, example: unemployed, police etc. (lowercase)
---@param label string Label of job, this will be displayed as name of given job
---@param grades table List of grades as table, every grade needs to be a table as well
---@return job|nil Returns a `job` class if found or created, otherwise `nil`
function corev_server.jobs:addJob(name, label, grades)
    name = corev_server:ensure(name, 'unknown')
    label = corev_server:ensure(label, 'Unknown')
    grades = corev_server:ensure(grades, {})

    if (name == 'unknown') then
        return nil
    end

    name = lower(name)

    if (__exports[8].self == nil) then
        return __exports[8].func(name, label, grades)
    else
        return __exports[8].func(__exports[8].self, name, label, grades)
    end
end

--- Register a new on event
---@param event string Name of event
function corev_server.events:register(event, ...)
    event = corev_server:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    if (__exports[10].self == nil) then
        return __exports[10].func(event, ...)
    else
        return __exports[10].func(__exports[10].self, event, ...)
    end
end

--- Unregister events based on event and/or names
---@param event string Name of event
function corev_server.events:unregister(event, ...)
    event = corev_server:ensure(event, 'unknown')

    if (event == 'unknown') then return end

    if (__exports[11].self == nil) then
        return __exports[11].func(event, ...)
    else
        return __exports[11].func(__exports[11].self, event, ...)
    end
end

--- Register a function as `playerConnecting`
---@param func function Execute this function when player is connecting
function corev_server.events:onPlayerConnect(func)
    func = corev_server:ensure(func, function(_, done) done() end)

    self:register('playerConnecting', func)
end

--- Register a function as `playerDropped`
---@param func function Execute this function when player is disconnected
function corev_server.events:onPlayerDisconnect(func)
    func = corev_server:ensure(func, function(_, done) done() end)

    self:register('playerDropped', func)
end

--- Returns stored resource name or call `GetCurrentResourceName`
---@return string Returns name of current resource
function corev_server:getCurrentResourceName()
    if (self:typeof(currentResourceName) == 'string') then
        return currentResourceName
    end

    return GetCurrentResourceName()
end

--- Returns a `player` class with the latest identifiers
---@param input string|number Any identifier or Player source
---@return player|nil Returns a `player` class if found, otherwise nil
function corev_server:getPlayerIdentifiers(input)
    input = corev_server:typeof(input) == 'number' and input or corev_server:ensure(input, 'unknown')

    if (self:typeof(input) == 'string' and input == 'unknown') then return nil end

    if (__exports[12].self == nil) then
        return __exports[12].func(input)
    else
        return __exports[12].func(__exports[12].self, input)
    end
end

--- Returns a `vPlayer` class based on given input
---@param input string|number Player identifier or Player source
---@return vPlayer|nil Founded/Generated `vPlayer` class or nil
function corev_server:getPlayer(input)
    input = corev_server:typeof(input) == 'number' and input or corev_server:ensure(input, 'unknown')

    if (self:typeof(input) == 'string' and input == 'unknown') then return nil end

    if (__exports[13].self == nil) then
        return __exports[13].func(input)
    else
        return __exports[13].func(__exports[13].self, input)
    end
end

--- Register a command
---@param name string|table Name of command to execute
---@param groups string|table Group(s) allowed to execute this command
---@param callback function Execute this function when player is allowed
function corev_server:registerCommand(name, groups, callback)
    name = self:ensure(name, 'unknown')
    groups = self:typeof(groups) == 'table' and groups or corev_server:ensure(groups, 'superadmin')
    callback = self:ensure(callback, function() end)

    if (__exports[14].self == nil) then
        return __exports[14].func(name, groups, callback)
    else
        return __exports[14].func(__exports[14].self, name, groups, callback)
    end
end

--- Create a parser for generated command
---@param name string Name of command
---@param parseInfo table Information about parser
function corev_server:registerParser(name, parseInfo)
    name = self:ensure(name, 'unknown')
    parseInfo = self:ensure(parseInfo, {})

    if (__exports[15].self == nil) then
        return __exports[15].func(name, parseInfo)
    else
        return __exports[15].func(__exports[15].self, name, parseInfo)
    end
end

--- Own implementation of GetHashKey
--- https://gist.github.com/ThymonA/5266760e0fe302feceb19094b6bff458
---@param name string Key to transform to hash
---@return number Generated hash
function corev_server:hashString(name)
    name = corev_server:ensure(name, 'unknown')

    local length = len(name)
    local hash = 0

    for i = 1, length, 1 do
        local c = byte(name, i, i)

        hash = hash + (c >= 65 and c <= 90 and (c + 32) or c)
        hash = hash + (hash << 10)
        hash = self:maxInt32(hash)
        hash = hash ~ (hash >> 6)
    end

    hash = hash + (hash << 3)
    hash = self:maxInt32(hash)
    hash = hash ~ (hash >> 11)
    hash = hash + (hash << 15)
    hash = self:maxInt32(hash)

    return floor(((hash + INT32_MAX) % INT64_MAX - INT32_MAX))
end

--- Returns current time in milliseconds
---@return number Time in milliseconds
function corev_server:getTimeInMilliseconds()
    local currentMilliseconds
    local _, b = modf(clock())

    if (b == 0) then
        currentMilliseconds = 0
    else
        currentMilliseconds = tonumber(tostring(b):sub(3,5))
    end

    local currentLocalTime = time(date('*t'))

    currentLocalTime = currentLocalTime * 1000
    currentLocalTime = currentLocalTime + currentMilliseconds

    return currentLocalTime
end

function corev_server:getCurrentTime()
    local _, b = modf(clock())

    if (b == 0) then
        b = '000'
    else
        b = tostring(b):sub(3,5)
    end

    return date('%Y-%m-%d %H:%M:%S.', time()) .. b
end

--- Will generate a random string based on given length
---@param length number Length the random string must be
---@param recurse boolean When `false`, GetGameTimer() will called as seed, otherwise keep current seed
---@return string Generated random string matching your length
function corev_server:getRandomString(length, recurse)
    length = self:ensure(length, 16)
    recurse = self:ensure(recurse, false)

    if (not recurse) then
        randomseed(GetGameTimer())
    end

    if (length <= 0) then return string.empty end

    local number = random(48, 122)

    if (number > 57 and number < 65) then
        return self:getRandomString(length, true)
    elseif (number > 90 and number < 97) then
        return self:getRandomString(length, true)
    else
        return self:getRandomString(length - 1, true) .. char(number)
    end
end

--- This function will return player's primary identifier or nil
---@param input string|number Any identifier or Player source
---@return string|nil Founded primary identifier or nil
function corev_server:getPrimaryIdentifier(input)
    local player = self:getPlayerIdentifiers(input)

    if (player == nil) then return nil end

    return player.identifier
end

--- Create a `player` class object
---@param source number|nil Player Source
---@param name string Name of player
---@param identifiers table List of identifiers
---@param identifier string Primary Identifier
---@return player New `player` class
function corev_server.classes:createPlayerClass(source, name, identifiers, identifier)
    --- Create a `player` class
    ---@class player
    local player = setmetatable({ __class = 'player' }, {})

    player.source = source
    player.name = name
    player.identifiers = identifiers
    player.identifier = identifier

    return player
end

--- Trigger event when client is requesting callback
corev_server:onClientTrigger(('corev:%s:serverCallback'):format(currentResourceName), function(name, requestId, ...)
    name = corev_server:ensure(name, 'unknown')
    requestId = corev_server:ensure(requestId, 0)

    local playerId = corev_server:ensure(source, -1)

    if (playerId == -1) then return end
    if (name == 'unknown') then return end
    if (requestId <= 0 or requestId > 65535) then return end
    if (((corev_server.callback or {}).callbacks or {})[name] == nil) then return end

    local params = pack(...)

    CreateThread(function()
        corev_server.callback:triggerCallback(name, playerId, function(...)
            _TCE(('corev:%s:serverCallback'):format(currentResourceName), playerId, requestId, ...)
        end, unpack(params))
    end)
end)

--- Prevent users from joining the server while database is updating
corev_server.events:onPlayerConnect(function(_, done, presentCard)
    presentCard:setTitle(corev_server:t('core', 'checking_server'), false)
    presentCard:setDescription(corev_server:t('core', 'check_for_database_updates'))

    if (corev_server.db.hasMigrations) then
        done(corev_server:t('core', 'database_is_updating'):format(currentResourceName))
        return
    end

    done()
end)

--- Register corev as global variable
_G.corev_server = corev_server

----------------------------
--- Modify global variables
----------------------------
_G.string = string

--- Checks if a string starts with given word
---@param self string String to search in
---@param word string Word to search for
---@return boolean `true` if word has been found, otherwise `false`
_G.string.startsWith = function(self, word)
    word = corev_server:ensure(word, 'unknown')

    return self:sub(1, #word) == word
end

--- Represent a empty string
_G.string.empty = ''