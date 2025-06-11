-- District Zero Database Initialization

local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'

-- Initialize Database
function InitializeDatabase()
    print('^3[District Zero] Initializing database...^7')
    
    -- Read schema file
    local schemaFile = LoadResourceFile(GetCurrentResourceName(), 'sql/schema.sql')
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
    
    print('^2[District Zero] Database initialized successfully^7')
    return true
end

-- Insert Default Data
function InsertDefaultData()
    -- Insert default districts if they don't exist
    for id, district in pairs(Config.Districts) do
        local success = MySQL.insert.await('INSERT IGNORE INTO dz_districts (id, name, label, description, center_x, center_y, center_z, radius) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            id,
            district.name,
            district.label,
            district.description,
            district.coords.x,
            district.coords.y,
            district.coords.z,
            district.radius
        })
        
        if not success then
            print('^1[District Zero] Failed to insert default district: ' .. id .. '^7')
            return false
        end
    end
    
    return true
end

-- Exports
exports('InitializeDatabase', InitializeDatabase)
exports('InsertDefaultData', InsertDefaultData) 