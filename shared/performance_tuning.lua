-- District Zero Performance Tuning System
-- Version: 1.0.0

local PerformanceTuning = {
    -- Performance Monitoring
    performanceMonitoring = {},
    
    -- Optimization Engine
    optimizationEngine = {},
    
    -- Cache Management
    cacheManagement = {},
    
    -- Resource Management
    resourceManagement = {},
    
    -- Query Optimization
    queryOptimization = {},
    
    -- Memory Management
    memoryManagement = {},
    
    -- Network Optimization
    networkOptimization = {},
    
    -- Load Balancing
    loadBalancing = {},
    
    -- Auto-Scaling
    autoScaling = {},
    
    -- Performance Metrics
    performanceMetrics = {},
    
    -- Optimization Rules
    optimizationRules = {},
    
    -- Performance Alerts
    performanceAlerts = {}
}

-- Performance Monitoring
local function RegisterPerformanceMonitor(name, monitor)
    if not name or not monitor then
        print('^1[District Zero] ^7Error: Invalid performance monitor registration')
        return false
    end
    
    PerformanceTuning.performanceMonitoring[name] = {
        instance = monitor,
        enabled = true,
        registered = GetGameTimer(),
        metrics = {},
        alerts = 0,
        lastAlert = 0
    }
    
    print('^2[District Zero] ^7Performance monitor registered: ' .. name)
    return true
end

local function MonitorPerformance(name, data)
    if PerformanceTuning.performanceMonitoring[name] and PerformanceTuning.performanceMonitoring[name].enabled then
        local monitor = PerformanceTuning.performanceMonitoring[name]
        
        local success, metrics = pcall(monitor.instance.monitor, data)
        if success and metrics then
            table.insert(monitor.metrics, {
                metrics = metrics,
                timestamp = GetGameTimer(),
                data = data
            })
            
            -- Keep only last 1000 metrics
            if #monitor.metrics > 1000 then
                table.remove(monitor.metrics, 1)
            end
            
            -- Check for performance alerts
            if monitor.instance.checkAlert and monitor.instance.checkAlert(metrics) then
                monitor.alerts = monitor.alerts + 1
                monitor.lastAlert = GetGameTimer()
                
                -- Trigger performance alert
                TriggerPerformanceAlert(name, metrics)
            end
            
            return metrics
        end
    end
    return nil
end

-- Optimization Engine
local function RegisterOptimizationRule(name, rule)
    if not name or not rule then
        print('^1[District Zero] ^7Error: Invalid optimization rule registration')
        return false
    end
    
    PerformanceTuning.optimizationRules[name] = {
        instance = rule,
        enabled = true,
        registered = GetGameTimer(),
        applications = 0,
        improvements = 0,
        lastApplied = 0
    }
    
    print('^2[District Zero] ^7Optimization rule registered: ' .. name)
    return true
end

local function ApplyOptimization(name, data)
    if PerformanceTuning.optimizationRules[name] and PerformanceTuning.optimizationRules[name].enabled then
        local rule = PerformanceTuning.optimizationRules[name]
        
        local success, result = pcall(rule.instance.optimize, data)
        if success and result then
            rule.applications = rule.applications + 1
            rule.lastApplied = GetGameTimer()
            
            if result.improvement then
                rule.improvements = rule.improvements + 1
                print('^2[District Zero] ^7Optimization applied: ' .. name .. ' - Improvement: ' .. result.improvement .. '%')
            end
            
            return result
        end
    end
    return nil
end

-- Cache Management
local function RegisterCache(name, cache)
    if not name or not cache then
        print('^1[District Zero] ^7Error: Invalid cache registration')
        return false
    end
    
    PerformanceTuning.cacheManagement[name] = {
        instance = cache,
        enabled = true,
        registered = GetGameTimer(),
        hits = 0,
        misses = 0,
        size = 0,
        maxSize = cache.maxSize or 1000
    }
    
    print('^2[District Zero] ^7Cache registered: ' .. name)
    return true
end

local function GetCachedData(name, key)
    if PerformanceTuning.cacheManagement[name] and PerformanceTuning.cacheManagement[name].enabled then
        local cache = PerformanceTuning.cacheManagement[name]
        
        local success, data = pcall(cache.instance.get, key)
        if success and data then
            cache.hits = cache.hits + 1
            return data
        else
            cache.misses = cache.misses + 1
            return nil
        end
    end
    return nil
end

local function SetCachedData(name, key, data, ttl)
    if PerformanceTuning.cacheManagement[name] and PerformanceTuning.cacheManagement[name].enabled then
        local cache = PerformanceTuning.cacheManagement[name]
        
        -- Check cache size
        if cache.size >= cache.maxSize then
            -- Evict oldest entry
            cache.instance.evict()
            cache.size = cache.size - 1
        end
        
        local success, result = pcall(cache.instance.set, key, data, ttl)
        if success and result then
            cache.size = cache.size + 1
            return true
        end
    end
    return false
end

-- Resource Management
local function RegisterResourceManager(name, manager)
    if not name or not manager then
        print('^1[District Zero] ^7Error: Invalid resource manager registration')
        return false
    end
    
    PerformanceTuning.resourceManagement[name] = {
        instance = manager,
        enabled = true,
        registered = GetGameTimer(),
        resources = {},
        usage = 0,
        limit = manager.limit or 100
    }
    
    print('^2[District Zero] ^7Resource manager registered: ' .. name)
    return true
end

local function AllocateResource(name, resourceType, amount)
    if PerformanceTuning.resourceManagement[name] and PerformanceTuning.resourceManagement[name].enabled then
        local manager = PerformanceTuning.resourceManagement[name]
        
        local success, result = pcall(manager.instance.allocate, resourceType, amount)
        if success and result then
            manager.usage = manager.usage + amount
            table.insert(manager.resources, {
                type = resourceType,
                amount = amount,
                allocated = GetGameTimer()
            })
            
            return result
        end
    end
    return nil
end

local function ReleaseResource(name, resourceId)
    if PerformanceTuning.resourceManagement[name] and PerformanceTuning.resourceManagement[name].enabled then
        local manager = PerformanceTuning.resourceManagement[name]
        
        local success, result = pcall(manager.instance.release, resourceId)
        if success and result then
            manager.usage = manager.usage - result.amount
            
            -- Remove from resources list
            for i, resource in ipairs(manager.resources) do
                if resource.id == resourceId then
                    table.remove(manager.resources, i)
                    break
                end
            end
            
            return result
        end
    end
    return nil
end

-- Query Optimization
local function RegisterQueryOptimizer(name, optimizer)
    if not name or not optimizer then
        print('^1[District Zero] ^7Error: Invalid query optimizer registration')
        return false
    end
    
    PerformanceTuning.queryOptimization[name] = {
        instance = optimizer,
        enabled = true,
        registered = GetGameTimer(),
        optimizations = 0,
        improvements = 0
    }
    
    print('^2[District Zero] ^7Query optimizer registered: ' .. name)
    return true
end

local function OptimizeQuery(name, query)
    if PerformanceTuning.queryOptimization[name] and PerformanceTuning.queryOptimization[name].enabled then
        local optimizer = PerformanceTuning.queryOptimization[name]
        
        local success, result = pcall(optimizer.instance.optimize, query)
        if success and result then
            optimizer.optimizations = optimizer.optimizations + 1
            
            if result.improvement then
                optimizer.improvements = optimizer.improvements + 1
                print('^2[District Zero] ^7Query optimized: ' .. name .. ' - Improvement: ' .. result.improvement .. '%')
            end
            
            return result.optimizedQuery
        end
    end
    return query -- Return original query if optimization fails
end

-- Memory Management
local function RegisterMemoryManager(name, manager)
    if not name or not manager then
        print('^1[District Zero] ^7Error: Invalid memory manager registration')
        return false
    end
    
    PerformanceTuning.memoryManagement[name] = {
        instance = manager,
        enabled = true,
        registered = GetGameTimer(),
        allocations = 0,
        deallocations = 0,
        currentUsage = 0
    }
    
    print('^2[District Zero] ^7Memory manager registered: ' .. name)
    return true
end

local function AllocateMemory(name, size)
    if PerformanceTuning.memoryManagement[name] and PerformanceTuning.memoryManagement[name].enabled then
        local manager = PerformanceTuning.memoryManagement[name]
        
        local success, result = pcall(manager.instance.allocate, size)
        if success and result then
            manager.allocations = manager.allocations + 1
            manager.currentUsage = manager.currentUsage + size
            
            return result
        end
    end
    return nil
end

local function DeallocateMemory(name, memoryId)
    if PerformanceTuning.memoryManagement[name] and PerformanceTuning.memoryManagement[name].enabled then
        local manager = PerformanceTuning.memoryManagement[name]
        
        local success, result = pcall(manager.instance.deallocate, memoryId)
        if success and result then
            manager.deallocations = manager.deallocations + 1
            manager.currentUsage = manager.currentUsage - result.size
            
            return result
        end
    end
    return nil
end

-- Network Optimization
local function RegisterNetworkOptimizer(name, optimizer)
    if not name or not optimizer then
        print('^1[District Zero] ^7Error: Invalid network optimizer registration')
        return false
    end
    
    PerformanceTuning.networkOptimization[name] = {
        instance = optimizer,
        enabled = true,
        registered = GetGameTimer(),
        optimizations = 0,
        bandwidthSaved = 0
    }
    
    print('^2[District Zero] ^7Network optimizer registered: ' .. name)
    return true
end

local function OptimizeNetwork(name, data)
    if PerformanceTuning.networkOptimization[name] and PerformanceTuning.networkOptimization[name].enabled then
        local optimizer = PerformanceTuning.networkOptimization[name]
        
        local success, result = pcall(optimizer.instance.optimize, data)
        if success and result then
            optimizer.optimizations = optimizer.optimizations + 1
            
            if result.bandwidthSaved then
                optimizer.bandwidthSaved = optimizer.bandwidthSaved + result.bandwidthSaved
            end
            
            return result.optimizedData
        end
    end
    return data -- Return original data if optimization fails
end

-- Load Balancing
local function RegisterLoadBalancer(name, balancer)
    if not name or not balancer then
        print('^1[District Zero] ^7Error: Invalid load balancer registration')
        return false
    end
    
    PerformanceTuning.loadBalancing[name] = {
        instance = balancer,
        enabled = true,
        registered = GetGameTimer(),
        requests = 0,
        distributions = 0
    }
    
    print('^2[District Zero] ^7Load balancer registered: ' .. name)
    return true
end

local function DistributeLoad(name, request)
    if PerformanceTuning.loadBalancing[name] and PerformanceTuning.loadBalancing[name].enabled then
        local balancer = PerformanceTuning.loadBalancing[name]
        
        local success, result = pcall(balancer.instance.distribute, request)
        if success and result then
            balancer.requests = balancer.requests + 1
            balancer.distributions = balancer.distributions + 1
            
            return result
        end
    end
    return nil
end

-- Auto-Scaling
local function RegisterAutoScaler(name, scaler)
    if not name or not scaler then
        print('^1[District Zero] ^7Error: Invalid auto-scaler registration')
        return false
    end
    
    PerformanceTuning.autoScaling[name] = {
        instance = scaler,
        enabled = true,
        registered = GetGameTimer(),
        scalingEvents = 0,
        currentScale = 1
    }
    
    print('^2[District Zero] ^7Auto-scaler registered: ' .. name)
    return true
end

local function CheckAutoScaling(name, metrics)
    if PerformanceTuning.autoScaling[name] and PerformanceTuning.autoScaling[name].enabled then
        local scaler = PerformanceTuning.autoScaling[name]
        
        local success, result = pcall(scaler.instance.check, metrics)
        if success and result then
            if result.scale then
                scaler.scalingEvents = scaler.scalingEvents + 1
                scaler.currentScale = result.scale
                
                print('^2[District Zero] ^7Auto-scaling applied: ' .. name .. ' - Scale: ' .. result.scale)
            end
            
            return result
        end
    end
    return nil
end

-- Performance Metrics
local function GetPerformanceMetrics()
    local metrics = {
        monitoring = {},
        optimization = {},
        cache = {},
        resources = {},
        queries = {},
        memory = {},
        network = {},
        loadBalancing = {},
        autoScaling = {},
        overall = {
            totalOptimizations = 0,
            totalImprovements = 0,
            averagePerformance = 0
        }
    }
    
    -- Collect monitoring metrics
    for name, monitor in pairs(PerformanceTuning.performanceMonitoring) do
        metrics.monitoring[name] = {
            alerts = monitor.alerts,
            lastAlert = monitor.lastAlert
        }
    end
    
    -- Collect optimization metrics
    for name, rule in pairs(PerformanceTuning.optimizationRules) do
        metrics.optimization[name] = {
            applications = rule.applications,
            improvements = rule.improvements
        }
        metrics.overall.totalOptimizations = metrics.overall.totalOptimizations + rule.applications
        metrics.overall.totalImprovements = metrics.overall.totalImprovements + rule.improvements
    end
    
    -- Collect cache metrics
    for name, cache in pairs(PerformanceTuning.cacheManagement) do
        metrics.cache[name] = {
            hits = cache.hits,
            misses = cache.misses,
            hitRate = cache.hits > 0 and (cache.hits / (cache.hits + cache.misses)) * 100 or 0
        }
    end
    
    -- Collect resource metrics
    for name, manager in pairs(PerformanceTuning.resourceManagement) do
        metrics.resources[name] = {
            usage = manager.usage,
            limit = manager.limit,
            utilization = (manager.usage / manager.limit) * 100
        }
    end
    
    -- Collect query metrics
    for name, optimizer in pairs(PerformanceTuning.queryOptimization) do
        metrics.queries[name] = {
            optimizations = optimizer.optimizations,
            improvements = optimizer.improvements
        }
    end
    
    -- Collect memory metrics
    for name, manager in pairs(PerformanceTuning.memoryManagement) do
        metrics.memory[name] = {
            currentUsage = manager.currentUsage,
            allocations = manager.allocations,
            deallocations = manager.deallocations
        }
    end
    
    -- Collect network metrics
    for name, optimizer in pairs(PerformanceTuning.networkOptimization) do
        metrics.network[name] = {
            optimizations = optimizer.optimizations,
            bandwidthSaved = optimizer.bandwidthSaved
        }
    end
    
    -- Collect load balancing metrics
    for name, balancer in pairs(PerformanceTuning.loadBalancing) do
        metrics.loadBalancing[name] = {
            requests = balancer.requests,
            distributions = balancer.distributions
        }
    end
    
    -- Collect auto-scaling metrics
    for name, scaler in pairs(PerformanceTuning.autoScaling) do
        metrics.autoScaling[name] = {
            scalingEvents = scaler.scalingEvents,
            currentScale = scaler.currentScale
        }
    end
    
    -- Calculate overall performance
    if metrics.overall.totalOptimizations > 0 then
        metrics.overall.averagePerformance = (metrics.overall.totalImprovements / metrics.overall.totalOptimizations) * 100
    end
    
    return metrics
end

-- Performance Alerts
local function TriggerPerformanceAlert(monitorName, metrics)
    local alert = {
        monitor = monitorName,
        metrics = metrics,
        timestamp = GetGameTimer(),
        severity = 'warning'
    }
    
    -- Determine severity based on metrics
    if metrics.cpuUsage and metrics.cpuUsage > 90 then
        alert.severity = 'critical'
    elseif metrics.memoryUsage and metrics.memoryUsage > 80 then
        alert.severity = 'high'
    end
    
    print('^1[District Zero] ^7Performance Alert: ' .. monitorName .. ' - ' .. alert.severity)
    
    -- Store alert
    table.insert(PerformanceTuning.performanceAlerts, alert)
    
    -- Keep only last 100 alerts
    if #PerformanceTuning.performanceAlerts > 100 then
        table.remove(PerformanceTuning.performanceAlerts, 1)
    end
end

-- Performance Tuning Methods
PerformanceTuning.RegisterPerformanceMonitor = RegisterPerformanceMonitor
PerformanceTuning.MonitorPerformance = MonitorPerformance
PerformanceTuning.RegisterOptimizationRule = RegisterOptimizationRule
PerformanceTuning.ApplyOptimization = ApplyOptimization
PerformanceTuning.RegisterCache = RegisterCache
PerformanceTuning.GetCachedData = GetCachedData
PerformanceTuning.SetCachedData = SetCachedData
PerformanceTuning.RegisterResourceManager = RegisterResourceManager
PerformanceTuning.AllocateResource = AllocateResource
PerformanceTuning.ReleaseResource = ReleaseResource
PerformanceTuning.RegisterQueryOptimizer = RegisterQueryOptimizer
PerformanceTuning.OptimizeQuery = OptimizeQuery
PerformanceTuning.RegisterMemoryManager = RegisterMemoryManager
PerformanceTuning.AllocateMemory = AllocateMemory
PerformanceTuning.DeallocateMemory = DeallocateMemory
PerformanceTuning.RegisterNetworkOptimizer = RegisterNetworkOptimizer
PerformanceTuning.OptimizeNetwork = OptimizeNetwork
PerformanceTuning.RegisterLoadBalancer = RegisterLoadBalancer
PerformanceTuning.DistributeLoad = DistributeLoad
PerformanceTuning.RegisterAutoScaler = RegisterAutoScaler
PerformanceTuning.CheckAutoScaling = CheckAutoScaling
PerformanceTuning.GetPerformanceMetrics = GetPerformanceMetrics
PerformanceTuning.TriggerPerformanceAlert = TriggerPerformanceAlert

-- Default Performance Features
RegisterPerformanceMonitor('system_performance', {
    monitor = function(data)
        return {
            cpuUsage = data.cpu or 0,
            memoryUsage = data.memory or 0,
            networkLatency = data.latency or 0,
            responseTime = data.responseTime or 0
        }
    end,
    checkAlert = function(metrics)
        return (metrics.cpuUsage and metrics.cpuUsage > 80) or
               (metrics.memoryUsage and metrics.memoryUsage > 75) or
               (metrics.responseTime and metrics.responseTime > 1000)
    end
})

RegisterOptimizationRule('query_optimization', {
    optimize = function(data)
        -- Optimize database queries
        local optimization = {
            improvement = 0,
            optimized = false
        }
        
        if data.query and string.find(data.query, "SELECT %*") then
            optimization.improvement = 15
            optimization.optimized = true
        end
        
        return optimization
    end
})

RegisterCache('mission_cache', {
    maxSize = 1000,
    get = function(key)
        -- Get cached mission data
        return nil -- Implementation would access actual cache
    end,
    set = function(key, data, ttl)
        -- Set cached mission data
        return true -- Implementation would store in actual cache
    end,
    evict = function()
        -- Evict oldest cache entry
        return true
    end
})

RegisterResourceManager('mission_resources', {
    limit = 100,
    allocate = function(resourceType, amount)
        -- Allocate mission resources
        return {
            id = GetGameTimer(),
            type = resourceType,
            amount = amount
        }
    end,
    release = function(resourceId)
        -- Release mission resources
        return {
            id = resourceId,
            amount = 10 -- Example amount
        }
    end
})

RegisterQueryOptimizer('mission_queries', {
    optimize = function(query)
        -- Optimize mission-related queries
        local optimization = {
            improvement = 0,
            optimizedQuery = query
        }
        
        if string.find(query, "SELECT %* FROM missions") then
            optimization.improvement = 20
            optimization.optimizedQuery = string.gsub(query, "SELECT %*", "SELECT id, title, description")
        end
        
        return optimization
    end
})

RegisterMemoryManager('mission_memory', {
    allocate = function(size)
        -- Allocate memory for mission data
        return {
            id = GetGameTimer(),
            size = size
        }
    end,
    deallocate = function(memoryId)
        -- Deallocate memory
        return {
            id = memoryId,
            size = 100 -- Example size
        }
    end
})

RegisterNetworkOptimizer('mission_network', {
    optimize = function(data)
        -- Optimize network data for missions
        local optimization = {
            bandwidthSaved = 0,
            optimizedData = data
        }
        
        if data.missions and #data.missions > 10 then
            optimization.bandwidthSaved = 25
            -- Remove unnecessary fields for network transmission
            optimization.optimizedData = {
                missions = data.missions,
                count = #data.missions
            }
        end
        
        return optimization
    end
})

RegisterLoadBalancer('mission_balancer', {
    distribute = function(request)
        -- Distribute mission requests across servers
        return {
            server = 'server_' .. math.random(1, 3),
            request = request
        }
    end
})

RegisterAutoScaler('mission_scaler', {
    check = function(metrics)
        -- Check if auto-scaling is needed
        local scale = 1
        
        if metrics.load and metrics.load > 80 then
            scale = 2
        elseif metrics.load and metrics.load > 60 then
            scale = 1.5
        end
        
        return {
            scale = scale,
            reason = 'load_based'
        }
    end
})

print('^2[District Zero] ^7Performance tuning system initialized')

-- Exports
exports('RegisterPerformanceMonitor', RegisterPerformanceMonitor)
exports('MonitorPerformance', MonitorPerformance)
exports('RegisterOptimizationRule', RegisterOptimizationRule)
exports('ApplyOptimization', ApplyOptimization)
exports('RegisterCache', RegisterCache)
exports('GetCachedData', GetCachedData)
exports('SetCachedData', SetCachedData)
exports('RegisterResourceManager', RegisterResourceManager)
exports('AllocateResource', AllocateResource)
exports('ReleaseResource', ReleaseResource)
exports('RegisterQueryOptimizer', RegisterQueryOptimizer)
exports('OptimizeQuery', OptimizeQuery)
exports('RegisterMemoryManager', RegisterMemoryManager)
exports('AllocateMemory', AllocateMemory)
exports('DeallocateMemory', DeallocateMemory)
exports('RegisterNetworkOptimizer', RegisterNetworkOptimizer)
exports('OptimizeNetwork', OptimizeNetwork)
exports('RegisterLoadBalancer', RegisterLoadBalancer)
exports('DistributeLoad', DistributeLoad)
exports('RegisterAutoScaler', RegisterAutoScaler)
exports('CheckAutoScaling', CheckAutoScaling)
exports('GetPerformanceMetrics', GetPerformanceMetrics)
exports('TriggerPerformanceAlert', TriggerPerformanceAlert)

return PerformanceTuning 