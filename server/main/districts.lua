local QBCore = exports['qb-core']:GetCoreObject()
local activeDistricts = {}
local districtEvents = {}
local districtPlayers = {}

-- Districts Server Handler
local QBX = exports['qbx_core']:GetSharedObject()
local districts = {}
local districtOwners = {}
local districtResources = {}
local districtInfluence = {}
local Utils = require 'shared/utils'

-- Initialize districts from config
local function InitializeDistricts()
    if not Config or not Config.Districts then
        print('[District Zero] Error: Config.Districts is not defined')
        return
    end

    -- Load districts from config or database
    districts = Config.Districts or {}
    
    -- Initialize district data
    for id, district in pairs(districts) do
        districtOwners[id] = district.owner or 'neutral'
        districtResources[id] = district.resources or {
            money = 0,
            materials = 0,
            influence = 0
        }
        districtInfluence[id] = district.influence or 0
    end
    Utils.PrintDebug("Districts initialized")
end

-- Get players in district
local function GetPlayersInDistrict(districtId)
    local district = activeDistricts[districtId]
    if not district then return {} end
    
    local players = {}
    for _, player in ipairs(GetPlayers()) do
        local ped = GetPlayerPed(player)
        local coords = GetEntityCoords(ped)
        local distance = #(coords - district.center)
        
        if distance <= district.radius then
            table.insert(players, player)
        end
    end
    return players
end

-- Update district control
local function UpdateDistrictControl(districtId)
    local district = activeDistricts[districtId]
    if not district then return end
    
    local players = GetPlayersInDistrict(districtId)
    local factionCounts = {}
    local maxCount = 0
    local controllingFaction = nil
    
    -- Count players per faction
    for _, player in ipairs(players) do
        local faction = exports['fivem-mm']:GetPlayerFaction(player)
        if faction then
            factionCounts[faction] = (factionCounts[faction] or 0) + 1
            if factionCounts[faction] > maxCount then
                maxCount = factionCounts[faction]
                controllingFaction = faction
            end
        end
    end
    
    -- Update control if changed
    if controllingFaction ~= district.controllingFaction then
        district.controllingFaction = controllingFaction
        exports['fivem-mm']:UpdateDistrictControl(districtId, controllingFaction)
        
        -- Notify players
        TriggerClientEvent('district:controlChanged', -1, districtId, controllingFaction)
        
        -- Trigger control change event
        if controllingFaction then
            TriggerEvent('district:onControlChanged', districtId, controllingFaction)
        end
    end
end

-- Check for district events
local function CheckDistrictEvents(districtId)
    local district = activeDistricts[districtId]
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
    local district = activeDistricts[districtId]
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
    local district = activeDistricts[districtId]
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
        
        for districtId, _ in pairs(activeDistricts) do
            UpdateDistrictControl(districtId)
            CheckDistrictEvents(districtId)
            EnforceDistrictRules(districtId)
        end
    end
end)

-- Player entered district
RegisterNetEvent('district:playerEntered')
AddEventHandler('district:playerEntered', function(districtId)
    local source = source
    local district = activeDistricts[districtId]
    if not district then return end
    
    -- Add player to district
    district.players[source] = true
    
    -- Notify player
    TriggerClientEvent('district:entered', source, district)
end)

-- Player left district
RegisterNetEvent('district:playerLeft')
AddEventHandler('district:playerLeft', function(districtId)
    local source = source
    local district = activeDistricts[districtId]
    if not district then return end
    
    -- Remove player from district
    district.players[source] = nil
    
    -- Notify player
    TriggerClientEvent('district:left', source, districtId)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    InitializeDistricts()
end)

-- Export functions
exports('GetDistrict', function(districtId)
    return activeDistricts[districtId]
end)

exports('GetDistrictPlayers', function(districtId)
    return activeDistricts[districtId] and activeDistricts[districtId].players or {}
end)

exports('IsPlayerInDistrict', function(playerId, districtId)
    return activeDistricts[districtId] and activeDistricts[districtId].players[playerId] or false
end)

exports('GetDistrictControllingFaction', function(districtId)
    return activeDistricts[districtId] and activeDistricts[districtId].controllingFaction or nil
end)

-- District Management
local function UpdateDistrict(id, data)
    if not districts[id] then return false end
    
    -- Update district data
    for key, value in pairs(data) do
        districts[id][key] = value
    end
    
    -- Notify all clients
    TriggerClientEvent('district:update', -1, id, districts[id])
    
    return true
end

local function SetDistrictOwner(id, owner)
    if not districts[id] then return false end
    
    districtOwners[id] = owner
    districts[id].owner = owner
    
    -- Notify all clients
    TriggerClientEvent('district:ownerUpdate', -1, id, owner)
    
    return true
end

local function UpdateDistrictResources(id, resourceType, amount)
    if not districts[id] then return false end
    if not districtResources[id] then return false end
    
    districtResources[id][resourceType] = (districtResources[id][resourceType] or 0) + amount
    districts[id].resources = districtResources[id]
    
    -- Notify all clients
    TriggerClientEvent('district:resourceUpdate', -1, id, resourceType, districtResources[id][resourceType])
    
    return true
end

local function UpdateDistrictInfluence(id, amount)
    if not districts[id] then return false end
    
    districtInfluence[id] = (districtInfluence[id] or 0) + amount
    districts[id].influence = districtInfluence[id]
    
    -- Notify all clients
    TriggerClientEvent('district:influenceUpdate', -1, id, districtInfluence[id])
    
    return true
end

-- Event Handlers
RegisterNetEvent('district:requestUpdate')
AddEventHandler('district:requestUpdate', function()
    local source = source
    TriggerClientEvent('district:update', source, districts)
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
    return districts
end)

exports('GetDistrictOwner', function(districtId)
    return districtOwners[districtId]
end)

exports('GetDistrictResources', function(districtId)
    return districtResources[districtId]
end)

exports('GetDistrictInfluence', function(districtId)
    return districtInfluence[districtId]
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