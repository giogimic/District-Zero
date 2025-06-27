-- Missions Client Handler
local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Mission System Enhancement
-- Version: 1.0.0

-- Mission System State
local MissionSystem = {
    activeMissions = {},
    completedMissions = {},
    missionCooldowns = {},
    missionProgress = {},
    lastUpdate = 0
}

-- Mission Configuration
local MissionConfig = {
    maxActiveMissions = 3,
    missionCooldown = 300000, -- 5 minutes
    objectiveUpdateInterval = 1000, -- 1 second
    rewardMultiplier = 1.0,
    difficultyScaling = true
}

-- Mission Types and Objectives
local MissionTypes = {
    CAPTURE_POINTS = 'capture_points',
    DEFEND_POINTS = 'defend_points',
    ELIMINATE_PLAYERS = 'eliminate_players',
    SURVIVE_TIME = 'survive_time',
    COLLECT_ITEMS = 'collect_items',
    ESCORT_TARGET = 'escort_target'
}

-- Mission Difficulty Levels
local MissionDifficulty = {
    EASY = {
        name = 'Easy',
        multiplier = 1.0,
        timeLimit = 600000, -- 10 minutes
        rewardMultiplier = 1.0
    },
    MEDIUM = {
        name = 'Medium',
        multiplier = 1.5,
        timeLimit = 900000, -- 15 minutes
        rewardMultiplier = 1.5
    },
    HARD = {
        name = 'Hard',
        multiplier = 2.0,
        timeLimit = 1200000, -- 20 minutes
        rewardMultiplier = 2.0
    }
}

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
local function InitializeMissionSystem()
    MissionSystem.activeMissions = {}
    MissionSystem.completedMissions = {}
    MissionSystem.missionCooldowns = {}
    MissionSystem.missionProgress = {}
    
    print('^2[District Zero] ^7Mission system initialized')
end

-- Generate mission objectives
local function GenerateMissionObjectives(missionType, difficulty, districtId)
    local objectives = {}
    local difficultyConfig = MissionDifficulty[difficulty]
    
    if missionType == MissionTypes.CAPTURE_POINTS then
        local targetPoints = math.floor(2 + (difficultyConfig.multiplier * 2))
        objectives = {
            type = 'capture_points',
            target = targetPoints,
            current = 0,
            description = string.format('Capture %d control points in %s', targetPoints, districtId),
            reward = 1000 * difficultyConfig.rewardMultiplier
        }
    elseif missionType == MissionTypes.DEFEND_POINTS then
        local targetTime = math.floor(300 + (difficultyConfig.multiplier * 300)) -- 5-15 minutes
        objectives = {
            type = 'defend_points',
            target = targetTime,
            current = 0,
            description = string.format('Defend control points for %d seconds', targetTime),
            reward = 1500 * difficultyConfig.rewardMultiplier
        }
    elseif missionType == MissionTypes.ELIMINATE_PLAYERS then
        local targetKills = math.floor(3 + (difficultyConfig.multiplier * 3))
        objectives = {
            type = 'eliminate_players',
            target = targetKills,
            current = 0,
            description = string.format('Eliminate %d enemy players', targetKills),
            reward = 2000 * difficultyConfig.rewardMultiplier
        }
    elseif missionType == MissionTypes.SURVIVE_TIME then
        local targetTime = math.floor(600 + (difficultyConfig.multiplier * 600)) -- 10-30 minutes
        objectives = {
            type = 'survive_time',
            target = targetTime,
            current = 0,
            description = string.format('Survive in district for %d seconds', targetTime),
            reward = 1200 * difficultyConfig.rewardMultiplier
        }
    end
    
    return objectives
end

-- Create new mission
local function CreateMission(missionType, difficulty, districtId)
    local missionId = Utils.GenerateId()
    local objectives = GenerateMissionObjectives(missionType, difficulty, districtId)
    
    local mission = {
        id = missionId,
        type = missionType,
        difficulty = difficulty,
        districtId = districtId,
        objectives = objectives,
        startTime = GetGameTimer(),
        timeLimit = MissionDifficulty[difficulty].timeLimit,
        status = 'active',
        progress = 0,
        rewards = {
            money = objectives.reward,
            exp = math.floor(objectives.reward * 0.5),
            items = {}
        }
    }
    
    MissionSystem.activeMissions[missionId] = mission
    MissionSystem.missionProgress[missionId] = 0
    
    -- Notify server
    TriggerServerEvent('dz:server:mission:created', mission)
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('New mission started: ' .. objectives.description, 'info')
    end
    
    return mission
end

-- Update mission progress
local function UpdateMissionProgress(missionId, progress, objectiveType)
    local mission = MissionSystem.activeMissions[missionId]
    if not mission then
        return false
    end
    
    local objective = mission.objectives
    if objective.type ~= objectiveType then
        return false
    end
    
    objective.current = math.min(objective.current + progress, objective.target)
    mission.progress = (objective.current / objective.target) * 100
    
    -- Check if mission is complete
    if objective.current >= objective.target then
        CompleteMission(missionId)
        return true
    end
    
    -- Update server
    TriggerServerEvent('dz:server:mission:progress', missionId, objective.current, mission.progress)
    
    return true
end

-- Complete mission
local function CompleteMission(missionId)
    local mission = MissionSystem.activeMissions[missionId]
    if not mission then
        return false
    end
    
    mission.status = 'completed'
    mission.completionTime = GetGameTimer()
    
    -- Move to completed missions
    MissionSystem.completedMissions[missionId] = mission
    MissionSystem.activeMissions[missionId] = nil
    
    -- Set cooldown
    MissionSystem.missionCooldowns[mission.type] = GetGameTimer() + MissionConfig.missionCooldown
    
    -- Award rewards
    AwardMissionRewards(mission)
    
    -- Notify server
    TriggerServerEvent('dz:server:mission:completed', mission)
    
    -- Show completion notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Mission completed! Reward: $' .. mission.rewards.money .. ' + ' .. mission.rewards.exp .. ' EXP', 'success')
    end
    
    return true
end

-- Award mission rewards
local function AwardMissionRewards(mission)
    -- This will be handled by the server
    TriggerServerEvent('dz:server:mission:claimRewards', mission.id, mission.rewards)
end

-- Check mission cooldown
local function IsMissionOnCooldown(missionType)
    local cooldownTime = MissionSystem.missionCooldowns[missionType]
    if not cooldownTime then
        return false
    end
    
    return GetGameTimer() < cooldownTime
end

-- Get available missions
local function GetAvailableMissions(districtId)
    local availableMissions = {}
    local currentTeam = State.currentTeam
    
    if not currentTeam then
        return availableMissions
    end
    
    -- Generate available missions based on district and team
    local missionTypes = {
        MissionTypes.CAPTURE_POINTS,
        MissionTypes.DEFEND_POINTS,
        MissionTypes.ELIMINATE_PLAYERS,
        MissionTypes.SURVIVE_TIME
    }
    
    for _, missionType in ipairs(missionTypes) do
        if not IsMissionOnCooldown(missionType) then
            for difficulty, _ in pairs(MissionDifficulty) do
                local mission = {
                    type = missionType,
                    difficulty = difficulty,
                    districtId = districtId,
                    objectives = GenerateMissionObjectives(missionType, difficulty, districtId)
                }
                table.insert(availableMissions, mission)
            end
        end
    end
    
    return availableMissions
end

-- Mission objective tracking
local function TrackMissionObjectives()
    for missionId, mission in pairs(MissionSystem.activeMissions) do
        if mission.status == 'active' then
            local objective = mission.objectives
            
            -- Check time limit
            local elapsed = GetGameTimer() - mission.startTime
            if elapsed > mission.timeLimit then
                FailMission(missionId, 'Time limit exceeded')
                goto continue
            end
            
            -- Update specific objective types
            if objective.type == MissionTypes.SURVIVE_TIME then
                local surviveTime = math.floor(elapsed / 1000) -- Convert to seconds
                if surviveTime > objective.current then
                    UpdateMissionProgress(missionId, surviveTime - objective.current, MissionTypes.SURVIVE_TIME)
                end
            end
            
            ::continue::
        end
    end
end

-- Fail mission
local function FailMission(missionId, reason)
    local mission = MissionSystem.activeMissions[missionId]
    if not mission then
        return false
    end
    
    mission.status = 'failed'
    mission.failReason = reason
    mission.failTime = GetGameTimer()
    
    -- Remove from active missions
    MissionSystem.activeMissions[missionId] = nil
    
    -- Notify server
    TriggerServerEvent('dz:server:mission:failed', missionId, reason)
    
    -- Show failure notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Mission failed: ' .. reason, 'error')
    end
    
    return true
end

-- Event handlers for mission updates
RegisterNetEvent('dz:client:mission:update', function(missionId, data)
    if MissionSystem.activeMissions[missionId] then
        for key, value in pairs(data) do
            MissionSystem.activeMissions[missionId][key] = value
        end
    end
end)

RegisterNetEvent('dz:client:mission:progress', function(missionId, progress, objectiveType)
    UpdateMissionProgress(missionId, progress, objectiveType)
end)

RegisterNetEvent('dz:client:mission:completed', function(missionId)
    CompleteMission(missionId)
end)

RegisterNetEvent('dz:client:mission:failed', function(missionId, reason)
    FailMission(missionId, reason)
end)

-- Mission objective update thread
CreateThread(function()
    while true do
        Wait(MissionConfig.objectiveUpdateInterval)
        TrackMissionObjectives()
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        InitializeMissionSystem()
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
exports('GetActiveMissions', function()
    return MissionSystem.activeMissions
end)

exports('GetCompletedMissions', function()
    return MissionSystem.completedMissions
end)

exports('CreateMission', function(missionType, difficulty, districtId)
    return CreateMission(missionType, difficulty, districtId)
end)

exports('UpdateMissionProgress', function(missionId, progress, objectiveType)
    return UpdateMissionProgress(missionId, progress, objectiveType)
end)

exports('GetAvailableMissions', function(districtId)
    return GetAvailableMissions(districtId)
end)

exports('IsMissionOnCooldown', function(missionType)
    return IsMissionOnCooldown(missionType)
end)

-- Export Documentation
--[[
Mission System Exports:

GetActiveMissions()
- Returns the currently active missions
- Returns: table

GetCompletedMissions()
- Returns the completed missions
- Returns: table

CreateMission(missionType, difficulty, districtId)
- Creates a new mission
- Parameters: missionType (string), difficulty (string), districtId (string)
- Returns: table

UpdateMissionProgress(missionId, progress, objectiveType)
- Updates the progress of a mission objective
- Parameters: missionId (string), progress (number), objectiveType (string)
- Returns: boolean

GetAvailableMissions(districtId)
- Returns available missions for a district
- Parameters: districtId (string)
- Returns: table

IsMissionOnCooldown(missionType)
- Checks if a mission is on cooldown
- Parameters: missionType (string)
- Returns: boolean

Usage:
- Get active missions: exports['district_zero']:GetActiveMissions()
- Get completed missions: exports['district_zero']:GetCompletedMissions()
- Create a new mission: exports['district_zero']:CreateMission(missionType, difficulty, districtId)
- Update mission progress: exports['district_zero']:UpdateMissionProgress(missionId, progress, objectiveType)
- Get available missions: exports['district_zero']:GetAvailableMissions(districtId)
- Check mission cooldown: exports['district_zero']:IsMissionOnCooldown(missionType)
]] 