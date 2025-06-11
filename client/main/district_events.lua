-- District Events Client Handler
local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'
local activeEvents = {}
local eventBlips = {}
local eventNPCs = {}

-- Error handling wrapper
local function SafeCall(fn, ...)
    local status, result = pcall(fn, ...)
    if not status then
        print('[District Zero] Error:', result)
        return nil
    end
    return result
end

-- Event cleanup
local function CleanupEvent(districtId)
    if eventBlips[districtId] then
        RemoveBlip(eventBlips[districtId])
        eventBlips[districtId] = nil
    end
    
    if eventNPCs[districtId] then
        for _, npc in pairs(eventNPCs[districtId]) do
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
        end
        eventNPCs[districtId] = nil
    end
end

-- Event handlers with error handling
RegisterNetEvent('district:spawnRaidNPCs', function(district)
    SafeCall(function()
        if not district or not district.center then
            print('[District Zero] Error: Invalid district data for raid')
            return
        end

        local npcs = {}
        local numNPCs = math.random(3, 6)
        
        for i = 1, numNPCs do
            local offset = vector3(
                math.random(-10.0, 10.0),
                math.random(-10.0, 10.0),
                0.0
            )
            local coords = district.center + offset
            
            local ped = CreatePed(4, Config.NPCModels.gang, coords.x, coords.y, coords.z, 0.0, true, true)
            if DoesEntityExist(ped) then
                SetPedArmour(ped, 100)
                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 999, false, true)
                SetPedCombatAttributes(ped, 46, true)
                table.insert(npcs, ped)
            end
        end
        
        eventNPCs[district.id] = npcs
    end)
end)

RegisterNetEvent('district:spawnEmergencyNPCs', function(district)
    SafeCall(function()
        if not district or not district.center then
            print('[District Zero] Error: Invalid district data for emergency')
            return
        end

        local npcs = {}
        local numNPCs = math.random(2, 4)
        
        for i = 1, numNPCs do
            local offset = vector3(
                math.random(-8.0, 8.0),
                math.random(-8.0, 8.0),
                0.0
            )
            local coords = district.center + offset
            
            local ped = CreatePed(4, Config.NPCModels.police, coords.x, coords.y, coords.z, 0.0, true, true)
            if DoesEntityExist(ped) then
                SetPedArmour(ped, 100)
                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 999, false, true)
                SetPedCombatAttributes(ped, 46, true)
                table.insert(npcs, ped)
            end
        end
        
        eventNPCs[district.id] = npcs
    end)
end)

RegisterNetEvent('district:spawnTurfWarNPCs', function(district)
    SafeCall(function()
        if not district or not district.center then
            print('[District Zero] Error: Invalid district data for turf war')
            return
        end

        local npcs = {}
        local numNPCs = math.random(4, 8)
        
        for i = 1, numNPCs do
            local offset = vector3(
                math.random(-15.0, 15.0),
                math.random(-15.0, 15.0),
                0.0
            )
            local coords = district.center + offset
            
            local ped = CreatePed(4, Config.NPCModels.gang, coords.x, coords.y, coords.z, 0.0, true, true)
            if DoesEntityExist(ped) then
                SetPedArmour(ped, 100)
                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 999, false, true)
                SetPedCombatAttributes(ped, 46, true)
                table.insert(npcs, ped)
            end
        end
        
        eventNPCs[district.id] = npcs
    end)
end)

RegisterNetEvent('district:spawnGangAttackNPCs', function(district)
    SafeCall(function()
        if not district or not district.center then
            print('[District Zero] Error: Invalid district data for gang attack')
            return
        end

        local npcs = {}
        local numNPCs = math.random(3, 6)
        
        for i = 1, numNPCs do
            local offset = vector3(
                math.random(-12.0, 12.0),
                math.random(-12.0, 12.0),
                0.0
            )
            local coords = district.center + offset
            
            local ped = CreatePed(4, Config.NPCModels.gang, coords.x, coords.y, coords.z, 0.0, true, true)
            if DoesEntityExist(ped) then
                SetPedArmour(ped, 100)
                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 999, false, true)
                SetPedCombatAttributes(ped, 46, true)
                table.insert(npcs, ped)
            end
        end
        
        eventNPCs[district.id] = npcs
    end)
end)

RegisterNetEvent('district:spawnPatrolNPCs', function(district)
    SafeCall(function()
        if not district or not district.center then
            print('[District Zero] Error: Invalid district data for patrol')
            return
        end

        local npcs = {}
        local numNPCs = math.random(2, 4)
        
        for i = 1, numNPCs do
            local offset = vector3(
                math.random(-10.0, 10.0),
                math.random(-10.0, 10.0),
                0.0
            )
            local coords = district.center + offset
            
            local ped = CreatePed(4, Config.NPCModels.police, coords.x, coords.y, coords.z, 0.0, true, true)
            if DoesEntityExist(ped) then
                SetPedArmour(ped, 100)
                GiveWeaponToPed(ped, GetHashKey('WEAPON_PISTOL'), 999, false, true)
                SetPedCombatAttributes(ped, 46, true)
                table.insert(npcs, ped)
            end
        end
        
        eventNPCs[district.id] = npcs
    end)
end)

RegisterNetEvent('district:cleanupEvent', function()
    SafeCall(function()
        for districtId, _ in pairs(eventNPCs) do
            CleanupEvent(districtId)
        end
    end)
end)

-- Event completion handlers
RegisterNetEvent('district:eventComplete', function(districtId, eventType)
    SafeCall(function()
        if not districtId or not eventType then
            print('[District Zero] Error: Invalid event completion data')
            return
        end

        CleanupEvent(districtId)
        QBX.Functions.Notify(Lang:t('success.event_completed'), 'success')
    end)
end)

RegisterNetEvent('district:eventFailed', function(districtId, eventType)
    SafeCall(function()
        if not districtId or not eventType then
            print('[District Zero] Error: Invalid event failure data')
            return
        end

        CleanupEvent(districtId)
        QBX.Functions.Notify(Lang:t('error.event_failed'), 'error')
    end)
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for districtId, _ in pairs(eventNPCs) do
            CleanupEvent(districtId)
        end
    end
end)

-- Event Handlers
RegisterNetEvent('dz:district:event:start')
AddEventHandler('dz:district:event:start', function(districtId, eventType, eventData)
    -- Handle event start
    Utils.PrintDebug('Event started: ' .. eventType)
    
    -- Update UI
    SendNUIMessage({
        type = 'event:start',
        districtId = districtId,
        eventType = eventType,
        eventData = eventData
    })
end)

RegisterNetEvent('dz:district:event:end')
AddEventHandler('dz:district:event:end', function(districtId, success)
    -- Handle event end
    Utils.PrintDebug('Event ended: ' .. (success and 'success' or 'failure'))
    
    -- Update UI
    SendNUIMessage({
        type = 'event:end',
        districtId = districtId,
        success = success
    })
end)

RegisterNetEvent('dz:district:event:progress')
AddEventHandler('dz:district:event:progress', function(districtId, progress)
    -- Handle progress update
    Utils.PrintDebug('Event progress: ' .. progress)
    
    -- Update UI
    SendNUIMessage({
        type = 'event:progress',
        districtId = districtId,
        progress = progress
    })
end)

RegisterNetEvent('dz:district:event:update')
AddEventHandler('dz:district:event:update', function(districtId, eventData)
    -- Handle event update
    Utils.PrintDebug('Event updated')
    
    -- Update UI
    SendNUIMessage({
        type = 'event:update',
        districtId = districtId,
        eventData = eventData
    })
end)

-- NUI Callbacks
RegisterNUICallback('event:join', function(data, cb)
    Utils.TriggerServerEvent('district:event:join', data.districtId)
    cb('ok')
end)

RegisterNUICallback('event:leave', function(data, cb)
    Utils.TriggerServerEvent('district:event:leave', data.districtId)
    cb('ok')
end)

RegisterNUICallback('event:progress:update', function(data, cb)
    Utils.TriggerServerEvent('district:event:progress:update', data.districtId, data.progress)
    cb('ok')
end) 