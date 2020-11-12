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
local randomseed = assert(math.randomseed)
local random = assert(math.random)
local floor = assert(math.floor)
local load = assert(load)
local pcall = assert(pcall)
local xpcall = assert(xpcall)
local pairs = assert(pairs)
local traceback = assert(debug.traceback)
local error = assert(error)
local vector3 = assert(vector3)
local vector2 = assert(vector2)
local setmetatable = assert(setmetatable)
local CreateThread = assert(Citizen.CreateThread)
local Wait = assert(Citizen.Wait)

--- FiveM cached global variables
local LoadResourceFile = assert(LoadResourceFile)
local GetResourceState = assert(GetResourceState)
local _TSE = assert(TriggerServerEvent)
local _RNE = assert(RegisterNetEvent)
local _AEH = assert(AddEventHandler)
local IsDuplicityVersion = assert(IsDuplicityVersion)
local GetCurrentResourceName = assert(GetCurrentResourceName)
local GetHashKey = assert(GetHashKey)
local HasModelLoaded = assert(HasModelLoaded)
local IsModelInCdimage = assert(IsModelInCdimage)
local RequestModel = assert(RequestModel)
local HasStreamedTextureDictLoaded = assert(HasStreamedTextureDictLoaded)
local RequestStreamedTextureDict = assert(RequestStreamedTextureDict)
local GetGameTimer = assert(GetGameTimer)

--- Required resource variables
local isClient = not IsDuplicityVersion()
local currentResourceName = GetCurrentResourceName()
local INT32_MAX, INT64_MAX = 2147483648, 4294967296

--- Cahce FiveM globals
local exports = assert(exports)
local __exports = assert({})

--- Prevent this file from executing from wrong side
if (not isClient) then
    error('You are trying to load a client file which is only allowed on the client side')
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
    [3] = { r = 'menuv', f = '__open', s = false },
    [4] = { r = 'menuv', f = '__close', s = false },
    [5] = { r = 'menuv', f = '__create', s = false }
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
local corev = class "corev"

--- Set default values for `corev` class
corev:set('callback', class "corev-callback")
corev:set('streaming', class "corev-streaming")
corev:set('menu', class "corev-menu")

--- Set default values for `corev-callback` class
corev.callback:set('requestId', 1)
corev.callback:set('callbacks', {})

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
    if (value.__class) then return value.__class end
    if (value.__type) then return value.__type end

    return rawType
end

--- Convert value to number
--- @param value any Any value
--- @return number A integer
function corev:toInt(value)
    local rawType = self:typeof(value)

    if (rawType == 'nil') then return 0 end
    if (rawType == 'number') then return value or 0 end

    return tonumber(value) or 0
end

--- Convert value to int32
--- @param value any Any value to int32
--- @return number Int32 value
function corev:maxInt32(value)
    local input = self:toInt(value)

    if (input >= INT32_MAX) then
        return input & (INT64_MAX - 1)
    end

    return input
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

--- Returns translation key founded or 'MISSING TRANSLATION'
--- @param language string? (optional) Needs to be a two letter identifier, example: EN, DE, NL, BE, FR etc.
--- @param module string? (optional) Register translation for a module, example: core
--- @param key string Key of translation
--- @returns string Translation or 'MISSING TRANSLATION'
function corev:t(...)
    if (__exports[2].self == nil) then
        return __exports[2].func(...)
    else
        return __exports[2].func(__exports[2].self, ...) 
    end
end

--- Own implementation of GetHashKey
--- https://gist.github.com/ThymonA/5266760e0fe302feceb19094b6bff458
--- @param name string Key to transform to hash
--- @returns number Generated hash
function corev:hashString(name)
    name = corev:ensure(name, 'unknown')

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

--- Trigger func by server
--- @param name string Name of trigger
--- @param callback function Trigger this function
function corev:onServerTrigger(name, callback)
    name = corev:ensure(name, 'unknown')
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown') then return end

    _RNE(name)
    _AEH(name, callback)
end

--- Trigger func by client
--- @param name string Name of trigger
--- @param callback function Trigger this function
function corev:onClientTrigger(name, callback)
    name = corev:ensure(name, 'unknown')
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown') then return end

    _AEH(name, callback)
end

--- Trigger server callback
--- @param name string Name of callback
--- @param callback function Trigger this function on server return
function corev.callback:triggerCallback(name, callback, ...)
    name = corev:ensure(name, 'unknown')
    callback = corev:ensure(callback, function() end)

    if (name == 'unknown') then return end

    self.callbacks[self.requestId] = callback

    _TSE(('corev:%s:serverCallback'):format(currentResourceName), name, self.requestId, ...)

    if (self.requestId < 65535) then
        self.requestId = self.requestId + 1
    else
        self.requestId = 1
    end
end

--- Load a model async and trigger cb when model has been loaded
--- @param hash number|string Hash you want to load
--- @param cb function When model is loaded, this function will be triggerd
function corev.streaming:requestModelAsync(hash, cb)
    hash = corev:typeof(hash) == 'number' and hash or corev:ensure(hash, 'unknown')
    cb = corev:ensure(cb, function() end)

    if (corev:typeof(hash) == 'string') then
        if (hash == 'unknown') then return end

        hash = GetHashKey(hash)
    end

    if (not HasModelLoaded(hash) and IsModelInCdimage(hash)) then
        RequestModel(hash)

        repeat Wait(0) until HasModelLoaded(hash) == true
    end

    cb()
end

--- Load a texture dictonary async and trigger cb when dictonary has been loaded
--- @param hash string Name of texture dictonary to load
--- @param cb function When dictonary is loaded, this function will be triggerd
function corev.streaming:requestTextureAsync(textureDictionary, cb)
    textureDictionary = corev:ensure(textureDictionary, 'unknown')
    cb = corev:ensure(cb, function() end)

    if (textureDictionary == 'unknown') then return end

    if (HasStreamedTextureDictLoaded(textureDictionary)) then
        cb()
        return
    end

    RequestStreamedTextureDict(textureDictionary, true)

    repeat Wait(0) until HasStreamedTextureDictLoaded(textureDictionary) == true

    cb()
end

--- Open a menu based on given `name` and `resource`
--- @param resource string (optional) Name of resource where menu is created
--- @param name string Name of menu
function corev.menu:open(...)
    if (__exports[3].self == nil) then
        return __exports[3].func(...)
    else
        return __exports[3].func(__exports[3].self, ...)
    end
end

--- Close a menu based on given `name` and `resource`
--- @param resource string (optional) Name of resource where menu is created
--- @param name string Name of menu
function corev.menu:close(...)
    if (__exports[4].self == nil) then
        return __exports[4].func(...)
    else
        return __exports[4].func(__exports[4].self, ...)
    end
end

--- Close a menu based on given `name` and `resource`
--- @param name string Name of menu
--- @param title string Title of menu
--- @param subtitle string Subtitle of menu
--- @return menu Created `menu` class
function corev.menu:create(name, title, subtitle)
    if (__exports[5].self == nil) then
        return __exports[5].func(name, title, subtitle)
    else
        return __exports[5].func(__exports[5].self, name, title, subtitle)
    end
end

--- Results from server callback
corev:onServerTrigger(('corev:%s:serverCallback'):format(currentResourceName), function(requestId, ...)
    requestId = corev:ensure(requestId, 0)

    if (requestId <= 0 or requestId > 65535) then return end
    if (((corev.callback or {}).callbacks or {})[requestId] == nil) then return end

    corev.callback.callbacks[requestId](...)
    corev.callback.callbacks[requestId] = nil
end)

--- Returns stored resource name or call `GetCurrentResourceName`
--- @return string Returns name of current resource
function corev:getCurrentResourceName()
    if (self:typeof(currentResourceName) == 'string') then
        return currentResourceName
    end

    return GetCurrentResourceName()
end

--- Will generate a random string based on given length
--- @param length number Length the random string must be
--- @param recurse boolean When `false`, GetGameTimer() will called as seed, otherwise keep current seed
--- @return string Generated random string matching your length
function corev:getRandomString(length, recurse)
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

--- Register corev as global variable
global.corev = corev

----------------------------
--- Modify global variables
----------------------------
global.string = string

--- Checks if a string starts with given word
--- @param self string String to search in
--- @param word string Word to search for
--- @return boolean `true` if word has been found, otherwise `false`
global.string.startsWith = function(self, word)
    word = corev:ensure(word, 'unknown')

    return self:sub(1, #word) == word
end

--- Represent a empty string
global.string.empty = ''