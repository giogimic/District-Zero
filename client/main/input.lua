-- client/main/input.lua
-- Input handling for District Zero

local Utils = require 'shared/utils'

-- Key mapping registration
RegisterCommand('+toggleDistrictMenu', function()
    if not LocalPlayer.state.isLoggedIn then return end
    TriggerEvent('dz:menu:toggle')
end, false)

RegisterKeyMapping('+toggleDistrictMenu', 'Toggle District Zero Menu', 'keyboard', 'F5')

-- NUI Focus Management
local function SetNuiFocus(hasFocus, hasCursor)
    SetNuiFocus(hasFocus, hasCursor)
    if hasFocus then
        SetNuiFocusKeepInput(false)
    end
end

-- Event Handlers
RegisterNetEvent('dz:menu:toggle')
AddEventHandler('dz:menu:toggle', function()
    local isMenuOpen = LocalPlayer.state.menuOpen or false
    SetNuiFocus(not isMenuOpen, not isMenuOpen)
    LocalPlayer.state:set('menuOpen', not isMenuOpen, true)
    SendNUIMessage({
        type = isMenuOpen and 'hide' or 'show'
    })
end)

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    LocalPlayer.state:set('menuOpen', false, true)
    cb('ok')
end)

-- Input validation
local function IsValidInput()
    return LocalPlayer.state.isLoggedIn and not LocalPlayer.state.isDead
end

-- Export functions
exports('SetNuiFocus', SetNuiFocus)
exports('IsValidInput', IsValidInput) 