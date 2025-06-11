-- client/main/init.lua
-- District Zero Client Initialization

local QBX = exports.qbx_core:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Client State
local State = {
    isInitialized = false,
    currentDistrict = nil,
    activeMissions = {},
    faction = nil,
    abilities = {}
}

-- Initialize client
local function Initialize()
    if State.isInitialized then return end
    
    -- Request initial data
    Events.TriggerEvent('dz:server:district:requestUpdate', 'client')
    Events.TriggerEvent('dz:server:mission:requestUpdate', 'client')
    Events.TriggerEvent('dz:server:faction:requestUpdate', 'client')
    
    -- Register key bindings
    RegisterKeyMapping('dz:client:menu:toggle', 'Open District Zero Menu', 'keyboard', 'F5')
    RegisterKeyMapping('dz:client:district:toggle', 'Toggle District View', 'keyboard', 'F6')
    RegisterKeyMapping('dz:client:mission:toggle', 'Toggle Mission View', 'keyboard', 'F7')
    
    -- Register commands
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
    
    State.isInitialized = true
end

-- Event Handlers
Events.RegisterEvent('dz:client:district:update', function(source, districts)
    State.districts = districts
    
    -- Update UI if open
    if State.isOpen then
        Events.TriggerEvent('dz:client:ui:update', 'client', {
            districts = districts
        })
    end
end)

Events.RegisterEvent('dz:client:mission:update', function(source, missions)
    State.activeMissions = missions
    
    -- Update UI if open
    if State.isOpen then
        Events.TriggerEvent('dz:client:ui:update', 'client', {
            missions = missions
        })
    end
end)

Events.RegisterEvent('dz:client:faction:update', function(source, faction)
    State.faction = faction
    
    -- Update UI if open
    if State.isOpen then
        Events.TriggerEvent('dz:client:ui:update', 'client', {
            faction = faction
        })
    end
end)

-- QBX Core Event Handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Initialize()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    State.isInitialized = false
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Initialize()
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        isInitialized = false,
        currentDistrict = nil,
        activeMissions = {},
        faction = nil,
        abilities = {}
    }
end)

-- Exports
exports('GetState', function()
    return State
end)

exports('GetCurrentDistrict', function()
    return State.currentDistrict
end)

exports('GetActiveMissions', function()
    return State.activeMissions
end)

exports('GetFaction', function()
    return State.faction
end) 