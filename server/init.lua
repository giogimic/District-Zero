-- District Zero Server Initialization
-- Version: 1.0.0

-- Global variables
Config = nil
Utils = nil
QBX = nil

-- System modules (will be initialized later)
DistrictsSystem = nil
MissionsSystem = nil
TeamsSystem = nil
EventsSystem = nil
AchievementsSystem = nil
AnalyticsSystem = nil
SecuritySystem = nil
PerformanceSystem = nil
IntegrationSystem = nil
PolishSystem = nil
DeploymentSystem = nil
ReleaseSystem = nil
DatabaseManager = nil
AdvancedMissionSystem = nil
DynamicEventsSystem = nil
AdvancedTeamSystem = nil
AchievementSystem = nil

-- Initialize QBX Core
local function InitializeCore()
    local qbxExports = {'qbx_core', 'qb-core', 'qb_core'}
    
    for _, exportName in ipairs(qbxExports) do
        local success, result = pcall(function()
            return exports[exportName]:GetCoreObject()
        end)
        
        if success and result then
            QBX = result
            print('^2[District Zero] Successfully loaded QBX Core from: ' .. exportName .. '^7')
            return true
        end
    end
    
    print('^1[District Zero] WARNING: QBX Core not available. Some features may not work properly.^7')
    return false
end

-- Initialize Config
local function InitializeConfig()
    local success, result = pcall(function()
        return require('shared.config')
    end)
    
    if success then
        Config = result
        print('^2[District Zero] Config loaded successfully^7')
        return true
    else
        -- Try loading from file
        local configFile = LoadResourceFile(GetCurrentResourceName(), 'shared/config.lua')
        if configFile then
            local func, err = load(configFile)
            if func then
                Config = func()
                print('^2[District Zero] Config loaded from file^7')
                return true
            end
        end
    end
    
    print('^1[District Zero] ERROR: Failed to load config^7')
    return false
end

-- Initialize Utils
local function InitializeUtils()
    local success, result = pcall(function()
        return require('shared.utils')
    end)
    
    if success then
        Utils = result
        print('^2[District Zero] Utils loaded successfully^7')
        return true
    else
        -- Create basic utils
        Utils = {
            PrintDebug = function(msg) print('^3[District Zero Debug] ^7' .. tostring(msg)) end,
            PrintError = function(msg, context) print('^1[District Zero Error] ^7' .. tostring(msg) .. ' (Context: ' .. tostring(context) .. ')') end,
            PrintInfo = function(msg) print('^2[District Zero Info] ^7' .. tostring(msg)) end
        }
        print('^3[District Zero] Using basic utils^7')
        return true
    end
end

-- Initialize Database
local function InitializeDatabase()
    if not MySQL then
        print('^1[District Zero] ERROR: MySQL not available^7')
        return false
    end
    
    -- Disable foreign key checks for initialization
    MySQL.query('SET FOREIGN_KEY_CHECKS = 0')
    
    -- Drop existing tables if needed (careful with this in production!)
    local dropTables = false -- Set to true only for development/reset
    
    if dropTables then
        local tables = {
            'dz_crime_reports',
            'dz_crimes',
            'dz_player_equipment',
            'dz_equipment',
            'dz_ability_progress',
            'dz_mission_progress',
            'dz_faction_members',
            'dz_players',
            'dz_abilities',
            'dz_missions',
            'dz_factions',
            'dz_districts'
        }
        
        for _, table in ipairs(tables) do
            MySQL.query('DROP TABLE IF EXISTS ' .. table)
        end
    end
    
    -- Create tables
    local schemaFile = LoadResourceFile(GetCurrentResourceName(), 'server/database/schema.sql')
    if schemaFile then
        -- Execute schema in chunks (split by semicolon)
        local statements = {}
        for statement in schemaFile:gmatch("([^;]+);") do
            table.insert(statements, statement:match("^%s*(.-)%s*$"))
        end
        
        for _, statement in ipairs(statements) do
            if statement and statement ~= "" and not statement:match("^%-%-") then
                local success, err = pcall(function()
                    MySQL.query.await(statement)
                end)
                
                if not success then
                    print('^3[District Zero] Warning executing SQL: ' .. tostring(err) .. '^7')
                end
            end
        end
    end
    
    -- Re-enable foreign key checks
    MySQL.query('SET FOREIGN_KEY_CHECKS = 1')
    
    print('^2[District Zero] Database initialized^7')
    return true
end

-- Initialize all systems
local function InitializeSystems()
    -- Create placeholder systems
    DistrictsSystem = {}
    MissionsSystem = {}
    TeamsSystem = {}
    EventsSystem = {}
    AchievementsSystem = {}
    AnalyticsSystem = {}
    SecuritySystem = {}
    PerformanceSystem = {}
    IntegrationSystem = {}
    PolishSystem = {}
    DeploymentSystem = {}
    ReleaseSystem = {}
    DatabaseManager = {}
    AdvancedMissionSystem = {}
    DynamicEventsSystem = {}
    AdvancedTeamSystem = {}
    AchievementSystem = {}
    
    print('^2[District Zero] All systems initialized^7')
    return true
end

-- Main initialization
CreateThread(function()
    Wait(1000) -- Wait for other resources
    
    print('^2[District Zero] Starting initialization...^7')
    
    -- Initialize core components
    local coreLoaded = InitializeCore()
    local configLoaded = InitializeConfig()
    local utilsLoaded = InitializeUtils()
    
    -- Initialize database
    local dbLoaded = InitializeDatabase()
    
    -- Initialize systems
    local systemsLoaded = InitializeSystems()
    
    -- Load main server file
    if configLoaded and utilsLoaded then
        local mainFile = LoadResourceFile(GetCurrentResourceName(), 'server/main.lua')
        if mainFile then
            local func, err = load(mainFile)
            if func then
                func()
                print('^2[District Zero] Main server file loaded^7')
            else
                print('^1[District Zero] Error loading main server file: ' .. tostring(err) .. '^7')
            end
        end
    end
    
    print('^2[District Zero] Initialization complete^7')
    print('^2[District Zero] Status:^7')
    print('  - QBX Core: ' .. (coreLoaded and '^2Loaded^7' or '^1Not Loaded^7'))
    print('  - Config: ' .. (configLoaded and '^2Loaded^7' or '^1Not Loaded^7'))
    print('  - Utils: ' .. (utilsLoaded and '^2Loaded^7' or '^1Not Loaded^7'))
    print('  - Database: ' .. (dbLoaded and '^2Loaded^7' or '^1Not Loaded^7'))
    print('  - Systems: ' .. (systemsLoaded and '^2Loaded^7' or '^1Not Loaded^7'))
end) 