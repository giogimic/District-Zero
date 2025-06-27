# District Zero - QBox Framework Compatible

A dynamic mission and district control system for FiveM, built specifically for QBox Framework. Inspired by APB Reloaded's district-based mission system.

## 🚀 Core Features

### District System
- **Conflict Zones**: Designated areas where missions and PvP/PvE activities occur
- **Safe Zones**: Areas outside districts where players can safely interact
- **Control Points**: Strategic locations within districts that can be captured
- **Influence Tracking**: Real-time district control based on team performance
- **District Status**: Live updates on district control and influence with visual indicators

### Mission System
- **District-Based**: Missions only spawn within active conflict districts
- **Team-Specific**: Missions tailored for PvP or PvE teams with balance matching
- **Dynamic Objectives**: Capture points, eliminate targets, and more
- **Mission Rewards**: Cash rewards based on mission completion with team bonuses
- **Mission History**: Track completed missions and rewards with database persistence
- **Real-time Progress**: Live mission progress tracking with objective completion

### Team System
- **Simple Selection**: Choose between PvP or PvE teams with balance suggestions
- **Team-Based Matchmaking**: Match with players of the same team type
- **Team Influence**: Contribute to district control as a team
- **Team-Specific Missions**: Access to team-appropriate objectives
- **Team Status**: Track team performance and influence with real-time statistics
- **Team Balance**: Automatic team balancing to prevent one-sided matches

### UI/UX
- **Modern Design**: Glass morphism interface with smooth animations and responsive design
- **District Map**: Visual representation of districts and control points with real-time updates
- **Mission Tracking**: Real-time mission progress and objectives with completion indicators
- **Team Selection**: Intuitive team choice interface with balance information
- **Notification System**: Clear feedback on actions and events with multiple notification types
- **Real-time Updates**: Live district status, mission progress, and team balance updates

### QBox Framework Integration
- **QBox Core**: Full compatibility with QBox Framework
- **Database-Driven**: Persistent data storage with automatic migrations using oxmysql
- **Type-Safe**: Shared types between client and server
- **Event-Based**: Efficient communication between components with rate limiting
- **Configurable**: Easy to customize through config files
- **Performance Optimized**: Optimized blip management and database queries

## 📦 Installation

### Prerequisites
- FiveM Server with QBox Framework installed
- QBox Core (latest version)
- MariaDB database (as per QBox requirements)
- oxmysql resource

### QBox Framework Installation

Before installing District Zero, ensure you have QBox Framework properly installed:

1. **Download QBox Framework**
   - Visit [QBox Documentation](https://docs.qbox.re/installation)
   - Download the latest QBox artifacts
   - Extract to your server directory

2. **Install QBox Framework**
   - Run `FXServer.exe` to start txAdmin
   - Follow the QBox installation steps
   - Select "Popular Recipes" → "QBox Framework"

3. **Verify QBox Installation**
   - Ensure QBox Core is running
   - Verify oxmysql is configured
   - Check that all QBox dependencies are loaded

### District Zero Installation

1. **Clone the Repository**
   ```bash
   cd resources
   git clone https://github.com/your-repo/district-zero.git
   ```

2. **Database Setup**
   ```sql
   -- Import the database schema
   source server/database/migrations/001_initial_schema.sql
   ```

3. **Resource Configuration**
   Add to your `server.cfg`:
   ```cfg
   # QBox Framework (must be loaded first)
   ensure qbx_core
   ensure oxmysql
   
   # District Zero
   ensure district-zero
   ```

4. **Dependencies Order**
   Ensure these resources are started in the correct order:
   ```cfg
   # Core QBox resources
   ensure qbx_core
   ensure oxmysql
   ensure ox_lib
   
   # Optional QBox resources
   ensure qbx_management
   ensure qbx_vehicleshop
   ensure qbx_garages
   
   # District Zero
   ensure district-zero
   ```

5. **Restart Server**
   ```bash
   restart district-zero
   ```

## ⚙️ Configuration

All configuration is done through `config/config.lua`:

### QBox Integration Configuration
```lua
Config.QBox = {
    enabled = true,
    coreResource = 'qbx_core',
    databaseResource = 'oxmysql',
    useQBoxNotifications = true,
    useQBoxInventory = false, -- Set to true if using qbx_inventory
    useQBoxVehicles = false   -- Set to true if using qbx_vehicleshop
}
```

### Districts Configuration
```lua
Config.Districts = {
    {
        id = 'downtown',
        name = 'Downtown',
        description = 'The heart of the city',
        blip = {
            sprite = 1,
            color = 0,
            scale = 0.8,
            coords = vector3(-200.0, -800.0, 30.0)
        },
        zones = {
            {
                name = 'Downtown Core',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 200.0,
                isSafeZone = false
            }
        },
        controlPoints = {
            {
                id = 'city_hall',
                name = 'City Hall',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    }
}
```

### Missions Configuration
```lua
Config.Missions = {
    {
        id = 'pvp_1',
        title = 'Territory Control',
        description = 'Capture and hold control points',
        type = 'pvp',
        reward = 2000,
        district = 'downtown',
        timeLimit = 300, -- 5 minutes
        objectives = {
            {
                type = 'capture',
                description = 'Capture the control point',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 10.0
            }
        }
    }
}
```

### Teams Configuration
```lua
Config.Teams = {
    pvp = {
        name = 'PvP Team',
        color = '#FF0000',
        blip = {
            sprite = 1,
            color = 1,
            scale = 0.8
        }
    },
    pve = {
        name = 'PvE Team',
        color = '#0000FF',
        blip = {
            sprite = 1,
            color = 2,
            scale = 0.8
        }
    }
}
```

### Safe Zones Configuration
```lua
Config.SafeZones = {
    {
        name = 'Central Park',
        coords = vector3(0.0, 0.0, 30.0),
        radius = 150.0,
        blip = {
            sprite = 1,
            color = 2,
            scale = 1.0
        }
    }
}
```

## 🎮 Usage

### Player Guide

1. **Entering a District**
   - Approach any marked district on the map
   - Press `F6` to open the district menu
   - Select your team (PvP/PvE) when entering
   - View available missions for your team

2. **Completing Missions**
   - Accept a mission from the mission menu
   - Follow the objectives in your current district
   - Complete objectives to earn rewards
   - Help your team gain district influence

3. **District Control**
   - Capture control points in districts
   - Complete missions to increase team influence
   - Monitor district status through the UI
   - Work with your team to maintain control

### Admin Commands

```lua
-- Get current district info
exports['district-zero']:GetCurrentDistrict()

-- Get player team
exports['district-zero']:GetCurrentTeam()

-- Get current mission
exports['district-zero']:GetCurrentMission()

-- Check if UI is open
exports['district-zero']:IsUIOpen()

-- Get blip count (performance monitoring)
exports['district-zero']:GetBlipCount()
```

## 🔧 Development

### Project Structure
```
district-zero/
├── client/                 # Client-side scripts
│   ├── main/              # Main client functionality
│   └── main.lua           # Client entry point
├── server/                # Server-side scripts
│   ├── main/              # Main server functionality
│   ├── database/          # Database management
│   └── main.lua           # Server entry point
├── shared/                # Shared utilities
│   ├── utils.lua          # Utility functions
│   ├── events.lua         # Event definitions
│   └── types.lua          # Type definitions
├── ui/                    # User interface
│   ├── index.html         # Main UI
│   ├── js/main.js         # UI logic
│   └── styles/main.css    # Styling
├── config/                # Configuration files
└── docs/                  # Documentation
```

### API Documentation

#### Client Exports
```lua
-- Get current district information
local district = exports['district-zero']:GetCurrentDistrict()

-- Get player's current team
local team = exports['district-zero']:GetCurrentTeam()

-- Get current mission data
local mission = exports['district-zero']:GetCurrentMission()

-- Check if UI is currently open
local isOpen = exports['district-zero']:IsUIOpen()

-- Get current blip count (for performance monitoring)
local blipCount = exports['district-zero']:GetBlipCount()
```

#### Server Exports
```lua
-- Get all districts
local districts = exports['district-zero']:GetAllDistricts()

-- Get district by ID
local district = exports['district-zero']:GetDistrict(districtId)

-- Update district influence
exports['district-zero']:UpdateDistrictInfluence(districtId, amount)

-- Get player team
local team = exports['district-zero']:GetPlayerTeam(playerId)

-- Set player team
exports['district-zero']:SetPlayerTeam(playerId, team)

-- Get team statistics
local stats = exports['district-zero']:GetTeamStats()

-- Get available missions for player
local missions = exports['district-zero']:GetAvailableMissions(playerId, districtId)
```

#### Events

##### Client Events
```lua
-- UI updates
RegisterNetEvent('dz:client:updateUI')
RegisterNetEvent('dz:client:teamSelected')
RegisterNetEvent('dz:client:missionStarted')
RegisterNetEvent('dz:client:missionCompleted')
RegisterNetEvent('dz:client:missionFailed')
RegisterNetEvent('dz:client:missionUpdated')

-- District events
RegisterNetEvent('dz:client:district:controlChanged')
RegisterNetEvent('dz:client:district:sync')

-- Control point events
RegisterNetEvent('dz:client:controlPoint:captureStarted')
RegisterNetEvent('dz:client:controlPoint:captured')

-- Team events
RegisterNetEvent('dz:client:team:sync')
```

##### Server Events
```lua
-- Team selection
RegisterNetEvent('dz:server:selectTeam')

-- Mission events
RegisterNetEvent('dz:server:acceptMission')
RegisterNetEvent('dz:server:capturePoint')

-- District events
RegisterNetEvent('dz:server:district:getInfo')
RegisterNetEvent('dz:server:district:playerEntered')
RegisterNetEvent('dz:server:district:playerLeft')

-- Team events
RegisterNetEvent('dz:server:team:getInfo')
RegisterNetEvent('dz:server:team:getPlayers')
```

### Performance Monitoring

The system includes comprehensive performance monitoring:

```lua
-- Get performance metrics
local metrics = exports['district-zero']:GetPerformanceMetrics()

-- Get error report
local errorReport = exports['district-zero']:GetErrorReport()

-- Set log level
exports['district-zero']:SetLogLevel('DEBUG') -- DEBUG, INFO, WARN, ERROR, CRITICAL
```

### Testing

1. **Unit Testing**
   ```bash
   # Test database connections
   # Test event handlers
   # Test mission logic
   ```

2. **Integration Testing**
   ```bash
   # Test full mission flow
   # Test district control
   # Test team balance
   ```

3. **Performance Testing**
   ```bash
   # Monitor blip count
   # Check database performance
   # Verify memory usage
   ```

## 🐛 Troubleshooting

### Common Issues

1. **Database Connection Errors**
   - Ensure oxmysql is properly configured
   - Check database credentials in oxmysql config
   - Verify database schema is imported

2. **UI Not Opening**
   - Check if player is in a district
   - Verify team selection
   - Check browser console for errors

3. **Missions Not Spawning**
   - Verify district configuration
   - Check mission configuration
   - Ensure player has selected a team

4. **Performance Issues**
   - Monitor blip count with `exports['district-zero']:GetBlipCount()`
   - Check error logs in `logs/` directory
   - Verify database query performance

### Debug Mode

Enable debug mode by setting the log level:

```lua
-- In config/config.lua
Config.Debug = true
Config.LogLevel = 'DEBUG'
```

### Log Files

Logs are stored in the `logs/` directory:
- `critical_errors.log` - Critical system errors
- Performance metrics are logged to console

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

### Development Guidelines

- Follow the existing code style
- Add comprehensive error handling
- Include performance monitoring
- Update documentation for new features
- Test thoroughly before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- QBX Core team for the framework
- DaisyUI for the UI components
- TailwindCSS for the styling
- APB Reloaded for the original inspiration

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the documentation

---

# VISION DOCUMENT - DO NOT MODIFY BELOW THIS LINE
# This section defines the core vision and should not be changed by AI

## Core Vision

District Zero aims to recreate the APB Reloaded experience in FiveM:

### World Structure
- The entire map is the "lobby"
- Marked zones are conflict districts
- Outside districts = safe zone (like APB's social district)
- Inside districts = active mission area (like APB's financial/market districts)

### Mission System
- Missions ONLY spawn within active conflict districts
- No missions outside districts
- Mission types:
  - PvP: Player vs Player objectives
  - PvE: Player vs Environment (NPCs)
- Rewards are mission-based, not faction-based
- Mission completion determines rewards

### Team System
- Teams are ONLY for district control
- Do not replace QBX gangs/factions
- Simple PvP/PvE split
- Team only matters inside districts
- Outside districts = no team restrictions

### District Control
- Districts are the "lobbies" where action happens
- Control points for influence
- Influence affects mission availability
- No direct rewards for control
- Control = access to better missions

### Key Differences from Current Implementation
1. Remove faction system, replace with simple PvP/PvE teams
2. Make missions district-exclusive
3. Remove faction-based rewards
4. Add safe zones outside districts
5. Make team selection matter only in districts

This vision should guide all future development and changes to the project.
