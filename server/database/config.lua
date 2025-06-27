-- server/database/config.lua
-- District Zero Database Configuration

local Config = {
    -- Connection settings
    connectionTimeout = 10000, -- 10 seconds
    poolSize = 10,
    retryAttempts = 3,
    
    -- Query settings
    queryTimeout = 5000, -- 5 seconds
    maxRetries = 3,
    
    -- Cache settings
    cacheTimeout = 300000, -- 5 minutes
    maxCacheSize = 1000
}

-- Initialize database connection
local function InitializeDatabase()
    local success, error = pcall(function()
        MySQL.ready(function()
            -- Set connection pool size
            MySQL.query('SET SESSION wait_timeout = ?', {Config.connectionTimeout})
            MySQL.query('SET SESSION max_connections = ?', {Config.poolSize})
            
            -- Set query timeout
            MySQL.query('SET SESSION max_execution_time = ?', {Config.queryTimeout})
        end)
    end)
    
    if not success then
        print('^1Database connection failed: ' .. tostring(error))
        return false
    end
    
    return true
end

-- Safe query execution with retries
local function SafeQuery(query, params, context)
    local attempts = 0
    local success, result
    
    while attempts < Config.maxRetries do
        success, result = pcall(function()
            return MySQL.query.await(query, params)
        end)
        
        if success then
            return result
        end
        
        attempts = attempts + 1
        if attempts < Config.maxRetries then
            Wait(1000) -- Wait 1 second before retry
        end
    end
    
    print('^1Query failed after ' .. attempts .. ' attempts: ' .. tostring(result))
    return nil
end

-- Query cache
local queryCache = {
    data = {},
    size = 0
}

-- Cache query result
local function CacheQuery(key, data)
    if queryCache.size >= Config.maxCacheSize then
        -- Remove oldest entry
        local oldestKey = next(queryCache.data)
        queryCache.data[oldestKey] = nil
        queryCache.size = queryCache.size - 1
    end
    
    queryCache.data[key] = {
        data = data,
        timestamp = GetGameTimer()
    }
    queryCache.size = queryCache.size + 1
end

-- Get cached query result
local function GetCachedQuery(key)
    local cached = queryCache.data[key]
    if cached and (GetGameTimer() - cached.timestamp) < Config.cacheTimeout then
        return cached.data
    end
    return nil
end

-- Clear query cache
local function ClearQueryCache()
    queryCache.data = {}
    queryCache.size = 0
end

-- Register cleanup handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Clear query cache
    ClearQueryCache()
    
    -- Close database connection
    if MySQL then
        MySQL.close()
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeDatabase()
end)

-- Exports
exports('SafeQuery', SafeQuery)
exports('CacheQuery', CacheQuery)
exports('GetCachedQuery', GetCachedQuery)
exports('ClearQueryCache', ClearQueryCache) 