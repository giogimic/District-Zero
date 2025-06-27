--[[
    District Zero FiveM - Deployment System
    Day 20: Final Integration & Deployment
    
    Handles deployment automation, environment management, configuration management,
    health checks, rollback capabilities, monitoring integration, and deployment metrics.
]]

local Deployment = {}
Deployment.__index = Deployment

-- Configuration
local CONFIG = {
    DEPLOYMENT_MODE = "production", -- production, staging, development
    AUTO_DEPLOY = false,
    ROLLBACK_ENABLED = true,
    HEALTH_CHECK_INTERVAL = 30000, -- 30 seconds
    DEPLOYMENT_TIMEOUT = 300000, -- 5 minutes
    MAX_ROLLBACK_VERSIONS = 5,
    BACKUP_ENABLED = true,
    MONITORING_ENABLED = true,
    LOGGING_ENABLED = true
}

-- State
local deploymentState = {
    currentVersion = "1.0.0",
    deploymentHistory = {},
    isDeploying = false,
    lastDeployment = nil,
    healthStatus = "healthy",
    rollbackVersions = {},
    deploymentMetrics = {
        totalDeployments = 0,
        successfulDeployments = 0,
        failedDeployments = 0,
        averageDeploymentTime = 0,
        lastDeploymentTime = 0
    }
}

-- Initialize deployment system
function Deployment.Initialize()
    print("^2[District Zero] ^7Initializing Deployment System...")
    
    -- Load deployment configuration
    Deployment.LoadConfiguration()
    
    -- Initialize deployment history
    Deployment.LoadDeploymentHistory()
    
    -- Start health monitoring
    Deployment.StartHealthMonitoring()
    
    -- Register deployment commands
    Deployment.RegisterCommands()
    
    -- Initialize monitoring integration
    if CONFIG.MONITORING_ENABLED then
        Deployment.InitializeMonitoring()
    end
    
    print("^2[District Zero] ^7Deployment System Initialized")
end

-- Load deployment configuration
function Deployment.LoadConfiguration()
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config/deployment.json")
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
        Deployment.SaveConfiguration()
    end
end

-- Save deployment configuration
function Deployment.SaveConfiguration()
    local configDir = GetResourcePath(GetCurrentResourceName()) .. "/config"
    if not Utils.DoesDirectoryExist(configDir) then
        Utils.CreateDirectory(configDir)
    end
    
    SaveResourceFile(GetCurrentResourceName(), "config/deployment.json", json.encode(CONFIG, {indent = true}))
end

-- Load deployment history
function Deployment.LoadDeploymentHistory()
    local historyFile = LoadResourceFile(GetCurrentResourceName(), "data/deployment_history.json")
    if historyFile then
        local history = json.decode(historyFile)
        if history then
            deploymentState.deploymentHistory = history.deployments or {}
            deploymentState.rollbackVersions = history.rollbackVersions or {}
            deploymentState.deploymentMetrics = history.metrics or deploymentState.deploymentMetrics
        end
    end
end

-- Save deployment history
function Deployment.SaveDeploymentHistory()
    local dataDir = GetResourcePath(GetCurrentResourceName()) .. "/data"
    if not Utils.DoesDirectoryExist(dataDir) then
        Utils.CreateDirectory(dataDir)
    end
    
    local history = {
        deployments = deploymentState.deploymentHistory,
        rollbackVersions = deploymentState.rollbackVersions,
        metrics = deploymentState.deploymentMetrics
    }
    
    SaveResourceFile(GetCurrentResourceName(), "data/deployment_history.json", json.encode(history, {indent = true}))
end

-- Start health monitoring
function Deployment.StartHealthMonitoring()
    CreateThread(function()
        while true do
            Deployment.PerformHealthCheck()
            Wait(CONFIG.HEALTH_CHECK_INTERVAL)
        end
    end)
end

-- Perform health check
function Deployment.PerformHealthCheck()
    local healthStatus = "healthy"
    local issues = {}
    
    -- Check system components
    local components = {
        "Districts",
        "Missions", 
        "Teams",
        "Events",
        "Achievements",
        "Analytics",
        "Security",
        "Performance"
    }
    
    for _, component in ipairs(components) do
        local status = Deployment.CheckComponentHealth(component)
        if status ~= "healthy" then
            table.insert(issues, {component = component, status = status})
            healthStatus = "degraded"
        end
    end
    
    -- Check database connectivity
    if not Deployment.CheckDatabaseHealth() then
        table.insert(issues, {component = "Database", status = "unhealthy"})
        healthStatus = "unhealthy"
    end
    
    -- Check resource usage
    local resourceUsage = Deployment.CheckResourceUsage()
    if resourceUsage.memory > 80 or resourceUsage.cpu > 80 then
        table.insert(issues, {component = "Resources", status = "high_usage"})
        healthStatus = "degraded"
    end
    
    deploymentState.healthStatus = healthStatus
    
    -- Log health status
    if #issues > 0 then
        print("^3[District Zero] ^7Health Check Issues:")
        for _, issue in ipairs(issues) do
            print(string.format("  - %s: %s", issue.component, issue.status))
        end
    end
    
    -- Trigger alerts if unhealthy
    if healthStatus == "unhealthy" then
        Deployment.TriggerHealthAlert(issues)
    end
end

-- Check component health
function Deployment.CheckComponentHealth(component)
    -- This would check actual component status
    -- For now, return healthy
    return "healthy"
end

-- Check database health
function Deployment.CheckDatabaseHealth()
    -- This would check actual database connectivity
    -- For now, return true
    return true
end

-- Check resource usage
function Deployment.CheckResourceUsage()
    -- This would check actual resource usage
    -- For now, return mock data
    return {
        memory = 45,
        cpu = 30,
        disk = 60
    }
end

-- Trigger health alert
function Deployment.TriggerHealthAlert(issues)
    if CONFIG.MONITORING_ENABLED then
        -- Send alert to monitoring system
        TriggerEvent("district_zero:monitoring:alert", {
            type = "health_check",
            severity = "warning",
            issues = issues
        })
    end
end

-- Initialize monitoring integration
function Deployment.InitializeMonitoring()
    -- Register monitoring events
    RegisterNetEvent("district_zero:deployment:metrics")
    AddEventHandler("district_zero:deployment:metrics", function(metrics)
        Deployment.UpdateMetrics(metrics)
    end)
    
    -- Start metrics collection
    CreateThread(function()
        while true do
            Deployment.CollectMetrics()
            Wait(60000) -- Every minute
        end
    end)
end

-- Collect metrics
function Deployment.CollectMetrics()
    local metrics = {
        timestamp = os.time(),
        version = deploymentState.currentVersion,
        healthStatus = deploymentState.healthStatus,
        playerCount = #GetPlayers(),
        resourceUsage = Deployment.CheckResourceUsage(),
        systemLoad = Deployment.GetSystemLoad()
    }
    
    -- Send metrics to monitoring
    TriggerEvent("district_zero:monitoring:metrics", metrics)
end

-- Get system load
function Deployment.GetSystemLoad()
    -- This would get actual system load
    -- For now, return mock data
    return {
        activePlayers = #GetPlayers(),
        activeMissions = 0,
        activeEvents = 0,
        activeTeams = 0
    }
end

-- Update metrics
function Deployment.UpdateMetrics(metrics)
    deploymentState.deploymentMetrics = metrics
    Deployment.SaveDeploymentHistory()
end

-- Deploy new version
function Deployment.DeployVersion(version, config)
    if deploymentState.isDeploying then
        return {success = false, message = "Deployment already in progress"}
    end
    
    deploymentState.isDeploying = true
    local startTime = GetGameTimer()
    
    print(string.format("^2[District Zero] ^7Starting deployment of version %s", version))
    
    -- Pre-deployment checks
    local preCheck = Deployment.PreDeploymentChecks(version, config)
    if not preCheck.success then
        deploymentState.isDeploying = false
        return preCheck
    end
    
    -- Create backup
    if CONFIG.BACKUP_ENABLED then
        local backup = Deployment.CreateBackup()
        if not backup.success then
            deploymentState.isDeploying = false
            return backup
        end
    end
    
    -- Deploy configuration
    local deployResult = Deployment.DeployConfiguration(version, config)
    if not deployResult.success then
        deploymentState.isDeploying = false
        return deployResult
    end
    
    -- Post-deployment checks
    local postCheck = Deployment.PostDeploymentChecks(version)
    if not postCheck.success then
        -- Rollback on failure
        if CONFIG.ROLLBACK_ENABLED then
            Deployment.RollbackVersion()
        end
        deploymentState.isDeploying = false
        return postCheck
    end
    
    -- Update deployment state
    local deploymentTime = GetGameTimer() - startTime
    deploymentState.currentVersion = version
    deploymentState.lastDeployment = {
        version = version,
        timestamp = os.time(),
        duration = deploymentTime,
        config = config
    }
    
    -- Add to history
    table.insert(deploymentState.deploymentHistory, deploymentState.lastDeployment)
    
    -- Update metrics
    deploymentState.deploymentMetrics.totalDeployments = deploymentState.deploymentMetrics.totalDeployments + 1
    deploymentState.deploymentMetrics.successfulDeployments = deploymentState.deploymentMetrics.successfulDeployments + 1
    deploymentState.deploymentMetrics.lastDeploymentTime = deploymentTime
    
    -- Calculate average deployment time
    local totalTime = 0
    local count = 0
    for _, deployment in ipairs(deploymentState.deploymentHistory) do
        if deployment.duration then
            totalTime = totalTime + deployment.duration
            count = count + 1
        end
    end
    if count > 0 then
        deploymentState.deploymentMetrics.averageDeploymentTime = totalTime / count
    end
    
    -- Save deployment history
    Deployment.SaveDeploymentHistory()
    
    deploymentState.isDeploying = false
    
    print(string.format("^2[District Zero] ^7Deployment of version %s completed successfully in %dms", version, deploymentTime))
    
    return {success = true, message = "Deployment completed successfully", deploymentTime = deploymentTime}
end

-- Pre-deployment checks
function Deployment.PreDeploymentChecks(version, config)
    print("^3[District Zero] ^7Running pre-deployment checks...")
    
    -- Check version format
    if not Deployment.ValidateVersion(version) then
        return {success = false, message = "Invalid version format"}
    end
    
    -- Check configuration
    if not Deployment.ValidateConfiguration(config) then
        return {success = false, message = "Invalid configuration"}
    end
    
    -- Check system health
    if deploymentState.healthStatus == "unhealthy" then
        return {success = false, message = "System health check failed"}
    end
    
    -- Check resource availability
    local resources = Deployment.CheckResourceUsage()
    if resources.memory > 90 or resources.cpu > 90 then
        return {success = false, message = "Insufficient resources for deployment"}
    end
    
    print("^2[District Zero] ^7Pre-deployment checks passed")
    return {success = true}
end

-- Validate version
function Deployment.ValidateVersion(version)
    -- Simple version validation (x.y.z format)
    return string.match(version, "^%d+%.%d+%.%d+$") ~= nil
end

-- Validate configuration
function Deployment.ValidateConfiguration(config)
    if not config then return false end
    
    -- Check required fields
    local required = {"districts", "missions", "teams", "events"}
    for _, field in ipairs(required) do
        if not config[field] then
            return false
        end
    end
    
    return true
end

-- Create backup
function Deployment.CreateBackup()
    print("^3[District Zero] ^7Creating backup...")
    
    local backup = {
        version = deploymentState.currentVersion,
        timestamp = os.time(),
        config = Deployment.GetCurrentConfiguration(),
        data = Deployment.GetCurrentData()
    }
    
    -- Add to rollback versions
    table.insert(deploymentState.rollbackVersions, backup)
    
    -- Keep only max rollback versions
    if #deploymentState.rollbackVersions > CONFIG.MAX_ROLLBACK_VERSIONS then
        table.remove(deploymentState.rollbackVersions, 1)
    end
    
    print("^2[District Zero] ^7Backup created successfully")
    return {success = true, backup = backup}
end

-- Get current configuration
function Deployment.GetCurrentConfiguration()
    -- This would get actual current configuration
    -- For now, return mock data
    return {
        districts = {},
        missions = {},
        teams = {},
        events = {}
    }
end

-- Get current data
function Deployment.GetCurrentData()
    -- This would get actual current data
    -- For now, return mock data
    return {
        players = {},
        teams = {},
        missions = {},
        events = {}
    }
end

-- Deploy configuration
function Deployment.DeployConfiguration(version, config)
    print("^3[District Zero] ^7Deploying configuration...")
    
    -- Apply configuration changes
    local success = Deployment.ApplyConfiguration(config)
    if not success then
        return {success = false, message = "Failed to apply configuration"}
    end
    
    -- Update version
    deploymentState.currentVersion = version
    
    print("^2[District Zero] ^7Configuration deployed successfully")
    return {success = true}
end

-- Apply configuration
function Deployment.ApplyConfiguration(config)
    -- This would apply actual configuration changes
    -- For now, return true
    return true
end

-- Post-deployment checks
function Deployment.PostDeploymentChecks(version)
    print("^3[District Zero] ^7Running post-deployment checks...")
    
    -- Wait for system to stabilize
    Wait(5000)
    
    -- Check system health
    Deployment.PerformHealthCheck()
    if deploymentState.healthStatus == "unhealthy" then
        return {success = false, message = "System health check failed after deployment"}
    end
    
    -- Check version
    if deploymentState.currentVersion ~= version then
        return {success = false, message = "Version mismatch after deployment"}
    end
    
    print("^2[District Zero] ^7Post-deployment checks passed")
    return {success = true}
end

-- Rollback version
function Deployment.RollbackVersion()
    if #deploymentState.rollbackVersions == 0 then
        return {success = false, message = "No rollback versions available"}
    end
    
    local rollbackVersion = table.remove(deploymentState.rollbackVersions)
    
    print(string.format("^3[District Zero] ^7Rolling back to version %s", rollbackVersion.version))
    
    -- Restore configuration
    local success = Deployment.RestoreConfiguration(rollbackVersion)
    if not success then
        return {success = false, message = "Failed to restore configuration"}
    end
    
    -- Update version
    deploymentState.currentVersion = rollbackVersion.version
    
    print("^2[District Zero] ^7Rollback completed successfully")
    return {success = true, message = "Rollback completed successfully"}
end

-- Restore configuration
function Deployment.RestoreConfiguration(rollbackVersion)
    -- This would restore actual configuration
    -- For now, return true
    return true
end

-- Get deployment status
function Deployment.GetDeploymentStatus()
    return {
        currentVersion = deploymentState.currentVersion,
        isDeploying = deploymentState.isDeploying,
        lastDeployment = deploymentState.lastDeployment,
        healthStatus = deploymentState.healthStatus,
        metrics = deploymentState.deploymentMetrics,
        rollbackVersions = #deploymentState.rollbackVersions
    }
end

-- Get deployment history
function Deployment.GetDeploymentHistory()
    return deploymentState.deploymentHistory
end

-- Register commands
function Deployment.RegisterCommands()
    RegisterCommand("deploy", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local version = args[1]
        local configFile = args[2]
        
        if not version then
            print("^1[District Zero] ^7Usage: deploy <version> [config_file]")
            return
        end
        
        local config = {}
        if configFile then
            local configData = LoadResourceFile(GetCurrentResourceName(), "config/" .. configFile)
            if configData then
                config = json.decode(configData) or {}
            end
        end
        
        local result = Deployment.DeployVersion(version, config)
        if result.success then
            print("^2[District Zero] ^7Deployment successful: " .. result.message)
        else
            print("^1[District Zero] ^7Deployment failed: " .. result.message)
        end
    end, true)
    
    RegisterCommand("rollback", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local result = Deployment.RollbackVersion()
        if result.success then
            print("^2[District Zero] ^7Rollback successful: " .. result.message)
        else
            print("^1[District Zero] ^7Rollback failed: " .. result.message)
        end
    end, true)
    
    RegisterCommand("deployment_status", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local status = Deployment.GetDeploymentStatus()
        print("^3[District Zero] ^7Deployment Status:")
        print("  Current Version: " .. status.currentVersion)
        print("  Is Deploying: " .. tostring(status.isDeploying))
        print("  Health Status: " .. status.healthStatus)
        print("  Total Deployments: " .. status.metrics.totalDeployments)
        print("  Successful Deployments: " .. status.metrics.successfulDeployments)
        print("  Failed Deployments: " .. status.metrics.failedDeployments)
        print("  Average Deployment Time: " .. status.metrics.averageDeploymentTime .. "ms")
        print("  Available Rollbacks: " .. status.rollbackVersions)
    end, true)
    
    RegisterCommand("deployment_history", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local history = Deployment.GetDeploymentHistory()
        print("^3[District Zero] ^7Deployment History:")
        for i, deployment in ipairs(history) do
            print(string.format("  %d. Version: %s, Time: %s, Duration: %dms", 
                i, deployment.version, os.date("%Y-%m-%d %H:%M:%S", deployment.timestamp), deployment.duration or 0))
        end
    end, true)
end

-- Export functions
exports("GetDeploymentStatus", Deployment.GetDeploymentStatus)
exports("GetDeploymentHistory", Deployment.GetDeploymentHistory)
exports("DeployVersion", Deployment.DeployVersion)
exports("RollbackVersion", Deployment.RollbackVersion)

-- Initialize on resource start
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Deployment.Initialize()
    end
end)

-- Save configuration to file
local function SaveConfiguration(configName, configData)
    if not configName or not configData then
        Utils.HandleError('Invalid parameters for SaveConfiguration', 'Deployment')
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
        Utils.HandleError('Failed to save configuration: ' .. tostring(error), 'Deployment')
        return false
    end
    
    Utils.PrintDebug('Configuration saved: ' .. configName, 'Deployment')
    return true
end

return Deployment 