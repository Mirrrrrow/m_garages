return {
    garages = {
        meeting_point_public_garage = {
            label = 'Meeting Point',
            coords = vec4(100.8020, -1072.5234, 28.3741, 332.0977),
            radius = 50.0,
            blip = {
                sprite = 357,
                color = 3,
                -- label = 'Public Garage' -- Overrides label
            },
            ped = {
                model = `s_m_y_valet_01`,
                scenario = 'WORLD_HUMAN_GUARD_STAND'
            },
            maximumVehicles = 25,
            allowedVehicleTypes = { 'car', 'bike' },
            parkingFees = {
                pricePerMinute = 0.03, -- Would be ~43$ per day times the multiplier.
                multipliers = {
                    [0] = 1,           -- Compact
                    [1] = 1,           -- Sedan
                    [2] = 1,           -- SUV
                    [3] = 1,           -- Coupe
                    [4] = 1,           -- Muscle
                    [5] = 1.1,         -- Sports Classic
                    [6] = 1.1,         -- Sports
                    [7] = 1.1,         -- Super
                    [8] = 0.9,         -- Motorcycle
                    [9] = 1,           -- Offroad
                    [10] = 1.4,        -- Industrial
                    [11] = 1.3,        -- Utility
                    [12] = 1.2,        -- Van
                    [14] = 1,          -- Boat
                    [15] = 1,          -- Helicopter
                    [16] = 1,          -- Plane
                    [17] = 1,          -- Service
                    [18] = 1,          -- Emergency
                    [19] = 1,          -- Military
                    [20] = 1,          -- Commercial (trucks)
                    models = {
                        [`t20`] = 1.13
                    }
                }
            }
        }
    }
}
