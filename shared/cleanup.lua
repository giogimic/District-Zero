-- shared/cleanup.lua
-- Resource cleanup handler for District Zero

local Utils = require 'shared/utils'

-- Cleanup Registry
local CleanupRegistry = {
    state = {},
    events = {},
    nui = {},
    database = {}
}

-- Register cleanup handlers
local function RegisterCleanup(type, handler)
    if not CleanupRegistry[type] then
        Utils.HandleError('Invalid cleanup type: ' .. type, 'RegisterCleanup')
        return false
    end
    
    table.insert(CleanupRegistry[type], handler)
    return true
end

-- State cleanup
local function CleanupState()
    for _, handler in ipairs(CleanupRegistry.state) do
        local success, result = pcall(handler)
        if not success then
            Utils.HandleError('State cleanup failed: ' .. tostring(result), 'CleanupState')
        end
    end
end

-- Event cleanup
local function CleanupEvents()
    for _, handler in ipairs(CleanupRegistry.events) do
        local success, result = pcall(handler)
        if not success then
            Utils.HandleError('Event cleanup failed: ' .. tostring(result), 'CleanupEvents')
        end
    end
end

-- NUI cleanup
local function CleanupNUI()
    for _, handler in ipairs(CleanupRegistry.nui) do
        local success, result = pcall(handler)
        if not success then
            Utils.HandleError('NUI cleanup failed: ' .. tostring(result), 'CleanupNUI')
        end
    end
end

-- Database cleanup
local function CleanupDatabase()
    for _, handler in ipairs(CleanupRegistry.database) do
        local success, result = pcall(handler)
        if not success then
            Utils.HandleError('Database cleanup failed: ' .. tostring(result), 'CleanupDatabase')
        end
    end
end

-- Main cleanup function
local function Cleanup()
    Utils.PrintDebug('Starting resource cleanup', 'cleanup')
    
    -- Cleanup in order
    CleanupState()
    CleanupEvents()
    CleanupNUI()
    CleanupDatabase()
    
    Utils.PrintDebug('Resource cleanup completed', 'cleanup')
end

-- Register resource stop handler
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Cleanup()
end)

-- Exports
exports('RegisterCleanup', RegisterCleanup)

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