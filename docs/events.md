# District Zero Events

This document lists all events used in District Zero for client-server communication.

## Client Events

### UI Events
- `dz:client:initialize`
  - Triggered when resource starts
  - No parameters
  - Initializes client-side systems

- `dz:client:updateUI`
  - Triggered when UI data needs updating
  - Parameters:
    ```lua
    {
        missions = Mission[],
        districts = District[],
        currentDistrict = District,
        currentTeam = string
    }
    ```

- `dz:client:missionStarted`
  - Triggered when a mission starts
  - Parameters:
    ```lua
    {
        id = string,
        title = string,
        description = string,
        objectives = MissionObjective[]
    }
    ```

- `dz:client:missionUpdated`
  - Triggered when mission progress updates
  - Parameters: Same as missionStarted

- `dz:client:missionCompleted`
  - Triggered when mission is completed
  - No parameters

- `dz:client:missionFailed`
  - Triggered when mission fails
  - No parameters

- `dz:client:districtUpdated`
  - Triggered when district status changes
  - Parameters:
    ```lua
    {
        id = string,
        influence = number,
        controlPoints = ControlPoint[]
    }
    ```

## Server Events

### Mission Events
- `dz:server:getUIData`
  - Triggered when client requests UI data
  - No parameters
  - Returns: UIData object

- `dz:server:selectTeam`
  - Triggered when player selects a team
  - Parameters:
    ```lua
    {
        team = 'pvp'|'pve'
    }
    ```

- `dz:server:acceptMission`
  - Triggered when player accepts a mission
  - Parameters:
    ```lua
    {
        missionId = string
    }
    ```

- `dz:server:capturePoint`
  - Triggered when player captures a control point
  - Parameters:
    ```lua
    {
        missionId = string,
        objectiveId = number
    }
    ```

## NUI Callbacks

### UI Callbacks
- `closeUI`
  - Called when UI is closed
  - No parameters
  - Returns: 'ok'

- `selectTeam`
  - Called when team is selected
  - Parameters:
    ```lua
    {
        team = 'pvp'|'pve'
    }
    ```
  - Returns: 'ok'

- `acceptMission`
  - Called when mission is accepted
  - Parameters:
    ```lua
    {
        missionId = string
    }
    ```
  - Returns: 'ok'

## Event Flow

1. **Resource Start**
   ```
   Server -> Client: dz:client:initialize
   ```

2. **UI Open**
   ```
   Client -> Server: dz:server:getUIData
   Server -> Client: dz:client:updateUI
   ```

3. **Team Selection**
   ```
   Client -> Server: dz:server:selectTeam
   Server -> Client: dz:client:updateUI
   ```

4. **Mission Start**
   ```
   Client -> Server: dz:server:acceptMission
   Server -> Client: dz:client:missionStarted
   ```

5. **Mission Progress**
   ```
   Client -> Server: dz:server:capturePoint
   Server -> Client: dz:client:missionUpdated
   ```

6. **Mission Complete**
   ```
   Server -> Client: dz:client:missionCompleted
   Server -> Client: dz:client:districtUpdated
   ``` 