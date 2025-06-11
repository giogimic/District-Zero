local activeEffects = {}

-- Handle backup requests
RegisterNetEvent('faction:backupRequest')
AddEventHandler('faction:backupRequest', function(source, coords)
    local player = source
    local playerName = GetPlayerName(player)
    
    -- Show notification
    ShowNotification('Backup requested by ' .. playerName)
    
    -- Add blip
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 1)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Backup Request: " .. playerName)
    EndTextCommandSetBlipName(blip)
    
    -- Remove blip after 30 seconds
    Citizen.SetTimeout(30000, function()
        RemoveBlip(blip)
    end)
end)

-- Handle tracking disable
RegisterNetEvent('faction:trackingDisabled')
AddEventHandler('faction:trackingDisabled', function()
    activeEffects.tracking = true
    ShowNotification('Police tracking disabled for 2 minutes')
end)

RegisterNetEvent('faction:trackingEnabled')
AddEventHandler('faction:trackingEnabled', function()
    activeEffects.tracking = false
    ShowNotification('Police tracking enabled')
end)

-- Handle signal jamming
RegisterNetEvent('faction:signalJammed')
AddEventHandler('faction:signalJammed', function()
    activeEffects.jammed = true
    ShowNotification('Radio signals jammed')
    
    -- Disable police radio
    -- Implement based on your radio system
end)

RegisterNetEvent('faction:signalRestored')
AddEventHandler('faction:signalRestored', function()
    activeEffects.jammed = false
    ShowNotification('Radio signals restored')
    
    -- Enable police radio
    -- Implement based on your radio system
end)

-- Check if player is affected by any effects
function IsAffectedByEffect(effectType)
    return activeEffects[effectType] == true
end

-- Show notification
function ShowNotification(message)
    -- Implement based on your notification system
    -- Example using native notification:
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

-- Export functions
exports('IsAffectedByEffect', IsAffectedByEffect) 