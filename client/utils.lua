local Utils = {}
local spawnedPeds = lib.array:new()

local function cleanPeds()
    spawnedPeds:forEach(function(entity)
        if DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, false, true)
            DeleteEntity(entity)
        end
    end)
end

---@param data { label: string, coords: vector3, sprite: number, color: number }
function Utils.addBlip(data)
    local coords = data.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, data.sprite)
    SetBlipColour(blip, data.color)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
end

---@param data { coords: vector4, model: number|string, scenario: string }
function Utils.spawnPed(data)
    local model = lib.requestModel(data.model)
    if not model then lib.print.error(('Unkown ped model: \'%s\'.'):format(data.model)) end

    local coords = data.coords
    local entity = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, true)

    local scenario = data.scenario
    if scenario then
        TaskStartScenarioInPlace(entity, scenario, 0, true)
    end

    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetBlockingOfNonTemporaryEvents(entity, true)

    spawnedPeds:push(entity)

    return entity
end

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

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    cleanPeds()
end)

return Utils
