-- shared/utils.lua
-- Common utility functions for the District Zero system
-- Version: 1.0.0

local Utils = {}
local isInitialized = false

-- Error tracking and logging system
local ErrorTracker = {
    errors = {},
    maxErrors = 100,
    errorCount = 0,
    lastErrorTime = 0
}

local PerformanceTracker = {
    metrics = {},
    startTime = GetGameTimer()
}

-- Log levels
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    CRITICAL = 5
}

local currentLogLevel = LOG_LEVELS.INFO

-- Helper function to get current timestamp
local function GetCurrentTimestamp()
    if IsDuplicityVersion() then -- Server-side
        return os.time()
    else -- Client-side
        return GetGameTimer() / 1000 -- Convert to seconds
    end
end

-- Helper function to format timestamp
local function FormatTimestamp(timestamp)
    if IsDuplicityVersion() then -- Server-side
        return os.date('%Y-%m-%d %H:%M:%S', timestamp)
    else -- Client-side
        return string.format('%d', timestamp)
    end
end

-- Enhanced error handling
function Utils.HandleError(err, context, level)
    level = level or LOG_LEVELS.ERROR
    if level < currentLogLevel then return end
    
    local errorInfo = {
        message = tostring(err),
        context = context or 'unknown',
        timestamp = GetCurrentTimestamp(),
        level = level,
        stack = debug.traceback()
    }
    
    -- Add to error tracker
    ErrorTracker.errorCount = ErrorTracker.errorCount + 1
    table.insert(ErrorTracker.errors, errorInfo)
    
    -- Keep only recent errors
    if #ErrorTracker.errors > ErrorTracker.maxErrors then
        table.remove(ErrorTracker.errors, 1)
    end
    
    -- Format error message
    local levelNames = {'DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL'}
    local prefix = string.format('[District Zero][%s]', levelNames[level])
    local message = string.format('%s %s: %s', prefix, context, tostring(err))
    
    -- Print to console
    if level >= LOG_LEVELS.ERROR then
        print('^1' .. message .. '^7')
    elseif level >= LOG_LEVELS.WARN then
        print('^3' .. message .. '^7')
    else
        print('^5' .. message .. '^7')
    end
    
    -- Log to file if critical (server-side only)
    if level >= LOG_LEVELS.CRITICAL and IsDuplicityVersion() then
        Utils.LogToFile('critical_errors.log', message)
    end
    
    return errorInfo
end

function Utils.PrintError(message, context)
    Utils.HandleError(message, context or 'ERROR', LOG_LEVELS.ERROR)
end

function Utils.PrintDebug(message, level)
    -- Handle level parameter - can be string or number
    local numericLevel = LOG_LEVELS.INFO -- default
    if type(level) == 'string' then
        numericLevel = LOG_LEVELS[level:upper()] or LOG_LEVELS.INFO
    elseif type(level) == 'number' then
        numericLevel = level
    end
    
    if numericLevel < currentLogLevel then return end
    
    local levelNames = {'DEBUG', 'INFO', 'WARN', 'ERROR', 'CRITICAL'}
    local prefix = string.format('[District Zero][%s]', levelNames[numericLevel])
    local formattedMessage = string.format('%s %s', prefix, tostring(message))
    
    if numericLevel >= LOG_LEVELS.WARN then
        print('^3' .. formattedMessage .. '^7')
    else
        print('^5' .. formattedMessage .. '^7')
    end
end

-- Performance monitoring
function Utils.StartTimer(name)
    if not name then return end
    PerformanceTracker.metrics[name] = {
        startTime = GetGameTimer(),
        endTime = nil,
        duration = nil
    }
end

function Utils.EndTimer(name)
    if not name or not PerformanceTracker.metrics[name] then return end
    
    local metric = PerformanceTracker.metrics[name]
    metric.endTime = GetGameTimer()
    metric.duration = metric.endTime - metric.startTime
    
    -- Log slow operations
    if metric.duration > 100 then -- 100ms threshold
        Utils.PrintDebug(string.format('Slow operation detected: %s took %dms', name, metric.duration), LOG_LEVELS.WARN)
    end
    
    return metric.duration
end

function Utils.GetPerformanceMetrics()
    return PerformanceTracker.metrics
end

-- Enhanced safe call with performance tracking
function Utils.SafeCall(fn, context, ...)
    local args = {...}
    local timerName = context or 'SafeCall'
    
    Utils.StartTimer(timerName)
    
    local success, result = pcall(function()
        return fn(table.unpack(args))
    end)
    
    Utils.EndTimer(timerName)
    
    if not success then
        Utils.HandleError(result, context, LOG_LEVELS.ERROR)
        return nil
    end
    
    return result
end

-- File logging (server-side only)
function Utils.LogToFile(filename, message)
    if not filename or not message or not IsDuplicityVersion() then return end
    
    local success = pcall(function()
        local file = io.open(GetResourcePath(GetCurrentResourceName()) .. '/logs/' .. filename, 'a')
        if file then
            local timestamp = FormatTimestamp(GetCurrentTimestamp())
            file:write(string.format('[%s] %s\n', timestamp, message))
            file:close()
        end
    end)
    
    if not success then
        print('^1[District Zero] Failed to write to log file: ' .. filename .. '^7')
    end
end

-- Enhanced notification system
function Utils.SendNotification(source, type, message, duration)
    if not source then 
        Utils.PrintError('SendNotification: Source is required')
        return 
    end
    if not type then type = 'info' end
    if not message then 
        Utils.PrintError('SendNotification: Message is required')
        return 
    end
    duration = duration or 5000
    
    Utils.SafeCall(function()
        TriggerClientEvent('ox_lib:notify', source, {
            type = type,
            description = message,
            duration = duration
        })
    end, 'SendNotification')
end

-- Enhanced database helpers with proper error handling
function Utils.SafeQuery(query, params, context)
    if not query then 
        Utils.PrintError('SafeQuery: Query is required', context)
        return nil 
    end
    
    Utils.StartTimer('DatabaseQuery_' .. (context or 'unknown'))
    
    local success, result = pcall(function()
        return MySQL.query.await(query, params)
    end)
    
    Utils.EndTimer('DatabaseQuery_' .. (context or 'unknown'))
    
    if not success then
        Utils.HandleError('Query failed: ' .. tostring(result), context, LOG_LEVELS.ERROR)
        return nil
    end
    
    return result
end

function Utils.SafeInsert(query, params, context)
    if not query then 
        Utils.PrintError('SafeInsert: Query is required', context)
        return nil 
    end
    
    Utils.StartTimer('DatabaseInsert_' .. (context or 'unknown'))
    
    local success, result = pcall(function()
        return MySQL.insert.await(query, params)
    end)
    
    Utils.EndTimer('DatabaseInsert_' .. (context or 'unknown'))
    
    if not success then
        Utils.HandleError('Insert failed: ' .. tostring(result), context, LOG_LEVELS.ERROR)
        return nil
    end
    
    return result
end

function Utils.SafeUpdate(query, params, context)
    if not query then 
        Utils.PrintError('SafeUpdate: Query is required', context)
        return nil 
    end
    
    Utils.StartTimer('DatabaseUpdate_' .. (context or 'unknown'))
    
    local success, result = pcall(function()
        return MySQL.update.await(query, params)
    end)
    
    Utils.EndTimer('DatabaseUpdate_' .. (context or 'unknown'))
    
    if not success then
        Utils.HandleError('Update failed: ' .. tostring(result), context, LOG_LEVELS.ERROR)
        return nil
    end
    
    return result
end

-- Enhanced event helpers with rate limiting and error handling
local eventCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second cooldown

function Utils.TriggerClientEvent(eventName, source, ...)
    if not eventName then
        Utils.PrintError('TriggerClientEvent: Event name is required')
        return
    end
    
    if not source then
        Utils.PrintError('TriggerClientEvent: Source is required')
        return
    end
    
    -- Rate limiting
    local eventKey = eventName .. '_' .. source
    if eventCooldowns[eventKey] and GetGameTimer() - eventCooldowns[eventKey] < COOLDOWN_TIME then
        Utils.PrintDebug('Event rate limited: ' .. eventName, LOG_LEVELS.DEBUG)
        return
    end
    eventCooldowns[eventKey] = GetGameTimer()
    
    local args = {...}
    Utils.SafeCall(function()
        TriggerClientEvent('dz:client:' .. eventName, source, table.unpack(args))
    end, 'TriggerClientEvent_' .. eventName)
end

function Utils.TriggerServerEvent(eventName, ...)
    if not eventName then
        Utils.PrintError('TriggerServerEvent: Event name is required')
        return
    end
    
    -- Rate limiting
    if eventCooldowns[eventName] and GetGameTimer() - eventCooldowns[eventName] < COOLDOWN_TIME then
        Utils.PrintDebug('Server event rate limited: ' .. eventName, LOG_LEVELS.DEBUG)
        return
    end
    eventCooldowns[eventName] = GetGameTimer()
    
    local args = {...}
    Utils.SafeCall(function()
        TriggerServerEvent('dz:server:' .. eventName, table.unpack(args))
    end, 'TriggerServerEvent_' .. eventName)
end

-- Enhanced state management with proper replication
function Utils.SetPlayerState(source, key, value)
    if not source then
        Utils.PrintError('SetPlayerState: Source is required')
        return
    end
    
    if not key then
        Utils.PrintError('SetPlayerState: Key is required')
        return
    end
    
    Utils.SafeCall(function()
        local player = Player(source)
        if player then
            player.state:set(key, value, true) -- true for replication
        else
            Utils.PrintError('SetPlayerState: Player not found', 'StateManagement')
        end
    end, 'SetPlayerState')
end

function Utils.GetPlayerState(source, key)
    if not source then
        Utils.PrintError('GetPlayerState: Source is required')
        return nil
    end
    
    if not key then
        Utils.PrintError('GetPlayerState: Key is required')
        return nil
    end
    
    return Utils.SafeCall(function()
        local player = Player(source)
        if player then
            return player.state[key]
        else
            Utils.PrintError('GetPlayerState: Player not found', 'StateManagement')
            return nil
        end
    end, 'GetPlayerState')
end

-- Enhanced validation helpers
function Utils.ValidateConfig()
    if not Config then
        Utils.PrintError('Config is not defined', 'Validation')
        return false
    end
    
    local requiredSections = {'Districts', 'Missions', 'Teams', 'SafeZones'}
    for _, section in ipairs(requiredSections) do
        if not Config[section] then
            Utils.PrintError('Config.' .. section .. ' is not defined', 'Validation')
            return false
        end
    end
    
    -- Validate districts
    for _, district in pairs(Config.Districts) do
        if not district.id or not district.name or not district.zones then
            Utils.PrintError('Invalid district configuration: ' .. (district.id or 'unknown'), 'Validation')
            return false
        end
    end
    
    -- Validate missions
    for _, mission in pairs(Config.Missions) do
        if not mission.id or not mission.title or not mission.objectives then
            Utils.PrintError('Invalid mission configuration: ' .. (mission.id or 'unknown'), 'Validation')
            return false
        end
    end
    
    Utils.PrintDebug('Configuration validation passed', LOG_LEVELS.INFO)
    return true
end

-- Resource validation
function Utils.ValidateResource()
    local resourceName = GetCurrentResourceName()
    -- Accept both 'District-Zero' and 'district-zero' as valid names
    if resourceName ~= 'District-Zero' and resourceName ~= 'district-zero' then
        Utils.PrintError('Resource name mismatch: expected District-Zero or district-zero, got ' .. resourceName, 'Validation')
        return false
    end
    return true
end

-- Error reporting
function Utils.GetErrorReport()
    return {
        totalErrors = ErrorTracker.errorCount,
        recentErrors = ErrorTracker.errors,
        performanceMetrics = PerformanceTracker.metrics,
        uptime = GetGameTimer() - PerformanceTracker.startTime
    }
end

function Utils.ClearErrorLog()
    ErrorTracker.errors = {}
    ErrorTracker.errorCount = 0
    Utils.PrintDebug('Error log cleared', LOG_LEVELS.INFO)
end

-- Set log level
function Utils.SetLogLevel(level)
    if LOG_LEVELS[level] then
        currentLogLevel = LOG_LEVELS[level]
        Utils.PrintDebug('Log level set to: ' .. level, LOG_LEVELS.INFO)
    else
        Utils.PrintError('Invalid log level: ' .. tostring(level), 'Configuration')
    end
end

-- Initialize only once
if not isInitialized then
    Utils.PrintDebug('Utils module initialized', LOG_LEVELS.INFO)
    
    -- Create logs directory if it doesn't exist (server-side only)
    if IsDuplicityVersion() then
        local success = pcall(function()
            os.execute('mkdir -p "' .. GetResourcePath(GetCurrentResourceName()) .. '/logs"')
        end)
        
        if not success then
            Utils.PrintError('Failed to create logs directory', 'Initialization')
        end
    end
    
    -- Validate resource
    if not Utils.ValidateResource() then
        Utils.PrintError('Resource validation failed', 'Initialization')
    end
    
    isInitialized = true
end

return Utils
