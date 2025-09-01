local Db = {}

---@param xPlayer table
---@param garage GarageProperties
---@param nearbyPlates string[]
---@return table
function Db.fetchVehicles(xPlayer, garage, nearbyPlates)
    local query, params =
        'SELECT plate, JSON_EXTRACT(vehicle, "$.model") AS model FROM owned_vehicles WHERE stored = 0 AND plate IN (?)',
        { nearbyPlates }

    local jobRestrictions = garage.restrictions?.playerJob
    local vehicleRestrictions = garage.restrictions?.vehicleTypes
    if vehicleRestrictions then
        query = query .. ' AND type IN (?)'
        table.insert(params, vehicleRestrictions)
    end

    if jobRestrictions then
        query = query .. ' AND job IN (?)'
        table.insert(params, jobRestrictions)
    else
        query = query .. ' AND job IS NULL AND owner = ?'
        table.insert(params, xPlayer.getIdentifier())
    end

    return MySQL.query.await(query, params)
end

---@param xPlayer table
---@param identifier string
---@param garage GarageProperties
---@param vehicleHandle number
---@return number?
function Db.storeVehicle(xPlayer, identifier, garage, vehicleHandle)
    local plate = TrimPlate(GetVehicleNumberPlateText(vehicleHandle))
    local query, params =
        'UPDATE owned_vehicles SET stored = 1, parking = ? WHERE plate = ?',
        { identifier, plate }

    local jobRestrictions = garage.restrictions?.playerJob
    local vehicleRestrictions = garage.restrictions?.vehicleTypes
    if vehicleRestrictions then
        query = query .. ' AND type IN (?)'
        table.insert(params, vehicleRestrictions)
    end

    if jobRestrictions then
        query = query .. ' AND job IN (?)'
        table.insert(params, jobRestrictions)
    else
        query = query .. ' AND job IS NULL AND owner = ?'
        table.insert(params, xPlayer.getIdentifier())
    end

    return MySQL.update.await(query, params)
end

return Db
