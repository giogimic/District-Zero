-- server/missions/missions.lua
-- District Zero Mission Management

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Mission State
local State = {
    missions = {},
    activeMissions = {},
    rewards = {}
}

-- Initialize missions
local function InitializeMissions()
    local missions = Utils.SafeQuery('SELECT * FROM dz_missions', {}, 'InitializeMissions')
    if missions then
        for _, mission in ipairs(missions) do
            State.missions[mission.id] = mission
        end
    end
end

-- Handle mission start
local function HandleMissionStart(source, missionId)
    if not State.missions[missionId] then return false end
    
    local mission = State.missions[missionId]
    local Player = QBX.Functions.GetPlayer(source)
    
    if not Player then return false end
    
    -- Check if player can start mission
    if mission.requirements then
        if mission.requirements.job and Player.PlayerData.job.name ~= mission.requirements.job then
            return false
        end
        if mission.requirements.gang and Player.PlayerData.gang.name ~= mission.requirements.gang then
            return false
        end
    end
    
    -- Check if mission is already active
    if State.activeMissions[source] then
        return false
    end
    
    -- Start mission
    State.activeMissions[source] = {
        missionId = missionId,
        startTime = os.time(),
        objectives = mission.objectives
    }
    
    -- Trigger mission start event
    Events.TriggerEvent('dz:client:mission:started', 'server', source, {
        missionId = missionId,
        objectives = mission.objectives
    })
    
    return true
end

-- Handle mission completion
local function HandleMissionComplete(source, missionId)
    if not State.missions[missionId] then return false end
    if not State.activeMissions[source] then return false end
    
    local mission = State.missions[missionId]
    local Player = QBX.Functions.GetPlayer(source)
    
    if not Player then return false end
    
    -- Check if all objectives are complete
    local activeMission = State.activeMissions[source]
    for _, objective in ipairs(activeMission.objectives) do
        if not objective.completed then
            return false
        end
    end
    
    -- Give rewards
    if mission.rewards then
        if mission.rewards.money then
            Player.Functions.AddMoney('cash', mission.rewards.money)
        end
        
        if mission.rewards.items then
            for _, item in ipairs(mission.rewards.items) do
                Player.Functions.AddItem(item.name, item.amount)
            end
        end
    end
    
    -- Update mission state
    State.activeMissions[source] = nil
    State.rewards[missionId] = os.time()
    
    -- Trigger mission complete event
    Events.TriggerEvent('dz:client:mission:completed', 'server', source, {
        missionId = missionId,
        rewards = mission.rewards
    })
    
    return true
end

-- Handle mission objective update
local function HandleObjectiveUpdate(source, missionId, objectiveId, status)
    if not State.missions[missionId] then return false end
    if not State.activeMissions[source] then return false end
    
    local activeMission = State.activeMissions[source]
    local objective = activeMission.objectives[objectiveId]
    
    if not objective then return false end
    
    -- Update objective status
    objective.completed = status
    
    -- Trigger objective update event
    Events.TriggerEvent('dz:client:mission:objectiveUpdated', 'server', source, {
        missionId = missionId,
        objectiveId = objectiveId,
        status = status
    })
    
    return true
end

-- Event Handlers
Events.RegisterEvent('dz:server:mission:start', function(source, missionId)
    HandleMissionStart(source, missionId)
end)

Events.RegisterEvent('dz:server:mission:complete', function(source, missionId)
    HandleMissionComplete(source, missionId)
end)

Events.RegisterEvent('dz:server:mission:updateObjective', function(source, missionId, objectiveId, status)
    HandleObjectiveUpdate(source, missionId, objectiveId, status)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeMissions()
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        missions = {},
        activeMissions = {},
        rewards = {}
    }
end)

-- Exports
exports('GetMissions', function()
    return State.missions
end)

exports('GetActiveMissions', function()
    return State.activeMissions
end)

exports('GetMissionRewards', function()
    return State.rewards
end) 