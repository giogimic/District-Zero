-- District Events Handler
local QBX = exports['qbx_core']:GetCore()
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
    -- Validate inputs
    if not districtId then
        Utils.HandleError('District ID is required', 'StartEvent')
        return false
    end
    
    if not eventType then
        Utils.HandleError('Event type is required', 'StartEvent')
        return false
    end
    
    -- Check district exists
    if not Config.Districts[districtId] then
        Utils.HandleError('District does not exist: ' .. tostring(districtId), 'StartEvent')
        return false
    end
    
    -- Check event type exists
    if not eventTypes[eventType] then
        Utils.HandleError('Invalid event type: ' .. tostring(eventType), 'StartEvent')
        return false
    end
    
    -- Check if event is already active
    if activeEvents[districtId] then
        Utils.HandleError('Event already active for district: ' .. tostring(districtId), 'StartEvent')
        return false
    end
    
    -- Check cooldown
    if eventCooldowns[districtId] and eventCooldowns[districtId] > os.time() then
        Utils.HandleError('Event on cooldown for district: ' .. tostring(districtId), 'StartEvent')
        return false
    end
    
    -- Get event data
    local event = eventTypes[eventType]
    
    -- Create event
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
    
    Utils.PrintDebug('Event started: ' .. eventType .. ' in district ' .. districtId, 'info')
    return true
end

local function EndEvent(districtId, success)
    -- Validate inputs
    if not districtId then
        Utils.HandleError('District ID is required', 'EndEvent')
        return false
    end
    
    -- Check if event exists
    if not activeEvents[districtId] then
        Utils.HandleError('No active event for district: ' .. tostring(districtId), 'EndEvent')
        return false
    end
    
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
    
    Utils.PrintDebug('Event ended: ' .. event.type .. ' in district ' .. districtId, 'info')
    return true
end

local function UpdateEventProgress(districtId, progress)
    -- Validate inputs
    if not districtId then
        Utils.HandleError('District ID is required', 'UpdateEventProgress')
        return false
    end
    
    if not progress then
        Utils.HandleError('Progress is required', 'UpdateEventProgress')
        return false
    end
    
    -- Check if event exists
    if not activeEvents[districtId] then
        Utils.HandleError('No active event for district: ' .. tostring(districtId), 'UpdateEventProgress')
        return false
    end
    
    -- Update progress
    activeEvents[districtId].progress = progress
    
    -- Check if event is complete
    if progress >= 100 then
        EndEvent(districtId, true)
    end
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:progress', -1, districtId, progress)
    
    Utils.PrintDebug('Event progress updated: ' .. progress .. '% in district ' .. districtId, 'info')
    return true
end

-- Event Handlers
RegisterNetEvent('dz:district:event:join')
AddEventHandler('dz:district:event:join', function(districtId)
    local source = source
    
    -- Validate inputs
    if not districtId then
        Utils.HandleError('District ID is required', 'EventJoin')
        return
    end
    
    -- Check if event exists
    if not activeEvents[districtId] then
        Utils.HandleError('No active event for district: ' .. tostring(districtId), 'EventJoin')
        return
    end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then
        Utils.HandleError('Player not found: ' .. tostring(source), 'EventJoin')
        return
    end
    
    -- Add player to participants
    activeEvents[districtId].participants[source] = true
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:update', -1, districtId, activeEvents[districtId])
    
    Utils.PrintDebug('Player joined event: ' .. player.PlayerData.citizenid, 'info')
end)

RegisterNetEvent('dz:district:event:leave')
AddEventHandler('dz:district:event:leave', function(districtId)
    local source = source
    
    -- Validate inputs
    if not districtId then
        Utils.HandleError('District ID is required', 'EventLeave')
        return
    end
    
    -- Check if event exists
    if not activeEvents[districtId] then
        Utils.HandleError('No active event for district: ' .. tostring(districtId), 'EventLeave')
        return
    end
    
    local player = QBX.Functions.GetPlayer(source)
    if not player then
        Utils.HandleError('Player not found: ' .. tostring(source), 'EventLeave')
        return
    end
    
    -- Remove player from participants
    activeEvents[districtId].participants[source] = nil
    
    -- Notify all players
    Utils.TriggerClientEvent('district:event:update', -1, districtId, activeEvents[districtId])
    
    Utils.PrintDebug('Player left event: ' .. player.PlayerData.citizenid, 'info')
end)

RegisterNetEvent('dz:district:event:progress:update')
AddEventHandler('dz:district:event:progress:update', function(districtId, progress)
    local source = source
    
    -- Validate inputs
    if not districtId then
        Utils.HandleError('District ID is required', 'EventProgressUpdate')
        return
    end
    
    if not progress then
        Utils.HandleError('Progress is required', 'EventProgressUpdate')
        return
    end
    
    -- Check if event exists
    if not activeEvents[districtId] then
        Utils.HandleError('No active event for district: ' .. tostring(districtId), 'EventProgressUpdate')
        return
    end
    
    -- Check if player is participant
    if not activeEvents[districtId].participants[source] then
        Utils.HandleError('Player is not a participant: ' .. tostring(source), 'EventProgressUpdate')
        return
    end
    
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