-- District Zero Districts Server Module
-- Version: 1.0.0

local Utils = require 'shared/utils'

-- State
local districtInfluence = {}

-- Initialize districts
local function InitializeDistricts()
    Utils.PrintDebug('Initializing districts...')
    
    -- Ensure Config.Districts exists
    if not Config or not Config.Districts then
        Utils.PrintDebug('Warning: Config.Districts not found, using defaults')
        Config = Config or {}
        Config.Districts = {
            downtown = {
                id = 'downtown',
                name = 'Downtown',
                influence_pvp = 0,
                influence_pve = 0
            }
        }
    end
    
    -- Initialize district data
    for id, district in pairs(Config.Districts) do
        districtInfluence[id] = {
            pvp = district.influence_pvp or 0,
            pve = district.influence_pve or 0
        }
    end
    
    Utils.PrintDebug('Districts initialized successfully')
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
exports('InitializeDistricts', InitializeDistricts) 