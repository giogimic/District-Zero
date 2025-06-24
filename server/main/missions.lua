-- District Zero Missions Server Handler
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'

-- Mission State Management
local MissionState = {
    activeMissions = {},
    playerMissions = {},
    missionCooldowns = {},
    lastSync = 0,
    syncInterval = 3000 -- 3 seconds
}

-- Mission States
local MISSION_STATES = {
    ACTIVE = 'active',
    COMPLETED = 'completed',
    FAILED = 'failed',
    EXPIRED = 'expired'
}

-- Initialize missions from config
local function InitializeMissions()
    if not Config or not Config.Missions then
        Utils.PrintDebug('[ERROR] Config.Missions not loaded')
        return false
    end

    -- Load mission data from database
    local success = pcall(function()
        local result = MySQL.query.await('SELECT * FROM dz_missions WHERE active = 1')
        if result then
            for _, mission in ipairs(result) do
                -- Parse objectives from JSON
                local objectives = json.decode(mission.objectives or '[]')
                mission.objectives = objectives
            end
        end
    end)

    if not success then
        Utils.PrintDebug('[ERROR] Failed to load missions from database')
        return false
    end

    Utils.PrintDebug('Missions initialized successfully')
    return true
end

-- Get available missions for player
local function GetAvailableMissions(playerId, districtId)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then return {} end

    local availableMissions = {}
    local playerTeam = exports['district-zero']:GetPlayerTeam(playerId)

    if not Config or not Config.Missions then
        return availableMissions
    end

    for _, mission in pairs(Config.Missions) do
        -- Check if mission is for the correct district
        if mission.district == districtId then
            -- Check if mission type matches player's team
            if mission.type == playerTeam then
                -- Check if player is not already in a mission
                if not MissionState.playerMissions[playerId] then
                    -- Check mission cooldown
                    if not MissionState.missionCooldowns[mission.id] or 
                       os.time() > MissionState.missionCooldowns[mission.id] then
                        table.insert(availableMissions, mission)
                    end
                end
            end
        end
    end

    return availableMissions
end

-- Start mission
local function StartMission(playerId, missionId, districtId)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then 
        TriggerClientEvent('QBCore:Notify', playerId, 'Player data not found', 'error')
        return false
    end

    -- Check if player is already in a mission
    if MissionState.playerMissions[playerId] then
        TriggerClientEvent('QBCore:Notify', playerId, 'You are already in a mission', 'error')
        return false
    end

    -- Find mission in config
    local mission = nil
    for _, m in pairs(Config.Missions) do
        if m.id == missionId and m.district == districtId then
            mission = m
            break
        end
    end

    if not mission then 
        TriggerClientEvent('QBCore:Notify', playerId, 'Mission not found', 'error')
        return false
    end

    -- Check if player is in the correct district
    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
    local inDistrict = false
    
    for _, district in pairs(Config.Districts) do
        if district.id == districtId then
            for _, zone in pairs(district.zones) do
                local distance = #(playerCoords - zone.coords)
                if distance <= zone.radius then
                    inDistrict = true
                    break
                end
            end
        end
        if inDistrict then break end
    end

    if not inDistrict then
        TriggerClientEvent('QBCore:Notify', playerId, 'You must be in the mission district to start this mission', 'error')
        return false
    end

    -- Check if player has selected a team
    local playerTeam = exports['district-zero']:GetPlayerTeam(playerId)
    if not playerTeam then
        TriggerClientEvent('QBCore:Notify', playerId, 'You must select a team first', 'error')
        return false
    end

    -- Check if mission type matches player's team
    if mission.type ~= playerTeam then
        TriggerClientEvent('QBCore:Notify', playerId, 'This mission is not available for your team', 'error')
        return false
    end
    
    -- Create mission instance
    local missionInstance = {
        id = mission.id,
        title = mission.title,
        description = mission.description,
        type = mission.type,
        district = mission.district,
        objectives = mission.objectives,
        reward = mission.reward,
        timeLimit = mission.timeLimit or 300, -- 5 minutes default
        startTime = os.time(),
        endTime = os.time() + (mission.timeLimit or 300),
        player = playerId,
        state = MISSION_STATES.ACTIVE,
        completedObjectives = {},
        progress = 0
    }
    
    -- Add to active missions
    MissionState.activeMissions[missionId] = missionInstance
    MissionState.playerMissions[playerId] = missionId

    -- Save mission progress to database
    MySQL.insert.await([[
        INSERT INTO dz_mission_progress (mission_id, citizenid, status, started_at)
        VALUES (?, ?, 'active', CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE status = 'active', started_at = CURRENT_TIMESTAMP
    ]], {missionId, player.PlayerData.citizenid})

    -- Send mission data to client
    TriggerClientEvent('dz:client:missionStarted', playerId, missionInstance)
    TriggerClientEvent('QBCore:Notify', playerId, 'Mission started: ' .. mission.title, 'success')

    Utils.PrintDebug('Mission started: ' .. mission.title .. ' for player ' .. playerId)
    return true
end

-- Complete objective
local function CompleteObjective(playerId, missionId, objectiveId)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then return false end

    local mission = MissionState.activeMissions[missionId]
    if not mission or mission.player ~= playerId then
        TriggerClientEvent('QBCore:Notify', playerId, 'No active mission found', 'error')
        return false
    end
    
    local objective = mission.objectives[objectiveId]
    if not objective then
        TriggerClientEvent('QBCore:Notify', playerId, 'Invalid objective', 'error')
        return false
    end
    
    -- Check if objective is already completed
    if mission.completedObjectives[objectiveId] then
        TriggerClientEvent('QBCore:Notify', playerId, 'Objective already completed', 'info')
        return false
    end
    
    -- Mark objective as complete
    mission.completedObjectives[objectiveId] = true
    mission.progress = mission.progress + 1

    -- Check if all objectives are complete
    local allComplete = true
    for i, _ in ipairs(mission.objectives) do
        if not mission.completedObjectives[i] then
            allComplete = false
            break
        end
    end
    
    if allComplete then
        -- Complete mission
        CompleteMission(playerId, missionId)
    else
        -- Update mission progress
        TriggerClientEvent('dz:client:missionUpdated', playerId, mission)
        TriggerClientEvent('QBCore:Notify', playerId, 'Objective completed!', 'success')
    end
    
    return true
end

-- Complete mission
local function CompleteMission(playerId, missionId)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then return false end

    local mission = MissionState.activeMissions[missionId]
    if not mission then return false end
    
    -- Give rewards
    if mission.reward then
        player.Functions.AddMoney('cash', mission.reward)
    end

    -- Update district influence
    local playerTeam = exports['district-zero']:GetPlayerTeam(playerId)
    if playerTeam and mission.district then
        exports['district-zero']:UpdateDistrictInfluence(mission.district, 10)
    end

    -- Update database
    MySQL.update.await([[
        UPDATE dz_mission_progress 
        SET status = 'completed', completed_at = CURRENT_TIMESTAMP
        WHERE mission_id = ? AND citizenid = ?
    ]], {missionId, player.PlayerData.citizenid})

    -- Set mission cooldown
    MissionState.missionCooldowns[missionId] = os.time() + 300 -- 5 minutes cooldown

    -- Complete mission
    mission.state = MISSION_STATES.COMPLETED
    TriggerClientEvent('dz:client:missionCompleted', playerId, missionId, mission.reward)
    TriggerClientEvent('QBCore:Notify', playerId, 'Mission completed! Reward: $' .. mission.reward, 'success')

    -- Clean up mission
    MissionState.activeMissions[missionId] = nil
    MissionState.playerMissions[playerId] = nil

    Utils.PrintDebug('Mission completed: ' .. mission.title .. ' for player ' .. playerId)
    return true
end

-- Fail mission
local function FailMission(playerId, missionId, reason)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then return false end

    local mission = MissionState.activeMissions[missionId]
    if not mission then return false end

    -- Update database
    MySQL.update.await([[
        UPDATE dz_mission_progress 
        SET status = 'failed', completed_at = CURRENT_TIMESTAMP
        WHERE mission_id = ? AND citizenid = ?
    ]], {missionId, player.PlayerData.citizenid})

    -- Fail mission
    mission.state = MISSION_STATES.FAILED
    TriggerClientEvent('dz:client:missionFailed', playerId, missionId, reason)
    TriggerClientEvent('QBCore:Notify', playerId, 'Mission failed: ' .. reason, 'error')

    -- Clean up mission
    MissionState.activeMissions[missionId] = nil
    MissionState.playerMissions[playerId] = nil

    Utils.PrintDebug('Mission failed: ' .. mission.title .. ' for player ' .. playerId .. ' - ' .. reason)
    return true
end

-- Check mission timeouts
local function CheckMissionTimeouts()
    local currentTime = os.time()
    
    for missionId, mission in pairs(MissionState.activeMissions) do
        if mission.state == MISSION_STATES.ACTIVE and currentTime >= mission.endTime then
            FailMission(mission.player, missionId, "Time's up!")
        end
    end
end

-- Sync mission state to clients
local function SyncMissionState()
    local currentTime = GetGameTimer()
    
    if currentTime - MissionState.lastSync < MissionState.syncInterval then
        return
    end
    
    MissionState.lastSync = currentTime
    
    -- Send mission state to all clients
    for _, playerId in ipairs(GetPlayers()) do
        local playerMission = MissionState.playerMissions[playerId]
        if playerMission then
            local mission = MissionState.activeMissions[playerMission]
            if mission then
                TriggerClientEvent('dz:client:mission:sync', playerId, mission)
            end
        end
    end
end

-- Event handlers
RegisterNetEvent('dz:server:acceptMission', function(missionId, districtId)
    local source = source
    StartMission(source, missionId, districtId)
end)

RegisterNetEvent('dz:server:capturePoint', function(missionId, objectiveId)
    local source = source
    CompleteObjective(source, missionId, objectiveId)
end)

RegisterNetEvent('dz:server:mission:getAvailable', function(districtId)
    local source = source
    local availableMissions = GetAvailableMissions(source, districtId)
    TriggerClientEvent('dz:client:mission:available', source, availableMissions)
end)

-- Player cleanup
AddEventHandler('playerDropped', function()
    local source = source
    
    -- Fail any active mission
    local missionId = MissionState.playerMissions[source]
    if missionId then
        FailMission(source, missionId, 'Player disconnected')
    end
end)

-- Mission monitoring thread
CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        CheckMissionTimeouts()
    end
end)

-- State sync thread
CreateThread(function()
    while true do
        Wait(MissionState.syncInterval)
        SyncMissionState()
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for database to be ready
    CreateThread(function()
        Wait(5000) -- Wait for database initialization
        
        if not InitializeMissions() then
            print('^1[District Zero] Failed to initialize missions^7')
            return
        end
        
        print('^2[District Zero] Missions system initialized successfully^7')
    end)
end)

-- Exports
exports('GetActiveMissions', function()
    return MissionState.activeMissions
end)

exports('GetPlayerMission', function(playerId)
    return MissionState.playerMissions[playerId]
end)

exports('GetAvailableMissions', function(playerId, districtId)
    return GetAvailableMissions(playerId, districtId)
end)

exports('StartMission', function(playerId, missionId, districtId)
    return StartMission(playerId, missionId, districtId)
end)

exports('CompleteMission', function(playerId, missionId)
    return CompleteMission(playerId, missionId)
end)

exports('FailMission', function(playerId, missionId, reason)
    return FailMission(playerId, missionId, reason)
end) 