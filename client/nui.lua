-- District Zero NUI Handler
local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'

-- NUI State
local NUI = {
    isVisible = false,
    isFocused = false,
    currentMenu = nil,
    menus = {
        main = 'html/index.html',
        missions = 'html/missions.html',
        factions = 'html/factions.html',
        stats = 'html/stats.html'
    }
}

-- Show NUI
local function ShowNUI(menu)
    if not menu or not NUI.menus[menu] then return false end
    
    NUI.isVisible = true
    NUI.currentMenu = menu
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = 'show',
        menu = menu
    })
    
    return true
end

-- Hide NUI
local function HideNUI()
    if not NUI.isVisible then return false end
    
    NUI.isVisible = false
    NUI.currentMenu = nil
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        type = 'hide'
    })
    
    return true
end

-- Toggle NUI
local function ToggleNUI(menu)
    if NUI.isVisible and NUI.currentMenu == menu then
        return HideNUI()
    else
        return ShowNUI(menu)
    end
end

-- NUI Callback Handler
RegisterNUICallback('close', function(data, cb)
    HideNUI()
    if cb then cb('ok') end
end)

RegisterNUICallback('focus', function(data, cb)
    NUI.isFocused = true
    if cb then cb('ok') end
end)

RegisterNUICallback('blur', function(data, cb)
    NUI.isFocused = false
    if cb then cb('ok') end
end)

-- NUI Event Handlers
RegisterNetEvent('dz:nui:show')
AddEventHandler('dz:nui:show', function(menu)
    ShowNUI(menu)
end)

RegisterNetEvent('dz:nui:hide')
AddEventHandler('dz:nui:hide', function()
    HideNUI()
end)

RegisterNetEvent('dz:nui:toggle')
AddEventHandler('dz:nui:toggle', function(menu)
    ToggleNUI(menu)
end)

-- Resource Stop Handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if NUI.isVisible then
        HideNUI()
    end
end)

-- Exports
exports('ShowNUI', ShowNUI)
exports('HideNUI', HideNUI)
exports('ToggleNUI', ToggleNUI)
exports('IsNUIVisible', function()
    return NUI.isVisible
end)
exports('IsNUIFocused', function()
    return NUI.isFocused
end)

-- NUI Documentation
--[[
NUI Documentation:

Menus:
- main: Main menu (html/index.html)
- missions: Missions menu (html/missions.html)
- factions: Factions menu (html/factions.html)
- stats: Stats menu (html/stats.html)

Usage:
- Show NUI: exports['district_zero']:ShowNUI('main')
- Hide NUI: exports['district_zero']:HideNUI()
- Toggle NUI: exports['district_zero']:ToggleNUI('main')
- Check visibility: exports['district_zero']:IsNUIVisible()
- Check focus: exports['district_zero']:IsNUIFocused()

Events:
- dz:nui:show: Show NUI menu
- dz:nui:hide: Hide NUI
- dz:nui:toggle: Toggle NUI menu

Callbacks:
- close: Close NUI
- focus: NUI focused
- blur: NUI blurred
]] 