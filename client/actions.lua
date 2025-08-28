local Actions = {}

local function generateCarLabel(model)
    model = tonumber(model)
    if not model then return end

    local displayName = GetDisplayNameFromVehicleModel(model)
    local makeName = GetMakeNameFromVehicleModel(model)
    local label = GetLabelText(displayName)
    if makeName ~= '' then
        label = GetLabelText(makeName) .. ' ' .. label
    end

    return label
end

function Actions.requestParkIn(garageKey, garageData)
    local success, result = lib.callback.await('garage:server:fetchNearbyVehicles', false, garageKey)
    if not success then return lib.notify({ description = result, type = 'error' }) end
    if #result == 0 then return lib.notify({ description = locale('messages.no_vehicles'), type = 'error' }) end

    local selection = lib.inputDialog(locale('vehicle_selector.header'), {
        {
            type = 'select',
            label = locale('vehicle_selector.label'),
            options = lib.array.map(result, function(vehicle)
                print(vehicle.vehicleModel)
                return {
                    value = vehicle.plate,
                    label = ('%s [%s]'):format(vehicle.plate, generateCarLabel(vehicle.vehicleModel))
                }
            end),
            required = true
        }
    })

    local vehicle = selection?[1]
    if not vehicle then return end

    print(vehicle)
end

return Actions
