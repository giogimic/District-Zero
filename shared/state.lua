-- shared/state.lua
-- District Zero State Management
-- Version: 1.0.0

local State = {
    -- Client state
    client = {
        isOpen = false,
        currentMenu = nil,
        currentData = nil,
        notifications = {}
    },
    
    -- Server state
    server = {
        districts = {},
        factions = {},
        missions = {},
        players = {}
    }
}

-- State validation
local function ValidateState(newState, stateType)
    if type(newState) ~= 'table' then
        return false, 'Invalid state format'
    end
    
    -- Validate client state
    if stateType == 'client' then
        if type(newState.isOpen) ~= 'boolean' then
            return false, 'Invalid isOpen value'
        end
        
        if newState.currentMenu and type(newState.currentMenu) ~= 'string' then
            return false, 'Invalid currentMenu value'
        end
        
        if newState.currentData and type(newState.currentData) ~= 'table' then
            return false, 'Invalid currentData value'
        end
        
        if newState.notifications and type(newState.notifications) ~= 'table' then
            return false, 'Invalid notifications value'
        end
    end
    
    -- Validate server state
    if stateType == 'server' then
        if newState.districts and type(newState.districts) ~= 'table' then
            return false, 'Invalid districts value'
        end
        
        if newState.factions and type(newState.factions) ~= 'table' then
            return false, 'Invalid factions value'
        end
        
        if newState.missions and type(newState.missions) ~= 'table' then
            return false, 'Invalid missions value'
        end
        
        if newState.players and type(newState.players) ~= 'table' then
            return false, 'Invalid players value'
        end
    end
    
    return true
end

-- Update state with validation
local function UpdateState(newState, stateType)
    local isValid, error = ValidateState(newState, stateType)
    if not isValid then
        return false, error
    end
    
    local success, error = pcall(function()
        State[stateType] = newState
    end)
    
    if not success then
        return false, error
    end
    
    return true
end

-- Get state
local function GetState(stateType)
    return State[stateType]
end

-- District Zero State Handler

-- State Registry
local StateRegistry = {}

-- Register cleanup handler
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Cleanup all states
        for _, state in pairs(StateRegistry) do
            if state.cleanup then
                state.cleanup()
            end
        end
    end
end)

-- Exports
exports('UpdateState', UpdateState)
exports('GetState', GetState)
exports('ValidateState', ValidateState) 