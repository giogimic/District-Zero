-- District Zero Event Handler

local Events = {}

-- Event Registry
Events.client = {
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
local function IsEventRateLimited(eventName, source)
    local key = eventName .. ':' .. source
    local lastTrigger = eventCooldowns[key]
    local now = GetGameTimer()
    
    if lastTrigger and (now - lastTrigger) < 1000 then -- 1 second cooldown
        return true
    end
    
    eventCooldowns[key] = now
    return false
end

-- Event validation
local function ValidateEvent(eventName, source, ...)
    if IsEventRateLimited(eventName, source) then
        return false, 'Event rate limited'
    end
    
    -- Validate event name format
    if not eventName:match('^dz:[a-z]+:[a-z]+$') then
        return false, 'Invalid event name format'
    end
    
    -- Validate source
    if not source or type(source) ~= 'number' then
        return false, 'Invalid source'
    end
    
    return true
end

-- Event Registration
local function RegisterEvent(eventName, eventType, handler)
    if not ValidateEvent(eventName, eventType) then
        Utils.HandleError('Invalid event: ' .. eventName, 'RegisterEvent')
        return false
    end
    
    if eventType == 'client' then
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, handler)
    else
        RegisterNetEvent(eventName)
        AddEventHandler(eventName, handler)
    end
    
    return true
end

-- Event Triggering with Rate Limiting
local eventCooldowns = {}
local COOLDOWN_TIME = 1000 -- 1 second cooldown

local function TriggerEvent(eventName, eventType, ...)
    if not ValidateEvent(eventName, eventType) then
        Utils.HandleError('Invalid event: ' .. eventName, 'TriggerEvent')
        return false
    end
    
    -- Rate limiting
    if eventCooldowns[eventName] and GetGameTimer() - eventCooldowns[eventName] < COOLDOWN_TIME then
        return false
    end
    eventCooldowns[eventName] = GetGameTimer()
    
    local args = {...}
    if eventType == 'client' then
        TriggerClientEvent(eventName, ...)
    else
        TriggerServerEvent(eventName, ...)
    end
    
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
        timestamp = os.time()
    }
    
    Utils.PrintDebug(string.format('Event: %s, Type: %s, Source: %s', 
        eventName, eventType, source), 'event')
end

-- Exports
exports('RegisterEvent', RegisterEvent)
exports('TriggerEvent', TriggerEvent)
exports('ValidateEvent', ValidateEvent)
exports('LogEvent', LogEvent)

-- Event Documentation
--[[
Event System Documentation:

1. Event Types:
   - client: Client-side events
   - server: Server-side events
   - shared: Shared events

2. Event Registration:
   RegisterEvent(eventName, eventType, handler)
   - eventName: Name of the event
   - eventType: Type of event (client/server/shared)
   - handler: Function to handle the event

3. Event Triggering:
   TriggerEvent(eventName, eventType, ...)
   - eventName: Name of the event
   - eventType: Type of event (client/server/shared)
   - ...: Arguments to pass to the event

4. Event Validation:
   ValidateEvent(eventName, eventType)
   - eventName: Name of the event
   - eventType: Type of event (client/server/shared)

5. Event Logging:
   LogEvent(eventName, eventType, source, data)
   - eventName: Name of the event
   - eventType: Type of event (client/server/shared)
   - source: Source of the event
   - data: Data associated with the event
]]

return Events 