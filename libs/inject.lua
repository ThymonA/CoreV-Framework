local function loadModule(name)
    if (name == nil or type(name) ~= 'string') then return nil end

    name = string.lower(name)

    if (Modules ~= nil and Modules[name] ~= nil) then
        local executable = Modules[name]

        if (executable:isLoaded()) then
            return executable:get()
        end

        if (executable:hasError()) then
            return nil
        end

        return self:get(name)
    end

    return nil
end

local function _type(value)
	local rawType = type(value)

	if (rawType ~= 'table') then
		return rawType
	end

	if (value.__class) then
		return value.__class
	end

	return rawType
end

_ENV.m = loadModule
_G.m = loadModule
_ENV.info = _type
_G.info = _type