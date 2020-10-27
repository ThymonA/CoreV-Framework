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
const overlays = require('./data/overlays.json')

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

class TattoosCollection {
    TORSO: Tattoo[] = [];
    HEAD: Tattoo[] = [];
    LEFT_ARM: Tattoo[] = [];
    RIGHT_ARM: Tattoo[] = [];
    LEFT_LEG: Tattoo[] = [];
    RIGHT_LEG: Tattoo[] = [];
    BADGES: Tattoo[] = [];
}

const MaleTattoosCollection = new TattoosCollection();
const FemaleTattoosCollection = new TattoosCollection();

overlays.forEach((element) => {
    const tattoo = element as Tattoo

    if (!(!tattoo.name || 0 === tattoo.name.length)) {
        if (tattoo.type == 'TYPE_TATTOO' && !tattoo.name.toLowerCase().includes('hair_')) {
            switch(tattoo.zoneId)
            {
                case TattooZone.ZONE_TORSO:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        MaleTattoosCollection.TORSO.push(tattoo);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        FemaleTattoosCollection.TORSO.push(tattoo);
                    }
                    break;
                case TattooZone.ZONE_HEAD:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        MaleTattoosCollection.HEAD.push(tattoo);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        FemaleTattoosCollection.HEAD.push(tattoo);
                    }
                    break;
                case TattooZone.ZONE_LEFT_ARM:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        MaleTattoosCollection.LEFT_ARM.push(tattoo);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        FemaleTattoosCollection.LEFT_ARM.push(tattoo);
                    }
                    break;
                case TattooZone.ZONE_RIGHT_ARM:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        MaleTattoosCollection.RIGHT_ARM.push(tattoo);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        FemaleTattoosCollection.RIGHT_ARM.push(tattoo);
                    }
                    break;
                case TattooZone.ZONE_LEFT_LEG:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        MaleTattoosCollection.LEFT_LEG.push(tattoo);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        FemaleTattoosCollection.LEFT_LEG.push(tattoo);
                    }
                    break;
                case TattooZone.ZONE_RIGHT_LEG:
                    if (tattoo.gender == 0 || tattoo.gender == 2)
                    {
                        MaleTattoosCollection.RIGHT_LEG.push(tattoo);
                    }
                    if (tattoo.gender == 1 || tattoo.gender == 2)
                    {
                        FemaleTattoosCollection.RIGHT_LEG.push(tattoo);
                    }
                    break;
                default:
                    break;
            }
        } else if (tattoo.type == 'TYPE_BADGE' && !tattoo.name.toLowerCase().includes('hair_')) {
            if (tattoo.gender == 0 || tattoo.gender == 2)
            {
                MaleTattoosCollection.BADGES.push(tattoo);
            }
            if (tattoo.gender == 1 || tattoo.gender == 2)
            {
                FemaleTattoosCollection.BADGES.push(tattoo);
            }
        } 
    }
});

console.log('MaleTattoosCollection.HEAD', MaleTattoosCollection.HEAD.length)
console.log('MaleTattoosCollection.BADGES', MaleTattoosCollection.BADGES.length)
console.log('MaleTattoosCollection.LEFT_ARM', MaleTattoosCollection.LEFT_ARM.length)
console.log('MaleTattoosCollection.LEFT_LEG', MaleTattoosCollection.LEFT_LEG.length)
console.log('MaleTattoosCollection.RIGHT_ARM', MaleTattoosCollection.RIGHT_ARM.length)
console.log('MaleTattoosCollection.RIGHT_LEG', MaleTattoosCollection.RIGHT_LEG.length)
console.log('MaleTattoosCollection.TORSO', MaleTattoosCollection.TORSO.length)