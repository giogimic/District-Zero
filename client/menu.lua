-- District Zero Menu Handler
local QBX = exports['qbx_core']:GetSharedObject()
local isMenuOpen = false
local currentTab = 'districts'
local menuVisible = false
local isPlayerLoaded = false

-- Menu Configuration
local menuConfig = {
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
}

-- Menu State
local menuState = {
    districts = {},
    missions = {},
    factions = {},
    stats = {}
}

-- Initialize Menu
local function InitializeMenu()
    if not isPlayerLoaded then return end
    
    -- Request initial data from server
    TriggerServerEvent('district:requestUpdate')
    TriggerServerEvent('faction:requestUpdate')
    
    -- Set up keybinds
    RegisterCommand('+toggleDistrictMenu', function()
        if not menuVisible then return end
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

-- Draw Menu
local function DrawMenu()
    if not isMenuOpen or not menuVisible or not isPlayerLoaded then return end
    
    -- Draw background
    DrawRect(menuConfig.position.x, menuConfig.position.y, menuConfig.width, menuConfig.height, 0, 0, 0, 200)
    
    -- Draw title
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(menuConfig.title)
    DrawText(menuConfig.position.x, menuConfig.position.y - menuConfig.height/2 + 0.02)
    
    -- Draw tabs
    local tabWidth = menuConfig.width / #menuConfig.tabs
    for i, tab in ipairs(menuConfig.tabs) do
        local tabX = menuConfig.position.x - menuConfig.width/2 + tabWidth * (i-0.5)
        local tabY = menuConfig.position.y - menuConfig.height/2 + 0.05
        
        -- Draw tab background
        local isSelected = currentTab == tab.name
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
end

-- Draw Tab Content
local function DrawTabContent()
    local contentY = menuConfig.position.y - menuConfig.height/2 + 0.1
    local contentHeight = menuConfig.height - 0.15
    
    -- Draw content background
    DrawRect(menuConfig.position.x, contentY + contentHeight/2, 
        menuConfig.width - 0.02, contentHeight, 30, 30, 30, 200)
    
    -- Draw specific tab content
    if currentTab == 'districts' then
        DrawDistrictsTab(contentY, contentHeight)
    elseif currentTab == 'missions' then
        DrawMissionsTab(contentY, contentHeight)
    elseif currentTab == 'factions' then
        DrawFactionsTab(contentY, contentHeight)
    elseif currentTab == 'stats' then
        DrawStatsTab(contentY, contentHeight)
    end
end

-- Tab Content Drawers
local function DrawDistrictsTab(startY, height)
    local y = startY
    for id, district in pairs(menuState.districts) do
        if y < startY + height - 0.05 then
            -- Draw district info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(district.name)
            DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y)
            
            -- Draw district status
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Control: %s", district.control))
            DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

local function DrawMissionsTab(startY, height)
    local y = startY
    for id, mission in pairs(menuState.missions) do
        if y < startY + height - 0.05 then
            -- Draw mission info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(mission.name)
            DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y)
            
            -- Draw mission status
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Status: %s", mission.status))
            DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

local function DrawFactionsTab(startY, height)
    local y = startY
    for id, faction in pairs(menuState.factions) do
        if y < startY + height - 0.05 then
            -- Draw faction info
            SetTextScale(0.3, 0.3)
            SetTextFont(4)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            AddTextComponentString(faction.name)
            DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y)
            
            -- Draw faction influence
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Influence: %d", faction.influence))
            DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y + 0.02)
            
            y = y + 0.06
        end
    end
end

local function DrawStatsTab(startY, height)
    local y = startY
    local stats = menuState.stats
    
    -- Draw player stats
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    
    -- Districts visited
    SetTextEntry("STRING")
    AddTextComponentString(string.format("Districts Visited: %d", stats.districtsVisited or 0))
    DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y)
    y = y + 0.03
    
    -- Missions completed
    SetTextEntry("STRING")
    AddTextComponentString(string.format("Missions Completed: %d", stats.missionsCompleted or 0))
    DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y)
    y = y + 0.03
    
    -- Faction influence
    SetTextEntry("STRING")
    AddTextComponentString(string.format("Faction Influence: %d", stats.factionInfluence or 0))
    DrawText(menuConfig.position.x - menuConfig.width/2 + 0.02, y)
end

-- Event Handlers
RegisterNetEvent('district:update')
AddEventHandler('district:update', function(districts)
    menuState.districts = districts
end)

RegisterNetEvent('faction:update')
AddEventHandler('faction:update', function(factions)
    menuState.factions = factions
end)

-- Player Load Handler
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isPlayerLoaded = true
    menuVisible = true
    InitializeMenu()
end)

-- Player Unload Handler
RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isPlayerLoaded = false
    menuVisible = false
    isMenuOpen = false
end)

-- Main thread
CreateThread(function()
    while true do
        Wait(0)
        if menuVisible and isPlayerLoaded then
            DrawMenu()
            
            -- Handle tab switching
            if IsControlJustPressed(0, 172) then -- Arrow Up
                local currentIndex = 1
                for i, tab in ipairs(menuConfig.tabs) do
                    if tab.name == currentTab then
                        currentIndex = i
                        break
                    end
                end
                currentIndex = currentIndex - 1
                if currentIndex < 1 then currentIndex = #menuConfig.tabs end
                currentTab = menuConfig.tabs[currentIndex].name
            elseif IsControlJustPressed(0, 173) then -- Arrow Down
                local currentIndex = 1
                for i, tab in ipairs(menuConfig.tabs) do
                    if tab.name == currentTab then
                        currentIndex = i
                        break
                    end
                end
                currentIndex = currentIndex + 1
                if currentIndex > #menuConfig.tabs then currentIndex = 1 end
                currentTab = menuConfig.tabs[currentIndex].name
            end
        end
    end
end)

-- Export menu state
exports('IsMenuOpen', function()
    return isMenuOpen and isPlayerLoaded
end)

exports('IsMenuVisible', function()
    return menuVisible and isPlayerLoaded
end)

exports('GetCurrentTab', function()
    return currentTab
end) 