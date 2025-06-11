-- District Zero District Events Handler
local QBCore = exports['qb-core']:GetCoreObject()
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
        QBCore.Functions.Notify(source, 'District ID is required', 'error')
        return false
    end
    
    if not eventType then
        QBCore.Functions.Notify(source, 'Event type is required', 'error')
        return false
    end
    
    -- Check if event is already active
    MySQL.query('SELECT * FROM dz_events WHERE district_id = ? AND status = ?', {districtId, 'active'}, function(result)
        if result and #result > 0 then
            QBCore.Functions.Notify(source, 'An event is already active in this district', 'error')
            return false
        end
        
        -- Get event data
        local event = eventTypes[eventType]
        if not event then
            QBCore.Functions.Notify(source, 'Invalid event type', 'error')
            return false
        end
        
        -- Create event
        MySQL.insert('INSERT INTO dz_events (district_id, type, start_time, end_time, status) VALUES (?, ?, ?, ?, ?)',
            {districtId, eventType, os.time(), os.time() + event.duration, 'active'},
            function(id)
                if id then
                    -- Notify all clients
                    TriggerClientEvent('district-zero:client:updateEvents', -1)
                    QBCore.Functions.Notify(source, 'Event started successfully', 'success')
                    return true
                else
                    QBCore.Functions.Notify(source, 'Failed to start event', 'error')
                    return false
                end
            end
        )
    end)
end

local function EndEvent(districtId, success)
    -- Validate inputs
    if not districtId then
        QBCore.Functions.Notify(source, 'District ID is required', 'error')
        return false
    end
    
    -- Get active event
    MySQL.query('SELECT * FROM dz_events WHERE district_id = ? AND status = ?', {districtId, 'active'}, function(result)
        if not result or #result == 0 then
            QBCore.Functions.Notify(source, 'No active event found', 'error')
            return false
        end
        
        local event = result[1]
        
        -- Update event status
        MySQL.update('UPDATE dz_events SET status = ?, end_time = ? WHERE id = ?',
            {success and 'completed' or 'failed', os.time(), event.id},
            function(affectedRows)
                if affectedRows > 0 then
                    -- Distribute rewards if successful
                    if success then
                        MySQL.query('SELECT * FROM dz_event_participants WHERE event_id = ?', {event.id}, function(participants)
                            for _, participant in ipairs(participants) do
                                local player = QBCore.Functions.GetPlayer(participant.player_id)
                                if player then
                                    -- Give money
                                    player.Functions.AddMoney('cash', eventTypes[event.type].rewards.money)
                                    
                                    -- Give items
                                    for _, item in pairs(eventTypes[event.type].rewards.items) do
                                        player.Functions.AddItem(item.name, item.amount)
                                    end
                                    
                                    -- Update influence
                                    MySQL.update('UPDATE dz_district_control SET influence = influence + ? WHERE district_id = ? AND faction_id = ?',
                                        {eventTypes[event.type].rewards.influence, districtId, player.PlayerData.metadata.faction}
                                    )
                                end
                            end
                        end)
                    end
                    
                    -- Notify all clients
                    TriggerClientEvent('district-zero:client:updateEvents', -1)
                    QBCore.Functions.Notify(source, 'Event ended successfully', 'success')
                    return true
                else
                    QBCore.Functions.Notify(source, 'Failed to end event', 'error')
                    return false
                end
            end
        )
    end)
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
RegisterNetEvent('district-zero:server:createEvent')
AddEventHandler('district-zero:server:createEvent', function(data)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to create events', 'error')
        return
    end
    
    MySQL.insert('INSERT INTO dz_events (district_id, type, start_time, end_time, status) VALUES (?, ?, ?, ?, ?)',
        {data.district_id, data.type, data.start_time, data.end_time, 'scheduled'},
        function(id)
            if id then
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateEvents', -1)
                QBCore.Functions.Notify(source, 'Event created successfully', 'success')
            else
                QBCore.Functions.Notify(source, 'Failed to create event', 'error')
            end
        end
    )
end)

RegisterNetEvent('district-zero:server:updateEvent')
AddEventHandler('district-zero:server:updateEvent', function(data)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to update events', 'error')
        return
    end
    
    MySQL.update('UPDATE dz_events SET district_id = ?, type = ?, start_time = ?, end_time = ?, status = ? WHERE id = ?',
        {data.district_id, data.type, data.start_time, data.end_time, data.status, data.id},
        function(affectedRows)
            if affectedRows > 0 then
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateEvents', -1)
                QBCore.Functions.Notify(source, 'Event updated successfully', 'success')
            else
                QBCore.Functions.Notify(source, 'Failed to update event', 'error')
            end
        end
    )
end)

RegisterNetEvent('district-zero:server:deleteEvent')
AddEventHandler('district-zero:server:deleteEvent', function(eventId)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to delete events', 'error')
        return
    end
    
    MySQL.query('DELETE FROM dz_events WHERE id = ?', {eventId}, function(affectedRows)
        if affectedRows > 0 then
            -- Notify all clients
            TriggerClientEvent('district-zero:client:updateEvents', -1)
            QBCore.Functions.Notify(source, 'Event deleted successfully', 'success')
        else
            QBCore.Functions.Notify(source, 'Failed to delete event', 'error')
        end
    end)
end)

RegisterNetEvent('district-zero:server:startEvent')
AddEventHandler('district-zero:server:startEvent', function(eventId)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    -- Check if player has permission
    if not player.PlayerData.metadata.admin then
        QBCore.Functions.Notify(source, 'You do not have permission to start events', 'error')
        return
    end
    
    MySQL.query('SELECT * FROM dz_events WHERE id = ?', {eventId}, function(result)
        if result and #result > 0 then
            local event = result[1]
            StartEvent(event.district_id, event.type)
        else
            QBCore.Functions.Notify(source, 'Event not found', 'error')
        end
    end)
end)

RegisterNetEvent('district-zero:server:joinEvent')
AddEventHandler('district-zero:server:joinEvent', function(eventId)
    local source = source
    local player = QBCore.Functions.GetPlayer(source)
    
    if not player then return end
    
    -- Check if player is in a faction
    if not player.PlayerData.metadata.faction then
        QBCore.Functions.Notify(source, 'You must be in a faction to join events', 'error')
        return
    end
    
    -- Add player to event
    MySQL.insert('INSERT INTO dz_event_participants (event_id, player_id, faction_id) VALUES (?, ?, ?)',
        {eventId, source, player.PlayerData.metadata.faction},
        function(id)
            if id then
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateEvents', -1)
                QBCore.Functions.Notify(source, 'Joined event successfully', 'success')
            else
                QBCore.Functions.Notify(source, 'Failed to join event', 'error')
            end
        end
    )
end)

RegisterNetEvent('district-zero:server:leaveEvent')
AddEventHandler('district-zero:server:leaveEvent', function(eventId)
    local source = source
    
    -- Remove player from event
    MySQL.query('DELETE FROM dz_event_participants WHERE event_id = ? AND player_id = ?',
        {eventId, source},
        function(affectedRows)
            if affectedRows > 0 then
                -- Notify all clients
                TriggerClientEvent('district-zero:client:updateEvents', -1)
                QBCore.Functions.Notify(source, 'Left event successfully', 'success')
            else
                QBCore.Functions.Notify(source, 'Failed to leave event', 'error')
            end
        end
    )
end)

-- Callbacks
QBCore.Functions.CreateCallback('district-zero:server:getEvents', function(source, cb)
    MySQL.query('SELECT * FROM dz_events ORDER BY start_time DESC', {}, function(result)
        if result then
            -- Load participants for each event
            for _, event in ipairs(result) do
                MySQL.query('SELECT * FROM dz_event_participants WHERE event_id = ?', {event.id}, function(participants)
                    event.participants = participants
                end)
            end
            cb(result)
        else
            cb({})
        end
    end)
end)

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

-- Get all events
QBCore.Functions.CreateCallback('district-zero:server:getEvents', function(source, cb)
    MySQL.query('SELECT * FROM dz_events ORDER BY start_time DESC', {}, function(result)
        if result then
            cb(result)
        else
            cb({})
        end
    end)
end)

-- Create new event
RegisterNetEvent('district-zero:server:createEvent')
AddEventHandler('district-zero:server:createEvent', function(data)
    local src = source
    local Player = QBX.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has permission
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to create events', 'error')
        return
    end
    
    MySQL.insert('INSERT INTO dz_events (name, description, district_id, start_time, end_time, status) VALUES (?, ?, ?, ?, ?, ?)', {
        data.name,
        data.description,
        data.districtId,
        data.startTime,
        data.endTime,
        'scheduled'
    }, function(id)
        if id then
            -- Notify all clients
            TriggerClientEvent('district-zero:client:updateEvents', -1)
            TriggerClientEvent('QBCore:Notify', src, 'Event created successfully', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to create event', 'error')
        end
    end)
end)

-- Update event
RegisterNetEvent('district-zero:server:updateEvent')
AddEventHandler('district-zero:server:updateEvent', function(data)
    local src = source
    local Player = QBX.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has permission
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to update events', 'error')
        return
    end
    
    MySQL.update('UPDATE dz_events SET name = ?, description = ?, district_id = ?, start_time = ?, end_time = ? WHERE id = ?', {
        data.name,
        data.description,
        data.districtId,
        data.startTime,
        data.endTime,
        data.id
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Notify all clients
            TriggerClientEvent('district-zero:client:updateEvents', -1)
            TriggerClientEvent('QBCore:Notify', src, 'Event updated successfully', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to update event', 'error')
        end
    end)
end)

-- Delete event
RegisterNetEvent('district-zero:server:deleteEvent')
AddEventHandler('district-zero:server:deleteEvent', function(eventId)
    local src = source
    local Player = QBX.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has permission
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to delete events', 'error')
        return
    end
    
    MySQL.query('DELETE FROM dz_events WHERE id = ?', {eventId}, function(affectedRows)
        if affectedRows > 0 then
            -- Notify all clients
            TriggerClientEvent('district-zero:client:updateEvents', -1)
            TriggerClientEvent('QBCore:Notify', src, 'Event deleted successfully', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Failed to delete event', 'error')
        end
    end)
end)

-- Start event
RegisterNetEvent('district-zero:server:startEvent')
AddEventHandler('district-zero:server:startEvent', function(eventId)
    local src = source
    local Player = QBX.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Check if player has permission
    if not Player.PlayerData.permission == 'admin' then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to start events', 'error')
        return
    end
    
    -- Get event details
    MySQL.query('SELECT * FROM dz_events WHERE id = ?', {eventId}, function(result)
        if result and #result > 0 then
            local event = result[1]
            
            -- Check if event is already active
            if event.status == 'active' then
                TriggerClientEvent('QBCore:Notify', src, 'Event is already active', 'error')
                return
            end
            
            -- Update event status
            MySQL.update('UPDATE dz_events SET status = ? WHERE id = ?', {
                'active',
                eventId
            }, function(affectedRows)
                if affectedRows > 0 then
                    -- Notify all clients
                    TriggerClientEvent('district-zero:client:updateEvents', -1)
                    TriggerClientEvent('QBCore:Notify', src, 'Event started successfully', 'success')
                    
                    -- Start event logic
                    StartEventLogic(event)
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Failed to start event', 'error')
                end
            end)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Event not found', 'error')
        end
    end)
end)

-- Event logic
function StartEventLogic(event)
    -- Get all players in the district
    local players = QBX.Functions.GetPlayers()
    local districtPlayers = {}
    
    for _, playerId in ipairs(players) do
        local Player = QBX.Functions.GetPlayer(playerId)
        if Player then
            -- Check if player is in the event district
            local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
            if IsPointInDistrict(playerCoords, event.district_id) then
                table.insert(districtPlayers, playerId)
            end
        end
    end
    
    -- Notify players in district
    for _, playerId in ipairs(districtPlayers) do
        TriggerClientEvent('QBCore:Notify', playerId, 'A district event has started!', 'success')
        -- Add event-specific notifications/effects here
    end
    
    -- Schedule event end
    SetTimeout(GetEventDuration(event), function()
        EndEvent(event)
    end)
end

-- End event
function EndEvent(event)
    -- Update event status
    MySQL.update('UPDATE dz_events SET status = ? WHERE id = ?', {
        'completed',
        event.id
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Notify all clients
            TriggerClientEvent('district-zero:client:updateEvents', -1)
            
            -- Get all players in the district
            local players = QBX.Functions.GetPlayers()
            local districtPlayers = {}
            
            for _, playerId in ipairs(players) do
                local Player = QBX.Functions.GetPlayer(playerId)
                if Player then
                    -- Check if player is in the event district
                    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
                    if IsPointInDistrict(playerCoords, event.district_id) then
                        table.insert(districtPlayers, playerId)
                    end
                end
            end
            
            -- Notify players in district
            for _, playerId in ipairs(districtPlayers) do
                TriggerClientEvent('QBCore:Notify', playerId, 'The district event has ended!', 'success')
                -- Add event completion rewards here
            end
        end
    end)
end

-- Helper function to check if a point is in a district
function IsPointInDistrict(coords, districtId)
    -- Get district boundaries from database
    MySQL.query('SELECT * FROM dz_districts WHERE id = ?', {districtId}, function(result)
        if result and #result > 0 then
            local district = result[1]
            -- Check if coords are within district boundaries
            -- This is a simplified check - you'll need to implement proper boundary checking
            return true
        end
        return false
    end)
end

-- Helper function to get event duration
function GetEventDuration(event)
    local startTime = os.time(event.start_time)
    local endTime = os.time(event.end_time)
    return (endTime - startTime) * 1000 -- Convert to milliseconds
end 