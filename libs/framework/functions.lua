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
--
-- Custom function for try catch
-- @func function Function to call
-- @catch_func function Trigger when exception is given
--
local function try(func, catch_func)
    local status, exception = pcall(func)

    if (not status) then
        catch_func(exception)
    end
end

-- Trim a string
-- @value string String to trim
-- @result string String after trim
--
local function string_trim(value)
    if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

--- Translations
---@param resource Resource
---@param module Module Name
---@param key Translation Key
local function _(resource, module, key, ...)
    local translations = CoreV.Translations or {}
    local resourceTranslations = translations[resource] or {}
    local moduleTranslations = resourceTranslations[module] or {}
    local translationKey = moduleTranslations[key] or ('MISSING TRANSLATION [%s][%s][%s]'):format(resource, module, key)

    return translationKey:format(...)
end

--- Returns a current time as string
local function currentTimeString()
    local date_table = os.date("*t")
    local hour, minute, second = date_table.hour, date_table.min, date_table.sec
    local year, month, day = date_table.year, date_table.month, date_table.day

    if (tonumber(month) < 10) then
        month = '0' .. tostring(month)
    end

    if (tonumber(day) < 10) then
        day = '0' .. tostring(day)
    end

    if (tonumber(hour) < 10) then
        hour = '0' .. tostring(hour)
    end

    if (tonumber(minute) < 10) then
        minute = '0' .. tostring(minute)
    end

    if (tonumber(second) < 10) then
        second = '0' .. tostring(second)
    end

    local timestring = ''

    if (string.lower(Config.Locale or 'en') == 'nl') then
        timestring = string.format("%d-%d-%d %d:%d:%d", day, month, year, hour, minute, second)
    else
        timestring = string.format("%d-%d-%d %d:%d:%d", year, month, day, hour, minute, second)
    end

    return timestring
end

--- Split a string by `delim`
--- @param str string String to split
--- @param delim Delimeter to split at
local function split(str, delim)
    local t = {}

    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
    end

    return t
end

--- Round up a value
--- @param value int Value to round up
--- @param numDecimalPlaces int Number of decimals
local function round(value, numDecimalPlaces)
    if (numDecimalPlaces) then
        local power = 10^numDecimalPlaces
        return math.floor((value * power) + 0.5) / (power)
    end

    return math.floor(value + 0.5)
end

local function updateFilePath(file)
    _ENV.CurrentFile = file
end

local function string_replace(str, this, that)
    local b,e = str:find(this,1,true)
  if b==nil then
     return str
  else
     return str:sub(1,b-1) .. that .. str:sub(e+1):replace(this, that)
  end
end

local function os_currentTime()
    local a, b = math.modf(os.clock())

    if (b == 0) then
        b = '000'
    else
        b = tostring(b):sub(3,5)
    end

    local tf = os.date('%Y-%m-%d %H:%M:%S.', os.time())

    return tf .. b
end

local function os_currentTimeInMilliseconds()
    local currentMilliseconds = 0
    local a, b = math.modf(os.clock())

    if (b == 0) then
        currentMilliseconds = 0
    else
        currentMilliseconds = tonumber(tostring(b):sub(3,5))
    end

    local currentLocalTime = os.time(os.date('*t'))

    currentLocalTime = currentLocalTime * 1000
    currentLocalTime = currentLocalTime + currentMilliseconds

    return currentLocalTime
end

local function os_currentTimeAsString()
    return os.date('%H:%M', os.time())
end

--- Hex to RGB
--- @param hex string Hex as #FFF or #FFFFFF
local function hex2rgb(hex)
    if (hex == nil or type(hex) ~= 'string') then return 255, 255, 255 end
    if (hex:startswith('#')) then hex = hex:gsub('#', '') end

    if (string.len(hex) == 3) then
        return tonumber(('0x%s'):format(hex:sub(1,1))), 
            tonumber(('0x%s'):format(hex:sub(2,2))),
            tonumber(('0x%s'):format(hex:sub(3,3)))
    elseif (string.len(hex) == 6) then
        return tonumber(('0x%s'):format(hex:sub(1,2))), 
            tonumber(('0x%s'):format(hex:sub(3,4))),
            tonumber(('0x%s'):format(hex:sub(5,6)))
    end

    return 255, 255, 255
end

--- Get a file from stream folder
--- @param resource string Resource Name
--- @param module string Module Name
--- @param file string Filename
local function getStreamFile(resource, module, file)
    if (resource == nil or type(resource) ~= 'string') then return nil end
    if (module == nil or type(module) ~= 'string') then return nil end
    if (file == nil or type(file) ~= 'string') then return nil end

    local isInternal = string.lower(resource) == string.lower(GetCurrentResourceName())

    if (isInternal) then
        local internalModuleData = LoadResourceFile(GetCurrentResourceName(), ('stream/01_%s/%s'):format(module, file))

        if (internalModuleData ~= nil and internalModuleData) then
            return internalModuleData
        end

        local internalResourceData = LoadResourceFile(GetCurrentResourceName(), ('stream/02_%s/%s'):format(module, file))

        if (internalResourceData ~= nil and internalResourceData) then
            return internalResourceData
        end

        return nil
    end

    local externalModuleData = LoadResourceFile(GetCurrentResourceName(), ('stream/03_%s/%s'):format(module, file))

    if (externalModuleData ~= nil and externalModuleData) then
        return externalModuleData
    end

    local externalResourceData = LoadResourceFile(GetCurrentResourceName(), ('stream/04_%s/%s'):format(module, file))

    if (externalResourceData ~= nil and externalResourceData) then
        return externalResourceData
    end

    return nil
end

local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-={}|[]`~'
local charTable = {}

for c in chars:gmatch"." do
    table.insert(charTable, c)
end

--- Returns a random string
--- @param length number Length of string
local function getRandomString(length)
    if (length == nil or type(length) ~= 'number' or length <= 0) then length = 24 end

    local randomString = ''

    if (os ~= nil and os.time ~= nil) then
        math.randomseed(os.time())
    end

    for i = 1, length do
        randomString = randomString .. charTable[math.random(1, #charTable)]
    end
end

local function getCurrentModule()
    if (CLIENT) then
        local debugInfo = debug.getinfo(3)
        local pathOfModule = debugInfo.short_src or 'unknown'
        local currentResourceName = GetCurrentResourceName()

        pathOfModule = string.replace(pathOfModule, '@', '')

        local isInternalModule = string.startswith(pathOfModule, currentResourceName)

        if (isInternalModule) then
            for _, _module in pairs(resource.internalModules or {}) do
                local generatedPath = ('%s/client/%s_module_client.lua'):format(currentResourceName, _module.name)

                if (string.lower(generatedPath) == pathOfModule) then
                    return _module.name
                end
            end

            for _, _resource in pairs(resource.internalResources or {}) do
                local generatedPath = ('%s/client/%s_resource_client.lua'):format(currentResourceName, _resource.name)

                if (string.lower(generatedPath) == pathOfModule) then
                    return _resource.name
                end
            end

            return nil
        end
    end

    return nil
end

-- FiveM maniplulation
_ENV.getCurrentModule = getCurrentModule
_G.getCurrentModule = getCurrentModule
_ENV.try = try
_G.try = try
_ENV.string.trim = string_trim
_G.string.trim = string_trim
_ENV.string.split = function(self, delim)
    return split(self, delim)
end
_G.string.split = function(self, delim)
    return split(self, delim)
end
_ENV._ = _
_G._ = _
_ENV.currentTimeString = currentTimeString
_G.currentTimeString = currentTimeString
_ENV.split = split
_G.split = split
_ENV.round = round
_G.round = round
_ENV.hex2rgb = hex2rgb
_G.hex2rgb = hex2rgb
_ENV.updateFilePath = updateFilePath
_G.updateFilePath = updateFilePath
_ENV.getStreamFile = getStreamFile
_G.getStreamFile = getStreamFile
_ENV.getRandomString = getRandomString
_G.getRandomString = getRandomString

_ENV.CR = function()
    if (CurrentFrameworkResource ~= nil and type(CurrentFrameworkResource) == 'string' and CurrentFrameworkResource ~= '') then
        return CurrentFrameworkResource
    end

    return GetCurrentResourceName()
end
_G.CR = function()
    if (CurrentFrameworkResource ~= nil and type(CurrentFrameworkResource) == 'string' and CurrentFrameworkResource ~= '') then
        return CurrentFrameworkResource
    end

    return GetCurrentResourceName()
end

_ENV.string.startswith = function(self, str)
    return self:sub(1, #str) == str
end
_G.string.startswith = function(self, str)
    return self:sub(1, #str) == str
end
_ENV.string.endswith = function(self, str)
    return self:sub(-#str) == str
end
_G.string.endswith = function(self, str)
    return self:sub(-#str) == str
end

_ENV.string.replace = string_replace
_G.string.replace = string_replace

if (_ENV.os == nil) then _ENV.os = {} end
if (_G.os == nil) then _G.os = {} end

_ENV.os.currentTime = function(self)
    return os_currentTime()
end
_G.os.currentTime = function(self)
    return os_currentTime()
end

_ENV.os.currentTimeInMilliseconds = function(self)
    return os_currentTimeInMilliseconds()
end
_G.os.currentTimeInMilliseconds = function(self)
    return os_currentTimeInMilliseconds()
end

_ENV.os.currentTimeAsString = os_currentTimeAsString
_G.os.currentTimeAsString = os_currentTimeAsString

local function triggerServerEvent(name, ...)
    if (CLIENT) then
        TriggerServerEvent(name, ...)
    else
        TriggerEvent(name, ...)
    end
end

local function triggerClientEvent(name, param1, ...)
    if (CLIENT) then
        TriggerEvent(name, param1, ...)
    else
        if (type(param1) == 'string') then param1 = tonumber(param1) end
        if (type(param1) ~= 'number') then param1 = 0 end

        if (param1 == 0) then
            TriggerEvent(name, ...)
        else
            TriggerClientEvent(name, param1, ...)
        end
    end
end

_ENV.TSE = triggerServerEvent
_G.TSE = triggerServerEvent
_ENV.TCE = triggerClientEvent
_G.TCE = triggerClientEvent