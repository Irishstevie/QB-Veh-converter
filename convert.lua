-- Function to load old vehicles data from vehicles.lua
function LoadOldVehicles()
    local vehicles = {}
    -- Load vehicles from vehicles.lua
    local file = io.open('G:/PixelPleasure/data/resources/[stevie]/QB-Veh-converter/vehicles.lua', 'r')
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
            ['shop'] = 'pdm', -- Assuming you want to set the shop to 'pdm'
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

-- Create a JSON string with each vehicle in the desired format
local jsonVehicles = "{\n"
local prevCategoryLabel = nil

for i, vehicleData in ipairs(newVehicles) do
    if prevCategoryLabel and prevCategoryLabel ~= vehicleData.categoryLabel then
        jsonVehicles = jsonVehicles .. "\n"
    end

    jsonVehicles = jsonVehicles .. "    {"
    jsonVehicles = jsonVehicles .. "['model'] = '" .. vehicleData.model .. "', "
    jsonVehicles = jsonVehicles .. "['name'] = '" .. vehicleData.name .. "', "
    jsonVehicles = jsonVehicles .. "['brand'] = '" .. vehicleData.brand .. "', "
    jsonVehicles = jsonVehicles .. "['price'] = " .. vehicleData.price .. ", "
    jsonVehicles = jsonVehicles .. "['categoryLabel'] = '" .. vehicleData.categoryLabel .. "', "
    jsonVehicles = jsonVehicles .. "['shop'] = '" .. vehicleData.shop .. "'"
    jsonVehicles = jsonVehicles .. "},"

    prevCategoryLabel = vehicleData.categoryLabel

    if i < #newVehicles then
        jsonVehicles = jsonVehicles .. "\n"
    end
end
jsonVehicles = jsonVehicles .. "\n}"

-- Save the new data to a JSON file (vehicles_new.json)
local filePath = 'G:/PixelPleasure/data/resources/[stevie]/QB-Veh-converter/vehicles_new.json'
local file = io.open(filePath, 'w')

if file then
    file:write(jsonVehicles)
    file:close()
    print('JSON data saved to ' .. filePath)
else
    print('Error: Unable to open ' .. filePath .. ' for writing.')
end