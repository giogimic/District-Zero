-- client/ui/loading.lua
-- District Zero UI Loading State Management

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Loading state
local State = {
    isLoading = false,
    loadingTasks = {},
    loadingTimeout = 10000 -- 10 seconds
}

-- Show loading state
local function ShowLoading(message)
    if State.isLoading then return false end
    
    State.isLoading = true
    State.loadingTasks = {}
    
    -- Show loading UI
    SendNUIMessage({
        action = 'loading',
        show = true,
        message = message or 'Loading...'
    })
    
    -- Set loading timeout
    State.loadingTimeout = SetTimeout(State.loadingTimeout, function()
        if State.isLoading then
            HideLoading('Loading timed out')
        end
    end)
    
    return true
end

-- Hide loading state
local function HideLoading(message)
    if not State.isLoading then return false end
    
    State.isLoading = false
    
    -- Clear loading timeout
    if State.loadingTimeout then
        ClearTimeout(State.loadingTimeout)
        State.loadingTimeout = nil
    end
    
    -- Hide loading UI
    SendNUIMessage({
        action = 'loading',
        show = false,
        message = message
    })
    
    return true
end

-- Add loading task
local function AddLoadingTask(task)
    if not State.isLoading then return false end
    
    table.insert(State.loadingTasks, task)
    return true
end

-- Complete loading task
local function CompleteLoadingTask(task)
    if not State.isLoading then return false end
    
    for i, t in ipairs(State.loadingTasks) do
        if t == task then
            table.remove(State.loadingTasks, i)
            break
        end
    end
    
    -- Check if all tasks are complete
    if #State.loadingTasks == 0 then
        HideLoading()
    end
    
    return true
end

-- Register cleanup handler
RegisterCleanup('loading', function()
    if State.isLoading then
        HideLoading('Resource stopped')
    end
end)

-- Exports
exports('ShowLoading', ShowLoading)
exports('HideLoading', HideLoading)
exports('AddLoadingTask', AddLoadingTask)
exports('CompleteLoadingTask', CompleteLoadingTask) 