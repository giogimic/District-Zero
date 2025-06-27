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
    
    print('^2[District Zero] Initialized ' .. #Config.Districts .. ' districts^7')
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
        district = districtId
    }

    -- Send mission to client
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

    if not mission.objectives[objectiveId] then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid objective'
        })
        return false
    end

    -- Mark objective as complete
    mission.objectives[objectiveId].completed = true

    -- Check if all objectives are complete
    local allComplete = true
    for _, objective in pairs(mission.objectives) do
        if not objective.completed then
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

    -- Get player statistics
    local playerStats = GetPlayerStats(source)
    
    -- Get team balance
    local teamBalance = GetTeamBalance()

    local data = {
        missions = currentDistrict and GetAvailableMissions(source, currentDistrict.id) or {},
        districts = Config.Districts,
        currentDistrict = currentDistrict,
        currentTeam = playerTeams[source],
        playerStats = playerStats,
        teamBalance = teamBalance
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
    
    -- Wait for config and database to be initialized
    CreateThread(function()
        local attempts = 0
        while not Config and attempts < 50 do
            Wait(100)
            attempts = attempts + 1
        end
        
        if not Config then
            print('^1[District Zero] ERROR: Config not loaded after 5 seconds^7')
            return
        end
        
        -- Wait for database to be ready
        Wait(2000)
        
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

-- Get player statistics
local function GetPlayerStats(source)
    if not QBX then return nil end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then return nil end
    
    -- Get mission history from database
    local result = MySQL.query.await([[
        SELECT 
            COUNT(*) as missions_completed,
            SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as successful_missions,
            SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_missions
        FROM dz_mission_progress 
        WHERE citizenid = ?
    ]], {player.PlayerData.citizenid})
    
    if not result or #result == 0 then
        return {
            missions_completed = 0,
            successful_missions = 0,
            failed_missions = 0,
            total_rewards = 0,
            playtime_hours = 0
        }
    end
    
    local stats = result[1]
    
    -- Get total rewards (this would need to be tracked separately in a real implementation)
    local totalRewards = 0
    
    -- Get playtime (this would need to be tracked separately in a real implementation)
    local playtimeHours = 0
    
    return {
        missions_completed = stats.missions_completed or 0,
        successful_missions = stats.successful_missions or 0,
        failed_missions = stats.failed_missions or 0,
        total_rewards = totalRewards,
        playtime_hours = playtimeHours
    }
end

-- Get team balance
local function GetTeamBalance()
    local pvpCount = 0
    local pveCount = 0
    
    -- Count players in each team
    for _, team in pairs(playerTeams) do
        if team == 'pvp' then
            pvpCount = pvpCount + 1
        elseif team == 'pve' then
            pveCount = pveCount + 1
        end
    end
    
    -- Calculate influence (this would be more complex in a real implementation)
    local totalInfluence = 0
    for _, district in pairs(districtInfluence) do
        totalInfluence = totalInfluence + district.pvp + district.pve
    end
    
    local pvpInfluence = 0
    local pveInfluence = 0
    
    if totalInfluence > 0 then
        for _, district in pairs(districtInfluence) do
            pvpInfluence = pvpInfluence + district.pvp
            pveInfluence = pveInfluence + district.pve
        end
        pvpInfluence = math.floor((pvpInfluence / totalInfluence) * 100)
        pveInfluence = math.floor((pveInfluence / totalInfluence) * 100)
    end
    
    return {
        pvp = {
            members = pvpCount,
            influence = pvpInfluence
        },
        pve = {
            members = pveCount,
            influence = pveInfluence
        }
    }
end

-- Player Stats and Team Balance Handlers
RegisterNetEvent('dz:server:getPlayerStats', function(playerId)
    local source = source
    
    -- Get player stats from database or memory
    local stats = GetPlayerStats(source)
    
    -- Send response back to client
    TriggerClientEvent('dz:client:playerStats:response', source, stats or {
        districtCaptures = 0,
        totalExp = 0,
        team = 'neutral'
    })
end)

RegisterNetEvent('dz:server:getTeamBalance', function()
    local source = source
    
    -- Calculate team balance
    local pvpCount = 0
    local pveCount = 0
    
    for _, playerId in ipairs(GetPlayers()) do
        local team = GetPlayerTeam(playerId)
        if team == 'pvp' then
            pvpCount = pvpCount + 1
        elseif team == 'pve' then
            pveCount = pveCount + 1
        end
    end
    
    local balance = {
        pvp = pvpCount,
        pve = pveCount
    }
    
    -- Send response back to client
    TriggerClientEvent('dz:client:teamBalance:response', source, balance)
end)

-- Database Integration for Player Stats
RegisterNetEvent('dz:server:savePlayerStats', function(stats)
    local source = source
    local success, message = exports['district-zero']:SavePlayerStats(source, stats)
    
    if success then
        print('^2[District Zero] ^7Player stats saved for player ' .. source)
    else
        print('^1[District Zero] ^7Failed to save player stats: ' .. message)
    end
end)

RegisterNetEvent('dz:server:loadPlayerStats', function()
    local source = source
    local stats, message = exports['district-zero']:LoadPlayerStats(source)
    
    if stats then
        TriggerClientEvent('dz:client:playerStats:loaded', source, stats)
    else
        print('^1[District Zero] ^7Failed to load player stats: ' .. message)
    end
end)

RegisterNetEvent('dz:server:updatePlayerStat', function(statType, value)
    local source = source
    local success, message = exports['district-zero']:UpdatePlayerStat(source, statType, value)
    
    if success then
        print('^2[District Zero] ^7Player stat updated: ' .. statType .. ' +' .. value)
    else
        print('^1[District Zero] ^7Failed to update player stat: ' .. message)
    end
end)

-- Database Integration for District History
RegisterNetEvent('dz:server:logDistrictCapture', function(districtId, districtName, controllingTeam, previousTeam, captureMethod, influenceData)
    local source = source
    local success, message = exports['district-zero']:LogDistrictCapture(districtId, districtName, controllingTeam, previousTeam, source, captureMethod, influenceData)
    
    if success then
        print('^2[District Zero] ^7District capture logged: ' .. districtId)
    else
        print('^1[District Zero] ^7Failed to log district capture: ' .. message)
    end
end)

RegisterNetEvent('dz:server:getDistrictHistory', function(districtId, limit)
    local source = source
    local history, message = exports['district-zero']:GetDistrictHistory(districtId, limit)
    
    if history then
        TriggerClientEvent('dz:client:districtHistory:loaded', source, history)
    else
        print('^1[District Zero] ^7Failed to load district history: ' .. message)
    end
end)

-- Database Integration for Control Point History
RegisterNetEvent('dz:server:logControlPointCapture', function(districtId, pointId, pointName, capturingTeam, participants, duration, success)
    local source = source
    local success, message = exports['district-zero']:LogControlPointCapture(districtId, pointId, pointName, capturingTeam, source, participants, duration, success)
    
    if success then
        print('^2[District Zero] ^7Control point capture logged: ' .. pointId)
    else
        print('^1[District Zero] ^7Failed to log control point capture: ' .. message)
    end
end)

-- Database Integration for Mission Logs
RegisterNetEvent('dz:server:logMissionCompletion', function(missionId, missionType, missionTitle, missionDifficulty, districtId, objectives, rewards, duration, success, progressData)
    local source = source
    local success, message = exports['district-zero']:LogMissionCompletion(missionId, source, missionType, missionTitle, missionDifficulty, districtId, objectives, rewards, duration, success, progressData)
    
    if success then
        print('^2[District Zero] ^7Mission completion logged: ' .. missionId)
    else
        print('^1[District Zero] ^7Failed to log mission completion: ' .. message)
    end
end)

RegisterNetEvent('dz:server:getPlayerMissionHistory', function(limit)
    local source = source
    local history, message = exports['district-zero']:GetPlayerMissionHistory(source, limit)
    
    if history then
        TriggerClientEvent('dz:client:missionHistory:loaded', source, history)
    else
        print('^1[District Zero] ^7Failed to load mission history: ' .. message)
    end
end)

-- Database Integration for Team Analytics
RegisterNetEvent('dz:server:getTeamAnalytics', function(teamType, days)
    local source = source
    local analytics, message = exports['district-zero']:GetTeamAnalytics(teamType, days)
    
    if analytics then
        TriggerClientEvent('dz:client:teamAnalytics:loaded', source, analytics)
    else
        print('^1[District Zero] ^7Failed to load team analytics: ' .. message)
    end
end)

-- Database Integration for Team Events
RegisterNetEvent('dz:server:logTeamEvent', function(eventId, eventType, teamType, eventData, duration, status, participants, rewardsDistributed)
    local source = source
    local success, message = exports['district-zero']:LogTeamEvent(eventId, eventType, teamType, source, eventData, duration, status, participants, rewardsDistributed)
    
    if success then
        print('^2[District Zero] ^7Team event logged: ' .. eventId)
    else
        print('^1[District Zero] ^7Failed to log team event: ' .. message)
    end
end)

-- Database Integration for Session Management
RegisterNetEvent('dz:server:startPlayerSession', function(teamType)
    local source = source
    local success, message = exports['district-zero']:StartPlayerSession(source, teamType)
    
    if success then
        print('^2[District Zero] ^7Player session started: ' .. source)
    else
        print('^1[District Zero] ^7Failed to start player session: ' .. message)
    end
end)

RegisterNetEvent('dz:server:endPlayerSession', function(districtsVisited, activitiesPerformed)
    local source = source
    local success, message = exports['district-zero']:EndPlayerSession(source, districtsVisited, activitiesPerformed)
    
    if success then
        print('^2[District Zero] ^7Player session ended: ' .. source)
    else
        print('^1[District Zero] ^7Failed to end player session: ' .. message)
    end
end)

-- Database Integration for Influence History
RegisterNetEvent('dz:server:logInfluenceChange', function(districtId, influencePvp, influencePve, influenceNeutral, changeReason)
    local source = source
    local success, message = exports['district-zero']:LogInfluenceChange(districtId, influencePvp, influencePve, influenceNeutral, changeReason)
    
    if success then
        print('^2[District Zero] ^7Influence change logged: ' .. districtId)
    else
        print('^1[District Zero] ^7Failed to log influence change: ' .. message)
    end
end)

-- Database Integration for Achievements
RegisterNetEvent('dz:server:trackAchievement', function(achievementId, achievementName, achievementDescription, achievementType, progressCurrent, progressRequired)
    local source = source
    local success, message = exports['district-zero']:TrackAchievement(source, achievementId, achievementName, achievementDescription, achievementType, progressCurrent, progressRequired)
    
    if success then
        print('^2[District Zero] ^7Achievement tracked: ' .. achievementId)
    else
        print('^1[District Zero] ^7Failed to track achievement: ' .. message)
    end
end)

-- Database Integration for Leaderboards
RegisterNetEvent('dz:server:getPlayerLeaderboard', function(teamType, limit)
    local source = source
    local leaderboard, message = exports['district-zero']:GetPlayerLeaderboard(teamType, limit)
    
    if leaderboard then
        TriggerClientEvent('dz:client:playerLeaderboard:loaded', source, leaderboard)
    else
        print('^1[District Zero] ^7Failed to load player leaderboard: ' .. message)
    end
end)

RegisterNetEvent('dz:server:getGlobalLeaderboard', function(limit)
    local source = source
    local leaderboard, message = exports['district-zero']:GetGlobalLeaderboard(limit)
    
    if leaderboard then
        TriggerClientEvent('dz:client:globalLeaderboard:loaded', source, leaderboard)
    else
        print('^1[District Zero] ^7Failed to load global leaderboard: ' .. message)
    end
end)

-- Database Integration for System Configuration
RegisterNetEvent('dz:server:getSystemConfig', function(configKey)
    local source = source
    local config, message = exports['district-zero']:GetSystemConfig(configKey)
    
    if config ~= nil then
        TriggerClientEvent('dz:client:systemConfig:loaded', source, configKey, config)
    else
        print('^1[District Zero] ^7Failed to load system config: ' .. message)
    end
end)

RegisterNetEvent('dz:server:setSystemConfig', function(configKey, configValue, configType)
    local source = source
    local success, message = exports['district-zero']:SetSystemConfig(configKey, configValue, configType)
    
    if success then
        print('^2[District Zero] ^7System config saved: ' .. configKey)
    else
        print('^1[District Zero] ^7Failed to save system config: ' .. message)
    end
end)

-- Enhanced Player Cleanup with Database Integration
AddEventHandler('playerDropped', function()
    local source = source
    
    -- End player session
    local districtsVisited = {}
    local activitiesPerformed = {}
    
    -- Get player's current district
    if activeMissions[source] then
        table.insert(activitiesPerformed, 'mission_active')
    end
    
    if playerTeams[source] then
        table.insert(activitiesPerformed, 'team_' .. playerTeams[source])
    end
    
    -- End session in database
    exports['district-zero']:EndPlayerSession(source, districtsVisited, activitiesPerformed)
    
    -- Clean up local state
    activeMissions[source] = nil
    playerTeams[source] = nil
    
    print('^3[District Zero] ^7Player ' .. source .. ' disconnected and session ended')
end)

-- Player Join Handler with Database Integration
AddEventHandler('playerJoining', function()
    local source = source
    
    -- Start player session
    exports['district-zero']:StartPlayerSession(source, 'neutral')
    
    print('^2[District Zero] ^7Player ' .. source .. ' joined and session started')
end)

-- Enhanced Team Selection with Database Integration
RegisterNetEvent('dz:server:selectTeam', function(team)
    local source = source
    
    if not team or (team ~= 'pvp' and team ~= 'pve') then
        TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'Invalid team selection'
        })
        return
    end
    
    -- Update player's team
    playerTeams[source] = team
    
    -- Update session with new team
    local districtsVisited = {}
    local activitiesPerformed = { 'team_' .. team }
    exports['district-zero']:EndPlayerSession(source, districtsVisited, activitiesPerformed)
    exports['district-zero']:StartPlayerSession(source, team)
    
    -- Update player stats
    local stats = {
        team_type = team,
        total_captures = 0,
        total_missions = 0,
        total_eliminations = 0,
        total_assists = 0,
        total_team_events = 0,
        total_points = 0,
        total_playtime = 0
    }
    exports['district-zero']:SavePlayerStats(source, stats)
    
    -- Notify client
    TriggerClientEvent('dz:client:teamSelected', source, team)
    
    print('^2[District Zero] ^7Player ' .. source .. ' selected team: ' .. team)
end)

-- Enhanced Mission Completion with Database Integration
local function CompleteMission(source, missionId, success)
    if not activeMissions[source] or activeMissions[source].id ~= missionId then
        return false
    end
    
    local mission = activeMissions[source]
    local completionTime = os.time()
    local duration = completionTime - (mission.startTime or completionTime)
    
    -- Log mission completion
    exports['district-zero']:LogMissionCompletion(
        missionId,
        source,
        mission.type or 'unknown',
        mission.title or 'Unknown Mission',
        mission.difficulty or 'EASY',
        mission.district or 'unknown',
        mission.objectives or {},
        mission.rewards or {},
        duration,
        success,
        mission.progress or {}
    )
    
    -- Update player stats
    if success then
        exports['district-zero']:UpdatePlayerStat(source, 'total_missions', 1)
        exports['district-zero']:UpdatePlayerStat(source, 'total_points', mission.rewards and mission.rewards.points or 100)
    end
    
    -- Clean up mission
    activeMissions[source] = nil
    
    return true
end

-- Enhanced District Capture with Database Integration
local function CaptureDistrict(districtId, team, capturedBy)
    if not Config or not Config.Districts then
        return false
    end
    
    local district = nil
    for _, d in pairs(Config.Districts) do
        if d.id == districtId then
            district = d
            break
        end
    end
    
    if not district then
        return false
    end
    
    local previousTeam = district.controllingTeam or 'neutral'
    district.controllingTeam = team
    
    -- Log district capture
    exports['district-zero']:LogDistrictCapture(
        districtId,
        district.name,
        team,
        previousTeam,
        capturedBy,
        'control_point',
        districtInfluence[districtId]
    )
    
    -- Update influence
    if districtInfluence[districtId] then
        exports['district-zero']:LogInfluenceChange(
            districtId,
            districtInfluence[districtId].pvp,
            districtInfluence[districtId].pve,
            0,
            'district_capture'
        )
    end
    
    return true
end

-- District Zero Server Main
-- Version: 1.0.0

-- Import shared modules
local Config = exports['district-zero']:GetConfig()
local PerformanceSystem = exports['district-zero']:GetPerformanceSystem()
local DatabaseManager = exports['district-zero']:GetDatabaseManager()
local SecuritySystem = exports['district-zero']:GetSecuritySystem()
local AdvancedMissionSystem = exports['district-zero']:GetAdvancedMissionSystem()
local DynamicEventsSystem = exports['district-zero']:GetDynamicEventsSystem()
local AdvancedTeamSystem = exports['district-zero']:GetAdvancedTeamSystem()
local AchievementSystem = exports['district-zero']:GetAchievementSystem()
local AnalyticsSystem = exports['district-zero']:GetAnalyticsSystem()

-- Server state
local ServerState = {
    players = {},
    districts = {},
    missions = {},
    teams = {},
    performanceMetrics = {},
    securityMetrics = {},
    serverStartTime = GetGameTimer(),
    eventCount = 0,
    lastEventLog = 0,
    -- Advanced mission state
    activeMissions = {},
    missionChains = {},
    dynamicEvents = {},
    bossEncounters = {},
    missionQueue = {},
    lastMissionGeneration = 0,
    missionGenerationInterval = 300000, -- 5 minutes
    -- Dynamic events state
    activeEvents = {},
    scheduledEvents = {},
    eventHistory = {},
    lastEventGeneration = 0,
    eventGenerationInterval = 180000, -- 3 minutes
    -- Advanced team state
    activeTeams = {},
    teamWars = {},
    alliances = {},
    teamChallenges = {},
    lastTeamChallenge = 0,
    teamChallengeInterval = 900000, -- 15 minutes
    -- Achievement state
    playerAchievements = {},
    achievementProgress = {},
    lastAchievementCheck = 0,
    achievementCheckInterval = 60000, -- 1 minute
    -- Analytics state
    analyticsData = {},
    dashboardCache = {},
    lastAnalyticsUpdate = 0,
    analyticsUpdateInterval = 30000 -- 30 seconds
}

-- Initialize server
local function InitializeServer()
    -- Initialize districts from config
    for districtId, district in pairs(Config.districts) do
        ServerState.districts[districtId] = {
            id = districtId,
            name = district.name,
            center = district.center,
            radius = district.radius,
            controlledBy = nil,
            influence = {},
            capturePoints = district.controlPoints or {},
            lastCapture = 0,
            captureCooldown = 300000 -- 5 minutes
        }
    end
    
    -- Initialize missions from config
    for missionId, mission in pairs(Config.missions) do
        ServerState.missions[missionId] = {
            id = missionId,
            name = mission.name,
            description = mission.description,
            objectives = mission.objectives or {},
            rewards = mission.rewards or {},
            active = false,
            startedBy = nil,
            startTime = 0,
            cooldown = mission.cooldown or 600000, -- 10 minutes
            lastCompleted = 0
        }
    end
    
    -- Initialize teams from config
    for teamId, team in pairs(Config.teams) do
        ServerState.teams[teamId] = {
            id = teamId,
            name = team.name,
            color = team.color,
            members = {},
            leader = nil,
            stats = {
                captures = 0,
                missions = 0,
                influence = 0
            },
            lastActivity = 0
        }
    end
    
    -- Initialize advanced mission system
    ServerState.activeMissions = AdvancedMissionSystem.activeMissions
    ServerState.missionChains = AdvancedMissionSystem.missionChains
    ServerState.dynamicEvents = AdvancedMissionSystem.dynamicEvents
    ServerState.bossEncounters = AdvancedMissionSystem.bossEncounters
    
    -- Initialize dynamic events system
    ServerState.activeEvents = DynamicEventsSystem.activeEvents
    ServerState.scheduledEvents = DynamicEventsSystem.scheduledEvents
    ServerState.eventHistory = DynamicEventsSystem.eventHistory
    
    -- Initialize advanced team system
    ServerState.activeTeams = AdvancedTeamSystem.activeTeams
    ServerState.teamWars = AdvancedTeamSystem.teamWars
    ServerState.alliances = AdvancedTeamSystem.alliances
    ServerState.teamChallenges = AdvancedTeamSystem.teamChallenges
    
    print('^2[District Zero] ^7Server initialized with ' .. 
          #ServerState.districts .. ' districts, ' .. 
          #ServerState.missions .. ' missions, ' .. 
          #ServerState.teams .. ' teams')
    
    -- Start performance monitoring
    PerformanceSystem.UpdatePerformanceMetrics()
    
    -- Log server start
    SecuritySystem.LogAuditEvent('server_start', {
        districts = #ServerState.districts,
        missions = #ServerState.missions,
        teams = #ServerState.teams
    })
end

-- Secure Event Handler Helper
local function SecureEventHandler(eventName, validationRules, handler)
    return function(...)
        local source = source
        local playerId = GetPlayerServerId(source)
        local args = {...}
        
        -- Security check
        local securityOk, securityMsg = SecuritySystem.SecureEvent(playerId, eventName, args[1] or {}, validationRules)
        if not securityOk then
            -- Log security violation
            SecuritySystem.LogAuditEvent('security_violation', {
                playerId = playerId,
                eventName = eventName,
                reason = securityMsg,
                data = args[1] or {}
            })
            
            -- Notify client
            TriggerClientEvent('dz:notification:show', source, {
                type = 'error',
                title = 'Security Violation',
                message = securityMsg,
                duration = 5000
            })
            
            return
        end
        
        -- Increment event count
        ServerState.eventCount = ServerState.eventCount + 1
        
        -- Call original handler
        return handler(...)
    end
end

-- Advanced Mission Generation
local function GenerateDynamicMissions()
    local currentTime = GetGameTimer()
    
    -- Check if it's time to generate new missions
    if currentTime - ServerState.lastMissionGeneration < ServerState.missionGenerationInterval then
        return
    end
    
    ServerState.lastMissionGeneration = currentTime
    
    -- Generate missions for each district
    for districtId, district in pairs(ServerState.districts) do
        -- Count active players in district
        local playersInDistrict = 0
        local playerLevels = {}
        
        for playerId, player in pairs(ServerState.players) do
            if player.currentDistrict == districtId then
                playersInDistrict = playersInDistrict + 1
                table.insert(playerLevels, player.stats.level or 1)
            end
        end
        
        -- Generate mission if there are players
        if playersInDistrict > 0 then
            local avgLevel = 1
            if #playerLevels > 0 then
                local totalLevel = 0
                for _, level in ipairs(playerLevels) do
                    totalLevel = totalLevel + level
                end
                avgLevel = math.floor(totalLevel / #playerLevels)
            end
            
            local mission = AdvancedMissionSystem.GenerateDynamicMission(districtId, avgLevel, playersInDistrict)
            if mission then
                ServerState.activeMissions[mission.id] = mission
                
                -- Notify players in district
                for playerId, player in pairs(ServerState.players) do
                    if player.currentDistrict == districtId then
                        TriggerClientEvent('dz:mission:available', playerId, mission)
                    end
                end
                
                print('^2[District Zero] ^7Generated dynamic mission: ' .. mission.name .. ' in district: ' .. districtId)
            end
        end
    end
end

-- Dynamic Events Management
local function GenerateDynamicEvents()
    local currentTime = GetGameTimer()
    
    -- Check if it's time to generate new events
    if currentTime - ServerState.lastEventGeneration < ServerState.eventGenerationInterval then
        return
    end
    
    ServerState.lastEventGeneration = currentTime
    
    -- Generate events for each district
    for districtId, district in pairs(ServerState.districts) do
        -- Count active players in district
        local playersInDistrict = 0
        local playerLevels = {}
        
        for playerId, player in pairs(ServerState.players) do
            if player.currentDistrict == districtId then
                playersInDistrict = playersInDistrict + 1
                table.insert(playerLevels, player.stats.level or 1)
            end
        end
        
        -- Generate event if there are players and random chance
        if playersInDistrict > 0 and math.random() < 0.3 then -- 30% chance
            local avgLevel = 1
            if #playerLevels > 0 then
                local totalLevel = 0
                for _, level in ipairs(playerLevels) do
                    totalLevel = totalLevel + level
                end
                avgLevel = math.floor(totalLevel / #playerLevels)
            end
            
            local eventId = DynamicEventsSystem.GenerateRandomEvent(districtId, {
                x = district.center.x + (math.random() - 0.5) * district.radius * 0.8,
                y = district.center.y + (math.random() - 0.5) * district.radius * 0.8,
                z = district.center.z
            })
            
            if eventId then
                print('^2[District Zero] ^7Generated dynamic event: ' .. eventId .. ' in district: ' .. districtId)
            end
        end
    end
end

-- Advanced Team Management
local function GenerateTeamChallenges()
    local currentTime = GetGameTimer()
    
    -- Check if it's time to generate new challenges
    if currentTime - ServerState.lastTeamChallenge < ServerState.teamChallengeInterval then
        return
    end
    
    ServerState.lastTeamChallenge = currentTime
    
    -- Get active teams
    local activeTeams = {}
    for teamId, team in pairs(ServerState.activeTeams) do
        if team.state == AdvancedTeamSystem.teamStates.ACTIVE and team.stats.current_members >= 2 then
            table.insert(activeTeams, teamId)
        end
    end
    
    -- Generate challenge if enough teams
    if #activeTeams >= 2 then
        local challengeTemplates = AdvancedTeamSystem.challengeTemplates
        local templateNames = {}
        for name, _ in pairs(challengeTemplates) do
            table.insert(templateNames, name)
        end
        
        if #templateNames > 0 then
            local selectedTemplate = templateNames[math.random(1, #templateNames)]
            local template = challengeTemplates[selectedTemplate]
            
            -- Select random teams
            local selectedTeams = {}
            local maxTeams = math.min(template.maxTeams, #activeTeams)
            for i = 1, maxTeams do
                local randomIndex = math.random(1, #activeTeams)
                table.insert(selectedTeams, activeTeams[randomIndex])
                table.remove(activeTeams, randomIndex)
            end
            
            local challenge = AdvancedTeamSystem.CreateTeamChallenge(template, selectedTeams)
            if challenge then
                ServerState.teamChallenges[challenge.id] = challenge
                
                -- Notify teams
                for _, teamId in ipairs(selectedTeams) do
                    local team = ServerState.activeTeams[teamId]
                    if team then
                        for playerId, _ in pairs(team.members) do
                            TriggerClientEvent('dz:team:challenge_available', playerId, challenge.id, challenge)
                        end
                    end
                end
                
                print('^2[District Zero] ^7Generated team challenge: ' .. challenge.name)
            end
        end
    end
end

-- Advanced Team Event Handlers
RegisterNetEvent('dz:team:create_advanced')
AddEventHandler('dz:team:create_advanced', SecureEventHandler('dz:team:create_advanced', {
    template = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
    name = { type = 'string', maxLength = 50, pattern = '^[a-zA-Z0-9\\s]+$' },
    description = { type = 'string', maxLength = 200 }
}, function(template, name, description)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local teamTemplate = AdvancedTeamSystem.teamTemplates[template]
    if not teamTemplate then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Invalid Template',
            message = 'Team template not found',
            duration = 3000
        })
        return
    end
    
    -- Check if player is already in a team
    if ServerState.players[playerId].team then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Already in Team',
            message = 'You must leave your current team first',
            duration = 3000
        })
        return
    end
    
    -- Create team
    local team = AdvancedTeamSystem.CreateTeamFromTemplate(teamTemplate, playerId, {
        name = name,
        description = description
    })
    
    if team then
        ServerState.activeTeams[team.id] = team
        ServerState.players[playerId].team = team.id
        
        -- Broadcast team creation
        TriggerClientEvent('dz:team:created', -1, team.id, team)
        
        -- Show notification
        TriggerClientEvent('dz:notification:show', source, {
            type = 'success',
            title = 'Team Created',
            message = 'Team ' .. name .. ' has been created',
            duration = 5000
        })
        
        print('^2[District Zero] ^7Advanced team created: ' .. name .. ' by player: ' .. ServerState.players[playerId].name)
    end
end))

RegisterNetEvent('dz:team:invite')
AddEventHandler('dz:team:invite', SecureEventHandler('dz:team:invite', {
    targetPlayerId = { type = 'number', min = 1, max = 1000 },
    role = { type = 'string', pattern = '^[a-zA-Z]+$', maxLength = 20 }
}, function(targetPlayerId, role)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] or not ServerState.players[targetPlayerId] then
        return
    end
    
    local player = ServerState.players[playerId]
    local targetPlayer = ServerState.players[targetPlayerId]
    
    if not player.team then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Team',
            message = 'You must be in a team to invite players',
            duration = 3000
        })
        return
    end
    
    local team = ServerState.activeTeams[player.team]
    if not team then
        return
    end
    
    -- Check permissions
    local member = team.members[playerId]
    if not member or not AdvancedTeamSystem.rolePermissions[member.role].invite then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Permission',
            message = 'You cannot invite players',
            duration = 3000
        })
        return
    end
    
    -- Check if target player is already in a team
    if targetPlayer.team then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Player in Team',
            message = 'Player is already in a team',
            duration = 3000
        })
        return
    end
    
    -- Send invitation
    TriggerClientEvent('dz:team:invitation', targetPlayerId, {
        teamId = player.team,
        teamName = team.name,
        inviterId = playerId,
        inviterName = player.name,
        role = role
    })
    
    -- Show notification
    TriggerClientEvent('dz:notification:show', source, {
        type = 'success',
        title = 'Invitation Sent',
        message = 'Invitation sent to ' .. targetPlayer.name,
        duration = 3000
    })
    
    print('^2[District Zero] ^7Team invitation sent: ' .. player.name .. ' invited ' .. targetPlayer.name)
end))

RegisterNetEvent('dz:team:accept_invitation')
AddEventHandler('dz:team:accept_invitation', SecureEventHandler('dz:team:accept_invitation', {
    teamId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
    role = { type = 'string', pattern = '^[a-zA-Z]+$', maxLength = 20 }
}, function(teamId, role)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local team = ServerState.activeTeams[teamId]
    if not team then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Team Not Found',
            message = 'Team no longer exists',
            duration = 3000
        })
        return
    end
    
    -- Add player to team
    local success, message = AdvancedTeamSystem.AddMemberToTeam(teamId, playerId, role)
    if success then
        ServerState.players[playerId].team = teamId
        
        -- Broadcast team update
        TriggerClientEvent('dz:team:update', -1, teamId, team)
        
        -- Show notification
        TriggerClientEvent('dz:notification:show', source, {
            type = 'success',
            title = 'Team Joined',
            message = 'You joined ' .. team.name,
            duration = 3000
        })
        
        print('^2[District Zero] ^7Player ' .. ServerState.players[playerId].name .. ' joined team: ' .. team.name)
    else
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Join Failed',
            message = message,
            duration = 3000
        })
    end
end))

RegisterNetEvent('dz:team:promote')
AddEventHandler('dz:team:promote', SecureEventHandler('dz:team:promote', {
    targetPlayerId = { type = 'number', min = 1, max = 1000 },
    newRole = { type = 'string', pattern = '^[a-zA-Z]+$', maxLength = 20 }
}, function(targetPlayerId, newRole)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] or not ServerState.players[targetPlayerId] then
        return
    end
    
    local player = ServerState.players[playerId]
    if not player.team then
        return
    end
    
    local team = ServerState.activeTeams[player.team]
    if not team then
        return
    end
    
    -- Check permissions
    local member = team.members[playerId]
    if not member or not AdvancedTeamSystem.rolePermissions[member.role].promote then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Permission',
            message = 'You cannot promote players',
            duration = 3000
        })
        return
    end
    
    -- Promote player
    local success, message = AdvancedTeamSystem.PromoteMember(player.team, targetPlayerId, newRole)
    if success then
        -- Broadcast team update
        TriggerClientEvent('dz:team:update', -1, player.team, team)
        
        -- Show notification
        TriggerClientEvent('dz:notification:show', source, {
            type = 'success',
            title = 'Player Promoted',
            message = 'Player promoted to ' .. newRole,
            duration = 3000
        })
        
        print('^2[District Zero] ^7Player promoted: ' .. ServerState.players[targetPlayerId].name .. ' to ' .. newRole)
    else
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Promotion Failed',
            message = message,
            duration = 3000
        })
    end
end))

RegisterNetEvent('dz:team:kick')
AddEventHandler('dz:team:kick', SecureEventHandler('dz:team:kick', {
    targetPlayerId = { type = 'number', min = 1, max = 1000 }
}, function(targetPlayerId)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] or not ServerState.players[targetPlayerId] then
        return
    end
    
    local player = ServerState.players[playerId]
    if not player.team then
        return
    end
    
    local team = ServerState.activeTeams[player.team]
    if not team then
        return
    end
    
    -- Check permissions
    local member = team.members[playerId]
    if not member or not AdvancedTeamSystem.rolePermissions[member.role].kick then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Permission',
            message = 'You cannot kick players',
            duration = 3000
        })
        return
    end
    
    -- Kick player
    local success, message = AdvancedTeamSystem.RemoveMemberFromTeam(player.team, targetPlayerId)
    if success then
        ServerState.players[targetPlayerId].team = nil
        
        -- Broadcast team update
        TriggerClientEvent('dz:team:update', -1, player.team, team)
        
        -- Show notification
        TriggerClientEvent('dz:notification:show', source, {
            type = 'success',
            title = 'Player Kicked',
            message = 'Player has been kicked from the team',
            duration = 3000
        })
        
        print('^2[District Zero] ^7Player kicked: ' .. ServerState.players[targetPlayerId].name .. ' from team: ' .. team.name)
    else
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Kick Failed',
            message = message,
            duration = 3000
        })
    end
end))

-- Team War Event Handlers
RegisterNetEvent('dz:team:declare_war')
AddEventHandler('dz:team:declare_war', SecureEventHandler('dz:team:declare_war', {
    targetTeamId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
    reason = { type = 'string', maxLength = 200 }
}, function(targetTeamId, reason)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local player = ServerState.players[playerId]
    if not player.team then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Team',
            message = 'You must be in a team to declare war',
            duration = 3000
        })
        return
    end
    
    local team = ServerState.activeTeams[player.team]
    if not team then
        return
    end
    
    -- Check permissions
    local member = team.members[playerId]
    if not member or not AdvancedTeamSystem.rolePermissions[member.role].declare_war then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Permission',
            message = 'You cannot declare war',
            duration = 3000
        })
        return
    end
    
    -- Declare war
    local success, message, warId = AdvancedTeamSystem.DeclareWar(player.team, targetTeamId, reason)
    if success then
        -- Broadcast war declaration
        TriggerClientEvent('dz:team:war_declared', -1, warId, {
            attacker = player.team,
            defender = targetTeamId,
            reason = reason
        })
        
        -- Show notification
        TriggerClientEvent('dz:notification:show', source, {
            type = 'warning',
            title = 'War Declared',
            message = 'War declared against ' .. targetTeamId,
            duration = 5000
        })
        
        print('^2[District Zero] ^7War declared: ' .. team.name .. ' vs ' .. targetTeamId)
    else
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'War Declaration Failed',
            message = message,
            duration = 3000
        })
    end
end))

-- Team Challenge Event Handlers
RegisterNetEvent('dz:team:join_challenge')
AddEventHandler('dz:team:join_challenge', SecureEventHandler('dz:team:join_challenge', {
    challengeId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 }
}, function(challengeId)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local player = ServerState.players[playerId]
    if not player.team then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'No Team',
            message = 'You must be in a team to join challenges',
            duration = 3000
        })
        return
    end
    
    local challenge = ServerState.teamChallenges[challengeId]
    if not challenge then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Challenge Not Found',
            message = 'Challenge no longer exists',
            duration = 3000
        })
        return
    end
    
    -- Check if team is already participating
    if not challenge.participants[player.team] then
        TriggerClientEvent('dz:notification:show', source, {
            type = 'error',
            title = 'Team Not Eligible',
            message = 'Your team is not eligible for this challenge',
            duration = 3000
        })
        return
    end
    
    -- Start challenge if not already started
    if challenge.state == 'pending' then
        local success, message = AdvancedTeamSystem.StartTeamChallenge(challengeId)
        if success then
            -- Broadcast challenge start
            TriggerClientEvent('dz:team:challenge_started', -1, challengeId, challenge)
            
            -- Show notification
            TriggerClientEvent('dz:notification:show', source, {
                type = 'success',
                title = 'Challenge Started',
                message = challenge.name .. ' has begun!',
                duration = 5000
            })
            
            print('^2[District Zero] ^7Team challenge started: ' .. challenge.name)
        end
    end
end))

RegisterNetEvent('dz:team:challenge_progress')
AddEventHandler('dz:team:challenge_progress', SecureEventHandler('dz:team:challenge_progress', {
    challengeId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
    objectiveId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
    progress = { type = 'number', min = 0, max = 1000 }
}, function(challengeId, objectiveId, progress)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local player = ServerState.players[playerId]
    if not player.team then
        return
    end
    
    -- Update challenge progress
    local success, message = AdvancedTeamSystem.UpdateChallengeProgress(challengeId, player.team, objectiveId, progress)
    if success then
        -- Broadcast progress update
        TriggerClientEvent('dz:team:challenge_progress_update', -1, challengeId, player.team, objectiveId, progress)
    end
end))

-- Achievement Event Handlers
RegisterNetEvent('dz:achievement:track_progress')
AddEventHandler('dz:achievement:track_progress', SecureEventHandler('dz:achievement:track_progress', {
    achievementId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
    progress = { type = 'number', min = 0, max = 1000000 }
}, function(achievementId, progress)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Update achievement progress
    local newProgress = AchievementSystem.UpdatePlayerProgress(playerId, achievementId, progress)
    
    -- Broadcast progress update
    TriggerClientEvent('dz:achievement:progress_update', source, achievementId, newProgress)
    
    print('^2[District Zero] ^7Achievement progress updated: ' .. playerId .. ' - ' .. achievementId .. ' = ' .. newProgress)
end))

RegisterNetEvent('dz:achievement:get_progress')
AddEventHandler('dz:achievement:get_progress', SecureEventHandler('dz:achievement:get_progress', {
    achievementId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 }
}, function(achievementId)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local progress = AchievementSystem.GetPlayerProgress(playerId, achievementId)
    TriggerClientEvent('dz:achievement:progress_response', source, achievementId, progress)
end))

RegisterNetEvent('dz:achievement:get_all_progress')
AddEventHandler('dz:achievement:get_all_progress', SecureEventHandler('dz:achievement:get_all_progress', {}, function()
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    local allProgress = {}
    for achievementId, _ in pairs(AchievementSystem.achievementTemplates) do
        allProgress[achievementId] = AchievementSystem.GetPlayerProgress(playerId, achievementId)
    end
    
    TriggerClientEvent('dz:achievement:all_progress_response', source, allProgress)
end))

-- Achievement Integration with Existing Systems
local function TrackAchievementProgress(playerId, achievementType, progress)
    -- Map achievement types to achievement IDs
    local achievementMapping = {
        kills = 'combat_kills',
        survival_time = 'combat_survivor',
        districts_visited = 'exploration_districts',
        distance_traveled = 'exploration_distance',
        team_captures = 'teamwork_captures',
        team_missions = 'teamwork_missions',
        team_leadership_time = 'leadership_team',
        wars_won = 'leadership_wars',
        items_collected = 'collection_items',
        player_interactions = 'social_interactions',
        total_playtime = 'special_24_hours'
    }
    
    local achievementId = achievementMapping[achievementType]
    if achievementId then
        AchievementSystem.UpdatePlayerProgress(playerId, achievementId, progress)
    end
end

-- Enhanced district capture with achievement tracking
local function CaptureDistrict(districtId, teamId, playerIds)
    -- Existing capture logic
    if ServerState.districts[districtId] then
        ServerState.districts[districtId].controlledBy = teamId
        ServerState.districts[districtId].lastCapture = GetGameTimer()
        
        -- Track achievement progress for all participating players
        for _, playerId in ipairs(playerIds) do
            -- Track team capture achievement
            TrackAchievementProgress(playerId, 'team_captures', 1)
            
            -- Track first capture achievement
            if not ServerState.playerAchievements[playerId] then
                ServerState.playerAchievements[playerId] = {}
            end
            
            if not ServerState.playerAchievements[playerId].first_capture then
                ServerState.playerAchievements[playerId].first_capture = true
                TrackAchievementProgress(playerId, 'first_capture', 1)
            end
        end
        
        -- Update team stats
        if ServerState.teams[teamId] then
            ServerState.teams[teamId].stats.captures = ServerState.teams[teamId].stats.captures + 1
        end
        
        print('^2[District Zero] ^7District ' .. districtId .. ' captured by team ' .. teamId)
    end
end

-- Enhanced mission completion with achievement tracking
local function CompleteMission(missionId, playerId, teamId)
    -- Existing mission completion logic
    if ServerState.missions[missionId] then
        ServerState.missions[missionId].lastCompleted = GetGameTimer()
        
        -- Track achievement progress
        if teamId then
            TrackAchievementProgress(playerId, 'team_missions', 1)
        end
        
        print('^2[District Zero] ^7Mission ' .. missionId .. ' completed by player ' .. playerId)
    end
end

-- Enhanced player join with achievement tracking
local function PlayerJoin(playerId, playerData)
    ServerState.players[playerId] = playerData
    ServerState.players[playerId].joinTime = GetGameTimer()
    ServerState.players[playerId].lastActivity = GetGameTimer()
    
    -- Initialize achievement progress
    AchievementSystem.InitializePlayerProgress(playerId)
    
    -- Track playtime achievement
    local sessionStartTime = GetGameTimer()
    ServerState.players[playerId].sessionStartTime = sessionStartTime
    
    print('^2[District Zero] ^7Player joined: ' .. playerId)
end

-- Enhanced player leave with achievement tracking
local function PlayerLeave(playerId)
    if ServerState.players[playerId] then
        local sessionDuration = GetGameTimer() - ServerState.players[playerId].sessionStartTime
        TrackAchievementProgress(playerId, 'total_playtime', sessionDuration)
        
        -- Save player data
        DatabaseManager.SavePlayerStats(playerId, ServerState.players[playerId].stats)
        
        ServerState.players[playerId] = nil
        print('^2[District Zero] ^7Player left: ' .. playerId)
    end
end

-- Achievement Check Thread
CreateThread(function()
    while true do
        Wait(ServerState.achievementCheckInterval)
        
        local currentTime = GetGameTimer()
        
        -- Check for time-based achievements
        for playerId, player in pairs(ServerState.players) do
            if player.sessionStartTime then
                local sessionDuration = currentTime - player.sessionStartTime
                TrackAchievementProgress(playerId, 'total_playtime', sessionDuration)
            end
            
            -- Check for survival time in combat zones
            if player.inCombatZone then
                local combatTime = currentTime - player.combatStartTime
                TrackAchievementProgress(playerId, 'survival_time', combatTime)
            end
        end
        
        ServerState.lastAchievementCheck = currentTime
    end
end)

-- Achievement Admin Commands
RegisterCommand('dzachievement', function(source, args, rawCommand)
    if source == 0 then -- Console only
        local subCommand = args[1] and args[1]:lower() or 'help'
        
        if subCommand == 'list' then
            print('^3[District Zero Achievements] ^7Available Achievements:')
            for achievementId, achievement in pairs(AchievementSystem.achievementTemplates) do
                print('  ' .. achievement.name .. ' (ID: ' .. achievementId .. ') - ' .. achievement.category)
            end
            
        elseif subCommand == 'progress' then
            if #args < 3 then
                print('^3[District Zero] ^7Usage: dzachievement progress <playerId> <achievementId>')
                return
            end
            
            local playerId = tonumber(args[2])
            local achievementId = args[3]
            
            if not playerId or not ServerState.players[playerId] then
                print('^1[District Zero] ^7Player not found')
                return
            end
            
            if not AchievementSystem.achievementTemplates[achievementId] then
                print('^1[District Zero] ^7Achievement not found')
                return
            end
            
            local progress = AchievementSystem.GetPlayerProgress(playerId, achievementId)
            print('^2[District Zero] ^7Player ' .. playerId .. ' progress for ' .. achievementId .. ': ' .. progress)
            
        elseif subCommand == 'award' then
            if #args < 4 then
                print('^3[District Zero] ^7Usage: dzachievement award <playerId> <achievementId> <progress>')
                return
            end
            
            local playerId = tonumber(args[2])
            local achievementId = args[3]
            local progress = tonumber(args[4])
            
            if not playerId or not ServerState.players[playerId] then
                print('^1[District Zero] ^7Player not found')
                return
            end
            
            if not AchievementSystem.achievementTemplates[achievementId] then
                print('^1[District Zero] ^7Achievement not found')
                return
            end
            
            if not progress then
                print('^1[District Zero] ^7Invalid progress value')
                return
            end
            
            local newProgress = AchievementSystem.UpdatePlayerProgress(playerId, achievementId, progress)
            print('^2[District Zero] ^7Awarded progress to player ' .. playerId .. ' for ' .. achievementId .. ': ' .. newProgress)
            
        elseif subCommand == 'reset' then
            if #args < 3 then
                print('^3[District Zero] ^7Usage: dzachievement reset <playerId> <achievementId>')
                return
            end
            
            local playerId = tonumber(args[2])
            local achievementId = args[3]
            
            if not playerId or not ServerState.players[playerId] then
                print('^1[District Zero] ^7Player not found')
                return
            end
            
            if not AchievementSystem.achievementTemplates[achievementId] then
                print('^1[District Zero] ^7Achievement not found')
                return
            end
            
            -- Reset achievement progress
            if AchievementSystem.playerProgress[playerId] then
                AchievementSystem.playerProgress[playerId].progress[achievementId] = 0
                AchievementSystem.playerProgress[playerId].completed[achievementId] = nil
            end
            
            print('^2[District Zero] ^7Reset achievement progress for player ' .. playerId .. ' - ' .. achievementId)
            
        elseif subCommand == 'stats' then
            print('^3[District Zero Achievement Statistics] ^7')
            local totalAchievements = 0
            local totalCompleted = 0
            local totalProgress = 0
            
            for achievementId, _ in pairs(AchievementSystem.achievementTemplates) do
                totalAchievements = totalAchievements + 1
            end
            
            for playerId, playerData in pairs(AchievementSystem.playerProgress) do
                for achievementId, _ in pairs(playerData.completed) do
                    totalCompleted = totalCompleted + 1
                end
                
                for achievementId, progress in pairs(playerData.progress) do
                    totalProgress = totalProgress + progress
                end
            end
            
            print('  Total Achievements: ' .. totalAchievements)
            print('  Total Completions: ' .. totalCompleted)
            print('  Total Progress: ' .. totalProgress)
            print('  Active Players: ' .. #ServerState.players)
            
        elseif subCommand == 'help' then
            print('^3[District Zero Achievement Commands] ^7Available commands:')
            print('  dzachievement list - List all achievements')
            print('  dzachievement progress <playerId> <achievementId> - Check player progress')
            print('  dzachievement award <playerId> <achievementId> <progress> - Award progress')
            print('  dzachievement reset <playerId> <achievementId> - Reset progress')
            print('  dzachievement stats - Show achievement statistics')
            print('  dzachievement help - Show this help')
            
        else
            print('^1[District Zero] ^7Unknown achievement command: ' .. subCommand)
        end
    end
end, true)

-- Achievement Reward Event Handlers
RegisterNetEvent('dz:achievement:reward_influence')
AddEventHandler('dz:achievement:reward_influence', function(amount)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Add influence to player
    if not ServerState.players[playerId].stats then
        ServerState.players[playerId].stats = {}
    end
    
    ServerState.players[playerId].stats.influence = (ServerState.players[playerId].stats.influence or 0) + amount
    
    -- Show notification
    TriggerClientEvent('dz:notification:show', source, {
        type = 'success',
        title = 'Achievement Reward',
        message = 'You earned ' .. amount .. ' influence!',
        duration = 3000
    })
    
    print('^2[District Zero] ^7Player ' .. playerId .. ' earned ' .. amount .. ' influence from achievement')
end)

RegisterNetEvent('dz:achievement:reward_experience')
AddEventHandler('dz:achievement:reward_experience', function(amount)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Add experience to player
    if not ServerState.players[playerId].stats then
        ServerState.players[playerId].stats = {}
    end
    
    ServerState.players[playerId].stats.experience = (ServerState.players[playerId].stats.experience or 0) + amount
    
    -- Show notification
    TriggerClientEvent('dz:notification:show', source, {
        type = 'success',
        title = 'Achievement Reward',
        message = 'You earned ' .. amount .. ' experience!',
        duration = 3000
    })
    
    print('^2[District Zero] ^7Player ' .. playerId .. ' earned ' .. amount .. ' experience from achievement')
end)

RegisterNetEvent('dz:achievement:reward_money')
AddEventHandler('dz:achievement:reward_money', function(amount)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Add money to player
    if not ServerState.players[playerId].stats then
        ServerState.players[playerId].stats = {}
    end
    
    ServerState.players[playerId].stats.money = (ServerState.players[playerId].stats.money or 0) + amount
    
    -- Show notification
    TriggerClientEvent('dz:notification:show', source, {
        type = 'success',
        title = 'Achievement Reward',
        message = 'You earned $' .. amount .. '!',
        duration = 3000
    })
    
    print('^2[District Zero] ^7Player ' .. playerId .. ' earned $' .. amount .. ' from achievement')
end)

RegisterNetEvent('dz:achievement:reward_title')
AddEventHandler('dz:achievement:reward_title', function(title)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Add title to player
    if not ServerState.players[playerId].titles then
        ServerState.players[playerId].titles = {}
    end
    
    table.insert(ServerState.players[playerId].titles, title)
    
    -- Show notification
    TriggerClientEvent('dz:notification:show', source, {
        type = 'success',
        title = 'Achievement Reward',
        message = 'You earned the title: ' .. title,
        duration = 5000
    })
    
    print('^2[District Zero] ^7Player ' .. playerId .. ' earned title: ' .. title)
end)

print('^2[District Zero] ^7Achievement system integrated')

-- Main Threads with Advanced Team Features
CreateThread(function()
    while true do
        Wait(5000) -- Update every 5 seconds
        
        -- Update performance metrics
        PerformanceSystem.UpdatePerformanceMetrics()
        
        -- Update security metrics
        ServerState.securityMetrics = SecuritySystem.GetSecurityMetrics()
        
        -- Update team member coordinates
        for teamId, team in pairs(ServerState.teams) do
            for playerId, member in pairs(team.members) do
                local player = GetPlayerPed(playerId)
                if player and player ~= 0 then
                    member.coords = GetEntityCoords(player)
                end
            end
        end
        
        -- Generate dynamic missions
        GenerateDynamicMissions()
        
        -- Generate dynamic events
        GenerateDynamicEvents()
        
        -- Generate team challenges
        GenerateTeamChallenges()
        
        -- Check memory threshold
        PerformanceSystem.CheckMemoryThreshold()
        
        -- Log event count periodically
        local currentTime = GetGameTimer()
        if currentTime - ServerState.lastEventLog > 60000 then -- Every minute
            print('^3[District Zero] ^7Event count: ' .. ServerState.eventCount)
            ServerState.eventCount = 0
            ServerState.lastEventLog = currentTime
        end
    end
end)

-- Resource Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Save all player stats
        for playerId, player in pairs(ServerState.players) do
            DatabaseManager.SavePlayerStats(playerId, player.stats)
        end
        
        -- Log server shutdown
        local uptime = GetGameTimer() - ServerState.serverStartTime
        SecuritySystem.LogAuditEvent('server_shutdown', {
            uptime = uptime,
            players = #ServerState.players
        })
        
        print('^2[District Zero] ^7Server shutdown after ' .. math.floor(uptime / 1000) .. ' seconds')
    end
end)

-- Exports
exports('GetServerState', function()
    return ServerState
end)

exports('GetPerformanceMetrics', function()
    return PerformanceSystem.GetPerformanceMetrics()
end)

exports('GetSecurityMetrics', function()
    return SecuritySystem.GetSecurityMetrics()
end)

exports('OptimizeMemory', function()
    return PerformanceSystem.OptimizeMemory()
end)

print('^2[District Zero] ^7Server main loaded with advanced team system') 

-- Analytics Event Handlers
RegisterNetEvent('dz:analytics:track_event')
AddEventHandler('dz:analytics:track_event', SecureEventHandler('dz:analytics:track_event', {
    category = { type = 'string', pattern = '^[a-zA-Z_]+$', maxLength = 50 },
    eventType = { type = 'string', pattern = '^[a-zA-Z_]+$', maxLength = 50 },
    data = { type = 'table' }
}, function(category, eventType, data)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Add player ID to data
    data.playerId = playerId
    data.timestamp = GetGameTimer()
    
    -- Track analytics event
    AnalyticsSystem.AddAnalyticsData(category, eventType, data)
    
    print('^2[District Zero] ^7Analytics event tracked: ' .. category .. '.' .. eventType .. ' by player ' .. playerId)
end))

RegisterNetEvent('dz:analytics:get_dashboard')
AddEventHandler('dz:analytics:get_dashboard', SecureEventHandler('dz:analytics:get_dashboard', {
    dashboardId = { type = 'string', pattern = '^[a-zA-Z_]+$', maxLength = 50 }
}, function(dashboardId)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Get dashboard data
    local dashboardData = AnalyticsSystem.GetDashboardData(dashboardId)
    if dashboardData then
        TriggerClientEvent('dz:analytics:dashboard_response', source, dashboardId, dashboardData)
    end
end))

RegisterNetEvent('dz:analytics:get_metric')
AddEventHandler('dz:analytics:get_metric', SecureEventHandler('dz:analytics:get_metric', {
    metricId = { type = 'string', pattern = '^[a-zA-Z_]+$', maxLength = 50 }
}, function(metricId)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Calculate metric
    local metricData = AnalyticsSystem.CalculateAnalytics(metricId)
    if metricData then
        TriggerClientEvent('dz:analytics:metric_response', source, metricId, metricData)
    end
end))

-- Enhanced Analytics Integration with Existing Systems
local function TrackPlayerSession(playerId, sessionData)
    AnalyticsSystem.TrackPlayerBehavior(playerId, 'session_time', {
        duration = sessionData.duration,
        startTime = sessionData.startTime,
        endTime = sessionData.endTime,
        activities = sessionData.activities or {}
    })
end

local function TrackPlayerMovement(playerId, movementData)
    AnalyticsSystem.TrackPlayerBehavior(playerId, 'movement_analysis', {
        distance = movementData.distance,
        duration = movementData.duration,
        startCoords = movementData.startCoords,
        endCoords = movementData.endCoords,
        speed = movementData.speed
    })
end

local function TrackPlayerCombat(playerId, combatData)
    AnalyticsSystem.TrackPlayerBehavior(playerId, 'combat_behavior', {
        kills = combatData.kills or 0,
        deaths = combatData.deaths or 0,
        assists = combatData.assists or 0,
        duration = combatData.duration or 0,
        weapon = combatData.weapon,
        location = combatData.location
    })
end

local function TrackTeamCapture(teamId, captureData)
    AnalyticsSystem.TrackTeamPerformance(teamId, 'capture_efficiency', {
        districtId = captureData.districtId,
        successful = captureData.successful,
        duration = captureData.duration,
        participants = captureData.participants,
        resistance = captureData.resistance
    })
end

local function TrackTeamMission(teamId, missionData)
    AnalyticsSystem.TrackTeamPerformance(teamId, 'mission_completion', {
        missionId = missionData.missionId,
        completed = missionData.completed,
        duration = missionData.duration,
        participants = missionData.participants,
        difficulty = missionData.difficulty,
        rewards = missionData.rewards
    })
end

local function TrackTeamWar(teamId, warData)
    AnalyticsSystem.TrackTeamPerformance(teamId, 'war_performance', {
        warId = warData.warId,
        opponent = warData.opponent,
        winner = warData.winner,
        score = warData.score,
        duration = warData.duration,
        participants = warData.participants
    })
end

local function TrackDistrictControl(districtId, controlData)
    AnalyticsSystem.TrackDistrictControl(districtId, 'control_duration', {
        teamId = controlData.teamId,
        duration = controlData.duration,
        startTime = controlData.startTime,
        endTime = controlData.endTime,
        captureCount = controlData.captureCount
    })
end

local function TrackDistrictCapture(districtId, captureData)
    AnalyticsSystem.TrackDistrictControl(districtId, 'capture_frequency', {
        teamId = captureData.teamId,
        timestamp = captureData.timestamp,
        participants = captureData.participants,
        resistance = captureData.resistance,
        duration = captureData.duration
    })
end

local function TrackMissionCompletion(missionId, completionData)
    AnalyticsSystem.TrackMissionStatistics(missionId, 'completion_rate', {
        completed = completionData.completed,
        duration = completionData.duration,
        participants = completionData.participants,
        difficulty = completionData.difficulty,
        rewards = completionData.rewards
    })
end

local function TrackMissionDifficulty(missionId, difficultyData)
    AnalyticsSystem.TrackMissionStatistics(missionId, 'difficulty_analysis', {
        difficulty = difficultyData.difficulty,
        completed = difficultyData.completed,
        duration = difficultyData.duration,
        participants = difficultyData.participants,
        successRate = difficultyData.successRate
    })
end

local function TrackSystemPerformance(performanceData)
    AnalyticsSystem.TrackSystemMetrics('performance', {
        cpu = performanceData.cpu,
        memory = performanceData.memory,
        players = performanceData.players,
        events = performanceData.events,
        uptime = performanceData.uptime
    })
end

local function TrackEconomicTransaction(transactionData)
    AnalyticsSystem.TrackEconomicAnalytics('flow', {
        type = transactionData.type, -- inflow or outflow
        amount = transactionData.amount,
        source = transactionData.source,
        sink = transactionData.sink,
        playerId = transactionData.playerId,
        timestamp = transactionData.timestamp
    })
end

local function TrackSocialInteraction(interactionData)
    AnalyticsSystem.TrackSocialAnalytics('interactions', {
        type = interactionData.type,
        playerId = interactionData.playerId,
        targetId = interactionData.targetId,
        teamId = interactionData.teamId,
        duration = interactionData.duration,
        timestamp = interactionData.timestamp
    })
end

local function TrackPerformanceMetrics(performanceData)
    AnalyticsSystem.TrackPerformanceAnalytics('metrics', {
        fps = performanceData.fps,
        latency = performanceData.latency,
        memory = performanceData.memory,
        cpu = performanceData.cpu,
        timestamp = performanceData.timestamp
    })
end

-- Enhanced Analytics Thread
CreateThread(function()
    while true do
        Wait(ServerState.analyticsUpdateInterval)
        
        local currentTime = GetGameTimer()
        
        -- Update system performance metrics
        local performanceData = PerformanceSystem.GetPerformanceMetrics()
        TrackSystemPerformance(performanceData)
        
        -- Update performance analytics
        TrackPerformanceMetrics({
            fps = performanceData.fps or 0,
            latency = performanceData.latency or 0,
            memory = performanceData.memory or 0,
            cpu = performanceData.cpu or 0,
            timestamp = currentTime
        })
        
        -- Track player activity patterns
        for playerId, player in pairs(ServerState.players) do
            if player.sessionStartTime then
                local sessionDuration = currentTime - player.sessionStartTime
                TrackPlayerSession(playerId, {
                    duration = sessionDuration,
                    startTime = player.sessionStartTime,
                    endTime = currentTime,
                    activities = player.activities or {}
                })
            end
        end
        
        ServerState.lastAnalyticsUpdate = currentTime
    end
end)

-- Analytics Admin Commands
RegisterCommand('dzanalytics', function(source, args, rawCommand)
    if source == 0 then -- Console only
        local subCommand = args[1] and args[1]:lower() or 'help'
        
        if subCommand == 'dashboard' then
            if #args < 2 then
                print('^3[District Zero] ^7Usage: dzanalytics dashboard <dashboardId>')
                return
            end
            
            local dashboardId = args[2]
            local dashboardData = AnalyticsSystem.GetDashboardData(dashboardId)
            
            if dashboardData then
                print('^3[District Zero Analytics Dashboard] ^7' .. dashboardData.name)
                print('  Description: ' .. dashboardData.description)
                print('  Layout: ' .. dashboardData.layout)
                print('  Refresh Interval: ' .. dashboardData.refreshInterval .. 'ms')
                print('  Metrics:')
                for _, metric in ipairs(dashboardData.metrics) do
                    print('    - ' .. metric.name .. ': ' .. tostring(metric.value))
                end
            else
                print('^1[District Zero] ^7Dashboard not found: ' .. dashboardId)
            end
            
        elseif subCommand == 'metric' then
            if #args < 2 then
                print('^3[District Zero] ^7Usage: dzanalytics metric <metricId>')
                return
            end
            
            local metricId = args[2]
            local metricData = AnalyticsSystem.CalculateAnalytics(metricId)
            
            if metricData then
                print('^3[District Zero Analytics Metric] ^7' .. metricData.name)
                print('  Description: ' .. metricData.description)
                print('  Category: ' .. metricData.category)
                print('  Type: ' .. metricData.type)
                print('  Unit: ' .. metricData.unit)
                print('  Value: ' .. tostring(metricData.value))
                print('  Data Points: ' .. metricData.dataPoints)
            else
                print('^1[District Zero] ^7Metric not found: ' .. metricId)
            end
            
        elseif subCommand == 'track' then
            if #args < 4 then
                print('^3[District Zero] ^7Usage: dzanalytics track <category> <eventType> <data>')
                return
            end
            
            local category = args[2]
            local eventType = args[3]
            local data = args[4] or {}
            
            AnalyticsSystem.AddAnalyticsData(category, eventType, {
                test = true,
                data = data,
                timestamp = GetGameTimer()
            })
            
            print('^2[District Zero] ^7Analytics event tracked: ' .. category .. '.' .. eventType)
            
        elseif subCommand == 'list' then
            print('^3[District Zero Analytics] ^7Available Metrics:')
            for metricId, metric in pairs(AnalyticsSystem.analyticsTemplates) do
                print('  ' .. metric.name .. ' (ID: ' .. metricId .. ') - ' .. metric.category)
            end
            
            print('^3[District Zero Analytics] ^7Available Dashboards:')
            for dashboardId, dashboard in pairs(AnalyticsSystem.dashboardTemplates) do
                print('  ' .. dashboard.name .. ' (ID: ' .. dashboardId .. ')')
            end
            
        elseif subCommand == 'stats' then
            print('^3[District Zero Analytics Statistics] ^7')
            local totalMetrics = 0
            local totalDataPoints = 0
            local totalDashboards = 0
            
            for category, data in pairs(AnalyticsSystem.analyticsData) do
                for metricId, metricData in pairs(data) do
                    totalMetrics = totalMetrics + 1
                    totalDataPoints = totalDataPoints + #metricData
                end
            end
            
            for dashboardId, _ in pairs(AnalyticsSystem.dashboardTemplates) do
                totalDashboards = totalDashboards + 1
            end
            
            print('  Total Metrics: ' .. totalMetrics)
            print('  Total Data Points: ' .. totalDataPoints)
            print('  Total Dashboards: ' .. totalDashboards)
            print('  Active Players: ' .. #ServerState.players)
            print('  Last Update: ' .. (ServerState.lastAnalyticsUpdate > 0 and 
                math.floor((GetGameTimer() - ServerState.lastAnalyticsUpdate) / 1000) .. 's ago' or 'Never'))
            
        elseif subCommand == 'clear' then
            if #args < 2 then
                print('^3[District Zero] ^7Usage: dzanalytics clear <category>')
                return
            end
            
            local category = args[2]
            if AnalyticsSystem.analyticsData[category] then
                AnalyticsSystem.analyticsData[category] = {}
                print('^2[District Zero] ^7Cleared analytics data for category: ' .. category)
            else
                print('^1[District Zero] ^7Category not found: ' .. category)
            end
            
        elseif subCommand == 'help' then
            print('^3[District Zero Analytics Commands] ^7Available commands:')
            print('  dzanalytics dashboard <dashboardId> - Get dashboard data')
            print('  dzanalytics metric <metricId> - Get metric data')
            print('  dzanalytics track <category> <eventType> <data> - Track analytics event')
            print('  dzanalytics list - List available metrics and dashboards')
            print('  dzanalytics stats - Show analytics statistics')
            print('  dzanalytics clear <category> - Clear analytics data')
            print('  dzanalytics help - Show this help')
            
        else
            print('^1[District Zero] ^7Unknown analytics command: ' .. subCommand)
        end
    end
end, true)

-- Analytics Dashboard Event Handlers
RegisterNetEvent('dz:analytics:dashboard_response')
AddEventHandler('dz:analytics:dashboard_response', function(dashboardId, dashboardData)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    -- Cache dashboard data
    ServerState.dashboardCache[dashboardId] = {
        data = dashboardData,
        timestamp = GetGameTimer()
    }
    
    print('^2[District Zero] ^7Dashboard data sent to player ' .. playerId .. ': ' .. dashboardId)
end)

RegisterNetEvent('dz:analytics:metric_response')
AddEventHandler('dz:analytics:metric_response', function(metricId, metricData)
    local source = source
    local playerId = GetPlayerServerId(source)
    
    if not ServerState.players[playerId] then
        return
    end
    
    print('^2[District Zero] ^7Metric data sent to player ' .. playerId .. ': ' .. metricId)
end)

print('^2[District Zero] ^7Advanced analytics system integrated')

-- Exports
exports('GetDistrictsSystem', function()
    return DistrictsSystem
end)

exports('GetMissionsSystem', function()
    return MissionsSystem
end)

exports('GetTeamsSystem', function()
    return TeamsSystem
end)

exports('GetEventsSystem', function()
    return EventsSystem
end)

exports('GetAchievementsSystem', function()
    return AchievementsSystem
end)

exports('GetAnalyticsSystem', function()
    return AnalyticsSystem
end)

exports('GetSecuritySystem', function()
    return SecuritySystem
end)

exports('GetPerformanceSystem', function()
    return PerformanceSystem
end)

exports('GetIntegrationSystem', function()
    return IntegrationSystem
end)

exports('GetPolishSystem', function()
    return PolishSystem
end)

exports('GetDeploymentSystem', function()
    return DeploymentSystem
end)

exports('GetReleaseSystem', function()
    return ReleaseSystem
end)

exports('GetUnifiedAPI', function()
    return {
        districts = DistrictsSystem,
        missions = MissionsSystem,
        teams = TeamsSystem,
        events = EventsSystem,
        achievements = AchievementsSystem,
        analytics = AnalyticsSystem,
        security = SecuritySystem,
        performance = PerformanceSystem,
        integration = IntegrationSystem,
        polish = PolishSystem,
        deployment = DeploymentSystem,
        release = ReleaseSystem
    }
end)

exports('GetSystemStatus', function()
    return {
        districts = DistrictsSystem and true or false,
        missions = MissionsSystem and true or false,
        teams = TeamsSystem and true or false,
        events = EventsSystem and true or false,
        achievements = AchievementsSystem and true or false,
        analytics = AnalyticsSystem and true or false,
        security = SecuritySystem and true or false,
        performance = PerformanceSystem and true or false,
        integration = IntegrationSystem and true or false,
        polish = PolishSystem and true or false,
        deployment = DeploymentSystem and true or false,
        release = ReleaseSystem and true or false
    }
end)

exports('GetIntegrationHealth', function()
    return {
        qbx_core = QBX and true or false,
        database = true,
        systems = {
            districts = DistrictsSystem and true or false,
            missions = MissionsSystem and true or false,
            teams = TeamsSystem and true or false,
            events = EventsSystem and true or false,
            achievements = AchievementsSystem and true or false,
            analytics = AnalyticsSystem and true or false,
            security = SecuritySystem and true or false,
            performance = PerformanceSystem and true or false,
            integration = IntegrationSystem and true or false,
            polish = PolishSystem and true or false,
            deployment = DeploymentSystem and true or false,
            release = ReleaseSystem and true or false
        }
    }
end)

-- Add missing exports
exports('GetConfig', function()
    return Config
end)

exports('GetUtils', function()
    return Utils
end)

exports('GetDatabaseManager', function()
    return DatabaseManager
end)

exports('GetAdvancedMissionSystem', function()
    return AdvancedMissionSystem
end)

exports('GetDynamicEventsSystem', function()
    return DynamicEventsSystem
end)

exports('GetAdvancedTeamSystem', function()
    return AdvancedTeamSystem
end)

exports('GetAchievementSystem', function()
    return AchievementSystem
end)

exports('GetDistrictHistory', function(districtId, limit)
    -- Implementation for getting district history
    return {}, "Not implemented yet"
end)

exports('GetPlayerMissionHistory', function(playerId, limit)
    -- Implementation for getting player mission history
    return {}, "Not implemented yet"
end)

exports('GetTeamAnalytics', function(teamType, days)
    -- Implementation for getting team analytics
    return {}, "Not implemented yet"
end)

exports('GetPlayerLeaderboard', function(teamType, limit)
    -- Implementation for getting player leaderboard
    return {}, "Not implemented yet"
end)

exports('GetGlobalLeaderboard', function(limit)
    -- Implementation for getting global leaderboard
    return {}, "Not implemented yet"
end)

exports('GetSystemConfig', function(configKey)
    -- Implementation for getting system config
    if configKey and Config[configKey] then
        return Config[configKey], "Success"
    end
    return Config, "Success"
end) 