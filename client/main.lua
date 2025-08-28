local spawnedPeds = lib.array:new()
local target = exports.ox_target

local MenuBuilder = require 'client.menuBuilder'

---@param data { label: string, coords: vector3, sprite: number, color: number }
local function addBlip(data)
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
local function spawnPed(data)
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

local function cleanPeds()
    spawnedPeds:forEach(function(entity)
        if DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, false, true)
            DeleteEntity(entity)
        end
    end)
end

for key, garage in pairs(Config.garages) do
    local coords = garage.coords

    local blip = garage.blip
    if blip then
        addBlip({
            label = blip.label or garage.label,
            coords = coords.xyz,
            sprite = blip.sprite,
            color = blip.color
        })
    end

    local ped = garage.ped
    lib.points.new({
        coords = coords.xyz,
        distance = 50,
        onEnter = function(self)
            if self.entity then return end

            local entity = spawnPed({
                coords = coords,
                model = ped.model,
                scenario = ped.scenario
            })

            target:addLocalEntity(entity, {
                label = locale('open_garage'),
                icon = 'fas fa-warehouse',
                onSelect = function()
                    MenuBuilder.openGarage(key, garage)
                end
            })

            self.entity = entity
        end,
        onExit = function(self)
            local entity = self.entity
            if not entity then return end

            target:removeLocalEntity(entity)
            DeleteEntity(entity)

            spawnedPeds = spawnedPeds:filter(function(element)
                return element ~= entity
            end)

            self.entity = nil
        end
    })
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    cleanPeds()
end)
