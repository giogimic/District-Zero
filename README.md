# District Zero

A comprehensive APB-style mission system for FiveM, built on the QBox framework.

## Features

### Current Implementation

- **Framework Integration**
  - QBox/QBX Core compatibility through bridge system
  - ox_lib integration for UI components
  - oxmysql for database operations

- **Mission System**
  - Dynamic mission generation and tracking
  - Multiple objective types (collect, kill, deliver)
  - Mission progress persistence
  - Reward system with money and items
  - Mission history tracking

- **UI/UX**
  - Clean mission interface
  - Objective markers and blips
  - Interactive text UI for objectives
  - Consistent notification system

- **Database**
  - Mission definitions and requirements
  - Progress tracking
  - Completion history
  - Flexible JSON storage for complex data

### Roadmap

1. **Mission System Enhancements**
   - [ ] Mission chains and dependencies
   - [ ] Dynamic mission generation based on player stats
   - [ ] Mission cooldowns and time limits
   - [ ] Mission difficulty scaling
   - [ ] Mission reputation system

2. **UI Improvements**
   - [ ] Mission map integration
   - [ ] Mission statistics and leaderboards
   - [ ] Mission briefing interface
   - [ ] Mission rewards preview
   - [ ] Mission progress visualization

3. **Framework Integration**
   - [ ] Additional framework support (ESX)
   - [ ] Better inventory integration
   - [ ] Job/grade requirements
   - [ ] Gang/faction integration
   - [ ] Phone integration

4. **Performance & Security**
   - [ ] Mission state optimization
   - [ ] Anti-cheat measures
   - [ ] Rate limiting
   - [ ] Mission validation
   - [ ] Resource usage optimization

5. **Additional Features**
   - [ ] Mission sharing
   - [ ] Mission contracts
   - [ ] Mission events
   - [ ] Mission achievements
   - [ ] Mission rewards shop

## Installation

1. Ensure you have the required dependencies:
   - QBox/QBX Core
   - ox_lib
   - oxmysql

2. Import the database schema:
   ```sql
   source sql/migrations/001_missions.sql
   ```

3. Add the resource to your server.cfg:
   ```cfg
   ensure district-zero
   ```

4. Configure the resource in `config.lua`

## Configuration

The resource can be configured through `config.lua`:

```lua
Config = {}

-- Framework settings
Config.Framework = 'qbx' -- or 'qb'
Config.Debug = false

-- Mission settings
Config.MissionTypes = {
    collect = true,
    kill = true,
    deliver = true
}

-- UI settings
Config.UISystem = {
    Notify = 'ox',
    TextUI = 'ox'
}

-- Blip settings
Config.Blips = {
    start = {
        sprite = 1,
        color = 5,
        scale = 0.8
    },
    objective = {
        sprite = 1,
        color = 5,
        scale = 0.8
    }
}
```

## Usage

### Commands

- `/missions` - Open the mission menu

### Events

#### Client Events
- `dz:showMission` - Show mission UI
- `dz:updateMission` - Update mission progress
- `dz:completeMission` - Complete mission
- `dz:failMission` - Fail mission

#### Server Events
- `dz:requestMissions` - Request available missions
- `dz:acceptMission` - Accept a mission
- `dz:completeObjective` - Complete an objective

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- QBox Framework
- ox_lib
- oxmysql
- FiveM Community
