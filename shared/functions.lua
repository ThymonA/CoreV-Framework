----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.thymonarens.nl/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: ThymonA
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
    return ((((CoreV.Translations or {})[resource] or {})[module] or {})[key] or ('MISSING TRANSLATION [%s][%s][%s]'):format(resource, module, key)):format(...)
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

local function split(str, delim)
    local t = {}

    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
    end

    return t
end

local function triggerClientEvent(name, source, ...)
    if (type(source) == 'string') then source = tonumber(source) end
    if (type(source) ~= 'number') then source = 0 end

    if (SERVER and source == 0) then
        TriggerEvent(name, ...)
    elseif(SERVER) then
        TriggerClientEvent(name, source, ...)
    end
end

-- FiveM maniplulation
_ENV.try = try
_G.try = try
_ENV.string.trim = string_trim
_G.string.trim = string_trim
_ENV._ = _
_G._ = _
_ENV.currentTimeString = currentTimeString
_G.currentTimeString = currentTimeString
_ENV.split = split
_G.split = split
_ENV.CR = GetCurrentResourceName
_G.CR = GetCurrentResourceName

if (CLIENT) then
    _ENV.TSE = TriggerServerEvent
    _G.TSE = TriggerServerEvent
end

if (SERVER) then
    _ENV.TCE = triggerClientEvent
    _G.TCE = triggerClientEvent
end