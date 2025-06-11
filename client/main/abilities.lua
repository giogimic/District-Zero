-- client/abilities.lua
-- Handles faction-specific abilities and their cooldowns

local activeAbilities = {}
local abilityCooldowns = {}
local abilities = {}
local cooldowns = {}
local isUIOpen = false

-- Initialize abilities
function InitializeAbilities()
    local playerFaction = Utils.GetPlayerFaction()
    if not playerFaction then return end

    local factionConfig = Config.Factions[playerFaction]
    if not factionConfig or not factionConfig.abilities then return end

    -- Reset cooldowns
    for _, ability in ipairs(factionConfig.abilities) do
        abilityCooldowns[ability.name] = 0
    end
end

-- Check if ability is available
function IsAbilityAvailable(abilityName)
    local playerFaction = Utils.GetPlayerFaction()
    if not playerFaction then return false end

    local factionConfig = Config.Factions[playerFaction]
    if not factionConfig or not factionConfig.abilities then return false end

    -- Find ability
    local ability = nil
    for _, ab in ipairs(factionConfig.abilities) do
        if ab.name == abilityName then
            ability = ab
            break
        end
    end

    if not ability then return false end

    -- Check rank requirement
    local playerRank = Utils.GetPlayerRank()
    if not playerRank or playerRank.level < ability.rankRequired then
        return false
    end

    -- Check cooldown
    if abilityCooldowns[abilityName] > GetGameTimer() then
        return false
    end

    return true
end

-- Use ability
function UseAbility(abilityName)
    if not IsAbilityAvailable(abilityName) then
        Utils.SendNotification("error", "Ability not available!")
        return false
    end

    local playerFaction = Utils.GetPlayerFaction()
    local factionConfig = Config.Factions[playerFaction]
    local ability = nil

    for _, ab in ipairs(factionConfig.abilities) do
        if ab.name == abilityName then
            ability = ab
            break
        end
    end

    if not ability then return false end

    -- Set cooldown
    abilityCooldowns[abilityName] = GetGameTimer() + (ability.cooldown * 1000)

    -- Execute ability
    local success = ExecuteAbility(ability)
    if success then
        Utils.SendNotification("success", "Ability used: " .. ability.label)
    end

    return success
end

-- Execute specific ability
function ExecuteAbility(ability)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    if ability.name == "backup" then
        -- Request police backup
        local backupBlip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
        SetBlipSprite(backupBlip, 1)
        SetBlipColour(backupBlip, 3)
        SetBlipScale(backupBlip, 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Backup Requested")
        EndTextCommandSetBlipName(backupBlip)
        
        -- Notify nearby officers
        Utils.TriggerServerEvent("notifyBackup", playerCoords)
        return true

    elseif ability.name == "spike_strip" then
        -- Deploy spike strip
        local forward = GetEntityForwardVector(playerPed)
        local spawnCoords = vector3(
            playerCoords.x + (forward.x * 5.0),
            playerCoords.y + (forward.y * 5.0),
            playerCoords.z
        )
        
        -- Create spike strip object
        local spikeStrip = CreateObject(GetHashKey("p_ld_stinger_s"), spawnCoords.x, spawnCoords.y, spawnCoords.z, true, true, true)
        SetEntityHeading(spikeStrip, GetEntityHeading(playerPed))
        PlaceObjectOnGroundProperly(spikeStrip)
        
        -- Remove after 30 seconds
        SetTimeout(30000, function()
            DeleteObject(spikeStrip)
        end)
        return true

    elseif ability.name == "police_scanner" then
        -- Scan for criminal activity
        local criminals = GetNearbyPlayers(50.0)
        for _, criminal in ipairs(criminals) do
            if IsPlayerWanted(criminal) then
                local criminalCoords = GetEntityCoords(GetPlayerPed(criminal))
                local blip = AddBlipForCoord(criminalCoords.x, criminalCoords.y, criminalCoords.z)
                SetBlipSprite(blip, 1)
                SetBlipColour(blip, 1)
                SetBlipScale(blip, 1.0)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Criminal Detected")
                EndTextCommandSetBlipName(blip)
                
                -- Remove blip after 30 seconds
                SetTimeout(30000, function()
                    RemoveBlip(blip)
                end)
            end
        end
        return true

    elseif ability.name == "lockpick" then
        -- Lockpick vehicle or door
        local vehicle = GetVehiclePedIsLookingAt(playerPed, 3.0, 3.0, 3.0)
        if DoesEntityExist(vehicle) then
            -- Lockpick vehicle
            SetVehicleDoorsLocked(vehicle, 1)
            SetVehicleDoorsLockedForAllPlayers(vehicle, false)
            return true
        end
        return false

    elseif ability.name == "hack_phone" then
        -- Disable police tracking
        Utils.TriggerServerEvent("disablePoliceTracking")
        return true

    elseif ability.name == "jammer" then
        -- Jam police communications
        local jammerBlip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
        SetBlipSprite(jammerBlip, 1)
        SetBlipColour(jammerBlip, 1)
        SetBlipScale(jammerBlip, 2.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Signal Jammer Active")
        EndTextCommandSetBlipName(jammerBlip)
        
        -- Remove after 60 seconds
        SetTimeout(60000, function()
            RemoveBlip(jammerBlip)
        end)
        return true
    end

    return false
end

-- Helper Functions
function GetNearbyPlayers(radius)
    local players = {}
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)
            if distance <= radius then
                table.insert(players, player)
            end
        end
    end

    return players
end

function IsPlayerWanted(player)
    -- Check if player has a wanted level
    return GetPlayerWantedLevel(player) > 0
end

-- Register keybinds
RegisterCommand('use_ability_1', function()
    local playerFaction = Utils.GetPlayerFaction()
    if not playerFaction then return end

    local factionConfig = Config.Factions[playerFaction]
    if not factionConfig or not factionConfig.abilities then return end

    local ability = factionConfig.abilities[1]
    if ability then
        UseAbility(ability.name)
    end
end, false)

RegisterCommand('use_ability_2', function()
    local playerFaction = Utils.GetPlayerFaction()
    if not playerFaction then return end

    local factionConfig = Config.Factions[playerFaction]
    if not factionConfig or not factionConfig.abilities then return end

    local ability = factionConfig.abilities[2]
    if ability then
        UseAbility(ability.name)
    end
end, false)

RegisterCommand('use_ability_3', function()
    local playerFaction = Utils.GetPlayerFaction()
    if not playerFaction then return end

    local factionConfig = Config.Factions[playerFaction]
    if not factionConfig or not factionConfig.abilities then return end

    local ability = factionConfig.abilities[3]
    if ability then
        UseAbility(ability.name)
    end
end, false)

-- Register keybinds
RegisterKeyMapping('use_ability_1', 'Use Ability 1', 'keyboard', '1')
RegisterKeyMapping('use_ability_2', 'Use Ability 2', 'keyboard', '2')
RegisterKeyMapping('use_ability_3', 'Use Ability 3', 'keyboard', '3')

-- Initialize abilities when player loads
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    InitializeAbilities()
end)

-- Update ability cooldowns
CreateThread(function()
    while true do
        Wait(1000)
        local currentTime = GetGameTimer()
        
        for abilityName, cooldown in pairs(abilityCooldowns) do
            if cooldown > currentTime then
                -- Update UI with remaining cooldown
                local remaining = math.ceil((cooldown - currentTime) / 1000)
                SendNUIMessage({
                    type = "updateAbilityCooldown",
                    ability = abilityName,
                    remaining = remaining
                })
            else
                abilityCooldowns[abilityName] = 0
                SendNUIMessage({
                    type = "updateAbilityCooldown",
                    ability = abilityName,
                    remaining = 0
                })
            end
        end
    end
end)

-- Initialize abilities
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 288) then -- F1
            TriggerAbility('backup')
        elseif IsControlJustPressed(0, 289) then -- F2
            TriggerAbility('tracking')
        elseif IsControlJustPressed(0, 170) then -- F3
            TriggerAbility('jammer')
        end
    end
end)

-- Register NUI callback for ability triggers
RegisterNUICallback('triggerAbility', function(data, cb)
    TriggerAbility(data.abilityId)
    cb('ok')
end)

-- Trigger an ability
function TriggerAbility(abilityId)
    if not abilities[abilityId] then return end
    if cooldowns[abilityId] and cooldowns[abilityId] > GetGameTimer() then return end

    local ability = abilities[abilityId]
    if not ability.enabled then return end

    -- Trigger server event
    TriggerServerEvent('faction:triggerAbility', abilityId)

    -- Set cooldown
    cooldowns[abilityId] = GetGameTimer() + (ability.cooldown * 1000)

    -- Update UI
    SendNUIMessage({
        type = 'updateCooldown',
        abilityId = abilityId,
        remainingTime = ability.cooldown * 1000,
        totalTime = ability.cooldown * 1000
    })
end

-- Update abilities from server
RegisterNetEvent('faction:updateAbilities')
AddEventHandler('faction:updateAbilities', function(factionAbilities)
    abilities = factionAbilities
    UpdateUI()
end)

-- Update faction info
RegisterNetEvent('faction:updateInfo')
AddEventHandler('faction:updateInfo', function(faction, rank)
    SendNUIMessage({
        type = 'updateFaction',
        faction = faction,
        rank = rank
    })
end)

-- Show/hide UI
RegisterNetEvent('faction:toggleAbilitiesUI')
AddEventHandler('faction:toggleAbilitiesUI', function(show)
    isUIOpen = show
    SendNUIMessage({
        type = show and 'show' or 'hide',
        faction = {
            name = GetFactionName(),
            rank = GetFactionRank()
        },
        abilities = abilities
    })
end)

-- Update UI with current state
function UpdateUI()
    if not isUIOpen then return end

    SendNUIMessage({
        type = 'show',
        faction = {
            name = GetFactionName(),
            rank = GetFactionRank()
        },
        abilities = abilities
    })
end

-- Update cooldowns
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if isUIOpen then
            for abilityId, endTime in pairs(cooldowns) do
                local remainingTime = endTime - GetGameTimer()
                if remainingTime > 0 then
                    SendNUIMessage({
                        type = 'updateCooldown',
                        abilityId = abilityId,
                        remainingTime = remainingTime,
                        totalTime = abilities[abilityId].cooldown * 1000
                    })
                else
                    cooldowns[abilityId] = nil
                    SendNUIMessage({
                        type = 'updateCooldown',
                        abilityId = abilityId,
                        remainingTime = 0,
                        totalTime = abilities[abilityId].cooldown * 1000
                    })
                end
            end
        end
    end
end)

-- Helper functions
function GetFactionName()
    -- Implement based on your faction system
    return "Faction Name"
end

function GetFactionRank()
    -- Implement based on your faction system
    return 1
end 