-- District Events Server Handler
local QBX = exports['qbx_core']:GetSharedObject()
local activeEvents = {}

-- Event Configurations
local eventConfigs = {
    raid = {
        duration = 300, -- 5 minutes
        minPlayers = 2,
        maxPlayers = 8,
        rewards = {
            money = {min = 5000, max = 15000},
            reputation = {min = 10, max = 30}
        }
    },
    emergency = {
        duration = 180, -- 3 minutes
        minPlayers = 1,
        maxPlayers = 4,
        rewards = {
            money = {min = 3000, max = 8000},
            reputation = {min = 5, max = 15}
        }
    },
    turf_war = {
        duration = 600, -- 10 minutes
        minPlayers = 4,
        maxPlayers = 16,
        rewards = {
            money = {min = 10000, max = 25000},
            reputation = {min = 20, max = 50}
        }
    },
    gang_attack = {
        duration = 240, -- 4 minutes
        minPlayers = 2,
        maxPlayers = 6,
        rewards = {
            money = {min = 4000, max = 12000},
            reputation = {min = 8, max = 25}
        }
    },
    patrol = {
        duration = 120, -- 2 minutes
        minPlayers = 1,
        maxPlayers = 2,
        rewards = {
            money = {min = 2000, max = 5000},
            reputation = {min = 3, max = 10}
        }
    }
}

-- Helper Functions
local function GetPlayersInDistrict(districtId)
    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local player = QBX.Functions.GetPlayer(tonumber(playerId))
        if player then
            local ped = GetPlayerPed(playerId)
            local coords = GetEntityCoords(ped)
            local district = exports['fivem-mm']:GetDistrict(districtId)
            if district then
                local distance = #(coords - district.center)
                if distance <= district.radius then
                    table.insert(players, playerId)
                end
            end
        end
    end
    return players
end

local function CalculateRewards(eventType, playerCount)
    local config = eventConfigs[eventType]
    if not config then return nil end
    
    local rewards = {}
    for rewardType, range in pairs(config.rewards) do
        local baseAmount = math.random(range.min, range.max)
        local multiplier = 1.0 + (playerCount / config.maxPlayers)
        rewards[rewardType] = math.floor(baseAmount * multiplier)
    end
    return rewards
end

-- Event Handlers
RegisterNetEvent('district:startRaid', function(districtId)
    if activeEvents[districtId] then return end
    
    local players = GetPlayersInDistrict(districtId)
    local config = eventConfigs.raid
    if #players < config.minPlayers or #players > config.maxPlayers then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough players for raid', 'error')
        return
    end
    
    local district = exports['fivem-mm']:GetDistrict(districtId)
    if not district then return end
    
    activeEvents[districtId] = {
        type = 'raid',
        startTime = os.time(),
        players = players
    }
    
    TriggerClientEvent('district:spawnRaidNPCs', -1, district)
    
    -- Set timeout for event completion
    SetTimeout(config.duration * 1000, function()
        if activeEvents[districtId] then
            TriggerEvent('district:failEvent', districtId)
        end
    end)
end)

RegisterNetEvent('district:startEmergency', function(districtId)
    if activeEvents[districtId] then return end
    
    local players = GetPlayersInDistrict(districtId)
    local config = eventConfigs.emergency
    if #players < config.minPlayers or #players > config.maxPlayers then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough players for emergency', 'error')
        return
    end
    
    local district = exports['fivem-mm']:GetDistrict(districtId)
    if not district then return end
    
    activeEvents[districtId] = {
        type = 'emergency',
        startTime = os.time(),
        players = players
    }
    
    TriggerClientEvent('district:spawnEmergencyNPCs', -1, district)
    
    SetTimeout(config.duration * 1000, function()
        if activeEvents[districtId] then
            TriggerEvent('district:failEvent', districtId)
        end
    end)
end)

RegisterNetEvent('district:startTurfWar', function(districtId)
    if activeEvents[districtId] then return end
    
    local players = GetPlayersInDistrict(districtId)
    local config = eventConfigs.turf_war
    if #players < config.minPlayers or #players > config.maxPlayers then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough players for turf war', 'error')
        return
    end
    
    local district = exports['fivem-mm']:GetDistrict(districtId)
    if not district then return end
    
    activeEvents[districtId] = {
        type = 'turf_war',
        startTime = os.time(),
        players = players,
        scores = {}
    }
    
    TriggerClientEvent('district:spawnTurfWarNPCs', -1, district)
    
    SetTimeout(config.duration * 1000, function()
        if activeEvents[districtId] then
            TriggerEvent('district:endTurfWar', districtId)
        end
    end)
end)

RegisterNetEvent('district:startGangAttack', function(districtId)
    if activeEvents[districtId] then return end
    
    local players = GetPlayersInDistrict(districtId)
    local config = eventConfigs.gang_attack
    if #players < config.minPlayers or #players > config.maxPlayers then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough players for gang attack', 'error')
        return
    end
    
    local district = exports['fivem-mm']:GetDistrict(districtId)
    if not district then return end
    
    activeEvents[districtId] = {
        type = 'gang_attack',
        startTime = os.time(),
        players = players
    }
    
    TriggerClientEvent('district:spawnGangAttackNPCs', -1, district)
    
    SetTimeout(config.duration * 1000, function()
        if activeEvents[districtId] then
            TriggerEvent('district:failEvent', districtId)
        end
    end)
end)

RegisterNetEvent('district:startPatrol', function(districtId)
    if activeEvents[districtId] then return end
    
    local players = GetPlayersInDistrict(districtId)
    local config = eventConfigs.patrol
    if #players < config.minPlayers or #players > config.maxPlayers then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough players for patrol', 'error')
        return
    end
    
    local district = exports['fivem-mm']:GetDistrict(districtId)
    if not district then return end
    
    activeEvents[districtId] = {
        type = 'patrol',
        startTime = os.time(),
        players = players
    }
    
    TriggerClientEvent('district:spawnPatrolNPCs', -1, district)
    
    SetTimeout(config.duration * 1000, function()
        if activeEvents[districtId] then
            TriggerEvent('district:failEvent', districtId)
        end
    end)
end)

RegisterNetEvent('district:eventComplete', function(districtId, eventType)
    if not activeEvents[districtId] or activeEvents[districtId].type ~= eventType then return end
    
    local event = activeEvents[districtId]
    local rewards = CalculateRewards(eventType, #event.players)
    
    if rewards then
        for _, playerId in ipairs(event.players) do
            local player = QBX.Functions.GetPlayer(tonumber(playerId))
            if player then
                player.Functions.AddMoney('cash', rewards.money)
                -- Add reputation logic here
                TriggerClientEvent('QBCore:Notify', playerId, 'Event completed! Rewards received.', 'success')
            end
        end
    end
    
    TriggerClientEvent('district:cleanupEvent', -1)
    activeEvents[districtId] = nil
end)

RegisterNetEvent('district:failEvent', function(districtId)
    if not activeEvents[districtId] then return end
    
    local event = activeEvents[districtId]
    for _, playerId in ipairs(event.players) do
        TriggerClientEvent('QBCore:Notify', playerId, 'Event failed!', 'error')
    end
    
    TriggerClientEvent('district:cleanupEvent', -1)
    activeEvents[districtId] = nil
end)

RegisterNetEvent('district:endTurfWar', function(districtId)
    if not activeEvents[districtId] or activeEvents[districtId].type ~= 'turf_war' then return end
    
    local event = activeEvents[districtId]
    local winningFaction = nil
    local highestScore = 0
    
    for faction, score in pairs(event.scores) do
        if score > highestScore then
            highestScore = score
            winningFaction = faction
        end
    end
    
    if winningFaction then
        exports['fivem-mm']:SetDistrictControl(districtId, winningFaction)
        local rewards = CalculateRewards('turf_war', #event.players)
        
        if rewards then
            for _, playerId in ipairs(event.players) do
                local player = QBX.Functions.GetPlayer(tonumber(playerId))
                if player and player.PlayerData.faction == winningFaction then
                    player.Functions.AddMoney('cash', rewards.money)
                    -- Add reputation logic here
                    TriggerClientEvent('QBCore:Notify', playerId, 'Turf war won! Rewards received.', 'success')
                end
            end
        end
    end
    
    TriggerClientEvent('district:cleanupEvent', -1)
    activeEvents[districtId] = nil
end)

RegisterNetEvent('district:updateTurfWarScore', function(districtId, faction, points)
    if not activeEvents[districtId] or activeEvents[districtId].type ~= 'turf_war' then return end
    
    local event = activeEvents[districtId]
    event.scores[faction] = (event.scores[faction] or 0) + points
end)

-- Exports
exports('GetActiveEvents', function()
    return activeEvents
end)

exports('IsEventActive', function(districtId)
    return activeEvents[districtId] ~= nil
end) 