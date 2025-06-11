local activeMissions = {}
local playerMissions = {}
local missionCooldowns = {}

-- Initialize mission system
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        UpdateMissionStates()
    end
end)

-- Update mission states and handle timeouts
function UpdateMissionStates()
    local currentTime = os.time()
    
    for missionId, mission in pairs(activeMissions) do
        if mission.state == Config.MissionStates.IN_PROGRESS then
            -- Check for mission timeout
            if currentTime >= mission.endTime then
                FailMission(missionId, "Time's up!")
            end
            
            -- Check if all players are still in the mission area
            for playerId, _ in pairs(mission.players) do
                if not IsPlayerInMissionArea(playerId, mission) then
                    FailMission(missionId, "Player left mission area")
                    break
                end
            end
        end
    end
end

-- Start a new mission
RegisterNetEvent('mission:start')
AddEventHandler('mission:start', function(missionType, missionId)
    local source = source
    local player = source
    
    -- Validate mission request
    if not CanStartMission(player, missionType, missionId) then
        TriggerClientEvent('mission:notification', player, "Cannot start mission", "error")
        return
    end
    
    -- Get mission data
    local mission = Config.Missions[missionType][missionId]
    if not mission then return end
    
    -- Create mission instance
    local missionInstance = {
        id = missionId,
        type = missionType,
        state = Config.MissionStates.IN_PROGRESS,
        startTime = os.time(),
        endTime = os.time() + mission.timeLimit,
        players = {[player] = true},
        location = mission.locations[1],
        vehicle = mission.vehicle,
        reward = mission.reward
    }
    
    -- Add to active missions
    activeMissions[missionId] = missionInstance
    playerMissions[player] = missionId
    
    -- Set cooldown
    missionCooldowns[missionId] = os.time() + mission.cooldown
    
    -- Notify players
    TriggerClientEvent('mission:started', player, missionInstance)
    TriggerClientEvent('mission:notification', player, "Mission started: " .. mission.name)
    
    -- Start mission timer
    StartMissionTimer(missionId)
end)

-- Join an existing mission
RegisterNetEvent('mission:join')
AddEventHandler('mission:join', function(missionId)
    local source = source
    local player = source
    
    -- Validate join request
    if not CanJoinMission(player, missionId) then
        TriggerClientEvent('mission:notification', player, "Cannot join mission", "error")
        return
    end
    
    local mission = activeMissions[missionId]
    if not mission then return end
    
    -- Add player to mission
    mission.players[player] = true
    playerMissions[player] = missionId
    
    -- Notify players
    TriggerClientEvent('mission:playerJoined', -1, missionId, player)
    TriggerClientEvent('mission:notification', player, "Joined mission: " .. Config.Missions[mission.type][mission.id].name)
end)

-- Complete mission
RegisterNetEvent('mission:complete')
AddEventHandler('mission:complete', function(missionId)
    local source = source
    local player = source
    
    local mission = activeMissions[missionId]
    if not mission or mission.state ~= Config.MissionStates.IN_PROGRESS then return end
    
    -- Validate completion
    if not IsPlayerInMissionArea(player, mission) then
        TriggerClientEvent('mission:notification', player, "Must be in mission area to complete", "error")
        return
    end
    
    -- Calculate rewards
    local reward = CalculateRewards(mission)
    
    -- Distribute rewards
    for playerId, _ in pairs(mission.players) do
        GiveReward(playerId, reward)
        TriggerClientEvent('mission:completed', playerId, missionId, reward)
    end
    
    -- Clean up mission
    CleanupMission(missionId)
end)

-- Fail mission
function FailMission(missionId, reason)
    local mission = activeMissions[missionId]
    if not mission then return end
    
    -- Notify players
    for playerId, _ in pairs(mission.players) do
        TriggerClientEvent('mission:failed', playerId, missionId, reason)
        TriggerClientEvent('mission:notification', playerId, "Mission failed: " .. reason, "error")
    end
    
    -- Clean up mission
    CleanupMission(missionId)
end

-- Check if player can start mission
function CanStartMission(player, missionType, missionId)
    -- Check if mission exists
    if not Config.Missions[missionType] or not Config.Missions[missionType][missionId] then
        return false
    end
    
    -- Check if player is already in a mission
    if playerMissions[player] then
        return false
    end
    
    -- Check mission cooldown
    if missionCooldowns[missionId] and os.time() < missionCooldowns[missionId] then
        return false
    end
    
    -- Check player rank
    local playerRank = GetPlayerFactionRank(player)
    local requiredRank = Config.Missions[missionType][missionId].requiredRank
    if playerRank < requiredRank then
        return false
    end
    
    -- Check online players requirement
    if not MeetsPlayerRequirement(missionType, missionId) then
        return false
    end
    
    return true
end

-- Check if player can join mission
function CanJoinMission(player, missionId)
    local mission = activeMissions[missionId]
    if not mission then return false end
    
    -- Check if player is already in a mission
    if playerMissions[player] then
        return false
    end
    
    -- Check if mission is full
    if CountMissionPlayers(missionId) >= Config.MissionRequirements.MAX_PLAYERS then
        return false
    end
    
    -- Check player rank
    local playerRank = GetPlayerFactionRank(player)
    local requiredRank = Config.Missions[mission.type][mission.id].requiredRank
    if playerRank < requiredRank then
        return false
    end
    
    return true
end

-- Check if mission meets player requirement
function MeetsPlayerRequirement(missionType, missionId)
    local mission = Config.Missions[missionType][missionId]
    local onlinePlayers = GetOnlinePlayers()
    
    if missionType == Config.MissionTypes.CRIMINAL then
        return CountFactionPlayers(Config.MissionTypes.POLICE) >= mission.policeRequired
    else
        return CountFactionPlayers(Config.MissionTypes.CRIMINAL) >= mission.minCriminals
    end
end

-- Calculate mission rewards
function CalculateRewards(mission)
    local baseReward = mission.reward
    local playerCount = CountMissionPlayers(mission.id)
    
    -- Apply team bonus
    if playerCount == Config.MissionRequirements.MAX_PLAYERS then
        baseReward.money = baseReward.money * Config.MissionRewards.BONUS_MULTIPLIER
        baseReward.reputation = baseReward.reputation * Config.MissionRewards.BONUS_MULTIPLIER
    end
    
    return baseReward
end

-- Give reward to player
function GiveReward(player, reward)
    -- Add money
    -- Implement based on your economy system
    
    -- Add reputation
    -- Implement based on your reputation system
    
    -- Notify player
    TriggerClientEvent('mission:reward', player, reward)
end

-- Clean up mission
function CleanupMission(missionId)
    local mission = activeMissions[missionId]
    if not mission then return end
    
    -- Remove players from mission
    for playerId, _ in pairs(mission.players) do
        playerMissions[playerId] = nil
    end
    
    -- Remove mission
    activeMissions[missionId] = nil
end

-- Helper functions
function CountMissionPlayers(missionId)
    local mission = activeMissions[missionId]
    if not mission then return 0 end
    
    local count = 0
    for _ in pairs(mission.players) do
        count = count + 1
    end
    return count
end

function CountFactionPlayers(faction)
    local count = 0
    for _, player in ipairs(GetPlayers()) do
        if GetPlayerFaction(player) == faction then
            count = count + 1
        end
    end
    return count
end

function IsPlayerInMissionArea(player, mission)
    local playerCoords = GetEntityCoords(GetPlayerPed(player))
    local missionCoords = mission.location
    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(missionCoords.x, missionCoords.y, missionCoords.z))
    return distance <= 50.0
end

-- Export functions
exports('GetActiveMissions', function()
    return activeMissions
end)

exports('GetPlayerMission', function(player)
    return playerMissions[player]
end) 