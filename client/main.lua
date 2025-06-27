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
    isInitialized = false,
    blipsCreated = false
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
        return false
    end
    
    -- Clear existing district blips
    BlipManager.ClearDistrictBlips()
    
    local blipsCreated = 0
    
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
                blipsCreated = blipsCreated + 1
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
                            blipsCreated = blipsCreated + 1
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
                    blipsCreated = blipsCreated + 1
                end
            end
        end
    end
    
    Utils.PrintDebug('Created ' .. blipsCreated .. ' district blips successfully')
    State.blipsCreated = true
    return true
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
                    if QBX and QBX.Functions then
                    QBX.Functions.DrawText3D(objective.coords.x, objective.coords.y, objective.coords.z, 'Press [E] to capture')
                    end
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent('dz:server:capturePoint', State.currentMission.id, i)
                    end
                elseif objective.type == 'eliminate' then
                    if QBX and QBX.Functions then
                    QBX.Functions.DrawText3D(objective.coords.x, objective.coords.y, objective.coords.z, 'Eliminate all targets')
                    end
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
        if inDistrict then break end
            end
        end
    end

    if inSafeZone then
        -- In safe zone - no missions, no team restrictions
        if State.currentDistrict or State.currentTeam then
        State.currentDistrict = nil
        State.currentTeam = nil
        SendNUIMessage({
            type = 'updateZoneStatus',
            inSafeZone = true,
            inDistrict = false
        })
        end
    elseif inDistrict and districtFound and districtFound.zones and not districtFound.zones[1].isSafeZone then
        -- In conflict district - missions can spawn here
        local districtChanged = State.currentDistrict ~= districtFound
        
        if districtChanged then
        State.currentDistrict = districtFound
            State.currentTeam = nil -- Reset team when changing districts
            
        SendNUIMessage({
            type = 'updateZoneStatus',
            inSafeZone = false,
            inDistrict = true,
            district = districtFound
        })
            
            -- Show notification for new district
            if QBX and QBX.Functions then
                QBX.Functions.Notify('Entered district: ' .. districtFound.name, 'info')
            end
        end
        
            -- Show team selection if not in a team
        if not State.currentTeam and not State.isUIOpen then
            TriggerEvent('dz:client:showTeamSelect', districtFound)
        end
    else
        -- Outside all zones - neutral area, no missions available
        if State.currentDistrict or State.currentTeam then
        State.currentDistrict = nil
        State.currentTeam = nil
        SendNUIMessage({
            type = 'updateZoneStatus',
            inSafeZone = false,
            inDistrict = false
        })
            
            -- Close UI if open
            if State.isUIOpen then
                TriggerEvent('dz:client:hideUI')
            end
        end
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
    cb({ success = true })
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

-- Enhanced NUI message handling
RegisterNUICallback('getUIData', function(data, cb)
    -- Request current UI data from server
    TriggerServerEvent('dz:server:getUIData')
    cb({ success = true })
end)

RegisterNUICallback('setNuiFocus', function(data, cb)
    local hasFocus = data.hasFocus or false
    local hasCursor = data.hasCursor or false
    SetNuiFocus(hasFocus, hasCursor)
    cb({ success = true })
end)

-- Error handling for NUI calls
RegisterNUICallback('error', function(data, cb)
    Utils.PrintDebug('[NUI ERROR] ' .. (data.message or 'Unknown error'))
    if QBX and QBX.Functions then
        QBX.Functions.Notify('UI Error: ' .. (data.message or 'Unknown error'), 'error')
    end
    cb({ success = false, error = data.message })
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
        currentTeam = data.currentTeam,
        playerStats = data.playerStats,
        teamBalance = data.teamBalance
    })
end)

RegisterNetEvent('dz:client:teamSelected', function(team)
    State.currentTeam = team
    SendNUIMessage({
        type = 'team:selected',
        team = team
    })
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Team selected: ' .. (team == 'pvp' and 'PvP' or 'PvE'), 'success')
    end
    
    -- Close team selection UI and show main UI
    SendNUIMessage({
        type = 'showUI',
        showTeamSelect = false
    })
end)

RegisterNetEvent('dz:client:missionStarted', function(mission)
    State.currentMission = mission
    BlipManager.CreateMissionBlip(mission)
    
    SendNUIMessage({
        type = 'mission:started',
        mission = mission
    })
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Mission started: ' .. mission.title, 'success')
    end
end)

RegisterNetEvent('dz:client:missionCompleted', function(missionId, reward)
    State.currentMission = nil
    BlipManager.ClearMissionBlips()
    
    SendNUIMessage({
        type = 'mission:completed',
        missionId = missionId,
        reward = reward
    })
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Mission completed! Reward: $' .. (reward or 0), 'success')
    end
end)

RegisterNetEvent('dz:client:missionFailed', function(missionId, reason)
    State.currentMission = nil
    BlipManager.ClearMissionBlips()
    
    SendNUIMessage({
        type = 'mission:failed',
        missionId = missionId,
        reason = reason
    })
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Mission failed: ' .. (reason or 'Unknown error'), 'error')
    end
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
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('District control changed to ' .. (team == 'pvp' and 'PvP' or 'PvE'), 'info')
    end
end)

RegisterNetEvent('dz:client:controlPoint:captureStarted', function(pointId, team)
    SendNUIMessage({
        type = 'controlPoint:captureStarted',
        pointId = pointId,
        team = team
    })
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Control point capture started!', 'info')
    end
end)

RegisterNetEvent('dz:client:controlPoint:captured', function(pointId, team)
    SendNUIMessage({
        type = 'controlPoint:captured',
        pointId = pointId,
        team = team
    })
    
    -- Show notification
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Control point captured by ' .. (team == 'pvp' and 'PvP' or 'PvE') .. '!', 'success')
    end
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

-- New event for showing team selection UI
RegisterNetEvent('dz:client:showTeamSelect', function(district)
    SendNUIMessage({
        type = 'showUI',
        showTeamSelect = true,
        district = district
    })
    State.isUIOpen = true
    SetNuiFocus(true, true)
end)

-- New event for hiding UI
RegisterNetEvent('dz:client:hideUI', function()
    SendNUIMessage({
        type = 'hideUI'
    })
    State.isUIOpen = false
    SetNuiFocus(false, false)
end)

-- Command to open UI
RegisterCommand('district', function()
    if not State.currentDistrict then
        if QBX and QBX.Functions then
        QBX.Functions.Notify('You must be in a district to open the menu', 'error')
        else
            print('^1[District Zero] You must be in a district to open the menu^7')
        end
        return
    end
    
    if not State.currentTeam then
        -- Show team selection first
        TriggerEvent('dz:client:showTeamSelect', State.currentDistrict)
    else
        -- Request UI data from server
        TriggerServerEvent('dz:server:getUIData')
    end
end, false)

-- Add /dz command as alias
RegisterCommand('dz', function()
    ExecuteCommand('district')
end, false)

-- Debug command to test the system
RegisterCommand('dzdebug', function()
    print('^5[District Zero] Debug Information:^7')
    print('^3Config loaded: ' .. (Config and 'YES' or 'NO') .. '^7')
    print('^3Districts loaded: ' .. (Config and Config.Districts and #Config.Districts or '0') .. '^7')
    print('^3Current district: ' .. (State.currentDistrict and State.currentDistrict.name or 'NONE') .. '^7')
    print('^3Current team: ' .. (State.currentTeam or 'NONE') .. '^7')
    print('^3Blips created: ' .. (State.blipsCreated and 'YES' or 'NO') .. '^7')
    print('^3Blip count: ' .. BlipManager.GetBlipCount() .. '^7')
    print('^3UI open: ' .. (State.isUIOpen and 'YES' or 'NO') .. '^7')
    
    -- Force create blips if not created
    if not State.blipsCreated then
        print('^3[District Zero] Attempting to create blips...^7')
        if BlipManager.CreateDistrictBlips() then
            print('^2[District Zero] Blips created successfully^7')
        else
            print('^1[District Zero] Failed to create blips^7')
        end
    end
end, false)

-- Force reload command
RegisterCommand('dzreload', function()
    print('^3[District Zero] Reloading resource...^7')
    ExecuteCommand('restart district-zero')
end, false)

-- Team selection commands
RegisterCommand('dzpvp', function()
    if not State.currentDistrict then
        if QBX and QBX.Functions then
            QBX.Functions.Notify('You must be in a district to select a team', 'error')
        end
        return
    end
    
    TriggerServerEvent('dz:server:selectTeam', 'pvp')
end, false)

RegisterCommand('dzpve', function()
    if not State.currentDistrict then
        if QBX and QBX.Functions then
            QBX.Functions.Notify('You must be in a district to select a team', 'error')
        end
        return
    end
    
    TriggerServerEvent('dz:server:selectTeam', 'pve')
end, false)

-- Test UI command
RegisterCommand('dztest', function()
    print('^5[District Zero] Testing UI integration...^7')
    
    -- Test team selection
    if State.currentDistrict then
        print('^3[District Zero] Testing team selection UI...^7')
        TriggerEvent('dz:client:showTeamSelect', State.currentDistrict)
    else
        print('^1[District Zero] No current district for testing^7')
    end
    
    -- Test notification
    SendNUIMessage({
        type = 'showNotification',
        message = 'UI test notification',
        type = 'info'
    })
    
    print('^2[District Zero] UI test completed^7')
end, false)

-- Key binding
RegisterKeyMapping('district', 'Open District Zero Menu', 'keyboard', 'F6')

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print('^5[District Zero] Client starting...^7')
    
    -- Wait for config to load
    CreateThread(function()
        local attempts = 0
        while not Config and attempts < 50 do
            Wait(100)
            attempts = attempts + 1
        end
        
        if not Config then
            print('^1[District Zero] ERROR: Config not loaded after 5 seconds^7')
            return
        end
    
    -- Initialize blip system
        if BlipManager.CreateDistrictBlips() then
            print('^2[District Zero] Blips created successfully^7')
        else
            print('^1[District Zero] Failed to create blips^7')
        end
        
    State.isInitialized = true
        print('^2[District Zero] Client initialized successfully^7')
    end)
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
    
    print('^3[District Zero] Client cleanup completed^7')
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

-- NUI Callbacks for District Control System
RegisterNUICallback('getDistricts', function(data, cb)
    local districts = {}
    
    -- Get all available districts
    for districtId, district in pairs(Config.districts or {}) do
        local districtData = {
            id = districtId,
            name = district.name,
            coords = district.coords,
            radius = district.radius,
            controlPoints = district.controlPoints or {},
            influence = { pvp = 0, pve = 0 },
            lastCaptured = 0,
            controllingTeam = 'neutral'
        }
        
        -- Get current influence from district control system
        local districtControl = exports['district-zero']:GetDistrictControl()
        if districtControl and districtControl.influence and districtControl.influence[districtId] then
            districtData.influence = districtControl.influence[districtId]
        end
        
        -- Get controlling team
        if districtControl and districtControl.districts and districtControl.districts[districtId] then
            districtData.controllingTeam = districtControl.districts[districtId].controllingTeam or 'neutral'
        end
        
        table.insert(districts, districtData)
    end
    
    cb({
        success = true,
        data = districts
    })
end)

RegisterNUICallback('startCapture', function(data, cb)
    local districtId = data.districtId
    local pointId = data.pointId
    
    if not districtId or not pointId then
        cb({
            success = false,
            error = 'Missing district or point ID'
        })
        return
    end
    
    local currentTeam = State.currentTeam
    if not currentTeam then
        cb({
            success = false,
            error = 'You must be in a team to capture points'
        })
        return
    end
    
    -- Start capture through district control system
    local success, message = exports['district-zero']:StartCapture(districtId, pointId, currentTeam, GetPlayerServerId(PlayerId()))
    
    cb({
        success = success,
        error = not success and message or nil
    })
end)

RegisterNUICallback('teleportToPoint', function(data, cb)
    local coords = data.coords
    
    if not coords or not coords.x or not coords.y or not coords.z then
        cb({
            success = false,
            error = 'Invalid coordinates'
        })
        return
    end
    
    -- Teleport player to control point
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    
    cb({
        success = true
    })
end)

RegisterNUICallback('getPlayerStats', function(data, cb)
    local playerId = GetPlayerServerId(PlayerId())
    
    -- Get player stats from server
    TriggerServerEvent('dz:server:getPlayerStats', playerId)
    
    -- Set up one-time event listener for response
    local eventName = 'dz:client:playerStats:response'
    local handler = function(stats)
        RemoveEventHandler(eventName, handler)
        cb({
            success = true,
            data = stats
        })
    end
    
    RegisterNetEvent(eventName, handler)
    
    -- Timeout after 5 seconds
    SetTimeout(5000, function()
        RemoveEventHandler(eventName, handler)
        cb({
            success = false,
            error = 'Request timeout'
        })
    end)
end)

RegisterNUICallback('getTeamBalance', function(data, cb)
    -- Get team balance from server
    TriggerServerEvent('dz:server:getTeamBalance')
    
    -- Set up one-time event listener for response
    local eventName = 'dz:client:teamBalance:response'
    local handler = function(balance)
        RemoveEventHandler(eventName, handler)
        cb({
            success = true,
            data = balance
        })
    end
    
    RegisterNetEvent(eventName, handler)
    
    -- Timeout after 5 seconds
    SetTimeout(5000, function()
        RemoveEventHandler(eventName, handler)
        cb({
            success = false,
            error = 'Request timeout'
        })
    end)
end)

-- NUI Focus Management
RegisterNUICallback('setNuiFocus', function(data, cb)
    local focus = data.focus
    local cursor = data.cursor or true
    
    SetNuiFocus(focus, cursor)
    cb({ success = true })
end)

RegisterNUICallback('closeNui', function(data, cb)
    SetNuiFocus(false, false)
    cb({ success = true })
end)

-- Test Commands for District Control System
RegisterCommand('testcapture', function(source, args)
    local districtId = args[1] or 'downtown'
    local pointId = args[2] or 'city_hall'
    local team = args[3] or 'pvp'
    
    if not State.currentTeam then
        QBX.Functions.Notify('You must be in a team first. Use /team pvp or /team pve', 'error')
        return
    end
    
    -- Start capture
    local success, message = exports['district-zero']:StartCapture(districtId, pointId, State.currentTeam, GetPlayerServerId(PlayerId()))
    
    if success then
        QBX.Functions.Notify('Test capture started: ' .. districtId .. ' - ' .. pointId, 'success')
    else
        QBX.Functions.Notify('Test capture failed: ' .. (message or 'Unknown error'), 'error')
    end
end, false)

RegisterCommand('testinfluence', function(source, args)
    local districtId = args[1] or 'downtown'
    
    -- Get district influence
    local influence = exports['district-zero']:GetDistrictInfluence(districtId)
    
    if influence then
        QBX.Functions.Notify(string.format('District %s Influence - PvP: %d%%, PvE: %d%%', 
            districtId, influence.pvp, influence.pve), 'info')
    else
        QBX.Functions.Notify('District influence not found', 'error')
    end
end, false)

RegisterCommand('testpoints', function(source, args)
    local districtId = args[1] or 'downtown'
    
    -- Get control points
    local points = exports['district-zero']:GetControlPoints(districtId)
    
    if points then
        local count = 0
        for _, _ in pairs(points) do
            count = count + 1
        end
        QBX.Functions.Notify(string.format('District %s has %d control points', districtId, count), 'info')
    else
        QBX.Functions.Notify('Control points not found', 'error')
    end
end, false)

RegisterCommand('testdistrict', function(source, args)
    local districtId = args[1] or 'downtown'
    
    -- Get district control data
    local districtControl = exports['district-zero']:GetDistrictControl()
    
    if districtControl and districtControl.districts and districtControl.districts[districtId] then
        local district = districtControl.districts[districtId]
        QBX.Functions.Notify(string.format('District: %s, Controlling Team: %s', 
            district.name, district.controllingTeam), 'info')
    else
        QBX.Functions.Notify('District not found', 'error')
    end
end, false)

-- Test Commands for Mission System
RegisterCommand('testmission', function(source, args)
    local missionType = args[1] or 'capture_points'
    local difficulty = args[2] or 'EASY'
    local districtId = args[3] or 'downtown'
    
    if not State.currentTeam then
        QBX.Functions.Notify('You must be in a team first. Use /team pvp or /team pve', 'error')
        return
    end
    
    -- Create mission
    local mission = exports['district-zero']:CreateMission(missionType, difficulty, districtId)
    
    if mission then
        QBX.Functions.Notify('Test mission created: ' .. missionType .. ' (' .. difficulty .. ') in ' .. districtId, 'success')
    else
        QBX.Functions.Notify('Failed to create test mission', 'error')
    end
end, false)

RegisterCommand('testprogress', function(source, args)
    local missionId = args[1]
    local progress = tonumber(args[2]) or 1
    local objectiveType = args[3] or 'capture_points'
    
    if not missionId then
        QBX.Functions.Notify('Usage: /testprogress [missionId] [progress] [objectiveType]', 'error')
        return
    end
    
    -- Update mission progress
    local success = exports['district-zero']:UpdateMissionProgress(missionId, progress, objectiveType)
    
    if success then
        QBX.Functions.Notify('Mission progress updated: +' .. progress, 'success')
    else
        QBX.Functions.Notify('Failed to update mission progress', 'error')
    end
end, false)

RegisterCommand('testmissions', function(source, args)
    local districtId = args[1] or 'downtown'
    
    -- Get available missions
    local missions = exports['district-zero']:GetAvailableMissions(districtId)
    
    if missions and #missions > 0 then
        QBX.Functions.Notify('Available missions in ' .. districtId .. ': ' .. #missions, 'info')
        for i, mission in ipairs(missions) do
            print(string.format('Mission %d: %s (%s) - %s', i, mission.type, mission.difficulty, mission.objectives.description))
        end
    else
        QBX.Functions.Notify('No available missions in ' .. districtId, 'info')
    end
end, false)

RegisterCommand('testcooldown', function(source, args)
    local missionType = args[1] or 'capture_points'
    
    -- Check mission cooldown
    local onCooldown = exports['district-zero']:IsMissionOnCooldown(missionType)
    
    if onCooldown then
        QBX.Functions.Notify('Mission type ' .. missionType .. ' is on cooldown', 'warning')
    else
        QBX.Functions.Notify('Mission type ' .. missionType .. ' is available', 'success')
    end
end, false)

-- Enhanced Team System Integration
RegisterNUICallback('joinTeam', function(data, cb)
    local teamType = data.teamType
    if not teamType or (teamType ~= 'pvp' and teamType ~= 'pve') then
        cb({ success = false, error = 'Invalid team type' })
        return
    end
    
    local success, message = exports['district-zero']:JoinTeam(teamType)
    cb({ success = success, message = message })
end)

RegisterNUICallback('leaveTeam', function(data, cb)
    local success, message = exports['district-zero']:LeaveTeam()
    cb({ success = success, message = message })
end)

RegisterNUICallback('switchTeam', function(data, cb)
    local teamType = data.teamType
    if not teamType or (teamType ~= 'pvp' and teamType ~= 'pve') then
        cb({ success = false, error = 'Invalid team type' })
        return
    end
    
    local success, message = exports['district-zero']:SwitchTeam(teamType)
    cb({ success = success, message = message })
end)

RegisterNUICallback('getTeamMembers', function(data, cb)
    local members = exports['district-zero']:GetTeamMembers()
    cb({ success = true, data = members })
end)

RegisterNUICallback('getTeamBalance', function(data, cb)
    local balance = exports['district-zero']:GetTeamBalance()
    cb({ success = true, data = balance })
end)

RegisterNUICallback('updateTeamStats', function(data, cb)
    local statType = data.statType
    local value = data.value or 1
    
    if not statType then
        cb({ success = false, error = 'Stat type required' })
        return
    end
    
    local success = exports['district-zero']:UpdateTeamStats(statType, value)
    cb({ success = success })
end)

RegisterNUICallback('createTeamEvent', function(data, cb)
    local eventType = data.type
    local eventData = data.data or {}
    
    if not eventType then
        cb({ success = false, error = 'Event type required' })
        return
    end
    
    local success, eventId = exports['district-zero']:CreateTeamEvent(eventType, eventData)
    cb({ success = success, eventId = eventId })
end)

RegisterNUICallback('joinTeamEvent', function(data, cb)
    local eventId = data.eventId
    
    if not eventId then
        cb({ success = false, error = 'Event ID required' })
        return
    end
    
    local success, message = exports['district-zero']:JoinTeamEvent(eventId)
    cb({ success = success, message = message })
end)

RegisterNUICallback('completeTeamEvent', function(data, cb)
    local eventId = data.eventId
    local success = data.success
    
    if not eventId then
        cb({ success = false, error = 'Event ID required' })
        return
    end
    
    local result, message = exports['district-zero']:CompleteTeamEvent(eventId, success)
    cb({ success = result, message = message })
end)

RegisterNUICallback('getTeamLeaderboard', function(data, cb)
    local leaderboard = exports['district-zero']:GetTeamLeaderboard()
    cb({ success = true, data = leaderboard })
end)

RegisterNUICallback('sendTeamMessage', function(data, cb)
    local message = data.message
    
    if not message or message.trim() == '' then
        cb({ success = false, error = 'Message required' })
        return
    end
    
    local success, result = exports['district-zero']:SendTeamMessage(message)
    cb({ success = success, message = result })
end)

RegisterNUICallback('getTeamMembersInRange', function(data, cb)
    local range = data.range or 100.0
    local members = exports['district-zero']:GetTeamMembersInRange(range)
    cb({ success = true, data = members })
end)

-- Team System Event Handlers
RegisterNetEvent('dz:client:team:receiveMessage', function(message, senderId, teamType)
    if QBX and QBX.Functions then
        QBX.Functions.Notify(string.format('[%s] Player %d: %s', teamType:upper(), senderId, message), 'info')
    end
end)

RegisterNetEvent('dz:client:team:eventReward', function(eventId, bonus)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Team event reward: $' .. bonus, 'success')
    end
end)

-- Test Commands for Enhanced Team System
RegisterCommand('testjointeam', function(source, args)
    local teamType = args[1] or 'pvp'
    
    if teamType ~= 'pvp' and teamType ~= 'pve' then
        QBX.Functions.Notify('Usage: /testjointeam [pvp/pve]', 'error')
        return
    end
    
    local success, message = exports['district-zero']:JoinTeam(teamType)
    QBX.Functions.Notify(message, success and 'success' or 'error')
end, false)

RegisterCommand('testleaveteam', function(source, args)
    local success, message = exports['district-zero']:LeaveTeam()
    QBX.Functions.Notify(message, success and 'success' or 'error')
end, false)

RegisterCommand('testswitchteam', function(source, args)
    local teamType = args[1] or 'pve'
    
    if teamType ~= 'pvp' and teamType ~= 'pve' then
        QBX.Functions.Notify('Usage: /testswitchteam [pvp/pve]', 'error')
        return
    end
    
    local success, message = exports['district-zero']:SwitchTeam(teamType)
    QBX.Functions.Notify(message, success and 'success' or 'error')
end, false)

RegisterCommand('testteamevent', function(source, args)
    local eventType = args[1] or 'team_capture'
    local description = args[2] or 'Test team event'
    
    local success, eventId = exports['district-zero']:CreateTeamEvent(eventType, { description = description })
    
    if success then
        QBX.Functions.Notify('Team event created: ' .. eventId, 'success')
    else
        QBX.Functions.Notify('Failed to create team event: ' .. eventId, 'error')
    end
end, false)

RegisterCommand('testteamstats', function(source, args)
    local statType = args[1] or 'captures'
    local value = tonumber(args[2]) or 1
    
    local success = exports['district-zero']:UpdateTeamStats(statType, value)
    
    if success then
        QBX.Functions.Notify('Team stats updated: ' .. statType .. ' +' .. value, 'success')
    else
        QBX.Functions.Notify('Failed to update team stats', 'error')
    end
end, false)

RegisterCommand('testteamleaderboard', function(source, args)
    local leaderboard = exports['district-zero']:GetTeamLeaderboard()
    
    if leaderboard then
        QBX.Functions.Notify('Team leaderboard retrieved', 'info')
        print('^3[District Zero] Team Leaderboard:^7')
        for team, members in pairs(leaderboard) do
            print('^2' .. team:upper() .. ' Team:^7')
            for i = 1, math.min(5, #members) do
                local member = members[i]
                local total = (member.stats.captures or 0) + (member.stats.missions or 0) + (member.stats.eliminations or 0)
                print(string.format('  %d. Player %d: %d points', i, member.id, total))
            end
        end
    else
        QBX.Functions.Notify('Failed to get team leaderboard', 'error')
    end
end, false)

RegisterCommand('testteammessage', function(source, args)
    local message = table.concat(args, ' ')
    
    if message == '' then
        QBX.Functions.Notify('Usage: /testteammessage [message]', 'error')
        return
    end
    
    local success, result = exports['district-zero']:SendTeamMessage(message)
    QBX.Functions.Notify(result, success and 'success' or 'error')
end, false)

RegisterCommand('testteammembers', function(source, args)
    local range = tonumber(args[1]) or 100.0
    local members = exports['district-zero']:GetTeamMembersInRange(range)
    
    if members then
        QBX.Functions.Notify('Team members in range (' .. range .. 'm): ' .. #members, 'info')
        for _, member in ipairs(members) do
            print(string.format('Player %d: %.1fm away', member.id, member.distance))
        end
    else
        QBX.Functions.Notify('No team members in range', 'info')
    end
end, false)

-- Database Integration
RegisterNetEvent('dz:client:playerStats:loaded', function(stats)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Player stats loaded from database', 'success')
        print('^3[District Zero] Player Stats:^7')
        print('  Captures: ' .. (stats.total_captures or 0))
        print('  Missions: ' .. (stats.total_missions or 0))
        print('  Eliminations: ' .. (stats.total_eliminations or 0))
        print('  Assists: ' .. (stats.total_assists or 0))
        print('  Team Events: ' .. (stats.total_team_events or 0))
        print('  Total Points: ' .. (stats.total_points or 0))
        print('  Playtime: ' .. math.floor((stats.total_playtime or 0) / 3600) .. ' hours')
    end
end)

RegisterNetEvent('dz:client:districtHistory:loaded', function(history)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('District history loaded: ' .. #history .. ' entries', 'info')
        print('^3[District Zero] District History:^7')
        for i = 1, math.min(5, #history) do
            local entry = history[i]
            print(string.format('  %d. %s captured by %s (%s)', 
                i, entry.district_name, entry.controlling_team:upper(), 
                os.date('%Y-%m-%d %H:%M', entry.capture_time)))
        end
    end
end)

RegisterNetEvent('dz:client:missionHistory:loaded', function(history)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Mission history loaded: ' .. #history .. ' entries', 'info')
        print('^3[District Zero] Mission History:^7')
        for i = 1, math.min(5, #history) do
            local entry = history[i]
            print(string.format('  %d. %s (%s) - %s', 
                i, entry.mission_title, entry.mission_difficulty, 
                entry.success and 'SUCCESS' or 'FAILED'))
        end
    end
end)

RegisterNetEvent('dz:client:teamAnalytics:loaded', function(analytics)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Team analytics loaded: ' .. #analytics .. ' entries', 'info')
        print('^3[District Zero] Team Analytics:^7')
        for i = 1, math.min(3, #analytics) do
            local entry = analytics[i]
            print(string.format('  %s Team (%s): %d members, %d points', 
                entry.team_type:upper(), entry.date, entry.total_members, entry.total_points))
        end
    end
end)

RegisterNetEvent('dz:client:playerLeaderboard:loaded', function(leaderboard)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Player leaderboard loaded: ' .. #leaderboard .. ' players', 'info')
        print('^3[District Zero] Player Leaderboard:^7')
        for i = 1, math.min(10, #leaderboard) do
            local player = leaderboard[i]
            print(string.format('  %d. Player %s: %d points (Rank #%d)', 
                i, player.player_id, player.total_points, player.team_rank))
        end
    end
end)

RegisterNetEvent('dz:client:globalLeaderboard:loaded', function(leaderboard)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('Global leaderboard loaded: ' .. #leaderboard .. ' players', 'info')
        print('^3[District Zero] Global Leaderboard:^7')
        for i = 1, math.min(10, #leaderboard) do
            local player = leaderboard[i]
            print(string.format('  %d. Player %s (%s): %d points (Global #%d)', 
                i, player.player_id, player.team_type:upper(), player.total_points, player.global_rank))
        end
    end
end)

RegisterNetEvent('dz:client:systemConfig:loaded', function(configKey, configValue)
    if QBX and QBX.Functions then
        QBX.Functions.Notify('System config loaded: ' .. configKey .. ' = ' .. tostring(configValue), 'info')
    end
end)

-- Database NUI Callbacks
RegisterNUICallback('loadPlayerStats', function(data, cb)
    TriggerServerEvent('dz:server:loadPlayerStats')
    cb({ success = true })
end)

RegisterNUICallback('savePlayerStats', function(data, cb)
    local stats = data.stats
    if stats then
        TriggerServerEvent('dz:server:savePlayerStats', stats)
        cb({ success = true })
    else
        cb({ success = false, error = 'No stats provided' })
    end
end)

RegisterNUICallback('updatePlayerStat', function(data, cb)
    local statType = data.statType
    local value = data.value or 1
    
    if statType then
        TriggerServerEvent('dz:server:updatePlayerStat', statType, value)
        cb({ success = true })
    else
        cb({ success = false, error = 'No stat type provided' })
    end
end)

RegisterNUICallback('getDistrictHistory', function(data, cb)
    local districtId = data.districtId
    local limit = data.limit or 10
    
    if districtId then
        TriggerServerEvent('dz:server:getDistrictHistory', districtId, limit)
        cb({ success = true })
    else
        cb({ success = false, error = 'No district ID provided' })
    end
end)

RegisterNUICallback('getPlayerMissionHistory', function(data, cb)
    local limit = data.limit or 20
    TriggerServerEvent('dz:server:getPlayerMissionHistory', limit)
    cb({ success = true })
end)

RegisterNUICallback('getTeamAnalytics', function(data, cb)
    local teamType = data.teamType
    local days = data.days or 7
    
    if teamType then
        TriggerServerEvent('dz:server:getTeamAnalytics', teamType, days)
        cb({ success = true })
    else
        cb({ success = false, error = 'No team type provided' })
    end
end)

RegisterNUICallback('getPlayerLeaderboard', function(data, cb)
    local teamType = data.teamType
    local limit = data.limit or 10
    
    if teamType then
        TriggerServerEvent('dz:server:getPlayerLeaderboard', teamType, limit)
        cb({ success = true })
    else
        cb({ success = false, error = 'No team type provided' })
    end
end)

RegisterNUICallback('getGlobalLeaderboard', function(data, cb)
    local limit = data.limit or 20
    TriggerServerEvent('dz:server:getGlobalLeaderboard', limit)
    cb({ success = true })
end)

RegisterNUICallback('getSystemConfig', function(data, cb)
    local configKey = data.configKey
    
    if configKey then
        TriggerServerEvent('dz:server:getSystemConfig', configKey)
        cb({ success = true })
    else
        cb({ success = false, error = 'No config key provided' })
    end
end)

RegisterNUICallback('setSystemConfig', function(data, cb)
    local configKey = data.configKey
    local configValue = data.configValue
    local configType = data.configType or 'string'
    
    if configKey and configValue ~= nil then
        TriggerServerEvent('dz:server:setSystemConfig', configKey, configValue, configType)
        cb({ success = true })
    else
        cb({ success = false, error = 'Invalid config data' })
    end
end)

-- Session Management
local sessionStartTime = 0
local sessionDistricts = {}
local sessionActivities = {}

-- Start session when player joins
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(3000) -- Wait for everything to initialize
        sessionStartTime = GetGameTimer()
        TriggerServerEvent('dz:server:startPlayerSession', 'neutral')
    end
end)

-- Track district visits
local function TrackDistrictVisit(districtId)
    if not sessionDistricts[districtId] then
        sessionDistricts[districtId] = true
        print('^3[District Zero] ^7Visited district: ' .. districtId)
    end
end

-- Track activities
local function TrackActivity(activity)
    table.insert(sessionActivities, activity)
    print('^3[District Zero] ^7Activity tracked: ' .. activity)
end

-- Enhanced district entry with tracking
local function OnDistrictEnter(districtId)
    TrackDistrictVisit(districtId)
    TrackActivity('district_enter_' .. districtId)
end

-- Enhanced mission start with tracking
local function OnMissionStart(missionId, missionType)
    TrackActivity('mission_start_' .. missionType)
end

-- Enhanced mission completion with tracking
local function OnMissionComplete(missionId, success)
    TrackActivity('mission_complete_' .. (success and 'success' or 'failed'))
end

-- Enhanced team selection with tracking
local function OnTeamSelect(teamType)
    TrackActivity('team_select_' .. teamType)
end

-- Enhanced capture with tracking
local function OnCapture(districtId, pointId, teamType)
    TrackActivity('capture_' .. districtId .. '_' .. pointId)
end

-- End session when player leaves
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        local sessionDuration = math.floor((GetGameTimer() - sessionStartTime) / 1000)
        TriggerServerEvent('dz:server:endPlayerSession', sessionDistricts, sessionActivities)
        print('^3[District Zero] ^7Session ended. Duration: ' .. sessionDuration .. 's')
    end
end)

-- Test Commands for Database Integration
RegisterCommand('testdbstats', function(source, args)
    TriggerServerEvent('dz:server:loadPlayerStats')
    QBX.Functions.Notify('Loading player stats from database...', 'info')
end, false)

RegisterCommand('testdbhistory', function(source, args)
    local districtId = args[1] or 'downtown'
    local limit = tonumber(args[2]) or 5
    
    TriggerServerEvent('dz:server:getDistrictHistory', districtId, limit)
    QBX.Functions.Notify('Loading district history...', 'info')
end, false)

RegisterCommand('testdbmissions', function(source, args)
    local limit = tonumber(args[1]) or 10
    
    TriggerServerEvent('dz:server:getPlayerMissionHistory', limit)
    QBX.Functions.Notify('Loading mission history...', 'info')
end, false)

RegisterCommand('testdbanalytics', function(source, args)
    local teamType = args[1] or 'pvp'
    local days = tonumber(args[2]) or 7
    
    TriggerServerEvent('dz:server:getTeamAnalytics', teamType, days)
    QBX.Functions.Notify('Loading team analytics...', 'info')
end, false)

RegisterCommand('testdbleaderboard', function(source, args)
    local teamType = args[1] or 'pvp'
    local limit = tonumber(args[2]) or 10
    
    TriggerServerEvent('dz:server:getPlayerLeaderboard', teamType, limit)
    QBX.Functions.Notify('Loading player leaderboard...', 'info')
end, false)

RegisterCommand('testdbglobal', function(source, args)
    local limit = tonumber(args[1]) or 20
    
    TriggerServerEvent('dz:server:getGlobalLeaderboard', limit)
    QBX.Functions.Notify('Loading global leaderboard...', 'info')
end, false)

RegisterCommand('testdbconfig', function(source, args)
    local configKey = args[1] or 'team_balance_threshold'
    
    TriggerServerEvent('dz:server:getSystemConfig', configKey)
    QBX.Functions.Notify('Loading system config...', 'info')
end, false)

RegisterCommand('testdbsave', function(source, args)
    local statType = args[1] or 'total_captures'
    local value = tonumber(args[2]) or 1
    
    TriggerServerEvent('dz:server:updatePlayerStat', statType, value)
    QBX.Functions.Notify('Saving player stat: ' .. statType .. ' +' .. value, 'info')
end, false)

RegisterCommand('testdbsession', function(source, args)
    local action = args[1] or 'info'
    
    if action == 'start' then
        TriggerServerEvent('dz:server:startPlayerSession', State.currentTeam or 'neutral')
        QBX.Functions.Notify('Session started', 'success')
    elseif action == 'end' then
        TriggerServerEvent('dz:server:endPlayerSession', sessionDistricts, sessionActivities)
        QBX.Functions.Notify('Session ended', 'success')
    else
        local duration = math.floor((GetGameTimer() - sessionStartTime) / 1000)
        QBX.Functions.Notify('Session duration: ' .. duration .. 's, Districts: ' .. #sessionDistricts .. ', Activities: ' .. #sessionActivities, 'info')
    end
end, false)

-- Import shared modules
local Config = exports['district_zero']:GetConfig()
local PerformanceSystem = exports['district_zero']:GetPerformanceSystem()
local SecuritySystem = exports['district_zero']:GetSecuritySystem()
local AdvancedMissionSystem = exports['district_zero']:GetAdvancedMissionSystem()
local DynamicEventsSystem = exports['district_zero']:GetDynamicEventsSystem()
local AdvancedTeamSystem = exports['district_zero']:GetAdvancedTeamSystem()
local AchievementSystem = exports['district_zero']:GetAchievementSystem()
local AnalyticsSystem = exports['district_zero']:GetAnalyticsSystem()

-- Client state
local ClientState = {
    playerId = nil,
    teamId = nil,
    currentDistrict = nil,
    activeMissions = {},
    achievements = {},
    sessionStartTime = GetGameTimer(),
    lastPosition = nil,
    lastMovementTime = 0,
    movementData = {},
    combatData = {
        kills = 0,
        deaths = 0,
        assists = 0,
        combatStartTime = 0,
        isInCombat = false
    },
    analyticsData = {},
    dashboardData = {},
    lastAnalyticsUpdate = 0,
    analyticsUpdateInterval = 30000 -- 30 seconds
}

-- Analytics Tracking Functions
local function TrackAnalyticsEvent(category, eventType, data)
    if not ClientState.playerId then
        return
    end
    
    -- Add client-specific data
    data.clientTimestamp = GetGameTimer()
    data.playerId = ClientState.playerId
    
    TriggerServerEvent('dz:analytics:track_event', category, eventType, data)
end

local function TrackPlayerMovement()
    if not ClientState.playerId or not ClientState.lastPosition then
        return
    end
    
    local currentPosition = GetEntityCoords(PlayerPedId())
    local currentTime = GetGameTimer()
    
    if currentPosition and ClientState.lastPosition then
        local distance = #(currentPosition - ClientState.lastPosition)
        local timeDiff = currentTime - ClientState.lastMovementTime
        
        if distance > 1.0 and timeDiff > 1000 then -- Only track significant movement
            TrackAnalyticsEvent('player_behavior', 'movement_analysis', {
                distance = distance,
                duration = timeDiff,
                startCoords = ClientState.lastPosition,
                endCoords = currentPosition,
                speed = distance / (timeDiff / 1000)
            })
            
            ClientState.lastMovementTime = currentTime
        end
    end
    
    ClientState.lastPosition = currentPosition
end

local function TrackPlayerCombat()
    if not ClientState.playerId then
        return
    end
    
    local playerPed = PlayerPedId()
    local isInCombat = IsPedInMeleeCombat(playerPed) or IsPedShooting(playerPed)
    
    if isInCombat and not ClientState.combatData.isInCombat then
        -- Combat started
        ClientState.combatData.isInCombat = true
        ClientState.combatData.combatStartTime = GetGameTimer()
        
    elseif not isInCombat and ClientState.combatData.isInCombat then
        -- Combat ended
        ClientState.combatData.isInCombat = false
        local combatDuration = GetGameTimer() - ClientState.combatData.combatStartTime
        
        TrackAnalyticsEvent('player_behavior', 'combat_behavior', {
            kills = ClientState.combatData.kills,
            deaths = ClientState.combatData.deaths,
            assists = ClientState.combatData.assists,
            duration = combatDuration,
            weapon = GetSelectedPedWeapon(playerPed),
            location = GetEntityCoords(playerPed)
        })
        
        -- Reset combat data
        ClientState.combatData.kills = 0
        ClientState.combatData.deaths = 0
        ClientState.combatData.assists = 0
    end
end

local function TrackPlayerActivity()
    if not ClientState.playerId then
        return
    end
    
    local currentTime = GetGameTimer()
    local sessionDuration = currentTime - ClientState.sessionStartTime
    
    TrackAnalyticsEvent('player_behavior', 'activity_patterns', {
        timestamp = currentTime,
        sessionDuration = sessionDuration,
        isActive = true
    })
end

local function TrackSocialInteraction(interactionType, targetId, teamId, duration)
    if not ClientState.playerId then
        return
    end
    
    TrackAnalyticsEvent('social_analytics', 'interactions', {
        type = interactionType,
        targetId = targetId,
        teamId = teamId,
        duration = duration,
        timestamp = GetGameTimer()
    })
end

local function TrackPerformanceMetrics()
    local fps = GetFrameRate()
    local latency = GetNetworkTime()
    local memory = GetMemoryUsage()
    local cpu = GetCpuUsage()
    
    TrackAnalyticsEvent('performance_analytics', 'metrics', {
        fps = fps,
        latency = latency,
        memory = memory,
        cpu = cpu,
        timestamp = GetGameTimer()
    })
end

-- Analytics Dashboard Functions
local function RequestDashboard(dashboardId)
    if not ClientState.playerId then
        return
    end
    
    TriggerServerEvent('dz:analytics:get_dashboard', dashboardId)
end

local function RequestMetric(metricId)
    if not ClientState.playerId then
        return
    end
    
    TriggerServerEvent('dz:analytics:get_metric', metricId)
end

-- Analytics Event Handlers
RegisterNetEvent('dz:analytics:dashboard_response')
AddEventHandler('dz:analytics:dashboard_response', function(dashboardId, dashboardData)
    ClientState.dashboardData[dashboardId] = {
        data = dashboardData,
        timestamp = GetGameTimer()
    }
    
    -- Update UI with dashboard data
    SendNUIMessage({
        type = 'analytics_dashboard_update',
        dashboardId = dashboardId,
        dashboardData = dashboardData
    })
    
    print('^2[District Zero] ^7Dashboard received: ' .. dashboardId)
end)

RegisterNetEvent('dz:analytics:metric_response')
AddEventHandler('dz:analytics:metric_response', function(metricId, metricData)
    ClientState.analyticsData[metricId] = {
        data = metricData,
        timestamp = GetGameTimer()
    }
    
    -- Update UI with metric data
    SendNUIMessage({
        type = 'analytics_metric_update',
        metricId = metricId,
        metricData = metricData
    })
    
    print('^2[District Zero] ^7Metric received: ' .. metricId)
end)

-- Enhanced Analytics Thread
CreateThread(function()
    while true do
        Wait(ClientState.analyticsUpdateInterval)
        
        if ClientState.playerId then
            -- Track player movement
            TrackPlayerMovement()
            
            -- Track player combat
            TrackPlayerCombat()
            
            -- Track player activity
            TrackPlayerActivity()
            
            -- Track performance metrics
            TrackPerformanceMetrics()
            
            ClientState.lastAnalyticsUpdate = GetGameTimer()
        end
    end
end)

-- Analytics Integration with Existing Systems
local function TrackMissionAnalytics(missionId, missionData)
    TrackAnalyticsEvent('mission_statistics', 'completion_rate', {
        missionId = missionId,
        completed = missionData.completed,
        duration = missionData.duration,
        participants = missionData.participants,
        difficulty = missionData.difficulty,
        rewards = missionData.rewards
    })
end

local function TrackTeamAnalytics(teamId, teamData)
    TrackAnalyticsEvent('team_performance', 'capture_efficiency', {
        teamId = teamId,
        districtId = teamData.districtId,
        successful = teamData.successful,
        duration = teamData.duration,
        participants = teamData.participants,
        resistance = teamData.resistance
    })
end

local function TrackDistrictAnalytics(districtId, districtData)
    TrackAnalyticsEvent('district_control', 'control_duration', {
        districtId = districtId,
        teamId = districtData.teamId,
        duration = districtData.duration,
        startTime = districtData.startTime,
        endTime = districtData.endTime,
        captureCount = districtData.captureCount
    })
end

-- Analytics Commands
RegisterCommand('dzanalytics', function(source, args, rawCommand)
    local subCommand = args[1] and args[1]:lower() or 'help'
    
    if subCommand == 'dashboard' then
        if #args < 2 then
            print('^3[District Zero] ^7Usage: /dzanalytics dashboard <dashboardId>')
            return
        end
        
        local dashboardId = args[2]
        RequestDashboard(dashboardId)
        print('^2[District Zero] ^7Requested dashboard: ' .. dashboardId)
        
    elseif subCommand == 'metric' then
        if #args < 2 then
            print('^3[District Zero] ^7Usage: /dzanalytics metric <metricId>')
            return
        end
        
        local metricId = args[2]
        RequestMetric(metricId)
        print('^2[District Zero] ^7Requested metric: ' .. metricId)
        
    elseif subCommand == 'track' then
        if #args < 4 then
            print('^3[District Zero] ^7Usage: /dzanalytics track <category> <eventType> <data>')
            return
        end
        
        local category = args[2]
        local eventType = args[3]
        local data = args[4] or {}
        
        TrackAnalyticsEvent(category, eventType, { data = data })
        print('^2[District Zero] ^7Analytics event tracked: ' .. category .. '.' .. eventType)
        
    elseif subCommand == 'list' then
        print('^3[District Zero Analytics] ^7Available Dashboards:')
        print('  overview - General system overview')
        print('  player_analytics - Player behavior analytics')
        print('  team_analytics - Team performance analytics')
        print('  system_analytics - System performance analytics')
        
        print('^3[District Zero Analytics] ^7Available Metrics:')
        print('  player_session_time - Session duration')
        print('  player_activity_patterns - Activity patterns')
        print('  player_movement_analysis - Movement analysis')
        print('  player_combat_behavior - Combat behavior')
        print('  team_capture_efficiency - Capture efficiency')
        print('  team_mission_completion - Mission completion')
        print('  team_war_performance - War performance')
        print('  district_control_duration - Control duration')
        print('  district_capture_frequency - Capture frequency')
        print('  mission_completion_rate - Completion rate')
        print('  mission_difficulty_analysis - Difficulty analysis')
        print('  server_performance - Server performance')
        print('  economic_flow - Economic flow')
        print('  social_interactions - Social interactions')
        print('  performance_metrics - Performance metrics')
        
    elseif subCommand == 'stats' then
        print('^3[District Zero Analytics Statistics] ^7')
        print('  Player ID: ' .. (ClientState.playerId or 'Not set'))
        print('  Session Duration: ' .. math.floor((GetGameTimer() - ClientState.sessionStartTime) / 1000) .. 's')
        print('  Dashboards Cached: ' .. #ClientState.dashboardData)
        print('  Metrics Cached: ' .. #ClientState.analyticsData)
        print('  Last Update: ' .. (ClientState.lastAnalyticsUpdate > 0 and 
            math.floor((GetGameTimer() - ClientState.lastAnalyticsUpdate) / 1000) .. 's ago' or 'Never'))
        
    elseif subCommand == 'help' then
        print('^3[District Zero Analytics Commands] ^7Available commands:')
        print('  /dzanalytics dashboard <dashboardId> - Request dashboard data')
        print('  /dzanalytics metric <metricId> - Request metric data')
        print('  /dzanalytics track <category> <eventType> <data> - Track analytics event')
        print('  /dzanalytics list - List available dashboards and metrics')
        print('  /dzanalytics stats - Show analytics statistics')
        print('  /dzanalytics help - Show this help')
        
    else
        print('^1[District Zero] ^7Unknown analytics command: ' .. subCommand)
    end
end, false)

-- NUI Callbacks for Analytics
RegisterNUICallback('requestAnalyticsDashboard', function(data, cb)
    if data.dashboardId then
        RequestDashboard(data.dashboardId)
        cb({ success = true, message = 'Dashboard requested: ' .. data.dashboardId })
    else
        cb({ success = false, message = 'Dashboard ID required' })
    end
end)

RegisterNUICallback('requestAnalyticsMetric', function(data, cb)
    if data.metricId then
        RequestMetric(data.metricId)
        cb({ success = true, message = 'Metric requested: ' .. data.metricId })
    else
        cb({ success = false, message = 'Metric ID required' })
    end
end)

RegisterNUICallback('trackAnalyticsEvent', function(data, cb)
    if data.category and data.eventType then
        TrackAnalyticsEvent(data.category, data.eventType, data.data or {})
        cb({ success = true, message = 'Event tracked: ' .. data.category .. '.' .. data.eventType })
    else
        cb({ success = false, message = 'Category and event type required' })
    end
end)

RegisterNUICallback('getAnalyticsData', function(data, cb)
    cb({
        success = true,
        dashboards = ClientState.dashboardData,
        metrics = ClientState.analyticsData,
        lastUpdate = ClientState.lastAnalyticsUpdate
    })
end)

print('^2[District Zero] ^7Advanced analytics system integrated')