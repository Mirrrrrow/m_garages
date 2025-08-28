local MenuBuilder = {}
local cachedMainMenus = {}

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
                description = locale('garage_menu.list_vehicles.description'),
                onSelect = function()
                    Actions.requestParkOut(garageKey)
                end
            },
            {
                icon = 'car',
                title = locale('garage_menu.park_vehicle.title'),
                description = locale('garage_menu.park_vehicle.description'),
                onSelect = function()
                    Actions.requestParkIn(garageKey)
                end
            }
        }
    })

    lib.showContext(menuId)
    cachedMainMenus[garageKey] = true
end

function MenuBuilder.openVehicleList(garageKey, vehicles)
    local menuId = ('garage_parkout_%s'):format(garageKey)
    local garageData = Config.garages[garageKey]

    lib.registerContext({
        id = menuId,
        title = garageData.label,
        options = lib.array.map(vehicles, function(vehicle)
            local fees = vehicle.storedDuration / 1000 / 60 *
                Utils.calculateWithdrawalFees(garageKey, vehicle.vehicleModel)
            return {
                icon = 'car',
                title = ("%s [%s]"):format(vehicle.plate, Utils.generateCarLabel(vehicle.vehicleModel)),
                metadata = {
                    { label = locale('garage_menu.parkout.stored_since'),          value = vehicle.storedAt },
                    { label = locale('garage_menu.parkout.withdrawal_fees.label'), value = locale('garage_menu.parkout.withdrawal_fees.value', lib.math.groupdigits(lib.math.floor(fees), '.')) }
                }
            }
        end)
    })

    lib.showContext(menuId)
end

return MenuBuilder
