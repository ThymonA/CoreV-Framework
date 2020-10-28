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
const overlays = require('./data/overlays.json');
const fs = require('fs-extra');

import * as json2lua from 'json2lua';
import { resolve } from 'path';
import { formatText, WriteMode } from 'lua-fmt';

type Dictionary<K extends string, T> = Partial<Record<K, T>>

enum TattooZone {
    ZONE_TORSO = 0,
    ZONE_HEAD = 1,
    ZONE_LEFT_ARM = 2,
    ZONE_RIGHT_ARM = 3,
    ZONE_LEFT_LEG = 4,
    ZONE_RIGHT_LEG = 5,
    ZONE_UNKNOWN = 6,
    ZONE_NONE = 7
}

class Tattoo {
    gender: number = 0;
    name: string = '';
    collectionName: string = '';
    zoneId: TattooZone = 7;
    type: string = '';

    constructor(gender: number, name: string, collectionName: string, zoneId: TattooZone, type: string) {
        this.gender = gender;
        this.name = name;
        this.collectionName = collectionName;
        this.zoneId = zoneId;
        this.type = type;
    }
}

class ExportCollection {
    TORSO: Dictionary<string, string[]> = {};
    HEAD: Dictionary<string, string[]> = {};
    LEFT_ARM: Dictionary<string, string[]> = {};
    RIGHT_ARM: Dictionary<string, string[]> = {};
    LEFT_LEG: Dictionary<string, string[]> = {};
    RIGHT_LEG: Dictionary<string, string[]> = {};
    BADGES: Dictionary<string, string[]> = {};
}

const maleObject = new ExportCollection();
const femaleObject = new ExportCollection();

overlays.forEach((element) => {
    const tattoo = element as Tattoo

    if (!(!tattoo.name || 0 === tattoo.name.length)) {
        if (tattoo.type == 'TYPE_TATTOO' && !tattoo.name.toLowerCase().includes('hair_')) {
            switch(tattoo.zoneId)
            {
                case TattooZone.ZONE_TORSO:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        if (maleObject.TORSO[tattoo.collectionName] == null || typeof maleObject.TORSO[tattoo.collectionName] == 'undefined') {
                            maleObject.TORSO[tattoo.collectionName] = [];
                        }

                        maleObject.TORSO[tattoo.collectionName].push(tattoo.name);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        if (femaleObject.TORSO[tattoo.collectionName] == null || typeof femaleObject.TORSO[tattoo.collectionName] == 'undefined') {
                            femaleObject.TORSO[tattoo.collectionName] = [];
                        }

                        femaleObject.TORSO[tattoo.collectionName].push(tattoo.name);
                    }
                    break;
                case TattooZone.ZONE_HEAD:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        if (maleObject.HEAD[tattoo.collectionName] == null || typeof maleObject.HEAD[tattoo.collectionName] == 'undefined') {
                            maleObject.HEAD[tattoo.collectionName] = [];
                        }

                        maleObject.HEAD[tattoo.collectionName].push(tattoo.name);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        if (femaleObject.HEAD[tattoo.collectionName] == null || typeof femaleObject.HEAD[tattoo.collectionName] == 'undefined') {
                            femaleObject.HEAD[tattoo.collectionName] = [];
                        }

                        femaleObject.HEAD[tattoo.collectionName].push(tattoo.name);
                    }
                    break;
                case TattooZone.ZONE_LEFT_ARM:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        if (maleObject.LEFT_ARM[tattoo.collectionName] == null || typeof maleObject.LEFT_ARM[tattoo.collectionName] == 'undefined') {
                            maleObject.LEFT_ARM[tattoo.collectionName] = [];
                        }

                        maleObject.LEFT_ARM[tattoo.collectionName].push(tattoo.name);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        if (femaleObject.LEFT_ARM[tattoo.collectionName] == null || typeof femaleObject.LEFT_ARM[tattoo.collectionName] == 'undefined') {
                            femaleObject.LEFT_ARM[tattoo.collectionName] = [];
                        }

                        femaleObject.LEFT_ARM[tattoo.collectionName].push(tattoo.name);
                    }
                    break;
                case TattooZone.ZONE_RIGHT_ARM:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        if (maleObject.RIGHT_ARM[tattoo.collectionName] == null || typeof maleObject.RIGHT_ARM[tattoo.collectionName] == 'undefined') {
                            maleObject.RIGHT_ARM[tattoo.collectionName] = [];
                        }

                        maleObject.RIGHT_ARM[tattoo.collectionName].push(tattoo.name);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        if (femaleObject.RIGHT_ARM[tattoo.collectionName] == null || typeof femaleObject.RIGHT_ARM[tattoo.collectionName] == 'undefined') {
                            femaleObject.RIGHT_ARM[tattoo.collectionName] = [];
                        }

                        femaleObject.RIGHT_ARM[tattoo.collectionName].push(tattoo.name);
                    }
                    break;
                case TattooZone.ZONE_LEFT_LEG:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        if (maleObject.LEFT_LEG[tattoo.collectionName] == null || typeof maleObject.LEFT_LEG[tattoo.collectionName] == 'undefined') {
                            maleObject.LEFT_LEG[tattoo.collectionName] = [];
                        }

                        maleObject.LEFT_LEG[tattoo.collectionName].push(tattoo.name);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        if (femaleObject.LEFT_LEG[tattoo.collectionName] == null || typeof femaleObject.LEFT_LEG[tattoo.collectionName] == 'undefined') {
                            femaleObject.LEFT_LEG[tattoo.collectionName] = [];
                        }

                        femaleObject.LEFT_LEG[tattoo.collectionName].push(tattoo.name);
                    }
                    break;
                case TattooZone.ZONE_RIGHT_LEG:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        if (maleObject.RIGHT_LEG[tattoo.collectionName] == null || typeof maleObject.RIGHT_LEG[tattoo.collectionName] == 'undefined') {
                            maleObject.RIGHT_LEG[tattoo.collectionName] = [];
                        }

                        maleObject.RIGHT_LEG[tattoo.collectionName].push(tattoo.name);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        if (femaleObject.RIGHT_LEG[tattoo.collectionName] == null || typeof femaleObject.RIGHT_LEG[tattoo.collectionName] == 'undefined') {
                            femaleObject.RIGHT_LEG[tattoo.collectionName] = [];
                        }

                        femaleObject.RIGHT_LEG[tattoo.collectionName].push(tattoo.name);
                    }
                    break;
                default:
                    break;
            }
        } else if (tattoo.type == 'TYPE_BADGE' && !tattoo.name.toLowerCase().includes('hair_')) {
            if (tattoo.gender == 0 || tattoo.gender == 2)
            {
                if (maleObject.BADGES[tattoo.collectionName] == null || typeof maleObject.BADGES[tattoo.collectionName] == 'undefined') {
                    maleObject.BADGES[tattoo.collectionName] = [];
                }

                maleObject.BADGES[tattoo.collectionName].push(tattoo.name);
            }
            if (tattoo.gender == 1 || tattoo.gender == 2)
            {
                if (femaleObject.BADGES[tattoo.collectionName] == null || typeof femaleObject.BADGES[tattoo.collectionName] == 'undefined') {
                    femaleObject.BADGES[tattoo.collectionName] = [];
                }

                femaleObject.BADGES[tattoo.collectionName].push(tattoo.name);
            }
        } 
    }
});

const luaDataMale = json2lua.fromObject(maleObject);
const luaDataFemale = json2lua.fromObject(femaleObject);
const export_directory = resolve(`${__dirname}/exports`);

if (!fs.existsSync(export_directory)) { fs.mkdirSync(export_directory, { recursive: true }); }

fs.writeFileSync(resolve(`${export_directory}/tattoos_male.lua`), formatText('return ' + luaDataMale, {
    useTabs: true,
    quotemark: 'single',
    writeMode: WriteMode.Diff,
    linebreakMultipleAssignments: true
}));

fs.writeFileSync(resolve(`${export_directory}/tattoos_female.lua`), formatText('return ' + luaDataFemale, {
    useTabs: true,
    quotemark: 'single',
    writeMode: WriteMode.Diff,
    linebreakMultipleAssignments: true
}));