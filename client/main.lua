-- client/main.lua
-- Client logic for APB systems (e.g., mission UI, player tracking)

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentMission = nil
local missionBlips = {}
local missionMarkers = {}
local isInMission = false
local missionTimer = 0
local missionStartTime = 0

-- Initialize player data
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Utils.PrintDebug("Player data loaded")
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    Utils.PrintDebug("Player data unloaded")
end)

-- Mission System
RegisterNetEvent('apb:client:startMission', function(missionData)
    if isInMission then
        Utils.SendNotification("error", "You are already in a mission!")
        return
    end

    currentMission = missionData
    isInMission = true
    missionStartTime = GetGameTimer()
    missionTimer = missionData.timeLimit

    -- Create mission blips and markers
    CreateMissionBlips(missionData)
    CreateMissionMarkers(missionData)

    -- Start mission timer
    StartMissionTimer()

    -- Show mission UI
    SendNUIMessage({
        type = "showMission",
        mission = missionData
    })
    SetNuiFocus(true, true)

    Utils.SendNotification("success", "Mission started: " .. missionData.label)
end)

-- Mission Timer
function StartMissionTimer()
    CreateThread(function()
        while isInMission do
            Wait(1000)
            missionTimer = missionTimer - 1
            
            if missionTimer <= 0 then
                FailMission("Time's up!")
                break
            end
            
            -- Update UI
            SendNUIMessage({
                type = "updateTimer",
                time = missionTimer
            })
        end
    end)
end

-- Mission Blips
function CreateMissionBlips(missionData)
    -- Clear existing blips
    for _, blip in pairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
    
    -- Create new blips
    for _, location in ipairs(missionData.locations) do
        local blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, location.blipSprite or 1)
        SetBlipColour(blip, location.blipColor or 1)
        SetBlipScale(blip, location.blipScale or 1.0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(location.label or "Mission Location")
        EndTextCommandSetBlipName(blip)
        table.insert(missionBlips, blip)
    end
end

-- Mission Markers
function CreateMissionMarkers(missionData)
    -- Clear existing markers
    missionMarkers = {}
    
    -- Create new markers
    for _, location in ipairs(missionData.locations) do
        table.insert(missionMarkers, {
            coords = vector3(location.x, location.y, location.z),
            type = location.markerType or 1,
            size = location.markerSize or vector3(1.0, 1.0, 1.0),
            color = location.markerColor or {r = 255, g = 255, b = 255, a = 100},
            bobUpAndDown = location.markerBob or false,
            faceCamera = location.markerFaceCamera or false,
            rotate = location.markerRotate or false,
            textureDict = location.markerTextureDict,
            textureName = location.markerTextureName,
            drawDistance = location.markerDrawDistance or 10.0
        })
    end
end

-- Mission Cleanup
function CleanupMission()
    -- Clear blips
    for _, blip in pairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
    
    -- Clear markers
    missionMarkers = {}
    
    -- Reset mission state
    currentMission = nil
    isInMission = false
    missionTimer = 0
    missionStartTime = 0
    
    -- Hide UI
    SendNUIMessage({
        type = "hideMission"
    })
    SetNuiFocus(false, false)
end

-- Mission Failure
function FailMission(reason)
    if not isInMission then return end
    
    -- Notify server
    TriggerServerEvent('apb:server:failMission', {
        missionId = currentMission.id,
        reason = reason
    })
    
    -- Cleanup
    CleanupMission()
    
    -- Notify player
    Utils.SendNotification("error", "Mission failed: " .. reason)
end

-- Mission Success
function CompleteMission()
    if not isInMission then return end
    
    -- Notify server
    TriggerServerEvent('apb:server:completeMission', {
        missionId = currentMission.id
    })
    
    -- Cleanup
    CleanupMission()
    
    -- Notify player
    Utils.SendNotification("success", "Mission completed successfully!")
end

-- Security Checks
CreateThread(function()
    while true do
        Wait(Config.Security.checkInterval)
        
        if isInMission then
            local playerPed = PlayerPedId()
            
            -- Check speed
            local speed = GetEntitySpeed(playerPed)
            if not Utils.IsValidSpeed(speed) then
                FailMission("Speed hack detected")
            end
            
            -- Check health
            local health = GetEntityHealth(playerPed)
            if not Utils.IsValidHealth(health) then
                FailMission("Health hack detected")
            end
            
            -- Check armor
            local armor = GetPedArmour(playerPed)
            if not Utils.IsValidArmor(armor) then
                FailMission("Armor hack detected")
            end
        end
    end
end)

-- Initialize
CreateThread(function()
    Utils.PrintDebug("Client script loaded")
    -- Additional initialization code here
end)
