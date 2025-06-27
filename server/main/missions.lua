-- Mission System (Server)
-- Version: 1.0.0

-- Mission System State
local MissionSystem = {
    activeMissions = {},
    missionHistory = {},
    missionQueue = {},
    lastMissionTime = 0
}

-- Mission Configuration
local MissionConfig = {
    maxActiveMissions = 3,
    missionCooldown = 300000, -- 5 minutes
    rewardMultiplier = 1.0,
    difficultyScaling = true,
    teamBonus = 1.2 -- 20% bonus for team missions
}

-- Mission Types
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

-- Initialize mission system
local function InitializeMissionSystem()
    MissionSystem.activeMissions = {}
    MissionSystem.missionHistory = {}
    MissionSystem.missionQueue = {}
    
    print('^2[District Zero] ^7Server mission system initialized')
end

-- Create mission for player
local function CreatePlayerMission(playerId, missionType, difficulty, districtId)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then
        return false, 'Player not found'
    end
    
    -- Check if player has too many active missions
    local activeMissions = GetPlayerActiveMissions(playerId)
    if #activeMissions >= MissionConfig.maxActiveMissions then
        return false, 'Maximum active missions reached'
    end
    
    -- Check mission cooldown
    if IsPlayerMissionOnCooldown(playerId, missionType) then
        return false, 'Mission type on cooldown'
    end
    
    -- Generate mission objectives
    local objectives = GenerateMissionObjectives(missionType, difficulty, districtId)
    
    -- Create mission
    local missionId = Utils.GenerateId()
    local mission = {
        id = missionId,
        playerId = playerId,
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
    
    -- Store mission
    if not MissionSystem.activeMissions[playerId] then
        MissionSystem.activeMissions[playerId] = {}
    end
    MissionSystem.activeMissions[playerId][missionId] = mission
    
    -- Notify client
    TriggerClientEvent('dz:client:mission:created', playerId, mission)
    
    -- Log mission creation
    print('^3[District Zero] ^7Mission created for player ' .. playerId .. ': ' .. missionType .. ' (' .. difficulty .. ')')
    
    return true, mission
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

-- Update mission progress
local function UpdateMissionProgress(playerId, missionId, progress, objectiveType)
    local mission = GetPlayerMission(playerId, missionId)
    if not mission then
        return false, 'Mission not found'
    end
    
    local objective = mission.objectives
    if objective.type ~= objectiveType then
        return false, 'Invalid objective type'
    end
    
    objective.current = math.min(objective.current + progress, objective.target)
    mission.progress = (objective.current / objective.target) * 100
    
    -- Check if mission is complete
    if objective.current >= objective.target then
        CompletePlayerMission(playerId, missionId)
        return true, 'Mission completed'
    end
    
    -- Update client
    TriggerClientEvent('dz:client:mission:progress', playerId, missionId, objective.current, objectiveType)
    
    return true, 'Progress updated'
end

-- Complete player mission
local function CompletePlayerMission(playerId, missionId)
    local mission = GetPlayerMission(playerId, missionId)
    if not mission then
        return false, 'Mission not found'
    end
    
    mission.status = 'completed'
    mission.completionTime = GetGameTimer()
    
    -- Set cooldown
    SetPlayerMissionCooldown(playerId, mission.type)
    
    -- Award rewards
    AwardMissionRewards(playerId, mission)
    
    -- Update mission stats
    UpdateMissionStats(playerId, mission, true)
    
    -- Notify client
    TriggerClientEvent('dz:client:mission:completed', playerId, missionId)
    
    -- Log completion
    print('^2[District Zero] ^7Mission completed by player ' .. playerId .. ': ' .. mission.type .. ' (' .. mission.difficulty .. ')')
    
    return true, 'Mission completed'
end

-- Fail player mission
local function FailPlayerMission(playerId, missionId, reason)
    local mission = GetPlayerMission(playerId, missionId)
    if not mission then
        return false, 'Mission not found'
    end
    
    mission.status = 'failed'
    mission.failReason = reason
    mission.failTime = GetGameTimer()
    
    -- Update mission stats
    UpdateMissionStats(playerId, mission, false)
    
    -- Notify client
    TriggerClientEvent('dz:client:mission:failed', playerId, missionId, reason)
    
    -- Log failure
    print('^1[District Zero] ^7Mission failed by player ' .. playerId .. ': ' .. mission.type .. ' - ' .. reason)
    
    return true, 'Mission failed'
end

-- Award mission rewards
local function AwardMissionRewards(playerId, mission)
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then
        return false
    end
    
    local rewards = mission.rewards
    local team = GetPlayerTeam(playerId)
    
    -- Apply team bonus if applicable
    if team and team ~= 'neutral' then
        rewards.money = math.floor(rewards.money * MissionConfig.teamBonus)
        rewards.exp = math.floor(rewards.exp * MissionConfig.teamBonus)
    end
    
    -- Award money
    if rewards.money > 0 then
        player.Functions.AddMoney('cash', rewards.money, 'mission-completion')
    end
    
    -- Award experience
    if rewards.exp > 0 then
        local stats = GetPlayerStats(playerId)
        if stats then
            stats.totalExp = (stats.totalExp or 0) + rewards.exp
            stats.missionsCompleted = (stats.missionsCompleted or 0) + 1
            SavePlayerStats(playerId, stats)
        end
    end
    
    -- Award items (if any)
    for _, item in ipairs(rewards.items) do
        player.Functions.AddItem(item.name, item.amount)
    end
    
    -- Notify player
    TriggerClientEvent('QBCore:Notify', playerId, 
        string.format('Mission rewards: $%d + %d EXP', rewards.money, rewards.exp), 'success')
    
    return true
end

-- Get player mission
local function GetPlayerMission(playerId, missionId)
    if not MissionSystem.activeMissions[playerId] then
        return nil
    end
    return MissionSystem.activeMissions[playerId][missionId]
end

-- Get player active missions
local function GetPlayerActiveMissions(playerId)
    local activeMissions = {}
    
    if MissionSystem.activeMissions[playerId] then
        for missionId, mission in pairs(MissionSystem.activeMissions[playerId]) do
            if mission.status == 'active' then
                table.insert(activeMissions, mission)
            end
        end
    end
    
    return activeMissions
end

-- Check player mission cooldown
local function IsPlayerMissionOnCooldown(playerId, missionType)
    local cooldownKey = playerId .. '_' .. missionType
    local cooldownTime = MissionSystem.missionCooldowns[cooldownKey]
    
    if not cooldownTime then
        return false
    end
    
    return GetGameTimer() < cooldownTime
end

-- Set player mission cooldown
local function SetPlayerMissionCooldown(playerId, missionType)
    local cooldownKey = playerId .. '_' .. missionType
    MissionSystem.missionCooldowns[cooldownKey] = GetGameTimer() + MissionConfig.missionCooldown
end

-- Update mission stats
local function UpdateMissionStats(playerId, mission, completed)
    if not MissionSystem.missionStats[playerId] then
        MissionSystem.missionStats[playerId] = {
            totalMissions = 0,
            completedMissions = 0,
            failedMissions = 0,
            totalRewards = 0,
            totalExp = 0
        }
    end
    
    local stats = MissionSystem.missionStats[playerId]
    stats.totalMissions = stats.totalMissions + 1
    
    if completed then
        stats.completedMissions = stats.completedMissions + 1
        stats.totalRewards = stats.totalRewards + mission.rewards.money
        stats.totalExp = stats.totalExp + mission.rewards.exp
    else
        stats.failedMissions = stats.failedMissions + 1
    end
end

-- Get available missions for player
local function GetAvailableMissionsForPlayer(playerId, districtId)
    local availableMissions = {}
    local player = QBX.Functions.GetPlayer(playerId)
    
    if not player then
        return availableMissions
    end
    
    local team = GetPlayerTeam(playerId)
    if not team or team == 'neutral' then
        return availableMissions
    end
    
    -- Generate available missions
    local missionTypes = {
        MissionTypes.CAPTURE_POINTS,
        MissionTypes.DEFEND_POINTS,
        MissionTypes.ELIMINATE_PLAYERS,
        MissionTypes.SURVIVE_TIME
    }
    
    for _, missionType in ipairs(missionTypes) do
        if not IsPlayerMissionOnCooldown(playerId, missionType) then
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

-- Event handlers
RegisterNetEvent('dz:server:mission:created', function(mission)
    local playerId = source
    -- Mission creation is handled by the server, this is just for logging
    print('^3[District Zero] ^7Mission creation requested by player ' .. playerId)
end)

RegisterNetEvent('dz:server:mission:progress', function(missionId, progress, objectiveType)
    local playerId = source
    local success, message = UpdateMissionProgress(playerId, missionId, progress, objectiveType)
    
    if not success then
        print('^1[District Zero] ^7Mission progress update failed for player ' .. playerId .. ': ' .. message)
    end
end)

RegisterNetEvent('dz:server:mission:completed', function(mission)
    local playerId = source
    -- Mission completion is handled by the server
end)

RegisterNetEvent('dz:server:mission:failed', function(missionId, reason)
    local playerId = source
    local success, message = FailPlayerMission(playerId, missionId, reason)
    
    if not success then
        print('^1[District Zero] ^7Mission failure handling failed for player ' .. playerId .. ': ' .. message)
    end
end)

RegisterNetEvent('dz:server:mission:claimRewards', function(missionId, rewards)
    local playerId = source
    -- Rewards are handled by the completion function
end)

-- NUI Callbacks
RegisterNUICallback('getAvailableMissions', function(data, cb)
    local playerId = source
    local districtId = data.districtId
    
    if not districtId then
        cb({
            success = false,
            error = 'District ID required'
        })
        return
    end
    
    local missions = GetAvailableMissionsForPlayer(playerId, districtId)
    
    cb({
        success = true,
        data = missions
    })
end)

RegisterNUICallback('createMission', function(data, cb)
    local playerId = source
    local missionType = data.missionType
    local difficulty = data.difficulty
    local districtId = data.districtId
    
    if not missionType or not difficulty or not districtId then
        cb({
            success = false,
            error = 'Missing mission parameters'
        })
        return
    end
    
    local success, result = CreatePlayerMission(playerId, missionType, difficulty, districtId)
    
    cb({
        success = success,
        data = success and result or nil,
        error = not success and result or nil
    })
end)

RegisterNUICallback('getPlayerMissions', function(data, cb)
    local playerId = source
    
    local activeMissions = GetPlayerActiveMissions(playerId)
    local missionStats = MissionSystem.missionStats[playerId] or {
        totalMissions = 0,
        completedMissions = 0,
        failedMissions = 0,
        totalRewards = 0,
        totalExp = 0
    }
    
    cb({
        success = true,
        data = {
            activeMissions = activeMissions,
            stats = missionStats
        }
    })
end)

-- Mission cleanup thread
CreateThread(function()
    while true do
        Wait(60000) -- Check every minute
        
        local currentTime = GetGameTimer()
        
        -- Clean up expired cooldowns
        for cooldownKey, cooldownTime in pairs(MissionSystem.missionCooldowns) do
            if currentTime > cooldownTime then
                MissionSystem.missionCooldowns[cooldownKey] = nil
            end
        end
        
        -- Check for timed out missions
        for playerId, missions in pairs(MissionSystem.activeMissions) do
            for missionId, mission in pairs(missions) do
                if mission.status == 'active' then
                    local elapsed = currentTime - mission.startTime
                    if elapsed > mission.timeLimit then
                        FailPlayerMission(playerId, missionId, 'Time limit exceeded')
                    end
                end
            end
        end
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        InitializeMissionSystem()
    end
end)

-- Player cleanup
AddEventHandler('playerDropped', function()
    local playerId = source
    
    -- Clean up player missions
    MissionSystem.activeMissions[playerId] = nil
    
    -- Clean up player cooldowns
    for cooldownKey, _ in pairs(MissionSystem.missionCooldowns) do
        if string.find(cooldownKey, playerId .. '_') then
            MissionSystem.missionCooldowns[cooldownKey] = nil
        end
    end
end)

-- Exports
exports('GetPlayerMissions', function(playerId)
    return MissionSystem.activeMissions[playerId] or {}
end)

exports('CreatePlayerMission', function(playerId, missionType, difficulty, districtId)
    return CreatePlayerMission(playerId, missionType, difficulty, districtId)
end)

exports('UpdateMissionProgress', function(playerId, missionId, progress, objectiveType)
    return UpdateMissionProgress(playerId, missionId, progress, objectiveType)
end)

exports('GetAvailableMissionsForPlayer', function(playerId, districtId)
    return GetAvailableMissionsForPlayer(playerId, districtId)
end) 