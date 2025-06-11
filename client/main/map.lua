-- Map Handler for District Zero
local QBX = exports['qbx_core']:GetCore()
local districtBlips = {}
local districtMarkers = {}
local districtZones = {}
local currentDistrict = nil
local isInDistrict = false
local isMapOpen = false
local selectedDistrict = nil
local activeWaypoint = nil
local minimapEnabled = true
local navigationEnabled = false
local PlayerData = {}

-- Essential Keybindings (only unique to our system)
local Keys = {
    ['F5'] = 327, -- Open/Close District Map
    ['ESCAPE'] = 322, -- Close UI
    ['ENTER'] = 18, -- Confirm Selection
    ['BACKSPACE'] = 177, -- Go Back
    ['DELETE'] = 178, -- Clear Waypoint
    ['INSERT'] = 121, -- Toggle Minimap
    ['END'] = 213, -- Toggle Navigation
    ['HOME'] = 212, -- Reset View
    ['PAGEUP'] = 10, -- Zoom In
    ['PAGEDOWN'] = 11, -- Zoom Out
    ['ARROWUP'] = 172, -- Navigate Up
    ['ARROWDOWN'] = 173, -- Navigate Down
    ['ARROWLEFT'] = 174, -- Navigate Left
    ['ARROWRIGHT'] = 175, -- Navigate Right
}

-- Enhanced Configuration
local Config = {
    blipSettings = {
        sprite = 1,
        color = 2,
        scale = 0.8,
        shortRange = true,
        display = 4,
        categories = {
            residential = { sprite = 1, color = 2 },
            commercial = { sprite = 2, color = 3 },
            industrial = { sprite = 3, color = 4 },
            special = { sprite = 4, color = 5 }
        }
    },
    markerSettings = {
        type = 1,
        size = {x = 50.0, y = 50.0, z = 50.0},
        color = {r = 0, g = 255, b = 0, a = 100},
        bobUpAndDown = false,
        faceCamera = false,
        rotate = false,
        drawDistance = 50.0,
        pulse = true,
        pulseSpeed = 1.0
    },
    zoneSettings = {
        types = {
            capture = { color = {r = 255, g = 0, b = 0, a = 100} },
            defend = { color = {r = 0, g = 255, b = 0, a = 100} },
            resource = { color = {r = 0, g = 0, b = 255, a = 100} },
            event = { color = {r = 255, g = 255, b = 0, a = 100} }
        }
    },
    minimapSettings = {
        enabled = true,
        position = {x = 0.0, y = 0.0},
        size = {width = 0.2, height = 0.2},
        zoom = 0.5,
        rotation = true,
        radar = true
    },
    navigationSettings = {
        enabled = true,
        routeColor = {r = 255, g = 255, b = 255, a = 200},
        routeWidth = 3.0,
        routeStyle = 1,
        routeBlip = true,
        routeBlipSprite = 1,
        routeBlipColor = 5,
        routeBlipScale = 0.8
    },
    uiSettings = {
        defaultVisible = false,
        requireAuth = true,
        keybind = 'F5',
        closeKey = 'ESCAPE',
        confirmKey = 'ENTER',
        backKey = 'BACKSPACE',
        navigationKeys = {
            up = 'ARROWUP',
            down = 'ARROWDOWN',
            left = 'ARROWLEFT',
            right = 'ARROWRIGHT'
        },
        mapControls = {
            zoomIn = 'PAGEUP',
            zoomOut = 'PAGEDOWN',
            resetView = 'HOME',
            clearWaypoint = 'DELETE',
            toggleMinimap = 'INSERT',
            toggleNavigation = 'END'
        }
    }
}

-- QBX Core Event Handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBX.Functions.GetPlayerData()
    -- Initialize player-specific settings
    Config.minimapSettings.enabled = PlayerData.metadata.minimapEnabled or true
    Config.navigationSettings.enabled = PlayerData.metadata.navigationEnabled or true
    -- Load saved district preferences
    if PlayerData.metadata.districtPreferences then
        for id, pref in pairs(PlayerData.metadata.districtPreferences) do
            if Config.Districts[id] then
                Config.Districts[id].preferences = pref
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    -- Save current settings to metadata
    if PlayerData.metadata then
        PlayerData.metadata.minimapEnabled = Config.minimapSettings.enabled
        PlayerData.metadata.navigationEnabled = Config.navigationSettings.enabled
        -- Save district preferences
        local preferences = {}
        for id, district in pairs(Config.Districts) do
            if district.preferences then
                preferences[id] = district.preferences
            end
        end
        PlayerData.metadata.districtPreferences = preferences
        -- Trigger server to save metadata
        TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
    end
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    -- Update district access based on job
    if isMapOpen then
        SendNUIMessage({
            action = 'updateJobAccess',
            job = JobInfo
        })
    end
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
    -- Update district access based on gang
    if isMapOpen then
        SendNUIMessage({
            action = 'updateGangAccess',
            gang = GangInfo
        })
    end
end)

RegisterNetEvent('QBCore:Client:OnMoneyChange', function(amount, changeType, reason)
    -- Update district income if player is in a district
    if currentDistrict and changeType == 'add' then
        local district = Config.Districts[currentDistrict]
        if district then
            district.income = district.income + amount
            -- Update UI if open
            if isMapOpen then
                SendNUIMessage({
                    action = 'updateDistrictIncome',
                    districtId = currentDistrict,
                    income = district.income
                })
            end
        end
    end
end)

-- System Connections (only unique to our system)
local function ConnectToSystems()
    -- Connect to district system
    RegisterNetEvent('district:update')
    AddEventHandler('district:update', function(districtData)
        if districtData then
            -- Update district information
            for id, data in pairs(districtData) do
                if Config.Districts[id] then
                    Config.Districts[id] = data
                end
            end
            -- Refresh UI if open
            if isMapOpen then
                SendNUIMessage({
                    action = 'updateDistricts',
                    districts = Config.Districts
                })
            end
        end
    end)

    -- Connect to waypoint system
    RegisterNetEvent('waypoint:update')
    AddEventHandler('waypoint:update', function(waypointData)
        if waypointData then
            -- Update waypoint information
            activeWaypoint = waypointData
            -- Refresh UI if open
            if isMapOpen then
                SendNUIMessage({
                    action = 'updateWaypoint',
                    waypoint = waypointData
                })
            end
        end
    end)
end

-- Initialize systems
CreateThread(function()
    ConnectToSystems()
    -- Wait for player data to be loaded
    while not PlayerData.citizenid do
        Wait(100)
    end
    -- Initialize with player data
    Config.minimapSettings.enabled = PlayerData.metadata.minimapEnabled or true
    Config.navigationSettings.enabled = PlayerData.metadata.navigationEnabled or true
end)

-- Keybinding Registration
RegisterCommand('+openDistrictMap', function()
    if not isMapOpen and PlayerData.citizenid then
        ShowUI()
    else
        QBX.Functions.Notify('You must be logged in to access the district map', 'error')
    end
end, false)

RegisterCommand('-openDistrictMap', function()
    -- Command released
end, false)

RegisterKeyMapping('+openDistrictMap', 'Open District Map', 'keyboard', Config.uiSettings.keybind)

-- Register essential keybindings
RegisterCommand('+toggleMinimap', function()
    if PlayerData.citizenid then
        ToggleMinimap(not Config.minimapSettings.enabled)
        -- Save to metadata
        if PlayerData.metadata then
            PlayerData.metadata.minimapEnabled = Config.minimapSettings.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
        end
    end
end, false)

RegisterCommand('+toggleNavigation', function()
    if PlayerData.citizenid then
        Config.navigationSettings.enabled = not Config.navigationSettings.enabled
        if not Config.navigationSettings.enabled then
            ClearWaypoint()
        end
        -- Save to metadata
        if PlayerData.metadata then
            PlayerData.metadata.navigationEnabled = Config.navigationSettings.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
        end
    end
end, false)

RegisterCommand('+clearWaypoint', function()
    if PlayerData.citizenid then
        ClearWaypoint()
    end
end, false)

RegisterCommand('+resetView', function()
    if PlayerData.citizenid then
        state.mapScale = 1
        state.mapOffset = { x = 0, y = 0 }
        updateMapTransform()
    end
end, false)

RegisterKeyMapping('+toggleMinimap', 'Toggle Minimap', 'keyboard', 'INSERT')
RegisterKeyMapping('+toggleNavigation', 'Toggle Navigation', 'keyboard', 'END')
RegisterKeyMapping('+clearWaypoint', 'Clear Waypoint', 'keyboard', 'DELETE')
RegisterKeyMapping('+resetView', 'Reset View', 'keyboard', 'HOME')

-- Enhanced minimap functions
local function ToggleMinimap(show)
    if show then
        DisplayRadar(true)
        SetRadarZoom(Config.minimapSettings.zoom)
        SetRadarAsExteriorThisFrame()
        SetRadarAsInteriorThisFrame('h4_fake_interior_lod', vector3(0.0, 0.0, 0.0), 0, 0)
    else
        DisplayRadar(false)
    end
end

local function UpdateMinimapPosition()
    if not Config.minimapSettings.enabled then return end
    
    local x = Config.minimapSettings.position.x
    local y = Config.minimapSettings.position.y
    local width = Config.minimapSettings.size.width
    local height = Config.minimapSettings.size.height
    
    SetMinimapComponentPosition('minimap', 'L', 'B', x, y, width, height)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', x, y, width, height)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', x, y, width, height)
end

-- Enhanced navigation functions
local function SetWaypoint(districtId)
    if not districtId or not Config.Districts[districtId] then return end
    
    local district = Config.Districts[districtId]
    local coords = district.center
    
    -- Clear existing waypoint
    if activeWaypoint then
        DeleteWaypoint()
        if DoesBlipExist(activeWaypoint) then
            RemoveBlip(activeWaypoint)
        end
    end
    
    -- Set new waypoint
    SetNewWaypoint(coords.x, coords.y)
    activeWaypoint = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    -- Configure waypoint blip
    SetBlipSprite(activeWaypoint, Config.navigationSettings.routeBlipSprite)
    SetBlipColour(activeWaypoint, Config.navigationSettings.routeBlipColor)
    SetBlipScale(activeWaypoint, Config.navigationSettings.routeBlipScale)
    SetBlipRoute(activeWaypoint, true)
    
    -- Notify UI
    SendNUIMessage({
        action = 'updateWaypoint',
        district = {
            id = districtId,
            name = district.name,
            coords = coords
        }
    })

    -- Save to player's recent waypoints
    if PlayerData.metadata then
        if not PlayerData.metadata.recentWaypoints then
            PlayerData.metadata.recentWaypoints = {}
        end
        table.insert(PlayerData.metadata.recentWaypoints, 1, {
            districtId = districtId,
            timestamp = os.time()
        })
        -- Keep only last 5 waypoints
        if #PlayerData.metadata.recentWaypoints > 5 then
            table.remove(PlayerData.metadata.recentWaypoints)
        end
        TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
    end
end

local function ClearWaypoint()
    if activeWaypoint then
        DeleteWaypoint()
        if DoesBlipExist(activeWaypoint) then
            RemoveBlip(activeWaypoint)
        end
        activeWaypoint = nil
        
        -- Notify UI
        SendNUIMessage({
            action = 'clearWaypoint'
        })
    end
end

-- Enhanced district check with navigation
local function UpdateCurrentDistrict()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local newDistrict = nil

    for id, district in pairs(Config.Districts) do
        if IsPlayerInDistrict(coords, district) then
            newDistrict = id
            break
        end
    end

    if newDistrict ~= currentDistrict then
        if currentDistrict then
            TriggerEvent('district:exit', currentDistrict)
        end
        if newDistrict then
            TriggerEvent('district:enter', newDistrict)
            -- Update player's visited districts
            if PlayerData.metadata then
                if not PlayerData.metadata.visitedDistricts then
                    PlayerData.metadata.visitedDistricts = {}
                end
                PlayerData.metadata.visitedDistricts[newDistrict] = os.time()
                TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
            end
        end
        currentDistrict = newDistrict
        
        -- Update navigation if waypoint is set
        if activeWaypoint and currentDistrict then
            local district = Config.Districts[currentDistrict]
            local waypointCoords = GetBlipCoords(activeWaypoint)
            local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(waypointCoords.x, waypointCoords.y, waypointCoords.z))
            
            if distance < 50.0 then
                -- Waypoint reached
                ClearWaypoint()
                QBX.Functions.Notify('Destination reached!', 'success')
            end
        end
    end
end

-- Events
RegisterNetEvent('district:enter')
AddEventHandler('district:enter', function(districtId)
    local district = Config.Districts[districtId]
    if district then
        isInDistrict = true
        QBX.Functions.Notify('Entered ' .. district.name, 'success')
        
        -- Update UI
        SendNUIMessage({
            action = 'updateCurrentDistrict',
            district = {
                id = districtId,
                name = district.name,
                type = district.type,
                control = district.control,
                population = district.population,
                income = district.income,
                defense = district.defense,
                resources = district.resources
            }
        })

        -- Check job/gang permissions
        if PlayerData.job and district.jobAccess then
            if not district.jobAccess[PlayerData.job.name] then
                QBX.Functions.Notify('You do not have permission to be in this district', 'error')
            end
        end
        if PlayerData.gang and district.gangAccess then
            if not district.gangAccess[PlayerData.gang.name] then
                QBX.Functions.Notify('Your gang does not have permission to be in this district', 'error')
            end
        end
    end
end)

RegisterNetEvent('district:exit')
AddEventHandler('district:exit', function(districtId)
    local district = Config.Districts[districtId]
    if district then
        isInDistrict = false
        QBX.Functions.Notify('Left ' .. district.name, 'info')
        
        -- Update UI
        SendNUIMessage({
            action = 'updateCurrentDistrict',
            district = nil
        })
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeMap', function(data, cb)
    HideUI()
    cb('ok')
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    if data.districtId then
        SetWaypoint(data.districtId)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('clearWaypoint', function(data, cb)
    ClearWaypoint()
    cb('ok')
end)

RegisterNUICallback('toggleMinimap', function(data, cb)
    if PlayerData.citizenid then
        Config.minimapSettings.enabled = data.enabled
        ToggleMinimap(data.enabled)
        -- Save to metadata
        if PlayerData.metadata then
            PlayerData.metadata.minimapEnabled = data.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
        end
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('toggleNavigation', function(data, cb)
    if PlayerData.citizenid then
        Config.navigationSettings.enabled = data.enabled
        if not data.enabled then
            ClearWaypoint()
        end
        -- Save to metadata
        if PlayerData.metadata then
            PlayerData.metadata.navigationEnabled = data.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', PlayerData.metadata)
        end
        cb('ok')
    else
        cb('error')
    end
end)

-- Threads
CreateThread(function()
    -- Generate districts if not defined in config
    if not Config.Districts then
        Config.Districts = GenerateDistrictLocations()
    end

    -- Create blips, markers, and zones
    CreateDistrictBlips()
    CreateDistrictMarkers()
    CreateDistrictZones()

    -- Initialize minimap
    ToggleMinimap(Config.minimapSettings.enabled)
    UpdateMinimapPosition()

    -- Hide UI by default
    SendNUIMessage({
        action = 'hideMap'
    })

    while true do
        Wait(0)
        UpdateCurrentDistrict()
        
        if Config.Settings.ShowMarkers then
            DrawDistrictMarkers()
        end
        
        if Config.Settings.ShowZones then
            DrawDistrictZones()
        end

        -- Handle key presses
        if IsControlJustPressed(0, Keys[Config.uiSettings.closeKey]) and isMapOpen then
            HideUI()
        end
    end
end)

-- Exports
exports('GetCurrentDistrict', function()
    return currentDistrict
end)

exports('IsInDistrict', function()
    return isInDistrict
end)

exports('GetDistrictInfo', function(districtId)
    return Config.Districts[districtId]
end)

exports('UpdateDistrict', function(districtId, data)
    UpdateDistrict(districtId, data)
end)

exports('SetWaypoint', function(districtId)
    SetWaypoint(districtId)
end)

exports('ClearWaypoint', function()
    ClearWaypoint()
end)

exports('ToggleMinimap', function(show)
    ToggleMinimap(show)
end)

exports('ToggleNavigation', function(enable)
    Config.navigationSettings.enabled = enable
end)

exports('ShowDistrictMap', function()
    ShowUI()
end)

exports('HideDistrictMap', function()
    HideUI()
end) 