-- District Zero Client
-- Version: 1.0.0

-- Try to get QBX Core with comprehensive error handling
local QBX = nil
local qbxLoaded = false

-- Try multiple QBX Core export names
local qbxExports = {
    'qbx_core',
    'qb-core',
    'qb_core'
}

for _, exportName in ipairs(qbxExports) do
    local success, result = pcall(function()
        return exports[exportName]:GetCoreObject()
    end)
    
    if success and result then
        QBX = result
        qbxLoaded = true
        print('^2[District Zero] Successfully loaded QBX Core from: ' .. exportName .. '^7')
        break
    else
        print('^3[District Zero] Failed to load from ' .. exportName .. ': ' .. tostring(result) .. '^7')
    end
end

if not qbxLoaded then
    print('^1[District Zero] WARNING: QBX Core not available. Some features may not work properly.^7')
    print('^3[District Zero] Make sure qbx_core is started before district-zero^7')
end

local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- State management
local State = {
    isUIOpen = false,
    currentDistrict = nil,
    currentTeam = nil,
    currentMission = nil,
    isInitialized = false
}

-- Optimized Blip Management System
local BlipManager = {
    blips = {},
    lastCleanup = 0,
    cleanupInterval = 30000, -- 30 seconds
    maxBlips = 100 -- Prevent excessive blip creation
}

-- Create a blip with proper error handling
local function CreateBlip(data)
    if not data or not data.coords then
        Utils.PrintDebug('[ERROR] Invalid blip data provided')
        return nil
    end
    
    -- Check blip limit
    local blipCount = 0
    for _ in pairs(BlipManager.blips) do
        blipCount = blipCount + 1
    end
    
    if blipCount >= BlipManager.maxBlips then
        Utils.PrintDebug('[WARNING] Maximum blip limit reached, cleaning up old blips')
        BlipManager.CleanupOldBlips()
    end
    
    local success, blip = pcall(function()
        local newBlip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        if not newBlip or newBlip == 0 then
            return nil
        end
        
        SetBlipSprite(newBlip, data.sprite or 1)
        SetBlipDisplay(newBlip, data.display or 4)
        SetBlipScale(newBlip, data.scale or 0.8)
        SetBlipColour(newBlip, data.color or 0)
        SetBlipAsShortRange(newBlip, data.shortRange ~= false)
        
        if data.name then
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(data.name)
            EndTextCommandSetBlipName(newBlip)
        end
        
        return newBlip
    end)
    
    if not success or not blip then
        Utils.PrintDebug('[ERROR] Failed to create blip: ' .. (data.name or 'unknown'))
        return nil
    end
    
    return blip
end

-- Remove a blip safely
local function RemoveBlip(blipId)
    if not blipId then return end
    
    local blip = BlipManager.blips[blipId]
    if blip then
        local success = pcall(function()
            RemoveBlip(blip)
        end)
        
        if not success then
            Utils.PrintDebug('[WARNING] Failed to remove blip: ' .. blipId)
        end
        
        BlipManager.blips[blipId] = nil
    end
end

-- BlipManager methods
BlipManager.CreateMissionBlip = function(mission)
    if not mission or not mission.id then
        Utils.PrintDebug('[ERROR] Invalid mission data for blip creation')
        return
    end
    
    -- Remove existing blip if it exists
    BlipManager.RemoveMissionBlip(mission.id)
    
    local blipData = {
        coords = mission.coords or mission.location,
        sprite = mission.blip and mission.blip.sprite or 1,
        scale = mission.blip and mission.blip.scale or 0.8,
        color = mission.blip and mission.blip.color or 0,
        name = mission.title or 'Mission',
        shortRange = true
    }
    
    local blip = CreateBlip(blipData)
    if blip then
        BlipManager.blips['mission_' .. mission.id] = blip
        Utils.PrintDebug('Created mission blip: ' .. mission.id)
    end
end

BlipManager.RemoveMissionBlip = function(missionId)
    RemoveBlip('mission_' .. missionId)
end

BlipManager.ClearMissionBlips = function()
    local toRemove = {}
    for blipId, _ in pairs(BlipManager.blips) do
        if string.find(blipId, 'mission_') then
            table.insert(toRemove, blipId)
        end
    end
    
    for _, blipId in ipairs(toRemove) do
        RemoveBlip(blipId)
    end
    
    Utils.PrintDebug('Cleared ' .. #toRemove .. ' mission blips')
end

BlipManager.CreateDistrictBlips = function()
    if not Config or not Config.Districts then
        Utils.PrintDebug('[ERROR] Config.Districts not available')
        return
    end
    
    -- Clear existing district blips
    BlipManager.ClearDistrictBlips()
    
    -- Create district blips
    for _, district in pairs(Config.Districts) do
        if district.blip and district.blip.coords then
            local blipData = {
                coords = district.blip.coords,
                sprite = district.blip.sprite or 1,
                scale = district.blip.scale or 1.0,
                color = district.blip.color or 0,
                name = district.name .. " (Conflict Zone)",
                shortRange = true
            }
            
            local blip = CreateBlip(blipData)
            if blip then
                BlipManager.blips['district_' .. district.id] = blip
            end
            
            -- Create control point blips
            if district.controlPoints then
                for _, point in pairs(district.controlPoints) do
                    if point.coords then
                        local pointBlipData = {
                            coords = point.coords,
                            sprite = 1,
                            scale = 0.6,
                            color = 0,
                            name = point.name or 'Control Point',
                            shortRange = true
                        }
                        
                        local pointBlip = CreateBlip(pointBlipData)
                        if pointBlip then
                            BlipManager.blips['control_' .. point.id] = pointBlip
                        end
                    end
                end
            end
        end
    end
    
    -- Create safe zone blips
    if Config.SafeZones then
        for _, safeZone in pairs(Config.SafeZones) do
            if safeZone.coords then
                local blipData = {
                    coords = safeZone.coords,
                    sprite = safeZone.blip and safeZone.blip.sprite or 1,
                    scale = safeZone.blip and safeZone.blip.scale or 1.0,
                    color = safeZone.blip and safeZone.blip.color or 2,
                    name = safeZone.name .. " (Safe Zone)",
                    shortRange = true
                }
                
                local blip = CreateBlip(blipData)
                if blip then
                    BlipManager.blips['safe_' .. safeZone.name] = blip
                end
            end
        end
    end
    
    Utils.PrintDebug('Created district blips successfully')
end

BlipManager.ClearDistrictBlips = function()
    local toRemove = {}
    for blipId, _ in pairs(BlipManager.blips) do
        if string.find(blipId, 'district_') or string.find(blipId, 'control_') or string.find(blipId, 'safe_') then
            table.insert(toRemove, blipId)
        end
    end
    
    for _, blipId in ipairs(toRemove) do
        RemoveBlip(blipId)
    end
    
    Utils.PrintDebug('Cleared ' .. #toRemove .. ' district blips')
end

BlipManager.CleanupOldBlips = function()
    local currentTime = GetGameTimer()
    if currentTime - BlipManager.lastCleanup < BlipManager.cleanupInterval then
        return
    end
    
    BlipManager.lastCleanup = currentTime
    
    -- Remove any invalid blips
    local toRemove = {}
    for blipId, blip in pairs(BlipManager.blips) do
        if not DoesBlipExist(blip) then
            table.insert(toRemove, blipId)
        end
    end
    
    for _, blipId in ipairs(toRemove) do
        BlipManager.blips[blipId] = nil
    end
    
    if #toRemove > 0 then
        Utils.PrintDebug('Cleaned up ' .. #toRemove .. ' invalid blips')
    end
end

BlipManager.GetBlipCount = function()
    local count = 0
    for _ in pairs(BlipManager.blips) do
        count = count + 1
    end
    return count
end

-- Mission and district checks
local function CheckObjectiveCompletion()
    if not State.currentMission then return end

    for i, objective in ipairs(State.currentMission.objectives) do
        if not objective.completed then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(objective.coords.x, objective.coords.y, objective.coords.z))
            
            if distance <= objective.radius then
                if objective.type == 'capture' then
                    QBX.Functions.DrawText3D(objective.coords.x, objective.coords.y, objective.coords.z, 'Press [E] to capture')
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent('dz:server:capturePoint', State.currentMission.id, i)
                    end
                elseif objective.type == 'eliminate' then
                    QBX.Functions.DrawText3D(objective.coords.x, objective.coords.y, objective.coords.z, 'Eliminate all targets')
                    -- Add elimination logic here
                end
            end
        end
    end
end

local function CheckDistrictBoundaries()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local inDistrict = false
    local inSafeZone = false
    local districtFound = nil

    -- Check if in safe zone first
    if Config.SafeZones then
        for _, safeZone in pairs(Config.SafeZones) do
            local distance = #(playerCoords - safeZone.coords)
            if distance <= safeZone.radius then
                inSafeZone = true
                break
            end
        end
    end

    -- Check if in district
    if Config.Districts then
        for _, district in pairs(Config.Districts) do
            if district.zones then
                for _, zone in pairs(district.zones) do
                    local distance = #(playerCoords - zone.coords)
                    if distance <= zone.radius then
                        inDistrict = true
                        districtFound = district
                        break
                    end
                end
            end
            if inDistrict then break end
        end
    end

    if inSafeZone then
        -- In safe zone - no missions, no team restrictions
        State.currentDistrict = nil
        State.currentTeam = nil
        SendNUIMessage({
            type = 'updateZoneStatus',
            inSafeZone = true,
            inDistrict = false
        })
    elseif inDistrict and districtFound and districtFound.zones and not districtFound.zones[1].isSafeZone then
        -- In conflict district - missions can spawn here
        State.currentDistrict = districtFound
        SendNUIMessage({
            type = 'updateZoneStatus',
            inSafeZone = false,
            inDistrict = true,
            district = districtFound
        })
        if not State.currentTeam then
            -- Show team selection if not in a team
            SendNUIMessage({
                type = 'showUI',
                showTeamSelect = true,
                district = districtFound
            })
            SetNuiFocus(true, true)
        end
    else
        -- Outside all zones - neutral area, no missions available
        State.currentDistrict = nil
        State.currentTeam = nil
        SendNUIMessage({
            type = 'updateZoneStatus',
            inSafeZone = false,
            inDistrict = false
        })
    end
end

-- Main thread for objective checking
CreateThread(function()
    while true do
        Wait(500) -- Check every 500ms instead of every frame
        if State.currentMission then
            CheckObjectiveCompletion()
        end
    end
end)

-- District boundary checking thread
CreateThread(function()
    while true do
        Wait(1000) -- Check every second
        CheckDistrictBoundaries()
    end
end)

-- Blip cleanup thread
CreateThread(function()
    while true do
        Wait(30000) -- Check every 30 seconds
        BlipManager.CleanupOldBlips()
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    State.isUIOpen = false
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback('selectTeam', function(data, cb)
    local team = data.team
    if team ~= 'pvp' and team ~= 'pve' then
        cb({ success = false, error = 'Invalid team selection' })
        return
    end
    
    State.currentTeam = team
    TriggerServerEvent('dz:server:selectTeam', team)
    cb({ success = true })
end)

RegisterNUICallback('acceptMission', function(data, cb)
    local missionId = data.missionId
    if not State.currentDistrict then
        cb({ success = false, error = 'No current district' })
        return
    end
    
    if not State.currentTeam then
        cb({ success = false, error = 'No team selected' })
        return
    end
    
    TriggerServerEvent('dz:server:acceptMission', missionId, State.currentDistrict.id)
    cb({ success = true })
end)

RegisterNUICallback('capturePoint', function(data, cb)
    local missionId = data.missionId
    local objectiveId = data.objectiveId
    
    if not State.currentTeam then
        cb({ success = false, error = 'No team selected' })
        return
    end
    
    TriggerServerEvent('dz:server:capturePoint', missionId, objectiveId)
    cb({ success = true })
end)

-- New real-time update callbacks
RegisterNUICallback('requestDistrictUpdate', function(data, cb)
    if State.currentDistrict then
        TriggerServerEvent('dz:server:district:getInfo', State.currentDistrict.id)
    end
    cb({ success = true })
end)

RegisterNUICallback('requestTeamUpdate', function(data, cb)
    TriggerServerEvent('dz:server:team:getInfo')
    cb({ success = true })
end)

-- Event handlers
RegisterNetEvent('dz:client:updateUI', function(data)
    if not State.isUIOpen then
        State.isUIOpen = true
        SetNuiFocus(true, true)
    end
    
    SendNUIMessage({
        type = 'updateUI',
        currentDistrict = data.currentDistrict,
        districts = data.districts,
        missions = data.missions,
        currentTeam = data.currentTeam
    })
end)

RegisterNetEvent('dz:client:teamSelected', function(team)
    State.currentTeam = team
    SendNUIMessage({
        type = 'showNotification',
        message = 'Team selected: ' .. (team == 'pvp' and 'PvP' or 'PvE'),
        type = 'success'
    })
end)

RegisterNetEvent('dz:client:missionStarted', function(mission)
    State.currentMission = mission
    BlipManager.CreateMissionBlip(mission)
    SendNUIMessage({
        type = 'mission:started',
        mission = mission
    })
end)

RegisterNetEvent('dz:client:missionCompleted', function(missionId, reward)
    State.currentMission = nil
    BlipManager.ClearMissionBlips()
    SendNUIMessage({
        type = 'mission:completed',
        missionId = missionId,
        reward = reward
    })
end)

RegisterNetEvent('dz:client:missionFailed', function(missionId, reason)
    State.currentMission = nil
    BlipManager.ClearMissionBlips()
    SendNUIMessage({
        type = 'mission:failed',
        missionId = missionId,
        reason = reason
    })
end)

RegisterNetEvent('dz:client:missionUpdated', function(mission)
    SendNUIMessage({
        type = 'mission:sync',
        mission = mission
    })
end)

RegisterNetEvent('dz:client:district:controlChanged', function(districtId, team)
    SendNUIMessage({
        type = 'district:controlChanged',
        districtId = districtId,
        team = team
    })
end)

RegisterNetEvent('dz:client:controlPoint:captureStarted', function(pointId, team)
    SendNUIMessage({
        type = 'controlPoint:captureStarted',
        pointId = pointId,
        team = team
    })
end)

RegisterNetEvent('dz:client:controlPoint:captured', function(pointId, team)
    SendNUIMessage({
        type = 'controlPoint:captured',
        pointId = pointId,
        team = team
    })
end)

RegisterNetEvent('dz:client:district:sync', function(districts)
    SendNUIMessage({
        type = 'district:sync',
        districts = districts
    })
end)

RegisterNetEvent('dz:client:team:sync', function(data)
    SendNUIMessage({
        type = 'team:sync',
        currentTeam = data.currentTeam,
        stats = data.stats,
        balance = data.balance
    })
end)

-- Command to open UI
RegisterCommand('district', function()
    if not State.currentDistrict then
        QBX.Functions.Notify('You must be in a district to open the menu', 'error')
        return
    end
    
    if not State.currentTeam then
        -- Show team selection first
        SendNUIMessage({
            type = 'showUI',
            showTeamSelect = true
        })
        State.isUIOpen = true
        SetNuiFocus(true, true)
    else
        -- Request UI data from server
        TriggerServerEvent('dz:server:getUIData')
    end
end, false)

-- Key binding
RegisterKeyMapping('district', 'Open District Zero Menu', 'keyboard', 'F6')

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Initialize blip system
    BlipManager.CreateDistrictBlips()
    State.isInitialized = true
    
    Utils.PrintDebug('District Zero client initialized successfully')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Clean up all blips
    for blipId, _ in pairs(BlipManager.blips) do
        RemoveBlip(blipId)
    end
    
    -- Close UI if open
    if State.isUIOpen then
        SetNuiFocus(false, false)
    end
    
    Utils.PrintDebug('District Zero client cleanup completed')
end)

-- Exports
exports('GetCurrentDistrict', function()
    return State.currentDistrict
end)

exports('GetCurrentTeam', function()
    return State.currentTeam
end)

exports('GetCurrentMission', function()
    return State.currentMission
end)

exports('IsUIOpen', function()
    return State.isUIOpen
end)

exports('GetBlipCount', function()
    return BlipManager.GetBlipCount()
end) 