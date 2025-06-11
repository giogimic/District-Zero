local Bridge = {}
local isClient = IsDuplicityVersion() == false

local function Debug(msg)
    if Config.Debug then
        print('^3[district-zero]^7 ' .. msg)
    end
end 

Bridge.Debug = Debug

function Bridge.Load()
    local framework = string.lower(Config.Framework)    
    local supportedFrameworks = {
        qb = true,
        qbx = true,
    }
    if not supportedFrameworks[framework] then
        Debug('^1Unsupported framework: ' .. framework)
        return nil
    end
    local bridgePath = isClient and 'bridge/client/' .. framework or 'bridge/server/' .. framework
    local success, frameworkBridge = pcall(function()
        return require(bridgePath)
    end)
    if success then
        if frameworkBridge and frameworkBridge.Init() then
            Debug('^2Successfully loaded ' .. framework .. ' bridge for ' .. (isClient and 'client' or 'server'))
            if frameworkBridge.RegisterEvents then
                frameworkBridge.RegisterEvents()
            end
            return frameworkBridge
        else
            Debug('^1Failed to initialize ' .. framework .. ' bridge for ' .. (isClient and 'client' or 'server'))
            return nil
        end
    else
        Debug('^1Failed to load ' .. framework .. ' bridge for ' .. (isClient and 'client' or 'server'))
        return nil
    end
end

-- UI Presets for consistent styling
local UIPresets = {
    notify = {
        default = {
            backgroundColor = 'rgba(10, 25, 55, 0.65)',
            color = '#60A5FA',
            position = 'center-right',
            duration = 6000,
            icon = 'info'
        },
        error = {
            backgroundColor = 'rgba(55, 25, 25, 0.65)',
            color = '#F87171',
            position = 'center-right',
            duration = 6000,
            icon = 'xmark'
        },
        success = {
            backgroundColor = 'rgba(25, 55, 25, 0.65)',
            color = '#34D399',
            position = 'center-right',
            duration = 6000,
            icon = 'check'
        },
        info = {
            backgroundColor = 'rgba(10, 25, 55, 0.65)',
            color = '#60A5FA',
            position = 'center-right',
            duration = 6000,
            icon = 'info'
        },
        warning = {
            backgroundColor = 'rgba(55, 55, 25, 0.65)',
            color = '#FBBF24',
            position = 'center-right',
            duration = 6000,
            icon = 'exclamation'
        }
    },
    textUI = {
        default = {
            backgroundColor = 'rgba(0, 0, 0, 0.5)',
            color = '#F87171',
            icon = 'info',
            position = 'top-center'
        },
        mission = {
            backgroundColor = 'rgba(36, 68, 17, 0.5)',
            color = '#FFFFFF',
            icon = 'flag',
            position = 'top-center'
        },
        objective = {
            backgroundColor = 'rgba(44, 98, 170, 0.5)',
            color = '#FFFFFF',
            icon = 'list-check',
            position = 'top-center'
        }
    }
}

if IsDuplicityVersion() then
    Bridge.Notify = function(playerId, message, type, title)
        local msgStr = tostring(message or "")
        local notifyType = type or 'info'
        local notifyStyle = UIPresets.notify[notifyType] or UIPresets.notify.info
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = title or 'District Zero',
            description = msgStr,
            type = notifyType,
            icon = notifyStyle.icon,
            position = notifyStyle.position,
            duration = notifyStyle.duration,
            style = {
                backgroundColor = notifyStyle.backgroundColor,
                color = notifyStyle.color,
                borderRadius = 14,
                fontSize = '16px',
                fontWeight = 'bold',
                textAlign = 'left',
                padding = '14px 20px',
                border = '1px solid ' .. notifyStyle.color
            }
        })
    end
else
    Bridge.Notify = function(message, type, title)
        local msgStr = tostring(message or "")
        local notifyType = type or 'info'
        local notifyStyle = UIPresets.notify[notifyType] or UIPresets.notify.info
        lib.notify({
            title = title or 'District Zero',
            description = msgStr,
            type = notifyType,
            icon = notifyStyle.icon,
            position = notifyStyle.position,
            duration = notifyStyle.duration,
            style = {
                backgroundColor = notifyStyle.backgroundColor,
                color = notifyStyle.color,
                borderRadius = 14,
                fontSize = '16px',
                fontWeight = 'bold',
                textAlign = 'left',
                padding = '14px 20px',
                border = '1px solid ' .. notifyStyle.color
            }
        })
    end

    Bridge.ShowTextUI = function(message, type)
        local textType = type or 'default'
        local style = UIPresets.textUI[textType] or UIPresets.textUI.default
        lib.showTextUI(message, {
            position = style.position,
            icon = style.icon,
            style = {
                backgroundColor = style.backgroundColor,
                color = style.color,
                borderRadius = 14,
                fontSize = '16px',
                fontWeight = 'bold',
                textAlign = 'left',
                padding = '14px 20px',
                border = '1px solid ' .. style.color
            }
        })
    end

    Bridge.HideTextUI = function()
        lib.hideTextUI()
    end
end

return Bridge 