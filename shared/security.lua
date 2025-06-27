-- District Zero Security System
-- Version: 1.0.0

local SecuritySystem = {
    -- Rate Limiting
    rateLimits = {},
    rateLimitConfig = {
        default = { maxRequests = 10, windowMs = 60000 }, -- 10 requests per minute
        district_capture = { maxRequests = 5, windowMs = 300000 }, -- 5 captures per 5 minutes
        mission_start = { maxRequests = 3, windowMs = 600000 }, -- 3 missions per 10 minutes
        team_select = { maxRequests = 10, windowMs = 300000 }, -- 10 team changes per 5 minutes
        ui_open = { maxRequests = 20, windowMs = 60000 }, -- 20 UI opens per minute
        database_query = { maxRequests = 50, windowMs = 60000 }, -- 50 queries per minute
        performance_request = { maxRequests = 10, windowMs = 60000 } -- 10 requests per minute
    },
    
    -- Input Validation
    validationRules = {
        playerId = { type = 'number', min = 1, max = 1000 },
        districtId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
        missionId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
        teamId = { type = 'string', pattern = '^[a-zA-Z0-9_]+$', maxLength = 50 },
        coords = { type = 'table', required = { 'x', 'y', 'z' }, numberRange = { min = -10000, max = 10000 } },
        message = { type = 'string', maxLength = 500, pattern = '^[a-zA-Z0-9\\s\\.,!?-]+$' },
        duration = { type = 'number', min = 1000, max = 30000 },
        influence = { type = 'number', min = 0, max = 1000 }
    },
    
    -- Permission System
    permissions = {
        admin = {
            'dz:admin:reset',
            'dz:admin:performance',
            'dz:admin:optimize',
            'dz:admin:kick',
            'dz:admin:ban',
            'dz:admin:config'
        },
        moderator = {
            'dz:mod:kick',
            'dz:mod:warn',
            'dz:mod:reset_district',
            'dz:mod:performance'
        },
        player = {
            'dz:player:join',
            'dz:player:leave',
            'dz:district:enter',
            'dz:district:exit',
            'dz:district:capture',
            'dz:mission:start',
            'dz:mission:complete',
            'dz:team:select',
            'dz:ui:open',
            'dz:ui:close'
        }
    },
    
    -- Anti-Exploit Measures
    exploitChecks = {
        teleportDetection = true,
        speedHackDetection = true,
        weaponHackDetection = true,
        godModeDetection = true,
        invalidCoordsDetection = true,
        rapidEventDetection = true
    },
    
    -- Audit Logging
    auditLog = {},
    maxAuditLogSize = 10000,
    auditLogConfig = {
        enabled = true,
        logLevel = 'info', -- debug, info, warn, error
        logEvents = {
            'player_join',
            'player_leave',
            'district_capture',
            'mission_start',
            'mission_complete',
            'team_select',
            'admin_action',
            'security_violation',
            'exploit_detected'
        }
    },
    
    -- Blacklist System
    blacklist = {
        players = {},
        ips = {},
        patterns = {
            'script', 'inject', 'hack', 'cheat', 'exploit',
            'admin', 'mod', 'god', 'teleport', 'speed'
        }
    },
    
    -- Security Metrics
    securityMetrics = {
        violations = 0,
        blocks = 0,
        exploits = 0,
        rateLimitHits = 0,
        validationFailures = 0,
        permissionDenials = 0
    }
}

-- Rate Limiting System
local function CheckRateLimit(playerId, action)
    local config = SecuritySystem.rateLimitConfig[action] or SecuritySystem.rateLimitConfig.default
    local currentTime = GetGameTimer()
    
    if not SecuritySystem.rateLimits[playerId] then
        SecuritySystem.rateLimits[playerId] = {}
    end
    
    if not SecuritySystem.rateLimits[playerId][action] then
        SecuritySystem.rateLimits[playerId][action] = {
            requests = {},
            blocked = false,
            blockUntil = 0
        }
    end
    
    local rateLimit = SecuritySystem.rateLimits[playerId][action]
    
    -- Check if player is blocked
    if rateLimit.blocked and currentTime < rateLimit.blockUntil then
        SecuritySystem.securityMetrics.rateLimitHits = SecuritySystem.securityMetrics.rateLimitHits + 1
        return false, 'Rate limit exceeded. Try again later.'
    end
    
    -- Clean old requests
    local validRequests = {}
    for _, requestTime in ipairs(rateLimit.requests) do
        if currentTime - requestTime < config.windowMs then
            table.insert(validRequests, requestTime)
        end
    end
    rateLimit.requests = validRequests
    
    -- Check if limit exceeded
    if #rateLimit.requests >= config.maxRequests then
        rateLimit.blocked = true
        rateLimit.blockUntil = currentTime + config.windowMs
        SecuritySystem.securityMetrics.rateLimitHits = SecuritySystem.securityMetrics.rateLimitHits + 1
        
        -- Log violation
        SecuritySystem.LogAuditEvent('security_violation', {
            playerId = playerId,
            action = action,
            reason = 'rate_limit_exceeded',
            limit = config.maxRequests,
            window = config.windowMs
        })
        
        return false, 'Rate limit exceeded. Try again later.'
    end
    
    -- Add current request
    table.insert(rateLimit.requests, currentTime)
    return true, 'Request allowed'
end

-- Input Validation System
local function ValidateInput(data, rules)
    if not data or not rules then
        return false, 'Invalid validation parameters'
    end
    
    for field, rule in pairs(rules) do
        local value = data[field]
        
        -- Check if required field is present
        if rule.required and not value then
            SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
            return false, 'Required field missing: ' .. field
        end
        
        if value then
            -- Type validation
            if rule.type == 'string' and type(value) ~= 'string' then
                SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                return false, 'Invalid type for ' .. field .. ': expected string'
            elseif rule.type == 'number' and type(value) ~= 'number' then
                SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                return false, 'Invalid type for ' .. field .. ': expected number'
            elseif rule.type == 'table' and type(value) ~= 'table' then
                SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                return false, 'Invalid type for ' .. field .. ': expected table'
            end
            
            -- String validation
            if rule.type == 'string' then
                -- Length validation
                if rule.maxLength and #value > rule.maxLength then
                    SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                    return false, 'Field ' .. field .. ' too long (max: ' .. rule.maxLength .. ')'
                end
                
                -- Pattern validation
                if rule.pattern and not string.match(value, rule.pattern) then
                    SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                    return false, 'Field ' .. field .. ' contains invalid characters'
                end
                
                -- Blacklist check
                for _, pattern in ipairs(SecuritySystem.blacklist.patterns) do
                    if string.find(string.lower(value), pattern) then
                        SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                        return false, 'Field ' .. field .. ' contains blacklisted content'
                    end
                end
            end
            
            -- Number validation
            if rule.type == 'number' then
                if rule.min and value < rule.min then
                    SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                    return false, 'Field ' .. field .. ' below minimum (' .. rule.min .. ')'
                end
                if rule.max and value > rule.max then
                    SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                    return false, 'Field ' .. field .. ' above maximum (' .. rule.max .. ')'
                end
            end
            
            -- Table validation
            if rule.type == 'table' and rule.required then
                for _, requiredField in ipairs(rule.required) do
                    if not value[requiredField] then
                        SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                        return false, 'Required table field missing: ' .. requiredField
                    end
                end
                
                -- Number range validation for coordinates
                if rule.numberRange then
                    for _, coord in ipairs({ 'x', 'y', 'z' }) do
                        if value[coord] and (value[coord] < rule.numberRange.min or value[coord] > rule.numberRange.max) then
                            SecuritySystem.securityMetrics.validationFailures = SecuritySystem.securityMetrics.validationFailures + 1
                            return false, 'Invalid coordinate value for ' .. coord
                        end
                    end
                end
            end
        end
    end
    
    return true, 'Validation passed'
end

-- Permission System
local function CheckPermission(playerId, permission)
    -- Check if player is blacklisted
    if SecuritySystem.blacklist.players[playerId] then
        SecuritySystem.securityMetrics.permissionDenials = SecuritySystem.securityMetrics.permissionDenials + 1
        return false, 'Player is blacklisted'
    end
    
    -- Check admin permissions (console)
    if playerId == 0 then
        for _, adminPerm in ipairs(SecuritySystem.permissions.admin) do
            if permission == adminPerm then
                return true, 'Admin permission granted'
            end
        end
    end
    
    -- Check player permissions (default for all players)
    for _, playerPerm in ipairs(SecuritySystem.permissions.player) do
        if permission == playerPerm then
            return true, 'Player permission granted'
        end
    end
    
    SecuritySystem.securityMetrics.permissionDenials = SecuritySystem.securityMetrics.permissionDenials + 1
    return false, 'Permission denied'
end

-- Anti-Exploit Detection
local function DetectExploits(playerId, data)
    local violations = {}
    
    -- Teleport detection
    if SecuritySystem.exploitChecks.teleportDetection and data.coords then
        local player = GetPlayerPed(playerId)
        if player and player ~= 0 then
            local currentCoords = GetEntityCoords(player)
            local distance = #(currentCoords - vector3(data.coords.x, data.coords.y, data.coords.z))
            
            if distance > 1000 then -- More than 1000 units in one update
                table.insert(violations, {
                    type = 'teleport_detected',
                    distance = distance,
                    coords = data.coords
                })
            end
        end
    end
    
    -- Invalid coordinates detection
    if SecuritySystem.exploitChecks.invalidCoordsDetection and data.coords then
        for coord, value in pairs(data.coords) do
            if type(value) == 'number' and (value < -10000 or value > 10000) then
                table.insert(violations, {
                    type = 'invalid_coordinates',
                    coord = coord,
                    value = value
                })
            end
        end
    end
    
    -- Rapid event detection
    if SecuritySystem.exploitChecks.rapidEventDetection then
        local currentTime = GetGameTimer()
        if not SecuritySystem.rateLimits[playerId] then
            SecuritySystem.rateLimits[playerId] = {}
        end
        
        if not SecuritySystem.rateLimits[playerId].rapid_events then
            SecuritySystem.rateLimits[playerId].rapid_events = {
                count = 0,
                lastReset = currentTime
            }
        end
        
        local rapidEvents = SecuritySystem.rateLimits[playerId].rapid_events
        
        -- Reset counter every second
        if currentTime - rapidEvents.lastReset > 1000 then
            rapidEvents.count = 0
            rapidEvents.lastReset = currentTime
        end
        
        rapidEvents.count = rapidEvents.count + 1
        
        if rapidEvents.count > 50 then -- More than 50 events per second
            table.insert(violations, {
                type = 'rapid_events',
                count = rapidEvents.count
            })
        end
    end
    
    return violations
end

-- Audit Logging System
local function LogAuditEvent(eventType, data)
    if not SecuritySystem.auditLogConfig.enabled then
        return
    end
    
    -- Check if event type should be logged
    local shouldLog = false
    for _, logEvent in ipairs(SecuritySystem.auditLogConfig.logEvents) do
        if eventType == logEvent then
            shouldLog = true
            break
        end
    end
    
    if not shouldLog then
        return
    end
    
    local logEntry = {
        timestamp = GetGameTimer(),
        eventType = eventType,
        data = data,
        level = SecuritySystem.auditLogConfig.logLevel
    }
    
    table.insert(SecuritySystem.auditLog, logEntry)
    
    -- Maintain log size
    if #SecuritySystem.auditLog > SecuritySystem.maxAuditLogSize then
        table.remove(SecuritySystem.auditLog, 1)
    end
    
    -- Print to console for important events
    if eventType == 'security_violation' or eventType == 'exploit_detected' then
        print('^1[District Zero Security] ^7' .. eventType .. ': ' .. json.encode(data))
    end
end

-- Blacklist Management
local function AddToBlacklist(playerId, reason)
    SecuritySystem.blacklist.players[playerId] = {
        reason = reason,
        timestamp = GetGameTimer(),
        admin = 'system'
    }
    
    LogAuditEvent('player_blacklisted', {
        playerId = playerId,
        reason = reason
    })
end

local function RemoveFromBlacklist(playerId)
    SecuritySystem.blacklist.players[playerId] = nil
    
    LogAuditEvent('player_unblacklisted', {
        playerId = playerId
    })
end

-- Security Metrics
local function GetSecurityMetrics()
    return SecuritySystem.securityMetrics
end

local function ResetSecurityMetrics()
    SecuritySystem.securityMetrics = {
        violations = 0,
        blocks = 0,
        exploits = 0,
        rateLimitHits = 0,
        validationFailures = 0,
        permissionDenials = 0
    }
end

-- Main Security Functions
local function SecureEvent(playerId, eventName, data, validationRules)
    -- Check rate limit
    local rateLimitOk, rateLimitMsg = CheckRateLimit(playerId, eventName)
    if not rateLimitOk then
        return false, rateLimitMsg
    end
    
    -- Check permission
    local permissionOk, permissionMsg = CheckPermission(playerId, eventName)
    if not permissionOk then
        return false, permissionMsg
    end
    
    -- Validate input
    if validationRules then
        local validationOk, validationMsg = ValidateInput(data, validationRules)
        if not validationOk then
            return false, validationMsg
        end
    end
    
    -- Detect exploits
    local violations = DetectExploits(playerId, data)
    if #violations > 0 then
        SecuritySystem.securityMetrics.exploits = SecuritySystem.securityMetrics.exploits + 1
        
        LogAuditEvent('exploit_detected', {
            playerId = playerId,
            eventName = eventName,
            violations = violations
        })
        
        -- Add to blacklist for severe violations
        for _, violation in ipairs(violations) do
            if violation.type == 'teleport_detected' or violation.type == 'rapid_events' then
                AddToBlacklist(playerId, violation.type)
                return false, 'Exploit detected: ' .. violation.type
            end
        end
        
        return false, 'Suspicious activity detected'
    end
    
    -- Log successful event
    LogAuditEvent('event_processed', {
        playerId = playerId,
        eventName = eventName,
        data = data
    })
    
    return true, 'Event processed successfully'
end

-- Security System Methods
SecuritySystem.CheckRateLimit = CheckRateLimit
SecuritySystem.ValidateInput = ValidateInput
SecuritySystem.CheckPermission = CheckPermission
SecuritySystem.DetectExploits = DetectExploits
SecuritySystem.LogAuditEvent = LogAuditEvent
SecuritySystem.AddToBlacklist = AddToBlacklist
SecuritySystem.RemoveFromBlacklist = RemoveFromBlacklist
SecuritySystem.GetSecurityMetrics = GetSecurityMetrics
SecuritySystem.ResetSecurityMetrics = ResetSecurityMetrics
SecuritySystem.SecureEvent = SecureEvent

-- Cleanup Thread
CreateThread(function()
    while true do
        Wait(300000) -- Every 5 minutes
        
        -- Clean up old rate limits
        local currentTime = GetGameTimer()
        for playerId, limits in pairs(SecuritySystem.rateLimits) do
            for action, limit in pairs(limits) do
                if limit.blocked and currentTime > limit.blockUntil then
                    limit.blocked = false
                    limit.blockUntil = 0
                end
            end
        end
        
        -- Log security metrics
        local metrics = GetSecurityMetrics()
        if metrics.violations > 0 or metrics.exploits > 0 then
            print('^3[District Zero Security] ^7Metrics: ' .. json.encode(metrics))
        end
    end
end)

-- Exports
exports('CheckRateLimit', CheckRateLimit)
exports('ValidateInput', ValidateInput)
exports('CheckPermission', CheckPermission)
exports('DetectExploits', DetectExploits)
exports('LogAuditEvent', LogAuditEvent)
exports('AddToBlacklist', AddToBlacklist)
exports('RemoveFromBlacklist', RemoveFromBlacklist)
exports('GetSecurityMetrics', GetSecurityMetrics)
exports('ResetSecurityMetrics', ResetSecurityMetrics)
exports('SecureEvent', SecureEvent)

return SecuritySystem 