function LoadOldVehicles()
    local vehicles = {}
    local file = io.open(('%s\\data\\vehicles.lua'):format(Config.fullPathToResource), 'r')
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

local function JsonifyVehicle(vehData)
    local model, name, brand, price, categoryLabel, shop = vehData.model, vehData.name, vehData.brand, vehData.price, vehData.categoryLabel, vehData.shop
    local jsonifiedVehicle = string.format("{\"model\": \"%s\", \"name\": \"%s\", \"brand\": \"%s\", \"price\": %d, \"categoryLabel\": \"%s\", \"shop\": \"%s\"},",
        model, name, brand, price, categoryLabel, shop)

    return jsonifiedVehicle
end

local oldVehicles = LoadOldVehicles()

for key, value in pairs(oldVehicles) do
    if type(value) == 'string' then
        oldVehicles[key] = nil
    end
end

local newVehicles = {}
local insertedModels = {}

for model, oldData in pairs(oldVehicles) do
    if not insertedModels[model] then
        local newData = {
            model = model,
            name = oldData['name'],
            brand = oldData['brand'],
            price = oldData['price'],
            categoryLabel = oldData['categoryLabel'] or 'Other',
            shop = oldData['shop'],
        }
        table.insert(newVehicles, newData)
        insertedModels[model] = true
    end
end

table.sort(newVehicles, function(a, b)
    if a.categoryLabel == 'OneOfOne' or a.categoryLabel == 'OriginalDonor' then
        return false
    elseif b.categoryLabel == 'OneOfOne' or b.categoryLabel == 'OriginalDonor' then
        return true
    elseif a.categoryLabel ~= b.categoryLabel then
        return a.categoryLabel < b.categoryLabel
    elseif a.brand ~= b.brand then
        return a.brand < b.brand
    else
        return a.model < b.model
    end
end)

local jsonVehicles = {}
local maxModelLength = 0
local maxNameLength = 0
local maxBrandLength = 0
local maxPriceLength = 0
local maxCategoryLength = 0
local maxShopLength = 0

for _, vehicleData in ipairs(newVehicles) do
    maxModelLength = math.max(maxModelLength, #vehicleData.model)
    maxNameLength = math.max(maxNameLength, #vehicleData.name)
    maxBrandLength = math.max(maxBrandLength, #vehicleData.brand)
    maxPriceLength = math.max(maxPriceLength, #tostring(vehicleData.price))
    maxCategoryLength = math.max(maxCategoryLength, #vehicleData.categoryLabel)
    maxShopLength = math.max(maxShopLength, #tostring(vehicleData.shop))
end

for i, vehicleData in ipairs(newVehicles) do
    local modelSpaces = string.rep(" ", maxModelLength - #vehicleData.model)
    local nameSpaces = string.rep(" ", maxNameLength - #vehicleData.name)
    local brandSpaces = string.rep(" ", maxBrandLength - #vehicleData.brand)
    local priceSpaces = string.rep(" ", maxPriceLength - #tostring(vehicleData.price))
    local categorySpaces = string.rep(" ", maxCategoryLength - #vehicleData.categoryLabel)
    local shopSpaces = string.rep(" ", maxShopLength - #tostring(vehicleData.shop))

    table.insert(jsonVehicles, {
        model = vehicleData.model .. modelSpaces,
        name = vehicleData.name .. nameSpaces,
        brand = vehicleData.brand .. brandSpaces,
        price = vehicleData.price,
        categoryLabel = vehicleData.categoryLabel .. categorySpaces,
        shop = vehicleData.shop .. shopSpaces
    })
end

local jsonVehiclesString = ''
for i, vehicleData in ipairs(newVehicles) do
    jsonVehiclesString = jsonVehiclesString .. "    {"

    local modelSpaces = string.rep(" ", maxModelLength - #vehicleData.model)
    local nameSpaces = string.rep(" ", maxNameLength - #vehicleData.name)
    local brandSpaces = string.rep(" ", maxBrandLength - #vehicleData.brand)
    local priceSpaces = string.rep(" ", maxPriceLength - #tostring(vehicleData.price))
    local categorySpaces = string.rep(" ", maxCategoryLength - #vehicleData.categoryLabel)
    local shopSpaces = string.rep(" ", maxShopLength - #tostring(vehicleData.shop))

    jsonVehiclesString = jsonVehiclesString .. string.format("\"model\": \"%s\",%s", vehicleData.model, modelSpaces)
    jsonVehiclesString = jsonVehiclesString .. string.format("\"name\": \"%s\",%s", vehicleData.name, nameSpaces)
    jsonVehiclesString = jsonVehiclesString .. string.format("\"brand\": \"%s\",%s", vehicleData.brand, brandSpaces)
    jsonVehiclesString = jsonVehiclesString .. string.format("\"price\": %d,%s", vehicleData.price, priceSpaces)
    jsonVehiclesString = jsonVehiclesString .. string.format("\"categoryLabel\": \"%s\",%s", vehicleData.categoryLabel, categorySpaces)
    jsonVehiclesString = jsonVehiclesString .. string.format("\"shop\": \"%s\"", vehicleData.shop, shopSpaces)

    if i < #newVehicles then
        jsonVehiclesString = jsonVehiclesString .. "},\n"
    else
        jsonVehiclesString = jsonVehiclesString .. "}\n"
    end
end

local filePath = ('%s\\converted\\vehicles_new.json'):format(Config.fullPathToResource)
local file = io.open(filePath, 'w')

if file then
    file:write(jsonVehiclesString)
    file:close()
    print('JSON data saved to ' .. filePath)
else
    print('Error: Unable to open ' .. filePath .. ' for writing.')
end
