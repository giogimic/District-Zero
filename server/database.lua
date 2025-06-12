-- District Zero Database
-- Version: 1.0.0

local Utils = require 'shared/utils'

-- Initialize database
local function InitializeDatabase()
    Utils.PrintDebug('Initializing database...')
    
    -- Create tables if they don't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS dz_districts (
            id VARCHAR(50) PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            influence_pvp INT DEFAULT 0,
            influence_pve INT DEFAULT 0,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    Utils.PrintDebug('Database initialized successfully')
end

-- Get district data
local function GetDistrictData(districtId)
    local result = MySQL.query.await('SELECT * FROM dz_districts WHERE id = ?', {districtId})
    return result[1]
end

-- Update district influence
local function UpdateDistrictInfluence(districtId, team, amount)
    local column = team == 'pvp' and 'influence_pvp' or 'influence_pve'
    MySQL.update('UPDATE dz_districts SET ' .. column .. ' = ' .. column .. ' + ?, last_updated = CURRENT_TIMESTAMP WHERE id = ?', {amount, districtId})
end

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeDatabase()
end)

-- Export functions
exports('GetDistrictData', GetDistrictData)
exports('UpdateDistrictInfluence', UpdateDistrictInfluence) 