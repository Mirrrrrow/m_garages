Utils = require 'client.utils'
MenuBuilder = require 'client.menuBuilder'
ModalBuilder = require 'client.modalBuilder'
Actions = require 'client.actions'

local target = exports.ox_target
for key, garage in pairs(Config.garages) do
    local coords = garage.coords

    local blip = garage.blip
    if blip then
        Utils.addBlip({
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

            local entity = Utils.spawnPed({
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

            self.entity = nil
        end
    })
end
