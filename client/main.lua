require 'client.config'

Utils = require 'client.utils'
MenuBuilder = require 'client.menuBuilder'

---@param identifier string
---@param data GarageProperties
local function openGarageMenu(identifier, data)
    if IsNuiFocused() or IsPauseMenuActive() or IsEntityDead(cache.ped) or cache.vehicle then return end

    local jobRestrictions = data.restrictions?.playerJob
    if jobRestrictions and not lib.table.contains(jobRestrictions, ESX.GetPlayerData().job.name) then return end

    MenuBuilder.buildGarageMenu(identifier, data)
end

for identifier, data in pairs(GARAGES) do
    local label, coords = data.label, data.coords

    local blip = data.blip
    if blip then
        Utils.createBlip({
            label = label,
            coords = coords,
            sprite = blip.sprite,
            color = blip.color,
            scale = blip.scale or 0.8
        })
    end

    local ped = data.ped
    Utils.createInteractablePed({
        coords = coords,
        model = ped.model,
        animation = ped.animation
    }, {
        icon = 'fas fa-warehouse',
        label = locale('open_garage'),
        distance = 2.0,
        onSelect = function()
            openGarageMenu(identifier, data)
        end
    })
end
