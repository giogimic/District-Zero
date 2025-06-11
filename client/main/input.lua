-- client/main/input.lua
-- Input handling for District Zero

local QBX = exports['qb-core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Key Bindings Configuration
local Config = {
    defaultBindings = {
        menu = 'F5',
        missions = 'F6',
        factions = 'F7',
        stats = 'F8',
        abilities = {
            '1',
            '2',
            '3'
        }
    }
}

-- Key Bindings State
local KeyBindings = {}

-- Initialize Key Bindings
local function InitializeKeyBindings()
    -- Register main menu command
    RegisterCommand('+toggleDistrictMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        Events.TriggerEvent('dz:client:menu:toggle')
    end, false)
    
    -- Register missions menu command
    RegisterCommand('+toggleMissionsMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        Events.TriggerEvent('dz:client:missions:toggle')
    end, false)
    
    -- Register factions menu command
    RegisterCommand('+toggleFactionsMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        Events.TriggerEvent('dz:client:factions:toggle')
    end, false)
    
    -- Register stats menu command
    RegisterCommand('+toggleStatsMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        Events.TriggerEvent('dz:client:stats:toggle')
    end, false)
    
    -- Register ability commands
    for i, key in ipairs(Config.defaultBindings.abilities) do
        RegisterCommand('+useAbility' .. i, function()
            if not QBX.Functions.GetPlayerData().citizenid then return end
            Events.TriggerEvent('dz:client:ability:use', i)
        end, false)
    end
    
    -- Register key mappings
    RegisterKeyMapping('+toggleDistrictMenu', 'Toggle District Zero Menu', 'keyboard', Config.defaultBindings.menu)
    RegisterKeyMapping('+toggleMissionsMenu', 'Toggle Missions Menu', 'keyboard', Config.defaultBindings.missions)
    RegisterKeyMapping('+toggleFactionsMenu', 'Toggle Factions Menu', 'keyboard', Config.defaultBindings.factions)
    RegisterKeyMapping('+toggleStatsMenu', 'Toggle Stats Menu', 'keyboard', Config.defaultBindings.stats)
    
    -- Register ability key mappings
    for i, key in ipairs(Config.defaultBindings.abilities) do
        RegisterKeyMapping('+useAbility' .. i, 'Use Ability ' .. i, 'keyboard', key)
    end
end

-- Player Load Handler
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    InitializeKeyBindings()
end)

-- Player Unload Handler
RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    -- Cleanup key bindings
    KeyBindings = {}
end)

-- Exports
exports('GetKeyBinding', function(action)
    return KeyBindings[action]
end)

exports('SetKeyBinding', function(action, key)
    if not Config.defaultBindings[action] then return false end
    KeyBindings[action] = key
    return true
end)

exports('GetAllKeyBindings', function()
    return KeyBindings
end)

-- NUI Focus Management
local function SetNuiFocus(hasFocus, hasCursor)
    SetNuiFocus(hasFocus, hasCursor)
    if hasFocus then
        SetNuiFocusKeepInput(false)
    end
end

-- Event Handlers
RegisterNetEvent('dz:menu:toggle')
AddEventHandler('dz:menu:toggle', function()
    local isMenuOpen = LocalPlayer.state.menuOpen or false
    SetNuiFocus(not isMenuOpen, not isMenuOpen)
    LocalPlayer.state:set('menuOpen', not isMenuOpen, true)
    SendNUIMessage({
        type = isMenuOpen and 'hide' or 'show'
    })
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    LocalPlayer.state:set('menuOpen', false, true)
    cb('ok')
end)

-- Input validation
local function IsValidInput()
    return LocalPlayer.state.isLoggedIn and not LocalPlayer.state.isDead
end

-- Export functions
exports('SetNuiFocus', SetNuiFocus)
exports('IsValidInput', IsValidInput) 