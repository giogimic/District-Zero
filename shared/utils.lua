-- shared/utils.lua
-- Common utility functions for the District Zero system

local Utils = {}
local isInitialized = false

-- Error handling
function Utils.HandleError(err, context)
    print(string.format('[APB Error] %s: %s', context, tostring(err)))
end

function Utils.PrintError(message)
    print(string.format('[APB Error] %s', tostring(message)))
end

function Utils.PrintDebug(message, level)
    level = level or 'info'
    local prefix = string.format('[APB Debug][%s]', level:upper())
    print(string.format('%s %s', prefix, tostring(message)))
end

function Utils.SafeCall(fn, context, ...)
    local args = {...}
    local success, result = pcall(function()
        return fn(table.unpack(args))
    end)
    if not success then
        Utils.HandleError(result, context)
        return nil
    end
    return result
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
        Utils.PrintError('Query failed in ' .. (context or 'unknown') .. ': ' .. tostring(result))
        return nil
    end
    
    return result
end

-- Event helpers with rate limiting
local eventCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second cooldown

function Utils.TriggerClientEvent(eventName, source, ...)
    if not eventName then
        Utils.PrintError('Event name is required')
        return
    end
    
    if not source then
        Utils.PrintError('Source is required')
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
        TriggerClientEvent('dz:' .. eventName, source, table.unpack(args))
    end, 'TriggerClientEvent')
end

function Utils.TriggerServerEvent(eventName, ...)
    if not eventName then
        Utils.PrintError('Event name is required')
        return
    end
    
    -- Rate limiting
    if eventCooldowns[eventName] and GetGameTimer() - eventCooldowns[eventName] < COOLDOWN_TIME then
        return
    end
    eventCooldowns[eventName] = GetGameTimer()
    
    local args = {...}
    Utils.SafeCall(function()
        TriggerServerEvent('dz:' .. eventName, table.unpack(args))
    end, 'TriggerServerEvent')
end

-- State management with proper replication
function Utils.SetPlayerState(source, key, value)
    if not source then
        Utils.PrintError('Source is required')
        return
    end
    
    if not key then
        Utils.PrintError('Key is required')
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
        Utils.PrintError('Source is required')
        return nil
    end
    
    if not key then
        Utils.PrintError('Key is required')
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
function Utils.ValidateConfig()
    if not Config then
        Utils.PrintError('Config is not defined')
        return false
    end
    
    if not Config.Districts then
        Utils.PrintError('Config.Districts is not defined')
        return false
    end
    
    if not Config.Missions then
        Utils.PrintError('Config.Missions is not defined')
        return false
    end
    
    if not Config.Teams then
        Utils.PrintError('Config.Teams is not defined')
        return false
    end
    
    return true
end

-- Resource validation
function Utils.ValidateResource()
    local resourceName = GetCurrentResourceName()
    if resourceName ~= 'dz' then
        Utils.PrintError('Resource name mismatch')
        return false
    end
    return true
end

-- Initialize only once
if not isInitialized then
    Utils.PrintDebug('Utils module initialized', 'info')
    Utils.ValidateResource()
    isInitialized = true
end

return Utils
