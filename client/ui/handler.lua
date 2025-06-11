-- client/ui/handler.lua
-- District Zero UI Handler

local QBCore = exports['qb-core']:GetCoreObject()

-- UI State
local State = {
    isOpen = false,
    currentMenu = nil,
    currentData = nil,
    notifications = {}
}

-- Show UI
local function ShowUI(menu, data)
    if State.isOpen then return false end
    
    State.isOpen = true
    State.currentMenu = menu
    State.currentData = data
    
    -- Get locale data
    local locale = QBCore.Shared.Locale
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        menu = menu,
        data = data,
        locale = locale
    })
    
    return true
end

-- Hide UI
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

-- Update UI
local function UpdateUI(data)
    if not State.isOpen then return false end
    
    State.currentData = data
    
    SendNUIMessage({
        action = 'update',
        data = data
    })
    
    return true
end

-- Show notification using Qbox's notification system
local function ShowNotification(message, type)
    QBCore.Functions.Notify(message, type)
end

-- NUI Callbacks
RegisterNUICallback('getLocale', function(data, cb)
    cb(QBCore.Shared.Locale)
end)

RegisterNUICallback('factions/list', function(data, cb)
    QBCore.Functions.TriggerCallback('district-zero:server:getFactions', function(factions)
        cb(factions)
    end)
end)

RegisterNUICallback('factions/create', function(data, cb)
    TriggerServerEvent('district-zero:server:createFaction', data)
    cb({ success = true })
end)

RegisterNUICallback('factions/update', function(data, cb)
    TriggerServerEvent('district-zero:server:updateFaction', data)
    cb({ success = true })
end)

RegisterNUICallback('factions/delete', function(data, cb)
    TriggerServerEvent('district-zero:server:deleteFaction', data.id)
    cb({ success = true })
end)

RegisterNUICallback('events/list', function(data, cb)
    QBCore.Functions.TriggerCallback('district-zero:server:getEvents', function(events)
        cb(events)
    end)
end)

RegisterNUICallback('events/create', function(data, cb)
    TriggerServerEvent('district-zero:server:createEvent', data)
    cb({ success = true })
end)

RegisterNUICallback('events/update', function(data, cb)
    TriggerServerEvent('district-zero:server:updateEvent', data)
    cb({ success = true })
end)

RegisterNUICallback('events/delete', function(data, cb)
    TriggerServerEvent('district-zero:server:deleteEvent', data.id)
    cb({ success = true })
end)

RegisterNUICallback('events/start', function(data, cb)
    TriggerServerEvent('district-zero:server:startEvent', data.id)
    cb({ success = true })
end)

RegisterNUICallback('districts/list', function(data, cb)
    QBCore.Functions.TriggerCallback('district-zero:server:getDistricts', function(districts)
        cb(districts)
    end)
end)

RegisterNUICallback('close', function(data, cb)
    HideUI()
    cb({ success = true })
end)

-- Event Handlers
RegisterNetEvent('district-zero:client:openUI')
AddEventHandler('district-zero:client:openUI', function(menu, data)
    ShowUI(menu, data)
end)

RegisterNetEvent('district-zero:client:closeUI')
AddEventHandler('district-zero:client:closeUI', function()
    HideUI()
end)

RegisterNetEvent('district-zero:client:updateUI')
AddEventHandler('district-zero:client:updateUI', function(data)
    UpdateUI(data)
end)

RegisterNetEvent('district-zero:client:updateFactions')
AddEventHandler('district-zero:client:updateFactions', function(factions)
    SendNUIMessage({
        action = 'updateFactions',
        factions = factions
    })
end)

RegisterNetEvent('district-zero:client:updateEvents')
AddEventHandler('district-zero:client:updateEvents', function(events)
    SendNUIMessage({
        action = 'updateEvents',
        events = events
    })
end)

-- Menu Integration
RegisterNetEvent('district-zero:client:openMenu')
AddEventHandler('district-zero:client:openMenu', function()
    local menu = {
        {
            header = QBCore.Shared.Locale['menu']['title'],
            isMenuHeader = true
        },
        {
            header = QBCore.Shared.Locale['menu']['factions'],
            txt = QBCore.Shared.Locale['menu']['factions_desc'],
            params = {
                event = "district-zero:client:openUI",
                args = {
                    menu = "factions"
                }
            }
        },
        {
            header = QBCore.Shared.Locale['menu']['events'],
            txt = QBCore.Shared.Locale['menu']['events_desc'],
            params = {
                event = "district-zero:client:openUI",
                args = {
                    menu = "events"
                }
            }
        },
        {
            header = QBCore.Shared.Locale['menu']['districts'],
            txt = QBCore.Shared.Locale['menu']['districts_desc'],
            params = {
                event = "district-zero:client:openUI",
                args = {
                    menu = "districts"
                }
            }
        },
        {
            header = QBCore.Shared.Locale['menu']['close'],
            txt = "",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }
    
    exports['qb-menu']:openMenu(menu)
end)

-- Command to open menu
RegisterCommand('dz', function()
    TriggerEvent('district-zero:client:openMenu')
end)

-- Key mapping
RegisterKeyMapping('dz', QBCore.Shared.Locale['menu']['keybind'], 'keyboard', 'F6')

-- Register cleanup handler
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if State.isOpen then
            HideUI()
        end
    end
end) 