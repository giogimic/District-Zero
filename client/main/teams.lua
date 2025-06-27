-- Team System Enhancement
-- Version: 1.0.0

local QBoxIntegration = require 'shared/qbox_integration'
local Utils = require 'shared/utils'

-- Get QBX Core object
local QBX = QBoxIntegration.GetCoreObject()

-- Team System State
local TeamSystem = {
    currentTeam = nil,
    teamMembers = {},
    teamBalance = { pvp = 0, pve = 0 },
    teamEvents = {},
    teamStats = {},
    lastUpdate = 0
}

-- Team Configuration
local TeamConfig = {
    maxTeamSize = 50,
    balanceThreshold = 5, -- Max difference between teams
    teamSwitchCooldown = 300000, -- 5 minutes
    teamEventInterval = 600000, -- 10 minutes
    teamBonusMultiplier = 1.2, -- 20% bonus for team activities
    teamCommunicationRange = 100.0 -- Voice chat range
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
    TeamSystem.currentTeam = nil
    TeamSystem.teamMembers = {}
    TeamSystem.teamBalance = { pvp = 0, pve = 0 }
    TeamSystem.teamEvents = {}
    TeamSystem.teamStats = {}
    
    print('^2[District Zero] ^7Team system initialized')
end

-- Join team
local function JoinTeam(teamType)
    if not teamType or (teamType ~= TeamTypes.PVP and teamType ~= TeamTypes.PVE) then
        return false, 'Invalid team type'
    end
    
    -- Check if player is already in a team
    if TeamSystem.currentTeam then
        return false, 'Already in a team'
    end
    
    -- Check team balance
    local currentBalance = TeamSystem.teamBalance
    local targetTeamCount = currentBalance[teamType] or 0
    local otherTeamCount = currentBalance[teamType == TeamTypes.PVP and TeamTypes.PVE or TeamTypes.PVP] or 0
    
    if targetTeamCount - otherTeamCount >= TeamConfig.balanceThreshold then
        return false, 'Team is full, please join the other team'
    end
    
    -- Join team
    TeamSystem.currentTeam = teamType
    
    -- Update team balance
    TeamSystem.teamBalance[teamType] = (TeamSystem.teamBalance[teamType] or 0) + 1
    
    -- Add to team members
    local playerId = GetPlayerServerId(PlayerId())
    TeamSystem.teamMembers[playerId] = {
        id = playerId,
        team = teamType,
        joinTime = GetGameTimer(),
        stats = {
            captures = 0,
            missions = 0,
            eliminations = 0,
            assists = 0
        }
    }
    
    -- Notify server
    TriggerServerEvent('dz:server:team:join', teamType)
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Joined ' .. teamType:upper() .. ' team!', 'success')
    end
    
    return true, 'Team joined successfully'
end

-- Leave team
local function LeaveTeam()
    if not TeamSystem.currentTeam then
        return false, 'Not in a team'
    end
    
    local teamType = TeamSystem.currentTeam
    local playerId = GetPlayerServerId(PlayerId())
    
    -- Update team balance
    TeamSystem.teamBalance[teamType] = math.max(0, (TeamSystem.teamBalance[teamType] or 0) - 1)
    
    -- Remove from team members
    TeamSystem.teamMembers[playerId] = nil
    TeamSystem.currentTeam = nil
    
    -- Notify server
    TriggerServerEvent('dz:server:team:leave', teamType)
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Left ' .. teamType:upper() .. ' team', 'info')
    end
    
    return true, 'Team left successfully'
end

-- Switch team
local function SwitchTeam(newTeamType)
    if not newTeamType or (newTeamType ~= TeamTypes.PVP and newTeamType ~= TeamTypes.PVE) then
        return false, 'Invalid team type'
    end
    
    if not TeamSystem.currentTeam then
        return JoinTeam(newTeamType)
    end
    
    if TeamSystem.currentTeam == newTeamType then
        return false, 'Already in this team'
    end
    
    -- Check cooldown
    local lastSwitch = TeamSystem.teamStats.lastSwitch or 0
    local currentTime = GetGameTimer()
    if currentTime - lastSwitch < TeamConfig.teamSwitchCooldown then
        local remaining = math.ceil((TeamConfig.teamSwitchCooldown - (currentTime - lastSwitch)) / 1000)
        return false, 'Team switch cooldown: ' .. remaining .. ' seconds remaining'
    end
    
    -- Leave current team
    local success, message = LeaveTeam()
    if not success then
        return false, message
    end
    
    -- Join new team
    success, message = JoinTeam(newTeamType)
    if not success then
        return false, message
    end
    
    -- Update switch time
    TeamSystem.teamStats.lastSwitch = currentTime
    
    return true, 'Team switched successfully'
end

-- Get team members in range
local function GetTeamMembersInRange(range)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local teamMembers = {}
    
    for playerId, memberData in pairs(TeamSystem.teamMembers) do
        if memberData.team == TeamSystem.currentTeam then
            local targetPed = GetPlayerPed(GetPlayerFromServerId(playerId))
            if targetPed and targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)
                
                if distance <= range then
                    table.insert(teamMembers, {
                        id = playerId,
                        coords = targetCoords,
                        distance = distance,
                        data = memberData
                    })
                end
            end
        end
    end
    
    return teamMembers
end

-- Update team stats
local function UpdateTeamStats(statType, value)
    if not TeamSystem.currentTeam then
        return false
    end
    
    local playerId = GetPlayerServerId(PlayerId())
    local memberData = TeamSystem.teamMembers[playerId]
    
    if memberData and memberData.stats then
        memberData.stats[statType] = (memberData.stats[statType] or 0) + (value or 1)
        
        -- Notify server
        TriggerServerEvent('dz:server:team:updateStats', statType, value)
        
        return true
    end
    
    return false
end

-- Create team event
local function CreateTeamEvent(eventType, data)
    if not TeamSystem.currentTeam then
        return false, 'Not in a team'
    end
    
    local eventId = Utils.GenerateId()
    local event = {
        id = eventId,
        type = eventType,
        team = TeamSystem.currentTeam,
        data = data or {},
        startTime = GetGameTimer(),
        participants = {},
        status = 'active'
    }
    
    TeamSystem.teamEvents[eventId] = event
    
    -- Notify server
    TriggerServerEvent('dz:server:team:createEvent', event)
    
    return true, eventId
end

-- Join team event
local function JoinTeamEvent(eventId)
    local event = TeamSystem.teamEvents[eventId]
    if not event then
        return false, 'Event not found'
    end
    
    if event.team ~= TeamSystem.currentTeam then
        return false, 'Event is for different team'
    end
    
    if event.status ~= 'active' then
        return false, 'Event is not active'
    end
    
    local playerId = GetPlayerServerId(PlayerId())
    event.participants[playerId] = {
        joinTime = GetGameTimer(),
        stats = {}
    }
    
    -- Notify server
    TriggerServerEvent('dz:server:team:joinEvent', eventId)
    
    return true, 'Joined team event'
end

-- Complete team event
local function CompleteTeamEvent(eventId, success)
    local event = TeamSystem.teamEvents[eventId]
    if not event then
        return false, 'Event not found'
    end
    
    event.status = success and 'completed' or 'failed'
    event.endTime = GetGameTimer()
    
    -- Award team bonuses
    if success then
        local participantCount = 0
        for _, _ in pairs(event.participants) do
            participantCount = participantCount + 1
        end
        
        if participantCount > 0 then
            local bonus = math.floor(1000 * TeamConfig.teamBonusMultiplier / participantCount)
            UpdateTeamStats('teamEvents', 1)
            
            -- Notify participants
            TriggerServerEvent('dz:server:team:eventReward', eventId, bonus)
        end
    end
    
    -- Notify server
    TriggerServerEvent('dz:server:team:completeEvent', eventId, success)
    
    return true, 'Team event completed'
end

-- Get team leaderboard
local function GetTeamLeaderboard()
    local leaderboard = {
        pvp = {},
        pve = {}
    }
    
    for playerId, memberData in pairs(TeamSystem.teamMembers) do
        local team = memberData.team
        if team == TeamTypes.PVP or team == TeamTypes.PVE then
            table.insert(leaderboard[team], {
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

-- Event handlers
RegisterNetEvent('dz:client:team:update', function(data)
    for key, value in pairs(data) do
        TeamSystem[key] = value
    end
end)

RegisterNetEvent('dz:client:team:balanceUpdate', function(balance)
    TeamSystem.teamBalance = balance
end)

RegisterNetEvent('dz:client:team:memberJoined', function(playerId, teamType)
    TeamSystem.teamMembers[playerId] = {
        id = playerId,
        team = teamType,
        joinTime = GetGameTimer(),
        stats = {
            captures = 0,
            missions = 0,
            eliminations = 0,
            assists = 0
        }
    }
    
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Player joined ' .. teamType:upper() .. ' team', 'info')
    end
end)

RegisterNetEvent('dz:client:team:memberLeft', function(playerId, teamType)
    TeamSystem.teamMembers[playerId] = nil
    
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Player left ' .. teamType:upper() .. ' team', 'info')
    end
end)

RegisterNetEvent('dz:client:team:eventCreated', function(event)
    TeamSystem.teamEvents[event.id] = event
    
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Team event started: ' .. event.type, 'info')
    end
end)

RegisterNetEvent('dz:client:team:eventCompleted', function(eventId, success)
    local event = TeamSystem.teamEvents[eventId]
    if event then
        event.status = success and 'completed' or 'failed'
        
        if QBX and QBX.Functions then
            local message = success and 'Team event completed!' or 'Team event failed'
            QBX.Functions.Notify(message, success and 'success' or 'error')
        end
    end
end)

-- Team communication system
local function SendTeamMessage(message)
    if not TeamSystem.currentTeam then
        return false, 'Not in a team'
    end
    
    local teamMembers = GetTeamMembersInRange(TeamConfig.teamCommunicationRange)
    
    for _, member in ipairs(teamMembers) do
        TriggerServerEvent('dz:server:team:sendMessage', member.id, message)
    end
    
    return true, 'Message sent to team'
end

-- Exports
exports('GetCurrentTeam', function()
    return TeamSystem.currentTeam
end)

exports('GetTeamMembers', function()
    return TeamSystem.teamMembers
end)

exports('GetTeamBalance', function()
    return TeamSystem.teamBalance
end)

exports('JoinTeam', function(teamType)
    return JoinTeam(teamType)
end)

exports('LeaveTeam', function()
    return LeaveTeam()
end)

exports('SwitchTeam', function(newTeamType)
    return SwitchTeam(newTeamType)
end)

exports('GetTeamMembersInRange', function(range)
    return GetTeamMembersInRange(range or TeamConfig.teamCommunicationRange)
end)

exports('UpdateTeamStats', function(statType, value)
    return UpdateTeamStats(statType, value)
end)

exports('CreateTeamEvent', function(eventType, data)
    return CreateTeamEvent(eventType, data)
end)

exports('JoinTeamEvent', function(eventId)
    return JoinTeamEvent(eventId)
end)

exports('CompleteTeamEvent', function(eventId, success)
    return CompleteTeamEvent(eventId, success)
end)

exports('GetTeamLeaderboard', function()
    return GetTeamLeaderboard()
end)

exports('SendTeamMessage', function(message)
    return SendTeamMessage(message)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(1000)
        InitializeTeamSystem()
    end
end) 