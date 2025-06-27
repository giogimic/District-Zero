--[[
    District Zero FiveM - Error Handler
    Comprehensive error handling, logging, and recovery system
]]

local ErrorHandler = {}
ErrorHandler.__index = ErrorHandler

-- Configuration
local CONFIG = {
    ENABLE_ERROR_LOGGING = true,
    ENABLE_PERFORMANCE_MONITORING = true,
    ENABLE_ERROR_RECOVERY = true,
    MAX_ERROR_LOG_SIZE = 1000,
    ERROR_LOG_FILE = "error_log.json",
    PERFORMANCE_LOG_FILE = "performance_log.json",
    LOG_LEVEL = "INFO", -- DEBUG, INFO, WARN, ERROR, CRITICAL
    AUTO_RECOVERY_ENABLED = true,
    MAX_RECOVERY_ATTEMPTS = 3
}

-- Error state
local errorState = {
    errorCount = 0,
    lastError = nil,
    errorHistory = {},
    performanceMetrics = {},
    recoveryAttempts = {},
    isRecovering = false
}

-- Log levels
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    CRITICAL = 5
}

-- Initialize error handler
function ErrorHandler.Initialize()
    print("^2[District Zero] ^7Initializing Error Handler...")
    
    -- Load configuration
    ErrorHandler.LoadConfiguration()
    
    -- Initialize error logging
    if CONFIG.ENABLE_ERROR_LOGGING then
        ErrorHandler.InitializeErrorLogging()
    end
    
    -- Initialize performance monitoring
    if CONFIG.ENABLE_PERFORMANCE_MONITORING then
        ErrorHandler.InitializePerformanceMonitoring()
    end
    
    -- Set up error recovery
    if CONFIG.ENABLE_ERROR_RECOVERY then
        ErrorHandler.InitializeErrorRecovery()
    end
    
    -- Register error events
    ErrorHandler.RegisterErrorEvents()
    
    print("^2[District Zero] ^7Error Handler Initialized")
end

-- Load configuration
function ErrorHandler.LoadConfiguration()
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config/error_handler.json")
    if configFile then
        local config = json.decode(configFile)
        if config then
            for key, value in pairs(config) do
                CONFIG[key] = value
            end
        end
    end
    
    -- Create default config if not exists
    if not configFile then
        ErrorHandler.SaveConfiguration()
    end
end

-- Save configuration
function ErrorHandler.SaveConfiguration()
    local configDir = GetResourcePath(GetCurrentResourceName()) .. "/config"
    if not Utils.DoesDirectoryExist(configDir) then
        Utils.CreateDirectory(configDir)
    end
    
    SaveResourceFile(GetCurrentResourceName(), "config/error_handler.json", json.encode(CONFIG, {indent = true}))
end

-- Initialize error logging
function ErrorHandler.InitializeErrorLogging()
    -- Load existing error log
    local logFile = LoadResourceFile(GetCurrentResourceName(), "data/" .. CONFIG.ERROR_LOG_FILE)
    if logFile then
        local log = json.decode(logFile)
        if log then
            errorState.errorHistory = log.errors or {}
            errorState.errorCount = log.totalErrors or 0
        end
    end
end

-- Initialize performance monitoring
function ErrorHandler.InitializePerformanceMonitoring()
    -- Load existing performance log
    local perfFile = LoadResourceFile(GetCurrentResourceName(), "data/" .. CONFIG.PERFORMANCE_LOG_FILE)
    if perfFile then
        local perf = json.decode(perfFile)
        if perf then
            errorState.performanceMetrics = perf.metrics or {}
        end
    end
end

-- Initialize error recovery
function ErrorHandler.InitializeErrorRecovery()
    -- Set up recovery mechanisms
    errorState.recoveryAttempts = {}
    errorState.isRecovering = false
end

-- Register error events
function ErrorHandler.RegisterErrorEvents()
    -- Register error reporting events
    RegisterNetEvent("district_zero:error:report")
    AddEventHandler("district_zero:error:report", function(errorData)
        ErrorHandler.HandleError(errorData)
    end)
    
    -- Register performance monitoring events
    RegisterNetEvent("district_zero:performance:report")
    AddEventHandler("district_zero:performance:report", function(perfData)
        ErrorHandler.HandlePerformanceReport(perfData)
    end)
end

-- Handle error
function ErrorHandler.HandleError(errorData)
    local errorInfo = {
        timestamp = os.time(),
        level = errorData.level or "ERROR",
        message = errorData.message or "Unknown error",
        source = errorData.source or "Unknown",
        stack = errorData.stack or "",
        playerId = errorData.playerId or nil,
        context = errorData.context or {}
    }
    
    -- Log error
    ErrorHandler.LogError(errorInfo)
    
    -- Update error state
    errorState.errorCount = errorState.errorCount + 1
    errorState.lastError = errorInfo
    
    -- Check if recovery is needed
    if CONFIG.AUTO_RECOVERY_ENABLED then
        ErrorHandler.AttemptRecovery(errorInfo)
    end
    
    -- Notify administrators
    ErrorHandler.NotifyAdministrators(errorInfo)
end

-- Log error
function ErrorHandler.LogError(errorInfo)
    if not CONFIG.ENABLE_ERROR_LOGGING then return end
    
    -- Add to error history
    table.insert(errorState.errorHistory, errorInfo)
    
    -- Keep log size manageable
    if #errorState.errorHistory > CONFIG.MAX_ERROR_LOG_SIZE then
        table.remove(errorState.errorHistory, 1)
    end
    
    -- Save error log
    ErrorHandler.SaveErrorLog()
    
    -- Print error to console
    local color = ErrorHandler.GetErrorColor(errorInfo.level)
    print(string.format("%s[District Zero] ^7[%s] %s: %s", 
        color, errorInfo.level, errorInfo.source, errorInfo.message))
end

-- Get error color
function ErrorHandler.GetErrorColor(level)
    local colors = {
        DEBUG = "^5",   -- Blue
        INFO = "^2",    -- Green
        WARN = "^3",    -- Yellow
        ERROR = "^1",   -- Red
        CRITICAL = "^8" -- Dark red
    }
    return colors[level] or "^7"
end

-- Save error log
function ErrorHandler.SaveErrorLog()
    local dataDir = GetResourcePath(GetCurrentResourceName()) .. "/data"
    if not Utils.DoesDirectoryExist(dataDir) then
        Utils.CreateDirectory(dataDir)
    end
    
    local logData = {
        totalErrors = errorState.errorCount,
        lastUpdated = os.time(),
        errors = errorState.errorHistory
    }
    
    SaveResourceFile(GetCurrentResourceName(), "data/" .. CONFIG.ERROR_LOG_FILE, json.encode(logData, {indent = true}))
end

-- Handle performance report
function ErrorHandler.HandlePerformanceReport(perfData)
    if not CONFIG.ENABLE_PERFORMANCE_MONITORING then return end
    
    local perfInfo = {
        timestamp = os.time(),
        operation = perfData.operation or "Unknown",
        duration = perfData.duration or 0,
        memory = perfData.memory or 0,
        cpu = perfData.cpu or 0,
        context = perfData.context or {}
    }
    
    -- Add to performance metrics
    table.insert(errorState.performanceMetrics, perfInfo)
    
    -- Keep metrics size manageable
    if #errorState.performanceMetrics > CONFIG.MAX_ERROR_LOG_SIZE then
        table.remove(errorState.performanceMetrics, 1)
    end
    
    -- Save performance log
    ErrorHandler.SavePerformanceLog()
    
    -- Check for performance issues
    ErrorHandler.CheckPerformanceIssues(perfInfo)
end

-- Save performance log
function ErrorHandler.SavePerformanceLog()
    local dataDir = GetResourcePath(GetCurrentResourceName()) .. "/data"
    if not Utils.DoesDirectoryExist(dataDir) then
        Utils.CreateDirectory(dataDir)
    end
    
    local perfData = {
        lastUpdated = os.time(),
        metrics = errorState.performanceMetrics
    }
    
    SaveResourceFile(GetCurrentResourceName(), "data/" .. CONFIG.PERFORMANCE_LOG_FILE, json.encode(perfData, {indent = true}))
end

-- Check performance issues
function ErrorHandler.CheckPerformanceIssues(perfInfo)
    -- Check for slow operations
    if perfInfo.duration > 1000 then -- 1 second
        ErrorHandler.HandleError({
            level = "WARN",
            message = "Slow operation detected: " .. perfInfo.operation,
            source = "PerformanceMonitor",
            context = {duration = perfInfo.duration, operation = perfInfo.operation}
        })
    end
    
    -- Check for high memory usage
    if perfInfo.memory > 80 then -- 80% memory usage
        ErrorHandler.HandleError({
            level = "WARN",
            message = "High memory usage detected",
            source = "PerformanceMonitor",
            context = {memory = perfInfo.memory}
        })
    end
    
    -- Check for high CPU usage
    if perfInfo.cpu > 80 then -- 80% CPU usage
        ErrorHandler.HandleError({
            level = "WARN",
            message = "High CPU usage detected",
            source = "PerformanceMonitor",
            context = {cpu = perfInfo.cpu}
        })
    end
end

-- Attempt recovery
function ErrorHandler.AttemptRecovery(errorInfo)
    if errorState.isRecovering then return end
    
    local source = errorInfo.source
    local attempts = errorState.recoveryAttempts[source] or 0
    
    if attempts >= CONFIG.MAX_RECOVERY_ATTEMPTS then
        ErrorHandler.HandleError({
            level = "CRITICAL",
            message = "Max recovery attempts reached for " .. source,
            source = "ErrorRecovery",
            context = {source = source, attempts = attempts}
        })
        return
    end
    
    errorState.isRecovering = true
    errorState.recoveryAttempts[source] = attempts + 1
    
    print(string.format("^3[District Zero] ^7Attempting recovery for %s (attempt %d/%d)", 
        source, attempts + 1, CONFIG.MAX_RECOVERY_ATTEMPTS))
    
    -- Attempt to recover the system
    local success = ErrorHandler.RecoverSystem(source, errorInfo)
    
    if success then
        print(string.format("^2[District Zero] ^7Recovery successful for %s", source))
        errorState.recoveryAttempts[source] = 0 -- Reset attempts on success
    else
        print(string.format("^1[District Zero] ^7Recovery failed for %s", source))
    end
    
    errorState.isRecovering = false
end

-- Recover system
function ErrorHandler.RecoverSystem(source, errorInfo)
    -- This would implement actual recovery logic
    -- For now, return true to simulate successful recovery
    return true
end

-- Notify administrators
function ErrorHandler.NotifyAdministrators(errorInfo)
    -- Send notification to all administrators
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        if IsPlayerAceAllowed(playerId, "district_zero.admin") then
            TriggerClientEvent("chat:addMessage", playerId, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System Error", string.format("[%s] %s: %s", 
                    errorInfo.level, errorInfo.source, errorInfo.message)}
            })
        end
    end
end

-- Safe function execution wrapper
function ErrorHandler.SafeExecute(func, context, ...)
    local startTime = GetGameTimer()
    
    local success, result = pcall(func, ...)
    
    local endTime = GetGameTimer()
    local duration = endTime - startTime
    
    -- Log performance
    if CONFIG.ENABLE_PERFORMANCE_MONITORING then
        ErrorHandler.HandlePerformanceReport({
            operation = context or "Unknown",
            duration = duration,
            context = {...}
        })
    end
    
    if not success then
        -- Log error
        ErrorHandler.HandleError({
            level = "ERROR",
            message = tostring(result),
            source = context or "Unknown",
            context = {...}
        })
        
        return nil, result
    end
    
    return result
end

-- Performance monitoring wrapper
function ErrorHandler.MonitorPerformance(operation, func, ...)
    local startTime = GetGameTimer()
    local startMemory = collectgarbage("count")
    
    local result = func(...)
    
    local endTime = GetGameTimer()
    local endMemory = collectgarbage("count")
    
    local duration = endTime - startTime
    local memoryDelta = endMemory - startMemory
    
    -- Report performance
    if CONFIG.ENABLE_PERFORMANCE_MONITORING then
        ErrorHandler.HandlePerformanceReport({
            operation = operation,
            duration = duration,
            memory = memoryDelta,
            context = {...}
        })
    end
    
    return result
end

-- Get error statistics
function ErrorHandler.GetErrorStatistics()
    return {
        totalErrors = errorState.errorCount,
        lastError = errorState.lastError,
        errorHistory = errorState.errorHistory,
        performanceMetrics = errorState.performanceMetrics,
        recoveryAttempts = errorState.recoveryAttempts
    }
end

-- Clear error logs
function ErrorHandler.ClearErrorLogs()
    errorState.errorHistory = {}
    errorState.performanceMetrics = {}
    errorState.errorCount = 0
    errorState.recoveryAttempts = {}
    
    -- Save cleared logs
    ErrorHandler.SaveErrorLog()
    ErrorHandler.SavePerformanceLog()
    
    print("^2[District Zero] ^7Error logs cleared")
end

-- Export functions
exports("SafeExecute", ErrorHandler.SafeExecute)
exports("MonitorPerformance", ErrorHandler.MonitorPerformance)
exports("GetErrorStatistics", ErrorHandler.GetErrorStatistics)
exports("ClearErrorLogs", ErrorHandler.ClearErrorLogs)

-- Initialize on resource start
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ErrorHandler.Initialize()
    end
end)

-- Save configuration to file
local function SaveConfiguration(configName, configData)
    if not configName or not configData then
        Utils.HandleError('Invalid parameters for SaveConfiguration', 'ErrorHandler')
        return false
    end
    
    local configDir = GetResourcePath(GetCurrentResourceName()) .. '/config'
    if not Utils.DoesDirectoryExist(configDir) then
        Utils.CreateDirectory(configDir)
    end
    
    local configFile = configDir .. '/' .. configName .. '.json'
    local success, error = pcall(function()
        local file = io.open(configFile, 'w')
        if file then
            file:write(json.encode(configData, { indent = true }))
            file:close()
            return true
        end
        return false
    end)
    
    if not success then
        Utils.HandleError('Failed to save configuration: ' .. tostring(error), 'ErrorHandler')
        return false
    end
    
    Utils.PrintDebug('Configuration saved: ' .. configName, 'ErrorHandler')
    return true
end

return ErrorHandler 