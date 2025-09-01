require 'server.config'

Db = require 'server.db'

lib.callback.register('garage:fetchNearbyVehicles', function(playerId, identifier)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, 'error' end

    local garage = GARAGES[identifier]
    if not garage then return false, 'error' end

    local nearbyVehicles = lib.getNearbyVehicles(GetEntityCoords(GetPlayerPed(playerId)), garage.radius or 25.0)

    local nearbyPlates, netIdByPlate = {}, {}
    nearbyPlates = lib.array.map(nearbyVehicles, function(element)
        local entity = element.vehicle
        local plate, netId = TrimPlate(GetVehicleNumberPlateText(entity)), NetworkGetNetworkIdFromEntity(entity)
        netIdByPlate[plate] = netId

        return plate
    end)

    local vehicles = Db.fetchVehicles(xPlayer, garage, nearbyPlates)
    if #vehicles == 0 then return false, 'no_vehicles_nearby' end

    return true, lib.array.map(vehicles, function(row)
        local netId = netIdByPlate[row.plate]
        return {
            netId = netId,
            plate = row.plate,
            model = tonumber(row.model)
        }
    end)
end)

lib.callback.register('garage:storeVehicle', function(playerId, netId, identifier)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, 'error' end

    local garage = GARAGES[identifier]
    if not garage then return false, 'error' end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle then return false, 'error' end

    local affectedRows = Db.storeVehicle(xPlayer, identifier, garage, vehicle)
    if affectedRows == 0 then return false, 'cannot_park_here' end

    DeleteEntity(vehicle)

    return true, 'vehicle_stored'
end)
