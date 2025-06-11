-- Client-side main file for District Zero
local QBCore = exports['qbx_core']:GetCoreObject()

-- Mission state
local activeMission = nil
local missionBlips = {}

-- Create mission blip
local function CreateMissionBlip(coords, type)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, type or 1)
    SetBlipColour(blip, 5)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mission Objective")
    EndTextCommandSetBlipName(blip)
    return blip
end

-- Clear mission blips
local function ClearMissionBlips()
    for _, blip in pairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
end

-- Update mission blips
local function UpdateMissionBlips(objectives)
    ClearMissionBlips()
    
    for _, objective in ipairs(objectives) do
        if not objective.completed and objective.coords then
            local blip = CreateMissionBlip(objective.coords, objective.blipType)
            table.insert(missionBlips, blip)
        end
    end
end

-- Check objective completion
local function CheckObjectiveCompletion(objective)
    if not objective or objective.completed then return false end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if objective.type == 'location' then
        local distance = #(playerCoords - vector3(objective.coords.x, objective.coords.y, objective.coords.z))
        return distance <= objective.radius
    elseif objective.type == 'kill' then
        return objective.kills >= objective.required
    elseif objective.type == 'collect' then
        return objective.collected >= objective.required
    end
    
    return false
end

-- Mission loop
CreateThread(function()
    while true do
        Wait(1000)
        
        if activeMission then
            for i, objective in ipairs(activeMission.objectives) do
                if not objective.completed and CheckObjectiveCompletion(objective) then
                    TriggerServerEvent('district-zero:server:completeObjective', activeMission.id, i)
                end
            end
        end
    end
end)

-- Events
RegisterNetEvent('district-zero:client:updateMission', function(mission)
    activeMission = mission
    UpdateMissionBlips(mission.objectives)
end)

RegisterNetEvent('district-zero:client:hideUI', function()
    activeMission = nil
    ClearMissionBlips()
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        ClearMissionBlips()
    end
end) 