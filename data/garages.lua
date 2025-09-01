---@type table<string,  GarageProperties>
return {
    meeting_point = {
        label = 'Meeting Point Garage',
        coords = vec4(100.5520, -1072.6576, 28.3741, 339.8177),
        radius = 25.0,
        blip = {
            sprite = 357,
            color = 0
        },
        ped = {
            model = 's_m_y_valet_01',
            animation = {
                name = 'WORLD_HUMAN_GUARD_STAND'
            }
        },
        restrictions = {
            playerJob = false,
            vehicleTypes = { 'car', 'bike' }
        },
        spawnpoints = {
            vec4(104.4628, -1078.6284, 28.1924, 338.4127),
            vec4(107.8994, -1079.7924, 28.0178, 339.0255),
            vec4(111.1200, -1081.2393, 28.0152, 338.0091)
        }
    },
    casino = {
        label = 'Casino Garage',
        coords = vec4(886.9645, 0.1737, 77.7650, 151.7120),
        blip = {
            sprite = 357,
            color = 0
        },
        ped = {
            model = 's_m_y_valet_01',
            animation = {
                name = 'WORLD_HUMAN_GUARD_STAND'
            }
        },
        restrictions = {
            playerJob = false,
            vehicleTypes = { 'car', 'bike' }
        },
        spawnpoints = {
            vec4(877.7978, 5.0193, 77.7641, 142.8389),
            vec4(875.2767, 7.2368, 77.7641, 149.9615)
        }
    },
    vespucci = {
        label = 'Vespucci Garage',
        coords = vec4(-1184.7744, -1508.7955, 3.6493, 33.3630),
        blip = {
            sprite = 357,
            color = 0
        },
        ped = {
            model = 's_m_y_valet_01',
            animation = {
                name = 'WORLD_HUMAN_GUARD_STAND'
            }
        },
        restrictions = {
            playerJob = false,
            vehicleTypes = { 'car', 'bike' }
        },
        spawnpoints = {
            vec4(-1191.0238, -1504.2203, 3.3694, 301.6123),
            vec4(-1193.9172, -1500.4117, 3.3678, 317.2433)
        }
    },
    vinewood = {
        label = 'Vinewood Garage',
        coords = vec4(363.3667, 298.2044, 102.8702, 243.2097),
        blip = {
            sprite = 357,
            color = 0
        },
        ped = {
            model = 's_m_y_valet_01',
            animation = {
                name = 'WORLD_HUMAN_GUARD_STAND'
            }
        },
        restrictions = {
            playerJob = false,
            vehicleTypes = { 'car', 'bike' }
        },
        spawnpoints = {
            vec4(375.0969, 295.0489, 102.2764, 166.9049),
            vec4(378.8999, 294.1480, 102.2013, 166.0356)
        }
    },
    mirror_park = {
        label = 'Mirror Park Garage',
        coords = vec4(1037.1626, -763.6642, 56.9930, 238.7022),
        blip = {
            sprite = 357,
            color = 0
        },
        ped = {
            model = 's_m_y_valet_01',
            animation = {
                name = 'WORLD_HUMAN_GUARD_STAND'
            }
        },
        restrictions = {
            playerJob = false,
            vehicleTypes = { 'car', 'bike' }
        },
        spawnpoints = {
            vec4(1047.5332, -774.4517, 57.0184, 88.5148),
            vec4(1047.3967, -778.2010, 57.0097, 77.7319)
        }
    }
}
