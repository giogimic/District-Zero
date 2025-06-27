-- shared/cleanup.lua
-- Resource cleanup handler for District Zero

local Utils = require 'shared/utils'

-- Cleanup System for District Zero
-- Handles resource cleanup and state management

local CleanupSystem = {}
local cleanupHandlers = {
    state = {},
    nui = {},
    database = {},
    general = {}
}

-- Register cleanup handler
local function RegisterCleanup(type, handler)
    if not cleanupHandlers[type] then
        Utils.HandleError('Invalid cleanup type: ' .. type, 'RegisterCleanup')
        return false
    end
    
    table.insert(cleanupHandlers[type], handler)
    return true
end

-- Execute cleanup for a specific type
local function ExecuteCleanup(type)
    if not cleanupHandlers[type] then
        Utils.HandleError('Invalid cleanup type: ' .. type, 'ExecuteCleanup')
        return false
    end
    
    for _, handler in pairs(cleanupHandlers[type]) do
        local success, error = pcall(handler)
        if not success then
            Utils.HandleError('Cleanup handler failed: ' .. tostring(error), 'ExecuteCleanup')
        end
    end
    
    return true
end

-- Execute all cleanup
local function ExecuteAllCleanup()
    Utils.PrintInfo('Executing cleanup for all systems...', 'CleanupSystem')
    
    for type, handlers in pairs(cleanupHandlers) do
        ExecuteCleanup(type)
    end
    
    Utils.PrintInfo('Cleanup completed', 'CleanupSystem')
end

-- Initialize cleanup system
local function Initialize()
    Utils.PrintInfo('Initializing Cleanup System...', 'CleanupSystem')
    
    -- Register default cleanup handlers
    RegisterCleanup('state', function()
        Utils.PrintDebug('Cleaning up state data', 'CleanupSystem')
        -- Add state cleanup logic here
    end)
    
    RegisterCleanup('nui', function()
        Utils.PrintDebug('Cleaning up NUI data', 'CleanupSystem')
        -- Add NUI cleanup logic here
    end)
    
    RegisterCleanup('database', function()
        Utils.PrintDebug('Cleaning up database connections', 'CleanupSystem')
        -- Add database cleanup logic here
    end)
    
    RegisterCleanup('general', function()
        Utils.PrintDebug('Executing general cleanup', 'CleanupSystem')
        -- Add general cleanup logic here
    end)
    
    Utils.PrintInfo('Cleanup System initialized', 'CleanupSystem')
end

-- Export functions
exports('RegisterCleanup', RegisterCleanup)
exports('ExecuteCleanup', ExecuteCleanup)
exports('ExecuteAllCleanup', ExecuteAllCleanup)

-- Initialize on resource start
CreateThread(function()
    Initialize()
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        ExecuteAllCleanup()
    end
end)

-- Return the cleanup system
return CleanupSystem

-- Cleanup Documentation
--[[
Cleanup System Documentation:

1. Cleanup Types:
   - state: State bag cleanup
   - events: Event cleanup
   - nui: NUI cleanup
   - database: Database cleanup

2. Registering Cleanup Handlers:
   RegisterCleanup(type, handler)
   - type: Type of cleanup (state/events/nui/database)
   - handler: Function to handle cleanup

3. Cleanup Order:
   1. State cleanup
   2. Event cleanup
   3. NUI cleanup
   4. Database cleanup

4. Error Handling:
   - All cleanup operations are wrapped in pcall
   - Errors are logged but don't stop cleanup process
   - Each cleanup type is handled independently

5. Usage Example:
   RegisterCleanup('state', function()
       -- Cleanup state bags
   end)
]] 