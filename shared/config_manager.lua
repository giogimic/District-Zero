--[[
    District Zero FiveM - Configuration Manager
    Handles configuration files, validation, defaults, and hot-reloading
]]

local ConfigManager = {}
ConfigManager.__index = ConfigManager

-- Configuration state
local configState = {
    configs = {},
    defaults = {},
    validators = {},
    watchers = {},
    isInitialized = false
}

-- Default configurations
local DEFAULT_CONFIGS = {
    districts = {
        enabled = true,
        maxDistricts = 10,
        captureTime = 300, -- 5 minutes
        captureRadius = 50.0,
        rewardMultiplier = 1.0,
        respawnTime = 60, -- 1 minute
        maxPlayersPerDistrict = 10
    },
    
    missions = {
        enabled = true,
        maxActiveMissions = 5,
        missionTimeout = 1800, -- 30 minutes
        difficultyScaling = true,
        rewardScaling = true,
        maxMissionsPerPlayer = 3
    },
    
    teams = {
        enabled = true,
        maxTeamSize = 8,
        minTeamSize = 2,
        teamCreationCost = 1000,
        maxTeams = 20,
        teamNameMaxLength = 20
    },
    
    events = {
        enabled = true,
        maxActiveEvents = 3,
        eventDuration = 3600, -- 1 hour
        eventCooldown = 1800, -- 30 minutes
        maxParticipants = 50,
        autoStart = false
    },
    
    achievements = {
        enabled = true,
        maxAchievements = 100,
        achievementPoints = true,
        leaderboardEnabled = true,
        notificationDelay = 3000 -- 3 seconds
    },
    
    analytics = {
        enabled = true,
        trackingInterval = 60000, -- 1 minute
        dataRetention = 30, -- 30 days
        exportEnabled = true,
        privacyMode = false
    },
    
    security = {
        enabled = true,
        antiCheatLevel = "medium",
        rateLimitEnabled = true,
        maxRequestsPerMinute = 100,
        banDuration = 3600, -- 1 hour
        whitelistEnabled = false
    },
    
    performance = {
        enabled = true,
        optimizationLevel = "medium",
        cacheEnabled = true,
        cacheSize = 1000,
        gcInterval = 300000, -- 5 minutes
        memoryLimit = 80 -- 80% memory usage
    },
    
    ui = {
        enabled = true,
        theme = "dark",
        language = "en",
        animations = true,
        soundEnabled = true,
        notifications = true
    },
    
    database = {
        type = "mysql", -- mysql, sqlite
        host = "localhost",
        port = 3306,
        database = "district_zero",
        username = "root",
        password = "",
        connectionLimit = 10,
        timeout = 5000
    },
    
    deployment = {
        mode = "production",
        autoDeploy = false,
        rollbackEnabled = true,
        healthCheckInterval = 30000,
        maxRollbackVersions = 5
    },
    
    release = {
        mode = "production",
        changelogEnabled = true,
        releaseNotesEnabled = true,
        postLaunchMonitoring = true,
        supportEnabled = true
    }
}

-- Initialize configuration manager
function ConfigManager.Initialize()
    print("^2[District Zero] ^7Initializing Configuration Manager...")
    
    -- Load all configurations
    ConfigManager.LoadAllConfigurations()
    
    -- Set up configuration watchers
    ConfigManager.SetupConfigWatchers()
    
    -- Validate all configurations
    ConfigManager.ValidateAllConfigurations()
    
    -- Register configuration events
    ConfigManager.RegisterConfigurationEvents()
    
    configState.isInitialized = true
    
    print("^2[District Zero] ^7Configuration Manager Initialized")
end

-- Save configuration to file
local function SaveConfiguration(configName, configData)
    if not configName or not configData then
        print('^1[District Zero] Invalid parameters for SaveConfiguration^7')
        return false
    end
    
    -- Use SaveResourceFile instead of io operations
    local success = pcall(function()
        SaveResourceFile(GetCurrentResourceName(), 'config/' .. configName .. '.json', json.encode(configData, { indent = true }))
    end)
    
    if not success then
        print('^1[District Zero] Failed to save configuration: ' .. configName .. '^7')
        return false
    end
    
    print('^2[District Zero] Configuration saved: ' .. configName .. '^7')
    return true
end

-- Load all configurations
function ConfigManager.LoadAllConfigurations()
    for configName, defaultConfig in pairs(DEFAULT_CONFIGS) do
        ConfigManager.LoadConfiguration(configName, defaultConfig)
    end
end

-- Load specific configuration
function ConfigManager.LoadConfiguration(configName, defaultConfig)
    local configFile = LoadResourceFile(GetCurrentResourceName(), "config/" .. configName .. ".json")
    local config = defaultConfig
    
    if configFile then
        local loadedConfig = json.decode(configFile)
        if loadedConfig then
            -- Merge with defaults
            config = ConfigManager.MergeConfigurations(defaultConfig, loadedConfig)
        end
    end
    
    -- Store configuration
    configState.configs[configName] = config
    configState.defaults[configName] = defaultConfig
    
    -- Create config file if it doesn't exist
    if not configFile then
        SaveConfiguration(configName, config)
    end
    
    print(string.format("^2[District Zero] ^7Loaded configuration: %s", configName))
end

-- Merge configurations
function ConfigManager.MergeConfigurations(defaultConfig, loadedConfig)
    local merged = {}
    
    -- Start with defaults
    for key, value in pairs(defaultConfig) do
        merged[key] = value
    end
    
    -- Override with loaded config
    for key, value in pairs(loadedConfig) do
        if type(value) == "table" and type(merged[key]) == "table" then
            merged[key] = ConfigManager.MergeConfigurations(merged[key], value)
        else
            merged[key] = value
        end
    end
    
    return merged
end



-- Setup configuration watchers
function ConfigManager.SetupConfigWatchers()
    -- This would set up file watchers for hot-reloading
    -- For now, we'll implement manual reload functionality
    print("^3[District Zero] ^7Configuration watchers setup (manual reload available)")
end

-- Validate all configurations
function ConfigManager.ValidateAllConfigurations()
    for configName, config in pairs(configState.configs) do
        local validator = configState.validators[configName]
        if validator then
            local isValid, error = validator(config)
            if not isValid then
                print(string.format("^1[District Zero] ^7Configuration validation failed for %s: %s", configName, error))
                -- Fall back to defaults
                configState.configs[configName] = configState.defaults[configName]
            end
        end
    end
end

-- Register configuration events
function ConfigManager.RegisterConfigurationEvents()
    -- Register configuration reload event
    RegisterNetEvent("district_zero:config:reload")
    AddEventHandler("district_zero:config:reload", function(configName)
        ConfigManager.ReloadConfiguration(configName)
    end)
    
    -- Register configuration update event
    RegisterNetEvent("district_zero:config:update")
    AddEventHandler("district_zero:config:update", function(configName, updates)
        ConfigManager.UpdateConfiguration(configName, updates)
    end)
end

-- Reload configuration
function ConfigManager.ReloadConfiguration(configName)
    if not configName then
        -- Reload all configurations
        ConfigManager.LoadAllConfigurations()
        print("^2[District Zero] ^7All configurations reloaded")
    else
        -- Reload specific configuration
        local defaultConfig = configState.defaults[configName]
        if defaultConfig then
            ConfigManager.LoadConfiguration(configName, defaultConfig)
            print(string.format("^2[District Zero] ^7Configuration %s reloaded", configName))
        else
            print(string.format("^1[District Zero] ^7Configuration %s not found", configName))
        end
    end
end

-- Update configuration
function ConfigManager.UpdateConfiguration(configName, updates)
    local config = configState.configs[configName]
    if not config then
        print(string.format("^1[District Zero] ^7Configuration %s not found", configName))
        return false
    end
    
    -- Apply updates
    for key, value in pairs(updates) do
        config[key] = value
    end
    
    -- Validate updated configuration
    local validator = configState.validators[configName]
    if validator then
        local isValid, error = validator(config)
        if not isValid then
            print(string.format("^1[District Zero] ^7Configuration update validation failed for %s: %s", configName, error))
            return false
        end
    end
    
    -- Save updated configuration
    SaveConfiguration(configName, config)
    
    -- Notify systems of configuration change
    TriggerEvent("district_zero:config:changed", configName, config)
    
    print(string.format("^2[District Zero] ^7Configuration %s updated", configName))
    return true
end

-- Get configuration
function ConfigManager.GetConfiguration(configName)
    return configState.configs[configName]
end

-- Get all configurations
function ConfigManager.GetAllConfigurations()
    return configState.configs
end

-- Add configuration validator
function ConfigManager.AddValidator(configName, validator)
    configState.validators[configName] = validator
end

-- Validate configuration
function ConfigManager.ValidateConfiguration(configName, config)
    local validator = configState.validators[configName]
    if validator then
        return validator(config)
    end
    return true
end

-- Reset configuration to defaults
function ConfigManager.ResetConfiguration(configName)
    local defaultConfig = configState.defaults[configName]
    if defaultConfig then
        configState.configs[configName] = ConfigManager.MergeConfigurations({}, defaultConfig)
        SaveConfiguration(configName, configState.configs[configName])
        print(string.format("^2[District Zero] ^7Configuration %s reset to defaults", configName))
        return true
    end
    return false
end

-- Export configuration
function ConfigManager.ExportConfiguration(configName)
    local config = configState.configs[configName]
    if config then
        local exportDir = GetResourcePath(GetCurrentResourceName()) .. "/exports"
        if not Utils.DoesDirectoryExist(exportDir) then
            Utils.CreateDirectory(exportDir)
        end
        
        local filename = "config_" .. configName .. "_" .. os.date("%Y%m%d_%H%M%S") .. ".json"
        SaveResourceFile(GetCurrentResourceName(), "exports/" .. filename, json.encode(config, {indent = true}))
        
        print(string.format("^2[District Zero] ^7Configuration %s exported to %s", configName, filename))
        return filename
    end
    return nil
end

-- Import configuration
function ConfigManager.ImportConfiguration(configName, importData)
    local success, config = pcall(json.decode, importData)
    if not success then
        print(string.format("^1[District Zero] ^7Failed to parse import data for %s", configName))
        return false
    end
    
    -- Validate imported configuration
    local validator = configState.validators[configName]
    if validator then
        local isValid, error = validator(config)
        if not isValid then
            print(string.format("^1[District Zero] ^7Imported configuration validation failed for %s: %s", configName, error))
            return false
        end
    end
    
    -- Apply imported configuration
    configState.configs[configName] = config
    ConfigManager.SaveConfiguration(configName, config)
    
    print(string.format("^2[District Zero] ^7Configuration %s imported successfully", configName))
    return true
end

-- Get configuration statistics
function ConfigManager.GetConfigurationStatistics()
    local stats = {
        totalConfigs = 0,
        loadedConfigs = 0,
        validators = 0,
        lastUpdated = os.time()
    }
    
    for configName, config in pairs(configState.configs) do
        stats.totalConfigs = stats.totalConfigs + 1
        if config then
            stats.loadedConfigs = stats.loadedConfigs + 1
        end
    end
    
    for configName, validator in pairs(configState.validators) do
        stats.validators = stats.validators + 1
    end
    
    return stats
end

-- Register commands
function ConfigManager.RegisterCommands()
    RegisterCommand("config_reload", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local configName = args[1]
        ConfigManager.ReloadConfiguration(configName)
    end, true)
    
    RegisterCommand("config_list", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local configs = ConfigManager.GetAllConfigurations()
        print("^3[District Zero] ^7Available Configurations:")
        for configName, config in pairs(configs) do
            print("  - " .. configName)
        end
    end, true)
    
    RegisterCommand("config_show", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local configName = args[1]
        if not configName then
            print("^1[District Zero] ^7Usage: config_show <config_name>")
            return
        end
        
        local config = ConfigManager.GetConfiguration(configName)
        if config then
            print("^3[District Zero] ^7Configuration: " .. configName)
            for key, value in pairs(config) do
                print("  " .. key .. ": " .. tostring(value))
            end
        else
            print("^1[District Zero] ^7Configuration " .. configName .. " not found")
        end
    end, true)
    
    RegisterCommand("config_reset", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local configName = args[1]
        if not configName then
            print("^1[District Zero] ^7Usage: config_reset <config_name>")
            return
        end
        
        ConfigManager.ResetConfiguration(configName)
    end, true)
    
    RegisterCommand("config_export", function(source, args, rawCommand)
        if source ~= 0 then
            TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "This command is admin only"}
            })
            return
        end
        
        local configName = args[1]
        if not configName then
            print("^1[District Zero] ^7Usage: config_export <config_name>")
            return
        end
        
        local filename = ConfigManager.ExportConfiguration(configName)
        if filename then
            print("^2[District Zero] ^7Configuration exported to: " .. filename)
        else
            print("^1[District Zero] ^7Failed to export configuration")
        end
    end, true)
end

-- Export functions
exports("GetConfiguration", ConfigManager.GetConfiguration)
exports("GetAllConfigurations", ConfigManager.GetAllConfigurations)
exports("UpdateConfiguration", ConfigManager.UpdateConfiguration)
exports("ReloadConfiguration", ConfigManager.ReloadConfiguration)
exports("ResetConfiguration", ConfigManager.ResetConfiguration)
exports("ExportConfiguration", ConfigManager.ExportConfiguration)
exports("ImportConfiguration", ConfigManager.ImportConfiguration)
exports("GetConfigurationStatistics", ConfigManager.GetConfigurationStatistics)
exports("GetConfig", ConfigManager.GetConfiguration) -- Alias for compatibility

-- Initialize on resource start
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ConfigManager.Initialize()
        ConfigManager.RegisterCommands()
    end
end)

return ConfigManager 