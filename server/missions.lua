-- District Zero Missions Server Module
-- Version: 1.0.0

local Utils = require 'shared/utils'

-- State
local activeMissions = {}
local playerMissions = {}

-- Initialize missions
local function InitializeMissions()
    Utils.PrintDebug('Initializing missions...')
    -- Mission initialization logic here
end

-- Get available missions
local function GetAvailableMissions(districtId)
    local missions = {}
    for _, mission in pairs(Config.Missions) do
        if mission.district == districtId then
            table.insert(missions, mission)
        end
    end
    return missions
end

-- Assign mission to player
local function AssignMission(playerId, missionId)
    if not Config.Missions[missionId] then return false end
    
    playerMissions[playerId] = {
        id = missionId,
        startTime = os.time(),
        status = 'active'
    }
    
    -- Notify client
    TriggerClientEvent('District-Zero:client:missionAssigned', playerId, Config.Missions[missionId])
    return true
end

-- Complete mission
local function CompleteMission(playerId, success)
    if not playerMissions[playerId] then return end
    
    local mission = Config.Missions[playerMissions[playerId].id]
    if not mission then return end
    
    -- Award influence
    if success then
        exports['District-Zero']:UpdateDistrictInfluence(mission.district, 'pve', mission.reward)
    end
    
    -- Clear mission
    playerMissions[playerId] = nil
    
    -- Notify client
    TriggerClientEvent('District-Zero:client:missionCompleted', playerId, success)
end

-- Event handlers
RegisterNetEvent('District-Zero:server:requestMissions')
AddEventHandler('District-Zero:server:requestMissions', function(districtId, cb)
    cb(GetAvailableMissions(districtId))
end)

RegisterNetEvent('District-Zero:server:acceptMission')
AddEventHandler('District-Zero:server:acceptMission', function(missionId)
    local playerId = source
    if AssignMission(playerId, missionId) then
        Utils.PrintDebug(string.format('Mission %s assigned to player %s', missionId, playerId))
    end
end)

RegisterNetEvent('District-Zero:server:completeMission')
AddEventHandler('District-Zero:server:completeMission', function(success)
    local playerId = source
    CompleteMission(playerId, success)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeMissions()
end)

-- Export functions
exports('GetAvailableMissions', GetAvailableMissions)
exports('AssignMission', AssignMission)
exports('CompleteMission', CompleteMission) 