-- Missions Client Handler
local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Mission State
local State = {
    activeMission = nil,
    missionVehicle = nil,
    missionBlips = {},
    missionMarkers = {},
    isInMission = false,
    missionTimer = 0,
    missionStartTime = 0
}

-- Event Validation
local function ValidateEvent(eventName, data)
    if not eventName then
        Utils.HandleError('Event name is required', 'VALIDATION', 'ValidateEvent')
        return false
    end
    
    if not data then
        Utils.HandleError('Event data is required', 'VALIDATION', 'ValidateEvent')
        return false
    end
    
    return true
end

-- Initialize mission system
CreateThread(function()
    while true do
        Wait(0)
        if State.activeMission then
            DrawMissionUI()
        end
    end
end)

-- Handle mission start
Events.RegisterEvent('dz:client:mission:start', function(missionData)
    if not ValidateEvent('dz:client:mission:start', missionData) then return end
    
    if State.isInMission then
        Utils.SendNotification("error", "You are already in a mission!")
        return
    end

    State.activeMission = missionData
    State.isInMission = true
    State.missionStartTime = GetGameTimer()
    State.missionTimer = missionData.timeLimit

    -- Create mission blips and markers
    CreateMissionBlips(missionData)
    CreateMissionMarkers(missionData)

    -- Start mission timer
    StartMissionTimer()

    -- Show mission UI
    Events.TriggerEvent('dz:client:ui:showMission', 'client', missionData)

    Utils.SendNotification("success", "Mission started: " .. missionData.label)
end)

-- Handle mission completion
Events.RegisterEvent('dz:client:mission:completed', function(missionId, reward)
    if State.activeMission and State.activeMission.id == missionId then
        Utils.SendNotification("success", "Mission completed! Reward: $" .. reward.money)
        CleanupMission()
    end
end)

-- Handle mission failure
Events.RegisterEvent('dz:client:mission:failed', function(missionId, reason)
    if State.activeMission and State.activeMission.id == missionId then
        Utils.SendNotification("error", "Mission failed: " .. reason)
        CleanupMission()
    end
end)

-- Handle player joining mission
Events.RegisterEvent('dz:client:mission:playerJoined', function(missionId, player)
    if State.activeMission and State.activeMission.id == missionId then
        local playerName = GetPlayerName(player)
        Utils.SendNotification("info", playerName .. " joined the mission")
    end
end)

-- Draw mission UI
function DrawMissionUI()
    if not State.activeMission then return end
    
    local mission = Config.Missions[State.activeMission.type][State.activeMission.id]
    local timeLeft = State.missionTimer - (GetGameTimer() - State.missionStartTime) / 1000
    
    -- Draw mission info
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(mission.name .. "\nTime left: " .. timeLeft .. "s")
    DrawText(0.5, 0.05)
    
    -- Draw mission description
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 200)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(mission.description)
    DrawText(0.5, 0.1)
end

-- Spawn mission vehicle
function SpawnMissionVehicle(vehicleModel)
    -- Request model
    local model = GetHashKey(vehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    
    -- Get player position
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    -- Spawn vehicle
    State.missionVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(playerPed, State.missionVehicle, -1)
    SetVehicleEngineOn(State.missionVehicle, true, true, false)
    
    -- Set vehicle properties
    SetVehicleDoorsLocked(State.missionVehicle, 2)
    SetVehicleHasBeenOwnedByPlayer(State.missionVehicle, true)
    SetEntityAsMissionEntity(State.missionVehicle, true, true)
    
    -- Release model
    SetModelAsNoLongerNeeded(model)
end

-- Create mission blips
function CreateMissionBlips(mission)
    -- Create start blip
    local startBlip = AddBlipForCoord(mission.location.x, mission.location.y, mission.location.z)
    SetBlipSprite(startBlip, 1)
    SetBlipColour(startBlip, 2)
    SetBlipScale(startBlip, 1.0)
    SetBlipAsShortRange(startBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mission Start")
    EndTextCommandSetBlipName(startBlip)
    table.insert(State.missionBlips, startBlip)
    
    -- Create objective blips
    local missionData = Config.Missions[mission.type][mission.id]
    for i, location in ipairs(missionData.locations) do
        if i > 1 then -- Skip first location as it's the start
            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 5)
            SetBlipScale(blip, 1.0)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Mission Objective " .. (i - 1))
            EndTextCommandSetBlipName(blip)
            table.insert(State.missionBlips, blip)
        end
    end
end

-- Clean up mission
function CleanupMission()
    -- Remove blips
    for _, blip in pairs(State.missionBlips) do
        RemoveBlip(blip)
    end
    State.missionBlips = {}
    
    -- Remove markers
    State.missionMarkers = {}
    
    -- Reset state
    State.activeMission = nil
    State.missionVehicle = nil
    State.isInMission = false
    State.missionTimer = 0
    State.missionStartTime = 0
    
    -- Hide UI
    Events.TriggerEvent('dz:client:ui:hideMission', 'client')
end

-- Mission Timer
function StartMissionTimer()
    CreateThread(function()
        while State.isInMission do
            Wait(1000)
            State.missionTimer = State.missionTimer - 1
            
            if State.missionTimer <= 0 then
                Events.TriggerEvent('dz:client:mission:failed', 'client', State.activeMission.id, "Time's up!")
                break
            end
            
            -- Update UI
            Events.TriggerEvent('dz:client:ui:updateTimer', 'client', State.missionTimer)
        end
    end)
end

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        activeMission = nil,
        missionVehicle = nil,
        missionBlips = {},
        missionMarkers = {},
        isInMission = false,
        missionTimer = 0,
        missionStartTime = 0
    }
end)

-- Register NUI cleanup handler
RegisterCleanup('nui', function()
    -- Remove all blips
    for _, blip in pairs(State.missionBlips) do
        RemoveBlip(blip)
    end
    
    -- Delete mission vehicle
    if State.missionVehicle and DoesEntityExist(State.missionVehicle) then
        DeleteEntity(State.missionVehicle)
    end
    
    -- Hide UI
    Events.TriggerEvent('dz:client:ui:hideMission', 'client')
end)

-- Exports
exports('GetActiveMission', function()
    return State.activeMission
end)

exports('GetMissionVehicle', function()
    return State.missionVehicle
end)

exports('IsInMission', function()
    return State.isInMission
end)

exports('GetMissionTimer', function()
    return State.missionTimer
end)

-- Export Documentation
--[[
Mission System Exports:

GetActiveMission()
- Returns the currently active mission data
- Returns: table or nil

GetMissionVehicle()
- Returns the vehicle associated with the current mission
- Returns: entity or nil

IsInMission()
- Returns whether the player is currently in a mission
- Returns: boolean

GetMissionTimer()
- Returns the remaining time for the current mission
- Returns: number

Usage:
- Check active mission: exports['district_zero']:GetActiveMission()
- Get mission vehicle: exports['district_zero']:GetMissionVehicle()
- Check mission status: exports['district_zero']:IsInMission()
- Get mission timer: exports['district_zero']:GetMissionTimer()
]] 