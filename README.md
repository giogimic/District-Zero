# District Zero

A dynamic mission and district control system for FiveM, built on QBX Core. Inspired by APB Reloaded's district-based mission system.

## Core Features

### District System
- **Conflict Zones**: Designated areas where missions and PvP/PvE activities occur
- **Safe Zones**: Areas outside districts where players can safely interact
- **Control Points**: Strategic locations within districts that can be captured
- **Influence Tracking**: District control based on team performance
- **District Status**: Real-time updates on district control and influence

### Mission System
- **District-Based**: Missions only spawn within active conflict districts
- **Team-Specific**: Missions tailored for PvP or PvE teams
- **Dynamic Objectives**: Capture points, eliminate targets, and more
- **Mission Rewards**: Cash rewards based on mission completion
- **Mission History**: Track completed missions and rewards

### Team System
- **Simple Selection**: Choose between PvP or PvE teams
- **Team-Based Matchmaking**: Match with players of the same team type
- **Team Influence**: Contribute to district control as a team
- **Team-Specific Missions**: Access to team-appropriate objectives
- **Team Status**: Track team performance and influence

### UI/UX
- **Modern Design**: Glass morphism interface with smooth animations
- **District Map**: Visual representation of districts and control points
- **Mission Tracking**: Real-time mission progress and objectives
- **Team Selection**: Intuitive team choice interface
- **Notification System**: Clear feedback on actions and events

### Framework Integration
- **QBX Core**: Full compatibility with QBX framework
- **Database-Driven**: Persistent data storage with migrations
- **Type-Safe**: Shared types between client and server
- **Event-Based**: Efficient communication between components
- **Configurable**: Easy to customize through config files

## Installation

1. Ensure you have QBX Core installed and configured
2. Clone this repository into your resources folder
3. Import the SQL files from `server/database/migrations`
4. Add `ensure district-zero` to your server.cfg
5. Restart your server

## Configuration

All configuration is done through `config/config.lua`:

### Districts
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
                name = 'City Hall',
                coords = vector3(-200.0, -800.0, 30.0),
                radius = 50.0,
                influence = 25
            }
        }
    }
}
```

### Missions
```lua
Config.Missions = {
    {
        id = 'pvp_1',
        title = 'Territory Control',
        description = 'Capture and hold control points',
        type = 'pvp',
        reward = 2000,
        district = 'downtown',
        objectives = {
            {
                type = 'capture',
                target = 'control_point',
                count = 1,
                timeLimit = 300
            }
        }
    }
}
```

### Teams
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

## Usage

1. **Entering a District**
   - Approach any marked district on the map
   - Select your team (PvP/PvE) when entering
   - View available missions for your team

2. **Completing Missions**
   - Accept a mission from the mission menu (F5)
   - Follow the objectives in your current district
   - Complete objectives to earn rewards
   - Help your team gain district influence

3. **District Control**
   - Capture control points in districts
   - Complete missions to increase team influence
   - Monitor district status through the UI
   - Work with your team to maintain control

## Development

### Prerequisites
- FiveM Server
- QBX Core
- MySQL/MariaDB

### Building
No build step required - the UI uses CDN-hosted DaisyUI and TailwindCSS.

### Testing
1. Start your FiveM server
2. Join the server
3. Use the mission menu (F5)
4. Test mission acceptance and completion
5. Verify district influence changes

### Documentation
- [Database Schema](server/database/migrations/001_initial_schema.sql)
- [Shared Types](shared/types.lua)
- [Events Documentation](docs/events.md)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- QBX Core team for the framework
- DaisyUI for the UI components
- TailwindCSS for the styling

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
