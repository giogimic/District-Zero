-- District Zero Factions Handler
local QBCore = exports['qb-core']:GetCoreObject()
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

-- Initialize factions from database
local function InitializeFactions()
    MySQL.query('SELECT * FROM dz_factions', {}, function(result)
        if result then
            for _, faction in ipairs(result) do
                -- Load faction members
                MySQL.query('SELECT * FROM dz_faction_members WHERE faction_id = ?', {faction.id}, function(members)
                    if members then
                        faction.members = members
                    end
                end)
            end
        end
    end)
end

-- Faction Management
local function UpdateFaction(id, data)
    if not data then return false end
    
    MySQL.update('UPDATE dz_factions SET name = ?, description = ?, color = ? WHERE id = ?',
        {data.name, data.description, data.color, id},
        function(affectedRows)
            if affectedRows > 0 then
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateFactions', -1)
                return true
            end
            return false
        end
    )
end

local function AddFactionMember(factionId, playerId)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end
    
    -- Check if player is already in a faction
    if player.PlayerData.metadata.faction then
        QBCore.Functions.Notify(playerId, 'You are already in a faction', 'error')
        return false
    end
    
    -- Add player to faction
    MySQL.insert('INSERT INTO dz_faction_members (faction_id, player_id, role, join_date) VALUES (?, ?, ?, ?)',
        {factionId, playerId, 'recruit', os.time()},
        function(id)
            if id then
                -- Update player metadata
                player.Functions.SetMetaData('faction', factionId)
                
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateFactions', -1)
                QBCore.Functions.Notify(playerId, 'Joined faction successfully', 'success')
                return true
            end
            return false
        end
    )
end

local function RemoveFactionMember(factionId, playerId)
    local player = QBCore.Functions.GetPlayer(playerId)
    if not player then return false end
    
    -- Check if player is in the faction
    if player.PlayerData.metadata.faction ~= factionId then
        QBCore.Functions.Notify(playerId, 'You are not in this faction', 'error')
        return false
    end
    
    -- Remove player from faction
    MySQL.query('DELETE FROM dz_faction_members WHERE faction_id = ? AND player_id = ?',
        {factionId, playerId},
        function(affectedRows)
            if affectedRows > 0 then
                -- Update player metadata
                player.Functions.SetMetaData('faction', nil)
                
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateFactions', -1)
                QBCore.Functions.Notify(playerId, 'Left faction successfully', 'success')
                return true
            end
            return false
        end
    )
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
    local player = QBCore.Functions.GetPlayer(source)
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
    local player = QBCore.Functions.GetPlayer(source)
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
QBCore.Commands.Add('setfaction', 'Set player faction (Admin Only)', {
    {name = 'playerId', help = 'Player ID'},
    {name = 'factionId', help = 'Faction ID or "none"'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local factionId = args[2]
    
    if factionId == 'none' then
        local player = QBCore.Functions.GetPlayer(targetId)
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

QBCore.Commands.Add('updatefaction', 'Update faction data (Admin Only)', {
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

-- Callbacks
QBCore.Functions.CreateCallback('district-zero:server:getFactions', function(source, cb)
    MySQL.query('SELECT * FROM dz_factions', {}, function(result)
        if result then
            -- Load members for each faction
            for _, faction in ipairs(result) do
                MySQL.query('SELECT * FROM dz_faction_members WHERE faction_id = ?', {faction.id}, function(members)
                    faction.members = members
                end)
            end
            cb(result)
        else
            cb({})
        end
    end)
end)

-- Event Handlers
RegisterNetEvent('district-zero:server:createFaction')
AddEventHandler('district-zero:server:createFaction', function(data)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to create factions', 'error')
        return
    end
    
    MySQL.insert('INSERT INTO dz_factions (name, description, color) VALUES (?, ?, ?)',
        {data.name, data.description, data.color},
        function(id)
            if id then
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateFactions', -1)
                QBCore.Functions.Notify(source, 'Faction created successfully', 'success')
            else
                QBCore.Functions.Notify(source, 'Failed to create faction', 'error')
            end
        end
    )
end)

RegisterNetEvent('district-zero:server:updateFaction')
AddEventHandler('district-zero:server:updateFaction', function(data)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to update factions', 'error')
        return
    end
    
    if UpdateFaction(data.id, data) then
        QBCore.Functions.Notify(source, 'Faction updated successfully', 'success')
    else
        QBCore.Functions.Notify(source, 'Failed to update faction', 'error')
    end
end)

RegisterNetEvent('district-zero:server:deleteFaction')
AddEventHandler('district-zero:server:deleteFaction', function(factionId)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to delete factions', 'error')
        return
    end
    
    MySQL.query('DELETE FROM dz_factions WHERE id = ?', {factionId}, function(affectedRows)
        if affectedRows > 0 then
            -- Notify all clients
            TriggerClientEvent('district-zero:client:updateFactions', -1)
            QBCore.Functions.Notify(source, 'Faction deleted successfully', 'success')
        else
            QBCore.Functions.Notify(source, 'Failed to delete faction', 'error')
        end
    end)
end)

RegisterNetEvent('district-zero:server:joinFaction')
AddEventHandler('district-zero:server:joinFaction', function(factionId)
    local source = source
    AddFactionMember(factionId, source)
end)

RegisterNetEvent('district-zero:server:leaveFaction')
AddEventHandler('district-zero:server:leaveFaction', function(factionId)
    local source = source
    RemoveFactionMember(factionId, source)
end) 