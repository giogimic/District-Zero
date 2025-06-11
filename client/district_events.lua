-- District Events Client Handler
local QBX = exports['qbx_core']:GetCoreObject()
local activeNPCs = {}
local eventObjectives = {}
local eventBlips = {}

-- NPC Configurations
local npcConfigs = {
    raid = {
        count = 8,
        models = {
            'g_m_y_salvagoon_01',
            'g_m_y_salvagoon_02',
            'g_m_y_salvagoon_03'
        },
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_SMG',
            'WEAPON_CARBINERIFLE'
        },
        health = 200,
        armor = 100
    },
    emergency = {
        count = 4,
        models = {
            's_m_m_paramedic_01',
            's_m_m_doctor_01',
            's_m_m_fireman_01'
        },
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_STUNGUN'
        },
        health = 150,
        armor = 50
    },
    turf_war = {
        count = 12,
        models = {
            'g_m_y_salvagoon_01',
            'g_m_y_salvagoon_02',
            'g_m_y_salvagoon_03',
            'g_m_y_mexgoon_01',
            'g_m_y_mexgoon_02',
            'g_m_y_mexgoon_03'
        },
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_SMG',
            'WEAPON_CARBINERIFLE',
            'WEAPON_SHOTGUN'
        },
        health = 250,
        armor = 150
    },
    gang_attack = {
        count = 6,
        models = {
            'g_m_y_mexgoon_01',
            'g_m_y_mexgoon_02',
            'g_m_y_mexgoon_03',
            'g_m_y_salvagoon_01',
            'g_m_y_salvagoon_02',
            'g_m_y_salvagoon_03'
        },
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_SMG',
            'WEAPON_CARBINERIFLE'
        },
        health = 200,
        armor = 100
    },
    patrol = {
        count = 2,
        models = {
            's_m_m_security_01',
            's_m_y_swat_01',
            's_m_y_cop_01'
        },
        weapons = {
            'WEAPON_PISTOL',
            'WEAPON_STUNGUN',
            'WEAPON_CARBINERIFLE'
        },
        health = 150,
        armor = 100
    }
}

-- Helper Functions
local function GetRandomPosition(center, radius)
    local angle = math.random() * 2 * math.pi
    local r = radius * math.sqrt(math.random())
    local x = center.x + r * math.cos(angle)
    local y = center.y + r * math.sin(angle)
    local z = center.z
    
    -- Get ground Z coordinate
    local ground, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    if ground then
        return vector3(x, y, groundZ)
    end
    return vector3(x, y, z)
end

local function CreateEventBlip(coords, sprite, color, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function SpawnNPCs(eventType, district)
    local config = npcConfigs[eventType]
    if not config then return end
    
    local center = district.center
    local radius = district.radius
    
    for i = 1, config.count do
        local model = config.models[math.random(#config.models)]
        local weapon = config.weapons[math.random(#config.weapons)]
        local position = GetRandomPosition(center, radius)
        
        -- Request and load model
        local hash = GetHashKey(model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(0)
        end
        
        -- Create NPC
        local ped = CreatePed(4, hash, position.x, position.y, position.z, 0.0, true, false)
        SetPedArmour(ped, config.armor)
        SetEntityHealth(ped, config.health)
        GiveWeaponToPed(ped, GetHashKey(weapon), 999, false, true)
        SetPedCombatAttributes(ped, 46, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedAsEnemy(ped, true)
        SetPedMaxHealth(ped, config.health)
        SetPedAlertness(ped, 3)
        SetPedAccuracy(ped, 60)
        SetPedCombatRange(ped, 2)
        SetPedCombatMovement(ped, 3)
        
        -- Add to active NPCs
        table.insert(activeNPCs, {
            ped = ped,
            eventType = eventType,
            districtId = district.id
        })
        
        -- Set model as no longer needed
        SetModelAsNoLongerNeeded(hash)
    end
end

-- Event Handlers
RegisterNetEvent('district:spawnRaidNPCs', function(district)
    SpawnNPCs('raid', district)
    local blip = CreateEventBlip(district.center, 1, 1, 'Raid Objective')
    table.insert(eventBlips, blip)
end)

RegisterNetEvent('district:spawnEmergencyNPCs', function(district)
    SpawnNPCs('emergency', district)
    local blip = CreateEventBlip(district.center, 1, 2, 'Emergency Response')
    table.insert(eventBlips, blip)
end)

RegisterNetEvent('district:spawnTurfWarNPCs', function(district)
    SpawnNPCs('turf_war', district)
    local blip = CreateEventBlip(district.center, 1, 3, 'Turf War')
    table.insert(eventBlips, blip)
end)

RegisterNetEvent('district:spawnGangAttackNPCs', function(district)
    SpawnNPCs('gang_attack', district)
    local blip = CreateEventBlip(district.center, 1, 4, 'Gang Attack')
    table.insert(eventBlips, blip)
end)

RegisterNetEvent('district:spawnPatrolNPCs', function(district)
    SpawnNPCs('patrol', district)
    local blip = CreateEventBlip(district.center, 1, 5, 'Patrol')
    table.insert(eventBlips, blip)
end)

RegisterNetEvent('district:cleanupEvent', function()
    -- Remove NPCs
    for _, npc in ipairs(activeNPCs) do
        if DoesEntityExist(npc.ped) then
            DeleteEntity(npc.ped)
        end
    end
    activeNPCs = {}
    
    -- Remove blips
    for _, blip in ipairs(eventBlips) do
        RemoveBlip(blip)
    end
    eventBlips = {}
    
    -- Clear objectives
    eventObjectives = {}
end)

-- Threads
CreateThread(function()
    while true do
        Wait(1000)
        
        -- Check for NPC deaths
        for i = #activeNPCs, 1, -1 do
            local npc = activeNPCs[i]
            if not DoesEntityExist(npc.ped) or IsEntityDead(npc.ped) then
                table.remove(activeNPCs, i)
                
                -- If all NPCs are dead, notify server
                if #activeNPCs == 0 then
                    TriggerServerEvent('district:eventComplete', npc.districtId, npc.eventType)
                end
            end
        end
    end
end)

-- Exports
exports('GetActiveNPCs', function()
    return activeNPCs
end)

exports('GetEventObjectives', function()
    return eventObjectives
end) 