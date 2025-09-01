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
        }
    }
}
