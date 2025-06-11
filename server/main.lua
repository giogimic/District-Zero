-- Server-side main file for District Zero
local QBCore = exports['qbx_core']:GetCoreObject()
local Bridge = require 'bridge/loader'
local Framework = Bridge.Load()

-- Mission state
local activeMissions = {}

-- Initialize missions from database
local function InitializeMissions()
    local result = MySQL.query.await('SELECT * FROM dz_missions')
    if result then
        for _, mission in ipairs(result) do
            mission.objectives = json.decode(mission.objectives)
            activeMissions[mission.id] = mission
        end
        Bridge.Debug('Loaded ' .. #result .. ' missions from database')
    end
end

-- Get available missions for player
local function GetAvailableMissions(source)
    local player = Framework.GetPlayerFromId(source)
    if not player then return {} end

    local availableMissions = {}
    for id, mission in pairs(activeMissions) do
        -- Check if player meets requirements
        if mission.requiredLevel and player.PlayerData.level < mission.requiredLevel then
            goto continue
        end

        -- Check if player has required items
        if mission.requiredItems then
            for _, item in ipairs(mission.requiredItems) do
                local hasItem = Framework.GetInventoryItem(player, item.name)
                if not hasItem or hasItem.count < item.count then
                    goto continue
                end
            end
        end

        table.insert(availableMissions, mission)
        ::continue::
    end

    return availableMissions
end

-- Accept mission
local function AcceptMission(source, missionId)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end

    local mission = activeMissions[missionId]
    if not mission then
        Bridge.Notify(source, 'Mission not found', 'error')
        return
    end

    -- Check if player already has an active mission
    local result = MySQL.query.await('SELECT * FROM dz_mission_progress WHERE citizenid = ? AND status = ?', {
        player.PlayerData.citizenid,
        'active'
    })

    if result and #result > 0 then
        Bridge.Notify(source, 'You already have an active mission', 'error')
        return
    end

    -- Create mission progress record
    MySQL.insert.await('INSERT INTO dz_mission_progress (mission_id, citizenid, status, started_at) VALUES (?, ?, ?, NOW())', {
        missionId,
        player.PlayerData.citizenid,
        'active'
    })

    -- Initialize objectives
    local missionData = {
        id = mission.id,
        title = mission.title,
        description = mission.description,
        objectives = {},
        startCoords = mission.startCoords,
        startBlip = mission.startBlip,
        startLabel = mission.startLabel
    }

    for i, objective in ipairs(mission.objectives) do
        missionData.objectives[i] = {
            type = objective.type,
            coords = objective.coords,
            radius = objective.radius,
            label = objective.label,
            blip = objective.blip,
            completed = false
        }
    end

    -- Send mission data to client
    TriggerClientEvent('dz:showMission', source, missionData)
    Bridge.Notify(source, 'Mission accepted: ' .. mission.title, 'success')
end

-- Complete objective
local function CompleteObjective(source, missionId, objectiveId)
    local player = Framework.GetPlayerFromId(source)
    if not player then return end

    -- Get mission progress
    local result = MySQL.query.await('SELECT * FROM dz_mission_progress WHERE citizenid = ? AND mission_id = ? AND status = ?', {
        player.PlayerData.citizenid,
        missionId,
        'active'
    })

    if not result or #result == 0 then
        Bridge.Notify(source, 'No active mission found', 'error')
        return
    end

    local progress = result[1]
    local objectives = json.decode(progress.objectives_completed or '[]')
    table.insert(objectives, objectiveId)

    -- Update progress
    MySQL.update.await('UPDATE dz_mission_progress SET objectives_completed = ? WHERE id = ?', {
        json.encode(objectives),
        progress.id
    })

    -- Check if all objectives are complete
    local mission = activeMissions[missionId]
    if #objectives >= #mission.objectives then
        -- Give rewards
        if mission.reward then
            if mission.reward.money then
                player.Functions.AddMoney('cash', mission.reward.money)
            end
            if mission.reward.items then
                for _, item in ipairs(mission.reward.items) do
                    Framework.AddInventoryItem(player, item.name, item.count)
                end
            end
        end

        -- Complete mission
        MySQL.update.await('UPDATE dz_mission_progress SET status = ?, completed_at = NOW() WHERE id = ?', {
            'completed',
            progress.id
        })

        TriggerClientEvent('dz:completeMission', source)
        Bridge.Notify(source, 'Mission completed!', 'success')
    else
        -- Update mission progress
        local missionData = {
            id = mission.id,
            title = mission.title,
            description = mission.description,
            objectives = {},
            startCoords = mission.startCoords,
            startBlip = mission.startBlip,
            startLabel = mission.startLabel
        }

        for i, objective in ipairs(mission.objectives) do
            missionData.objectives[i] = {
                type = objective.type,
                coords = objective.coords,
                radius = objective.radius,
                label = objective.label,
                blip = objective.blip,
                completed = table.contains(objectives, i)
            }
        end

        TriggerClientEvent('dz:updateMission', source, missionData)
    end
end

-- Event handlers
RegisterNetEvent('dz:requestMissions', function()
    local source = source
    local missions = GetAvailableMissions(source)
    TriggerClientEvent('dz:showMissions', source, missions)
end)

RegisterNetEvent('dz:acceptMission', function(missionId)
    local source = source
    AcceptMission(source, missionId)
end)

RegisterNetEvent('dz:completeObjective', function(missionId, objectiveId)
    local source = source
    CompleteObjective(source, missionId, objectiveId)
end)

-- Initialize on resource start
CreateThread(function()
    InitializeMissions()
end) 