-- District Zero Districts Server Module
-- Version: 1.0.0

local PlayerData = require 'qbx_core.server.modules.playerdata'
local Utils = require 'shared/utils'

-- State
local districtInfluence = {}

-- Initialize districts
local function InitializeDistricts()
    for _, district in pairs(Config.Districts) do
        districtInfluence[district.id] = {
            pvp = 0,
            pve = 0
        }
    end
end

-- Get district data
local function GetDistrictData(districtId)
    return districtInfluence[districtId]
end

-- Update district influence
local function UpdateDistrictInfluence(districtId, team, amount)
    if not districtInfluence[districtId] then return end
    if team ~= 'pvp' and team ~= 'pve' then return end
    
    districtInfluence[districtId][team] = districtInfluence[districtId][team] + amount
    
    -- Save to database
    exports['District-Zero']:UpdateDistrictInfluence(districtId, team, amount)
    
    -- Notify clients
    TriggerClientEvent('District-Zero:client:districtUpdated', -1, districtId, districtInfluence[districtId])
end

-- Event handlers
RegisterNetEvent('District-Zero:server:getDistrictData')
AddEventHandler('District-Zero:server:getDistrictData', function(districtId, cb)
    cb(GetDistrictData(districtId))
end)

-- Initialize on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    InitializeDistricts()
end)

-- Export functions
exports('GetDistrictData', GetDistrictData)
exports('UpdateDistrictInfluence', UpdateDistrictInfluence) 