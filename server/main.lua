-- server/main.lua
-- Server logic for APB systems (e.g., mission management, player data)

local QBCore = exports['qb-core']:GetCoreObject()
local activeMissions = {}
local playerData = {}

-- Initialize player data
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Initialize player data if not exists
    if not playerData[src] then
        playerData[src] = {
            faction = nil,
            xp = 0,
            level = 1,
            missions = {
                completed = 0,
                failed = 0
            }
        }
    end

    Utils.PrintDebug("Player data initialized for " .. GetPlayerName(src))
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function()
    local src = source
    playerData[src] = nil
    Utils.PrintDebug("Player data unloaded for " .. GetPlayerName(src))
end)

-- Mission Management
RegisterNetEvent('apb:server:startMission', function(missionType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Check if player is already in a mission
    if activeMissions[src] then
        Utils.TriggerClientEvent("notification", src, "error", "You are already in a mission!")
        return
    end

    -- Get player's faction
    local playerFaction = playerData[src].faction
    if not playerFaction then
        Utils.TriggerClientEvent("notification", src, "error", "You need to join a faction first!")
        return
    end

    -- Get mission data
    local missionData = GetMissionData(missionType, playerFaction)
    if not missionData then
        Utils.TriggerClientEvent("notification", src, "error", "Invalid mission type!")
        return
    end

    -- Start mission
    activeMissions[src] = {
        type = missionType,
        startTime = os.time(),
        data = missionData
    }

    -- Send mission data to client
    Utils.TriggerClientEvent("startMission", src, missionData)
    Utils.PrintDebug("Mission started for " .. GetPlayerName(src))
end)

RegisterNetEvent('apb:server:completeMission', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verify mission exists
    if not activeMissions[src] then
        Utils.TriggerClientEvent("notification", src, "error", "No active mission found!")
        return
    end

    -- Calculate rewards
    local missionData = activeMissions[src].data
    local xpReward = Utils.CalculateMissionReward(
        missionData.xpReward,
        playerData[src].level,
        Config.Rewards.xpMultiplier
    )
    local cashReward = Utils.CalculateMissionReward(
        missionData.cashReward,
        playerData[src].level,
        Config.Rewards.cashMultiplier
    )

    -- Add time bonus
    local timeBonus = data.timeBonus or 0
    cashReward = cashReward + (cashReward * (timeBonus / 100))

    -- Update player data
    playerData[src].xp = playerData[src].xp + xpReward
    playerData[src].missions.completed = playerData[src].missions.completed + 1

    -- Check for level up
    local newRank = Utils.GetFactionRank(playerData[src].faction, playerData[src].xp)
    if newRank and newRank.level > playerData[src].level then
        playerData[src].level = newRank.level
        -- Give level up bonus
        Player.Functions.AddMoney("cash", Config.Rewards.levelUpBonus.cash)
        for _, item in ipairs(Config.Rewards.levelUpBonus.items) do
            Player.Functions.AddItem(item.name, item.amount)
        end
        Utils.TriggerClientEvent("notification", src, "success", "Level up! You are now " .. newRank.label)
    end

    -- Add rewards
    Player.Functions.AddMoney("cash", cashReward)

    -- Clean up mission
    activeMissions[src] = nil

    -- Notify client
    Utils.TriggerClientEvent("notification", src, "success", 
        string.format("Mission completed! Rewards: %s XP, %s", 
            xpReward, 
            Utils.FormatMoney(cashReward)
        )
    )

    Utils.PrintDebug("Mission completed for " .. GetPlayerName(src))
end)

RegisterNetEvent('apb:server:failMission', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verify mission exists
    if not activeMissions[src] then
        Utils.TriggerClientEvent("notification", src, "error", "No active mission found!")
        return
    end

    -- Update player data
    playerData[src].missions.failed = playerData[src].missions.failed + 1

    -- Clean up mission
    activeMissions[src] = nil

    -- Notify client
    Utils.TriggerClientEvent("notification", src, "error", "Mission failed: " .. (data.reason or "Unknown reason"))

    Utils.PrintDebug("Mission failed for " .. GetPlayerName(src))
end)

-- Faction Management
RegisterNetEvent('apb:server:joinFaction', function(faction)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Verify faction exists
    if not Config.Factions[faction] then
        Utils.TriggerClientEvent("notification", src, "error", "Invalid faction!")
        return
    end

    -- Update player data
    playerData[src].faction = faction
    playerData[src].xp = 0
    playerData[src].level = 1

    -- Notify client
    Utils.TriggerClientEvent("notification", src, "success", "Joined faction: " .. Config.Factions[faction].label)
    Utils.TriggerClientEvent("updateFaction", src, {
        faction = faction,
        rank = Utils.GetFactionRank(faction, 0)
    })

    Utils.PrintDebug("Player " .. GetPlayerName(src) .. " joined faction: " .. faction)
end)

-- Helper Functions
function GetMissionData(missionType, faction)
    local missions = Config.Missions.types[faction]
    if not missions then return nil end

    for _, mission in ipairs(missions) do
        if mission.id == missionType then
            return mission
        end
    end
    return nil
end

-- Export functions
exports('GetPlayerFaction', function(playerId)
    return playerData[playerId] and playerData[playerId].faction or nil
end)

exports('GetPlayerRank', function(playerId)
    if not playerData[playerId] then return nil end
    return Utils.GetFactionRank(
        playerData[playerId].faction,
        playerData[playerId].xp
    )
end)

exports('GetPlayerData', function(playerId)
    return playerData[playerId]
end)

-- Initialize
CreateThread(function()
    Utils.PrintDebug("Server script loaded")
    -- Additional initialization code here
end)
