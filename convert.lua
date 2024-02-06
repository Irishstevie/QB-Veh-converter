function LoadOldVehicles()
    local vehicles = {}
    local file = io.open('C:/Pixel-Pleasure/data/resources/[stevie]/QB-Veh-converter/vehicles.lua', 'r')
    if file then
        local data = file:read('*a')
        file:close()
        local chunk, err = load(data, 'vehicles.lua', 't', {})
        if chunk then
            vehicles = chunk()
        else
            print('Error loading vehicles.lua: ' .. err)
        end
    else
        print('Error: Unable to open vehicles.lua for reading.')
    end
    return vehicles
end

local oldVehicles = LoadOldVehicles()
local newVehicles = {}

local modelTracker = {}
local duplicates = {}
local totalVehicles = 0

for model, oldData in pairs(oldVehicles) do
    if type(oldData) == 'table' then
        local vehicleType = 'automobile'
        if oldData['category'] == 'motorcycles' then
            vehicleType = 'motorcycles'
        elseif oldData['category'] == 'cycles' then
            vehicleType = 'bike'
        end

        local cleanName = oldData['name']:gsub("'", "")

        local newData = {
            model = model,
            name = cleanName,
            brand = oldData['brand'],
            price = oldData['price'],
            category = oldData['category'] or 'Other',
            type = vehicleType,
            shop = 'pdm',
        }
        table.insert(newVehicles, newData)

        if modelTracker[model] then
            table.insert(duplicates, model)
        else
            modelTracker[model] = true
        end
    end
end

table.sort(newVehicles, function(a, b)
    if a.category == b.category then
        return a.price < b.price
    else
        return a.category < b.category
    end
end)

local vehiclesDataStr = "QBShared = QBShared or {}\nQBShared.Vehicles = QBShared.Vehicles or {}\n\nlocal Vehicles = {\n"
local currentCategory = nil
for _, vehicleData in ipairs(newVehicles) do
    totalVehicles = totalVehicles + 1

    if vehicleData.category ~= currentCategory then
        if currentCategory ~= nil then
            vehiclesDataStr = vehiclesDataStr .. "\n"
        end
        vehiclesDataStr = vehiclesDataStr .. "  -- " .. vehicleData.category .. "\n"
        currentCategory = vehicleData.category
    end

    vehiclesDataStr = vehiclesDataStr .. "  { model = '" .. vehicleData.model .. "', "
    vehiclesDataStr = vehiclesDataStr .. "name = '" .. vehicleData.name .. "', "
    vehiclesDataStr = vehiclesDataStr .. "brand = '" .. vehicleData.brand .. "', "
    vehiclesDataStr = vehiclesDataStr .. "price = " .. vehicleData.price .. ", "
    vehiclesDataStr = vehiclesDataStr .. "category = '" .. vehicleData.category .. "', "
    vehiclesDataStr = vehiclesDataStr .. "type = '" .. vehicleData.type .. "', "
    vehiclesDataStr = vehiclesDataStr .. "shop = '" .. vehicleData.shop .. "' },\n"
end
vehiclesDataStr = vehiclesDataStr .. "}\n\nfor i = 1, #Vehicles do\n    QBShared.Vehicles[Vehicles[i].model] = {\n        spawncode = Vehicles[i].model,\n        name = Vehicles[i].name,\n        brand = Vehicles[i].brand,\n        model = Vehicles[i].model,\n        price = Vehicles[i].price,\n        category = Vehicles[i].category,\n        hash = joaat(Vehicles[i].model),\n        type = Vehicles[i].type,\n        shop = Vehicles[i].shop\n    }\nend"

vehiclesDataStr = vehiclesDataStr .. "\n-- Total Vehicles Processed: " .. totalVehicles .. "\n"
if #duplicates > 0 then
    vehiclesDataStr = vehiclesDataStr .. "-- Duplicates Detected: " .. table.concat(duplicates, ", ") .. "\n"
else

end

vehiclesDataStr = vehiclesDataStr .. "-- QB-Veh-converter Made By 🙊 Stevie | Asshole Inspired 🙉 \n"

local filePath = 'C:/Pixel-Pleasure/data/resources/[stevie]/QB-Veh-converter/vehicles_new.lua'
local file = io.open(filePath, 'w')
if file then
    file:write(vehiclesDataStr)
    file:close()
    print('Lua table saved to ' .. filePath)
else
    print('Error: Unable to open ' .. filePath .. ' for writing.')
end