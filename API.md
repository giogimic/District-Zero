# District Zero API Documentation

## Overview

District Zero is a dynamic territory control system for FiveM servers. This document outlines the available API endpoints, events, and exports.

## Events

### Client Events

#### Menu Events

- `dz:menu:toggle`

  - Toggles the main menu
  - Parameters: None
  - Returns: None

- `dz:menu:close`

  - Closes the main menu
  - Parameters: None
  - Returns: None

- `dz:menu:update`
  - Updates menu state
  - Parameters: `state` (table)
  - Returns: None

#### District Events

- `dz:district:requestUpdate`

  - Requests district data update
  - Parameters: None
  - Returns: None

- `dz:district:update`

  - Receives district data update
  - Parameters: `data` (table)
  - Returns: None

- `dz:district:capture`

  - Attempts to capture a district
  - Parameters: `districtId` (string)
  - Returns: None

- `dz:district:defend`
  - Defends a district
  - Parameters: `districtId` (string)
  - Returns: None

#### Faction Events

- `dz:faction:requestUpdate`

  - Requests faction data update
  - Parameters: None
  - Returns: None

- `dz:faction:update`

  - Receives faction data update
  - Parameters: `data` (table)
  - Returns: None

- `dz:faction:join`

  - Joins a faction
  - Parameters: `factionId` (string)
  - Returns: None

- `dz:faction:leave`
  - Leaves a faction
  - Parameters: None
  - Returns: None

#### Mission Events

- `dz:mission:start`

  - Starts a mission
  - Parameters: `missionId` (string)
  - Returns: None

- `dz:mission:complete`

  - Completes a mission
  - Parameters: `missionId` (string)
  - Returns: None

- `dz:mission:fail`
  - Fails a mission
  - Parameters: `missionId` (string)
  - Returns: None

### Server Events

#### Menu Events

- `dz:menu:request`

  - Requests menu data
  - Parameters: None
  - Returns: None

- `dz:menu:response`
  - Sends menu data
  - Parameters: `data` (table)
  - Returns: None

#### District Events

- `dz:district:request`

  - Requests district data
  - Parameters: None
  - Returns: None

- `dz:district:response`
  - Sends district data
  - Parameters: `data` (table)
  - Returns: None

#### Faction Events

- `dz:faction:request`

  - Requests faction data
  - Parameters: None
  - Returns: None

- `dz:faction:response`
  - Sends faction data
  - Parameters: `data` (table)
  - Returns: None

## Exports

### Client Exports

#### Menu Exports

- `ShowNUI(menu)`

  - Shows NUI menu
  - Parameters: `menu` (string)
  - Returns: `boolean`

- `HideNUI()`

  - Hides NUI
  - Parameters: None
  - Returns: `boolean`

- `ToggleNUI(menu)`
  - Toggles NUI menu
  - Parameters: `menu` (string)
  - Returns: `boolean`

#### Key Binding Exports

- `GetKeyBinding(action)`

  - Gets key binding
  - Parameters: `action` (string)
  - Returns: `string`

- `SetKeyBinding(action, key)`

  - Sets key binding
  - Parameters: `action` (string), `key` (string)
  - Returns: `boolean`

- `GetAllKeyBindings()`
  - Gets all key bindings
  - Parameters: None
  - Returns: `table`

#### Performance Exports

- `ThrottleEvent(eventName, callback, time)`

  - Throttles event execution
  - Parameters: `eventName` (string), `callback` (function), `time` (number)
  - Returns: `boolean`

- `SetCache(key, value, ttl)`

  - Sets cache value
  - Parameters: `key` (string), `value` (any), `ttl` (number)
  - Returns: None

- `GetCache(key)`

  - Gets cache value
  - Parameters: `key` (string)
  - Returns: `any`

- `OptimizeLoop(callback, interval)`
  - Optimizes loop execution
  - Parameters: `callback` (function), `interval` (number)
  - Returns: `function`

### Server Exports

#### Database Exports

- `Query(query, params)`

  - Executes database query
  - Parameters: `query` (string), `params` (table)
  - Returns: `table`

- `Transaction(queries)`
  - Executes database transaction
  - Parameters: `queries` (table)
  - Returns: `boolean`

## Error Handling

All functions and events include proper error handling and validation. Errors are logged and can be caught using try-catch blocks.

## Performance Considerations

- Event throttling is implemented to prevent spam
- Cache management is available for frequently accessed data
- Loop optimization is provided for performance-critical operations
- Resource cleanup is handled automatically

## Examples

### Menu Usage

```lua
-- Show menu
exports['district_zero']:ShowNUI('main')

-- Hide menu
exports['district_zero']:HideNUI()

-- Toggle menu
exports['district_zero']:ToggleNUI('main')
```

### Key Binding Usage

```lua
-- Get key binding
local key = exports['district_zero']:GetKeyBinding('menu')

-- Set key binding
exports['district_zero']:SetKeyBinding('menu', 'F5')

-- Get all bindings
local bindings = exports['district_zero']:GetAllKeyBindings()
```

### Performance Usage

```lua
-- Throttle event
exports['district_zero']:ThrottleEvent('dz:district:update', function()
    -- Update logic
end, 5000)

-- Cache data
exports['district_zero']:SetCache('district_data', data, 300)

-- Get cached data
local data = exports['district_zero']:GetCache('district_data')

-- Optimize loop
local optimizedLoop = exports['district_zero']:OptimizeLoop(function()
    -- Loop logic
end, 1000)
```

## Version History

- 1.0.0: Initial release
- 1.0.1: Added performance optimizations
- 1.0.2: Added proper error handling
- 1.0.3: Added proper documentation
