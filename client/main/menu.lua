-- District Zero Menu Handler
local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'

-- Menu State
local State = {
    isMenuOpen = false,
    currentTab = 'districts',
    menuVisible = false,
    isPlayerLoaded = false,
    menuConfig = {
        position = vector2(0.85, 0.5),
        width = 0.3,
        height = 0.6,
        title = "District Zero",
        tabs = {
            {name = 'districts', label = 'Districts'},
            {name = 'missions', label = 'Missions'},
            {name = 'factions', label = 'Factions'},
            {name = 'stats', label = 'Stats'}
        }
    },
    menuState = {
        districts = {},
        missions = {},
        factions = {},
        stats = {}
    }
}

-- Initialize Menu
local function InitializeMenu()
    if not State.isPlayerLoaded then return end
    
    -- Set up keybinds
    RegisterCommand('+toggleDistrictMenu', function()
        if not State.isPlayerLoaded then return end
        ToggleMenu()
    end, false)
    
    RegisterKeyMapping('+toggleDistrictMenu', 'Toggle District Zero Menu', 'keyboard', 'F5')
    
    -- Register additional keybinds
    RegisterCommand('+toggleMissionsMenu', function()
        if not State.isPlayerLoaded then return end
        ToggleMissionsMenu()
    end, false)
    RegisterKeyMapping('+toggleMissionsMenu', 'Toggle Missions Menu', 'keyboard', 'F6')
    
    RegisterCommand('+toggleFactionsMenu', function()
        if not State.isPlayerLoaded then return end
        ToggleFactionsMenu()
    end, false)
    RegisterKeyMapping('+toggleFactionsMenu', 'Toggle Factions Menu', 'keyboard', 'F7')
    
    RegisterCommand('+toggleStatsMenu', function()
        if not State.isPlayerLoaded then return end
        ToggleStatsMenu()
    end, false)
    RegisterKeyMapping('+toggleStatsMenu', 'Toggle Stats Menu', 'keyboard', 'F8')
end

-- Toggle Menu
function ToggleMenu()
    if not State.isPlayerLoaded then return end
    
    State.isMenuOpen = not State.isMenuOpen
    if State.isMenuOpen then
        -- Refresh data when opening
        Events.TriggerEvent('dz:client:district:requestUpdate', 'client')
        Events.TriggerEvent('dz:client:faction:requestUpdate', 'client')
        State.currentTab = 'districts'
    else
        -- Close all sub-menus
        CloseAllMenus()
    end
end

-- Toggle Sub-Menus
function ToggleMissionsMenu()
    if not State.isPlayerLoaded then return end
    State.isMenuOpen = true
    State.currentTab = 'missions'
    Events.TriggerEvent('dz:client:mission:requestUpdate', 'client')
end

function ToggleFactionsMenu()
    if not State.isPlayerLoaded then return end
    State.isMenuOpen = true
    State.currentTab = 'factions'
    Events.TriggerEvent('dz:client:faction:requestUpdate', 'client')
end

function ToggleStatsMenu()
    if not State.isPlayerLoaded then return end
    State.isMenuOpen = true
    State.currentTab = 'stats'
    Events.TriggerEvent('dz:client:stats:requestUpdate', 'client')
end

-- Close All Menus
function CloseAllMenus()
    State.isMenuOpen = false
    State.currentTab = 'districts'
    -- Close any open sub-menus
    Events.TriggerEvent('dz:client:ui:closeAll', 'client')
end

-- Draw Menu
local function DrawMenu()
    if not State.isMenuOpen or not State.isPlayerLoaded then return end
    
    -- Draw background
    DrawRect(State.menuConfig.position.x, State.menuConfig.position.y, State.menuConfig.width, State.menuConfig.height, 0, 0, 0, 200)
    
    -- Draw title
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(State.menuConfig.title)
    DrawText(State.menuConfig.position.x, State.menuConfig.position.y - State.menuConfig.height/2 + 0.02)
    
    -- Draw tabs
    local tabWidth = State.menuConfig.width / #State.menuConfig.tabs
    for i, tab in ipairs(State.menuConfig.tabs) do
        local tabX = State.menuConfig.position.x - State.menuConfig.width/2 + tabWidth * (i-0.5)
        local tabY = State.menuConfig.position.y - State.menuConfig.height/2 + 0.05
        
        -- Draw tab background
        local isSelected = State.currentTab == tab.name
        DrawRect(tabX, tabY, tabWidth - 0.01, 0.03, 
            isSelected and 100 or 50,
            isSelected and 100 or 50,
            isSelected and 100 or 50,
            200)
        
        -- Draw tab text
        SetTextScale(0.3, 0.3)
        SetTextFont(4)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(tab.label)
        DrawText(tabX, tabY - 0.01)
    end
    
    -- Draw content based on current tab
    DrawTabContent()
    
    -- Draw close button
    DrawCloseButton()
end

-- Draw Close Button
local function DrawCloseButton()
    local closeX = State.menuConfig.position.x + State.menuConfig.width/2 - 0.02
    local closeY = State.menuConfig.position.y - State.menuConfig.height/2 + 0.02
    
    -- Draw close button background
    DrawRect(closeX, closeY, 0.02, 0.02, 255, 0, 0, 200)
    
    -- Draw close button text
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("X")
    DrawText(closeX, closeY - 0.01)
end

-- Draw Tab Content
local function DrawTabContent()
    local contentY = State.menuConfig.position.y - State.menuConfig.height/2 + 0.1
    local contentHeight = State.menuConfig.height - 0.15
    
    -- Draw content background
    DrawRect(State.menuConfig.position.x, contentY + contentHeight/2, 
        State.menuConfig.width - 0.02, contentHeight, 30, 30, 30, 200)
    
    -- Draw specific tab content
    if State.currentTab == 'districts' then
        DrawDistrictsTab(contentY, contentHeight)
    elseif State.currentTab == 'missions' then
        DrawMissionsTab(contentY, contentHeight)
    elseif State.currentTab == 'factions' then
        DrawFactionsTab(contentY, contentHeight)
    elseif State.currentTab == 'stats' then
        DrawStatsTab(contentY, contentHeight)
    end
end

-- Tab Content Drawers
local function DrawDistrictsTab(startY, height)
    local y = startY
    for id, district in pairs(State.menuState.districts) do
        if y < startY + height - 0.05 then
            -- Draw district info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(district.name)
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y)
            
            -- Draw district status
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Control: %s", district.control))
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

local function DrawMissionsTab(startY, height)
    local y = startY
    for id, mission in pairs(State.menuState.missions) do
        if y < startY + height - 0.05 then
            -- Draw mission info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(mission.name)
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y)
            
            -- Draw mission status
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Status: %s", mission.status))
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

local function DrawFactionsTab(startY, height)
    local y = startY
    for id, faction in pairs(State.menuState.factions) do
        if y < startY + height - 0.05 then
            -- Draw faction info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(faction.name)
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y)
            
            -- Draw faction status
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Members: %d", faction.memberCount))
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

local function DrawStatsTab(startY, height)
    local y = startY
    for id, stat in pairs(State.menuState.stats) do
        if y < startY + height - 0.05 then
            -- Draw stat info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(stat.name)
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y)
            
            -- Draw stat value
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Value: %s", stat.value))
            DrawText(State.menuConfig.position.x - State.menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

-- Event Handlers
Events.RegisterEvent('dz:client:menu:updateDistricts', function(districts)
    State.menuState.districts = districts
end)

Events.RegisterEvent('dz:client:menu:updateMissions', function(missions)
    State.menuState.missions = missions
end)

Events.RegisterEvent('dz:client:menu:updateFactions', function(factions)
    State.menuState.factions = factions
end)

Events.RegisterEvent('dz:client:menu:updateStats', function(stats)
    State.menuState.stats = stats
end)

-- Player Load Handler
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    State.isPlayerLoaded = true
    InitializeMenu()
end)

-- Player Unload Handler
RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    State.isPlayerLoaded = false
    CloseAllMenus()
end)

-- Menu Thread
CreateThread(function()
    while true do
        Wait(0)
        if State.isMenuOpen and State.isPlayerLoaded then
            DrawMenu()
        end
    end
end)

-- Register cleanup handler
RegisterCleanup('state', function()
    -- Cleanup state
    State = {
        isMenuOpen = false,
        currentTab = 'districts',
        menuVisible = false,
        isPlayerLoaded = false,
        menuConfig = {
            position = vector2(0.85, 0.5),
            width = 0.3,
            height = 0.6,
            title = "District Zero",
            tabs = {
                {name = 'districts', label = 'Districts'},
                {name = 'missions', label = 'Missions'},
                {name = 'factions', label = 'Factions'},
                {name = 'stats', label = 'Stats'}
            }
        },
        menuState = {
            districts = {},
            missions = {},
            factions = {},
            stats = {}
        }
    }
end)

-- Register NUI cleanup handler
RegisterCleanup('nui', function()
    -- Close menu
    State.isMenuOpen = false
    Events.TriggerEvent('dz:client:ui:closeAll', 'client')
end)

-- Exports
exports('IsMenuOpen', function()
    return State.isMenuOpen and State.isPlayerLoaded
end)

exports('GetMenuState', function()
    return State.menuState
end)

exports('SetMenuState', function(key, value)
    if not State.menuState[key] then return false end
    State.menuState[key] = value
    return true
end) 