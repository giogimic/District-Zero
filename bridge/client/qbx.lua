local Bridge = {}
local QBX = nil

function Bridge.Init()
    QBX = exports['qb-core']:GetCoreObject()
    return true
end

function Bridge.GetPlayerData()
    return QBX.Functions.GetPlayerData()
end

function Bridge.GetClosestPlayer()
    return QBX.Functions.GetClosestPlayer()
end

function Bridge.GetClosestVehicle()
    return QBX.Functions.GetClosestVehicle()
end

function Bridge.GetClosestPed()
    return QBX.Functions.GetClosestPed()
end

function Bridge.GetClosestObject()
    return QBX.Functions.GetClosestObject()
end

function Bridge.GetClosestEntity()
    return QBX.Functions.GetClosestEntity()
end

function Bridge.GetFramework()
    return QBX
end

function Bridge.RegisterEvents()
    -- Register any framework-specific events here
end

return Bridge 