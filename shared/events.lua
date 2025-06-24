-- District Zero Event Handler
-- Version: 1.0.0

local Events = {}

-- Simple logging function to avoid circular dependencies
local function LogDebug(message, context)
    local prefix = '[District Zero]'
    if context then
        prefix = prefix .. ' [' .. context .. ']'
    end
    print('^5' .. prefix .. ' ' .. tostring(message) .. '^7')
end

local function LogError(message, context)
    local prefix = '[District Zero]'
    if context then
        prefix = prefix .. ' [' .. context .. ']'
    end
    print('^1' .. prefix .. ' ' .. tostring(message) .. '^7')
end

-- Event Registry
Events.client = {
    -- UI Events
    'dz:client:updateUI',
    'dz:client:missionStarted',
    'dz:client:missionCompleted',
    'dz:client:missionUpdated',
    'dz:client:teamSelected',
    
    -- Menu Events
    'dz:client:menu:toggle',
    'dz:client:menu:close',
    'dz:client:menu:update',
    
    -- District Events
    'dz:client:district:requestUpdate',
    'dz:client:district:update',
    'dz:client:district:capture',
    'dz:client:district:defend',
    
    -- Mission Events
    'dz:client:mission:start',
    'dz:client:mission:complete',
    'dz:client:mission:fail'
}

Events.server = {
    -- UI Events
    'dz:server:getUIData',
    'dz:server:selectTeam',
    'dz:server:acceptMission',
    'dz:server:capturePoint',
    
    -- Menu Events
    'dz:server:menu:request',
    'dz:server:menu:response',
    
    -- District Events
    'dz:server:district:request',
    'dz:server:district:response',
    'dz:server:district:capture',
    'dz:server:district:defend',
    
    -- Mission Events
    'dz:server:mission:start',
    'dz:server:mission:complete',
    'dz:server:mission:fail'
}

Events.shared = {
    -- State Events
    'dz:shared:state:update',
    'dz:shared:state:request'
}

-- Event rate limiting
local eventCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second cooldown

local function IsEventRateLimited(eventName, source)
    local key = eventName .. ':' .. tostring(source)
    local lastTrigger = eventCooldowns[key]
    local now = GetGameTimer()
    
    if lastTrigger and (now - lastTrigger) < COOLDOWN_TIME then
        return true
    end
    
    eventCooldowns[key] = now
    return false
end

-- Event validation
local function ValidateEvent(eventName, source, ...)
    if not eventName or type(eventName) ~= 'string' then
        return false, 'Invalid event name'
    end
    
    -- Validate event name format (allow for more flexible naming)
    if not eventName:match('^dz:[a-z]+:[a-zA-Z]+') then
        return false, 'Invalid event name format'
    end
    
    -- Validate source (only for server events)
    if source and type(source) ~= 'number' then
        return false, 'Invalid source'
    end
    
    return true
end

-- Event Registration
local function RegisterEvent(eventName, eventType, handler)
    if not eventName or not eventType or not handler then
        LogError('Invalid parameters for RegisterEvent', 'events')
        return false
    end
    
    if eventType == 'client' then
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, handler)
    elseif eventType == 'server' then
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, handler)
    else
        LogError('Invalid event type: ' .. eventType, 'events')
        return false
    end
    
    LogDebug('Registered event: ' .. eventName .. ' (' .. eventType .. ')', 'events')
    return true
end

-- Event Triggering with Rate Limiting
local function TriggerEvent(eventName, eventType, target, ...)
    if not ValidateEvent(eventName, target) then
        LogError('Invalid event: ' .. eventName, 'events')
        return false
    end
    
    -- Rate limiting for server events
    if eventType == 'server' and target then
        if IsEventRateLimited(eventName, target) then
            LogDebug('Event rate limited: ' .. eventName .. ' from source: ' .. target, 'events')
            return false
        end
    end
    
    local args = {...}
    if eventType == 'client' then
        TriggerClientEvent(eventName, target, table.unpack(args))
    elseif eventType == 'server' then
        TriggerServerEvent(eventName, table.unpack(args))
    else
        LogError('Invalid event type for triggering: ' .. eventType, 'events')
        return false
    end
    
    -- Log event
    LogEvent(eventName, eventType, target, args)
    return true
end

-- Event Logging
local function LogEvent(eventName, eventType, source, data)
    if not Config or not Config.Debug then return end
    
    local logData = {
        event = eventName,
        type = eventType,
        source = source,
        data = data,
        timestamp = GetGameTimer()
    }
    
    LogDebug(string.format('Event: %s, Type: %s, Source: %s', 
        eventName, eventType, tostring(source)), 'events')
end

-- Register all events
local function RegisterAllEvents()
    LogDebug('Registering all District Zero events...', 'events')
    
    -- Register client events
    for _, eventName in ipairs(Events.client) do
        RegisterEvent(eventName, 'client', function(...)
            LogDebug('Client event triggered: ' .. eventName, 'events')
        end)
    end
    
    -- Register server events
    for _, eventName in ipairs(Events.server) do
        RegisterEvent(eventName, 'server', function(...)
            LogDebug('Server event triggered: ' .. eventName, 'events')
        end)
    end
    
    LogDebug('All events registered successfully', 'events')
end

-- Initialize event system
local function InitializeEventSystem()
    RegisterAllEvents()
    LogDebug('Event system initialized', 'events')
end

-- Exports
exports('RegisterEvent', RegisterEvent)
exports('TriggerEvent', TriggerEvent)
exports('ValidateEvent', ValidateEvent)
exports('LogEvent', LogEvent)
exports('InitializeEventSystem', InitializeEventSystem)

-- Initialize on resource start
CreateThread(function()
    InitializeEventSystem()
end)

-- Event Documentation
--[[
Event System Documentation:

1. Event Types:
   - client: Client-side events (triggered from server to client)
   - server: Server-side events (triggered from client to server)
   - shared: Shared events (can be triggered from either side)

2. Event Registration:
   RegisterEvent(eventName, eventType, handler)
   - eventName: Name of the event (must start with 'dz:')
   - eventType: Type of event ('client' or 'server')
   - handler: Function to handle the event

3. Event Triggering:
   TriggerEvent(eventName, eventType, target, ...)
   - eventName: Name of the event
   - eventType: Type of event ('client' or 'server')
   - target: Player ID (for client events) or nil (for server events)
   - ...: Arguments to pass to the event

4. Event Validation:
   ValidateEvent(eventName, source, ...)
   - eventName: Name of the event
   - source: Source player ID (for validation)
   - ...: Additional arguments

5. Event Logging:
   LogEvent(eventName, eventType, source, data)
   - eventName: Name of the event
   - eventType: Type of event
   - source: Source of the event
   - data: Data associated with the event

6. Rate Limiting:
   - All server events have a 1-second cooldown per player
   - Rate limited events are logged and blocked
   - Client events are not rate limited

7. Current Events:
   Client Events:
   - dz:client:updateUI - Updates the UI with new data
   - dz:client:missionStarted - Notifies client of mission start
   - dz:client:missionCompleted - Notifies client of mission completion
   - dz:client:missionUpdated - Updates mission progress
   - dz:client:teamSelected - Notifies client of team selection
   
   Server Events:
   - dz:server:getUIData - Requests UI data from server
   - dz:server:selectTeam - Player selects a team
   - dz:server:acceptMission - Player accepts a mission
   - dz:server:capturePoint - Player captures a control point
]]

return Events 