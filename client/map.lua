-- Map Handler for District Zero
local QBX = exports.qbx_core:GetCoreObject()
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
    }
}

-- Enhanced district generation
local function GenerateDistrictLocations()
    local districts = {}
    local cityCenter = vector3(0.0, 0.0, 0.0) -- Replace with your city center
    local radius = 1000.0 -- Adjust based on your map size
    local numDistricts = 10 -- Adjust number of districts

    -- District types and their probabilities
    local districtTypes = {
        { type = "residential", weight = 0.4 },
        { type = "commercial", weight = 0.3 },
        { type = "industrial", weight = 0.2 },
        { type = "special", weight = 0.1 }
    }

    for i = 1, numDistricts do
        local angle = (i / numDistricts) * 2 * math.pi
        local distance = radius * math.sqrt(math.random())
        local x = cityCenter.x + distance * math.cos(angle)
        local y = cityCenter.y + distance * math.sin(angle)
        local z = cityCenter.z

        -- Find ground Z
        local ground, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
        if ground then
            -- Select district type based on weights
            local typeRoll = math.random()
            local currentWeight = 0
            local selectedType = "residential"
            
            for _, typeInfo in ipairs(districtTypes) do
                currentWeight = currentWeight + typeInfo.weight
                if typeRoll <= currentWeight then
                    selectedType = typeInfo.type
                    break
                end
            end

            -- Generate district properties
            local population = math.random(100, 1000)
            local income = math.random(1000, 10000)
            local defense = math.random(1, 100)
            local resources = {
                money = math.random(1000, 10000),
                materials = math.random(100, 1000),
                influence = math.random(1, 100)
            }

            districts[i] = {
                id = i,
                name = "District " .. i,
                type = selectedType,
                center = vector3(x, y, groundZ),
                radius = 100.0, -- Adjust district size
                color = Config.blipSettings.categories[selectedType].color,
                population = population,
                income = income,
                defense = defense,
                resources = resources,
                control = "neutral",
                events = {},
                upgrades = {},
                lastUpdate = os.time()
            }
        end
    end

    return districts
end

-- Enhanced blip creation
local function CreateDistrictBlips()
    for id, district in pairs(Config.Districts) do
        local blip = AddBlipForCoord(district.center.x, district.center.y, district.center.z)
        local category = Config.blipSettings.categories[district.type]
        
        SetBlipSprite(blip, category.sprite)
        SetBlipDisplay(blip, Config.blipSettings.display)
        SetBlipScale(blip, Config.blipSettings.scale)
        SetBlipColour(blip, category.color)
        SetBlipAsShortRange(blip, Config.blipSettings.shortRange)
        
        -- Add blip category
        SetBlipCategory(blip, 7) -- Custom category for districts
        
        -- Add blip name
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(district.name)
        EndTextCommandSetBlipName(blip)
        
        -- Add blip description
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(string.format(
            "Type: %s\nPopulation: %d\nIncome: $%d\nDefense: %d",
            district.type,
            district.population,
            district.income,
            district.defense
        ))
        EndTextCommandSetBlipName(blip)
        
        districtBlips[id] = blip
    end
end

-- Enhanced marker creation
local function CreateDistrictMarkers()
    for id, district in pairs(Config.Districts) do
        districtMarkers[id] = {
            coords = district.center,
            radius = district.radius,
            color = district.color or Config.markerSettings.color,
            pulse = Config.markerSettings.pulse,
            pulseSpeed = Config.markerSettings.pulseSpeed,
            alpha = Config.markerSettings.color.a
        }
    end
end

-- Enhanced zone creation
local function CreateDistrictZones()
    for id, district in pairs(Config.Districts) do
        districtZones[id] = {
            coords = district.center,
            radius = district.radius,
            type = "capture", -- Default zone type
            color = Config.zoneSettings.types.capture.color,
            active = false,
            progress = 0,
            startTime = 0,
            endTime = 0
        }
    end
end

-- Enhanced district update
local function UpdateDistrict(id, data)
    if not Config.Districts[id] then return end
    
    Config.Districts[id] = {
        ...Config.Districts[id],
        ...data,
        lastUpdate = os.time()
    }
    
    -- Update blip
    if districtBlips[id] then
        local district = Config.Districts[id]
        local category = Config.blipSettings.categories[district.type]
        SetBlipColour(districtBlips[id], category.color)
        
        -- Update blip description
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(string.format(
            "Type: %s\nPopulation: %d\nIncome: $%d\nDefense: %d",
            district.type,
            district.population,
            district.income,
            district.defense
        ))
        EndTextCommandSetBlipName(districtBlips[id])
    end
    
    -- Update marker
    if districtMarkers[id] then
        districtMarkers[id].color = Config.Districts[id].color
    end
    
    -- Update zone
    if districtZones[id] then
        districtZones[id].type = data.zoneType or districtZones[id].type
        districtZones[id].color = Config.zoneSettings.types[districtZones[id].type].color
    end
    
    -- Notify UI
    SendNUIMessage({
        action = 'updateDistrict',
        district = Config.Districts[id]
    })
end

-- Enhanced marker drawing
local function DrawDistrictMarkers()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local time = GetGameTimer() / 1000

    for id, marker in pairs(districtMarkers) do
        if #(coords - marker.coords) <= Config.markerSettings.drawDistance then
            -- Calculate pulse effect
            local alpha = marker.color.a
            if marker.pulse then
                alpha = marker.color.a * (0.5 + 0.5 * math.sin(time * marker.pulseSpeed))
            end

            DrawMarker(
                Config.markerSettings.type,
                marker.coords.x, marker.coords.y, marker.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                marker.radius, marker.radius, 1.0,
                marker.color.r, marker.color.g, marker.color.b, alpha,
                Config.markerSettings.bobUpAndDown,
                Config.markerSettings.faceCamera,
                2,
                Config.markerSettings.rotate,
                nil, nil, false
            )
        end
    end
end

-- Enhanced zone drawing
local function DrawDistrictZones()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    for id, zone in pairs(districtZones) do
        if zone.active and #(coords - zone.coords) <= Config.markerSettings.drawDistance then
            -- Draw zone boundary
            DrawMarker(
                1, -- Cylinder type
                zone.coords.x, zone.coords.y, zone.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                zone.radius, zone.radius, 1.0,
                zone.color.r, zone.color.g, zone.color.b, zone.color.a,
                false, false, 2, false, nil, nil, false
            )

            -- Draw progress indicator if zone is active
            if zone.progress > 0 then
                local progressRadius = zone.radius * (zone.progress / 100)
                DrawMarker(
                    1,
                    zone.coords.x, zone.coords.y, zone.coords.z - 0.5,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    progressRadius, progressRadius, 1.0,
                    255, 255, 255, 100,
                    false, false, 2, false, nil, nil, false
                )
            end
        end
    end
end

-- Enhanced district check
local function IsPlayerInDistrict(coords, district)
    local distance = #(vector3(coords.x, coords.y, coords.z) - vector3(district.center.x, district.center.y, district.center.z))
    return distance <= district.radius
end

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

-- Enhanced map control functions
local function ToggleMapControls(show)
    if show then
        -- Enable map controls
        SetNuiFocus(true, true)
        isMapOpen = true
        
        -- Show UI
        SendNUIMessage({
            action = 'showMap',
            districts = Config.Districts,
            currentDistrict = currentDistrict,
            waypoint = activeWaypoint
        })
    else
        -- Disable map controls
        SetNuiFocus(false, false)
        isMapOpen = false
        
        -- Hide UI
        SendNUIMessage({
            action = 'hideMap'
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
                TriggerEvent('QBCore:Notify', 'Destination reached!', 'success')
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
        TriggerEvent('QBCore:Notify', 'Entered ' .. district.name, 'success')
        
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
    end
end)

RegisterNetEvent('district:exit')
AddEventHandler('district:exit', function(districtId)
    local district = Config.Districts[districtId]
    if district then
        isInDistrict = false
        TriggerEvent('QBCore:Notify', 'Left ' .. district.name, 'info')
        
        -- Update UI
        SendNUIMessage({
            action = 'updateCurrentDistrict',
            district = nil
        })
    end
end)

-- NUI Callbacks
RegisterNUICallback('getDistricts', function(data, cb)
    cb(Config.Districts)
end)

RegisterNUICallback('setDistrictBlip', function(data, cb)
    if districtBlips[data.districtId] then
        SetBlipColour(districtBlips[data.districtId], data.color)
        cb('ok')
    else
        cb('error')
    end
end)

RegisterNUICallback('startZoneEvent', function(data, cb)
    if districtZones[data.districtId] then
        districtZones[data.districtId].active = true
        districtZones[data.districtId].type = data.zoneType
        districtZones[data.districtId].color = Config.zoneSettings.types[data.zoneType].color
        districtZones[data.districtId].startTime = GetGameTimer()
        districtZones[data.districtId].endTime = GetGameTimer() + (data.duration * 1000)
        districtZones[data.districtId].progress = 0
        cb('ok')
    else
        cb('error')
    end
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
    Config.minimapSettings.enabled = data.enabled
    ToggleMinimap(data.enabled)
    cb('ok')
end)

RegisterNUICallback('toggleNavigation', function(data, cb)
    Config.navigationSettings.enabled = data.enabled
    if not data.enabled then
        ClearWaypoint()
    end
    cb('ok')
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

    while true do
        Wait(0)
        UpdateCurrentDistrict()
        
        if Config.Settings.ShowMarkers then
            DrawDistrictMarkers()
        end
        
        if Config.Settings.ShowZones then
            DrawDistrictZones()
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