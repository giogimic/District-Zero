-- District Zero Database Initialization

local QBCore = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'

-- Initialize database
local function InitializeDatabase()
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
local function InsertDefaultData()
    if not Config.Districts then
        print('^1[District Zero] Config.Districts is not defined^7')
        return false
    end

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

-- Get districts from database
local function GetDistricts()
    local result = MySQL.query.await('SELECT * FROM dz_districts')
    return result or {}
end

-- Get district control
local function GetDistrictControl(districtId)
    local result = MySQL.query.await('SELECT * FROM dz_district_control WHERE district_id = ?', {districtId})
    return result and result[1] or nil
end

-- Register exports
exports('InitializeDatabase', InitializeDatabase)
exports('InsertDefaultData', InsertDefaultData)
exports('GetDistricts', GetDistricts)
exports('GetDistrictControl', GetDistrictControl)

-- Initialize on resource start
CreateThread(function()
    -- Wait for Qbox to be ready
    while not QBCore do
        Wait(100)
    end
    
    -- Create migrations table if it doesn't exist
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS dz_migrations (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ]])
    
    -- Run migrations
    local appliedMigrations = {}
    MySQL.query('SELECT name FROM dz_migrations', {}, function(result)
        if result then
            for _, row in ipairs(result) do
                appliedMigrations[row.name] = true
            end
        end
        
        -- Get all migration files
        local migrationFiles = {}
        local resourcePath = GetResourcePath(GetCurrentResourceName())
        local migrationPath = resourcePath .. '/server/database/migrations'
        
        -- Use LoadResourceFile to get migration files
        local files = LoadResourceFile(GetCurrentResourceName(), 'server/database/migrations')
        if files then
            for file in files:gmatch("[^\r\n]+") do
                if file:match('%.sql$') then
                    table.insert(migrationFiles, file)
                end
            end
        end
        
        -- Sort migration files
        table.sort(migrationFiles)
        
        -- Apply pending migrations
        for _, file in ipairs(migrationFiles) do
            if not appliedMigrations[file] then
                local path = 'server/database/migrations/' .. file
                local content = LoadResourceFile(GetCurrentResourceName(), path)
                
                if content then
                    -- Execute migration
                    MySQL.query(content, {}, function(result)
                        if result then
                            -- Record migration
                            MySQL.insert('INSERT INTO dz_migrations (name) VALUES (?)', {file})
                            print('[District Zero] Applied migration: ' .. file)
                        else
                            print('[District Zero] Failed to apply migration: ' .. file)
                        end
                    end)
                else
                    print('[District Zero] Failed to load migration file: ' .. file)
                end
            end
        end
    end)
end)

-- Exports
exports('GetFactions', function()
    local result = MySQL.query.await('SELECT * FROM dz_factions')
    return result or {}
end)

exports('GetEvents', function()
    local result = MySQL.query.await('SELECT * FROM dz_events ORDER BY start_time DESC')
    return result or {}
end) 