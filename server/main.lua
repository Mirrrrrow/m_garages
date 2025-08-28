lib.callback.register('garage:server:fetchNearbyVehicles', function(playerId, garageKey)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, locale('messages.unknown_error') end

    local garage = Config.garages[garageKey]
    if not garage then return false, locale('messages.unknown_error') end

    local netIdByPlates = {}
    local nearbyVehicles = lib.array.map(lib.getNearbyVehicles(garage.coords.xyz, garage.radius), function(element)
        local entity = element.vehicle
        local plate = GetVehicleNumberPlateText(entity):gsub('^%s*(.-)%s*$', '%1')
        netIdByPlates[plate] = NetworkGetNetworkIdFromEntity(entity)

        return plate
    end)

    if not nearbyVehicles or #nearbyVehicles == 0 then
        return true, {}
    end

    local query = [[
        SELECT plate, type, job, owner, JSON_UNQUOTE(JSON_EXTRACT(vehicle, '$.model')) AS vehicleModel
        FROM owned_vehicles
        WHERE plate IN (?)
    ]]
    local params = { nearbyVehicles }

    if garage.allowedJobs and #garage.allowedJobs > 0 then
        query = query .. " AND job IN (?)"
        table.insert(params, garage.allowedJobs)
    else
        query = query .. " AND owner = ?"
        table.insert(params, xPlayer.getIdentifier())
    end

    if garage.allowedVehicleTypes and #garage.allowedVehicleTypes > 0 then
        query = query .. " AND type IN (?)"
        table.insert(params, garage.allowedVehicleTypes)
    end

    local rows = MySQL.query.await(query, params)
    for _, row in ipairs(rows) do
        row.netId = netIdByPlates[row.plate]
    end

    return true, rows
end)
