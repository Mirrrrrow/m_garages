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

lib.callback.register('garage:server:requestStoredVehicles', function(playerId, garageKey)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, locale('messages.unknown_error') end

    local garage = Config.garages[garageKey]
    if not garage then return false, locale('messages.unknown_error') end

    local query = [[
        SELECT plate, type, job, owner, storedAt,
            JSON_UNQUOTE(JSON_EXTRACT(vehicle, '$.model')) AS vehicleModel,
            CURRENT_TIMESTAMP() as now
        FROM owned_vehicles
        WHERE stored = 1 AND parking = ?
    ]]
    local params = { garageKey }

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
    table.sort(rows, function(a, b)
        return a.storedAt > b.storedAt
    end)
    for _, row in ipairs(rows) do
        row.storedDuration = row.now - row.storedAt
        row.storedAt = row.storedAt and os.date('%Y-%m-%d %H:%M:%S', row.storedAt / 1000)
    end

    return true, rows
end)

---@todo add some security checks
lib.callback.register('garage:server:storeVehicle', function(playerId, garageKey, netId)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, locale('messages.unknown_error') end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return false, locale('messages.unknown_error') end

    MySQL.update.await([[
        UPDATE
            owned_vehicles
        SET
            stored = 1,
            storedAt = CURRENT_TIMESTAMP(),
            parking = ?
        WHERE
            plate = ?
        AND
            owner = ?
    ]], { garageKey, GetVehicleNumberPlateText(vehicle):gsub('^%s*(.-)%s*$', '%1'), xPlayer.getIdentifier() })

    DeleteEntity(vehicle)

    return true, locale('messages.vehicle_stored')
end)
