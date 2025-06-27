-- Performance Optimization System for District Zero
-- Version: 1.0.0

local PerformanceSystem = {
    -- Blip Management
    blips = {},
    blipPool = {},
    maxBlips = 150,
    blipCleanupInterval = 30000, -- 30 seconds
    lastBlipCleanup = 0,
    
    -- Event Throttling
    eventThrottles = {},
    throttleConfig = {
        district_update = { interval = 1000, maxPerInterval = 5 },
        mission_update = { interval = 2000, maxPerInterval = 3 },
        team_update = { interval = 1500, maxPerInterval = 4 },
        influence_update = { interval = 3000, maxPerInterval = 2 },
        capture_update = { interval = 500, maxPerInterval = 10 },
        notification = { interval = 100, maxPerInterval = 20 }
    },
    
    -- Memory Management
    memoryUsage = 0,
    memoryThreshold = 100 * 1024 * 1024, -- 100MB
    garbageCollectionInterval = 60000, -- 1 minute
    lastGarbageCollection = 0,
    
    -- Caching System
    cache = {},
    cacheConfig = {
        maxSize = 1000,
        ttl = 300000, -- 5 minutes
        cleanupInterval = 60000 -- 1 minute
    },
    lastCacheCleanup = 0,
    
    -- Performance Monitoring
    performanceMetrics = {
        fps = 0,
        memoryUsage = 0,
        networkLatency = 0,
        blipCount = 0,
        eventCount = 0,
        cacheHits = 0,
        cacheMisses = 0
    },
    metricsUpdateInterval = 5000, -- 5 seconds
    lastMetricsUpdate = 0,
    
    -- Network Optimization
    networkThrottles = {},
    networkConfig = {
        maxEventsPerSecond = 50,
        batchSize = 10,
        compressionThreshold = 1024 -- 1KB
    }
}

-- Blip Management System
local function CreateOptimizedBlip(data)
    if not data or not data.coords then
        return nil, 'Invalid blip data'
    end
    
    -- Check blip limit
    local blipCount = 0
    for _ in pairs(PerformanceSystem.blips) do
        blipCount = blipCount + 1
    end
    
    if blipCount >= PerformanceSystem.maxBlips then
        -- Clean up old blips
        PerformanceSystem.CleanupOldBlips()
        
        -- Check again after cleanup
        blipCount = 0
        for _ in pairs(PerformanceSystem.blips) do
            blipCount = blipCount + 1
        end
        
        if blipCount >= PerformanceSystem.maxBlips then
            return nil, 'Maximum blip limit reached'
        end
    end
    
    -- Try to reuse blip from pool
    local blip = nil
    if #PerformanceSystem.blipPool > 0 then
        blip = table.remove(PerformanceSystem.blipPool)
    else
        blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    end
    
    if not blip or blip == 0 then
        return nil, 'Failed to create blip'
    end
    
    -- Configure blip
    SetBlipSprite(blip, data.sprite or 1)
    SetBlipDisplay(blip, data.display or 4)
    SetBlipScale(blip, data.scale or 0.8)
    SetBlipColour(blip, data.color or 0)
    SetBlipAsShortRange(blip, data.shortRange ~= false)
    
    if data.name then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
    
    -- Store blip data
    local blipId = data.id or ('blip_' .. GetGameTimer())
    PerformanceSystem.blips[blipId] = {
        blip = blip,
        data = data,
        created = GetGameTimer(),
        lastUpdate = GetGameTimer()
    }
    
    return blipId, blip
end

local function RemoveOptimizedBlip(blipId)
    local blipData = PerformanceSystem.blips[blipId]
    if not blipData then
        return false, 'Blip not found'
    end
    
    -- Remove blip
    if blipData.blip and blipData.blip ~= 0 then
        RemoveBlip(blipData.blip)
        
        -- Add to pool for reuse
        if #PerformanceSystem.blipPool < 50 then
            table.insert(PerformanceSystem.blipPool, blipData.blip)
        end
    end
    
    PerformanceSystem.blips[blipId] = nil
    return true, 'Blip removed'
end

local function UpdateOptimizedBlip(blipId, data)
    local blipData = PerformanceSystem.blips[blipId]
    if not blipData then
        return false, 'Blip not found'
    end
    
    -- Update blip properties
    if data.coords then
        SetBlipCoords(blipData.blip, data.coords.x, data.coords.y, data.coords.z)
    end
    
    if data.sprite then
        SetBlipSprite(blipData.blip, data.sprite)
    end
    
    if data.color then
        SetBlipColour(blipData.blip, data.color)
    end
    
    if data.scale then
        SetBlipScale(blipData.blip, data.scale)
    end
    
    -- Update metadata
    blipData.lastUpdate = GetGameTimer()
    if data.data then
        blipData.data = data.data
    end
    
    return true, 'Blip updated'
end

local function CleanupOldBlips()
    local currentTime = GetGameTimer()
    local toRemove = {}
    
    for blipId, blipData in pairs(PerformanceSystem.blips) do
        -- Remove blips older than 5 minutes
        if currentTime - blipData.lastUpdate > 300000 then
            table.insert(toRemove, blipId)
        end
    end
    
    for _, blipId in ipairs(toRemove) do
        RemoveOptimizedBlip(blipId)
    end
    
    PerformanceSystem.lastBlipCleanup = currentTime
    return #toRemove
end

-- Event Throttling System
local function ShouldThrottleEvent(eventType)
    local config = PerformanceSystem.throttleConfig[eventType]
    if not config then
        return false
    end
    
    local currentTime = GetGameTimer()
    local throttle = PerformanceSystem.eventThrottles[eventType]
    
    if not throttle then
        PerformanceSystem.eventThrottles[eventType] = {
            lastEvent = 0,
            eventCount = 0,
            intervalStart = currentTime
        }
        return false
    end
    
    -- Check if we're in a new interval
    if currentTime - throttle.intervalStart >= config.interval then
        throttle.eventCount = 0
        throttle.intervalStart = currentTime
    end
    
    -- Check if we've exceeded the limit
    if throttle.eventCount >= config.maxPerInterval then
        return true
    end
    
    -- Update event count
    throttle.eventCount = throttle.eventCount + 1
    throttle.lastEvent = currentTime
    
    return false
end

local function ThrottledTriggerEvent(eventName, ...)
    if ShouldThrottleEvent(eventName) then
        return false, 'Event throttled'
    end
    
    TriggerEvent(eventName, ...)
    return true, 'Event triggered'
end

local function ThrottledTriggerServerEvent(eventName, ...)
    if ShouldThrottleEvent(eventName) then
        return false, 'Event throttled'
    end
    
    TriggerServerEvent(eventName, ...)
    return true, 'Event triggered'
end

-- Memory Management System
local function GetMemoryUsage()
    local memoryInfo = collectgarbage('count')
    PerformanceSystem.memoryUsage = memoryInfo * 1024 -- Convert to bytes
    return PerformanceSystem.memoryUsage
end

local function OptimizeMemory()
    local currentTime = GetGameTimer()
    
    -- Force garbage collection
    collectgarbage('collect')
    
    -- Clean up old cache entries
    PerformanceSystem.CleanupCache()
    
    -- Clean up old blips
    PerformanceSystem.CleanupOldBlips()
    
    PerformanceSystem.lastGarbageCollection = currentTime
    return GetMemoryUsage()
end

local function CheckMemoryThreshold()
    local memoryUsage = GetMemoryUsage()
    
    if memoryUsage > PerformanceSystem.memoryThreshold then
        OptimizeMemory()
        return true, 'Memory optimized'
    end
    
    return false, 'Memory usage normal'
end

-- Caching System
local function GetCacheKey(...)
    local args = {...}
    local key = ''
    for i, arg in ipairs(args) do
        key = key .. tostring(arg) .. '_'
    end
    return key:sub(1, -2) -- Remove trailing underscore
end

local function GetFromCache(...)
    local key = GetCacheKey(...)
    local cacheEntry = PerformanceSystem.cache[key]
    
    if not cacheEntry then
        PerformanceSystem.performanceMetrics.cacheMisses = PerformanceSystem.performanceMetrics.cacheMisses + 1
        return nil
    end
    
    -- Check if entry is expired
    if GetGameTimer() - cacheEntry.timestamp > PerformanceSystem.cacheConfig.ttl then
        PerformanceSystem.cache[key] = nil
        PerformanceSystem.performanceMetrics.cacheMisses = PerformanceSystem.performanceMetrics.cacheMisses + 1
        return nil
    end
    
    PerformanceSystem.performanceMetrics.cacheHits = PerformanceSystem.performanceMetrics.cacheHits + 1
    return cacheEntry.data
end

local function SetCache(data, ttl, ...)
    local key = GetCacheKey(...)
    local currentTime = GetGameTimer()
    
    -- Check cache size
    local cacheSize = 0
    for _ in pairs(PerformanceSystem.cache) do
        cacheSize = cacheSize + 1
    end
    
    if cacheSize >= PerformanceSystem.cacheConfig.maxSize then
        -- Remove oldest entries
        local oldestKey = nil
        local oldestTime = currentTime
        
        for k, entry in pairs(PerformanceSystem.cache) do
            if entry.timestamp < oldestTime then
                oldestTime = entry.timestamp
                oldestKey = k
            end
        end
        
        if oldestKey then
            PerformanceSystem.cache[oldestKey] = nil
        end
    end
    
    PerformanceSystem.cache[key] = {
        data = data,
        timestamp = currentTime,
        ttl = ttl or PerformanceSystem.cacheConfig.ttl
    }
    
    return true
end

local function CleanupCache()
    local currentTime = GetGameTimer()
    local toRemove = {}
    
    for key, entry in pairs(PerformanceSystem.cache) do
        if currentTime - entry.timestamp > entry.ttl then
            table.insert(toRemove, key)
        end
    end
    
    for _, key in ipairs(toRemove) do
        PerformanceSystem.cache[key] = nil
    end
    
    PerformanceSystem.lastCacheCleanup = currentTime
    return #toRemove
end

-- Performance Monitoring System
local function UpdatePerformanceMetrics()
    local currentTime = GetGameTimer()
    
    -- Update FPS (simplified calculation)
    PerformanceSystem.performanceMetrics.fps = Utils.GetFrameRate()
    
    -- Update memory usage (simplified)
    PerformanceSystem.performanceMetrics.memoryUsage = GetMemoryUsage()
    
    -- Update CPU usage (simplified)
    PerformanceSystem.performanceMetrics.cpu = 30 -- Default value
    
    -- Update network latency (simplified)
    PerformanceSystem.performanceMetrics.networkLatency = 50 -- Default value
    
    -- Update blip count
    local blipCount = 0
    for _ in pairs(PerformanceSystem.blips) do
        blipCount = blipCount + 1
    end
    PerformanceSystem.performanceMetrics.blipCount = blipCount
    
    -- Update event count
    local eventCount = 0
    for _, throttle in pairs(PerformanceSystem.eventThrottles) do
        eventCount = eventCount + throttle.eventCount
    end
    PerformanceSystem.performanceMetrics.eventCount = eventCount
    
    PerformanceSystem.lastMetricsUpdate = currentTime
end

local function GetPerformanceMetrics()
    return PerformanceSystem.performanceMetrics
end

local function LogPerformanceMetrics()
    local metrics = GetPerformanceMetrics()
    print('^3[District Zero Performance] ^7Metrics:')
    print('  FPS: ' .. metrics.fps)
    print('  Memory: ' .. math.floor(metrics.memoryUsage / 1024 / 1024) .. 'MB')
    print('  Blips: ' .. metrics.blipCount)
    print('  Events: ' .. metrics.eventCount)
    print('  Cache Hits: ' .. metrics.cacheHits)
    print('  Cache Misses: ' .. metrics.cacheMisses)
end

-- Network Optimization System
local function ShouldThrottleNetwork(eventName)
    local currentTime = GetGameTimer()
    local throttle = PerformanceSystem.networkThrottles[eventName]
    
    if not throttle then
        PerformanceSystem.networkThrottles[eventName] = {
            lastEvent = 0,
            eventCount = 0,
            intervalStart = currentTime
        }
        return false
    end
    
    -- Check if we're in a new second
    if currentTime - throttle.intervalStart >= 1000 then
        throttle.eventCount = 0
        throttle.intervalStart = currentTime
    end
    
    -- Check if we've exceeded the limit
    if throttle.eventCount >= PerformanceSystem.networkConfig.maxEventsPerSecond then
        return true
    end
    
    throttle.eventCount = throttle.eventCount + 1
    throttle.lastEvent = currentTime
    
    return false
end

local function OptimizedTriggerServerEvent(eventName, ...)
    if ShouldThrottleNetwork(eventName) then
        return false, 'Network throttled'
    end
    
    TriggerServerEvent(eventName, ...)
    return true, 'Event sent'
end

-- Batch Processing System
local function CreateBatchProcessor(batchSize, processFunction)
    local batch = {
        items = {},
        size = batchSize or PerformanceSystem.networkConfig.batchSize,
        processFunction = processFunction,
        lastProcess = 0
    }
    
    function batch:Add(item)
        table.insert(self.items, item)
        
        if #self.items >= self.size then
            self:Process()
        end
    end
    
    function batch:Process()
        if #self.items > 0 then
            self.processFunction(self.items)
            self.items = {}
            self.lastProcess = GetGameTimer()
        end
    end
    
    return batch
end

-- Performance System Methods
PerformanceSystem.CreateOptimizedBlip = CreateOptimizedBlip
PerformanceSystem.RemoveOptimizedBlip = RemoveOptimizedBlip
PerformanceSystem.UpdateOptimizedBlip = UpdateOptimizedBlip
PerformanceSystem.CleanupOldBlips = CleanupOldBlips
PerformanceSystem.ThrottledTriggerEvent = ThrottledTriggerEvent
PerformanceSystem.ThrottledTriggerServerEvent = ThrottledTriggerServerEvent
PerformanceSystem.GetMemoryUsage = GetMemoryUsage
PerformanceSystem.OptimizeMemory = OptimizeMemory
PerformanceSystem.CheckMemoryThreshold = CheckMemoryThreshold
PerformanceSystem.GetFromCache = GetFromCache
PerformanceSystem.SetCache = SetCache
PerformanceSystem.CleanupCache = CleanupCache
PerformanceSystem.UpdatePerformanceMetrics = UpdatePerformanceMetrics
PerformanceSystem.GetPerformanceMetrics = GetPerformanceMetrics
PerformanceSystem.LogPerformanceMetrics = LogPerformanceMetrics
PerformanceSystem.OptimizedTriggerServerEvent = OptimizedTriggerServerEvent
PerformanceSystem.CreateBatchProcessor = CreateBatchProcessor

-- Performance Monitoring Thread
CreateThread(function()
    while true do
        Wait(PerformanceSystem.metricsUpdateInterval)
        UpdatePerformanceMetrics()
        
        -- Log metrics every 30 seconds
        if GetGameTimer() - PerformanceSystem.lastMetricsUpdate > 30000 then
            LogPerformanceMetrics()
        end
    end
end)

-- Memory Management Thread
CreateThread(function()
    while true do
        Wait(PerformanceSystem.garbageCollectionInterval)
        CheckMemoryThreshold()
    end
end)

-- Cache Cleanup Thread
CreateThread(function()
    while true do
        Wait(PerformanceSystem.cacheConfig.cleanupInterval)
        CleanupCache()
    end
end)

-- Blip Cleanup Thread
CreateThread(function()
    while true do
        Wait(PerformanceSystem.blipCleanupInterval)
        CleanupOldBlips()
    end
end)

-- Exports
exports('CreateOptimizedBlip', CreateOptimizedBlip)
exports('RemoveOptimizedBlip', RemoveOptimizedBlip)
exports('UpdateOptimizedBlip', UpdateOptimizedBlip)
exports('ThrottledTriggerEvent', ThrottledTriggerEvent)
exports('ThrottledTriggerServerEvent', ThrottledTriggerServerEvent)
exports('GetMemoryUsage', GetMemoryUsage)
exports('OptimizeMemory', OptimizeMemory)
exports('GetFromCache', GetFromCache)
exports('SetCache', SetCache)
exports('GetPerformanceMetrics', GetPerformanceMetrics)
exports('OptimizedTriggerServerEvent', OptimizedTriggerServerEvent)
exports('CreateBatchProcessor', CreateBatchProcessor)

return PerformanceSystem 