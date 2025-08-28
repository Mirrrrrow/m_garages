local ModalBuilder = {}

function ModalBuilder.requestVehicleSelection(vehicles)
    local selection = lib.inputDialog(locale('vehicle_selector.header'), {
        {
            type = 'select',
            icon = 'list',
            label = locale('vehicle_selector.label'),
            options = lib.array.map(vehicles, function(vehicle)
                return {
                    value = vehicle.netId,
                    label = ('%s [%s]'):format(vehicle.plate, Utils.generateCarLabel(vehicle.vehicleModel))
                }
            end),
            required = true
        }
    })

    return selection?[1]
end

function ModalBuilder.requestVehicleStorageConfirmation(garageKey, vehicleNetId)
    local garage = Config.garages[garageKey]
    if not garage then
        lib.notify({ description = locale('messages.unknown_error'), type = 'error' })
        return false
    end

    if not garage.parkingFees then return true end

    local entity = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not entity or not DoesEntityExist(entity) then
        lib.notify({ description = locale('messages.unknown_error'), type = 'error' })
        return false
    end

    local parkingFeesData = garage.parkingFees
    local fee = parkingFeesData.pricePerMinute *
        (parkingFeesData.multipliers.models[GetEntityModel(entity)] or parkingFeesData.multipliers[GetVehicleClass(entity)] or 1)

    local success = lib.alertDialog({
        header = locale('confirmation.header'),
        content = locale('confirmation.content', lib.math.groupdigits(fee, '.')),
        centered = true,
        cancel = true
    })

    return success == 'confirm'
end

return ModalBuilder
