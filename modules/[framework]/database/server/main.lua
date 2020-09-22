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
local database = class('database')

--- Set default values
database:set {
    isReady = false,
    migrations = {}
}

--- Make sure params are safe
--- @param params array Parameters
function database:safeParameters(params)
    if (params == nil) then
        return {[''] = ''}
    end

    assert(type(params) == 'table', _(CR(), 'database', 'error_params_type'))

    if (next(params) == nil) then
        return {[''] = ''}
    end

    return params
end

--- Execute query to database
--- @param query string Query
--- @param params array Parameters
function database:execute(query, params)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    local result, finished = 0, false

    exports['mysql-async']:mysql_execute(query, self:safeParameters(params), function(results)
        result = results
        finished = true
    end)

    repeat Citizen.Wait(0) until finished == true

    return result
end

--- Fetch all results from database
--- @param query string Query
--- @param params array Parameters
function database:fetchAll(query, params)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    local result, finished = 0, false

    exports['mysql-async']:mysql_fetch_all(query, self:safeParameters(params), function(results)
        result = results
        finished = true
    end)

    repeat Citizen.Wait(0) until finished == true

    return result
end

--- Fetch the first column of the first row
--- @param query string Query
--- @param params array Parameters
function database:fetchScalar(query, params)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    local result, finished = 0, false

    exports['mysql-async']:mysql_fetch_scalar(query, self:safeParameters(params), function(results)
        result = results
        finished = true
    end)

    repeat Citizen.Wait(0) until finished == true

    return result
end


--- Execute a query and retrieve the last id insert
--- @param query string Query
--- @param params array Parameters
function database:insert(query, params)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    local result, finished = 0, false

    exports['mysql-async']:mysql_insert(query, self:safeParameters(params), function(results)
        result = results
        finished = true
    end)

    repeat Citizen.Wait(0) until finished == true

    return result
end

--- Stores a query for later execution
--- @param query string Query
--- @param params array Parameters
function database:store(query)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    local result, finished = 0, false

    exports['mysql-async']:mysql_store(query, function(results)
        result = results
        finished = true
    end)

    repeat Citizen.Wait(0) until finished == true

    return result
end

--- Execute a List of querys
--- @param query string Query
--- @param params array Parameters
function database:transaction(querys, params)
    assert(type(params) == 'table', _(CR(), 'database', 'error_queries_type'))

    for _, query in pairs(querys or {}) do
        assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))
    end

    local result, finished = 0, false

    exports['mysql-async']:mysql_transaction(querys, self:safeParameters(params), function(results)
        result = results
        finished = true
    end)

    repeat Citizen.Wait(0) until finished == true

    return result
end

--- Execute query to database async
--- @param query string Query
--- @param params array Parameters
--- @param func function Callback function
function database:executeAsync(query, params, func)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    exports['mysql-async']:mysql_execute(query, self:safeParameters(params), func)
end

--- Fetch all results from database
--- @param query string Query
--- @param params array Parameters
--- @param func function Callback function
function database:fetchAllAsync(query, params, func)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    exports['mysql-async']:mysql_fetch_all(query, self:safeParameters(params), func)
end

--- Fetch the first column of the first row
--- @param query string Query
--- @param params array Parameters
--- @param func function Callback function
function database:fetchScalarAsync(query, params, func)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    exports['mysql-async']:mysql_fetch_scalar(query, self:safeParameters(params), func)
end

--- Execute a query and retrieve the last id insert
--- @param query string Query
--- @param params array Parameters
--- @param func function Callback function
function database:insertAsync(query, params, func)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    exports['mysql-async']:mysql_insert(query, self:safeParameters(params), func)
end

--- Stores a query for later execution
--- @param query string Query
--- @param params array Parameters
--- @param func function Callback function
function database:storeAsync(query, func)
    assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))

    exports['mysql-async']:mysql_store(query, func)
end

--- Stores a query for later execution
--- @param query string Query
--- @param params array Parameters
--- @param func function Callback function
function database:transactionAsync(querys, params, func)
    assert(type(params) == 'table', _(CR(), 'database', 'error_queries_type'))

    for _, query in pairs(querys or {}) do
        assert(type(query) == 'string' or type(query) == 'number', _(CR(), 'database', 'error_query_type'))
    end

    exports['mysql-async']:mysql_transaction(querys, self:safeParameters(params), func)
end

--- Trigger func when mysql-async is ready
--- @param func function Callback function
function database:ready(func)
    Citizen.CreateThread(function()
        repeat Citizen.Wait(0) until database.isReady == true

        func()
    end)
end

--- Apply migraiton to databse
--- @param resource string Resource Name
--- @param module string Module Name
--- @param name string Migration Name
function database:applyMigration(object, _migration)
    local queryDone = false

    self:ready(function()
        local content = getFrameworkFile(object.name, object.type, ('migrations/%s'):format(_migration))
        local objectType = object.type or nil

        if (objectType == nil or type(objectType) ~= 'string') then queryDone = true return end
        if (content == nil) then queryDone = true return end

        local resourceName, resourceType = 'none', nil

        if (string.lower(objectType) == 'ir') then resourceType = 'resource' end
        if (string.lower(objectType) == 'er') then resourceType = 'resource' end
        if (string.lower(objectType) == 'im') then resourceType = 'module' end
        if (string.lower(objectType) == 'em') then resourceType = 'module' end

        if (resourceType == nil) then queryDone = true return end

        if (string.lower(object.type) == string.lower(ResourceTypes.ExternalResource)) then
            resourceName = object.name
        end

        if (string.lower(object.type) == string.lower(ResourceTypes.InternalResource) or
            string.lower(object.type) == string.lower(ResourceTypes.InternalModule)) then
            resourceName = GetCurrentResourceName()
        end

        local migrations = ((database.migrations[resourceName] or {})[resourceType] or {})[object.name] or {}

        for _, migration in pairs(migrations or {}) do
            if (string.lower(migration.version) == string.lower(_migration)) then
                queryDone = true
                return
            end
        end

        database:execute(content, {})
        database:execute('INSERT INTO `migrations` (`resource`, `type`, `name`, `version`) VALUES (@resource, @type, @name, @version)', {
            ['@resource'] = resourceName,
            ['@type'] = resourceType,
            ['@name'] = object.name,
            ['@version'] = _migration
        })

        queryDone = true
    end)

    repeat Citizen.Wait(0) until queryDone == true

    return queryDone
end

--- Change ready state when database is ready
Citizen.CreateThread(function()
    while GetResourceState('mysql-async') ~= 'started' do
        Citizen.Wait(0)
    end

    while not exports['mysql-async']:is_ready() do
        Citizen.Wait(0)
    end

    local count = database:fetchScalar("SELECT COUNT(*) AS `count` FROM `information_schema`.`tables` WHERE `TABLE_SCHEMA` = @databaseName AND `TABLE_NAME` = 'migrations'", {
        ['@databaseName'] = DBNAME
    })

    if (not (count > 0)) then
        local mainSql = getModuleFile('database', 'scripts/main.sql')

        if (mainSql ~= nil) then
            database:execute(mainSql, {})
        end
    end

    local migrationInDatabase = database:fetchAll('SELECT * FROM `migrations`', {})

    for _, migration in pairs(migrationInDatabase or {}) do
        if (database.migrations[migration.resource] == nil) then
            database.migrations[migration.resource] = {}
        end

        if (database.migrations[migration.resource][migration.type] == nil) then
            database.migrations[migration.resource][migration.type] = {}
        end

        if (database.migrations[migration.resource][migration.type][migration.name] == nil) then
            database.migrations[migration.resource][migration.type][migration.name] = {}
        end

        table.insert(database.migrations[migration.resource][migration.type][migration.name], migration)
    end

    database.isReady = true
end)

--- Trigger when player is connecting
onPlayerConnecting(function(source, returnSuccess, returnError, deferrals)
    local textUpdated = false

    while not database.isReady do
        if (not textUpdated) then
            deferrals.update(_(CR(), 'database', 'database_not_started'))
        end

        Citizen.Wait(0)
    end

    returnSuccess()
end)

addModule('database', database)