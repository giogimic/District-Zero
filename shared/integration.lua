-- District Zero Integration System
-- Version: 1.0.0

local IntegrationSystem = {
    -- System Registry
    systems = {},
    
    -- Event Bus
    eventBus = {},
    
    -- State Management
    globalState = {},
    
    -- Integration Hooks
    hooks = {},
    
    -- Performance Monitoring
    performanceMetrics = {},
    
    -- Error Handling
    errorHandlers = {},
    
    -- System Dependencies
    dependencies = {
        config = 'Config',
        performance = 'PerformanceSystem',
        database = 'DatabaseManager',
        security = 'SecuritySystem',
        missions = 'AdvancedMissionSystem',
        events = 'DynamicEventsSystem',
        teams = 'AdvancedTeamSystem',
        achievements = 'AchievementSystem',
        analytics = 'AnalyticsSystem'
    }
}

-- System Registration
local function RegisterSystem(name, system)
    if not name or not system then
        print('^1[District Zero] ^7Error: Invalid system registration - name and system required')
        return false
    end
    
    IntegrationSystem.systems[name] = {
        instance = system,
        registered = GetGameTimer(),
        status = 'active',
        dependencies = {},
        hooks = {}
    }
    
    print('^2[District Zero] ^7System registered: ' .. name)
    return true
end

-- System Dependency Management
local function RegisterDependency(systemName, dependencyName, dependency)
    if not IntegrationSystem.systems[systemName] then
        print('^1[District Zero] ^7Error: System not found for dependency registration: ' .. systemName)
        return false
    end
    
    IntegrationSystem.systems[systemName].dependencies[dependencyName] = {
        instance = dependency,
        registered = GetGameTimer(),
        status = 'active'
    }
    
    print('^2[District Zero] ^7Dependency registered: ' .. systemName .. ' -> ' .. dependencyName)
    return true
end

-- Event Bus Management
local function RegisterEvent(eventName, handler, priority)
    if not eventName or not handler then
        print('^1[District Zero] ^7Error: Invalid event registration - event name and handler required')
        return false
    end
    
    if not IntegrationSystem.eventBus[eventName] then
        IntegrationSystem.eventBus[eventName] = {}
    end
    
    table.insert(IntegrationSystem.eventBus[eventName], {
        handler = handler,
        priority = priority or 0,
        registered = GetGameTimer()
    })
    
    -- Sort by priority (higher priority first)
    table.sort(IntegrationSystem.eventBus[eventName], function(a, b)
        return a.priority > b.priority
    end)
    
    print('^2[District Zero] ^7Event registered: ' .. eventName .. ' (priority: ' .. (priority or 0) .. ')')
    return true
end

local function EmitEvent(eventName, data, source)
    if not IntegrationSystem.eventBus[eventName] then
        return false
    end
    
    local eventData = {
        name = eventName,
        data = data,
        source = source,
        timestamp = GetGameTimer(),
        processed = false
    }
    
    local success = true
    local errors = {}
    
    for _, eventHandler in ipairs(IntegrationSystem.eventBus[eventName]) do
        local success, error = pcall(eventHandler.handler, eventData)
        if not success then
            table.insert(errors, {
                handler = eventHandler,
                error = error
            })
            success = false
        end
    end
    
    if #errors > 0 then
        print('^1[District Zero] ^7Event processing errors for ' .. eventName .. ':')
        for _, error in ipairs(errors) do
            print('  - Handler error: ' .. tostring(error.error))
        end
    end
    
    return success
end

-- State Management
local function SetGlobalState(key, value, source)
    if not key then
        print('^1[District Zero] ^7Error: Invalid state key')
        return false
    end
    
    local oldValue = IntegrationSystem.globalState[key]
    IntegrationSystem.globalState[key] = {
        value = value,
        source = source,
        timestamp = GetGameTimer(),
        previous = oldValue
    }
    
    -- Emit state change event
    EmitEvent('state_changed', {
        key = key,
        value = value,
        previous = oldValue,
        source = source
    }, 'IntegrationSystem')
    
    return true
end

local function GetGlobalState(key)
    if not key then
        return nil
    end
    
    local state = IntegrationSystem.globalState[key]
    return state and state.value or nil
end

local function GetGlobalStateHistory(key)
    if not key then
        return nil
    end
    
    local state = IntegrationSystem.globalState[key]
    return state and state.previous or nil
end

-- Hook System
local function RegisterHook(hookName, callback, priority)
    if not hookName or not callback then
        print('^1[District Zero] ^7Error: Invalid hook registration - hook name and callback required')
        return false
    end
    
    if not IntegrationSystem.hooks[hookName] then
        IntegrationSystem.hooks[hookName] = {}
    end
    
    table.insert(IntegrationSystem.hooks[hookName], {
        callback = callback,
        priority = priority or 0,
        registered = GetGameTimer()
    })
    
    -- Sort by priority (higher priority first)
    table.sort(IntegrationSystem.hooks[hookName], function(a, b)
        return a.priority > b.priority
    end)
    
    print('^2[District Zero] ^7Hook registered: ' .. hookName .. ' (priority: ' .. (priority or 0) .. ')')
    return true
end

local function ExecuteHook(hookName, data)
    if not IntegrationSystem.hooks[hookName] then
        return data
    end
    
    local result = data
    
    for _, hook in ipairs(IntegrationSystem.hooks[hookName]) do
        local success, hookResult = pcall(hook.callback, result)
        if success and hookResult ~= nil then
            result = hookResult
        elseif not success then
            print('^1[District Zero] ^7Hook execution error for ' .. hookName .. ': ' .. tostring(hookResult))
        end
    end
    
    return result
end

-- Performance Monitoring
local function StartPerformanceTimer(name)
    if not name then
        return nil
    end
    
    local timerId = name .. '_' .. GetGameTimer()
    IntegrationSystem.performanceMetrics[timerId] = {
        name = name,
        startTime = GetGameTimer(),
        endTime = nil,
        duration = nil
    }
    
    return timerId
end

local function EndPerformanceTimer(timerId)
    if not timerId or not IntegrationSystem.performanceMetrics[timerId] then
        return nil
    end
    
    local timer = IntegrationSystem.performanceMetrics[timerId]
    timer.endTime = GetGameTimer()
    timer.duration = timer.endTime - timer.startTime
    
    return timer.duration
end

local function GetPerformanceMetrics()
    local metrics = {}
    local totalDuration = 0
    local count = 0
    
    for timerId, timer in pairs(IntegrationSystem.performanceMetrics) do
        if timer.duration then
            if not metrics[timer.name] then
                metrics[timer.name] = {
                    totalDuration = 0,
                    count = 0,
                    averageDuration = 0,
                    minDuration = math.huge,
                    maxDuration = 0
                }
            end
            
            local metric = metrics[timer.name]
            metric.totalDuration = metric.totalDuration + timer.duration
            metric.count = metric.count + 1
            metric.minDuration = math.min(metric.minDuration, timer.duration)
            metric.maxDuration = math.max(metric.maxDuration, timer.duration)
            
            totalDuration = totalDuration + timer.duration
            count = count + 1
        end
    end
    
    -- Calculate averages
    for name, metric in pairs(metrics) do
        metric.averageDuration = metric.totalDuration / metric.count
    end
    
    return {
        metrics = metrics,
        totalDuration = totalDuration,
        totalCount = count,
        averageDuration = count > 0 and totalDuration / count or 0
    }
end

-- Error Handling
local function RegisterErrorHandler(errorType, handler)
    if not errorType or not handler then
        print('^1[District Zero] ^7Error: Invalid error handler registration')
        return false
    end
    
    IntegrationSystem.errorHandlers[errorType] = handler
    print('^2[District Zero] ^7Error handler registered: ' .. errorType)
    return true
end

local function HandleError(errorType, error, context)
    local handler = IntegrationSystem.errorHandlers[errorType]
    if handler then
        local success, result = pcall(handler, error, context)
        if not success then
            print('^1[District Zero] ^7Error handler failed: ' .. tostring(result))
        end
        return result
    else
        print('^1[District Zero] ^7No error handler for: ' .. errorType .. ' - ' .. tostring(error))
        return false
    end
end

-- System Health Check
local function GetSystemHealth()
    local health = {
        systems = {},
        eventBus = {},
        hooks = {},
        performance = {},
        errors = 0,
        overall = 'healthy'
    }
    
    -- Check systems
    for name, system in pairs(IntegrationSystem.systems) do
        health.systems[name] = {
            status = system.status,
            uptime = GetGameTimer() - system.registered,
            dependencies = #system.dependencies
        }
    end
    
    -- Check event bus
    for eventName, handlers in pairs(IntegrationSystem.eventBus) do
        health.eventBus[eventName] = {
            handlers = #handlers,
            lastEmitted = 0 -- Would need to track this
        }
    end
    
    -- Check hooks
    for hookName, hooks in pairs(IntegrationSystem.hooks) do
        health.hooks[hookName] = {
            hooks = #hooks
        }
    end
    
    -- Check performance
    local perfMetrics = GetPerformanceMetrics()
    health.performance = {
        totalTimers = perfMetrics.totalCount,
        averageDuration = perfMetrics.averageDuration
    }
    
    return health
end

-- Integration System Methods
IntegrationSystem.RegisterSystem = RegisterSystem
IntegrationSystem.RegisterDependency = RegisterDependency
IntegrationSystem.RegisterEvent = RegisterEvent
IntegrationSystem.EmitEvent = EmitEvent
IntegrationSystem.SetGlobalState = SetGlobalState
IntegrationSystem.GetGlobalState = GetGlobalState
IntegrationSystem.GetGlobalStateHistory = GetGlobalStateHistory
IntegrationSystem.RegisterHook = RegisterHook
IntegrationSystem.ExecuteHook = ExecuteHook
IntegrationSystem.StartPerformanceTimer = StartPerformanceTimer
IntegrationSystem.EndPerformanceTimer = EndPerformanceTimer
IntegrationSystem.GetPerformanceMetrics = GetPerformanceMetrics
IntegrationSystem.RegisterErrorHandler = RegisterErrorHandler
IntegrationSystem.HandleError = HandleError
IntegrationSystem.GetSystemHealth = GetSystemHealth

-- Default Error Handlers
RegisterErrorHandler('system_error', function(error, context)
    print('^1[District Zero] ^7System Error: ' .. tostring(error))
    if context then
        print('^3[District Zero] ^7Context: ' .. tostring(context))
    end
    return false
end)

RegisterErrorHandler('performance_error', function(error, context)
    print('^1[District Zero] ^7Performance Error: ' .. tostring(error))
    if context then
        print('^3[District Zero] ^7Context: ' .. tostring(context))
    end
    return false
end)

-- Default Events
RegisterEvent('system_startup', function(data)
    print('^2[District Zero] ^7System startup event processed')
    SetGlobalState('system_status', 'running', 'IntegrationSystem')
end, 100)

RegisterEvent('system_shutdown', function(data)
    print('^3[District Zero] ^7System shutdown event processed')
    SetGlobalState('system_status', 'shutdown', 'IntegrationSystem')
end, 100)

-- Initialize integration system
print('^2[District Zero] ^7Integration system initialized')

-- Exports
exports('RegisterSystem', RegisterSystem)
exports('RegisterDependency', RegisterDependency)
exports('RegisterEvent', RegisterEvent)
exports('EmitEvent', EmitEvent)
exports('SetGlobalState', SetGlobalState)
exports('GetGlobalState', GetGlobalState)
exports('GetGlobalStateHistory', GetGlobalStateHistory)
exports('RegisterHook', RegisterHook)
exports('ExecuteHook', ExecuteHook)
exports('StartPerformanceTimer', StartPerformanceTimer)
exports('EndPerformanceTimer', EndPerformanceTimer)
exports('GetPerformanceMetrics', GetPerformanceMetrics)
exports('RegisterErrorHandler', RegisterErrorHandler)
exports('HandleError', HandleError)
exports('GetSystemHealth', GetSystemHealth)

return IntegrationSystem 