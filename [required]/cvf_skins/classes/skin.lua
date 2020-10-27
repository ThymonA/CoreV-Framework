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
local class = assert(class)
local corev = assert(corev)
local skin_funcs = assert(skin_funcs)
local pairs = assert(pairs)
local GetNumberOfPedDrawableVariations = assert(GetNumberOfPedDrawableVariations)
local GetNumberOfPedPropDrawableVariations = assert(GetNumberOfPedPropDrawableVariations)
local GetNumHeadOverlayValues = assert(GetNumHeadOverlayValues)
local GetNumHairColors = assert(GetNumHairColors)
local GetPedDrawableVariation = assert(GetPedDrawableVariation)
local GetNumberOfPedTextureVariations = assert(GetNumberOfPedTextureVariations)
local GetPedTextureVariation = assert(GetPedTextureVariation)
local GetPedPropIndex = assert(GetPedPropIndex)
local GetNumberOfPedPropTextureVariations = assert(GetNumberOfPedPropTextureVariations)
local GetPedPropTextureIndex = assert(GetPedPropTextureIndex)
local __GetPedHeadOverlayValue = assert(GetPedHeadOverlayValue)

--- Wrapper for GetPedHeadOverlayValue
local function GetPedHeadOverlayValue(ped, index)
    local value = __GetPedHeadOverlayValue(ped, index)

    if (value ~= 255) then return value end

    return 0
end

--- Returns a `skin_options` classed based on given `ped`
--- @param ped any Any ped entity
function GeneratePedSkin(ped)
    --- Makes sure that ped exists
    ped = corev:ensure(ped, PlayerPedId())

    --- Load and checks ped model
    local pedModel = GetEntityModel(ped)
    local isMP = pedModel == GetHashKey('mp_m_freemode_01') or pedModel == GetHashKey('mp_f_freemode_01')

    --- Create a skin_options class
    local skin_options = class 'skin_options'
    local __index = 0

    --- Set default values
    skin_options:set {
        ped = ped,
        isMultiplayerPed = isMP,
        options = {}
    }

    --- Create a skin option
    --- @param name string Name for option identification
    --- @param min number Number of minimal results
    --- @param max number Number of maximum results
    --- @param value number Current number on ped
    --- @return skin_option Generated skin option
    function skin_options:createOptions(name, min, max, value)
        __index = __index + 1
        name = corev:ensure(name, 'unknown')
        min = corev:ensure(min, 0)
        max = corev:ensure(max, 0)
        value = corev:ensure(value, min)

        if (name == 'unknown') then return nil end

        --- Create a `skin_option` class
        local skin_option = class 'skin_option'

        --- Set default value
        skin_option:set {
            index = __index,
            name = name,
            min = min,
            max = max,
            value = value
        }

        return skin_option
    end

    --- Create a skin category
    --- @param name string Name of category
    function skin_options:createCategory(name)
        name = corev:ensure(name, 'unknown')

        --- Create a `skin_category` class
        local skin_category = class 'skin_category'

        --- Set default values
        skin_category:set {
            name = name,
            options = {}
        }

        --- Add a `skin_option` class to current category
        --- @param _name string Name for option identification
        --- @param min number Number of minimal results
        --- @param max number Number of maximum results
        function skin_category:addOption(_name, min, max, value)
            _name = corev:ensure(_name, 'unknown')
            min = corev:ensure(min, 0)
            max = corev:ensure(max, 0)
            value = corev:ensure(value, 0)

            if (_name == 'unknown') then return nil end

            self.options[_name] = skin_options:createOptions(('%s.%s'):format(self.name, _name), min, max, value)
        end

        return skin_category
    end

    --- Transform current skin into table
    function skin_options:toTable()
        local result = {}

        for index, option in pairs(self.options) do
            result[index] = option.value
        end

        return result
    end

    --- Returns `skin_option` based on `input`
    --- @param input any Any input
    --- @returns skin_option|nil Skin option based on `input`
    function skin_options:getOption(input)
        if (input == nil) then return nil end

        local inputType = corev:typeof(input)

        if (inputType == 'number') then
            if (self.options[input] ~= nil) then
                return self.options[input]
            end

            return nil
        end

        if (inputType == 'string') then
            for key, option in pairs(self.options) do
                if (option.name == input) then
                    return self.options[key]
                end
            end

            return nil
        end

        return nil
    end

    --- #inheritance
    skin_options:set('inheritance', skin_options:createCategory('inheritance'))

    skin_options.inheritance:addOption('father', 0, 46, 0)
    skin_options.inheritance:addOption('mother', 0, 46, 0)
    skin_options.inheritance:addOption('shapeMix', 0, 10, 0)
    skin_options.inheritance:addOption('skinMix', 0, 10, 0)
    --- #inheritance

    --- #appearance
    skin_options:set('appearance', {
        hair = skin_options:createCategory('hair'),
        blemishes = skin_options:createCategory('blemishes'),
        beard = skin_options:createCategory('beard'),
        eyebrows = skin_options:createCategory('eyebrows'),
        ageing = skin_options:createCategory('ageing'),
        makeup = skin_options:createCategory('makeup'),
        blush = skin_options:createCategory('blush'),
        complexion = skin_options:createCategory('complexion'),
        sun_damage = skin_options:createCategory('sun_damage'),
        lipstick = skin_options:createCategory('lipstick'),
        moles_freckles = skin_options:createCategory('moles_freckles'),
        chest_hair = skin_options:createCategory('chest_hair'),
        body_blemishes = skin_options:createCategory('body_blemishes'),
        add_body_blemishes = skin_options:createCategory('add_body_blemishes'),
        eyes = skin_options:createCategory('eyes')
    })

    local numberOfColors = GetNumHairColors()

    --- #appearance -> hair
    skin_options.appearance.hair:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 2) + 1, GetPedDrawableVariation(ped, 2))
    skin_options.appearance.hair:addOption('color', 0, numberOfColors, 0)
    skin_options.appearance.hair:addOption('highlight', 0, numberOfColors, 0)
    --- #appearance -> blemishes
    skin_options.appearance.blemishes:addOption('style', 0, GetNumHeadOverlayValues(0), GetPedHeadOverlayValue(ped, 0))
    skin_options.appearance.blemishes:addOption('opacity', 0, 10, 0)
    --- #appearance -> beard
    skin_options.appearance.beard:addOption('style', 0, GetNumHeadOverlayValues(1), GetPedHeadOverlayValue(ped, 1))
    skin_options.appearance.beard:addOption('opacity', 0, 10, 0)
    skin_options.appearance.beard:addOption('color', 0, numberOfColors, 0)
    --- #appearance -> eyebrows
    skin_options.appearance.eyebrows:addOption('style', 0, GetNumHeadOverlayValues(2), GetPedHeadOverlayValue(ped, 2))
    skin_options.appearance.eyebrows:addOption('opacity', 0, 10, 0)
    skin_options.appearance.eyebrows:addOption('color', 0, numberOfColors, 0)
    --- #appearance -> ageing
    skin_options.appearance.ageing:addOption('style', 0, GetNumHeadOverlayValues(3), GetPedHeadOverlayValue(ped, 3))
    skin_options.appearance.ageing:addOption('opacity', 0, 10, 0)
    --- #appearance -> makeup
    skin_options.appearance.makeup:addOption('style', 0, GetNumHeadOverlayValues(4), GetPedHeadOverlayValue(ped, 4))
    skin_options.appearance.makeup:addOption('opacity', 0, 10, 0)
    skin_options.appearance.makeup:addOption('color', 0, numberOfColors, 0)
    --- #appearance -> blush
    skin_options.appearance.blush:addOption('style', 0, GetNumHeadOverlayValues(5), GetPedHeadOverlayValue(ped, 5))
    skin_options.appearance.blush:addOption('opacity', 0, 10, 0)
    skin_options.appearance.blush:addOption('color', 0, numberOfColors, 0)
    --- #appearance -> complexion
    skin_options.appearance.complexion:addOption('style', 0, GetNumHeadOverlayValues(6), GetPedHeadOverlayValue(ped, 6))
    skin_options.appearance.complexion:addOption('opacity', 0, 10, 0)
    --- #appearance -> sun_damage
    skin_options.appearance.sun_damage:addOption('style', 0, GetNumHeadOverlayValues(7), GetPedHeadOverlayValue(ped, 7))
    skin_options.appearance.sun_damage:addOption('opacity', 0, 10, 0)
    --- #appearance -> lipstick
    skin_options.appearance.lipstick:addOption('style', 0, GetNumHeadOverlayValues(8), GetPedHeadOverlayValue(ped, 8))
    skin_options.appearance.lipstick:addOption('opacity', 0, 10, 0)
    skin_options.appearance.lipstick:addOption('color', 0, numberOfColors, 0)
    --- #appearance -> moles_freckles
    skin_options.appearance.moles_freckles:addOption('style', 0, GetNumHeadOverlayValues(9), GetPedHeadOverlayValue(ped, 9))
    skin_options.appearance.moles_freckles:addOption('opacity', 0, 10, 0)
    --- #appearance -> chest_hair
    skin_options.appearance.chest_hair:addOption('style', 0, GetNumHeadOverlayValues(10), GetPedHeadOverlayValue(ped, 10))
    skin_options.appearance.chest_hair:addOption('opacity', 0, 10, 0)
    skin_options.appearance.chest_hair:addOption('color', 0, numberOfColors, 0)
    --- #appearance -> body_blemishes
    skin_options.appearance.body_blemishes:addOption('style', 0, GetNumHeadOverlayValues(11), GetPedHeadOverlayValue(ped, 11))
    skin_options.appearance.body_blemishes:addOption('opacity', 0, 10, 0)
    --- #appearance -> add_body_blemishes
    skin_options.appearance.add_body_blemishes:addOption('style', 0, GetNumHeadOverlayValues(12), GetPedHeadOverlayValue(ped, 12))
    skin_options.appearance.add_body_blemishes:addOption('opacity', 0, 10, 0)
    --- #appearance

    --- #clothing
    skin_options:set('clothing', {
        mask = skin_options:createCategory('mask'),
        upper_body = skin_options:createCategory('upper_body'),
        lower_body = skin_options:createCategory('lower_body'),
        bag = skin_options:createCategory('bag'),
        shoe = skin_options:createCategory('shoe'),
        chain = skin_options:createCategory('chain'),
        accessory = skin_options:createCategory('accessory'),
        body_armor = skin_options:createCategory('body_armor'),
        badge = skin_options:createCategory('badge'),
        overlay = skin_options:createCategory('overlay')
    })

    --- Clothing cached values
    local cachedValues = {
        mask = GetPedDrawableVariation(ped, 1),
        upper_body = GetPedDrawableVariation(ped, 3),
        lower_body = GetPedDrawableVariation(ped, 4),
        bag = GetPedDrawableVariation(ped, 5),
        shoe = GetPedDrawableVariation(ped, 6),
        chain = GetPedDrawableVariation(ped, 7),
        accessory = GetPedDrawableVariation(ped, 8),
        body_armor = GetPedDrawableVariation(ped, 9),
        badge = GetPedDrawableVariation(ped, 10),
        overlay = GetPedDrawableVariation(ped, 11)
    }

    --- #clothing -> mask
    skin_options.clothing.mask:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 1), cachedValues.mask)
    skin_options.clothing.mask:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 1, cachedValues.mask), GetPedTextureVariation(ped, 1))
    --- #clothing -> upper_body
    skin_options.clothing.upper_body:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 3), cachedValues.upper_body)
    skin_options.clothing.upper_body:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 3, cachedValues.upper_body), GetPedTextureVariation(ped, 3))
    --- #clothing -> lower_body
    skin_options.clothing.lower_body:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 4), cachedValues.lower_body)
    skin_options.clothing.lower_body:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 4, cachedValues.lower_body), GetPedTextureVariation(ped, 4))
    --- #clothing -> bag
    skin_options.clothing.bag:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 5), cachedValues.bag)
    skin_options.clothing.bag:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 5, cachedValues.bag), GetPedTextureVariation(ped, 5))
    --- #clothing -> shoe
    skin_options.clothing.shoe:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 6), cachedValues.shoe)
    skin_options.clothing.shoe:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 6, cachedValues.shoe), GetPedTextureVariation(ped, 6))
    --- #clothing -> chain
    skin_options.clothing.chain:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 7), cachedValues.chain)
    skin_options.clothing.chain:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 7, cachedValues.chain), GetPedTextureVariation(ped, 7))
    --- #clothing -> accessory
    skin_options.clothing.accessory:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 8), cachedValues.accessory)
    skin_options.clothing.accessory:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 8, cachedValues.accessory), GetPedTextureVariation(ped, 8))
    --- #clothing -> body_armor
    skin_options.clothing.body_armor:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 9), cachedValues.body_armor)
    skin_options.clothing.body_armor:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 9, cachedValues.body_armor), GetPedTextureVariation(ped, 9))
    --- #clothing -> badge
    skin_options.clothing.badge:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 10), cachedValues.badge)
    skin_options.clothing.badge:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 10, cachedValues.badge), GetPedTextureVariation(ped, 10))
    --- #clothing -> overlay
    skin_options.clothing.overlay:addOption('style', 0, GetNumberOfPedDrawableVariations(ped, 11), cachedValues.overlay)
    skin_options.clothing.overlay:addOption('variant', 0, GetNumberOfPedTextureVariations(ped, 11, cachedValues.overlay), GetPedTextureVariation(ped, 11))
    --- #clothing

    --- #props
    skin_options:set('props', {
        hats = skin_options:createCategory('hats'),
        glasses = skin_options:createCategory('glasses'),
        misc = skin_options:createCategory('misc'),
        watches = skin_options:createCategory('watches'),
        bracelets = skin_options:createCategory('bracelets')
    })

    --- Clothing cached values
    local cachedPropsValues = {
        hats = GetPedPropIndex(ped, 0),
        glasses = GetPedPropIndex(ped, 1),
        misc = GetPedPropIndex(ped, 2),
        watches = GetPedPropIndex(ped, 6),
        bracelets = GetPedPropIndex(ped, 7)
    }

    --- #props -> hats
    skin_options.props.hats:addOption('style', -1, GetNumberOfPedPropDrawableVariations(ped, 0), cachedPropsValues.hats)
    skin_options.props.hats:addOption('variant', 0, GetNumberOfPedPropTextureVariations(ped, 0, cachedPropsValues.hats), GetPedPropTextureIndex(ped, 0))
    --- #props -> glasses
    skin_options.props.glasses:addOption('style', -1, GetNumberOfPedPropDrawableVariations(ped, 1), cachedPropsValues.glasses)
    skin_options.props.glasses:addOption('variant', 0, GetNumberOfPedPropTextureVariations(ped, 1, cachedPropsValues.glasses), GetPedPropTextureIndex(ped, 1))
    --- #props -> misc
    skin_options.props.misc:addOption('style', -1, GetNumberOfPedPropDrawableVariations(ped, 2), cachedPropsValues.misc)
    skin_options.props.misc:addOption('variant', 0, GetNumberOfPedPropTextureVariations(ped, 2, cachedPropsValues.misc), GetPedPropTextureIndex(ped, 2))
    --- #props -> watches
    skin_options.props.watches:addOption('style', -1, GetNumberOfPedPropDrawableVariations(ped, 6), cachedPropsValues.watches)
    skin_options.props.watches:addOption('variant', 0, GetNumberOfPedPropTextureVariations(ped, 6, cachedPropsValues.watches), GetPedPropTextureIndex(ped, 6))
    --- #props -> bracelets
    skin_options.props.bracelets:addOption('style', -1, GetNumberOfPedPropDrawableVariations(ped, 7), cachedPropsValues.bracelets)
    skin_options.props.bracelets:addOption('variant', 0, GetNumberOfPedPropTextureVariations(ped, 7, cachedPropsValues.bracelets), GetPedPropTextureIndex(ped, 7))
    --- #props

    --- Update index references
    function skin_options:updateRefs()
        --- #inheritance
        for key, inheritance_option in pairs((self.inheritance or {}).options or {}) do
            self.options[inheritance_option.index] = self.inheritance.options[key]
        end
        --- #inheritance

        --- #appearance
        for categoryKey, appearance_category in pairs(self.appearance or {}) do
            for key, category_option in pairs(appearance_category.options or {}) do
                self.options[category_option.index] = self.appearance[categoryKey].options[key]
            end
        end
        --- #appearance

        --- #clothing
        for categoryKey, clothing_category in pairs(self.clothing or {}) do
            for key, category_option in pairs(clothing_category.options or {}) do
                self.options[category_option.index] = self.clothing[categoryKey].options[key]
            end
        end
        --- #clothing

        --- #props
        for categoryKey, prop_category in pairs(self.props or {}) do
            for key, category_option in pairs(prop_category.options or {}) do
                self.options[category_option.index] = self.props[categoryKey].options[key]
            end
        end
        --- #props
    end

    --- Returns if key matches pattern
    --- @param key string Given input key
    --- @param pattern string Pattern to check for
    --- @return boolean `true` if matches, otherwise `false`
    function skin_options:keyMatch(key, pattern)
        if (type(pattern) == 'table') then
            for _, ptrn in pairs(pattern) do
                if (string.match(key, ptrn .. '%..*') ~= nil) then
                    return true
                end
            end

            return false
        end

        return string.match(key, pattern .. '%..*') ~= nil
    end

    --- Returns if key matches pattern
    --- @param key string Given input key
    --- @param pattern string Pattern to check for
    --- @return string|nul Results from match
    function skin_options:getKey(key, pattern)
        if (type(pattern) == 'table') then
            for inx, ptrn in pairs(pattern) do
                local result = string.match(key, ptrn .. '%..*')

                if (result ~= nil) then
                    return result, inx
                end
            end

            return nil, 0
        end

        return string.match(key, pattern .. '%..*'), 0
    end

    --- Update the ped
    function skin_options:triggerUpdate(key)
        key = corev:ensure(key, 'none')

        --- local key table for code reuse and better readability | #apperaance
        local apperaanceKeys = {
            [1]  = 'blemishes', [2]  = 'beard',          [3]  = 'eyebrows',   [4]  = 'ageing',
            [5]  = 'makeup',    [6]  = 'blush',          [7]  = 'complexion', [8]  = 'sun_damage',
            [9]  = 'lipstick',  [10] = 'moles_freckles', [11] = 'chest_hair', [12] = 'body_blemishes',
            [13] = 'add_body_blemishes'
        }

        --- local key table for code reuse and better readability | #clothing
        local clothingKeys = {
            [1] = 'mask',       [2]  = 'not_used', [3]  = 'upper_body', [4] = 'lower_body',
            [5] = 'bag',        [6]  = 'shoe',     [7]  = 'chain',      [8] = 'accessory',
            [9] = 'body_armor', [10] = 'badge',    [11] = 'overlay'
        }

        --- local key table for code reuse and better readability | #clothing
        local propKeys = {
            [1] = 'hats',       [2]  = 'glasses',  [3]  = 'misc',   [7]  = 'watches',
            [8] = 'bracelets'
        }

        if (self:keyMatch(key, 'inheritance')) then
            skin_funcs:updateInheritance(self)
        elseif (self:keyMatch(key, 'hair')) then
            skin_funcs:updateAppearanceHair(self)
        elseif (self:keyMatch(key, apperaanceKeys)) then
            local apperaanceKey, keyIndex = self:getKey(key, apperaanceKeys)

            if (apperaanceKey ~= nil) then
                apperaanceKey = corev:split(apperaanceKey, '.')[1]

                skin_funcs:updateAppearance(self, apperaanceKey, keyIndex)
            end
        elseif (self:keyMatch(key, clothingKeys)) then
            local clothingKey, keyIndex = self:getKey(key, clothingKeys)

            if (clothingKey ~= nil) then
                clothingKey = corev:split(clothingKey, '.')[1]

                skin_funcs:updateClothing(self, clothingKey, keyIndex)
            end
        elseif (self:keyMatch(key, propKeys)) then
            local propKey, keyIndex = self:getKey(key, propKeys)

            if (propKey ~= nil) then
                propKey = corev:split(propKey, '.')[1]

                skin_funcs:updateProp(self, propKey, keyIndex - 1)
            end
        end
    end

    --- Update a skin option
    function skin_options:updateValue(key, value, execute)
        local option = self:getOption(key)

        if (option == nil) then return end

        value = corev:ensure(value, 0)
        execute = corev:ensure(execute, false)

        if (option.min >= value) then
            value = option.min
        elseif (option.max <= value) then
            value = option.max
        end

        if (option.min <= value and option.max >= value) then
            option.value = value
        end

        if (execute) then
            self:triggerUpdate(option.name)
        end
    end

    --- Update index references
    skin_options:updateRefs()

    return skin_options
end

Citizen.CreateThread(function()
    local playerPed = PlayerPedId()
    local skin = GeneratePedSkin(playerPed)
    local testSkin = {0,0,0,0,31,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,21,0,19,0,45,0,10,0,0,0,21,2,0,0,0,0,4,0,25,1,5,0,-1,-1,-1,-1,-1,-1}

    for idx, vlu in pairs(testSkin) do
        skin:updateValue(idx, vlu, true)
    end

    print(json.encode(skin:toTable()))
end)