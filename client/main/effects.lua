-- client/main/effects.lua
-- District Zero Effects Handler

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Effects State
local State = {
    activeEffects = {},
    backupBlips = {}
}

-- Handle backup requests
Events.RegisterEvent('dz:client:faction:backupRequest', function(source, coords)
    local player = source
    local playerName = GetPlayerName(player)
    
    -- Show notification
    Utils.SendNotification('Backup requested by ' .. playerName)
    
    -- Add blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Backup Request: " .. playerName)
    EndTextCommandSetBlipName(blip)
    
    -- Store blip for cleanup
    State.backupBlips[blip] = true
    
    -- Remove blip after 30 seconds
    SetTimeout(30000, function()
        if State.backupBlips[blip] then
            RemoveBlip(blip)
            State.backupBlips[blip] = nil
        end
    end)
end)

-- Handle tracking disable
Events.RegisterEvent('dz:client:faction:trackingDisabled', function()
    State.activeEffects.tracking = true
    Utils.SendNotification('Police tracking disabled for 2 minutes')
end)

Events.RegisterEvent('dz:client:faction:trackingEnabled', function()
    State.activeEffects.tracking = false
    Utils.SendNotification('Police tracking enabled')
end)

-- Handle signal jamming
Events.RegisterEvent('dz:client:faction:signalJammed', function()
    State.activeEffects.jammed = true
    Utils.SendNotification('Radio signals jammed')
    
    -- Disable police radio
    Events.TriggerEvent('dz:client:radio:disable', 'client')
end)

Events.RegisterEvent('dz:client:faction:signalRestored', function()
    State.activeEffects.jammed = false
    Utils.SendNotification('Radio signals restored')
    
    -- Enable police radio
    Events.TriggerEvent('dz:client:radio:enable', 'client')
end)

-- Check if player is affected by any effects
function IsAffectedByEffect(effectType)
    return State.activeEffects[effectType] == true
end

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        activeEffects = {},
        backupBlips = {}
    }
end)

-- Register NUI cleanup handler
RegisterCleanup('nui', function()
    -- Remove all backup blips
    for blip, _ in pairs(State.backupBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    State.backupBlips = {}
end)

-- Exports
exports('IsAffectedByEffect', IsAffectedByEffect)

exports('GetActiveEffects', function()
    return State.activeEffects
end)

exports('SetActiveEffect', function(effectType, value)
    State.activeEffects[effectType] = value
    return true
end) 