-- Server-side main file for District Zero
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- State management
local activeMissions = {}
local playerTeams = {}
local districtInfluence = {}

-- Initialize districts
local function InitializeDistricts()
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        return
    end
    
    for _, district in pairs(Config.Districts) do
        districtInfluence[district.id] = {
            pvp = 0,
            pve = 0
        }
    end
end

-- Get available missions for player
local function GetAvailableMissions(source, districtId)
    local player = QBX.Functions.GetPlayer(source)
    if not player then return {} end

    local availableMissions = {}
    if not Config or not Config.Missions then
        Utils.PrintDebug('[ERROR] Config.Missions not loaded')
        return availableMissions
    end

    for _, mission in pairs(Config.Missions) do
        if mission.district == districtId then
            -- Check if mission type matches player's team
            if playerTeams[source] == mission.type then
                table.insert(availableMissions, mission)
            end
        end
    end

    return availableMissions
end

-- Accept mission
local function AcceptMission(source, missionId)
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end

    if not Config or not Config.Missions then
        Utils.PrintDebug('[ERROR] Config.Missions not loaded')
        return
    end

    local mission = nil
    for _, m in pairs(Config.Missions) do
        if m.id == missionId then
            mission = m
            break
        end
    end

    if not mission then
        QBX.Functions.Notify(source, 'Mission not found', 'error')
        return
    end

    -- Check if player is in the correct district
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local inDistrict = false
    
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        return
    end

    for _, district in pairs(Config.Districts) do
        if district.id == mission.district then
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
        QBX.Functions.Notify(source, 'You must be in the mission district to accept this mission', 'error')
        return
    end

    -- Check if player already has an active mission
    if activeMissions[source] then
        QBX.Functions.Notify(source, 'You already have an active mission', 'error')
        return
    end

    -- Initialize mission
    activeMissions[source] = {
        id = mission.id,
        title = mission.title,
        description = mission.description,
        objectives = mission.objectives,
        startTime = os.time(),
        player = source
    }

    -- Send mission data to client
    TriggerClientEvent('dz:client:missionStarted', source, activeMissions[source])
    QBX.Functions.Notify(source, 'Mission accepted: ' .. mission.title, 'success')
end

-- Complete objective
local function CompleteObjective(source, missionId, objectiveId)
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end

    local mission = activeMissions[source]
    if not mission or mission.id ~= missionId then
        QBX.Functions.Notify(source, 'No active mission found', 'error')
        return
    end

    local objective = mission.objectives[objectiveId]
    if not objective then
        QBX.Functions.Notify(source, 'Invalid objective', 'error')
        return
    end

    -- Mark objective as complete
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
        if mission.reward then
            player.Functions.AddMoney('cash', mission.reward)
        end

        -- Update district influence
        local district = mission.district
        if districtInfluence[district] then
            districtInfluence[district][playerTeams[source]] = districtInfluence[district][playerTeams[source]] + 1
        end

        -- Complete mission
        activeMissions[source] = nil
        TriggerClientEvent('dz:client:missionCompleted', source)
        QBX.Functions.Notify(source, 'Mission completed!', 'success')
    else
        -- Update mission progress
        TriggerClientEvent('dz:client:missionUpdated', source, mission)
    end
end

-- Team selection
local function SelectTeam(source, team)
    if team ~= 'pvp' and team ~= 'pve' then
        QBX.Functions.Notify(source, 'Invalid team selection', 'error')
        return
    end

    playerTeams[source] = team
    QBX.Functions.Notify(source, 'Joined ' .. Config.Teams[team].name, 'success')
end

-- Event handlers
RegisterNetEvent('dz:server:getUIData', function()
    local source = source
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local currentDistrict = nil

    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        return
    end

    -- Find current district
    for _, district in pairs(Config.Districts) do
        for _, zone in pairs(district.zones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                currentDistrict = district
                break
            end
        end
        if currentDistrict then break end
    end

    local data = {
        missions = currentDistrict and GetAvailableMissions(source, currentDistrict.id) or {},
        districts = Config.Districts,
        currentDistrict = currentDistrict,
        currentTeam = playerTeams[source]
    }

    TriggerClientEvent('dz:client:updateUI', source, data)
end)

RegisterNetEvent('dz:server:selectTeam', function(team)
    local source = source
    SelectTeam(source, team)
end)

RegisterNetEvent('dz:server:acceptMission', function(missionId)
    local source = source
    AcceptMission(source, missionId)
end)

RegisterNetEvent('dz:server:capturePoint', function(missionId, objectiveId)
    local source = source
    CompleteObjective(source, missionId, objectiveId)
end)

-- Player cleanup
AddEventHandler('playerDropped', function()
    local source = source
    activeMissions[source] = nil
    playerTeams[source] = nil
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeDistricts()
end) 