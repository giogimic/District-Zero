local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- State Management
local State = {
    currentDistrict = nil,
    districtBlips = {},
    districtMarkers = {},
    districtEvents = {},
    isInDistrict = false
}

-- Create district blips
local function CreateDistrictBlip(district)
    if not district or not district.center then
        Utils.HandleError('Invalid district data for blip creation', 'CreateDistrictBlip')
        return nil
    end

    local blip = AddBlipForRadius(district.center.x, district.center.y, district.center.z, district.radius)
    SetBlipColour(blip, district.color or 1)
    SetBlipAlpha(blip, 128)
    
    local centerBlip = AddBlipForCoord(district.center.x, district.center.y, district.center.z)
    SetBlipSprite(centerBlip, 1)
    SetBlipColour(centerBlip, district.color or 1)
    SetBlipScale(centerBlip, 0.8)
    SetBlipAsShortRange(centerBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(district.name)
    EndTextCommandSetBlipName(centerBlip)
    
    return {radius = blip, center = centerBlip}
end

-- Update district blip colors
local function UpdateDistrictBlips(districts)
    Utils.SafeCall(function()
        -- Remove existing blips
        for _, blips in pairs(State.districtBlips) do
            RemoveBlip(blips.radius)
            RemoveBlip(blips.center)
        end
        State.districtBlips = {}
        
        -- Create new blips
        for id, district in pairs(districts) do
            State.districtBlips[id] = CreateDistrictBlip(district)
        end
    end, 'UpdateDistrictBlips')
end

-- Create district markers
local function CreateDistrictMarkers()
    for _, district in pairs(Config.Districts) do
        State.districtMarkers[district.id] = {
            center = district.center,
            radius = district.radius,
            color = {r = 255, g = 255, b = 255, a = 100}
        }
    end
end

-- Update district markers
local function UpdateDistrictMarkers()
    for districtId, marker in pairs(State.districtMarkers) do
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
    for _, marker in pairs(State.districtMarkers) do
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
local function CheckDistrictBoundaries()
    Utils.SafeCall(function()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        
        for id, district in pairs(Config.Districts) do
            local distance = #(coords - district.center)
            if distance <= district.radius then
                if not State.isInDistrict or State.currentDistrict ~= id then
                    State.currentDistrict = id
                    State.isInDistrict = true
                    Events.TriggerEvent('dz:client:district:entered', 'client', id)
                end
                return
            end
        end
        
        if State.isInDistrict then
            State.isInDistrict = false
            State.currentDistrict = nil
            Events.TriggerEvent('dz:client:district:exited', 'client')
        end
    end, 'CheckDistrictBoundaries')
end

-- Handle district events
Events.RegisterEvent('dz:client:district:eventStarted', function(districtId, eventType)
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
    
    State.districtEvents[districtId] = {
        type = eventType,
        blip = eventBlip,
        startTime = GetGameTimer()
    }
    
    -- Show notification
    QBX.Functions.Notify(Config.Districts[districtId].name .. ": " .. eventType .. " event started!", "primary")
end)

-- Clean up district events
local function CleanupDistrictEvents()
    local currentTime = GetGameTimer()
    for districtId, event in pairs(State.districtEvents) do
        if currentTime - event.startTime > 300000 then -- 5 minutes
            RemoveBlip(event.blip)
            State.districtEvents[districtId] = nil
        end
    end
end

-- District monitoring thread
CreateThread(function()
    CreateDistrictBlip(Config.Districts[1]) -- Assuming the first district is created
    CreateDistrictMarkers()
    
    while true do
        Wait(0)
        CheckDistrictBoundaries()
        UpdateDistrictMarkers()
        DrawDistrictMarkers()
        CleanupDistrictEvents()
    end
end)

-- District control changed
Events.RegisterEvent('dz:client:district:controlChanged', function(districtId, controllingFaction)
    if Config.Districts[districtId] then
        QBX.Functions.Notify(Config.Districts[districtId].name .. " is now controlled by " .. controllingFaction, "primary")
    end
end)

-- Player entered district
Events.RegisterEvent('dz:client:district:entered', function(districtId)
    Utils.SafeCall(function()
        if not districtId then
            Utils.HandleError('Invalid district ID on enter', 'DistrictEntered')
            return
        end

        local district = Config.Districts[districtId]
        if district then
            QBX.Functions.Notify(Lang:t('info.entered_district', {district = district.name}), 'info')
        end
    end, 'DistrictEntered')
end)

-- Player left district
Events.RegisterEvent('dz:client:district:exited', function()
    QBX.Functions.Notify(Lang:t('info.exited_district'), 'info')
end)

-- Event handlers
Events.RegisterEvent('dz:client:district:updateBlips', function(districts)
    UpdateDistrictBlips(districts)
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        currentDistrict = nil,
        districtBlips = {},
        districtMarkers = {},
        districtEvents = {},
        isInDistrict = false
    }
end)

-- Register NUI cleanup handler
RegisterCleanup('nui', function()
    -- Remove all blips
    for _, blips in pairs(State.districtBlips) do
        RemoveBlip(blips.radius)
        RemoveBlip(blips.center)
    end
    
    -- Remove event blips
    for _, event in pairs(State.districtEvents) do
        RemoveBlip(event.blip)
    end
end)

-- Exports
exports('GetCurrentDistrict', function()
    return State.currentDistrict
end)

exports('IsInDistrict', function()
    return State.isInDistrict
end) 