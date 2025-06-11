local QBCore = exports['qb-core']:GetCoreObject()
local activeDistricts = {}
local districtEvents = {}
local districtPlayers = {}

-- Initialize districts
local function InitializeDistricts()
    for _, district in pairs(Config.Districts) do
        activeDistricts[district.id] = {
            id = district.id,
            name = district.name,
            center = district.center,
            radius = district.radius,
            controllingFaction = nil,
            eventHooks = district.eventHooks,
            pvpEnabled = district.pvpEnabled,
            pveEnabled = district.pveEnabled,
            players = {},
            lastEvent = nil,
            eventCooldown = 0
        }
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