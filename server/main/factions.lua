-- Factions Server Handler
local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'
local factions = {}
local factionMembers = {}
local factionResources = {}
local factionInfluence = {}

-- Error handling wrapper
local function SafeCall(fn, ...)
    local status, result = pcall(fn, ...)
    if not status then
        print('[District Zero] Error:', result)
        return nil
    end
    return result
end

-- Initialize factions from config
local function InitializeFactions()
    -- Load factions from config or database
    factions = Config.Factions or {}
    
    -- Initialize faction data
    for id, faction in pairs(factions) do
        factionMembers[id] = {}
        factionResources[id] = faction.resources or {
            money = 0,
            materials = 0,
            influence = 0
        }
        factionInfluence[id] = faction.influence or 0
    end
end

-- Faction Management
local function UpdateFaction(id, data)
    if not factions[id] then return false end
    
    -- Update faction data
    for key, value in pairs(data) do
        factions[id][key] = value
    end
    
    -- Notify all clients
    TriggerClientEvent('faction:update', -1, id, factions[id])
    
    return true
end

local function AddFactionMember(factionId, playerId)
    if not factions[factionId] then return false end
    
    local player = QBX.Functions.GetPlayer(playerId)
    if not player then return false end
    
    -- Add player to faction
    factionMembers[factionId][playerId] = {
        id = playerId,
        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        rank = 'recruit',
        joinDate = os.time()
    }
    
    -- Update player metadata
    player.Functions.SetMetaData('faction', factionId)
    
    -- Notify all clients
    TriggerClientEvent('faction:memberUpdate', -1, factionId, factionMembers[factionId])
    
    return true
end

local function RemoveFactionMember(factionId, playerId)
    if not factions[factionId] then return false end
    if not factionMembers[factionId][playerId] then return false end
    
    local player = QBX.Functions.GetPlayer(playerId)
    if player then
        -- Remove faction from player metadata
        player.Functions.SetMetaData('faction', nil)
    end
    
    -- Remove player from faction
    factionMembers[factionId][playerId] = nil
    
    -- Notify all clients
    TriggerClientEvent('faction:memberUpdate', -1, factionId, factionMembers[factionId])
    
    return true
end

local function UpdateFactionResources(factionId, resourceType, amount)
    if not factions[factionId] then return false end
    if not factionResources[factionId] then return false end
    
    factionResources[factionId][resourceType] = (factionResources[factionId][resourceType] or 0) + amount
    factions[factionId].resources = factionResources[factionId]
    
    -- Notify all clients
    TriggerClientEvent('faction:resourceUpdate', -1, factionId, resourceType, factionResources[factionId][resourceType])
    
    return true
end

local function UpdateFactionInfluence(factionId, amount)
    if not factions[factionId] then return false end
    
    factionInfluence[factionId] = (factionInfluence[factionId] or 0) + amount
    factions[factionId].influence = factionInfluence[factionId]
    
    -- Notify all clients
    TriggerClientEvent('faction:influenceUpdate', -1, factionId, factionInfluence[factionId])
    
    return true
end

-- Event Handlers
RegisterNetEvent('faction:requestUpdate')
AddEventHandler('faction:requestUpdate', function()
    local source = source
    TriggerClientEvent('faction:update', source, factions)
end)

RegisterNetEvent('faction:joinRequest')
AddEventHandler('faction:joinRequest', function(factionId)
    local source = source
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end
    
    -- Check if player is already in a faction
    if player.PlayerData.metadata.faction then
        TriggerClientEvent('QBCore:Notify', source, 'You are already in a faction', 'error')
        return
    end
    
    -- Add player to faction
    if AddFactionMember(factionId, source) then
        TriggerClientEvent('QBCore:Notify', source, 'Joined faction successfully', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to join faction', 'error')
    end
end)

RegisterNetEvent('faction:leaveRequest')
AddEventHandler('faction:leaveRequest', function()
    local source = source
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end
    
    local factionId = player.PlayerData.metadata.faction
    if not factionId then
        TriggerClientEvent('QBCore:Notify', source, 'You are not in a faction', 'error')
        return
    end
    
    -- Remove player from faction
    if RemoveFactionMember(factionId, source) then
        TriggerClientEvent('QBCore:Notify', source, 'Left faction successfully', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to leave faction', 'error')
    end
end)

-- Commands
QBX.Commands.Add('setfaction', 'Set player faction (Admin Only)', {
    {name = 'playerId', help = 'Player ID'},
    {name = 'factionId', help = 'Faction ID or "none"'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local factionId = args[2]
    
    if factionId == 'none' then
        local player = QBX.Functions.GetPlayer(targetId)
        if player and player.PlayerData.metadata.faction then
            RemoveFactionMember(player.PlayerData.metadata.faction, targetId)
            TriggerClientEvent('QBCore:Notify', source, 'Removed player from faction', 'success')
        end
    else
        if AddFactionMember(factionId, targetId) then
            TriggerClientEvent('QBCore:Notify', source, 'Added player to faction', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Failed to add player to faction', 'error')
        end
    end
end, 'admin')

QBX.Commands.Add('updatefaction', 'Update faction data (Admin Only)', {
    {name = 'factionId', help = 'Faction ID'},
    {name = 'key', help = 'Data key'},
    {name = 'value', help = 'New value'}
}, true, function(source, args)
    local factionId = args[1]
    local key = args[2]
    local value = args[3]
    
    if UpdateFaction(factionId, {[key] = value}) then
        TriggerClientEvent('QBCore:Notify', source, 'Faction updated', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to update faction', 'error')
    end
end, 'admin')

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeFactions()
    end
end)

-- Exports
exports('GetFactions', function()
    return factions
end)

exports('GetFactionMembers', function(factionId)
    return factionMembers[factionId]
end)

exports('GetFactionResources', function(factionId)
    return factionResources[factionId]
end)

exports('GetFactionInfluence', function(factionId)
    return factionInfluence[factionId]
end)

exports('UpdateFaction', function(factionId, data)
    return UpdateFaction(factionId, data)
end)

exports('AddFactionMember', function(factionId, playerId)
    return AddFactionMember(factionId, playerId)
end)

exports('RemoveFactionMember', function(factionId, playerId)
    return RemoveFactionMember(factionId, playerId)
end)

exports('UpdateFactionResources', function(factionId, resourceType, amount)
    return UpdateFactionResources(factionId, resourceType, amount)
end)

exports('UpdateFactionInfluence', function(factionId, amount)
    return UpdateFactionInfluence(factionId, amount)
end) 