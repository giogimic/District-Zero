-- District Zero Teams Server Module
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'

-- State
local playerTeams = {}

-- Initialize teams
local function InitializeTeams()
    Utils.PrintDebug('Initializing teams...')
    -- Team initialization logic here
end

-- Get player team
local function GetPlayerTeam(playerId)
    return playerTeams[playerId]
end

-- Set player team
local function SetPlayerTeam(playerId, team)
    if team ~= 'pvp' and team ~= 'pve' then return false end
    
    playerTeams[playerId] = team
    
    -- Notify client
    TriggerClientEvent('dz:client:teamUpdated', playerId, team)
    return true
end

-- Event handlers
RegisterNetEvent('dz:server:getTeam')
AddEventHandler('dz:server:getTeam', function(cb)
    local playerId = source
    cb(GetPlayerTeam(playerId))
end)

RegisterNetEvent('dz:server:selectTeam')
AddEventHandler('dz:server:selectTeam', function(team)
    local playerId = source
    if SetPlayerTeam(playerId, team) then
        Utils.PrintDebug(string.format('Player %s joined team %s', playerId, team))
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeTeams()
end)

-- Export functions
exports('GetPlayerTeam', GetPlayerTeam)
exports('SetPlayerTeam', SetPlayerTeam) 