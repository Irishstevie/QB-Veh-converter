-- Function to load old vehicles data from vehicles.lua
function LoadOldVehicles()
    local vehicles = {}
    -- Load vehicles from vehicles.lua
    local file = io.open(('%s\\data\\vehicles.lua'):format(Config.fullPathToResource), 'r')
    if file then
        local data = file:read('*a')
        file:close()
        -- Execute the loaded Lua code to get the vehicles data
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

-- Generate the JSON object for each vehicle data
local function JsonifyVehicle(vehData)
    local model, name, brand, price, categoryLabel, shop = vehData.model, vehData.name, vehData.brand, vehData.price, vehData.categoryLabel, vehData.shop
    local jsonifiedVehicle = string.format("{['model'] = '%s', ['name'] = '%s', ['brand'] = '%s', ['price'] = %d, ['categoryLabel'] = '%s', ['shop'] = '%s'},",
        model, name, brand, price, categoryLabel, shop)

    return jsonifiedVehicle
end

-- Load the old vehicles data from vehicles.lua
local oldVehicles = LoadOldVehicles()

-- Remove lines with unwanted comments
for key, value in pairs(oldVehicles) do
    if type(value) == 'string' then
        oldVehicles[key] = nil
    end
end

-- Convert the old data to the new format
local newVehicles = {}
local insertedModels = {} -- Keep track of inserted models to prevent duplicates

for model, oldData in pairs(oldVehicles) do
    if not insertedModels[model] then
        local newData = {
            ['model'] = model,
            ['name'] = oldData['name'],
            ['brand'] = oldData['brand'],
            ['price'] = oldData['price'],
            ['categoryLabel'] = oldData['categoryLabel'] or 'Other', -- Default to 'Other' if categoryLabel is nil
            ['shop'] = oldData['shop'], -- Assuming you want to set the shop to 'pdm'
        }
        table.insert(newVehicles, newData)
        insertedModels[model] = true -- Mark the model as inserted
    end
end

-- Sort the new data by categoryLabel, brand, and then model
table.sort(newVehicles, function(a, b)
    if a.categoryLabel == 'OneOfOne' or a.categoryLabel == 'OriginalDonor' then
        return false -- Ensure 'OneOfOne' and 'OriginalDonor' stay at the bottom
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

-- Create a JSON string with each vehicle in the desired format with aligned columns
local jsonVehicles = "{\n"

local maxModelLength = 0
local maxNameLength = 0
local maxBrandLength = 0
local maxPriceLength = 0
local maxCategoryLength = 0
local maxShopLength = 0

-- Sort the vehicles first by 'shop', and then by 'categoryLabel'
table.sort(newVehicles, function(a, b)
    local shopA = tostring(a.shop)
    local shopB = tostring(b.shop)
    local categoryA = tostring(a.categoryLabel)
    local categoryB = tostring(b.categoryLabel)

    if shopA == shopB then
        return categoryA < categoryB
    else
        return shopA < shopB
    end
end)

for _, vehicleData in ipairs(newVehicles) do
    maxModelLength = math.max(maxModelLength, #vehicleData.model)
    maxNameLength = math.max(maxNameLength, #vehicleData.name)
    maxBrandLength = math.max(maxBrandLength, #vehicleData.brand)
    maxPriceLength = math.max(maxPriceLength, #tostring(vehicleData.price))
    maxCategoryLength = math.max(maxCategoryLength, #vehicleData.categoryLabel)
    maxShopLength = math.max(maxShopLength, #tostring(vehicleData.shop))
end

for i, vehicleData in ipairs(newVehicles) do
    jsonVehicles = jsonVehicles .. "    {"

    local modelSpaces = string.rep(" ", maxModelLength - #vehicleData.model)
    local nameSpaces = string.rep(" ", maxNameLength - #vehicleData.name)
    local brandSpaces = string.rep(" ", maxBrandLength - #vehicleData.brand)
    local priceSpaces = string.rep(" ", maxPriceLength - #tostring(vehicleData.price))
    local categorySpaces = string.rep(" ", maxCategoryLength - #vehicleData.categoryLabel)
    local shopSpaces = string.rep(" ", maxShopLength - #tostring(vehicleData.shop))

    jsonVehicles = jsonVehicles .. string.format("['model'] = '%s',%s", vehicleData.model, modelSpaces)
    jsonVehicles = jsonVehicles .. string.format("['name'] = '%s',%s", vehicleData.name, nameSpaces)
    jsonVehicles = jsonVehicles .. string.format("['brand'] = '%s',%s", vehicleData.brand, brandSpaces)
    jsonVehicles = jsonVehicles .. string.format("['price'] = %d,%s", vehicleData.price, priceSpaces)
    jsonVehicles = jsonVehicles .. string.format("['categoryLabel'] = '%s',%s", vehicleData.categoryLabel, categorySpaces)
    jsonVehicles = jsonVehicles .. string.format("['shop'] = '%s'", vehicleData.shop, shopSpaces)

    if i < #newVehicles then
        jsonVehicles = jsonVehicles .. "},\n"
    else
        jsonVehicles = jsonVehicles .. "}\n"
    end
end
jsonVehicles = jsonVehicles .. "}"

-- Save the new data to a JSON file (vehicles_new.json) with aligned columns
local filePath = ('%s\\converted\\vehicles_new.json'):format(Config.fullPathToResource)
local file = io.open(filePath, 'w')

if file then
    file:write(jsonVehicles)
    file:close()
    print('JSON data saved to ' .. filePath)
else
    print('Error: Unable to open ' .. filePath .. ' for writing.')
end