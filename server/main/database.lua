local QBCore = exports['qb-core']:GetCoreObject()
local connectionPool = {}
local queryCache = {}
local CACHE_TTL = 300 -- 5 minutes cache TTL

-- Initialize database connection
local function InitializeDatabase()
    -- oxmysql is already initialized by QBCore
    Utils.PrintDebug("Database connection initialized")
end

-- Execute a query with parameters
local function ExecuteQuery(query, params, cb)
    if not query then return end
    
    -- Check cache for SELECT queries
    if query:lower():match("^%s*select") then
        local cacheKey = query .. (params and json.encode(params) or "")
        if queryCache[cacheKey] and (os.time() - queryCache[cacheKey].timestamp) < CACHE_TTL then
            if cb then cb(queryCache[cacheKey].result) end
            return queryCache[cacheKey].result
        end
    end
    
    -- Execute query
    exports.oxmysql:execute(query, params, function(result)
        -- Cache SELECT results
        if query:lower():match("^%s*select") then
            local cacheKey = query .. (params and json.encode(params) or "")
            queryCache[cacheKey] = {
                result = result,
                timestamp = os.time()
            }
        end
        
        if cb then cb(result) end
    end)
end

-- Character Management
local function GetCharacter(identifier, cb)
    ExecuteQuery("SELECT * FROM characters WHERE identifier = ?", {identifier}, cb)
end

local function CreateCharacter(identifier, name, cb)
    ExecuteQuery(
        "INSERT INTO characters (identifier, name) VALUES (?, ?)",
        {identifier, name},
        cb
    )
end

local function UpdateCharacter(identifier, data, cb)
    local updates = {}
    local params = {}
    
    for k, v in pairs(data) do
        table.insert(updates, k .. " = ?")
        table.insert(params, v)
    end
    
    table.insert(params, identifier)
    
    ExecuteQuery(
        "UPDATE characters SET " .. table.concat(updates, ", ") .. " WHERE identifier = ?",
        params,
        cb
    )
end

-- Faction Management
local function GetFaction(factionId, cb)
    ExecuteQuery("SELECT * FROM factions WHERE id = ?", {factionId}, cb)
end

local function CreateFaction(name, type, cb)
    ExecuteQuery(
        "INSERT INTO factions (name, type) VALUES (?, ?)",
        {name, type},
        cb
    )
end

-- Gang Management
local function GetGang(gangId, cb)
    ExecuteQuery("SELECT * FROM gangs WHERE id = ?", {gangId}, cb)
end

local function CreateGang(name, color, ownerIdentifier, cb)
    ExecuteQuery(
        "INSERT INTO gangs (name, color, owner_identifier) VALUES (?, ?, ?)",
        {name, color, ownerIdentifier},
        cb
    )
end

local function AddGangMember(gangId, characterId, rank, cb)
    ExecuteQuery(
        "INSERT INTO gang_members (gang_id, character_id, rank) VALUES (?, ?, ?)",
        {gangId, characterId, rank},
        cb
    )
end

-- District Management
local function GetDistrict(districtId, cb)
    ExecuteQuery("SELECT * FROM districts WHERE id = ?", {districtId}, cb)
end

local function UpdateDistrictControl(districtId, faction, cb)
    ExecuteQuery(
        "UPDATE districts SET controlling_faction = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        {faction, districtId},
        cb
    )
end

-- Mission Management
local function CreateMission(type, difficulty, districtId, assignedTo, cb)
    ExecuteQuery(
        "INSERT INTO missions (type, difficulty, district_id, assigned_to, state, started_at) VALUES (?, ?, ?, ?, 'pending', CURRENT_TIMESTAMP)",
        {type, difficulty, districtId, assignedTo},
        cb
    )
end

local function UpdateMissionState(missionId, state, cb)
    ExecuteQuery(
        "UPDATE missions SET state = ?, completed_at = CASE WHEN ? = 'completed' THEN CURRENT_TIMESTAMP ELSE NULL END WHERE id = ?",
        {state, state, missionId},
        cb
    )
end

-- Economy Management
local function CreateTransaction(characterId, amount, type, description, cb)
    ExecuteQuery(
        "INSERT INTO transactions (character_id, amount, type, description) VALUES (?, ?, ?, ?)",
        {characterId, amount, type, description},
        cb
    )
end

local function GetCharacterBalance(characterId, cb)
    ExecuteQuery(
        "SELECT SUM(CASE WHEN type = 'deposit' THEN amount ELSE -amount END) as balance FROM transactions WHERE character_id = ?",
        {characterId},
        cb
    )
end

-- Inventory Management
local function GetCharacterInventory(characterId, cb)
    ExecuteQuery("SELECT * FROM inventory WHERE character_id = ?", {characterId}, cb)
end

local function AddItem(characterId, item, amount, cb)
    ExecuteQuery(
        "INSERT INTO inventory (character_id, item, amount) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE amount = amount + ?",
        {characterId, item, amount, amount},
        cb
    )
end

-- Skill Management
local function GetCharacterSkills(characterId, cb)
    ExecuteQuery("SELECT * FROM skills WHERE character_id = ?", {characterId}, cb)
end

local function UpdateSkill(characterId, skill, xp, cb)
    ExecuteQuery(
        "INSERT INTO skills (character_id, skill, xp) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE xp = xp + ?, level = FLOOR(xp / 1000) + 1, updated_at = CURRENT_TIMESTAMP",
        {characterId, skill, xp, xp},
        cb
    )
end

-- Clear cache periodically
CreateThread(function()
    while true do
        Wait(CACHE_TTL * 1000)
        queryCache = {}
    end
end)

-- Initialize database on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    InitializeDatabase()
end)

-- Export functions
exports('GetCharacter', GetCharacter)
exports('CreateCharacter', CreateCharacter)
exports('UpdateCharacter', UpdateCharacter)
exports('GetFaction', GetFaction)
exports('CreateFaction', CreateFaction)
exports('GetGang', GetGang)
exports('CreateGang', CreateGang)
exports('AddGangMember', AddGangMember)
exports('GetDistrict', GetDistrict)
exports('UpdateDistrictControl', UpdateDistrictControl)
exports('CreateMission', CreateMission)
exports('UpdateMissionState', UpdateMissionState)
exports('CreateTransaction', CreateTransaction)
exports('GetCharacterBalance', GetCharacterBalance)
exports('GetCharacterInventory', GetCharacterInventory)
exports('AddItem', AddItem)
exports('GetCharacterSkills', GetCharacterSkills)
exports('UpdateSkill', UpdateSkill)

-- Database Management
local Database = {
    maxRetries = 3,
    retryDelay = 1000,
    transactionTimeout = 5000
}

-- Execute query with retry
function Database.ExecuteQuery(query, params, retries)
    retries = retries or 0
    
    -- Check retry limit
    if retries >= Database.maxRetries then
        Utils.HandleError('Max retries reached for query', 'DATABASE', 'ExecuteQuery')
        return nil
    end
    
    -- Execute query
    local success, result = pcall(function()
        return MySQL.query.await(query, params)
    end)
    
    -- Handle error
    if not success then
        Utils.HandleError('Database query failed', 'DATABASE', 'ExecuteQuery')
        Wait(Database.retryDelay)
        return Database.ExecuteQuery(query, params, retries + 1)
    end
    
    return result
end

-- Execute transaction
function Database.ExecuteTransaction(queries)
    -- Start transaction
    local success, result = pcall(function()
        return MySQL.transaction.await(queries)
    end)
    
    -- Handle error
    if not success then
        Utils.HandleError('Transaction failed', 'DATABASE', 'ExecuteTransaction')
        return false
    end
    
    return true
end

-- Initialize database
function Database.Initialize()
    -- Create tables if they don't exist
    local queries = {
        [[
            CREATE TABLE IF NOT EXISTS dz_districts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(50) NOT NULL,
                owner VARCHAR(50),
                influence INT DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ]],
        [[
            CREATE TABLE IF NOT EXISTS dz_missions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(50) NOT NULL,
                description TEXT,
                reward INT DEFAULT 0,
                difficulty INT DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ]],
        [[
            CREATE TABLE IF NOT EXISTS dz_player_missions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                player_id VARCHAR(50) NOT NULL,
                mission_id INT NOT NULL,
                status VARCHAR(20) DEFAULT 'active',
                started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP NULL,
                FOREIGN KEY (mission_id) REFERENCES dz_missions(id)
            )
        ]]
    }
    
    -- Execute transaction
    if not Database.ExecuteTransaction(queries) then
        Utils.HandleError('Failed to initialize database', 'DATABASE', 'Initialize')
        return false
    end
    
    return true
end

-- Save district data
function Database.SaveDistrict(districtId, data)
    -- Prepare query
    local query = [[
        UPDATE dz_districts 
        SET owner = ?, influence = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
    ]]
    
    -- Execute query
    local result = Database.ExecuteQuery(query, {
        data.owner,
        data.influence,
        districtId
    })
    
    return result ~= nil
end

-- Load district data
function Database.LoadDistrict(districtId)
    -- Prepare query
    local query = [[
        SELECT * FROM dz_districts WHERE id = ?
    ]]
    
    -- Execute query
    local result = Database.ExecuteQuery(query, {districtId})
    
    if result and #result > 0 then
        return result[1]
    end
    
    return nil
end

-- Save mission data
function Database.SaveMission(missionId, data)
    -- Prepare query
    local query = [[
        UPDATE dz_missions 
        SET name = ?, description = ?, reward = ?, difficulty = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
    ]]
    
    -- Execute query
    local result = Database.ExecuteQuery(query, {
        data.name,
        data.description,
        data.reward,
        data.difficulty,
        missionId
    })
    
    return result ~= nil
end

-- Load mission data
function Database.LoadMission(missionId)
    -- Prepare query
    local query = [[
        SELECT * FROM dz_missions WHERE id = ?
    ]]
    
    -- Execute query
    local result = Database.ExecuteQuery(query, {missionId})
    
    if result and #result > 0 then
        return result[1]
    end
    
    return nil
end

-- Initialize database on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Initialize database
    if not Database.Initialize() then
        Utils.HandleError('Failed to initialize database', 'INIT', 'onResourceStart')
        return
    end
end)

-- Export database functions
exports('SaveDistrict', Database.SaveDistrict)
exports('LoadDistrict', Database.LoadDistrict)
exports('SaveMission', Database.SaveMission)
exports('LoadMission', Database.LoadMission) 