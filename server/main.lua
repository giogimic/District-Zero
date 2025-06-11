-- Server-side main file for District Zero
local QBCore = exports['qbx_core']:GetCoreObject()

-- Mission state
local activeMissions = {}
local missionQueue = {}

-- Initialize mission system
local function InitializeMissions()
    -- Load missions from database
    local result = MySQL.query.await('SELECT * FROM dz_missions')
    if result then
        for _, mission in ipairs(result) do
            missionQueue[mission.id] = mission
        end
    end
end

-- Get available missions for player
local function GetAvailableMissions(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    
    local availableMissions = {}
    for id, mission in pairs(missionQueue) do
        if not activeMissions[id] then
            table.insert(availableMissions, {
                id = id,
                title = mission.title,
                description = mission.description,
                difficulty = mission.difficulty,
                reward = mission.reward
            })
        end
    end
    
    return availableMissions
end

-- Accept mission
local function AcceptMission(source, missionId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    if activeMissions[missionId] then
        TriggerClientEvent('QBCore:Notify', source, 'This mission is already active', 'error')
        return false
    end
    
    local mission = missionQueue[missionId]
    if not mission then
        TriggerClientEvent('QBCore:Notify', source, 'Mission not found', 'error')
        return false
    end
    
    activeMissions[missionId] = {
        player = source,
        startTime = os.time(),
        objectives = mission.objectives
    }
    
    TriggerClientEvent('district-zero:client:updateMission', source, {
        id = missionId,
        title = mission.title,
        description = mission.description,
        objectives = mission.objectives
    })
    
    return true
end

-- Complete mission objective
local function CompleteObjective(source, missionId, objectiveId)
    local mission = activeMissions[missionId]
    if not mission or mission.player ~= source then return false end
    
    local objective = mission.objectives[objectiveId]
    if not objective then return false end
    
    objective.completed = true
    
    -- Check if all objectives are complete
    local allComplete = true
    for _, obj in ipairs(mission.objectives) do
        if not obj.completed then
            allComplete = false
            break
        end
    end
    
    if allComplete then
        -- Give rewards
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('cash', mission.reward)
            TriggerClientEvent('QBCore:Notify', source, 'Mission completed! Reward: $' .. mission.reward, 'success')
        end
        
        -- Clean up mission
        activeMissions[missionId] = nil
        TriggerClientEvent('district-zero:client:hideUI', source)
    else
        -- Update mission progress
        TriggerClientEvent('district-zero:client:updateMission', source, {
            id = missionId,
            title = mission.title,
            description = mission.description,
            objectives = mission.objectives
        })
    end
    
    return true
end

-- Events
RegisterNetEvent('district-zero:server:requestMissions', function()
    local source = source
    local missions = GetAvailableMissions(source)
    TriggerClientEvent('district-zero:client:showMissions', source, missions)
end)

RegisterNetEvent('district-zero:server:acceptMission', function(missionId)
    local source = source
    AcceptMission(source, missionId)
end)

RegisterNetEvent('district-zero:server:completeObjective', function(missionId, objectiveId)
    local source = source
    CompleteObjective(source, missionId, objectiveId)
end)

-- Initialize
CreateThread(function()
    InitializeMissions()
end) 