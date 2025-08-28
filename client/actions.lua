local Actions = {}

function Actions.requestParkIn(garageKey)
    local success, result = lib.callback.await('garage:server:fetchNearbyVehicles', false, garageKey)
    if not success then return lib.notify({ description = result, type = 'error' }) end
    if #result == 0 then return lib.notify({ description = locale('messages.no_vehicles'), type = 'error' }) end

    local vehicle = ModalBuilder.requestVehicleSelection(result)
    if not vehicle then return end

    local hasConfirmed = ModalBuilder.requestVehicleStorageConfirmation(garageKey, vehicle)
    if not hasConfirmed then return end

    success, result = lib.callback.await('garage:server:storeVehicle', false, garageKey, vehicle)
    lib.notify({ description = result, type = success and 'success' or 'error' })
end

function Actions.requestParkOut(garageKey)
    local success, result = lib.callback.await('garage:server:requestStoredVehicles', false, garageKey)

    if not success then return lib.notify({ description = result, type = 'error' }) end
    if #result == 0 then return lib.notify({ description = locale('messages.no_vehicles'), type = 'error' }) end

    MenuBuilder.openVehicleList(garageKey, result)
end

return Actions
