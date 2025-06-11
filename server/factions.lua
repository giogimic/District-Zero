-- Factions Server Handler
local QBX = exports.qbx_core:GetCoreObject()
local factions = {}

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
    SafeCall(function()
        if not Config or not Config.Factions then
            print('[District Zero] Error: Config.Factions is not defined')
            return
        end

        for id, faction in pairs(Config.Factions) do
            factions[id] = {
                id = id,
                name = faction.name,
                type = faction.type,
                members = {},
                districts = {},
                reputation = 0,
                level = 1,
                lastUpdate = os.time()
            }
        end
    end)
end

-- Faction Management
local function CreateFaction(source, name, type)
    return SafeCall(function()
        local player = QBX.Functions.GetPlayer(source)
        if not player then 
            print('[District Zero] Error: Invalid player source for faction creation')
            return false 
        end

        if not Config.Factions[type] then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.invalid_faction'), 'error')
            return false
        end

        local factionId = #factions + 1
        factions[factionId] = {
            id = factionId,
            name = name,
            type = type,
            members = {player.PlayerData.citizenid},
            districts = {},
            reputation = 0,
            level = 1,
            lastUpdate = os.time()
        }

        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.faction_created'), 'success')
        return true
    end)
end

local function JoinFaction(source, factionId)
    return SafeCall(function()
        local player = QBX.Functions.GetPlayer(source)
        if not player then 
            print('[District Zero] Error: Invalid player source for faction join')
            return false 
        end

        if not factions[factionId] then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.invalid_faction'), 'error')
            return false
        end

        if #factions[factionId].members >= Config.Settings.MaxFactionMembers then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.faction_full'), 'error')
            return false
        end

        table.insert(factions[factionId].members, player.PlayerData.citizenid)
        TriggerClientEvent('QBCore:Notify', source, Lang:t('success.faction_joined'), 'success')
        return true
    end)
end

local function LeaveFaction(source, factionId)
    return SafeCall(function()
        local player = QBX.Functions.GetPlayer(source)
        if not player then 
            print('[District Zero] Error: Invalid player source for faction leave')
            return false 
        end

        if not factions[factionId] then
            TriggerClientEvent('QBCore:Notify', source, Lang:t('error.invalid_faction'), 'error')
            return false
        end

        for i, memberId in ipairs(factions[factionId].members) do
            if memberId == player.PlayerData.citizenid then
                table.remove(factions[factionId].members, i)
                TriggerClientEvent('QBCore:Notify', source, Lang:t('success.faction_left'), 'success')
                return true
            end
        end

        return false
    end)
end

-- Faction Events
RegisterNetEvent('faction:create', function(name, type)
    local source = source
    CreateFaction(source, name, type)
end)

RegisterNetEvent('faction:join', function(factionId)
    local source = source
    JoinFaction(source, factionId)
end)

RegisterNetEvent('faction:leave', function(factionId)
    local source = source
    LeaveFaction(source, factionId)
end)

-- Exports
exports('GetFactions', function()
    return factions
end)

exports('GetFaction', function(factionId)
    return factions[factionId]
end)

exports('GetPlayerFaction', function(citizenid)
    return SafeCall(function()
        for _, faction in pairs(factions) do
            for _, memberId in ipairs(faction.members) do
                if memberId == citizenid then
                    return faction
                end
            end
        end
        return nil
    end)
end)

-- Initialize factions on resource start
CreateThread(function()
    InitializeFactions()
end) 