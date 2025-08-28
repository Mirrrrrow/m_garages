local Actions = {}

function Actions.requestParkIn(garageKey, garageData)
    local success, result = lib.callback.await('garage:server:fetchNearbyVehicles', false, garageKey)
    if not success then return lib.notify({ description = result, type = 'error' }) end
    if #result == 0 then return lib.notify({ description = locale('messages.no_vehicles'), type = 'error' }) end

    local vehicle = ModalBuilder.requestVehicleSelection(result)
    if not vehicle then return end

    local hasConfirmed = ModalBuilder.requestVehicleStorageConfirmation(garageKey, vehicle)
end

return Actions
