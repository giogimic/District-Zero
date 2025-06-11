-- District Zero Performance Handler
local Utils = require 'shared/utils'

-- Performance Configuration
local Config = {
    throttle = {
        default = 1000, -- Default throttle time in ms
        events = {
            ['dz:district:update'] = 5000,
            ['dz:faction:update'] = 5000,
            ['dz:mission:update'] = 3000
        }
    },
    cache = {
        ttl = 300, -- Cache time to live in seconds
        maxSize = 1000 -- Maximum cache size
    }
}

-- Event Throttling
local ThrottledEvents = {}

local function ThrottleEvent(eventName, callback, time)
    time = time or Config.throttle.default
    
    if ThrottledEvents[eventName] and (GetGameTimer() - ThrottledEvents[eventName]) < time then
        return false
    end
    
    ThrottledEvents[eventName] = GetGameTimer()
    return callback()
end

-- Cache Management
local Cache = {
    data = {},
    timestamps = {}
}

local function SetCache(key, value, ttl)
    ttl = ttl or Config.cache.ttl
    
    -- Check cache size
    if #Cache.data >= Config.cache.maxSize then
        -- Remove oldest entry
        local oldestKey = nil
        local oldestTime = math.huge
        
        for k, time in pairs(Cache.timestamps) do
            if time < oldestTime then
                oldestTime = time
                oldestKey = k
            end
        end
        
        if oldestKey then
            Cache.data[oldestKey] = nil
            Cache.timestamps[oldestKey] = nil
        end
    end
    
    Cache.data[key] = value
    Cache.timestamps[key] = os.time() + ttl
end

local function GetCache(key)
    if not Cache.data[key] then return nil end
    
    if os.time() > Cache.timestamps[key] then
        Cache.data[key] = nil
        Cache.timestamps[key] = nil
        return nil
    end
    
    return Cache.data[key]
end

-- Loop Optimization
local function OptimizeLoop(callback, interval)
    interval = interval or 1000
    local lastRun = 0
    
    return function(...)
        local currentTime = GetGameTimer()
        if currentTime - lastRun >= interval then
            lastRun = currentTime
            return callback(...)
        end
    end
end

-- Resource Cleanup
local function Cleanup()
    -- Clear cache
    Cache.data = {}
    Cache.timestamps = {}
    
    -- Clear throttled events
    ThrottledEvents = {}
end

-- Exports
exports('ThrottleEvent', ThrottleEvent)
exports('SetCache', SetCache)
exports('GetCache', GetCache)
exports('OptimizeLoop', OptimizeLoop)
exports('Cleanup', Cleanup)

-- Performance Documentation
--[[
Performance Documentation:

Event Throttling:
- ThrottleEvent(eventName, callback, time)
  - Throttles event execution to prevent spam
  - Default throttle time: 1000ms
  - Custom throttle times per event in Config

Cache Management:
- SetCache(key, value, ttl)
  - Stores data in cache with TTL
  - Default TTL: 300 seconds
  - Maximum cache size: 1000 entries
- GetCache(key)
  - Retrieves data from cache
  - Returns nil if expired or not found

Loop Optimization:
- OptimizeLoop(callback, interval)
  - Optimizes loop execution with interval
  - Default interval: 1000ms
  - Prevents excessive CPU usage

Resource Cleanup:
- Cleanup()
  - Clears cache
  - Clears throttled events
  - Should be called on resource stop

Usage:
- Throttle event: exports['district_zero']:ThrottleEvent('eventName', callback, time)
- Cache data: exports['district_zero']:SetCache('key', value, ttl)
- Get cached data: exports['district_zero']:GetCache('key')
- Optimize loop: exports['district_zero']:OptimizeLoop(callback, interval)
- Cleanup: exports['district_zero']:Cleanup()
]] 