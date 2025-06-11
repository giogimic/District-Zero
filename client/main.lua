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
        while isInMission and missionTimer > 0 do
            Wait(1000)
            missionTimer = missionTimer - 1
            
            -- Update UI
            SendNUIMessage({
                type = "updateTimer",
                time = Utils.FormatTime(missionTimer)
            })

            -- Check for mission timeout
            if missionTimer <= 0 then
                FailMission("Time's up!")
            end
        end
    end)
end

-- Mission Blips
function CreateMissionBlips(missionData)
    -- Clear existing blips
    ClearMissionBlips()

    -- Create new blips for objectives
    for _, objective in ipairs(missionData.objectives) do
        local location = Utils.GetRandomMissionLocation(objective.type)
        if location then
            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 5)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(objective.label)
            EndTextCommandSetBlipName(blip)
            table.insert(missionBlips, blip)
        end
    end
end

function ClearMissionBlips()
    for _, blip in ipairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
end

-- Mission Markers
function CreateMissionMarkers(missionData)
    -- Clear existing markers
    ClearMissionMarkers()

    -- Create new markers for objectives
    for _, objective in ipairs(missionData.objectives) do
        local location = Utils.GetRandomMissionLocation(objective.type)
        if location then
            table.insert(missionMarkers, {
                location = location,
                type = objective.type,
                label = objective.label
            })
        end
    end
end

function ClearMissionMarkers()
    missionMarkers = {}
end

-- Mission Completion
function CompleteMission()
    if not isInMission then return end

    -- Calculate rewards
    local timeBonus = math.floor((missionTimer / currentMission.timeLimit) * 100)
    local totalReward = Utils.CalculateMissionReward(
        currentMission.cashReward,
        PlayerData.level or 1,
        Config.Rewards.cashMultiplier
    )

    -- Trigger server event for rewards
    Utils.TriggerServerEvent("completeMission", {
        missionId = currentMission.id,
        timeBonus = timeBonus,
        totalReward = totalReward
    })

    -- Clean up
    CleanupMission()
    
    Utils.SendNotification("success", "Mission completed! Reward: " .. Utils.FormatMoney(totalReward))
end

function FailMission(reason)
    if not isInMission then return end

    Utils.TriggerServerEvent("failMission", {
        missionId = currentMission.id,
        reason = reason
    })

    -- Clean up
    CleanupMission()
    
    Utils.SendNotification("error", "Mission failed: " .. reason)
end

function CleanupMission()
    isInMission = false
    currentMission = nil
    missionTimer = 0
    ClearMissionBlips()
    ClearMissionMarkers()
    
    -- Hide mission UI
    SendNUIMessage({
        type = "hideMission"
    })
    SetNuiFocus(false, false)
end

-- Mission Objective Tracking
CreateThread(function()
    while true do
        Wait(0)
        if isInMission and currentMission then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for i, marker in ipairs(missionMarkers) do
                local distance = #(playerCoords - marker.location)
                
                -- Draw marker
                DrawMarker(1, marker.location.x, marker.location.y, marker.location.z - 1.0,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    1.0, 1.0, 1.0, 255, 255, 255, 100,
                    false, true, 2, false, nil, nil, false)

                -- Check for objective completion
                if distance < 2.0 then
                    if IsControlJustPressed(0, 38) then -- E key
                        CompleteObjective(marker.type)
                    end
                end
            end
        else
            Wait(1000)
        end
    end
end)

function CompleteObjective(objectiveType)
    if not currentMission then return end

    for i, objective in ipairs(currentMission.objectives) do
        if objective.type == objectiveType then
            objective.count = objective.count - 1
            
            -- Update UI
            SendNUIMessage({
                type = "updateObjective",
                objectiveIndex = i,
                remaining = objective.count
            })

            -- Check if all objectives are complete
            local allComplete = true
            for _, obj in ipairs(currentMission.objectives) do
                if obj.count > 0 then
                    allComplete = false
                    break
                end
            end

            if allComplete then
                CompleteMission()
            end

            break
        end
    end
end

-- NUI Callbacks
RegisterNUICallback('closeMission', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Security checks
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
