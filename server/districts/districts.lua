-- server/districts/districts.lua
-- District Zero District Management

local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- District State
local State = {
    districts = {},
    captures = {},
    rewards = {}
}

-- Initialize districts
local function InitializeDistricts()
    local districts = Utils.SafeQuery('SELECT * FROM dz_districts', {}, 'InitializeDistricts')
    if districts then
        for _, district in ipairs(districts) do
            State.districts[district.id] = district
        end
    end
end

-- Handle district capture
local function HandleCapture(source, districtId)
    if not State.districts[districtId] then return false end
    
    local district = State.districts[districtId]
    local Player = QBX.Functions.GetPlayer(source)
    
    if not Player then return false end
    
    -- Check if player can capture
    if district.requirements then
        if district.requirements.job and Player.PlayerData.job.name ~= district.requirements.job then
            return false
        end
        if district.requirements.gang and Player.PlayerData.gang.name ~= district.requirements.gang then
            return false
        end
    end
    
    -- Update district ownership
    local success = Utils.SafeQuery('UPDATE dz_districts SET owner = ? WHERE id = ?', 
        {source, districtId}, 'HandleCapture')
    
    if success then
        district.owner = source
        State.captures[districtId] = {
            time = os.time(),
            player = source
        }
        
        -- Trigger capture event
        Events.TriggerEvent('dz:client:district:captured', 'server', -1, {
            districtId = districtId,
            player = source,
            time = os.time()
        })
        
        return true
    end
    return false
end

-- Handle district rewards
local function HandleRewards(source, districtId)
    if not State.districts[districtId] then return false end
    
    local district = State.districts[districtId]
    local Player = QBX.Functions.GetPlayer(source)
    
    if not Player then return false end
    
    -- Check if player owns district
    if district.owner ~= source then return false end
    
    -- Check if rewards are available
    if not district.rewards then return false end
    
    -- Give rewards
    if district.rewards.money then
        Player.Functions.AddMoney('cash', district.rewards.money)
    end
    
    if district.rewards.items then
        for _, item in ipairs(district.rewards.items) do
            Player.Functions.AddItem(item.name, item.amount)
        end
    end
    
    -- Update last reward time
    State.rewards[districtId] = os.time()
    
    return true
end

-- Event Handlers
Events.RegisterEvent('dz:server:district:capture', function(source, districtId)
    HandleCapture(source, districtId)
end)

Events.RegisterEvent('dz:server:district:requestRewards', function(source, districtId)
    HandleRewards(source, districtId)
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeDistricts()
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        districts = {},
        captures = {},
        rewards = {}
    }
end)

-- Exports
exports('GetDistricts', function()
    return State.districts
end)

exports('GetCaptures', function()
    return State.captures
end)

exports('GetRewards', function()
    return State.rewards
end) 