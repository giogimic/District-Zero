-- District Zero Input Handler
local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Key Bindings Configuration
local Config = {
    defaultBindings = {
        menu = 'F5',
        missions = 'F6',
        factions = 'F7',
        stats = 'F8'
    },
    allowedKeys = {
        'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10',
        'F11', 'F12', 'INSERT', 'HOME', 'PAGEUP', 'PAGEDOWN', 'DELETE', 'END'
    }
}

-- Key Bindings State
local KeyBindings = {}

-- Load Key Bindings
local function LoadKeyBindings()
    local savedBindings = QBX.Functions.GetPlayerData().metadata.keyBindings
    if savedBindings then
        KeyBindings = savedBindings
    else
        KeyBindings = Config.defaultBindings
    end
end

-- Save Key Bindings
local function SaveKeyBindings()
    QBX.Functions.SetPlayerData('metadata', {
        keyBindings = KeyBindings
    })
end

-- Validate Key
local function ValidateKey(key)
    for _, allowedKey in ipairs(Config.allowedKeys) do
        if key == allowedKey then
            return true
        end
    end
    return false
end

-- Register Key Binding
local function RegisterKeyBinding(action, key)
    if not action or not key then return false end
    if not ValidateKey(key) then return false end
    
    -- Check for conflicts
    for actionName, boundKey in pairs(KeyBindings) do
        if boundKey == key and actionName ~= action then
            return false
        end
    end
    
    KeyBindings[action] = key
    SaveKeyBindings()
    return true
end

-- Initialize Key Bindings
local function InitializeKeyBindings()
    LoadKeyBindings()
    
    -- Register default bindings
    for action, key in pairs(Config.defaultBindings) do
        if not KeyBindings[action] then
            RegisterKeyBinding(action, key)
        end
    end
    
    -- Register commands
    RegisterCommand('+toggleDistrictMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        TriggerEvent('dz:menu:toggle')
    end, false)
    
    RegisterCommand('+toggleMissionsMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        TriggerEvent('dz:missions:toggle')
    end, false)
    
    RegisterCommand('+toggleFactionsMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        TriggerEvent('dz:factions:toggle')
    end, false)
    
    RegisterCommand('+toggleStatsMenu', function()
        if not QBX.Functions.GetPlayerData().citizenid then return end
        TriggerEvent('dz:stats:toggle')
    end, false)
    
    -- Register key mappings
    RegisterKeyMapping('+toggleDistrictMenu', 'Toggle District Zero Menu', 'keyboard', KeyBindings.menu)
    RegisterKeyMapping('+toggleMissionsMenu', 'Toggle Missions Menu', 'keyboard', KeyBindings.missions)
    RegisterKeyMapping('+toggleFactionsMenu', 'Toggle Factions Menu', 'keyboard', KeyBindings.factions)
    RegisterKeyMapping('+toggleStatsMenu', 'Toggle Stats Menu', 'keyboard', KeyBindings.stats)
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
    return RegisterKeyBinding(action, key)
end)

exports('GetAllKeyBindings', function()
    return KeyBindings
end)

-- Key Binding Documentation
--[[
Key Binding Documentation:

Default Bindings:
- Menu: F5
- Missions: F6
- Factions: F7
- Stats: F8

Allowed Keys:
- Function Keys: F1-F12
- Navigation Keys: INSERT, HOME, PAGEUP, PAGEDOWN, DELETE, END

Usage:
- Get key binding: exports['district_zero']:GetKeyBinding('menu')
- Set key binding: exports['district_zero']:SetKeyBinding('menu', 'F5')
- Get all bindings: exports['district_zero']:GetAllKeyBindings()
]] 

-- client/input.lua
-- District Zero Input Management

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Key bindings configuration
local keyBindings = {
    menu = {
        key = 'F5',
        description = 'Open District Zero Menu',
        command = 'dz:client:menu:toggle'
    },
    district = {
        key = 'F6',
        description = 'Toggle District View',
        command = 'dz:client:district:toggle'
    },
    mission = {
        key = 'F7',
        description = 'Toggle Mission View',
        command = 'dz:client:mission:toggle'
    }
}

-- Register key bindings
local function RegisterKeyBindings()
    for name, binding in pairs(keyBindings) do
        RegisterCommand(binding.command, function()
            if not State.isOpen then
                Events.TriggerEvent('dz:client:menu:open', 'client')
            end
        end)
        
        RegisterKeyMapping(binding.command, binding.description, 'keyboard', binding.key)
    end
end

-- Handle key press
local function HandleKeyPress(key)
    if not keyBindings[key] then return end
    
    local binding = keyBindings[key]
    ExecuteCommand(binding.command)
end

-- Register input handlers
RegisterCommand('dz:client:menu:toggle', function()
    if not State.isOpen then
        Events.TriggerEvent('dz:client:menu:open', 'client')
    else
        Events.TriggerEvent('dz:client:menu:close', 'client')
    end
end)

RegisterCommand('dz:client:district:toggle', function()
    Events.TriggerEvent('dz:client:district:toggle', 'client')
end)

RegisterCommand('dz:client:mission:toggle', function()
    Events.TriggerEvent('dz:client:mission:toggle', 'client')
end)

-- Register cleanup handler
RegisterCleanup('input', function()
    -- Unregister key bindings
    for _, binding in pairs(keyBindings) do
        RegisterCommand(binding.command, function() end)
    end
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    RegisterKeyBindings()
end)

-- Exports
exports('GetKeyBindings', function()
    return keyBindings
end)

exports('RegisterKeyBinding', function(name, binding)
    if keyBindings[name] then
        return false, 'Key binding already exists'
    end
    
    keyBindings[name] = binding
    RegisterKeyBindings()
    return true
end)

exports('UnregisterKeyBinding', function(name)
    if not keyBindings[name] then
        return false, 'Key binding does not exist'
    end
    
    local binding = keyBindings[name]
    RegisterCommand(binding.command, function() end)
    keyBindings[name] = nil
    return true
end) 