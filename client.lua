-- District Zero Main Client Handler
local QBX = exports['qbx_core']:GetSharedObject()
local isMenuOpen = false
local menuVisible = false
local isPlayerLoaded = false

-- Initialize
local function Initialize()
    if not isPlayerLoaded then return end
    
    -- Set up keybinds
    RegisterCommand('+toggleDistrictMenu', function()
        if not isPlayerLoaded then return end
        ToggleMenu()
    end, false)
    
    RegisterKeyMapping('+toggleDistrictMenu', 'Toggle District Zero Menu', 'keyboard', 'F5')
end

-- Toggle Menu
function ToggleMenu()
    if not isPlayerLoaded then return end
    
    isMenuOpen = not isMenuOpen
    if isMenuOpen then
        -- Refresh data when opening
        TriggerServerEvent('district:requestUpdate')
        TriggerServerEvent('faction:requestUpdate')
    end
end

-- Player Load Handler
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isPlayerLoaded = true
    menuVisible = true
    Initialize()
end)

-- Player Unload Handler
RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isPlayerLoaded = false
    menuVisible = false
    isMenuOpen = false
end)

-- Export menu state
exports('IsMenuOpen', function()
    return isMenuOpen and isPlayerLoaded
end)

exports('IsMenuVisible', function()
    return menuVisible and isPlayerLoaded
end)

exports('IsPlayerLoaded', function()
    return isPlayerLoaded
end) 