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
local function CreateMissionBlip(coords, type, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, type)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function ClearMissionBlips()
    for _, blip in pairs(missionBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    missionBlips = {}
end

local function UpdateMissionBlips()
    ClearMissionBlips()
    if not currentMission then return end

    -- Add mission start blip
    if currentMission.startCoords then
        missionBlips.start = CreateMissionBlip(
            currentMission.startCoords,
            currentMission.startBlip or 1,
            currentMission.startLabel or 'Mission Start'
        )
    end

    -- Add objective blips
    if currentMission.objectives then
        for i, objective in ipairs(currentMission.objectives) do
            if objective.coords and not objective.completed then
                missionBlips['obj_' .. i] = CreateMissionBlip(
                    objective.coords,
                    objective.blip or 1,
                    objective.label or ('Objective ' .. i)
                )
            end
        end
    end
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
    isUIOpen = not isUIOpen
    SetNuiFocus(isUIOpen, isUIOpen)
    
    if isUIOpen then
        -- Get missions and districts data
        local missions = exports['dz']:GetMissions()
        local districts = exports['dz']:GetDistricts()
        
        -- Send data to UI
        SendNUIMessage({
            type = 'showUI',
            missions = missions,
            districts = districts
        })
    else
        SendNUIMessage({
            type = 'hideUI'
        })
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
    -- Initialize client state
    Utils.PrintDebug('Client initialized')
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
end) 