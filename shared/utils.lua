-- shared/utils.lua
-- Common utility functions for the District Zero system

local QBX = exports['qbx_core']:GetSharedObject()
local Utils = {}

-- Debug logging
function Utils.PrintDebug(message)
    if Config and Config.Debug then
        print('[APB Debug] ' .. tostring(message))
    end
end

-- Notification system
function Utils.SendNotification(source, type, message)
    if source then
        TriggerClientEvent('ox_lib:notify', source, {
            type = type,
            description = message
        })
    end
end

-- Database helpers
function Utils.SafeQuery(query, params)
    local success, result = pcall(function()
        return MySQL.query.await(query, params)
    end)
    
    if not success then
        Utils.PrintDebug('Database query failed: ' .. tostring(result))
        return nil
    end
    
    return result
end

-- Event helpers
function Utils.TriggerClientEvent(eventName, source, ...)
    if source then
        TriggerClientEvent('dz:' .. eventName, source, ...)
    end
end

function Utils.TriggerServerEvent(eventName, ...)
    TriggerServerEvent('dz:' .. eventName, ...)
end

-- State management
function Utils.SetPlayerState(source, key, value)
    if source then
        LocalPlayer.state:set(key, value, true)
    end
end

function Utils.GetPlayerState(source, key)
    if source then
        return LocalPlayer.state[key]
    end
    return nil
end

-- Validation helpers
function Utils.IsValidSpeed(speed)
    return speed >= 0 and speed <= (Config and Config.MaxSpeed or 500)
end

function Utils.IsValidHealth(health)
    return health >= 0 and health <= (Config and Config.MaxHealth or 200)
end

function Utils.IsValidArmor(armor)
    return armor >= 0 and armor <= (Config and Config.MaxArmor or 100)
end

-- Initialize
Utils.PrintDebug('Utils module initialized')

-- Export the utils
return Utils
