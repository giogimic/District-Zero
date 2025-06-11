-- District Zero Event Handler
local Utils = require 'shared/utils'

-- Event Registry
local Events = {
    -- Client Events
    client = {
        -- Menu Events
        'dz:menu:toggle',
        'dz:menu:close',
        'dz:menu:update',
        
        -- District Events
        'dz:district:requestUpdate',
        'dz:district:update',
        'dz:district:capture',
        'dz:district:defend',
        
        -- Faction Events
        'dz:faction:requestUpdate',
        'dz:faction:update',
        'dz:faction:join',
        'dz:faction:leave',
        
        -- Mission Events
        'dz:mission:start',
        'dz:mission:complete',
        'dz:mission:fail',
        
        -- State Events
        'dz:state:update',
        'dz:state:request'
    },
    
    -- Server Events
    server = {
        -- Menu Events
        'dz:menu:request',
        'dz:menu:response',
        
        -- District Events
        'dz:district:request',
        'dz:district:response',
        'dz:district:capture',
        'dz:district:defend',
        
        -- Faction Events
        'dz:faction:request',
        'dz:faction:response',
        'dz:faction:join',
        'dz:faction:leave',
        
        -- Mission Events
        'dz:mission:start',
        'dz:mission:complete',
        'dz:mission:fail',
        
        -- State Events
        'dz:state:update',
        'dz:state:request'
    }
}

-- Event Validation
local function ValidateEvent(eventName, eventType)
    if not eventName or not eventType then return false end
    if not Events[eventType] then return false end
    
    for _, event in ipairs(Events[eventType]) do
        if event == eventName then
            return true
        end
    end
    
    return false
end

-- Event Registration
local function RegisterEvent(eventName, eventType, handler)
    if not ValidateEvent(eventName, eventType) then
        print('[District Zero] Error: Invalid event: ' .. eventName)
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

-- Event Triggering
local function TriggerEvent(eventName, eventType, ...)
    if not ValidateEvent(eventName, eventType) then
        print('[District Zero] Error: Invalid event: ' .. eventName)
        return false
    end
    
    if eventType == 'client' then
        TriggerServerEvent(eventName, ...)
    else
        TriggerClientEvent(eventName, ...)
    end
    
    return true
end

-- Exports
exports('RegisterEvent', RegisterEvent)
exports('TriggerEvent', TriggerEvent)
exports('ValidateEvent', ValidateEvent)

-- Event Documentation
--[[
Event Documentation:

Client Events:
- dz:menu:toggle: Toggle the main menu
- dz:menu:close: Close the main menu
- dz:menu:update: Update menu state
- dz:district:requestUpdate: Request district data update
- dz:district:update: Receive district data update
- dz:district:capture: Attempt to capture a district
- dz:district:defend: Defend a district
- dz:faction:requestUpdate: Request faction data update
- dz:faction:update: Receive faction data update
- dz:faction:join: Join a faction
- dz:faction:leave: Leave a faction
- dz:mission:start: Start a mission
- dz:mission:complete: Complete a mission
- dz:mission:fail: Fail a mission
- dz:state:update: Update state
- dz:state:request: Request state update

Server Events:
- dz:menu:request: Request menu data
- dz:menu:response: Send menu data
- dz:district:request: Request district data
- dz:district:response: Send district data
- dz:district:capture: Capture a district
- dz:district:defend: Defend a district
- dz:faction:request: Request faction data
- dz:faction:response: Send faction data
- dz:faction:join: Join a faction
- dz:faction:leave: Leave a faction
- dz:mission:start: Start a mission
- dz:mission:complete: Complete a mission
- dz:mission:fail: Fail a mission
- dz:state:update: Update state
- dz:state:request: Request state update
]] 