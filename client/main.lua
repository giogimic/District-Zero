-- District Zero Client
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'
local isInitialized = false

-- State management
local isUIOpen = false
local currentMission = nil
local currentTeam = nil
local currentDistrict = nil
local missionBlips = {}
local districtBlips = {}
local controlPointBlips = {}

-- Blip management
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

local function CreateDistrictBlips()
    for _, district in pairs(Config.Districts) do
        local blip = AddBlipForCoord(district.blip.coords.x, district.blip.coords.y, district.blip.coords.z)
        SetBlipSprite(blip, district.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, district.blip.scale)
        SetBlipColour(blip, district.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(district.name)
        EndTextCommandSetBlipName(blip)

        districtBlips[district.id] = blip

        -- Create control point blips
        for _, point in pairs(district.controlPoints) do
            local pointBlip = AddBlipForCoord(point.coords.x, point.coords.y, point.coords.z)
            SetBlipSprite(pointBlip, 1)
            SetBlipDisplay(pointBlip, 4)
            SetBlipScale(pointBlip, 0.6)
            SetBlipColour(pointBlip, 0)
            SetBlipAsShortRange(pointBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(point.name)
            EndTextCommandSetBlipName(pointBlip)

            controlPointBlips[point.name] = pointBlip
        end
    end
end

local function ClearDistrictBlips()
    for _, blip in pairs(districtBlips) do
        RemoveBlip(blip)
    end
    districtBlips = {}

    for _, blip in pairs(controlPointBlips) do
        RemoveBlip(blip)
    end
    controlPointBlips = {}
end

-- Mission and district checks
local function CheckObjectiveCompletion()
    if not currentMission then return end

    for i, objective in ipairs(currentMission.objectives) do
        if not objective.completed then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(objective.coords.x, objective.coords.y, objective.coords.z))
            
            if distance <= objective.radius then
                if objective.type == 'capture' then
                    QBX.Functions.DrawText3D(objective.coords.x, objective.coords.y, objective.coords.z, 'Press [E] to capture')
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent('dz:server:capturePoint', currentMission.id, i)
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
    local currentDistrict = nil

    for _, district in pairs(Config.Districts) do
        for _, zone in pairs(district.zones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                inDistrict = true
                currentDistrict = district
                break
            end
        end
        if inDistrict then break end
    end

    if inDistrict and not zone.isSafeZone then
        -- In conflict district
        if not currentTeam then
            -- Show team selection if not in a team
            SendNUIMessage({
                type = 'showUI',
                showTeamSelect = true
            })
            SetNuiFocus(true, true)
        end
    else
        -- Outside district or in safe zone
        currentTeam = nil
    end
end

-- Main loops
CreateThread(function()
    while true do
        Wait(0)
        if currentMission then
            CheckObjectiveCompletion()
        end
        CheckDistrictBoundaries()
    end
end)

-- UI Management
local function ToggleUI()
    if not isUIOpen then
        QBX.Functions.TriggerCallback('dz:server:getUIData', function(data)
            if data then
                SendNUIMessage({
                    type = 'showUI',
                    missions = data.missions,
                    districts = data.districts
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

RegisterNUICallback('selectTeam', function(data, cb)
    currentTeam = data.team
    TriggerServerEvent('dz:server:selectTeam', data.team)
    cb('ok')
end)

RegisterNUICallback('acceptMission', function(data, cb)
    if not currentTeam then
        QBX.Functions.Notify('You must select a team first!', 'error')
        return
    end
    TriggerServerEvent('dz:server:acceptMission', data.missionId)
    cb('ok')
end)

-- Key mapping
RegisterCommand('dz', function()
    ToggleUI()
end, false)

RegisterKeyMapping('dz', 'Open District Zero Menu', 'keyboard', 'F5')

-- Event handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Initialize()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isInitialized = false
    ClearDistrictBlips()
    ClearMissionBlips()
end)

RegisterNetEvent('dz:client:initialize')
AddEventHandler('dz:client:initialize', function(data)
    Initialize()
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

RegisterNetEvent('dz:client:districtUpdated')
AddEventHandler('dz:client:districtUpdated', function(district)
    currentDistrict = district
    -- Update district blips and UI
end)

-- Initialize on resource start
CreateThread(function()
    Wait(1000) -- Wait for QBX to be ready
    Initialize()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if isUIOpen then
        SetNuiFocus(false, false)
    end
    
    ClearMissionBlips()
    ClearDistrictBlips()
end)

-- Initialize the system
local function Initialize()
    if isInitialized then return end
    
    -- Validate config
    if not Config then
        Utils.PrintError('VALIDATION: Config is not defined')
        return false
    end
    
    if not Config.Districts then
        Utils.PrintError('VALIDATION: Config.Districts is not defined')
        return false
    end
    
    if not Config.Missions then
        Utils.PrintError('VALIDATION: Config.Missions is not defined')
        return false
    end
    
    -- Initialize districts
    if not InitializeDistricts() then
        Utils.PrintError('INIT: Failed to initialize districts')
        return false
    end
    
    -- Create district blips
    CreateDistrictBlips()
    
    isInitialized = true
    Utils.PrintDebug('Client initialized')
    return true
end

-- Initialize districts
local function InitializeDistricts()
    if not Config.Districts then return false end
    
    for _, district in pairs(Config.Districts) do
        if not district.id or not district.name or not district.zones then
            Utils.PrintError('INIT: Invalid district configuration: ' .. (district.id or 'unknown'))
            return false
        end
    end
    
    return true
end 