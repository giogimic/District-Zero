-- server/main/main.lua
-- District Zero Main Server Handler

local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Server State
local State = {
    districts = {},
    factions = {},
    missions = {},
    players = {},
    config = {
        districts = {},
        factions = {},
        missions = {}
    }
}

-- Initialize
local function Initialize()
    -- Load districts
    local districts = Utils.SafeQuery('SELECT * FROM dz_districts', {}, 'Initialize')
    if districts then
        for _, district in ipairs(districts) do
            State.districts[district.id] = district
        end
    end
    
    -- Load factions
    local factions = Utils.SafeQuery('SELECT * FROM dz_factions', {}, 'Initialize')
    if factions then
        for _, faction in ipairs(factions) do
            State.factions[faction.id] = faction
        end
    end
    
    -- Load missions
    local missions = Utils.SafeQuery('SELECT * FROM dz_missions', {}, 'Initialize')
    if missions then
        for _, mission in ipairs(missions) do
            State.missions[mission.id] = mission
        end
    end
end

-- Player Management
local function AddPlayer(source)
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return end
    
    State.players[source] = {
        citizenid = Player.PlayerData.citizenid,
        job = Player.PlayerData.job,
        gang = Player.PlayerData.gang,
        metadata = Player.PlayerData.metadata
    }
end

local function RemovePlayer(source)
    State.players[source] = nil
end

-- District Management
local function UpdateDistrict(districtId, data)
    if not State.districts[districtId] then return false end
    
    local success = Utils.SafeQuery('UPDATE dz_districts SET ? WHERE id = ?', 
        {data, districtId}, 'UpdateDistrict')
    
    if success then
        State.districts[districtId] = data
        Events.TriggerEvent('dz:client:district:update', 'server', -1, State.districts)
        return true
    end
    return false
end

-- Mission Management
local function StartMission(source, missionId)
    if not State.missions[missionId] then return false end
    
    local mission = State.missions[missionId]
    local player = State.players[source]
    
    if not player then return false end
    
    -- Check requirements
    if mission.requirements then
        if mission.requirements.job and player.job.name ~= mission.requirements.job then
            return false
        end
        if mission.requirements.gang and player.gang.name ~= mission.requirements.gang then
            return false
        end
    end
    
    -- Start mission
    Events.TriggerEvent('dz:client:mission:start', 'server', source, mission)
    return true
end

-- Event Handlers
Events.RegisterEvent('dz:server:player:loaded', function(source)
    AddPlayer(source)
end)

Events.RegisterEvent('dz:server:player:unloaded', function(source)
    RemovePlayer(source)
end)

Events.RegisterEvent('dz:server:district:requestUpdate', function(source)
    Events.TriggerEvent('dz:client:district:update', 'server', source, State.districts)
end)

Events.RegisterEvent('dz:server:mission:start', function(source, missionId)
    StartMission(source, missionId)
end)

Events.RegisterEvent('dz:server:player:saveMetadata', function(source, metadata)
    local Player = QBX.Functions.GetPlayer(source)
    if Player then
        Player.Functions.SetMetaData('metadata', metadata)
    end
end)

-- QBX Core Event Handlers
RegisterNetEvent('QBCore:Server:OnPlayerLoaded')
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    local source = source
    AddPlayer(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload')
AddEventHandler('QBCore:Server:OnPlayerUnload', function()
    local source = source
    RemovePlayer(source)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Initialize()
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        districts = {},
        factions = {},
        missions = {},
        players = {},
        config = {
            districts = {},
            factions = {},
            missions = {}
        }
    }
end)

-- Register database cleanup handler
RegisterCleanup('database', function()
    -- Close any open database connections
    if MySQL then
        MySQL.close()
    end
end)

-- Exports
exports('GetDistricts', function()
    return State.districts
end)

exports('GetFactions', function()
    return State.factions
end)

exports('GetMissions', function()
    return State.missions
end)

exports('GetPlayers', function()
    return State.players
end)
