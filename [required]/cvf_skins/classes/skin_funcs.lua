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
---@type corev_client
local corev = assert(corev_client)
local getTattooData = assert(getTattooData)
local pairs = assert(pairs)
local upper = assert(string.upper)
local lower = assert(string.lower)
local GetHashKey = assert(GetHashKey)
local SetPedHeadBlendData = assert(SetPedHeadBlendData)
local SetPedHairColor = assert(SetPedHairColor)
local SetPedComponentVariation = assert(SetPedComponentVariation)
local SetPedHeadOverlay = assert(SetPedHeadOverlay)
local SetPedHeadOverlayColor = assert(SetPedHeadOverlayColor)
local GetNumberOfPedTextureVariations = assert(GetNumberOfPedTextureVariations)
local GetNumberOfPedPropTextureVariations = assert(GetNumberOfPedPropTextureVariations)
local ClearPedProp = assert(ClearPedProp)
local SetPedPropIndex = assert(SetPedPropIndex)
local ClearPedDecorations = assert(ClearPedDecorations)
local AddPedDecorationFromHashes = assert(AddPedDecorationFromHashes)

--- Create `skin_funcs` class
---@class skin_funcs
local skin_funcs = setmetatable({ __class = 'skin_funcs' }, {})

--- Checks if `input` exsists in `list`
---@param input number Any number
---@param list number[] List of numbers
---@return boolean `true` if `input` has been found, otherwise `false`
function skin_funcs:any(input, list)
    input = corev:ensure(input, -1)
    list = corev:ensure(list, {})

    for _, item in pairs(list) do
        if (item == input) then
            return true
        end
    end

    return false
end

--- Update category `inheritance` based on given `skin_options`
---@param skin_options skin_options Skin options
function skin_funcs:updateInheritance(skin_options)
    local _father = (skin_options:getOption('inheritance.father') or {}).value or 0
    local _mother = (skin_options:getOption('inheritance.mother') or {}).value or 0
    local _shapeMix = (skin_options:getOption('inheritance.shapeMix') or {}).value or 0
    local _skinMix = (skin_options:getOption('inheritance.skinMix') or {}).value or 0

    _shapeMix, _skinMix = _shapeMix + 0.0, _skinMix + 0.0

    SetPedHeadBlendData(skin_options.ped, _father, _mother, 0, _father, _mother, 0, _shapeMix, _skinMix, 0.0, false)
end

--- Update category `inheritance` based on given `skin_options`
---@param skin_options skin_options Skin options
function skin_funcs:updateAppearanceHair(skin_options)
    local _style = (skin_options:getOption('hair.style') or {}).value or 0
    local _color = (skin_options:getOption('hair.color') or {}).value or 0
    local _highlight = (skin_options:getOption('hair.highlight') or {}).value or 0

    SetPedHairColor(skin_options.ped, _color, _highlight)
    SetPedComponentVariation(skin_options.ped, 2, _style, _style)
end

--- Update category `appearance` based on given `skin_options`
---@param skin_options skin_options Skin options
function skin_funcs:updateAppearance(skin_options, key, index)
    key = corev:ensure(key, 'unknown')
    index = corev:ensure(index, -1)

    local _style = (skin_options:getOption(('%s.style'):format(key)) or {}).value or 0
    local _color = (skin_options:getOption(('%s.color'):format(key)) or {}).value or 0
    local _opacity = (skin_options:getOption(('%s.opacity'):format(key)) or {}).value or 0

    if (index < 0) then return end

    _opacity = _opacity + 0.0

    if (self:any(index, { 0, 3, 6, 7, 9, 11, 12 })) then
        SetPedHeadOverlay(skin_options.ped, index, _style, _opacity)
    elseif (self:any(index, { 1, 2, 10 })) then
        SetPedHeadOverlay(skin_options.ped, index, _style, _opacity)
        SetPedHeadOverlayColor(skin_options.ped, index, 1, _color, _color)
    elseif (self:any(index, { 4, 5, 8 })) then
        SetPedHeadOverlay(skin_options.ped, index, _style, _opacity)
        SetPedHeadOverlayColor(skin_options.ped, index, 2, _color, _color)
    end
end

--- Update category `clothing` based on given `skin_options`
---@param skin_options skin_options Skin options
function skin_funcs:updateClothing(skin_options, key, index)
    key = corev:ensure(key, 'unknown')
    index = corev:ensure(index, -1)

    local _style = (skin_options:getOption(('%s.style'):format(key)) or {}).value or 0
    local _variantOption = skin_options:getOption(('%s.variant'):format(key))
    local _variant = (_variantOption or {}).value or 0

    if (index < 0) then return end

    SetPedComponentVariation(skin_options.ped, index, _style, _variant)

    local newMax = GetNumberOfPedTextureVariations(skin_options.ped, index, _style)

    if (_variantOption ~= nil) then
        _variantOption.max = newMax

        skin_options:updateValue(_variantOption.name, _variant, false)
    end
end

--- Update category `props` based on given `skin_options`
---@param skin_options skin_options Skin options
function skin_funcs:updateProp(skin_options, key, index)
    key = corev:ensure(key, 'unknown')
    index = corev:ensure(index, -1)

    local _style = (skin_options:getOption(('%s.style'):format(key)) or {}).value or -1
    local _variantOption = skin_options:getOption(('%s.variant'):format(key))
    local _variant = (_variantOption or {}).value or 0

    if (index < 0) then return end

    if (_style == -1) then
        ClearPedProp(skin_options.ped, index)
    else
        SetPedPropIndex(skin_options.ped, index, _style, _variant, 2)

        local newMax = GetNumberOfPedPropTextureVariations(skin_options.ped, index, _style)

        if (_variantOption ~= nil) then
            _variantOption.max = newMax

            skin_options:updateValue(_variantOption.name, _variant, false)
        end
    end
end

--- Update category `tattoo` based on given `skin_options`
---@param skin_options skin_options Skin options
function skin_funcs:updateTattoos(skin_options)
    local tattooData = getTattooData(skin_options.isMale and 'male' or 'female')

    ClearPedDecorations(skin_options.ped)

    for categoryKey, tattoo_category in pairs(skin_options.tattoos or {}) do
        for _, category_option in pairs(tattoo_category.options or {}) do
            local value = category_option.value or 0

            if (value > 0) then
                local header = upper(corev:replace(categoryKey, 'tattoo_', ''))
                local categoryName = ('tattoo_%s.'):format(lower(header))
                local dlc = corev:replace(category_option.name, categoryName, '')
                local nameOfTatto = ((tattooData[header] or {})[dlc] or {})[value] or 'unknown'

                if (nameOfTatto ~= 'unknown') then
                    AddPedDecorationFromHashes(skin_options.ped, GetHashKey(dlc), GetHashKey(nameOfTatto))
                end
            end
        end
    end
end

--- Register `skin_funcs` as global library
_G.skin_funcs = skin_funcs