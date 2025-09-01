local MenuBuilder = {}

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
            },
            {
                icon = 'fas fa-undo',
                title = locale('main_menu.retrieve_vehicle'),
            },
        }
    })

    cachedGarageMenus[identifier] = menuId
    lib.showContext(menuId)
end

return MenuBuilder
