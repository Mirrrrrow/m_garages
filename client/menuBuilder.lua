local MenuBuilder = {}
local cachedMainMenus = {}

local Actions = require 'client.actions'
function MenuBuilder.openGarage(garageKey, garageData)
    local menuId = ('garage_%s'):format(garageKey)
    if cachedMainMenus[garageKey] then
        return lib.showContext(menuId)
    end

    lib.registerContext({
        id = menuId,
        title = garageData.label,
        options = {
            {
                icon = 'list',
                title = locale('garage_menu.list_vehicles.title'),
                description = locale('garage_menu.list_vehicles.description')
            },
            {
                icon = 'car',
                title = locale('garage_menu.park_vehicle.title'),
                description = locale('garage_menu.park_vehicle.description'),
                onSelect = function()
                    Actions.requestParkIn(garageKey, garageData)
                end
            }
        }
    })

    lib.showContext(menuId)
    cachedMainMenus[garageKey] = true
end

return MenuBuilder
