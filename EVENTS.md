# District Zero Event Documentation

## Event Naming Convention

All events follow the pattern: `dz:{type}:{action}`

- `dz:client:` - Client-side events
- `dz:server:` - Server-side events
- `dz:shared:` - Shared events

## Client Events

### Menu Events

| Event Name              | Description           | Parameters        | Returns |
| ----------------------- | --------------------- | ----------------- | ------- |
| `dz:client:menu:toggle` | Toggles the main menu | None              | None    |
| `dz:client:menu:close`  | Closes the main menu  | None              | None    |
| `dz:client:menu:update` | Updates menu state    | `{state: object}` | None    |

### District Events

| Event Name                         | Description                    | Parameters             | Returns              |
| ---------------------------------- | ------------------------------ | ---------------------- | -------------------- |
| `dz:client:district:requestUpdate` | Requests district data update  | None                   | None                 |
| `dz:client:district:update`        | Receives district data update  | `{district: object}`   | None                 |
| `dz:client:district:capture`       | Attempts to capture a district | `{districtId: string}` | `{success: boolean}` |
| `dz:client:district:defend`        | Defends a district             | `{districtId: string}` | `{success: boolean}` |

### Mission Events

| Event Name                   | Description         | Parameters            | Returns              |
| ---------------------------- | ------------------- | --------------------- | -------------------- |
| `dz:client:mission:start`    | Starts a mission    | `{missionId: string}` | `{success: boolean}` |
| `dz:client:mission:complete` | Completes a mission | `{missionId: string}` | `{success: boolean}` |
| `dz:client:mission:fail`     | Fails a mission     | `{missionId: string}` | `{success: boolean}` |

## Server Events

### Menu Events

| Event Name                | Description        | Parameters                       | Returns          |
| ------------------------- | ------------------ | -------------------------------- | ---------------- |
| `dz:server:menu:request`  | Requests menu data | `{source: number}`               | `{data: object}` |
| `dz:server:menu:response` | Sends menu data    | `{source: number, data: object}` | None             |

### District Events

| Event Name                    | Description            | Parameters                             | Returns              |
| ----------------------------- | ---------------------- | -------------------------------------- | -------------------- |
| `dz:server:district:request`  | Requests district data | `{source: number}`                     | `{data: object}`     |
| `dz:server:district:response` | Sends district data    | `{source: number, data: object}`       | None                 |
| `dz:server:district:capture`  | Captures a district    | `{source: number, districtId: string}` | `{success: boolean}` |
| `dz:server:district:defend`   | Defends a district     | `{source: number, districtId: string}` | `{success: boolean}` |

### Mission Events

| Event Name                   | Description         | Parameters                            | Returns              |
| ---------------------------- | ------------------- | ------------------------------------- | -------------------- |
| `dz:server:mission:start`    | Starts a mission    | `{source: number, missionId: string}` | `{success: boolean}` |
| `dz:server:mission:complete` | Completes a mission | `{source: number, missionId: string}` | `{success: boolean}` |
| `dz:server:mission:fail`     | Fails a mission     | `{source: number, missionId: string}` | `{success: boolean}` |

## Shared Events

### State Events

| Event Name                | Description           | Parameters        | Returns           |
| ------------------------- | --------------------- | ----------------- | ----------------- |
| `dz:shared:state:update`  | Updates state         | `{state: object}` | None              |
| `dz:shared:state:request` | Requests state update | None              | `{state: object}` |

## Event Usage Examples

### Client-side Event Registration

```lua
RegisterNetEvent('dz:client:menu:toggle')
AddEventHandler('dz:client:menu:toggle', function()
    -- Handle menu toggle
end)
```

### Server-side Event Registration

```lua
RegisterNetEvent('dz:server:district:capture')
AddEventHandler('dz:server:district:capture', function(source, districtId)
    -- Handle district capture
end)
```

### Event Triggering

```lua
-- Client to Server
TriggerServerEvent('dz:server:district:capture', districtId)

-- Server to Client
TriggerClientEvent('dz:client:district:update', source, districtData)
```

## State Management

### State Bag Usage

```lua
-- Setting state
Player(source).state:set('district', districtData, true)

-- Getting state
local districtData = Player(source).state.district
```

## Error Handling

### Event Error Handling

```lua
RegisterNetEvent('dz:client:menu:toggle')
AddEventHandler('dz:client:menu:toggle', function()
    local success, result = pcall(function()
        -- Event handling code
    end)

    if not success then
        -- Error handling
    end
end)
```

## Performance Considerations

1. Rate limiting is implemented for all events
2. State updates are batched where possible
3. Event validation is performed before processing
4. Resource cleanup is handled on stop
