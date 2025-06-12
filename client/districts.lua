-- District Zero Districts Module
-- Version: 1.0.0

local districts = {}
local districtBlips = {}

-- Initialize districts
function InitializeDistricts()
    if not Config.Districts then return false end

    -- Create district blips and zones
    for _, district in pairs(Config.Districts) do
        -- Create blip
        local blip = AddBlipForCoord(district.blip.coords.x, district.blip.coords.y, district.blip.coords.z)
        SetBlipSprite(blip, district.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, district.blip.scale)
        SetBlipColour(blip, district.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(district.name)
        EndTextCommandSetBlipName(blip)

        -- Store blip
        districtBlips[district.id] = blip

        -- Create control point blips
        for _, point in pairs(district.controlPoints) do
            local pointBlip = AddBlipForCoord(point.coords.x, point.coords.y, point.coords.z)
            SetBlipSprite(pointBlip, 1)
            SetBlipDisplay(pointBlip, 4)
            SetBlipScale(pointBlip, 0.8)
            SetBlipColour(pointBlip, 0)
            SetBlipAsShortRange(pointBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(point.name)
            EndTextCommandSetBlipName(pointBlip)

            -- Store point blip
            if not districtBlips[district.id .. '_points'] then
                districtBlips[district.id .. '_points'] = {}
            end
            table.insert(districtBlips[district.id .. '_points'], pointBlip)
        end

        -- Store district data
        districts[district.id] = {
            id = district.id,
            name = district.name,
            description = district.description,
            blip = blip,
            zones = district.zones,
            controlPoints = district.controlPoints,
            influence = 0,
            currentTeam = 'neutral'
        }
    end

    return true
end

-- Get current district
function GetCurrentDistrict()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, district in pairs(districts) do
        for _, zone in pairs(district.zones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                return district
            end
        end
    end

    return nil
end

-- Get available missions for district
function GetAvailableMissions(districtId)
    local availableMissions = {}
    
    for _, mission in pairs(Config.Missions) do
        if mission.district == districtId then
            table.insert(availableMissions, mission)
        end
    end

    return availableMissions
end

-- Update district influence
function UpdateDistrictInfluence(districtId, influence, team)
    if not districts[districtId] then return end

    districts[districtId].influence = influence
    districts[districtId].currentTeam = team

    -- Update blip color based on team
    local blip = districtBlips[districtId]
    if blip then
        if team == 'pvp' then
            SetBlipColour(blip, 1) -- Red
        elseif team == 'pve' then
            SetBlipColour(blip, 2) -- Blue
        else
            SetBlipColour(blip, 0) -- White
        end
    end
end

-- Clear district blips
function ClearDistrictBlips()
    for _, blip in pairs(districtBlips) do
        if type(blip) == 'table' then
            for _, pointBlip in pairs(blip) do
                RemoveBlip(pointBlip)
            end
        else
            RemoveBlip(blip)
        end
    end
    districtBlips = {}
end

-- Event handlers
RegisterNetEvent('dz:client:districtUpdated', function(data)
    UpdateDistrictInfluence(data.id, data.influence, data.team)
end)

-- Export functions
exports('GetCurrentDistrict', GetCurrentDistrict)
exports('GetAvailableMissions', GetAvailableMissions) 