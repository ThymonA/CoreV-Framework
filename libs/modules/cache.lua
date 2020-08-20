--- cache addon
cache = class('cache')

-- set default values
cache:set {
    data = {}
}

--- Read data from the cache
--- @param key cached key
function cache:read(key)
    if (key == nil or (type(key) ~= 'number' and type(key) ~= 'string')) then
        return nil
    end

    if (type(key) == 'number') then
        key = tostring(key)
    end

    key = string.lower(key)

    if (cache.data ~= nil and cache.data[key] ~= nil) then
        return cache.data[key]
    end

    return nil
end

--- Write data to the cache
--- @param key Cache Key
--- @param value Cache Value
function cache:write(key, value)
    if (key == nil or (type(key) ~= 'number' and type(key) ~= 'string')) then
        return nil
    end

    if (type(key) == 'number') then
        key = tostring(key)
    end

    key = string.lower(key)

    if (cache.data ~= nil) then
        cache.data[key] = value
    end
end

--- Check if key exists in cache
--- @param key Cache Key
function cache:exists(key)
    if (key == nil or (type(key) ~= 'number' and type(key) ~= 'string')) then
        return false
    end

    if (type(key) == 'number') then
        key = tostring(key)
    end

    key = string.lower(key)

    if (cache.data ~= nil and cache.data[key] ~= nil) then
        return true
    end

    return false
end

--- Add cache as module when available
Citizen.CreateThread(function()
    while true do
        if (addModule ~= nil and type(addModule) == 'function') then
            addModule('cache', cache)
            return
        end

        Citizen.Wait(0)
    end
end)