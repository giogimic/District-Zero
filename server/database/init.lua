-- District Zero Database Initialization
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'

-- Database initialization state
local isDatabaseInitialized = false

-- Initialize database tables
local function InitializeDatabaseTables()
    local success = pcall(function()
        -- Create districts table
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS dz_districts (
                id VARCHAR(50) PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                description TEXT,
                influence_pvp INT DEFAULT 0,
                influence_pve INT DEFAULT 0,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Create players table
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS dz_players (
                citizenid VARCHAR(50) PRIMARY KEY,
                team VARCHAR(10) DEFAULT NULL,
                current_district VARCHAR(50) DEFAULT NULL,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Create missions table
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS dz_missions (
                id VARCHAR(50) PRIMARY KEY,
                title VARCHAR(100) NOT NULL,
                description TEXT,
                type VARCHAR(10) NOT NULL,
                district_id VARCHAR(50) NOT NULL,
                reward INT DEFAULT 0,
                objectives JSON,
                active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Create mission progress table
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS dz_mission_progress (
                id INT AUTO_INCREMENT PRIMARY KEY,
                mission_id VARCHAR(50) NOT NULL,
                citizenid VARCHAR(50) NOT NULL,
                status ENUM('active', 'completed', 'failed') DEFAULT 'active',
                started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP NULL,
                objectives_completed JSON DEFAULT '[]',
                UNIQUE KEY unique_mission_player (mission_id, citizenid),
                INDEX idx_citizenid (citizenid),
                INDEX idx_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
        
        -- Create control points table
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS dz_control_points (
                id INT AUTO_INCREMENT PRIMARY KEY,
                district_id VARCHAR(50) NOT NULL,
                name VARCHAR(100) NOT NULL,
                coords_x FLOAT NOT NULL,
                coords_y FLOAT NOT NULL,
                coords_z FLOAT NOT NULL,
                radius FLOAT NOT NULL,
                influence INT DEFAULT 25,
                current_team VARCHAR(10) DEFAULT 'neutral',
                last_captured TIMESTAMP NULL,
                INDEX idx_district (district_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ]])
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to create database tables')
        return false
    end
    
    return true
end

-- Insert default district data
local function InsertDefaultDistricts()
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        return false
    end
    
    local success = pcall(function()
        for _, district in pairs(Config.Districts) do
            MySQL.insert.await([[
                INSERT IGNORE INTO dz_districts (id, name, description, influence_pvp, influence_pve)
                VALUES (?, ?, ?, 0, 0)
            ]], {district.id, district.name, district.description})
        end
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to insert default districts')
        return false
    end
    
    return true
end

-- Insert default mission data
local function InsertDefaultMissions()
    if not Config or not Config.Missions then
        Utils.PrintDebug('[ERROR] Config.Missions not loaded')
        return false
    end
    
    local success = pcall(function()
        for _, mission in pairs(Config.Missions) do
            local objectives = json.encode(mission.objectives or {})
            MySQL.insert.await([[
                INSERT IGNORE INTO dz_missions (id, title, description, type, district_id, reward, objectives)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ]], {mission.id, mission.title, mission.description, mission.type, mission.district, mission.reward, objectives})
        end
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to insert default missions')
        return false
    end
    
    return true
end

-- Insert default control points
local function InsertDefaultControlPoints()
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not loaded')
        return false
    end
    
    local success = pcall(function()
        for _, district in pairs(Config.Districts) do
            if district.controlPoints then
                for _, point in pairs(district.controlPoints) do
                    MySQL.insert.await([[
                        INSERT IGNORE INTO dz_control_points (district_id, name, coords_x, coords_y, coords_z, radius, influence)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ]], {district.id, point.name, point.coords.x, point.coords.y, point.coords.z, point.radius, point.influence})
                end
            end
        end
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to insert default control points')
        return false
    end
    
    return true
end

-- Load player data from database
local function LoadPlayerData(source)
    local player = QBX.Functions.GetPlayer(source)
    if not player then return false end
    
    local success = pcall(function()
        local result = MySQL.single.await([[
            SELECT team, current_district FROM dz_players WHERE citizenid = ?
        ]], {player.PlayerData.citizenid})
        
        if result then
            -- Return player data for use in other modules
            return {
                team = result.team,
                currentDistrict = result.current_district
            }
        end
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to load player data for ' .. source)
        return false
    end
    
    return true
end

-- Save player data to database
local function SavePlayerData(source, data)
    local player = QBX.Functions.GetPlayer(source)
    if not player then return false end
    
    local success = pcall(function()
        MySQL.insert.await([[
            INSERT INTO dz_players (citizenid, team, current_district, last_updated)
            VALUES (?, ?, ?, CURRENT_TIMESTAMP)
            ON DUPLICATE KEY UPDATE 
                team = VALUES(team),
                current_district = VALUES(current_district),
                last_updated = CURRENT_TIMESTAMP
        ]], {player.PlayerData.citizenid, data.team, data.currentDistrict})
    end)
    
    if not success then
        Utils.PrintDebug('[ERROR] Failed to save player data for ' .. source)
        return false
    end
    
    return true
end

-- Initialize database
local function InitializeDatabase()
    if isDatabaseInitialized then
        return true
    end
    
    Utils.PrintDebug('Initializing District Zero database...')
    
    -- Create tables
    if not InitializeDatabaseTables() then
        return false
    end
    
    -- Insert default data
    if not InsertDefaultDistricts() then
        return false
    end
    
    if not InsertDefaultMissions() then
        return false
    end
    
    if not InsertDefaultControlPoints() then
        return false
    end
    
    isDatabaseInitialized = true
    Utils.PrintDebug('District Zero database initialized successfully')
    return true
end

-- Event handlers
RegisterNetEvent('dz:server:loadPlayerData', function()
    local source = source
    LoadPlayerData(source)
end)

RegisterNetEvent('dz:server:savePlayerData', function(data)
    local source = source
    SavePlayerData(source, data)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for MySQL to be ready
    CreateThread(function()
        Wait(3000) -- Wait for MySQL to be ready
        
        if not InitializeDatabase() then
            print('^1[District Zero] Failed to initialize database^7')
            return
        end
        
        print('^2[District Zero] Database initialized successfully^7')
    end)
end)

-- Exports
exports('InitializeDatabase', InitializeDatabase)
exports('LoadPlayerData', LoadPlayerData)
exports('SavePlayerData', SavePlayerData)
exports('IsDatabaseInitialized', function()
    return isDatabaseInitialized
end) 