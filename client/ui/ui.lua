-- client/ui/ui.lua
-- District Zero UI Handler

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- UI State
local State = {
    isOpen = false,
    currentMenu = nil,
    currentData = nil,
    notifications = {}
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
        data = data
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