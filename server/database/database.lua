-- Database Manager for District Zero
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'

-- Database Configuration
local DatabaseConfig = {
    connectionTimeout = 10000,
    maxRetries = 3,
    retryDelay = 1000,
    batchSize = 100,
    cleanupInterval = 3600000, -- 1 hour
    maxLogAge = 2592000, -- 30 days
    analyticsUpdateInterval = 300000 -- 5 minutes
}

-- Database State
local DatabaseState = {
    isConnected = false,
    lastCleanup = 0,
    lastAnalyticsUpdate = 0,
    pendingOperations = {},
    batchOperations = {}
}

-- Initialize database connection
local function InitializeDatabase()
    local success = pcall(function()
        -- Test database connection
        local result = MySQL.query.await('SELECT 1')
        if result then
            DatabaseState.isConnected = true
            print('^2[District Zero] ^7Database connection established')
            
            -- Run database migrations
            RunDatabaseMigrations()
            
            -- Start cleanup timer
            CreateThread(function()
                while true do
                    Wait(DatabaseConfig.cleanupInterval)
                    CleanupOldData()
                end
            end)
            
            -- Start analytics update timer
            CreateThread(function()
                while true do
                    Wait(DatabaseConfig.analyticsUpdateInterval)
                    UpdateTeamAnalytics()
                end
            end)
            
            return true
        end
    end)
    
    if not success then
        print('^1[District Zero] ^7Failed to connect to database')
        return false
    end
    
    return true
end

-- Run database migrations
local function RunDatabaseMigrations()
    local migrations = {
        -- Add any future migrations here
    }
    
    for i, migration in ipairs(migrations) do
        local success = pcall(function()
            MySQL.query.await(migration)
        end)
        
        if success then
            print('^2[District Zero] ^7Migration ' .. i .. ' completed')
        else
            print('^1[District Zero] ^7Migration ' .. i .. ' failed')
        end
    end
end

-- Player Statistics Management
local function SavePlayerStats(playerId, stats)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO player_stats 
            (player_id, player_name, team_type, total_captures, total_missions, 
             total_eliminations, total_assists, total_team_events, total_points, 
             total_playtime, last_active)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE
            player_name = VALUES(player_name),
            team_type = VALUES(team_type),
            total_captures = VALUES(total_captures),
            total_missions = VALUES(total_missions),
            total_eliminations = VALUES(total_eliminations),
            total_assists = VALUES(total_assists),
            total_team_events = VALUES(total_team_events),
            total_points = VALUES(total_points),
            total_playtime = VALUES(total_playtime),
            last_active = NOW()
        ]]
        
        local Player = QBX.Functions.GetPlayer(playerId)
        local playerName = Player and Player.PlayerData.name or 'Unknown'
        
        MySQL.insert.await(query, {
            playerId,
            playerName,
            stats.team_type or 'neutral',
            stats.total_captures or 0,
            stats.total_missions or 0,
            stats.total_eliminations or 0,
            stats.total_assists or 0,
            stats.total_team_events or 0,
            stats.total_points or 0,
            stats.total_playtime or 0
        })
    end)
    
    return success, success and 'Stats saved' or 'Failed to save stats'
end

local function LoadPlayerStats(playerId)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = 'SELECT * FROM player_stats WHERE player_id = ?'
        local results = MySQL.query.await(query, { playerId })
        return results and results[1] or nil
    end)
    
    if success and result then
        return result, 'Stats loaded'
    else
        return nil, 'Failed to load stats'
    end
end

local function UpdatePlayerStat(playerId, statType, value)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = string.format([[
            INSERT INTO player_stats (player_id, %s, last_active)
            VALUES (?, ?, NOW())
            ON DUPLICATE KEY UPDATE
            %s = %s + VALUES(%s),
            last_active = NOW()
        ]], statType, statType, statType, statType)
        
        MySQL.insert.await(query, { playerId, value })
    end)
    
    return success, success and 'Stat updated' or 'Failed to update stat'
end

-- District History Management
local function LogDistrictCapture(districtId, districtName, controllingTeam, previousTeam, capturedBy, captureMethod, influenceData)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO district_history 
            (district_id, district_name, controlling_team, previous_team, 
             captured_by, capture_method, influence_pvp, influence_pve)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ]]
        
        MySQL.insert.await(query, {
            districtId,
            districtName,
            controllingTeam,
            previousTeam,
            capturedBy,
            captureMethod or 'control_point',
            influenceData and influenceData.pvp or 0,
            influenceData and influenceData.pve or 0
        })
    end)
    
    return success, success and 'District capture logged' or 'Failed to log district capture'
end

local function GetDistrictHistory(districtId, limit)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = string.format([[
            SELECT * FROM district_history 
            WHERE district_id = ? 
            ORDER BY capture_time DESC 
            LIMIT %d
        ]], limit or 10)
        
        return MySQL.query.await(query, { districtId })
    end)
    
    if success then
        return result, 'District history loaded'
    else
        return nil, 'Failed to load district history'
    end
end

-- Control Point History Management
local function LogControlPointCapture(districtId, pointId, pointName, capturingTeam, capturedBy, participants, duration, success)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO control_point_history 
            (district_id, point_id, point_name, capturing_team, captured_by, 
             participants, capture_duration, capture_success, capture_end_time)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ]]
        
        MySQL.insert.await(query, {
            districtId,
            pointId,
            pointName,
            capturingTeam,
            capturedBy,
            json.encode(participants or {}),
            duration or 0,
            success and 1 or 0
        })
    end)
    
    return success, success and 'Control point capture logged' or 'Failed to log control point capture'
end

-- Mission Logs Management
local function LogMissionCompletion(missionId, playerId, missionType, missionTitle, missionDifficulty, districtId, objectives, rewards, duration, success, progressData)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO mission_logs 
            (mission_id, player_id, mission_type, mission_title, mission_difficulty,
             district_id, objectives, rewards, duration, success, progress_data)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]]
        
        MySQL.insert.await(query, {
            missionId,
            playerId,
            missionType,
            missionTitle,
            missionDifficulty,
            districtId,
            json.encode(objectives or {}),
            json.encode(rewards or {}),
            duration or 0,
            success and 1 or 0,
            json.encode(progressData or {})
        })
    end)
    
    return success, success and 'Mission completion logged' or 'Failed to log mission completion'
end

local function GetPlayerMissionHistory(playerId, limit)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = string.format([[
            SELECT * FROM mission_logs 
            WHERE player_id = ? 
            ORDER BY completion_time DESC 
            LIMIT %d
        ]], limit or 20)
        
        return MySQL.query.await(query, { playerId })
    end)
    
    if success then
        return result, 'Mission history loaded'
    else
        return nil, 'Failed to load mission history'
    end
end

-- Team Analytics Management
local function UpdateTeamAnalytics()
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        -- Get current date
        local currentDate = os.date('%Y-%m-%d')
        
        -- Update PVP team analytics
        local pvpQuery = [[
            INSERT INTO team_analytics 
            (team_type, date, total_members, total_captures, total_missions,
             total_eliminations, total_assists, total_team_events, total_points)
            SELECT 
                'pvp' as team_type,
                ? as date,
                COUNT(*) as total_members,
                SUM(total_captures) as total_captures,
                SUM(total_missions) as total_missions,
                SUM(total_eliminations) as total_eliminations,
                SUM(total_assists) as total_assists,
                SUM(total_team_events) as total_team_events,
                SUM(total_points) as total_points
            FROM player_stats 
            WHERE team_type = 'pvp' AND DATE(last_active) = ?
            ON DUPLICATE KEY UPDATE
            total_members = VALUES(total_members),
            total_captures = VALUES(total_captures),
            total_missions = VALUES(total_missions),
            total_eliminations = VALUES(total_eliminations),
            total_assists = VALUES(total_assists),
            total_team_events = VALUES(total_team_events),
            total_points = VALUES(total_points),
            updated_at = NOW()
        ]]
        
        MySQL.insert.await(pvpQuery, { currentDate, currentDate })
        
        -- Update PVE team analytics
        local pveQuery = [[
            INSERT INTO team_analytics 
            (team_type, date, total_members, total_captures, total_missions,
             total_eliminations, total_assists, total_team_events, total_points)
            SELECT 
                'pve' as team_type,
                ? as date,
                COUNT(*) as total_members,
                SUM(total_captures) as total_captures,
                SUM(total_missions) as total_missions,
                SUM(total_eliminations) as total_eliminations,
                SUM(total_assists) as total_assists,
                SUM(total_team_events) as total_team_events,
                SUM(total_points) as total_points
            FROM player_stats 
            WHERE team_type = 'pve' AND DATE(last_active) = ?
            ON DUPLICATE KEY UPDATE
            total_members = VALUES(total_members),
            total_captures = VALUES(total_captures),
            total_missions = VALUES(total_missions),
            total_eliminations = VALUES(total_eliminations),
            total_assists = VALUES(total_assists),
            total_team_events = VALUES(total_team_events),
            total_points = VALUES(total_points),
            updated_at = NOW()
        ]]
        
        MySQL.insert.await(pveQuery, { currentDate, currentDate })
    end)
    
    if success then
        DatabaseState.lastAnalyticsUpdate = GetGameTimer()
        print('^2[District Zero] ^7Team analytics updated')
    end
    
    return success, success and 'Team analytics updated' or 'Failed to update team analytics'
end

local function GetTeamAnalytics(teamType, days)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = string.format([[
            SELECT * FROM team_analytics 
            WHERE team_type = ? 
            AND date >= DATE_SUB(CURDATE(), INTERVAL %d DAY)
            ORDER BY date DESC
        ]], days or 7)
        
        return MySQL.query.await(query, { teamType })
    end)
    
    if success then
        return result, 'Team analytics loaded'
    else
        return nil, 'Failed to load team analytics'
    end
end

-- Team Events Management
local function LogTeamEvent(eventId, eventType, teamType, creatorId, eventData, duration, status, participants, rewardsDistributed)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO team_events 
            (event_id, event_type, team_type, creator_id, event_data, 
             duration, status, participants, rewards_distributed, end_time)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ]]
        
        MySQL.insert.await(query, {
            eventId,
            eventType,
            teamType,
            creatorId,
            json.encode(eventData or {}),
            duration or 0,
            status,
            json.encode(participants or {}),
            json.encode(rewardsDistributed or {})
        })
    end)
    
    return success, success and 'Team event logged' or 'Failed to log team event'
end

-- Session Management
local function StartPlayerSession(playerId, teamType)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO session_logs 
            (player_id, team_type, session_start)
            VALUES (?, ?, NOW())
        ]]
        
        MySQL.insert.await(query, { playerId, teamType or 'neutral' })
    end)
    
    return success, success and 'Session started' or 'Failed to start session'
end

local function EndPlayerSession(playerId, districtsVisited, activitiesPerformed)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            UPDATE session_logs 
            SET session_end = NOW(),
                session_duration = TIMESTAMPDIFF(SECOND, session_start, NOW()),
                districts_visited = ?,
                activities_performed = ?
            WHERE player_id = ? AND session_end IS NULL
            ORDER BY session_start DESC
            LIMIT 1
        ]]
        
        MySQL.update.await(query, {
            json.encode(districtsVisited or {}),
            json.encode(activitiesPerformed or {}),
            playerId
        })
    end)
    
    return success, success and 'Session ended' or 'Failed to end session'
end

-- Influence History Management
local function LogInfluenceChange(districtId, influencePvp, influencePve, influenceNeutral, changeReason)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO district_influence_history 
            (district_id, influence_pvp, influence_pve, influence_neutral, 
             total_influence, change_reason)
            VALUES (?, ?, ?, ?, ?, ?)
        ]]
        
        local totalInfluence = (influencePvp or 0) + (influencePve or 0) + (influenceNeutral or 0)
        
        MySQL.insert.await(query, {
            districtId,
            influencePvp or 0,
            influencePve or 0,
            influenceNeutral or 0,
            totalInfluence,
            changeReason or 'unknown'
        })
    end)
    
    return success, success and 'Influence change logged' or 'Failed to log influence change'
end

-- Achievement Management
local function TrackAchievement(playerId, achievementId, achievementName, achievementDescription, achievementType, progressCurrent, progressRequired)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO achievements 
            (player_id, achievement_id, achievement_name, achievement_description,
             achievement_type, progress_current, progress_required, completed, completed_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
            progress_current = VALUES(progress_current),
            completed = VALUES(completed),
            completed_at = VALUES(completed_at),
            updated_at = NOW()
        ]]
        
        local completed = progressCurrent >= progressRequired
        local completedAt = completed and 'NOW()' or 'NULL'
        
        MySQL.insert.await(query, {
            playerId,
            achievementId,
            achievementName,
            achievementDescription,
            achievementType,
            progressCurrent,
            progressRequired,
            completed and 1 or 0,
            completedAt
        })
    end)
    
    return success, success and 'Achievement tracked' or 'Failed to track achievement'
end

-- System Configuration Management
local function GetSystemConfig(configKey)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = 'SELECT config_value, config_type FROM system_config WHERE config_key = ?'
        local results = MySQL.query.await(query, { configKey })
        return results and results[1] or nil
    end)
    
    if success and result then
        -- Convert value based on type
        if result.config_type == 'integer' then
            return tonumber(result.config_value), 'Config loaded'
        elseif result.config_type == 'float' then
            return tonumber(result.config_value), 'Config loaded'
        elseif result.config_type == 'boolean' then
            return result.config_value == 'true', 'Config loaded'
        elseif result.config_type == 'json' then
            return json.decode(result.config_value), 'Config loaded'
        else
            return result.config_value, 'Config loaded'
        end
    else
        return nil, 'Failed to load config'
    end
end

local function SetSystemConfig(configKey, configValue, configType)
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        local query = [[
            INSERT INTO system_config (config_key, config_value, config_type)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE
            config_value = VALUES(config_value),
            config_type = VALUES(config_type),
            updated_at = NOW()
        ]]
        
        MySQL.insert.await(query, { configKey, tostring(configValue), configType or 'string' })
    end)
    
    return success, success and 'Config saved' or 'Failed to save config'
end

-- Data Cleanup
local function CleanupOldData()
    if not DatabaseState.isConnected then
        return false, 'Database not connected'
    end
    
    local success = pcall(function()
        -- Clean up old session logs
        local sessionQuery = string.format([[
            DELETE FROM session_logs 
            WHERE session_start < DATE_SUB(NOW(), INTERVAL %d DAY)
        ]], DatabaseConfig.maxLogAge / 86400)
        
        MySQL.query.await(sessionQuery)
        
        -- Clean up old influence history
        local influenceQuery = string.format([[
            DELETE FROM district_influence_history 
            WHERE timestamp < DATE_SUB(NOW(), INTERVAL %d DAY)
        ]], DatabaseConfig.maxLogAge / 86400)
        
        MySQL.query.await(influenceQuery)
        
        DatabaseState.lastCleanup = GetGameTimer()
        print('^2[District Zero] ^7Database cleanup completed')
    end)
    
    return success, success and 'Cleanup completed' or 'Failed to cleanup'
end

-- Leaderboard Queries
local function GetPlayerLeaderboard(teamType, limit)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = string.format([[
            SELECT * FROM player_leaderboard 
            WHERE team_type = ?
            ORDER BY total_points DESC
            LIMIT %d
        ]], limit or 10)
        
        return MySQL.query.await(query, { teamType })
    end)
    
    if success then
        return result, 'Leaderboard loaded'
    else
        return nil, 'Failed to load leaderboard'
    end
end

local function GetGlobalLeaderboard(limit)
    if not DatabaseState.isConnected then
        return nil, 'Database not connected'
    end
    
    local success, result = pcall(function()
        local query = string.format([[
            SELECT * FROM player_leaderboard 
            ORDER BY global_rank
            LIMIT %d
        ]], limit or 20)
        
        return MySQL.query.await(query, {})
    end)
    
    if success then
        return result, 'Global leaderboard loaded'
    else
        return nil, 'Failed to load global leaderboard'
    end
end

-- Exports
exports('SavePlayerStats', SavePlayerStats)
exports('LoadPlayerStats', LoadPlayerStats)
exports('UpdatePlayerStat', UpdatePlayerStat)
exports('LogDistrictCapture', LogDistrictCapture)
exports('GetDistrictHistory', GetDistrictHistory)
exports('LogControlPointCapture', LogControlPointCapture)
exports('LogMissionCompletion', LogMissionCompletion)
exports('GetPlayerMissionHistory', GetPlayerMissionHistory)
exports('UpdateTeamAnalytics', UpdateTeamAnalytics)
exports('GetTeamAnalytics', GetTeamAnalytics)
exports('LogTeamEvent', LogTeamEvent)
exports('StartPlayerSession', StartPlayerSession)
exports('EndPlayerSession', EndPlayerSession)
exports('LogInfluenceChange', LogInfluenceChange)
exports('TrackAchievement', TrackAchievement)
exports('GetSystemConfig', GetSystemConfig)
exports('SetSystemConfig', SetSystemConfig)
exports('GetPlayerLeaderboard', GetPlayerLeaderboard)
exports('GetGlobalLeaderboard', GetGlobalLeaderboard)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(2000) -- Wait for database to be ready
        InitializeDatabase()
    end
end) 