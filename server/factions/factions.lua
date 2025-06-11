-- server/factions/factions.lua
-- District Zero Faction Management

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Faction State
local State = {
    factions = {},
    members = {},
    territories = {}
}

-- Initialize factions
local function InitializeFactions()
    local factions = Utils.SafeQuery('SELECT * FROM dz_factions', {}, 'InitializeFactions')
    if factions then
        for _, faction in ipairs(factions) do
            State.factions[faction.id] = faction
        end
    end
end

-- Handle faction join
local function HandleFactionJoin(source, factionId)
    if not State.factions[factionId] then return false end
    
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Check if player is already in a faction
    if State.members[source] then
        return false
    end
    
    -- Add player to faction
    State.members[source] = {
        factionId = factionId,
        joinTime = os.time(),
        rank = 1
    }
    
    -- Update player metadata
    Player.Functions.SetMetaData('faction', factionId)
    
    -- Trigger faction join event
    Events.TriggerEvent('dz:client:faction:joined', 'server', source, {
        factionId = factionId,
        rank = 1
    })
    
    return true
end

-- Handle faction leave
local function HandleFactionLeave(source)
    if not State.members[source] then return false end
    
    local Player = QBX.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Remove player from faction
    local factionId = State.members[source].factionId
    State.members[source] = nil
    
    -- Update player metadata
    Player.Functions.SetMetaData('faction', nil)
    
    -- Trigger faction leave event
    Events.TriggerEvent('dz:client:faction:left', 'server', source, {
        factionId = factionId
    })
    
    return true
end

-- Handle faction rank update
local function HandleFactionRankUpdate(source, targetSource, newRank)
    if not State.members[source] or not State.members[targetSource] then return false end
    
    local sourceFaction = State.members[source].factionId
    local targetFaction = State.members[targetSource].factionId
    
    -- Check if same faction
    if sourceFaction ~= targetFaction then return false end
    
    -- Check if source has permission
    local sourceRank = State.members[source].rank
    if sourceRank <= newRank then return false end
    
    -- Update rank
    State.members[targetSource].rank = newRank
    
    -- Trigger rank update event
    Events.TriggerEvent('dz:client:faction:rankUpdated', 'server', targetSource, {
        factionId = targetFaction,
        newRank = newRank
    })
    
    return true
end

-- Handle territory update
local function HandleTerritoryUpdate(factionId, districtId, status)
    if not State.factions[factionId] then return false end
    
    -- Update territory
    State.territories[districtId] = {
        factionId = factionId,
        status = status,
        updateTime = os.time()
    }
    
    -- Trigger territory update event
    Events.TriggerEvent('dz:client:faction:territoryUpdated', 'server', -1, {
        factionId = factionId,
        districtId = districtId,
        status = status
    })
    
    return true
end

-- Event Handlers
Events.RegisterEvent('dz:server:faction:join', function(source, factionId)
    HandleFactionJoin(source, factionId)
end)

Events.RegisterEvent('dz:server:faction:leave', function(source)
    HandleFactionLeave(source)
end)

Events.RegisterEvent('dz:server:faction:updateRank', function(source, targetSource, newRank)
    HandleFactionRankUpdate(source, targetSource, newRank)
end)

Events.RegisterEvent('dz:server:faction:updateTerritory', function(source, factionId, districtId, status)
    HandleTerritoryUpdate(factionId, districtId, status)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeFactions()
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        factions = {},
        members = {},
        territories = {}
    }
end)

-- Exports
exports('GetFactions', function()
    return State.factions
end)

exports('GetFactionMembers', function()
    return State.members
end)

exports('GetFactionTerritories', function()
    return State.territories
end) 