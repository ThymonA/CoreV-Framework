Config.Locks = {
    Doors = {
        --- Office door
        ['POLICE_OFFICE_DOOR'] = {
            Authorized = { Jobs = { 'politie' }, Groups = { } },
            Locked = true,
            Distance = 10,
            LabelPosition = vector3(447.23, -980.03, 31.20),
            Door = {
                Name = 'v_ilev_ph_gendoor002',
                Hash = -1320876379,
                Heading = 180.000,
                Position = vector3(446.57280, -980.01060, 30.83930),
                Rotation = vector3(0.00000, 0.00000, -179.99990),
                ResetPosition = false
            }
        },
        --- Hallway locker room
        ['POLICE_HALLWAY_LOCKER_ROOM'] = {
            Authorized = { Jobs = { 'politie' }, Groups = { } },
            Locked = true,
            Distance = 10,
            LabelPosition = vector3(449.99, -986.42, 31.20),
            Door = {
                Name = 'v_ilev_ph_gendoor004',
                Hash = 1557126584,
                Heading = 89.873,
                Position = vector3(450.10410, -985.73840, 30.83930),
                Rotation = vector3(-0.00001, 0.00000, 89.87250),
                ResetPosition = false
            }
        },
        --- Hallway stairs
        ['POLICE_HALLWAY_STARIS'] = {
            Authorized = { Jobs = { 'politie' }, Groups = { } },
            Locked = true,
            Distance = 10,
            LabelPosition = vector3(444.7, -989.39, 31.20),
            Doors = {
                {
                    Name = 'v_ilev_ph_gendoor005',
                    Hash = 185711165,
                    Heading = 0.000,
                    Position = vector3(446.00790, -989.44540, 30.83930),
                    Rotation = vector3(0.00000, 0.00000, 0.00000),
                    ResetPosition = false
                },
                {
                    Name = 'v_ilev_ph_gendoor005',
                    Hash = 185711165,
                    Heading = 180.000,
                    Position = vector3(443.40780, -989.44540, 30.83930),
                    Rotation = vector3(0.00000, 0.00000, 180.00000),
                    ResetPosition = false
                }
            }
        },
        --- Entrance police station
        ['POLICE_ENTRANCE_STATION'] = {
            Authorized = { Jobs = { 'politie' }, Groups = { } },
            Distance = 10,
            LabelPosition = vector3(434.71, -981.91, 31.20),
            Doors = {
                {
                    Name = 'v_ilev_ph_door01',
                    Hash = 3079744621,
                    Heading = 0.000,
                    Position = vector3(434.7479, -980.6184, 30.83926),
                    Rotation = vector3(0.00000, 0.00000, -89.87250),
                    ResetPosition = false
                },
                {
                    Name = 'v_ilev_ph_door002',
                    Hash = 320433149,
                    Heading = 180.000,
                    Position = vector3(434.7479, -983.2151, 30.83926),
                    Rotation = vector3(0.00000, 0.00000, -89.87250),
                    ResetPosition = false
                }
            }
        }
    }
}