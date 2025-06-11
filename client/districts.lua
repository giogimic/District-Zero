local QBCore = exports['qb-core']:GetCoreObject()
local currentDistrict = nil
local districtBlips = {}
local districtMarkers = {}
local districtEvents = {}

-- Create district blips
local function CreateDistrictBlips()
    for _, district in pairs(Config.Districts) do
        local blip = AddBlipForRadius(district.center.x, district.center.y, district.center.z, district.radius)
        SetBlipRotation(blip, 0)
        SetBlipColour(blip, 1) -- Default color
        SetBlipAlpha(blip, 128)
        
        local centerBlip = AddBlipForCoord(district.center.x, district.center.y, district.center.z)
        SetBlipSprite(centerBlip, 1)
        SetBlipDisplay(centerBlip, 4)
        SetBlipScale(centerBlip, 0.8)
        SetBlipColour(centerBlip, 1)
        SetBlipAsShortRange(centerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(district.name)
        EndTextCommandSetBlipName(centerBlip)
        
        districtBlips[district.id] = {
            area = blip,
            center = centerBlip
        }
    end
end

-- Update district blip colors
local function UpdateDistrictBlips()
    for districtId, blips in pairs(districtBlips) do
        local controllingFaction = exports['fivem-mm']:GetDistrictControllingFaction(districtId)
        local color = 1 -- Default color (white)
        
        if controllingFaction then
            if controllingFaction == "criminal" then
                color = 1 -- Red
            elseif controllingFaction == "police" then
                color = 3 -- Blue
            elseif controllingFaction == "civilian" then
                color = 2 -- Green
            end
        end
        
        SetBlipColour(blips.area, color)
        SetBlipColour(blips.center, color)
    end
end

-- Create district markers
local function CreateDistrictMarkers()
    for _, district in pairs(Config.Districts) do
        districtMarkers[district.id] = {
            center = district.center,
            radius = district.radius,
            color = {r = 255, g = 255, b = 255, a = 100}
        }
    end
end

-- Update district markers
local function UpdateDistrictMarkers()
    for districtId, marker in pairs(districtMarkers) do
        local controllingFaction = exports['fivem-mm']:GetDistrictControllingFaction(districtId)
        
        if controllingFaction then
            if controllingFaction == "criminal" then
                marker.color = {r = 255, g = 0, b = 0, a = 100} -- Red
            elseif controllingFaction == "police" then
                marker.color = {r = 0, g = 0, b = 255, a = 100} -- Blue
            elseif controllingFaction == "civilian" then
                marker.color = {r = 0, g = 255, b = 0, a = 100} -- Green
            end
        else
            marker.color = {r = 255, g = 255, b = 255, a = 100} -- White
        end
    end
end

-- Draw district markers
local function DrawDistrictMarkers()
    for _, marker in pairs(districtMarkers) do
        DrawMarker(1, -- Type
            marker.center.x, marker.center.y, marker.center.z - 1.0, -- Position
            0.0, 0.0, 0.0, -- Direction
            0.0, 0.0, 0.0, -- Rotation
            marker.radius * 2.0, marker.radius * 2.0, 1.0, -- Scale
            marker.color.r, marker.color.g, marker.color.b, marker.color.a, -- Color
            false, -- Bob up and down
            false, -- Face camera
            2, -- P19
            false, -- Rotate
            nil, -- Texture dictionary
            nil, -- Texture name
            false -- Draw on entities
        )
    end
end

-- Check player district
local function CheckPlayerDistrict()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local newDistrict = nil
    
    for districtId, district in pairs(Config.Districts) do
        local distance = #(playerCoords - district.center)
        if distance <= district.radius then
            newDistrict = districtId
            break
        end
    end
    
    if newDistrict ~= currentDistrict then
        if currentDistrict then
            TriggerServerEvent('district:playerLeft', currentDistrict)
        end
        if newDistrict then
            TriggerServerEvent('district:playerEntered', newDistrict)
        end
        currentDistrict = newDistrict
    end
end

-- Handle district events
RegisterNetEvent('district:eventStarted')
AddEventHandler('district:eventStarted', function(districtId, eventType)
    if not Config.Districts[districtId] then return end
    
    -- Create event blip
    local eventBlip = AddBlipForCoord(Config.Districts[districtId].center.x, Config.Districts[districtId].center.y, Config.Districts[districtId].center.z)
    SetBlipSprite(eventBlip, 1)
    SetBlipDisplay(eventBlip, 4)
    SetBlipScale(eventBlip, 1.0)
    SetBlipColour(eventBlip, 1)
    SetBlipAsShortRange(eventBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Districts[districtId].name .. " - " .. eventType)
    EndTextCommandSetBlipName(eventBlip)
    
    districtEvents[districtId] = {
        type = eventType,
        blip = eventBlip,
        startTime = GetGameTimer()
    }
    
    -- Show notification
    QBCore.Functions.Notify(Config.Districts[districtId].name .. ": " .. eventType .. " event started!", "primary")
end)

-- Clean up district events
local function CleanupDistrictEvents()
    local currentTime = GetGameTimer()
    for districtId, event in pairs(districtEvents) do
        if currentTime - event.startTime > 300000 then -- 5 minutes
            RemoveBlip(event.blip)
            districtEvents[districtId] = nil
        end
    end
end

-- District monitoring thread
CreateThread(function()
    CreateDistrictBlips()
    CreateDistrictMarkers()
    
    while true do
        Wait(0)
        CheckPlayerDistrict()
        UpdateDistrictBlips()
        UpdateDistrictMarkers()
        DrawDistrictMarkers()
        CleanupDistrictEvents()
    end
end)

-- District control changed
RegisterNetEvent('district:controlChanged')
AddEventHandler('district:controlChanged', function(districtId, controllingFaction)
    if Config.Districts[districtId] then
        QBCore.Functions.Notify(Config.Districts[districtId].name .. " is now controlled by " .. controllingFaction, "primary")
    end
end)

-- Player entered district
RegisterNetEvent('district:entered')
AddEventHandler('district:entered', function(district)
    QBCore.Functions.Notify("Entered " .. district.name, "primary")
end)

-- Player left district
RegisterNetEvent('district:left')
AddEventHandler('district:left', function(districtId)
    if Config.Districts[districtId] then
        QBCore.Functions.Notify("Left " .. Config.Districts[districtId].name, "primary")
    end
end) 