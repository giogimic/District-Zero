-- Server Team System Enhancement
-- Version: 1.0.0

local QBoxIntegration = require 'shared/qbox_integration'
local Utils = require 'shared/utils'

-- Get QBX Core object
local QBX = QBoxIntegration.GetCoreObject()

-- Team System State
local TeamSystem = {
    teams = {},
    teamBalance = { pvp = 0, pve = 0 },
    teamEvents = {},
    teamStats = {},
    teamPersistence = {},
    lastUpdate = 0
}

-- Team Configuration
local TeamConfig = {
    maxTeamSize = 50,
    balanceThreshold = 5,
    teamSwitchCooldown = 300000, -- 5 minutes
    teamEventInterval = 600000, -- 10 minutes
    teamBonusMultiplier = 1.2,
    teamCommunicationRange = 100.0,
    persistenceInterval = 300000, -- 5 minutes
    teamRewards = {
        capture = 500,
        mission = 300,
        elimination = 100,
        assist = 50,
        teamEvent = 1000
    }
}

-- Team Types
local TeamTypes = {
    PVP = 'pvp',
    PVE = 'pve',
    NEUTRAL = 'neutral'
}

-- Team Events
local TeamEvents = {
    TEAM_CAPTURE = 'team_capture',
    TEAM_DEFENSE = 'team_defense',
    TEAM_MISSION = 'team_mission',
    TEAM_BATTLE = 'team_battle',
    TEAM_CHALLENGE = 'team_challenge'
}

-- Initialize team system
local function InitializeTeamSystem()
    TeamSystem.teams = {}
    TeamSystem.teamBalance = { pvp = 0, pve = 0 }
    TeamSystem.teamEvents = {}
    TeamSystem.teamStats = {}
    TeamSystem.teamPersistence = {}
    
    print('^2[District Zero] ^7Server team system initialized')
    
    -- Start persistence timer
    CreateThread(function()
        while true do
            Wait(TeamConfig.persistenceInterval)
            SaveTeamPersistence()
        end
    end)
    
    -- Start team event timer
    CreateThread(function()
        while true do
            Wait(TeamConfig.teamEventInterval)
            CreateRandomTeamEvent()
        end
    end)
end

-- Load team persistence
local function LoadTeamPersistence()
    local success, data = pcall(function()
        return json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/teams.json') or '{}')
    end)
    
    if success and data then
        TeamSystem.teamPersistence = data
        print('^2[District Zero] ^7Team persistence loaded')
    else
        print('^3[District Zero] ^7No team persistence found, starting fresh')
    end
end

-- Save team persistence
local function SaveTeamPersistence()
    local data = {
        teams = TeamSystem.teams,
        teamStats = TeamSystem.teamStats,
        lastUpdate = os.time()
    }
    
    local success = pcall(function()
        SaveResourceFile(GetCurrentResourceName(), 'data/teams.json', json.encode(data), -1)
    end)
    
    if success then
        print('^2[District Zero] ^7Team persistence saved')
    else
        print('^1[District Zero] ^7Failed to save team persistence')
    end
end

-- Get player team
local function GetPlayerTeam(source)
    for teamType, members in pairs(TeamSystem.teams) do
        if members[source] then
            return teamType
        end
    end
    return nil
end

-- Add player to team
local function AddPlayerToTeam(source, teamType)
    if not teamType or (teamType ~= TeamTypes.PVP and teamType ~= TeamTypes.PVE) then
        return false, 'Invalid team type'
    end
    
    -- Remove from current team first
    local currentTeam = GetPlayerTeam(source)
    if currentTeam then
        RemovePlayerFromTeam(source, currentTeam)
    end
    
    -- Check team balance
    local currentBalance = TeamSystem.teamBalance
    local targetTeamCount = currentBalance[teamType] or 0
    local otherTeamCount = currentBalance[teamType == TeamTypes.PVP and TeamTypes.PVE or TeamTypes.PVP] or 0
    
    if targetTeamCount - otherTeamCount >= TeamConfig.balanceThreshold then
        return false, 'Team is full, please join the other team'
    end
    
    -- Initialize team if doesn't exist
    if not TeamSystem.teams[teamType] then
        TeamSystem.teams[teamType] = {}
    end
    
    -- Add player to team
    TeamSystem.teams[teamType][source] = {
        id = source,
        team = teamType,
        joinTime = os.time(),
        stats = {
            captures = 0,
            missions = 0,
            eliminations = 0,
            assists = 0,
            teamEvents = 0
        }
    }
    
    -- Update team balance
    TeamSystem.teamBalance[teamType] = (TeamSystem.teamBalance[teamType] or 0) + 1
    
    -- Notify all clients
    TriggerClientEvent('dz:client:team:memberJoined', -1, source, teamType)
    TriggerClientEvent('dz:client:team:balanceUpdate', -1, TeamSystem.teamBalance)
    
    -- Load persistent stats if available
    if TeamSystem.teamPersistence[source] then
        TeamSystem.teams[teamType][source].stats = TeamSystem.teamPersistence[source].stats or TeamSystem.teams[teamType][source].stats
    end
    
    return true, 'Player added to team'
end

-- Remove player from team
local function RemovePlayerFromTeam(source, teamType)
    if not TeamSystem.teams[teamType] or not TeamSystem.teams[teamType][source] then
        return false, 'Player not in team'
    end
    
    -- Save stats to persistence
    TeamSystem.teamPersistence[source] = {
        stats = TeamSystem.teams[teamType][source].stats,
        lastTeam = teamType,
        lastUpdate = os.time()
    }
    
    -- Remove from team
    TeamSystem.teams[teamType][source] = nil
    
    -- Update team balance
    TeamSystem.teamBalance[teamType] = math.max(0, (TeamSystem.teamBalance[teamType] or 0) - 1)
    
    -- Notify all clients
    TriggerClientEvent('dz:client:team:memberLeft', -1, source, teamType)
    TriggerClientEvent('dz:client:team:balanceUpdate', -1, TeamSystem.teamBalance)
    
    return true, 'Player removed from team'
end

-- Update player stats
local function UpdatePlayerStats(source, statType, value)
    local teamType = GetPlayerTeam(source)
    if not teamType or not TeamSystem.teams[teamType] or not TeamSystem.teams[teamType][source] then
        return false, 'Player not in team'
    end
    
    local playerData = TeamSystem.teams[teamType][source]
    playerData.stats[statType] = (playerData.stats[statType] or 0) + (value or 1)
    
    -- Award rewards if applicable
    if TeamConfig.teamRewards[statType] then
        local reward = TeamConfig.teamRewards[statType] * (value or 1)
        local Player = QBX.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('cash', reward)
            TriggerClientEvent('dz:client:notification', source, 'Team reward: $' .. reward, 'success')
        end
    end
    
    return true, 'Stats updated'
end

-- Create team event
local function CreateTeamEvent(eventType, data, source)
    local teamType = GetPlayerTeam(source)
    if not teamType then
        return false, 'Player not in team'
    end
    
    local eventId = Utils.GenerateId()
    local event = {
        id = eventId,
        type = eventType,
        team = teamType,
        creator = source,
        data = data or {},
        startTime = os.time(),
        participants = {},
        status = 'active'
    }
    
    TeamSystem.teamEvents[eventId] = event
    
    -- Notify all clients
    TriggerClientEvent('dz:client:team:eventCreated', -1, event)
    
    return true, eventId
end

-- Join team event
local function JoinTeamEvent(eventId, source)
    local event = TeamSystem.teamEvents[eventId]
    if not event then
        return false, 'Event not found'
    end
    
    local teamType = GetPlayerTeam(source)
    if event.team ~= teamType then
        return false, 'Event is for different team'
    end
    
    if event.status ~= 'active' then
        return false, 'Event is not active'
    end
    
    event.participants[source] = {
        joinTime = os.time(),
        stats = {}
    }
    
    return true, 'Joined team event'
end

-- Complete team event
local function CompleteTeamEvent(eventId, success, source)
    local event = TeamSystem.teamEvents[eventId]
    if not event then
        return false, 'Event not found'
    end
    
    event.status = success and 'completed' or 'failed'
    event.endTime = os.time()
    
    -- Award team bonuses
    if success then
        local participantCount = 0
        for _, _ in pairs(event.participants) do
            participantCount = participantCount + 1
        end
        
        if participantCount > 0 then
            local bonus = math.floor(TeamConfig.teamRewards.teamEvent * TeamConfig.teamBonusMultiplier / participantCount)
            
            for participantId, _ in pairs(event.participants) do
                UpdatePlayerStats(participantId, 'teamEvents', 1)
                
                local Player = QBX.Functions.GetPlayer(participantId)
                if Player then
                    Player.Functions.AddMoney('cash', bonus)
                    TriggerClientEvent('dz:client:notification', participantId, 'Team event reward: $' .. bonus, 'success')
                end
            end
        end
    end
    
    -- Notify all clients
    TriggerClientEvent('dz:client:team:eventCompleted', -1, eventId, success)
    
    return true, 'Team event completed'
end

-- Create random team event
local function CreateRandomTeamEvent()
    local eventTypes = {
        TeamEvents.TEAM_CAPTURE,
        TeamEvents.TEAM_DEFENSE,
        TeamEvents.TEAM_MISSION,
        TeamEvents.TEAM_BATTLE,
        TeamEvents.TEAM_CHALLENGE
    }
    
    local randomEvent = eventTypes[math.random(1, #eventTypes)]
    local eventId = Utils.GenerateId()
    
    local event = {
        id = eventId,
        type = randomEvent,
        team = math.random() > 0.5 and TeamTypes.PVP or TeamTypes.PVE,
        creator = 'system',
        data = {
            description = 'Random team event: ' .. randomEvent,
            duration = 300, -- 5 minutes
            reward = 1500
        },
        startTime = os.time(),
        participants = {},
        status = 'active'
    }
    
    TeamSystem.teamEvents[eventId] = event
    
    -- Notify all clients
    TriggerClientEvent('dz:client:team:eventCreated', -1, event)
    
    -- Auto-complete after duration
    SetTimeout(event.data.duration * 1000, function()
        if TeamSystem.teamEvents[eventId] and TeamSystem.teamEvents[eventId].status == 'active' then
            CompleteTeamEvent(eventId, true)
        end
    end)
end

-- Get team leaderboard
local function GetTeamLeaderboard()
    local leaderboard = {
        pvp = {},
        pve = {}
    }
    
    for teamType, members in pairs(TeamSystem.teams) do
        for playerId, memberData in pairs(members) do
            table.insert(leaderboard[teamType], {
                id = playerId,
                stats = memberData.stats,
                joinTime = memberData.joinTime
            })
        end
    end
    
    -- Sort by total stats
    for team, members in pairs(leaderboard) do
        table.sort(members, function(a, b)
            local aTotal = (a.stats.captures or 0) + (a.stats.missions or 0) + (a.stats.eliminations or 0)
            local bTotal = (b.stats.captures or 0) + (b.stats.missions or 0) + (b.stats.eliminations or 0)
            return aTotal > bTotal
        end)
    end
    
    return leaderboard
end

-- Send team message
local function SendTeamMessage(targetId, message, source)
    local teamType = GetPlayerTeam(source)
    if not teamType then
        return false, 'Not in a team'
    end
    
    TriggerClientEvent('dz:client:team:receiveMessage', targetId, message, source, teamType)
    return true, 'Message sent'
end

-- Event handlers
RegisterNetEvent('dz:server:team:join', function(teamType)
    local source = source
    local success, message = AddPlayerToTeam(source, teamType)
    
    if not success then
        TriggerClientEvent('dz:client:notification', source, message, 'error')
    end
end)

RegisterNetEvent('dz:server:team:leave', function(teamType)
    local source = source
    local success, message = RemovePlayerFromTeam(source, teamType)
    
    if not success then
        TriggerClientEvent('dz:client:notification', source, message, 'error')
    end
end)

RegisterNetEvent('dz:server:team:updateStats', function(statType, value)
    local source = source
    local success, message = UpdatePlayerStats(source, statType, value)
    
    if not success then
        print('^1[District Zero] ^7Failed to update stats: ' .. message)
    end
end)

RegisterNetEvent('dz:server:team:createEvent', function(event)
    local source = source
    local success, eventId = CreateTeamEvent(event.type, event.data, source)
    
    if not success then
        TriggerClientEvent('dz:client:notification', source, eventId, 'error')
    end
end)

RegisterNetEvent('dz:server:team:joinEvent', function(eventId)
    local source = source
    local success, message = JoinTeamEvent(eventId, source)
    
    if not success then
        TriggerClientEvent('dz:client:notification', source, message, 'error')
    end
end)

RegisterNetEvent('dz:server:team:completeEvent', function(eventId, success)
    local source = source
    local success, message = CompleteTeamEvent(eventId, success, source)
    
    if not success then
        TriggerClientEvent('dz:client:notification', source, message, 'error')
    end
end)

RegisterNetEvent('dz:server:team:eventReward', function(eventId, bonus)
    local source = source
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddMoney('cash', bonus)
        TriggerClientEvent('dz:client:notification', source, 'Team event reward: $' .. bonus, 'success')
    end
end)

RegisterNetEvent('dz:server:team:sendMessage', function(targetId, message)
    local source = source
    local success, message = SendTeamMessage(targetId, message, source)
    
    if not success then
        TriggerClientEvent('dz:client:notification', source, message, 'error')
    end
end)

-- Commands
QBX.Commands.Add('jointeam', 'Join a team (pvp/pve)', {{name = 'team', help = 'Team type (pvp/pve)'}}, true, function(source, args)
    local teamType = args[1] and args[1]:lower()
    if not teamType or (teamType ~= 'pvp' and teamType ~= 'pve') then
        TriggerClientEvent('dz:client:notification', source, 'Usage: /jointeam [pvp/pve]', 'error')
        return
    end
    
    local success, message = AddPlayerToTeam(source, teamType)
    TriggerClientEvent('dz:client:notification', source, message, success and 'success' or 'error')
end)

QBX.Commands.Add('leaveteam', 'Leave current team', {}, true, function(source, args)
    local currentTeam = GetPlayerTeam(source)
    if not currentTeam then
        TriggerClientEvent('dz:client:notification', source, 'Not in a team', 'error')
        return
    end
    
    local success, message = RemovePlayerFromTeam(source, currentTeam)
    TriggerClientEvent('dz:client:notification', source, message, success and 'success' or 'error')
end)

QBX.Commands.Add('switchteam', 'Switch to different team', {{name = 'team', help = 'Team type (pvp/pve)'}}, true, function(source, args)
    local teamType = args[1] and args[1]:lower()
    if not teamType or (teamType ~= 'pvp' and teamType ~= 'pve') then
        TriggerClientEvent('dz:client:notification', source, 'Usage: /switchteam [pvp/pve]', 'error')
        return
    end
    
    local currentTeam = GetPlayerTeam(source)
    if currentTeam == teamType then
        TriggerClientEvent('dz:client:notification', source, 'Already in this team', 'error')
        return
    end
    
    -- Remove from current team
    if currentTeam then
        RemovePlayerFromTeam(source, currentTeam)
    end
    
    -- Add to new team
    local success, message = AddPlayerToTeam(source, teamType)
    TriggerClientEvent('dz:client:notification', source, message, success and 'success' or 'error')
end)

QBX.Commands.Add('teamstats', 'Show team statistics', {}, true, function(source, args)
    local currentTeam = GetPlayerTeam(source)
    if not currentTeam then
        TriggerClientEvent('dz:client:notification', source, 'Not in a team', 'error')
            return
        end
        
    local playerData = TeamSystem.teams[currentTeam][source]
    if playerData then
        local stats = playerData.stats
        local message = string.format('Team Stats - Captures: %d, Missions: %d, Eliminations: %d, Assists: %d, Team Events: %d',
            stats.captures or 0, stats.missions or 0, stats.eliminations or 0, stats.assists or 0, stats.teamEvents or 0)
        TriggerClientEvent('dz:client:notification', source, message, 'info')
    end
end)

QBX.Commands.Add('teamleaderboard', 'Show team leaderboard', {}, true, function(source, args)
    local leaderboard = GetTeamLeaderboard()
    local message = 'Team Leaderboard:\n'
    
    for team, members in pairs(leaderboard) do
        message = message .. '\n' .. team:upper() .. ':\n'
        for i = 1, math.min(5, #members) do
            local member = members[i]
            local total = (member.stats.captures or 0) + (member.stats.missions or 0) + (member.stats.eliminations or 0)
            message = message .. string.format('%d. Player %d: %d points\n', i, member.id, total)
        end
    end
    
    TriggerClientEvent('dz:client:notification', source, message, 'info')
end)

QBX.Commands.Add('createteamevent', 'Create a team event', {{name = 'type', help = 'Event type'}, {name = 'description', help = 'Event description'}}, true, function(source, args)
    local eventType = args[1]
    local description = args[2] or 'Custom team event'
    
    if not eventType then
        TriggerClientEvent('dz:client:notification', source, 'Usage: /createteamevent [type] [description]', 'error')
        return
    end
    
    local data = { description = description }
    local success, eventId = CreateTeamEvent(eventType, data, source)
    
    if success then
        TriggerClientEvent('dz:client:notification', source, 'Team event created: ' .. eventId, 'success')
    else
        TriggerClientEvent('dz:client:notification', source, eventId, 'error')
    end
end)

-- Exports
exports('GetPlayerTeam', function(source)
    return GetPlayerTeam(source)
end)

exports('AddPlayerToTeam', function(source, teamType)
    return AddPlayerToTeam(source, teamType)
end)

exports('RemovePlayerFromTeam', function(source, teamType)
    return RemovePlayerFromTeam(source, teamType)
end)

exports('UpdatePlayerStats', function(source, statType, value)
    return UpdatePlayerStats(source, statType, value)
end)

exports('GetTeamLeaderboard', function()
    return GetTeamLeaderboard()
end)

exports('GetTeamBalance', function()
    return TeamSystem.teamBalance
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        LoadTeamPersistence()
        InitializeTeamSystem()
    end
end)

-- Save persistence on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        SaveTeamPersistence()
    end
end) 