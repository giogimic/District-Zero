local activeMission = nil
local missionBlips = {}
local missionVehicle = nil

-- Initialize mission system
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if activeMission then
            DrawMissionUI()
        end
    end
end)

-- Handle mission start
RegisterNetEvent('mission:started')
AddEventHandler('mission:started', function(mission)
    activeMission = mission
    SpawnMissionVehicle(mission.vehicle)
    CreateMissionBlips(mission)
    ShowNotification("Mission started: " .. Config.Missions[mission.type][mission.id].name)
end)

-- Handle mission completion
RegisterNetEvent('mission:completed')
AddEventHandler('mission:completed', function(missionId, reward)
    if activeMission and activeMission.id == missionId then
        ShowNotification("Mission completed! Reward: $" .. reward.money)
        CleanupMission()
    end
end)

-- Handle mission failure
RegisterNetEvent('mission:failed')
AddEventHandler('mission:failed', function(missionId, reason)
    if activeMission and activeMission.id == missionId then
        ShowNotification("Mission failed: " .. reason, "error")
        CleanupMission()
    end
end)

-- Handle player joining mission
RegisterNetEvent('mission:playerJoined')
AddEventHandler('mission:playerJoined', function(missionId, player)
    if activeMission and activeMission.id == missionId then
        local playerName = GetPlayerName(player)
        ShowNotification(playerName .. " joined the mission")
    end
end)

-- Draw mission UI
function DrawMissionUI()
    if not activeMission then return end
    
    local mission = Config.Missions[activeMission.type][activeMission.id]
    local timeLeft = activeMission.endTime - os.time()
    
    -- Draw mission info
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(mission.name .. "\nTime left: " .. timeLeft .. "s")
    DrawText(0.5, 0.05)
    
    -- Draw mission description
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 200)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(mission.description)
    DrawText(0.5, 0.1)
end

-- Spawn mission vehicle
function SpawnMissionVehicle(vehicleModel)
    -- Request model
    local model = GetHashKey(vehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    
    -- Get player position
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    
    -- Spawn vehicle
    missionVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(playerPed, missionVehicle, -1)
    SetVehicleEngineOn(missionVehicle, true, true, false)
    
    -- Set vehicle properties
    SetVehicleDoorsLocked(missionVehicle, 2)
    SetVehicleHasBeenOwnedByPlayer(missionVehicle, true)
    SetEntityAsMissionEntity(missionVehicle, true, true)
    
    -- Release model
    SetModelAsNoLongerNeeded(model)
end

-- Create mission blips
function CreateMissionBlips(mission)
    -- Create start blip
    local startBlip = AddBlipForCoord(mission.location.x, mission.location.y, mission.location.z)
    SetBlipSprite(startBlip, 1)
    SetBlipColour(startBlip, 2)
    SetBlipScale(startBlip, 1.0)
    SetBlipAsShortRange(startBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mission Start")
    EndTextCommandSetBlipName(startBlip)
    table.insert(missionBlips, startBlip)
    
    -- Create objective blips
    local missionData = Config.Missions[mission.type][mission.id]
    for i, location in ipairs(missionData.locations) do
        if i > 1 then -- Skip first location as it's the start
            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 5)
            SetBlipScale(blip, 1.0)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Mission Objective " .. (i - 1))
            EndTextCommandSetBlipName(blip)
            table.insert(missionBlips, blip)
        end
    end
end

-- Clean up mission
function CleanupMission()
    -- Remove blips
    for _, blip in ipairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
    
    -- Remove vehicle
    if missionVehicle and DoesEntityExist(missionVehicle) then
        DeleteEntity(missionVehicle)
    end
    missionVehicle = nil
    
    -- Clear active mission
    activeMission = nil
end

-- Show notification
function ShowNotification(message, type)
    type = type or "info"
    
    -- Implement based on your notification system
    -- Example using native notification:
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

-- Export functions
exports('GetActiveMission', function()
    return activeMission
end)

exports('GetMissionVehicle', function()
    return missionVehicle
end) 