-- District Zero Database Handler
local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'

-- Database Configuration
local Config = {
    poolSize = 5,
    timeout = 5000,
    retries = 3
}

-- Connection Pool
local pool = {}

-- Initialize Pool
local function InitializePool()
    for i = 1, Config.poolSize do
        pool[i] = {
            inUse = false,
            lastUsed = 0
        }
    end
end

-- Get Connection
local function GetConnection()
    for i = 1, Config.poolSize do
        if not pool[i].inUse then
            pool[i].inUse = true
            pool[i].lastUsed = os.time()
            return i
        end
    end
    return nil
end

-- Release Connection
local function ReleaseConnection(id)
    if pool[id] then
        pool[id].inUse = false
    end
end

-- Execute Query with Retry
local function ExecuteQuery(query, params, retries)
    retries = retries or Config.retries
    local connId = GetConnection()
    
    if not connId then
        Utils.HandleError('No available database connections', 'ExecuteQuery')
        return nil
    end
    
    local success, result = pcall(function()
        return MySQL.query.await(query, params)
    end)
    
    ReleaseConnection(connId)
    
    if not success then
        if retries > 0 then
            Wait(1000)
            return ExecuteQuery(query, params, retries - 1)
        end
        Utils.HandleError('Database query failed: ' .. tostring(result), 'ExecuteQuery')
        return nil
    end
    
    return result
end

-- Execute Transaction
local function ExecuteTransaction(queries)
    local connId = GetConnection()
    
    if not connId then
        Utils.HandleError('No available database connections', 'ExecuteTransaction')
        return false
    end
    
    local success = pcall(function()
        MySQL.transaction.await(queries)
    end)
    
    ReleaseConnection(connId)
    
    if not success then
        Utils.HandleError('Transaction failed', 'ExecuteTransaction')
        return false
    end
    
    return true
end

-- Initialize
CreateThread(function()
    InitializePool()
end)

-- Exports
exports('Query', ExecuteQuery)
exports('Transaction', ExecuteTransaction)

-- Event Handlers
RegisterNetEvent('dz:database:query')
AddEventHandler('dz:database:query', function(query, params, cb)
    if not query then return end
    
    local result = ExecuteQuery(query, params)
    if cb then cb(result) end
end)

RegisterNetEvent('dz:database:transaction')
AddEventHandler('dz:database:transaction', function(queries, cb)
    if not queries then return end
    
    local success = ExecuteTransaction(queries)
    if cb then cb(success) end
end) 