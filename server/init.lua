-- District Zero Server Initialization
-- This file initializes all core systems and global variables

-- Initialize global variables first
Config = {}
Utils = {}
DatabaseManager = nil
QBCore = nil
QBX = nil

-- Performance system placeholder
PerformanceSystem = {
    StartMonitoring = function() end,
    StopMonitoring = function() end,
    GetMetrics = function() return {} end
}

-- Load configuration
local configPath = GetResourcePath(GetCurrentResourceName()) .. '/shared/config.lua'
local configFile = LoadResourceFile(GetCurrentResourceName(), 'shared/config.lua')
if configFile then
    local configFunc, err = load(configFile)
    if configFunc then
        configFunc()
        print('[District Zero] Configuration loaded successfully')
    else
        print('[District Zero] Error loading configuration: ' .. tostring(err))
    end
else
    print('[District Zero] Configuration file not found')
end

-- Load utilities
local utilsFile = LoadResourceFile(GetCurrentResourceName(), 'shared/utils.lua')
if utilsFile then
    local utilsFunc, err = load(utilsFile)
    if utilsFunc then
        utilsFunc()
        print('[District Zero] Utilities loaded successfully')
    else
        print('[District Zero] Error loading utilities: ' .. tostring(err))
    end
else
    print('[District Zero] Utilities file not found')
end

-- Initialize QBX Core with fallback
local function InitializeCore()
    local coreResources = {'qbx_core', 'qb-core', 'qb_core'}
    
    for _, resourceName in ipairs(coreResources) do
        if GetResourceState(resourceName) == 'started' then
            local success, result = pcall(function()
                return exports[resourceName]:GetCoreObject()
            end)
            
            if success and result then
                QBCore = result
                QBX = result
                print('[District Zero] Successfully loaded QBX Core from: ' .. resourceName)
                return true
            end
        end
    end
    
    print('[District Zero] Warning: Could not load QBX Core - some features may not work')
    return false
end

-- Initialize database
local function InitializeDatabase()
    -- Create data directory if needed
    local dataPath = GetResourcePath(GetCurrentResourceName()) .. '/data'
    
    -- Initialize database manager
    DatabaseManager = {
        ready = false,
        Execute = function(query, params)
            if MySQL and MySQL.query then
                return MySQL.query.await(query, params)
            end
            return {}
        end,
        Insert = function(query, params)
            if MySQL and MySQL.insert then
                return MySQL.insert.await(query, params)
            end
            return 0
        end,
        Update = function(query, params)
            if MySQL and MySQL.update then
                return MySQL.update.await(query, params)
            end
            return 0
        end,
        Scalar = function(query, params)
            if MySQL and MySQL.scalar then
                return MySQL.scalar.await(query, params)
            end
            return nil
        end,
        Single = function(query, params)
            if MySQL and MySQL.single then
                return MySQL.single.await(query, params)
            end
            return nil
        end
    }
    
    -- Run database initialization
    CreateThread(function()
        if MySQL and MySQL.ready then
            MySQL.ready(function()
                -- Disable foreign key checks temporarily
                MySQL.query('SET FOREIGN_KEY_CHECKS = 0')
                
                -- Load and execute schema
                local schemaFile = LoadResourceFile(GetCurrentResourceName(), 'database/schema.sql')
                if schemaFile then
                    -- Split schema into individual statements
                    local statements = {}
                    for statement in schemaFile:gmatch("([^;]+);") do
                        local trimmed = statement:match("^%s*(.-)%s*$")
                        if trimmed and trimmed ~= "" then
                            table.insert(statements, trimmed)
                        end
                    end
                    
                    -- Execute each statement
                    for _, statement in ipairs(statements) do
                        local success, err = pcall(function()
                            MySQL.query.await(statement)
                        end)
                        if not success then
                            print('[District Zero] Database statement error: ' .. tostring(err))
                        end
                    end
                    
                    print('[District Zero] Database schema initialized')
                else
                    print('[District Zero] Database schema file not found')
                end
                
                -- Re-enable foreign key checks
                MySQL.query('SET FOREIGN_KEY_CHECKS = 1')
                
                DatabaseManager.ready = true
            end)
        else
            print('[District Zero] MySQL not available - database features disabled')
        end
    end)
end

-- Register all exports
local function RegisterExports()
    -- Config exports
    exports('GetConfig', function() return Config end)
    exports('GetConfigValue', function(key) return Config[key] end)
    
    -- Utils exports
    exports('GetUtils', function() return Utils end)
    
    -- Database exports
    exports('GetDatabaseManager', function() return DatabaseManager end)
    
    -- Performance exports
    exports('GetPerformanceSystem', function() return PerformanceSystem end)
    
    -- Placeholder exports for systems that will be initialized later
    exports('GetCurrentDistrict', function(playerId) return nil end)
    exports('GetTeamStats', function(team) return {} end)
    exports('GetPlayerTeam', function(playerId) return 'neutral' end)
    exports('GetDistrictInfluence', function(districtId) return { pvp = 0, pve = 0 } end)
    exports('GetMissionProgress', function(playerId, missionId) return 0 end)
    exports('GetPlayerAchievements', function(playerId) return {} end)
    exports('GetAnalyticsData', function(category) return {} end)
    exports('GetSecurityStatus', function() return { status = 'active', threats = 0 } end)
    exports('GetPerformanceMetrics', function() return { fps = 60, memory = 0, cpu = 0 } end)
    exports('GetDistrictControl', function(districtId) return 'neutral' end)
    exports('GetControlPoints', function(districtId) return {} end)
    exports('GetActiveEvents', function() return {} end)
    exports('GetEventProgress', function(eventId) return 0 end)
    exports('GetTeamMembers', function(team) return {} end)
    exports('GetMissionStatus', function(missionId) return 'inactive' end)
    exports('GetPlayerStats', function(playerId) return {} end)
    exports('GetDistrictBonuses', function(districtId) return {} end)
    exports('GetActiveBuffs', function(playerId) return {} end)
    exports('GetLeaderboard', function(category) return {} end)
    exports('GetServerMetrics', function() return {} end)
    exports('GetPlayerRank', function(playerId) return 1 end)
    exports('GetDistrictResources', function(districtId) return {} end)
    exports('GetUpgradeStatus', function(upgradeId) return 'locked' end)
    exports('GetQuestProgress', function(playerId, questId) return 0 end)
    exports('GetFactionStanding', function(playerId, faction) return 0 end)
    exports('GetEventRewards', function(eventId) return {} end)
    exports('GetChallengeStatus', function(challengeId) return 'inactive' end)
    exports('GetPlayerInventory', function(playerId) return {} end)
    exports('GetSkillLevel', function(playerId, skill) return 0 end)
    exports('GetPrestigeLevel', function(playerId) return 0 end)
    exports('GetSeasonProgress', function() return 0 end)
    exports('GetBattlePassTier', function(playerId) return 0 end)
    exports('GetDailyRewards', function(playerId) return {} end)
    exports('GetWeeklyChallenge', function() return {} end)
    exports('GetGuildInfo', function(guildId) return {} end)
    exports('GetAllianceStatus', function(alliance) return 'neutral' end)
    exports('GetTerritoryMap', function() return {} end)
    exports('GetResourceNodes', function(districtId) return {} end)
    exports('GetMarketPrices', function() return {} end)
    exports('GetAuctionListings', function() return {} end)
    exports('GetPlayerReputation', function(playerId) return 0 end)
    
    print('[District Zero] All exports registered')
end

-- Main initialization
CreateThread(function()
    -- Initialize core
    InitializeCore()
    
    -- Initialize database
    InitializeDatabase()
    
    -- Register exports
    RegisterExports()
    
    -- Wait a bit for everything to initialize
    Wait(1000)
    
    -- Load main server file
    local mainFile = LoadResourceFile(GetCurrentResourceName(), 'server/main.lua')
    if mainFile then
        local mainFunc, err = load(mainFile)
        if mainFunc then
            mainFunc()
            print('[District Zero] Main server file loaded')
        else
            print('[District Zero] Error loading main server file: ' .. tostring(err))
        end
    end
end) 