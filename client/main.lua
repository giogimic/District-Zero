-- Client-side main file for District Zero
local Bridge = require 'bridge/loader'
local Framework = Bridge.Load()
local isUIOpen = false
local currentMission = nil
local missionBlips = {}

-- Client-side main handler
local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Mission state management
local function CreateMissionBlip(mission)
    if missionBlips[mission.id] then
        RemoveMissionBlip(mission.id)
    end

    local blip = AddBlipForCoord(mission.coords.x, mission.coords.y, mission.coords.z)
    SetBlipSprite(blip, mission.blip.sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, mission.blip.scale or 0.8)
    SetBlipColour(blip, mission.blip.color or 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(mission.title)
    EndTextCommandSetBlipName(blip)

    missionBlips[mission.id] = blip
end

local function RemoveMissionBlip(missionId)
    if missionBlips[missionId] then
        RemoveBlip(missionBlips[missionId])
        missionBlips[missionId] = nil
    end
end

local function ClearMissionBlips()
    for _, blip in pairs(missionBlips) do
        RemoveBlip(blip)
    end
    missionBlips = {}
end

local function CheckObjectiveCompletion()
    if not currentMission then return end

    for i, objective in ipairs(currentMission.objectives) do
        if not objective.completed then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(objective.coords.x, objective.coords.y, objective.coords.z))
            
            if distance <= objective.radius then
                if objective.type == 'collect' then
                    Bridge.ShowTextUI('Press [E] to collect', 'objective')
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent('dz:completeObjective', currentMission.id, i)
                        Bridge.HideTextUI()
                    end
                elseif objective.type == 'kill' then
                    Bridge.ShowTextUI('Eliminate all targets', 'objective')
                    -- Add kill objective logic here
                elseif objective.type == 'deliver' then
                    Bridge.ShowTextUI('Press [E] to deliver', 'objective')
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent('dz:completeObjective', currentMission.id, i)
                        Bridge.HideTextUI()
                    end
                end
            else
                Bridge.HideTextUI()
            end
        end
    end
end

-- Mission loop
CreateThread(function()
    while true do
        Wait(0)
        if currentMission then
            CheckObjectiveCompletion()
        end
    end
end)

-- Toggle UI
local function ToggleUI()
    if not isUIOpen then
        -- Get data from server
        QBX.Functions.TriggerCallback('dz:server:getUIData', function(data)
            if data then
                -- Send data to UI
                SendNUIMessage({
                    type = 'showUI',
                    missions = data.missions,
                    districts = data.districts,
                    factions = data.factions
                })
                SetNuiFocus(true, true)
                isUIOpen = true
            end
        end)
    else
        SendNUIMessage({
            type = 'hideUI'
        })
        SetNuiFocus(false, false)
        isUIOpen = false
    end
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('acceptMission', function(data, cb)
    TriggerServerEvent('dz:server:acceptMission', data.missionId)
    cb('ok')
end)

-- Key mapping
RegisterCommand('+openMissionMenu', function()
    ToggleUI()
end, false)

RegisterKeyMapping('+openMissionMenu', 'Open Mission Menu', 'keyboard', 'F5')

-- Event handlers
RegisterNetEvent('dz:client:initialize')
AddEventHandler('dz:client:initialize', function(data)
    Utils.PrintDebug('Client initialized')
end)

RegisterNetEvent('dz:client:missionStarted')
AddEventHandler('dz:client:missionStarted', function(mission)
    currentMission = mission
    CreateMissionBlip(mission)
    QBX.Functions.Notify('New mission started: ' .. mission.title, 'primary')
end)

RegisterNetEvent('dz:client:missionUpdated')
AddEventHandler('dz:client:missionUpdated', function(mission)
    currentMission = mission
    CreateMissionBlip(mission)
end)

RegisterNetEvent('dz:client:missionCompleted')
AddEventHandler('dz:client:missionCompleted', function()
    ClearMissionBlips()
    currentMission = nil
    QBX.Functions.Notify('Mission completed!', 'success')
end)

RegisterNetEvent('dz:client:missionFailed')
AddEventHandler('dz:client:missionFailed', function()
    ClearMissionBlips()
    currentMission = nil
    QBX.Functions.Notify('Mission failed!', 'error')
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Wait for QBCore to be ready
    while not QBX do
        Wait(100)
    end
    
    -- Initialize client
    TriggerEvent('dz:client:initialize')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Close UI if open
    if isUIOpen then
        SetNuiFocus(false, false)
    end
    
    -- Clear blips
    ClearMissionBlips()
end) 