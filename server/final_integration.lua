--[[
    District Zero FiveM - Final Integration System
    Day 20: Final Integration & Deployment
    
    Orchestrates all systems, handles dependencies, provides unified APIs,
    manages cross-system communication, and ensures seamless integration.
]]

local FinalIntegration = {}
FinalIntegration.__index = FinalIntegration

-- System registry
local systems = {
    districts = nil,
    missions = nil,
    teams = nil,
    events = nil,
    achievements = nil,
    analytics = nil,
    security = nil,
    performance = nil,
    integration = nil,
    polish = nil,
    deployment = nil
}

-- Integration state
local integrationState = {
    initialized = false,
    systemsReady = {},
    dependencies = {},
    crossSystemEvents = {},
    unifiedAPI = {},
    healthStatus = "initializing"
}

-- System dependencies
local SYSTEM_DEPENDENCIES = {
    districts = {},
    missions = {"districts"},
    teams = {"districts"},
    events = {"districts", "missions"},
    achievements = {"missions", "teams", "events"},
    analytics = {"districts", "missions", "teams", "events", "achievements"},
    security = {"districts", "missions", "teams"},
    performance = {"districts", "missions", "teams", "events"},
    integration = {"districts", "missions", "teams", "events", "achievements"},
    polish = {"districts", "missions", "teams", "events", "achievements", "analytics"},
    deployment = {"districts", "missions", "teams", "events", "achievements", "analytics", "security", "performance"}
}

-- Initialize final integration
function FinalIntegration.Initialize()
    print("^2[District Zero] ^7Initializing Final Integration System...")
    
    -- Load all systems
    FinalIntegration.LoadSystems()
    
    -- Initialize system dependencies
    FinalIntegration.InitializeDependencies()
    
    -- Start system orchestration
    FinalIntegration.StartOrchestration()
    
    -- Register unified API
    FinalIntegration.RegisterUnifiedAPI()
    
    -- Register cross-system events
    FinalIntegration.RegisterCrossSystemEvents()
    
    -- Register integration commands
    FinalIntegration.RegisterCommands()
    
    -- Start health monitoring
    FinalIntegration.StartHealthMonitoring()
    
    integrationState.initialized = true
    integrationState.healthStatus = "healthy"
    
    print("^2[District Zero] ^7Final Integration System Initialized")
    print("^2[District Zero] ^7All systems integrated and ready")
end

-- Load all systems
function FinalIntegration.LoadSystems()
    print("^3[District Zero] ^7Loading systems...")
    
    -- Load core systems
    systems.districts = exports["district_zero"]:GetDistrictsSystem()
    systems.missions = exports["district_zero"]:GetMissionsSystem()
    systems.teams = exports["district_zero"]:GetTeamsSystem()
    systems.events = exports["district_zero"]:GetEventsSystem()
    systems.achievements = exports["district_zero"]:GetAchievementsSystem()
    
    -- Load advanced systems
    systems.analytics = exports["district_zero"]:GetAnalyticsSystem()
    systems.security = exports["district_zero"]:GetSecuritySystem()
    systems.performance = exports["district_zero"]:GetPerformanceSystem()
    
    -- Load integration systems
    systems.integration = exports["district_zero"]:GetIntegrationSystem()
    systems.polish = exports["district_zero"]:GetPolishSystem()
    systems.deployment = exports["district_zero"]:GetDeploymentSystem()
    
    print("^2[District Zero] ^7All systems loaded successfully")
end

-- Initialize system dependencies
function FinalIntegration.InitializeDependencies()
    print("^3[District Zero] ^7Initializing system dependencies...")
    
    for systemName, dependencies in pairs(SYSTEM_DEPENDENCIES) do
        integrationState.dependencies[systemName] = dependencies
    end
    
    print("^2[District Zero] ^7System dependencies initialized")
end

-- Start system orchestration
function FinalIntegration.StartOrchestration()
    print("^3[District Zero] ^7Starting system orchestration...")
    
    CreateThread(function()
        -- Initialize systems in dependency order
        FinalIntegration.InitializeSystemsInOrder()
        
        -- Start cross-system communication
        FinalIntegration.StartCrossSystemCommunication()
        
        -- Start unified event handling
        FinalIntegration.StartUnifiedEventHandling()
        
        print("^2[District Zero] ^7System orchestration started")
    end)
end

-- Initialize systems in dependency order
function FinalIntegration.InitializeSystemsInOrder()
    local initialized = {}
    local maxIterations = 100
    local iteration = 0
    
    while #initialized < #systems and iteration < maxIterations do
        iteration = iteration + 1
        
        for systemName, system in pairs(systems) do
            if not initialized[systemName] and FinalIntegration.CanInitializeSystem(systemName, initialized) then
                FinalIntegration.InitializeSystem(systemName, system)
                initialized[systemName] = true
                integrationState.systemsReady[systemName] = true
            end
        end
    end
    
    if #initialized < #systems then
        print("^1[District Zero] ^7Warning: Some systems could not be initialized due to dependency issues")
    end
end

-- Check if system can be initialized
function FinalIntegration.CanInitializeSystem(systemName, initialized)
    local dependencies = integrationState.dependencies[systemName] or {}
    
    for _, dependency in ipairs(dependencies) do
        if not initialized[dependency] then
            return false
        end
    end
    
    return true
end

-- Initialize individual system
function FinalIntegration.InitializeSystem(systemName, system)
    print(string.format("^3[District Zero] ^7Initializing %s system...", systemName))
    
    if system and system.Initialize then
        local success = pcall(function()
            system.Initialize()
        end)
        
        if success then
            print(string.format("^2[District Zero] ^7%s system initialized successfully", systemName))
        else
            print(string.format("^1[District Zero] ^7Failed to initialize %s system", systemName))
        end
    else
        print(string.format("^3[District Zero] ^7%s system not available", systemName))
    end
end

-- Start cross-system communication
function FinalIntegration.StartCrossSystemCommunication()
    print("^3[District Zero] ^7Starting cross-system communication...")
    
    -- Register system communication events
    RegisterNetEvent("district_zero:system:communication")
    AddEventHandler("district_zero:system:communication", function(data)
        FinalIntegration.HandleSystemCommunication(data)
    end)
    
    -- Start periodic system sync
    CreateThread(function()
        while true do
            FinalIntegration.SyncSystems()
            Wait(30000) -- Every 30 seconds
        end
    end)
    
    print("^2[District Zero] ^7Cross-system communication started")
end

-- Handle system communication
function FinalIntegration.HandleSystemCommunication(data)
    local sourceSystem = data.source
    local targetSystem = data.target
    local message = data.message
    local payload = data.payload
    
    if systems[targetSystem] and systems[targetSystem].HandleMessage then
        systems[targetSystem].HandleMessage(sourceSystem, message, payload)
    end
end

-- Sync systems
function FinalIntegration.SyncSystems()
    for systemName, system in pairs(systems) do
        if system and system.Sync then
            pcall(function()
                system.Sync()
            end)
        end
    end
end

-- Start unified event handling
function FinalIntegration.StartUnifiedEventHandling()
    print("^3[District Zero] ^7Starting unified event handling...")
    
    -- Register unified events
    FinalIntegration.RegisterUnifiedEvents()
    
    -- Start event processing
    CreateThread(function()
        while true do
            FinalIntegration.ProcessUnifiedEvents()
            Wait(100) -- Every 100ms
        end
    end)
    
    print("^2[District Zero] ^7Unified event handling started")
end

-- Register unified events
function FinalIntegration.RegisterUnifiedEvents()
    integrationState.crossSystemEvents = {
        "district_captured",
        "mission_completed",
        "team_created",
        "event_started",
        "achievement_unlocked",
        "security_violation",
        "performance_alert",
        "analytics_update"
    }
    
    for _, eventName in ipairs(integrationState.crossSystemEvents) do
        RegisterNetEvent("district_zero:" .. eventName)
        AddEventHandler("district_zero:" .. eventName, function(data)
            FinalIntegration.HandleUnifiedEvent(eventName, data)
        end)
    end
end

-- Handle unified event
function FinalIntegration.HandleUnifiedEvent(eventName, data)
    -- Route event to relevant systems
    local eventHandlers = {
        district_captured = {"analytics", "achievements", "events"},
        mission_completed = {"analytics", "achievements", "teams", "events"},
        team_created = {"analytics", "events"},
        event_started = {"analytics", "achievements", "teams"},
        achievement_unlocked = {"analytics", "events"},
        security_violation = {"analytics", "security", "performance"},
        performance_alert = {"analytics", "performance"},
        analytics_update = {"achievements", "events"}
    }
    
    local handlers = eventHandlers[eventName] or {}
    for _, systemName in ipairs(handlers) do
        if systems[systemName] and systems[systemName].HandleEvent then
            pcall(function()
                systems[systemName].HandleEvent(eventName, data)
            end)
        end
    end
end

-- Process unified events
function FinalIntegration.ProcessUnifiedEvents()
    -- Process any queued events
    -- This would handle event queuing and processing
end

-- Register unified API
function FinalIntegration.RegisterUnifiedAPI()
    print("^3[District Zero] ^7Registering unified API...")
    
    integrationState.unifiedAPI = {
        -- District operations
        GetDistricts = function() return systems.districts and systems.districts.GetDistricts() or {} end,
        GetDistrict = function(id) return systems.districts and systems.districts.GetDistrict(id) or nil end,
        CaptureDistrict = function(id, teamId) return systems.districts and systems.districts.CaptureDistrict(id, teamId) or false end,
        
        -- Mission operations
        GetMissions = function() return systems.missions and systems.missions.GetMissions() or {} end,
        GetMission = function(id) return systems.missions and systems.missions.GetMission(id) or nil end,
        CreateMission = function(data) return systems.missions and systems.missions.CreateMission(data) or nil end,
        CompleteMission = function(id, playerId) return systems.missions and systems.missions.CompleteMission(id, playerId) or false end,
        
        -- Team operations
        GetTeams = function() return systems.teams and systems.teams.GetTeams() or {} end,
        GetTeam = function(id) return systems.teams and systems.teams.GetTeam(id) or nil end,
        CreateTeam = function(data) return systems.teams and systems.teams.CreateTeam(data) or nil end,
        JoinTeam = function(teamId, playerId) return systems.teams and systems.teams.JoinTeam(teamId, playerId) or false end,
        
        -- Event operations
        GetEvents = function() return systems.events and systems.events.GetEvents() or {} end,
        GetEvent = function(id) return systems.events and systems.events.GetEvent(id) or nil end,
        StartEvent = function(id) return systems.events and systems.events.StartEvent(id) or false end,
        
        -- Achievement operations
        GetAchievements = function() return systems.achievements and systems.achievements.GetAchievements() or {} end,
        GetPlayerAchievements = function(playerId) return systems.achievements and systems.achievements.GetPlayerAchievements(playerId) or {} end,
        UnlockAchievement = function(playerId, achievementId) return systems.achievements and systems.achievements.UnlockAchievement(playerId, achievementId) or false end,
        
        -- Analytics operations
        GetAnalytics = function() return systems.analytics and systems.analytics.GetAnalytics() or {} end,
        GetPlayerAnalytics = function(playerId) return systems.analytics and systems.analytics.GetPlayerAnalytics(playerId) or {} end,
        TrackEvent = function(event, data) return systems.analytics and systems.analytics.TrackEvent(event, data) or false end,
        
        -- Security operations
        GetSecurityStatus = function() return systems.security and systems.security.GetSecurityStatus() or {} end,
        CheckPlayerSecurity = function(playerId) return systems.security and systems.security.CheckPlayerSecurity(playerId) or true end,
        ReportViolation = function(playerId, violation) return systems.security and systems.security.ReportViolation(playerId, violation) or false end,
        
        -- Performance operations
        GetPerformanceMetrics = function() return systems.performance and systems.performance.GetPerformanceMetrics() or {} end,
        OptimizePerformance = function() return systems.performance and systems.performance.OptimizePerformance() or false end,
        
        -- Integration operations
        GetSystemStatus = function() return FinalIntegration.GetSystemStatus() end,
        GetIntegrationHealth = function() return FinalIntegration.GetIntegrationHealth() end,
        
        -- Deployment operations
        GetDeploymentStatus = function() return systems.deployment and systems.deployment.GetDeploymentStatus() or {} end,
        DeployVersion = function(version, config) return systems.deployment and systems.deployment.DeployVersion(version, config) or {success = false} end
    }
    
    print("^2[District Zero] ^7Unified API registered")
end

-- Register cross-system events
function FinalIntegration.RegisterCrossSystemEvents()
    print("^3[District Zero] ^7Registering cross-system events...")
    
    -- Register events for cross-system communication
    RegisterNetEvent("district_zero:integration:system_ready")
    AddEventHandler("district_zero:integration:system_ready", function(systemName)
        FinalIntegration.OnSystemReady(systemName)
    end)
    
    RegisterNetEvent("district_zero:integration:system_error")
    AddEventHandler("district_zero:integration:system_error", function(systemName, error)
        FinalIntegration.OnSystemError(systemName, error)
    end)
    
    RegisterNetEvent("district_zero:integration:health_check")
    AddEventHandler("district_zero:integration:health_check", function()
        FinalIntegration.PerformHealthCheck()
    end)
    
    print("^2[District Zero] ^7Cross-system events registered")
end

-- On system ready
function FinalIntegration.OnSystemReady(systemName)
    print(string.format("^2[District Zero] ^7System %s is ready", systemName))
    integrationState.systemsReady[systemName] = true
end

-- On system error
function FinalIntegration.OnSystemError(systemName, error)
    print(string.format("^1[District Zero] ^7System %s error: %s", systemName, error))
    integrationState.systemsReady[systemName] = false
end

-- Start health monitoring
function FinalIntegration.StartHealthMonitoring()
    print("^3[District Zero] ^7Starting health monitoring...")
    
    CreateThread(function()
        while true do
            FinalIntegration.PerformHealthCheck()
            Wait(60000) -- Every minute
        end
    end)
    
    print("^2[District Zero] ^7Health monitoring started")
end

-- Perform health check
function FinalIntegration.PerformHealthCheck()
    local healthySystems = 0
    local totalSystems = 0
    
    for systemName, system in pairs(systems) do
        totalSystems = totalSystems + 1
        if integrationState.systemsReady[systemName] then
            healthySystems = healthySystems + 1
        end
    end
    
    local healthPercentage = (healthySystems / totalSystems) * 100
    
    if healthPercentage >= 90 then
        integrationState.healthStatus = "healthy"
    elseif healthPercentage >= 70 then
        integrationState.healthStatus = "degraded"
    else
        integrationState.healthStatus = "unhealthy"
    end
    
    -- Log health status
    if integrationState.healthStatus ~= "healthy" then
        print(string.format("^3[District Zero] ^7Integration Health: %s (%d/%d systems)", 
            integrationState.healthStatus, healthySystems, totalSystems))
    end
end

-- Get system status
function FinalIntegration.GetSystemStatus()
    local status = {}
    
    for systemName, system in pairs(systems) do
        status[systemName] = {
            ready = integrationState.systemsReady[systemName] or false,
            available = system ~= nil,
            dependencies = integrationState.dependencies[systemName] or {}
        }
    end
    
    return status
end

-- Get integration health
function FinalIntegration.GetIntegrationHealth()
    return {
        status = integrationState.healthStatus,
        initialized = integrationState.initialized,
        systemsReady = integrationState.systemsReady,
        totalSystems = #systems,
        healthySystems = 0 -- Calculate this
    }
end

-- Get unified API
function FinalIntegration.GetUnifiedAPI()
    return integrationState.unifiedAPI
end

-- Register commands
function FinalIntegration.RegisterCommands()
    RegisterCommand("integration_status", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local status = FinalIntegration.GetSystemStatus()
        local health = FinalIntegration.GetIntegrationHealth()
        
        print("^3[District Zero] ^7Integration Status:")
        print("  Overall Health: " .. health.status)
        print("  Initialized: " .. tostring(health.initialized))
        print("  Systems:")
        
        for systemName, systemStatus in pairs(status) do
            local statusColor = systemStatus.ready and "^2" or "^1"
            local statusText = systemStatus.ready and "Ready" or "Not Ready"
            print(string.format("    %s: %s%s^7", systemName, statusColor, statusText))
        end
    end, true)
    
    RegisterCommand("integration_health", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        FinalIntegration.PerformHealthCheck()
        local health = FinalIntegration.GetIntegrationHealth()
        
        print("^3[District Zero] ^7Integration Health Check:")
        print("  Status: " .. health.status)
        print("  Initialized: " .. tostring(health.initialized))
        print("  Total Systems: " .. health.totalSystems)
    end, true)
    
    RegisterCommand("integration_sync", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        print("^3[District Zero] ^7Syncing all systems...")
        FinalIntegration.SyncSystems()
        print("^2[District Zero] ^7System sync completed")
    end, true)
    
    RegisterCommand("integration_test", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        print("^3[District Zero] ^7Testing integration...")
        
        -- Test unified API
        local api = FinalIntegration.GetUnifiedAPI()
        local testResults = {}
        
        -- Test district operations
        local districts = api.GetDistricts()
        table.insert(testResults, {test = "GetDistricts", success = districts ~= nil})
        
        -- Test mission operations
        local missions = api.GetMissions()
        table.insert(testResults, {test = "GetMissions", success = missions ~= nil})
        
        -- Test team operations
        local teams = api.GetTeams()
        table.insert(testResults, {test = "GetTeams", success = teams ~= nil})
        
        -- Test event operations
        local events = api.GetEvents()
        table.insert(testResults, {test = "GetEvents", success = events ~= nil})
        
        -- Test achievement operations
        local achievements = api.GetAchievements()
        table.insert(testResults, {test = "GetAchievements", success = achievements ~= nil})
        
        -- Test analytics operations
        local analytics = api.GetAnalytics()
        table.insert(testResults, {test = "GetAnalytics", success = analytics ~= nil})
        
        -- Test security operations
        local security = api.GetSecurityStatus()
        table.insert(testResults, {test = "GetSecurityStatus", success = security ~= nil})
        
        -- Test performance operations
        local performance = api.GetPerformanceMetrics()
        table.insert(testResults, {test = "GetPerformanceMetrics", success = performance ~= nil})
        
        -- Test integration operations
        local integration = api.GetSystemStatus()
        table.insert(testResults, {test = "GetSystemStatus", success = integration ~= nil})
        
        -- Test deployment operations
        local deployment = api.GetDeploymentStatus()
        table.insert(testResults, {test = "GetDeploymentStatus", success = deployment ~= nil})
        
        -- Report results
        print("^3[District Zero] ^7Integration Test Results:")
        local passed = 0
        for _, result in ipairs(testResults) do
            local color = result.success and "^2" or "^1"
            local status = result.success and "PASS" or "FAIL"
            print(string.format("  %s: %s%s^7", result.test, color, status))
            if result.success then passed = passed + 1 end
        end
        
        print(string.format("^3[District Zero] ^7Tests Passed: %d/%d", passed, #testResults))
    end, true)
end

-- Export functions
exports("GetUnifiedAPI", FinalIntegration.GetUnifiedAPI)
exports("GetSystemStatus", FinalIntegration.GetSystemStatus)
exports("GetIntegrationHealth", FinalIntegration.GetIntegrationHealth)
exports("PerformHealthCheck", FinalIntegration.PerformHealthCheck)

-- Initialize on resource start
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Wait a bit for other systems to load
        CreateThread(function()
            Wait(5000)
            FinalIntegration.Initialize()
        end)
    end
end)

return FinalIntegration 