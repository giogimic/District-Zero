-- District Zero UI Module
-- Version: 1.0.0

local QBX = exports['qbx_core']:GetSharedObject()
local Utils = require 'shared/utils'

-- State
local isUIOpen = false

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

-- Event handlers
RegisterNetEvent('dz:client:updateUI')
AddEventHandler('dz:client:updateUI', function(data)
    if isUIOpen then
        SendNUIMessage({
            type = 'updateUI',
            missions = data.missions,
            districts = data.districts,
            currentDistrict = data.currentDistrict,
            currentTeam = data.currentTeam
        })
    end
end)

-- Export functions
exports('ToggleUI', ToggleUI) 