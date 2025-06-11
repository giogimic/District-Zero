-- server/abilities.lua
-- Server-side ability management and synchronization

local abilities = {
    backup = {
        name = "Backup Request",
        description = "Request backup from nearby faction members",
        cooldown = 300, -- 5 minutes
        requiredRank = 1,
        enabled = true
    },
    tracking = {
        name = "Police Tracking",
        description = "Disable police tracking for 2 minutes",
        cooldown = 600, -- 10 minutes
        requiredRank = 2,
        enabled = true
    },
    jammer = {
        name = "Signal Jammer",
        description = "Jam police radio signals in a 100m radius for 1 minute",
        cooldown = 900, -- 15 minutes
        requiredRank = 3,
        enabled = true
    }
}

local activeEffects = {}

-- Handle ability triggers
RegisterNetEvent('faction:triggerAbility')
AddEventHandler('faction:triggerAbility', function(abilityId)
    local source = source
    local player = source
    local faction = GetPlayerFaction(player)
    local rank = GetPlayerFactionRank(player)

    if not faction or not rank then return end
    if not abilities[abilityId] then return end

    local ability = abilities[abilityId]
    if rank < ability.requiredRank then return end

    -- Apply ability effects
    ApplyAbilityEffect(player, abilityId, faction)
end)

-- Apply ability effects
function ApplyAbilityEffect(player, abilityId, faction)
    local ability = abilities[abilityId]
    local playerCoords = GetEntityCoords(GetPlayerPed(player))

    if abilityId == 'backup' then
        -- Notify nearby faction members
        local players = GetPlayers()
        for _, targetPlayer in ipairs(players) do
            if IsPlayerInFaction(targetPlayer, faction) and targetPlayer ~= player then
                local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayer))
                local distance = #(playerCoords - targetCoords)
                
                if distance <= 1000.0 then -- 1km radius
                    TriggerClientEvent('faction:backupRequest', targetPlayer, player, playerCoords)
                end
            end
        end
    elseif abilityId == 'tracking' then
        -- Disable police tracking
        activeEffects[player] = activeEffects[player] or {}
        activeEffects[player].tracking = {
            endTime = os.time() + 120, -- 2 minutes
            faction = faction
        }
        
        -- Notify player
        TriggerClientEvent('faction:trackingDisabled', player)
        
        -- Remove effect after duration
        Citizen.SetTimeout(120000, function()
            if activeEffects[player] and activeEffects[player].tracking then
                activeEffects[player].tracking = nil
                TriggerClientEvent('faction:trackingEnabled', player)
            end
        end)
    elseif abilityId == 'jammer' then
        -- Create jammer effect
        activeEffects[player] = activeEffects[player] or {}
        activeEffects[player].jammer = {
            endTime = os.time() + 60, -- 1 minute
            coords = playerCoords,
            faction = faction
        }
        
        -- Notify nearby players
        local players = GetPlayers()
        for _, targetPlayer in ipairs(players) do
            if IsPlayerInFaction(targetPlayer, 'police') then
                local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayer))
                local distance = #(playerCoords - targetCoords)
                
                if distance <= 100.0 then -- 100m radius
                    TriggerClientEvent('faction:signalJammed', targetPlayer)
                end
            end
        end
        
        -- Remove effect after duration
        Citizen.SetTimeout(60000, function()
            if activeEffects[player] and activeEffects[player].jammer then
                activeEffects[player].jammer = nil
                
                -- Notify nearby players
                local players = GetPlayers()
                for _, targetPlayer in ipairs(players) do
                    if IsPlayerInFaction(targetPlayer, 'police') then
                        local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayer))
                        local distance = #(playerCoords - targetCoords)
                        
                        if distance <= 100.0 then
                            TriggerClientEvent('faction:signalRestored', targetPlayer)
                        end
                    end
                end
            end
        end)
    end
end

-- Check if player is affected by any ability effects
function IsPlayerAffectedByEffect(player, effectType)
    if not activeEffects[player] then return false end
    
    if effectType == 'tracking' then
        return activeEffects[player].tracking ~= nil
    elseif effectType == 'jammer' then
        return activeEffects[player].jammer ~= nil
    end
    
    return false
end

-- Get player's faction
function GetPlayerFaction(player)
    -- Implement based on your faction system
    return "faction_name"
end

-- Get player's faction rank
function GetPlayerFactionRank(player)
    -- Implement based on your faction system
    return 1
end

-- Check if player is in faction
function IsPlayerInFaction(player, faction)
    return GetPlayerFaction(player) == faction
end

-- Get all players
function GetPlayers()
    local players = {}
    for i = 0, GetNumPlayerIndices() - 1 do
        table.insert(players, GetPlayerFromIndex(i))
    end
    return players
end

-- Export functions
exports('IsPlayerAffectedByEffect', IsPlayerAffectedByEffect)
exports('GetPlayerFaction', GetPlayerFaction)
exports('GetPlayerFactionRank', GetPlayerFactionRank)

-- Handle backup requests
RegisterNetEvent('apb:server:notifyBackup', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verify player is an enforcer
    local playerFaction = exports['fivem-mm']:GetPlayerFaction(src)
    if playerFaction ~= 'enforcer' then return end

    -- Notify nearby enforcers
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer then
            local targetFaction = exports['fivem-mm']:GetPlayerFaction(playerId)
            if targetFaction == 'enforcer' and playerId ~= src then
                Utils.TriggerClientEvent("notification", playerId, "info", "Backup requested by " .. GetPlayerName(src))
                Utils.TriggerClientEvent("showBackupBlip", playerId, coords)
            end
        end
    end
end)

-- Handle police tracking disable
RegisterNetEvent('apb:server:disablePoliceTracking', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verify player is a criminal
    local playerFaction = exports['fivem-mm']:GetPlayerFaction(src)
    if playerFaction ~= 'criminal' then return end

    -- Disable tracking for 5 minutes
    activeEffects[src] = {
        type = "tracking_disabled",
        endTime = os.time() + 300
    }

    -- Notify player
    Utils.TriggerClientEvent("notification", src, "success", "Police tracking disabled for 5 minutes")
end)

-- Handle signal jamming
RegisterNetEvent('apb:server:jammerActivated', function(coords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verify player is a criminal
    local playerFaction = exports['fivem-mm']:GetPlayerFaction(src)
    if playerFaction ~= 'criminal' then return end

    -- Create jammer effect
    activeEffects[src] = {
        type = "jammer",
        coords = coords,
        endTime = os.time() + 60
    }

    -- Notify nearby enforcers
    local players = QBCore.Functions.GetPlayers()
    for _, playerId in ipairs(players) do
        local targetPlayer = QBCore.Functions.GetPlayer(playerId)
        if targetPlayer then
            local targetFaction = exports['fivem-mm']:GetPlayerFaction(playerId)
            if targetFaction == 'enforcer' then
                Utils.TriggerClientEvent("notification", playerId, "warning", "Communications jammed in your area")
                Utils.TriggerClientEvent("showJammerBlip", playerId, coords)
            end
        end
    end
end)

-- Clean up expired effects
CreateThread(function()
    while true do
        Wait(1000)
        local currentTime = os.time()
        
        for playerId, effect in pairs(activeEffects) do
            if effect.endTime <= currentTime then
                if effect.type == "tracking_disabled" then
                    Utils.TriggerClientEvent("notification", playerId, "info", "Police tracking restored")
                elseif effect.type == "jammer" then
                    Utils.TriggerClientEvent("notification", playerId, "info", "Signal jammer deactivated")
                end
                activeEffects[playerId] = nil
            end
        end
    end
end)

-- Export functions
exports('GetActiveEffects', function(playerId)
    return activeEffects[playerId]
end)

exports('IsTrackingDisabled', function(playerId)
    local effect = activeEffects[playerId]
    return effect and effect.type == "tracking_disabled"
end)

exports('IsInJammedArea', function(playerId, coords)
    for _, effect in pairs(activeEffects) do
        if effect.type == "jammer" then
            local distance = #(coords - effect.coords)
            if distance <= 50.0 then
                return true
            end
        end
    end
    return false
end) 