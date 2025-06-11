local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'

-- Database configuration
local Config = {
    waitTimeout = 28800,
    maxConnections = 100
}

-- Initialize database
local function InitializeDatabase()
    print('^3[District Zero] Initializing database...^7')
    
    -- Set session variables
    local success = MySQL.query.await('SET GLOBAL wait_timeout = 28800')
    if not success then
        print('^1[District Zero] Failed to set wait_timeout^7')
        return false
    end
    
    success = MySQL.query.await('SET GLOBAL max_connections = 100')
    if not success then
        print('^1[District Zero] Failed to set max_connections^7')
        return false
    end
    
    -- Read schema file
    local schemaFile = LoadResourceFile(GetCurrentResourceName(), 'server/database/schema.sql')
    if not schemaFile then
        print('^1[District Zero] Failed to load schema file^7')
        return false
    end
    
    -- Split schema into individual queries
    local queries = {}
    for query in schemaFile:gmatch("[^;]+") do
        if query:match("%S") then -- Only add non-empty queries
            table.insert(queries, query)
        end
    end
    
    -- Execute each query with error handling
    for i, query in ipairs(queries) do
        local success, result = pcall(function()
            return MySQL.query.await(query)
        end)
        
        if not success then
            print('^1[District Zero] Failed to execute query ' .. i .. ': ' .. tostring(result) .. '^7')
            print('^1Query: ' .. query:sub(1, 100) .. '...^7')
            return false
        end
    end
    
    -- Verify tables were created
    local tables = {
        'dz_districts',
        'dz_factions',
        'dz_missions',
        'dz_abilities',
        'dz_players',
        'dz_faction_members',
        'dz_mission_progress',
        'dz_ability_progress',
        'dz_equipment',
        'dz_player_equipment',
        'dz_crimes',
        'dz_crime_reports'
    }
    
    for _, tableName in ipairs(tables) do
        local success, result = pcall(function()
            return MySQL.query.await('SHOW TABLES LIKE ?', {tableName})
        end)
        
        if not success or not result or #result == 0 then
            print('^1[District Zero] Table ' .. tableName .. ' was not created properly^7')
            return false
        end
    end
    
    print('^2[District Zero] Database initialized successfully^7')
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

-- Get equipment data
local function GetEquipmentData(equipmentId)
    if not equipmentId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_equipment WHERE id = ?', {equipmentId})
    return result and result[1]
end

-- Update equipment data
local function UpdateEquipmentData(equipmentId, data)
    if not equipmentId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_equipment SET ? WHERE id = ?', {data, equipmentId})
    return success and true or false
end

-- Get player equipment
local function GetPlayerEquipment(playerId)
    if not playerId then return nil end
    
    local result = MySQL.query.await([[
        SELECT pe.*, e.* 
        FROM dz_player_equipment pe
        JOIN dz_equipment e ON pe.equipment_id = e.id
        WHERE pe.player_id = ?
    ]], {playerId})
    return result
end

-- Update player equipment
local function UpdatePlayerEquipment(playerId, equipmentId, data)
    if not playerId or not equipmentId or not data then return false end
    
    local success = MySQL.update.await('UPDATE dz_player_equipment SET ? WHERE player_id = ? AND equipment_id = ?', 
        {data, playerId, equipmentId})
    return success and true or false
end

-- Get crime data
local function GetCrimeData(crimeId)
    if not crimeId then return nil end
    
    local result = MySQL.query.await('SELECT * FROM dz_crimes WHERE id = ?', {crimeId})
    return result and result[1]
end

-- Get crime reports
local function GetCrimeReports(districtId)
    if not districtId then return nil end
    
    local result = MySQL.query.await([[
        SELECT cr.*, c.* 
        FROM dz_crime_reports cr
        JOIN dz_crimes c ON cr.crime_id = c.id
        WHERE cr.location->>'$.district' = ?
    ]], {districtId})
    return result
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
    
    -- Wait a moment for MySQL to be ready
    Wait(1000)
    
    if InitializeDatabase() then
        print('^2[District Zero] Database initialized successfully^7')
    else
        print('^1[District Zero] Failed to initialize database^7')
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
exports('GetEquipmentData', GetEquipmentData)
exports('UpdateEquipmentData', UpdateEquipmentData)
exports('GetPlayerEquipment', GetPlayerEquipment)
exports('UpdatePlayerEquipment', UpdatePlayerEquipment)
exports('GetCrimeData', GetCrimeData)
exports('GetCrimeReports', GetCrimeReports)
exports('GetPlayerData', GetPlayerData)
exports('UpdatePlayerData', UpdatePlayerData) 