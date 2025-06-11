-- Map Handler for District Zero
local QBX = exports['qbx_core']:GetCoreObject()
local Utils = require 'shared/utils'
local Events = require 'shared/events'
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

-- Map State
local State = {
    districtBlips = {},
    districtMarkers = {},
    districtZones = {},
    currentDistrict = nil,
    isInDistrict = false,
    isMapOpen = false,
    selectedDistrict = nil,
    activeWaypoint = nil,
    minimapEnabled = true,
    navigationEnabled = false,
    playerData = {},
    config = {
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
}

-- QBX Core Event Handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    State.playerData = QBX.Functions.GetPlayerData()
    -- Initialize player-specific settings
    State.config.minimapSettings.enabled = State.playerData.metadata.minimapEnabled or true
    State.config.navigationSettings.enabled = State.playerData.metadata.navigationEnabled or true
    -- Load saved district preferences
    if State.playerData.metadata.districtPreferences then
        for id, pref in pairs(State.playerData.metadata.districtPreferences) do
            if Config.Districts[id] then
                Config.Districts[id].preferences = pref
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    -- Save current settings to metadata
    if State.playerData.metadata then
        State.playerData.metadata.minimapEnabled = State.config.minimapSettings.enabled
        State.playerData.metadata.navigationEnabled = State.config.navigationSettings.enabled
        -- Save district preferences
        local preferences = {}
        for id, district in pairs(Config.Districts) do
            if district.preferences then
                preferences[id] = district.preferences
            end
        end
        State.playerData.metadata.districtPreferences = preferences
        -- Trigger server to save metadata
        Events.TriggerEvent('dz:server:player:saveMetadata', 'server', State.playerData.metadata)
    end
    State.playerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    State.playerData.job = JobInfo
    -- Update district access based on job
    if State.isMapOpen then
        Events.TriggerEvent('dz:client:ui:updateJobAccess', 'client', JobInfo)
    end
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate')
AddEventHandler('QBCore:Client:OnGangUpdate', function(GangInfo)
    State.playerData.gang = GangInfo
    -- Update district access based on gang
    if State.isMapOpen then
        Events.TriggerEvent('dz:client:ui:updateGangAccess', 'client', GangInfo)
    end
end)

RegisterNetEvent('QBCore:Client:OnMoneyChange')
AddEventHandler('QBCore:Client:OnMoneyChange', function(amount, changeType, reason)
    -- Update district income if player is in a district
    if State.currentDistrict and changeType == 'add' then
        local district = Config.Districts[State.currentDistrict]
        if district then
            district.income = district.income + amount
            -- Update UI if open
            if State.isMapOpen then
                Events.TriggerEvent('dz:client:ui:updateDistrictIncome', 'client', {
                    districtId = State.currentDistrict,
                    income = district.income
                })
            end
        end
    end
end)

-- System Connections
local function ConnectToSystems()
    -- Connect to district system
    Events.RegisterEvent('dz:client:district:update', function(districtData)
        if districtData then
            -- Update district information
            for id, data in pairs(districtData) do
                if Config.Districts[id] then
                    Config.Districts[id] = data
                end
            end
            -- Refresh UI if open
            if State.isMapOpen then
                Events.TriggerEvent('dz:client:ui:updateDistricts', 'client', Config.Districts)
            end
        end
    end)

    -- Connect to waypoint system
    Events.RegisterEvent('dz:client:waypoint:update', function(waypointData)
        if waypointData then
            -- Update waypoint information
            State.activeWaypoint = waypointData
            -- Refresh UI if open
            if State.isMapOpen then
                Events.TriggerEvent('dz:client:ui:updateWaypoint', 'client', waypointData)
            end
        end
    end)
end

-- Initialize systems
CreateThread(function()
    ConnectToSystems()
    -- Wait for player data to be loaded
    while not State.playerData.citizenid do
        Wait(100)
    end
    -- Initialize with player data
    State.config.minimapSettings.enabled = State.playerData.metadata.minimapEnabled or true
    State.config.navigationSettings.enabled = State.playerData.metadata.navigationEnabled or true
end)

-- Keybinding Registration
RegisterCommand('+openDistrictMap', function()
    if not State.isMapOpen and State.playerData.citizenid then
        ShowUI()
    else
        QBX.Functions.Notify('You must be logged in to access the district map', 'error')
    end
end, false)

RegisterCommand('-openDistrictMap', function()
    -- Command released
end, false)

RegisterKeyMapping('+openDistrictMap', 'Open District Map', 'keyboard', State.config.uiSettings.keybind)

-- Register essential keybindings
RegisterCommand('+toggleMinimap', function()
    if State.playerData.citizenid then
        ToggleMinimap(not State.config.minimapSettings.enabled)
        -- Save to metadata
        if State.playerData.metadata then
            State.playerData.metadata.minimapEnabled = State.config.minimapSettings.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', State.playerData.metadata)
        end
    end
end, false)

RegisterCommand('+toggleNavigation', function()
    if State.playerData.citizenid then
        State.config.navigationSettings.enabled = not State.config.navigationSettings.enabled
        if not State.config.navigationSettings.enabled then
            ClearWaypoint()
        end
        -- Save to metadata
        if State.playerData.metadata then
            State.playerData.metadata.navigationEnabled = State.config.navigationSettings.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', State.playerData.metadata)
        end
    end
end, false)

RegisterCommand('+clearWaypoint', function()
    if State.playerData.citizenid then
        ClearWaypoint()
    end
end, false)

RegisterCommand('+resetView', function()
    if State.playerData.citizenid then
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
        SetRadarZoom(State.config.minimapSettings.zoom)
        SetRadarAsExteriorThisFrame()
        SetRadarAsInteriorThisFrame('h4_fake_interior_lod', vector3(0.0, 0.0, 0.0), 0, 0)
    else
        DisplayRadar(false)
    end
end

local function UpdateMinimapPosition()
    if not State.config.minimapSettings.enabled then return end
    
    local x = State.config.minimapSettings.position.x
    local y = State.config.minimapSettings.position.y
    local width = State.config.minimapSettings.size.width
    local height = State.config.minimapSettings.size.height
    
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
    if State.activeWaypoint then
        DeleteWaypoint()
        if DoesBlipExist(State.activeWaypoint) then
            RemoveBlip(State.activeWaypoint)
        end
    end
    
    -- Set new waypoint
    SetNewWaypoint(coords.x, coords.y)
    State.activeWaypoint = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    -- Configure waypoint blip
    SetBlipSprite(State.activeWaypoint, State.config.navigationSettings.routeBlipSprite)
    SetBlipColour(State.activeWaypoint, State.config.navigationSettings.routeBlipColor)
    SetBlipScale(State.activeWaypoint, State.config.navigationSettings.routeBlipScale)
    SetBlipRoute(State.activeWaypoint, true)
    
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
    if State.playerData.metadata then
        if not State.playerData.metadata.recentWaypoints then
            State.playerData.metadata.recentWaypoints = {}
        end
        table.insert(State.playerData.metadata.recentWaypoints, 1, {
            districtId = districtId,
            timestamp = os.time()
        })
        -- Keep only last 5 waypoints
        if #State.playerData.metadata.recentWaypoints > 5 then
            table.remove(State.playerData.metadata.recentWaypoints)
        end
        TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', State.playerData.metadata)
    end
end

local function ClearWaypoint()
    if State.activeWaypoint then
        DeleteWaypoint()
        if DoesBlipExist(State.activeWaypoint) then
            RemoveBlip(State.activeWaypoint)
        end
        State.activeWaypoint = nil
        
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

    if newDistrict ~= State.currentDistrict then
        if State.currentDistrict then
            TriggerEvent('district:exit', State.currentDistrict)
        end
        if newDistrict then
            TriggerEvent('district:enter', newDistrict)
            -- Update player's visited districts
            if State.playerData.metadata then
                if not State.playerData.metadata.visitedDistricts then
                    State.playerData.metadata.visitedDistricts = {}
                end
                State.playerData.metadata.visitedDistricts[newDistrict] = os.time()
                TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', State.playerData.metadata)
            end
        end
        State.currentDistrict = newDistrict
        
        -- Update navigation if waypoint is set
        if State.activeWaypoint and State.currentDistrict then
            local district = Config.Districts[State.currentDistrict]
            local waypointCoords = GetBlipCoords(State.activeWaypoint)
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
        State.isInDistrict = true
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
        if State.playerData.job and district.jobAccess then
            if not district.jobAccess[State.playerData.job.name] then
                QBX.Functions.Notify('You do not have permission to be in this district', 'error')
            end
        end
        if State.playerData.gang and district.gangAccess then
            if not district.gangAccess[State.playerData.gang.name] then
                QBX.Functions.Notify('Your gang does not have permission to be in this district', 'error')
            end
        end
    end
end)

RegisterNetEvent('district:exit')
AddEventHandler('district:exit', function(districtId)
    local district = Config.Districts[districtId]
    if district then
        State.isInDistrict = false
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
    if State.playerData.citizenid then
        State.config.minimapSettings.enabled = data.enabled
        ToggleMinimap(data.enabled)
        -- Save to metadata
        if State.playerData.metadata then
            State.playerData.metadata.minimapEnabled = data.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', State.playerData.metadata)
        end
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('toggleNavigation', function(data, cb)
    if State.playerData.citizenid then
        State.config.navigationSettings.enabled = data.enabled
        if not data.enabled then
            ClearWaypoint()
        end
        -- Save to metadata
        if State.playerData.metadata then
            State.playerData.metadata.navigationEnabled = data.enabled
            TriggerServerEvent('QBCore:Server:SetMetaData', 'metadata', State.playerData.metadata)
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
    ToggleMinimap(State.config.minimapSettings.enabled)
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
        if IsControlJustPressed(0, Keys[State.config.uiSettings.closeKey]) and State.isMapOpen then
            HideUI()
        end
    end
end)

-- Exports
exports('GetMapState', function()
    return State
end)

exports('SetMapState', function(key, value)
    if not State[key] then return false end
    State[key] = value
    return true
end)

exports('GetCurrentDistrict', function()
    return State.currentDistrict
end)

exports('IsInDistrict', function()
    return State.isInDistrict
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
    State.config.navigationSettings.enabled = enable
end)

exports('ShowDistrictMap', function()
    ShowUI()
end)

exports('HideDistrictMap', function()
    HideUI()
end) 