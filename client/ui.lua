-- UI Handler
local QBX = exports.qbx_core:GetCoreObject()
local isUIOpen = false
local currentTab = nil

-- UI Configuration
local UIConfig = {
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

-- UI Functions
local function ToggleUI()
    isUIOpen = not isUIOpen
    SetNuiFocus(isUIOpen, isUIOpen)
    SendNUIMessage({
        action = "toggleUI",
        show = isUIOpen
    })
end

local function OpenTab(tabName)
    if not UIConfig.tabs[tabName] then return end
    
    currentTab = tabName
    SendNUIMessage({
        action = "openTab",
        tab = tabName,
        content = UIConfig.tabs[tabName].content
    })
end

local function UpdateSettings(settings)
    UIConfig.settings = settings
    SendNUIMessage({
        action = "updateSettings",
        settings = settings
    })
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
    TriggerServerEvent('district:useAbility', data.abilityId)
    cb('ok')
end)

RegisterNUICallback('startMission', function(data, cb)
    TriggerServerEvent('district:startMission', data.missionId)
    cb('ok')
end)

RegisterNUICallback('viewDistrict', function(data, cb)
    TriggerServerEvent('district:getDistrictInfo', data.districtId)
    cb('ok')
end)

-- Commands
RegisterCommand('district', function()
    ToggleUI()
end)

RegisterCommand('districtconfig', function()
    if isUIOpen then
        OpenTab('config')
    else
        ToggleUI()
        OpenTab('config')
    end
end)

-- Keybinds
RegisterKeyMapping('district', 'Open District Zero UI', 'keyboard', 'F6')
RegisterKeyMapping('districtconfig', 'Open District Zero Settings', 'keyboard', 'F7')

-- Events
RegisterNetEvent('district:updateUI', function(data)
    if isUIOpen then
        SendNUIMessage({
            action = "updateData",
            data = data
        })
    end
end)

RegisterNetEvent('district:notify', function(message, type)
    if UIConfig.settings.notifications then
        QBX.Functions.Notify(message, type)
    end
end)

-- Exports
exports('GetUIConfig', function()
    return UIConfig
end)

exports('UpdateSettings', function(settings)
    UpdateSettings(settings)
end)

-- Resource cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and isUIOpen then
        SetNuiFocus(false, false)
    end
end) 