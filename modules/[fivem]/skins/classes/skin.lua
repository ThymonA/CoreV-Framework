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
function skins:loadSkin(playerPed, model, values)
    --- Some checks in order to let everthing run fine
    if (playerPed == nil) then playerPed = PlayerPedId() end
    if (model == nil or type(model) ~= 'string') then model = 'mp_m_freemode_01' end
    if (values == nil) then values = {} end
    if (type(values) ~= 'table') then values = {} end

    --- Create a skin object
    local skin = class('skin')

    --- Set default ped variation
    SetPedComponentVariation(playerPed, 3, 15, 0, 0)
    SetPedComponentVariation(playerPed, 8, 15, 0, 0)
    SetPedComponentVariation(playerPed, 11, 15, 0, 0)

    --- Set default skin values
    skin:set {
        drawableVariations = {},
        propVariations = {},
        options = {
            colors = {},
            hairs = {},
            blemishes = {},
            beards = {},
            eyebrows = {},
            ageings = {},
            makeups = {},
            blushes = {},
            complexions = {},
            sunDamages = {},
            lipsticks = {},
            molesFreckles = {},
            chestHairs = {},
            bodyBlemishes = {},
            eyeColors = {},
            clothingMasks = {},
            clothingMasksTexture = {},
            clothingUpperBody = {},
            clothingUpperBodyTexture = {},
            clothingLowerBody = {},
            clothingLowerBodyTexture = {},
            clothingBagsParachutes = {},
            clothingBagsParachutesTexture = {},
            clothingShoes = {},
            clothingShoesTexture = {},
            clothingScarfsChains = {},
            clothingScarfsChainsTexture = {},
            clothingShirtAccessory = {},
            clothingShirtAccessoryTexture = {},
            clothingBodyArmor = {},
            clothingBodyArmorTexture = {},
            clothingBagsesLogos = {},
            clothingBagsesLogosTexture = {},
            clothingShirtOverlayJackets = {},
            clothingShirtOverlayJacketsTexture = {}
        },
        modelHash = GetHashKey(model)
    }

    --- Change ped if model don't match
    if (GetEntityModel(playerPed) ~= skin.modelHash) then
        RequestModel(skin.modelHash)

        repeat Wait(0) until HasModelLoaded(skin.modelHash)

        if (PlayerPedId() == playerPed) then
            SetPlayerModel(PlayerId(), skin.modelHash)
        end

        SetPedDefaultComponentVariation(skin.modelHash)
        SetModelAsNoLongerNeeded(skin.modelHash)
    end

    --- Set default values for
    skin:set {
        values = {
            hair = {
                style = (values.hair or {}).style or values['hair:style'] or GetPedDrawableVariation(playerPed, 2),
                color = (values.hair or {}).color or values['hair:color'] or 0,
                hightlightColor = (values.hair or {}).hightlightColor or values['hair:hightlightColor'] or 0
            },
            blemish = {
                style = (values.blemish or {}).style or values['blemish:style'] or 0,
                opacity = (values.blemish or {}).opacity or values['blemish:opacity'] or 0.0
            },
            beard = {
                style = (values.beard or {}).style or values['beard:style'] or 0,
                color = (values.beard or {}).color or values['beard:color'] or 0,
                opacity = (values.beard or {}).opacity or values['beard:opacity'] or 0
            },
            eyebrow = {
                style = (values.eyebrow or {}).style or values['eyebrow:style'] or 0,
                color = (values.eyebrow or {}).color or values['eyebrow:color'] or 0,
                opacity = (values.eyebrow or {}).opacity or values['eyebrow:opacity'] or 0
            },
            ageing = {
                style = (values.ageing or {}).style or values['ageing:style'] or 0,
                opacity = (values.ageing or {}).opacity or values['ageing:opacity'] or 0
            },
            makeup = {
                style = (values.makeup or {}).style or values['makeup:style'] or 0,
                color = (values.makeup or {}).color or values['makeup:color'] or 0,
                opacity = (values.makeup or {}).opacity or values['makeup:opacity'] or 0
            },
            blush = {
                style = (values.blush or {}).style or values['blush:style'] or 0,
                color = (values.blush or {}).color or values['blush:color'] or 0,
                opacity = (values.blush or {}).opacity or values['blush:opacity'] or 0
            },
            complexion = {
                style = (values.complexion or {}).style or values['complexion:style'] or 0,
                opacity = (values.complexion or {}).opacity or values['complexion:opacity'] or 0
            },
            sun_damage = {
                style = (values.sun_damage or {}).style or values['sun_damage:style'] or 0,
                opacity = (values.sun_damage or {}).opacity or values['sun_damage:opacity'] or 0
            },
            lipstick = {
                style = (values.lipstick or {}).style or values['lipstick:style'] or 0,
                color = (values.lipstick or {}).color or values['lipstick:color'] or 0,
                opacity = (values.lipstick or {}).opacity or values['lipstick:opacity'] or 0
            },
            mole_freckle = {
                style = (values.mole_freckle or {}).style or values['mole_freckle:style'] or 0,
                opacity = (values.mole_freckle or {}).opacity or values['mole_freckle:opacity'] or 0
            },
            chest_hair = {
                style = (values.chest_hair or {}).style or values['chest_hair:style'] or 0,
                color = (values.chest_hair or {}).color or values['chest_hair:color'] or 0,
                opacity = (values.chest_hair or {}).opacity or values['chest_hair:opacity'] or 0
            },
            body_blemish = {
                style = (values.body_blemish or {}).style or values['body_blemish:style'] or 0,
                opacity = (values.body_blemish or {}).opacity or values['body_blemish:opacity'] or 0
            },
            clothing = {
                unused_head = 0,
                unused_head_texture = 0,
                masks = 0,
                masks_texture = 0,
                unused_hair = 0,
                unused_hair_texture = 0,
                upper_body = 0,
                upper_body_texture = 0,
                lower_body = 0,
                lower_body_texture = 0,
                bags_parachutes = 0,
                bags_parachutes_texture = 0,
                shoes = 0,
                shoes_texture = 0,
                scarfs_chains = 0,
                scarfs_chains_texture = 0,
                shirt_accessory = 0,
                shirt_accessory_texture = 0,
                body_armor = 0,
                body_armor_texture = 0,
                badges_logos = 0,
                badges_logos_texture = 0,
                shirt_overlay_jackets = 0,
                shirt_overlay_jackets_texture = 0
            },
            eyeColor = values.eyeColor or values['eyeColor'] or 0
        }
    }

    --- Returns current skin as table
    --- @param ignoreDefaultOrNull boolean|number Ignore default values
    function skin:getSkinData(ignoreDefaultOrNull)
        if (ignoreDefaultOrNull == nil) then ignoreDefaultOrNull = false end
        if (type(ignoreDefaultOrNull) ~= 'boolean') then ignoreDefaultOrNull = tonumber(ignoreDefaultOrNull) end
        if (type(ignoreDefaultOrNull) == 'number') then ignoreDefaultOrNull = ignoreDefaultOrNull == 1 end

        local result = {}
        local currentSkin = self.values or {}

        for category, value in pairs(currentSkin) do
            local categoryName = tostring(category or 'unknown')

            if (type(value) == 'table') then
                for option, optionValue in pairs(value or {}) do
                    local optionName = tostring(option or 'unknown')
                    local addOptionToResult = not ignoreDefaultOrNull

                    if (not addOptionToResult) then
                        if (type(optionValue) == 'number' and optionValue > 0) then
                            addOptionToResult = true
                        elseif (type(optionValue) == 'table') then
                            addOptionToResult = true
                        elseif (type(optionValue) == 'boolean' and optionValue) then
                            addOptionToResult = true
                        end
                    end

                    if (addOptionToResult) then
                        result[('%s:%s'):format(categoryName, optionName)] = optionValue
                    end
                end
            else
                local addOptionToResult = not ignoreDefaultOrNull

                if (not addOptionToResult) then
                    if (type(value) == 'number' and value > 0) then
                        addOptionToResult = true
                    elseif (type(value) == 'boolean' and value) then
                        addOptionToResult = true
                    end
                end

                if (addOptionToResult) then
                    result[categoryName] = value
                end
            end
        end

        return result
    end

    for i = 0, GetNumHairColors(), 1 do
        table.insert(skin.options.colors, { value = i, label = _(CR(), 'skins', 'color_label', (i + 1)) })
    end

    for i = 0, GetNumberOfPedDrawableVariations(playerPed, 2), 1 do
        table.insert(skin.options.hairs, { value = i, label = _(CR(), 'skins', 'hair_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(0), 1 do
        table.insert(skin.options.blemishes, { value = i, label = _(CR(), 'skins', 'blemishes_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(1), 1 do
        table.insert(skin.options.beards, { value = i, label = _(CR(), 'skins', 'beard_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(2), 1 do
        table.insert(skin.options.eyebrows, { value = i, label = _(CR(), 'skins', 'eyebrow_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(3), 1 do
        table.insert(skin.options.ageings, { value = i, label = _(CR(), 'skins', 'ageing_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(4), 1 do
        table.insert(skin.options.makeups, { value = i, label = _(CR(), 'skins', 'makeup_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(5), 1 do
        table.insert(skin.options.blushes, { value = i, label = _(CR(), 'skins', 'blush_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(6), 1 do
        table.insert(skin.options.complexions, { value = i, label = _(CR(), 'skins', 'complexion_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(7), 1 do
        table.insert(skin.options.sunDamages, { value = i, label = _(CR(), 'skins', 'sun_damage_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(8), 1 do
        table.insert(skin.options.lipsticks, { value = i, label = _(CR(), 'skins', 'lipstick_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(9), 1 do
        table.insert(skin.options.molesFreckles, { value = i, label = _(CR(), 'skins', 'moles_freckle_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(10), 1 do
        table.insert(skin.options.chestHairs, { value = i, label = _(CR(), 'skins', 'chest_hair_style_label', (i + 1)) })
    end

    for i = 0, GetNumHeadOverlayValues(11), 1 do
        table.insert(skin.options.bodyBlemishes, { value = i, label = _(CR(), 'skins', 'body_blemish_style_label', (i + 1)) })
    end

    for i = 0, 32, 1 do
        table.insert(skin.options.eyeColors, { value = i, label = _(CR(), 'skins', 'eye_color_label', (i + 1)) })
    end

    for i = 1, #skins.clothingOptions, 1 do
        if (i ~= 1 and i ~= 3) then
            local clothingOption = skins.clothingOptions[i] or { label = 'Unknown', key = 'unknown' }
            local value = (values.clothing or {})[clothingOption.key or 'unknown'] or values[('clothing:%s'):format(clothingOption.key or 'unknown')] or 0
            local valueTexture = (values.clothing or {})[('%s_texture'):format(clothingOption.key or 'unknown')] or values[('clothing:%s_texture'):format(clothingOption.key or 'unknown')] or 0

            local index = value ~= 255 and value or GetPedDrawableVariation(playerPed, i)
            local textureIndex = valueTexture ~= 255 and valueTexture or GetPedTextureVariation(playerPed, i)

            local maxDrawables = GetNumberOfPedDrawableVariations(playerPed, i)
            local maxTextures = GetNumberOfPedTextureVariations(playerPed, i, index)

            for x = 1, maxDrawables, 1 do
                if (i == 2) then
                    skin.values.clothing.masks = index

                    table.insert(skin.options.clothingMasks, { value = x, label = ('#%s'):format(i) })
                elseif (i == 4) then
                    skin.values.clothing.upper_body = index

                    table.insert(skin.options.clothingUpperBody, { value = x, label = ('#%s'):format(i) })
                elseif (i == 5) then
                    skin.values.clothing.lower_body = index

                    table.insert(skin.options.clothingLowerBody, { value = x, label = ('#%s'):format(i) })
                elseif (i == 6) then
                    skin.values.clothing.bags_parachutes = index

                    table.insert(skin.options.clothingBagsParachutes, { value = x, label = ('#%s'):format(i) })
                elseif (i == 7) then
                    skin.values.clothing.shoes = index

                    table.insert(skin.options.clothingShoes, { value = x, label = ('#%s'):format(i) })
                elseif (i == 8) then
                    skin.values.clothing.scarfs_chains = index

                    table.insert(skin.options.clothingScarfsChains, { value = x, label = ('#%s'):format(i) })
                elseif (i == 9) then
                    skin.values.clothing.shirt_accessory = index

                    table.insert(skin.options.clothingShirtAccessory, { value = x, label = ('#%s'):format(i) })
                elseif (i == 10) then
                    skin.values.clothing.body_armor = index

                    table.insert(skin.options.clothingBodyArmor, { value = x, label = ('#%s'):format(i) })
                elseif (i == 11) then
                    skin.values.clothing.badges_logos = index

                    table.insert(skin.options.clothingBagsesLogos, { value = x, label = ('#%s'):format(i) })
                elseif (i == 12) then
                    skin.values.clothing.shirt_overlay_jackets = index

                    table.insert(skin.options.clothingShirtOverlayJackets, { value = x, label = ('#%s'):format(i) })
                end
            end

            for x = 1, maxTextures, 1 do
                if (i == 2) then
                    skin.values.clothing.masks_texture = textureIndex

                    table.insert(skin.options.clothingMasksTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 4) then
                    skin.values.clothing.upper_body_texture = textureIndex

                    table.insert(skin.options.clothingUpperBodyTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 5) then
                    skin.values.clothing.lower_body_texture = textureIndex

                    table.insert(skin.options.clothingLowerBodyTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 6) then
                    skin.values.clothing.bags_parachutes_texture = textureIndex

                    table.insert(skin.options.clothingBagsParachutesTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 7) then
                    skin.values.clothing.shoes_texture = textureIndex

                    table.insert(skin.options.clothingShoesTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 8) then
                    skin.values.clothing.scarfs_chains_texture = textureIndex

                    table.insert(skin.options.clothingScarfsChainsTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 9) then
                    skin.values.clothing.shirt_accessory_texture = textureIndex

                    table.insert(skin.options.clothingShirtAccessoryTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 10) then
                    skin.values.clothing.body_armor_texture = textureIndex

                    table.insert(skin.options.clothingBodyArmorTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 11) then
                    skin.values.clothing.badges_logos_texture = textureIndex

                    table.insert(skin.options.clothingBagsesLogosTexture, { value = x, label = ('#%s'):format(i) })
                elseif (i == 12) then
                    skin.values.clothing.shirt_overlay_jackets_texture = textureIndex

                    table.insert(skin.options.clothingShirtOverlayJacketsTexture, { value = x, label = ('#%s'):format(i) })
                end
            end
        end
    end

    --- Update current playerPed
    SetPedHeadOverlay(playerPed, 0, skin.values.blemish.style, skin.values.blemish.opacity)
    SetPedHeadOverlay(playerPed, 1, skin.values.beard.style, skin.values.beard.opacity)
    SetPedHeadOverlayColor(playerPed, 1, 1, skin.values.beard.color, skin.values.beard.color)
    SetPedHeadOverlay(playerPed, 2, skin.values.eyebrow.style, skin.values.eyebrow.opacity)
    SetPedHeadOverlayColor(playerPed, 2, 1, skin.values.eyebrow.color, skin.values.eyebrow.color)
    SetPedHeadOverlay(playerPed, 3, skin.values.ageing.style, skin.values.ageing.opacity)
    SetPedHeadOverlay(playerPed, 4, skin.values.makeup.style, skin.values.makeup.opacity)
    SetPedHeadOverlayColor(playerPed, 4, 1, skin.values.makeup.color, skin.values.makeup.color)
    SetPedHeadOverlay(playerPed, 5, skin.values.blush.style, skin.values.blush.opacity)
    SetPedHeadOverlayColor(playerPed, 5, 1, skin.values.blush.color, skin.values.blush.color)
    SetPedHeadOverlay(playerPed, 6, skin.values.complexion.style, skin.values.complexion.opacity)
    SetPedHeadOverlay(playerPed, 7, skin.values.sun_damage.style, skin.values.sun_damage.opacity)
    SetPedHeadOverlay(playerPed, 8, skin.values.lipstick.style, skin.values.lipstick.opacity)
    SetPedHeadOverlayColor(playerPed, 8, 1, skin.values.lipstick.color, skin.values.lipstick.color)
    SetPedHeadOverlay(playerPed, 9, skin.values.mole_freckle.style, skin.values.mole_freckle.opacity)
    SetPedHeadOverlay(playerPed, 10, skin.values.chest_hair.style, skin.values.chest_hair.opacity)
    SetPedHeadOverlayColor(playerPed, 10, 1, skin.values.chest_hair.color, skin.values.chest_hair.color)
    SetPedHeadOverlay(playerPed, 11, skin.values.body_blemish.style, skin.values.body_blemish.opacity)
    SetPedEyeColor(playerPed, skin.values.eyeColor)

    for _, clothingOption in pairs(skins.clothingOptions or {}) do
        local value = (((skin or {}).value or {}).clothing or {})[clothingOption.key] or 0
        local valueTexture = (((skin or {}).value or {}).clothing or {})[('%s_texture'):format(clothingOption.key)] or 0

        SetPedComponentVariation(playerPed, clothingOption.index, value, valueTexture, 0)
    end
end