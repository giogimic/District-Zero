-- District Zero Client Exports
-- Version: 1.0.0

-- Client state (placeholder for now)
local ClientState = {
    currentDistrict = nil,
    currentTeam = nil,
    currentMission = nil,
    blipCount = 0,
    districts = {},
    districtControl = {},
    districtInfluence = {},
    controlPoints = {},
    teamMembers = {},
    teamBalance = 0,
    teamLeaderboard = {},
    performanceMetrics = {},
    errorReport = {}
}

-- Export functions
exports('GetCurrentDistrict', function()
    return ClientState.currentDistrict
end)

exports('GetCurrentTeam', function()
    return ClientState.currentTeam
end)

exports('GetCurrentMission', function()
    return ClientState.currentMission
end)

exports('GetBlipCount', function()
    return ClientState.blipCount
end)

exports('GetAllDistricts', function()
    return ClientState.districts
end)

exports('GetDistrict', function(districtId)
    return ClientState.districts[districtId]
end)

exports('GetPlayerTeam', function(playerId)
    -- This would normally check the actual player team
    return ClientState.currentTeam
end)

exports('GetTeamStats', function()
    return {
        members = #ClientState.teamMembers,
        balance = ClientState.teamBalance,
        wins = 0,
        losses = 0
    }
end)

exports('GetAvailableMissions', function(districtId)
    -- This would normally get missions from server
    return {}
end)

exports('GetPerformanceMetrics', function()
    return ClientState.performanceMetrics
end)

exports('GetErrorReport', function()
    return ClientState.errorReport
end)

exports('GetDistrictControl', function()
    return ClientState.districtControl
end)

exports('GetDistrictInfluence', function(districtId)
    return ClientState.districtInfluence[districtId] or { pvp = 0, pve = 0 }
end)

exports('GetControlPoints', function(districtId)
    return ClientState.controlPoints[districtId] or {}
end)

exports('GetTeamMembers', function()
    return ClientState.teamMembers
end)

exports('GetTeamBalance', function()
    return ClientState.teamBalance
end)

exports('GetTeamLeaderboard', function()
    return ClientState.teamLeaderboard
end)

exports('GetTeamMembersInRange', function(range)
    local inRange = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, member in ipairs(ClientState.teamMembers) do
        if member.ped and member.ped ~= playerPed then
            local memberCoords = GetEntityCoords(member.ped)
            local distance = #(playerCoords - memberCoords)
            if distance <= range then
                table.insert(inRange, member)
            end
        end
    end
    
    return inRange
end)

-- Additional client exports from fxmanifest
exports('GetUI', function()
    return {
        show = function() SendNUIMessage({ action = 'show' }) end,
        hide = function() SendNUIMessage({ action = 'hide' }) end,
        update = function(data) SendNUIMessage({ action = 'update', data = data }) end
    }
end)

exports('GetClientEvents', function()
    return {
        trigger = function(eventName, ...) TriggerEvent(eventName, ...) end,
        register = function(eventName, handler) RegisterNetEvent(eventName); AddEventHandler(eventName, handler) end
    }
end)

exports('GetClientPerformance', function()
    return {
        fps = GetFramerate(),
        ping = 0, -- Would need actual ping calculation
        memory = collectgarbage("count")
    }
end) 