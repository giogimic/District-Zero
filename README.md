# District Zero

Advanced District Control System for FiveM servers using QBX Core framework.

## Features

- District Control System
- Mission Management
- Faction System
- Advanced UI
- Performance Optimized
- OneSync Compatible

## Dependencies

- [qbx_core](https://github.com/qbox-project/qbx_core)
- [oxmysql](https://github.com/overextended/oxmysql)

## Installation

1. Ensure you have the required dependencies installed
2. Place the resource in your server's resources folder
3. Import the database schema:
   ```sql
   source server/database/migrations.sql
   ```
4. Add the resource to your server.cfg:
   ```cfg
   ensure district_zero
   ```

## Configuration

The resource can be configured through the following files:

- `config/districts.lua` - District settings
- `config/missions.lua` - Mission settings
- `config/factions.lua` - Faction settings

## Usage

### Commands

- `/dzmenu` - Open the District Zero menu
- `/dzhelp` - Show help information

### Key Bindings

- `F5` - Open District Zero menu
- `F6` - Toggle district view
- `F7` - Toggle mission view

### Events

#### Client Events

```lua
-- Open menu
TriggerEvent('dz:client:menu:open')

-- Close menu
TriggerEvent('dz:client:menu:close')

-- Update district
TriggerEvent('dz:client:district:update', districtData)
```

#### Server Events

```lua
-- Start mission
TriggerEvent('dz:server:mission:start', missionId)

-- Complete mission
TriggerEvent('dz:server:mission:complete', missionId)

-- Update district
TriggerEvent('dz:server:district:update', districtId, data)
```

### Exports

#### Client Exports

```lua
-- Get current district
exports['district_zero']:GetCurrentDistrict()

-- Get active missions
exports['district_zero']:GetActiveMissions()

-- Get faction info
exports['district_zero']:GetFactionInfo()
```

#### Server Exports

```lua
-- Get district data
exports['district_zero']:GetDistrictData(districtId)

-- Get mission data
exports['district_zero']:GetMissionData(missionId)

-- Get faction data
exports['district_zero']:GetFactionData(factionId)
```

## Performance

The resource is optimized for performance with:

- Query caching
- Event throttling
- State validation
- Resource cleanup
- OneSync compatibility

## Support

For support, please:

1. Check the [documentation](https://docs.fivem.net/docs/scripting-manual/)
2. Search [existing issues](https://github.com/your-repo/issues)
3. Create a new issue if needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
