-- District Zero Security Hardening System
-- Version: 1.0.0

local SecurityHardening = {
    -- Anti-Cheat Systems
    antiCheat = {},
    
    -- Input Validation
    inputValidation = {},
    
    -- Rate Limiting
    rateLimiting = {},
    
    -- Session Management
    sessionManagement = {},
    
    -- Threat Detection
    threatDetection = {},
    
    -- Security Logging
    securityLogging = {},
    
    -- Encryption
    encryption = {},
    
    -- Access Control
    accessControl = {},
    
    -- Vulnerability Scanning
    vulnerabilityScanning = {},
    
    -- Security Metrics
    securityMetrics = {}
}

-- Anti-Cheat Systems
local function RegisterAntiCheat(name, antiCheat)
    if not name or not antiCheat then
        print('^1[District Zero] ^7Error: Invalid anti-cheat registration')
        return false
    end
    
    SecurityHardening.antiCheat[name] = {
        instance = antiCheat,
        enabled = true,
        registered = GetGameTimer(),
        detections = 0,
        lastDetection = 0
    }
    
    print('^2[District Zero] ^7Anti-cheat registered: ' .. name)
    return true
end

local function CheckAntiCheat(name, playerId, data)
    if SecurityHardening.antiCheat[name] and SecurityHardening.antiCheat[name].enabled then
        local antiCheat = SecurityHardening.antiCheat[name]
        
        local success, result = pcall(antiCheat.instance.check, data)
        if success and result then
            antiCheat.detections = antiCheat.detections + 1
            antiCheat.lastDetection = GetGameTimer()
            
            -- Log detection
            LogSecurityEvent('anti_cheat_detection', {
                playerId = playerId,
                antiCheat = name,
                data = data,
                timestamp = GetGameTimer()
            })
            
            -- Take action
            if antiCheat.instance.action then
                antiCheat.instance.action(playerId, data)
            end
            
            return true
        end
    end
    return false
end

-- Input Validation
local function RegisterInputValidator(name, validator)
    if not name or not validator then
        print('^1[District Zero] ^7Error: Invalid input validator registration')
        return false
    end
    
    SecurityHardening.inputValidation[name] = {
        instance = validator,
        enabled = true,
        registered = GetGameTimer(),
        validations = 0,
        failures = 0
    }
    
    print('^2[District Zero] ^7Input validator registered: ' .. name)
    return true
end

local function ValidateInput(name, input)
    if SecurityHardening.inputValidation[name] and SecurityHardening.inputValidation[name].enabled then
        local validator = SecurityHardening.inputValidation[name]
        validator.validations = validator.validations + 1
        
        local success, result = pcall(validator.instance.validate, input)
        if success and result then
            return true
        else
            validator.failures = validator.failures + 1
            
            -- Log validation failure
            LogSecurityEvent('input_validation_failure', {
                validator = name,
                input = input,
                timestamp = GetGameTimer()
            })
            
            return false
        end
    end
    return true -- Default to valid if no validator
end

-- Rate Limiting
local function RegisterRateLimiter(name, limiter)
    if not name or not limiter then
        print('^1[District Zero] ^7Error: Invalid rate limiter registration')
        return false
    end
    
    SecurityHardening.rateLimiting[name] = {
        instance = limiter,
        enabled = true,
        registered = GetGameTimer(),
        requests = {},
        blocks = 0
    }
    
    print('^2[District Zero] ^7Rate limiter registered: ' .. name)
    return true
end

local function CheckRateLimit(name, identifier)
    if SecurityHardening.rateLimiting[name] and SecurityHardening.rateLimiting[name].enabled then
        local limiter = SecurityHardening.rateLimiting[name]
        local currentTime = GetGameTimer()
        
        -- Initialize request tracking for this identifier
        if not limiter.requests[identifier] then
            limiter.requests[identifier] = {
                count = 0,
                lastRequest = 0,
                blocked = false
            }
        end
        
        local requests = limiter.requests[identifier]
        
        -- Check if still blocked
        if requests.blocked then
            if currentTime - requests.lastRequest >= limiter.instance.blockDuration then
                requests.blocked = false
                requests.count = 0
            else
                return false
            end
        end
        
        -- Check rate limit
        if currentTime - requests.lastRequest >= limiter.instance.window then
            requests.count = 1
        else
            requests.count = requests.count + 1
        end
        
        requests.lastRequest = currentTime
        
        if requests.count > limiter.instance.maxRequests then
            requests.blocked = true
            limiter.blocks = limiter.blocks + 1
            
            -- Log rate limit violation
            LogSecurityEvent('rate_limit_violation', {
                limiter = name,
                identifier = identifier,
                count = requests.count,
                timestamp = currentTime
            })
            
            return false
        end
        
        return true
    end
    return true -- Default to allowed if no limiter
end

-- Session Management
local function CreateSession(playerId, data)
    local sessionId = playerId .. '_' .. GetGameTimer()
    local session = {
        id = sessionId,
        playerId = playerId,
        data = data,
        created = GetGameTimer(),
        lastActivity = GetGameTimer(),
        active = true
    }
    
    SecurityHardening.sessionManagement[sessionId] = session
    return sessionId
end

local function ValidateSession(sessionId)
    local session = SecurityHardening.sessionManagement[sessionId]
    if not session then
        return false
    end
    
    local currentTime = GetGameTimer()
    local sessionTimeout = 3600000 -- 1 hour
    
    if currentTime - session.lastActivity > sessionTimeout then
        session.active = false
        return false
    end
    
    session.lastActivity = currentTime
    return true
end

local function DestroySession(sessionId)
    SecurityHardening.sessionManagement[sessionId] = nil
end

-- Threat Detection
local function RegisterThreatDetector(name, detector)
    if not name or not detector then
        print('^1[District Zero] ^7Error: Invalid threat detector registration')
        return false
    end
    
    SecurityHardening.threatDetection[name] = {
        instance = detector,
        enabled = true,
        registered = GetGameTimer(),
        threats = 0,
        lastThreat = 0
    }
    
    print('^2[District Zero] ^7Threat detector registered: ' .. name)
    return true
end

local function DetectThreat(name, data)
    if SecurityHardening.threatDetection[name] and SecurityHardening.threatDetection[name].enabled then
        local detector = SecurityHardening.threatDetection[name]
        
        local success, result = pcall(detector.instance.detect, data)
        if success and result then
            detector.threats = detector.threats + 1
            detector.lastThreat = GetGameTimer()
            
            -- Log threat detection
            LogSecurityEvent('threat_detected', {
                detector = name,
                data = data,
                timestamp = GetGameTimer()
            })
            
            -- Take action
            if detector.instance.action then
                detector.instance.action(data)
            end
            
            return true
        end
    end
    return false
end

-- Security Logging
local function LogSecurityEvent(eventType, data)
    local logEntry = {
        type = eventType,
        data = data,
        timestamp = GetGameTimer(),
        serverId = GetConvar('sv_hostname', 'unknown')
    }
    
    -- Store in memory (in production, this would go to a secure log file/database)
    if not SecurityHardening.securityLogging.events then
        SecurityHardening.securityLogging.events = {}
    end
    
    table.insert(SecurityHardening.securityLogging.events, logEntry)
    
    -- Keep only last 1000 events
    if #SecurityHardening.securityLogging.events > 1000 then
        table.remove(SecurityHardening.securityLogging.events, 1)
    end
    
    -- Print to console for development
    print('^1[District Zero Security] ^7' .. eventType .. ': ' .. json.encode(data))
end

local function GetSecurityLogs(limit)
    limit = limit or 100
    local logs = SecurityHardening.securityLogging.events or {}
    local result = {}
    
    for i = #logs, math.max(1, #logs - limit + 1), -1 do
        table.insert(result, logs[i])
    end
    
    return result
end

-- Encryption
local function EncryptData(data, key)
    if not data or not key then
        return nil
    end
    
    -- Simple XOR encryption for demonstration
    -- In production, use proper encryption libraries
    local encrypted = {}
    for i = 1, #data do
        local charCode = string.byte(data, i)
        local keyChar = string.byte(key, ((i - 1) % #key) + 1)
        table.insert(encrypted, string.char(bit.bxor(charCode, keyChar)))
    end
    
    return table.concat(encrypted)
end

local function DecryptData(encryptedData, key)
    if not encryptedData or not key then
        return nil
    end
    
    -- XOR decryption (same as encryption)
    return EncryptData(encryptedData, key)
end

-- Access Control
local function RegisterAccessControl(name, accessControl)
    if not name or not accessControl then
        print('^1[District Zero] ^7Error: Invalid access control registration')
        return false
    end
    
    SecurityHardening.accessControl[name] = {
        instance = accessControl,
        enabled = true,
        registered = GetGameTimer(),
        checks = 0,
        denials = 0
    }
    
    print('^2[District Zero] ^7Access control registered: ' .. name)
    return true
end

local function CheckAccess(name, playerId, resource)
    if SecurityHardening.accessControl[name] and SecurityHardening.accessControl[name].enabled then
        local accessControl = SecurityHardening.accessControl[name]
        accessControl.checks = accessControl.checks + 1
        
        local success, result = pcall(accessControl.instance.check, playerId, resource)
        if success and result then
            return true
        else
            accessControl.denials = accessControl.denials + 1
            
            -- Log access denial
            LogSecurityEvent('access_denied', {
                accessControl = name,
                playerId = playerId,
                resource = resource,
                timestamp = GetGameTimer()
            })
            
            return false
        end
    end
    return true -- Default to allowed if no access control
end

-- Vulnerability Scanning
local function RegisterVulnerabilityScanner(name, scanner)
    if not name or not scanner then
        print('^1[District Zero] ^7Error: Invalid vulnerability scanner registration')
        return false
    end
    
    SecurityHardening.vulnerabilityScanning[name] = {
        instance = scanner,
        enabled = true,
        registered = GetGameTimer(),
        scans = 0,
        vulnerabilities = 0
    }
    
    print('^2[District Zero] ^7Vulnerability scanner registered: ' .. name)
    return true
end

local function ScanVulnerabilities(name, target)
    if SecurityHardening.vulnerabilityScanning[name] and SecurityHardening.vulnerabilityScanning[name].enabled then
        local scanner = SecurityHardening.vulnerabilityScanning[name]
        scanner.scans = scanner.scans + 1
        
        local success, result = pcall(scanner.instance.scan, target)
        if success and result then
            scanner.vulnerabilities = scanner.vulnerabilities + #result
            
            -- Log vulnerabilities
            for _, vulnerability in ipairs(result) do
                LogSecurityEvent('vulnerability_found', {
                    scanner = name,
                    target = target,
                    vulnerability = vulnerability,
                    timestamp = GetGameTimer()
                })
            end
            
            return result
        end
    end
    return {}
end

-- Security Metrics
local function GetSecurityMetrics()
    local metrics = {
        antiCheat = {},
        inputValidation = {},
        rateLimiting = {},
        threatDetection = {},
        accessControl = {},
        vulnerabilityScanning = {},
        overall = {
            totalEvents = 0,
            totalThreats = 0,
            totalViolations = 0
        }
    }
    
    -- Anti-cheat metrics
    for name, antiCheat in pairs(SecurityHardening.antiCheat) do
        metrics.antiCheat[name] = {
            detections = antiCheat.detections,
            lastDetection = antiCheat.lastDetection
        }
        metrics.overall.totalThreats = metrics.overall.totalThreats + antiCheat.detections
    end
    
    -- Input validation metrics
    for name, validator in pairs(SecurityHardening.inputValidation) do
        metrics.inputValidation[name] = {
            validations = validator.validations,
            failures = validator.failures,
            failureRate = validator.validations > 0 and (validator.failures / validator.validations) * 100 or 0
        }
        metrics.overall.totalViolations = metrics.overall.totalViolations + validator.failures
    end
    
    -- Rate limiting metrics
    for name, limiter in pairs(SecurityHardening.rateLimiting) do
        metrics.rateLimiting[name] = {
            blocks = limiter.blocks
        }
        metrics.overall.totalViolations = metrics.overall.totalViolations + limiter.blocks
    end
    
    -- Threat detection metrics
    for name, detector in pairs(SecurityHardening.threatDetection) do
        metrics.threatDetection[name] = {
            threats = detector.threats,
            lastThreat = detector.lastThreat
        }
        metrics.overall.totalThreats = metrics.overall.totalThreats + detector.threats
    end
    
    -- Access control metrics
    for name, accessControl in pairs(SecurityHardening.accessControl) do
        metrics.accessControl[name] = {
            checks = accessControl.checks,
            denials = accessControl.denials,
            denialRate = accessControl.checks > 0 and (accessControl.denials / accessControl.checks) * 100 or 0
        }
        metrics.overall.totalViolations = metrics.overall.totalViolations + accessControl.denials
    end
    
    -- Vulnerability scanning metrics
    for name, scanner in pairs(SecurityHardening.vulnerabilityScanning) do
        metrics.vulnerabilityScanning[name] = {
            scans = scanner.scans,
            vulnerabilities = scanner.vulnerabilities
        }
        metrics.overall.totalThreats = metrics.overall.totalThreats + scanner.vulnerabilities
    end
    
    -- Overall metrics
    metrics.overall.totalEvents = #(SecurityHardening.securityLogging.events or {})
    
    return metrics
end

-- Security Hardening Methods
SecurityHardening.RegisterAntiCheat = RegisterAntiCheat
SecurityHardening.CheckAntiCheat = CheckAntiCheat
SecurityHardening.RegisterInputValidator = RegisterInputValidator
SecurityHardening.ValidateInput = ValidateInput
SecurityHardening.RegisterRateLimiter = RegisterRateLimiter
SecurityHardening.CheckRateLimit = CheckRateLimit
SecurityHardening.CreateSession = CreateSession
SecurityHardening.ValidateSession = ValidateSession
SecurityHardening.DestroySession = DestroySession
SecurityHardening.RegisterThreatDetector = RegisterThreatDetector
SecurityHardening.DetectThreat = DetectThreat
SecurityHardening.LogSecurityEvent = LogSecurityEvent
SecurityHardening.GetSecurityLogs = GetSecurityLogs
SecurityHardening.EncryptData = EncryptData
SecurityHardening.DecryptData = DecryptData
SecurityHardening.RegisterAccessControl = RegisterAccessControl
SecurityHardening.CheckAccess = CheckAccess
SecurityHardening.RegisterVulnerabilityScanner = RegisterVulnerabilityScanner
SecurityHardening.ScanVulnerabilities = ScanVulnerabilities
SecurityHardening.GetSecurityMetrics = GetSecurityMetrics

-- Default Security Features
RegisterAntiCheat('speed_hack', {
    check = function(data)
        -- Check for unrealistic movement speeds
        if data.speed and data.speed > 50 then -- 50 m/s is unrealistic
            return true
        end
        return false
    end,
    action = function(playerId, data)
        print('^1[District Zero] ^7Speed hack detected for player ' .. playerId)
        -- Implement punishment (kick, ban, etc.)
    end
})

RegisterAntiCheat('teleport_hack', {
    check = function(data)
        -- Check for impossible teleportation
        if data.distance and data.time and data.distance / (data.time / 1000) > 100 then
            return true
        end
        return false
    end,
    action = function(playerId, data)
        print('^1[District Zero] ^7Teleport hack detected for player ' .. playerId)
        -- Implement punishment
    end
})

RegisterInputValidator('mission_data', {
    validate = function(input)
        -- Validate mission data structure
        if not input or type(input) ~= 'table' then
            return false
        end
        
        if not input.id or not input.title then
            return false
        end
        
        return true
    end
})

RegisterRateLimiter('mission_requests', {
    maxRequests = 10,
    window = 60000, -- 1 minute
    blockDuration = 300000 -- 5 minutes
})

RegisterThreatDetector('suspicious_activity', {
    detect = function(data)
        -- Detect suspicious patterns
        if data.frequency and data.frequency > 100 then -- 100 events per second
            return true
        end
        return false
    end,
    action = function(data)
        print('^1[District Zero] ^7Suspicious activity detected')
        -- Implement response
    end
})

RegisterAccessControl('mission_access', {
    check = function(playerId, resource)
        -- Check if player has access to mission system
        if not playerId or not resource then
            return false
        end
        
        -- Add your access control logic here
        return true
    end
})

RegisterVulnerabilityScanner('data_injection', {
    scan = function(target)
        local vulnerabilities = {}
        
        -- Check for SQL injection patterns
        if string.find(target, "';") or string.find(target, "DROP") then
            table.insert(vulnerabilities, {
                type = 'sql_injection',
                severity = 'high',
                description = 'Potential SQL injection detected'
            })
        end
        
        -- Check for XSS patterns
        if string.find(target, "<script>") or string.find(target, "javascript:") then
            table.insert(vulnerabilities, {
                type = 'xss',
                severity = 'medium',
                description = 'Potential XSS attack detected'
            })
        end
        
        return vulnerabilities
    end
})

print('^2[District Zero] ^7Security hardening system initialized')

-- Exports
exports('RegisterAntiCheat', RegisterAntiCheat)
exports('CheckAntiCheat', CheckAntiCheat)
exports('RegisterInputValidator', RegisterInputValidator)
exports('ValidateInput', ValidateInput)
exports('RegisterRateLimiter', RegisterRateLimiter)
exports('CheckRateLimit', CheckRateLimit)
exports('CreateSession', CreateSession)
exports('ValidateSession', ValidateSession)
exports('DestroySession', DestroySession)
exports('RegisterThreatDetector', RegisterThreatDetector)
exports('DetectThreat', DetectThreat)
exports('LogSecurityEvent', LogSecurityEvent)
exports('GetSecurityLogs', GetSecurityLogs)
exports('EncryptData', EncryptData)
exports('DecryptData', DecryptData)
exports('RegisterAccessControl', RegisterAccessControl)
exports('CheckAccess', CheckAccess)
exports('RegisterVulnerabilityScanner', RegisterVulnerabilityScanner)
exports('ScanVulnerabilities', ScanVulnerabilities)
exports('GetSecurityMetrics', GetSecurityMetrics)

return SecurityHardening 