-- District Zero Error Handler
local Utils = require 'shared/utils'

-- Error Types
local ErrorTypes = {
    VALIDATION = 'VALIDATION',
    DATABASE = 'DATABASE',
    NETWORK = 'NETWORK',
    PERMISSION = 'PERMISSION',
    STATE = 'STATE',
    UNKNOWN = 'UNKNOWN'
}

-- Error Handler
local function HandleError(error, type, context)
    type = type or ErrorTypes.UNKNOWN
    context = context or 'Unknown'
    
    -- Log error
    print(string.format('[District Zero] [%s] [%s] %s', type, context, error))
    
    -- Notify client if applicable
    if IsDuplicityVersion() then
        TriggerClientEvent('dz:error:notify', -1, {
            type = type,
            message = error,
            context = context
        })
    end
    
    -- Return error for handling
    return {
        type = type,
        message = error,
        context = context
    }
end

-- Validation
local function ValidateInput(input, rules)
    if not input then
        return HandleError('Input is required', ErrorTypes.VALIDATION, 'ValidateInput')
    end
    
    if not rules then
        return HandleError('Validation rules are required', ErrorTypes.VALIDATION, 'ValidateInput')
    end
    
    local errors = {}
    
    for field, rule in pairs(rules) do
        if rule.required and not input[field] then
            table.insert(errors, string.format('%s is required', field))
        end
        
        if input[field] and rule.type and type(input[field]) ~= rule.type then
            table.insert(errors, string.format('%s must be of type %s', field, rule.type))
        end
        
        if input[field] and rule.min and input[field] < rule.min then
            table.insert(errors, string.format('%s must be at least %s', field, rule.min))
        end
        
        if input[field] and rule.max and input[field] > rule.max then
            table.insert(errors, string.format('%s must be at most %s', field, rule.max))
        end
        
        if input[field] and rule.pattern and not string.match(input[field], rule.pattern) then
            table.insert(errors, string.format('%s must match pattern %s', field, rule.pattern))
        end
    end
    
    if #errors > 0 then
        return HandleError(table.concat(errors, ', '), ErrorTypes.VALIDATION, 'ValidateInput')
    end
    
    return nil
end

-- Permission Check
local function CheckPermission(source, permission)
    if not source then
        return HandleError('Source is required', ErrorTypes.PERMISSION, 'CheckPermission')
    end
    
    if not permission then
        return HandleError('Permission is required', ErrorTypes.PERMISSION, 'CheckPermission')
    end
    
    -- Check if player has permission
    local hasPermission = false
    
    if IsDuplicityVersion() then
        local Player = QBX.Functions.GetPlayer(source)
        if Player then
            hasPermission = Player.PlayerData.permission == permission
        end
    else
        local PlayerData = QBX.Functions.GetPlayerData()
        hasPermission = PlayerData.permission == permission
    end
    
    if not hasPermission then
        return HandleError('Permission denied', ErrorTypes.PERMISSION, 'CheckPermission')
    end
    
    return nil
end

-- State Validation
local function ValidateState(state, required)
    if not state then
        return HandleError('State is required', ErrorTypes.STATE, 'ValidateState')
    end
    
    if not required then
        return HandleError('Required fields are required', ErrorTypes.STATE, 'ValidateState')
    end
    
    local errors = {}
    
    for _, field in ipairs(required) do
        if not state[field] then
            table.insert(errors, string.format('%s is required', field))
        end
    end
    
    if #errors > 0 then
        return HandleError(table.concat(errors, ', '), ErrorTypes.STATE, 'ValidateState')
    end
    
    return nil
end

-- Exports
exports('HandleError', HandleError)
exports('ValidateInput', ValidateInput)
exports('CheckPermission', CheckPermission)
exports('ValidateState', ValidateState)

-- Error Documentation
--[[
Error Documentation:

Error Types:
- VALIDATION: Input validation errors
- DATABASE: Database operation errors
- NETWORK: Network communication errors
- PERMISSION: Permission check errors
- STATE: State validation errors
- UNKNOWN: Unknown errors

Usage:
- Handle error: exports['district_zero']:HandleError(error, type, context)
- Validate input: exports['district_zero']:ValidateInput(input, rules)
- Check permission: exports['district_zero']:CheckPermission(source, permission)
- Validate state: exports['district_zero']:ValidateState(state, required)

Examples:
- Handle error:
  exports['district_zero']:HandleError('Invalid input', 'VALIDATION', 'ValidateInput')

- Validate input:
  exports['district_zero']:ValidateInput(input, {
    name = { required = true, type = 'string' },
    age = { required = true, type = 'number', min = 0, max = 100 }
  })

- Check permission:
  exports['district_zero']:CheckPermission(source, 'admin')

- Validate state:
  exports['district_zero']:ValidateState(state, { 'player', 'district' })
]] 