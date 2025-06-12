-- District Zero Teams Module
-- Version: 1.0.0

local currentTeam = nil

-- Initialize teams
function InitializeTeams()
    if not Config.Teams then return false end

    -- Register team selection command
    RegisterCommand('team', function(source, args)
        if not args[1] then
            QBX.Functions.Notify('Usage: /team [pvp/pve]', 'error')
            return
        end

        local team = args[1]:lower()
        if team ~= 'pvp' and team ~= 'pve' then
            QBX.Functions.Notify('Invalid team. Choose pvp or pve', 'error')
            return
        end

        TriggerServerEvent('dz:server:selectTeam', team)
    end, false)

    return true
end

-- Set current team
function SetCurrentTeam(team)
    if not Config.Teams[team] then return false end
    
    currentTeam = team
    
    -- Update UI
    SendNUIMessage({
        type = 'updateUI',
        data = {
            currentTeam = team
        }
    })

    return true
end

-- Get current team
function GetCurrentTeam()
    return currentTeam
end

-- Check if player is in team
function IsInTeam(team)
    return currentTeam == team
end

-- Check if player can access mission
function CanAccessMission(mission)
    if not mission then return false end
    
    -- If no team selected, can't access missions
    if not currentTeam then return false end
    
    -- Check if mission type matches team
    return mission.type == currentTeam
end

-- Event handlers
RegisterNetEvent('dz:client:teamSelected', function(team)
    SetCurrentTeam(team)
    QBX.Functions.Notify('You joined the ' .. Config.Teams[team].name, 'success')
end)

-- Export functions
exports('GetCurrentTeam', GetCurrentTeam)
exports('IsInTeam', IsInTeam)
exports('CanAccessMission', CanAccessMission) 