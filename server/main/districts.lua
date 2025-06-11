local QBCore = exports['qb-core']:GetCoreObject()
local activeDistricts = {}
local districtEvents = {}
local districtPlayers = {}

-- Districts Server Handler
local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'

-- State Management
local State = {
    districts = {},
    owners = {},
    resources = {},
    influence = {},
    players = {}
}

-- District State Management
local DistrictState = {
    districts = {},
    players = {},
    lastSync = 0,
    syncInterval = 5000, -- 5 seconds
    maxRetries = 3,
    retryDelay = 1000
}

-- Initialize districts from config
local function InitializeDistricts()
    if not Config or not Config.Districts then
        Utils.HandleError('Config.Districts is not defined', 'VALIDATION', 'InitializeDistricts')
        return
    end

    -- Load districts from config or database
    State.districts = Config.Districts or {}
    
    -- Initialize district data
    for id, district in pairs(State.districts) do
        State.owners[id] = district.owner or 'neutral'
        State.resources[id] = district.resources or {
            money = 0,
            materials = 0,
            influence = 0
        }
        State.influence[id] = district.influence or 0
        State.players[id] = {}
    end
    
    Utils.PrintDebug("Districts initialized")
end

-- Get players in district
local function GetPlayersInDistrict(districtId)
    if not State.districts[districtId] then return {} end
    
    local players = {}
    for _, player in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local distance = #(coords - State.districts[districtId].center)
        
        if distance <= State.districts[districtId].radius then
            table.insert(players, player)
        end
    end
    return players
end

-- Update district control
local function UpdateDistrictControl(districtId, factionId)
    if not State.districts[districtId] then return false end
    
    State.owners[districtId] = factionId
    
    -- Notify all clients
    TriggerClientEvent('dz:district:update', -1, districtId, {
        owner = factionId,
        resources = State.resources[districtId],
        influence = State.influence[districtId]
    })
    
    return true
end

-- Check for district events
local function CheckDistrictEvents(districtId)
    local district = State.districts[districtId]
    if not district then return end
    
    -- Check event cooldown
    if district.eventCooldown > os.time() then return end
    
    -- Random event chance
    if math.random() < 0.1 then -- 10% chance per check
        local eventType = district.eventHooks[math.random(#district.eventHooks)]
        TriggerEvent('district:triggerEvent', districtId, eventType)
    end
end

-- Handle district events
RegisterNetEvent('district:triggerEvent')
AddEventHandler('district:triggerEvent', function(districtId, eventType)
    local district = State.districts[districtId]
    if not district then return end
    
    -- Set event cooldown
    district.eventCooldown = os.time() + 300 -- 5 minutes
    district.lastEvent = eventType
    
    -- Trigger event based on type
    if eventType == "raid" then
        TriggerEvent('district:startRaid', districtId)
    elseif eventType == "emergency" then
        TriggerEvent('district:startEmergency', districtId)
    elseif eventType == "turf_war" then
        TriggerEvent('district:startTurfWar', districtId)
    elseif eventType == "npc_gang_attack" then
        TriggerEvent('district:startNPCAttack', districtId)
    elseif eventType == "npc_patrol" then
        TriggerEvent('district:startNPCPatrol', districtId)
    end
    
    -- Notify players
    TriggerClientEvent('district:eventStarted', -1, districtId, eventType)
end)

-- PvP/PvE rule enforcement
local function EnforceDistrictRules(districtId)
    local district = State.districts[districtId]
    if not district then return end
    
    local players = GetPlayersInDistrict(districtId)
    for _, player in ipairs(players) do
        -- PvP rules
        if not district.pvpEnabled then
            -- Disable PvP damage
            SetCanAttackFriendly(GetPlayerPed(player), false, false)
        end
        
        -- PvE rules
        if not district.pveEnabled then
            -- Disable NPC damage
            SetPedCanRagdoll(GetPlayerPed(player), false)
        end
    end
end

-- District monitoring thread
CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        
        for districtId, _ in pairs(State.districts) do
            UpdateDistrictControl(districtId, State.owners[districtId])
            CheckDistrictEvents(districtId)
            EnforceDistrictRules(districtId)
        end
    end
end)

-- Player entered district
RegisterNetEvent('dz:district:playerEntered')
AddEventHandler('dz:district:playerEntered', function(districtId)
    local source = source
    if not State.districts[districtId] then return end
    
    -- Add player to district
    State.players[districtId][source] = true
    
    -- Notify player
    TriggerClientEvent('dz:district:entered', source, State.districts[districtId])
end)

-- Player left district
RegisterNetEvent('dz:district:playerLeft')
AddEventHandler('dz:district:playerLeft', function(districtId)
    local source = source
    if not State.districts[districtId] then return end
    
    -- Remove player from district
    State.players[districtId][source] = nil
    
    -- Notify player
    TriggerClientEvent('dz:district:left', source, districtId)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeDistricts()
    
    -- Initialize district state
    if not InitializeDistrictState() then
        Utils.HandleError('Failed to initialize district state', 'INIT', 'onResourceStart')
        return
    end
    
    -- Start state sync loop
    CreateThread(function()
        while true do
            SyncDistrictState()
            Wait(DistrictState.syncInterval)
        end
    end)
end)

-- Resource stop handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Cleanup state
    State = {
        districts = {},
        owners = {},
        resources = {},
        influence = {},
        players = {}
    }
    
    -- Save district state to database
    for _, district in pairs(DistrictState.districts) do
        MySQL.update('UPDATE dz_districts SET owner = ?, influence = ? WHERE id = ?', {
            district.owner,
            district.influence,
            district.id
        })
    end
end)

-- Exports
exports('GetDistrict', function(districtId)
    return State.districts[districtId]
end)

exports('GetDistrictPlayers', function(districtId)
    return State.players[districtId] or {}
end)

exports('IsPlayerInDistrict', function(playerId, districtId)
    return State.players[districtId] and State.players[districtId][playerId] or false
end)

exports('GetDistrictControllingFaction', function(districtId)
    return State.owners[districtId]
end)

exports('GetDistrictResources', function(districtId)
    return State.resources[districtId]
end)

exports('GetDistrictInfluence', function(districtId)
    return State.influence[districtId]
end)

exports('UpdateDistrict', function(districtId, data)
    if not State.districts[districtId] then return false end
    
    -- Update district data
    for key, value in pairs(data) do
        State.districts[districtId][key] = value
    end
    
    -- Notify all clients
    TriggerClientEvent('dz:district:update', -1, districtId, State.districts[districtId])
    
    return true
end)

exports('SetDistrictOwner', function(districtId, owner)
    return UpdateDistrictControl(districtId, owner)
end)

exports('UpdateDistrictResources', function(districtId, resourceType, amount)
    if not State.districts[districtId] then return false end
    if not State.resources[districtId][resourceType] then return false end
    
    State.resources[districtId][resourceType] = State.resources[districtId][resourceType] + amount
    
    -- Notify all clients
    TriggerClientEvent('dz:district:update', -1, districtId, {
        resources = State.resources[districtId]
    })
    
    return true
end)

exports('UpdateDistrictInfluence', function(districtId, amount)
    if not State.districts[districtId] then return false end
    
    State.influence[districtId] = State.influence[districtId] + amount
    
    -- Notify all clients
    TriggerClientEvent('dz:district:update', -1, districtId, {
        influence = State.influence[districtId]
    })
    
    return true
end)

-- Event Handlers
RegisterNetEvent('district:requestUpdate')
AddEventHandler('district:requestUpdate', function()
    local source = source
    TriggerClientEvent('district:update', source, State.districts)
end)

RegisterNetEvent('district:captureAttempt')
AddEventHandler('district:captureAttempt', function(districtId)
    local source = source
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end
    
    -- Check if player has required items/permissions
    -- Add your capture logic here
    
    -- Example capture logic
    if math.random() < 0.5 then -- 50% chance of success
        SetDistrictOwner(districtId, player.PlayerData.citizenid)
        TriggerClientEvent('QBCore:Notify', source, 'District captured successfully!', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to capture district', 'error')
    end
end)

-- Commands
QBX.Commands.Add('setdistrictowner', 'Set district owner (Admin Only)', {
    {name = 'districtId', help = 'District ID'},
    {name = 'owner', help = 'Owner ID or "neutral"'}
}, true, function(source, args)
    local districtId = tonumber(args[1])
    local owner = args[2]
    
    if SetDistrictOwner(districtId, owner) then
        TriggerClientEvent('QBCore:Notify', source, 'District owner updated', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to update district owner', 'error')
    end
end, 'admin')

QBX.Commands.Add('updatedistrict', 'Update district data (Admin Only)', {
    {name = 'districtId', help = 'District ID'},
    {name = 'key', help = 'Data key'},
    {name = 'value', help = 'New value'}
}, true, function(source, args)
    local districtId = tonumber(args[1])
    local key = args[2]
    local value = args[3]
    
    if UpdateDistrict(districtId, {[key] = value}) then
        TriggerClientEvent('QBCore:Notify', source, 'District updated', 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, 'Failed to update district', 'error')
    end
end, 'admin')

-- Exports
exports('GetDistricts', function()
    return State.districts
end)

exports('GetDistrictOwner', function(districtId)
    return State.owners[districtId]
end)

exports('GetDistrictResources', function(districtId)
    return State.resources[districtId]
end)

exports('GetDistrictInfluence', function(districtId)
    return State.influence[districtId]
end)

exports('UpdateDistrict', function(districtId, data)
    return UpdateDistrict(districtId, data)
end)

exports('SetDistrictOwner', function(districtId, owner)
    return SetDistrictOwner(districtId, owner)
end)

exports('UpdateDistrictResources', function(districtId, resourceType, amount)
    return UpdateDistrictResources(districtId, resourceType, amount)
end)

exports('UpdateDistrictInfluence', function(districtId, amount)
    return UpdateDistrictInfluence(districtId, amount)
end) 

-- Initialize district state
local function InitializeDistrictState()
    -- Load districts from database
    local success, result = pcall(function()
        return MySQL.query.await('SELECT * FROM dz_districts')
    end)
    
    if not success then
        Utils.HandleError('Failed to load districts from database', 'DATABASE', 'InitializeDistrictState')
        return false
    end
    
    -- Initialize district state
    for _, district in ipairs(result) do
        DistrictState.districts[district.id] = {
            id = district.id,
            name = district.name,
            owner = district.owner,
            influence = district.influence,
            lastUpdate = os.time(),
            players = {},
            isActive = false
        }
    end
    
    return true
end

-- Sync district state
local function SyncDistrictState()
    local currentTime = GetGameTimer()
    
    -- Check if it's time to sync
    if currentTime - DistrictState.lastSync < DistrictState.syncInterval then
        return
    end
    
    -- Update last sync time
    DistrictState.lastSync = currentTime
    
    -- Sync district state to all clients
    for _, player in ipairs(GetPlayers()) do
        local playerDistricts = {}
        
        -- Get player's current districts
        for districtId, district in pairs(DistrictState.districts) do
            if district.players[player] then
                table.insert(playerDistricts, {
                    id = district.id,
                    name = district.name,
                    owner = district.owner,
                    influence = district.influence,
                    isActive = district.isActive
                })
            end
        end
        
        -- Send district state to player
        TriggerClientEvent('dz:syncDistricts', player, playerDistricts)
    end
end

-- Update district state
local function UpdateDistrictState(districtId, data)
    local district = DistrictState.districts[districtId]
    if not district then
        return false
    end
    
    -- Update district data
    for key, value in pairs(data) do
        if district[key] ~= nil then
            district[key] = value
        end
    end
    
    -- Update last update time
    district.lastUpdate = os.time()
    
    -- Sync state to all players in district
    for player, _ in pairs(district.players) do
        TriggerClientEvent('dz:updateDistrict', player, districtId, data)
    end
    
    return true
end

-- Add player to district
local function AddPlayerToDistrict(player, districtId)
    local district = DistrictState.districts[districtId]
    if not district then
        return false
    end
    
    -- Add player to district
    district.players[player] = true
    DistrictState.players[player] = districtId
    
    -- Notify player
    TriggerClientEvent('dz:enterDistrict', player, districtId)
    
    return true
end

-- Remove player from district
local function RemovePlayerFromDistrict(player, districtId)
    local district = DistrictState.districts[districtId]
    if not district then
        return false
    end
    
    -- Remove player from district
    district.players[player] = nil
    DistrictState.players[player] = nil
    
    -- Notify player
    TriggerClientEvent('dz:exitDistrict', player, districtId)
    
    return true
end

-- Export district state functions
exports('GetDistrictState', function(districtId)
    return DistrictState.districts[districtId]
end)

exports('UpdateDistrictState', UpdateDistrictState)
exports('AddPlayerToDistrict', AddPlayerToDistrict)
exports('RemovePlayerFromDistrict', RemovePlayerFromDistrict) 