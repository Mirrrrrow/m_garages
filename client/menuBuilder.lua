local MenuBuilder = {}

---@param identifier string
function MenuBuilder.buildStoreModal(identifier)
    local success, result = lib.callback.await('garage:fetchNearbyVehicles', false, identifier)
    if not success then return lib.notify({ description = locale(result), type = 'error' }) end

    local values = lib.inputDialog(locale('store_vehicle.header'), {
        {
            icon = 'fas fa-list',
            type = 'select',
            label = locale('store_vehicle.select.label'),
            description = locale('store_vehicle.select.description'),
            options = lib.array.map(result, function(vehicle)
                return {
                    label = ('%s | %s'):format(vehicle.plate, Utils.getCarLabel(vehicle.model)),
                    value = vehicle.netId
                }
            end),
            required = true
        }
    })

    local netId = values?[1]
    if not netId then return end

    success, result = lib.callback.await('garage:storeVehicle', false, netId, identifier)
    lib.notify({ description = locale(result), type = success and 'success' or 'error' })
end

---@param identifier string
---@param data GarageProperties
function MenuBuilder.buildRetrieveMenu(identifier, data)
    local success, result = lib.callback.await('garage:fetchStoredVehicles', false, identifier)
    if not success then return lib.notify({ description = locale(result), type = 'error' }) end

    local retrieveMenuId = ('retrieve_g_%s'):format(identifier)
    lib.registerContext({
        id = retrieveMenuId,
        title = data.label,
        options = lib.array.map(result, function(vehicle)
            return {
                icon = 'car',
                title = ('%s | %s'):format(vehicle.plate, Utils.getCarLabel(vehicle.model)),
            }
        end),
    })

    lib.showContext(retrieveMenuId)
end

local cachedGarageMenus = {}
---@param identifier string
---@param data GarageProperties
function MenuBuilder.buildGarageMenu(identifier, data)
    local menuId = ('garage_mm_%s'):format(identifier)
    if cachedGarageMenus[identifier] then
        return lib.showContext(menuId)
    end

    lib.registerContext({
        id = menuId,
        title = data.label,
        options = {
            {
                icon = 'fas fa-warehouse',
                title = locale('main_menu.store_vehicle'),
                onSelect = function()
                    MenuBuilder.buildStoreModal(identifier)
                end
            },
            {
                icon = 'fas fa-undo',
                title = locale('main_menu.retrieve_vehicle'),
                onSelect = function()
                    MenuBuilder.buildRetrieveMenu(identifier, data)
                end
            },
        }
    })

    cachedGarageMenus[identifier] = menuId
    lib.showContext(menuId)
end

return MenuBuilder
