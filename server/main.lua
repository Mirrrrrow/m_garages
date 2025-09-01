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

lib.callback.register('garage:fetchStoredVehicles', function(playerId, identifier)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, 'error' end

    local garage = GARAGES[identifier]
    if not garage then return false, 'error' end

    local vehicles = Db.fetchStoredVehicles(xPlayer, identifier, garage)
    if #vehicles == 0 then return false, 'no_vehicles_stored' end

    return true, vehicles
end)

lib.callback.register('garage:retrieveVehicle', function(playerId, plate, identifier)
    local xPlayer = ESX.Player(playerId)
    if not xPlayer then return false, 'error' end

    local garage = GARAGES[identifier]
    if not garage then return false, 'error' end

    local success, vehicle = Db.retrieveVehicle(xPlayer, identifier, garage, plate)
    if not success then return false, 'cannot_retrieve_vehicle' end

    ---@todo wip get spawnpoints this is just for dev stuff
    local coords = GetEntityCoords(GetPlayerPed(playerId))
    ESX.OneSync.SpawnVehicle(tonumber(vehicle.model), coords, 0, vehicle, function(netId)
        if not netId then return false, 'error' end

        if WARP_PED_WHEN_RETRIEVING then
            lib.waitFor(function()
                local entity = NetworkGetEntityFromNetworkId(netId)
                if DoesEntityExist(entity) then
                    TaskWarpPedIntoVehicle(GetPlayerPed(playerId), entity, -1)
                    return true
                end
            end, 'Unable to warp ped into vehicle')
        end
    end)
    return true, 'vehicle_retrieved'
end)
