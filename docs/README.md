# District Zero FiveM - Documentation

## Overview

District Zero is a comprehensive district-based competitive gaming system for FiveM, designed specifically for QBox Framework. This system provides dynamic mission generation, territory control, team management, and advanced analytics.

## Features

### Core Systems
- **District Control**: Capture and defend territories with real-time influence tracking
- **Mission System**: Dynamic mission generation with various objectives
- **Team Management**: PvP and PvE team coordination
- **Event System**: Special events and competitions
- **Achievement System**: Progress tracking and rewards

### Advanced Features
- **Analytics Dashboard**: Real-time performance metrics
- **Security System**: Anti-cheat and threat detection
- **Performance Optimization**: Resource usage optimization
- **Modern UI**: React-based interface with real-time updates

## Installation

### Prerequisites
- FiveM Server with QBox Framework
- MariaDB database (as per QBox requirements)
- oxmysql resource

### Quick Start
1. Ensure QBox Framework is installed
2. Add to server.cfg:
   ```cfg
   # QBox Framework (must be loaded first)
   ensure qbx_core
   ensure oxmysql
   ensure ox_lib
   
   # District Zero
   ensure district-zero
   ```
3. Import database schema
4. Configure settings in `shared/config.lua`
5. Restart server

For detailed installation instructions, see [QBOX_INSTALLATION.md](../QBOX_INSTALLATION.md).

## Configuration

### QBox Integration
```lua
Config.QBox = {
    enabled = true,
    coreResource = 'qbx_core',
    databaseResource = 'oxmysql',
    useQBoxNotifications = true,
    useQBoxInventory = false,
    useQBoxVehicles = false
}
```

### Database Configuration
```lua
Config.Database = {
    type = 'oxmysql',
    host = 'localhost',
    port = 3306,
    database = 'qbox',
    username = 'root',
    password = 'your_password'
}
```

## API Reference

### Server Exports
- `GetDistrictsSystem()` - Access district management
- `GetMissionsSystem()` - Access mission system
- `GetTeamsSystem()` - Access team management
- `GetEventsSystem()` - Access event system
- `GetAchievementsSystem()` - Access achievement system

### Client Exports
- `GetUI()` - Access UI components
- `GetClientEvents()` - Access client events
- `GetClientPerformance()` - Access performance data

## Troubleshooting

### Common Issues
1. **Resource fails to start**: Check QBox dependencies are loaded
2. **Database errors**: Verify MariaDB connection and schema
3. **QBox integration issues**: Ensure qbx_core is loaded first

### Debug Mode
Enable debug mode in `shared/config.lua`:
```lua
Config.Development = {
    debug = true,
    verbose = true
}
```

## Support

- **QBox Documentation**: https://docs.qbox.re/
- **GitHub Issues**: https://github.com/district-zero/fivem-mm/issues
- **Installation Guide**: [QBOX_INSTALLATION.md](../QBOX_INSTALLATION.md)

## Version Compatibility

- **QBox Framework**: Latest version
- **FiveM**: Latest artifacts
- **MariaDB**: 10.5+ (as per QBox requirements)
- **District Zero**: 1.0.0+ 