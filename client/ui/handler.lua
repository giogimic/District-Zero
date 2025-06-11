-- client/ui/handler.lua
-- District Zero UI Handler

local QBCore = exports['qb-core']:GetCoreObject()
local isUIOpen = false

-- Show UI with mission data
local function ShowUI(missions)
    if isUIOpen then return end
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'show',
        data = {
            missions = missions
        }
    })
end

-- Hide UI
local function HideUI()
    if not isUIOpen then return end
    isUIOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'hide'
    })
end

-- Update mission progress
local function UpdateMission(mission)
    if not isUIOpen then return end
    SendNUIMessage({
        type = 'updateMission',
        data = {
            mission = mission
        }
    })
end

-- NUI Callbacks
RegisterNUICallback('close', function(_, cb)
    HideUI()
    cb({})
end)

RegisterNUICallback('acceptMission', function(data, cb)
    TriggerServerEvent('district-zero:server:acceptMission', data.missionId)
    cb({})
end)

RegisterNUICallback('declineMission', function(data, cb)
    TriggerServerEvent('district-zero:server:declineMission', data.missionId)
    cb({})
end)

-- Events
RegisterNetEvent('district-zero:client:showMissions', function(missions)
    ShowUI(missions)
end)

RegisterNetEvent('district-zero:client:updateMission', function(mission)
    UpdateMission(mission)
end)

RegisterNetEvent('district-zero:client:hideUI', function()
    HideUI()
end)

-- Command to open mission menu
RegisterCommand('missions', function()
    TriggerServerEvent('district-zero:server:requestMissions')
end)

-- Key mapping
RegisterKeyMapping('missions', 'Open Mission Menu', 'keyboard', 'F5')

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if isUIOpen then
            HideUI()
        end
    end
end) 