lib.locale()

require 'shared.config'


function TrimPlate(plate)
    return plate:gsub("^%s*(.-)%s*$", "%1")
end
