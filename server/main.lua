-- Server-side main file for District Zero
-- Version: 1.0.0

-- Try to get QBX Core with comprehensive error handling
local QBX = nil
local qbxLoaded = false

-- Try multiple QBX Core export names
local qbxExports = {
    'qbx_core',
    'qb-core',
    'qb_core'
}

for _, exportName in ipairs(qbxExports) do
    local success, result = pcall(function()
        return exports[exportName]:GetCoreObject()
    end)
    
    if success and result then
        QBX = result
        qbxLoaded = true
        print('^2[District Zero] Successfully loaded QBX Core from: ' .. exportName .. '^7')
        break
    else
        print('^3[District Zero] Failed to load from ' .. exportName .. ': ' .. tostring(result) .. '^7')
    end
end

if not qbxLoaded then
    print('^1[District Zero] WARNING: QBX Core not available. Some features may not work properly.^7')
    print('^3[District Zero] Make sure qbx_core is started before district-zero^7')
end

local Utils = require 'shared/utils'

-- State management
local activeMissions = {}
local playerTeams = {}
local districtInfluence = {}
local isInitialized = false

-- Initialize districts
local function InitializeDistricts()
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        return false
    end
    
    for _, district in pairs(Config.Districts) do
        districtInfluence[district.id] = {
            pvp = 0,
            pve = 0
        }
    end
    
    return true
end

-- Get available missions for player
local function GetAvailableMissions(source, districtId)
    if not QBX then
        Utils.PrintError('QBX Core not available', 'GetAvailableMissions')
        return {}
    end
    
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
local function AcceptMission(source, missionId, districtId)
    if not QBX then
        Utils.PrintError('QBX Core not available', 'AcceptMission')
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Core system not available'
        })
        return false
    end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then 
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Player data not found'
        })
        return false
    end

    if not Config or not Config.Missions then
        Utils.PrintDebug('[ERROR] Config.Missions not loaded')
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Mission system not available'
        })
        return false
    end

    local mission = nil
    for _, m in pairs(Config.Missions) do
        if m.id == missionId then
            mission = m
            break
        end
    end

    if not mission then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Mission not found'
        })
        return false
    end

    -- Check if player is in the correct district
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local inDistrict = false
    
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'District system not available'
        })
        return false
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
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You must be in the mission district to accept this mission'
        })
        return false
    end

    -- Check if player already has an active mission
    if activeMissions[source] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You already have an active mission'
        })
        return false
    end

    -- Check if player has selected a team
    if not playerTeams[source] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'You must select a team first'
        })
        return false
    end

    -- Check if mission type matches player's team
    if mission.type ~= playerTeams[source] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'This mission is not available for your team'
        })
        return false
    end

    -- Initialize mission
    activeMissions[source] = {
        id = mission.id,
        title = mission.title,
        description = mission.description,
        objectives = mission.objectives,
        startTime = GetGameTimer(),
        player = source,
        district = mission.district
    }

    -- Save mission progress to database
    MySQL.insert.await([[
        INSERT INTO dz_mission_progress (mission_id, citizenid, status, started_at)
        VALUES (?, ?, 'active', CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE status = 'active', started_at = CURRENT_TIMESTAMP
    ]], {missionId, player.PlayerData.citizenid})

    -- Send mission data to client
    TriggerClientEvent('dz:client:missionStarted', source, activeMissions[source])
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Mission accepted: ' .. mission.title
    })
    
    return true
end

-- Complete objective
local function CompleteObjective(source, missionId, objectiveId)
    if not QBX then
        Utils.PrintError('QBX Core not available', 'CompleteObjective')
        return false
    end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then return false end

    local mission = activeMissions[source]
    if not mission or mission.id ~= missionId then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'No active mission found'
        })
        return false
    end

    local objective = mission.objectives[objectiveId]
    if not objective then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid objective'
        })
        return false
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

        -- Update database
        MySQL.update.await([[
            UPDATE dz_mission_progress 
            SET status = 'completed', completed_at = CURRENT_TIMESTAMP
            WHERE mission_id = ? AND citizenid = ?
        ]], {missionId, player.PlayerData.citizenid})

        -- Complete mission
        activeMissions[source] = nil
        TriggerClientEvent('dz:client:missionCompleted', source)
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'success',
            description = 'Mission completed! Reward: $' .. mission.reward
        })
        return true
    else
        -- Update mission progress
        TriggerClientEvent('dz:client:missionUpdated', source, mission)
        return true
    end
end

-- Team selection
local function SelectTeam(source, team)
    if not QBX then
        Utils.PrintError('QBX Core not available', 'SelectTeam')
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Core system not available'
        })
        return false
    end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then 
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Player data not found'
        })
        return false
    end

    if team ~= 'pvp' and team ~= 'pve' then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid team selection'
        })
        return false
    end

    if not Config.Teams or not Config.Teams[team] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Team configuration not found'
        })
        return false
    end

    playerTeams[source] = team
    
    -- Save team selection to database
    MySQL.insert.await([[
        INSERT INTO dz_players (citizenid, team, last_updated)
        VALUES (?, ?, CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE team = ?, last_updated = CURRENT_TIMESTAMP
    ]], {player.PlayerData.citizenid, team, team})

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = 'Joined ' .. Config.Teams[team].name
    })
    TriggerClientEvent('dz:client:teamSelected', source, team)
    
    return true
end

-- Event handlers
RegisterNetEvent('dz:server:getUIData', function()
    local source = source
    
    if not QBX then
        Utils.PrintError('QBX Core not available', 'getUIData')
        return
    end
    
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

RegisterNetEvent('dz:server:acceptMission', function(missionId, districtId)
    local source = source
    AcceptMission(source, missionId, districtId)
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
    
    print('^5[District Zero] Starting District Zero server...^7')
    print('^5[District Zero] QBX Core status: ' .. (qbxLoaded and '^2LOADED^7' or '^1NOT AVAILABLE^7') .. '^7')
    
    -- Wait for database to be initialized
    CreateThread(function()
        Wait(2000) -- Wait for database initialization
        
        -- Initialize districts
        if not InitializeDistricts() then
            print('^1[District Zero] Failed to initialize districts^7')
            return
        end
        
        isInitialized = true
        print('^2[District Zero] Server initialized successfully^7')
        
        if not qbxLoaded then
            print('^3[District Zero] WARNING: Running without QBX Core. Some features may be limited.^7')
        end
    end)
end)

-- Exports
exports('GetPlayerTeam', function(source)
    return playerTeams[source]
end)

exports('GetActiveMission', function(source)
    return activeMissions[source]
end)

exports('GetDistrictInfluence', function(districtId)
    return districtInfluence[districtId]
end)

exports('InitializeDistricts', InitializeDistricts)

exports('IsDatabaseInitialized', function()
    return true -- Assume database is ready after resource start
end) 