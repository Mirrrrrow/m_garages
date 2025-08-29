local function trimPlate(plate)
    return plate and plate:gsub('^%s*(.-)%s*$', '%1') or nil
end

lib.callback.register('garage:server:fetchNearbyVehicles', function(playerId, garageKey)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, locale('messages.unknown_error') end

    local garage = Config.garages[garageKey]
    if not garage then return false, locale('messages.unknown_error') end

    local netIdByPlates, plates = {}, {}
    for _, element in ipairs(lib.getNearbyVehicles(garage.coords.xyz, garage.radius)) do
        local entity = element.vehicle
        local plate = trimPlate(GetVehicleNumberPlateText(entity))
        if plate then
            netIdByPlates[plate] = NetworkGetNetworkIdFromEntity(entity)
            table.insert(plates, plate)
        end
    end

    if #plates == 0 then return true, {} end

    local query = [[
        SELECT plate, type, job, owner,
               JSON_UNQUOTE(JSON_EXTRACT(vehicle, '$.model')) AS vehicleModel
        FROM owned_vehicles
        WHERE plate IN (?)
    ]]
    local params = { plates }

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

    local rows = MySQL.query.await(query, params) or {}
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

    local rows = MySQL.query.await(query, params) or {}

    table.sort(rows, function(a, b)
        return a.storedAt > b.storedAt
    end)

    for _, row in ipairs(rows) do
        row.storedDuration = row.now - row.storedAt
        if row.storedAt then
            row.storedAt = os.date('%Y-%m-%d %H:%M:%S', row.storedAt / 1000)
        end
    end

    return true, rows
end)

lib.callback.register('garage:server:storeVehicle', function(playerId, garageKey, netId)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, locale('messages.unknown_error') end

    local garage = Config.garages[garageKey]
    if not garage then return false, locale('messages.unknown_error') end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return false, locale('messages.unknown_error') end

    local plate = trimPlate(GetVehicleNumberPlateText(vehicle))
    if not plate then return false, locale('messages.unknown_error') end

    local query = [[
        UPDATE owned_vehicles
        SET stored = 1,
            storedAt = CURRENT_TIMESTAMP(),
            parking = ?
        WHERE plate = ? AND owner = ?
    ]]
    local params = { garageKey, plate, xPlayer.getIdentifier() }

    if garage.allowedJobs and #garage.allowedJobs > 0 then
        query = query .. " AND job IN (?)"
        table.insert(params, garage.allowedJobs)
    end

    if garage.allowedVehicleTypes and #garage.allowedVehicleTypes > 0 then
        query = query .. " AND type IN (?)"
        table.insert(params, garage.allowedVehicleTypes)
    end

    local affectedRows = MySQL.update.await(query, params)
    if affectedRows == 0 then return false, locale('messages.unknown_error') end

    DeleteEntity(vehicle)

    return true, locale('messages.vehicle_stored')
end)
