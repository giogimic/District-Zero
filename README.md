# District Zero

A comprehensive district management system for FiveM servers, featuring territory control, resource management, and dynamic events.

## Features

### District Management
- **District Types**
  - Residential districts
  - Commercial districts
  - Industrial districts
  - Special districts
- **District Control**
  - Capture system
  - Defense system
  - Upgrade system
  - Resource management
- **District Stats**
  - Population tracking
  - Income generation
  - Defense rating
  - Resource levels

### Map System
- **Interactive Map**
  - District visualization
  - Territory boundaries
  - Status indicators
  - Event markers
- **Navigation**
  - Waypoint system
  - Route guidance
  - Distance tracking
  - Arrival notifications
- **Minimap Integration**
  - Customizable position
  - Adjustable size
  - Zoom controls
  - Radar features

### UI Features
- **District List**
  - Search functionality
  - Filter options
  - Sort capabilities
  - Status indicators
- **District Details**
  - Comprehensive info
  - Resource display
  - Action buttons
  - Event tracking
- **Map Controls**
  - Zoom controls
  - View reset
  - Layer toggles
  - Navigation tools

## Installation

1. Download the latest release
2. Extract to your server's resources folder
3. Add to your server.cfg:
```cfg
ensure district-zero
```

## Configuration

### District Settings
```lua
Config.Districts = {
    -- District generation settings
    numDistricts = 10,
    cityCenter = vector3(0.0, 0.0, 0.0),
    radius = 1000.0,
    
    -- District types and weights
    types = {
        residential = { weight = 0.4 },
        commercial = { weight = 0.3 },
        industrial = { weight = 0.2 },
        special = { weight = 0.1 }
    }
}
```

### Map Settings
```lua
Config.MapSettings = {
    -- Minimap settings
    minimap = {
        enabled = true,
        position = {x = 0.0, y = 0.0},
        size = {width = 0.2, height = 0.2},
        zoom = 0.5
    },
    
    -- Navigation settings
    navigation = {
        enabled = true,
        routeColor = {r = 255, g = 255, b = 255, a = 200},
        routeWidth = 3.0
    }
}
```

## Usage

### Commands
- `/district` - Open district management UI
- `/districtinfo [id]` - View district information
- `/capture [id]` - Attempt to capture a district
- `/defend [id]` - Defend current district
- `/upgrade [id]` - Upgrade district facilities

### Exports
```lua
-- Get current district
exports['district-zero']:GetCurrentDistrict()

-- Check if in district
exports['district-zero']:IsInDistrict()

-- Get district info
exports['district-zero']:GetDistrictInfo(districtId)

-- Update district
exports['district-zero']:UpdateDistrict(districtId, data)

-- Set waypoint
exports['district-zero']:SetWaypoint(districtId)

-- Clear waypoint
exports['district-zero']:ClearWaypoint()

-- Toggle minimap
exports['district-zero']:ToggleMinimap(show)

-- Toggle navigation
exports['district-zero']:ToggleNavigation(enable)
```

### Events
```lua
-- District events
RegisterNetEvent('district:enter')
RegisterNetEvent('district:exit')
RegisterNetEvent('district:capture')
RegisterNetEvent('district:defend')
RegisterNetEvent('district:upgrade')

-- Map events
RegisterNetEvent('district:waypointSet')
RegisterNetEvent('district:waypointReached')
RegisterNetEvent('district:minimapToggle')
```

## Dependencies
- QBX Core
- ESX (optional)
- Standalone (optional)

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Support
For support, join our Discord server or create an issue on GitHub.

## Credits
- Original concept by [Your Name]
- Developed by [Your Team]
- Special thanks to [Contributors] 