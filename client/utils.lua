local Utils = {}

function Utils.generateCarLabel(model)
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

function Utils.calculateWithdrawalFees(garageKey, model)
    local garage = Config.garages[garageKey]
    if not garage then return 0 end

    local parkingFeesData = garage.parkingFees
    if not parkingFeesData then return 0 end

    local fee = parkingFeesData.pricePerMinute *
        (parkingFeesData.multipliers.models[model] or parkingFeesData.multipliers[GetVehicleClassFromName(model)] or 1)
    return fee
end

return Utils
