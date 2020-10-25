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

--- Cache global variables
local assert = assert
local type = assert(type)
local pairs = assert(pairs)
local tostring = assert(tostring)
local xpcall = assert(xpcall)
local load = assert(load)
local traceback = assert(traceback or debug.traceback)
local pack = assert(pack or table.pack)
local lower = assert(string.lower)
local isClient = not IsDuplicityVersion()

local exports = assert(exports)
local cfv_ids_self = assert(exports['cvf_ids'])
local cfv_ids_func = assert(cfv_ids_self.__id)

local configuration = {}

--- Merge multiple tables into one table
local function merge_tables(...)
    local tables_to_merge = {...}

    if (#tables_to_merge == 0) then
        return {}
    elseif (#tables_to_merge == 1) then
        return tables_to_merge[1]
    end

    local result = tables_to_merge[1]

    if (type(result) ~= 'table') then
        result = {}
    end

    for i = 2, #tables_to_merge do
        local from = tables_to_merge[i]

        if (type(from) == 'table') then
            for k, v in pairs(from) do
                if type(v) == 'table' then
                    result[k] = result[k] or {}

                    if (type(result[k]) == 'table') then
                        result[k] = merge_tables(result[k], v)
                    end
                else
                    result[k] = v
                end
            end
        end
    end

    return result
end

--- This function results a config table or value from stored configuration variable
--- @param cacheKey number Cached key from `cfv_ids:__id`
--- @return any|nil results from stored configuration variable
local function getConfigurationFromCache(cacheKey, ...)
    local arguments = pack(...)

    if (configuration[cacheKey] ~= nil) then
        local cachedResults = configuration[cacheKey]

        for _, argument in pairs(arguments) do
            if (type(argument) == 'string') then
                cachedResults = cachedResults[argument] or nil

                if (cachedResults == nil) then
                    return nil
                elseif (type(cachedResults) ~= 'table') then
                    return cachedResults
                end
            end
        end

        return cachedResults
    end

    return nil
end

--- Load configuration by name
--- @param name string Name of configuration
--- @param cacheKey number Cached key from `cfv_ids:__id`
local function loadConfigurationVariable(name, cacheKey)
    if (configuration[cacheKey] ~= nil) then
        return
    end

    local sharedConfiguration = {}
    local sharedConfigurationPath = ('configs/shared/%s.lua'):format(name)
    local sharedConfigurationFile = LoadResourceFile(GetCurrentResourceName(), sharedConfigurationPath)
    local environmentConfiguration = {}
    local environmentConfigurationPath = isClient and ('configs/client/%s.lua'):format(name) or ('configs/server/%s.lua'):format(name)
    local environmentConfigurationFile = LoadResourceFile(GetCurrentResourceName(), environmentConfigurationPath)

    if (sharedConfigurationFile) then
        local func, _ = load(sharedConfigurationFile, ('%s/%s'):format(GetCurrentResourceName(), sharedConfigurationPath))

        if (func) then
            local ok, result = xpcall(func, traceback)

            if (ok) then
                sharedConfiguration = result or {}
            end
        end
    end

    if (environmentConfigurationFile) then
        local func, _ = load(environmentConfigurationFile, ('%s/%s'):format(GetCurrentResourceName(), environmentConfigurationPath))

        if (func) then
            local ok, result = xpcall(func, traceback)

            if (ok) then
                environmentConfiguration = result or {}
            end
        end
    end

    configuration[cacheKey] = merge_tables(sharedConfiguration, environmentConfiguration)
end

--- Load or return cached configuration based on name
--- @param name string Name of configuration to load
--- @params ... string[] Filer results by key
--- @return any|nil Returns `any` data from cached configuration or `nil` if not found
local function getConfiguration(name, ...)
    name = name or 'core'

    if (type(name) ~= 'string') then name = tostring(name) end

    name = lower(name)

    local cacheKey = cfv_ids_func(cfv_ids_self, name)

    loadConfigurationVariable(name, cacheKey)

    return getConfigurationFromCache(cacheKey, ...)
end

--- Register `getConfiguration` as export function
exports('__c', getConfiguration)