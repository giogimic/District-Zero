-- server/main/main.lua
-- District Zero Main Server Handler

local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Server State
local State = {
    isInitialized = false,
    districts = {},
    missions = {},
    factions = {},
    players = {}
}

-- Initialize server
local function Initialize()
    if State.isInitialized then return end
    
    -- Wait for database to be ready
    while not exports['dz'].InitializeDatabase do
        Wait(100)
    end
    
    -- Initialize database
    local success = exports['dz']:InitializeDatabase()
    if not success then
        print('^1[District Zero] Failed to initialize database^7')
        return
    end
    
    -- Insert default data
    success = exports['dz']:InsertDefaultData()
    if not success then
        print('^1[District Zero] Failed to insert default data^7')
        return
    end
    
    -- Initialize districts
    if not InitializeDistricts() then
        print('^1[District Zero] Failed to initialize districts^7')
        return
    end
    
    -- Initialize missions
    if not InitializeMissions() then
        print('^1[District Zero] Failed to initialize missions^7')
        return
    end
    
    -- Initialize factions
    if not InitializeFactions() then
        print('^1[District Zero] Failed to initialize factions^7')
        return
    end
    
    State.isInitialized = true
    print('^2[District Zero] Server initialized successfully^7')
end

-- Event Handlers
RegisterNetEvent('dz:server:initialize')
AddEventHandler('dz:server:initialize', function()
    Initialize()
end)

RegisterNetEvent('dz:server:player:join')
AddEventHandler('dz:server:player:join', function()
    local source = source
    AddPlayer(source)
end)

RegisterNetEvent('dz:server:player:leave')
AddEventHandler('dz:server:player:leave', function()
    local source = source
    RemovePlayer(source)
end)

-- Player Management
function AddPlayer(source)
    if not source then return end
    
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return end
    
    State.players[source] = {
        citizenid = Player.PlayerData.citizenid,
        faction = Player.PlayerData.faction,
        district = nil,
        missions = {},
        abilities = {}
    }
    
    -- Send initial data to player
    TriggerClientEvent('dz:client:initialize', source, {
        districts = State.districts,
        missions = State.missions,
        factions = State.factions
    })
end

function RemovePlayer(source)
    if not source then return end
    State.players[source] = nil
end

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for QBCore to be ready
    while not QBX do
        Wait(100)
    end
    
    -- Initialize server
    Initialize()
end)

-- Register cleanup handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Cleanup state
    State = {
        isInitialized = false,
        districts = {},
        missions = {},
        factions = {},
        players = {}
    }
end)

-- Exports
exports('GetState', function()
    return State
end)

exports('GetPlayer', function(source)
    return State.players[source]
end)

exports('GetDistrict', function(districtId)
    return State.districts[districtId]
end)

exports('GetMission', function(missionId)
    return State.missions[missionId]
end)

exports('GetFaction', function(factionId)
    return State.factions[factionId]
end)
