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

-- Mission Management
RegisterNetEvent('dz:server:acceptMission')
AddEventHandler('dz:server:acceptMission', function(missionId)
    local source = source
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return end
    
    local mission = State.missions[missionId]
    if not mission then return end
    
    -- Check requirements
    if not CheckMissionRequirements(Player, mission) then
        TriggerClientEvent('QBCore:Notify', source, 'You do not meet the requirements for this mission', 'error')
        return
    end
    
    -- Add mission to player
    State.players[source].missions[missionId] = {
        startTime = os.time(),
        objectives = mission.objectives,
        completed = false
    }
    
    -- Notify player
    TriggerClientEvent('dz:client:missionStarted', source, mission)
end)

function CheckMissionRequirements(Player, mission)
    if not mission.requirements then return true end
    
    -- Check level
    if mission.requirements.level and Player.PlayerData.level < mission.requirements.level then
        return false
    end
    
    -- Check items
    if mission.requirements.items then
        for _, item in ipairs(mission.requirements.items) do
            if not Player.Functions.GetItemByName(item.name) then
                return false
            end
        end
    end
    
    return true
end

-- UI Data Callback
QBX.Functions.CreateCallback('dz:server:getUIData', function(source, cb)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    
    -- Get available missions for player
    local availableMissions = {}
    for id, mission in pairs(State.missions) do
        if CheckMissionRequirements(Player, mission) then
            availableMissions[id] = mission
        end
    end
    
    cb({
        missions = availableMissions,
        districts = State.districts,
        factions = State.factions
    })
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for QBCore to be ready
    while not QBX do
        Wait(100)
    end
end)

-- Wait for database to be ready
RegisterNetEvent('dz:database:ready')
AddEventHandler('dz:database:ready', function()
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
