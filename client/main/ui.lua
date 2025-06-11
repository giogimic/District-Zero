-- client/main/ui.lua
-- District Zero UI Handler

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- UI State
local State = {
    isUIOpen = false,
    currentTab = nil,
    config = {
        tabs = {
            abilities = {
                label = "Abilities",
                icon = "fas fa-magic",
                content = "abilities.html"
            },
            districts = {
                label = "Districts",
                icon = "fas fa-map-marked-alt",
                content = "districts.html"
            },
            missions = {
                label = "Missions",
                icon = "fas fa-tasks",
                content = "missions.html"
            },
            config = {
                label = "Settings",
                icon = "fas fa-cog",
                content = "config.html"
            }
        },
        settings = {
            notifications = true,
            blips = true,
            markers = true,
            minimap = true,
            debug = false
        }
    }
}

-- UI Functions
local function ToggleUI()
    State.isUIOpen = not State.isUIOpen
    SetNuiFocus(State.isUIOpen, State.isUIOpen)
    Events.TriggerEvent('dz:client:ui:toggle', 'client', State.isUIOpen)
end

local function OpenTab(tabName)
    if not State.config.tabs[tabName] then return end
    
    State.currentTab = tabName
    Events.TriggerEvent('dz:client:ui:openTab', 'client', {
        tab = tabName,
        content = State.config.tabs[tabName].content
    })
end

local function UpdateSettings(settings)
    State.config.settings = settings
    Events.TriggerEvent('dz:client:ui:updateSettings', 'client', settings)
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    ToggleUI()
    cb('ok')
end)

RegisterNUICallback('openTab', function(data, cb)
    OpenTab(data.tab)
    cb('ok')
end)

RegisterNUICallback('updateSettings', function(data, cb)
    UpdateSettings(data.settings)
    cb('ok')
end)

RegisterNUICallback('useAbility', function(data, cb)
    Events.TriggerEvent('dz:client:ability:use', 'client', data.abilityId)
    cb('ok')
end)

RegisterNUICallback('startMission', function(data, cb)
    Events.TriggerEvent('dz:client:mission:start', 'client', data.missionId)
    cb('ok')
end)

RegisterNUICallback('viewDistrict', function(data, cb)
    Events.TriggerEvent('dz:client:district:getInfo', 'client', data.districtId)
    cb('ok')
end)

-- Commands
RegisterCommand('district', function()
    ToggleUI()
end)

RegisterCommand('districtconfig', function()
    if State.isUIOpen then
        OpenTab('config')
    else
        ToggleUI()
        OpenTab('config')
    end
end)

-- Keybinds
RegisterKeyMapping('district', 'Open District Zero UI', 'keyboard', 'F6')
RegisterKeyMapping('districtconfig', 'Open District Zero Settings', 'keyboard', 'F7')

-- Event Handlers
Events.RegisterEvent('dz:client:ui:update', function(data)
    if State.isUIOpen then
        Events.TriggerEvent('dz:client:ui:updateData', 'client', data)
    end
end)

Events.RegisterEvent('dz:client:ui:notify', function(message, type)
    if State.config.settings.notifications then
        QBX.Functions.Notify(message, type)
    end
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        isUIOpen = false,
        currentTab = nil,
        config = {
            tabs = {
                abilities = {
                    label = "Abilities",
                    icon = "fas fa-magic",
                    content = "abilities.html"
                },
                districts = {
                    label = "Districts",
                    icon = "fas fa-map-marked-alt",
                    content = "districts.html"
                },
                missions = {
                    label = "Missions",
                    icon = "fas fa-tasks",
                    content = "missions.html"
                },
                config = {
                    label = "Settings",
                    icon = "fas fa-cog",
                    content = "config.html"
                }
            },
            settings = {
                notifications = true,
                blips = true,
                markers = true,
                minimap = true,
                debug = false
            }
        }
    }
end)

-- Register NUI cleanup handler
RegisterCleanup('nui', function()
    -- Close UI
    if State.isUIOpen then
        SetNuiFocus(false, false)
        Events.TriggerEvent('dz:client:ui:toggle', 'client', false)
    end
end)

-- Exports
exports('GetUIConfig', function()
    return State.config
end)

exports('UpdateSettings', function(settings)
    UpdateSettings(settings)
end) 