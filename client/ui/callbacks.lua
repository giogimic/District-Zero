-- client/ui/callbacks.lua
-- District Zero NUI Callback Management

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Callback state
local State = {
    callbacks = {},
    timeout = 5000 -- 5 seconds
}

-- Register callback
local function RegisterCallback(name, handler)
    if State.callbacks[name] then
        return false, 'Callback already registered'
    end
    
    State.callbacks[name] = {
        handler = handler,
        timeout = State.timeout
    }
    
    return true
end

-- Handle callback
local function HandleCallback(name, data, cb)
    if not State.callbacks[name] then
        cb('error', 'Callback not registered')
        return
    end
    
    local callback = State.callbacks[name]
    
    -- Set callback timeout
    local timeout = SetTimeout(callback.timeout, function()
        if State.callbacks[name] then
            cb('error', 'Callback timeout')
            State.callbacks[name] = nil
        end
    end)
    
    -- Execute callback
    local success, result = pcall(function()
        return callback.handler(data)
    end)
    
    -- Clear timeout
    ClearTimeout(timeout)
    
    if success then
        cb('ok', result)
    else
        cb('error', result)
    end
    
    -- Remove callback
    State.callbacks[name] = nil
end

-- Register NUI callbacks
RegisterNUICallback('action', function(data, cb)
    HandleCallback('action', data, cb)
end)

RegisterNUICallback('close', function(data, cb)
    HandleCallback('close', data, cb)
end)

RegisterNUICallback('error', function(data, cb)
    HandleCallback('error', data, cb)
end)

-- Register cleanup handler
RegisterCleanup('callbacks', function()
    -- Clear all callbacks
    State.callbacks = {}
end)

-- Exports
exports('RegisterCallback', RegisterCallback)
exports('HandleCallback', HandleCallback) 