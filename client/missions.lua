-- District Zero Missions Module
-- Version: 1.0.0

local activeMission = nil
local missionTimer = nil
local missionBlips = {}

-- Initialize missions
function InitializeMissions()
    if not Config.Missions then return false end
    return true
end

-- Start mission
function StartMission(mission)
    if not mission then return false end
    
    -- Check if player can access mission
    if not exports['district-zero']:CanAccessMission(mission) then
        QBX.Functions.Notify('You cannot access this mission type', 'error')
        return false
    end

    -- Set active mission
    activeMission = mission
    
    -- Create mission blips
    CreateMissionBlips(mission)
    
    -- Start mission timer
    if mission.timeLimit then
        StartMissionTimer(mission.timeLimit)
    end
    
    -- Update UI
    SendNUIMessage({
        type = 'missionStarted',
        mission = mission
    })

    return true
end

-- Update mission
function UpdateMission(mission)
    if not mission then return false end
    
    activeMission = mission
    
    -- Update UI
    SendNUIMessage({
        type = 'missionUpdated',
        mission = mission
    })

    return true
end

-- Complete mission
function CompleteMission()
    if not activeMission then return false end
    
    -- Clear mission blips
    ClearMissionBlips()
    
    -- Stop mission timer
    if missionTimer then
        ClearTimeout(missionTimer)
        missionTimer = nil
    end
    
    -- Update UI
    SendNUIMessage({
        type = 'missionCompleted'
    })
    
    -- Clear active mission
    activeMission = nil

    return true
end

-- Fail mission
function FailMission()
    if not activeMission then return false end
    
    -- Clear mission blips
    ClearMissionBlips()
    
    -- Stop mission timer
    if missionTimer then
        ClearTimeout(missionTimer)
        missionTimer = nil
    end
    
    -- Update UI
    SendNUIMessage({
        type = 'missionFailed'
    })
    
    -- Clear active mission
    activeMission = nil

    return true
end

-- Create mission blips
function CreateMissionBlips(mission)
    ClearMissionBlips()
    
    -- Create blips for objectives
    for _, objective in pairs(mission.objectives) do
        if objective.coords then
            local blip = AddBlipForCoord(objective.coords.x, objective.coords.y, objective.coords.z)
            SetBlipSprite(blip, 1)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 5)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(objective.description)
            EndTextCommandSetBlipName(blip)
            
            table.insert(missionBlips, blip)
        end
    end
end

-- Clear mission blips
function ClearMissionBlips()
    for _, blip in pairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
end

-- Start mission timer
function StartMissionTimer(duration)
    if missionTimer then
        ClearTimeout(missionTimer)
    end
    
    local timeLeft = duration
    
    missionTimer = SetTimeout(1000, function()
        timeLeft = timeLeft - 1
        
        if timeLeft <= 0 then
            FailMission()
            return
        end
        
        -- Update UI
        SendNUIMessage({
            type = 'updateTimer',
            time = timeLeft
        })
        
        -- Continue timer
        StartMissionTimer(timeLeft)
    end)
end

-- Event handlers
RegisterNetEvent('dz:client:missionStarted', function(mission)
    StartMission(mission)
end)

RegisterNetEvent('dz:client:missionUpdated', function(mission)
    UpdateMission(mission)
end)

RegisterNetEvent('dz:client:missionCompleted', function()
    CompleteMission()
end)

RegisterNetEvent('dz:client:missionFailed', function()
    FailMission()
end)

-- Export functions
exports('GetActiveMission', function()
    return activeMission
end) 