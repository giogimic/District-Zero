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

-- District Control System
-- Version: 1.0.0

-- District Control State
local DistrictControl = {
    currentDistrict = nil,
    controlPoints = {},
    captureProgress = {},
    influence = {},
    lastUpdate = 0
}

-- Control Point Capture System
local ControlPointSystem = {
    captureTime = 60000, -- 60 seconds to capture
    captureRadius = 50.0,
    influenceRadius = 100.0,
    captureBlips = {},
    captureMarkers = {}
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

-- Initialize control points for a district
local function InitializeControlPoints(district)
    if not district or not district.controlPoints then
        return false
    end
    
    DistrictControl.controlPoints[district.id] = {}
    
    for _, point in pairs(district.controlPoints) do
        DistrictControl.controlPoints[district.id][point.id] = {
            id = point.id,
            name = point.name,
            coords = point.coords,
            radius = point.radius,
            influence = point.influence,
            currentTeam = 'neutral',
            captureProgress = 0,
            lastCaptured = 0,
            isBeingCaptured = false,
            capturingTeam = nil,
            captureStartTime = 0
        }
        
        -- Create control point blip
        CreateControlPointBlip(point)
    end
    
    return true
end

-- Create control point blip
local function CreateControlPointBlip(point)
    local blip = AddBlipForCoord(point.coords.x, point.coords.y, point.coords.z)
    if blip and blip ~= 0 then
        SetBlipSprite(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 0) -- Neutral color
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(point.name .. " (Control Point)")
        EndTextCommandSetBlipName(blip)
        
        ControlPointSystem.captureBlips[point.id] = blip
    end
end

-- Update control point blip color based on team
local function UpdateControlPointBlip(pointId, team)
    local blip = ControlPointSystem.captureBlips[pointId]
    if blip and blip ~= 0 then
        local color = 0 -- Neutral
        if team == 'pvp' then
            color = 1 -- Red
        elseif team == 'pve' then
            color = 3 -- Blue
        end
        SetBlipColour(blip, color)
    end
end

-- Check if player is in capture range
local function IsInCaptureRange(playerCoords, pointCoords, radius)
    local distance = #(playerCoords - pointCoords)
    return distance <= radius
end

-- Start capture process
local function StartCapture(pointId, team)
    local district = DistrictControl.currentDistrict
    if not district or not DistrictControl.controlPoints[district.id] then
        return false
    end
    
    local point = DistrictControl.controlPoints[district.id][pointId]
    if not point then
        return false
    end
    
    -- Check if point is already being captured
    if point.isBeingCaptured then
        return false
    end
    
    -- Check if point is already controlled by the team
    if point.currentTeam == team then
        return false
    end
    
    -- Start capture
    point.isBeingCaptured = true
    point.capturingTeam = team
    point.captureStartTime = GetGameTimer()
    point.captureProgress = 0
    
    -- Notify server
    TriggerServerEvent('dz:server:controlPoint:startCapture', district.id, pointId, team)
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Starting capture of ' .. point.name, 'info')
    end
    
    return true
end

-- Update capture progress
local function UpdateCaptureProgress(pointId)
    local district = DistrictControl.currentDistrict
    if not district or not DistrictControl.controlPoints[district.id] then
        return
    end
    
    local point = DistrictControl.controlPoints[district.id][pointId]
    if not point or not point.isBeingCaptured then
        return
    end
    
    local currentTime = GetGameTimer()
    local elapsed = currentTime - point.captureStartTime
    local progress = math.min((elapsed / ControlPointSystem.captureTime) * 100, 100)
    
    point.captureProgress = progress
    
    -- Check if capture is complete
    if progress >= 100 then
        CompleteCapture(pointId)
    end
end

-- Complete capture
local function CompleteCapture(pointId)
    local district = DistrictControl.currentDistrict
    if not district or not DistrictControl.controlPoints[district.id] then
        return
    end
    
    local point = DistrictControl.controlPoints[district.id][pointId]
    if not point then
        return
    end
    
    local capturingTeam = point.capturingTeam
    
    -- Update point ownership
    point.currentTeam = capturingTeam
    point.isBeingCaptured = false
    point.capturingTeam = nil
    point.captureProgress = 0
    point.lastCaptured = GetGameTimer()
    
    -- Update blip color
    UpdateControlPointBlip(pointId, capturingTeam)
    
    -- Notify server
    TriggerServerEvent('dz:server:controlPoint:captured', district.id, pointId, capturingTeam)
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify(point.name .. ' captured by ' .. (capturingTeam == 'pvp' and 'PvP' or 'PvE') .. '!', 'success')
    end
    
    -- Update district influence
    UpdateDistrictInfluence(district.id)
end

-- Cancel capture
local function CancelCapture(pointId)
    local district = DistrictControl.currentDistrict
    if not district or not DistrictControl.controlPoints[district.id] then
        return
    end
    
    local point = DistrictControl.controlPoints[district.id][pointId]
    if not point then
        return
    end
    
    point.isBeingCaptured = false
    point.capturingTeam = nil
    point.captureProgress = 0
    
    -- Notify server
    TriggerServerEvent('dz:server:controlPoint:cancelCapture', district.id, pointId)
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Capture of ' .. point.name .. ' cancelled', 'error')
    end
end

-- Update district influence
local function UpdateDistrictInfluence(districtId)
    local district = DistrictControl.currentDistrict
    if not district or district.id ~= districtId then
        return
    end
    
    local pvpPoints = 0
    local pvePoints = 0
    local totalPoints = 0
    
    for _, point in pairs(DistrictControl.controlPoints[districtId]) do
        totalPoints = totalPoints + 1
        if point.currentTeam == 'pvp' then
            pvpPoints = pvpPoints + 1
        elseif point.currentTeam == 'pve' then
            pvePoints = pvePoints + 1
        end
    end
    
    if totalPoints > 0 then
        DistrictControl.influence[districtId] = {
            pvp = math.floor((pvpPoints / totalPoints) * 100),
            pve = math.floor((pvePoints / totalPoints) * 100)
        }
        
        -- Notify server of influence change
        TriggerServerEvent('dz:server:district:influenceUpdate', districtId, DistrictControl.influence[districtId])
    end
end

-- Draw capture progress
local function DrawCaptureProgress()
    local district = DistrictControl.currentDistrict
    if not district or not DistrictControl.controlPoints[district.id] then
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, point in pairs(DistrictControl.controlPoints[district.id]) do
        if point.isBeingCaptured then
            local distance = #(playerCoords - point.coords)
            if distance <= ControlPointSystem.influenceRadius then
                -- Draw 3D text with capture progress
                local progressText = string.format("Capturing: %d%%", math.floor(point.captureProgress))
                local teamText = point.capturingTeam == 'pvp' and 'PvP' or 'PvE'
                
                if QBX and QBX.Functions then
                    QBX.Functions.DrawText3D(point.coords.x, point.coords.y, point.coords.z + 2.0, progressText)
                    QBX.Functions.DrawText3D(point.coords.x, point.coords.y, point.coords.z + 1.5, teamText)
                end
                
                -- Draw capture marker
                DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                    point.radius * 2, point.radius * 2, 1.0, 
                    point.capturingTeam == 'pvp' and 255 or 0, 
                    point.capturingTeam == 'pve' and 255 or 0, 
                    0, 100, false, true, 2, false, nil, nil, false)
            end
        end
    end
end

-- Check capture interactions
local function CheckCaptureInteractions()
    local district = DistrictControl.currentDistrict
    if not district or not DistrictControl.controlPoints[district.id] then
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    local currentTeam = State.currentTeam
    
    if not currentTeam then
        return
    end
    
    for pointId, point in pairs(DistrictControl.controlPoints[district.id]) do
        if IsInCaptureRange(playerCoords, point.coords, point.radius) then
            -- Check if point can be captured
            if point.currentTeam ~= currentTeam and not point.isBeingCaptured then
                if QBX and QBX.Functions then
                    QBX.Functions.DrawText3D(point.coords.x, point.coords.y, point.coords.z + 1.0, 'Press [E] to capture')
                end
                
                if IsControlJustPressed(0, 38) then -- E key
                    StartCapture(pointId, currentTeam)
                end
            elseif point.isBeingCaptured and point.capturingTeam ~= currentTeam then
                -- Show counter-capture option
                if QBX and QBX.Functions then
                    QBX.Functions.DrawText3D(point.coords.x, point.coords.y, point.coords.z + 1.0, 'Press [F] to counter-capture')
                end
                
                if IsControlJustPressed(0, 23) then -- F key
                    StartCapture(pointId, currentTeam)
                end
            end
        end
    end
end

-- Main district control thread
CreateThread(function()
    while true do
        Wait(0)
        
        if DistrictControl.currentDistrict then
            DrawCaptureProgress()
            CheckCaptureInteractions()
        end
    end
end)

-- Capture progress update thread
CreateThread(function()
    while true do
        Wait(100) -- Update every 100ms
        
        if DistrictControl.currentDistrict then
            local district = DistrictControl.currentDistrict
            if DistrictControl.controlPoints[district.id] then
                for pointId, _ in pairs(DistrictControl.controlPoints[district.id]) do
                    UpdateCaptureProgress(pointId)
                end
            end
        end
    end
end)

-- Event handlers
RegisterNetEvent('dz:client:district:controlPoint:update', function(districtId, pointId, data)
    if not DistrictControl.controlPoints[districtId] then
        DistrictControl.controlPoints[districtId] = {}
    end
    
    DistrictControl.controlPoints[districtId][pointId] = data
    
    -- Update blip color
    UpdateControlPointBlip(pointId, data.currentTeam)
end)

RegisterNetEvent('dz:client:district:influence:update', function(districtId, influence)
    DistrictControl.influence[districtId] = influence
end)

-- Exports
exports('GetDistrictControl', function()
    return DistrictControl
end)

exports('GetControlPoints', function(districtId)
    return DistrictControl.controlPoints[districtId]
end)

exports('GetDistrictInfluence', function(districtId)
    return DistrictControl.influence[districtId]
end)

-- Initialize when entering district
RegisterNetEvent('dz:client:district:entered', function(district)
    DistrictControl.currentDistrict = district
    InitializeControlPoints(district)
    
    -- Request current control point status from server
    TriggerServerEvent('dz:server:district:requestControlPoints', district.id)
end)

-- Cleanup when leaving district
RegisterNetEvent('dz:client:district:left', function()
    DistrictControl.currentDistrict = nil
    DistrictControl.controlPoints = {}
    DistrictControl.captureProgress = {}
    
    -- Remove all capture blips
    for _, blip in pairs(ControlPointSystem.captureBlips) do
        if blip and blip ~= 0 then
            RemoveBlip(blip)
        end
    end
    ControlPointSystem.captureBlips = {}
end) 