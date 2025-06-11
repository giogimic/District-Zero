-- shared/utils.lua
-- Utility functions for APB systems

Utils = {}

-- Debug printing
function Utils.PrintDebug(message)
    if Config.Debug then
        print("[APB Debug] " .. message)
    end
end

-- Faction utilities
function Utils.GetFactionRank(faction, xp)
    local factionConfig = Config.Factions[faction]
    if not factionConfig then return nil end
    
    local currentRank = factionConfig.ranks[1]
    for _, rank in ipairs(factionConfig.ranks) do
        if xp >= rank.xpRequired then
            currentRank = rank
        else
            break
        end
    end
    return currentRank
end

function Utils.GetNextRank(faction, currentXp)
    local factionConfig = Config.Factions[faction]
    if not factionConfig then return nil end
    
    for i, rank in ipairs(factionConfig.ranks) do
        if currentXp < rank.xpRequired then
            return rank
        end
    end
    return nil
end

-- Mission utilities
function Utils.GetRandomMissionLocation(missionType)
    local locations = Config.Missions.locations[missionType]
    if not locations then return nil end
    
    return locations[math.random(1, #locations)]
end

function Utils.CalculateMissionReward(baseReward, playerLevel, multiplier)
    return math.floor(baseReward * (1 + (playerLevel * 0.1)) * multiplier)
end

-- UI utilities
function Utils.FormatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

function Utils.FormatMoney(amount)
    return "$" .. string.format("%,d", amount)
end

-- Security utilities
function Utils.IsValidPosition(position)
    return position and position.x and position.y and position.z
end

function Utils.IsValidSpeed(speed)
    return speed <= Config.Security.maxSpeed
end

function Utils.IsValidHealth(health)
    return health <= Config.Security.maxHealth
end

function Utils.IsValidArmor(armor)
    return armor <= Config.Security.maxArmor
end

-- Notification utilities
function Utils.SendNotification(type, message)
    if not Config.Notifications.types[type] then
        type = "info"
    end
    
    local notification = Config.Notifications.types[type]
    -- Implementation will be handled by the client
    TriggerEvent("apb:client:notification", {
        type = type,
        message = message,
        color = notification.color,
        icon = notification.icon
    })
end

-- Mission objective utilities
function Utils.ValidateObjective(missionType, objectiveType)
    local missionConfig = Config.Missions.types[missionType]
    if not missionConfig then return false end
    
    for _, mission in ipairs(missionConfig) do
        for _, objective in ipairs(mission.objectives) do
            if objective.type == objectiveType then
                return true
            end
        end
    end
    return false
end

-- Player utilities
function Utils.GetPlayerFaction(playerId)
    -- Implementation will be handled by the server
    return nil
end

function Utils.GetPlayerRank(playerId)
    -- Implementation will be handled by the server
    return nil
end

-- Export utilities
function Utils.ExportPlayerData(playerId)
    -- Implementation will be handled by the server
    return nil
end

-- Event utilities
function Utils.TriggerClientEvent(eventName, playerId, ...)
    TriggerClientEvent("apb:client:" .. eventName, playerId, ...)
end

function Utils.TriggerServerEvent(eventName, ...)
    TriggerServerEvent("apb:server:" .. eventName, ...)
end
