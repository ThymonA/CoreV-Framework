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
---@type corev_client|corev_server
local corev = assert(corev_client or corev_server)
local pairs = assert(pairs)
local insert = assert(table.insert)
local decode = assert(json.decode)
local sub = assert(string.sub)
local pack = assert(table.pack)

--- Cahce FiveM globals
local exports = assert(exports)
local GetInvokingResource = assert(GetInvokingResource)
local LoadResourceFile = assert(LoadResourceFile)
local GetNumResources = assert(GetNumResources)
local GetResourceByFindIndex = assert(GetResourceByFindIndex)
local GetNumResourceMetadata = assert(GetNumResourceMetadata)
local GetResourceMetadata = assert(GetResourceMetadata)

--- Create translation class
---@class translations
local translations = setmetatable({ __class = 'translations' }, {})

--- Set default values
translations.translations = {}

--- Add a translation to CoreV's framework
---@param language string Needs to be a two letter identifier, example: EN, DE, NL, BE, FR etc.
---@param module string Register translation for a module, example: core
---@param key string Key of translation
---@param value string Translated value
---@param override boolean Override if translation already exists
function translations:addTranslation(language, module, key, value, override)
    language = corev:ensure(language, 'unknown')
    module = corev:ensure(module, 'unknown')
    key = corev:ensure(key, 'unknown')
    value = corev:ensure(value, 'unknown')
    override = corev:ensure(override, false)

    if (language == 'unknown' or key == 'unknown' or value == 'unknown') then
        return
    end

    if (module == 'unknown') then module = 'core' end

    module = corev:hashString(module)
    language = corev:hashString(language)
    key = corev:hashString(key)

    if (self.translations == nil) then self.translations = {} end
    if (self.translations[module] == nil) then self.translations[module] = {} end
    if (self.translations[module][language] == nil) then self.translations[module][language] = {} end

    if (not override and self.translations[module][language][key] ~= nil) then return end

    self.translations[module][language][key] = value
end

--- Returns a translation from current framework
---@param language string Needs to be a two letter identifier, example: EN, DE, NL, BE, FR etc.
---@param module string Register translation for a module, example: core
---@param key string Key of translation
---@return string Translation or 'MISSING TRANSLATION'
function translations:getTranslation(language, module, key)
    language = corev:ensure(language, 'unknown')
    module = corev:ensure(module, 'unknown')
    key = corev:ensure(key, 'unknown')

    if (language == 'unknown' or key == 'unknown') then
        return 'MISSING TRANSLATION'
    end

    if (module == 'unknown') then module = 'core' end

    --- Transform invoking resource to CoreV module
    if (module:startsWith('corev_')) then
        module = sub(module, 7)
    elseif (module:startsWith('cvf_')) then
        module = sub(module, 5)
    elseif (module == 'corev') then
        module = 'core'
    end

    module = corev:hashString(module)
    language = corev:hashString(language)
    key = corev:hashString(key)

    return (((self.translations or {})[module] or {})[language] or {})[key] or 'MISSING TRANSLATION'
end

--- Load all translations
for i = 0, GetNumResources(), 1 do
    local translationFiles = {}
    local resourceName = corev:ensure(GetResourceByFindIndex(i), 'unknown')

    if (resourceName ~= 'unknown') then
        for i2 = 0, GetNumResourceMetadata(resourceName, 'translation'), 1 do
            local translationFile = corev:ensure(GetResourceMetadata(resourceName, 'translation', i2), 'unknown')

            if (translationFile ~= 'unknown') then
                insert(translationFiles, translationFile)
            end
        end
    end

    for _, translationFile in pairs(translationFiles) do
        if (corev:endswith(translationFile, '.json')) then
            local jsonFile = LoadResourceFile(resourceName, translationFile)

            if (jsonFile) then
                local jsonData = decode(jsonFile)

                if (jsonData) then
                    local __language = jsonData.language or 'xx'
                    local __translations = jsonData.translations or {}
                    local __module = resourceName

                    __language = corev:ensure(__language, 'xx')
                    __translations = corev:ensure(__translations, {})

                    if (__module == 'corev') then
                        __module = 'core'
                    else
                        if (__module:startsWith('corev_')) then
                            __module = sub(__module, 7)
                        elseif (__module:startsWith('cvf_')) then
                            __module = sub(__module, 5)
                        end

                        __module = corev:ensure(__module, 'core')
                    end

                    for __key, __value in pairs(__translations) do
                        __key = corev:ensure(__key, 'unknown')
                        __value = corev:ensure(__value, 'unknown')

                        translations:addTranslation(__language, __module, __key, __value, true)
                    end
                end
            end
        end
    end
end

--- Returns translation key founded or 'MISSING TRANSLATION'
---@params language string? (optional) Needs to be a two letter identifier, example: EN, DE, NL, BE, FR etc.
---@params module string? (optional) Register translation for a module, example: core
---@params key string Key of translation
---@return string Translation or 'MISSING TRANSLATION'
local function getTranslationKey(...)
    local __module = GetInvokingResource()

    __module = corev:ensure(__module, 'corev')

    local arguments = pack(...)

    if (#arguments == 0) then
        return 'MISSING TRANSLATION'
    end

    if (#arguments == 1) then
        local language = corev:ensure(corev:cfg('core', 'language'), 'en')
        local module = __module
        local key = corev:ensure(arguments[1], 'unknown')

        return translations:getTranslation(language, module, key)
    end

    if (#arguments == 2) then
        local language = corev:ensure(corev:cfg('core', 'language'), 'en')
        local module = corev:ensure(arguments[1], __module)
        local key = corev:ensure(arguments[2], 'unknown')

        return translations:getTranslation(language, module, key)
    end

    if (#arguments >= 3) then
        local language = corev:ensure(arguments[1], 'en')
        local module = corev:ensure(arguments[2], __module)
        local key = corev:ensure(arguments[3], 'unknown')

        return translations:getTranslation(language, module, key)
    end

    return 'MISSING TRANSLATION'
end

--- Register `getTranslationKey` as export function
exports('__t', getTranslationKey)