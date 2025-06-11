-- client/ui/ui.lua
-- District Zero UI Handler

local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- UI State
local State = {
    isOpen = false,
    currentMenu = nil,
    currentData = nil,
    notifications = {},
    menuConfig = {
        position = vector2(0.85, 0.5),
        width = 0.3,
        height = 0.6,
        title = "District Zero",
        tabs = {
            {name = 'districts', label = 'Districts', icon = '🗺️'},
            {name = 'missions', label = 'Missions', icon = '🎯'},
            {name = 'factions', label = 'Factions', icon = '👥'},
            {name = 'stats', label = 'Stats', icon = '📊'}
        }
    }
}

-- UI Functions
local function ShowUI(menu, data)
    if State.isOpen then return false end
    
    State.isOpen = true
    State.currentMenu = menu
    State.currentData = data
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        menu = menu,
        data = data,
        config = State.menuConfig
    })
    
    return true
end

local function HideUI()
    if not State.isOpen then return false end
    
    State.isOpen = false
    State.currentMenu = nil
    State.currentData = nil
    
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'hide'
    })
    
    return true
end

local function UpdateUI(data)
    if not State.isOpen then return false end
    
    State.currentData = data
    
    SendNUIMessage({
        action = 'update',
        data = data
    })
    
    return true
end

local function ShowNotification(message, type)
    local id = #State.notifications + 1
    
    State.notifications[id] = {
        message = message,
        type = type,
        time = GetGameTimer()
    }
    
    SendNUIMessage({
        action = 'notification',
        id = id,
        message = message,
        type = type
    })
    
    -- Remove notification after 5 seconds
    SetTimeout(5000, function()
        if State.notifications[id] then
            State.notifications[id] = nil
            SendNUIMessage({
                action = 'removeNotification',
                id = id
            })
        end
    end)
    
    return id
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    HideUI()
    cb('ok')
end)

RegisterNUICallback('action', function(data, cb)
    if not State.isOpen then
        cb('error')
        return
    end
    
    -- Handle UI actions
    if data.action == 'select' then
        Events.TriggerEvent('dz:client:ui:select', 'client', data.value)
    elseif data.action == 'back' then
        Events.TriggerEvent('dz:client:ui:back', 'client')
    elseif data.action == 'confirm' then
        Events.TriggerEvent('dz:client:ui:confirm', 'client', data.value)
    end
    
    cb('ok')
end)

-- Event Handlers
Events.RegisterEvent('dz:client:ui:show', function(source, menu, data)
    ShowUI(menu, data)
end)

Events.RegisterEvent('dz:client:ui:hide', function(source)
    HideUI()
end)

Events.RegisterEvent('dz:client:ui:update', function(source, data)
    UpdateUI(data)
end)

Events.RegisterEvent('dz:client:ui:notification', function(source, message, type)
    ShowNotification(message, type)
end)

-- Menu Toggle Handler
RegisterNetEvent('dz:client:menu:toggle')
AddEventHandler('dz:client:menu:toggle', function()
    if State.isOpen then
        HideUI()
    else
        ShowUI('main', State.currentData)
    end
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        isOpen = false,
        currentMenu = nil,
        currentData = nil,
        notifications = {}
    }
    
    -- Hide UI
    HideUI()
end)

-- Register NUI cleanup handler
RegisterCleanup('nui', function()
    -- Hide UI
    HideUI()
    
    -- Clear notifications
    for id, _ in pairs(State.notifications) do
        SendNUIMessage({
            action = 'removeNotification',
            id = id
        })
    end
    State.notifications = {}
end)

-- Exports
exports('ShowUI', ShowUI)
exports('HideUI', HideUI)
exports('UpdateUI', UpdateUI)
exports('ShowNotification', ShowNotification) 