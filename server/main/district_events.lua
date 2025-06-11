-- District Events Handler
local QBX = exports['qbx_core']:GetSharedObject()
local Utils = require 'shared/utils'
local activeEvents = {}
local eventCooldowns = {}

-- Event Types
local eventTypes = {
    capture = {
        name = "District Capture",
        duration = 300, -- 5 minutes
        minPlayers = 2,
        rewards = {
            money = 1000,
            items = {},
            influence = 50
        }
    },
    defend = {
        name = "District Defense",
        duration = 600, -- 10 minutes
        minPlayers = 3,
        rewards = {
            money = 2000,
            items = {},
            influence = 75
        }
    },
    resource = {
        name = "Resource Gathering",
        duration = 900, -- 15 minutes
        minPlayers = 1,
        rewards = {
            money = 500,
            items = {},
            influence = 25
        }
    }
}

-- Event Management
local function StartEvent(districtId, eventType)
    if not Config.Districts[districtId] then return false end
    if activeEvents[districtId] then return false end
    if eventCooldowns[districtId] and eventCooldowns[districtId] > os.time() then return false end
    
    local event = eventTypes[eventType]
    if not event then return false end
    
    activeEvents[districtId] = {
        type = eventType,
        startTime = os.time(),
        endTime = os.time() + event.duration,
        participants = {},
        progress = 0,
        rewards = event.rewards
    }
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:start', -1, districtId, eventType, activeEvents[districtId])
    
    -- Set cooldown
    eventCooldowns[districtId] = os.time() + (event.duration * 2)
    
    return true
end

local function EndEvent(districtId, success)
    if not activeEvents[districtId] then return false end
    
    local event = activeEvents[districtId]
    local district = Config.Districts[districtId]
    
    -- Distribute rewards
    if success then
        for playerId, _ in pairs(event.participants) do
            local player = QBX.Functions.GetPlayer(playerId)
            if player then
                -- Give money
                player.Functions.AddMoney('cash', event.rewards.money)
                
                -- Give items
                for _, item in pairs(event.rewards.items) do
                    player.Functions.AddItem(item.name, item.amount)
                end
                
                -- Update influence
                if district then
                    district.influence = (district.influence or 0) + event.rewards.influence
                end
            end
        end
    end
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:end', -1, districtId, success)
    
    -- Clear event
    activeEvents[districtId] = nil
    
    return true
end

local function UpdateEventProgress(districtId, progress)
    if not activeEvents[districtId] then return false end
    
    activeEvents[districtId].progress = progress
    
    -- Check if event is complete
    if progress >= 100 then
        EndEvent(districtId, true)
    end
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:progress', -1, districtId, progress)
    
    return true
end

-- Event Handlers
RegisterNetEvent('dz:district:event:join')
AddEventHandler('dz:district:event:join', function(districtId)
    local source = source
    if not activeEvents[districtId] then return end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then return end
    
    -- Add player to participants
    activeEvents[districtId].participants[source] = true
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:update', -1, districtId, activeEvents[districtId])
end)

RegisterNetEvent('dz:district:event:leave')
AddEventHandler('dz:district:event:leave', function(districtId)
    local source = source
    if not activeEvents[districtId] then return end
    
    -- Remove player from participants
    activeEvents[districtId].participants[source] = nil
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:update', -1, districtId, activeEvents[districtId])
end)

RegisterNetEvent('dz:district:event:progress:update')
AddEventHandler('dz:district:event:progress:update', function(districtId, progress)
    local source = source
    if not activeEvents[districtId] then return end
    if not activeEvents[districtId].participants[source] then return end
    
    UpdateEventProgress(districtId, progress)
end)

-- Commands
QBX.Commands.Add('dz:event:start', 'Start a district event (Admin Only)', {
    {name = 'districtId', help = 'District ID'},
    {name = 'eventType', help = 'Event Type (capture/defend/resource)'}
}, true, function(source, args)
    local districtId = tonumber(args[1])
    local eventType = args[2]
    
    if StartEvent(districtId, eventType) then
        Utils.SendNotification(source, 'success', 'Event started successfully')
    else
        Utils.SendNotification(source, 'error', 'Failed to start event')
    end
end, 'admin')

QBX.Commands.Add('dz:event:end', 'End a district event (Admin Only)', {
    {name = 'districtId', help = 'District ID'},
    {name = 'success', help = 'Success (true/false)'}
}, true, function(source, args)
    local districtId = tonumber(args[1])
    local success = args[2] == 'true'
    
    if EndEvent(districtId, success) then
        Utils.SendNotification(source, 'success', 'Event ended successfully')
    else
        Utils.SendNotification(source, 'error', 'Failed to end event')
    end
end, 'admin')

-- Exports
exports('GetActiveEvents', function()
    return activeEvents
end)

exports('GetEventCooldowns', function()
    return eventCooldowns
end)

exports('StartEvent', function(districtId, eventType)
    return StartEvent(districtId, eventType)
end)

exports('EndEvent', function(districtId, success)
    return EndEvent(districtId, success)
end)

exports('UpdateEventProgress', function(districtId, progress)
    return UpdateEventProgress(districtId, progress)
end) 