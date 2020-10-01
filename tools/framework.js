// ----------------------- [ CoreV ] -----------------------
// -- GitLab: https://git.arens.io/ThymonA/corev-framework/
// -- GitHub: https://github.com/ThymonA/CoreV-Framework/
// -- License: GNU General Public License v3.0
// --          https://choosealicense.com/licenses/gpl-3.0/
// -- Author: Thymon Arens <contact@arens.io>
// -- Name: CoreV
// -- Version: 1.0.0
// -- Description: Custom FiveM Framework
// ----------------------- [ CoreV ] -----------------------

const fs = require('fs');
const json2lua = require('json2lua');
const { formatText, WriteMode } = require('lua-fmt');

const rawWeapons = require('./data/weapons.json');
const rawAmmos = require('./data/ammo.json');
const rawWeaponComponents = require('./data/weapon_components.json');

// Fill those lists
const ammos = {};
const components = {};
const weapons = {};
const groups = {};

// Fill list ammos with nameHash as primary
for(let i = 0; i < rawAmmos.length; i++) {
    const rawAmmo = rawAmmos[i];

    let __nameHash = 'unknown';
    let __hash = 0x0;
    let __max = 0;

    if (typeof rawAmmo != 'undefined') {
        if (typeof rawAmmo.nameHash != 'undefined' && rawAmmo.nameHash != null) { __nameHash = rawAmmo.nameHash; };
        if (typeof rawAmmo.hash != 'undefined' && rawAmmo.hash != null) { __hash = rawAmmo.hash; };
        if (typeof rawAmmo.max != 'undefined' && rawAmmo.max != null) { __max = rawAmmo.max; };

        ammos[__nameHash] = {
            id: __nameHash,
            hash: __hash,
            max: __max,
            name: 'x_(CR(), \'core\', \'' + __nameHash.toLowerCase() + '\')x'
        }
    }
}

// Transform object to lua
const ammoConfigFile = json2lua.fromObject(ammos);

// Fill list components with nameHash as primary
for(let i = 0; i < rawWeaponComponents.length; i++) {
    const rawComponent = rawWeaponComponents[i];

    let __nameHash = 'unknown';
    let __hash = 0x0;
    let __type = 'unknown';
    let __model = 'unknown';
    let __gxtName = 'unknown';
    let __gxtDescription = 'unknown';

    if (typeof rawComponent != 'undefined') {
        if (typeof rawComponent.nameHash != 'undefined' && rawComponent.nameHash != null) { __nameHash = rawComponent.nameHash; };
        if (typeof rawComponent.hash != 'undefined' && rawComponent.hash != null) { __hash = rawComponent.hash; };
        if (typeof rawComponent.type != 'undefined' && rawComponent.type != null) { __type = rawComponent.type; };
        if (typeof rawComponent.model != 'undefined' && rawComponent.model != null) { __model = rawComponent.model; };
        if (typeof rawComponent.gxtName != 'undefined' && rawComponent.gxtName != null) { __gxtName = rawComponent.gxtName; };
        if (typeof rawComponent.gxtDescription != 'undefined' && rawComponent.gxtDescription != null) { __gxtDescription = rawComponent.gxtDescription; };

        components[__nameHash] = {
            id: __nameHash,
            hash: __hash,
            model: __model,
            gxtName: __gxtName,
            gxtDescription: __gxtDescription,
            __type: __type,
            type: 'unknown'
        }

        if (__type == 'CWeaponComponentClipInfo') { 
            components[__nameHash].type = 'clip';

            let __clipSize = 0;

            if (typeof rawComponent.clipSize != 'undefined' && rawComponent.clipSize != null) {
                __clipSize = rawComponent.clipSize
            }

            components[__nameHash].clipSize = __clipSize;
        } else if (__type == 'CWeaponComponentFlashLightInfo') {
            components[__nameHash].type = 'flashlight';
        } else if (__type == 'CWeaponComponentInfo') {
            components[__nameHash].type = 'default';
        } else if (__type == 'CWeaponComponentScopeInfo') {
            components[__nameHash].type = 'scope';
        } else if (__type == 'CWeaponComponentSuppressorInfo') {
            components[__nameHash].type = 'suppressor';
        } else if (__type == 'CWeaponComponentVariantModelInfo') {
            components[__nameHash].type = 'variant';
        } else if (__type == 'CWeaponComponentVariantModelInfo') {
            components[__nameHash].type = 'variant';
        }
    }
}

// Transform object to lua
const componentConfigFile = json2lua.fromObject(components);

const capitalize = (s) => {
    if (typeof s !== 'string') return ''

    return s.charAt(0).toUpperCase() + s.slice(1)
}

// Fill list weapons with nameHash as primary
for(let i = 0; i < rawWeapons.length; i++) {
    const rawWeapon = rawWeapons[i];

    let __nameHash = 'unknown';
    let __hash = 0x0;
    let __clipSize = 0;
    let __group = 'unknown';
    let __model = 'unknown';
    let __ammo = 'unknown';
    let __gxtName = 'unknown';
    let __gxtDescription = 'unknown';
    let __components = [];

    if (typeof rawWeapon != 'undefined') {
        if (typeof rawWeapon.nameHash != 'undefined' && rawWeapon.nameHash != null) { __nameHash = rawWeapon.nameHash; };
        if (typeof rawWeapon.hash != 'undefined' && rawWeapon.hash != null) { __hash = rawWeapon.hash; };
        if (typeof rawWeapon.clipSize != 'undefined' && rawWeapon.clipSize != null) { __clipSize = rawWeapon.clipSize; };
        if (typeof rawWeapon.group != 'undefined' && rawWeapon.group != null) { __group = rawWeapon.group; };
        if (typeof rawWeapon.model != 'undefined' && rawWeapon.model != null) { __model = rawWeapon.model; };
        if (typeof rawWeapon.ammo != 'undefined' && rawWeapon.ammo != null) { __ammo = rawWeapon.ammo; };
        if (typeof rawWeapon.gxtName != 'undefined' && rawWeapon.gxtName != null) { __gxtName = rawWeapon.gxtName; };
        if (typeof rawWeapon.gxtDescription != 'undefined' && rawWeapon.gxtDescription != null) { __gxtDescription = rawWeapon.gxtDescription; };

        if (typeof rawWeapon.components != 'undefined' && rawWeapon.components != null) {
            for(let i2 = 0; i2 < rawWeapon.components.length; i2++) {
                let __components__nameHash = 'unknown';
                let __components__isDefault = false;

                if (typeof rawWeapon.components[i2] != 'undefined' && rawWeapon.components[i2] != null && typeof rawWeapon.components[i2].nameHash != 'undefined' && rawWeapon.components[i2].nameHash != null) { __components__nameHash = rawWeapon.components[i2].nameHash; };
                if (typeof rawWeapon.components[i2] != 'undefined' && rawWeapon.components[i2] != null && typeof rawWeapon.components[i2].isDefault != 'undefined' && rawWeapon.components[i2].isDefault != null) { __components__isDefault = rawWeapon.components[i2].isDefault; };

                let __component = null;

                if (typeof components != 'undefined' && components != null && typeof components[__components__nameHash] != 'undefined' && components[__components__nameHash] != null) { __component = components[__components__nameHash]; };

                if (__component != null) {
                    let __componentObject = {
                        id: __components__nameHash,
                        hash: __component.hash,
                        model: __component.model,
                        gxtName: __component.gxtName,
                        gxtDescription: __component.gxtDescription,
                        __type: __component.__type,
                        type: __component.type,
                        default: __components__isDefault
                    };

                    __components.push(__componentObject);
                }
            }

            let __ammoObject = null;

            if (typeof ammos != 'undefined' && ammos != null && typeof ammos[__ammo] != 'undefined' && ammos[__ammo] != null) { __ammoObject = ammos[__ammo]; };

            let __name = __nameHash.toLowerCase();

            __name = __name.replace('weapon_', '');
            __name = __name.replace('gadget_', '');
            __name = __name.replace('vehicle_', '');

            if (__group == 'unknown' || __group == '' || __group == null || __group == 'NULL') { __group = null; };
            if (__model == 'unknown' || __model == '' || __model == null || __model == 'NULL') { __model = null; };
            
            if (__group != null) { __group = __group.toLowerCase(); }
            if (__group != null) { __group = __group.replace('group_', ''); }

            if (__group != null) {
                const groupName = capitalize(__group)

                if (typeof groups[groupName] != 'undefined' && groups[groupName] != null) {
                    groups[groupName].weapons.push(__nameHash);
                } else {
                    groups[groupName] = { id: __group, weapons: [ __nameHash ], name: 'x_(CR(), \'core\', \'' + __group.toLowerCase() + '\')x' };
                }
            }

            weapons[__name] = {
                id: __nameHash,
                hash: __hash,
                clipSize: __clipSize,
                group: __group,
                model: __model,
                ammo: __ammoObject,
                gxtName: __gxtName,
                gxtDescription: __gxtDescription,
                components: __components,
                hasAttachments: __components != null && __components.length > 0,
                numberOfAttachments: __components != null ? __components.length : 0,
                name: 'x_(CR(), \'core\', \'' + __nameHash.toLowerCase() + '\')x'
            };
        };
    }
}

// Create export directory if not exsits
if (!fs.existsSync(__dirname + '/export')) { fs.mkdirSync(__dirname + '/export'); };

// Transform object to lua
const weaponConfigFile = json2lua.fromObject(weapons);
const groupConfigFile = json2lua.fromObject(groups);

const options = { quotemark: 'single', useTabs: true, linebreakMultipleAssignments: true, lineWidth: 20 };

// Format strings to formatter / pretty lua files 
let formattedWeaponConfigFile = formatText('Config.Weapons = ' + weaponConfigFile, options);
let formatteAmmoConfigFile = formatText('Config.WeaponAmmos = ' + ammoConfigFile, options);
let formatteComponentConfigFile = formatText('Config.WeaponComponents = ' + componentConfigFile, options);
let formatteGroupConfigFile = formatText('Config.WeaponCategories = ' + groupConfigFile, options);

function fixFormatedLua(input) {
    input = input.replace(/"x_\(/g, '_(');
    input = input.replace(/\'x_\(/g, '_(');
    input = input.replace(/\)x"/g, ')');
    input = input.replace(/\)x\'/g, ')');

    input = input.replace(/\['id'\]/g, 'id');
    input = input.replace(/\['hash'\]/g, 'hash');
    input = input.replace(/\['model'\]/g, 'model');
    input = input.replace(/\['gxtName'\]/g, 'gxtName');
    input = input.replace(/\['gxtDescription'\]/g, 'gxtDescription');
    input = input.replace(/\['__type'\]/g, '__type');
    input = input.replace(/\['type'\]/g, 'type');
    input = input.replace(/\['default'\]/g, 'default');
    input = input.replace(/\['clipSize'\]/g, 'clipSize');
    input = input.replace(/\['group'\]/g, 'category');
    input = input.replace(/\['ammo'\]/g, 'ammo');
    input = input.replace(/\['components'\]/g, 'components');
    input = input.replace(/\['hasAttachments'\]/g, 'hasAttachments');
    input = input.replace(/\['numberOfAttachments'\]/g, 'numberOfAttachments');
    input = input.replace(/\['name'\]/g, 'name');
    input = input.replace(/\['max'\]/g, 'max');
    input = input.replace(/\['weapons'\]/g, 'weapons');

    return input
}

// Replace placeholders
formattedWeaponConfigFile = fixFormatedLua(formattedWeaponConfigFile);
formatteAmmoConfigFile = fixFormatedLua(formatteAmmoConfigFile);
formatteComponentConfigFile = fixFormatedLua(formatteComponentConfigFile);
formatteGroupConfigFile = fixFormatedLua(formatteGroupConfigFile);

// Save generated lua files
fs.writeFileSync(__dirname + '/export/weapon_config.lua', formattedWeaponConfigFile);
fs.writeFileSync(__dirname + '/export/weapon_ammo_config.lua', formatteAmmoConfigFile);
fs.writeFileSync(__dirname + '/export/weapon_component_config.lua', formatteComponentConfigFile);
fs.writeFileSync(__dirname + '/export/weapon_category_config.lua', formatteGroupConfigFile);

// Let user know that files has been generated
console.log('FILES GENERATED!!!');