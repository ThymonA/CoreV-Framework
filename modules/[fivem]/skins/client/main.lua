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
local skins = class('skins')

skins:set {
    defaultOpacityOptions = {
        { value = 0, label = '0%' },
        { value = 10, label = '10%' },
        { value = 20, label = '20%' },
        { value = 30, label = '30%' },
        { value = 40, label = '40%' },
        { value = 50, label = '50%' },
        { value = 60, label = '60%' },
        { value = 70, label = '70%' },
        { value = 80, label = '80%' },
        { value = 90, label = '90%' },
        { value = 100, label = '100%' }
    },
    clothingOptions = {
        { label = _(CR(), 'skins', 'unused_head_label'), key = 'unused_head', index = 0 },
        { label = _(CR(), 'skins', 'masks_label'), key = 'masks', index = 1 },
        { label = _(CR(), 'skins', 'unused_hair_label'), key = 'unused_hair', index = 2 },
        { label = _(CR(), 'skins', 'upper_body_label'), key = 'upper_body', index = 3 },
        { label = _(CR(), 'skins', 'lower_body_label'), key = 'lower_body', index = 4 },
        { label = _(CR(), 'skins', 'bags_parachutes_label'), key = 'bags_parachutes', index = 5 },
        { label = _(CR(), 'skins', 'shoes_label'), key = 'shoes', index = 6 },
        { label = _(CR(), 'skins', 'scarfs_chains_label'), key = 'scarfs_chains', index = 7 },
        { label = _(CR(), 'skins', 'shirt_accessory_label'), key = 'shirt_accessory', index = 8 },
        { label = _(CR(), 'skins', 'body_armor_label'), key = 'body_armor', index = 9 },
        { label = _(CR(), 'skins', 'badges_logos_label'), key = 'badges_logos', index = 10 },
        { label = _(CR(), 'skins', 'shirt_overlay_jackets_label'), key = 'shirt_overlay_jackets', index = 11 }
    },
    categories = {
        [1] = {
            label = _(CR(), 'skins', 'inheritance_options_label'),
        }
    }
}