-- District Zero Main Client Handler
local QBX = exports['qbx_core']:GetCore()
local Utils = require 'shared/utils'

-- State Management
local State = {
    menu = {
        isOpen = false,
        isVisible = false,
        currentTab = 'districts'
    },
    player = {
        isLoaded = false,
        data = nil
    }
}

-- Initialize
local function Initialize()
    if not State.player.isLoaded then return end
    
    -- Set up keybinds
    RegisterCommand('+toggleDistrictMenu', function()
        if not State.player.isLoaded then return end
        ToggleMenu()
    end, false)
    
    RegisterKeyMapping('+toggleDistrictMenu', 'Toggle District Zero Menu', 'keyboard', 'F5')
end

-- Toggle Menu
function ToggleMenu()
    if not State.player.isLoaded then return end
    
    State.menu.isOpen = not State.menu.isOpen
    if State.menu.isOpen then
        -- Refresh data when opening
        TriggerServerEvent('dz:district:requestUpdate')
        TriggerServerEvent('dz:faction:requestUpdate')
    else
        -- Close all sub-menus
        CloseAllMenus()
    end
end

-- Close All Menus
function CloseAllMenus()
    State.menu.isOpen = false
    State.menu.currentTab = 'districts'
    -- Close any open sub-menus
    TriggerEvent('dz:ui:closeAll')
end

-- Player Load Handler
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    State.player.isLoaded = true
    State.player.data = QBX.Functions.GetPlayerData()
    Initialize()
end)

-- Player Unload Handler
RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    State.player.isLoaded = false
    State.player.data = nil
    CloseAllMenus()
end)

-- State Update Handler
RegisterNetEvent('dz:state:update')
AddEventHandler('dz:state:update', function(newState)
    if type(newState) ~= 'table' then return end
    
    for key, value in pairs(newState) do
        if State[key] then
            State[key] = value
        end
    end
end)

-- Resource Stop Handler
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Cleanup state
    State = {
        menu = {
            isOpen = false,
            isVisible = false,
            currentTab = 'districts'
        },
        player = {
            isLoaded = false,
            data = nil
        }
    }
end)

-- Exports
exports('IsMenuOpen', function()
    return State.menu.isOpen and State.player.isLoaded
end)

exports('GetState', function()
    return State
end)

exports('SetState', function(key, value)
    if not State[key] then return false end
    State[key] = value
    return true
end) 