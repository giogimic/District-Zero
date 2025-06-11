local QBX = exports.qbx_core:GetCoreObject()
local Utils = require 'shared/utils'

-- Database configuration
local Config = {
    waitTimeout = 28800,
    maxConnections = 100
}

-- Initialize database
local function InitializeDatabase()
    -- Set session variables
    MySQL.query('SET SESSION wait_timeout = ?', {Config.waitTimeout})
    MySQL.query('SET GLOBAL max_connections = ?', {Config.maxConnections})
    
    -- Create tables if they don't exist
    local success = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS dz_districts (
            id INT PRIMARY KEY AUTO_INCREMENT,
            name VARCHAR(50) NOT NULL,
            description TEXT,
            owner INT,
            status ENUM('active', 'inactive', 'locked') DEFAULT 'active',
            requirements JSON,
            rewards JSON,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ]])
    
    if not success then
        print('^1Failed to create districts table^7')
        return false
    end
    
    -- Create other tables...
    -- (Add other table creation queries here)
    
    return true
end

-- Get district data
local function GetDistrictData(districtId)
    if not districtId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_districts WHERE id = ?', {districtId})
    return result and result[1]
end

-- Update district data
local function UpdateDistrictData(districtId, data)
    if not districtId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_districts SET ? WHERE id = ?', {data, districtId})
    return success and true or false
end

-- Get faction data
local function GetFactionData(factionId)
    if not factionId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_factions WHERE id = ?', {factionId})
    return result and result[1]
end

-- Update faction data
local function UpdateFactionData(factionId, data)
    if not factionId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_factions SET ? WHERE id = ?', {data, factionId})
    return success and true or false
end

-- Get mission data
local function GetMissionData(missionId)
    if not missionId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_missions WHERE id = ?', {missionId})
    return result and result[1]
end

-- Update mission data
local function UpdateMissionData(missionId, data)
    if not missionId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_missions SET ? WHERE id = ?', {data, missionId})
    return success and true or false
end

-- Get ability data
local function GetAbilityData(abilityId)
    if not abilityId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_abilities WHERE id = ?', {abilityId})
    return result and result[1]
end

-- Update ability data
local function UpdateAbilityData(abilityId, data)
    if not abilityId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_abilities SET ? WHERE id = ?', {data, abilityId})
    return success and true or false
end

-- Get player data
local function GetPlayerData(playerId)
    if not playerId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_players WHERE citizenid = ?', {playerId})
    return result and result[1]
end

-- Update player data
local function UpdatePlayerData(playerId, data)
    if not playerId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_players SET ? WHERE citizenid = ?', {data, playerId})
    return success and true or false
end

-- Initialize database on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if InitializeDatabase() then
        print('^2Database initialized successfully^7')
    else
        print('^1Failed to initialize database^7')
    end
end)

-- Exports
exports('GetDistrictData', GetDistrictData)
exports('UpdateDistrictData', UpdateDistrictData)
exports('GetFactionData', GetFactionData)
exports('UpdateFactionData', UpdateFactionData)
exports('GetMissionData', GetMissionData)
exports('UpdateMissionData', UpdateMissionData)
exports('GetAbilityData', GetAbilityData)
exports('UpdateAbilityData', UpdateAbilityData)
exports('GetPlayerData', GetPlayerData)
exports('UpdatePlayerData', UpdatePlayerData) 