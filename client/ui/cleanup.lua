-- client/ui/cleanup.lua
-- District Zero UI Cleanup

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- UI cleanup
local function CleanupUI()
    -- Hide UI
    if State.isOpen then
        Events.TriggerEvent('dz:client:menu:close', 'client')
    end
    
    -- Clear NUI messages
    SendNUIMessage({
        action = 'cleanup'
    })
    
    -- Reset focus
    SetNuiFocus(false, false)
    
    -- Clear notifications
    State.notifications = {}
end

-- NUI cleanup
local function CleanupNUI()
    -- Clear all NUI messages
    SendNUIMessage({
        action = 'cleanup'
    })
    
    -- Reset focus
    SetNuiFocus(false, false)
    
    -- Clear notifications
    State.notifications = {}
end

-- Register cleanup handlers
RegisterCleanup('ui', function()
    CleanupUI()
end)

RegisterCleanup('nui', function()
    CleanupNUI()
end)

-- Register resource stop handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Cleanup UI
    CleanupUI()
    
    -- Cleanup NUI
    CleanupNUI()
end)

-- Exports
exports('CleanupUI', CleanupUI)
exports('CleanupNUI', CleanupNUI) 