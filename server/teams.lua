-- District Zero Teams Server Module
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

-- Team State Management
local TeamState = {
    players = {},
    teamStats = {
        pvp = { count = 0, influence = 0 },
        pve = { count = 0, influence = 0 }
    },
    lastSync = 0,
    syncInterval = 5000 -- 5 seconds
}

-- Team Configuration
local TEAMS = {
    PVP = 'pvp',
    PVE = 'pve'
}

-- Initialize teams
local function InitializeTeams()
    Utils.PrintDebug('Initializing teams system...')
    
    -- Load team data from database
    local success = pcall(function()
        local result = MySQL.query.await('SELECT * FROM dz_players WHERE team IS NOT NULL')
        if result then
            for _, player in ipairs(result) do
                -- Note: We can't directly map citizenid to playerId here
                -- This will be handled when players join
                Utils.PrintDebug('Found team data for player: ' .. player.citizenid)
            end
        end
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to load team data from database')
        return false
    end
    
    Utils.PrintDebug('Teams system initialized successfully')
    return true
end

-- Get player team
local function GetPlayerTeam(playerId)
    return TeamState.players[playerId] and TeamState.players[playerId].team or nil
end

-- Set player team
local function SetPlayerTeam(playerId, team)
    if not QBX then
        Utils.PrintError('QBX Core not available', 'SetPlayerTeam')
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'Core system not available'
        })
        return false
    end
    
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then 
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'Player data not found'
        })
        return false
    end
    
    if team ~= TEAMS.PVP and team ~= TEAMS.PVE then
        TriggerClientEvent('ox_lib:notify', playerId, {
            type = 'error',
            description = 'Invalid team selection'
        })
        return false
    end
    
    -- Get old team for stats update
    local oldTeam = TeamState.players[playerId] and TeamState.players[playerId].team
    
    -- Update player team
    TeamState.players[playerId] = {
        team = team,
        citizenid = player.PlayerData.citizenid,
        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        setTime = GetGameTimer()
    }
    
    -- Update team stats
    if oldTeam then
        TeamState.teamStats[oldTeam].count = math.max(0, TeamState.teamStats[oldTeam].count - 1)
    end
    TeamState.teamStats[team].count = TeamState.teamStats[team].count + 1
    
    -- Save to database
    MySQL.insert.await([[
        INSERT INTO dz_players (citizenid, team, last_updated)
        VALUES (?, ?, CURRENT_TIMESTAMP)
        ON DUPLICATE KEY UPDATE team = ?, last_updated = CURRENT_TIMESTAMP
    ]], {player.PlayerData.citizenid, team, team})
    
    -- Notify client
    TriggerClientEvent('dz:client:teamSelected', playerId, team)
    TriggerClientEvent('ox_lib:notify', playerId, {
        type = 'success',
        description = 'Joined ' .. (team == TEAMS.PVP and 'PvP' or 'PvE') .. ' team'
    })
    
    -- Update district influence for all districts the player is in
    for districtId, district in pairs(exports['district-zero']:GetAllDistricts()) do
        if district.players and district.players[playerId] then
            district.players[playerId].team = team
            exports['district-zero']:CalculateDistrictInfluence(districtId)
        end
    end
    
    Utils.PrintDebug('Player ' .. playerId .. ' joined team ' .. team)
    return true
end

-- Get team statistics
local function GetTeamStats()
    return TeamState.teamStats
end

-- Get players in team
local function GetTeamPlayers(team)
    local players = {}
    for playerId, playerData in pairs(TeamState.players) do
        if playerData.team == team then
            table.insert(players, {
                id = playerId,
                name = playerData.name,
                setTime = playerData.setTime
            })
        end
    end
    return players
end

-- Get team balance
local function GetTeamBalance()
    local pvpCount = TeamState.teamStats.pvp.count
    local pveCount = TeamState.teamStats.pve.count
    local total = pvpCount + pveCount
    
    if total == 0 then
        return { pvp = 0.5, pve = 0.5 }
    end
    
    return {
        pvp = pvpCount / total,
        pve = pveCount / total
    }
end

-- Suggest team for player (for balance)
local function SuggestTeam(playerId)
    local balance = GetTeamBalance()
    
    if balance.pvp < balance.pve then
        return TEAMS.PVP
    elseif balance.pve < balance.pvp then
        return TEAMS.PVE
    else
        -- Equal balance, return random
        return math.random() < 0.5 and TEAMS.PVP or TEAMS.PVE
    end
end

-- Check if player can join team (for balance)
local function CanJoinTeam(playerId, team)
    local balance = GetTeamBalance()
    local currentTeam = GetPlayerTeam(playerId)
    
    -- If player is already in this team, allow
    if currentTeam == team then
        return true
    end
    
    -- Check team balance
    if team == TEAMS.PVP and balance.pvp > 0.6 then
        return false, 'PvP team is full'
    elseif team == TEAMS.PVE and balance.pve > 0.6 then
        return false, 'PvE team is full'
    end
    
    return true
end

-- Sync team state to clients
local function SyncTeamState()
    local currentTime = GetGameTimer()
    
    if currentTime - TeamState.lastSync < TeamState.syncInterval then
        return
    end
    
    TeamState.lastSync = currentTime
    
    -- Send team state to all clients
    for _, playerId in ipairs(GetPlayers()) do
        local playerTeam = GetPlayerTeam(playerId)
        local teamStats = GetTeamStats()
        local teamBalance = GetTeamBalance()
        
        TriggerClientEvent('dz:client:team:sync', playerId, {
            currentTeam = playerTeam,
            stats = teamStats,
            balance = teamBalance
        })
    end
end

-- Event handlers
RegisterNetEvent('dz:server:selectTeam', function(team)
    local source = source
    local canJoin, reason = CanJoinTeam(source, team)
    
    if not canJoin then
        TriggerClientEvent('QBCore:Notify', source, reason, 'error')
        return
    end
    
    SetPlayerTeam(source, team)
end)

RegisterNetEvent('dz:server:team:getInfo', function()
    local source = source
    local playerTeam = GetPlayerTeam(source)
    local teamStats = GetTeamStats()
    local teamBalance = GetTeamBalance()
    local suggestedTeam = SuggestTeam(source)
    
    TriggerClientEvent('dz:client:team:info', source, {
        currentTeam = playerTeam,
        stats = teamStats,
        balance = teamBalance,
        suggestedTeam = suggestedTeam
    })
end)

RegisterNetEvent('dz:server:team:getPlayers', function(team)
    local source = source
    local players = GetTeamPlayers(team)
    TriggerClientEvent('dz:client:team:players', source, team, players)
end)

-- Player cleanup
AddEventHandler('playerDropped', function()
    local source = source
    
    -- Update team stats
    local playerTeam = TeamState.players[source] and TeamState.players[source].team
    if playerTeam then
        TeamState.teamStats[playerTeam].count = math.max(0, TeamState.teamStats[playerTeam].count - 1)
    end
    
    -- Remove player from team state
    TeamState.players[source] = nil
end)

-- State sync thread
CreateThread(function()
    while true do
        Wait(TeamState.syncInterval)
        SyncTeamState()
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for database to be ready
    CreateThread(function()
        Wait(5000) -- Wait for database initialization
        
        if not InitializeTeams() then
            print('^1[District Zero] Failed to initialize teams^7')
            return
        end
        
        print('^2[District Zero] Teams system initialized successfully^7')
    end)
end)

-- Exports
exports('GetPlayerTeam', GetPlayerTeam)
exports('SetPlayerTeam', SetPlayerTeam)
exports('GetTeamStats', GetTeamStats)
exports('GetTeamPlayers', GetTeamPlayers)
exports('GetTeamBalance', GetTeamBalance)
exports('SuggestTeam', SuggestTeam)
exports('CanJoinTeam', CanJoinTeam) 