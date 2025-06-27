-- QBox Framework Integration
-- Handles all QBox-specific functionality and compatibility

local QBX = nil
local QBoxIntegration = {}

-- Try to get QBox Core object with fallback support
local function GetQBoxCore()
    if QBX then return QBX end
    
    -- Try qbx_core first (QBox Framework)
    if GetResourceState('qbx_core') == 'started' then
        local success, result = pcall(function()
            return exports['qbx_core']:GetCoreObject()
        end)
        if success and result then
            QBX = result
            return QBX
        end
    end
    
    -- Try qb-core as fallback (QBCore)
    if GetResourceState('qb-core') == 'started' then
        local success, result = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if success and result then
            QBX = result
            return QBX
        end
    end
    
    return nil
end

-- QBox Core Functions
QBoxIntegration.GetPlayer = function(source)
    local core = GetQBoxCore()
    if not core then return nil end
    return core.Functions.GetPlayer(source)
end

QBoxIntegration.GetPlayerByCitizenId = function(citizenId)
    local core = GetQBoxCore()
    if not core then return nil end
    return core.Functions.GetPlayerByCitizenId(citizenId)
end

QBoxIntegration.GetPlayers = function()
    local core = GetQBoxCore()
    if not core then return {} end
    return core.Functions.GetPlayers()
end

QBoxIntegration.AddMoney = function(source, moneyType, amount, reason)
    local core = GetQBoxCore()
    if not core then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.AddMoney(moneyType, amount, reason)
    return true
end

QBoxIntegration.RemoveMoney = function(source, moneyType, amount, reason)
    local core = GetQBoxCore()
    if not core then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.RemoveMoney(moneyType, amount, reason)
    return true
end

QBoxIntegration.GetMoney = function(source, moneyType)
    local core = GetQBoxCore()
    if not core then return 0 end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return 0 end
    
    return Player.Functions.GetMoney(moneyType)
end

-- QBox Notification Functions
QBoxIntegration.Notify = function(source, message, type, duration)
    local core = GetQBoxCore()
    if not core then return false end
    
    if Config and Config.QBox and Config.QBox.useQBoxNotifications then
        core.Functions.Notify(source, message, type, duration)
    else
        -- Fallback to ox_lib notifications
        if GetResourceState('ox_lib') == 'started' then
            exports['ox_lib']:notify(source, {
                title = 'District Zero',
                description = message,
                type = type or 'inform',
                duration = duration or 5000
            })
        end
    end
    return true
end

-- QBox Inventory Functions
QBoxIntegration.AddItem = function(source, item, amount, slot, info)
    local core = GetQBoxCore()
    if not core or (Config and Config.QBox and not Config.QBox.useQBoxInventory) then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.Functions.AddItem(item, amount, slot, info)
end

QBoxIntegration.RemoveItem = function(source, item, amount, slot)
    local core = GetQBoxCore()
    if not core or (Config and Config.QBox and not Config.QBox.useQBoxInventory) then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.Functions.RemoveItem(item, amount, slot)
end

QBoxIntegration.GetItem = function(source, item)
    local core = GetQBoxCore()
    if not core or (Config and Config.QBox and not Config.QBox.useQBoxInventory) then return nil end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player.Functions.GetItemByName(item)
end

-- QBox Vehicle Functions
QBoxIntegration.AddVehicle = function(source, plate, vehicle)
    local core = GetQBoxCore()
    if not core or (Config and Config.QBox and not Config.QBox.useQBoxVehicles) then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- This would need to be implemented based on your vehicle system
    -- core.Functions.AddVehicle(source, plate, vehicle)
    return true
end

-- QBox Management Functions
QBoxIntegration.IsPlayerAdmin = function(source)
    local core = GetQBoxCore()
    if not core or (Config and Config.QBox and not Config.QBox.useQBoxManagement) then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.PlayerData.admin or Player.PlayerData.permission == 'admin'
end

QBoxIntegration.IsPlayerModerator = function(source)
    local core = GetQBoxCore()
    if not core or (Config and Config.QBox and not Config.QBox.useQBoxManagement) then return false end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return false end
    
    return Player.PlayerData.moderator or Player.PlayerData.permission == 'moderator'
end

-- QBox Database Functions
QBoxIntegration.ExecuteSql = function(query, params)
    if GetResourceState('oxmysql') == 'started' then
        return exports.oxmysql:execute(query, params)
    elseif GetResourceState('mysql-async') == 'started' then
        return exports['mysql-async']:mysql_execute(query, params)
    end
    
    return nil
end

QBoxIntegration.ExecuteSqlSync = function(query, params)
    if GetResourceState('oxmysql') == 'started' then
        return exports.oxmysql:executeSync(query, params)
    elseif GetResourceState('mysql-async') == 'started' then
        return exports['mysql-async']:mysql_execute_sync(query, params)
    end
    
    return nil
end

QBoxIntegration.Scalar = function(query, params)
    if GetResourceState('oxmysql') == 'started' then
        return exports.oxmysql:scalar(query, params)
    elseif GetResourceState('mysql-async') == 'started' then
        return exports['mysql-async']:mysql_scalar(query, params)
    end
    
    return nil
end

QBoxIntegration.ScalarSync = function(query, params)
    if GetResourceState('oxmysql') == 'started' then
        return exports.oxmysql:scalarSync(query, params)
    elseif GetResourceState('mysql-async') == 'started' then
        return exports['mysql-async']:mysql_scalar_sync(query, params)
    end
    
    return nil
end

-- QBox Utility Functions
QBoxIntegration.GetPlayerData = function(source)
    local core = GetQBoxCore()
    if not core then return nil end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player.PlayerData
end

QBoxIntegration.GetPlayerName = function(source)
    local core = GetQBoxCore()
    if not core then return 'Unknown' end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return 'Unknown' end
    
    return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
end

QBoxIntegration.GetPlayerCitizenId = function(source)
    local core = GetQBoxCore()
    if not core then return nil end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player.PlayerData.citizenid
end

QBoxIntegration.GetPlayerJob = function(source)
    local core = GetQBoxCore()
    if not core then return nil end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player.PlayerData.job
end

QBoxIntegration.GetPlayerGang = function(source)
    local core = GetQBoxCore()
    if not core then return nil end
    local Player = core.Functions.GetPlayer(source)
    if not Player then return nil end
    
    return Player.PlayerData.gang
end

-- QBox Event Functions
QBoxIntegration.TriggerClientEvent = function(eventName, source, ...)
    TriggerClientEvent(eventName, source, ...)
    return true
end

QBoxIntegration.TriggerServerEvent = function(eventName, source, ...)
    TriggerServerEvent(eventName, source, ...)
    return true
end

-- QBox Validation Functions
QBoxIntegration.IsValidPlayer = function(source)
    local core = GetQBoxCore()
    if not core then return false end
    local Player = core.Functions.GetPlayer(source)
    return Player ~= nil
end

QBoxIntegration.IsPlayerOnline = function(citizenId)
    local core = GetQBoxCore()
    if not core then return false end
    local Player = core.Functions.GetPlayerByCitizenId(citizenId)
    return Player ~= nil
end

-- QBox Framework Detection
QBoxIntegration.IsQBoxAvailable = function()
    return GetQBoxCore() ~= nil
end

QBoxIntegration.GetFrameworkVersion = function()
    local core = GetQBoxCore()
    if not core then return 'Unknown' end
    return core.Config and core.Config.Version or 'Unknown'
end

-- QBox Configuration Functions
QBoxIntegration.GetConfig = function()
    local core = GetQBoxCore()
    if not core then return {} end
    return core.Config or {}
end

QBoxIntegration.GetSharedObject = function()
    return GetQBoxCore()
end

-- Export the QBox Integration
exports('GetQBoxIntegration', function()
    return QBoxIntegration
end)

-- Return the integration object
return QBoxIntegration 