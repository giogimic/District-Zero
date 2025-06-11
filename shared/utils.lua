-- shared/utils.lua
-- Common utility functions for the District Zero system

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = {}

-- Error handling
function Utils.HandleError(err, context)
    if Config and Config.Debug then
        print(string.format('[APB Error] %s: %s', context, tostring(err)))
    end
    -- You could add error reporting to a service here
end

function Utils.SafeCall(fn, context, ...)
    local args = {...}
    local success, result = pcall(function()
        return fn(unpack(args))
    end)
    if not success then
        Utils.HandleError(result, context)
        return nil
    end
    return result
end

-- Debug logging
function Utils.PrintDebug(message, level)
    if not Config then return end
    if not Config.Debug then return end
    
    level = level or 'info'
    local prefix = string.format('[APB Debug][%s]', level:upper())
    print(string.format('%s %s', prefix, tostring(message)))
end

-- Notification system
function Utils.SendNotification(source, type, message)
    if not source then return end
    if not type then type = 'info' end
    if not message then return end
    
    Utils.SafeCall(function()
        TriggerClientEvent('ox_lib:notify', source, {
            type = type,
            description = message
        })
    end, 'SendNotification')
end

-- Database helpers with proper error handling
function Utils.SafeQuery(query, params, context)
    if not query then return nil end
    
    local success, result = pcall(function()
        return MySQL.query.await(query, params)
    end)
    
    if not success then
        print('^1Query failed in ' .. (context or 'unknown') .. ': ' .. tostring(result))
        return nil
    end
    
    return result
end

-- Event helpers with rate limiting
local eventCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second cooldown

function Utils.TriggerClientEvent(eventName, source, ...)
    if not eventName then
        Utils.HandleError('Event name is required', 'TriggerClientEvent')
        return
    end
    
    if not source then
        Utils.HandleError('Source is required', 'TriggerClientEvent')
        return
    end
    
    -- Rate limiting
    local eventKey = eventName .. source
    if eventCooldowns[eventKey] and GetGameTimer() - eventCooldowns[eventKey] < COOLDOWN_TIME then
        return
    end
    eventCooldowns[eventKey] = GetGameTimer()
    
    local args = {...}
    Utils.SafeCall(function()
        TriggerClientEvent('dz:' .. eventName, source, unpack(args))
    end, 'TriggerClientEvent')
end

function Utils.TriggerServerEvent(eventName, ...)
    if not eventName then
        Utils.HandleError('Event name is required', 'TriggerServerEvent')
        return
    end
    
    -- Rate limiting
    if eventCooldowns[eventName] and GetGameTimer() - eventCooldowns[eventName] < COOLDOWN_TIME then
        return
    end
    eventCooldowns[eventName] = GetGameTimer()
    
    local args = {...}
    Utils.SafeCall(function()
        TriggerServerEvent('dz:' .. eventName, unpack(args))
    end, 'TriggerServerEvent')
end

-- State management with proper replication
function Utils.SetPlayerState(source, key, value)
    if not source then
        Utils.HandleError('Source is required', 'SetPlayerState')
        return
    end
    
    if not key then
        Utils.HandleError('Key is required', 'SetPlayerState')
        return
    end
    
    Utils.SafeCall(function()
        local player = Player(source)
        if player then
            player.state:set(key, value, true) -- true for replication
        end
    end, 'SetPlayerState')
end

function Utils.GetPlayerState(source, key)
    if not source then
        Utils.HandleError('Source is required', 'GetPlayerState')
        return nil
    end
    
    if not key then
        Utils.HandleError('Key is required', 'GetPlayerState')
        return nil
    end
    
    return Utils.SafeCall(function()
        local player = Player(source)
        if player then
            return player.state[key]
        end
        return nil
    end, 'GetPlayerState')
end

-- Validation helpers
function Utils.IsValidSpeed(speed)
    if type(speed) ~= 'number' then
        Utils.HandleError('Speed must be a number', 'IsValidSpeed')
        return false
    end
    
    local maxSpeed = Config and Config.MaxSpeed or 500
    return speed >= 0 and speed <= maxSpeed
end

function Utils.IsValidHealth(health)
    if type(health) ~= 'number' then
        Utils.HandleError('Health must be a number', 'IsValidHealth')
        return false
    end
    
    local maxHealth = Config and Config.MaxHealth or 200
    return health >= 0 and health <= maxHealth
end

function Utils.IsValidArmor(armor)
    if type(armor) ~= 'number' then
        Utils.HandleError('Armor must be a number', 'IsValidArmor')
        return false
    end
    
    local maxArmor = Config and Config.MaxArmor or 100
    return armor >= 0 and armor <= maxArmor
end

-- Resource validation
function Utils.ValidateResource()
    local resourceName = GetCurrentResourceName()
    if resourceName ~= 'dz' then
        Utils.HandleError('Resource name mismatch', 'ValidateResource')
        return false
    end
    return true
end

-- Initialize
Utils.PrintDebug('Utils module initialized', 'info')
Utils.ValidateResource()

-- Export the utils (removed _G usage)
return Utils
