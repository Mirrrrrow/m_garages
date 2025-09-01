local Db = {}

---Internal function to build a SQL query for fetching vehicles (with all the restrictions)
---@param xPlayer table
---@param garage GarageProperties
---@param baseQuery string
---@param baseParams table
---@return string, table
local function buildQuery(xPlayer, garage, baseQuery, baseParams)
    local jobRestrictions = garage.restrictions?.playerJob
    local vehicleRestrictions = garage.restrictions?.vehicleTypes

    if vehicleRestrictions then
        baseQuery = baseQuery .. ' AND type IN (?)'
        table.insert(baseParams, vehicleRestrictions)
    end

    if jobRestrictions then
        baseQuery = baseQuery .. ' AND job IN (?)'
        table.insert(baseParams, jobRestrictions)
    else
        baseQuery = baseQuery .. ' AND job IS NULL AND owner = ?'
        table.insert(baseParams, xPlayer.getIdentifier())
    end

    return baseQuery, baseParams
end

---@param xPlayer table
---@param garage GarageProperties
---@param nearbyPlates string[]
---@return table
function Db.fetchVehicles(xPlayer, garage, nearbyPlates)
    local query, params = buildQuery(xPlayer, garage,
        'SELECT plate, JSON_EXTRACT(vehicle, "$.model") AS model FROM owned_vehicles WHERE stored = 0 AND plate IN (?)',
        { nearbyPlates })

    return MySQL.query.await(query, params)
end

---@param xPlayer table
---@param identifier string
---@param garage GarageProperties
---@return table
function Db.fetchStoredVehicles(xPlayer, identifier, garage)
    local query, params = buildQuery(xPlayer, garage,
        'SELECT plate, JSON_EXTRACT(vehicle, "$.model") AS model FROM owned_vehicles WHERE stored = 1 AND parking = ?',
        { identifier })

    return MySQL.query.await(query, params)
end

---@param xPlayer table
---@param identifier string
---@param garage GarageProperties
---@param vehicleHandle number
---@param vehicleProperties table
---@return number?
function Db.storeVehicle(xPlayer, identifier, garage, vehicleHandle, vehicleProperties)
    local plate = TrimPlate(GetVehicleNumberPlateText(vehicleHandle))

    local baseQuery = SAVE_VEHICLE_PROPERTIES and
        'UPDATE owned_vehicles SET stored = 1, parking = ?, vehicle = ? WHERE plate = ?' or
        'UPDATE owned_vehicles SET stored = 1, parking = ? WHERE plate = ?'

    local baseParams = SAVE_VEHICLE_PROPERTIES and
        { identifier, json.encode(vehicleProperties), plate } or
        { identifier, plate }

    local query, params = buildQuery(xPlayer, garage,
        baseQuery,
        baseParams)

    return MySQL.update.await(query, params)
end

---@param xPlayer table
---@param identifier string
---@param garage GarageProperties
---@param plate string
---@return boolean, table
function Db.retrieveVehicle(xPlayer, identifier, garage, plate)
    local query, params = buildQuery(xPlayer, garage,
        'UPDATE owned_vehicles SET stored = 0, parking = NULL WHERE plate = ? AND stored = 1 AND parking = ?',
        { plate, identifier })

    local affectedRows = MySQL.update.await(query, params)
    if affectedRows == 0 then return false, {} end

    return true,
        json.decode(MySQL.scalar.await('SELECT vehicle FROM owned_vehicles WHERE plate = ?',
            { plate }) or "{}")
end

return Db
