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
local gmatch = assert(string.gmatch)
local insert = assert(table.insert)
local isClient = not IsDuplicityVersion()
local currentResourceName = GetCurrentResourceName()

--- Cahce FiveM globals
local exports = assert(exports)
local __exports = assert({})

--- Load those exports
local __loadExports = {
    { r = 'cvf_config', f = '__c' },
    { r = 'cvf_ids', f = '__id' },
    { r = 'cvf_translations', f = '__t' }
}

--- Store global exports as local variable
for index, _le in pairs(__loadExports) do
    if (currentResourceName ~= _le.r) then
        __exports[index] = { self = assert(exports[_le.r]), func = nil }
        __exports[index].func = assert(__exports[index].self[_le.f])
    else
        __exports[index] = { self = nil, func = __global[_le.f] or __environment[_le.f] or function() return nil end }
    end
end

--- Remove table from memory
__loadExports = nil

if (not isClient) then
    error('You are trying to load a client file which is only allowed on the client side')
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
            local ok, result = xpcall(func, debug.traceback)

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
local corev = class "corev"

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

--- Register corev as global variable
global.corev = corev